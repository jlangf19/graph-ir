//10 - Link Parent Processes
match (p:PROCESS), (pp:PROCESS) where pp.PID = p.parent_PID
create ((pp) - [:CREATES] -> (p))