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
      datafrom=" MANA_Room "
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
    sql="select a.*,case a.deleteFlag when 1 then '是' else '否' end as dlfg,b.StandName from "& datafrom &" a left join MANA_RoomSta b on a.SSNum=b.SerialNum where a.SerialNum in("& sqlid &") "&taxis
    QueryToJSON(conn, sql).Flush
  end if
  rs.close
  set rs=nothing
response.Write"}"
'-----------------------------------------------------------'
elseif ProcessType="SaveAdd" then 
	set rs = server.createobject("adodb.recordset")
	sql="select * from MANA_Room where RoomNo='"&Request.Form("RoomNo")&"'"
	rs.open sql,conn,1,3
	if not rs.eof then
		response.Write("{""status"":false,""messages"":""房间已存在，新增失败！""}")
		response.End()
	else
		rs.addnew()
rs("RoomNo")=Request.Form("RoomNo")
rs("Price")=Request.Form("Price")
rs("SSNum")=Request.Form("SSNum")
rs("Chuangwei")=Request.Form("Chuangwei")
rs("PCount")=Request.Form("PCount")
rs("Zige")=Request.Form("Zige")
rs("UseType")=Request.Form("UseType")
rs("FLows")=Request.Form("FLows")
rs("Mits")=Request.Form("Mits")
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
	sql="select * from MANA_Room where RoomNo='"&Request.Form("RoomNo")&"' and SerialNum<>"&Request.Form("SerialNum")
	rs.open sql,conn,1,1
	if not rs.eof then
		response.Write("{""status"":false,""messages"":""修改后的房间已存在，修改失败！""}")
		response.End()
	else
		sql="select * from MANA_Room where SerialNum="&Request.Form("SerialNum")
		set rs = server.createobject("adodb.recordset")
		rs.open sql,conn,1,3
		if rs.eof then
			response.Write("{""status"":false,""messages"":""对应房间不存在，修改失败！""}")
			response.End()
		else
rs("RoomNo")=Request.Form("RoomNo")
rs("Price")=Request.Form("Price")
rs("SSNum")=Request.Form("SSNum")
rs("Chuangwei")=Request.Form("Chuangwei")
rs("PCount")=Request.Form("PCount")
rs("Zige")=Request.Form("Zige")
rs("UseType")=Request.Form("UseType")
rs("FLows")=Request.Form("FLows")
rs("Mits")=Request.Form("Mits")
rs("memo")=Request.Form("memo")
			dim objDtData,json
			objDtData=Request("OrderDetailData")
			Set json = toArray(objDtData)
			for i=0 to json.Count-1
				dim BedID,tstatus,DSerialNum
				DSerialNum=json(i)("SerialNum")
				BedID=json(i)("BedID")
				tstatus=json(i)("__status")
				if tstatus="add" and BedID<>"" then
					conn.execute("insert into MANA_Bed (SSNum,BedID) values (" &Request.Form("SerialNum")& ",'" &BedID& "')")
				elseif tstatus="update" and BedID<>"" and DSerialNum<>"" then
					conn.execute("update MANA_Bed set BedID='" &BedID& "' where SerialNum=" &DSerialNum)
				elseif tstatus="delete" and DSerialNum<>"" then
					conn.execute("delete from MANA_Bed where SerialNum=" &DSerialNum)
				end if
			next
			Set json = Nothing
			rs.update
			rs.close
			set rs=nothing 
		end if
	end if
		%>
{"status":true,"messages":"保存成功！"}
		<%
elseif ProcessType="doDel" then 
	'删除组别
	sql="select 1 from MANA_Room a,MANA_Bed b where a.SerialNum=b.SSNum and a.SerialNum="&request.Form("SerialNum")
	set rs=server.createobject("adodb.recordset")
	rs.open sql,conn,1,1
	if not rs.eof then
		response.Write("{""status"":false,""messages"":""该车辆已存在床位信息不允许删除！""}")
		response.End()
	end if
	conn.execute("delete from MANA_Room where SerialNum='"&Request("SerialNum")&"'")
	response.Write("{""status"":true,""messages"":""删除成功！""}")
elseif ProcessType="getDt" then 
	sql="select * from MANA_Room where SerialNum="&request.Form("SerialNum")
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
	sql="select * from MANA_RoomSta"
	response.Write("{""Rows"":")
	QueryToJSON(conn, sql).Flush
	response.Write("}")
elseif ProcessType="getBeds" then 
	sql="select a.*,b.FKType,b.FKName,b.FKSex,b.InDate,b.Yajin,b.Qsz,b.PlanOutDate from MANA_Bed a left join MANA_RoomApply b on a.SerialNum=b.BedSNum and b.LeaveFlag=0 where a.SSNum="&request("SerialNum")
	response.Write("{""Rows"":")
	QueryToJSON(conn, sql).Flush
	response.Write("}")
end if
conn.close()
set conn=nothing
 %>
