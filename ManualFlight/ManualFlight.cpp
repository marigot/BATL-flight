// == NECESSARY INCLUDES ==
#include "stdafx.h"
#include <windows.h>
#include <iostream>
#include <assert.h>
#include <conio.h>
#include <stddef.h>
#include <sstream>
#define _USE_MATH_DEFINES
#include <cmath>
#include <vector>
#include <numeric>
#include <fstream>
#include <chrono>  // timekeeping
#include <ctime>

// OpenCV files
//#include "opencv2/opencv.hpp"
//#include <opencv2/core/core.hpp>
//#include <opencv2/highgui/highgui.hpp>
//#include <opencv2/imgproc/imgproc.hpp>


// == ARDUINO COMMUNICATION ==
#using < System.dll > // needed for IO::Ports (connection to Arduino)

using namespace System;
using namespace System::IO::Ports;
using System::String;


// == ADDITIONAL NAMESPACE ==
using namespace std; // C++
//using namespace cv; // OpenCV
typedef std::chrono::high_resolution_clock Clock; // timekeeping
ofstream currentData;

// == CONVERT SYSTEM STRINGS TO STD STRINGS == 
void MarshalString(System::String^ s, string& os) {
	using namespace Runtime::InteropServices;
	const char* chars =
		(const char*)(Marshal::StringToHGlobalAnsi(s)).ToPointer();
	os = chars;
	Marshal::FreeHGlobal(IntPtr((void*)chars));
}

void MarshalString(System::String^ s, wstring& os) {
	using namespace Runtime::InteropServices;
	const wchar_t* chars =
		(const wchar_t*)(Marshal::StringToHGlobalUni(s)).ToPointer();
	os = chars;
	Marshal::FreeHGlobal(IntPtr((void*)chars));
}

// == INITIALIZE DRONE + ARDUINO COMMUNICATION ==
public ref class CurrentObject // .NET C# used for Common Language Support does not support global variables, so static class is used
{
public:
	// Used to create Serial Port connection
	static System::String^ ComName = "COM8"; // check under Control panel, since this has changed unexpectedly
	static int baudRate = 9600; // connection rate, from Arduino code 
	static SerialPort^ arduino2 = gcnew SerialPort(ComName, baudRate); // sets up connection to arduion

	// Used to hold responses from Arduino
	static System::String^ data2;

};

int main()
{
	try
	{
		// INITIALIZE CURRENT SENSOR AND ARDUINO
		Console::WriteLine("[PC]: Initializing Current Sensor...");
		currentData.open("CurrentData.csv");
		if (!currentData.is_open())
		{
			throw 5;
		}

		//OPEN CONNECTION TO ARDUINO AND BIND DRONE
		CurrentObject::arduino2->Open();
		Sleep(100); // Allow connection to settle 

		if (!CurrentObject::arduino2->IsOpen) // check to ensure that connection worked
		{
			throw 1;
		}

		// START COLLECTING CURRENT DATA
		CurrentObject::arduino2->WriteLine("C \n");
		Console::WriteLine("[PC]: Collecting Data");
		Console::WriteLine("[PC]: Reset Arduino to Stop");

		int quit = 0;
		MSG msg;
		while (!quit)
		{

			// WRITE CURRENT TO CSV FILE
			string current; // holds data read from Arduino
			CurrentObject::data2 = CurrentObject::arduino2->ReadLine();
			MarshalString(CurrentObject::data2, current);
			currentData << current;
		}

	}
	catch (TimeoutException^)
	{
		Console::WriteLine("Timeout");
	}
	catch (System::IO::IOException^)
	{
		Console::WriteLine("Arduino not connected");
		cout << "\nExecution terminated" << endl;
		Sleep(5);
		return 0;
	}

	finally // Resets the arduino connection. From Python code, not sure if this is actually necessary
	{
		CurrentObject::arduino2->Close();
		CurrentObject::arduino2->Open();
		CurrentObject::arduino2->Close();
		cout << "\nExecution terminated" << endl;
	}
	return 0;

}