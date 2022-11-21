//18 - Plot additional host connections
match (n:HOST {hostname: "host_10"}) - [r:CONNECTION] -> (a)
return a,r,n