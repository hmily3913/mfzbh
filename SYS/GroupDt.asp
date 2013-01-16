<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<!--#include file="../Include/NoSqlHack.Asp" -->
<!--#include file="../Include/ConnSiteData.asp" -->
<!--#include file="../CheckAdmin.asp" -->
<!--#include file="../Include/md5.asp" -->
<!--#include file="../Include/Function.asp" -->
<%
dim UserID,UserName,print_tag,ProcessType
UserName=session("UserName")
UserID=session("UserID")
ProcessType=request("ProcessType")
print_tag=request("print_tag")
if print_tag=1 then
response.ContentType("application/vnd.ms-excel")
response.AddHeader "Content-disposition", "attachment; filename=erpData.xls"
end if

dim rs,sql
if ProcessType="showGroup" then 
	set rs = server.createobject("adodb.recordset")
	sql="select cast(SerialNum as varchar) as id,GroupName as name,ForbidFlag,0 as pID from sys_PermissionGroup "&_
			" union "&_
			" select a.UserID as id,a.UserID+'/'+b.UserName as name,ForbidFlag,a.GroupSnum as pID from sys_PermissionGroupDetails a,sys_Users b where a.userid=b.UserId  order by pid,id"
	rs.open sql,conn,1,1
	response.Write("[")
	do until rs.eof
		%>
		{"id": "<%=rs("id")%>", "ForbidFlag": "<%=rs("ForbidFlag")%>", "name": "<%=rs("name")%>", "pId": "<%=rs("pId")%>"
		<%
		if rs("ForbidFlag")="1" then
	%>
	, "font":{"color":"red"}
	<%
		end if
		response.Write("}")
		rs.movenext
		If Not rs.eof Then
			Response.Write ","
		End If
	loop
	response.Write("]")
	set rs=nothing
	Set Conn = Nothing
elseif ProcessType="showUsers" then 
	set rs = server.createobject("adodb.recordset")
	sql="select a.UserID as id,a.UserID+'/'+a.UserName as name,a.ForbidFlag,isnull(e.code,'0') as pId,0 as pflag from sys_Users a "&_
			" left join AIS20091116143745.DBO.HM_Employees b on a.userid=b.code and a.ForbidFlag=0 "&_
			" left join AIS20091116143745.DBO.ORG_Position_Employee c on c.EmID = b.EM_ID "&_
			" left join AIS20091116143745.DBO.ORG_Position d on c.PositionID = d.ID "&_
			" left join AIS20091116143745.DBO.ORG_Unit e on e.ID = d.UnitID where a.UserID<>'admin' "&_
			" union "&_
			"select distinct e.code as id,e.name,0 as ForbidFlag,case when len(e.code)<5 then '0' else left(e.code,len(e.code)-5) end as pId,1 as pflag from sys_Users a "&_
			" inner join AIS20091116143745.DBO.HM_Employees b on a.userid=b.code and a.ForbidFlag=0 "&_
			" inner join AIS20091116143745.DBO.ORG_Position_Employee c on c.EmID = b.EM_ID "&_
			" inner join AIS20091116143745.DBO.ORG_Position d on c.PositionID = d.ID "&_
			" inner join AIS20091116143745.DBO.ORG_Unit e on e.ID = d.UnitID "
	rs.open sql,conn,1,1
	response.Write("[")
	do until rs.eof
		%>
		{"id": "<%=rs("id")%>", "name": "<%=rs("name")%>", "pId": "<%=rs("pId")%>"
		<%
		if rs("pflag")="1" then
	%>
	,"open":true
	<%
		end if
		response.Write("}")
		rs.movenext
		If Not rs.eof Then
			Response.Write ","
		End If
	loop
	response.Write("]")
	set rs=nothing
	Set Conn = Nothing
elseif ProcessType="showPurview" then 
	set rs = server.createobject("adodb.recordset")
	sql="select a.*,case when b.Serialnum is null then 0 else 1 end as useFlag  "&_
			" from sys_Permission a left join sys_PermissionUse b "&_
			" on a.SerialNum=b.Pid and GroupFlag=1 and UID='"& request("SerialNum")&"'"
	rs.open sql,conn,1,1
	response.Write("[")
	do until rs.eof
		%>
		{"id": "<%=rs("SerialNum")%>", "PermissionID": "<%=rs("PermissionID")%>", "name": "<%=rs("PermissionName")%>", "pId": "<%=rs("PSNum")%>"
		<%
		if rs("useFlag")="1" then
	%>
	, "checked":true
	<%
		end if
		response.Write("}")
		rs.movenext
		If Not rs.eof Then
			Response.Write ","
		End If
	loop
	response.Write("]")
	set rs=nothing
	Set Conn = Nothing
elseif ProcessType="SaveAdd" then 
	if request.Form("SerialNum")="" then
	'新增保存
		set rs = server.createobject("adodb.recordset")
		sql="select * from sys_PermissionGroup where GroupName='"&Request.Form("GroupName")&"'"
		rs.open sql,conn,1,3
		if not rs.eof then
		'如果已存在对应的模块编码
			response.Write("{""status"":false,""messages"":""组别名已存在，新增失败！""}")
			response.End()
		else
			rs.addnew()
			rs("GroupName")=Request.Form("GroupName")
			rs.update
			rs.close
			set rs=nothing 
		end if
		sql="select top 1 * from sys_PermissionGroup order by SerialNum desc"
		set rs = server.createobject("adodb.recordset")
		rs.open sql,conn,1,1
		'返回新增节点，界面中添加！
		%>
{"status":true,"messages":"保存成功！","Add":true,"datas":{"id": "<%=rs("SerialNum")%>", "ForbidFlag": "0", "name": "<%=rs("GroupName")%>", "pId": "0"}}
		<%
		rs.close
		set rs=nothing 
		Set Conn = Nothing
	else
	'编辑保存
		if Request.Form("SerialNum")="1" then
			response.Write("{""status"":false,""messages"":""内置组别不能修改，编辑失败！""}")
			response.End()
		end if
		set rs = server.createobject("adodb.recordset")
		sql="select * from sys_PermissionGroup where SerialNum='"&Request.Form("SerialNum")&"'"
		rs.open sql,conn,1,3
		if rs.eof then
			response.Write("{""status"":false,""messages"":""要编辑组别已删除，编辑失败！""}")
			response.End()
		else
			rs("GroupName")=Request.Form("GroupName")
		%>
{"status":true,"messages":"保存成功！","Add":false,"datas":{"id": "<%=Request.Form("SerialNum")%>", "ForbidFlag": "0", "name": "<%=Request.Form("GroupName")%>", "pId": "0"}}
		<%
			rs.update
			rs.close
			set rs=nothing 
		end if
		Set Conn = Nothing
	end if
elseif ProcessType="doDel" then 
	if Request("delType")="0" then
	'删除组别
		if Request("SerialNum")="1" then
			response.Write("{""status"":false,""messages"":""内置组别不允许删除！""}")
			response.End()
		end if
		conn.execute("delete from sys_PermissionGroup where SerialNum='"&Request("SerialNum")&"'")
		conn.execute("delete from sys_PermissionGroupDetails where GroupSnum='"&Request("SerialNum")&"'")
		response.Write("{""status"":true,""messages"":""删除成功！""}")
	elseif Request("delType")="1" then
	'从组别中删除用户
		if Request("SerialNum")="admin" then
			response.Write("{""status"":false,""messages"":""内置组别不允许删除！""}")
			response.End()
		end if
		conn.execute("delete from sys_PermissionGroupDetails where UserID='"&Request("SerialNum")&"' and GroupSNum ='"&Request("PID")&"'")
		response.Write("{""status"":true,""messages"":""删除成功！""}")
	end if
	Set Conn = Nothing
elseif ProcessType="setPurview" then 
	if Request("UserID")=1 then
		response.Write("{""status"":false,""messages"":""内置组别不允许修改！""}")
		response.End()
	end if
	dim UID
	set rs = server.createobject("adodb.recordset")
	sql="select SerialNum from sys_PermissionGroup where SerialNum='"&Request("UserID")&"'"
	rs.open sql,conn,1,1
	if rs.eof then
		response.Write("{""status"":false,""messages"":""组别不存在，设置失败！""}")
		response.End()
	else
		UID=rs("SerialNum")
		set rs=nothing
		Conn.execute("delete from sys_PermissionUse where GroupFlag=1 and UID="&UID&" and PID not in ("&Request("allNodeID")&")")
		Conn.execute("insert into sys_PermissionUse (Uid,Pid,GroupFlag) select "&UID&",SerialNum,1 from sys_Permission where serialnum in ("&Request("allNodeID")&") except select "&UID&",pid,1 from sys_PermissionUse where groupflag=1 and UID="&UID)
		response.Write("{""status"":true,""messages"":""设置成功！""}")
	end if
elseif ProcessType="setUsers" then 
	set rs = server.createobject("adodb.recordset")
	sql="select SerialNum from sys_PermissionGroup where SerialNum='"&Request("UserID")&"'"
	rs.open sql,conn,1,1
	if rs.eof then
		response.Write("{""status"":false,""messages"":""组别不存在，设置失败！""}")
		response.End()
	else
		UID=rs("SerialNum")
		set rs=nothing
'		Conn.execute("delete from sys_PermissionGroupDetails where GroupFlag=1 and GroupSNum="&UID&" and UserID not in ("&Request("allNodeID")&")")
		Conn.execute("insert into sys_PermissionGroupDetails (GroupSNum,UserID) select "&UID&",UserID from sys_Users where UserID in ("&Request("allNodeID")&") except select "&UID&",UserID from sys_PermissionGroupDetails where GroupSNum="&UID)
		response.Write("{""status"":true,""messages"":""添加成功！""}")
	end if
end if

 %>
