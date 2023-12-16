#!/usr/bin/ruby -w

$times = []
$distances = []

$times = gets.chomp.sub(/Time:\s+/,'').split(' ').map { |x| x.to_i }
$distances = gets.chomp.sub(/Distance:\s+/,'').split(' ').map { |x| x.to_i }

 
def race_distance(racenb,chargetime)
    racetime = $times[racenb] - chargetime
    distance = racetime * chargetime
    return distance
end

def race_distances(racenb)
    distances = []
    for i in 0..$times[racenb] do
        distances.push(race_distance(racenb,i))
    end
    return distances
end

def race_distances_winners(racenb)
    return race_distances(racenb).select { |dist| dist > $distances[racenb] }
end

race_distances_winners_size = []
for racenb in 0..$times.length-1 do
    race_distances_winners_size.push(race_distances_winners(racenb).length)
end

puts race_distances_winners_size.inject(:*)