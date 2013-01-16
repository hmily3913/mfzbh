<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<!--#include file="../Include/NoSqlHack.Asp" -->
<!--#include file="../Include/ConnSiteData.asp" -->
<!--#include file="../CheckAdmin.asp" -->
<!--#include file="../Include/md5.asp" -->
<!--#include file="../Include/Function.asp" -->
<%

dim ProcessType,start_date,end_date,print_tag,UserName,UserID
UserName=session("UserName")
UserID=session("UserID")
ProcessType=request("ProcessType")
print_tag=request("print_tag")
if print_tag=1 then
response.ContentType("application/vnd.ms-excel")
response.AddHeader "Content-disposition", "attachment; filename=erpData.xls"
end if
if ProcessType="DetailsList" then 
  dim page'页码
      page=clng(request("page"))
  dim idCount'记录总数
  dim pages'每页条数
      pages=request("rp")
  dim pagec'总页数

  dim datafrom'数据表名
      datafrom=" (select UserID,UserName,UserNumber from sys_users "&_
			" union "&_
			" SELECT CODE AS UserID,NAME AS UserName,FNumber as UserNumber FROM AIS20091116143745.DBO.HM_Employees WHERE STATUS=1) a "&_
			" left join sys_users b on a.userid=b.userid  "
  dim datawhere'数据条件
  dim i'用于循环的整数
	Dim searchterm,searchcols
	datawhere=" where 1=1 "
	if Request.Form("query") <> "" then
		searchterm = Request.Form("query")
		searchcols = Request.Form("qtype")
		if isnumeric(searchterm) then
		datawhere = datawhere&" and " & searchcols & " = " & searchterm & " "
		else
		datawhere = datawhere&" and " & searchcols & " LIKE '%" & searchterm & "%' "
		end if
	End if

  dim sqlid'本页需要用到的id
  dim taxis'排序的语句 asc,desc
	Dim sortname
	if Request.Form("sortname") = "" then
	sortname = "SerialNum" 
	Else
	sortname = Request.Form("sortname")
	End If
	Dim sortorder
	if Request.Form("sortorder") = "" then
	sortorder = "desc"
	Else
	sortorder = Request.Form("sortorder")
	End If
      taxis=" order by "&sortname&" "&sortorder
  dim rs,sql'sql语句
  '获取记录总数
  sql="select count(1) as idCount from "& datafrom &" " & datawhere
  set rs=server.createobject("adodb.recordset")
  rs.open sql,conn,0,1
  idCount=rs("idCount")
  if(idcount>0) then'如果记录总数=0,则不处理
    if(idcount mod pages=0)then'如果记录总数除以每页条数有余数,则=记录总数/每页条数+1
	  pagec=int(idcount/pages)'获取总页数
   	else
      pagec=int(idcount/pages)+1'获取总页数
    end if
  end if
	'获取本页需要用到的id============================================
    '读取所有记录的id数值,因为只有id所以速度很快
    sql="select a.Userid from "& datafrom &" " & datawhere & taxis
    set rs=server.createobject("adodb.recordset")
    rs.open sql,conn,1,1
    rs.pagesize = pages '每页显示记录数
	rs.absolutepage = page  
    for i=1 to rs.pagesize
	  if rs.eof then exit for  
	  if(i=1)then
	    sqlid="'" & rs("Userid") &"'"
	  else
	    sqlid=sqlid &",'"&rs("Userid") &"'"
	  end if
	  rs.movenext
    next
  '获取本页需要用到的id结束============================================
'-----------------------------------------------------------
'-----------------------------------------------------------
%>
{"page":"<%=page%>","total":"<%=idcount%>","rows":[
<%
  if sqlid<>"" then'如果记录总数=0,则不处理
    '用in刷选本页所语言的数据,仅读取本页所需的数据,所以速度快
    sql="select a.*,case when b.SerialNum is null then '未设置' else '' end as UseFlag,b.forbidflag from "& datafrom &" where a.Userid in("& sqlid &") "&taxis
    set rs=server.createobject("adodb.recordset")
    rs.open sql,conn,1,1
    do until rs.eof'填充数据到表格'
%>		
		{"id":"<%=rs("Userid")%>",
		"cell":["<%=rs("Userid")%>","<%=JsonStr(rs("UserName"))%>","<%=JsonStr(rs("UserNumber"))%>","<%=JsonStr(rs("UseFlag"))%>","<%=rs("ForbidFlag")%>"]}
<%		
	    rs.movenext
		If Not rs.eof Then
		  Response.Write ","
		End If
    loop
  end if
  rs.close
  set rs=nothing
response.Write"]}"
'-----------------------------------------------------------'
elseif ProcessType="SaveAdd" then 
	set rs = server.createobject("adodb.recordset")
	sql="select * from sys_Users where UserID='"&Request.Form("UserID")&"'"
	rs.open sql,conn,1,3
	if Request.Form("password")<>Request.Form("passwordconf") then
		response.Write("两次密码不一次，设置失败！")
		response.End()
	end if
	if rs.eof then rs.addnew
	rs("UserID")=Request.Form("UserID")
	rs("UserName")=Request.Form("UserName")
	rs("UserNumber")=Request.Form("UserNumber")
	rs("password")=md5(Request.Form("password"))
	rs.update
	rs.close
	set rs=nothing 
	response.write "保存成功！"
elseif ProcessType="Forbid" then
	set rs = server.createobject("adodb.recordset")
	sql="select * from sys_Users where UserID='"&Request("UserID")&"'"
	rs.open sql,conn,1,3
	if rs.eof then
		response.Write("该用户未设置，不是系统用户不需要禁用！")
		response.End()
	elseif rs("UserID")="admin" then
		response.Write("系统内置用户，不允许禁用！")
		response.End()
	else
		rs("ForbidFlag")=1
		response.write "禁用成功！"
	end if
elseif ProcessType="ClearGZ" then
	set rs = server.createobject("adodb.recordset")
	sql="select * from sys_Users where UserID='"&Request("UserID")&"'"
	rs.open sql,conn,1,3
	if rs.eof then
		response.Write("该用户未设置，不是系统用户不需要清空！")
		response.End()
	elseif rs("UserID")="admin" then
		response.Write("系统内置用户，不允许清空！")
		response.End()
	else
		rs("GZPassword")=""
		response.write "清空成功！"
	end if
elseif ProcessType="showPurview" then 
	set rs = server.createobject("adodb.recordset")
	sql="select a.*,case when c.Serialnum is null then 0 else 1 end as useFlag from sys_Permission a left join sys_PermissionUse b on a.SerialNum=b.Pid and b.GroupFlag=0 left join sys_Users c on b.UID=c.SerialNum and c.UserID='"& request("SerialNum")&"'"
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
elseif ProcessType="setPurview" then 
	dim UID
	set rs = server.createobject("adodb.recordset")
	sql="select SerialNum from sys_Users where UserID='"&Request("UserID")&"'"
	rs.open sql,conn,1,1
	if rs.eof then
		response.Write("{""status"":false,""messages"":""用户不存在，设置失败！""}")
		response.End()
	else
		UID=rs("SerialNum")
		set rs=nothing
		Conn.execute("delete from sys_PermissionUse where GroupFlag=0 and UID="&UID&" and PID not in ("&Request("allNodeID")&")")
		Conn.execute("insert into sys_PermissionUse (Uid,Pid,GroupFlag) select "&UID&",SerialNum,0 from sys_Permission where serialnum in ("&Request("allNodeID")&") except select "&UID&",pid,0 from sys_PermissionUse where groupflag=0 and UID="&UID)
		response.Write("{""status"":true,""messages"":""设置成功！""}")
	end if
end if
Set Conn = Nothing
 %>
