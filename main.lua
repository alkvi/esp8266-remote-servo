
-- init GPIO
print("Initializing GPIO")
-- we want servo control on D1=GPIO5, LUA code uses IO index, this is IO index 1
controlPin = 1
-- set mode to OUT direction
gpio.mode(controlPin, gpio.OUTPUT)
-- servo variables
servoFrequency = 50 -- in Hz
stepResolution = 1000 -- total cycle resolution
restingPointDuty = stepResolution*0.075 -- resting point at 7.5% duty cycle
cwDuty = stepResolution*0.1 -- clockwise at 10% duty cycle
ccwDuty = stepResolution*0.05 -- counter-clockwise at 5% duty cycle
-- setup controlPin to 50 Hz, pulse period of 1000 steps, initial duty to 75 steps (i.e. 7.5% at resting point, 1.5ms)
pwm2.setup_pin_hz(controlPin,50,1000,75)
-- starts pwm, internal led will blink with 0.5sec interval
print("Starting PWM")
pwm2.start()

homePage = [[
    <h1> ESP8266 Web Server</h1>
    <p>
    GPIO5
    <a href=\"?pin=CW\"><button>Clockwise</button></a>&nbsp;
    <a href=\"?pin=CCW\"><button>Counter-clockwise</button></a>&nbsp;
    <a href=\"?pin=OFF\"><button>OFF</button></a>&nbsp;
    </p>
    ]]

-- create server
print("Creating server")
srv = net.createServer(net.TCP)
print("Server created on ip:")
print(wifi.sta.getip())
srv:listen(80,function(conn)
    conn:on("receive", function(client,request)
        print("Got a request")
        local buf = "";
        local _, _, method, path, vars = string.find(request, "([A-Z]+) (.+)?(.+) HTTP");
        if(method == nil)then
            _, _, method, path = string.find(request, "([A-Z]+) (.+) HTTP");
        end
        local _GET = {}
        if (vars ~= nil)then
            for k, v in string.gmatch(vars, "(%w+)=(%w+)&*") do
                _GET[k] = v
            end
        end
        buf = homePage
        local _on,_off = "",""
        if(_GET.pin == "CW")then
            print("Got CW, setting duty to " .. tostring(cwDuty))
            pwm2.set_duty(controlPin, cwDuty)
        elseif(_GET.pin == "CCW")then
            print("Got CCW, setting duty to " .. tostring(ccwDuty))
            pwm2.set_duty(controlPin, ccwDuty)
        elseif(_GET.pin == "OFF")then
            print("Setting servo to resting point at " .. tostring(restingPointDuty))
            pwm2.set_duty(controlPin, restingPointDuty)
        end
        client:send(buf);
        collectgarbage();
    end)
    conn:on("sent", function(client) client:close() end)
end)


--srv:listen(80, function(conn)
--    conn:on("receive", function(sck, payload)
--        print(payload)
--        sck:send("HTTP/1.0 200 OK\r\nContent-Type: text/html\r\n\r\n<h1> Hello, NodeMCU.</h1>")
--    end)
--    conn:on("sent", function(sck) sck:close() end)
--end)