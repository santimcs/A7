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

# Get command line arguments for date1 and date2
date1 = ARGV[0]
date2 = ARGV[1]

# Open input and output CSV files
input_file = "c:/Users/User/OneDrive/A7/Data/buy-input.csv"
output_file = "c:/Users/User/OneDrive/A7/Data/prices-change.csv"

CSV.open(output_file, "wb") do |csv_out|
  # Write output CSV headers
  headers = ["period", "name", "shares", "date1", "date2", "price1", "price2", "change", "%change", "amount"]
  csv_out << headers

  # Write header to screen
  puts headers.map { |h| sprintf("%-10s", h) }.join(" ")

  # Read input CSV file
  CSV.foreach(input_file, headers: true) do |row|
    # Retrieve prices from MySQL database
    query = "SELECT price FROM price WHERE name = '#{row['name']}' AND date = '#{date1}'"
    result = client.query(query)
    price1 = result.first['price']

    query = "SELECT price FROM price WHERE name = '#{row['name']}' AND date = '#{date2}'"
    result = client.query(query)
    price2 = result.first['price']

    # Calculate change, %change, and amount
    change = price2 - price1
    pct_change = change / price1 * 100
    amount = change * row['shares'].to_i

    # Write output CSV row
    csv_row_scr = [row['period'], row['name'], row['shares'], date1, date2, sprintf("%.2f", price1), sprintf("%.2f", price2), sprintf("%.2f", change), sprintf("%.2f", pct_change), number_with_delimiter(sprintf("%.2f", amount))]
    csv_row = [row['period'], row['name'], row['shares'], date1, date2, sprintf("%.2f", price1), sprintf("%.2f", price2), sprintf("%.2f", change), sprintf("%.2f", pct_change), amount]
    csv_out << csv_row

    # Write row data to screen
    puts csv_row_scr.map { |v| sprintf("%-10s", v) }.join(" ")
  end
end
