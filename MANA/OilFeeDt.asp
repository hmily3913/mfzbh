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
      datafrom=" MANA_OilFee "
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
	sql="select * from MANA_OilFee"
	rs.open sql,conn,1,3
		rs.addnew()
rs("jylx")=Request.Form("jylx")
rs("jysj")=Request.Form("jysj")
rs("jydd")=Request.Form("jydd")
rs("kahao")=Request.Form("kahao")
rs("userid")=Request.Form("userid")
rs("spmc")=Request.Form("spmc")
rs("yl")=Request.Form("yl")
rs("je")=Request.Form("je")
rs("ye")=Request.Form("ye")
rs("jylsh")=Request.Form("jylsh")
rs("memo")=Request.Form("memo")
rs("carbrand")=Request.Form("carbrand")
rs("Biller")=UserName
rs("BillerID")=UserID
rs("BillDate")=now()
		rs.update
		rs.close
		set rs=nothing 
		%>
{"status":true,"messages":"保存成功！"}
		<%
elseif ProcessType="SaveEdit" then 
	set rs = server.createobject("adodb.recordset")
	sql="select * from MANA_OilFee where SerialNum="&Request.Form("SerialNum")
	set rs = server.createobject("adodb.recordset")
	rs.open sql,conn,1,3
	if rs.eof then
		response.Write("{""status"":false,""messages"":""对应记录不存在，修改失败！""}")
		response.End()
	elseif rs("checkflag")=1 then
		response.Write("{""status"":false,""messages"":""对应记录已审核，不允许修改！""}")
		response.End()
	else
rs("jylx")=Request.Form("jylx")
rs("jysj")=Request.Form("jysj")
rs("jydd")=Request.Form("jydd")
rs("kahao")=Request.Form("kahao")
rs("userid")=Request.Form("userid")
rs("spmc")=Request.Form("spmc")
rs("yl")=Request.Form("yl")
rs("je")=Request.Form("je")
rs("ye")=Request.Form("ye")
rs("jylsh")=Request.Form("jylsh")
rs("memo")=Request.Form("memo")
rs("carbrand")=Request.Form("carbrand")

rs("Biller")=UserName
rs("BillerID")=UserID
rs("BillDate")=now()
		rs.update
		rs.close
		set rs=nothing 
end if
		%>
{"status":true,"messages":"保存成功！"}
		<%
elseif ProcessType="doDel" then 
	conn.execute("delete from MANA_OilFee where checkflag=0 and ctflag=0 and SerialNum in ("&Request("SerialNum")&")")
	response.Write("{""status"":true,""messages"":""删除成功！""}")
elseif ProcessType="Check" then
	conn.execute("update MANA_OilFee set checkflag=1,checker='"&UserName&"',checkerID='"&UserID&"',CheckDate=getdate() where checkflag=0 and SerialNum in ("&Request("SerialNum")&")")
	response.Write("{""status"":true,""messages"":""审核成功！""}")
elseif ProcessType="unCheck" then
	conn.execute("update MANA_OilFee set checkflag=0,checker=null,checkerID=null,CheckDate=null where checkflag=1 and ctflag=0 and SerialNum in ("&Request("SerialNum")&")")
	response.Write("{""status"":true,""messages"":""反审核成功！""}")
elseif ProcessType="getDt" then 
	sql="select a.*,b.name as empname from MANA_OilFee a left join AIS20091116143745.DBO.HM_Employees b on a.userid=b.code where SerialNum="&request.Form("SerialNum")
'		QueryToJSONOBJ conn,sql
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
	rs.close
	set rs=nothing 
elseif ProcessType="getCard" then 
	sql="select a.*,b.name as empname from MANA_OilCard a left join AIS20091116143745.DBO.HM_Employees b on a.userid=b.code "
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
elseif ProcessType="ctList" then 
	sql="select t1.oilcardnumber,isnull(t5.name,'美丰') as xm,t1.carbrand,t2.fygs,t3.kms,t4.icje,t4.xjje, "
	sql= sql & " case when gsje>0 and fygs='公司' then round((t6.zje/1.17-grje)*icje/gsje,2) else 0 end as 分摊后油费金额,case when gsje>0 and fygs='公司' then round((t6.zje/1.17-grje)*icje/gsje+xjje,2) else 0 end as 合计金额, "
'	sql=sql & " case when kms>0 then ((t6.zje/1.17-grje)*icje/gsje+xjje)/kms else 0 end as 每公里分配额, "
	sql=sql & " case when kms>0 and gsje>0 then round(((t6.zje/1.17-grje)*icje/gsje+xjje)/kms,2) else 0 end as 每公里分配额, "
	sql=sql & " t6.* from  "
	sql=sql & " MANA_OilCard t1  "
	sql=sql & " inner join MANA_Car t2 on t1.carbrand=t2.car_brand "
	sql=sql & " left join  (select chepai as chepai,sum(sylcs) as kms from MANA_Chuche "
	sql=sql & " where datediff(d,hlsj,'"&request("SDate")&"')<=0 and datediff(d,hlsj,'"&request("EDate")&"')>=0  "
	sql=sql & " and checkflag=1 and CtFlag=0 and HlFlag=0 GROUP BY chepai "
	sql=sql & " ) t3 on t1.carbrand=t3.chepai  "
	sql=sql & " left join (select carbrand,sum(case jylx when 'IC卡消费' then je else 0 end) as icje,sum(case jylx when '现金消费' then je else 0 end) as xjje from MANA_OilFee "
	sql=sql & " where CtFlag=0 and CheckFlag=1 "
	sql=sql & " group by carbrand "
	sql=sql & " ) t4 on t2.car_brand=t4.carbrand "
	sql=sql & " left join AIS20091116143745.DBO.HM_Employees t5 on t2.userid=t5.code "
	sql=sql & " join (select sum(case fygs when '公司' then a.je else 0 end) as gsje,sum(case fygs when '公司' then 0 else a.je end) as grje,sum(a.je) as zje "
	sql=sql & " from MANA_OilFee a,MANA_Car b "
	sql=sql & " where jylx='IC卡消费' and b.car_brand=a.carbrand and a.CtFlag=0 and a.CheckFlag=1) t6 on 1=1 "
	sql=sql & " order by t2.fygs desc,t1.carbrand asc"
	%>
	{ "Rows": 
	<%
	QueryToJSON(conn, sql).Flush
	response.Write"}"
elseif ProcessType="setct" then 
	sql="update t1 set fyje=t2.每公里分配额*sylcs,t1.CtFlag=1,CtDate=getdate() from MANA_Chuche t1,( "
	sql= sql & " select t1.oilcardnumber,t5.name,t1.carbrand,t2.fygs,t3.kms,t4.icje,t4.xjje, "
	sql= sql & " case when gsje>0 then round((t6.zje/1.17-grje)*icje/gsje,2) else 0 end as 分摊后油费金额,case when gsje>0 then round((t6.zje/1.17-grje)*icje/gsje+xjje,2) else 0 end as 合计金额, "
	sql= sql & " case when kms>0 and gsje>0 then ((t6.zje/1.17-grje)*icje/gsje+xjje)/kms else 0 end as 每公里分配额, "
	sql= sql & " t6.* from  "
	sql= sql & " MANA_OilCard t1  "
	sql= sql & " inner join MANA_Car t2 on t1.carbrand=t2.car_brand "
	sql= sql & " left join  (select chepai as chepai,sum(sylcs) as kms from MANA_Chuche "
	sql= sql & " where datediff(d,hlsj,'"&request("SDate")&"')<=0 and datediff(d,hlsj,'"&request("EDate")&"')>=0  "
	sql= sql & " and checkflag=1 and CtFlag=0 and HlFlag=0 GROUP BY chepai "
	sql= sql & " ) t3 on t1.carbrand=t3.chepai  "
	sql= sql & " left join (select carbrand,sum(case jylx when 'IC卡消费' then je else 0 end) as icje,sum(case jylx when '现金消费' then je else 0 end) as xjje from MANA_OilFee "
	sql= sql & " where CtFlag=0 and CheckFlag=1 "
	sql= sql & " group by carbrand "
	sql= sql & " ) t4 on t2.car_brand=t4.carbrand "
	sql= sql & " left join AIS20091116143745.DBO.HM_Employees t5 on t2.userid=t5.code "
	sql= sql & " join (select sum(case fygs when '公司' then a.je else 0 end) as gsje,sum(case fygs when '公司' then 0 else a.je end) as grje,sum(a.je) as zje "
	sql= sql & " from MANA_OilFee a,MANA_Car b "
	sql= sql & " where jylx='IC卡消费' and b.car_brand=a.carbrand and a.CtFlag=0 and a.CheckFlag=1) t6 on 1=1 "
	sql= sql & " ) t2 where t2.carbrand=t1.chepai and datediff(d,t1.hlsj,'"&request("SDate")&"')<=0 and datediff(d,t1.hlsj,'"&request("EDate")&"')>=0 and t1.checkflag=1 and CtFlag=0 and HlFlag=0"
	conn.execute(sql)
	sql="update MANA_OilFee set CtFlag=1,CtDate=getdate() where CtFlag=0 and CheckFlag=1 "
	conn.execute(sql)
	response.Write("{""status"":true,""messages"":""期间内的出车单费用更新成功！""}")
elseif ProcessType="checkct" then 
	sql= "select chepai as chepai,isnull(sum(sylcs),0) as kms from MANA_Chuche "
	sql= sql & " where datediff(d,hlsj,'"&request("SDate")&"')<=0 and datediff(d,hlsj,'"&request("EDate")&"')>=0  "
	sql= sql & " and checkflag=1 and CtFlag=0 and HlFlag=1 GROUP BY chepai having isnull(sum(sylcs),0)>0"
	set rs=server.createobject("adodb.recordset")
	rs.open sql,conn,1,1
	if rs.eof then
		response.Write("{""status"":true,""messages"":""期间内的出车单未设置过滤单据！""}")
	else
		response.Write("{""status"":true,""messages"":""期间内的出车单已经设置车牌为["&rs("chepai")&"],过滤公里数["&rs("kms")&"]！""}")
	end if
	rs.close
	set rs=nothing 
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
		if trim(excelrs("卡号"))<>"" then
			i=i+1  
			set rs=conn.execute("select userid,carbrand from MANA_OilCard where oilcardnumber='"&excelrs("卡号")&"'")
			dim shiyongren,carbrand
			shiyongren=rs("userid")
			carbrand=rs("carbrand")
			conn.execute("insert into MANA_OilFee (jylx,jysj,jydd,kahao,userid,spmc,yl,je,ye,jylsh,Biller,BillerID,BillDate,carbrand) values ('"&excelrs("交易类型")&"','"&excelrs("交易时间")&"','"&excelrs("交易地点")&"','"&excelrs("卡号")&"','"&shiyongren&"','"&excelrs("商品名称")&"',"&_
			iif((excelrs("油量(升)")="" or isnull(excelrs("油量(升)"))),0,excelrs("油量(升)"))&","&_
			iif((excelrs("金额(元)")="" or isnull(excelrs("金额(元)"))),0,excelrs("金额(元)"))&","&_
			iif((excelrs("余额(元)")="" or isnull(excelrs("余额(元)"))),0,excelrs("余额(元)"))&",'"&excelrs("交易流水号")&"','"&UserName&"','"&UserID&"',getdate(),'"&carbrand&"')")		
		end if
		excelrs.movenext
	loop
	excelrs.close()
  set excelrs=nothing
  excelconn.Close()
	set excelconn=nothing
	response.Write("{""status"":true,""messages"":""共计"&i&"条数据导入成功！""}")
end if
conn.close()
set conn=nothing
 %>
