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
      datafrom=" MANA_Car "
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
	sql="select * from MANA_Car where car_brand='"&Request.Form("car_brand")&"'"
	rs.open sql,conn,1,3
	if not rs.eof then
		response.Write("{""status"":false,""messages"":""车牌号已存在，新增失败！""}")
		response.End()
	else
		rs.addnew()
		rs("car_logo")=Request.Form("car_logo")
		rs("car_brand")=Request.Form("car_brand")
		rs("typename")=Request.Form("typename")
		rs("userid")=Request.Form("userid")
		rs("machine_certificate")=Request.Form("machine_certificate")
		rs("ride_number")=Request.Form("ride_number")
		rs("exes_standard")=Request.Form("exes_standard")
		rs("status")=Request.Form("status")
		if Request.Form("yield_date")<>"" then rs("yield_date")=Request.Form("yield_date")
		rs("yield_plant")=Request.Form("yield_plant")
		if Request.Form("enrol_date")<>"" then rs("enrol_date")=Request.Form("enrol_date")
		if Request.Form("buy_date")<>"" then rs("buy_date")=Request.Form("buy_date")
		rs("engine_id")=Request.Form("engine_id")
		rs("chassis_id")=Request.Form("chassis_id")
		rs("car_color")=Request.Form("car_color")
		rs("type_spec")=Request.Form("type_spec")
		rs("up_cast")=Request.Form("up_cast")
		rs("oilbox_capability")=Request.Form("oilbox_capability")
		rs("price")=Request.Form("price")
		rs("buy_id")=Request.Form("buy_id")
		rs("gas_grade")=Request.Form("gas_grade")
		rs("oil_consume")=Request.Form("oil_consume")
		if Request.Form("year_check_date")<>"" then rs("year_check_date")=Request.Form("year_check_date")
		rs("day_count")=Request.Form("day_count")
		rs("memo")=Request.Form("memo")
		rs("create_id")=UserID
		rs("create_time")=now()
		rs("chauffeur_id")=Request.Form("chauffeur_id")
		rs("mileage_numeric")=Request.Form("mileage_numeric")
		rs("fygs")=Request.Form("fygs")
		rs.update
		rs.close
		set rs=nothing 
	end if
		%>
{"status":true,"messages":"保存成功！"}
		<%
elseif ProcessType="SaveEdit" then 
	set rs = server.createobject("adodb.recordset")
	sql="select * from MANA_Car where car_brand='"&Request.Form("car_brand")&"' and SerialNum<>"&Request.Form("SerialNum")
	rs.open sql,conn,1,1
	if not rs.eof then
		response.Write("{""status"":false,""messages"":""修改后的车牌已存在，修改失败！""}")
		response.End()
	else
		sql="select * from MANA_Car where SerialNum="&Request.Form("SerialNum")
		set rs = server.createobject("adodb.recordset")
		rs.open sql,conn,1,3
		if rs.eof then
			response.Write("{""status"":false,""messages"":""对应车辆档案不存在，修改失败！""}")
			response.End()
		else
			rs("car_logo")=Request.Form("car_logo")
			rs("car_brand")=Request.Form("car_brand")
			rs("typename")=Request.Form("typename")
			rs("userid")=Request.Form("userid")
			rs("machine_certificate")=Request.Form("machine_certificate")
			rs("ride_number")=Request.Form("ride_number")
			rs("exes_standard")=Request.Form("exes_standard")
			rs("status")=Request.Form("status")
			if Request.Form("yield_date")<>"" then rs("yield_date")=Request.Form("yield_date")
			rs("yield_plant")=Request.Form("yield_plant")
			if Request.Form("enrol_date")<>"" then rs("enrol_date")=Request.Form("enrol_date")
			if Request.Form("buy_date")<>"" then rs("buy_date")=Request.Form("buy_date")
			rs("engine_id")=Request.Form("engine_id")
			rs("chassis_id")=Request.Form("chassis_id")
			rs("car_color")=Request.Form("car_color")
			rs("type_spec")=Request.Form("type_spec")
			rs("up_cast")=Request.Form("up_cast")
			rs("oilbox_capability")=Request.Form("oilbox_capability")
			rs("price")=Request.Form("price")
			rs("buy_id")=Request.Form("buy_id")
			rs("gas_grade")=Request.Form("gas_grade")
			rs("oil_consume")=Request.Form("oil_consume")
			if Request.Form("year_check_date")<>"" then rs("year_check_date")=Request.Form("year_check_date")
			rs("day_count")=Request.Form("day_count")
			rs("memo")=Request.Form("memo")
			rs("update_id")=UserID
			rs("update_time")=now()
			rs("chauffeur_id")=Request.Form("chauffeur_id")
			rs("fygs")=Request.Form("fygs")
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
	sql="select 1 from MANA_Car a,MANA_Chuche b where a.car_brand=b.chepai and a.SerialNum="&request.Form("SerialNum")
	set rs=server.createobject("adodb.recordset")
	rs.open sql,conn,1,1
	if not rs.eof then
		response.Write("{""status"":false,""messages"":""该车辆已存在出车信息不允许删除！""}")
		response.End()
	end if
	conn.execute("delete from MANA_Car where SerialNum='"&Request("SerialNum")&"'")
	response.Write("{""status"":true,""messages"":""删除成功！""}")
elseif ProcessType="getDt" then 
	sql="select a.*,b.name as empname,case a.status when 1 then '是' else '否' end as statusname from MANA_Car a left join AIS20091116143745.DBO.HM_Employees b on a.userid=b.code where SerialNum="&request.Form("SerialNum")
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
