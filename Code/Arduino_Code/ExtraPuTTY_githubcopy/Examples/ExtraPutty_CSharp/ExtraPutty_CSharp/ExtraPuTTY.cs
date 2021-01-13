using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Runtime.InteropServices;
using System.Windows.Forms;

namespace ExtraPutty
{
    class eSession
    {        
        [DllImport("ExtraPuTTY.dll", EntryPoint = "Connexion")]
        static extern int OpenConnection(string TargetName, ref UInt32 ConnectionId, string Login, string Password, byte ShowTerminal, Int32 Protocol, UInt32 PortNumber, Int32 Report, CallbackRcvData Callback, UInt32 SpecSettings);
        [DllImport("ExtraPuTTY.dll", EntryPoint = "SendRcvData")]
        static extern int SendData(UInt32 ConnectionId, string Data, string Title, string Comments, Int32 TimeCapture,ref IntPtr Buf, Int32 MaxSizeData, UInt32 settings);
        [DllImport("ExtraPuTTY.dll", EntryPoint = "CloseConnexion")]
        static extern int CloseSession(UInt32 ConnectionId);
    
        public enum PType : int
        {
            TELNET       = 0,
            SSH          = 1,
            RLOGIN       = 2,
            RAW          = 3,
            LOAD_SESSION = 4,
            SERIAL_LINK  = 5,
            CYGTERM      = 6
        };

        private UInt32 ConnectionId;

        public delegate int CallbackRcvData(UInt32 ConnectionId, IntPtr Data, Int32 size, Int32 Status);

        //Default constructor
        public eSession()
        {
          
        }

        //Default destructor
        ~eSession()
        {
            if (this.ConnectionId != 0)
            {
                CloseSession(this.ConnectionId);
            }
        }

        public void Create(string TargetName, string Login, string Password, Int32 Protocol,UInt32 PortCOM, CallbackRcvData Callback)
        {
            int result = 0;
            result = OpenConnection(TargetName, ref this.ConnectionId, Login, Password, 0, Protocol, 0, 0, Callback,0);
            if (result != 0)
            {
                throw new System.ArgumentException("Parameter cannot be null", "original");
            }
        }

        public void Send(string Data, string Title, string Comments, Int32 TimeCapture,ref IntPtr Buf, Int32 MaxSizeData, UInt32 settings)
        {
            int result = 0;
            result = SendData(this.ConnectionId, Data, Title, Comments, TimeCapture,ref Buf, MaxSizeData, settings);
            if (result != 0)
            {
                throw new System.ArgumentException("Parameter cannot be null", "original");
            }
        }

        public void Close()
        {
            CloseSession(this.ConnectionId);
        }
    }
}
