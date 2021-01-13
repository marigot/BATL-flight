// SampleConnexionDlg.h : header file
//

#if !defined(AFX_SAMPLECONNEXIONDLG_H__FB27BB83_B092_4F4C_B2F6_A194E4132869__INCLUDED_)
#define AFX_SAMPLECONNEXIONDLG_H__FB27BB83_B092_4F4C_B2F6_A194E4132869__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

/////////////////////////////////////////////////////////////////////////////
// CSampleConnexionDlg dialog

class CSampleConnexionDlg : public CDialog
{
// Construction
public:
	CSampleConnexionDlg(CWnd* pParent = NULL);	// standard constructor

// Dialog Data
	//{{AFX_DATA(CSampleConnexionDlg)
	enum { IDD = IDD_SAMPLECONNEXION_DIALOG };
	CButton	m_ymodemup;
	CButton	m_lua;
	CButton	m_waitrestart;
	CButton	m_displayputty;
	CEdit	m_datatimewindow;
	CButton	m_sendbutton;
	CEdit	m_sendcmd;
	CEdit	m_login;
	CEdit	m_password;
	CEdit	m_port;
	CEdit	m_target;
	CEdit	m_rcvEdit;
	CButton	m_wait;
	CButton	m_check;
	CComboBox	m_liste;
	CEdit	m_cmd;
	CButton	m_close;
	CButton	m_send;
	CButton	m_connexion;
	//}}AFX_DATA

	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CSampleConnexionDlg)
	protected:
	virtual void DoDataExchange(CDataExchange* pDX);	// DDX/DDV support
	//}}AFX_VIRTUAL

// Implementation
protected:
	HICON m_hIcon;

	// Generated message map functions
	//{{AFX_MSG(CSampleConnexionDlg)
	virtual BOOL OnInitDialog();
	afx_msg void OnSysCommand(UINT nID, LPARAM lParam);
	afx_msg void OnPaint();
	afx_msg HCURSOR OnQueryDragIcon();
	afx_msg void OnConnexion();
	afx_msg void OnSendcmd();
	afx_msg void OnClose();
	afx_msg void OnWait();
	afx_msg void OnWaiting();
	afx_msg void OnEnd();
	afx_msg void OnSendToTarget();
	afx_msg void OnWaitrestart();
	afx_msg void OnEditchangeListprotocol();
	afx_msg void OnSelchangeListprotocol();
	afx_msg void OnLua();
	afx_msg void OnKeepAliveServer();
	afx_msg void OnForceToClose();
	afx_msg void OnUploadFile();
	afx_msg void OnYmodem();
	afx_msg void OnYmodemup();
	afx_msg void OnPuTTYsettings();
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_SAMPLECONNEXIONDLG_H__FB27BB83_B092_4F4C_B2F6_A194E4132869__INCLUDED_)
