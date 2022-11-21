//12 - Link Files/Services
match (f:FILE), (s:SERVICE) where f.path = s.file_path
create ((s) - [:LAUNCH {command: s.path}] -> (f))