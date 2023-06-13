require 'sequel'
require 'active_record'
require 'business_time'
require 'bigdecimal'

# Database connections
const = Sequel.connect("mysql2://root:@localhost/stock")
conlt = Sequel.connect("sqlite://c:/ruby/portlt/db/development.sqlite3")

today = Date.today

num_business_days = 1.business_day
yesterday = today - num_business_days

sql_upd = <<-SQL
  UPDATE buy B
  SET dividend =
  (SELECT DIVIDEND FROM dividend D
  WHERE B.name = D.name)
SQL
const.run(sql_upd)

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
df1 = const[sql, yesterday].all

sql = <<-SQL
  SELECT name, aq_eps AS eps
  FROM epss
  WHERE year = 2022 AND quarter = 4
SQL
df2 = conlt[sql].all

df_merge = df1.map do |row1|
  row2 = df2.find { |row| row[:name] == row1[:name] }
  next unless row2

  shares = row1[:volbuy].to_i
  cost_amt = (shares * row1[:u_cost]).round(2)
  mkt_amt = (shares * row1[:mkt_price]).round(2)
  div_amt = (shares * row1[:dividend]).round(2)
  mkt_percent = (div_amt / mkt_amt * 100).round(2)
  cst_percent = (div_amt / cost_amt * 100).round(2)
  dpr_percent = (row1[:dividend] / row2[:eps] * 100).round(2)

  {
    prd: row1[:prd],
    name: row1[:name],
    shares: shares,
    u_cost: "฿%.2f" % row1[:u_cost],
    cost_amt: "฿%,.2f" % cost_amt,
    mkt_price: "฿%.2f" % row1[:mkt_price],
    mkt_amt: "฿%,.2f" % mkt_amt,
    dividend: "฿%.4f" % row1[:dividend],
    div_amt: "฿%,.2f" % div_amt,
    cst_percent: "%.2f%%" % cst_percent,
    mkt_percent: "%.2f%%" % mkt_percent,
    eps: "฿%.4f" % row2[:eps],
    dpr_percent: "%.2f%%" % dpr_percent
  }
end.compact.sort_by { |row| [row[:prd], row[:name]] }

# Display the results
puts "  name\tshares\tu_cost\tcost_amt\tmkt_price\tmkt_amt\tdividend\tdiv_amt\tcst-%\tmkt-%\teps\tdpr-%"
puts "prd"
puts "---------------------------------------------------------------------------------------------------------"
df_merge.each do |row|
  puts "#{row[:prd]}\t#{row[:name]}\t#{row[:shares].to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}\t#{row[:u_cost]}\t#{row[:cost_amt]}\t
  #{row[:mkt_price]}\t#{row[:mkt_amt]}\t#{row[:dividend]}\t#{row[:div_amt]}\t#{row[:cst_percent]}\t#{row[:mkt_percent]}\t#{row[:eps]}\t#{row[:dpr_percent]}"
end