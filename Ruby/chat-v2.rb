require 'csv'
require 'business_time'

def summarize_prices(input_file, output_file)
    previous_row = nil
    previous_trend = 'First Record'
    start_date = nil
    start_price = nil
    trend = nil
    nbr = 0
    days = 0

    CSV.open(output_file, 'w') do |output|
    output << %w[name from_date to_date days from_price to_price trend nbr]
    header = %w[name from_date to_date days from_price to_price trend nbr].join(',')
    puts header

      CSV.foreach(input_file) do |row|

        if previous_row.nil? # process for 1st row
          start_date = row[1]
          start_price = row[2]

        else # process for 2nd row onward

          if row[2] > previous_row[2]
              trend = "Upward"
          elsif row[2] < previous_row[2]
              trend = "Downward"
          end

          if trend != previous_trend
              days = calc_days(start_date, previous_row[1])  
              output << [previous_row[0], start_date, previous_row[1], days, start_price, previous_row[2], previous_trend, nbr]
              output_string = [previous_row[0], start_date, previous_row[1], days, start_price, previous_row[2], previous_trend, nbr].join(',')
              puts output_string
              
              start_date = row[1]
              start_price = row[2]
              previous_trend = trend
        #   else
        #     previous_trend = trend
          end

        end # end of previous_row.nil?

        previous_row = row  # do every row
      end # end of foreach row

    # process after last row
    if previous_row != nil
        days = calc_days(start_date, previous_row[1])  
        output << [previous_row[0], start_date, previous_row[1], days, start_price, previous_row[2], previous_trend, nbr]
        output_string = [previous_row[0], start_date, previous_row[1], days, start_price, previous_row[2], previous_trend, nbr].join(',')
        puts output_string
    end
    
  end # end of output_file

end

def calc_days(start_date, end_date)

    start_date = Date.parse(start_date)
    end_date = Date.parse(end_date)
    business_days = 0
    date = end_date
    while date > start_date
     business_days = business_days + 1 unless date.saturday? or date.sunday?
    date = date - 1.day
    end
    business_days + 1
    
end

# Get the current script's directory
current_dir = File.dirname(__FILE__)
# Construct the file path to the input folder
input_dir = File.join(current_dir, '..', 'Data')
# Construct the file path to the output folder
output_dir = File.join(current_dir, '..', 'CSV')

# Construct the file path to the input file
input_file = File.join(input_dir, "Quarterly-Price-by-Name.csv")
# Construct the file path to the temp file
file_temp = File.join(input_dir, "temp.csv")
# Construct the file path to the output file
output_file = File.join(output_dir, "output.csv")

puts input_file
summarize_prices(input_file, output_file)

new_output_file = File.join(output_dir, "summary.csv")
File.rename(output_file, new_output_file)
puts new_output_file


