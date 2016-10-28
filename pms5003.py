#encoding=utf-8
import os
import serial  
import time
from struct import *

# 打开串口  
print "Opening Serial Port...",
ser = serial.Serial("/dev/tty.wchusbserial1420", baudrate=9600, timeout=2.0)
print "Serial Connected"

def read_pm_line(_port):
    rv = b''
    while True:
        ch1 = _port.read()
        if ch1 == b'\x42':
            ch2 = _port.read()
            if ch2 == b'\x4d':
                rv += ch1 + ch2
                rv += _port.read(38)
                return rv

def main(): 
    cnt = 0
    # conn = sqlite3.connect('pm25.db')
    # c = conn.cursor()
    while True:  
        # 获得接收缓冲区字符
        recv = read_pm_line(ser)

        cnt = cnt + 1
        print "[%d]Recieve Data" % cnt,
        print len(recv), "Bytes:",
        tmp = recv[4:36]
        datas = unpack('>hhhhhhhhhhhhhhhh', tmp)
        # print datas
        os.system('clear') 
        print('\n======= PMS5003ST ========\n'
              'PM1.0(CF=1): {}\n'
              'PM2.5(CF=1): {}\n'
              'PM10 (CF=1): {}\n'
              'PM1.0 (STD): {}\n'
              'PM2.5 (STD): {}\n'
              'PM10  (STD): {}\n'
              '>0.3um     : {}\n'
              '>0.5um     : {}\n'
              '>1.0um     : {}\n'
              '>2.5um     : {}\n'
              '>5.0um     : {}\n'
              '>10um      : {}\n'
              'HCHO       : {}\n'
              'temperature: {}\n'
              'humidity(%): {}'.format(datas[0], datas[1], datas[2],
                                       datas[3], datas[4], datas[5],
                                       datas[6], datas[7], datas[8],
                                       datas[9], datas[10], datas[11],
                                       datas[12]/1000.0, datas[13]/10.0, datas[14]/10.0))
        # 清空接收缓冲区  
        ser.flushInput()
        
        # 必要的软件延时  
        time.sleep(0.1)  


if __name__ == '__main__':  
    try:  
        main()  
    except KeyboardInterrupt:  
        if ser != None:  
            ser.close()