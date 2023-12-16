#!/usr/bin/ruby -w

$oasis = []

def predict_previous(sequence)
    higher_level_sequence = sequence.each_cons(2).map { |a,b| b - a }
    if higher_level_sequence.all? { |x| x == 0 } then
        return sequence.first
    else
        return sequence.first - predict_previous(higher_level_sequence) 
    end
end

while line = gets
    $oasis.push(line.chomp.split(' ').map { |x| x.to_i })
end

puts $oasis.map { |sequence| predict_previous(sequence) }.inject(:+)

