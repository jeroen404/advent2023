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
        rule_part_combos = []
        if part.send(param).max > value.to_i then
            new_part = Part.new(part.x,part.m,part.a,part.s)
            new_max = part.send(param).max
            new_min = [part.send(param).min,value.to_i + 1].max
            new_param = Param.new(new_min,new_max)
            new_part.send("#{param}=",new_param)
            rule_part_combos << RulePartCombo.new(Workflow.get(cond_flow_name).first_rule,new_part)
        end
        if part.send(param).min < value.to_i then
            new_part = Part.new(part.x,part.m,part.a,part.s)
            new_min = part.send(param).min
            new_max = [part.send(param).max,value.to_i].min
            new_param = Param.new(new_min,new_max)
            new_part.send("#{param}=",new_param)
            rule_part_combos << RulePartCombo.new(next_rule,new_part)
        end
        return rule_part_combos
    end
end

class RuleLT < Rule
    def execute(part)
        rule_part_combos = []
        if part.send(param).min < value.to_i then
            new_part = Part.new(part.x,part.m,part.a,part.s)
            new_min = part.send(param).min
            new_max = [part.send(param).max,value.to_i - 1].min
            new_param = Param.new(new_min,new_max)
            new_part.send("#{param}=",new_param)
            rule_part_combos << RulePartCombo.new(Workflow.get(cond_flow_name).first_rule,new_part)
        end
        if part.send(param).max > value.to_i then
            new_part = Part.new(part.x,part.m,part.a,part.s)
            new_max = part.send(param).max
            new_min = [part.send(param).min,value.to_i].max
            new_param = Param.new(new_min,new_max)
            new_part.send("#{param}=",new_param)
            rule_part_combos << RulePartCombo.new(next_rule,new_part)
        end
        return rule_part_combos
    end
end

class RuleJump < Rule
    def initialize(cond_flow_name)
        super(nil,nil,cond_flow_name,nil)
    end
    def execute(part)
        return [RulePartCombo.new(Workflow.get(cond_flow_name).first_rule,part)]
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
        return (x.max - x.min + 1) * (m.max - m.min + 1) * (a.max - a.min + 1) * (s.max - s.min + 1)
    end
end

class Param < Struct.new(:min,:max)
end

class RulePartCombo < Struct.new(:rule,:part)
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


part = Part.new(Param.new(1,4000),Param.new(1,4000),Param.new(1,4000),Param.new(1,4000))

accepted_parts = []

queue = [RulePartCombo.new(Workflow.get("in").first_rule,part)]

while not queue.empty? do
    rule_part_combo = queue.shift
    rule = rule_part_combo.rule
    part = rule_part_combo.part
    rule_part_combos = rule.execute(part)
    if rule_part_combos != nil then
        queue += rule_part_combos
    end
    if part.status == "accepted" then
        accepted_parts << part
    end
end


puts accepted_parts.map { |part| part.value }.inject(:+)