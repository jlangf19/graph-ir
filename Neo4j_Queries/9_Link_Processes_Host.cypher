//9 - Link Processes/Host
match (h:HOST {ip_address: "192.168.1.24"}), (p:PROCESS)
create ((h) - [:PRESENT] -> (p))