#!/usr/bin/ruby -w

$seeds = []

$map_mapper_map = {}

$maps = {}

$seeds = gets.sub(/seeds: /,'').split(' ').map { |x| x.to_i }
#puts "seeds: " + $seeds.to_s

def walk_map(source,source_number)
    destination_number = -1
    $maps[source].each do |mapping|
        if source_number >= mapping[1] && source_number <= mapping[1] + mapping[2]
            destination_number = mapping[0] + (source_number - mapping[1])
            break
        end
    end
    if destination_number == -1
        destination_number = source_number
    end
    #puts "source: #{source} source_number: #{source_number} destination_number: #{destination_number}"
    if $map_mapper_map[source] == "location"
        return destination_number
    else
        return walk_map($map_mapper_map[source],destination_number)
    end
end
            
current_source = "seed"
while line = gets
    line.chomp!
    if line.match(/(\w+)-to-(\w+)\s+map:/)
        source , destination = line.match(/(\w+)-to-(\w+)\s+map:/).captures
        #puts "source: #{source} destination: #{destination}"
        $map_mapper_map[source] = destination
        current_source = source
        $maps[current_source] = []
    elsif line.match(/^(\d+) (\d+) (\d+)$/)
        x, y, z = line.match(/^(\d+) (\d+) (\d+)$/).captures
        #puts "x: #{x} y: #{y} z: #{z}"
        $maps[current_source].push([x.to_i, y.to_i, z.to_i])
    elsif line.match(/^$/)
        #puts "blank line"
    else
        puts "error: #{line}"
    end
end

#puts $map_mapper_map.to_s
#puts $maps.to_s

locations = []
$seeds.each do |seed|
   location =  walk_map("seed",seed)
   #puts "seed: #{seed} location: #{location}"
    locations.push(location)
end
puts locations.min