#!/usr/bin/ruby -w

$time = gets.chomp.sub(/Time:\s+/,'').gsub(/\s+/,'').to_i 
$distance = gets.chomp.sub(/Distance:\s+/,'').gsub(/\s+/,'').to_i 

 
def race_distance(chargetime)
    racetime = $time - chargetime
    distance = racetime * chargetime
    return distance
end

def race_distances()
    distances = []
    for i in 0..$time do
        distances.push(race_distance(i))
    end
    return distances
end

def race_distances_winners()
    return race_distances().select { |dist| dist > $distance }
end


puts race_distances_winners().length()
