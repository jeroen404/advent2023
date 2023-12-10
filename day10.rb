#!/usr/bin/ruby -w

class Node < Struct.new(:x, :y, :type)
    attr_accessor :neighbours, :connections, :distance
    
    @@start_node = nil

    def self.start_node
        @@start_node
    end



    def initialize(x, y, type)
        super(x, y, type)
        @neighbours = []
        @connections = []
        if type == 'S'
            @@start_node = self
        end
        @distance = -1
    end
    def add_neighbour(node)
        update_connections_with(node)
        @neighbours | [node]  # union
    end
    def update_connections_with(node)
        if type == '.' then return end
        if node.type == '.' then return end
        if type == 'S' and valid_any?(node) then @connections << node end
        if type == '|' and (valid_north?(node) or  valid_south?(node)) then @connections << node end
        if type == '-' and (valid_west?(node) or valid_east?(node)) then @connections << node end
        if type == 'L' and (valid_north?(node) or valid_east?(node)) then @connections << node end
        if type == 'J' and (valid_north?(node) or valid_west?(node)) then @connections << node end
        if type == '7' and (valid_south?(node) or valid_west?(node)) then @connections << node end
        if type == 'F' and (valid_south?(node) or valid_east?(node)) then @connections << node end
            #puts "connections for #{self} are #{connections} after adding #{node}"
    end
    
    def valid_south?(node)
        return ((node.type == '|' or node.type == 'L' or node.type == 'J' or node.type == 'S') and node.y == y+1)
    end
    def valid_north?(node)
        return ((node.type == '|' or node.type == '7' or node.type == 'F' or node.type == 'S') and node.y == y-1)
    end
    def valid_east?(node)
        return ((node.type == '-' or node.type == 'J' or node.type == '7' or node.type == 'S') and node.x == x+1)
    end
    def valid_west?(node)
        return ((node.type == '-' or node.type == 'L' or node.type == 'F' or node.type == 'S') and node.x == x-1)
    end
    def valid_any?(node)
        return (valid_north?(node) or valid_south?(node) or valid_west?(node) or valid_east?(node))
    end

    def ==(other)
        return (x == other.x and y == other.y)
    end

    

    def next(prev)
        next_node = connections.select { |node| node != prev }[0]
        return next_node
    end



    def inspect
        return "<#{x} #{y} #{type}>"
    end
    
end

def surrounding_nodes(x, y)
    nodes = []

    if x-1 >= 0
        nodes.push($input_matrix[y][x-1])
    end
    if x+1 < $input_matrix[0].length
        nodes.push($input_matrix[y][x+1])
    end
    if y-1 >= 0
        nodes.push($input_matrix[y-1][x])
    end
    if y+1 < $input_matrix.length
        nodes.push($input_matrix[y+1][x])
    end
    return nodes
end

$input_matrix = []

y = 0
while line = gets
    $input_matrix.push(line.chomp.each_char.each_with_index.map { |c,x| Node.new(x,y,c) })
    y += 1
end

$input_matrix.each_with_index do |row, y|
    row.each_with_index do |node, x|
        surrounding_nodes(x, y).each do |neighbour|
            node.add_neighbour(neighbour)
        end
    end
end

Node.start_node.distance = 0
Node.start_node.connections.each do |node|
    dist = 1
    cur_node = node
    prev_node = Node.start_node
    while (cur_node.distance == -1) or (cur_node.distance > dist) do
        cur_node.distance = dist
        next_node = cur_node.next(prev_node)
        prev_node = cur_node
        cur_node = next_node
        dist += 1
    end
end

puts $input_matrix.flatten.inject(0) { | max , node | node.distance > max ? node.distance : max }