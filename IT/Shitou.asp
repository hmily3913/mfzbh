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
<style>
	.ui-dialog .ui-state-error { padding: .3em; }
	.validateTips { border: 1px solid transparent; padding: 3ps; }
</style>

</head>
<body>
<table id="flex1" style="display:none"></table>
<script language="javascript">
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
					$('.trSelected', $('#flex1')).each(function(i,fieldone){
						AllSNum=AllSNum+fieldone.id.replace("row","")+",";
					});
					AllSNum=AllSNum.substr(0,AllSNum.length-1);
				  $.post('ShitouDt.asp?ProcessType=Clsstatus',{"SerialNum":AllSNum},function(data){
						var datajson=jQuery.parseJSON(data);
						$('#messagetext').text(datajson.messages);
						$( "#dialog-message" ).dialog( "open" );
						if(datajson.status) $("#flex1").flexReload();
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
});
$("#flex1").flexigrid
	(
	{
	url: 'ShitouDt.asp?ProcessType=DetailsList',
	dataType: 'json',
	colModel : [
	{display: '用户ID', name : 'Fk3UserID', width : 60, sortable : true, align: 'left'},
	{display: '用户名', name : 'FuserName', width : 60, sortable : true, align: 'left'},
	{display: 'K3用户', name : 'FK3userName', width : 60, sortable : true, align: 'left'},
	{display: '最后登录时间', name : 'Flogindate', width : 120, sortable : true, align: 'left'},
	{display: '登陆状态', name : 'fstatus', width : 60, sortable : true, align: 'left'}
		],
	buttons : [
		{name: '清除',  onpress : test},
		{separator: true}
		],
//	onRowDblclick:rowdbclick,
	sortname: "Flogindate",
	sortorder: "desc",
	singleSelect: false,
	striped:true,//
	rp: 20,
	usepager: true,
	title: '实投单网络控制',
	showTableToggleBtn: true,
	showcheckbox: true,
	width:'100%',
	height: 420
	}
	);
	
	function rowdbclick(rowData){
	}
	function test(com,grid)
	{
		if (com=='清除')
			{
				if($('.trSelected', grid).length==0){
					$('#messagetext').text('请先选择一条记录再进行操作!');
					$( "#dialog-message" ).dialog( "open" );
				}else{
					$('#confirmtext').text('是否清理选择用户在线状态？');
					$( "#dialog-confirm" ).dialog( "open" );
				}
			}
	}
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

</BODY>
</HTML>
