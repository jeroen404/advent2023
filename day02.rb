#!/usr/bin/ruby -w

$red_max= 12
$green_max = 13
$blue_max = 14

$color_map = { 'red' => 0, 'green' => 1, 'blue' => 2 }

$games = []

def parse_game_line(line)
    line.chomp!
    game_id = line.sub(/^Game\s(\d+):.*/, '\1')
    line.sub!(/Game\s\d+:/, '')
    game_array = []
    #puts '* id:' + game_id + ' *' + line
    line.split(';').each do |draw|
        #puts '** ' + draw
        draw_array = [0,0,0]
        draw.split(',').each do |color|
            color_parse = color.match(/(\d+) (\w+)$/).captures
            draw_array[$color_map[color_parse[1]]] = color_parse[0].to_i
        end
        #puts draw_array.to_s
        game_array.push(draw_array)
    end
    $games[game_id.to_i] = game_array
end

def get_possible_games
    possible_games = []
    for i in 1..$games.length-1 do
        possible = true
        $games[i].each do |draw|
            if draw[0] > $red_max || draw[1] > $green_max || draw[2] > $blue_max
                possible = false
            end
        end
        if possible
            possible_games.push(i)
        end
    end
    return possible_games
end


while line = gets
    parse_game_line(line)
end

#add up all possible games
sum = get_possible_games.inject(0) { |sum, x| sum + x }

puts sum