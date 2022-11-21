//15 - All connections between hosts
match (n:HOST) - [r:CONNECTION] -> (a)
return a,r,n