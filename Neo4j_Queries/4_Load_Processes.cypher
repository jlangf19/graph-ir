//4 - Load Processes
load csv with headers from "file:///processes.csv" as line
create (:PROCESS {name: line.name, PID: line.processid, parent_PID: line.parentprocessid, execution_path: line.ExecutablePath, creation_time: datetime(line.neo4jcreationtime)})