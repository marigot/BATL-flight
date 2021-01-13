#ifndef ExtraPuTTY_Header
#define ExtraPuTTY_Header

#ifdef DLL_Ex_EXPORT
  #define DECLDIR __declspec(dllexport) __stdcall
#else
  #define DECLDIR __declspec(dllimport) __stdcall
#endif

extern "C"
{
  int DECLDIR Connexion(char *TargetName,unsigned long *ConnexionId,char *Login,char *Password,bool ShowPuTTY,long Protocol,unsigned long PortNumber,long GenerateReport,void *ptrFctRcv,unsigned long SpecSettings);
  int DECLDIR SendRcvData(unsigned long ConnexionId,char *Command,char *Title,char *Comments,long TimeCapture,char **RcvTelnetData,long MaxSizeofData,unsigned long settings);
  int DECLDIR SendRcvData_O(unsigned long ConnexionId,char *Command,char *Title,char *Comments,long TimeCapture,char *RcvTelnetData,long MaxSizeofData,unsigned long settings);
  int DECLDIR lua_dofile(unsigned long ConnexionId,char *PathFile,char *Title,char *Comments);
  int DECLDIR WaitingMessage(unsigned long ConnexionId,char *Message,char *Title,char *Comments,unsigned long TimeCapture);
  int DECLDIR WaitReConnect(unsigned long ConnexionId,long TimeOut);
  int DECLDIR ForceToClose(unsigned long ConnexionId);
  int DECLDIR CloseConnexion(unsigned long ConnexionId);
  int DECLDIR CloseAllConnexion();
  int DECLDIR FtpLoader(char *TargetName,char *FilePath,char *DestPath,bool ShowEPUTTY,char *User,char *Pass,unsigned long TransfertMode,bool verbose);
  int DECLDIR RetrieveExistingConnection(unsigned char ConnectionHandle);

  void DECLDIR SendRcvData_F(unsigned long ConnexionId,char *Command,char *Title,char *Comments,long TimeCapture,char RcvTelnetData[],long MaxSizeofData,unsigned long settings,bool &result, char reportText[1024],
                             bool &errorOccurred, long &errorCode, char errorMsg[1024]);
  void DECLDIR WaitingMessage_F(unsigned long ConnexionId,char *Command,char *Title,char *Comments,unsigned long TimeCapture,bool &result, char reportText[1024],
                                bool &errorOccurred, long &errorCode, char errorMsg[1024]);
  void DECLDIR lua_dofile_F(unsigned long ConnexionId,char *PathFile,char *Title,char *Comments,bool &result, char reportText[1024],
                            bool &errorOccurred, long &errorCode, char errorMsg[1024]);
  void DECLDIR WaitReConnect_F(unsigned long ConnexionId,long TimeOut,bool &result, char reportText[1024],
                               bool &errorOccurred, long &errorCode, char errorMsg[1024]);
  void DECLDIR ForceToClose_F(unsigned long ConnexionId,bool &result, char reportText[1024],
                              bool &errorOccurred, long &errorCode, char errorMsg[1024]);
  void DECLDIR CloseConnexion_F(unsigned long ConnexionId,bool &result, char reportText[1024],
                                bool &errorOccurred, long &errorCode, char errorMsg[1024]);
  void DECLDIR CloseAllConnexion_F(bool &result, char reportText[1024],
                                   bool &errorOccurred, long &errorCode, char errorMsg[1024]);
  void DECLDIR FtpLoader_F(char *TargetName,char *FilePath,char *DestPath,bool ShowEPUTTY,char *User,char *Pass,unsigned long TransfertMode,bool verbose, bool &result, char reportText[1024],
                           bool &errorOccurred, long &errorCode, char errorMsg[1024]);
  void DECLDIR Connexion_F(char *TargetName,unsigned long *ConnexionId,char *Login,char *Password,bool ShowPuTTY,long Protocol,unsigned long PortNumber,long GenerateReport,long  TypeCRLF,char *NewCRLF,char *ReportFileData,unsigned long SpecSettings, bool &result, char reportText[1024],
                           bool &errorOccurred, long &errorCode, char errorMsg[1024]);
  void DECLDIR RetrieveExistingConnection_F(unsigned char ConnectionHandle,bool &result, char reportText[1024],
                                            bool &errorOccurred, long &errorCode, char errorMsg[1024]);
														  
}
#endif