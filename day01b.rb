#!/usr/bin/ruby -w

string_numbers = ['one', 'two', 'three', 'four', 'five', 'six', 'seven', 'eight', 'nine']

#check if a char is a digit
def is_digit?(c)
    c.ord >= 48 && c.ord <= 57
end


def starting_number(string, string_numbers)
    char = 1
    string_numbers.each do |number|
        if string.start_with?(number)
            return char
        end
        char += 1
    end
    return -1
end

#scan string for numbers
def scan(string, string_numbers)
    numbers = []
    for i in 0..(string.length-1) do
        if is_digit?(string[i])
            numbers.push(string[i].to_i)
        else 
            starting_number_si = starting_number(string[i..-1], string_numbers) 
            if starting_number_si != -1
                numbers.push(starting_number_si)
            end
        end

    end
    return numbers
end

#combine first and last digit to a number in a array of numbers
def combine(numbers)
    (numbers[0].to_s + numbers[-1].to_s).to_i
end

sum = 0
#read strings from stdin and combine first and last digit
while line = gets
    sum += combine(scan(line, string_numbers))
end

puts sum