#!/usr/bin/ruby -w

#check if a char is a digit
def is_digit?(c)
    c.ord >= 48 && c.ord <= 57
end

# get first digit in string
def first_digit(string)
    string.each_char do |c|
        if is_digit?(c)
            return c
        end
    end
    return '0'
end

# get last digit in string
def last_digit(string)
    string.reverse.each_char do |c|
        if is_digit?(c)
            return c
        end
    end
    return '0'
end

# combine first and last digit to a number in a string
def combine(first, last)
    (first + last).to_i
end

sum = 0
#read strings from stdin and combine first and last digit
while line = gets
    sum += combine(first_digit(line), last_digit(line))
end

puts sum