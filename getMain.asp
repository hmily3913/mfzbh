<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<!--#include file="Include/ConnSiteData.Asp" -->
<!--#include file="Include/NoSqlHack.Asp" -->
<!--#include file="Include/MD5.Asp" -->
<!--#include file="CheckAdmin.asp" -->
<%
dim UserID,UserName
UserID=session("UserID")
UserName=session("UserName")
dim rs,sql
if request("ProcessType")="getTree" then
	set rs = server.createobject("adodb.recordset")
	sql="select * from sys_Permission where SerialNum in (select PID from sys_PermissionUse a,sys_Users b where a.GroupFlag=0 and a.UID=b.SerialNum and b.UserID='"&UserID&"' union "&_
	"select PID from sys_PermissionUse a,sys_Users b,sys_PermissionGroupDetails c where a.GroupFlag=1 and b.UserID='"&UserID&"' and c.UserID=b.UserID and a.UID=c.GroupSnum) and ProcessType='' order by SerialNum"
	rs.open sql,conn,1,1
	if rs.eof then
			%>
			[{"id": "1", "TreeUrl": "", "PermissionID": "1", "name": "你没有任何权限，请联系管理员！", "pId": "0"}]
			<%
		 response.end
	else
		response.Write("[")
		do until rs.eof
			%>
			{"id": "<%=rs("SerialNum")%>", "TreeUrl": "<%=rs("TreeUrl")%>", "PermissionID": "<%=rs("PermissionID")%>", "name": "<%=rs("PermissionName")%>", "pId": "<%=rs("PSNum")%>","target":"<%=rs("SerialNum")%>"}
			<%
			rs.movenext
			If Not rs.eof Then
				Response.Write ","
			End If
		loop
		response.Write("]")
	end if
	set rs=nothing
elseif request("ProcessType")="resetPD" then
	set rs = server.createobject("adodb.recordset")
	sql="select * from sys_Users where UserID='"&UserID&"' and Password='"&MD5(request.Form("OldPassword"))&"'"
	rs.open sql,conn,1,3
	if rs.eof then
		response.Write("{""status"":false,""messages"":""原密码不正确，修改失败！""}")
	else
		if request.Form("Newpassword")=request.Form("Newpasswordconf") then
			rs("Password")=md5(request.Form("Newpassword"))
			rs.update
			response.Write("{""status"":true,""messages"":""密码修改成功！""}")
		else
			response.Write("{""status"":false,""messages"":""两次输入的新密码不相同，修改失败！""}")
		end if
	end if
	rs.close
	set rs=nothing
end if
Set Conn = Nothing
%>