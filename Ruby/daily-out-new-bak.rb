require 'nokogiri'
require 'open-uri'
require 'fileutils'
load './ruby/my_utils.rb'

# Get the current script's directory
current_dir = File.dirname(__FILE__)
# Construct the file path to the input folder
input_dir = File.join(current_dir, '..', 'Data')
# Construct the file path to the output folder
output_dir = File.join(current_dir, '..', 'Data')
# Construct the file path to the input file
file_in = File.join(input_dir, "daily-sales-prices.csv")
# Construct the file path to the output file
file_out   = 'c:\ruby\port_lite\db\daily_out.csv'

ary_inp = []
ary_out = []
ary_tmp = []
ary_hdr = []
diff = 0
jjj = 0

fo = File.open(file_out, "w")
fi = File.open(file_in, "r")

fi.each do |line|

    if (jjj == 0) # 1st record of orders.csv is header
        puts "Name      From Date    To Date   From     To     Pct     Shares    Max    Min S Action"

        hdr_line ='name,fm_date,to_date,fm_price,to_price,percent,qty,max_price,min_price,status,action' + "\n"
        fo.write hdr_line
    end 

    if (jjj > 0) 
        ary_inp = line.split(",")
        stock_name = ary_inp[0]  
        fm_date = ary_inp[1]    
        to_date = ary_inp[13]    
        fm_price_old = ary_inp[3].to_f
        to_price_old = ary_inp[4].to_f
        trend = to_price_old - fm_price_old 
        max_price_old = ary_inp[6].to_f
        min_price_old = ary_inp[7].to_f
        status = ary_inp[9].strip

        ary_out[0] = ary_inp[0]  # stock name  
        ary_out[1] = ary_inp[1]  # from date   
        ary_out[2] = ary_inp[13].strip  # to_date <= date
        ary_out[3] = ary_inp[3]  # from price 
  		ary_out[4] = ary_inp[10] # to price <= price

        ary_tmp[6] = ary_inp[6] # max_price
        ary_tmp[7] = ary_inp[7] # min_price
        ary_tmp[12]= ary_inp[12]  # volume

        ary_out[6] = strip_comma(ary_tmp[12])  #  No. of shares
        ary_out[7] = ary_tmp[6]   # max price    
        ary_out[8] = ary_tmp[7]   # min price    
        ary_out[9] = ary_inp[9]  

        max_price_new = ary_out[7].to_f  
        min_price_new = ary_out[8].to_f
        if (max_price_new >= max_price_old)
            ary_out[7] = max_price_new
        else
            ary_out[7] = max_price_old
        end
        if (min_price_new <= min_price_old)
            ary_out[8] = min_price_new
        else
            ary_out[8] = min_price_old
        end
    
        # determine trend
        diff = ary_inp[11].to_f  # change
        if (trend >= 0)  # always higher, equal 0 is illogical 
            if (diff < 0)
                action = 'Insert'
            else
                action = 'Update'
            end
        else
            if (diff > 0)
                action = 'Insert'
            else
                action = 'Update'
            end    
        end

        if (action == 'Insert')
            ary_out[1] = to_date.strip  # fm_date
            ary_out[3] = to_price_old   # fm_price
            ary_out[7] = max_price_new
            ary_out[8] = min_price_new
        end
        ary_out[10] = action
        # pct calculation
        pct = ary_out[4].to_f - ary_out[3].to_f
        pct = pct / ary_out[3].to_f * 100
        ary_out[5] = pct.round(2) # %change

        out_line = ary_out.join(',')
        out_line = out_line + "\n"
        fo.write out_line  

        printf "%-8s %10s %10s %6.2f %6.2f %7s %10d %6.2f %6.2f %s %6s\n",
        # printf "%-8s %10s %10s %8s %8s %7s %10s %8s %8s %s %6s\n",
        ary_out[0],ary_out[1],ary_out[2],ary_out[3],ary_out[4],
        ary_out[5],ary_out[6],ary_out[7],ary_out[8],ary_out[9],ary_out[10]

    end
    jjj += 1
end
fo.close
fi.close

# Copy the file "daily_out.csv" from the source directory to the destination directory
FileUtils.cp(file_out, "c:\\Users\\User\\OneDrive\\A7\\Data\\daily_out.csv")
FileUtils.cp(file_out, "c:\\Users\\User\\OneDrive\\Documents\\obsidian-git-sync\\Data\\daily_out.csv")
FileUtils.cp(file_out, "c:\\Users\\User\\iCloudDrive\\daily_out.csv")
