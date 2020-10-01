#hoverTest code
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
#log_conf1 = LogConfig(name='rpy',period_in_ms=10)
#log_conf2 = LogConfig(name='xy',period_in_ms=10)
log_conf3 = LogConfig(name='kalman',period_in_ms=10)
log_conf4 = LogConfig(name='a',period_in_ms=10)
log_conf5 = LogConfig(name='b',period_in_ms=10)
log_conf6 = LogConfig(name='c',period_in_ms=10)
#zeroing variables for time, stateEstimate.x/y/z, kalman.stateX/stateY/stateZ
firstTime=0
firstX=0
firstY=0
firstZ=0
firstKX=0
firstKY=0
firstKZ=0
ogsx=0
ogsy=0
ogsz=0
ogkx=0
ogky=0
ogkz=0
t=0
#time array
timePlot=[]
#stateEstimate.x/y/z arrays
stateEstimateX=[]
stateEstimateY=[]
stateEstimateZ=[]
#kalman.x/y/z arrays
kalmanX=[]
kalmanY=[]
kalmanZ=[]
#controller.roll/pitch/yaw arrays
controllerRoll=[]
controllerPitch=[]
controllerYaw=[]
#controller.rollRate/pitchRate/yawRate arrays
controllerRollRate=[]
controllerPitchRate=[]
controllerYawRate=[]
#gyro.x/y/z arrays
gyroX=[]
gyroY=[]
gyroZ=[]
gyroXRaw=[]
gyroYRaw=[]
gyroZRaw=[]
gyroXVariance=[]
gyroYVariance=[]
gyroZVariance=[]
#vbat array
vbat=[]
#pid array
pidRollP=[]
pidRollI=[]
pidRollD=[]
pidPitchP=[]
pidPitchI=[]
pidPitchD=[]
pidYawP=[]
pidYawI=[]
pidYawD=[]
pidRateRollP=[]
pidRateRollI=[]
pidRateRollD=[]
pidRatePitchP=[]
pidRatePitchI=[]
pidRatePitchD=[]
pidRateYawP=[]
pidRateYawI=[]
pidRateYawD=[]

#start/liftoffs/maneuvers/stop times array
chunksT=[]
#file I/O initialization
currentTime=str(datetime.datetime.now())     #change file label below#
fileName='/Users/bewleylab/Documents/GitHub/Data/'+currentTime+'_f15_d3.5_t36k_p0.5_i0.5_d0x.txt'
f=open(fileName,"w+")

# Only output errors from the logging framework
logging.basicConfig(level=logging.ERROR)

###taken from example code autonomousSequence.py###
#does something with the kalman variance to estimate starting position but not exactly sure what
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
    
###returns and saves data for log block 1 (controller.roll/pitch/yaw/rollRate/pitchRate/yawRate)
##'''def value_callback1(timestamp,data,logconf):
##    global firstTime
##    global t
##    
##    #b=data['pm.batteryLevel']
##    if not f.closed:
##        cr=data['controller.roll']
##        controllerRoll.append(cr)
##        cp=data['controller.pitch']
##        controllerPitch.append(cp)
##        cy=data['controller.yaw']
##        controllerYaw.append(cy)
##        
##        crr=data['controller.rollRate']
##        controllerRollRate.append(crr)
##        cpr=data['controller.pitchRate']
##        controllerPitchRate.append(cpr)
##        cyr=data['controller.yawRate']
##        controllerYawRate.append(cyr)
##        
##        if firstTime==0:
##            firstTime=timestamp
##
##        t=timestamp-firstTime
##        tempStr='{},{},{},{},{},{},{}'.format(t,cp,cpr,cr,crr,cy,cyr)
##
##        timePlot.append((t))
##        print('added new t')
##        f.write(tempStr+'\n')
##        
##    
##    #print(b)'''
##
###returns and saves data for log block 2 (stateEstimate.x/y/z and gyro.x/y/z)
##'''def value_callback2(timestamp,data,logconf):
##    global firstX
##    global firstY
##    global firstZ
##    global ogsx
##    global ogsy
##    global ogsz
##    if not f.closed:
##        sx=data['stateEstimate.x']
##        if firstX==0:
##            ogsx=sx
##            firstX=1
##        sx=sx-ogsx
##        stateEstimateX.append(sx)
##        sy=data['stateEstimate.y']
##        if firstY==0:
##            ogsy=sy
##            firstY=1
##        sy=sy-ogsy 
##        stateEstimateY.append(sy)
##        sz=data['stateEstimate.z']
##        if firstZ==0:
##            ogsz=sz
##            firstZ=1
##        sz=sz-ogsz
##        stateEstimateZ.append(sz)
##            
##
##        gx=data['gyro.x']
##        gyroX.append(gx)
##        gy=data['gyro.y']
##        gyroY.append(gy)
##        gz=data['gyro.z']
##        gyroZ.append(gz)
##        
##        #b=data['pm.batteryLevel']
##        
##        tempStr=',{},{},{},{},{},{}'.format(sx,sy,sz,gx,gy,gz)
##        f.write(tempStr+'\n')
##        print("in next log block")
##    
##    #print(b)'''
##
###returns and saves data for log block 3 (kalman.stateX/stateY/stateZ)
def value_callback3(timestamp,data,logconf):
    global firstKX
    global firstKY
    global firstKZ
    global t
    global firstTime
    global ogkx
    global ogky
    global ogkz

    global firstX
    global firstY
    global firstZ
    global ogsx
    global ogsy
    global ogsz
    if not f.closed:
##        kx=data['kalman.stateX']
##        if firstKX==0:
##            ogkx=kx
##            firstKX=1
##        kx=kx-ogkx
##        kalmanX.append(kx)
##        ky=data['kalman.stateY']
##        if firstKY==0:
##            ogky=ky
##            firstKY=1
##        ky=ky-ogky
##        kalmanY.append(ky)
        kz=data['kalman.stateZ']
        if firstKZ==0:
            ogkz=kz
            firstKZ=1
        #kz=kz-ogkz
        kalmanZ.append(kz)

        if firstTime==0:
            firstTime=timestamp

        t=timestamp-firstTime
        timePlot.append((t))
#        gz=data['gyro.z']
#        gyroZ.append(gz)
    #if not f.closed:
    #    sx=data['stateEstimate.x']
    #    if firstX==0:
    #        ogsx=sx
    #        firstX=1
    #    sx=sx-ogsx
    #    stateEstimateX.append(sx)
    #    sy=data['stateEstimate.y']
    #    if firstY==0:
    #        ogsy=sy
    #        firstY=1
    #    sy=sy-ogsy 
    #    stateEstimateY.append(sy)
    #    sz=data['stateEstimate.z']
    #    if firstZ==0:
    #        ogsz=sz
    #        firstZ=1
    #    sz=sz-ogsz
     #   stateEstimateZ.append(sz)    
   #     #b=data['pm.vbat']
   #     #vbat.append(b)
        
        #tempStr=',{},{},{}'.format(kx,ky,kz)
        #tempStr='{},{},{},{}'.format(t,kx,ky,kz);
        tempStr='{},{}'.format(t,kz);
        f.write(tempStr)
        #print(b),
def value_callback4(timestamp,data,logconf):
    if not f.closed:
        gx=data['gyro.x']
        gyroX.append(gx)
        
        gxRaw=data['gyro.xRaw']
        gyroXRaw.append(gxRaw)

        #gxVariance=data['gyro.xVariance']
        #gyroXVariance.append(gxVariance)

        zrange=data['range.zrange']
    
        tempStr=',{},{},{}'.format(gx,gxRaw,zrange)
        f.write(tempStr)

def value_callback5(timestamp,data,logconf):
    if not f.closed:
        gy=data['gyro.y']
        gyroY.append(gy)
        
        #gyRaw=data['gyro.yRaw']
        #gyroYRaw.append(gyRaw)

        #gyVariance=data['gyro.yVariance']
        #gyroYVariance.append(gyVariance)

        #ff=data['sitAw.FFAccWZDetected']
        accz=data['acc.z']
        
        b=data['motor.m1']
        vbat.append(b)
    
        tempStr=',{},{},{}'.format(gy,accz,b)
        f.write(tempStr+'\n')

def value_callback6(timestamp,data,logconf):
    if not f.closed:
        m1x=data['motor.m2']
        m2x=data['motor.m3']
        m3x=data['motor.m4']
        tempStr=',{},{},{}'.format(m1x,m2x,m3x)
        f.write(tempStr+'\n')
#returns and saves data for log block 4 (pid_attitude.roll_outP/I/D, pid_attitude.pitch_outP/I/D)
##def value_callback4(timestamp,data,logconf):
##    global firstTime
##    #global t
##    if not f.closed:
##        rp=data['pid_attitude.roll_outP']
##        pidRollP.append(rp)
##        ri=data['pid_attitude.roll_outI']
##        pidRollI.append(ri)
##        rd=data['pid_attitude.roll_outD']
##        pidRollD.append(rd)
##
##        pp=data['pid_attitude.pitch_outP']
##        pidPitchP.append(pp)
##        pi=data['pid_attitude.pitch_outI']
##        pidPitchI.append(pi)
##        pd=data['pid_attitude.pitch_outD']
##        pidPitchD.append(pd)
##
##        #if firstTime==0:
##        #    firstTime=timestamp
##
##        #t=timestamp-firstTime
##        #timePlot.append((t))
##        
##        tempStr=',{},{},{},{},{},{}'.format(rp,ri,rd,pp,pi,pd)
##        #tempStr='{},{},{},{},{},{},{}'.format(t,rp,ri,rd,pp,pi,pd)
##        f.write(tempStr)
##        
##        #b=data['pm.vbat']
##        #vbat.append(b)
##        #print(b)
##
##def value_callback5(timestamp,data,logconf):
##    if not f.closed:
##        rrp=data['pid_rate.roll_outP']
##        pidRateRollP.append(rrp)
##        rri=data['pid_rate.roll_outI']
##        pidRateRollI.append(rri)
##        rrd=data['pid_rate.roll_outD']
##        pidRateRollD.append(rrd)
##        
##        prp=data['pid_rate.pitch_outP']
##        pidRatePitchP.append(prp)
##        pri=data['pid_rate.pitch_outI']
##        pidRatePitchI.append(pri)
##        prd=data['pid_rate.pitch_outD']
##        pidRatePitchD.append(prd)
##        
##        tempStr=',{},{},{},{},{},{}'.format(rrp,rri,rrd,prp,pri,prd)
##        f.write(tempStr)
###returns and saves data for log block 5 (pid_attitude.yaw_outP/I/D, pid_rate.roll_outP/I/D)
##def value_callback5(timestamp,data,logconf):
##    if not f.closed:
##        yp=data['pid_attitude.yaw_outP']
##        pidYawP.append(yp)
##        yi=data['pid_attitude.yaw_outI']
##        pidYawI.append(yi)
##        yd=data['pid_attitude.yaw_outD']
##        pidYawD.append(yd)
##        
##        rrp=data['pid_rate.roll_outP']
##        pidRateRollP.append(rrp)
##        rri=data['pid_rate.roll_outI']
##        pidRateRollI.append(rri)
##        rrd=data['pid_rate.roll_outD']
##        pidRateRollD.append(rrd)
##
##        
##        tempStr=',{},{},{},{},{},{}'.format(yp,yi,yd,rrp,rri,rrd)
##        f.write(tempStr)
##
###returns and saves data for log block 6 (pid_rate.pitch_outP/I/D, pid_rate.yaw_outP/I/D)
##def value_callback6(timestamp,data,logconf):
##    if not f.closed:
##        prp=data['pid_rate.pitch_outP']
##        pidRatePitchP.append(prp)
##        pri=data['pid_rate.pitch_outI']
##        pidRatePitchI.append(pri)
##        prd=data['pid_rate.pitch_outD']
##        pidRatePitchD.append(prd)
##
##        yrp=data['pid_rate.yaw_outP']
##        pidRateYawP.append(yrp)
##        yri=data['pid_rate.yaw_outI']
##        pidRateYawI.append(yri)
##        yrd=data['pid_rate.yaw_outD']
##        pidRateYawD.append(yrd)
##        
##        tempStr=',{},{},{},{},{},{}'.format(prp,pri,prd,yrp,yri,yrd)
##
##        f.write(tempStr+'\n')


    
#adds all logging variables to respective log blocks and starts logging
def start_value_printing(scf):
##    '''log_conf1.add_variable('controller.roll','float')
##    log_conf1.add_variable('controller.pitch','float')
##    log_conf1.add_variable('controller.yaw','float')
##    log_conf1.add_variable('controller.rollRate','float')
##    log_conf1.add_variable('controller.pitchRate','float')
##    log_conf1.add_variable('controller.yawRate','float')
##
##    log_conf2.add_variable('stateEstimate.x','float')
##    log_conf2.add_variable('stateEstimate.y','float')
##    log_conf2.add_variable('stateEstimate.z','float')
##    log_conf2.add_variable('gyro.x','float')
##    log_conf2.add_variable('gyro.y','float')
##    log_conf2.add_variable('gyro.z','float')
##
    #log_conf3.add_variable('kalman.stateX','float')
    #log_conf3.add_variable('kalman.stateY','float')
    log_conf3.add_variable('kalman.stateZ','float')
    #log_conf3.add_variable('stateEstimate.x','float')
    #log_conf3.add_variable('stateEstimate.y','float')
    #log_conf3.add_variable('stateEstimate.z','float')
##    log_conf3.add_variable('pm.vbat','float')'''
    log_conf4.add_variable('gyro.x','float')
    log_conf4.add_variable('gyro.xRaw','int16_t')
#    log_conf4.add_variable('gyro.xVariance','float')
    log_conf4.add_variable('range.zrange','uint16_t')
    
    log_conf5.add_variable('gyro.y','float')
#   log_conf5.add_variable('gyro.yRaw','int16_t')
#    log_conf5.add_variable('gyro.yVariance','float')
#    log_conf5.add_variable('sitAw.FFAccWZDetected','uint8_t')
    log_conf5.add_variable('acc.z','float')
    log_conf5.add_variable('motor.m1','int32_t')

    log_conf6.add_variable('motor.m2','int32_t')
    log_conf6.add_variable('motor.m3','int32_t')
    log_conf6.add_variable('motor.m4','int32_t')

##    log_conf4.add_variable('pid_attitude.roll_outP','float')
##    log_conf4.add_variable('pid_attitude.roll_outI','float')
##    log_conf4.add_variable('pid_attitude.roll_outD','float')
##    log_conf4.add_variable('pid_attitude.pitch_outP','float')
##    log_conf4.add_variable('pid_attitude.pitch_outI','float')
##    log_conf4.add_variable('pid_attitude.pitch_outD','float')
###    log_conf4.add_variable('pm.vbat','float')
##    
####    log_conf5.add_variable('pid_attitude.yaw_outP','float')
####    log_conf5.add_variable('pid_attitude.yaw_outI','float')
####    log_conf5.add_variable('pid_attitude.yaw_outD','float')
##    log_conf5.add_variable('pid_rate.roll_outP','float')
##    log_conf5.add_variable('pid_rate.roll_outI','float')
##    log_conf5.add_variable('pid_rate.roll_outD','float')
##    log_conf5.add_variable('pid_rate.pitch_outP','float')
##    log_conf5.add_variable('pid_rate.pitch_outI','float')
##    log_conf5.add_variable('pid_rate.pitch_outD','float')

##    log_conf6.add_variable('pid_rate.pitch_outP','float')
##    log_conf6.add_variable('pid_rate.pitch_outI','float')
##    log_conf6.add_variable('pid_rate.pitch_outD','float')
##    log_conf6.add_variable('pid_rate.yaw_outP','float')
##    log_conf6.add_variable('pid_rate.yaw_outI','float')
##    log_conf6.add_variable('pid_rate.yaw_outD','float')
 
    #scf.cf.log.add_config(log_conf1)
    #scf.cf.log.add_config(log_conf2)
    scf.cf.log.add_config(log_conf3)
    scf.cf.log.add_config(log_conf4)
    scf.cf.log.add_config(log_conf5)
    scf.cf.log.add_config(log_conf6)
    #log_conf1.data_received_cb.add_callback(value_callback1)
    #log_conf2.data_received_cb.add_callback(value_callback2)
    log_conf3.data_received_cb.add_callback(value_callback3)
    log_conf4.data_received_cb.add_callback(value_callback4)
    log_conf5.data_received_cb.add_callback(value_callback5)
    log_conf6.data_received_cb.add_callback(value_callback6)
    #log_conf1.start()
    #log_conf2.start()
    log_conf3.start()
    log_conf4.start()
    log_conf5.start()
    log_conf6.start()

###modified from example code flowsequenceSync.py###
#main function
if __name__ == '__main__':
    
    # Initialize the low-level drivers (don't list the debug drivers)
    cflib.crtp.init_drivers(enable_debug_driver=False)

    with SyncCrazyflie(URI, cf=Crazyflie(rw_cache='./cache')) as scf:
        #labels all the saved logging variables
        f.write('timestamp, '
                #'controller.pitch,controller.pitchRate,controller.roll,controller.rollRate,controller.yaw,controller.yawRate,'
                #'stateEstimate.x,stateEstimate.y,stateEstimate.z,'
                #'gyro.x,gyro.y,gyro.z,'
                #'kalman.stateX,kalman.stateY,kalman.stateZ,'
                'kalman.stateZ, '
                #'stateEstimate.x,stateEstimate.y,stateEstimate.z,'
                'gyro.x, gyro.xRaw, range.zrange, gyro.y, acc.z, pm.vbat, '#gyro.yVariance'
                #'kalman.stateZ,'
                #'pid_attitude.roll_outP,pid_attitude.roll_outI,pid_attitude.roll_outD,'
                #'pid_attitude.pitch_outP,pid_attitude.pitch_outI,pid_attitude.pitch_outD,'
                #'pid_attitude.yaw_outP,pid_attitude.yaw_outI,pid_attitude.yaw_outD,'
                #'pid_rate.roll_outP,pid_rate.roll_outI,pid_rate.roll_outD,'
                #'pid_rate.pitch_outP,pid_rate.pitch_outI,pid_rate.pitch_outD,'
                #'pid_rate.yaw_outP,pid_rate.yaw_outI,pid_rate.yaw_outD,'
                'M1X, M2X, M3X, M4X'
                '\n')
        #starts logging
        reset_estimator(scf)
        start_value_printing(scf)
        cf = scf.cf
        
        #print('begin moving. time is:', t)
        chunksT.append(t)
        print(radio)
        #function header                               
        '''def send_hover_setpoint(self, vx, vy, yawrate, zdistance):
        ***    vx and vy are in m/s
        ***    yawrate is in degrees/s'''


        '''thrust_mult = 1
        thrust_step = 500
        thrust = 25000
        pitch = 0
        roll = 0
        yawrate = 0

        # Unlock startup thrust protection
        cf.commander.send_setpoint(0, 0, 0, 0)

        while thrust >= 25000:
            cf.commander.send_setpoint(roll, pitch, yawrate, thrust)
            time.sleep(0.1)
            if thrust >= 25500:
                thrust_mult = -1
            thrust += thrust_step * thrust_mult
        cf.commander.send_setpoint(0, 0, 0, 0)
        # Make sure that the last packet leaves before the link is closed
        # since the message queue is not flushed before closing
        time.sleep(5)'''


        
        #liftoff
        print("running");
        for y in range(10):
            print(y)
            if  y==0:
                print('liftoff time is:',t)
                chunksT.append(t)
            cf.commander.send_hover_setpoint(0, 0, 0, y / 25)
            time.sleep(0.1)
        #hover
        for _ in range(500):
            print(_)
            if  _==0:
                print('hover time is:',t)
                chunksT.append(t)
            cf.commander.send_hover_setpoint(0, 0, 0, (0.42-.075))
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
        #log_conf1.stop()
        #log_conf2.stop()
        log_conf3.stop()
        log_conf4.stop()
        log_conf5.stop()
        log_conf6.stop()
        #print('stopped logging')
        
        
        #log_conf1.delete()
        #log_conf2.delete()
        log_conf3.delete()
        log_conf4.delete()
        log_conf5.delete()
        log_conf6.delete()
        time.sleep(1)
        #close writing to file
        f.close()
        
        
        #plotting
        integRollCRR=[0]
        integRollGX=[0]
        integPitchCPR=[0]
        integPitchGY=[0]
        integYawCYR=[0]
        integYawGZ=[0]
        
        
        
        #highkey sketchy integration function (trapezoid riemann sum, but so sketch)
##        for i in timePlot:
##            if i!=0:
##                '''if ((controllerRollRate[int(i/10)]>=0&&controllerRollRate[int((i/10))-1]<=0):
##                    m=(controllerRollRate[int(i/10)]-controllerRollRate[int((i/10))-1])/10
##                    x=(-controllerRollRate[int((i/10))-1])+(m*int((i/10))))/m
##                    areaCRR=((controllerRollRate[int(i/10)]+controllerRollRate[int((i/10))-1])/2)*.01 + integRollCRR[int(i/10)-1]
##                    areaGX=((gyroX[int(i/10)]+gyroX[int((i/10))-1])/2)*.01 + integRollGX[int(i/10)-1]
##                else if (controllerRollRate[int(i/10)]<=0&&controllerRollRate[int((i/10))-1]>=0)):
##                    m=(controllerRollRate[int(i/10)]-controllerRollRate[int((i/10))-1])/10
##                    x=(-controllerRollRate[int((i/10))-1])+(m*int((i/10))))/m
##                    areaCRR=integRollCRR[int(i/10)-1]-(((controllerRollRate[int((i/10))-1])*(x-i-10)/2)+(controllerRollRate[int(i/10)]*(10-
##                    
##                    areaGX=((gyroX[int(i/10)]+gyroX[int((i/10))-1])/2)*.01 + integRollGX[int(i/10)-1]
##                else:
##                    areaCRR=((controllerRollRate[int(i/10)]+controllerRollRate[int((i/10))-1])/2)*.01 + integRollCRR[int(i/10)-1]
##                    areaGX=((gyroX[int(i/10)]+gyroX[int((i/10))-1])/2)*.01 + integRollGX[int(i/10)-1]'''
##                areaCRR=((controllerRollRate[int(i/10)]+controllerRollRate[int((i/10))-1])/2)*.01 + integRollCRR[int(i/10)-1]
##                areaGX=((gyroX[int(i/10)]+gyroX[int((i/10))-1])/2)*.01 + integRollGX[int(i/10)-1]
##                integRollCRR.append(areaCRR)
##                integRollGX.append(areaGX)
##                areaCPR=((controllerPitchRate[int(i/10)]+controllerPitchRate[int((i/10))-1])/2)*.01 + integPitchCPR[int(i/10)-1]
##                areaGY=((gyroY[int(i/10)]+gyroY[int((i/10))-1])/2)*.01 + integPitchGY[int(i/10)-1]
##                integPitchCPR.append(areaCPR)
##                integPitchGY.append(areaGY)
##                areaCYR=((controllerYawRate[int(i/10)]+controllerYawRate[int((i/10))-1])/2)*.01 + integYawCYR[int(i/10)-1]
##                areaGZ=((gyroZ[int(i/10)]+gyroZ[int((i/10))-1])/2)*.01 + integYawGZ[int(i/10)-1]
##                integYawCYR.append(areaCYR)
##                integYawGZ.append(areaGZ)


        #if (len(timePlot)!=len(pidRollP)):
        #    print('in if')
        #    timePlot.pop(len(timePlot)-1)

        #print(gyroXVariance)
        
##        plt.figure(currentTime)
##        plt.rcParams.update({'font.size': 8})
##        
##
##        plt.subplot(331)
##        for xc in chunksT:
##            plt.axvline(x=xc,color='r')
##        plt.plot(timePlot,gyroXRaw, label='gyro.xRaw')
##        plt.ylim(-1500,1500)
##        plt.grid(True)
##        plt.legend()
##        
##        plt.subplot(334)
##        for xc in chunksT:
##            plt.axvline(x=xc,color='r')
##
##        plt.plot(timePlot,gyroX, label='gyro.x')
##        plt.ylim(-300,300)
##        plt.grid(True)
##        plt.legend()
##
##
##        plt.subplot(337)
##        for xc in chunksT:
##            plt.axvline(x=xc,color='r')
##        plt.plot(timePlot,gyroXVariance, label='gyro.xVariance')
##        plt.ylim(gyroXVariance[0]-.25,gyroXVariance[0]+.25)
##        plt.grid(True)
##        plt.legend()
##
##        plt.subplot(332)
##        for xc in chunksT:
##            plt.axvline(x=xc,color='r')
##        plt.plot(timePlot,gyroYRaw, label='gyro.yRaw')
##        plt.ylim(-1500,1500)
##        plt.grid(True)
##        plt.legend()
##
##        plt.subplot(335)
##        for xc in chunksT:
##            plt.axvline(x=xc,color='r')
##        plt.plot(timePlot,gyroY, label='gyro.y')
##        plt.ylim(-300,300)
##        plt.grid(True)
##        plt.legend()
##
##        plt.subplot(338)
##        for xc in chunksT:
##            plt.axvline(x=xc,color='r')
##        plt.plot(timePlot,gyroYVariance, label='gyro.yVariance')
##        plt.ylim(gyroYVariance[0]-.25,gyroYVariance[0]+.25)
##        plt.grid(True)
##        plt.legend()
##
##        plt.subplot(333)
##        for xc in chunksT:
##            plt.axvline(x=xc,color='r')
##        plt.plot(timePlot,kalmanZ, label='kalman.z')
##        plt.ylim(.3,.4)
##        plt.grid(True)
##        plt.legend()


##
##        plt.subplot(331)
##        for xc in chunksT:
##            plt.axvline(x=xc,color='r')
##        plt.plot(timePlot,pidRollP, label='pid_attitude.roll_outP')
##        plt.plot(timePlot,pidRollI, label='pid_attitude.roll_outI')
##        plt.plot(timePlot,pidRollD, label='pid_attitude.roll_outD')
##        plt.ylim(-40,40)
##        plt.grid(True)
##        plt.legend()
##
##        plt.subplot(334)
##        for xc in chunksT:
##            plt.axvline(x=xc,color='r')
##        plt.plot(timePlot,pidPitchP, label='pid_attitude.pitch_outP')
##        plt.plot(timePlot,pidPitchI, label='pid_attitude.pitch_outI')
##        plt.plot(timePlot,pidPitchD, label='pid_attitude.pitch_outD')
##        plt.ylim(-50,50)
##        plt.grid(True)
##        plt.legend()
##
##        plt.subplot(337)
##        for xc in chunksT:
##            plt.axvline(x=xc,color='r')
##        plt.plot(timePlot,pidYawP, label='pid_attitude.yaw_outP')
##        plt.plot(timePlot,pidYawI, label='pid_attitude.yaw_outI')
##        plt.plot(timePlot,pidYawD, label='pid_attitude.yaw_outD')
##        plt.ylim(-30,30)
##        plt.grid(True)
##        plt.legend()
##
##        plt.subplot(332)
##        for xc in chunksT:
##            plt.axvline(x=xc,color='r')
##        plt.plot(timePlot,pidRateRollP, label='pid_rate.roll_outP')
##        plt.plot(timePlot,pidRateRollI, label='pid_rate.roll_outI')
##        plt.plot(timePlot,pidRateRollD, label='pid_rate.roll_outD')
##        plt.ylim(-20000,20000)
##        plt.grid(True)
##        plt.legend()
##
##        plt.subplot(335)
##        for xc in chunksT:
##            plt.axvline(x=xc,color='r')
##        plt.plot(timePlot,pidRatePitchP, label='pid_rate.pitch_outP')
##        plt.plot(timePlot,pidRatePitchI, label='pid_rate.pitch_outI')
##        plt.plot(timePlot,pidRatePitchD, label='pid_rate.pitch_outD')
##        plt.ylim(-20000,20000)
##        plt.grid(True)
##        plt.legend()
##
##        plt.subplot(338)
##        for xc in chunksT:
##            plt.axvline(x=xc,color='r')
##        plt.plot(timePlot,pidRateYawP, label='pid_rate.Yaw_outP')
##        plt.plot(timePlot,pidRateYawI, label='pid_rate.Yaw_outI')
##        plt.plot(timePlot,pidRateYawD, label='pid_rate.Yaw_outD')
##        plt.ylim(-4000,4000)
##        plt.grid(True)
##        plt.legend()
##
##        plt.subplot(333)
##        #plt.plot(timePlot,stateEstimateX, label='State Estimate X')
##        plt.plot(timePlot,kalmanX, label='Kalman State Estimate X')
##        for xc in chunksT:
##            plt.axvline(x=xc,color='r')
##        #plt.title('State Estimate X')
##        plt.ylim(-.75,.75)
##        plt.xlabel('Time (ms)')
##        plt.ylabel('Meters')
##        plt.grid(True)
##        plt.legend()
##
##        plt.subplot(336)
##        #plt.plot(timePlot,stateEstimateY, label='State Estimate Y')
##        plt.plot(timePlot,kalmanY, label='Kalman State Estimate Y')
##        for xc in chunksT:
##            plt.axvline(x=xc,color='r')
##        #plt.title('State Estimate Y')
##        plt.ylim(-.75,.75)
##        plt.xlabel('Time (ms)')
##        plt.ylabel('Meters')
##        plt.grid(True)
##        plt.legend()
##
##        plt.subplot(339)
##        #plt.plot(timePlot,stateEstimateZ, label='State Estimate Z')
##        plt.plot(timePlot,kalmanZ, label='Kalman State Estimate Z')
##        for xc in chunksT:
##            plt.axvline(x=xc,color='r')
##        #plt.title('State Estimate Z')
##        plt.ylim(-.75,.75)
##        plt.xlabel('Time (ms)')
##        plt.ylabel('Meters')
##        plt.grid(True)
##        plt.legend()
        
##        plt.subplot(331)
##        '''plt.plot(timePlot,vbat, label='vbat')
##        for xc in chunksT:
##            plt.axvline(x=xc,color='r')
##        plt.grid(True)
##        plt.legend()'''
##        
##        #plt.plot(timePlot,stabilizerRoll, label='Stabilizer Roll')
##        for xc in chunksT:
##            plt.axvline(x=xc,color='r')
##        #plt.plot(timePlot,controllerRoll, label='Controller Roll')
##        #plt.plot(timePlot,integRollCRR, label='Integrated Controller Roll Rate')
##        plt.plot(timePlot,integRollGX, label='Integrated Gyro X')
##        #plt.title('Roll')
##        plt.ylim(-20,20)
##        plt.xlabel('Time (ms)')
##        plt.ylabel('Degrees')
##        plt.grid(True)
##        plt.legend()
##
##        plt.subplot(334)
##        '''plt.plot(timePlot,extVbat, label='extVbat')
##        for xc in chunksT:
##            plt.axvline(x=xc,color='r')
##        plt.grid(True)
##        plt.legend()'''
##        #plt.plot(timePlot,stabilizerPitch, label='Stabilizer Pitch')
##        for xc in chunksT:
##            plt.axvline(x=xc,color='r')
##        #plt.plot(timePlot,controllerPitch, label='Controller Pitch')
##        #plt.plot(timePlot,integPitchCPR, label='Integrated Controller Pitch Rate')
##        plt.plot(timePlot,integPitchGY, label='Integrated Gyro Y')
##        #plt.title('Pitch')
##        plt.ylim(-20,20)
##        plt.xlabel('Time (ms)')
##        plt.ylabel('Degrees')
##        plt.grid(True)
##        plt.legend()
##        
##        plt.subplot(337)
##        #plt.plot(timePlot,stabilizerYaw, label='Stabilizer Yaw')
##        for xc in chunksT:
##            plt.axvline(x=xc,color='r')
##        #plt.plot(timePlot,controllerYaw, label='Controller Yaw')
##        #plt.plot(timePlot,integYawCYR, label='Integrated Controller Yaw Rate')
##        plt.plot(timePlot,integYawGZ, label='Integrated Gyro Z')
##        #plt.title('Yaw')
##        plt.ylim(-20,20)
##        plt.xlabel('Time (ms)')
##        plt.ylabel('Degrees')
##        plt.grid(True)
##        plt.legend()
##
##        plt.subplot(332)
##        plt.plot(timePlot,controllerRollRate, label='Controller Roll Rate')
##        #plt.plot(timePlot,gyroX, label='Gyro X')
##        for xc in chunksT:
##            plt.axvline(x=xc,color='r')
##        #plt.title('Roll Rate')
##        plt.ylim(-200,200)
##        plt.xlabel('Time (ms)')
##        plt.ylabel('Degrees/Second')
##        plt.grid(True)
##        leg=plt.legend()
##
##        plt.subplot(335)
##        plt.plot(timePlot,controllerPitchRate, label='Controller Pitch Rate')
##        #plt.plot(timePlot,gyroY, label='Gyro Y')
##        for xc in chunksT:
##            plt.axvline(x=xc,color='r')
##        #plt.title('Pitch Rate')
##        plt.ylim(-200,200)
##        plt.xlabel('Time (ms)')
##        plt.ylabel('Degrees/Second')
##        plt.grid(True)
##        leg=plt.legend()
##
##        plt.subplot(338)
##        plt.plot(timePlot,controllerYawRate, label='Controller Yaw Rate')
##        #plt.plot(timePlot,gyroZ, label='Gyro Z')
##        for xc in chunksT:
##            plt.axvline(x=xc,color='r')
##        #plt.title('Yaw Rate')
##        plt.ylim(-200,200)
##        plt.xlabel('Time (ms)')
##        plt.ylabel('Degrees/Second')
##        plt.grid(True)
##        leg=plt.legend()
##
##        plt.subplot(333)
##        #plt.plot(timePlot,stateEstimateX, label='State Estimate X')
##        plt.plot(timePlot,kalmanX, label='Kalman State Estimate X')
##        for xc in chunksT:
##            plt.axvline(x=xc,color='r')
##        #plt.title('State Estimate X')
##        plt.ylim(-1,1)
##        plt.xlabel('Time (ms)')
##        plt.ylabel('Meters')
##        plt.grid(True)
##        plt.legend()
##
##        plt.subplot(336)
##        #plt.plot(timePlot,stateEstimateY, label='State Estimate Y')
##        plt.plot(timePlot,kalmanY, label='Kalman State Estimate Y')
##        for xc in chunksT:
##            plt.axvline(x=xc,color='r')
##        #plt.title('State Estimate Y')
##        plt.ylim(-1,1)
##        plt.xlabel('Time (ms)')
##        plt.ylabel('Meters')
##        plt.grid(True)
##        plt.legend()
##
##        plt.subplot(339)
##        #plt.plot(timePlot,stateEstimateZ, label='State Estimate Z')
##        plt.plot(timePlot,kalmanZ, label='Kalman State Estimate Z')
##        for xc in chunksT:
##            plt.axvline(x=xc,color='r')
##        #plt.title('State Estimate Z')
##        plt.ylim(-1,1)
##        plt.xlabel('Time (ms)')
##        plt.ylabel('Meters')
##        plt.grid(True)
##        plt.legend()
                               
##        plt.show()

