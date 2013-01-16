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
      datafrom=" MANA_RoomApply a "
  dim datawhere'数据条件
  dim i'用于循环的整数
	Dim searchterm,searchcols
	datawhere=request("where")
	if len(datawhere)>0 then datawhere=" where "&getwherestr(datawhere)
  dim sqlid'本页需要用到的id
  dim taxis'排序的语句 asc,desc
	Dim sortname
	if Request.Form("sortname") = "" then
	sortname = "a.SerialNum" 
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
    sql="select a.*,b.code+'/'+b.name as Emp,d.RoomNo+'/'+c.BedID as Bed from "& datafrom &" left join AIS20091116143745.DBO.HR_Base_Emp b on a.Employee=b.code inner join MANA_Bed c on a.BedSNum=c.SerialNum inner join MANA_Room d on c.SSNum=d.SerialNum where a.SerialNum in("& sqlid &") "&taxis
    QueryToJSON(conn, sql).Flush
  end if
  rs.close
  set rs=nothing
response.Write"}"
'-----------------------------------------------------------'
elseif ProcessType="SaveAdd" then 
	set rs = server.createobject("adodb.recordset")
	sql="select * from MANA_Bed where SerialNum='"&Request.Form("BedSNum")&"'"
	rs.open sql,conn,1,1
	if rs.eof then
		response.Write("{""status"":false,""messages"":""床位不存在，新增失败！""}")
		response.End()
	elseif rs("deleteFlag")=1 then
		response.Write("{""status"":false,""messages"":""该床位已有人入住，新增失败！""}")
		response.End()
	end if
	set rs = server.createobject("adodb.recordset")
	sql="select * from MANA_RoomApply"
	rs.open sql,conn,1,3
		rs.addnew()
rs("Employee")=Request.Form("Employee")
rs("BedSNum")=Request.Form("BedSNum")
rs("FKType")=Request.Form("FKType")
rs("FKName")=Request.Form("FKName")
rs("FKSex")=Request.Form("FKSex")
rs("InDate")=Request.Form("InDate")
rs("Yajin")=Request.Form("Yajin")
rs("Qsz")=Request.Form("Qsz")
if Request.Form("PlanOutDate")<>"" then rs("PlanOutDate")=Request.Form("PlanOutDate")
rs("memo")=Request.Form("memo")
rs("Biller")=UserName
rs("BillerID")=UserID
rs("BillDate")=now()

		rs.update
		conn.execute("update MANA_Bed set deleteFlag=1 where SerialNum='"&Request.Form("BedSNum")&"'")
		rs.close
		set rs=nothing 
		%>
{"status":true,"messages":"保存成功！"}
		<%
elseif ProcessType="SaveEdit" then 
	set rs = server.createobject("adodb.recordset")
	sql="select * from MANA_RoomApply where SerialNum="&Request.Form("SerialNum")
	set rs = server.createobject("adodb.recordset")
	rs.open sql,conn,1,3
	if rs("LeaveFlag")=1 then
		response.Write("{""status"":false,""messages"":""该入住信息已经退宿完成，修改失败！""}")
		response.End()
	else
rs("Employee")=Request.Form("Employee")
rs("BedSNum")=Request.Form("BedSNum")
rs("FKType")=Request.Form("FKType")
rs("FKName")=Request.Form("FKName")
rs("FKSex")=Request.Form("FKSex")
rs("InDate")=Request.Form("InDate")
rs("Yajin")=Request.Form("Yajin")
rs("Qsz")=Request.Form("Qsz")
if Request.Form("PlanOutDate")<>"" then rs("PlanOutDate")=Request.Form("PlanOutDate")
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
	sql="select * from MANA_RoomApply where SerialNum="&request.Form("SerialNum")
	set rs=server.createobject("adodb.recordset")
	rs.open sql,conn,1,1
	if rs.eof then
		response.Write("{""status"":false,""messages"":""对应入住信息不存在，删除失败！""}")
		response.End()
	elseif rs("LeaveFlag")=1 then
		response.Write("{""status"":false,""messages"":""对应住宿信息不允许删除，删除失败！""}")
		response.End()
	end if
	conn.execute("update MANA_Bed set deleteFlag=0 where SerialNum="&rs("BedSNum"))
	conn.execute("delete from MANA_RoomApply where SerialNum='"&Request("SerialNum")&"'")
	response.Write("{""status"":true,""messages"":""删除成功！""}")
elseif ProcessType="Check" then 
	'删除组别
	sql="select * from MANA_RoomApply where SerialNum="&request.Form("SerialNum")
	set rs=server.createobject("adodb.recordset")
	rs.open sql,conn,1,3
	if rs.eof then
		response.Write("{""status"":false,""messages"":""对应住宿信息不存在，退房失败！""}")
		response.End()
	elseif rs("LeaveFlag")=1 then
		response.Write("{""status"":false,""messages"":""对应住宿信息已退房，不允许重复操作！""}")
		response.End()
	end if
	if Request.Form("OutDate")="" then
		response.Write("{""status"":false,""messages"":""退房时间不能为空，退房失败！""}")
		response.End()
	elseif datediff("n",rs("InDate"),Request.Form("OutDate"))<0 then
			response.Write("{""status"":false,""messages"":""退房时间不能早于入住时间，退房失败！""}")
			response.End()
	end if
	rs("OutDate")=Request.Form("OutDate")
	rs("Leaver")=UserName
	rs("LeaverID")=UserID
	rs("LeaveDate")=now()
	rs("LeaveFlag")=1
	rs.update
	conn.execute("update MANA_Bed set deleteFlag=0 where SerialNum='"&rs("BedSNum")&"'")
	rs.close
	set rs=nothing 
	response.Write("{""status"":true,""messages"":""退房成功！""}")
elseif ProcessType="getDt" then 
	sql="select * from MANA_RoomApply where SerialNum="&request.Form("SerialNum")
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
elseif ProcessType="BedGrid" then 
      page=clng(request("page"))
      pages=request("pagesize")

      datafrom=" (select b.SerialNum,a.RoomNo+'/'+b.BedID as text,a.RoomNo,a.Price,b.BedID,c.StandName,a.Chuangwei,a.PCount,a.Zige,a.UseType,a.FLows,a.Mits,c.Money from MANA_Room a,MANA_Bed b,MANA_RoomSta c where a.SerialNum=b.SSNum and b.deleteFlag=0 and a.SSNum=c.SerialNum) ttt"
	datawhere=request("where")
	if len(datawhere)>0 then datawhere=" where "&getwherestr(datawhere)
	if Request.Form("sortname") = "" then
	sortname = "SerialNum" 
	Else
	sortname = Request.Form("sortname")
	End If
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
    sql="select * from  "& datafrom &" where SerialNum in("& sqlid &") "&taxis
		QueryToJSON(conn, sql).Flush
  end if
  rs.close
  set rs=nothing
response.Write"}"
end if
conn.close()
set conn=nothing
 %>
