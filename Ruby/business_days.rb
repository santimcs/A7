#!/usr/bin/env ruby

require 'date'

def business_days_between(fm_date, to_date)
  business_days = 0

  current_date = fm_date

  while current_date <= to_date
    unless current_date.saturday? || current_date.sunday?
      business_days += 1
    end
    current_date = current_date.next_day
  end

  business_days
end

if ARGV.length != 2
  puts "Usage: #{$0} fm_date to_date (format: YYYY-MM-DD)"
  exit 1
end

fm_date = Date.parse(ARGV[0])
to_date = Date.parse(ARGV[1])

business_days = business_days_between(fm_date, to_date)

puts "Business days between #{fm_date} and #{to_date}: #{business_days}"
