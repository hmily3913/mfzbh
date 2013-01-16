<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<!--#include file="../../Include/NoSqlHack.Asp" -->
<!--#include file="../../Include/ConnSiteData.asp" -->
<!--#include file="../../CheckAdmin.asp" -->
<!--#include file="../../Include/Function.asp" -->
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
if ProcessType="getTables" then
	dim sql,rs
		sql="select name from sys.objects where type_desc='"&request("type_desc")&"' order by modify_date desc"
		
		set rs=server.createobject("adodb.recordset")
		rs.open sql,conn,1,1
		response.write "["
		do until rs.eof
			Response.Write("{""id"":"""&rs("name")&""",""text"":"""&rs("name")&"""}")
	    rs.movenext
		If Not rs.eof Then
		  Response.Write ","
		End If
    loop
		Response.Write("]")
		rs.close
		set rs=nothing 
elseif ProcessType="getTableDetail" then
		sql="select * from sys.columns where object_id = object_id(N'dbo."&request("TableName")&"') order by column_id"
		
		set rs=server.createobject("adodb.recordset")
		rs.open sql,conn,1,1
		response.write "["
		do until rs.eof
			Response.Write("{ ""isInPrimaryKey"": false, ""isInForeignKey"": false, ""isNullable"":"& LCase(cstr(rs("is_nullable")))&", ""inputType"":"""& DataTypeName(rs("user_type_id"))&""", ""isAutoKey"": "&LCase(cstr(rs("is_identity")))&", ""sourceTableName"": """", ""sourceTableIDField"": """", ""sourceTableTextField"": """", ""name"": """&rs("name")&""", ""text"": """&rs("name")&""", ""type"": ""column"", ""icon"": ""images/table_key.png"" }")
	    rs.movenext
		If Not rs.eof Then
		  Response.Write ","
		End If
    loop
		Response.Write("]")
		rs.close
		set rs=nothing 
end if
Set Conn = Nothing
 %>
