//1 - Load Users
load csv with headers from "file:///users.csv" as line
create (:USER {name: line.name, first: line.first_name, last: line.last_name, domain: line.domain, security_group: line.security_groups, create_date: datetime(line.create_date)})