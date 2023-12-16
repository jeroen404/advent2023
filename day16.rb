#!/usr/bin/ruby -w
# set RUBY_THREAD_VM_STACK_SIZE=5000000
# want ik ga niet recursief wegdoen :middle_finger:

$debug = false

class Node < Struct.new(:mirror,:beams)

    def propagate(beam)
        if beams.include?(beam) then
            return
        else 
            beams << beam
            mirror.reflect(beam).select{|b| b.valid?}.each do |b|
                $grid[b.y][b.x].propagate(b)
            end
        end
    end

    def energized?
        return beams.length > 0
    end

end

class Beam < Struct.new(:x,:y,:dx,:dy)
    def valid?
        return !outside?(x,y)
    end
end

class Mirror < Struct.new(:type)
    def reflect(beam)
        if type == '.' then
            return [Beam.new(beam.x+beam.dx,beam.y+beam.dy,beam.dx,beam.dy)]
        elsif type == '/' then
            if beam.dx == 0 then
                return [Beam.new(beam.x-beam.dy,beam.y,-beam.dy,0)]
            else
                return [Beam.new(beam.x,beam.y-beam.dx,0,-beam.dx)]
            end
        elsif type == '\\' then
            if beam.dx == 0 then
                return [Beam.new(beam.x+beam.dy,beam.y,beam.dy,0)]
            else
                return [Beam.new(beam.x,beam.y+beam.dx,0,beam.dx)]
            end
        elsif type == '|' then
            if beam.dx == 0 then
                return [Beam.new(beam.x,beam.y+beam.dy,0,beam.dy)]
            else
                return [Beam.new(beam.x,beam.y+1,0,1),Beam.new(beam.x,beam.y-1,0,-1)]
            end
        elsif type == '-' then
            if beam.dx == 0 then
                return [Beam.new(beam.x+1,beam.y,1,0),Beam.new(beam.x-1,beam.y,-1,0)]
            else
                return [Beam.new(beam.x+beam.dx,beam.y,beam.dx,0)]
            end
        end 
        raise "Unknown mirror type #{type}"
    end
end

def outside?(x,y)
    return x < 0 || y < 0 || x >= $grid[0].length || y >= $grid.length
end

def print_grid
    $grid.each do |row|
        row.each do |node|
            print node.mirror.type
        end
        puts
    end
end

def print_energy
    $grid.each do |row|
        row.each do |node|
            if node.energized? and node.mirror.type == '.' then
                if node.beams.length == 1 then
                    if node.beams[0].dx == 1 then
                        print '>'
                    elsif node.beams[0].dx == -1 then
                        print '<'
                    elsif node.beams[0].dy == 1 then
                        print 'v'
                    elsif node.beams[0].dy == -1 then
                        print '^'
                    else
                        print '?'
                    end
                else
                    print node.beams.length
                end
            else
                print node.mirror.type
            end
        end
        puts
    end
end

def reset_grid
    $grid.each do |row|
        row.each do |node|
            node.beams = []
        end
    end
end

def score_grid
    return $grid.flatten.select{|n| n.energized?}.length
end

$grid = []
while line = gets do
    $grid << line.chomp.split('').map { |type| Node.new(Mirror.new(type),[]) }
end
print_grid if $debug

max_energy = 0
for x in 0..$grid[0].length-1 do
    reset_grid
    $grid[0][x].propagate(Beam.new(x,0,0,1))
    max_energy = [max_energy, score_grid()].max
    reset_grid
    y=$grid.length-1
    $grid[y][x].propagate(Beam.new(x,y,0,-1))
    max_energy = [max_energy, score_grid()].max
end
for y in 0..$grid.length-1 do
    reset_grid
    $grid[y][0].propagate(Beam.new(0,y,1,0))
    max_energy = [max_energy, score_grid()].max
    reset_grid
    x=$grid[0].length-1
    $grid[y][x].propagate(Beam.new(x,y,-1,0))
    max_energy = [max_energy, score_grid()].max
end

puts max_energy

# part1:
#initial_beam = Beam.new(0,0,1,0)
#$grid[0][0].propagate(initial_beam)
#puts $grid.flatten.select{|n| n.energized?}.length
#print_energy if $debug




