<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<!--#include file="../Include/ConnSiteData.asp" -->
<!--#include file="../Include/NoSqlHack.Asp" -->
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
if ProcessType="EmpGrid" then 
  dim page'页码
      page=clng(request("page"))
  dim idCount'记录总数
  dim pages'每页条数
      pages=request("pagesize")
  dim pagec'总页数

  dim datafrom'数据表名
      datafrom="(select b.FItemid as SerialNum,b.code as id,b.code+'/'+b.name as text,isnull(e.code,'0') as pId,e.name as pName,b.name as empname,case sex when 1 then '男' else '女' end as sex from  AIS20091116143745.DBO.HR_Base_Emp b "&_
			" inner join AIS20091116143745.DBO.ORG_Position_Employee c on c.EmID = b.EM_ID and b.status=1 and b.FIsHREmp = 1 "&_
			" inner join AIS20091116143745.DBO.ORG_Position d on c.PositionID = d.ID "&_
			" inner join AIS20091116143745.DBO.ORG_Unit e on e.ID = d.UnitID where b.status=1 and b.FIsHREmp = 1 ) ttt "
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
    sql="select * from  "& datafrom &" where SerialNum in("& sqlid &") "&taxis
		QueryToJSON(conn, sql).Flush
  end if
  rs.close
  set rs=nothing
response.Write"}"
'-----------------------------------------------------------'
elseif ProcessType="CustGrid" then 
  sql="select isnull(a.UserNumber,'') as fnumber from sys_Users a,sys_PermissionGroupDetails b where a.UserID=b.userid and b.GroupSnum=9 and a.UserID='"&UserID&"'"
  set rs=server.createobject("adodb.recordset")
	rs.open sql,conn,0,1
	dim whadd
	whadd=""
	if not rs.eof then
		if rs("fnumber")<>"" then whadd=" and c.fnumber='"&rs("fnumber")&"' "
	end if
      page=clng(request("page"))
      pages=request("pagesize")
      datafrom="(select b.FItemid as SerialNum,b.FItemid as id,b.FNumber+'/'+b.FName as text,b.FNumber,b.FName as custName,c.FName as empname,d.fname as departname from  AIS20091116143745.DBO.t_Organization b "&_
			" left join AIS20091116143745.DBO.t_emp c on c.FItemid = b.FEmployee "&_
			" left join AIS20091116143745.DBO.t_department d on d.FItemid = b.FDepartment "&_
			" where b.FDeleted=0 and b.fflat=1 "&whadd&") ttt "
	datawhere=request("where")
	if len(datawhere)>0 then datawhere=" where "&getwherestr(datawhere)
	if Request.Form("sortname") = "" then
	sortname = "SerialNum" 
	Else
	sortname = Request.Form("sortname")
	End If
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
    sql="select * from  "& datafrom &" where SerialNum in("& sqlid &") "&taxis
		QueryToJSON(conn, sql).Flush
  end if
  rs.close
  set rs=nothing
response.Write"}"
'-----------------------------------------------------------'
elseif ProcessType="EmpData" then 
	sql="select b.code as id,b.code+'/'+b.name as text,isnull(e.code,'0') as pId,0 as pflag from  AIS20091116143745.DBO.HR_Base_Emp b "&_
			" inner join AIS20091116143745.DBO.ORG_Position_Employee c on c.EmID = b.EM_ID and b.status=1 and b.FIsHREmp = 1 "&_
			" inner join AIS20091116143745.DBO.ORG_Position d on c.PositionID = d.ID "&_
			" inner join AIS20091116143745.DBO.ORG_Unit e on e.ID = d.UnitID where b.status=1 and b.FIsHREmp = 1 "&_
			" union "&_
			"select distinct e.code as id,e.name as text,case when len(e.code)<5 then '0' else left(e.code,len(e.code)-5) end as pId,1 as pflag from  AIS20091116143745.DBO.HR_Base_Emp b "&_
			" inner join AIS20091116143745.DBO.ORG_Position_Employee c on c.EmID = b.EM_ID and b.status=1 and b.FIsHREmp = 1 "&_
			" inner join AIS20091116143745.DBO.ORG_Position d on c.PositionID = d.ID "&_
			" inner join AIS20091116143745.DBO.ORG_Unit e on e.ID = d.UnitID where b.status=1 "
	QueryToJSON(conn, sql).Flush
elseif ProcessType="DepartData" then 
	sql="select distinct e.code as id,e.name as text,case when len(e.code)<5 then '0' else left(e.code,len(e.code)-5) end as pId,1 as pflag from  AIS20091116143745.DBO.HR_Base_Emp b "&_
			" inner join AIS20091116143745.DBO.ORG_Position_Employee c on c.EmID = b.EM_ID and b.status=1 and b.FIsHREmp = 1 "&_
			" inner join AIS20091116143745.DBO.ORG_Position d on c.PositionID = d.ID "&_
			" inner join AIS20091116143745.DBO.ORG_Unit e on e.ID = d.UnitID "
	QueryToJSON(conn, sql).Flush
elseif ProcessType="K3DepartData" then 
	sql="select distinct fnumber as id,fname as text,case when CHARINDEX('.',fnumber)=0 then '0' else left(fnumber,len(fnumber)-charindex('.',reverse(fnumber))) end as pId,1 as pflag from AIS20091116143745.DBO.t_item where fitemclassid=2 and fdeleted=0 order by fnumber "
	QueryToJSON(conn, sql).Flush
elseif ProcessType="Emps" then 
'取职员姓名
	sql="select code as id,code+'/'+name as text from AIS20091116143745.DBO.HR_Base_Emp"
	datawhere=request("where")
	if len(datawhere)>0 then sql=sql&" where "&getwherestr(datawhere)
	QueryToJSON(conn, sql).Flush
elseif ProcessType="GetIcons" then 
	sql="select * from sys_icons where iconflag=0 order by serialnum desc"
	response.Write("{ ""status"":true,""Data"":")
	QueryToJSON(conn, sql).Flush
	response.Write("}")
elseif ProcessType="GetMyButtons" then 
	sql="select a.* from sys_Permission a,sys_Permission b where a.IconFile is not null and a.IconFile<>'' and a.psnum=b.serialnum and b.TreeUrl='"&request("MenuUrl")&"' and a.SerialNum in (select PID from sys_PermissionUse a,sys_Users b where a.GroupFlag=0 and a.UID=b.SerialNum and b.UserID='"&UserID&"' union "&_
	"select PID from sys_PermissionUse a,sys_Users b,sys_PermissionGroupDetails c where a.GroupFlag=1 and b.UserID='"&UserID&"' and c.UserID=b.UserID and a.UID=c.GroupSnum) order by PermissionID"
	response.Write("{ ""status"":true,""Data"":")
	QueryToJSON(conn, sql).Flush
	response.Write("}")
elseif ProcessType="RoomStas" then 
'取房间标准
	sql="select SerialNum as id,StandName as text from MANA_RoomSta"
	datawhere=request("where")
	if len(datawhere)>0 then sql=sql&" where "&getwherestr(datawhere)
	QueryToJSON(conn, sql).Flush
elseif ProcessType="Beds" then 
'取职员姓名
	sql="select b.SerialNum as id,a.RoomNo+'/'+b.BedID as text from MANA_Room a,MANA_Bed b where a.SerialNum=b.SSNum"
	datawhere=request("where")
	if len(datawhere)>0 then sql=sql&" and "&getwherestr(datawhere)
	QueryToJSON(conn, sql).Flush
elseif ProcessType="SaleDept" then
	sql="select distinct FDepartment as id,b.fnumber as SerialNum,b.fname as text from AIS20091116143745.DBO.t_Organization a,AIS20091116143745.DBO.t_department b where fflat=1 and a.FDepartment=b.fitemid"
	QueryToJSON(conn, sql).Flush
elseif ProcessType="departments" then 
'取职员姓名
	sql="select distinct fnumber as id,fname as text,case when CHARINDEX('.',fnumber)=0 then '0' else left(fnumber,len(fnumber)-charindex('.',reverse(fnumber))) end as pId,1 as pflag from AIS20091116143745.DBO.t_department where fdeleted=0 "
	datawhere=request("where")
	if len(datawhere)>0 then sql=sql&" and "&getwherestr(datawhere)
	sql=sql&" order by fnumber"
%>
{ "Rows": 
<%
	QueryToJSON(conn, sql).Flush
%>
}
<%
elseif ProcessType="department" then 
'取职员姓名
	sql="select distinct fnumber as id,fname as text,case when CHARINDEX('.',fnumber)=0 then '0' else left(fnumber,len(fnumber)-charindex('.',reverse(fnumber))) end as pId,1 as pflag from AIS20091116143745.DBO.t_department where fdeleted=0 "
	datawhere=request("where")
	if len(datawhere)>0 then sql=sql&" and "&getwherestr(datawhere)
	sql=sql&" order by fnumber"
	QueryToJSON(conn, sql).Flush
end if
conn.close()
set conn=nothing
 %>
