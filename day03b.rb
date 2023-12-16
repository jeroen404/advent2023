#!/usr/bin/ruby -w

$schematic = []
$valid_numbers = []
$gears_near_numbers = []

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

def surrounding_gears(x,y)
    gears = []
    for i in -1..1 do
        for j in -1..1 do
            if i != 0 || j != 0
                if x+i >= 0 && x+i < $schematic.length && y+j >= 0 && y+j < $schematic[0].length
                    if($schematic[y+j][x+i] == '*')
                        gears.push([y+j,x+i])
                    end
                end
            end
        end
    end
    return gears
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
    found_number = false
    valid_number = false
    constructed_number = ''
    surrounding_gears = []
    for x in 0..($schematic[y].length-1) do
        #puts x.to_s + ' ' + y.to_s + ' ' + $schematic[y][x].to_s
        #puts "found_number: #{found_number} valid_number: #{valid_number} constructed_number: #{constructed_number}"
        if ! found_number
            if is_digit?($schematic[y][x])
                found_number = true
                valid_number = valid_number || surrounded_by_a_symbol?(x,y)
                constructed_number += $schematic[y][x]
                surrounding_gears(x,y).each do |gear|
                    unless surrounding_gears.include?(gear)
                        surrounding_gears.push(gear)
                        #puts "pushed gear: #{gear} for number: #{constructed_number} at #{x},#{y}"
                    end
                end
            end
        else
            if is_digit?($schematic[y][x]) 
                valid_number = valid_number || surrounded_by_a_symbol?(x,y)
                constructed_number += $schematic[y][x]
                surrounding_gears(x,y).each do |gear|
                    unless surrounding_gears.include?(gear)
                        surrounding_gears.push(gear)
                        #puts "pushed gear: #{gear} for number: #{constructed_number} at #{x},#{y}"
                    end
                end
            else
                if valid_number
                    #puts "valid number: #{constructed_number}"
                    $valid_numbers.push(constructed_number.to_i)
                    $gears_near_numbers.push(surrounding_gears)
                end
                found_number = false
                valid_number = false
                constructed_number = ''
                surrounding_gears = []
            end
        end
    end
    if (valid_number)
        #puts "valid number: #{constructed_number}"
        $valid_numbers.push(constructed_number.to_i)
        $gears_near_numbers.push(surrounding_gears)
    end
end

while line = gets
    $schematic.push(line.chomp.chars)
end

for i in 0..($schematic.length-1) do
    valid_numbers_in_line(i)
end

#$valid_numbers.each do |number|
#    puts "number #{number} has gears near: " + $gears_near_numbers[$valid_numbers.index(number)].to_s
#end

numbers_near_gears = {}
i=0
$gears_near_numbers.each do |gears|
    gears.each do |gear|
        #puts "gear #{gear} has number "  + $valid_numbers[i].to_s
        if numbers_near_gears[gear] == nil
            numbers_near_gears[gear] = [$valid_numbers[i]]
        else
            numbers_near_gears[gear].push($valid_numbers[i])
        end
    end
    i += 1
end
#puts numbers_near_gears.to_s

sum = 0
numbers_near_gears.each do |gear, numbers|
    if numbers.length == 2
        ratio = numbers.inject(:*)
        #puts "ratio: #{ratio}"
        sum += ratio
    end
end

puts sum

#puts $gears_near_numbers.to_s

#sumtot = $valid_numbers.inject(:+)
#puts sumtot