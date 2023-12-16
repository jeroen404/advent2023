#!/usr/bin/ruby -w

$winners = []
$my_numbers = []
$card_cardinity = []

def parse_card(line)
    line.chomp!
    #card_id = line.sub(/^Card\s(\d+):.*/, '\1')
    line.sub!(/Card\s+\d+:/, '')
    winners = line.sub(/\|.*$/, '').split(' ').map { |x| x.to_i }
    my_numbers = line.sub(/^.*\|/, '').split(' ').map { |x| x.to_i }
    #puts winners.to_s + ' ' + my_numbers.to_s
    $winners.push(winners)
    $my_numbers.push(my_numbers)
    $card_cardinity.push(1)
end

def process_card(card_index)
    score = $my_numbers[card_index].inject(0) { |score, number| score + ($winners[card_index].include?(number) ? 1 : 0) }
        for i in (card_index+1)..(card_index + score) do
            #puts "card_index: #{card_index} i: #{i} score: #{score}"
            $card_cardinity[i] += $card_cardinity[card_index]
        end
    #puts 'card numbers ' + $card_cardinity.to_s
end


while line = gets
    parse_card(line)
end

for i in 0..$winners.length-1 do
    process_card(i)
end

#puts $card_cardinity
puts $card_cardinity.inject(:+)