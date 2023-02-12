# encoding: utf-8
require 'nokogiri'
require 'open-uri'
require 'fileutils'
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

# Get the current script's directory
current_dir = File.dirname(__FILE__)
#puts current_dir
# Construct the file path to the input folder
# input_dir = File.join(current_dir, '..', 'Data')
input_dir = File.join(current_dir, '..', 'Data')

#puts input_dir
# Construct the file path to the output folder
output_dir = File.join(current_dir, '..', 'Data')
#puts output_dir

# Construct the file path to the output file
file_out = File.join(output_dir, "orders-log.csv")
# Construct the file path to the input file
file_in = File.join(input_dir, "Price-for-Order.csv")

ary_in = []
ary_out = []

order_price = 0
last_trade = 0
jjj = 0

fo = File.open(file_out, "w")
# fp = File.open(file_out2, "w")
fi = File.open(file_in, "r")

fi.each do |line|

    if (jjj == 0) # 1st record of orders.csv is header
        hdr_line ='trade,name,spd,reason,market,qty,target,current,change,%change,active,xdate' + "\n"
        fo.write hdr_line
        # fp.write hdr_line
        puts hdr_line
    end   

    if (jjj > 0)  # from 2nd record of orders.csv onward is data
        ary_in = line.split(",")
        stock_name = ary_in[1]  
        # trade = ary_in[0].strip
        ary_out[0] = ary_in[0]  
        ary_out[1] = ary_in[1]
        ary_out[2] = 0 # spreads      
        ary_out[3] = ary_in[3]    
        ary_out[4] = ary_in[4].strip   
        ary_out[5] = ary_in[5]  
        order_price = ary_in[6]  
        ary_out[6] = order_price    
        ary_out[7] = ary_in[7] # Last trade
        ary_out[8] = ary_in[8] # Price Change        
        ary_out[9] = ary_in[9] # Percent Change    
        active = ary_in[10].to_i                     
        ary_out[10] = ary_in[10].to_i
        ary_out[11] = ary_in[11].strip

        ary_out[2] = number_of_spread(ary_in[7].to_f,ary_in[6].to_f)
        if (active != 2)
            if (ary_out[2] <= -10 or ary_out[2] >= 10)
                ary_out[10] = 0
            else
                ary_out[10] = 1
            end 
        end
        out_line = ary_out.join(',') 
        out_line += "\n"
        puts out_line
        fo.write out_line
        # fp.write out_line

    end

    jjj += 1

end

fi.close
fo.close

FileUtils.cp(file_out, "c:\\Users\\User\\OneDrive\\Documents\\obsidian-git-sync\\Data\\orders-log.csv")
