#!/usr/bin/ruby -w

$debug = false
class ModDict
    @@mods = {}
    def self.get(label)
        @@mods[label]
    end
    def self.add(mod)
        @@mods[mod.label] = mod
    end
    def self.set_inputs
        blackholes = []
        @@mods.each do |label,mod|
            mod.output.each do |output|
                if @@mods.has_key? output then
                    ModDict.get(output).input << label
                else
                    blackholes << output
                end
            end
        end
        blackholes.each do |blackhole|
            ModDict.add(ModBlackhole.new(blackhole,[],[]))
        end
    end
    def self.print
        @@mods.each do |label,mod|
            puts "#{label} : #{mod.input} -> #{mod.output}"
        end
    end
end

class Mod < Struct.new(:label,:input,:output)
    def fire(pulse)
        raise "not implemented"
    end
end

class ModFlipFlop < Mod
    def initialize(label,input,output)
        @state = false
        super(label,input,output)
    end
    def fire(pulse)
        if not pulse.high? then
            @state = !@state
            if @state then
                return output.map { |c| HighPulse.new(label,c) }
            else
                return output.map { |c| LowPulse.new(label,c) }
            end
        else
            return []
        end
    end
end

class ModConjunction < Mod
    def initialize(label,input,output)
        super(label,input,output)
        @state = {}
    end
    def fire(pulse)
        @state[pulse.src] = pulse.high?
        input.each do |label|
            if not @state.has_key? label then
                @state[label] = false
            end
        end
        if @state.values.all? { |v| v } then
            return output.map { |c| LowPulse.new(label,c) }
        else
            return output.map { |c| HighPulse.new(label,c) }
        end
    end
end

class ModBroadcast < Mod
    def fire(pulse)
        return output.map { |c| pulse.high? ? HighPulse.new(label,c) : LowPulse.new(label,c) }
    end
end

class ModBlackhole < Mod
    def fire(pulse)
        @last_pulse = pulse
        return []
    end
    def last_pulse
        @last_pulse
    end
end

class Pulse < Struct.new(:src,:dest)
end

class HighPulse < Pulse
    def high?
        true
    end
    def type
        "high"
    end
end
class LowPulse < Pulse
    def high?
        false
    end
    def type
        "low"
    end
end

STDIN.read.split(/\n/).each do |line|
    type,label,outputs = line.match(/(\S)(\w+) -> (.*)/).captures
    output = outputs.split(', ')
    if type == "b" then
        ModDict.add(ModBroadcast.new("b" + label,[],output))
    elsif type == '&' then
        ModDict.add(ModConjunction.new(label,[],output))
    elsif type == '%' then
        ModDict.add(ModFlipFlop.new(label,[],output))
    else
        raise "unknown mod type #{label}"
    end
end
#ModDict.print
ModDict.set_inputs
#ModDict.print

def button_push
    pulse_queue = [LowPulse.new("button","broadcaster")]
    low_pulses = 1
    high_pulses = 0
    while pulse_queue.length > 0 do
        pulse = pulse_queue.shift
        puts "pulse: #{pulse.src} -#{pulse.type}-> #{pulse.dest}" if $debug
        if ModDict.get(pulse.dest) then
            new_pulses = ModDict.get(pulse.dest).fire(pulse)
            pulse_queue += new_pulses
            high_pulses += new_pulses.select { |p| p.high? }.length
            low_pulses += new_pulses.select { |p| not p.high? }.length
        else
            raise "unknown mod #{pulse.dest}"
        end
    end
    return low_pulses,high_pulses
end

acc_low_pulses,acc_high_pulses = [0,0]
1000000.times do |i|
    low_pulses,high_pulses = button_push
    acc_low_pulses += low_pulses
    acc_high_pulses += high_pulses
    i += 1
    if ModDict.get("rx") then
        rx_pulse = ModDict.get("rx").last_pulse
        if rx_pulse then
            if not rx_pulse.high? then
                puts "part 2: rx pulse low after #{i} iterations"
                break
            end
        end
    end
end
#puts "part 1:" + (acc_low_pulses * acc_high_pulses).to_s