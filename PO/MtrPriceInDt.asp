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
      datafrom=" PO_MtrPriceIn "
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
{"page":"<%=page%>","total":"<%=idcount%>","rows":[
<%
  if sqlid<>"" then'如果记录总数=0,则不处理
    '用in刷选本页所语言的数据,仅读取本页所需的数据,所以速度快
    sql="select * from "& datafrom &" where SerialNum in("& sqlid &") "&taxis
    set rs=server.createobject("adodb.recordset")
    rs.open sql,conn,1,1
    do until rs.eof'填充数据到表格'
%>		
		{"id":"<%=rs("SerialNum")%>",
		"cell":["<%=rs("FNumber")%>","<%=rs("MtrPrice")%>","<%=rs("Biller")%>","<%=rs("BillerID")%>","<%=rs("InTime")%>"]}
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
elseif ProcessType="xls2sql" then
'	Server.ScriptTimeout = 99
	dim fileurl
	fileurl=request("fileurl")
	set excelconn=server.createobject("adodb.connection")
	set excelrs=server.createobject("adodb.recordset")
	excelconn.open "Provider=Microsoft.Jet.OLEDB.4.0;Extended Properties=Excel 8.0;Data Source=" & Server.mappath(fileurl)
'	Rem HDR 默认为YES,表示第一行作为字段名, 否则视它为内容 ""Excel 8.0;HDR=YES""
'	Rem 对于Excel2007,而应为: "Provider=Microsoft.ACE.OLEDB.12.0; Extended Properties=Excel 12.0;Data Source=xxx.xlsx;"
	sql="select * from [Sheet1$]"
	excelrs.open sql,excelconn,1,1
	i=0
	Do While Not excelrs.EOF
		set rs=server.createobject("adodb.recordset")
		dim sql2
		sql2="select fplanprice from test2.dbo.t_icitem where fnumber='"&excelrs("物料长代码")&"' and ferpclsid=1"
		rs.open sql2,conn,1,1
		if not rs.eof then
			i=i+1  
			conn.execute("update test2.dbo.t_icitem set fplanprice="&excelrs("物料单价")&" where fnumber='"&excelrs("物料长代码")&"'")
			conn.execute("insert into PO_MtrPriceIn (FNumber,MtrPrice,Biller,BillerID,InTime) values ('"&excelrs("物料长代码")&"','"&iif(excelrs("物料单价")="",0,excelrs("物料单价"))&"','"&UserName&"','"&UserID&"',getdate())")
		end if
		excelrs.movenext
	loop
	rs.close()
	set rs=nothing
	excelrs.close()
  set excelrs=nothing
  excelconn.Close()
	set excelconn=nothing
	response.Write("{""status"":true,""messages"":""共计"&i&"条数据导入成功！""}")
end if
Set Conn = Nothing
 %>
