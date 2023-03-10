require 'nokogiri'
require 'open-uri'
# require 'certified'

def strip(string)
	new_str = ''
	str = string
	str.each_byte do  |x| 
    	if ("#{x.chr}" != ',')
      		new_str = new_str + "#{x.chr}"
    	end
	end
	return new_str	
end

# file_out = 'c:\A8\data\setindex.csv'

# Get the current script's directory
current_dir = File.dirname(__FILE__)

# Construct the file path to the output folder
output_dir = File.join(current_dir, '..', 'Data')

# Construct the file path to the output file
file_out = File.join(output_dir, "setindex.csv")

fo = File.open(file_out, "w")

url = "https://classic.settrade.com/settrade/home"

html_data = open(url).read
doc = Nokogiri::HTML(html_data)

array = []
ary_out = []
ary_out[0] = Date.today

elements = doc.xpath("//div[@class='value']")
puts elements
i = 0
elements.each do | element |
        puts i.to_s + ' ' + element.text
  case i
    when 0 
      ary_out[1] = strip(element.text)                       
  end
  puts ary_out[i]
  i += 1

end

#  printf "Date %10s Index %10s", ary_out[0],ary_out[1]
out_line = ary_out.join(",")
out_line = out_line + "\n"
puts out_line
fo.write out_line
fo.close

