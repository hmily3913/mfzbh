<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>

<% Option Explicit %>
<HTML>
<HEAD>
<META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=utf-8" />
<META NAME="copyright" CONTENT="Copyright 2011-2012" />
<META NAME="Author" CONTENT="zbh" />
<META NAME="Keywords" CONTENT="" />
<META NAME="Description" CONTENT="" />
<TITLE>员工列表</TITLE>
<link rel="stylesheet" href="../Images/CssAdmin.css">
<script language="javascript" src="../Script/Admin.js"></script>
</HEAD>
<!--#include file="../Include/ConnSiteData.asp" -->
<!--#include file="../CheckAdmin.asp"-->
<%
'if Instr(session("AdminPurview"),"|1502,")=0 then 
'  response.write ("<font color='red')>你不具有该管理模块的操作权限，请返回！</font>")
'  response.end
'end if
'========判断是否具有管理权限
%>
<BODY>
<table width="100%" border="0" cellpadding="3" cellspacing="1" bgcolor="#99BBE8">
    <tr>
      <td nowrap bgcolor="#8DB5E9"><font color="#FFFFFF"><strong>序号</strong></font></td>
      <td nowrap bgcolor="#8DB5E9"><font color="#FFFFFF"><strong>开始</strong></font></td>
      <td nowrap bgcolor="#8DB5E9"><font color="#FFFFFF"><strong>结束</strong></font></td>
	</tr>
<%
  dim rs,sql,rs1,sql1'sql语句
  '获取记录总数
	sql="select top 10 * from OperationLog order by serialnum desc"
  set rs=server.createobject("adodb.recordset")
  rs.open sql,connzxpt,0,1
  while(not rs.eof)
	  Response.Write "<tr bgcolor='#EBF2F9' onMouseOver = ""this.style.backgroundColor = '#FFFFFF'"" onMouseOut = ""this.style.backgroundColor = ''"" style='cursor:hand'>" & vbCrLf
      Response.Write "<td nowrap>"&rs("serialnum")&"</td>" & vbCrLf
      Response.Write "<td nowrap>"&rs("ReptUpsDate")&"</td>" & vbCrLf
      Response.Write "<td nowrap>"&rs("ReptUpeDate")&"</td>" & vbCrLf
      Response.Write "</tr>" & vbCrLf
    rs.movenext
  wend
  rs.close
  set rs=nothing
%>
</table>
<table width="100%" border="0" cellpadding="3" cellspacing="1" bgcolor="#99BBE8">
    <tr>
      <td nowrap bgcolor="#8DB5E9"><font color="#FFFFFF"><strong>序号</strong></font></td>
      <td nowrap bgcolor="#8DB5E9"><font color="#FFFFFF"><strong>用户名</strong></font></td>
      <td nowrap bgcolor="#8DB5E9"><font color="#FFFFFF"><strong>姓名</strong></font></td>
      <td nowrap bgcolor="#8DB5E9"><font color="#FFFFFF"><strong>最后活动时间</strong></font></td>
      <td nowrap bgcolor="#8DB5E9"><font color="#FFFFFF"><strong>状态</strong></font></td>
      <td nowrap bgcolor="#8DB5E9"><font color="#FFFFFF"><strong>IP</strong></font></td>
      <td nowrap bgcolor="#8DB5E9"><font color="#FFFFFF"><strong>系统</strong></font></td>
      <td nowrap bgcolor="#8DB5E9"><font color="#FFFFFF"><strong>浏览器</strong></font></td>
	</tr>
<%

	sql="select * from smmsys_Online  order by o_lasttime desc"
  set rs=server.createobject("adodb.recordset")
  rs.open sql,connzxpt,1,1
	dim i:i=0
  while(not rs.eof)
		i=i+1
		dim tempstr:tempstr="离开"
		if rs("o_state")=1 then tempstr="在线"
	  Response.Write "<tr bgcolor='#EBF2F9' onMouseOver = ""this.style.backgroundColor = '#FFFFFF'"" onMouseOut = ""this.style.backgroundColor = ''"" style='cursor:hand'>" & vbCrLf
      Response.Write "<td nowrap>"&i&"</td>" & vbCrLf
      Response.Write "<td nowrap>"&rs("UserName")&"</td>" & vbCrLf
      Response.Write "<td nowrap>"&rs("AdminName")&"</td>" & vbCrLf
      Response.Write "<td nowrap>"&rs("o_lasttime")&"</td>" & vbCrLf
      Response.Write "<td nowrap>"&tempstr&"</td>" & vbCrLf
      Response.Write "<td nowrap>"&rs("o_ip")&"</td>" & vbCrLf
      Response.Write "<td nowrap>"&system(rs("LoginSoft"))&"</td>" & vbCrLf
      Response.Write "<td nowrap>"&browser(rs("LoginSoft"))&"</td>" & vbCrLf
      Response.Write "</tr>" & vbCrLf
    rs.movenext
  wend
  rs.close
  set rs=nothing
%>
</table>
</body>
</html>
