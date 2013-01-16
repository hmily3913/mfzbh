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
if ProcessType="DetailsList" then 
  dim page'页码
      page=clng(request("page"))
  dim idCount'记录总数
  dim pages'每页条数
      pages=request("pagesize")
  dim pagec'总页数

  dim datafrom'数据表名
      datafrom=" MANA_OilCard "
  dim datawhere'数据条件
  dim i'用于循环的整数
	Dim searchterm,searchcols

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
    sql="select SerialNum from "& datafrom &" " & datawhere & taxis
    set rs=server.createobject("adodb.recordset")
    rs.open sql,conn,1,1
    rs.pagesize = pages '每页显示记录数
	rs.absolutepage = page  
    for i=1 to rs.pagesize
	  if rs.eof then exit for  
	  if(i=1)then
	    sqlid=rs("SerialNum")
	  else
	    sqlid=sqlid &","&rs("SerialNum")
	  end if
	  rs.movenext
    next
  '获取本页需要用到的id结束============================================
'-----------------------------------------------------------
'-----------------------------------------------------------
%>
{ "page":"<%=page%>","total":"<%=idcount%>","Rows": [
<%
  if sqlid<>"" then'如果记录总数=0,则不处理
    '用in刷选本页所语言的数据,仅读取本页所需的数据,所以速度快
    sql="select a.*,b.name as empname from "& datafrom &" a left join AIS20091116143745.DBO.HM_Employees b on a.userid=b.code where SerialNum in("& sqlid &") "&taxis
    set rs=server.createobject("adodb.recordset")
    rs.open sql,conn,1,1
    do until rs.eof'填充数据到表格'
			Response.Write("{")
			for i=0 to rs.fields.count-1
				response.write (""""&rs.fields(i).name & """:"""&JsonStr(rs.fields(i).value)&"""")
				if i<rs.fields.count-1 then response.Write(",")
			next
			response.Write("}")
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
	sql="select * from MANA_OilCard where oilcardnumber='"&Request.Form("oilcardnumber")&"'"
	rs.open sql,conn,1,3
	if not rs.eof then
		response.Write("{""status"":false,""messages"":""油卡号已存在，新增失败！""}")
		response.End()
	else
		rs.addnew()
rs("oilcardnumber")=Request.Form("oilcardnumber")
rs("blcompany")=Request.Form("blcompany")
rs("userid")=Request.Form("userid")
rs("carbrand")=Request.Form("carbrand")
rs("status")=Request.Form("status")
rs("memo")=Request.Form("memo")
		rs.update
		rs.close
		set rs=nothing 
	end if
		%>
{"status":true,"messages":"保存成功！"}
		<%
elseif ProcessType="SaveEdit" then 
	set rs = server.createobject("adodb.recordset")
	sql="select * from MANA_OilCard where oilcardnumber='"&Request.Form("oilcardnumber")&"' and SerialNum<>"&Request.Form("SerialNum")
	rs.open sql,conn,1,1
	if not rs.eof then
		response.Write("{""status"":false,""messages"":""修改后的油卡已存在，修改失败！""}")
		response.End()
	else
		sql="select * from MANA_OilCard where SerialNum="&Request.Form("SerialNum")
		set rs = server.createobject("adodb.recordset")
		rs.open sql,conn,1,3
		if rs.eof then
			response.Write("{""status"":false,""messages"":""对应油卡档案不存在，修改失败！""}")
			response.End()
		else
rs("oilcardnumber")=Request.Form("oilcardnumber")
rs("blcompany")=Request.Form("blcompany")
rs("userid")=Request.Form("userid")
rs("carbrand")=Request.Form("carbrand")
rs("status")=Request.Form("status")
rs("memo")=Request.Form("memo")
			rs.update
			rs.close
			set rs=nothing 
		end if
	end if
		%>
{"status":true,"messages":"保存成功！"}
		<%
elseif ProcessType="doDel" then 
	sql="select 1 from MANA_OilCard a,MANA_OilFee b where a.oilcardnumber=b.kahao and a.SerialNum="&request.Form("SerialNum")
	set rs=server.createobject("adodb.recordset")
	rs.open sql,conn,1,1
	if rs.eof then
		conn.execute("delete from MANA_OilCard where SerialNum='"&Request("SerialNum")&"'")
	else
		conn.execute("update MANA_OilCard set deleteflag=1 where SerialNum='"&Request("SerialNum")&"'")
	end if
	rs.close
	set rs=nothing 
	response.Write("{""status"":true,""messages"":""删除成功！""}")
elseif ProcessType="CarList" then 
	sql="select a.car_brand from MANA_Car a where deleteFlag=0 order by fygs desc,car_brand asc"
	set rs=server.createobject("adodb.recordset")
	rs.open sql,conn,1,1
	Response.Write("[")
	do until rs.eof'填充数据到表格'
		Response.Write("{""id"":"""&rs("car_brand")&""",""text"":"""&rs("car_brand")&"""}")
		rs.movenext
	If Not rs.eof Then
		Response.Write ","
	End If
	loop
	response.Write("]")
	rs.close
	set rs=nothing 
elseif ProcessType="getDt" then 
	sql="select a.*,b.name as empname,case a.status when 1 then '是' else '否' end as statusname from MANA_OilCard a left join AIS20091116143745.DBO.HM_Employees b on a.userid=b.code where SerialNum="&request.Form("SerialNum")
	set rs=server.createobject("adodb.recordset")
	rs.open sql,conn,1,1
'	Response.Write("[")
'	do until rs.eof'填充数据到表格'
			Response.Write("{""status"":true,""messages"":""读取完成"",""Data"":{")
			for i=0 to rs.fields.count-1
				response.write (""""&rs.fields(i).name & """:"""&JsonStr(rs.fields(i).value)&"""")
				if i<rs.fields.count-1 then response.Write(",")
			next
			response.Write("}}")
'	loop
'	response.Write("]")
end if
conn.close()
set conn=nothing
 %>
