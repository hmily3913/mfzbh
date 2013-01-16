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
      datafrom=" MANA_Work "
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
    sql="select a.*,b.name as Applyer from "& datafrom &" a left join AIS20091116143745.DBO.HM_Employees b on a.Apply=b.code where a.SerialNum in("& sqlid &") "&taxis
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
	sql="select * from MANA_Work "
	rs.open sql,conn,1,3
		rs.addnew()
rs("WorkName")=Request.Form("WorkName")
rs("XQMS")=Request.Form("XQMS")
rs("Apply")=Request.Form("Apply")
rs("ApplyDate")=Request.Form("ApplyDate")
if Request.Form("PlanFDate")<>"" then rs("PlanFDate")=Request.Form("PlanFDate")
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
	sql="select * from MANA_Work where SerialNum="&Request.Form("SerialNum")
	set rs = server.createobject("adodb.recordset")
	rs.open sql,conn,1,3
	if rs.eof then
		response.Write("{""status"":false,""messages"":""对应该项工作不存在，修改失败！""}")
		response.End()
	else
rs("WorkName")=Request.Form("WorkName")
rs("XQMS")=Request.Form("XQMS")
rs("Apply")=Request.Form("Apply")
rs("ApplyDate")=Request.Form("ApplyDate")
if Request.Form("PlanFDate")<>"" then rs("PlanFDate")=Request.Form("PlanFDate")
rs("memo")=Request.Form("memo")
rs("Biller")=UserName
rs("BillerID")=UserID
rs("BillDate")=now()
		rs.update
		rs.close
		set rs=nothing 
	end if
		%>
{"status":true,"messages":"保存成功！"}
		<%
elseif ProcessType="doDel" then 
	'删除组别
	sql="select 1 from MANA_Work where CheckFlag>0 and SerialNum="&request.Form("SerialNum")
	set rs=server.createobject("adodb.recordset")
	rs.open sql,conn,1,1
	if not rs.eof then
		response.Write("{""status"":false,""messages"":""该项工作不处于待审核状态，删除失败！""}")
		response.End()
	end if
	conn.execute("delete from MANA_Work where SerialNum='"&Request("SerialNum")&"'")
	conn.execute("delete from MANA_WorkDt where SerialNum='"&Request("SerialNum")&"'")
	response.Write("{""status"":true,""messages"":""删除成功！""}")
elseif ProcessType="Check" then 
	sql="select * from MANA_Work where SerialNum="&Request.Form("SerialNum")
	set rs = server.createobject("adodb.recordset")
	rs.open sql,conn,1,3
	if rs.eof then
		response.Write("{""status"":false,""messages"":""对应记录不存在，审核失败！""}")
		response.End()
	elseif rs("checkflag")>0 then
		response.Write("{""status"":false,""messages"":""对应记录已审核，不需要重复审核！""}")
		response.End()
	else
		rs("checkflag")=1
rs("Checker")=UserName
rs("CheckerID")=UserID
rs("CheckDate")=now()
		rs.update
		rs.close
		set rs=nothing 
	end if
	response.Write("{""status"":true,""messages"":""审核成功！""}")
elseif ProcessType="unCheck" then 
	sql="select * from MANA_Work where SerialNum="&Request.Form("SerialNum")
	set rs = server.createobject("adodb.recordset")
	rs.open sql,conn,1,3
	if rs.eof then
		response.Write("{""status"":false,""messages"":""对应记录不存在，审核失败！""}")
		response.End()
	elseif rs("checkflag")<>1 then
		response.Write("{""status"":false,""messages"":""对应记录当前状态不允许反审核！""}")
		response.End()
	else
		rs("checkflag")=0
rs("Checker")=null
rs("CheckerID")=null
rs("CheckDate")=null
		rs.update
		rs.close
		set rs=nothing 
	end if
	response.Write("{""status"":true,""messages"":""反审核成功！""}")
elseif ProcessType="getDt" then 
	sql="select * from MANA_Work where SerialNum="&request.Form("SerialNum")
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
elseif ProcessType="getSSNum" then 
	sql="select * from MANA_WorkDt"
	response.Write("{""Rows"":")
	QueryToJSON(conn, sql).Flush
	response.Write("}")
elseif ProcessType="getText" then 
	sql="select *,'' as Flag from MANA_WorkDt where SSNum="&request("SerialNum")&" order by StartDate asc"
	response.Write("{""Rows"":")
	QueryToJSON(conn, sql).Flush
	response.Write("}")
elseif ProcessType="SaveDetail" then
	sql="select * from MANA_Work where SerialNum='"&Request.Form("SerialNum")&"'"
	set rs = server.createobject("adodb.recordset")
	rs.open sql,conn,1,1
	if rs.eof then
		response.Write("{""status"":false,""messages"":""对应记录不存在，登记失败！""}")
		response.End()
	elseif rs("checkflag")=0 then
		response.Write("{""status"":false,""messages"":""对应记录未审核，登记失败！""}")
		response.End()
	elseif rs("Apply")<>UserID then
		response.Write("{""status"":false,""messages"":""只能维护执行人是自己的单据，登记失败！""}")
		response.End()
	else
		dim objDtData,json
		objDtData=Request("OrderDetailData")
		Set json = toArray(objDtData)
		for i=0 to json.Count-1
			dim WorkText,StartDate,EndDate,Flag,memo,tstatus,DSerialNum
			DSerialNum=json(i)("SerialNum")
			WorkText=json(i)("WorkText")
			StartDate=json(i)("StartDate")
			EndDate=json(i)("EndDate")
			Flag=json(i)("Flag")
			memo=json(i)("memo")
			tstatus=json(i)("__status")
			if isnull(EndDate) then EndDate="null"
			if tstatus="add" and not isnull(StartDate) and not isnull(WorkText) then
				sql="select * from MANA_WorkDt"
				set rs = server.createobject("adodb.recordset")
				rs.open sql,conn,1,3
				rs.addnew()
				rs("WorkText")=WorkText
				rs("StartDate")=StartDate
				rs("SSNum")=Request.Form("SerialNum")
				if not isnull(EndDate) and EndDate<>"" then rs("EndDate")=EndDate
				if not isnull(memo) then rs("memo")=memo
				rs("NotDate")=now()
				rs.update
				rs.close
				sql="select * from MANA_WorkDt where SerialNum='"&Request.Form("DSerialNum")&"'"
			elseif tstatus="update" and StartDate<>"" and DSerialNum<>"" then
				sql="select * from MANA_WorkDt where SerialNum='"&DSerialNum&"'"
				set rs = server.createobject("adodb.recordset")
				rs.open sql,conn,1,3
				rs("WorkText")=WorkText
				rs("StartDate")=StartDate
				if not isnull(EndDate) then rs("EndDate")=EndDate
				if not isnull(memo) then rs("memo")=memo
				rs("NotDate")=now()
				rs.update
				rs.close
			elseif tstatus="delete" and DSerialNum<>"" then
				conn.execute("delete from MANA_WorkDt where SerialNum=" &DSerialNum)
			end if
			if Flag="完成" and not isnull(EndDate) then
				conn.execute("update MANA_Work set CheckFlag='3',ActFDate='" &EndDate& "' where SerialNum=" &Request.Form("SerialNum"))
			else
				conn.execute("update MANA_Work set CheckFlag='2',ActFDate=null where SerialNum=" &Request.Form("SerialNum"))
			end if
		next
		Set json = Nothing
	response.Write("{""status"":true,""messages"":""登记成功！""}")
	end if
elseif ProcessType="getGantt" then
	sql="select distinct a.* from MANA_Work a,MANA_WorkDt b where a.CheckFlag>1 and a.SerialNum=b.SSNum and (datediff(d,b.StartDate,'"&request.QueryString("SDate")&"')<=0 and datediff(d,b.StartDate,'"&request.QueryString("EDate")&"')>=0 or datediff(d,b.EndDate,'"&request.QueryString("SDate")&"')<=0 and datediff(d,b.EndDate,'"&request.QueryString("SDate")&"')>=0) order by a.ApplyDate"
	set rs=server.createobject("adodb.recordset")
	rs.open sql,conn,1,1
	Response.Write("[")
	do until rs.eof'填充数据到表格'
		Response.Write("{ ""name"":"""&rs("WorkName")&""",""desc"":"""",""values"":[")
		dim sql2,rs2
		sql2="select * from MANA_WorkDt b where (datediff(d,b.StartDate,'"&request.QueryString("SDate")&"')<=0 and datediff(d,b.StartDate,'"&request.QueryString("EDate")&"')>=0 or datediff(d,b.EndDate,'"&request.QueryString("SDate")&"')<=0 and datediff(d,b.EndDate,'"&request.QueryString("SDate")&"')>=0) and SSNum="&rs("SerialNum")
		set rs2=server.createobject("adodb.recordset")
		rs2.open sql2,conn,1,1
		do until rs2.eof
			dim sd,ed
			sd=request.QueryString("SDate")
			ed=request.QueryString("EDate")
			if datediff("s",request.QueryString("SDate"),rs2("StartDate"))>0 then sd=rs2("StartDate")
			if datediff("s",request.QueryString("EDate"),rs2("EndDate"))<0 then ed=rs2("EndDate")
			response.Write("{""from"":""/Date("&datediff( "s", "1970-01-01 00:00:000",sd)*1000&")/"", ""to"":""/Date("&datediff( "s", "1970-01-01 00:00:000",ed)*1000&")/"", ""desc"": ""<b>"&rs2("WorkText")&"</b><br><b>Data</b>: ["&rs2("StartDate")&" - "&rs2("EndDate")&"] "", ""customClass"": ""ganttRed"", ""label"": """&rs2("WorkText")&"""}")
			rs2.movenext
			If Not rs2.eof Then
				Response.Write ","
			End If
		loop
		Response.Write("]}")
		rs.movenext
		If Not rs.eof Then
		  Response.Write ","
		End If
	loop
	response.Write("]")
end if
conn.close()
set conn=nothing
 %>
