using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;

namespace ExtraPutty_CSharp
{
    public partial class Settings : Form
    {
        private ExtraPutty.eSession.PType Protocol = 0;

        public event OpenSessionPuTTY Session_Set;

        public delegate void OpenSessionPuTTY(Param settings);
      
        public Settings()
        {
            InitializeComponent();
        }

        public struct Param
        {
            private int _protocol;
            private string _DeviceAdd;
            private string _Login;
            private string _Password;

            public int protocol
            {
                get{return _protocol;}
                set{_protocol = value;}
            }
            public string DeviceAdd
            {
                get { return _DeviceAdd; }
                set { _DeviceAdd = value; }
            }
            public string Login
            {
                get { return _Login; }
                set { _Login = value; }
            }
            public string Password
            {
                get { return _Password; }
                set { _Password = value; }
            }

           /* public Param()
            {
                this.protocol = (int)ExtraPutty.eSession.PType.TELNET;
                this.DeviceAdd = "";
                this.Login = "";
                this.Password = "";
            }*/
        }

        private void Connection_Click(object sender, EventArgs e)
        {
            Param Settings = new Param();

            Settings.DeviceAdd = DeviceAdd.Text;
            Settings.Login = Login.Text;
            Settings.Password = Password.Text;
            Settings.protocol = (int)Protocol;

            if (this.Session_Set != null)
            {                             
                this.Session_Set(Settings);
                this.Close();
            }

        }

        private void comboBox1_SelectedIndexChanged(object sender, EventArgs e)
        {
            int prot = comboBox1.SelectedIndex;
            label2.Text = "@ or hostName";
            Password.Enabled = true;
            switch (prot)
            {
                case 0:
                    Protocol = ExtraPutty.eSession.PType.TELNET;
                    break;
                case 1:
                    Protocol = ExtraPutty.eSession.PType.SSH;
                    break;
                case 2:
                    Protocol = ExtraPutty.eSession.PType.LOAD_SESSION;
                    label2.Text = "Putty Session";
                    break;
                case 3:
                    Protocol = ExtraPutty.eSession.PType.CYGTERM;
                    label2.Text = "Command";
                    DeviceAdd.Text = "-";
                    Password.Text = "";
                    Login.Text = "";
                    Password.Enabled = false;
                    Login.Enabled = false;
                    break;
            }
        }
    }
}
