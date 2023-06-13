require 'mysql2'
require 'active_support'
require 'active_support/core_ext/integer/time'

date_input = ARGV[0] || (Date.today - 1.business_day).strftime('%Y-%m-%d')
#date_input = ARGV[0].presence || (Date.today - 1.business_day).strftime('%Y-%m-%d')

client = Mysql2::Client.new(
  host: 'localhost',
  username: 'root',
  password: '',
  database: 'stock'
)

sql_upd = <<~SQL
  UPDATE buy B
  SET dividend =
  (SELECT DIVIDEND FROM dividend D
  WHERE B.name = D.name)
SQL

client.query(sql_upd)

sql = <<~SQL
  SELECT B.name, volbuy, B.price AS u_cost,
  dividend, P.price AS mkt_price, period AS prd
  FROM buy B
  JOIN price P
  ON B.name = P.name
  WHERE P.date = '#{date_input}'
  AND active = 1
  ORDER BY period, name
SQL

result = client.query(sql)

data = result.map do |row|
  shares = row['volbuy']
  u_cost = row['u_cost']
  cost_amt = shares * u_cost
  mkt_price = row['mkt_price']
  mkt_amt = shares * mkt_price
  dividend = row['dividend']
  div_amt = shares * dividend
  cst_pct = (div_amt / cost_amt) * 100
  mkt_pct = (div_amt / mkt_amt) * 100

  {
    prd: row['prd'],
    name: row['name'],
    shares: shares,
    u_cost: "฿%.2f" % u_cost,
    cost_amt: "฿%0.2f" % cost_amt,
    mkt_price: "฿%.2f" % mkt_price,
    mkt_amt: "฿%0.2f" % mkt_amt,
    dividend: "฿%.4f" % dividend,
    div_amt: "฿%0.2f" % div_amt,
    cst_pct: "%.2f%%" % cst_pct,
    mkt_pct: "%.2f%%" % mkt_pct
  }
end

puts "prd\tname\tshares\t u_cost\t   cost_amt\t  price\t mkt_amount\tdiv\tdiv_amount\t cst-%\t mkt-%"

data.each do |row|
  puts "%3s\t%s\t%6s\t%7s\t%11s\t%7s\t%11s\t%7s\t%10s\t%6s\t%6s" % [
    row[:prd], row[:name], row[:shares], row[:u_cost], row[:cost_amt],
    row[:mkt_price], row[:mkt_amt], row[:dividend], row[:div_amt],
    row[:cst_pct], row[:mkt_pct]
  ]
end

