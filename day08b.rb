#!/usr/bin/ruby -w

$instructions = []
$nodes = {}

class Node
    def initialize(name, left, right)
        @name = name
        @left = left
        @right = right
    end

    def left
        @left
    end

    def right
        @right
    end

    def name
        @name
    end

    def inspect
        return "Node #{@name} left: #{@left} right: #{@right}"
    end
end


$instructions = gets.chomp.each_char.to_a
gets 

while line = gets
    line.chomp!
    name,left,right = line.match(/(\w+)\s+\=\s+\((\w+),\s+(\w+)\)/).captures 
    $nodes[name] = Node.new(name , left, right)
end


start_nodes = $nodes.select { |k,v| k =~ /A$/ }

steps_collection = []
start_nodes.each do |node_name,node|
    steps = 0
    next_node = node_name
    $instructions.cycle do |instruction|
            if next_node =~ /Z$/ then
                steps_collection << steps
                break
            end
        next_node = (instruction == "L") ? $nodes[next_node].left : $nodes[next_node].right
        steps += 1
    end
end

puts steps_collection.inject(1,:lcm)