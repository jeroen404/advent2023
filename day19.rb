#!/usr/bin/ruby -w

class Workflow < Struct.new(:name, :first_rule)
    @@workflows = {}
    def self.get(name)
        @@workflows[name]
    end
    def self.add(workflow)
        @@workflows[workflow.name] = workflow
    end
end

class Rule < Struct.new(:param, :value, :cond_flow_name, :next_rule)
    def execute(part)
        raise "not implemented"
    end
end

class RuleGT < Rule
    def execute(part)
        if part.send(param) > value.to_i then
            return Workflow.get(cond_flow_name).first_rule
        else
            return next_rule
        end
    end
end

class RuleLT < Rule
    def execute(part)
        if part.send(param).to_i < value.to_i then
            return Workflow.get(cond_flow_name).first_rule
        else
            return next_rule
        end
    end
end

class RuleJump < Rule
    def initialize(cond_flow_name)
        super(nil,nil,cond_flow_name,nil)
    end
    def execute(part)
        return Workflow.get(cond_flow_name).first_rule
    end
end

class RuleAccept < Rule

    def initialize()
        super(nil,nil,nil,nil)
    end
    def execute(part)
        part.status = "accepted"
        return nil
    end
end

class RuleReject < Rule
    def initialize()
        super(nil,nil,nil,nil)
    end
    def execute(part)
        part.status = "rejected"
        return nil
    end
end


class Part < Struct.new(:x,:m,:a,:s,:status)
    def initialize(x,m,a,s)
        super(x,m,a,s,nil)
    end

    def value
        return x + m + a + s
    end
end

accept_rule = RuleAccept.new()
reject_rule = RuleReject.new()
Workflow.add(Workflow.new("A",accept_rule))
Workflow.add(Workflow.new("R",reject_rule))

workflow_lines,part_lines = STDIN.read.split(/\n\n/)

workflow_lines.each_line do |line|
    name,rulesdef = line.match(/(\w+)\{(.*)\}/).captures
    prev_rule = nil
    rulesdef.split(',').reverse.each do |ruledef|
        if ruledef.include? ">" then
            param,value,cond_flow_name = ruledef.match(/(\w+)>(\d+)\:(\w+)/).captures
            rule = RuleGT.new(param,value,cond_flow_name,prev_rule)
        elsif ruledef.include? "<" then
            param,value,cond_flow_name = ruledef.match(/(\w+)<(\d+)\:(\w+)/).captures
            rule = RuleLT.new(param,value,cond_flow_name,prev_rule)
        else
            cond_flow_name = ruledef
            rule = RuleJump.new(cond_flow_name)
        end
        prev_rule = rule
    end
    workflow = Workflow.new(name,prev_rule)
    Workflow.add(workflow)
end

parts = part_lines.each_line.map do |line|
    x,m,a,s = line.match(/x=(\d+),m=(\d+),a=(\d+),s=(\d+)/).captures
    Part.new(x.to_i,m.to_i,a.to_i,s.to_i)
end

accepted_parts = []

parts.each do |part|
    puts "part: x #{part.x} m  #{part.m} a #{part.a} s #{part.s}"
    rule = Workflow.get("in").first_rule
    while rule != nil do
        puts "rule: #{rule.param} #{rule.value} #{rule.cond_flow_name} #{rule.next_rule}"
        rule = rule.execute(part)
    end
    if part.status == "accepted" then
        accepted_parts << part
    end
end

puts accepted_parts.map { |part| part.value }.inject(:+)