require 'csv'

def summarize_prices(input_file, output_file)
    previous_name = nil
    previous_row = nil
    previous_trend = 'First Record'
    start_date = nil
    start_price = nil
    trend = nil
    no = 0

    CSV.open(output_file, 'w') do |output|
        output << %w[name from_date to_date from_price to_price trend no]
        str = %w[name from_date to_date from_price to_price trend no].join(',')
        puts str

        CSV.foreach(input_file) do |row|
            no = no + 1
            if previous_row.nil? # process for 1st row
                start_date = row[1]
                start_price = row[2]
                previous_name = row[0]  
            end

            if !previous_row.nil? # process for 2nd row onward
                if row[0] != previous_name
                    start_date = row[1]
                    start_price = row[2]
                    trend = nil
                end
            end            

            if !previous_row.nil? # process for 2nd row onward

                if row[2] > previous_row[2]
                    trend = "Upward"
                elsif row[2] < previous_row[2]
                    trend = "Downward"
                end

                # if row[0] != previous_name
                #     previous_trend = 'First record'
                #     previous_name = row[0]
                # end

                if trend != previous_trend
                    output << [previous_name, start_date, previous_row[1], start_price, previous_row[2], previous_trend, no]
                    output_string = [previous_name, start_date, previous_row[1], start_price, previous_row[2], previous_trend, no].join(',')
                    puts output_string
                    
                    # start_date = row[1]
                    # start_price = row[2]
                    previous_trend = trend
                end

            end # end of process for 2nd row onward

            previous_row = row  # do every row
            previous_name = row[0]  # do every row
        end # end of foreach row

        # process after last row
        if previous_row != nil
            output << [previous_name, start_date, previous_row[1], start_price, previous_row[2], previous_trend, no]
            output_string = [previous_name, start_date, previous_row[1], start_price, previous_row[2], previous_trend, no].join(',')
            puts output_string
        end
    
    end # end of output_file

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


