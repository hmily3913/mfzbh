<!--#include file="Include/ConnSiteData.Asp" -->
<!--#include file="Include/NoSqlHack.Asp" -->
<!--#include file="Include/md5.asp" -->
<%
dim LoginName,LoginPassword,AdminName,Password,AdminPurview,UserName,rs,sql,AdminPurviewFLW,Depart,DepartName,UserNumber
LoginName=UCase(trim(request.form("LoginName")))
LoginPassword=request.form("LoginPassword")
set rs = server.createobject("adodb.recordset")
sql="select UserID,UserName,Password,UserNumber from sys_Users where UserID='"&LoginName&"' and ForbidFlag=0"' or UserNumber='"&LoginName&"')
rs.open sql,conn,1,1
if rs.eof then
   response.write "用户名称不正确，请重新输入。"
   response.end
else
   UserID=rs("UserID")
'   UserNumber=rs("UserNumber")
   UserName=rs("UserName")
   Password=rs("Password")
end if
if md5(LoginPassword)<>Password then
'   response.write LoginPassword
   response.write "用户密码不正确，请重新输入。"
   response.end
end if 
if LoginName=UCase(UserID) and md5(LoginPassword)=Password then' or LoginName=UCase(UserNumber))
'   rs("frighttype")=9
'   rs.update
   rs.close
   set rs=nothing 
   
'	set rs = server.createobject("adodb.recordset")
'	sql="select a.Permissions,a.PermissionsFLW from smmsys_PermissionGroup a,smmsys_PermissionGroupDetails b where a.ForbidFlag=0 and a.SerialNum=b.GroupSnum and b.UserID='"&UserName&"'"
'	rs.open sql,connzxpt,1,1
'	while (not rs.eof)
'	  AdminPurview=rs("Permissions")&AdminPurview
'	  AdminPurviewFLW=rs("PermissionsFLW")&AdminPurviewFLW
'		rs.movenext
'	wend
   session("UserID")=UserID
   session("UserName")=UserName
'   session("Depart")=Depart
'	session("DepartName")=DepartName
   session.timeout=1000
   '==================================
   dim LoginIP,LoginTime,LoginSoft
   LoginIP=Request.ServerVariables("Remote_Addr")
   LoginSoft=Request.ServerVariables("Http_USER_AGENT")
   LoginTime=now()
   '====================================
	 sql="select * from sys_Online where UserName='"&UserID&"'"
	 set rs = server.createobject("adodb.recordset")
	 rs.open sql,conn,1,1
	 if not rs.eof then
	 	sql="update sys_Online set o_ip='"&LoginIP&"',o_lasttime='"&LoginTime&"',LoginSoft='"&LoginSoft&"',AdminName='"&UserName&"',o_state=1 where UserName='"&UserID&"'"
		conn.Execute (sql)
	 else
     sql = "insert into sys_Online (o_ip,UserName, o_lasttime,LoginSoft,AdminName,o_state) values ('"&LoginIP&"','" & UserID & "', '" & LoginTime & "','"&LoginSoft&"','" & UserName & "',1)"
     conn.Execute (sql)
	 end if
   rs.close
   set rs=nothing 
   '========================================
   response.write "登录成功"
   response.end
end if
Set Conn = Nothing
%>