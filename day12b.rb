#!/usr/bin/ruby -w

$debug = false

class Line < Struct.new(:record,:seq)
    def solve 
        return solve_line(record,seq)
    end
end

$cache = {}

def add_cache(record,seq,solution)
    if not $cache.has_key?(record) then
        $cache[record] = {}
    end
    $cache[record][seq] = solution
end

def explode_line(line)
    new_record = []
    for i in 1..5 do
        new_record = new_record + line.record + ['?']
    end
    new_record.pop
    new_seq = []
    for i in 1..5 do
        new_seq = new_seq + line.seq 
    end
    return Line.new(new_record,new_seq)
end

def solve_line(record,seq)
    
    if record.length == 0 then
        if seq.length == 0 then
            return 1
        else
            return 0
        end
    end
    if seq.length == 0 then
        if record.detect { |x| x == '#' } then
            return 0
        else
            return 1
        end
    end
    if $cache.has_key?(record) then
        if $cache[record].has_key?(seq) then
            return $cache[record][seq]
        end
    end

    if record[0] == '.' then
        return solve_line(record[1..-1],seq)
    elsif record[0] == '?' then
        point_record = (['.'] + record[1..-1])
        point_solution = solve_line(point_record,seq)
        add_cache(point_record,seq,point_solution)
        hash_record = (['#'] + record[1..-1])
        hash_solution = solve_line((['#'] + record[1..-1]),seq)
        add_cache(hash_record,seq,hash_solution)
        return  point_solution + hash_solution
    elsif record[0] == '#' then
        if record.length >= seq[0] and (not record[0..(seq[0]-1)].include?('.')) then
            if record.length > seq[0]  then
                if record[seq[0]] == '#' then # +1 -1
                    return 0
                else
                    return solve_line(record[(seq[0]+1)..-1],seq[1..-1]) 
                end
            end
            return solve_line(record[seq[0]..-1],seq[1..-1])
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

