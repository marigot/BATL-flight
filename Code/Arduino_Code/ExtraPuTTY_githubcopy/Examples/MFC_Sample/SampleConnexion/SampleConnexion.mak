# Microsoft Developer Studio Generated NMAKE File, Based on SampleConnexion.dsp
!IF "$(CFG)" == ""
CFG=SampleConnexion - Win32 Debug
!MESSAGE No configuration specified. Defaulting to SampleConnexion - Win32 Debug.
!ENDIF 

!IF "$(CFG)" != "SampleConnexion - Win32 Release" && "$(CFG)" != "SampleConnexion - Win32 Debug"
!MESSAGE Invalid configuration "$(CFG)" specified.
!MESSAGE You can specify a configuration when running NMAKE
!MESSAGE by defining the macro CFG on the command line. For example:
!MESSAGE 
!MESSAGE NMAKE /f "SampleConnexion.mak" CFG="SampleConnexion - Win32 Debug"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "SampleConnexion - Win32 Release" (based on "Win32 (x86) Application")
!MESSAGE "SampleConnexion - Win32 Debug" (based on "Win32 (x86) Application")
!MESSAGE 
!ERROR An invalid configuration is specified.
!ENDIF 

!IF "$(OS)" == "Windows_NT"
NULL=
!ELSE 
NULL=nul
!ENDIF 

!IF  "$(CFG)" == "SampleConnexion - Win32 Release"

OUTDIR=.\Release
INTDIR=.\Release
# Begin Custom Macros
OutDir=.\Release
# End Custom Macros

ALL : "$(OUTDIR)\SampleConnexion.exe"


CLEAN :
	-@erase "$(INTDIR)\SampleConnexion.obj"
	-@erase "$(INTDIR)\SampleConnexion.pch"
	-@erase "$(INTDIR)\SampleConnexion.res"
	-@erase "$(INTDIR)\SampleConnexionDlg.obj"
	-@erase "$(INTDIR)\StdAfx.obj"
	-@erase "$(INTDIR)\vc60.idb"
	-@erase "$(OUTDIR)\SampleConnexion.exe"

"$(OUTDIR)" :
    if not exist "$(OUTDIR)/$(NULL)" mkdir "$(OUTDIR)"

CPP=cl.exe
CPP_PROJ=/nologo /Gz /Zp16 /MD /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /D "_AFXDLL" /D "_MBCS" /Fp"$(INTDIR)\SampleConnexion.pch" /Yu"stdafx.h" /Fo"$(INTDIR)\\" /Fd"$(INTDIR)\\" /FD /c 

.c{$(INTDIR)}.obj::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

.cpp{$(INTDIR)}.obj::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

.cxx{$(INTDIR)}.obj::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

.c{$(INTDIR)}.sbr::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

.cpp{$(INTDIR)}.sbr::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

.cxx{$(INTDIR)}.sbr::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

MTL=midl.exe
MTL_PROJ=/nologo /D "NDEBUG" /mktyplib203 /win32 
RSC=rc.exe
RSC_PROJ=/l 0x40c /fo"$(INTDIR)\SampleConnexion.res" /d "NDEBUG" /d "_AFXDLL" 
BSC32=bscmake.exe
BSC32_FLAGS=/nologo /o"$(OUTDIR)\SampleConnexion.bsc" 
BSC32_SBRS= \
	
LINK32=link.exe
LINK32_FLAGS=/nologo /subsystem:windows /incremental:no /pdb:"$(OUTDIR)\SampleConnexion.pdb" /machine:I386 /out:"$(OUTDIR)\SampleConnexion.exe" 
LINK32_OBJS= \
	"$(INTDIR)\SampleConnexion.obj" \
	"$(INTDIR)\SampleConnexionDlg.obj" \
	"$(INTDIR)\StdAfx.obj" \
	"$(INTDIR)\SampleConnexion.res"

"$(OUTDIR)\SampleConnexion.exe" : "$(OUTDIR)" $(DEF_FILE) $(LINK32_OBJS)
    $(LINK32) @<<
  $(LINK32_FLAGS) $(LINK32_OBJS)
<<

!ELSEIF  "$(CFG)" == "SampleConnexion - Win32 Debug"

OUTDIR=.\Debug
INTDIR=.\Debug
# Begin Custom Macros
OutDir=.\Debug
# End Custom Macros

ALL : "$(OUTDIR)\SampleConnexion.exe"


CLEAN :
	-@erase "$(INTDIR)\SampleConnexion.obj"
	-@erase "$(INTDIR)\SampleConnexion.pch"
	-@erase "$(INTDIR)\SampleConnexion.res"
	-@erase "$(INTDIR)\SampleConnexionDlg.obj"
	-@erase "$(INTDIR)\StdAfx.obj"
	-@erase "$(INTDIR)\vc60.idb"
	-@erase "$(INTDIR)\vc60.pdb"
	-@erase "$(OUTDIR)\SampleConnexion.exe"
	-@erase "$(OUTDIR)\SampleConnexion.ilk"
	-@erase "$(OUTDIR)\SampleConnexion.pdb"

"$(OUTDIR)" :
    if not exist "$(OUTDIR)/$(NULL)" mkdir "$(OUTDIR)"

CPP=cl.exe
CPP_PROJ=/nologo /Gz /MDd /W3 /Gm /GX /ZI /Od /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /D "_AFXDLL" /D "_MBCS" /Fp"$(INTDIR)\SampleConnexion.pch" /Yu"stdafx.h" /Fo"$(INTDIR)\\" /Fd"$(INTDIR)\\" /FD /GZ /c 

.c{$(INTDIR)}.obj::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

.cpp{$(INTDIR)}.obj::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

.cxx{$(INTDIR)}.obj::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

.c{$(INTDIR)}.sbr::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

.cpp{$(INTDIR)}.sbr::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

.cxx{$(INTDIR)}.sbr::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

MTL=midl.exe
MTL_PROJ=/nologo /D "_DEBUG" /mktyplib203 /win32 
RSC=rc.exe
RSC_PROJ=/l 0x40c /fo"$(INTDIR)\SampleConnexion.res" /d "_DEBUG" /d "_AFXDLL" 
BSC32=bscmake.exe
BSC32_FLAGS=/nologo /o"$(OUTDIR)\SampleConnexion.bsc" 
BSC32_SBRS= \
	
LINK32=link.exe
LINK32_FLAGS=/nologo /subsystem:windows /incremental:yes /pdb:"$(OUTDIR)\SampleConnexion.pdb" /debug /machine:I386 /out:"$(OUTDIR)\SampleConnexion.exe" /pdbtype:sept 
LINK32_OBJS= \
	"$(INTDIR)\SampleConnexion.obj" \
	"$(INTDIR)\SampleConnexionDlg.obj" \
	"$(INTDIR)\StdAfx.obj" \
	"$(INTDIR)\SampleConnexion.res"

"$(OUTDIR)\SampleConnexion.exe" : "$(OUTDIR)" $(DEF_FILE) $(LINK32_OBJS)
    $(LINK32) @<<
  $(LINK32_FLAGS) $(LINK32_OBJS)
<<

!ENDIF 


!IF "$(NO_EXTERNAL_DEPS)" != "1"
!IF EXISTS("SampleConnexion.dep")
!INCLUDE "SampleConnexion.dep"
!ELSE 
!MESSAGE Warning: cannot find "SampleConnexion.dep"
!ENDIF 
!ENDIF 


!IF "$(CFG)" == "SampleConnexion - Win32 Release" || "$(CFG)" == "SampleConnexion - Win32 Debug"
SOURCE=.\SampleConnexion.cpp

"$(INTDIR)\SampleConnexion.obj" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\SampleConnexion.pch"


SOURCE=.\SampleConnexion.rc

"$(INTDIR)\SampleConnexion.res" : $(SOURCE) "$(INTDIR)"
	$(RSC) $(RSC_PROJ) $(SOURCE)


SOURCE=.\SampleConnexionDlg.cpp

"$(INTDIR)\SampleConnexionDlg.obj" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\SampleConnexion.pch"


SOURCE=.\StdAfx.cpp

!IF  "$(CFG)" == "SampleConnexion - Win32 Release"

CPP_SWITCHES=/nologo /Gz /Zp16 /MD /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /D "_AFXDLL" /D "_MBCS" /Fp"$(INTDIR)\SampleConnexion.pch" /Yc"stdafx.h" /Fo"$(INTDIR)\\" /Fd"$(INTDIR)\\" /FD /c 

"$(INTDIR)\StdAfx.obj"	"$(INTDIR)\SampleConnexion.pch" : $(SOURCE) "$(INTDIR)"
	$(CPP) @<<
  $(CPP_SWITCHES) $(SOURCE)
<<


!ELSEIF  "$(CFG)" == "SampleConnexion - Win32 Debug"

CPP_SWITCHES=/nologo /Gz /MDd /W3 /Gm /GX /ZI /Od /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /D "_AFXDLL" /D "_MBCS" /Fp"$(INTDIR)\SampleConnexion.pch" /Yc"stdafx.h" /Fo"$(INTDIR)\\" /Fd"$(INTDIR)\\" /FD /GZ /c 

"$(INTDIR)\StdAfx.obj"	"$(INTDIR)\SampleConnexion.pch" : $(SOURCE) "$(INTDIR)"
	$(CPP) @<<
  $(CPP_SWITCHES) $(SOURCE)
<<


!ENDIF 


!ENDIF 

