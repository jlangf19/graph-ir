//8 - Link Services/Host
match (h:HOST {ip_address: "192.168.1.24"}), (s:SERVICE)
create ((h) - [:PRESENT] -> (s))