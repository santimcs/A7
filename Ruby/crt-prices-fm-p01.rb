require 'nokogiri'
require 'open-uri'
require 'cgi'
load './ruby/my_utils.rb'

process = ARGV.shift

# file_in   = 'c:\A8\data\name-ttl.csv'
# file_out = 'c:\A8\data\price.csv'

# file_temp = '..\data\name-tmp.csv'


# Get the current script's directory
current_dir = File.dirname(__FILE__)
#puts current_dir
# Construct the file path to the input folder
input_dir = File.join(current_dir, '..', 'Data')
#puts input_dir
# Construct the file path to the output folder
output_dir = File.join(current_dir, '..', 'Data')
#puts output_dir

# Construct the file path to the input file
file_in = File.join(input_dir, "name-ttl.csv")
# Construct the file path to the temp file
file_temp = File.join(input_dir, "name-temp.csv")
# Construct the file path to the output file
file_out = File.join(output_dir, "price.csv")

fo = File.open(file_out,"w") 
ft = File.open(file_temp,"w")
fi = File.open(file_in, "r")

if (process == '-o')
    puts "Enter stock name "
    stock_name = gets.chomp
    ft.write stock_name
else
    fi.each do |line|
        array = line.chomp.split(",")
        stock_name = array[0]
        out_line = stock_name + "\n"
    #   puts out_line
        ft.write out_line
    end
end
ft.close

time = Time.new
puts 'Start at: ' + time.strftime("%I:%M %p")

fi = File.open(file_temp, "r")
fi.each do |line|
    stock_name = CGI.escape(line.chomp)
    url = "http://classic.settrade.com/C04_01_stock_quote_p1.jsp?txtSymbol=#{stock_name}&ssoPageId=9&selectPage=1"
    html_data = open(url).read
    doc = Nokogiri::HTML(html_data)

    array = []
    ary_out = []
    array[0] = stock_name.upcase
    ary_out[0] = stock_name.upcase
    ary_out[1] = DateTime.now.strftime('%Y-%m-%d')  

    elements = doc.xpath("//h1")
    i = 0
    elements.each do |element|
        i += 1		
  	    if (i == 2)
  		    ary_out[2] = element.text.strip
  	    end
    end

    tables = doc.css('table.table-info')
    rows = tables.css('tr')
    i = 0
    rows.each do | row |
        cols = row.css('td')
        cols.each do | col |
            i += 1
        #   puts i.to_s + ' ' + col.text
            array[i] = col.text.strip
        end
    end
    ary_out[6] = array[4]  
    ary_out[3] = array[6]
	ary_out[4] = array[8]
    ary_out[5] = strip_comma(array[12])

    if (ary_out[2] != '-')
        out_line = ary_out.join(',')
        out_line = out_line + "\n"
        fo.write(out_line)
    end
    #  puts out_line
    if (ary_out[2] != '-')
        printf "%-8s %6.2f %6.2f %6.2f %6.2f %10d\n", 
        ary_out[0],ary_out[6],ary_out[2],ary_out[3],ary_out[4],ary_out[5]
    end
    sleep(1)
end

time = Time.new
puts 'End at: ' + time.strftime("%I:%M %p")

fo.close
fi.close
