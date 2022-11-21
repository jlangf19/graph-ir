//7 - Load Hosts Links
load csv with headers from "file:///host_links.csv" as line
match (s:HOST), (d:HOST) where s.ip_address = line.src and d.ip_address = line.dst
create ((s) - [:CONNECTION {port: line.port}] -> (d))