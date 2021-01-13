-- Start
-- Script: script.lua

-- Reconfigure Putty settings
lua_putty_settings("logtype" ,"LGTYP_DEBUG");
lua_putty_settings("rekey_time" ,"0");
lua_putty_settings("rekey_data" ,"2G");
lua_putty_settings("log_sessions_events" ,"1");
lua_putty_settings("ExtraPuttyTimeStampTerm" ,"TS_TERM");
lua_putty_settings("ExtraPuttyTimeStampFormat" ,"[%S%T -- TEST]");
lua_putty_settings("logfilename" ,"c:\\putty.txt");
lua_putty_settings("logxfovr" ,"LGXF_APN");
lua_putty_settings("logflush" ,"0");
lua_putty_settings("logomitpass" ,"0");
lua_putty_settings("logomitdata" ,"1");

-- Apply new settings
lua_do_reconfig();

-- Send Login and Password : log,pass,timeout
lua_send_login_password("root","root",10000);

value = lua_msgbox("Do you want to activate the ExtraPuTTY Trace ?","Question",1,32,0);
if value == 1 then
-- Active trace to get back all data
lua_start_trace();
end

--InputBox example
res, value = lua_inputbox("What is your admin Group ?","Question");
if res == 0 then
   if string.match(value,"Group1") then
      lua_senddata("set level1",true);
    else
      lua_senddata("set level2",true);
    end
end

-- Send command command1 with CRLF
lua_senddata("command1",true);

-- sleep of 500 ms
lua_sleep(500);

-- read the trace buffer while the text <end command 1> is not found
while true do

-- Read the content of the trace buffer
  res,value = lua_getdata();
  
-- check if <end command 1> is present within buffer  
  if string.match(value,"end command 1") then
  
-- Reset the trace buffer  
    lua_reset_trace();
    
-- Send command vi test.cnf with CRLF    
    lua_senddata("vi test.cnf",true);
    
-- sleep of 500 ms    
    lua_sleep(500);
    
-- Read the content of the trace buffer    
    res,value = lua_getdata();
    break;
  end
end

-- display message box with the content of the file test.cnf
res = lua_msgbox(value,"test.cnf");

-- De-Activation of trace
lua_stop_trace();

-- Send command to reset the terminal without CRLF
lua_senddata("EXT_SYS_CMD_RESET_TERM",false);

-- End