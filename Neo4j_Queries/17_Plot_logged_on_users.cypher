//17 - Plot logged on users 
match (h:HOST) - [r] - (d) <- [l:LOGIN] - (u:USER)
where not (h.domain = "area1") and not (h.domain = "area2")
return h,r,d,l,u