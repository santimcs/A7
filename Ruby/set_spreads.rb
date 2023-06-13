#!/usr/bin/env ruby

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



if ARGV.length != 2
  puts "Usage: #{$0} fm_price to_price"
  exit 1
end

fm_price = ARGV[0].to_f
to_price = ARGV[1].to_f

spreads = spreads_between(fm_price, to_price)

puts "Number of spreads between #{fm_price} THB and #{to_price} THB: #{spreads}"
