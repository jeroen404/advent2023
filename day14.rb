#!/usr/bin/ruby -w

$cache = {}

def loop_detect(direction,plat)
    if $cache[[direction,plat]] then
        return true
    end
    $cache[[direction,plat]] = 1
    return false
end

def tilt(direction,plat)
    send("tilt_"+direction,$platform)
end

def tilt_west(plat)
    plat.each do |row|
        for i in 1..row.length-1 do
            if row[i] == "O" then
                for j in i.downto(1) do
                    if row[j-1] == "." then
                        row[j-1] = "O"
                        row[j] = "."
                    else 
                        break
                    end
                end
            end
        end
    end
    return plat
end

def tilt_north(plat)
    plat_new = plat.transpose
    return tilt_west(plat_new).transpose
end

def tilt_east(plat)
    plat.map(&:reverse!)
    plat = tilt_west(plat)
    plat.map(&:reverse!)
    return plat
end

def tilt_south(plat)
    plat_new = plat.transpose
    return tilt_east(plat_new).transpose
end


$platform = STDIN.read.split("\n").map {|s| s.split("") }

#puts $platform.map { |row| row.join("") }.join("\n")
#puts "-------------------" 
#puts (tilt_south($platform)).map { |row| row.join("") }.join("\n")
#score = tilt_south($platform).map.with_index { |row,index| row.count("O") * ($platform.size - index) }.inject(:+)

cycles = 1000000000 * 4
i=0
['north','west','south','east'].cycle do |tilt|
    #$platform = send(tilt,$platform)
    $platform = tilt(tilt,$platform)
    i += 1
    if loop_detect(tilt,$platform) then
        puts "loop detected at #{i}"
        break
    end
    if i > cycles then
        break
    end
end

more_cycles = (cycles % i) * 4
puts "more cycles: #{more_cycles}"
i=1
['north','west','south','east'].cycle do |tilt|
    $platform = tilt(tilt,$platform)
    i += 1
    if i > more_cycles then
        break
    end
end

score = $platform.map.with_index { |row,index| row.count("O") * ($platform.size - index) }.inject(:+)
puts "score: #{score}"