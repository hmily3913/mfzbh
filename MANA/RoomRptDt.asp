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
elseif ProcessType="showData" then
	sql="select date from Calendar where year(date)="&request.Form("Year")&" and weeknum="&request.Form("Weeks")&" order by weekday"
	set rs=server.createobject("adodb.recordset")
	rs.open sql,conn,1,1
	dim sql1,sql2
	i=1
	sql1="select a.roomno as 房间号,b.bedid as 床位号"
	while(not rs.eof)
		sql1=sql1&",isnull(dbo.fn_Merge(b.SerialNum,'"&rs("date")&"'),'未入住') as '"&rs("date")&"' "
		i=i+1
		rs.movenext
	wend
	set rs=server.createobject("adodb.recordset")
	sql=sql1&sql2
	sql=sql&" from MANA_Room a inner join MANA_bed b on b.ssnum=a.serialNum  "
	if request.form("RoomNo") then sql=sql&" where a.roomno like '%"&request.Form("RoomNo")&"%' "
	sql=sql&"  group by a.roomno,b.bedid,b.SerialNum order by a.roomno,b.bedid "
	rs.open sql,conn,1,1
	
	response.Write("<table width=""100%"" border=""0"" cellpadding=""3"" id=""listtable"" cellspacing=""1"" bgcolor=""#000000"" style='font-size: 12px;'>")
	response.Write("<tr bgcolor='#99BBE8'>")
	For Each col In rs.Fields
		response.Write("<td width=80>"&col.Name&"</td>")
	Next
	response.Write("</tr>")
	dim temstr
	temstr=""
	while(not rs.eof)
		if temstr<>rs("房间号") then
		temstr=rs("房间号")
		response.Write("<tr bgcolor='#EBF2F9' style=""border-top:solid 1px #FFF"">")
		else
		response.Write("<tr bgcolor='#EBF2F9'>")
		end if
		For Each col In rs.Fields
			if col.name="房间号" or col.name="床位号" then
				response.Write("<td>"&col.value&"</td>")
			elseif col.value="未入住" then
				response.Write("<td><font color=red>"&col.value&"</font></td>")
			else
				response.Write("<td><font color=blue>"&col.value&"</font></td>")
			end if
		Next
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
