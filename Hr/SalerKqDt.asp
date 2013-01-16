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
if ProcessType="SumList" then 
%>
  <table width="100%" bodysize="1" cellspacing="0" cellpadding="0" border="1px solid" id="listtable">
      <tr>
        <td height="25" width="30" align="center" valign="middle"><span class="STYLE3 STYLE1">序号</span></td>
        <td height="25" align="center" valign="middle"><span class="STYLE3 STYLE1">姓名</span></td>
        <td height="25" align="center" valign="middle"><span class="STYLE3 STYLE1">手机号</span></td>
        <td width="50" height="25" align="center" valign="middle"><span class="STYLE3 STYLE1">出勤次数</span></td>
<%
		For i = 1 To 31
			if cInt(right(cstr(DateSerial(request("y"),request("m")+1,0)),2))>=i then
			
				if Weekday(request("y")+"-"+request("m")+"-"+cstr(i))=1 then
		%>
		<td width="30" height="25" align="center" valign="middle" bgcolor="#959595"><%=i%>日</td>
		<%
				else
		%>
		<td width="30" height="25" align="center" valign="middle"><%=i%>日</td>
		<%
				end if
			else
		%>
		<td width="30" height="25" align="center" valign="middle"><%=i%>日</td>
		<%
			end if
		next
%>      
      </tr>
	  <%

      sql="select a.mobi,b.xingming,sum(1) as ct0,sum(case day(shijian) when 1 then 1 else 0 end) as ct1 "&_
",sum(case day(shijian) when 2 then 1 else 0 end) as ct2 "&_
",sum(case day(shijian) when 3 then 1 else 0 end) as ct3 "&_
",sum(case day(shijian) when 4 then 1 else 0 end) as ct4 "&_
",sum(case day(shijian) when 5 then 1 else 0 end) as ct5 "&_
",sum(case day(shijian) when 6 then 1 else 0 end) as ct6 "&_
",sum(case day(shijian) when 7 then 1 else 0 end) as ct7 "&_
",sum(case day(shijian) when 8 then 1 else 0 end) as ct8 "&_
",sum(case day(shijian) when 9 then 1 else 0 end) as ct9 "&_
",sum(case day(shijian) when 10 then 1 else 0 end) as ct10 "&_
",sum(case day(shijian) when 11 then 1 else 0 end) as ct11 "&_
",sum(case day(shijian) when 12 then 1 else 0 end) as ct12 "&_
",sum(case day(shijian) when 13 then 1 else 0 end) as ct13 "&_
",sum(case day(shijian) when 14 then 1 else 0 end) as ct14 "&_
",sum(case day(shijian) when 15 then 1 else 0 end) as ct15 "&_
",sum(case day(shijian) when 16 then 1 else 0 end) as ct16 "&_
",sum(case day(shijian) when 17 then 1 else 0 end) as ct17 "&_
",sum(case day(shijian) when 18 then 1 else 0 end) as ct18 "&_
",sum(case day(shijian) when 19 then 1 else 0 end) as ct19 "&_
",sum(case day(shijian) when 20 then 1 else 0 end) as ct20 "&_
",sum(case day(shijian) when 21 then 1 else 0 end) as ct21 "&_
",sum(case day(shijian) when 22 then 1 else 0 end) as ct22 "&_
",sum(case day(shijian) when 23 then 1 else 0 end) as ct23 "&_
",sum(case day(shijian) when 24 then 1 else 0 end) as ct24 "&_
",sum(case day(shijian) when 25 then 1 else 0 end) as ct25 "&_
",sum(case day(shijian) when 26 then 1 else 0 end) as ct26 "&_
",sum(case day(shijian) when 27 then 1 else 0 end) as ct27 "&_
",sum(case day(shijian) when 28 then 1 else 0 end) as ct28 "&_
",sum(case day(shijian) when 29 then 1 else 0 end) as ct29 "&_
",sum(case day(shijian) when 30 then 1 else 0 end) as ct30 "&_
",sum(case day(shijian) when 31 then 1 else 0 end) as ct31 "&_
"from mfsms.dbo.kqtable a,(select mobi,xingming,ROW_NUMBER() OVER(PARTITION BY mobi ORDER BY shijian) as zz "&_
"from mfsms.dbo.kqtable where year(shijian)="&request("y")&" and month(shijian)="&request("m")&") b  "&_
"where year(a.shijian)="&request("y")&" and month(a.shijian)="&request("m")&" "&_
"and a.mobi=b.mobi and b.zz=1 "&_
"group by a.mobi,b.xingming "&_
"order by b.xingming "
	set rs=server.createobject("adodb.recordset")
	rs.open sql,conn,1,1
	dim x:x=1
	do while not rs.eof
	  mobi=rs("mobi")
	  %>
      <tr>
        <td height="36" align="center" valign="middle"><span class="STYLE3 STYLE1">
		<%response.Write(x)%>
		</span></td>
        <td height="36" align="center" valign="middle"><span class="STYLE3 STYLE1">
		<%response.Write(rs("xingming"))%>
		</span></td>
        <td align="center" valign="middle"><A href="javascript:f_open('<%=rs("mobi")%>');"><span class="STYLE3 STYLE1"><%=rs("mobi")%></span></a></td>
        <td align="center" valign="middle">
		  <span class="STYLE1">
		<%
		dim ct0:ct0=0
		For i = 1 To 31
			if rs("ct"&i)>0 then ct0=ct0+1
		next
		response.Write(ct0)
		%>
		  </span></td>
<%
		For i = 1 To 31
			dim resstr
				resstr
			if rs("ct"&i)=0 then
				resstr="<font color='#FF0000'>"+cstr(rs("ct"&i))+"</font>"
			else
				resstr=cstr(rs("ct"&i))
			end if
			
			if cint(right(cstr(DateSerial(request("y"),request("m")+1,0)),2))>=i then
				if Weekday(request("y")+"-"+request("m")+"-"+cstr(i))=1 then
		%>
		<td align="center" valign="middle" bgcolor="#959595"><%response.Write(resstr)%></td>
		<%
				else
		%>
		<td align="center" valign="middle"><%response.Write(resstr)%></td>
		<%
				end if
			else
		%>
		<td align="center" valign="middle"><%response.Write(resstr)%></td>
		<%
			end if
		next
        x=x+1
		rs.movenext
		loop
      %>
  </table>
		  <%
  rs.close
  set rs=nothing
'QueryToJSON(conn, sql).Flush
elseif ProcessType="List" then 
y=request("y")
m=request("m")
mobi=request("mobi")
set rs=server.createobject("adodb.recordset")
sql="select mobi,xingming,shiduan,shijian,neirong from mfsms.dbo.kqtable where year(shijian)="&y&" and month(shijian)="&m&" and mobi='"&mobi&"' order by shijian"
rs.open sql,conn,1,1
k=1
%>
  <p><%=rs("xingming")%>在<%=y%>年<%=m%>月的详细考勤记录如下：</p>
  <table width="98%" bodysize="1" cellspacing="0" cellpadding="0" border="1px solid" style="font-size:12px;">
    <tr>
      <td width="40" height="25" align="center" valign="middle"><span class="STYLE2">序号</span></td>
      <td width="86" height="25" align="center" valign="middle"><span class="STYLE2">姓名</span></td>
      <td width="126" align="center" valign="middle"><span class="STYLE2">手机号</span></td>
      <td width="89" align="center" valign="middle"><span class="STYLE2">时段</span></td>
      <td width="148" align="center" valign="middle"><span class="STYLE2">汇报时间</span></td>
      <td width="40" align="center" valign="middle"><span class="STYLE2">星期</span></td>
	  <td width="319" align="center" valign="middle"><span class="STYLE2">汇报内容</span></td>
    </tr>
	<%
	do while not rs.eof
	if weekday(rs("shijian"))=1 then
	%>
    <tr>
      <td height="25" align="center" valign="middle" bgcolor="#959595"><span class="STYLE2"><%=k%></span></td>
      <td height="25" align="center" valign="middle" bgcolor="#959595"><span class="STYLE2"><%=rs("xingming")%></span></td>
      <td align="center" valign="middle" bgcolor="#959595"><span class="STYLE2"><%=rs("mobi")%></span></td>
      <td align="center" valign="middle" bgcolor="#959595"><span class="STYLE2"><%=rs("shiduan")%></span></td>
      <td align="center" valign="middle" bgcolor="#959595"><span class="STYLE2"><%=rs("shijian")%></span></td>
      <td align="center" valign="middle" bgcolor="#959595"><span class="STYLE2"><%=right(WeekdayName(Weekday(rs("shijian"))),1)%></span></td>
	  <td align="center" valign="middle" bgcolor="#959595"><span class="STYLE2"><%=rs("neirong")%></span></td>
    </tr>
	<%
	else
	%>
    <tr>
      <td height="25" align="center" valign="middle"><span class="STYLE2"><%=k%></span></td>
      <td height="25" align="center" valign="middle"><span class="STYLE2"><%=rs("xingming")%></span></td>
      <td align="center" valign="middle"><span class="STYLE2"><%=rs("mobi")%></span></td>
      <td align="center" valign="middle"><span class="STYLE2"><%=rs("shiduan")%></span></td>
      <td align="center" valign="middle"><span class="STYLE2"><%=rs("shijian")%></span></td>
      <td align="center" valign="middle"><span class="STYLE2"><%=right(WeekdayName(Weekday(rs("shijian"))),1)%></span></td>
	  <td align="center" valign="middle"><span class="STYLE2"><%=rs("neirong")%></span></td>
    </tr>
	<%
	end if
	k=k+1
	rs.movenext
	loop
	
	%>
  </table>
  <%

end if
conn.close()
set conn=nothing
 %>
