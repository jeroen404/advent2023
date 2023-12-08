#!/usr/bin/ruby -w

$hands = []

class Hand

    @@card_val = { 'A' => 14, 'K' => 13, 'Q' => 12, 'J' => 1, 'T' => 10,  }

    def initialize(hand,bid)
        @hand = hand
        @bid = bid
    end

    def hand
        @hand
    end

    def bid
        @bid
    end

    def same_card_values
        card_values = {}
        @hand.each_char do |c|
            card_values[c] = card_values.key?(c) ? card_values[c] + 1 : 1
        end
        return card_values
    end

    def score1
        card_values = same_card_values
        jokers = card_values.key?('J') ? card_values['J'] : 0
        card_values.delete('J')
        max_card_values = card_values.values.max || 0 # 5 jokers
        tally = card_values.values.tally
        score = 1

        if max_card_values + jokers == 5
            score = 7 # 5 of a kind
        elsif max_card_values + jokers == 4
            score = 6 # 4 of a kind
        elsif max_card_values + jokers == 3
            if (tally[2] == 2) or (tally[3] == 1 && tally[2] == 1)
                score = 5 # full house
            else
                score = 4 # 3 of a kind
            end
        elsif max_card_values + jokers == 2
            if tally[2] == 2
                score = 3 # 2 pair
            else
                score = 2 # 1 pair
            end
        end
        
        return score
    end

    def has_higher_score2_than?(other)
        i = 0
        hand.each_char do |c|
            my_val = c.to_i
            other_val = other.hand[i].to_i
            if @@card_val[c] then
                my_val = @@card_val[c]
            end
            if @@card_val[other.hand[i]] then
                other_val = @@card_val[other.hand[i]]
            end
            if my_val > other_val
                return true
            elsif my_val < other_val
                return false
            end
            i += 1
        end
        return false
    end

    def <(other)
        if self.score1 < other.score1 then
            return true
        elsif self.score1 > other.score1 then
            return false
        else
            return ! self.has_higher_score2_than?(other)
        end
    end

    def >(other)
        return other < self
    end

    def ==(other)
        return self.hand == other.hand
    end

    def <=>(other)
        if self < other then
            return -1
        elsif self > other then
            return 1
        else
            return 0
        end
    end

    def inspect
        return "(Hand: hand'" + @hand + "',bid:'" + @bid + "',score1:" + self.score1.to_s + ",card_values:" + self.same_card_values.to_s + ")"
    end

end

while line = gets do
    hand, bid = line.split(' ')
    $hands << Hand.new(hand,bid)
end

def debug 
    #puts $hands.sort.to_s

    puts $hands.select { |h| h.score1 != h.bid.to_i }.to_s
    #puts $hands.sort.map { |h| h.hand }.length
    #puts $hands.sort.map { |h| h.hand }.uniq.length
end

#debug

puts $hands.sort.map.with_index { |h,i| (i+1)*h.bid.to_i}.inject(:+)