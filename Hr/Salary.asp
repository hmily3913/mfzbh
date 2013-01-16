<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN""http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<!--#include file="../CheckAdmin.asp" -->
<head>
<META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=utf-8" />
<TITLE>欢迎进入系统后台</TITLE>
<link rel="stylesheet" href="../css/center.css">
<script language="javascript" src="../Script/jquery-1.7.2.min.js"></script>
<link rel="stylesheet" href="../css/jquery-ui.css">
<script language="javascript" src="../Script/jquery-ui.min.js"></script>
<link rel="stylesheet" href="../css/flexigrid.bbit.css">
<script language="javascript" src="../Script/jquery.flexigrid.js"></script>
<script language="javascript" src="../Script/jquery.validate.js"></script>
<link rel="stylesheet" href="../css/zTreeStyle.css">
<SCRIPT type="text/javascript" src="../Script/jquery.ztree.all-3.2.min.js"></SCRIPT>
<style>
	#dialog-form label,#dialog-form input { display:block; }
	#dialog-form input.text { margin-bottom:8px; width:95%; padding: 4px;}
	fieldset { padding:0; border:0; margin-top:10px;}
	.ui-dialog .ui-state-error { padding: .3em; }
	.validateTips { border: 1px solid transparent; padding: 3ps; }
</style>

</head>
<body>
<table id="flex1" style="display:none"></table>
<script language="javascript">

$("#flex1").flexigrid
	(
	{
	url: 'SalaryDt.asp?ProcessType=DetailsList',
	dataType: 'json',
	autoload:false,
	colModel : [
	{display: '年份', name : 'Years', width : 40, sortable : true, align: 'left'},
	{display: '月份', name : 'Months', width : 40, sortable : true, align: 'left'},
	{display: '工号', name : 'UserID', width : 40, sortable : true, align: 'left'},
	{display: '姓名', name : 'UserName', width : 60, sortable : true, align: 'left'},
	{display: '资质月薪', name : 'ZZYX', width : 60, sortable : true, align: 'left'},
	{display: '月奖', name : 'YJ', width : 60, sortable : true, align: 'left'},
	{display: '加班', name : 'JBGZ', width : 60, sortable : true, align: 'left'},
	{display: '补发', name : 'BFGZ', width : 60, sortable : true, align: 'left'},
	{display: '扣罚', name : 'KJGZ', width : 60, sortable : true, align: 'left'},
	{display: '应发工资', name : 'YFGZ', width : 60, sortable : true, align: 'left'},
	{display: '通勤费', name : 'TQF', width : 60, sortable : true, align: 'left'},
	{display: '月发小计', name : 'YFXJ', width : 60, sortable : true, align: 'left'},
	{display: '代扣个人社保', name : 'DKGRSHBX', width : 60, sortable : true, align: 'left'},
	{display: '代扣个人所得税', name : 'DKGRSDS', width : 60, sortable : true, align: 'left'},
	{display: '代扣工会会费', name : 'DKGHHF', width : 60, sortable : true, align: 'left'},
	{display: '餐费', name : 'DKCF', width : 60, sortable : true, align: 'left'},
	{display: '水费', name : 'DKSF', width : 60, sortable : true, align: 'left'},
	{display: '电费', name : 'DKDF', width : 60, sortable : true, align: 'left'},
	{display: '住房费', name : 'ZFYJ', width : 60, sortable : true, align: 'left'},
	{display: '代扣其他', name : 'DKQT', width : 60, sortable : true, align: 'left'},
	{display: '实付金额', name : 'SFJE', width : 60, sortable : true, align: 'left'}
		],
	buttons : [
		{name: '设置密码',  onpress : test},
		{separator: true},
		{name: '条件查询',  onpress : test},
		{separator: true},
		{name: '数据导入',  onpress : test},
		{separator: true},
		{name: '删除',  onpress : test},
		{separator: true},
		{name: '打印工资条',  onpress : test},
		{separator: true},
		{name: '下载模版',  onpress : test},
		{separator: true},
		{name: '历史数据查询',  onpress : test},
		{separator: true}
		],
	onRowDblclick:rowdbclick,
	sortname: "SerialNum",
	sortorder: "desc",
	singleSelect: false,
	striped:true,//
	rp: 20,
	usepager: true,
	title: '工资查询',
	showTableToggleBtn: true,
	showcheckbox: true,
	width:'100%',
	height: 320
	}
	);
	
	function rowdbclick(rowData){
	}
	function test(com,grid)
	{
		if (com=='条件查询')
			{
				$('#allfield').show();
				$('#SJDR').hide();
				$('#GZPDDiv').hide();
				$('#SearchDiv').show();
				$('#ProcessType').val('Search');
				$( "#dialog-form" ).dialog( "open" );
			}
		else if (com=='设置密码')
			{
				$('#allfield').show();
				$('#SJDR').hide();
				$('#GZPDDiv').show();
				$('.cfpd').show();
				$('#SearchDiv').hide();
				$('#ProcessType').val('setPassword');
				$( "#dialog-form" ).dialog( "open" );
			}			
		else if (com=='数据导入')
			{
				$( "#dialog-form" ).dialog( "open" );
				$('#allfield').hide();
				$('#SJDR').show();
				$('#fileurl').val('');
				$('#ProcessType').val('xls2sql');
				$('#mfileup').attr("src","../Script/xheditor_plugins/multiupload/multiupload.html");
			}
		else if(com=='打印工资条')
		{
				$('#allfield').show();
				$('#SJDR').hide();
				$('#GZPDDiv').hide();
				$('#SearchDiv').show();
				$('#ProcessType').val('PrintSly');
				$( "#dialog-form" ).dialog( "open" );
		}
		else if(com=='下载模版'){
			window.open("SalaryFMT.xls");
		}
		else if(com=='删除'){
				if($('.trSelected', grid).length==0){
					$('#messagetext').text('请先选择一条记录再进行操作！');
					$( "#dialog-message" ).dialog( "open" );
					return false;
				}
				$('#confirmtext').text("确定要删除所选工资信息?");
				$( "#dialog-confirm" ).dialog( "open" );
		}
		else if(com=='历史数据查询'){
			window.open("http://220.189.244.202/mfhr/");
		}
	}
	
	
$(function(){
		$( "#dialog:ui-dialog" ).dialog( "destroy" );
	//确认
		$( "#dialog-confirm" ).dialog({
			autoOpen:false,
			resizable: false,
			height:200,
			modal: true,
			buttons: {
				"确认": function() {
					$( this ).dialog( "close" );
					var AllSNum="";
					for(var i=0;i<$('.trSelected', $('#flex1')).length;i++){
						AllSNum=AllSNum+$($('.trSelected', $('#flex1'))[i]).attr("id").replace("row","")+",";
					}
					AllSNum=AllSNum.substr(0,AllSNum.length-1);
				  $.post('SalaryDt.asp?ProcessType=DelSalary',{"SerialNum":AllSNum},function(data){
						var datajson=jQuery.parseJSON(data);//转换后的JSON对象
						$('#messagetext').text(datajson.messages);
						$( "#dialog-message" ).dialog( "open" );
						if(datajson.status){
							$( "#dialog-form" ).dialog( "close" );
							$("#flex1").flexReload();
						}
				  });
				},
				"取消": function() {
					$( this ).dialog( "close" );
					return false;
				}
			}
		});	
		//提示
		$( "#dialog-message" ).dialog({
			autoOpen: false,
			modal: true,
			buttons: {
				"确定": function() {
					$( this ).dialog( "close" );
				}
			}
		});
		//表单
		$( "#dialog-form" ).dialog({
		autoOpen: false,
		height: 350,
		width: 350,
		modal: true,
		buttons: {
			"确定": function() {
				if($('#ProcessType').val()=='Search'){
					$("#flex1").flexOptions({newp: 1, params:[
						{name:"UserID",value:$('#UserID').val()},
						{name:"UserName",value:$('#UserName').val()},
						{name:"Years",value:$('#Years').val()},
						{name:"Months",value:$('#Months').val()}
						]
					});
					$("#flex1").flexReload();
				}else if($('#ProcessType').val()=='PrintSly'){
					window.open("SalaryDt.asp?print_tag=1&UserID="+$('#UserID').val()+"&UserName="+encodeURIComponent($('#UserName').val())+"&Months="+$('#Months').val()+"&Years="+$('#Years').val()+"&ProcessType="+$('#ProcessType').val());
				}else{
					$('#AddForm').submit();
				}
				$( this ).dialog( "close" );
			},
			Cancel: function() {
				$( this ).dialog( "close" );
			}
		},
		close: function() {
		}
	});
	$("#AddForm").validate({
		submitHandler:function(form){
			$.post('SalaryDt.asp',$("#AddForm").serialize(),function(data){
				var datajson=jQuery.parseJSON(data);//转换后的JSON对象
				$('#messagetext').text(datajson.messages);
				$( "#dialog-message" ).dialog( "open" );
				if(datajson.status){
					$( "#dialog-form" ).dialog( "close" );
					$("#flex1").flexReload();
				}
			});
		}
	});
	<%
	if session("GZSucces")<>true then
	%>
	$('#SJDR').hide();
				$('#GZPDDiv').show();
				$('#SearchDiv').hide();
				$('#ProcessType').val('GZLogin');
				$( "#dialog-form" ).dialog( "open" );
				$('.cfpd').hide();
	<%
	end if
	%>
});
</script>
<div id="dialog-confirm" title="操作确认">
	<p><span class="ui-icon ui-icon-alert" style="float:left; margin:0 7px 20px 0;"></span>
  <b id="confirmtext"></b>
  </p>
</div>
<div id="dialog-message" title="操作提示">
	<p>
		<span class="ui-icon ui-icon-circle-check" style="float:left; margin:0 7px 50px 0;"></span>
		<B id="messagetext">操作失败！.</B>
	</p>
</div>
<div id="dialog-form" title="工资查询" >
	<form id="AddForm">
	<fieldset id="allfield">
    <input type="hidden" id="ProcessType" name="ProcessType" />
    <input type="hidden" id="fileurl" name="fileurl" />
    <input type="hidden" id="swapPost" name="swapPost" />
    <div id="SearchDiv">
		<label for="UserID">职员代码（工号）</label>
		<input type="text" name="UserID" id="UserID" class="text ui-widget-content ui-corner-all" value="<%=session("UserID")%>"/>
		<label for="UserName">姓名</label>
		<input type="text" name="UserName" id="UserName" value="<%=session("UserName")%>" class="text ui-widget-content ui-corner-all" />
		<label for="Years">年份</label>
		<input type="text" name="Years" id="Years" class="text ui-widget-content ui-corner-all required" value="<%=year(now())%>"/>
		<label for="Months">月份</label>
		<input type="text" name="Months" id="Months" value="<%=Month(now())%>" class="text ui-widget-content ui-corner-all required" />
    </div>
    <div id="GZPDDiv">
		<label for="password">密码</label>
		<input type="password" name="password" id="password" value="" class="text ui-widget-content ui-corner-all" />
		<label for="passwordconf" class="cfpd">密码确认</label>
		<input type="password" name="passwordconf" id="passwordconf" value="" class="text ui-widget-content ui-corner-all cfpd" />
    </div>
	</fieldset>
    <div id="SJDR">
    <iframe id="mfileup" name="mfileup" src="#"></iframe>
    </div>
	</form>
</div>

</BODY>
</HTML>
