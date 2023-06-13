require 'csv'

def summarize_prices(input_file, output_file)
    previous_row = nil
    previous_trend = nil
    start_date = nil
    start_price = nil
    trend = nil
    nbr = 0

    CSV.open(output_file, 'w') do |output|
        output << %w[name from_date to_date from_price to_price trend nbr]
        header = %w[name from_date to_date from_price to_price trend nbr].join(',')
        puts header

        CSV.foreach(input_file) do |row|
            nbr = nbr + 1
            if previous_row.nil? # process for 1st row
                start_date = row[1]
                start_price = row[2]
            end

            if !previous_row.nil? # process for 2nd row onward
                if row[0] != previous_row[0]    # group break
                    output << [previous_row[0], start_date, previous_row[1], start_price, previous_row[2], previous_trend, nbr]
                    output_string = [previous_row[0], start_date, previous_row[1], start_price, previous_row[2], previous_trend, nbr].join(',')
                    puts output_string                    
                    start_date = row[1]
                    start_price = row[2]
                    # trend = nil # this statement causes one incorrect nil for each group of data 
                end

                if row[0] == previous_row[0]    # same group

                    if row[2] > previous_row[2]
                        trend = "Upward"
                    end
                    if row[2] < previous_row[2]
                        trend = "Downward"
                    end

                    if trend != previous_trend

                        if row[0] == previous_row[0]
                            output << [previous_row[0], start_date, previous_row[1], start_price, previous_row[2], previous_trend, nbr]
                            output_string = [previous_row[0], start_date, previous_row[1], start_price, previous_row[2], previous_trend, nbr].join(',')
                            puts output_string
                        end

                        start_date = row[1]
                        start_price = row[2]
                        previous_trend = trend
                    end

                end

            end # end of process for 2nd row onward

            previous_row = row  # do every row
        end # end of foreach row

        # process after last row
        output << [previous_row[0], start_date, previous_row[1], start_price, previous_row[2], previous_trend, nbr]
        output_string = [previous_row[0], start_date, previous_row[1], start_price, previous_row[2], previous_trend, nbr].join(',')
        puts output_string
    
    end # end of output_file

end # end of function

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