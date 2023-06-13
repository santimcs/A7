require 'date'
require 'active_record'
require 'mysql2'
require 'sqlite3'
require 'pry'

class Buy < ApplicationRecord
    self.table_name = "buy"
  end
  

class Price < ActiveRecord::Base
end

class Eps < ActiveRecord::Base
  self.table_name = 'epss'
end

date_arg = ARGV[0]
yesterday = Date.parse(date_arg)

ActiveRecord::Base.establish_connection(
  adapter: 'mysql2',
  host: 'localhost',
  username: 'root',
  password: '',
  database: 'stock'
)

Buy.connection.execute(<<-SQL)
  UPDATE buy B
  SET dividend =
  (SELECT DIVIDEND FROM dividend D
  WHERE B.name = D.name)
SQL

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

buys = Buy.find_by_sql([sql, yesterday])

ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: 'c:\\ruby\\portlt\\db\\development.sqlite3'
)

eps_data = Eps.where(year: 2022, quarter: 4)

results = []

buys.each do |buy|
  eps = eps_data.find { |e| e.name == buy.name }
  shares = buy.volbuy.to_i
  cost_amt = shares * buy.u_cost
  mkt_amt = shares * buy.mkt_price
  div_amt = shares * buy.dividend
  mkt_pct = div_amt / mkt_amt * 100
  cst_pct = div_amt / cost_amt * 100
  dpr_pct = buy.dividend / eps.aq_eps * 100

  results << {
    'prd' => buy.prd,
    'name' => buy.name,
    'shares' => shares,
    'u_cost' => "฿%.2f" % buy.u_cost,
    'cost_amt' => "฿%,.2f" % cost_amt,
    'mkt_price' => "฿%.2f" % buy.mkt_price,
    'mkt_amt' => "฿%,.2f" % mkt_amt,
    'dividend' => "฿%.4f" % buy.dividend,
    'div_amt' => "฿%,.2f" % div_amt,
    'cst-%' => "%.2f%%" % cst_pct,
    'mkt-%' => "%.2f%%" % mkt_pct,
    'eps' => "฿%.4f" % eps.aq_eps,
    'dpr-%' => "%.2f%%" % dpr_pct
  }
end

results.sort_by! { |r| [r['prd'], r['name']] }

puts "  name  shares  u_cost  cost_amt  mkt_price  mkt_amt  dividend  div_amt  cst-%  mkt-%  eps  dpr-%"
puts "---------------------------------------------------------------------------------------------------------"
results.each do |row|
    puts "#{row['prd']}\t#{row['name']}\t#{row['shares']}\t#{row['u_cost']}\t#{row['cost_amt']}\t#{row['mkt_price']}\t#{row['mkt_amt']}\t#{row['dividend']}\t#{row['div_amt']}\t#{row['cst-%']}\t#{row['mkt-%']}\t#{row['eps']}\t#{row['dpr-%']}"
  end
  