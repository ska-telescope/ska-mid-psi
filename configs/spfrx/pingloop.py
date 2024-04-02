from PyTango import DeviceProxy
import os
from time import sleep

os.environ["TANGO_HOST"] = "10.164.10.181:10000"
server = "ska001/spfrxpu/controller"
dp = DeviceProxy(server)

while True:
    dp.command_inout("MonitorPing")
    print(f"Pinging {server}")
    sleep(100)