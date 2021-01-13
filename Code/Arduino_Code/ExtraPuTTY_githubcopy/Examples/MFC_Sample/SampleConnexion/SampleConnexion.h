// SampleConnexion.h : main header file for the SAMPLECONNEXION application
//

#if !defined(AFX_SAMPLECONNEXION_H__EC0E17FF_FB3D_4375_884F_A7AC73E83B14__INCLUDED_)
#define AFX_SAMPLECONNEXION_H__EC0E17FF_FB3D_4375_884F_A7AC73E83B14__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#ifndef __AFXWIN_H__
	#error include 'stdafx.h' before including this file for PCH
#endif

#include "resource.h"		// main symbols

/////////////////////////////////////////////////////////////////////////////
// CSampleConnexionApp:
// See SampleConnexion.cpp for the implementation of this class
//

class CSampleConnexionApp : public CWinApp
{
public:
	CSampleConnexionApp();

// Overrides
	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CSampleConnexionApp)
	public:
	virtual BOOL InitInstance();
	//}}AFX_VIRTUAL

// Implementation

	//{{AFX_MSG(CSampleConnexionApp)
		// NOTE - the ClassWizard will add and remove member functions here.
		//    DO NOT EDIT what you see in these blocks of generated code !
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};


/////////////////////////////////////////////////////////////////////////////

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_SAMPLECONNEXION_H__EC0E17FF_FB3D_4375_884F_A7AC73E83B14__INCLUDED_)
