#!/usr/bin/ruby -w

$schemas = []

def find_mirror_y(schema)
    if schema.length <= 2 then
        puts "schema too small"
        return 0
    end
    (schema.size-1).times do |y|
        mirror = true
        schema[0].size.times do |x|
            for yy in y+1..(schema.length-1) do
                yyy = y - (yy - y) + 1
                if yyy >= 0 then
                    #puts "y: #{y} x: #{x} yy: #{yy} yyy: #{yyy} schema[yy][x]: #{schema[yy][x]} schema[yyy][x]: #{schema[yyy][x]} mirror: #{mirror}"
                    if not (schema[yy][x] == schema[yyy][x]) then
                        mirror = false
                    end
                else
                    break
                end
            end
            if not mirror then
                break
            end
        end
        if mirror
           return y
        end
    end
    return -1
end

def find_mirror_x(schema)
    schema_flip = schema.transpose
    return find_mirror_y(schema_flip)
end

def score(schema)
    x_mirror = find_mirror_x(schema)
    x_score =  x_mirror > -1 ? x_mirror + 1 : 0
    y_mirror = find_mirror_y(schema)
    y_score =  y_mirror > -1 ? (y_mirror + 1)*100 : 0
    return x_score + y_score
end

def print_schema(schema)
    schema.each_with_index do |row,index|
        puts (index).to_s + ' ' + row.join("")
    end
end


schema = []
while line = gets
    if line.length > 1 then
        schema.push(line.chomp.each_char.to_a)
    else
        $schemas.push(schema)
        schema = []
    end
end
$schemas.push(schema)

# $schemas.each do |schema|
#     puts "schema:"
#     print_schema(schema)
#     puts "mirror_y: #{find_mirror_y(schema)}"
#     puts "mirror_x: #{find_mirror_x(schema)}"
#     puts "score: #{score(schema)}"
# end

# puts $schemas.map {|s| find_mirror_y(s) }.to_s
# puts $schemas.map {|s| find_mirror_x(s) }.to_s
puts $schemas.map {|s| score(s) }.inject(:+)