<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<!--#include file="../Include/ConnSiteData.asp" -->
<!--#include file="../Include/NoSqlHack.Asp" -->
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
if ProcessType="showPurview" then 
	set rs = server.createobject("adodb.recordset")
	sql="select * from sys_Permission"
	rs.open sql,conn,1,1
	response.Write("[")
	do until rs.eof
		%>
		{"id": "<%=rs("SerialNum")%>", "P1": "<%=rs("ProcessType")%>", "TreeUrl": "<%=rs("TreeUrl")%>", "PermissionID": "<%=rs("PermissionID")%>", "name": "<%=rs("PermissionName")%>", "pId": "<%=rs("PSNum")%>", "icons": "<%=rs("IconFile")%>"}
		<%
		rs.movenext
		If Not rs.eof Then
			Response.Write ","
		End If
	loop
	response.Write("]")
	set rs=nothing
elseif ProcessType="SaveAdd" then 
	if request.Form("SerialNum")="" then
	'新增保存
		if request.Form("PSNum")="0" then
		'增加模块
			set rs = server.createobject("adodb.recordset")
			sql="select * from sys_Permission where PermissionID='"&Request.Form("PermissionID")&"'"
			rs.open sql,conn,1,3
			if not rs.eof then
			'如果已存在对应的模块编码
				response.Write("{""status"":false,""messages"":""模块编码已存在，新增失败！""}")
				response.End()
			else
				rs.addnew()
				rs("PermissionID")=Request.Form("PermissionID")
				rs("PermissionName")=Request.Form("PermissionName")
				'权限全名=模块名
				rs("LongName")=Request.Form("PermissionName")
				rs("TreeUrl")=Request.Form("TreeUrl")
				rs("ProcessType")=Request.Form("P1")
				rs("IconFile")=Request.Form("icons")
				rs.update
				rs.close
				set rs=nothing 
			end if
		else
		'增加非模块（功能或者菜单）
			set rs = server.createobject("adodb.recordset")
			sql="select * from sys_Permission where SerialNum='"&Request.Form("PSNum")&"'"
			rs.open sql,conn,1,3
			if rs.eof then
				response.Write("{""status"":false,""messages"":""上级权限已不存在，新增失败！""}")
				response.End()
			else
				dim npNo,rsnp,posLstr,thispid,longname
				npNo=rs("PermissionID")
				longname=rs("LongName")&"-"
				rs.addnew()
				'生成新的PermissionID
				set rsnp = server.createobject("adodb.recordset")
				sql="select top 1 * from sys_Permission where PSNum='"&Request.Form("PSNum")&"' order by SerialNum desc"
				rsnp.open sql,conn,1,1
				if not rsnp.eof then
					posLstr=InStrRev(rsnp("PermissionID"),"-")
					if Mid(rsnp("PermissionID"), posLstr+1)="" then
						thispid=1
					else
						thispid=cint(Mid(rsnp("PermissionID"), posLstr+1))+1
					end if
'					longname=Mid(rsnp("LongName"),1, InStrRev(longname,"-"))
					if thispid<10 then
						npNo=Mid(rsnp("PermissionID"),1, posLstr) & "0" & thispid
					else
						npNo=Mid(rsnp("PermissionID"),1, posLstr) & thispid
					end if
				else
					npNo=npNo&"-01"
				end if
				rsnp.close
				set rsnp=nothing
				rs("PermissionID")=npNo
				rs("LongName")=longname&Request.Form("PermissionName")
				rs("PermissionName")=Request.Form("PermissionName")
				rs("TreeUrl")=Request.Form("TreeUrl")
				rs("ProcessType")=Request.Form("P1")
				rs("PSNum")=Request.Form("PSNum")
				rs("IconFile")=Request.Form("icons")
				rs.update
				rs.close
				set rs=nothing 
			end if
		end if
		sql="select top 1 * from sys_Permission order by SerialNum desc"
		set rs = server.createobject("adodb.recordset")
		rs.open sql,conn,1,1
		'给管理员组赋予新增权限
		conn.execute("insert into sys_PermissionUse (UID,PID,GroupFlag) values (1,"&rs("SerialNum")&",1)")
		'返回新增节点，界面中添加！
		%>
{"status":true,"messages":"保存成功！","Add":true,"datas":{"id": "<%=rs("SerialNum")%>", "P1": "<%=rs("ProcessType")%>", "TreeUrl": "<%=rs("TreeUrl")%>", "PermissionID": "<%=rs("PermissionID")%>", "name": "<%=rs("PermissionName")%>", "pId": "<%=rs("PSNum")%>", "icons": "<%=rs("IconFile")%>"}}
		<%
		rs.close
		set rs=nothing 
	else
	'编辑保存
		set rs = server.createobject("adodb.recordset")
		sql="select * from sys_Permission where SerialNum='"&Request.Form("SerialNum")&"'"
		rs.open sql,conn,1,3
		if rs.eof then
			response.Write("{""status"":false,""messages"":""要编辑的权限已删除，编辑失败！""}")
			response.End()
		else
			rs("PermissionName")=Request.Form("PermissionName")
			rs("TreeUrl")=Request.Form("TreeUrl")
			rs("ProcessType")=Request.Form("P1")
			rs("IconFile")=Request.Form("icons")
			rs("LongName")=mid(rs("LongName"),1,InStrRev(rs("LongName"),"-"))&Request.Form("PermissionName")
		%>
{"status":true,"messages":"保存成功！","Add":false,"datas":{"id": "<%=rs("SerialNum")%>", "P1": "<%=Request.Form("P1")%>", "TreeUrl": "<%=Request.Form("TreeUrl")%>", "PermissionID": "<%=rs("PermissionID")%>", "name": "<%=Request.Form("PermissionName")%>", "pId": "<%=rs("PSNum")%>", "icons": "<%=rs("IconFile")%>"}}
		<%
			rs.update
			rs.close
			set rs=nothing 
		end if
	end if
elseif ProcessType="doDel" then 
	conn.execute("delete from sys_Permission where SerialNum='"&Request("SerialNum")&"'")
	conn.execute("delete from sys_PermissionUse where PID='"&Request("SerialNum")&"'")
	response.Write("{""status"":true,""messages"":""删除成功！""}")
end if
Set Conn = Nothing
 %>
