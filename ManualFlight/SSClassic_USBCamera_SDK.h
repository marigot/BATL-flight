// The following ifdef block is the standard way of creating macros which make exporting 
// from a DLL simpler. All files within this DLL are compiled with the MTUSBDLL_EXPORTS
// symbol defined on the command line. this symbol should not be defined on any project
// that uses this DLL. This way any other project whose source files include this file see 
// MTUSBDLL_API functions as being imported from a DLL, wheras this DLL sees symbols
// defined with this macro as being exported.
typedef int SDK_RETURN_CODE;
typedef unsigned int DEV_HANDLE;

#ifdef SDK_EXPORTS
#define SDK_API extern "C" __declspec(dllexport) SDK_RETURN_CODE _cdecl
#define SDK_HANDLE_API extern "C" __declspec(dllexport) DEV_HANDLE _cdecl
#define SDK_POINTER_API extern "C" __declspec(dllexport) unsigned char * _cdecl
#define SDK_POINTER_API2 extern "C" __declspec(dllexport) unsigned short * _cdecl
#define SDK_POINTER_API3 extern "C" __declspec(dllexport) unsigned long * _cdecl
#else
#define SDK_API extern "C" __declspec(dllimport) SDK_RETURN_CODE _cdecl
#define SDK_HANDLE_API extern "C" __declspec(dllimport) DEV_HANDLE _cdecl
#define SDK_POINTER_API extern "C" __declspec(dllimport) unsigned char * _cdecl
#define SDK_POINTER_API2 extern "C" __declspec(dllimport) unsigned short * _cdecl
#define SDK_POINTER_API3 extern "C" __declspec(dllimport) unsigned long * _cdecl
#endif

#define GRAB_FRAME_FOREVER	0x8888


typedef struct {
    int CameraID;
    int WorkMode;	 // 0 - NORMAL mode, 1 - TRIGGER mode
    int SensorClock; // 24, 48, 96 for 24MHz, 48MHz and 96MHz
    int Row;	// It's ColSize, in 1280x1024, it's 1024
    int Column;	// It's RowSize, in 1280x1024, it's 1280
    int Bin;	// 0, 1, 2 for no-decimation, 1:2 and 1:4 decimation
    int BinMode;// 0 - Skip, 1 - Bin
    int CameraBit; // 8 or 16.
    int XStart;
    int YStart;
    int ExposureTime; // in 50us unit, e.g. 100 means 5000us(5ms)
    int RedGain;
    int GreenGain;
    int BlueGain;
    int TimeStamp; // in 1ms unit, 0 - 0xFFFFFFFF and round back
    int SensorMode;// Bit0 is used for GRR mode, Bit1 is used for Strobe out enable
    int TriggerOccurred; // Used for NORMAL mode only, set when the external trigger occurred during the grabbing of last frame.
    int TriggerEventCount; // Reserved.
    int FrameSequenceNo; // Reserved.
    int IsFrameBad; // Is the current frame a bad one.

    int FrameProcessType; // 0 - RAW, 1 - BMP
    int FilterAcceptForFile; // Reserved
} TProcessedDataProperty;

 typedef struct {
    int FrameTotalRows;   // including V_Blanking Rows
    int VBlankingRows;    // Actual VBlanking rows (expanded if ET is longer)
    int VBlankingRowsInTriggerMode; // The rows set in VBlanking register.
    int RowClocks;        // including H_Blanking clocks
    int HBlankingClocks;  // setting in HBlanking register
    int ExposureTimeRows; // setting in ET registers
    int RowTimeinUs;      // including H_Blanking
    int FrameReadingTimeInUs;   // V_Blanking is not included, F_Valid time
    int VBlankingTimeInUs;      // Actual VBlanking time in "us"
    int VBlankingTimeInUsInTriggerMode; // VBlanking(in reg) time in "us"
    int DMABufferPreFetchWaitTimeInUs;  // Prefetching threshold in "us"
} TFrameParameter;


typedef void (* DeviceFaultCallBack)( int DeviceID, int DeviceType );
typedef void (* FrameDataCallBack)( TProcessedDataProperty* Attributes, unsigned char *BytePtr );

// Import functions:
SDK_API SSClassicUSB_InitDevice( void );
SDK_API SSClassicUSB_UnInitDevice( void );
SDK_API SSClassicUSB_GetModuleNoSerialNo( int DeviceID, char *ModuleNo, char *SerialNo);
SDK_API SSClassicUSB_AddDeviceToWorkingSet( int DeviceID );
SDK_API SSClassicUSB_RemoveDeviceFromWorkingSet( int DeviceID );
SDK_API SSClassicUSB_StartCameraEngine( HWND ParentHandle, int CameraBitOption, int ProcessThreads, int IsCallBackInThread );
SDK_API SSClassicUSB_StopCameraEngine( void );
SDK_API SSClassicUSB_SetUSBConnectMonitor( int DeviceID, int MonitorOn );
SDK_API SSClassicUSB_SetUSB30TransferSize( int TransferSizeLevel );
SDK_API SSClassicUSB_GetCameraFirmwareVersion( int DeviceID );
SDK_API SSClassicUSB_StartFrameGrab( int DeviceID, int TotalFrames );
SDK_API SSClassicUSB_StopFrameGrab( int DeviceID );
SDK_API SSClassicUSB_ShowFactoryControlPanel( int DeviceID, char *passWord );
SDK_API SSClassicUSB_HideFactoryControlPanel( void );
SDK_API SSClassicUSB_SetBayerFilterType( int DeviceID, int FilterType );
SDK_API SSClassicUSB_SetCameraWorkMode( int DeviceID, int WorkMode );
SDK_API SSClassicUSB_SetCustomizedResolution( int deviceID, int RowSize, int ColSize, int Bin, int BinMode );
SDK_API SSClassicUSB_SetExposureTime( int DeviceID, int exposureTime );
SDK_API SSClassicUSB_SetXYStart( int DeviceID, int XStart, int YStart );
SDK_API SSClassicUSB_SetGains( int DeviceID, int RedGain, int GreenGain, int BlueGain );
SDK_API SSClassicUSB_SetColumnGain( int DeviceID, int ColumnGain );
SDK_API SSClassicUSB_SetGainRatios( int DeviceID, int RedGainRatio, int BlueGainRatio);
SDK_API SSClassicUSB_SetGamma( int DeviceID, int Gamma, int Contrast, int Bright, int Sharp );
SDK_API SSClassicUSB_SetBWMode( int DeviceID, int BWMode, int H_Mirror, int V_Flip );
SDK_API SSClassicUSB_SetMinimumFrameDelay( int IsMinimumFrameDelay ); 
SDK_API SSClassicUSB_SoftTrigger( int DeviceID );
SDK_API SSClassicUSB_SetSensorFrequency( int DeviceID, int Frequency );
SDK_API SSClassicUSB_SetSensorBlankings( int DeviceID, int HBlanking, int VBlanking );
SDK_API SSClassicUSB_SetSensorMode( int DeviceID, int SensorMode );
SDK_API SSClassicUSB_SetTriggerBurstCount( int DeviceID, int BurstCount );
SDK_API SSClassicUSB_ResetTimeStamp( int DeviceID );
SDK_API SSClassicUSB_InstallFrameHooker( int FrameType, FrameDataCallBack FrameHooker );
SDK_API SSClassicUSB_InstallUSBDeviceHooker( DeviceFaultCallBack USBDeviceHooker );
SDK_POINTER_API SSClassicUSB_GetCurrentFrame( int FrameType, int DeviceID, unsigned char* &FramePtr );
SDK_POINTER_API2 SSClassicUSB_GetCurrentFrame16bit( int FrameType, int DeviceID, unsigned short* &FramePtr );
SDK_POINTER_API3 SSClassicUSB_GetCurrentFramePara( int DeviceID, unsigned long* &FrameParaPtr );
SDK_API SSClassicUSB_GetDevicesErrorState();
SDK_API SSClassicUSB_IsUSBSuperSpeed( int DeviceID );
SDK_API SSClassicUSB_SetGPIOConfig( int DeviceID, unsigned char ConfigByte );
SDK_API SSClassicUSB_SetGPIOOut( int DeviceID, unsigned char OutputByte );
SDK_API SSClassicUSB_SetGPIOInOut( int DeviceID, unsigned char OutputByte, unsigned char *InputBytePtr );


