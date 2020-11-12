require 'active_support/all'
SAT = 1
UNSAT = 0

class CNF
  attr_accessor :formula
  attr_accessor :truth_assignment
  def initialize
    @formula = Array.new
    @truth_assignment = Hash.new
  end

  def unit_propagation
    while !self.exist_empty_clause? and l = self.find_unit_clause
      @truth_assignment["#{l.abs}".to_sym] = l > 0
      self.simplify(l)
    end
  end

  def simplify(l)
    @formula.delete_if do |cls|
      cls.include?(l)
    end
    @formula.map{|cls| if cls.include?(-1*l) then cls.delete(-1*l) end}
  end

  def find_unit_clause
    @formula.map{|cls| if cls.size == 1 then return cls.first end}
    return false
  end

  def exist_empty_clause?
    @formula.map{|cls| if cls.empty? then return true end}
    return false
  end

  def choose_variable
    @truth_assignment.map{|key,value| if value == nil then return key.to_s.to_i end}
    return false
  end

  def append l
    @formula.append [l] if l
    return self
  end

  def result
    str = ""
    @truth_assignment.map{|key,value| unless value then str<<"-" end; str<<key.to_s+" "}
    return str << "0"
  end
end

def parse(file_path,cnf)
  header = ""; clauses = [];
  File.open(file_path,"r") do |f|
    header = f.readline
    clauses = f.readlines
  end
  header.split[2].to_i.times do |i|
    cnf.truth_assignment["#{i+1}".to_sym] = nil
  end
  clauses.each do |e|
    clause = e.split.map{|i| i.to_i}
    clause.pop
    cnf.formula.append clause
  end
end

def DPLL(cnf)
  if cnf.formula.empty? then return SAT end
  cnf.unit_propagation
  if cnf.exist_empty_clause? then return UNSAT end
  x = cnf.choose_variable
  tmp_formula = cnf.formula.deep_dup
  tmp_truth = cnf.truth_assignment.deep_dup
  if DPLL(cnf.append x) == SAT
    return SAT
  else
    cnf.formula = tmp_formula
    cnf.truth_assignment = tmp_truth
    return DPLL(cnf.append -1*x)
  end
end

cnf = CNF.new
parse(ARGV[0],cnf)
case DPLL(cnf)
when SAT
  puts "SAT"
  puts cnf.result
when UNSAT
  puts "UNSAT"
end
