require './cnf.rb'

SAT = 1
UNSAT = 0

def DPLL(cnf)
  if cnf.empty? then return SAT end
  cnf.unit_propagation
  if cnf.exist_empty_clause? then return UNSAT end
  x = cnf.choose_variable
  tmp = cnf.deep_dup
  if DPLL(cnf.append x) == SAT
    return SAT
  else
    cnf.restore(tmp)
    return DPLL(cnf.append -1*x)
  end
end

cnf = CNF.new
cnf.parse(ARGV[0])
case DPLL(cnf)
when SAT
  puts "SAT"
  puts cnf.result
when UNSAT
  puts "UNSAT"
end
