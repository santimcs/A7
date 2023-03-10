# encoding: utf-8
require 'nokogiri'
require 'open-uri'
load './ruby/my_utils.rb'

# file_in   = '..\data\name-ttl.csv'
# file_out  = '..\data\consensus.csv'

# Get the current script's directory
current_dir = File.dirname(__FILE__)
# Construct the file path to the input folder
input_dir = File.join(current_dir, '..', 'Data')
# Construct the file path to the output folder
output_dir = File.join(current_dir, '..', 'Data')

# Construct the file path to the input file
file_in = File.join(input_dir, "name-ttl.csv")
# Construct the file path to the output file
file_out = File.join(output_dir, "consensus.csv")

fi = File.open(file_in, "r")
fo = File.open(file_out,"w") 

# Column Header
header = 'Name,Price,Buy,Hold,Sell,EPS_a,EPS_b,PE,PBV,DIV%,Target,Sts'
header += "\n"
fo.write(header) #   '..\data\consensus.csv

time = Time.new
puts 'Start at: ' + time.strftime("%A, %b %d %I:%M %p") 
puts header 

j = 0 # record number to display at the end of the line

fi.each do |line|

  stock_name = line.chomp
  status = 'x'
  url = "http://classic.settrade.com/AnalystConsensus/C04_10_stock_saa_p1.jsp?txtSymbol=#{stock_name}&ssoPageId=11&selectPage=10"
  html_data = open(url).read
  html_data = html_data.force_encoding("utf-8")
  doc = Nokogiri::HTML(html_data)

  array = []
  ary_out = []
  array[0] = stock_name.upcase
  ary_out[0] = stock_name.upcase
  ary_out[11] = status.upcase
  elements = doc.xpath("//div[@class='text-right']/h1")
  i = 0

  elements.each do | element |

    i += 1
  	price = element.text
  	ary_out[i] = element.text

  end

  # =>  retrieve buy, hold, sell
  elements = doc.xpath("//div[@class='row separate-content']/div[@class='col-xs-12']/div[@class='row']/div")
  i = 0

  elements.each do | element |
    
    case i

      when 2 
        ary_out[2] = element.text
      when 5 
        ary_out[3] = element.text
      when 8 
        ary_out[4] = element.text  

    end

    i += 1

  end

  elements = doc.xpath("//table[@class='table table-info']/tfoot/tr/td")
  i = 0

  elements.each do | element |

    i += 1

    if (i > 1 and i < 10)

      str = strip_comma(element.text.strip)

      if (str == '-')

        str = '0'

      end

      case i

        when 2
          ary_out[5]  = str  # EPS_a
        when 4
          ary_out[6]  = str  # EPS_b
        when 6
          ary_out[7]  = str  # P/E
        when 7
          ary_out[8]  = str  # P/BV
        when 8
          ary_out[9]  = str  # DIV%
        when 9
          ary_out[10] = str  # Target Price

      end

    end

  end

  if (ary_out[5] != nil)  # EPS_a

    out_line = ary_out.join(',')
    out_line += "\n"
    fo.write(out_line) 

    j += 1
    
    printf "%-8s %6.2f %2d %2d %2d %6.2f %6.2f %9.1f %9.1f %5s %6.2f %1s %3d\n", 
    ary_out[0], ary_out[1], ary_out[2], ary_out[3],
    ary_out[4], ary_out[5], ary_out[6], ary_out[7],
    ary_out[8], ary_out[9], ary_out[10], ary_out[11], j    

  end

 sleep(1)

end

time = Time.new
puts 'End at: ' + time.strftime("%A, %b %d %I:%M %p")

fo.close
fi.close
