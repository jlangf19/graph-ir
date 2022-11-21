//5 - Load Files
load csv with headers from "file:///files.csv" as line
create (:FILE {name: line.Name, path: line.Path, type: line.extension, create_date: datetime(line.neo4jcreationtime), last_access_date: datetime(line.neo4jlastaccesstime), last_modify_date: datetime(line.neo4jlastwritetime), hash: line.Hash})