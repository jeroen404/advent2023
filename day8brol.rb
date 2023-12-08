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

def finished?(current_nodes)
    return (current_nodes.keys.select { |k| k =~ /Z$/ }.length == current_nodes.length)
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

#debug

steps = 0
current_nodes = $nodes.select { |k,v| k =~ /A$/ }

while ! finished? (current_nodes) do
    $instructions.each do |instruction|
        steps += 1
        new_currentnodes = current_nodes.map do |current_node_name, current_node|
            if instruction == "L" then
                new_name = $nodes[current_node.name].left
            elsif instruction == "R" then
                new_name = $nodes[current_node.name].right
            end
            new_node = $nodes[new_name]
            [new_name, new_node]
        end
        current_nodes = new_currentnodes.to_h
    end
end

puts steps