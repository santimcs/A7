require 'sequel'
require 'awesome_print'

db_stock = Sequel.mysql2("stock", host: 'localhost', user: 'root', password: '')
db_development = Sequel.sqlite('C:\\ruby\\portlt\\db\\development.sqlite3')
db_portpg = Sequel.postgres("portpg_development", host: 'localhost', user: 'postgres', password: 'admin')

puts "Enter date "
inp_date = gets.chomp

sql_upd = <<-SQL
  UPDATE buy B
  SET dividend =
  (SELECT DIVIDEND FROM dividend D
  WHERE B.name = D.name)
SQL
db_stock.run(sql_upd)

sql = <<-SQL
  SELECT B.name, volbuy, B.price AS u_cost, 
  dividend, P.price AS mkt_price, period AS prd
  FROM buy B 
  JOIN price P
  ON B.name = P.name
  WHERE P.date = ?
  AND active = 1
  ORDER BY period, name
SQL
df1 = db_stock.fetch(sql, inp_date).all

sql = <<-SQL
  SELECT name, aq_eps AS eps 
  FROM epss 
  WHERE year = 2022 AND quarter = 4
SQL
df2 = db_development.fetch(sql).all

sql = <<-SQL
  SELECT name, market 
  FROM tickers
SQL
df3 = db_portpg.fetch(sql).all

merged = df1.map do |row1|
  row2 = df2.find { |r| r[:name] == row1[:name] }
  row3 = df3.find { |r| r[:name] == row1[:name] }
  row1.merge(row2).merge(row3) if row2 && row3
end.compact

formatted_rows = merged.map do |row|
  cost_amt = row[:volbuy] * row[:u_cost]
  mkt_amt = row[:volbuy] * row[:mkt_price]
  div_amt = row[:volbuy] * row[:dividend]
  {
    prd: row[:prd],
    name: row[:name],
    shares: row[:volbuy].to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse,
    u_cost: "฿%.2f" % row[:u_cost],
    mkt_price: "฿%.2f" % row[:mkt_price],
    dividend: "฿%.4f" % row[:dividend],
    cst_percent: "%.2f%%" % (div_amt / cost_amt * 100),
    mkt_percent: "%.2f%%" % (div_amt / mkt_amt * 100),
    eps: "฿%.4f" % row[:eps],
    dpr_percent: "%.2f%%" % (row[:dividend] / row[:eps] * 100),
    market: row[:market]
  }
end

# Display the results
puts "prd\tname\tshares\tdiv\tu_cost\tprice\teps      \tcst-%\tmkt-%\tdpr-%\tmarket"
formatted_rows.each do |row|  
  puts "#{row[:prd]}\t#{row[:name]}\t#{row[:shares]}\t#{row[:dividend]}\t#{row[:u_cost]}\t#{row[:mkt_price]}\t#{row[:eps]}   \t#{row[:cst_percent]}\t#{row[:mkt_percent]}\t#{row[:dpr_percent]}\t#{row[:market]}"
end
