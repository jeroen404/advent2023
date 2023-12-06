#!/usr/bin/ruby -w

$seeds = []

$map_mapper_map = {}

$maps = {}

$seeds = gets.sub(/seeds: /,'').split(' ').map { |x| x.to_i }
#puts "seeds: " + $seeds.to_s

def min(a,b)
    if a < b then
        return a
    else
        return b
    end
end

def max(a,b)
    if a > b then
        return a
    else
        return b
    end
end

def walk_map(source,source_number_start,source_number_range)
    #puts "walk_map source #{source} source_number_start #{source_number_start} source_number_range #{source_number_range}"
    ranges = []
    $maps[source].each do |mapping|
        if source_number_start + source_number_range - 1 < mapping[1] then
            next
        end
        if source_number_start > mapping[1] + mapping[2] then
            next
        end
        source_range_start = max(source_number_start, mapping[1])
        source_range_stop = min(source_number_start + source_number_range - 1, mapping[1] + mapping[2] - 1)

        destination_range_start = mapping[0] + (source_range_start - mapping[1])
        #destination_range_stop = min(mapping[0] + source_number_start + source_number_range  - 1, mapping[0] + mapping[2] - 1)
        destination_range_stop = min(mapping[0] + source_range_stop - mapping[1]  , mapping[0] + mapping[2] - 1)
        #puts "mapping #{mapping.to_s}"
        #puts "mapping source #{source} source_range_start #{source_range_start} source_range_stop #{source_range_stop} destination_range_start #{destination_range_start} destination_range_stop #{destination_range_stop}"
        ranges.push([source_range_start, source_range_stop,destination_range_start, destination_range_stop])
    end
    #sort ranges on source_range_start
    ranges.sort! { |a,b| a[0] <=> b[0] }

    #puts "og ranges: #{ranges.to_s}"
    if ranges.length == 0 then
        ranges.push([source_number_start, source_number_start + source_number_range - 1, source_number_start, source_number_start + source_number_range - 1])
    else
        nb_og_ranges = ranges.length
        i = 0
        # de gaatjes opvullen
        while i < nb_og_ranges - 1 do
            range_start = ranges[i][1] + 1
            range_stop = ranges[i+1][0] - 1
            if range_start <= range_stop then
                #puts "debug fill range_start #{range_start} range_stop #{range_stop}"
                ranges.push([range_start, range_stop, range_start, range_stop])
            end
            i += 1
        end
        # eerste range en laatste range opvullen
        if ranges[0][0] > source_number_start then
            ranges.push([source_number_start, ranges[0][0] - 1, source_number_start, ranges[0][0] - 1])
            #puts "debug fill first #{ranges.last.to_s}"
        end
        if ranges[nb_og_ranges-1][1] < source_number_start + source_number_range - 1 then
            ranges.push([ranges[nb_og_ranges-1][1] + 1, source_number_start + source_number_range - 1, ranges[nb_og_ranges-1][1] + 1, source_number_start + source_number_range - 1])
            #puts "debug fill end #{ranges.last.to_s}"
        end
    end

    #puts "source #{source} start #{source_number_start} source stop #{source_number_start + source_number_range - 1}   ranges: #{ranges.to_s}" 

    ranges_range = ranges.inject(0) { |sum, range| sum + range[3] - range[2] + 1 }
    if ranges_range != source_number_range then
        #puts " !!! ranges_range: #{ranges_range} source_number_range: #{source_number_range}"
    end

    min = -1
    if $map_mapper_map[source] == "location"
        #puts "leaf #{ranges.to_s}"
        min = ranges[0][2]
        ranges.each do |range|
            if range[3] < min then
                min = range[2]
            end
        end
    else
        ranges.each do |range|
            range_min = walk_map($map_mapper_map[source],range[2],range[3]-range[2]+1)
            if min == -1 then
                min = range_min
            elsif range_min < min then
                min = range_min
            end
        end
    end

    return min
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

min = -1
$i = 0
while $i < $seeds.length do
    if min == -1 then
        min = walk_map("seed",$seeds[$i],$seeds[$i+1])
    else
        min = min(walk_map("seed",$seeds[$i],$seeds[$i+1]),min)
    end
   $i += 2
end

puts min