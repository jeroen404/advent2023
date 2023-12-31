#!/usr/bin/ruby -w

$debug = false
$expansion_factor = 1000000 - 1

class Galaxy < Struct.new(:x,:y)
end

def distance(galaxy1, galaxy2)
    x_max = [galaxy1.x, galaxy2.x].max
    x_min = [galaxy1.x, galaxy2.x].min
    y_max = [galaxy1.y, galaxy2.y].max
    y_min = [galaxy1.y, galaxy2.y].min
    empty_cols_between = $empty_cols.select { |col| col > x_min && col < x_max }.length
    empty_rows_between = $empty_rows.select { |row| row > y_min && row < y_max }.length
    expansion_x = empty_cols_between * $expansion_factor  
    expansion_y = empty_rows_between * $expansion_factor
    x_distance = (galaxy1.x - galaxy2.x).abs + expansion_x
    y_distance = (galaxy1.y - galaxy2.y).abs + expansion_y
    return x_distance + y_distance 
end

def print_map(map)
    map.each do |row|
        puts row.join("")
    end
end

$map=[]

while line = gets do
    $map << line.chomp.each_char.to_a
end

print_map $map if $debug

$galaxies= []
$map.each_with_index do |row, row_index|
    row.each_with_index do |col, col_index|
        if col == "#" then
            $galaxies << Galaxy.new(col_index,row_index)
        end
    end
end

$empty_rows = (0..$map.length).to_a - $galaxies.map { |galaxy| galaxy.y } 
$empty_cols = (0..$map[0].length).to_a - $galaxies.map { |galaxy| galaxy.x }

puts "empty_rows: #{$empty_rows}" if $debug
puts "empty_cols: #{$empty_cols}" if $debug


puts $galaxies.combination(2).map { |g1,g2| distance(g1,g2) }.inject(:+)