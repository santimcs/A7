require 'csv'
require 'mysql2'
require 'action_view'

include ActionView::Helpers::NumberHelper

# Set up MySQL connection
client = Mysql2::Client.new(
  :host => "localhost",
  :username => "root",
  :password => "",
  :database => "stock"
)

def tick_size(price)
  case price
  when 0...2
    0.01
  when 2...5
    0.02
  when 5...10
    0.05
  when 10...25
    0.10
  when 25...100
    0.25
  when 100...200
    0.50
  when 200...400
    1.00
  else
    2.00
  end
end

def spreads_between(fm_price, to_price)
  total_spreads = 0
  is_negative_spread = fm_price > to_price
  tolerance = 1e-8

  if is_negative_spread
    fm_price, to_price = to_price, fm_price
  end

  while fm_price < to_price
    tick_size_fm = tick_size(fm_price)
    next_threshold = case tick_size_fm
                     when 0.01 then 2
                     when 0.02 then 5
                     when 0.05 then 10
                     when 0.10 then 25
                     when 0.25 then 100
                     when 0.50 then 200
                     when 1.00 then 400
                     else Float::INFINITY
                     end

    upper_bound = [to_price + tick_size_fm / 2, next_threshold].min  # Add tick_size_fm / 2 here
    total_spreads += ((upper_bound - fm_price) / tick_size_fm).to_i
    fm_price = upper_bound

    # Adjust for floating-point imprecision
    if (to_price - fm_price).abs <= tolerance
      fm_price = to_price
    end
  end

  total_spreads = -total_spreads if is_negative_spread
  total_spreads
end

def convert_date_format(date_string)
  # Split the date string into its components
  year, month, day = date_string.split('-')

  # Get the last two characters of the year
  short_year = year[-2, 2]

  # Reassemble the date string in the desired format
  new_date_string = "#{short_year}-#{month}-#{day}"

  return new_date_string
end

# Get command line arguments for date1 and date2
date1 = ARGV[0]
date2 = ARGV[1]

# Open input and output CSV files
input_file = "c:/Users/User/OneDrive/A7/Data/buy-input.csv"
output_file = "c:/Users/User/OneDrive/A7/Data/prices-change.csv"

CSV.open(output_file, "wb") do |csv_out|
  # Write output CSV headers
  headers = ["period", "name", "shares", "date1", "date2", "price1", "price2", "change", "%change", "amount", "spd"]
  csv_out << headers

  # Write header to screen
  puts headers.map { |h| sprintf("%10s", h) }.join(" ")

  # Read input CSV file
  CSV.foreach(input_file, headers: true) do |row|

    # Retrieve prices from MySQL database
    query = "SELECT price FROM price WHERE name = '#{row['name']}' AND date = '#{date1}'"
    result = client.query(query)
    price1 = result.first.nil? ? 0 : result.first['price']

    query = "SELECT price FROM price WHERE name = '#{row['name']}' AND date = '#{date2}'"
    result = client.query(query)
    price2 = result.first.nil? ? 0 : result.first['price']

    # Calculate change, %change, and amount
    change = price2 - price1
    pct_change = change / price1 * 100
    amount = change * row['shares'].to_i

    # Find spreads between price1 and price2
    sprd = spreads_between(price1, price2)
    # Convert date format
    dt1 = convert_date_format(date1)
    dt2 = convert_date_format(date2)

    # Write output CSV row
    csv_row_scr = [row['period'], row['name'], row['shares'], dt1, dt2, sprintf("%.2f", price1), sprintf("%.2f", price2), sprintf("%.2f", change), sprintf("%.2f", pct_change), number_with_delimiter(sprintf("%.2f", amount)), sprd]
    csv_row = [row['period'], row['name'], row['shares'], date1, date2, sprintf("%.2f", price1), sprintf("%.2f", price2), sprintf("%.2f", change), sprintf("%.2f", pct_change), amount, sprd]
    csv_out << csv_row

    # Write row data to screen
    puts csv_row_scr.map { |v| sprintf("%10s", v) }.join(" ")
  end
end
