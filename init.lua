-- load credentials, 'HOME_SSID' and 'HOME_PWD' declared and initialize in there
dofile("credentials.lua")

print('init.lua ver 1.2')
wifi.setmode(wifi.STATION)
print('set mode=STATION (mode='..wifi.getmode()..')')
print('MAC: ',wifi.sta.getmac())
print('chip: ',node.chipid())
print('heap: ',node.heap())
-- wifi config start
wifi.sta.config {ssid=HOME_SSID, pwd=HOME_PWD}
-- wifi config end
