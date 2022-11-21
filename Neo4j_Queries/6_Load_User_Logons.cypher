//6 - Load User Logons
load csv with headers from "file:///user_links.csv" as line
match (u:USER), (h:HOST) where u.name = line.user and h.ip_address = line.dst
create ((u) - [:LOGIN] -> (h))