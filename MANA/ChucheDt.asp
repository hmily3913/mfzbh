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
      datafrom=" MANA_Chuche "
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
{ "page":"<%=page%>","total":"<%=idcount%>","Rows": [
<%
  if sqlid<>"" then'如果记录总数=0,则不处理
    '用in刷选本页所语言的数据,仅读取本页所需的数据,所以速度快
    sql="select a.*,b.name as syrer,c.name as jsyer,d.fname as ycbmer from "& datafrom &" a left join AIS20091116143745.DBO.HM_Employees b on a.syr=b.code left join AIS20091116143745.DBO.HM_Employees c on a.jsy=c.code left join AIS20091116143745.DBO.t_department d on d.fnumber=a.ycbm where SerialNum in("& sqlid &") "&taxis
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
	sql="select * from MANA_Chuche where chepai='"&Request.Form("chepai")&"' and CheckFlag=0"
	rs.open sql,conn,1,1
	if not rs.eof then
		response.Write("{""status"":false,""messages"":""该车辆在出行状态，不允许制定发出单！""}")
		response.End()
	end if
	set rs = server.createobject("adodb.recordset")
	sql="select * from MANA_Chuche where chepai='"&Request.Form("chepai")&"' and datediff(n,'"&Request.Form("cfsj")&"',hlsj)>0"
	rs.open sql,conn,1,3
	if not rs.eof then
		response.Write("{""status"":false,""messages"":""不能登记早于之前的出车单，保存失败！""}")
		response.End()
	end if
		rs.addnew()
rs("chepai")=Request.Form("chepai")
rs("cfsj")=Request.Form("cfsj")
rs("cflcs")=Request.Form("cflcs")
rs("syr")=Request.Form("syr")
rs("ycbm")=Request.Form("ycbm")
rs("jsy")=Request.Form("jsy")
rs("syjmdd")=Request.Form("syjmdd")
rs("fylb")=Request.Form("fylb")
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
elseif ProcessType="EditAll" then 
	set rs = server.createobject("adodb.recordset")
	sql="select * from MANA_Chuche where (datediff(n,'"&Request.Form("cfsj")&"',hlsj)>0 and datediff(n,'"&Request.Form("cfsj")&"',cfsj)<0 or datediff(n,'"&Request.Form("hlsj")&"',hlsj)>0 and datediff(n,'"&Request.Form("hlsj")&"',cfsj)<0 ) and chepai='"&Request.Form("chepai")&"' and SerialNum<>"&Request.Form("SerialNum")
	rs.open sql,conn,1,1
	if not rs.eof then
		response.Write("{""status"":false,""messages"":""对应的出发或者回来时间与其他出车单时间冲突，不允许修改！""}")
		response.End()
	end if
	sql="select * from MANA_Chuche where SerialNum="&Request.Form("SerialNum")
	set rs = server.createobject("adodb.recordset")
	rs.open sql,conn,1,3
		rs("cfsj")=Request.Form("cfsj")
		rs("syr")=Request.Form("syr")
		rs("ycbm")=Request.Form("ycbm")
		rs("jsy")=Request.Form("jsy")
		rs("syjmdd")=Request.Form("syjmdd")
		rs("fylb")=Request.Form("fylb")
		rs("hlsj")=Request.Form("hlsj")
		rs("memo")=Request.Form("memo")
		rs("cxyl")=Request.Form("cxyl")
		rs("qjws")=Request.Form("qjws")
		rs("clwg")=Request.Form("clwg")
		if Request.Form("ysghsj")<>"" then rs("ysghsj")=Request.Form("ysghsj")
		rs.update
		rs.close
		set rs=nothing 
		%>
{"status":true,"messages":"保存成功！"}
		<%
elseif ProcessType="SaveEdit" then 
	sql="select * from MANA_Chuche where SerialNum="&Request.Form("SerialNum")
	set rs = server.createobject("adodb.recordset")
	rs.open sql,conn,1,3
	if rs.eof then
		response.Write("{""status"":false,""messages"":""对应记录不存在，修改失败！""}")
		response.End()
	elseif rs("checkflag")=1 then
		rs("cxyl")=Request.Form("cxyl")
		rs("qjws")=Request.Form("qjws")
		rs("clwg")=Request.Form("clwg")
		if Request.Form("ysghsj")<>"" then rs("ysghsj")=Request.Form("ysghsj")
		rs("Checker")=UserName
		rs("CheckerID")=UserID
		rs("CheckDate")=now()
		rs.update
		rs.close
		set rs=nothing 
		response.Write("{""status"":true,""messages"":""对应记录已审核，只保存车辆检查信息！""}")
	else
		if datediff("n",rs("cfsj"),Request.Form("hlsj"))<0 then
			response.Write("{""status"":false,""messages"":""回来时间不能早于出发时间，回车失败！""}")
			response.End()
		end if
		if cdbl(Request.Form("hllcs"))<cdbl(rs("cflcs")) then
			response.Write("{""status"":false,""messages"":"""&Request.Form("hllcs")&"回来里程数不能小于出发里程数，回车失败！""}")
			response.End()
		end if
		rs("hlsj")=Request.Form("hlsj")
		rs("hllcs")=Request.Form("hllcs")
		rs("sylcs")=Request.Form("sylcs")
		rs("memo")=Request.Form("memo")
		rs("cxyl")=Request.Form("cxyl")
		rs("qjws")=Request.Form("qjws")
		rs("clwg")=Request.Form("clwg")
		if Request.Form("ysghsj")<>"" then rs("ysghsj")=Request.Form("ysghsj")
		rs("Checker")=UserName
		rs("CheckerID")=UserID
		rs("CheckDate")=now()
		rs("CheckFlag")=1
		rs.update
		rs.close
		set rs=nothing 
		conn.execute("update MANA_Car set mileage_numeric="&Request.Form("hllcs")&" where car_brand='"&Request.Form("chepai")&"'")
		%>
{"status":true,"messages":"保存成功！"}
		<%
	end if
elseif ProcessType="doDel" then 
	sql="select * from MANA_Chuche where SerialNum="&Request.Form("SerialNum")
	set rs = server.createobject("adodb.recordset")
	rs.open sql,conn,1,3
	if rs.eof then
		response.Write("{""status"":false,""messages"":""对应记录不存在，删除失败！""}")
		response.End()
	elseif rs("checkflag")=1 then
		response.Write("{""status"":false,""messages"":""对应记录已审核，不允许删除！""}")
		response.End()
	elseif rs("ctflag")=1 then
		response.Write("{""status"":false,""messages"":""对应记录已计算，不允许删除！""}")
		response.End()
	else
		rs.delete
		rs.close
		set rs=nothing 
	end if
'	conn.execute("delete from MANA_Chuche where checkflag=0 and SerialNum in ("&Request("SerialNum")&")")
	response.Write("{""status"":true,""messages"":""删除成功！""}")
elseif ProcessType="unCheck" then 
	sql="select * from MANA_Chuche where SerialNum="&Request.Form("SerialNum")
	set rs = server.createobject("adodb.recordset")
	rs.open sql,conn,1,3
	if rs.eof then
		response.Write("{""status"":false,""messages"":""对应记录不存在，反审核失败！""}")
		response.End()
	elseif rs("checkflag")=0 then
		response.Write("{""status"":false,""messages"":""对应记录未审核，不允许反审核！""}")
		response.End()
	elseif rs("ctflag")=1 then
		response.Write("{""status"":false,""messages"":""对应记录已计算，不允许反审核！""}")
		response.End()
	else
		dim rs2
		set rs2=conn.execute("select 1 from MANA_Chuche a,MANA_Chuche b where a.chepai=b.chepai and datediff(n,b.cfsj,a.hlsj)<0 and a.SerialNum="&Request.Form("SerialNum"))
		if not rs2.eof then
			response.Write("{""status"":false,""messages"":""该车在此出车之后已经存在车辆调度，不允许反审核！""}")
			response.End()
		end if
		rs("checkflag")=0
		conn.execute("update MANA_Car set mileage_numeric="&rs("cflcs")&" where car_brand='"&rs("chepai")&"'")
		rs.update
		rs.close
		set rs=nothing 
	end if
	response.Write("{""status"":true,""messages"":""反审核成功！""}")
elseif ProcessType="hl" then 
	sql="select * from MANA_Chuche where SerialNum in ("&Request.Form("SerialNum")&")"
	set rs = server.createobject("adodb.recordset")
	rs.open sql,conn,1,3
	if rs.eof then
		response.Write("{""status"":false,""messages"":""对应记录不存在，删除失败！""}")
		response.End()
	end if
	while(not rs.eof)
		if rs("checkflag")=0 then
			response.Write("{""status"":false,""messages"":""对应记录未审核，不允许锁定！""}")
			response.End()
		elseif rs("ctflag")=1 then
			response.Write("{""status"":false,""messages"":""对应记录已计算，不允许锁定！""}")
			response.End()
		elseif rs("hlflag")=1 then
			response.Write("{""status"":false,""messages"":""对应记录已锁定，不允许重复锁定！""}")
			response.End()
		else
			rs("hlflag")=1
		end if
		rs.movenext
	wend
	rs.update
	rs.close
	set rs=nothing 
	response.Write("{""status"":true,""messages"":""锁定成功！""}")
elseif ProcessType="unhl" then 
	sql="select * from MANA_Chuche where SerialNum in ("&Request.Form("SerialNum")&")"
	set rs = server.createobject("adodb.recordset")
	rs.open sql,conn,1,3
	if rs.eof then
		response.Write("{""status"":false,""messages"":""对应记录不存在，删除失败！""}")
		response.End()
	end if
	while(not rs.eof)
		if rs("checkflag")=0 then
			response.Write("{""status"":false,""messages"":""对应记录未审核，不允许解锁！""}")
			response.End()
		elseif rs("ctflag")=1 then
			response.Write("{""status"":false,""messages"":""对应记录已计算，不允许解锁！""}")
			response.End()
		elseif rs("hlflag")=0 then
			response.Write("{""status"":false,""messages"":""对应记录已锁定，不允许重复解锁！""}")
			response.End()
		else
			rs("hlflag")=0
		end if
		rs.movenext
	wend
		rs.update
	rs.close
	set rs=nothing 
	response.Write("{""status"":true,""messages"":""解锁成功！""}")
elseif ProcessType="getDt" then 
	sql="select a.*,b.name as syrer,c.name as jsyer,d.fname as ycbmer from MANA_Chuche a left join AIS20091116143745.DBO.HM_Employees b on a.syr=b.code left join AIS20091116143745.DBO.HM_Employees c on a.jsy=c.code left join AIS20091116143745.DBO.t_department d on d.fnumber=a.ycbm where SerialNum="&request.Form("SerialNum")
	QueryToJSONOBJ conn,sql

elseif ProcessType="CarList" then 
	sql="select * from MANA_Car where status=1 and fygs='公司' and deleteFlag=0 order by car_brand"
	set rs=server.createobject("adodb.recordset")
	rs.open sql,conn,1,1
	%>
	{ "Rows": [
	<%
	do until rs.eof'填充数据到表格'
			Response.Write("{")
			for i=0 to rs.fields.count-1
				response.write (""""&rs.fields(i).name & """:"""&JsonStr(rs.fields(i).value)&"""")
				if i<rs.fields.count-1 then response.Write(",")
			next
			response.Write("}")
			rs.movenext()
			If Not rs.eof Then
				Response.Write ","
			End If
	loop
	response.Write"]}"
	rs.close
	set rs=nothing 
elseif ProcessType="ftList" then
	sql="exec Z_油费分配 '"&request("SDate")&"'"
	set rs=server.createobject("adodb.recordset")
	rs.open sql,conn,1,1
	dim tstr1,tstr2
	tstr1=""
	tstr2=""
	response.Write("<table width=""100%"" border=""0"" cellpadding=""3"" cellspacing=""1"" bgcolor=""#99BBE8"" style='font-size: 12px;'>")
	response.Write("<tr>")
	For Each col In rs.Fields
		if col.Name <>"差旅用" and col.Name <>"rn" then response.Write("<td width=80>"&col.Name&"</td>")
	Next
	response.Write("</tr>")
	while(not rs.eof)
		response.Write("<tr bgcolor='#EBF2F9'>")
		For Each col In rs.Fields
			if col.name="部门" then
				if col.value=tstr1 then
					response.Write("<td></td>")
				else
					response.Write("<td>"&col.value&"</td>")
					tstr1=col.value
				end if
			elseif col.name="使用人" then
				if col.value=tstr2 then
					response.Write("<td></td>")
				else
					response.Write("<td>"&col.value&"</td>")
					tstr2=col.value
				end if
			elseif col.Name <>"差旅用" and col.Name <>"rn" then 
				response.Write("<td>"&col.value&"</td>")
			end if
		Next
		rs.movenext
		response.Write("</tr>")
	wend
	response.Write("</table>")
	'// 释放对象 
	rs.close
	set rs=nothing 
elseif ProcessType="Export" then
	datawhere=request("where")
	if len(datawhere)>0 then datawhere=" where "&getwherestr(datawhere)

    sql="select a.*,b.name as syrer,c.name as jsyer,d.fname as ycbmer,case CheckFlag when 1 then '回车' else '出车' end as sfhc,case HLFlag when 1 then '是' else '否' end as sfsd from MANA_Chuche a left join AIS20091116143745.DBO.HM_Employees b on a.syr=b.code left join AIS20091116143745.DBO.HM_Employees c on a.jsy=c.code left join AIS20091116143745.DBO.fdepartment d on d.fnumber=a.ycbm"&datawhere
		response.Write(sql)
	set rs=server.createobject("adodb.recordset")
	rs.open sql,conn,1,1
	response.Write("<table width=""100%"" border=""0"" cellpadding=""3"" cellspacing=""1"" bgcolor=""#99BBE8"" style='font-size: 12px;'>")
	response.Write("<tr>")
	response.Write("<td width=80>车牌</td>")
	response.Write("<td width=80>出发时间</td>")
	response.Write("<td width=80>出发公里表</td>")
	response.Write("<td width=80>使用人</td>")
	response.Write("<td width=80>使用部门</td>")
	response.Write("<td width=80>驾驶员</td>")
	response.Write("<td width=80>事由及目的地</td>")
	response.Write("<td width=80>费用类别</td>")
	response.Write("<td width=80>状态</td>")
	response.Write("<td width=80>锁定</td>")
	response.Write("<td width=80>回来时间</td>")
	response.Write("<td width=80>回来公里表</td>")
	response.Write("<td width=80>使用公里数</td>")
	response.Write("<td width=80>费用金额</td>")
	response.Write("<td width=80>备注</td>")
	response.Write("<td width=80>登记人</td>")
	response.Write("<td width=80>登记时间</td>")
	response.Write("</tr>")

	while(not rs.eof)
		response.Write("<tr bgcolor='#EBF2F9'>")
		response.Write("<td>"&rs("chepai")&"</td>")
		response.Write("<td>"&rs("cfsj")&"</td>")
		response.Write("<td>"&rs("cflcs")&"</td>")
		response.Write("<td>"&rs("syrer")&"</td>")
		response.Write("<td>"&rs("ycbmer")&"</td>")
		response.Write("<td>"&rs("jsyer")&"</td>")
		response.Write("<td>"&rs("syjmdd")&"</td>")
		response.Write("<td>"&rs("fylb")&"</td>")
		response.Write("<td>"&rs("sfhc")&"</td>")
		response.Write("<td>"&rs("sfsd")&"</td>")
		response.Write("<td>"&rs("hlsj")&"</td>")
		response.Write("<td>"&rs("hllcs")&"</td>")
		response.Write("<td>"&rs("sylcs")&"</td>")
		response.Write("<td>"&rs("fyje")&"</td>")
		response.Write("<td>"&rs("memo")&"</td>")
		response.Write("<td>"&rs("Biller")&"</td>")
		response.Write("<td>"&rs("BillDate")&"</td>")
		rs.movenext
		response.Write("</tr>")
	wend
	response.Write("</table>")
	'// 释放对象 
	rs.close
	set rs=nothing 
end if
conn.close()
set conn=nothing
 %>
