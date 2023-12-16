#!/usr/bin/ruby -w


$color_map = { 'red' => 0, 'green' => 1, 'blue' => 2 }

$games = {}

def parse_game_line(line)
    line.chomp!
    game_id = line.sub(/^Game\s(\d+):.*/, '\1')
    line.sub!(/Game\s\d+:/, '')
    game_array = []
    line.split(';').each do |draw|
        draw_array = [0,0,0]
        draw.split(',').each do |color|
            color_parse = color.match(/(\d+) (\w+)$/).captures
            draw_array[$color_map[color_parse[1]]] = color_parse[0].to_i
        end
        game_array.push(draw_array)
    end
    $games[game_id.to_i] = game_array
end

def get_minimum_game(game)
    minimum_game = [0,0,0]
    game.each do |draw|
        minimum_game = [draw[0] > minimum_game[0] ? draw[0] : minimum_game[0], 
                        draw[1] > minimum_game[1] ? draw[1] : minimum_game[1], 
                        draw[2] > minimum_game[2] ? draw[2] : minimum_game[2]]
    end
    return minimum_game
end


while line = gets
    parse_game_line(line)
end

sum = 0
$games.each do |game_id,game|
    sum += get_minimum_game(game).inject(:*)
end

puts sum