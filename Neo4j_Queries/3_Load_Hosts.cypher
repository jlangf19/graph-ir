//3 - Load Hosts
load csv with headers from "file:///hosts.csv" as line
create (:HOST {hostname: line.hostname, ip_address: line.ip_address, domain: line.domain, OS: line.operating_system})