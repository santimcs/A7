require 'mysql2'
require 'active_support'
require 'active_support/core_ext/integer/time'
require 'sqlite3'

date_input = ARGV[0] || (Date.today - 1.business_day).strftime('%Y-%m-%d')

# Connect to the SQLite database
db = SQLite3::Database.new "C:/ruby/portlt/db/development.sqlite3"

# Get the EPS for a given name, year and quarter from the SQLite table
def get_eps(db, name, year, quarter)
    sql = "SELECT aq_eps FROM epss WHERE name = '#{name}' AND year = 2022 AND quarter = 4"
    result = db.execute(sql)
    result.first.first.to_f
end

# Get user input for dividend per share and number of shares
def get_dividend_payout_ratio(name)
    # puts "Please enter the dividend per share for #{name}:"
    # dividend_per_share = gets.chomp.to_f

    # puts "Please enter the number of shares owned for #{name}:"
    # num_shares = gets.chomp.to_i

    eps = get_eps(db, name, 2022, 4)
    dividend_payout_ratio = (dividend_per_share * num_shares) / (eps * num_shares)

    dividend_payout_ratio
end

# Connect to the MySQL database
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

result.each do |row|
    shares = row['volbuy']
    u_cost = row['u_cost']
    cost_amt = shares * u_cost
    mkt_price = row['mkt_price']
    mkt_amt = shares * mkt_price
    dividend = row['dividend']
    div_amt = shares * dividend
    cst_pct = (div_amt / cost_amt) * 100
    mkt_pct = (div_amt / mkt_amt) * 100
    eps = row['eps']
    # div_payout_ratio = get_dividend_payout_ratio(row['name'])

    puts "%3s\t%s\t%6s\t%7s\t%11s\t%7s\t%11s\t%7s\t%10s\t%6s\t%6s\t%6s" % [
      row['prd'], row['name'], row['volbuy'], "฿%.2f" % row['u_cost'], "฿%0.2f" % cost_amt,
      "฿%.2f" % row['mkt_price'], "฿%0.2f" % mkt_amt, "฿%.4f" % dividend,
      "฿%0.2f" % div_amt, "%.2f%%" % cst_pct, "%.2f%%" % mkt_pct, '123456'
    ]
  end


