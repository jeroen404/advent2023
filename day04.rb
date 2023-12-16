#!/usr/bin/ruby -w

def parse_card(line)
    line.chomp!
    #card_id = line.sub(/^Card\s(\d+):.*/, '\1')
    line.sub!(/Card\s\d+:/, '')
    winners = line.sub(/\|.*$/, '').split(' ')
    my_numbers = line.sub(/^.*\|/, '').split(' ')
    #puts card_id + ' ' + winners.to_s + ' ' + my_numbers.to_s
    return card_score(winners, my_numbers)
end

def card_score(winners, my_numbers)
    score = 0
    winners.each do |winner|
        if my_numbers.include?(winner)
            score = score == 0 ? 1 : score * 2
        end
    end
    return score
end

sum = 0
while line = gets
    sum += parse_card(line)
end
puts sum