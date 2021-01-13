// SampleConnexionDlg.cpp : implementation file
//

#include "stdafx.h"
#include "SampleConnexion.h"
#include "SampleConnexionDlg.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

//Global Variable
CSampleConnexionDlg *pDlg;
char Buffer[1000000] = "";
char TargetName[100] = "";
unsigned long ConnexionId = 0;
//Prototypage of all light extraputty functions
typedef int (*Function_extraputty_Connexion) (char *,unsigned long *,char *,char *,unsigned char,unsigned long,unsigned long,unsigned long,void*,unsigned long);
typedef int (*Function_extraputty_SendRcvCmd) (unsigned long,char *,char *,char *,long,char **,long,unsigned long);
typedef int (*Function_extraputty_WaitingMessage) (unsigned long,char *,char *,char *,long);
typedef int (*Function_extraputty_LoadLuaFile) (unsigned long,char *,char *,char *);
typedef int (*Function_extraputty_UploadFile) (unsigned long,int,char *,char *,char *);
typedef int (*Function_extraputty_WaitReConnect) (unsigned long,long);
typedef int (*Function_extraputty_RetrieveConnection) (unsigned char);
typedef int (*Function_extraputty_PuTTYsettings) (unsigned long ,char *,char *,char *,char *);
typedef int (*Function_extraputty_DoReconfig) (unsigned long,char *,char *);
typedef int (*Function_extraputty_ForceToClose) (unsigned long);
typedef int (*Function_extraputty_CloseAll) ();
typedef int (*Function_extraputty_Close) (unsigned long);

Function_extraputty_Connexion Connexion;
Function_extraputty_SendRcvCmd SendRcvCmd;
Function_extraputty_WaitingMessage WaitingMessage;
Function_extraputty_LoadLuaFile  LoadLuaFile;
Function_extraputty_UploadFile  UploadFile;
Function_extraputty_PuTTYsettings PuttySettings;
Function_extraputty_DoReconfig DoReconfig;
Function_extraputty_WaitReConnect WaitReConnect;
Function_extraputty_CloseAll CloseAll;
Function_extraputty_Close CloseConnexion;
Function_extraputty_RetrieveConnection RetrieveConnection;
Function_extraputty_ForceToClose ForceToClose;


/////////////////////////////////////////////////////////////////////////////
// CAboutDlg dialog used for App About

class CAboutDlg : public CDialog
{
public:
	CAboutDlg();

// Dialog Data
	//{{AFX_DATA(CAboutDlg)
	enum { IDD = IDD_ABOUTBOX };
	//}}AFX_DATA

	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CAboutDlg)
	protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support
	//}}AFX_VIRTUAL

// Implementation
protected:
	//{{AFX_MSG(CAboutDlg)
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};

CAboutDlg::CAboutDlg() : CDialog(CAboutDlg::IDD)
{
	//{{AFX_DATA_INIT(CAboutDlg)
	//}}AFX_DATA_INIT
}

void CAboutDlg::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	//{{AFX_DATA_MAP(CAboutDlg)
	//}}AFX_DATA_MAP
}

BEGIN_MESSAGE_MAP(CAboutDlg, CDialog)
	//{{AFX_MSG_MAP(CAboutDlg)
		// No message handlers
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CSampleConnexionDlg dialog

CSampleConnexionDlg::CSampleConnexionDlg(CWnd* pParent /*=NULL*/)
	: CDialog(CSampleConnexionDlg::IDD, pParent)
{	
	//{{AFX_DATA_INIT(CSampleConnexionDlg)
	//}}AFX_DATA_INIT
	// Note that LoadIcon does not require a subsequent DestroyIcon in Win32
	m_hIcon = AfxGetApp()->LoadIcon(IDR_MAINFRAME);
}

void CSampleConnexionDlg::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	//{{AFX_DATA_MAP(CSampleConnexionDlg)
	DDX_Control(pDX, IDC_Ymodem_up, m_ymodemup);
	DDX_Control(pDX, IDC_LUA, m_lua);
	DDX_Control(pDX, IDC_WAITRESTART, m_waitrestart);
	DDX_Control(pDX, IDC_SHOWPUTTY, m_displayputty);
	DDX_Control(pDX, IDC_RCVDATA, m_datatimewindow);
	DDX_Control(pDX, IDC_BUTTON1, m_sendbutton);
	DDX_Control(pDX, IDC_SEND, m_sendcmd);
	DDX_Control(pDX, IDC_LOGIN1, m_login);
	DDX_Control(pDX, IDC_PASSWORD, m_password);
	DDX_Control(pDX, IDC_PORT, m_port);
	DDX_Control(pDX, IDC_TARGET, m_target);
	DDX_Control(pDX, IDC_RECEIVED, m_rcvEdit);
	DDX_Control(pDX, IDC_WAITING, m_wait);
	DDX_Control(pDX, IDC_LISTPROTOCOL, m_liste);
	DDX_Control(pDX, IDC_CMD, m_cmd);
	DDX_Control(pDX, IDC_CLOSE, m_close);
	DDX_Control(pDX, IDC_SENDCMD, m_send);
	DDX_Control(pDX, IDC_CONNEXION, m_connexion);
	//}}AFX_DATA_MAP
}

BEGIN_MESSAGE_MAP(CSampleConnexionDlg, CDialog)
	//{{AFX_MSG_MAP(CSampleConnexionDlg)
	ON_WM_SYSCOMMAND()
	ON_WM_PAINT()
	ON_WM_QUERYDRAGICON()
	ON_BN_CLICKED(IDC_CONNEXION, OnConnexion)
	ON_BN_CLICKED(IDC_SENDCMD, OnSendcmd)
	ON_BN_CLICKED(IDC_CLOSE, OnClose)	
	ON_BN_CLICKED(IDC_WAITING, OnWaiting)
	ON_BN_CLICKED(IDC_BUTTON1, OnSendToTarget)
	ON_BN_CLICKED(IDC_WAITRESTART, OnWaitrestart)
	ON_CBN_SELCHANGE(IDC_LISTPROTOCOL, OnSelchangeListprotocol)
	ON_BN_CLICKED(IDC_LUA, OnLua)
	ON_BN_CLICKED(IDC_KeepAliveServer, OnKeepAliveServer)
	ON_BN_CLICKED(IDC_ForceToClose, OnForceToClose)
	ON_BN_CLICKED(IDC_Ymodem_up, OnYmodemup)
	ON_BN_CLICKED(IDC_BUTTON2, OnPuTTYsettings)
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CSampleConnexionDlg message handlers

BOOL CSampleConnexionDlg::OnInitDialog()
{
	CDialog::OnInitDialog();

	// Add "About..." menu item to system menu.
	// IDM_ABOUTBOX must be in the system command range.
	ASSERT((IDM_ABOUTBOX & 0xFFF0) == IDM_ABOUTBOX);
	ASSERT(IDM_ABOUTBOX < 0xF000);

	CMenu* pSysMenu = GetSystemMenu(FALSE);
	if (pSysMenu != NULL)
	{
		CString strAboutMenu;
		strAboutMenu.LoadString(IDS_ABOUTBOX);
		if (!strAboutMenu.IsEmpty())
		{
			pSysMenu->AppendMenu(MF_SEPARATOR);
			pSysMenu->AppendMenu(MF_STRING, IDM_ABOUTBOX, strAboutMenu);
		}
	}

	// Set the icon for this dialog.  The framework does this automatically
	//  when the application's main window is not a dialog
	SetIcon(m_hIcon, 1);			// Set big icon
	SetIcon(m_hIcon, FALSE);		// Set small icon
	
	// TODO: Add extra initialization here
	
	//Load ExtraPuTTY DLL
    HMODULE hDLL = LoadLibrary("ExtraPuTTY.dll");
	if(!hDLL)	//if load failed
	{
		//Display error message
		MessageBox("Impossible to load DLL...", "Erreur", MB_ICONERROR);
		CDialog::OnOK();
	}
	else
	{
       //Link on all functions
       Connexion      = (Function_extraputty_Connexion) GetProcAddress(hDLL, "Connexion");
       SendRcvCmd     = (Function_extraputty_SendRcvCmd) GetProcAddress(hDLL, "SendRcvData");
	   WaitingMessage = (Function_extraputty_WaitingMessage) GetProcAddress(hDLL, "WaitingMessage");
	   LoadLuaFile    = (Function_extraputty_LoadLuaFile) GetProcAddress(hDLL, "lua_dofile");	  
	   UploadFile     = (Function_extraputty_UploadFile) GetProcAddress(hDLL, "UploadFiles");
	   PuttySettings  = (Function_extraputty_PuTTYsettings) GetProcAddress(hDLL, "PuTTYSettings");
	   DoReconfig     = (Function_extraputty_DoReconfig) GetProcAddress(hDLL, "DoReconfig");
	   WaitReConnect  = (Function_extraputty_WaitReConnect) GetProcAddress(hDLL, "WaitReConnect");
       CloseAll       = (Function_extraputty_CloseAll) GetProcAddress(hDLL, "CloseAllConnexion");
       CloseConnexion = (Function_extraputty_Close) GetProcAddress(hDLL, "CloseConnexion");
	   RetrieveConnection = (Function_extraputty_RetrieveConnection)GetProcAddress(hDLL, "RetrieveExistingConnection");
	   ForceToClose   = (Function_extraputty_ForceToClose)GetProcAddress(hDLL, "ForceToClose");
	   //Add target in combobox
	   m_liste.AddString("Telnet");	   
	   m_liste.AddString("SSH");
	   m_liste.AddString("RLogin");
	   m_liste.AddString("Raw");
	   m_liste.AddString("Load Putty Session");	   	   	   
	   m_liste.AddString("Serial Link");
	   m_liste.AddString("Cygterm");
	   //Select the first Target
	   m_liste.SetCurSel(0);
	   //by default display putty terminal
	   m_displayputty.SetCheck(BST_CHECKED);
	}
    pDlg = STATIC_DOWNCAST(CSampleConnexionDlg,AfxGetMainWnd());	
	return 1;  // return 1  unless you set the focus to a control
}

void CSampleConnexionDlg::OnSysCommand(UINT nID, LPARAM lParam)
{
	if ((nID & 0xFFF0) == IDM_ABOUTBOX)
	{
		CAboutDlg dlgAbout;
		dlgAbout.DoModal();
	}
	else
	{
		CDialog::OnSysCommand(nID, lParam);
	}
}

// If you add a minimize button to your dialog, you will need the code below
//  to draw the icon.  For MFC applications using the document/view model,
//  this is automatically done for you by the framework.

void CSampleConnexionDlg::OnPaint() 
{
	if (IsIconic())
	{
		CPaintDC dc(this); // device context for painting

		SendMessage(WM_ICONERASEBKGND, (WPARAM) dc.GetSafeHdc(), 0);

		// Center icon in client rectangle
		int cxIcon = GetSystemMetrics(SM_CXICON);
		int cyIcon = GetSystemMetrics(SM_CYICON);
		CRect rect;
		GetClientRect(&rect);
		int x = (rect.Width() - cxIcon + 1) / 2;
		int y = (rect.Height() - cyIcon + 1) / 2;

		// Draw the icon
		dc.DrawIcon(x, y, m_hIcon);
	}
	else
	{
		CDialog::OnPaint();
	}
}

// The system calls this to obtain the cursor to display while the user drags
//  the minimized window.
HCURSOR CSampleConnexionDlg::OnQueryDragIcon()
{
	return (HCURSOR) m_hIcon;
}


int RcvData(unsigned long Id,char *buf, int size,int status)
{	
	char buff[100000] = "";
	int start,end;

	if((buf != NULL) && (status == 0))
	{
	  memcpy(&buff,buf,size);
	  strcat(Buffer,buff);
	  pDlg->SetDlgItemText(IDC_RECEIVED,Buffer);
      pDlg->m_rcvEdit.GetSel(start,end);
	  pDlg->m_rcvEdit.SetSel (end-2,end-1);	  
	}
	else if(status != 0)
	{
      MessageBox(NULL,"Connection remote by host","Error",MB_OK);
	}

	return 0;
}


//The function "Connexion" is used to made an connexion to target via 
//Telnet or SSH protocol in this example
//But you can change to made n connexion with Rlogin or Raw protocol
//Prototypage of the extraputty fonction 
//int Connexion(char *TargetName,     => TargetName or PuttySession Name (in this case Protocol must be equalt to 4)
//              char *Login,          => Login    (optinonal parameter)
//              char *Password,       => Password (optinonal parameter) 
//              bool ShowPuTTY,       => 1: Putty Terminal is display, FALSE: not display
//              long Protocol,        => 0:Telnet,1:SSH,2:Rlogin,3:Raw,4:LoadPutty Session
//              long GenerateReport   => 1:extraputty report activate,0:Not activate
//             );
//For more details of this function go to http://www.extraputty.com/htmldoc/Chapter6.html#LCONECT
void CSampleConnexionDlg::OnConnexion() 
{
	// TODO: Add your control notification handler code here		
	int inc = 0;
	int res = 0;
	char Error[100] = "";
	unsigned long portnumber = 0;	
	int resultFct = 0;
	char login[100] = "\0";
	char password[100] = "\0";
	long protocol = 0;
	int returnfct = 0;
 	bool displayPutty = true;
	
	SetDlgItemText(IDC_RECEIVED,"");
	
	//Get protocol
	protocol = m_liste.GetCurSel();	

	//Get targetname
    GetDlgItemText(IDC_TARGET,TargetName,100);

	//Get login
    GetDlgItemText(IDC_LOGIN1,login,100);

	//Get password
    GetDlgItemText(IDC_PASSWORD,password,100);

	//Get port number
	portnumber = GetDlgItemInt(IDC_PORT,&resultFct,false);
	if(resultFct == 0)
	{
		portnumber = 0;
	}

	//Display putty terminal
	returnfct = m_displayputty.GetCheck();
	displayPutty = (returnfct != 0);
	
	//connexion
	res = Connexion(TargetName,&ConnexionId,login,password,displayPutty,protocol,portnumber,0,RcvData,0);
	if(res == 0)
	{
	   m_connexion.EnableWindow(FALSE);
	   m_liste.EnableWindow(FALSE);
	   m_send.EnableWindow(1);
	   m_wait.EnableWindow(1);
	   m_close.EnableWindow(1);
	   m_cmd.EnableWindow(1);
	   m_waitrestart.EnableWindow(1);
	   m_lua.EnableWindow(1);
	   m_ymodemup.EnableWindow(1);
	   m_target.EnableWindow(FALSE);
	   m_port.EnableWindow(FALSE);
	   m_login.EnableWindow(FALSE);
	   m_password.EnableWindow(FALSE);
	   m_rcvEdit.EnableWindow(1);
	   m_sendcmd.EnableWindow(1);
	   m_sendbutton.EnableWindow(1);
	   m_datatimewindow.EnableWindow(1);
	}
	else
	{
		sprintf(Error,"Connection Error : %d",res);
		MessageBox(Error,"ERROR",MB_OK);
	}
}

//The function "SendRcvData" is used to Send and received data  
//If you don't want to received the reply of your command set the parameter TimeCapture to 0
//But you can change to made n connexion with Rlogin or Raw protocol
//Prototypage of the extraputty fonction 
//int SendRcvData(char *TargetName,   => The same TargetName or PuttySession Name used with connexion function
//                char *Command,      => Data to send
//                char *Title,        => Title of your command,used only if extraputty report is activate
//                char *Comments,     => Comments of your command,used only if extraputty report is activate
//                long TimeCapture,   => Time to capture the reply data in ms
//                char *RcvTelnetData => Buffer which contain your data if TimerCapture is > 0
//                );
//For more details of this function go to http://www.extraputty.com/htmldoc/Chapter6.html#LSEND
void CSampleConnexionDlg::OnSendcmd() 
{	
	// TODO: Add your control notification handler code here
	char *RcvTelnetData= NULL;
	char Cmd[1000] = "\0";
	int Size = 0;

    RcvTelnetData =(char*) malloc(sizeof(char)*1000000);
    if(RcvTelnetData == NULL)
	{
       SetDlgItemText(IDC_RCVDATA,"Memory allocation problem");
       return;
	}
	Size = sizeof(char)*1000000;
	GetDlgItemText(IDC_CMD,Cmd,1000);

	if(SendRcvCmd(ConnexionId,Cmd,"","",5000,&RcvTelnetData,Size,2) == 0)
	{
		if(strlen(RcvTelnetData) == 0)
		{
		  SetDlgItemText(IDC_RCVDATA,"NO DATA RECEIVED !");
		}
		else
		{
          SetDlgItemText(IDC_RCVDATA,RcvTelnetData);
		}
	}
	else
	{
        SetDlgItemText(IDC_RCVDATA,"ERROR");
	}
}

//This function is used to close all connexion which is made with the same load of DLL  
//Prototypage of the extraputty fonction 
//int CloseConnexion(char *TargetName  => The same TargetName or PuttySession Name used with connexion function
//                  );
//For more details of this function go to http://www.extraputty.com/htmldoc/Chapter6.html#LCLOSE

void CSampleConnexionDlg::OnClose() 
{
	char Cmd[1000] = "\0";
	int ret = 0;
	// TODO: Add your control notification handler code here
	m_connexion.EnableWindow(1);
	m_liste.EnableWindow(1);
	m_send.EnableWindow(FALSE);
	m_wait.EnableWindow(FALSE);
	m_close.EnableWindow(FALSE);
	m_cmd.EnableWindow(FALSE);
	m_waitrestart.EnableWindow(FALSE);
	m_lua.EnableWindow(FALSE);
	m_ymodemup.EnableWindow(FALSE);
	m_target.EnableWindow(1);
	m_port.EnableWindow(1);
	m_login.EnableWindow(1);
	m_password.EnableWindow(1);
	m_rcvEdit.EnableWindow(FALSE);
	m_sendcmd.EnableWindow(FALSE);
	m_sendbutton.EnableWindow(FALSE);
	m_datatimewindow.EnableWindow(FALSE);

	//Close connexion
	ret = CloseConnexion(ConnexionId);
	if(ret ==0)	
	{		
		SetDlgItemText(IDC_RCVDATA,"Sucess to close connection");
	}
	else
	{
		sprintf(Cmd,"Error to close connection : %d",ret);
        SetDlgItemText(IDC_RCVDATA,Cmd);
	}
}

void CSampleConnexionDlg::OnWaiting() 
{
	// TODO: Add your control notification handler code here
	char Cmd[1000] = "\0";

    GetDlgItemText(IDC_CMD,Cmd,1000);
	if(strlen(Cmd) == 0)
	{
       SetDlgItemText(IDC_RCVDATA,"Message is not set");
       return;
	}
	
	if(WaitingMessage(ConnexionId,Cmd,"","",1000) == 0)
	{
		SetDlgItemText(IDC_RCVDATA,"Message received on terminal");
	}		
	else
	{
        SetDlgItemText(IDC_RCVDATA,"ERROR");
	}
}

void CSampleConnexionDlg::OnSendToTarget() 
{
	// TODO: Add your control notification handler code here
	char Cmd[1000] = "";
	char *RcvTelnetData= NULL;

	GetDlgItemText(IDC_SEND,Cmd,1000);
	if(strlen(Cmd)==0)
		MessageBox("Command not set","Error",MB_OK);

	if(SendRcvCmd(ConnexionId,Cmd,"","",0,&RcvTelnetData,0,2) != 0)
	{
		MessageBox("Failed to send command to target","Error",MB_OK);
	}
	SetDlgItemText(IDC_SEND,"");
}

void CSampleConnexionDlg::OnWaitrestart() 
{
	// TODO: Add your control notification handler code here
	
	if(WaitReConnect(ConnexionId,60000) == 0)
	{
		SetDlgItemText(IDC_RCVDATA,"Connection established");
	}		
	else
	{
        SetDlgItemText(IDC_RCVDATA,"ERROR");
	}	
}

void CSampleConnexionDlg::OnSelchangeListprotocol() 
{
	// TODO: Add your control notification handler code here
	long protocol = 0;

	protocol = m_liste.GetCurSel();
	if(protocol == 6)
	{
	   m_port.EnableWindow(FALSE);
	   m_login.EnableWindow(FALSE);
	   m_password.EnableWindow(FALSE);
	   SetDlgItemText(IDC_STATIC_T,"     Command :");
	   SetDlgItemText(IDC_TARGET,"-");

	}
	else if(protocol == 4)
	{
	   m_port.EnableWindow(TRUE);
	   m_login.EnableWindow(TRUE);
	   m_password.EnableWindow(TRUE);
	   SetDlgItemText(IDC_STATIC_T,"Session Name:");
	   SetDlgItemText(IDC_STATIC_P,"     Port :");
	}	
	else
	{
	   m_port.EnableWindow(TRUE);
	   m_login.EnableWindow(TRUE);
	   m_password.EnableWindow(TRUE);
	   SetDlgItemText(IDC_STATIC_T,"IP,HostName :");
	   SetDlgItemText(IDC_STATIC_P,"     Port :");
	   if(protocol == 5)
	   {
         SetDlgItemText(IDC_STATIC_T,"	COM :");	   
         SetDlgItemText(IDC_STATIC_P,"SPEED :");
	   }
	}
}

void CSampleConnexionDlg::OnLua() 
{
	char lua_script[2048] = "";

	// TODO: Add your control notification handler code here    	   		    
    sprintf(lua_script,"<PATH_EXPUTTY>Examples\\script.lua");

	if(LoadLuaFile(ConnexionId,lua_script,"","") == 0)
	{
		MessageBox("Lua dofile OK","LUA",MB_OK);
	}
	else
	{
        MessageBox("Lua dofile ERROR","LUA",MB_OK);
	}
}

void CSampleConnexionDlg::OnKeepAliveServer() 
{
	// TODO: Add your control notification handler code here
	unsigned char ConnectionHandle = 23;

	RetrieveConnection(ConnectionHandle);
}

void CSampleConnexionDlg::OnForceToClose() 
{
	// TODO: Add your control notification handler code here
	m_connexion.EnableWindow(1);
	m_liste.EnableWindow(1);
	m_send.EnableWindow(FALSE);
	m_wait.EnableWindow(FALSE);
	m_close.EnableWindow(FALSE);
	m_cmd.EnableWindow(FALSE);
	m_waitrestart.EnableWindow(FALSE);
	m_lua.EnableWindow(FALSE);
	m_ymodemup.EnableWindow(FALSE);
	m_target.EnableWindow(1);
	m_port.EnableWindow(1);
	m_login.EnableWindow(1);
	m_password.EnableWindow(1);
	m_rcvEdit.EnableWindow(FALSE);
	m_sendcmd.EnableWindow(FALSE);
	m_sendbutton.EnableWindow(FALSE);
	m_datatimewindow.EnableWindow(FALSE);

	ForceToClose(ConnexionId);
	SetDlgItemText(IDC_RCVDATA,"Force to close connection");
}

void CSampleConnexionDlg::OnYmodemup() 
{
	char FilePath[2048] = "";
	char *RcvTelnetData= NULL;

	// TODO: Add your control notification handler code here
    sprintf(FilePath,"./ExtraPuTTY.dll");
	if(SendRcvCmd(ConnexionId,"rb -y","","",0,&RcvTelnetData,0,2) != 0)
	{
		MessageBox("Failed to send command to target","Error",MB_OK);
	}
	if(UploadFile(ConnexionId,2,FilePath,"","") == 0)
	{
		MessageBox("Lua dofile OK","LUA",MB_OK);
	}
	else
	{
        MessageBox("Lua dofile ERROR","LUA",MB_OK);
	}
	
}

void CSampleConnexionDlg::OnPuTTYsettings() 
{
	// TODO: Add your control notification handler code here
	PuttySettings(ConnexionId,"logtype" ,"LGTYP_DEBUG" , "", "");
	PuttySettings(ConnexionId,"rekey_time" ,"0" , "", "");
	PuttySettings(ConnexionId,"rekey_data" ,"2G" , "", "");
	PuttySettings(ConnexionId,"log_sessions_events" ,"1" , "", "");
	PuttySettings(ConnexionId,"ExtraPuttyTimeStampTerm" ,"TS_TERM" , "", "");
	PuttySettings(ConnexionId,"ExtraPuttyTimeStampFormat" ,"[%S%T -- TEST]" , "", "");
	PuttySettings(ConnexionId,"logfilename" ,"c:\\putty.txt" , "", "");	
	PuttySettings(ConnexionId,"logxfovr" ,"LGXF_APN" , "", "");
	PuttySettings(ConnexionId,"logflush" ,"0" , "", "");	
	PuttySettings(ConnexionId,"logomitpass" ,"0" , "", "");
	PuttySettings(ConnexionId,"logomitdata" ,"1" , "", "");

	DoReconfig(ConnexionId, "", "");
}
