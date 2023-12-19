#!/usr/bin/ruby -w

$debug = true

class Node < Struct.new(:x,:y)
end

class Instruction < Struct.new(:direction,:steps,:color)
    def new_x(x)
        if direction == 'R' then
            return x + steps
        elsif direction == 'L' then
            return x - steps 
        end
        return x
    end
    def new_y(y)
        if direction == 'U' then
            return y - steps 
        elsif direction == 'D' then
            return y + steps 
        end
        return y
    end
end

def decode_color(color)
    steps = color[0..4].to_i(16)
    case color[5]
    when '0'
        direction = 'R'
    when '1'
        direction = 'D'
    when '2'
        direction = 'L'
    when '3'
        direction = 'U'
    end

    return direction,steps
end

instructions = STDIN.read.split(/\n/).map do |line|
    direction,steps,color = line.match(/(\w) (\d+) \(\#([a-f0-9]+)\)/).captures
    direction,steps = decode_color(color)

    Instruction.new(direction,steps.to_i,color)
end

input_nodes = []
current_node = Node.new(0,0)
input_nodes << current_node

instructions.each do |instruction|
    new_x = instruction.new_x(current_node.x)
    new_y = instruction.new_y(current_node.y)
    current_node = Node.new(new_x,new_y)
    input_nodes << current_node
end

puts input_nodes.last.x.to_s + ',' + input_nodes.last.y.to_s if $debug

min_x = input_nodes.map { |n| n.x }.min
min_y = input_nodes.map { |n| n.y }.min

nodes = input_nodes.map { |n| Node.new(n.x-min_x,n.y-min_y) }

# buitenkant
perimeter = 0
nodes.each_with_index do |node,index|
    next_node = nodes[(index+1) % nodes.length]
    perimeter += (node.x-next_node.x).abs + (node.y-next_node.y).abs
end

puts perimeter.to_s if $debug

# binnenkant
shoelace = 0
nodes.each_with_index do |node,index|
    next_node = nodes[(index+1) % nodes.length]
    shoelace += (node.x*(next_node.y) - node.y*(next_node.x))
end

area = shoelace/2 + perimeter/2 + 1
puts area.to_s 


