#!/usr/bin/ruby -w

$debug = false

class Node < Struct.new(:x, :y, :type)
    attr_accessor :neighbours, :connections, :distance, :outside
    
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
        @outside = false
    end

    def outside?
        @outside
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
        if other == nil then return false end
        return (x == other.x and y == other.y)
    end

    def next(prev)
        next_node = connections.select { |node| node != prev }[0]
        return next_node
    end

    def spread_north
        if y-1 >= 0 then
            if not $double_matrix[y-1][x].outside? then
                if distance == -1 then
                    if ['.','*'].include?($double_matrix[y-1][x].type)
                        $double_matrix[y-1][x].outside = true
                        return $double_matrix[y-1][x]
                    end
                end
            end
        end
        return nil
    end

    def spread_south
        if y+1 < $double_matrix.length then
            if not $double_matrix[y+1][x].outside? then
                if distance == -1 then
                    if ['.','*'].include?($double_matrix[y+1][x].type)
                        $double_matrix[y+1][x].outside = true
                        return $double_matrix[y+1][x]
                    end
                end
            end
        end
        return nil
    end

    def spread_east
        if x+1 < $double_matrix[0].length then
            if not $double_matrix[y][x+1].outside? then
                if distance == -1 then
                    if ['.','*'].include?($double_matrix[y][x+1].type)
                        $double_matrix[y][x+1].outside = true
                        return $double_matrix[y][x+1]
                    end
                end
            end    
        end
        return nil
    end

    def spread_west
        if x-1 >= 0 then
            if not $double_matrix[y][x-1].outside? then
                if distance == -1 then
                    if ['.','*'].include?($double_matrix[y][x-1].type)
                        $double_matrix[y][x-1].outside = true
                        return $double_matrix[y][x-1]
                    end
                end
            end
        end
        return nil
    end

    def spread_outside
        new_outside = []
        
        new_outside.push(spread_north)
        new_outside.push(spread_south)
        new_outside.push(spread_east)
        new_outside.push(spread_west)
        return new_outside.select { |node| node != nil }
    end
       
    def set_start_node_true_type
        if type == 'S' then
            up = connections.detect { |node| node.y == y-1 }
            down = connections.detect { |node| node.y == y+1 }
            left = connections.detect { |node| node.x == x-1 }
            right = connections.detect { |node| node.x == x+1 }
            if up and down then
                type = '|'
            end
            if left and right then
                type = '-'
            end
            if up and right then
                type = 'L'
            end
            if up and left then
                type = 'J'
            end
            if down and left then
                type = '7'
            end
            if down and right then
                type = 'F'
            end
            self.type = type
        else
            raise "start node is not S but #{self}"
        end
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

def print_matrix(matrix)
    matrix.each do |row|
        row.each do |node|
            print node.type
        end
        print '  '
        row.each do |node|
            if node.outside? then
                print 'O'
            else
                print node.type
            end
        end
        puts
    end
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
Node.start_node.set_start_node_true_type

print_matrix($input_matrix) if $debug

$double_matrix = []
$input_matrix.each_with_index do |row, y|
    $double_matrix[y*2] = []
    $double_matrix[y*2+1] = []
    row.each_with_index do |node, x|
        if node.distance == -1 then
            $double_matrix[y*2].push(Node.new(x*2, y*2, '.'))
            $double_matrix[y*2].push(Node.new(x*2+1, y*2, '*'))
            $double_matrix[y*2+1].push(Node.new(x*2, y*2+1, '*'))
            $double_matrix[y*2+1].push(Node.new(x*2+1, y*2+1, '*'))
        else
            $double_matrix[y*2].push(Node.new(x*2, y*2, node.type))
            if ['-','F','L'].include?(node.type) then
                $double_matrix[y*2].push(Node.new(x*2+1, y*2, '-'))
            else
                $double_matrix[y*2].push(Node.new(x*2+1, y*2, '*'))
            end
            if ['|','F','7'].include?(node.type) then
                $double_matrix[y*2+1].push(Node.new(x*2, y*2+1, '|'))
            else
                $double_matrix[y*2+1].push(Node.new(x*2, y*2+1, '*'))
            end
            $double_matrix[y*2+1].push(Node.new(x*2+1, y*2+1, '*'))
        end
    end
end 


print_matrix($double_matrix) if $debug



#mark border nodes as outside
$double_matrix[0].each { |node| node.type == '.' ? node.outside = true : node.outside = false }
$double_matrix[-1].each { |node| node.type == '.' ?  node.outside = true : node.outside = false}
$double_matrix.each { |row| row[0].type == '.' ? row[0].outside = true : row[0].outside = false }
$double_matrix.each { |row| row[-1].type == '.' ? row[-1].outside = true : row[-1].outside = false }

new_outside = $double_matrix.flatten.select { |node| node.outside? }
while (new_outside.length > 0) do
    next_outside = []
    new_outside.each do |node|
            next_outside |= node.spread_outside # union
    end
    new_outside = next_outside
    puts "---------------------------------" if $debug
    print_matrix($double_matrix) if $debug
 
end

puts $double_matrix.flatten.select { |node| node.type == '.' and (not node.outside?) }.length

#puts $input_matrix.flatten.inject(0) { | max , node | node.distance > max ? node.distance : max }