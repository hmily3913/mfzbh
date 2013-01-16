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
	if session("GZSucces")="" or not session("GZSucces") then
		response.Write("{""status"":false,""messages"":""验证未通过，无法进行查询！""}")
		response.End()
	end if
  dim page'页码
      page=clng(request("page"))
  dim idCount'记录总数
  dim pages'每页条数
      pages=request("rp")
  dim pagec'总页数

  dim datafrom'数据表名
      datafrom=" hr_Salary "
  dim datawhere'数据条件
  dim i'用于循环的整数
	Dim searchterm,searchcols
	datawhere=" where 1=1 "
	if not CHKOnePermiss(request.servervariables("PATH_INFO"),"ShowAll") then
		datawhere=datawhere&" and UserID='"&UserID&"' "
	end if
	if Request("UserID") <> "" then datawhere=datawhere&" and UserID like '%"&Request("UserID")&"%' "
	if Request("UserName") <> "" then datawhere=datawhere&" and UserName like '%"&Request("UserName")&"%' "
	if Request("Years") <> "" then datawhere=datawhere&" and Years = '"&Request("Years")&"' "
	if Request("Months") <> "" then datawhere=datawhere&" and Months = '"&Request("Months")&"' "
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
		"cell":["<%=rs("Years")%>","<%=rs("Months")%>","<%=rs("Userid")%>","<%=JsonStr(rs("UserName"))%>","<%=JsonStr(rs("ZZYX"))%>","<%=rs("YJ")%>","<%=rs("JBGZ")%>","<%=rs("BFGZ")%>","<%=rs("KJGZ")%>","<%=rs("YFGZ")%>","<%=rs("TQF")%>","<%=rs("YFXJ")%>","<%=rs("DKGRSHBX")%>","<%=rs("DKGRSDS")%>","<%=rs("DKGHHF")%>","<%=rs("DKCF")%>","<%=rs("DKSF")%>","<%=rs("DKDF")%>","<%=rs("ZFYJ")%>","<%=rs("DKQT")%>","<%=rs("SFJE")%>"]}
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
elseif ProcessType="setPassword" then 
	if session("GZSucces")="" or not session("GZSucces") then
'		response.Write(session("GZPassword"))
		response.Write("{""status"":false,""messages"":""验证未通过，无法设置密码！""}")
		response.End()
	end if
	if Request.Form("password")<>Request.Form("passwordconf") then
		response.Write("{""status"":false,""messages"":""两次密码不一次，设置失败！""}")
		response.End()
	end if
	set rs = server.createobject("adodb.recordset")
	sql="select * from sys_Users where UserID='"&Request.Form("UserID")&"'"
	rs.open sql,conn,1,3
	rs("GZPassword")=md5(Request.Form("password"))
	rs.update
	rs.close
	set rs=nothing 
	response.Write("{""status"":true,""messages"":""密码设置成功，此密码只对工资查询有效！""}")
elseif ProcessType="GZLogin" then
	set rs = server.createobject("adodb.recordset")
	sql="select * from sys_Users where UserID='"&UserID&"'"
	rs.open sql,conn,1,1
	if rs.eof then
		response.Write("{""status"":false,""messages"":""帐号不正确，请重新登录！""}")
		response.End()
	elseif isnull(rs("GZPassword")) or rs("GZPassword")="" then
		session("GZSucces")=true
		response.Write("{""status"":true,""messages"":""验证通过，未设置密码，为了个人保密信息请设置密码！""}")
		response.End()
	elseif  rs("GZPassword")=md5(Request.Form("password")) then
		session("GZSucces")=true
		response.Write("{""status"":true,""messages"":""验证通过，可进行工资查询！""}")
		response.End()
	else
		session("GZSucces")=false
		response.Write("{""status"":false,""messages"":""密码错误，禁止工资查询！""}")
		response.End()
	end if
elseif ProcessType="DelSalary" then
	conn.execute("delete from hr_Salary  where SerialNum in ("&request("SerialNum")&")")
	response.Write("{""status"":true,""messages"":""删除成功！""}")
elseif ProcessType="xls2sql" then
'	Server.ScriptTimeout = 99
	dim fileurl
	fileurl=request("fileurl")
	set excelconn=server.createobject("adodb.connection")
	set excelrs=server.createobject("adodb.recordset")
	excelconn.open "Provider=Microsoft.Jet.OLEDB.4.0;Data Source=" & Server.mappath(fileurl)&";Extended Properties=""Excel 8.0;HDR=Yes;IMEX=1"""
'	excelconn.open "Data Provider=MSDASQL.1;driver=Microsoft Excel Driver (*.xls);DBQ=" & Server.mappath(fileurl)
	sql="select * from [Sheet1$]"
	excelrs.open sql,excelconn,1,1
	i=0
	Do While not excelrs.eof
		if trim(excelrs("姓名"))<>"" then
			i=i+1  
			conn.execute("insert into hr_Salary (UserID,UserName,Years,Months,ZZYX,YJ,JBGZ,BFGZ,KJGZ,YFGZ,TQF,YFXJ,DKGRSHBX,DKGRSDS,DKGHHF,DKCF,DKSF,DKDF,ZFYJ,DKQT,SFJE) values ('"&excelrs("工号")&"','"&excelrs("姓名")&"','"&excelrs("年份")&"','"&excelrs("月份")&"',"&_
			iif((excelrs("资质月薪")="" or isnull(excelrs("资质月薪"))),0,excelrs("资质月薪"))&","&_
			iif((excelrs("月奖")="" or isnull(excelrs("月奖"))),0,excelrs("月奖"))&","&_
			iif((excelrs("加班")="" or isnull(excelrs("加班"))),0,excelrs("加班"))&","&_
			iif((excelrs("补发")="" or isnull(excelrs("补发"))),0,excelrs("补发"))&","&_
			iif((excelrs("扣罚")="" or isnull(excelrs("扣罚"))),0,excelrs("扣罚"))&","&_
			iif((excelrs("应发工资")="" or isnull(excelrs("应发工资"))),0,excelrs("应发工资"))&","&_
			iif((excelrs("通勤费")="" or isnull(excelrs("通勤费"))),0,excelrs("通勤费"))&","&_
			iif((excelrs("月发小计")="" or isnull(excelrs("月发小计"))),0,excelrs("月发小计"))&","&_
			iif((excelrs("代扣个人社保费")="" or isnull(excelrs("代扣个人社保费"))),0,excelrs("代扣个人社保费"))&","&_
			iif((excelrs("代扣个人所得税")="" or isnull(excelrs("代扣个人所得税"))),0,excelrs("代扣个人所得税"))&","&_
			iif((excelrs("代扣工会会费")="" or isnull(excelrs("代扣工会会费"))),0,excelrs("代扣工会会费"))&","&_
			iif((excelrs("代扣餐费")="" or isnull(excelrs("代扣餐费"))),0,excelrs("代扣餐费"))&","&_
			iif((excelrs("水费")="" or isnull(excelrs("水费"))),0,excelrs("水费"))&","&_
			iif((excelrs("电费")="" or isnull(excelrs("电费"))),0,excelrs("电费"))&","&_
			iif((excelrs("住房费")="" or isnull(excelrs("住房费"))),0,excelrs("住房费"))&","&_
			iif((excelrs("代扣其他")="" or isnull(excelrs("代扣其他"))),0,excelrs("代扣其他"))&","&_
			iif((excelrs("实付金额")="" or isnull(excelrs("实付金额"))),0,excelrs("实付金额"))&")")		
		end if
		excelrs.movenext
	loop
	excelrs.close()
  set excelrs=nothing
  excelconn.Close()
	set excelconn=nothing
	response.Write("{""status"":true,""messages"":""共计"&i&"条数据导入成功！""}")
elseif ProcessType="PrintSly" then
	set rs = server.createobject("adodb.recordset")
	sql="select * from hr_Salary where 1=1 "
	if Request("UserID") <> "" then sql=sql&" and UserID like '%"&Request("UserID")&"%' "
	if Request("UserName") <> "" then sql=sql&" and UserName like '%"&Request("UserName")&"%' "
	if Request("Years") <> "" then sql=sql&" and Years = '"&Request("Years")&"' "
	if Request("Months") <> "" then sql=sql&" and Months = '"&Request("Months")&"' "
	rs.open sql,conn,1,1
	response.Write("<table border=1>")
	while not rs.eof
		%>
    <tr style="font:bold;" align='center'>
    <td>月份</td>
    <td>工号</td>
    <td>姓名</td>
    <td>资质月薪</td>
    <td>月奖</td>
    <td>加班</td>
    <td>补发</td>
    <td>扣罚</td>
    <td>应发工资</td>
    <td>通勤费</td>
    <td>月发小计</td>
    <td>代扣个人社保费</td>
    <td>代扣个人所得税</td>
    <td>代扣工会会费</td>
    <td>代扣餐费</td>
    <td>水费</td>
    <td>电费</td>
    <td>住房费</td>
    <td>代扣其他</td>
    <td>实付金额</td>
    </tr>
    <tr align='center'>
    <td><%=rs("Years")%>.<%=rs("Months")%></td>
    <td><%=rs("UserID")%></td>
    <td><%=rs("UserName")%></td>
    <td><%=rs("ZZYX")%></td>
    <td><%=rs("YJ")%></td>
    <td><%=rs("JBGZ")%></td>
    <td><%=rs("BFGZ")%></td>
    <td><%=rs("KJGZ")%></td>
    <td><%=rs("YFGZ")%></td>
    <td><%=rs("TQF")%></td>
    <td><%=rs("YFXJ")%></td>
    <td><%=rs("DKGRSHBX")%></td>
    <td><%=rs("DKGRSDS")%></td>
    <td><%=rs("DKGHHF")%></td>
    <td><%=rs("DKCF")%></td>
    <td><%=rs("DKSF")%></td>
    <td><%=rs("DKDF")%></td>
    <td><%=rs("ZFYJ")%></td>
    <td><%=rs("DKQT")%></td>
    <td><%=rs("SFJE")%></td>
    </tr>
		<%
		rs.movenext
	wend
	response.Write("</table>")
	rs.close
	set rs=nothing
end if
Conn.close
Set Conn = Nothing
 %>
