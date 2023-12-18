#!/usr/bin/ruby -w

$debug = false

class HyperNode < Struct.new(:x,:y,:direction,:steps)
    def next_nodes(grid,part)
        nodes = []
        if part == 1 then
            if steps < 3 then
                xx,yy = direction.next_straigth(x,y)
                if grid.inside?(xx,yy) then
                    nodes << HyperNode.new(xx,yy,direction,steps+1)
                end
            end
            xx,yy = direction.next_left(x,y)
            if grid.inside?(xx,yy) then
                nodes << HyperNode.new(xx,yy,direction.left,1)
            end
            xx,yy = direction.next_right(x,y)
            if grid.inside?(xx,yy) then
                nodes << HyperNode.new(xx,yy,direction.right,1)
            end
            return nodes
        elsif part == 2 then
            if steps < 10 then
                xx,yy = direction.next_straigth(x,y)
                if grid.inside?(xx,yy) then
                    nodes << HyperNode.new(xx,yy,direction,steps+1)
                end
            end
            if steps > 3 then
                xx,yy = direction.next_left(x,y)
                if grid.inside?(xx,yy) then
                    nodes << HyperNode.new(xx,yy,direction.left,1)
                end
                xx,yy = direction.next_right(x,y)
                if grid.inside?(xx,yy) then
                    nodes << HyperNode.new(xx,yy,direction.right,1)
                end
            end
            return nodes
        end
    end

    def cost(grid)
        return grid[x,y]
    end
    def dict_hash_key
        #return "#{x}-#{y}-#{direction.cardinal}"
        #return [x,y,direction.cardinal,steps]
        return self
    end

    def to_s
        if direction.cardinal == 'N' then
              return '^'
        elsif direction.cardinal == 'E' then
              return '>'
        elsif direction.cardinal == 'S' then
              return 'v'
        elsif direction.cardinal == 'W' then
              return '<'
        end
    end
end

class Direction < Struct.new(:cardinal)
    def left
        if cardinal == 'N' then
            return Direction.new('W')
        elsif cardinal == 'W' then
            return Direction.new('S')
        elsif cardinal == 'S' then
            return Direction.new('E')
        elsif cardinal == 'E' then
            return Direction.new('N')
        end
    end

    def right
        if cardinal == 'N' then
            return Direction.new('E')
        elsif cardinal == 'E' then
            return Direction.new('S')
        elsif cardinal == 'S' then
            return Direction.new('W')
        elsif cardinal == 'W' then
            return Direction.new('N')
        end
    end

    def reverse
        if cardinal == 'N' then
            return Direction.new('S')
        elsif cardinal == 'E' then
            return Direction.new('W')
        elsif cardinal == 'S' then
            return Direction.new('N')
        elsif cardinal == 'W' then
            return Direction.new('E')
        end
    end

    def next_straigth(x,y)
        if cardinal == 'N' then
            return x,y-1
        elsif cardinal == 'E' then
            return x+1,y
        elsif cardinal == 'S' then
            return x,y+1
        elsif cardinal == 'W' then
            return x-1,y
        end
    end

    def next_left(x,y)
        return left.next_straigth(x,y)
    end

    def next_right(x,y)
        return right.next_straigth(x,y)
    end
end

class Grid < Struct.new(:nodes)
    def initialize
        super([])
    end

    def [](x,y)
        return nodes[y][x]
    end

    def []=(x,y,value)
        nodes[y][x] = value
    end

    def width
        return nodes[0].length
    end

    def height
        return nodes.length
    end

    def outside?(x,y)
        return x < 0 || y < 0 || x >= width || y >= height
    end
    def inside?(x,y)
        return !outside?(x,y)
    end

    def print_grid
        nodes.each do |row|
            row.each do |node|
                print node.to_s
            end
            puts
        end
    end
end


#read grid from STDIN
grid = Grid.new
while line = gets do
    grid.nodes << line.chomp.split('').map { |c| c.to_i}
end
#grid.print_grid

finish_x,finish_y = [grid.width-1,grid.height-1]


start_S = HyperNode.new(0,1,Direction.new('S'),1)
start_E = HyperNode.new(1,0,Direction.new('E'),1)

queue = []
queue << start_S
queue << start_E

dist = {}
dist[start_S.dict_hash_key] = start_S.cost(grid)
dist[start_E.dict_hash_key] = start_E.cost(grid)

previous = {}

part = 2

found_node = nil
while not queue.empty? do
    current_min_val = queue.map{|n| dist[n]}.min
    current_min = queue.select{|n| dist[n] == current_min_val}.first
    if current_min.x == finish_x and current_min.y == finish_y and current_min.steps > 3 then
        found_node = current_min
        break
    end
    queue.delete(current_min)
    current_min.next_nodes(grid,part).each do |next_node|
            if dist[next_node.dict_hash_key] == nil or dist[next_node.dict_hash_key] > dist[current_min.dict_hash_key] + next_node.cost(grid) then
                queue << next_node
                dist[next_node.dict_hash_key] = dist[current_min.dict_hash_key] + next_node.cost(grid)
                previous[next_node] = current_min
            end
        #end
    end
end

puts dist[found_node.dict_hash_key]

exit

# prev = previous[found_node]
# cost = grid[finish_x,finish_y]
# grid[finish_x,finish_y] = 'X'
# grid[0,0] = 'X'
# while not ((prev.x == 0) and (prev.y == 0)) do
#     cost += grid[prev.x,prev.y].to_i
#     grid[prev.x,prev.y] = prev.to_s
#     prev = previous[prev]
#     if prev == nil then
#         puts "prev is nil"
#         break
#     end
# end
# grid.print_grid

# puts "cost: #{cost}"

