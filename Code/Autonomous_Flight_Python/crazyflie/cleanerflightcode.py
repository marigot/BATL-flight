#new & improved bad Boi
'''**************
imported packages
**************'''
import logging
import cflib.crtp
import time
#import matplotlib.pyplot as plt
import datetime
import cflib.drivers.crazyradio as crazyradio


from cflib.crazyflie import Crazyflie
from cflib.crazyflie.syncCrazyflie import SyncCrazyflie
from cflib.crazyflie.log import LogConfig
from cflib.crazyflie.syncLogger import SyncLogger

'''*************
global variables
*************'''
#change this to the radio ID
URI = 'radio://0/80/2M'
radio=crazyradio.Crazyradio()
radio.set_channel(75)
#set up LogConfig objects for logging
log_confKalman = LogConfig(name='kalman',period_in_ms=10)
log_confAcc = LogConfig(name='acc',period_in_ms=10)
log_confGyro = LogConfig(name='gyro',period_in_ms=10)
log_confPm = LogConfig(name='pm',period_in_ms=10)
log_confBaro = LogConfig(name='baro',period_in_ms=10)

#store data for future use?
#time
startTime=time.time()
tarray=[]
#kalman
kalmanZ=[]
#acc
accZ=[]
#gyro
gyroX=[]
gyroY=[]
#battery
vbat=[]
#baro
asl=[]
pressure=[]
temp=[]

'''tunnelMiddle=.42 #middle of tunnel in meters
cylinder=.015/2 #cylinder radius meters'''

isHover=False



#file I/O initialization
currentTime=str(datetime.datetime.now())     #change file label below#
fileName='/Users/bewleylab/Documents/GitHub/Data/'+currentTime+'_f15_d3.5_t36k_p0.5_i0.5_d0x.txt'
f=open(fileName,"w+")

# Only output errors from the logging framework
logging.basicConfig(level=logging.ERROR)

###taken from example code autonomousSequence.py###
#localizing using the Kalman filter
def wait_for_position_estimator(scf):
    print('Waiting for estimator to find position...')

    log_config = LogConfig(name='Kalman Variance', period_in_ms=500)
    log_config.add_variable('kalman.varPX', 'float')
    log_config.add_variable('kalman.varPY', 'float')
    log_config.add_variable('kalman.varPZ', 'float')

    var_y_history = [1000] * 10
    var_x_history = [1000] * 10
    var_z_history = [1000] * 10

    threshold = 0.001

    with SyncLogger(scf, log_config) as logger:
        for log_entry in logger:
            data = log_entry[1]

            var_x_history.append(data['kalman.varPX'])
            var_x_history.pop(0)
            var_y_history.append(data['kalman.varPY'])
            var_y_history.pop(0)
            var_z_history.append(data['kalman.varPZ'])
            var_z_history.pop(0)

            min_x = min(var_x_history)
            max_x = max(var_x_history)
            min_y = min(var_y_history)
            max_y = max(var_y_history)
            min_z = min(var_z_history)
            max_z = max(var_z_history)

            print("{} {} {}".
                  format(max_x - min_x, max_y - min_y, max_z - min_z))

            if (max_x - min_x) < threshold and (
                    max_y - min_y) < threshold and (
                    max_z - min_z) < threshold:
                break

###taken from example code autonomousSequence.py###
#resets the estimator
def reset_estimator(scf):
    cf = scf.cf
    cf.param.set_value('kalman.resetEstimation', '1')
    time.sleep(0.1)
    cf.param.set_value('kalman.resetEstimation', '0')

    wait_for_position_estimator(cf)
    
###kalman.stateZ
def value_callbackKalman(timestamp,data,logconf):
    if not f.closed:
    #time
        global startTime
        global isHover
        
        if isHover
        t=time.time()-startTime
        tarray.append(t)
    #kalman.z
        kz=data['kalman.stateZ']
        kalmanZ.append(kz)
    #write to file
        tempStr='{}, {}'.format(t,kz);
        f.write(tempStr)
        
###acc.z
def value_callbackAcc(timestamp,data,logconf):
    if not f.closed:
    #acc.z
        accZ=data['acc.z']
        acc.append(accZ)
    #write to file
        tempStr=', {}'.format(accZ)
        f.write(tempStr+'\n')
        
###gyro.x/gyro.y
def value_callbackGyro(timestamp,data,logconf):
    if not f.closed:
    #gyro.x
        gx=data['gyro.x']
        gyroX.append(gx)
    #gyro.y
        gy=data['gyro.y']
        gyroY.append(gy)
    #write to file
        tempStr=', {}, {}'.format(gx,gy)
        f.write(tempStr)
        
###pm.vbat
def value_callbackPm(timestamp,data,logconf):
    if not f.closed:
    #pm.vbat
        b=data['pm.vbat']
        vbat.append(b)
    #write to file
        tempStr=', {}'.format(b)
        f.write(tempStr+'\n')
        
###baro.asl/baro.pressure/baro.temp
def value_callbackPm(timestamp,data,logconf):
    if not f.closed:
    #baro.asl
        aslData=data['baro.asl']
        asl.append(aslData)
    #baro.pressure
        p=data['baro.pressure']
        pressure.append(p)
    #baro.temp
        tempData=['baro.temp']
        temp.append(tempData)
    #write to file
        tempStr=', {}, {}, {}'.format(aslData,p,tempData)
        f.write(tempStr+'\n')
    
#adds all logging variables to respective log blocks and starts logging
def start_value_printing(scf):
    #kalman
    log_confKalman.add_variable('kalman.stateZ','float')
    #acc
    log_confAcc.add_variable('acc.z','float')
    #gyro
    log_confGyro.add_variable('gyro.x','float')
    log_confGyro.add_variable('gyro.y','float')
    #pm
    log_confPm.add_variable('pm.vbat','float')
    #baro
    log_confBaro.add_variable('baro.asl','float')
    log_confBaro.add_variable('baro.pressure','float')
    log_confBaro.add_variable('baro.temp','float')

    #add configs
    scf.cf.log.add_config(log_confKalman)
    scf.cf.log.add_config(log_confAcc)
    scf.cf.log.add_config(log_confGyro)
    scf.cf.log.add_config(log_confPm)
    scf.cf.log.add_config(log_confBaro)

    #add callbacks
    log_confKalman.data_received_cb.add_callback(value_callbackKalman)
    log_confAcc.data_received_cb.add_callback(value_callbackAcc)
    log_confGyro.data_received_cb.add_callback(value_callbackGyro)
    log_confPm.data_received_cb.add_callback(value_callbackPm)
    log_confBaro.data_received_cb.add_callback(value_callbackBaro)

    #start logs
    log_confKalman.start()
    log_confAcc.start()
    log_confGyro.start()
    log_confPm.start()
    log_confBaro.start()

###modified from example code flowsequenceSync.py###
#main function
if __name__ == '__main__':
    
    global isHover
    
    # Initialize the low-level drivers (don't list the debug drivers)
    cflib.crtp.init_drivers(enable_debug_driver=False)

    with SyncCrazyflie(URI, cf=Crazyflie(rw_cache='./cache')) as scf:
        #labels all the saved logging variables
        f.write('timestamp, kalman.stateZ, acc.z, gyro.x, gyro.y, pm.vbat, baro.asl, baro.pressure, baro.temp\n')
        
        #starts logging
        reset_estimator(scf)
        start_value_printing(scf)
        cf = scf.cf
        
        print(radio)                       

        #liftoff
        for y in range(10):
            cf.commander.send_hover_setpoint(0, 0, 0, y / 25) #rise up to .4 m
            time.sleep(0.1)
        #hover
        hoverTime=time.time()
        while time.time()-hoverTime<70:
            if time.time()-hoverTime>5 and time.time()-hoverTime<65:
                isHover=True
            else
                isHover=False
                
            cf.commander.send_hover_setpoint(0, 0, 0, (0.42-.075)) #hover point
            time.sleep(0.1)
        #landing
        for y in range(10):
            print(y)
            if  y==0:
                print('landing time is:',t)
                chunksT.append(t)
            cf.commander.send_hover_setpoint(0, 0, 0, (10 - y) / 25)
            time.sleep(0.1)
        print('landed time is:',t)
        print (ogkz)
        chunksT.append(t)
        #time.sleep(.5)
        cf.commander.send_stop_setpoint()
        
        #stop logging and clear the log configs
        #log_confKalman.stop()
        #log_conf2.stop()
        log_confKalman.stop()
        log_confGyro.stop()
        log_confBaro.stop()
        #log_confAcc.stop()
        #print('stopped logging')
        
        
        #log_confKalman.delete()
        #log_conf2.delete()
        log_confKalman.delete()
        log_confGyro.delete()
        log_confBaro.delete()
        #log_confAcc.delete()
        time.sleep(1)
        #close writing to file
        f.close()