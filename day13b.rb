#!/usr/bin/ruby -w

$schemas = []

def find_mirror_y(schema,smudges)
    if schema.length <= 2 then
        raise "schema too small"
    end
    (schema.size-1).times do |y|
        faults = 0
        schema[0].size.times do |x|
            for yy in y+1..(schema.length-1) do
                yyy = y - (yy - y) + 1 # 2*y - yy + 1 onder de vrienden
                if yyy >= 0 then
                    if not (schema[yy][x] == schema[yyy][x]) then
                        faults += 1
                    end
                else
                    break
                end
            end
            if faults > smudges then
                break
            end
        end
        if faults == smudges
           return y
        end
    end
    return -1
end

# hihi
def find_mirror_x(schema,smudges)
    schema_flip = schema.transpose
    return find_mirror_y(schema_flip,smudges)
end

def score(schema,smudges)
    x_mirror = find_mirror_x(schema,smudges)
    y_mirror = find_mirror_y(schema,smudges)
    return x_mirror + (y_mirror + 1)*100
end

def print_schema(schema)
    schema.each_with_index do |row,index|
        puts (index).to_s + ' ' + row.join("")
    end
end

## input
STDIN.split("\n\n").each do |schema|
    $schemas.push(schema.split("\n").map {|s| s.split("") })
end

# deel 1 & 2
puts $schemas.map {|s| score(s,0) }.inject(:+)
puts $schemas.map {|s| score(s,1) }.inject(:+)