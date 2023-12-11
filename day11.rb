#!/usr/bin/ruby -w

$debug = false

class Galaxy < Struct.new(:x,:y)
end

def distance(galaxy1, galaxy2)
    x_distance = (galaxy1.x - galaxy2.x).abs 
    y_distance = (galaxy1.y - galaxy2.y).abs 
    return x_distance + y_distance 
end

def print_map(map)
    map.each do |row|
        puts row.join("")
    end
end

$original_map=[]

while line = gets do
    $original_map << line.chomp.each_char.to_a
end

print_map $original_map if $debug

$expanded_map = []

empty_rows = 0
$original_map.each_with_index do |row, row_index|
    $expanded_map[row_index+empty_rows] = row
    if not row.include? "#" then
        empty_rows += 1
        $expanded_map[row_index+empty_rows] = row.clone #hopelijk geen deep clone nodig
    end
end
empty_cols = []
for i in 0..$expanded_map[0].length-1 do
    if not ($expanded_map.detect { |row| row[i] == "#" }) then
        empty_cols << i
    end
end

puts "empty_cols: #{empty_cols}" if $debug

$expanded_map.each_with_index do |row, row_index|
    inserted = 0
    row.each_with_index do |col, col_index|
        if empty_cols.include? col_index then
            $expanded_map[row_index].insert(col_index+inserted+1,'.') 
            inserted += 1
        end
    end
end

puts "-------------------" if $debug
print_map $expanded_map if $debug

$galaxies= []
$expanded_map.each_with_index do |row, row_index|
    row.each_with_index do |col, col_index|
        if col == "#" then
            $galaxies << Galaxy.new(col_index,row_index)
        end
    end
end


puts $galaxies.combination(2).map { |g1,g2| distance(g1,g2) }.inject(:+)