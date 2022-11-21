//16 - Plot Evil Connections
match (h:HOST) - [r] - (d)
where not (h.domain = "area1") and not (h.domain = "area2")
return h,r,d