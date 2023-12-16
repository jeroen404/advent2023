#!/usr/bin/ruby -w

class Lens < Struct.new(:label,:focal,:next)
    def initialize(label,focal)
        super(label,focal,nil)
    end
end

class Box
    #linked list of lenses
    def initialize
        @head = nil
    end

    def remove(label)
        if @head == nil then
            return
        end
        if @head.label == label then
            @head = @head.next
            return
        end
        current = @head
        while current.next != nil do
            if current.next.label == label then
                current.next = current.next.next
                return
            end
            current = current.next
        end
    end

    def replace_or_append(label,focal)
        if @head == nil then
            @head = Lens.new(label,focal)
            return
        end
        current = @head
        while current.next != nil do
            if current.label == label then
                current.focal = focal
                return
            end
            current = current.next
        end
        if current.label == label then
            current.focal = focal
            return
        end
        current.next = Lens.new(label,focal)
    end

    def power
        if @head == nil then
            return 0
        end
        current = @head
        power = 0
        lens_number = 0
        while current != nil do
            power += (current.focal * (lens_number+1))
            current = current.next
            lens_number += 1
        end
        return power
    end
end

class Instruction < Struct.new(:label,:operation,:focal)
    def self.parse(string)
        label,operation,focal = string.match(/([a-z]+)(\=|\-)([0-9]?)/).captures
        if operation == '='
            if not focal then
                raise "focal is not set for equals instruction"
            end
            focal_i = focal.to_i
            EqualsInstruction.new(label,operation,focal_i)
        else
            RemoveInstruction.new(label,operation,nil)
        end
    end

    def execute(machine)
        execute_on_box(machine[book_hash(label)])
    end

    def execute_on_box(box)
        raise "not implemented"
    end
end

class EqualsInstruction < Instruction
    def execute_on_box(box)
        box.replace_or_append(label,focal)
    end
end

class RemoveInstruction < Instruction
    def execute_on_box(box)
        box.remove(label)
    end
end

def book_hash(string)
    h = 0
    string.each_char do |c|
        h += c.ord
        h *= 17
        h %= 256
    end
    return h
end

#puts book_hash('HASH')
instructions = STDIN.read.gsub(/\n/,'').split(',').map { |s| Instruction.parse(s) }
# part 1:
#checksums = instructions.map { |s| book_hash(s) }.inject(:+)
#puts checksums

machine = []
256.times do 
    machine.push(Box.new)
end

instructions.each do |instruction|
    instruction.execute(machine)
end

power = machine.map.with_index { |box,index| box.power * (index+1) }.inject(:+)
puts power