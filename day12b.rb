#!/usr/bin/ruby -w

$debug = false

class Line < Struct.new(:record,:seq)
    def solve 
        return solve_line(record,seq)
    end
end

$cache = {}

def explode_line(line)
    new_record = []
    5.times do
        new_record += line.record + ['?']
    end
    new_record.pop
    new_seq = []
    5.times do
        new_seq += line.seq 
    end
    return Line.new(new_record,new_seq)
end

def cache_solve_line(record,seq)
    # a||=b means assign b to a only if a is unassigned or evaluates to false
    return $cache[[record,seq]] ||=  solve_line(record,seq) 
end

def solve_line(record,seq)
    
    if record.empty? then
        return seq.length == 0 ? 1 : 0
    end

    if seq.empty? then
        return record.detect { |x| x == '#' } ? 0 : 1
    end

    if record[0] == '.' then
        return cache_solve_line(record[1..-1],seq)
    elsif record[0] == '?' then
        point_record = (['.'] + record[1..-1])
        point_solution = solve_line(point_record,seq)
        hash_record = (['#'] + record[1..-1])
        hash_solution = solve_line(hash_record,seq)
        return  point_solution + hash_solution
    elsif record[0] == '#' then
        if record.length >= seq[0] and (not record[0..(seq[0]-1)].include?('.')) then
            if record.length > seq[0]  then
                if record[seq[0]] == '#' then # +1 -1
                    return 0
                else
                    return cache_solve_line(record[(seq[0]+1)..-1],seq[1..-1]) 
                end
            end
            return cache_solve_line(record[seq[0]..-1],seq[1..-1])
        else
            return 0
        end
    end
end

lines = []
while line = gets
    schema_line,broken_sequence = line.chomp.split(' ')
    lines.push(explode_line(Line.new(schema_line.each_char.to_a, broken_sequence.split(',').map { |x| x.to_i })))
end

puts lines.map { |line| line.solve }.inject(:+)
