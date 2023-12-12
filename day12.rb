#!/usr/bin/ruby -w

$debug = false

class Line < Struct.new(:record,:seq)
    def solve 
        return solve_line(record,seq,record)
    end
end



def solve_line(record,seq,debug_string)
    debug_s = debug_string.dup
    #puts 'Solving: ' + record.to_s + ' x ' + seq.to_s + ' x '  + debug_s.join if $debug
    #puts 'Solving: Rec: ' + record.join + ' l: ' + record.length.to_s + ' Seq:' + seq.join(',') if $debug
    
    if record.length == 0 then
        if seq.length == 0 then
            puts "A solution!: " + debug_s.join if $debug
            return 1
        else
            return 0
        end
    end
    if seq.length == 0 then
        if record.detect { |x| x == '#' } then
            return 0
        else
            puts "A solution_: " + debug_s.join if $debug
            return 1
        end
    end
  
    if record[0] == '.' then
        return solve_line(record[1..-1],seq,debug_s)
    elsif record[0] == '?' then
        i = debug_s.index('?')
        debug_s[i] = '.'
        point_solution = solve_line((['.'] + record[1..-1]),seq,debug_s)
        debug_s[i] = '#'
        hash_solution = solve_line((['#'] + record[1..-1]),seq,debug_s)
        return  point_solution + hash_solution
    elsif record[0] == '#' then
        if record.length >= seq[0] and (not record[0..(seq[0]-1)].include?('.')) then
            if record.length > seq[0]  then
                if record[seq[0]] == '#' then # +1 -1
                    return 0
                else
                    return solve_line(record[(seq[0]+1)..-1],seq[1..-1],debug_s) 
                end
            end
            return solve_line(record[seq[0]..-1],seq[1..-1],debug_s)
        else
            return 0
        end
    end


end

lines = []

while line = gets
    schema_line,broken_sequence = line.chomp.split(' ')
    lines.push(Line.new(schema_line.each_char.to_a, broken_sequence.split(',').map { |x| x.to_i }))
end

#lines.each { |line| 
#    puts 'Rec: ' + line.record.join + ' Seq:' + line.seq.join(',') + ' Solve:' + line.solve.to_s
#}

puts lines.map { |line| line.solve }.inject(:+)

