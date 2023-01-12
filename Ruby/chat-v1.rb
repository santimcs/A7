require 'csv'

def summarize_prices(input_file, output_file)
    previous_row = nil
    previous_trend = nil
    start_date = nil
    start_price = nil
    trend = nil
    CSV.open(output_file, 'w') do |output|
    output << %w[name from_date to_date from_price to_price trend]
    str = %w[name from_date to_date from_price to_price trend]
    puts str
      CSV.foreach(input_file) do |row|

        if previous_row.nil? # process for 1st rcd
          start_date = row[1]
          start_price = row[2]

          # if row[2] > start_price
          #     trend = "Upward"
          # elsif row[2] < start_price
          #     trend = "Downward"
          # end

        else # process for not 1st rcd

          if row[2] > previous_row[2]
              trend = "Upward"
          elsif row[2] < previous_row[2]
              trend = "Downward"
          end

          if trend != previous_trend
              output << [previous_row[0], start_date, previous_row[1], start_price, previous_row[2], previous_trend]
              str = [previous_row[0], start_date, previous_row[1], start_price, previous_row[2], previous_trend]
              puts str
              start_date = row[1]
              start_price = row[2]
              previous_trend = trend
          else
            previous_trend = trend
          end

        end # end of previous_row.nil?

        previous_row = row  # do every row
      end # end of foreach row
    # process when there is no more row
    if previous_row != nil
        output << [previous_row[0], start_date, previous_row[1], start_price, previous_row[2], previous_trend]
        str = [previous_row[0], start_date, previous_row[1], start_price, previous_row[2], previous_trend]
        puts str

    end
    
  end 
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

# input_file = 'input.csv'
# output_file = 'output.csv'
summarize_prices(input_file, output_file)
