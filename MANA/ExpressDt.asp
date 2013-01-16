<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<!--#include file="../Include/ConnSiteData.asp" -->
<!--#include file="../Include/NoSqlHack.Asp" -->
<!--#include file="../CheckAdmin.asp" -->
<!--#include file="../Include/md5.asp" -->
<!--#include file="../Include/Function.asp" -->
<!--#include file="../Include/json2str.asp" -->
<!--#include file="../Include/json.asp" -->
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
      datafrom=" MANA_Express "
  dim datawhere'数据条件
  dim i'用于循环的整数
	Dim searchterm,searchcols
	datawhere=request("where")
	if len(datawhere)>0 then datawhere=" where "&getwherestr(datawhere)
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
{ "page":"<%=page%>","total":"<%=idcount%>","Rows": 
<%
  if sqlid<>"" then'如果记录总数=0,则不处理
    '用in刷选本页所语言的数据,仅读取本页所需的数据,所以速度快
    sql="select a.*,b.name as Senderer,d.fname as Sendbmer from "& datafrom &" a left join AIS20091116143745.DBO.HM_Employees b on a.Sender=b.code left join AIS20091116143745.DBO.t_department d on d.fnumber=a.Sendbm where SerialNum in("& sqlid &") "&taxis
		QueryToJSON(conn, sql).Flush
	else
		response.Write("[]")
  end if
  rs.close
  set rs=nothing
response.Write"}"
'-----------------------------------------------------------'
elseif ProcessType="SaveAdd" then 
	set rs = server.createobject("adodb.recordset")
	sql="select * from MANA_Express"
	rs.open sql,conn,1,3
		rs.addnew()
rs("SendDate")=Request.Form("SendDate")
rs("Sender")=Request.Form("Sender")
rs("Sendbm")=Request.Form("Sendbm")
rs("Mdd")=Request.Form("Mdd")
rs("ECompany")=Request.Form("ECompany")
rs("Fees")=Request.Form("Fees")
rs("Geter")=Request.Form("Geter")
if Request.Form("GetDate")<>"" then rs("GetDate")=Request.Form("GetDate")
rs("memo")=Request.Form("memo")
rs("Biller")=UserName
rs("BillerID")=UserID
rs("BillDate")=now()
		rs.update
		rs.close
		set rs=nothing 
		%>
{"status":true,"messages":"保存成功！"}
		<%
elseif ProcessType="SaveEdit" then 
	sql="select * from MANA_Express where SerialNum="&Request.Form("SerialNum")
	set rs = server.createobject("adodb.recordset")
	rs.open sql,conn,1,3
	if rs.eof then
		response.Write("{""status"":false,""messages"":""对应记录不存在，修改失败！""}")
		response.End()
	elseif rs("checkflag")=1 then
		rs("Checker")=UserName
		rs("CheckerID")=UserID
		rs("CheckDate")=now()
		response.Write("{""status"":false,""messages"":""对应记录已审核，不允许修改！""}")
		response.End()
	else
rs("SendDate")=Request.Form("SendDate")
rs("Sender")=Request.Form("Sender")
rs("Sendbm")=Request.Form("Sendbm")
rs("Mdd")=Request.Form("Mdd")
rs("ECompany")=Request.Form("ECompany")
rs("Fees")=Request.Form("Fees")
rs("Geter")=Request.Form("Geter")
if Request.Form("GetDate")<>"" then rs("GetDate")=Request.Form("GetDate")
rs("memo")=Request.Form("memo")
rs("Biller")=UserName
rs("BillerID")=UserID
rs("BillDate")=now()
		rs.update
		rs.close
		set rs=nothing 
		%>
{"status":true,"messages":"保存成功！"}
		<%
	end if
elseif ProcessType="doDel" then 
	sql="select 1 from MANA_Express where CheckFlag>0 and SerialNum in ("&Request("SerialNum")&")"
	set rs=server.createobject("adodb.recordset")
	rs.open sql,conn,1,1
	if not rs.eof then
		response.Write("{""status"":false,""messages"":""该项工作不处于待审核状态，删除失败！""}")
		response.End()
	end if
	conn.execute("delete from MANA_Express where checkflag=0 and SerialNum in ("&Request("SerialNum")&")")
	response.Write("{""status"":true,""messages"":""删除成功！""}")
elseif ProcessType="Check" then
	conn.execute("update MANA_Express set checkflag=1,checker='"&UserName&"',checkerID='"&UserID&"',CheckDate=getdate() where checkflag=0 and SerialNum in ("&Request("SerialNum")&")")
	response.Write("{""status"":true,""messages"":""审核成功！""}")
elseif ProcessType="unCheck" then
	conn.execute("update MANA_Express set checkflag=0,checker=null,checkerID=null,CheckDate=null where checkflag=1 and SerialNum in ("&Request("SerialNum")&")")
	response.Write("{""status"":true,""messages"":""反审核成功！""}")
elseif ProcessType="getDt" then 
	sql="select a.*,b.name as Senderer,d.fname as Sendbmer from MANA_Express a left join AIS20091116143745.DBO.HM_Employees b on a.Sender=b.code left join AIS20091116143745.DBO.t_department d on d.fnumber=a.Sendbm where SerialNum="&request.Form("SerialNum")
	QueryToJSONOBJ conn,sql
elseif ProcessType="ctList" then 
    sql="select a.*,b.name as jjr,d.fname as bm from MANA_Express a left join AIS20091116143745.DBO.HM_Employees b on a.Sender=b.code left join AIS20091116143745.DBO.t_department d on d.fnumber=a.Sendbm where a.CheckFlag=1 and a.SendDate>='"&request.QueryString("SDate")&"' and a.SendDate<='"&request.QueryString("EDate")&"' order by d.fnumber,b.code "
		response.Write("{""Rows"":")
		QueryToJSON(conn, sql).Flush
		response.Write("}")
elseif ProcessType="poexcel" then 
	response.ContentType("application/vnd.ms-excel")
	response.AddHeader "Content-disposition", "attachment; filename=erpData.xls"
	sql="select a.*,b.name as jjr,d.fname as bm from MANA_Express a left join AIS20091116143745.DBO.HM_Employees b on a.Sender=b.code left join AIS20091116143745.DBO.t_department d on d.fnumber=a.Sendbm where a.CheckFlag=1 and a.SendDate>='"&request.QueryString("SDate")&"' and a.SendDate<='"&request.QueryString("EDate")&"' order by d.fnumber,b.code"
	set rs=server.createobject("adodb.recordset")
	rs.open sql,conn,1,1
	response.Write("<table width=""100%"" border=""1"" style='font-size: 12px;'>")
	response.Write("<tr>")
	response.Write("<td width=80>部门</td>")
	response.Write("<td width=80>寄件人</td>")
	response.Write("<td width=80>目的地</td>")
	response.Write("<td width=80>寄件日期时间</td>")
	response.Write("<td width=80>费用(元)</td>")
	response.Write("<td width=80>小计(元)</td>")
	response.Write("</tr>")
	dim strtemp,totalfees
	strtemp=""
	totalfees=0
	while(not rs.eof)
		response.Write("<tr>")
		totalfees=totalfees+cdbl(rs("Fees"))
		if rs("bm")<>strtemp then
		strtemp=rs("bm")
	response.Write("<td>"&rs("bm")&"</td>")
	response.Write("<td>"&rs("jjr")&"</td>")
	response.Write("<td>"&rs("mdd")&"</td>")
	response.Write("<td>"&rs("SendDate")&"</td>")
	response.Write("<td>"&rs("Fees")&"</td>")
	response.Write("<td></td>")
		else
	response.Write("<td></td>")
	response.Write("<td>"&rs("jjr")&"</td>")
	response.Write("<td>"&rs("mdd")&"</td>")
	response.Write("<td>"&rs("SendDate")&"</td>")
	response.Write("<td>"&rs("Fees")&"</td>")
	response.Write("<td></td>")
		end if
		response.Write("</tr>")
		rs.movenext
	wend
	response.Write("<tr>")
	response.Write("<td colspan=4>合计</td>")
	response.Write("<td>"&totalfees&"</td>")
	response.Write("<td></td>")
	response.Write("</tr>")
	response.Write("</table>")
	'// 释放对象 
	rs.close
	set rs=nothing 
end if
conn.close()
set conn=nothing
 %>
