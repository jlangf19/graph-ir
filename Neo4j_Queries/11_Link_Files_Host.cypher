//11 - Link Files/Host
match (h:HOST {ip_address: "192.168.1.24"}), (f:FILE)
create ((h) - [:PRESENT] -> (f))