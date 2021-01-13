using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using ExtraPutty;
using System.Runtime.InteropServices;
using System.Threading;
 
namespace ExtraPutty_CSharp
{
    public partial class Main : Form
    {
           
        #region Not in the scop of this example
        //Delegate functions to update forms and make connection from a thread to not block the application
        private delegate void CallBackDisplay(string txt);
        public delegate void CallbackConnection(int Status);        
        private Settings.Param Settings;
        private Thread ThreadConnection;

        public Main()
        {
            InitializeComponent();
        }

        //Close exe
        private void exitToolStripMenuItem_Click(object sender, EventArgs e)
        {
            this.Close();
        }

        //To catch enter key
        private void CheckKeys(object sender, System.Windows.Forms.KeyPressEventArgs e)
        {
            if (e.KeyChar == (char)13)
            {
                IntPtr toto = IntPtr.Zero;
                Session.Send(DataToSnd.Text, "", "", 0, ref toto, 0, 2);
                DataToSnd.Text = "";
            }
        }

        //To get Data settings of from2
        private void Main_Load(object sender, EventArgs e)
        {
            this.DataToSnd.KeyPress += new System.Windows.Forms.KeyPressEventHandler(CheckKeys);
        }

        //Data comes from from2 : Connection settings
        private void OpenSession_Set(Settings.Param Settings)
        {
            ptrFct = new eSession.CallbackRcvData(this.RcvData);
            this.Settings = Settings;
            ThreadConnection = new Thread(new ThreadStart(this.ThreadProc));
            ThreadConnection.Start();
            toolStripProgressBar1.Value = 50;
        }

        private void settingsToolStripMenuItem_Click(object sender, EventArgs e)
        {
            Settings FormSettings = new Settings();

            FormSettings.Session_Set += new Settings.OpenSessionPuTTY(this.OpenSession_Set);
            FormSettings.Show();
        }

        //Update window form when connection is end : OK or not
        public void Connection_End(int Status)
        {
            if (this.InvokeRequired == true)
            {
                CallbackConnection FctEnd = new CallbackConnection(this.Connection_End);
                this.Invoke(FctEnd, Status);
            }
            else
            {
                if (Status == 1)
                {
                    DataToSnd.Enabled = true;
                    DataToSnd.Focus();
                    button1.Enabled = true;
                    settingsToolStripMenuItem.Enabled = false;
                    closeToolStripMenuItem.Enabled = true;
                }
                else
                {
                    MessageBox.Show("Connection failed", "Error", MessageBoxButtons.OK);
                }
                toolStripProgressBar1.Value = 100;
            }
        }
        //delegate function to display data received on terminal
        private void Displaytext(string txt)
        {
            if (this.DataRcvFrom.InvokeRequired == true)
            {
                CallBackDisplay FctSetetext = new CallBackDisplay(this.Displaytext);
                this.Invoke(FctSetetext, txt);
            }
            else
            {
                DataRcvFrom.AppendText(txt);
                DataRcvFrom.SelectionStart = DataRcvFrom.TextLength;
                DataRcvFrom.SelectionLength = 0;
                DataRcvFrom.Focus();
                DataToSnd.Focus();
            }
        }

        #endregion

        //Callback declaration used to  get data from terminal : callback of ExtraPuTTY connection function
        eSession.CallbackRcvData ptrFct = null;
        //Create eSession object from ExtraPuTTY class
        private eSession Session = new eSession();

        //Callback used to get data from terminal, calls from ExtraPuTTY.dll
        public int RcvData(UInt32 ConnectionId,IntPtr Data, Int32 size, Int32 Status)
        {
            if ((size > 0) && (Status == 0) && (Data != null))
            {
                this.Displaytext(Marshal.PtrToStringAnsi(Data));
            }
            
            return 0;
        }

        //Send data 
        private void button1_Click(object sender, EventArgs e)
        {
            IntPtr toto = IntPtr.Zero;
            Session.Send(DataToSnd.Text, "", "", 0,ref toto, 0, 2);
            DataToSnd.Text = "";
        }

        // The thread procedure performs connection
        public void ThreadProc()
        {
            try
            {
                //open putty session , portCOM not used in this example not serial link
                Session.Create(Settings.DeviceAdd, Settings.Login, Settings.Password, Settings.protocol, 0, ptrFct);                
                this.Connection_End(1);
            }
            catch
            {
                this.Connection_End(0);
            }
        }

        //Close connection
        private void closeToolStripMenuItem_Click(object sender, EventArgs e)
        {
            Session.Close();
            DataToSnd.Text = "";
            button1.Enabled = false;
            DataToSnd.Enabled = false;
            settingsToolStripMenuItem.Enabled = true;
            closeToolStripMenuItem.Enabled = false;
        }
    }   
}
