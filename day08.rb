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

    def inspect
        return "Node #{@name} left: #{@left} right: #{@right}"
    end
end

def debug
    puts "Instructions: #{$instructions.to_s}"
    puts "Nodes: #{$nodes}"
end

$instructions = gets.chomp.each_char.to_a
gets 

while line = gets
    line.chomp!
    name,left,right = line.match(/(\w+)\s+\=\s+\((\w+),\s+(\w+)\)/).captures 
    $nodes[name] = Node.new(name , left, right)
end

debug

steps = 0
current_node = "AAA"

while current_node != "ZZZ" do
    $instructions.each do |instruction|
        steps += 1
        if instruction == "L" then
            current_node = $nodes[current_node].left
        elsif instruction == "R" then
            current_node = $nodes[current_node].right
        end
    end
end

puts steps