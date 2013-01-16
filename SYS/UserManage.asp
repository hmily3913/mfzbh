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
<div style="position:absolute;top:20px;left:62%;">
	<div style="width:250px;overflow:auto; padding:10px;">
		当前被修改权限共 <span id="changeCount" style="color:#A60000">0</span> 个
	</div>
<div style="width:250px; height:420px; background-color:#F0F6E4;border:1px solid #617775; overflow:hidden;">
  <div style="width:250px; height:395px; overflow:auto;">
    <ul id="Permission" class="ztree"></ul>
  </div>
  <div style="height:24px;width:250px; border-top:1px solid #617775;" align="center">
    <input type="button" id="savePerm" value="保存权限" />
  </div>
</div>
</div>
<script language="javascript">
//权限树
		var permTree;
		var setting3 = {
			async: {
				enable: true,
				url:"UserManageDt.asp?ProcessType=showPurview",
				dataFilter: filter
			},
			view: {
				selectedMulti: false
			},
			check: {
				enable: true,
				chkboxType: { "Y": "ps", "N": "s" }
			},
			data: {
				simpleData: {
					enable: true
				}
			},
			callback: {
				onCheck: onCheck
			}
		};	
		function filter(treeId, parentNode, childNodes) {
			if (!childNodes) return null;
			for (var i=0, l=childNodes.length; i<l; i++) {
				childNodes[i].name = childNodes[i].name.replace(/\.n/g, '.');
			}
			return childNodes;
		}
		function onCheck(e, treeId, treeNode) {
			var changeCount = permTree.getChangeCheckedNodes().length;
			$("#changeCount").text(changeCount);
		}	
$(function(){
		$( "#dialog:ui-dialog" ).dialog( "destroy" );
		$('#savePerm').button().click(function() {
//			if(permTree.getChangeCheckedNodes().length==0){
//				$('#messagetext').text('当前被修改权限共0个，不需要保存！');
//				$( "#dialog-message" ).dialog( "open" );
//			}
//			else 
			if($('.trSelected', $('#flex1')).length==0){
				$('#messagetext').text('无用户被选中，保存失败！');
				$( "#dialog-message" ).dialog( "open" );
			}else{
				var allNodeID='0';
				for(var i=0;i<permTree.getCheckedNodes().length;i++){
					allNodeID+=','+permTree.getCheckedNodes()[i].id;
//					if(i!=permTree.getCheckedNodes().length-1)allNodeID+=',';
				}
				$.post('UserManageDt.asp?ProcessType=setPurview',{
					"allNodeID":allNodeID,
					"UserID":$('.trSelected', $('#flex1')).attr("ch").split('_ZZ$BH_')[0]
				},function(data){
					var datajson=jQuery.parseJSON(data);//转换后的JSON对象
					$('#messagetext').text(datajson.messages);
					$( "#dialog-message" ).dialog( "open" );
					if(datajson.status){
						
					}
				});
			}
		});
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
				  $.post('UserManageDt.asp',{"UserID":SNum,"ProcessType":$('#ProcessType').val()},function(data){
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
			"保存": function() {
				$('#AddForm').submit();
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
			$.post('UserManageDt.asp',$("#AddForm").serialize(),function(data){
				$('#messagetext').text(data);
				$( "#dialog-message" ).dialog( "open" );
				if(data.indexOf("成功")>-1){
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
	url: 'UserManageDt.asp?ProcessType=DetailsList',
	dataType: 'json',
	colModel : [
	{display: '用户名', name : 'UserID', width : 100, sortable : true, align: 'left'},
	{display: '员工姓名', name : 'UserName', width : 100, sortable : true, align: 'left'},
	{display: 'K3编号', name : 'UserNumber', width : 100, sortable : true, align: 'left'},
	{display: '是否设置', name : 'UseFlag', width : 100, sortable : true, align: 'left'},
	{display: '是否禁用', name : 'ForbidFlag', width : 60, sortable : true, align: 'left'}
		],
	buttons : [
		{name: '设置',  onpress : test},
		{separator: true},
		{name: '禁用',  onpress : test},
		{separator: true},
		{name: '查看权限',  onpress : test},
		{separator: true},
		{name: '清空工资密码',  onpress : test},
		{separator: true}
		],
	searchitems : [
		{display: '用户名', name : 'a.UserID', isdefault: true},
		{display: '姓名', name : 'a.UserName'},
		{display: '禁用', name : 'a.ForbidFlag'}
		],
	onRowDblclick:rowdbclick,
	sortname: "a.Userid",
	sortorder: "desc",
	singleSelect: true,
	striped:true,//
	rp: 20,
	usepager: true,
	title: '用户管理',
	showTableToggleBtn: true,
	showcheckbox: false,
	width:'60%',
	height: 420
	}
	);
	
	function rowdbclick(rowData){
		$('#UserID').val($(rowData).data(("UserID")));
		$('#UserName').val($(rowData).data(("UserName")));
		$('#UserNumber').val($(rowData).data(("UserNumber")));
		$('#ProcessType').val('SaveAdd');
		$( "#dialog-form" ).dialog( "open" );
	}
	function test(com,grid)
	{
		if (com=='禁用')
			{
				if($('.trSelected', grid).length==0){
					$('#messagetext').text('请先选择一条记录再进行操作！');
					$( "#dialog-message" ).dialog( "open" );
					return false;
				}
				var SNum=$('.trSelected', grid).attr("id").replace("row","");
				$('#confirmtext').text("确定要禁用所选用户--"+SNum);
				$('#ProcessType').val('Forbid');
				$( "#dialog-confirm" ).dialog( "open" );
			}
		else if (com=='设置')
			{
				if($('.trSelected', grid).length==0){
					$('#messagetext').text('请先选择一条记录再进行操作！');
					$( "#dialog-message" ).dialog( "open" );
					return false;}
				$('#ProcessType').val('SaveAdd');
				var vals=$('.trSelected', $('#flex1')).attr("ch").split('_ZZ$BH_')[0];
				$('#UserID').val(vals);
				vals=$('.trSelected', $('#flex1')).attr("ch").split('_ZZ$BH_')[1];
				$('#UserName').val(vals);
				vals=$('.trSelected', $('#flex1')).attr("ch").split('_ZZ$BH_')[2];
				$('#UserNumber').val(vals);
				$( "#dialog-form" ).dialog( "open" );
			}			
		else if(com=='查看权限')
		{
				if($('.trSelected', grid).length==0){
					$('#messagetext').text('请先选择一条记录再进行操作！');
					$( "#dialog-message" ).dialog( "open" );
					return false;
				}
				var SNum=$('.trSelected', grid).attr("id").replace("row","");

				setting3.async.otherParam={ "SerialNum":SNum},
				$.fn.zTree.init($("#Permission"), setting3);
				permTree = $.fn.zTree.getZTreeObj("Permission");
				$("#changeCount").text(0);
		}
		else if (com=='清空工资密码')
			{
				if($('.trSelected', grid).length==0){
					$('#messagetext').text('请先选择一条记录再进行操作！');
					$( "#dialog-message" ).dialog( "open" );
					return false;
				}
				var SNum=$('.trSelected', grid).attr("id").replace("row","");
				$('#confirmtext').text("确定要清空所选用户工资密码--"+SNum);
				$('#ProcessType').val('ClearGZ');
				$( "#dialog-confirm" ).dialog( "open" );
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
<div id="dialog-form" title="用户管理" >
	<p class="validateTips">所有字段必须填写.</p>

	<form id="AddForm">
	<fieldset>
    <input type="hidden" id="ProcessType" name="ProcessType" />
		<label for="UserID">工号</label>
		<input type="text" name="UserID" id="UserID" class="text ui-widget-content ui-corner-all required" readonly="readonly"/>
		<label for="UserName">姓名</label>
		<input type="text" name="UserName" id="UserName" value="" class="text ui-widget-content ui-corner-all required" readonly="readonly"/>
		<label for="UserNumber">K3编号</label>
		<input type="text" name="UserNumber" id="UserNumber" value="" class="text ui-widget-content ui-corner-all required" readonly="readonly"/>
		<label for="password">密码</label>
		<input type="password" name="password" id="password" value="" class="text ui-widget-content ui-corner-all required" />
		<label for="passwordconf">密码确认</label>
		<input type="password" name="passwordconf" id="passwordconf" value="" class="text ui-widget-content ui-corner-all required" />
	</fieldset>
	</form>
</div>

</BODY>
</HTML>
