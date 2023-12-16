#!/usr/bin/ruby -w

$schematic = []

#get surrounding chars of a char
def surrounding_chars(x, y)
    chars = []
    for i in -1..1 do
        for j in -1..1 do
            if i != 0 || j != 0
                if x+i >= 0 && x+i < $schematic.length && y+j >= 0 && y+j < $schematic[0].length
                    chars.push($schematic[y+j][x+i])
                end
            end
        end
    end
    return chars
end

def is_digit?(c)
    c.ord >= 48 && c.ord <= 57
end

def surrounded_by_a_symbol?(x,y)
    #puts "surrounded_by_a_symbol? #{x} #{y} surrounding_chars: #{surrounding_chars(x, y).to_s}" 
    surrounding_chars(x, y).each do |c|
        if ! (is_digit?(c) || c == '.')
            return true
        end
    end
    return false
end

def valid_numbers_in_line(y)
    numbers = []
    found_number = false
    valid_number = false
    constructed_number = ''
    for x in 0..($schematic[y].length-1) do
        #puts x.to_s + ' ' + y.to_s + ' ' + $schematic[y][x].to_s
        #puts "found_number: #{found_number} valid_number: #{valid_number} constructed_number: #{constructed_number}"
        if ! found_number
            if is_digit?($schematic[y][x])
                found_number = true
                valid_number = valid_number || surrounded_by_a_symbol?(x,y)
                constructed_number += $schematic[y][x]

            end
        else
            if is_digit?($schematic[y][x]) 
                valid_number = valid_number || surrounded_by_a_symbol?(x,y)
                constructed_number += $schematic[y][x]
            else
                if valid_number
                    #puts "valid number: #{constructed_number}"
                    numbers.push(constructed_number.to_i)
                end
                found_number = false
                valid_number = false
                constructed_number = ''
            end
        end
    end
    if (valid_number)
        #puts "valid number: #{constructed_number}"
        numbers.push(constructed_number.to_i)
    end
    return numbers
end

while line = gets
    $schematic.push(line.chomp.chars)
end


sumtot = 0
for i in 0..($schematic.length-1) do
    sumtot += valid_numbers_in_line(i).inject(0) { |sum, x| sum + x }
end
puts sumtot