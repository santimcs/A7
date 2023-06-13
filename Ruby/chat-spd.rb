require 'csv'
require 'business_time'
load './ruby/my_utils.rb'

def number_of_spread(minp,maxp)
    div = 0.0 # divider for calculating the number of spreads
    gap = 0.0 # gap between minp and maxp
    spd = 0   # number of spreads
    
    # If maxp is greater than minp, calculate the gap and set mult to 1.
    # Otherwise, swap the values of minp and maxp, and set mult to -1.
    if (maxp > minp) 
        gap = maxp - minp # gap = max price - minimum price
        mult = 1 # multiplier for adjusting the result based on the order of minp and maxp
    else
        tmpp = minp
        minp = maxp
        maxp = tmpp
        gap  = maxp - minp
        mult = -1
    end
    
    # If the gap is not 0, enter a case statement to determine the number of spreads
    # based on the range that maxp falls into.
    if gap != 0
        case maxp
            # Calculate the number of spreads using a divisor of 0.01.
            when 0.00..2.00 then 
            begin
                div = 0.01 
                spd = (gap/div).round()
            end
            # Calculate the number of spreads using a divisor of 0.02.
            # If minp is less than the boundary value (2.00), calculate the number of spreads
            # in two parts: between minp and the boundary value, and between the boundary value and maxp.
            when 2.02..5.00 then 
            begin
                div = 0.02
                boundary = div * 100
                if minp < boundary
                    spd = (boundary - minp) / 0.01
                    spd += (maxp - boundary) / div
                else
                    spd = (gap/div).round()
                end
            end      
            # Calculate the number of spreads using a divisor of 0.05.
            # If minp is less than the boundary value (5.00), calculate the number of spreads
            # in two parts: between minp and the boundary value, and between the boundary value and maxp.
            when 5.05..10.00 then  
            begin
                div = 0.05
                boundary = div * 100
                if minp < boundary
                    spd1 = ((boundary - minp) / 0.02).round()
                    spd2 = ((maxp - boundary) / div).round()
                    spd = spd1 + spd2                      
                    # spd = (boundary - minp) / 0.02
                    # spd += (maxp - boundary) / div
                else
                    spd = (gap/div).round()
                end            
            end      
            # Calculate the number of spreads using a divisor of 0.10.
            # If minp is less than the boundary value (10.00), calculate the number of spreads
            # in two parts: between minp and the boundary value, and between the boundary value and maxp.
            when 10.10..25.00 then 
            begin
                div = 0.10
                boundary = div * 100

                if minp < boundary    #continue
                    # spd = (boundary - minp) / 0.05
                    # spd += (maxp - boundary) / div
                    spd1 = ((boundary - minp) / 0.05).round()
                    spd2 = ((maxp - boundary) / div).round()
                    spd = spd1 + spd2
                else
                    spd = (gap/div).round()
                end          
            end   
            when 25.25..100.00 then 
            begin
                div = 0.25
                boundary = div * 100
                if minp < boundary
                    spd1 = ((boundary - minp) / 0.10).round()
                    spd2 = ((maxp - boundary) / div).round()
                    spd = spd1 + spd2
                else
                    spd = (gap/div).round()
                end            
            end    
            when 100.50..200.00 then 
            begin
                div = 0.50
                boundary = div * 200
                if minp < boundary
                    spd1 = ((boundary - minp) / 0.25).round()
                    spd2 = ((maxp - boundary) / div).round()
                    spd = spd1 + spd2
                else
                    spd = (gap/div).round()
                end             
            end      
            when 201.00..400.00 then 
            begin
                div = 1.00
                boundary = div * 200                
                if minp < boundary
                    spd1 = ((boundary - minp) / 0.50).round()
                    spd2 = ((maxp - boundary) / div).round()
                    spd = spd1 + spd2
                else
                    spd = (gap/div).round()
                end            
            end   
            else 
            begin
                div = 2.00
                boundary = div * 200
                if minp < boundary
                    spd1 = ((boundary - minp) / 1.00).round()
                    spd2 = ((maxp - boundary) / div).round()
                    spd = spd1 + spd2
                else
                    spd = (gap/div).round()
                end            
            end         
        end 
    end
    spreads = (spd * mult).to_i
    return spreads
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
    business_days += 1
end

def summarize_prices(input_file, output_file)
    previous_row = nil
    previous_trend = nil
    start_date = nil
    start_price = nil
    trend = nil
    nbr = 0
    days = 0
    ttl_qty = 0

    CSV.open(output_file, 'w') do |output|
        output << %w[name from_date to_date days from_price to_price spd ttl_qty trend nbr]
        header = %w[name fm_date to_date days fm_price to_price spd ttl_qty trend nbr].join('|')
        puts header

        CSV.foreach(input_file) do |row|
            nbr = nbr + 1
            if previous_row.nil? # process for 1st row
                start_date = row[1]
                start_price = row[2]
                # ttl_qty = row[3].to_i
            end

            if !previous_row.nil? # process for 2nd row onward
                if row[0] != previous_row[0]    # group break
                    days = calc_days(start_date, previous_row[1])  
                    spd = number_of_spread(start_price.to_f,previous_row[2].to_f)
                    output << [previous_row[0], start_date, previous_row[1], days, start_price, previous_row[2], spd, ttl_qty, previous_trend, nbr]
                    output_string = [previous_row[0], start_date, previous_row[1], days, start_price, previous_row[2], spd, commas(ttl_qty), previous_trend, nbr].join(',')
                          puts output_string                    
                    start_date = row[1]
                    start_price = row[2]
                    ttl_qty = 0
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
                            days = calc_days(start_date, previous_row[1])  
                            spd = number_of_spread(start_price.to_f,previous_row[2].to_f)
                            output << [previous_row[0], start_date, previous_row[1], days, start_price, previous_row[2], spd, ttl_qty, previous_trend, nbr]
                            output_string = [previous_row[0], start_date, previous_row[1], days, start_price, previous_row[2], spd, commas(ttl_qty), previous_trend, nbr].join(',')
                            puts output_string
                        end

                        start_date = row[1]
                        start_price = row[2]
                        ttl_qty = 0
                        previous_trend = trend
                    end

                end

            end # end of process for 2nd row onward

            previous_row = row  # do every row
            ttl_qty = ttl_qty + row[3].to_i
        end # end of foreach row

        # process after last row
        days = calc_days(start_date, previous_row[1])  
        spd = number_of_spread(start_price.to_f,previous_row[2].to_f)
        output << [previous_row[0], start_date, previous_row[1], days, start_price, previous_row[2], spd, ttl_qty, previous_trend, nbr]
        output_string = [previous_row[0], start_date, previous_row[1], days, start_price, previous_row[2], spd, commas(ttl_qty), previous_trend, nbr].join(',')
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