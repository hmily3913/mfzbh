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
if ProcessType="getData1" then 
  sql=" select 月份,round(sum(a1),0) as 前年销售额,round(sum(a2),0) as 去年销售额,round(sum(a3),0) as 今年销售额 from "&_ 
"	(select month(v1.FDate) as 月份, "&_
"	case when year(v1.FDate)=year(getdate())-2 then isnull(v2.fentryselfi0463,0)/(1+v2.FTaxRate/100)+FAmount else 0 end as a1, "&_
"	case when year(v1.FDate)=year(getdate())-1 then isnull(v2.fentryselfi0463,0)/(1+v2.FTaxRate/100)+FAmount else 0 end as a2, "&_
"	case when year(v1.FDate)=year(getdate()) then isnull(v2.fentryselfi0463,0)/(1+v2.FTaxRate/100)+FAmount else 0 end as a3  "&_
" from AIS20091116143745.dbo.ICSale v1 inner Join AIS20091116143745.dbo.ICSaleEntry v2 On v1.FInterID=v2.FInterID inner join AIS20091116143745.dbo.t_submessage z on z.ftypeid=101 and v1.FSaleStyle=z.Finterid  "&_
" where v1.FTranType in (80,86) and (z.FName='赊销' or z.FName='零售') and v1.FDate>cast(year(getdate())-3 as varchar(4))+'-01-01' and v1.FDate<=getdate() and (ISNULL(v1.FCancelLation, 0) = 0) AND (v1.FCheckerID > 0)) aaa "&_
" group by 月份 order by 月份" 
	set rs=server.createobject("adodb.recordset")
	rs.open sql,conn,1,1
	response.write "["
	do until rs.eof
		dim i
		response.Write("{""Monthdata"":[")
	  for i=0 to rs.fields.count-2
		response.write ("{""name"":"""&rs.fields(i).name & """,""value"":"""&rs.fields(i).value&"""},")
	  next
		response.write ("{""name"":"""&rs.fields(i).name & """,""value"":"""&rs.fields(i).value&"""}]}")
		rs.movenext
	If Not rs.eof Then
		Response.Write ","
	End If
	loop
	response.Write("]")
  rs.close
  set rs=nothing
'QueryToJSON(conn, sql).Flush
end if
conn.close()
set conn=nothing
 %>
