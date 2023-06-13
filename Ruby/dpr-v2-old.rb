require 'sequel'
require 'active_support/core_ext/date/calculations'
require 'awesome_print'

db_stock = Sequel.mysql2("stock", host: 'localhost', user: 'root', password: '')
db_development = Sequel.sqlite('C:\\ruby\\portlt\\db\\development.sqlite3')

today = Date.today
# yesterday = today.business_days_ago(1)

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
df1 = db_stock.fetch(sql, today).all

sql = <<-SQL
  SELECT name, aq_eps AS eps 
  FROM epss 
  WHERE year = 2022 AND quarter = 4
SQL
df2 = db_development.fetch(sql).all

merged = df1.map do |row1|
  row2 = df2.find { |r| r[:name] == row1[:name] }
  row1.merge(row2) if row2
end.compact

formatted_rows = merged.map do |row|
  cost_amt = row[:volbuy] * row[:u_cost]
  mkt_amt = row[:volbuy] * row[:mkt_price]
  div_amt = row[:volbuy] * row[:dividend]
  {
    name: row[:name],
    shares: row[:volbuy],
    u_cost: "฿%.2f" % row[:u_cost],
    cost_amt: "฿%.2f" % cost_amt,
    mkt_price: "฿%.2f" % row[:mkt_price],
    mkt_amt: "฿%.2f" % mkt_amt,
    dividend: "฿%.4f" % row[:dividend],
    div_amt: "฿%.2f" % div_amt,
    cst_percent: "%.2f%%" % (div_amt / cost_amt * 100),
    mkt_percent: "%.2f%%" % (div_amt / mkt_amt * 100),
    eps: "฿%.4f" % row[:eps],
    dpr_percent: "%.2f%%" % (row[:dividend] / row[:eps] * 100)
  }
end

# Display the results
puts "  name\tshares\tu_cost\tcost_amt\tmkt_price\tmkt_amt\tdividend\tdiv_amt\tcst-%\tmkt-%\teps\tdpr-%"
puts "prd"
puts "---------------------------------------------------------------------------------------------------------"
# df_merge.each do |row|
formatted_rows.each do |row|  
  puts "#{row[:prd]}\t#{row[:name]}\t#{row[:shares].to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}\t#{row[:u_cost]}\t#{row[:cost_amt]}\t
  #{row[:mkt_price]}\t#{row[:mkt_amt]}\t#{row[:dividend]}\t#{row[:div_amt]}\t#{row[:cst_percent]}\t#{row[:mkt_percent]}\t#{row[:eps]}\t#{row[:dpr_percent]}"
end
