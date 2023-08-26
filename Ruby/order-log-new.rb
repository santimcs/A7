# encoding: utf-8
require 'nokogiri'
require 'open-uri'
require 'fileutils'
load './ruby/my_utils.rb'

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
  
  
  

# Get the current script's directory
current_dir = File.dirname(__FILE__)
# Construct the file path to the input folder
input_dir = File.join(current_dir, '..', 'Data')

# Construct the file path to the output folder
output_dir = File.join(current_dir, '..', 'Data')

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

        ary_out[2] = spreads_between(ary_in[7].to_f,ary_in[6].to_f)
        if (active == 0)
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
