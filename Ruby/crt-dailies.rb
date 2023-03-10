require 'nokogiri'
require 'open-uri'
require 'certified'
load './ruby/my_utils.rb'

process = ARGV.shift

# file_in = '..\data\name-ttl.csv'
# file_out = '..\data\dailies.csv'
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
file_out = File.join(output_dir, "dailies.csv")

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
header = 'name,date,prv,open,high,low,price,volume,daily_volume,par,ceiling,floor,chg_amt,chg_pct'
header += "\n"
fo.write(header) #   '..\data\dailies.csv 

time = Time.new
puts 'Start at: ' + time.strftime("%I:%M %p")

fi = File.open(file_temp, "r")
fi.each do |line|

	stock_name = line.chomp
	# stock_name = CGI.escape(line.chomp)
	url = "https://classic.settrade.com/C04_01_stock_quote_p1.jsp?txtSymbol=#{stock_name}"
	html_data = open(url).read
	doc = Nokogiri::HTML(html_data)

	elements = doc.xpath("//div[contains(text(),'ข้อมูลล่าสุด')]")
	tmp = elements.text
	list = tmp.split(" ")
	date1 = list[1]
	list = date1.split("/")
	date2 = list[2]+'-'+list[1]+'-'+list[0]

	elements = doc.xpath("//h1")
	i, price = 0
	chgamt, chgpct = ''
	elements.each do |element|	
		case i
			when 1
				price = element.text.strip 
			when 2
				chgamt = element.text.strip 
			when 3
				chgpct = element.text.strip 
		end 
		i += 1 
	end

	elements = doc.xpath("//table[@class='table table-info']//tr//td")
	i, j = 0
	array = []
	array[0] = stock_name.upcase
	array[1] = date2
	offset = 1

	elements.each do |element|	

		if i.odd?

			case i

				when i

					tmp = element.text.strip
					j = (i/2)+1
					array[offset+j] = tmp

			end	 #case

		end #odd
		i += 1

	end #element

	ary = []
	ary[0] = array[0]
	ary[1] = array[1]
	ary[2] = array[2]
	ary[3] = array[3]
	ary[4] = array[4]
	ary[5] = array[5]
	ary[6] = price
	ary[7] = strip_comma(array[7])
	float_field = strip_comma(array[8])
	if (float_field == '-')
		float_field = 0
	end
	ary[8] = float_field
	ary[9] = array[9]
	ary[10] = strip_comma(array[10])
	ary[11] = array[11]	
	ary[12] = chgamt
	ary[13] = chgpct.chop

	out_line = ary.join(',') 
	out_line += "\n"
	puts out_line
	fo.write out_line	
	sleep(1)	
	
end #line

time = Time.new
puts 'End at: ' + time.strftime("%I:%M %p")
fo.close
fi.close