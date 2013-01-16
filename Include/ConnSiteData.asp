<%
Dim Conn,ConnStr
On error resume next
Set Conn=Server.CreateObject("Adodb.Connection")
ConnStr="driver={SQL Server};server=10.0.0.121;UID=sa;PWD=mflogin;Database=XXPT"
Conn.open ConnStr
if err then
   err.clear
   Set Conn = Nothing
	 response.Write("{""status"":false,""messages"":""系统错误：数据库连接出错，请检查'系统管理>>站点常量设置',请联系管理员!""}")
'   Response.Write ""
   Response.End
end if
%>
