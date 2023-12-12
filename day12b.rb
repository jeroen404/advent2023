#!/usr/bin/ruby -w

$debug = false

class Line < Struct.new(:record,:seq)

    @@cache = {}

    def explode
        new_record = []
        5.times do
            new_record += record + ['?']
        end
        new_record.pop
        new_seq = []
        5.times do
            new_seq += seq 
        end
        return Line.new(new_record,new_seq)
    end

    def cache_solve_line()
        # a||=b means assign b to a only if a is unassigned or evaluates to false
        return @@cache[[record,seq]] ||=  solve_line() 
    end

    def solve_line()
        
        if record.empty? then
            return seq.empty? ? 1 : 0
        end

        if seq.empty? then
            return record.include?('#') ? 0 : 1
        end

        if record.length < seq.inject(:+) + seq.size - 1 then
            return 0
        end

        if record[0] == '.' then
            return Line.new(record[1..-1],seq).cache_solve_line()
        elsif record[0] == '?' then
            point_record = (['.'] + record[1..-1])
            point_solution = Line.new(point_record,seq).solve_line()
            hash_record = (['#'] + record[1..-1])
            hash_solution = Line.new(hash_record,seq).solve_line()
            return  point_solution + hash_solution
        elsif record[0] == '#' then
            if not record[0..(seq[0]-1)].include?('.') then
                if record.length > seq[0]  then
                    if record[seq[0]] == '#' then # +1 -1
                        return 0
                    else
                        return Line.new(record[(seq[0]+1)..-1],seq[1..-1]).cache_solve_line() 
                    end
                end
                return Line.new(record[seq[0]..-1],seq[1..-1]).cache_solve_line()
            else
                return 0
            end
        end
    end
end


lines = []
while line = gets
    schema_line,broken_sequence = line.chomp.split(' ')
    lines.push((Line.new(schema_line.each_char.to_a, broken_sequence.split(',').map { |x| x.to_i })).explode)
end

puts lines.map { |line| line.solve_line }.inject(:+)
