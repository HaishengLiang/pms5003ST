-- OLED Display demo
-- Variables 
sda = 1 -- SDA Pin
scl = 2 -- SCL Pin
i   = 0

function init_OLED(sda,scl) --Set up the u8glib lib
     sla = 0x3C
     i2c.setup(0, sda, scl, i2c.SLOW)
     
     disp = u8g.ssd1306_128x64_i2c(sla)
     disp:setFont(u8g.font_6x10)
     disp:setFontRefHeightExtendedText()
     disp:setDefaultForegroundColor()
     disp:setFontPosTop()
end

function print_OLED()
   disp:firstPage()
   repeat
     time = tmr.now
     str1=string.format("PM2.5 Sensor[%d]", i)
     disp:drawStr(0, 0, str1)
     
     str2=string.format("T : %.1fC  H : %.1f%%", t, h)
     disp:drawStr(0, 15, str2)
     
     str3=string.format("PM2.5 : %d", pm25)
     disp:drawStr(0, 30, str3)

     str4=string.format("THOC  : %.3f", hcho)
     disp:drawStr(0, 45, str4)

   until disp:nextPage() == false
   i = i+1   
end

function parse(data)
    local bs = {}
    for i = 1, #data do
        bs[i] = string.byte(data, i)
    end
    
    if (bs[1] ~= 0x42) or (bs[2] ~= 0x4d) then
        return nil
    end 

    local d = {}
    
    d['pm1_0-CF1-ST'] = bs[5]  * 256 + bs[6]
    d['pm2_5-CF1-ST'] = bs[7]  * 256 + bs[8]
    d['pm10-CF1-ST']  = bs[9]  * 256 + bs[10]
    d['pm1_0-AT']     = bs[11] * 256 + bs[12]
    d['pm2_5-AT']     = bs[13] * 256 + bs[14]
    d['pm10-AT']      = bs[15] * 256 + bs[16]
    d['0_3um-count']  = bs[17] * 256 + bs[18]
    d['0_5um-count']  = bs[19] * 256 + bs[20]
    d['1_0um-count']  = bs[21] * 256 + bs[22]
    d['2_5um-count']  = bs[23] * 256 + bs[24]
    d['5_0um-count']  = bs[25] * 256 + bs[26]
    d['10um-count']   = bs[27] * 256 + bs[28]
    d['hcho']         = bs[29] * 256 + bs[30]
    d['temperature']  = bs[31] * 256 + bs[32]
    d['humidity']     = bs[33] * 256 + bs[34]
    
    return d
    
end -- parse

function getSenserData()
    print_OLED()
end


aqi = nil
t = 0.0
h = 0.0
pm25 = 0
hcho = 0.000 
-- Main Program 
init_OLED(sda,scl)

uart.setup( 0, 9600, 8, 0, 1, 0 )
uart.on("data", 0x420x4d,
  function(data)
    gpio.write(0, gpio.LOW)
    info = parse(data)
--  print("receive from uart:", info['pm2_5-AT'])
    t = info['temperature']/10.0
    h = info['humidity']/10.0
    pm25 = info['pm2_5-AT']
    hcho = info['hcho']/1000.0
    if data==nil then
      uart.on("data") -- unregister callback function
    end
    gpio.write(0, gpio.HIGH)
end, 0)

tmr.alarm(1, 1000, 1, getSenserData)
