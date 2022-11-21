//2 - Load Services
load csv with headers from "file:///services.csv" as line
create (:SERVICE {name: line.Name, PID: line.processid, path: line.pathname, start_mode: line.StartMode, file_path: line.filepath})