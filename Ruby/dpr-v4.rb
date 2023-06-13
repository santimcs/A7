require 'mysql2'
require 'sqlite3'
require 'pg'
require 'daru'

today = Date.today
yesterday = today - 1

db_stock = Mysql2::Client.new(host: "localhost", username: "root", database: "stock")
db_portlt = SQLite3::Database.new("c:\\ruby\\portlt\\db\\development.sqlite3")
db_portpg = PG::Connection.new(dbname: "portpg_development", user: "postgres", password: "admin", host: "localhost")

sql_upd = <<~SQL
  UPDATE buy B
  SET dividend =
  (SELECT DIVIDEND FROM dividend D
  WHERE B.name = D.name)
SQL

db_stock.query(sql_upd)

sql = <<~SQL
  SELECT B.name, volbuy, B.price AS u_cost,
  dividend, P.price AS price, period AS prd
  FROM buy B
  JOIN price P
  ON B.name = P.name
  WHERE P.date = "#{yesterday}"
  AND active = 1
  ORDER BY period, name
SQL

df1 = Daru::DataFrame.from_sql(db_stock, sql)
df1['shares'] = df1['volbuy'].to_a.map(&:to_i)
df1['mkt-%'] = df1['dividend'].to_a.zip(df1['price'].to_a).map { |div, price| (div / price * 100).round(2) }
df1['cst-%'] = df1['dividend'].to_a.zip(df1['u_cost'].to_a).map { |div, cost| (div / cost * 100).round(2) }

sql = <<~SQL
  SELECT name, aq_eps AS eps
  FROM epss
  WHERE year = 2022 AND quarter = 4
SQL

df2 = Daru::DataFrame.from_sql(db_portlt, sql)

df_merge = df1.join(df2, on: ['name'], how: :inner)
df_merge['dpr-%'] = df_merge['dividend'].to_a.zip(df_merge['eps'].to_a).map { |div, eps| (div / eps * 100).round(2) }

sql = <<~SQL
  SELECT name, market
  FROM tickers
SQL

df3 = Daru::DataFrame.from_sql(db_portpg, sql)

df_merge2 = df_merge.join(df3, on: ['name'], how: :inner)
df_merge2.index = df_merge2['prd'].to_a

colu = %w[name shares dividend u_cost price eps cst-% mkt-% dpr-% market]
format_dict = {
  'shares' => -> (n) { n.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse },
  'u_cost' => -> (n) { "฿%.2f" % n },
  'price' => -> (n) { "฿%.2f" % n },
  'dividend' => -> (n) { "฿%.4f" % n },
  'eps' => -> (n) { "฿%.4f" % n },
  'cst-%' => -> (n) { "%.2f%%" % n },
  'mkt-%' => -> (n) {"%.2f%%" % n },
  'dpr-%' => -> (n) { "%.2f%%" % n }
  }
  
  df_merge2.sort(['name'], ascending: [true]).each_row_with_index do |row, index|
    output = []
    colu.each do |col|
      if format_dict.key?(col)
        output << format_dict[col].call(row[col])
      else
        output << row[col].to_s
      end
    end
    puts "#{index}\t#{output.join("\t")}"
  end
  