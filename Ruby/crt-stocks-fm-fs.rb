require 'nokogiri'
require 'open-uri'
require 'certified'
load './ruby/my_utils.rb'

process = ARGV.shift

# file_in = '..\data\name-ttl.csv'
# file_out = '..\data\stocks.csv'
# file_temp = '..\data\name-tmp.csv'

# Get the current script's directory
current_dir = File.dirname(__FILE__)
# Construct the file path to the input folder
input_dir = File.join(current_dir, '..', 'Data')
# Construct the file path to the output folder
output_dir = File.join(current_dir, '..', 'Data')

# Construct the file path to the input file
file_in = File.join(input_dir, "name-ttl.csv")
# Construct the file path to the temp file
file_temp = File.join(input_dir, "name-temp.csv")
# Construct the file path to the output file
file_out = File.join(output_dir, "stocks.csv")

fo = File.open(file_out, "w")
ft = File.open(file_temp,"w")
fi = File.open(file_in,"r")

if (process == '-o')

	puts "Enter stock name "
	stock_name = gets.chomp
	ft.write stock_name

else

	fi.each do |line|

		array = line.chomp.split(",")
		stock_name = array[0]
		out_line = stock_name + "\n"
		#	puts out_line
		ft.write out_line

	end

end

ft.close

# Column Header
header = 'Name,Market,Price,Max,Min,PE,PBV,Paid-up,Market Cap,Dly Vol,Beta'
header += "\n"
fo.write(header) #   '..\data\stocks.csv   

time = Time.new
puts 'Start at: ' + time.strftime("%I:%M %p")

fi = File.open(file_temp, "r")

fi.each do |line|

	stock_name = line.chomp
	# stock_name = CGI.escape(line.chomp)
	url = "https://classic.set.or.th/set/factsheet.do?symbol=#{stock_name}&language=th&country=TH"
	html_data = open(url).read
	doc = Nokogiri::HTML(html_data)
	elements = doc.xpath("//table[@class='table-factsheet-padding0']//td[@class='factsheet-noline']")

	i = 0
	array = []
	array[0] = stock_name.upcase

	elements.each do |element|	

		i += 1
		case i

			when 2
				array[1] = element.text

  		end 

	end

	elements = doc.xpath("//td//table[@class='table-factsheet-padding0']//td[@class='factsheet']")

	i, k, l = 0
	offset = 1

	elements.each do |element|	

		i += 1

		if ( i < 7 )

			tmp = element.text.strip

			if (tmp == 'N/A' || tmp == '-')

				tmp = '999.99'

			end

			array[i+offset]  = tmp 

  		end  

  		if ( element.text.strip  == 'มูลค่าซื้อขาย/วัน (ลบ.)' )

			k = i 

  		end   	

  		if ( element.text.strip  == 'Beta' )

			l = i 

  		end 

	end

	i = 0
	offset = 7

	elements.each do |element|	

		i += 1

		case i

			when k+1
				tmp = element.text.chop 

				if (tmp == '-' || tmp == 'N/A' || tmp == '?')

					tmp = '0'

				end		

				array[offset+1] = tmp

			when l+1
				tmp = element.text.chop 

				if (tmp == '-' || tmp == 'N/A' || tmp == '?')

					tmp = '0'

				end

				array[offset+2] = tmp

		end	

	end 

	ary = []
	ary[0] = array[0]
	ary[1] = array[1]
	ary[2] = array[2]

	list = array[3].split("/")
	maxp = list[0].chop
	x = list[1]
	lngth = x.length
	minp = x[1,lngth-1]

	ary[3] = maxp
	ary[4] = minp
	ary[5] = array[4]
	ary[6] = array[5]
	ary[7] = strip_comma(array[6])
	ary[8] = strip_comma(array[7])
	ary[9] = strip_comma(array[8])
	ary[10] = array[9]
	out_line = ary.join(',') 
	out_line += "\n"
	puts out_line
	fo.write out_line	
	sleep(1)	
	
end

time = Time.new
puts 'End at: ' + time.strftime("%I:%M %p")

fo.close
