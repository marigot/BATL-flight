#include <Stepper.h>
#include <Servo.h>

/////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////




// **********************************************************
// ***** GLOBAL VARIABLES ***********************************
// **********************************************************


// ALL //////////////////////////////

unsigned long int VLC = 0; // void loop count

int ledPin = 13;




// VOLTAGE //////////////////////////

int voltIn = A1;  // FSR0

double volts = 0;




// CURRENT //////////////////////////

// sensor: ACS712

const int currIn = A0;
int mVperAmp = 185; // use 100 for 20A Module and 66 for 30A Module

double vpp = 0;
double VRMS = 0;
double ampsRMS = 0;



// POWER ////////////////////////////

double watts = 0;



// **********************************************************
// ***** SETUP **********************************************
// **********************************************************


void setup(){ 
  
 Serial.begin(28800);

 pinMode(ledPin, OUTPUT);
 pinMode(currIn, INPUT);
 pinMode(voltIn, INPUT);         // set pin to input
 

 
}





// **********************************************************
// ***** LOOP ***********************************************
// **********************************************************


void loop(){

 VLC++;  // always increment VLC

 // get current
 vpp = getVPP();
 VRMS = (vpp/2.0) *0.707;  //root 2 is 0.707
 ampsRMS = (VRMS * 1000)/mVperAmp;


 // get voltage
 volts = abs(analogRead(voltIn));


 // get power
 watts = ampsRMS*volts;
 
 
 // PRINT 
 Serial.print(VLC);  Serial.print(", "); 
 Serial.print(volts);  Serial.print(", "); 
 Serial.print(ampsRMS);  Serial.print(", "); 
 Serial.print(watts);  Serial.println("");



 
}





// **********************************************************
// ***** FLOATS *********************************************
// **********************************************************


float getVPP()
{
  float result;
  int readValue;             //value read from the sensor
  int maxValue = 0;          // store max value here
  int minValue = 1024;          // store min value here
  
   uint32_t start_time = millis();
   while((millis()-start_time) < 10) // sampling period (1x per 10ms)
   {
       readValue = analogRead(currIn);
       // see if you have a new maxValue
       if (readValue > maxValue) 
       {
           /*record the maximum sensor value*/
           maxValue = readValue;
       }
       if (readValue < minValue) 
       {
           /*record the minimum sensor value*/
           minValue = readValue;
       }
   }
   
   // Subtract min from max
   result = ((maxValue - minValue) * 5.0)/1024.0;
      
   return result;
 }
