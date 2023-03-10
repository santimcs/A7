# encoding: utf-8
require 'nokogiri'
require 'open-uri'
load './ruby/my_utils.rb'

active = 0

def number_of_spread(minp,maxp)
    div = 0.0
    gap = 0.0
    spd = 0
    if (maxp > minp) 
        gap = maxp - minp
        mult = 1
    else
        tmpp = minp
        minp = maxp
        maxp = tmpp
        gap  = maxp - minp
        mult = -1
    end
    if gap != 0
        case maxp
            when 0.00..2.00 then 
            begin
                div = 0.01 
                spd = (gap/div).round()
            end
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
            when 10.10..25.00 then 
            begin
                div = 0.10
                boundary = div * 100
                if minp < boundary
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

process = ARGV.shift
inp_digit = process[0].to_i

# file_in   = '..\data\orders.csv'

# Get the current script's directory
current_dir = File.dirname(__FILE__)
# Construct the file path to the input folder
input_dir = File.join(current_dir, '..', 'Data')
# Construct the file path to the input file
file_in = File.join(input_dir, "orders.csv")

# ary_in[0] = Trade          
# ary_in[1] = Stock Name 
# ary_in[2] = Qty
# ary_in[3] = Order Price  
# ary_in[4] = Active 
# ary_in[5] = Reason 
# ary_in[6] = Market 
# ary_in[7] = xdate 
ary_in = []
ary_out = []
# ary_out[0] = Trade          
# ary_out[1] = Stock Name 
# ary_out[2] = Qty
# ary_out[3] = Order Price 
# ary_out[4] = Last Trade          
# ary_out[5] = Price Change
# ary_out[6] = Percent Change
# ary_out[7] = Order Price - Last Trade
# ary_out[8] = Number of Spreads
# ary_out[9] = Reason   
# ary_out[10] = Market          
# ary_out[11] = Active    
# ary_out[12] = xdate    

order_price = 0
last_trade = 0
jjj = 0

fi = File.open(file_in, "r")
while true do
    puts   "T Name        Qty  Order  Price     Diff  Percent     Name"
    puts   "----------------------------------------------------------"

    fi.each do |line|

        if (jjj > 0)
            ary_in = line.split(",")
            stock_name = ary_in[1]  
            trade = ary_in[0].strip
            ary_out[0] = trade  
            ary_out[1] = ary_in[1]  # Name
            ary_out[2] = ary_in[2]  # Qty        
            order_price = ary_in[3]             
            ary_out[3] = order_price
            ary_out[4] = 0.00       # Last trade      
            ary_out[5] = 0          # Price Change
            ary_out[6] = '%'     	# Percent Change
            ary_out[7] = 0     		# Order Price - Last Trade
            ary_out[8] = 0     		# Number of Spreads
            ary_out[9] = ary_in[5]  # Reason 
            ary_out[10] = ary_in[6].strip    # Market (if skip to new line when print, must strip last column of line printf)         
            active = ary_in[4].to_i
            ary_out[11] = active       
            ary_out[12] = ary_in[7].chop  # xdate     

            url = "https://www.set.or.th/th/market/product/stock/quote/#{stock_name}/factsheet"
            html_data = open(url).read
            doc = Nokogiri::HTML(html_data)
            last_trade = doc.xpath("//span[@class='card-product-percent fs-24px title-font-family ms-2']/text()")
            if (last_trade != '')
                puts last_trade
            else
                puts 'No data'
            end
            # i = 0
            # elements.each do |element|
            #     ary_out[4] = element.text.strip   # Last trade     
            #     last_trade = element.text.strip   # Last trade  
            #     puts last_trade
            # end            
            # ary_out[4] = last_trade
            # last_trade = //span[@class='card-product-percent fs-24px title-font-family ms-2']/text()
            # ary_out[7] = (order_price.to_f - last_trade.to_f)
            # ary_out[8] = number_of_spread(last_trade.to_f,order_price.to_f)

            if ary_out[4] != '-'
                if (active < inp_digit)
                    printf "%1s %-8s %6s %6.2f %6.2f %8s %8s %8s %1s %6.2f %3s %-8s %-6s %8s\n",
                    ary_out[0],ary_out[1],ary_out[2],ary_out[3],ary_out[4],ary_out[5],ary_out[6],
                    ary_out[1],ary_out[11],ary_out[7],ary_out[8],ary_out[9],ary_out[10],ary_out[12]
                    sleep(5)
                end # active >= inp_digit
            end # ary_out
        end # jjj
        jjj += 1
    end # end of each line 

    items = 0
    # plus = 0
    sleep(10)
    fi.rewind
    jjj = 0
end
fi.close