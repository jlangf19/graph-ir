//19 - Plot host_30 admin logins
match (n:HOST {hostname: "host_30"}) - [r:LOGIN] - (u:USER {security_group: "administrators"})
return n,r,u