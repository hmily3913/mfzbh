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
					var SNum=$('.trSelected', $('#flex1')).attr("ch").split('_ZZ$BH_')[0];
				  $.post('MtrPriceInDt.asp?ProcessType=Forbid',{"UserID":SNum},function(data){
						$('#messagetext').text(data);
						$( "#dialog-message" ).dialog( "open" );
						if(data.indexOf("成功")>-1) $("#flex1").flexReload();
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
			"导入": function() {
				if($('#fileurl').val()==''){
					$('#messagetext').text('请先上传文件，再进行导入！');
					$( "#dialog-message" ).dialog( "open" );
				}else{
					$('#AddForm').submit();
					$( this ).dialog( "close" );
				}
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
			$('#loading-one').empty().append('数据载入中...').parent().fadeIn('slow');
			$.post('MtrPriceInDt.asp',$("#AddForm").serialize(),function(data){
				$('#loading-one').empty().append('数据载入完成.').parent().fadeOut('slow');
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
});
$("#flex1").flexigrid
	(
	{
	url: 'MtrPriceInDt.asp?ProcessType=DetailsList',
	dataType: 'json',
	autoload:true,
	colModel : [
	{display: '物料编号', name : 'Years', width : 80, sortable : true, align: 'left'},
	{display: '计划单价', name : 'Months', width : 60, sortable : true, align: 'left'},
	{display: '录入人工号', name : 'UserID', width : 60, sortable : true, align: 'left'},
	{display: '姓名', name : 'UserName', width : 60, sortable : true, align: 'left'},
	{display: '录入时间', name : 'BZGZ', width : 120, sortable : true, align: 'left'}
		],
	buttons : [
		{name: '数据导入',  onpress : test},
		{separator: true},
		{name: '下载模版',  onpress : test},
		{separator: true}
		],
	onRowDblclick:rowdbclick,
	sortname: "SerialNum",
	sortorder: "desc",
	singleSelect: true,
	striped:true,//
	rp: 20,
	usepager: true,
	title: '物料计划价格导入',
	showTableToggleBtn: true,
	showcheckbox: false,
	width:'100%',
	height: 420
	}
	);
	
	function rowdbclick(rowData){
	}
	function test(com,grid)
	{
		if (com=='数据导入')
			{
				$( "#dialog-form" ).dialog( "open" );
				$('#fileurl').val('');
				$('#mfileup').attr("src","../Script/xheditor_plugins/multiupload/multiupload.html");
			}
		else if(com=='下载模版'){
			window.open("MtrPriceInFMT.xls");
		}
	}
</script>
<div id="loading" style="position:fixed !important;position:absolute;top:0;left:0;height:100%; width:100%; z-index:9999; background:#000 url(../images/load.gif) no-repeat center center; opacity:0.6; filter:alpha(opacity=60);font-size:14px;line-height:20px;overflow:hidden;display:none;">
	<p id="loading-one" style="color:#fff;position:absolute; top:50%; left:50%; margin:20px 0 0 -50px; padding:3px 10px;">数据载入中...</p>
</div>

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
<div id="dialog-form" title="物料计划价格导入" >
	<form id="AddForm">
	<fieldset>
    <input type="hidden" id="ProcessType" name="ProcessType" value="xls2sql"/>
    <input type="hidden" id="fileurl" name="fileurl" />
<!--    <textarea id="Fujian" name="Fujian"></textarea>-->
    <iframe id="mfileup" name="mfileup" src="#"></iframe>
	</fieldset>
	</form>
</div>

</BODY>
</HTML>
