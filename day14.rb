#!/usr/bin/ruby -w

$cache = {}

def loop_detect(plat,i)
    if $cache[plat] then
        return $cache[plat]
    end
    $cache[plat] = i
    return -1
end

#def tilt(direction,plat)
#    send("tilt_"+direction,$platform)
#end

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

def print_plat(plat)
    puts plat.map { |row| row.join("") }.join("\n")
end

$platform = STDIN.read.split("\n").map {|s| s.split("") }

cycles = 1000000000 
i=0
j=0
cycles.times do
    $platform = tilt_north($platform)
    $platform = tilt_west($platform)
    $platform = tilt_south($platform)
    $platform = tilt_east($platform)
    i += 1
    if (j = loop_detect($platform,i) )> 0 then
        puts "loop detected between #{j} and  #{i}"
        break
    end
end

more_cycles = (cycles - i)  % (i - j)
puts "more cycles: #{more_cycles}"
more_cycles.times do
    $platform = tilt_north($platform)
    $platform = tilt_west($platform)
    $platform = tilt_south($platform)
    $platform = tilt_east($platform)
end

score = $platform.map.with_index { |row,index| row.count("O") * ($platform.size - index) }.inject(:+)
puts "score: #{score}"