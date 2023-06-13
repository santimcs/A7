require 'csv'
require 'fileutils'
load './ruby/my_utils.rb'

# Define constants for file paths
INPUT_FILE_PATH = 'C:/Users/User/OneDrive/A7/Data/daily-sales-prices.csv'
OUTPUT_FILE_PATH = 'C:/ruby/port_lite/db/daily_out.csv'
OUTPUT_FILE_PATHS = [
  'C:/Users/User/OneDrive/A7/Data/daily_out.csv',
  'C:/Users/User/OneDrive/Documents/obsidian-git-sync/Data/daily_out.csv',
  'C:/Users/User/iCloudDrive/daily_out.csv'
]

# Write CSV header to output file
CSV.open(OUTPUT_FILE_PATH, 'wb') do |csv|
  csv << %w[name fm_date to_date fm_price to_price percent qty max_price min_price status action]
end
puts "Name      From Date    To Date   From     To     Pct      Shares    Max    Min S Action"
puts "---------------------------------------------------------------------------------------"
# Parse input file and write to output file
CSV.foreach(INPUT_FILE_PATH, headers: true) do |row|
  stock_name = row['name']
  fm_date = row['fm_date']
  to_date = row['date']
  fm_price_old = row['fm_price'].to_f
  to_price_old = row['to_price'].to_f
  trend = to_price_old - fm_price_old 
  max_price_old = row['max_price'].to_f
  min_price_old = row['min_price'].to_f
  status = row['status'].strip

  fm_price = row['fm_price']
  to_price = row['price']
  max_price = row['max_price']
  min_price = row['min_price']

  # Determine new max and min prices
  max_price_new = [max_price.to_f, max_price_old].max
  min_price_new = [min_price.to_f, min_price_old].min
  if to_price.to_f < min_price_new
    min_price_new = to_price.to_f
  end
  if to_price.to_f > max_price_new
    max_price_new = to_price.to_f
  end  

  # Determine trend and action
  diff = row['change'].to_f
  if (trend > 0 && diff < 0) || (trend < 0 && diff > 0)
    action = 'Insert'
    fm_date = to_date
    fm_price = to_price_old
  else
    action = 'Update'
  end

  # Calculate percent change
  pct = (to_price.to_f - fm_price.to_f) / fm_price.to_f * 100

  # Write row to output file
  CSV.open(OUTPUT_FILE_PATH, 'ab') do |csv|
    csv << [stock_name, fm_date, to_date, fm_price, to_price, pct.round(2), row['qty'], max_price_new, min_price_new, status, action]
  end
  printf "%-8s %10s %10s %6.2f %6.2f %7s %11s %6.2f %6.2f %s %6s\n",
  stock_name, fm_date, to_date, fm_price.to_f, to_price.to_f, pct.round(2).to_s+'%', row['qty'].to_i.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse, max_price_new, min_price_new, status, action
end
puts "======================================================================================="

# Copy the output file to other directories
OUTPUT_FILE_PATHS.each do |path|
  FileUtils.cp(OUTPUT_FILE_PATH, path)
end
