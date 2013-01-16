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

  sql="select isnull(a.UserNumber,'') as fnumber from sys_Users a,sys_PermissionGroupDetails b where a.UserID=b.userid and b.GroupSnum=9 and a.UserID='"&UserID&"'"
  set rs=server.createobject("adodb.recordset")
	rs.open sql,conn,0,1
	dim whadd
	whadd=""
	if not rs.eof then
		if rs("fnumber")<>"" then whadd=" and c.fnumber='"&rs("fnumber")&"' "
	end if
  dim datafrom'数据表名
      datafrom="(select b.FItemid as SerialNum,b.FItemid as id,b.FNumber+'/'+b.FName as text,b.FNumber,b.FName as custName,c.FName as empname,d.fname as departname from  AIS20091116143745.DBO.t_Organization b "&_
			" left join AIS20091116143745.DBO.t_emp c on c.FItemid = b.FEmployee "&_
			" left join AIS20091116143745.DBO.t_department d on d.FItemid = b.FDepartment "&_
			" where year(b.flastTradeDate)>2011 and b.FDeleted=0 and b.fflat=1 "&whadd&") ttt "
  dim datawhere'数据条件
  dim i'用于循环的整数
	Dim searchterm,searchcols
	datawhere=request("where")
	if len(datawhere)>0 then datawhere=" where "&getwherestr(datawhere)
  dim sqlid'本页需要用到的id
  dim taxis'排序的语句 asc,desc
	Dim sortname
	if Request.Form("sortname") = "" then
	sortname = "FNumber" 
	Else
	sortname = Request.Form("sortname")
	End If
	Dim sortorder
	if Request.Form("sortorder") = "" then
	sortorder = "asc"
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
  rs.close
  set rs=nothing
  '获取本页需要用到的id结束============================================
'-----------------------------------------------------------
'-----------------------------------------------------------
%>
{ "page":"<%=page%>","total":"<%=idcount%>","Rows": 
<%
  if sqlid<>"" then'如果记录总数=0,则不处理
    '用in刷选本页所语言的数据,仅读取本页所需的数据,所以速度快
    sql="select * from "& datafrom &" where SerialNum in("& sqlid &") "&taxis
    QueryToJSON(conn, sql).Flush
  end if
response.Write"}"
'-----------------------------------------------------------'

elseif ProcessType="PrintAll" then 
	dim SDate,EDate,CustID,Cust,CustName,Deptid
	SDate=request("SDate")
	EDate=request("EDate")
	Cust=request("CustID")
	Deptid=request("Dept")
%>
<style media=print> 
.Noprint{display:none;} 
.PageNext{page-break-after: always;} 
</style>
<script language="javascript" src="../Script/jquery-1.7.2.min.js"></script>
<script language="javascript">
function delRow(evt,obj){
	if(window.confirm("是否确定删除此行数据？")){
		var delval=parseFloat($('td:eq(1)',obj).text().replace(",",""));
		$(obj).remove();
		delval=Math.round(parseFloat($('#skje').text().replace(",",""))-delval,2);
		$('#skje').text(delval);
		$('.t3').text(delval);
		ct();		
	}
}
function ct(){
	var alls=0
	var t1=parseFloat($('.t2').text().replace(",",""))+parseFloat($('.t3').text().replace(",",""));
	var t6=t1-parseFloat($('.t4').text().replace(",",""))-parseFloat($('.t5').text().replace(",",""));
	var t7=parseFloat($('.t8').text().replace(",",""))+parseFloat($('.t9').text().replace(",",""))+parseFloat($('.t10').text().replace(",",""));
	var t11=t6+t7;
	$('.t1').text(Math.round(t1));
	$('.t6').text(Math.round(t6));
	$('.t7').text(Math.round(t7));
	$('.t11').text(Math.round(t11));
}
function sedit(obj){
	$(obj).parent().text($(obj).val());
	ct();
}
$(function(){
	$('.fedit').dblclick( function () {
		if($('.cedit').length>0)return false;
		$('font',this).html('<input type="text" class="cedit" value='+$('font',this).text().replace(",","")+' style="width:80%;font-size:12px;font-color:red;" onblur="return sedit(this)"\>');
		$('.cedit').focus().select();
	});
});
</script>
<table class="Noprint">
 <tr>
 <td><div><OBJECT id="WebBrowser" classid=CLSID:8856F961-340A-11D0-A96B-00C04FD705A2 height=0 width=0></OBJECT><input type="button" value="打印" onclick="javascript:window.print()">&nbsp;<input type="button" value="页面设置" onclick=document.getElementById("WebBrowser").ExecWB(8,1)>&nbsp;<input type="button" value="打印预览" onclick=document.getElementById("WebBrowser").ExecWB(7,1)></div></td>
 </tr>
</table>
<%

  sql="select c.fitemid from sys_Users a,sys_PermissionGroupDetails b,AIS20091116143745.dbo.t_emp c where c.fnumber=a.UserNumber and a.UserID=b.userid and b.GroupSnum=9 and a.UserID='"&UserID&"'"
  set rs=server.createobject("adodb.recordset")
	rs.open sql,conn,0,1
	whadd=""
	if not rs.eof then
		if rs("fitemid")<>"" then whadd=" and a.FEmployee='"&rs("fitemid")&"' "
	end if

dim sql2,rs2
set rs2 = server.createobject("adodb.recordset")
sql2="select distinct a.FNumber,a.FName,a.FItemid from AIS20091116143745.dbo.t_Organization a,AIS20091116143745.dbo.vwicbill_8 b where 客户编号=a.fnumber and b.FCheckFLag='※' and b.FCancellation='' and b.FDate>='"&SDate&"' AND b.FDate<='"&EDate&"' "&whadd
if Deptid<>"" then sql2=sql2&" and a.FDepartment="&Deptid
if Cust<>"" then sql2=sql2&" and a.FItemid in ("&Cust&") "
sql2=sql2&" order by a.fnumber asc"
	rs2.open sql2,conn,1,1
while(not rs2.eof)
'	set rs = server.createobject("adodb.recordset")
'	sql="select FNumber,FName from AIS20091116143745.dbo.t_Organization where FItemid='"&Cust&"'"
'	rs.open sql,conn,1,1
	CustID=rs2("FNumber")
	CustName=rs2("FName")
	Cust=rs2("FItemid")
	dim hwxs'货物销售
	hwxs=0
	dim bnskx'本年收款额
	bnskx=0
	dim zkjs'折扣结算
	zkjs=0
	dim dcyhe'冬储优惠额
	dcyhe=0
	set rs = server.createobject("adodb.recordset")
	sql="select 客户编号,c.FSupplyID as 客户名称,CONVERT(varchar,c.FDate,23) 日期,c.FNumber 产品代码,c.FItemID 产品名称,c.FModel 规格型号,c.FUnitID 单位,c.FAuxQty 数量,c.FConsignPrice as 统一价,case when yfzffs=8610 and FAuxQty<0 then c.FQty*isnull(e.FDecimal,0)/1000/c.FAuxQty else 运费单价*c.FQty/c.FAuxQty end 运费单价,case when yfzffs=8610 and FAuxQty<0 then (c.FQty*isnull(e.FDecimal,0)/1000+c.FConsignAmount)/c.FAuxQty else (isnull(运费金额,0)+c.FConsignAmount)/c.FAuxQty end as 统一价加运费,case when yfzffs=8610 and FAuxQty<0 then (c.FQty*isnull(e.FDecimal,0)/1000+c.FConsignAmount) else (isnull(运费金额,0)+c.FConsignAmount) end as 金额,d.fname as sc "&_
"from AIS20091116143745.dbo.vwicbill_8 c "&_
"inner join AIS20091116143745.dbo.t_Organization a on 客户编号=a.fnumber "&_
"left join AIS20091116143745.dbo.t_Department d on d.FItemid=a.FDepartment "&_
"left join AIS20091116143745.dbo.z_YFJGEntry e on a.FDepartment=e.FBase and datediff(d,c.FDate,e.fdate)<=0 and datediff(d,c.FDate,e.FDate1)>=0 "&_
"where c.FCheckFLag='※' and c.FCancellation='' and c.FDate>='"&SDate&"' AND c.FDate<='"&EDate&"' "&_
"AND c.客户编号='"&CustID&"' order by c.FDate "
	rs.open sql,conn,1,1
	dim ygsc'退款转年初，江西市场 2012-02-01做的退款单
	ygsc=0
if not rs.eof then
%>
<table width="100%" cellpadding="3" cellspacing="0" bgcolor="#000000">
<tr height="40"><td colspan="8" align="center" bgcolor="#FFFFFF"><font style="font-size:18px"><b>销售发货对账明细表</b></font></td></tr>
<tr height="20"><td colspan="8" align="center" bgcolor="#FFFFFF"><font style="font-size:12px">结算期间:<%=SDate%>至<%=EDate%></font></td></tr>
<tr height="30"><td colspan="8" align="left" bgcolor="#FFFFFF"><font style="font-size:14px"><b>单位名称：<%=CustName%>（<%=CustID%>）</b></font></td></tr>
<tr height="30">
<td width="10%" align="center" bgcolor="#FFFFFF" style="border:1px solid;"><font style="font-size:12px">日期 </font></td>
<td width="14%" align="center" bgcolor="#FFFFFF" style="border:1px solid;"><font style="font-size:12px">产品名称 </font></td>
<td width="20%" align="center" bgcolor="#FFFFFF" style="border:1px solid;"><font style="font-size:12px">规格型号 </font></td>
<td width="6%" align="center" bgcolor="#FFFFFF" style="border:1px solid;"><font style="font-size:12px">单位</font></td>
<td width="10%" align="center" bgcolor="#FFFFFF" style="border:1px solid;"><font style="font-size:12px">发货数量</font></td>
<%if rs("sc")="广西市场" then%>
<td width="10%" align="center" bgcolor="#FFFFFF" style="border:1px solid;"><font style="font-size:12px">统一单价</font></td>
<td width="10%" align="center" bgcolor="#FFFFFF" style="border:1px solid;"><font style="font-size:12px">运费单价</font></td>
<%else%>
<td width="10%" align="center" colspan="2" bgcolor="#FFFFFF" style="border:1px solid;"><font style="font-size:12px">统一价<br />(含运费)</font></td>
<%end if%>
<td width="10%" align="center" bgcolor="#FFFFFF" style="border:1px solid;"><font style="font-size:12px">金额</font></td>
</tr>
<%
	dim zint
	zint=1
	while(not rs.eof)
		if datediff("d",rs("日期"),"2012-01-01")=0 and rs("sc")="云贵市场" then
			ygsc=ygsc+cdbl(rs("金额"))
		else
		response.Write("<tr height='20' style='border: 1px solid; '>"&vbcrlf)
		response.Write("<td bgcolor=""#FFFFFF"" style=""border:1px solid;""><font style=""font-size:12px"">"&rs("日期")&"</font></td>"&vbcrlf)
		response.Write("<td bgcolor=""#FFFFFF"" style=""border:1px solid;""><font style=""font-size:12px"">"&rs("产品名称")&"</font></td>"&vbcrlf)
		response.Write("<td bgcolor=""#FFFFFF"" style=""border:1px solid;""><font style=""font-size:12px"">"&rs("规格型号")&"</font></td>"&vbcrlf)
		response.Write("<td bgcolor=""#FFFFFF"" style=""border:1px solid;""><font style=""font-size:12px"">"&rs("单位")&"</font></td>"&vbcrlf)
		response.Write("<td bgcolor=""#FFFFFF"" style=""border:1px solid;"" align='right'><font style=""font-size:12px"">"&FormatNumber(rs("数量"),2,-1)&"</font></td>"&vbcrlf)
		if rs("sc")="广西市场" then
		response.Write("<td bgcolor=""#FFFFFF"" style=""border:1px solid;"" align='right'><font style=""font-size:12px"">"&FormatNumber(rs("统一价"),2,-1)&"</font></td>"&vbcrlf)
		response.Write("<td bgcolor=""#FFFFFF"" style=""border:1px solid;"" align='right'><font style=""font-size:12px"">"&FormatNumber(rs("运费单价"),2,-1)&"</font></td>"&vbcrlf)
		else
		response.Write("<td bgcolor=""#FFFFFF"" colspan=""2"" style=""border:1px solid;"" align='right'><font style=""font-size:12px"">"&FormatNumber(rs("统一价加运费"),2,-1)&"</font></td>"&vbcrlf)
		end if
		response.Write("<td bgcolor=""#FFFFFF"" style=""border:1px solid;"" align='right'><font style=""font-size:12px"">"&FormatNumber(rs("金额"),2,-1)&"</font></td>"&vbcrlf)
		response.Write("</tr>"&vbcrlf)
		hwxs=hwxs+cdbl(rs("金额"))
		end if
		rs.movenext
	wend
%>
<tr height="20">
<td width="10%" align="center" bgcolor="#FFFFFF" style="border:1px solid;"><font style="font-size:12px">&nbsp; </font></td>
<td width="14%" align="center" bgcolor="#FFFFFF" style="border:1px solid;"><font style="font-size:12px">合计 </font></td>
<td width="20%" align="center" bgcolor="#FFFFFF" style="border:1px solid;"><font style="font-size:12px">&nbsp; </font></td>
<td width="6%" align="center" bgcolor="#FFFFFF" style="border:1px solid;"><font style="font-size:12px">&nbsp;</font></td>
<td width="10%" align="center" bgcolor="#FFFFFF" style="border:1px solid;"><font style="font-size:12px">&nbsp;</font></td>
<td width="10%" align="center" colspan="2" bgcolor="#FFFFFF" style="border:1px solid;"><font style="font-size:12px">&nbsp;</font></td>
<td width="10%" bgcolor="#FFFFFF" style="border:1px solid;" align='right'><font style="font-size:12px"><%=FormatNumber(hwxs,2,-1)%>&nbsp;</font></td>
</tr>
<tr height="50"><td colspan="8" align="right" bgcolor="#FFFFFF"><font style="font-size:12px">
美丰农化有限公司盖章</font></td></tr>
<tr height="20"><td colspan="8" align="right" bgcolor="#FFFFFF"><font style="font-size:12px">
<%=EDate%></font></td></tr>
</table>
<%
end if
'and (a.FBillType=1000 or a.FBillType=1004)
	set rs = server.createobject("adodb.recordset")
	sql="select d.FName as sc,c.FNumber,c.FName,CONVERT(varchar(12) ,a.FDate,23) as 日期,b.fname as 结算方式,sum(a.FAmountFor) as FAmountFor,a.fexplanation as zy,0 as ord1 "&_
"from AIS20091116143745.dbo.t_RP_NewReceiveBill a,AIS20091116143745.dbo.t_settle b,AIS20091116143745.dbo.t_Organization c,AIS20091116143745.dbo.t_Department d "&_
"where c.FDepartment=d.FItemid and fdate>='"&SDate&"' AND fdate<='"&EDate&"' and a.FSettle=b.fitemid and a.FClassTypeID=1000005 "&_
" and a.FCustomer=c.FItemid AND c.FNumber='"&CustID&"' and (a.fexplanation<>'销售折扣转货款' or datediff(m,fdate,'2012-09-01')>0) and a.FSettle<>9  "&_
"group by c.FNumber,c.FName,a.FDate,b.fname,a.fexplanation,d.FName "&_
"union all "&_
"select d.FName as sc,c.FNumber,c.FName,CONVERT(varchar(12) ,a.FDate,23) as 日期,b.fname as 结算方式,a.FAmountFor,a.FExplanation as zy,0 as ord1  "&_
"from AIS20091116143745.dbo.t_RP_NewReceiveBill a,AIS20091116143745.dbo.t_settle b ,AIS20091116143745.dbo.t_Organization c ,AIS20091116143745.dbo.t_Department d "&_
"where c.FDepartment=d.FItemid and fdate>='"&SDate&"' AND fdate<='"&EDate&"' and a.FSettle=b.fitemid and a.FClassTypeID=1000015  "&_
"and a.FCustomer=c.FItemid AND c.FNumber='"&CustID&"' order by c.FNumber,日期"
	rs.open sql,conn,1,1
	if not rs.eof then
	zint=zint+1
	dim tknc'退款转年初，江西市场 2012-02-01做的退款单
	tknc=0
%>
<div class="PageNext">&nbsp;</div>
<table width="100%" cellpadding="3" cellspacing="0" bgcolor="#000000">
<tr height="40"><td colspan="4" align="center" bgcolor="#FFFFFF"><font style="font-size:18px"><b>客户收款对账明细表</b></font></td></tr>
<tr height="20"><td colspan="4" align="center" bgcolor="#FFFFFF"><font style="font-size:12px">结算期间:<%=SDate%>至<%=EDate%></font></td></tr>
<tr height="30"><td colspan="4" align="left" bgcolor="#FFFFFF"><font style="font-size:14px"><b>单位名称：<%=CustName%>（<%=CustID%>）</b></font></td></tr>
<tr height="30">
<td width="20%" align="center" bgcolor="#FFFFFF" style="border:1px solid;"><font style="font-size:12px">到账日期 </font></td>
<td width="30%" align="center" bgcolor="#FFFFFF" style="border:1px solid;"><font style="font-size:12px">金额（元） </font></td>
<td width="10%" align="center" bgcolor="#FFFFFF" style="border:1px solid;"><font style="font-size:12px">结算方式 </font></td>
<td width="40%" align="center" bgcolor="#FFFFFF" style="border:1px solid;"><font style="font-size:12px">备注</font></td>
</tr>
<%
	while(not rs.eof)
		if rs("日期")="2012-02-01" and rs("FAmountFor")<0 then'(rs("sc")="江西市场" or rs("sc")="安徽市场") and 
		tknc=tknc+rs("FAmountFor")
		rs.movenext
		else
		response.Write("<tr height='20' style='border: 1px solid; ' ondblclick=""delRow(event,this)"" title=""双击可删除一行"">")
		response.Write("<td bgcolor=""#FFFFFF"" style=""border:1px solid;""><font style=""font-size:12px"">"&rs("日期")&"</font></td>")
		response.Write("<td bgcolor=""#FFFFFF"" style=""border:1px solid;"" align='right'><font style=""font-size:12px"">"&FormatNumber(rs("FAmountFor"),2,-1)&"</font></td>")
		response.Write("<td bgcolor=""#FFFFFF"" style=""border:1px solid;""><font style=""font-size:12px"">"&rs("结算方式")&"</font></td>")
		if rs("sc")="广西市场" then
		response.Write("<td bgcolor=""#FFFFFF"" style=""border:1px solid;""><font style=""font-size:12px"">"&rs("zy")&"&nbsp;</font></td>")
		else
		response.Write("<td bgcolor=""#FFFFFF"" style=""border:1px solid;""><font style=""font-size:12px"">&nbsp;</font></td>")
		end if
		response.Write("</tr>")
		bnskx=bnskx+cdbl(rs("FAmountFor"))
		rs.movenext
		end if
	wend
%>
<tr height="20">
<td align="center" bgcolor="#FFFFFF" style="border:1px solid;"><font style="font-size:12px">合计 </font></td>
<td bgcolor="#FFFFFF" style="border:1px solid;" align='right'><font style="font-size:12px" id="skje"><%=FormatNumber(bnskx,2,-1)%></font></td>
<td bgcolor="#FFFFFF" style="border:1px solid;">&nbsp;</font></td>
<td bgcolor="#FFFFFF" style="border:1px solid;">&nbsp;</font></td>
</tr>
<tr><td align="left" bgcolor="#FFFFFF" colspan="4" style="border:1px solid;"><font style="font-size:12px">
注：1、结算方式分"贷记卡"（卡号4041170042835615）、"借记卡"（卡号6228480330257484718）、<br/>
"电汇"(账号215101040025303)、现金等方式 </font></td></tr>
<tr><td align="left" bgcolor="#FFFFFF" colspan="4" style="border:1px solid;"><font style="font-size:12px">
    2、本表"到账日期"是美丰公司款项收到的日期为准。</font></td></tr>
<tr><td align="left" bgcolor="#FFFFFF" colspan="4" style="border:1px solid;"><font style="font-size:12px">
    3、正数表示收到客户款，负数表示退还客户款</font></td></tr>
<tr height="50"><td colspan="9" align="right" bgcolor="#FFFFFF"><font style="font-size:12px">
美丰农化有限公司盖章</font></td></tr>
<tr height="20"><td colspan="9" align="right" bgcolor="#FFFFFF"><font style="font-size:12px">
<%=EDate%></font></td></tr>
</table>
<%
end if
	set rs = server.createobject("adodb.recordset")
	sql="select t2.*,t3.fname as cust,t4.fname as product,t4.fmodel,t5.fname as unit,t1.fdate,t1.fdate1 "&_
			"from AIS20091116143745.dbo.z_KHZKJS t1,AIS20091116143745.dbo.z_KHZKJSEntry t2,AIS20091116143745.dbo.t_Organization t3,AIS20091116143745.dbo.t_icitem t4,AIS20091116143745.dbo.t_measureunit t5 "&_
			"where t1.fuser>0 and t1.fid=t2.fid and t2.fbase3=t3.fitemid and t2.fbase1=t4.fitemid and t2.fbase2=t5.fitemid "&_
			" and t3.FNumber='"&CustID&"' and t1.FDate>='"&SDate&"' and t1.FDate1<='"&EDate&"' order by t1.fid,t3.fnumber,t4.fnumber"
	rs.open sql,conn,1,1
	if not rs.eof then
	zint=zint+1
%>
<div class="PageNext">&nbsp;</div>
<table width="100%" cellpadding="3" cellspacing="0" bgcolor="#000000">
<tr height="40"><td colspan="6" align="center" bgcolor="#FFFFFF"><font style="font-size:18px"><b>客户销售折扣结算单</b></font></td></tr>
<tr height="20"><td colspan="6" align="center" bgcolor="#FFFFFF"><font style="font-size:12px">结算期间:<%=SDate%>至<%=EDate%></font></td></tr>
<tr height="30">
<td colspan="4" align="left" bgcolor="#FFFFFF"><font style="font-size:14px"><b>单位名称：<%=CustName%>（<%=CustID%>）</b></font></td>
<td colspan="2" align="left" bgcolor="#FFFFFF"><font style="font-size:14px"><b>数量单位：箱   金额单位：元</b></font></td></tr>
<tr height="30">
<td width="20%" align="center" bgcolor="#FFFFFF" style="border:1px solid;"><font style="font-size:12px">产品名称 </font></td>
<td width="25%" align="center" bgcolor="#FFFFFF" style="border:1px solid;"><font style="font-size:12px">规格 </font></td>
<td width="10%" align="center" bgcolor="#FFFFFF" style="border:1px solid;"><font style="font-size:12px">发货数量 </font></td>
<td width="10%" align="center" bgcolor="#FFFFFF" style="border:1px solid;"><font style="font-size:12px">单件折扣额 </font></td>
<td width="10%" align="center" bgcolor="#FFFFFF" style="border:1px solid;"><font style="font-size:12px">折扣金额 </font></td>
<td width="25%" align="center" bgcolor="#FFFFFF" style="border:1px solid;"><font style="font-size:12px">备注</font></td>
</tr>
<%

	while(not rs.eof)
		response.Write("<tr height='20' style='border: 1px solid; '>")
		response.Write("<td bgcolor=""#FFFFFF"" style=""border:1px solid;""><font style=""font-size:12px"">"&rs("product")&"</font></td>")
		response.Write("<td bgcolor=""#FFFFFF"" style=""border:1px solid;""><font style=""font-size:12px"">"&rs("fmodel")&"</font></td>")
		response.Write("<td bgcolor=""#FFFFFF"" style=""border:1px solid;"" align='right'><font style=""font-size:12px"">"&FormatNumber(rs("FDecimal"),2,-1)&"</font></td>")
		response.Write("<td bgcolor=""#FFFFFF"" style=""border:1px solid;"" align='right'><font style=""font-size:12px"">"&FormatNumber(cdbl(rs("FDecimal7"))/cdbl(rs("FDecimal")),2,-1)&"</font></td>")
		response.Write("<td bgcolor=""#FFFFFF"" style=""border:1px solid;"" align='right'><font style=""font-size:12px"">"&FormatNumber(rs("FDecimal7"),2,-1)&"</font></td>")
		response.Write("<td bgcolor=""#FFFFFF"" style=""border:1px solid;""><font style=""font-size:12px"">"&rs("FText")&"&nbsp;</font></td>")
		response.Write("</tr>")
		zkjs=zkjs+cdbl(rs("FDecimal7"))
		rs.movenext
	wend
%>
<tr height="20">
<td align="center" bgcolor="#FFFFFF" style="border:1px solid;"><font style="font-size:12px">合计 </font></td>
<td bgcolor="#FFFFFF" style="border:1px solid;">&nbsp;</font></td>
<td bgcolor="#FFFFFF" style="border:1px solid;">&nbsp;</font></td>
<td bgcolor="#FFFFFF" style="border:1px solid;">&nbsp;</font></td>
<td align="center" bgcolor="#FFFFFF" style="border:1px solid;"><font style="font-size:12px"><%=FormatNumber(zkjs,2,-1)%></font></td>
<td bgcolor="#FFFFFF" style="border:1px solid;">&nbsp;</font></td>
</tr>
<tr height="50"><td colspan="6" align="right" bgcolor="#FFFFFF"><font style="font-size:12px">
美丰农化有限公司盖章</font></td></tr>
<tr height="20"><td colspan="6" align="right" bgcolor="#FFFFFF"><font style="font-size:12px">
<%=EDate%></font></td></tr>
</table>
<%
end if
	set rs = server.createobject("adodb.recordset")
	sql="select a.* "&_
		"from AIS20091116143745.dbo.z_BZJMXEntry a, AIS20091116143745.dbo.z_BZJMX b "&_
		"where a.fid=b.fid and b.fuser>0 and a.FBase='"&Cust&"' and b.fcombobox='"&year(SDate)&"' "
	rs.open sql,conn,1,1
	dim tdbls
	tdbls=0
	if not rs.eof then
	zint=zint+1
%>
<div class="PageNext">&nbsp;</div>
<table width="100%" cellpadding="3" cellspacing="0" bgcolor="#000000">
<tr height="40"><td colspan="6" align="center" bgcolor="#FFFFFF"><font style="font-size:18px"><b>储备保证金优惠额明细表</b></font></td></tr>
<tr height="20"><td colspan="6" align="center" bgcolor="#FFFFFF"><font style="font-size:12px">结算期间:<%=SDate%>至<%=EDate%></font></td></tr>
<tr height="30"><td colspan="6" align="left" bgcolor="#FFFFFF"><font style="font-size:14px"><b>单位名称：<%=CustName%>（<%=CustID%>）</b></font></td><tr height="30">
<td width="16%" align="center" bgcolor="#FFFFFF" style="border:1px solid;"><font style="font-size:12px">入账日期 </font></td>
<td width="16%" align="center" bgcolor="#FFFFFF" style="border:1px solid;"><font style="font-size:12px">转款金额 </font></td>
<td width="16%" align="center" bgcolor="#FFFFFF" style="border:1px solid;"><font style="font-size:12px">结转日期 </font></td>
<td width="16%" align="center" bgcolor="#FFFFFF" style="border:1px solid;"><font style="font-size:12px">累计天数 </font></td>
<td width="16%" align="center" bgcolor="#FFFFFF" style="border:1px solid;"><font style="font-size:12px">优惠率（%） </font></td>
<td width="16%" align="center" bgcolor="#FFFFFF" style="border:1px solid;"><font style="font-size:12px">优惠额</font></td>
</tr>
<%

	while(not rs.eof)
		response.Write("<tr height='20' style='border: 1px solid; '>")
		response.Write("<td bgcolor=""#FFFFFF"" style=""border:1px solid;""><font style=""font-size:12px"">"&rs("FDate")&"</font></td>")
		response.Write("<td bgcolor=""#FFFFFF"" style=""border:1px solid;"" align='right'><font style=""font-size:12px"">"&FormatNumber(rs("FDecimal1"),2,-1)&"</font></td>")
		response.Write("<td bgcolor=""#FFFFFF"" style=""border:1px solid;""><font style=""font-size:12px"">"&rs("FDate1")&"</font></td>")
		response.Write("<td bgcolor=""#FFFFFF"" style=""border:1px solid;""><font style=""font-size:12px"">"&rs("FInteger")&"</font></td>")
		response.Write("<td bgcolor=""#FFFFFF"" style=""border:1px solid;""><font style=""font-size:12px"">"&FormatNumber(rs("FDecimal2"),2,-1)&"%</font></td>")
		response.Write("<td bgcolor=""#FFFFFF"" style=""border:1px solid;"" align='right'><font style=""font-size:12px"">"&FormatNumber(rs("FDecimal3"),2,-1)&"</font></td>")
		response.Write("</tr>")
		tdbls=tdbls+cdbl(rs("FDecimal1"))
		dcyhe=dcyhe+cdbl(rs("FDecimal3"))
		rs.movenext
	wend
%>
<tr height="20">
<td align="center" bgcolor="#FFFFFF" style="border:1px solid;"><font style="font-size:12px">合计 </font></td>
<td align="center" bgcolor="#FFFFFF" style="border:1px solid;"><font style="font-size:12px"><%=FormatNumber(tdbls,2,-1)%></font></td>
<td bgcolor="#FFFFFF" style="border:1px solid;">&nbsp;</font></td>
<td bgcolor="#FFFFFF" style="border:1px solid;">&nbsp;</font></td>
<td bgcolor="#FFFFFF" style="border:1px solid;">&nbsp;</font></td>
<td align="center" bgcolor="#FFFFFF" style="border:1px solid;"><font style="font-size:12px"><%=FormatNumber(dcyhe,2,-1)%></font></td>
</tr>
<tr height="50"><td colspan="6" align="right" bgcolor="#FFFFFF"><font style="font-size:12px">
美丰农化有限公司盖章</font></td></tr>
<tr height="20"><td colspan="6" align="right" bgcolor="#FFFFFF"><font style="font-size:12px">
<%=EDate%></font></td></tr>
</table>
<%
end if

	set rs = server.createobject("adodb.recordset")
	sql="select b.*,c.fnumber,c.fname,c.fmodel from AIS20091116143745.dbo.z_ZDCPJL a,AIS20091116143745.dbo.z_ZDCPJLEntry b,AIS20091116143745.dbo.t_icitem c "&_
			"where a.fuser>0 and a.fid=b.fid and b.FBase1=c.fitemid and a.fcombobox= '" & year(SDate) & "' and a.FBase="&Cust&" order by c.fnumber"
	rs.open sql,conn,1,1
	dim tdbls1,tdbls2,tdbls3,tdbls4,tdbls5,zdcp
	tdbls1=0:tdbls2=0:tdbls3=0:tdbls4=0:tdbls5=0:zdcp=0
	if not rs.eof then
	zint=zint+1
%>
<div class="PageNext">&nbsp;</div>
<table width="100%" cellpadding="3" cellspacing="0" bgcolor="#000000">
<tr height="40"><td colspan="10" align="center" bgcolor="#FFFFFF"><font style="font-size:18px"><b>重点产品销售奖励结算表</b></font></td></tr>
<tr height="20"><td colspan="10" align="center" bgcolor="#FFFFFF"><font style="font-size:12px">结算期间:<%=SDate%>至<%=EDate%></font></td></tr>
<tr height="30">
<td colspan="7" align="left" bgcolor="#FFFFFF"><font style="font-size:14px"><b>单位名称：<%=CustName%>（<%=CustID%>）</b></font></td>
<td colspan="3" align="left" bgcolor="#FFFFFF"><font style="font-size:14px"><b>单位：公斤、元</b></font></td>
<tr height="30">
<td width="12%" align="center" bgcolor="#FFFFFF" style="border:1px solid;"><font style="font-size:12px">产品代码 </font></td>
<td width="12%" align="center" bgcolor="#FFFFFF" style="border:1px solid;"><font style="font-size:12px">产品名称 </font></td>
<td width="18%" align="center" bgcolor="#FFFFFF" style="border:1px solid;"><font style="font-size:10px">规格型号 </font></td>
<td width="8%" align="center" bgcolor="#FFFFFF" style="border:1px solid;"><font style="font-size:12px">上年销量 </font></td>
<td width="8%" align="center" bgcolor="#FFFFFF" style="border:1px solid;"><font style="font-size:12px">今年销量 </font></td>
<td width="8%" align="center" bgcolor="#FFFFFF" style="border:1px solid;"><font style="font-size:12px">统一结算价 </font></td>
<td width="8%" align="center" bgcolor="#FFFFFF" style="border:1px solid;"><font style="font-size:12px">上年销售额</font></td>
<td width="8%" align="center" bgcolor="#FFFFFF" style="border:1px solid;"><font style="font-size:12px">今年销售额</font></td>
<td width="8%" align="center" bgcolor="#FFFFFF" style="border:1px solid;"><font style="font-size:12px">同比增长额</font></td>
<td width="10%" align="center" bgcolor="#FFFFFF" style="border:1px solid;"><font style="font-size:12px">备注</font></td>
</tr>
<%
	while(not rs.eof)
		response.Write("<tr height='20' style='border: 1px solid; '>")
		response.Write("<td bgcolor=""#FFFFFF"" style=""border:1px solid;""><font style=""font-size:12px"">"&rs("fnumber")&"</font></td>")
		response.Write("<td bgcolor=""#FFFFFF"" style=""border:1px solid;""><font style=""font-size:12px"">"&rs("fname")&"</font></td>")
		response.Write("<td bgcolor=""#FFFFFF"" style=""border:1px solid;""><font style=""font-size:12px"">"&rs("fmodel")&"</font></td>")
		response.Write("<td bgcolor=""#FFFFFF"" style=""border:1px solid;"" align='right'><font style=""font-size:12px"">"&FormatNumber(rs("FDecimal"),2,-1)&"</font></td>")
		response.Write("<td bgcolor=""#FFFFFF"" style=""border:1px solid;"" align='right'><font style=""font-size:12px"">"&FormatNumber(rs("FDecimal1"),2,-1)&"</font></td>")
		response.Write("<td bgcolor=""#FFFFFF"" style=""border:1px solid;"" align='right'><font style=""font-size:12px"">"&FormatNumber(rs("FDecimal2"),2,-1)&"</font></td>")
		response.Write("<td bgcolor=""#FFFFFF"" style=""border:1px solid;"" align='right'><font style=""font-size:12px"">"&FormatNumber(rs("FDecimal3"),2,-1)&"</font></td>")
		response.Write("<td bgcolor=""#FFFFFF"" style=""border:1px solid;"" align='right'><font style=""font-size:12px"">"&FormatNumber(rs("FDecimal4"),2,-1)&"</font></td>")
		response.Write("<td bgcolor=""#FFFFFF"" style=""border:1px solid;"" align='right'><font style=""font-size:12px"">"&FormatNumber(rs("FDecimal5"),2,-1)&"</font></td>")
		response.Write("<td bgcolor=""#FFFFFF"" style=""border:1px solid;""><font style=""font-size:12px"">&nbsp;</font></td>")
		response.Write("</tr>")
		tdbls1=tdbls1+cdbl(rs("FDecimal"))
		tdbls2=tdbls2+cdbl(rs("FDecimal1"))
		tdbls3=tdbls3+cdbl(rs("FDecimal3"))
		tdbls4=tdbls4+cdbl(rs("FDecimal4"))
		tdbls5=tdbls5+cdbl(rs("FDecimal5"))
		rs.movenext
	wend
	dim wy,bfb
	wy=tdbls5\10000
	if tdbls5>=10000 and tdbls5<50000 then
		zdcp=(tdbls5\10000)*400
		bfb="4%"
	elseif tdbls5>=50000 and tdbls5<100000 then
		zdcp=(tdbls5\10000)*500
		bfb="5%"
	else
		zdcp=(tdbls5\10000)*600
		bfb="6%"
	end if
%>
<tr height="20">
<td align="center" bgcolor="#FFFFFF" style="border:1px solid;"><font style="font-size:12px">合计 </font></td>
<td bgcolor="#FFFFFF" style="border:1px solid;">&nbsp;</font></td>
<td bgcolor="#FFFFFF" style="border:1px solid;">&nbsp;</font></td>
<td bgcolor="#FFFFFF" style="border:1px solid;" align='right'><font style="font-size:12px"><%=FormatNumber(tdbls1,2,-1)%></font></td>
<td bgcolor="#FFFFFF" style="border:1px solid;" align='right'><font style="font-size:12px"><%=FormatNumber(tdbls2,2,-1)%></font></td>
<td bgcolor="#FFFFFF" style="border:1px solid;">&nbsp;</font></td>
<td bgcolor="#FFFFFF" style="border:1px solid;" align='right'><font style="font-size:12px"><%=FormatNumber(tdbls3,2,-1)%></font></td>
<td bgcolor="#FFFFFF" style="border:1px solid;" align='right'><font style="font-size:12px"><%=FormatNumber(tdbls4,2,-1)%></font></td>
<td bgcolor="#FFFFFF" style="border:1px solid;" align='right'><font style="font-size:12px"><%=FormatNumber(tdbls5,2,-1)%></font></td>
<td bgcolor="#FFFFFF" style="border:1px solid;">&nbsp;</font></td>
</tr>
<tr>
<td align="left" bgcolor="#FFFFFF" colspan="2" style="border:1px solid;"><font style="font-size:14px">
重点销售产品总销售额同比增长额(万元)</font></td>
<td align="center" bgcolor="#FFFFFF" colspan="1" style="border:1px solid;"><font style="font-size:14px">
<%=wy%></font></td>
<td align="left" bgcolor="#FFFFFF" colspan="2" style="border:1px solid;"><font style="font-size:14px">
奖励比例</font></td>
<td align="center" bgcolor="#FFFFFF" colspan="1" style="border:1px solid;"><font style="font-size:14px">
<%=bfb%></font></td>
<td align="left" bgcolor="#FFFFFF" colspan="2" style="border:1px solid;"><font style="font-size:14px">
奖励额(元)</font></td>
<td align="center" bgcolor="#FFFFFF" colspan="2" style="border:1px solid;"><font style="font-size:14px">
<%=zdcp%></font></td>
</tr>
<tr><td align="left" bgcolor="#FFFFFF" colspan="10" style="border:1px solid;"><font style="font-size:12px">
注：                                <br/>                                                                                                       
1、买赠促销的赠送部分计入销量，本表年度（公历指1月1日至9月25日）；<br/>
2、本表核算办法参照"美农供销函[2012]18号"《关于美丰重点销售产品客户激励政策的说明》； <br/>
3、核算公式：1万元 ≤2012年销售额-2011年销售额＜5万元，奖励额=增长额*4%；5万元 ≤2012年销售额-2011年销售额＜10万元，奖励额=增长额*5%；2012年销售额- 2011年销售额≥10万元，奖励额=增长额*6%。<br/>
4、增长部分销售额取万元整数（不计小数部分取整）。
</font></td></tr>
<tr height="50"><td colspan="10" align="right" bgcolor="#FFFFFF"><font style="font-size:12px">
美丰农化有限公司盖章</font></td></tr>
<tr height="20"><td colspan="10" align="right" bgcolor="#FFFFFF"><font style="font-size:12px">
<%=EDate%></font></td></tr>
</table>
<%
end if
%>
<div class="PageNext">&nbsp;</div>
<%
	set rs = server.createobject("adodb.recordset")
	sql="Select b.FYear,b.FPeriod,Sum(b.FBeginBalance) FBeginBalance "&_
			" From AIS20091116143745.dbo.t_Balance b, AIS20091116143745.dbo.t_Account a Where (a.FGroupID<600 or a.FGroupID>=700) AND  "&_
			" EXISTS (Select d.FDetailID From AIS20091116143745.dbo.t_ItemDetailV d Where d.FItemclassID = 1 AND d.FitemID="&Cust&" AND b.FDetailID=d.FDetailID )  "&_
			" and b.FAccountID = a.FAccountID and ( b. FYear="&left(SDate,4)&" and  b.FPeriod=1 "&_
			") and b.FCurrencyID=1 and a.FNumber in ('1131.01','2181.06','2181.08','2181.12','2181.13','2181.14') Group by b.FYear,b.FPeriod"
	rs.open sql,conn,1,1
	dim qcye:qcye=0-tknc+ygsc
	if not rs.eof then qcye=qcye+rs("FBeginBalance")
'	allsum=FormatNumber(cdbl(qcye)+cdbl(hwxs)-cdbl(bnskx)-cdbl(zkjs)-cdbl(dcyhe)-cdbl(zdcp),2,-1)
	a1=bnskx-qcye
	a2=bnskx-qcye-hwxs
	a3=zkjs+dcyhe+zdcp
	allsum=zkjs+dcyhe+zdcp+bnskx-qcye-hwxs
%>
<table width="100%" cellpadding="3" cellspacing="0" bgcolor="#000000">
<tr height="40"><td colspan="4" align="center" bgcolor="#FFFFFF"><font style="font-size:18px"><b>客户年度销售结算表</b></font></td></tr>
<tr height="20"><td colspan="4" align="center" bgcolor="#FFFFFF"><font style="font-size:12px">结算期间:<%=SDate%>至<%=EDate%></font></td></tr>
<tr height="30"><td colspan="4" align="left" bgcolor="#FFFFFF"><font style="font-size:14px"><b>单位名称：<%=CustName%>（<%=CustID%>）</b></font></td></tr>
<tr height="30">
<td width="5%" align="center" bgcolor="#FFFFFF" style="border:1px solid;"><font style="font-size:12px">行号 </font></td>
<td width="20%" align="center" bgcolor="#FFFFFF" style="border:1px solid;"><font style="font-size:12px">项目 </font></td>
<td width="20%" align="center" bgcolor="#FFFFFF" style="border:1px solid;"><font style="font-size:12px">金额（元） </font></td>
<td width="55%" align="center" bgcolor="#FFFFFF" style="border:1px solid;"><font style="font-size:12px">备注</font></td>
</tr>
<tr height="30">
<td width="5%" align="center" bgcolor="#FFFFFF" style="border:1px solid;"><font style="font-size:12px">1 </font></td>
<td width="20%" align="left" bgcolor="#FFFFFF" style="border:1px solid;"><font style="font-size:12px"><b>一、收款</b> </font></td>
<td width="20%" align="right" bgcolor="#FFFFFF" style="border:1px solid;"><font style="font-size:12px" class="t1"><%=FormatNumber(a1,2,-1)%></font></td>
<td width="55%" align="left" bgcolor="#FFFFFF" style="border:1px solid;"><font style="font-size:12px">收款=上年结转+本年收款</font></td>
</tr>
<tr height="30">
<td width="5%" align="center" bgcolor="#FFFFFF" style="border:1px solid;"><font style="font-size:12px">2 </font></td>
<td width="20%" align="left" bgcolor="#FFFFFF" style="border:1px solid;"><font style="font-size:12px">&nbsp;&nbsp;&nbsp;&nbsp;上年结转 </font></td>
<td width="20%" align="right" bgcolor="#FFFFFF" style="border:1px solid;"><font style="font-size:12px" class="t2"><%=FormatNumber(-qcye,2,-1)%></font></td>
<td width="55%" align="left" bgcolor="#FFFFFF" style="border:1px solid;"><font style="font-size:12px">截止2011年12月31日客户留存余额</font></td>
</tr>
<tr height="30">
<td width="5%" align="center" bgcolor="#FFFFFF" style="border:1px solid;"><font style="font-size:12px">3 </font></td>
<td width="20%" align="left" bgcolor="#FFFFFF" style="border:1px solid;"><font style="font-size:12px">&nbsp;&nbsp;&nbsp;&nbsp;本年收款 </font></td>
<td width="20%" align="right" bgcolor="#FFFFFF" style="border:1px solid;"><font style="font-size:12px" class="t3"><%=FormatNumber(bnskx,2,-1)%></font></td>
<td width="55%" align="left" bgcolor="#FFFFFF" style="border:1px solid;"><font style="font-size:12px">见附表"客户收款对账明细表"</font></td>
</tr>
<tr height="30">
<td width="5%" align="center" bgcolor="#FFFFFF" style="border:1px solid;"><font style="font-size:12px">4</font></td>
<td width="20%" align="left" bgcolor="#FFFFFF" style="border:1px solid;"><font style="font-size:12px"><b>二、货物销售</b></font></td>
<td width="20%" align="right" bgcolor="#FFFFFF" style="border:1px solid;"><font style="font-size:12px" class="t4"><%=FormatNumber(hwxs,2,-1)%></font></td>
<td width="55%" align="left" bgcolor="#FFFFFF" style="border:1px solid;"><font style="font-size:12px">见附表"销售发货对账明细表"</font></td>
</tr>
<tr height="30">
<td width="5%" align="center" bgcolor="#FFFFFF" style="border:1px solid;"><font style="font-size:12px">5 </font></td>
<td width="20%" align="left" bgcolor="#FFFFFF" style="border:1px solid;"><font style="font-size:12px"><b>三、代付其他款 </b></font></td>
<td width="20%" align="right" bgcolor="#FFFFFF" style="border:1px solid;" class="fedit"><font style="font-size:12px;width:100%;" class="t5">0</font></td>
<td width="55%" align="left" bgcolor="#FFFFFF" style="border:1px solid;"><font style="font-size:12px">见附表"代付其他明细表"</font></td>
</tr>
<tr height="30">
<td width="5%" align="center" bgcolor="#FFFFFF" style="border:1px solid;"><font style="font-size:12px">6 </font></td>
<td width="20%" align="left" bgcolor="#FFFFFF" style="border:1px solid;"><font style="font-size:12px"><b>四、余额 </b></font></td>
<td width="20%" align="right" bgcolor="#FFFFFF" style="border:1px solid;"><font style="font-size:12px;width:100%;" class="t6"><%=FormatNumber(a2,2,-1)%></font></td>
<td width="55%" align="left" bgcolor="#FFFFFF" style="border:1px solid;"><font style="font-size:12px">余额=收款-货款销售-代付其他款</font></td>
</tr>
<tr height="30">
<td width="5%" align="center" bgcolor="#FFFFFF" style="border:1px solid;"><font style="font-size:12px">7 </font></td>
<td width="20%" align="left" bgcolor="#FFFFFF" style="border:1px solid;"><font style="font-size:12px"><b>五、销售优惠 </b></font></td>
<td width="20%" align="right" bgcolor="#FFFFFF" style="border:1px solid;"><font style="font-size:12px;width:100%;" class="t7"><%=FormatNumber(a3,2,-1)%></font></td>
<td width="55%" align="left" bgcolor="#FFFFFF" style="border:1px solid;"><font style="font-size:12px">销售优惠=冬储款优惠额+销售折扣额+其他奖励</font></td>
</tr>
<tr height="30">
<td width="5%" align="center" bgcolor="#FFFFFF" style="border:1px solid;"><font style="font-size:12px">8 </font></td>
<td width="20%" align="left" bgcolor="#FFFFFF" style="border:1px solid;"><font style="font-size:12px">&nbsp;&nbsp;&nbsp;&nbsp;冬储款优惠额 </font></td>
<td width="20%" align="right" bgcolor="#FFFFFF" style="border:1px solid;"><font style="font-size:12px" class="t8"><%=FormatNumber(dcyhe,2,-1)%></font></td>
<td width="55%" align="left" bgcolor="#FFFFFF" style="border:1px solid;"><font style="font-size:12px">见附表"冬储优惠额明细表"</font></td>
</tr>
<tr height="30">
<td width="5%" align="center" bgcolor="#FFFFFF" style="border:1px solid;"><font style="font-size:12px">9</font></td>
<td width="20%" align="left" bgcolor="#FFFFFF" style="border:1px solid;"><font style="font-size:12px">&nbsp;&nbsp;&nbsp;&nbsp;销售折扣额 </font></td>
<td width="20%" align="right" bgcolor="#FFFFFF" style="border:1px solid;"><font style="font-size:12px" class="t9"><%=FormatNumber(zkjs,2,-1)%></font></td>
<td width="55%" align="left" bgcolor="#FFFFFF" style="border:1px solid;"><font style="font-size:12px">见附表"客户销售折扣结算表"</font></td>
</tr>
<tr height="30">
<td width="5%" align="center" bgcolor="#FFFFFF" style="border:1px solid;"><font style="font-size:12px">10</font></td>
<td width="20%" align="left" bgcolor="#FFFFFF" style="border:1px solid;"><font style="font-size:12px">&nbsp;&nbsp;&nbsp;&nbsp;重点产品奖励 </font></td>
<td width="20%" align="right" bgcolor="#FFFFFF" style="border:1px solid;"><font style="font-size:12px" class="t10"><%=FormatNumber(zdcp,2,-1)%></font></td>
<td width="55%" align="left" bgcolor="#FFFFFF" style="border:1px solid;"><font style="font-size:12px">见附表"重点产品销售奖励结算表"此奖励以本公司产品形式赠送</font></td>
</tr>
<tr height="30">
<td width="5%" align="center" bgcolor="#FFFFFF" style="border:1px solid;"><font style="font-size:12px">11 </font></td>
<td width="20%" align="left" bgcolor="#FFFFFF" style="border:1px solid;"><font style="font-size:12px"><b>六、结余 </b></font></td>
<td width="20%" align="right" bgcolor="#FFFFFF" style="border:1px solid;"><font style="font-size:12px;width:100%;" class="t11"><%=FormatNumber(allsum,2,-1)%></font></td>
<td width="55%" align="left" bgcolor="#FFFFFF" style="border:1px solid;"><font style="font-size:12px">结余=余额+销售优惠</font></td>
</tr>
<tr height="50"><td colspan="9" align="right" bgcolor="#FFFFFF"><font style="font-size:12px">
美丰农化有限公司盖章</font></td></tr>
<tr height="20"><td colspan="9" align="right" bgcolor="#FFFFFF"><font style="font-size:12px">
<%=EDate%></font></td></tr>
<tr height="20"><td colspan="9" align="left" bgcolor="#FFFFFF"><font style="font-size:12px">&nbsp;</font></td></tr>
<tr height="30"><td colspan="9" align="left" bgcolor="#FFFFFF"><font style="font-size:12px">
注：①核对无误后签名盖章后寄回（或传真）至我公司；<br>
&nbsp;&nbsp;&nbsp;&nbsp;②如有异议请及时与我公司业务负责人核对，并将有异议事项注明签名盖章后原件寄回我公司；<br>
&nbsp;&nbsp;&nbsp;&nbsp;③请在收到挂号信10天内（以挂号信的邮戳日期为准）回传，不予确认回传的客户，美丰公司视同无异议处理；<br>
&nbsp;&nbsp;&nbsp;&nbsp;④通信地址：温州经济技术开发区九峰山路2号，邮编：325011，传真号码：0577-86521230，联系电话：0577-86522798；<br>
&nbsp;&nbsp;&nbsp;&nbsp;⑤本表附件共_<%=zint%>_份。
</font></td></tr>
<tr>
<td colspan="3" bgcolor="#FFFFFF" style="border:1px solid;">
<font style="font-size:12px;">
结论：1、信息核对无误</font>
<br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br />
<font style="font-size:12px;">
客户单位盖章&nbsp;&nbsp;&nbsp;&nbsp;</font><br /><br /><br />
<font style="font-size:12px;">
负责人签名：</font><br /><br /><br />
<font style="font-size:12px;float:right;">
年&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;月&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;日;&nbsp;&nbsp;&nbsp;&nbsp;</font>
</font></td>
<td bgcolor="#FFFFFF" style="border:1px solid;">
<font style="font-size:12px;">
2、信息不符，请列明不符的详细情况</font>
<br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br />
<font style="font-size:12px;">
客户单位盖章&nbsp;&nbsp;&nbsp;&nbsp;</font><br /><br /><br />
<font style="font-size:12px;">
负责人签名：</font><br /><br /><br />
<font style="font-size:12px;float:right;">
年&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;月&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;日;&nbsp;&nbsp;&nbsp;&nbsp;</font>
</font></td>
</tr>
</table>
<div class="PageNext">&nbsp;</div>
<table width="100%" cellpadding="3" cellspacing="0" bgcolor="#000000">
<tr height="40"><td colspan="4" align="center" bgcolor="#FFFFFF"><font style="font-size:18px"><b>客户年度销售结算表</b></font></td></tr>
<tr height="20"><td colspan="4" align="center" bgcolor="#FFFFFF"><font style="font-size:12px">结算期间:<%=SDate%>至<%=EDate%></font></td></tr>
<tr height="30"><td colspan="4" align="left" bgcolor="#FFFFFF"><font style="font-size:14px"><b>单位名称：<%=CustName%>（<%=CustID%>）</b></font></td></tr>
<tr height="30">
<td width="5%" align="center" bgcolor="#FFFFFF" style="border:1px solid;"><font style="font-size:12px">行号 </font></td>
<td width="20%" align="center" bgcolor="#FFFFFF" style="border:1px solid;"><font style="font-size:12px">项目 </font></td>
<td width="20%" align="center" bgcolor="#FFFFFF" style="border:1px solid;"><font style="font-size:12px">金额（元） </font></td>
<td width="55%" align="center" bgcolor="#FFFFFF" style="border:1px solid;"><font style="font-size:12px">备注</font></td>
</tr>
<tr height="30">
<td width="5%" align="center" bgcolor="#FFFFFF" style="border:1px solid;"><font style="font-size:12px">1 </font></td>
<td width="20%" align="left" bgcolor="#FFFFFF" style="border:1px solid;"><font style="font-size:12px"><b>一、收款</b> </font></td>
<td width="20%" align="right" bgcolor="#FFFFFF" style="border:1px solid;"><font style="font-size:12px" class="t1"><%=FormatNumber(a1,2,-1)%></font></td>
<td width="55%" align="left" bgcolor="#FFFFFF" style="border:1px solid;"><font style="font-size:12px">收款=上年结转+本年收款</font></td>
</tr>
<tr height="30">
<td width="5%" align="center" bgcolor="#FFFFFF" style="border:1px solid;"><font style="font-size:12px">2 </font></td>
<td width="20%" align="left" bgcolor="#FFFFFF" style="border:1px solid;"><font style="font-size:12px">&nbsp;&nbsp;&nbsp;&nbsp;上年结转 </font></td>
<td width="20%" align="right" bgcolor="#FFFFFF" style="border:1px solid;"><font style="font-size:12px" class="t2"><%=FormatNumber(-qcye,2,-1)%></font></td>
<td width="55%" align="left" bgcolor="#FFFFFF" style="border:1px solid;"><font style="font-size:12px">截止2011年12月31日客户留存余额</font></td>
</tr>
<tr height="30">
<td width="5%" align="center" bgcolor="#FFFFFF" style="border:1px solid;"><font style="font-size:12px">3 </font></td>
<td width="20%" align="left" bgcolor="#FFFFFF" style="border:1px solid;"><font style="font-size:12px">&nbsp;&nbsp;&nbsp;&nbsp;本年收款 </font></td>
<td width="20%" align="right" bgcolor="#FFFFFF" style="border:1px solid;"><font style="font-size:12px" class="t3"><%=FormatNumber(bnskx,2,-1)%></font></td>
<td width="55%" align="left" bgcolor="#FFFFFF" style="border:1px solid;"><font style="font-size:12px">见附表"客户收款对账明细表"</font></td>
</tr>
<tr height="30">
<td width="5%" align="center" bgcolor="#FFFFFF" style="border:1px solid;"><font style="font-size:12px">4</font></td>
<td width="20%" align="left" bgcolor="#FFFFFF" style="border:1px solid;"><font style="font-size:12px"><b>二、货物销售</b></font></td>
<td width="20%" align="right" bgcolor="#FFFFFF" style="border:1px solid;"><font style="font-size:12px" class="t4"><%=FormatNumber(hwxs,2,-1)%></font></td>
<td width="55%" align="left" bgcolor="#FFFFFF" style="border:1px solid;"><font style="font-size:12px">见附表"销售发货对账明细表"</font></td>
</tr>
<tr height="30">
<td width="5%" align="center" bgcolor="#FFFFFF" style="border:1px solid;"><font style="font-size:12px">5 </font></td>
<td width="20%" align="left" bgcolor="#FFFFFF" style="border:1px solid;"><font style="font-size:12px"><b>三、代付其他款 </b></font></td>
<td width="20%" align="right" bgcolor="#FFFFFF" style="border:1px solid;" class="fedit"><font style="font-size:12px;width:100%;" class="t5">0</font></td>
<td width="55%" align="left" bgcolor="#FFFFFF" style="border:1px solid;"><font style="font-size:12px">见附表"代付其他明细表"</font></td>
</tr>
<tr height="30">
<td width="5%" align="center" bgcolor="#FFFFFF" style="border:1px solid;"><font style="font-size:12px">6 </font></td>
<td width="20%" align="left" bgcolor="#FFFFFF" style="border:1px solid;"><font style="font-size:12px"><b>四、余额 </b></font></td>
<td width="20%" align="right" bgcolor="#FFFFFF" style="border:1px solid;"><font style="font-size:12px;width:100%;" class="t6"><%=FormatNumber(a2,2,-1)%></font></td>
<td width="55%" align="left" bgcolor="#FFFFFF" style="border:1px solid;"><font style="font-size:12px">余额=收款-货款销售-代付其他款</font></td>
</tr>
<tr height="30">
<td width="5%" align="center" bgcolor="#FFFFFF" style="border:1px solid;"><font style="font-size:12px">7 </font></td>
<td width="20%" align="left" bgcolor="#FFFFFF" style="border:1px solid;"><font style="font-size:12px"><b>五、销售优惠 </b></font></td>
<td width="20%" align="right" bgcolor="#FFFFFF" style="border:1px solid;"><font style="font-size:12px;width:100%;" class="t7"><%=FormatNumber(a3,2,-1)%></font></td>
<td width="55%" align="left" bgcolor="#FFFFFF" style="border:1px solid;"><font style="font-size:12px">销售优惠=冬储款优惠额+销售折扣额+其他奖励</font></td>
</tr>
<tr height="30">
<td width="5%" align="center" bgcolor="#FFFFFF" style="border:1px solid;"><font style="font-size:12px">8 </font></td>
<td width="20%" align="left" bgcolor="#FFFFFF" style="border:1px solid;"><font style="font-size:12px">&nbsp;&nbsp;&nbsp;&nbsp;冬储款优惠额 </font></td>
<td width="20%" align="right" bgcolor="#FFFFFF" style="border:1px solid;"><font style="font-size:12px" class="t8"><%=FormatNumber(dcyhe,2,-1)%></font></td>
<td width="55%" align="left" bgcolor="#FFFFFF" style="border:1px solid;"><font style="font-size:12px">见附表"冬储优惠额明细表"</font></td>
</tr>
<tr height="30">
<td width="5%" align="center" bgcolor="#FFFFFF" style="border:1px solid;"><font style="font-size:12px">9</font></td>
<td width="20%" align="left" bgcolor="#FFFFFF" style="border:1px solid;"><font style="font-size:12px">&nbsp;&nbsp;&nbsp;&nbsp;销售折扣额 </font></td>
<td width="20%" align="right" bgcolor="#FFFFFF" style="border:1px solid;"><font style="font-size:12px" class="t9"><%=FormatNumber(zkjs,2,-1)%></font></td>
<td width="55%" align="left" bgcolor="#FFFFFF" style="border:1px solid;"><font style="font-size:12px">见附表"客户销售折扣结算表"</font></td>
</tr>
<tr height="30">
<td width="5%" align="center" bgcolor="#FFFFFF" style="border:1px solid;"><font style="font-size:12px">10</font></td>
<td width="20%" align="left" bgcolor="#FFFFFF" style="border:1px solid;"><font style="font-size:12px">&nbsp;&nbsp;&nbsp;&nbsp;重点产品奖励 </font></td>
<td width="20%" align="right" bgcolor="#FFFFFF" style="border:1px solid;"><font style="font-size:12px" class="t10"><%=FormatNumber(zdcp,2,-1)%></font></td>
<td width="55%" align="left" bgcolor="#FFFFFF" style="border:1px solid;"><font style="font-size:12px">见附表"重点产品销售奖励结算表"此奖励以本公司产品形式赠送</font></td>
</tr>
<tr height="30">
<td width="5%" align="center" bgcolor="#FFFFFF" style="border:1px solid;"><font style="font-size:12px">11 </font></td>
<td width="20%" align="left" bgcolor="#FFFFFF" style="border:1px solid;"><font style="font-size:12px"><b>六、结余 </b></font></td>
<td width="20%" align="right" bgcolor="#FFFFFF" style="border:1px solid;"><font style="font-size:12px;width:100%;" class="t11"><%=FormatNumber(allsum,2,-1)%></font></td>
<td width="55%" align="left" bgcolor="#FFFFFF" style="border:1px solid;"><font style="font-size:12px">结余=余额+销售优惠</font></td>
</tr>
<tr height="50"><td colspan="9" align="right" bgcolor="#FFFFFF"><font style="font-size:12px">
美丰农化有限公司盖章</font></td></tr>
<tr height="20"><td colspan="9" align="right" bgcolor="#FFFFFF"><font style="font-size:12px">
<%=EDate%></font></td></tr>
<tr height="20"><td colspan="9" align="left" bgcolor="#FFFFFF"><font style="font-size:12px">&nbsp;</font></td></tr>
<tr height="30"><td colspan="9" align="left" bgcolor="#FFFFFF"><font style="font-size:12px">
注：①核对无误后签名盖章后寄回（或传真）至我公司；<br>
&nbsp;&nbsp;&nbsp;&nbsp;②如有异议请及时与我公司业务负责人核对，并将有异议事项注明签名盖章后原件寄回我公司；<br>
&nbsp;&nbsp;&nbsp;&nbsp;③请在收到挂号信10天内（以挂号信的邮戳日期为准）回传，不予确认回传的客户，美丰公司视同无异议处理；<br>
&nbsp;&nbsp;&nbsp;&nbsp;④通信地址：温州经济技术开发区九峰山路2号，邮编：325011，传真号码：0577-86521230，联系电话：0577-86522798；<br>
&nbsp;&nbsp;&nbsp;&nbsp;⑤本表附件共_<%=zint%>_份。
</font></td></tr>
<tr>
<td colspan="3" bgcolor="#FFFFFF" style="border:1px solid;">
<font style="font-size:12px;">
结论：1、信息核对无误</font>
<br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br />
<font style="font-size:12px;">
客户单位盖章&nbsp;&nbsp;&nbsp;&nbsp;</font><br /><br /><br />
<font style="font-size:12px;">
负责人签名：</font><br /><br /><br />
<font style="font-size:12px;float:right;">
年&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;月&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;日;&nbsp;&nbsp;&nbsp;&nbsp;</font>
</font></td>
<td bgcolor="#FFFFFF" style="border:1px solid;">
<font style="font-size:12px;">
2、信息不符，请列明不符的详细情况</font>
<br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br />
<font style="font-size:12px;">
客户单位盖章&nbsp;&nbsp;&nbsp;&nbsp;</font><br /><br /><br />
<font style="font-size:12px;">
负责人签名：</font><br /><br /><br />
<font style="font-size:12px;float:right;">
年&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;月&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;日;&nbsp;&nbsp;&nbsp;&nbsp;</font>
</font></td>
</tr>
</table>
<%
rs2.movenext
wend
  rs.close
  set rs=nothing
  rs2.close
  set rs2=nothing
end if
conn.close()
set conn=nothing
 %>
