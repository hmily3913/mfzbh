<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<!--#include file="../CheckAdmin.asp" -->
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"    "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<head>
<META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=utf-8" />
<TITLE>欢迎进入系统后台</TITLE>
<link rel="stylesheet" href="../css/center.css">
<script language="javascript" src="../Script/jquery-1.7.2.min.js"></script>
<link rel="stylesheet" href="../css/jquery-ui.css">
<script language="javascript" src="../Script/jquery-ui.min.js"></script>
<link rel="stylesheet" href="../css/zTreeStyle.css">
<SCRIPT type="text/javascript" src="../Script/jquery.ztree.all-3.2.min.js"></SCRIPT>
<script language="javascript" src="../Script/jquery.validate.js"></script>
    <link href="../lib/ligerUI/skins/Aqua/css/ligerui-all.css" rel="stylesheet" type="text/css" />
    <link href="../lib/ligerUI/skins/ligerui-icons.css" rel="stylesheet" type="text/css" />
    <link href="../css/common.css" rel="stylesheet" type="text/css" />  
<script src="../lib/ligerUI/js/ligerui.min.js" type="text/javascript"></script>
<script language="javascript" src="../Script/LG.js"></script>
<script language="javascript" src="../Script/iconselector.js"></script>
<style type="text/css">

.ztree li span.button.add {
    background-position: -144px 0;
    margin-left: 2px;
    margin-right: -1px;
    vertical-align: top;
}
.ztree li span.button.shows {
    background-position: -126px -48px;
    margin-left: 2px;
    margin-right: -1px;
    vertical-align: top;
}
/* ------------- 右键菜单 -----------------  */

div#rMenu {
	top:0;
	visibility:hidden;
	position:absolute;
	background-color:#555555;
	text-align: left;
	padding:2px;
}

div#rMenu ul {
	margin:1px 0;
	padding:0 5px;
	cursor: pointer;
	list-style: none outside none;
	background-color:#DFDFDF;
	font-size:12px;
}
div#rMenu ul li {
	margin:0;
	padding:2px 0;
}

	#dialog-form label,#dialog-form input { display:block; }
	#dialog-form input.text { margin-bottom:8px; width:95%; padding: 4px;}
	fieldset { padding:0; border:0; margin-top:10px;}
	.ui-dialog .ui-state-error { padding: .3em; }
	.validateTips { border: 1px solid transparent; padding: 3ps; }

</style>
<script language="javascript">
var zTree;
var rMenu;
var setting = {
	async: {
		enable: true,
		url:"PurviewDt.asp?ProcessType=showPurview",
//		autoParam:["id", "name=n", "level=lv"],
//		otherParam:{"otherParam":"zTreeAsyncTest"},
		dataFilter: filter
	},
	view: {
		expandSpeed: ($.browser.msie && parseInt($.browser.version)<=6)?"":"fast",
		addHoverDom: addHoverDom,
		removeHoverDom: removeHoverDom,
		selectedMulti: false
	},
	edit: {
		enable: true,
		renameTitle:"编辑",
		removeTitle:"删除"
	},
	data: {
		simpleData: {
			enable: true,
			idKey: "id",
			pIdKey: "pId",
			rootPId: ""
		}
	},
	callback: {
		onRightClick: OnRightClick,
		beforeRemove: beforeRemove,
		beforeEditName:beforeEditName
	}
}; 
function filter(treeId, parentNode, childNodes) {
	if (!childNodes) return null;
	for (var i=0, l=childNodes.length; i<l; i++) {
		childNodes[i].name = childNodes[i].name.replace(/\.n/g, '.');
	}
	return childNodes;
}
function beforeRemove(treeId, treeNode) {
	zTree.selectNode(treeNode);
	$('#confirmtext').text("是否删除节点-"+treeNode.name+"?");
	$( "#dialog-confirm" ).dialog("open");
	return false;
}		
function beforeEditName(treeId, treeNode) {
	$('#PermissionID').val(treeNode.PermissionID);
	if(treeNode.pId==0)$('#PermissionID').attr("readonly",false);
	else $('#PermissionID').attr("readonly",true);
	$('#PermissionName').val(treeNode.name);
	$('#TreeUrl').val(treeNode.TreeUrl);
	$('#P1').val(treeNode.P1);
	$('#SerialNum').val(treeNode.id);
	$('#PSNum').val(treeNode.pId);
	$('#icons').val(treeNode.icons);
	$( "#dialog-form" ).dialog("open")
	return false;
}
function addHoverDom(treeId, treeNode) {
	var sObj = $("#" + treeNode.tId + "_span");
	if ($("#addBtn_"+treeNode.id).length>0) return;
	var addStr = "<span class='button add' id='addBtn_" + treeNode.id
		+ "' title='新增' onfocus='this.blur();'></span>";
	sObj.append(addStr);
	addStr = "<span class='button shows' id='showBtn_" + treeNode.id
		+ "' title='查用户' onfocus='this.blur();'></span>";
	sObj.append(addStr);
	var btn = $("#addBtn_"+treeNode.id);
	if (btn) btn.bind("click", function(){
		$('#TreeUrl').val(treeNode.TreeUrl);
		$('#P1').val(treeNode.P1);
		$('#PermissionID').attr("readonly",true).val('').attr("disabled","disabled");
		$('#PermissionName').val('');
		$('#SerialNum').val('');
		$('#icons').val('');
		$('#PSNum').val(treeNode.id);
		$( "#dialog-form" ).dialog("open")
	});
};
function removeHoverDom(treeId, treeNode) {
	$("#addBtn_"+treeNode.id).unbind().remove();
	$("#showBtn_"+treeNode.id).unbind().remove();
};

//--右键--------------------
function OnRightClick(event, treeId, treeNode) {
	if (!treeNode && event.target.tagName.toLowerCase() != "button" && $(event.target).parents("a").length == 0) {
		zTree.cancelSelectedNode();
		showRMenu("root", event.clientX, event.clientY);
	} 
}

function showRMenu(type, x, y) {
	$("#rMenu ul").show();
	if (type=="root") {
		$("#m_del").hide();
		$("#m_edit").hide();
	} else {
		$("#m_del").show();
		$("#m_edit").show();
	}
	rMenu.css({"top":y+"px", "left":x+"px", "visibility":"visible"});

	$("body").bind("mousedown", onBodyMouseDown);
}
function hideRMenu() {
	if (rMenu) rMenu.css({"visibility": "hidden"});
	$("body").unbind("mousedown", onBodyMouseDown);
}
function onBodyMouseDown(event){
	if (!(event.target.id == "rMenu" || $(event.target).parents("#rMenu").length>0)) {
		rMenu.css({"visibility" : "hidden"});
	}
}
function addTreeNode() {
	hideRMenu();
	$('#TreeUrl').val('');
	$('#P1').val('');
	$('#PermissionID').attr("readonly",false).removeAttr("disabled").val('');
	$('#PermissionName').val('');
	$('#SerialNum').val('');
	$('#PSNum').val('0');
	$( "#dialog-form" ).dialog("open")
}
function removeTreeNode() {
	hideRMenu();
}
function resetTree() {
	hideRMenu();
	$.fn.zTree.init($("#Permission"), setting);
}
//右键结束------------
	$(document).ready(function(){
		$.fn.zTree.init($("#Permission"), setting);
		zTree = $.fn.zTree.getZTreeObj("Permission");
		rMenu = $("#rMenu");
		$( "#dialog:ui-dialog" ).dialog( "destroy" );
	
		$( "#dialog-confirm" ).dialog({
			autoOpen:false,
			resizable: false,
			height:200,
			modal: true,
			buttons: {
				"确认": function() {
					var node = zTree.getSelectedNodes();
					if (node[0]) {
						if (node[0].isParent) {
							$( this ).dialog( "close" );
							$('#messagetext').text("要删除的节点是父节点，不允许执行删除操作，请先删除子节点！");
							$( "#dialog-message" ).dialog( "open" );
						} else {
							$.post('PurviewDt.asp?ProcessType=doDel',{
								SerialNum:node[0].id
							},function(data){
								$('#dialog-confirm').dialog( "close" );
								var datajson=jQuery.parseJSON(data);//转换后的JSON对象
								$('#messagetext').text(datajson.messages);
								$( "#dialog-message" ).dialog( "open" );
								zTree.removeNode(node[0]);
							});
						}
					}
				},
				"取消": function() {
					$( this ).dialog( "close" );
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
			height: 450,
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
				$.post('PurviewDt.asp?ProcessType=SaveAdd',{
					SerialNum:$('#SerialNum').val(),
					PermissionID:$('#PermissionID').val(),
					PermissionName:$('#PermissionName').val(),
					TreeUrl:$('#TreeUrl').val(),
					P1:$('#P1').val(),
					icons:$('#icons').val(),
					PSNum:$('#PSNum').val()
					},function(data){
					var datajson=jQuery.parseJSON(data);//转换后的JSON对象
					$('#messagetext').text(datajson.messages);
					$( "#dialog-message" ).dialog( "open" );
					if(datajson.status){
						var nodes = zTree.getSelectedNodes();
						if(datajson.Add){
							if(nodes[0])
								zTree.addNodes(nodes[0], datajson.datas);
							else
								zTree.addNodes(null, datajson.datas);
						}
						else{
							zTree.updateNode(nodes[0], true);
						}
						$( "#dialog-form" ).dialog( "close" );
					}
				});
			}
		});
		
		$("#icons").ligerComboBox({
			valueFieldID:"icons",
			onBeforeOpen: function (){
				currentComboBox = this;
				f_openIconsWin();
				return false;
			}
			//,
//			render: function ()
//			{
//				return rowdata.MenuIcon;
//			}
		});
		$.ligerui.get('icons')._setWidth(300);
	});


</script>
</HEAD>

<BODY>
<div id="dialog-confirm" title="操作确认">
	<p><span class="ui-icon ui-icon-alert" style="float:left; margin:0 7px 20px 0;"></span>
  <b id="confirmtext"></b>
  </p>
</div>

<div id="dialog-message" title="操作提示">
	<p>
		<span class="ui-icon ui-icon-circle-check" style="float:left; margin:0 7px 50px 0;"></span>
		<B id="messagetext">操作失败！</B>
	</p>
</div>

<div id="rMenu">
	<ul>
		<li id="m_add" onclick="addTreeNode();">增加模块</li>
		<li id="m_edit" onclick="renameTreeNode(event);">编辑节点</li>
		<li id="m_del" onclick="removeTreeNode();">删除权限</li>
		<li id="m_reset" onclick="resetTree();">重新载入权限</li>
	</ul>
</div>

<div class="content_wrap">
	<div class="zTreeDemoBackground left">
		<ul id="Permission" class="ztree"></ul>
	</div>
	<div class="right">
	</div>
</div>

<div id="dialog-form" title="权限管理" >
	<form id="AddForm">
	<fieldset>
		<label for="SerialNum">权限内码</label>
		<input type="text" name="SerialNum" id="SerialNum" class="text ui-widget-content ui-corner-all" readonly="readonly" disabled/>
		<label for="PermissionID">权限编号</label>
		<input type="text" name="PermissionID" id="PermissionID" class="text ui-widget-content ui-corner-all"/>
		<label for="PermissionName">权限名称</label>
		<input type="text" name="PermissionName" id="PermissionName" value="" class="text ui-widget-content ui-corner-all required"/>
		<label for="TreeUrl">导航Url</label>
		<input type="text" name="TreeUrl" id="TreeUrl" value="" class="text ui-widget-content ui-corner-all" />
		<label for="P1">参数值一</label>
		<input type="text" name="P1" id="P1" value="" class="text ui-widget-content ui-corner-all" />
		<label for="icons">图标</label>
		<input type="text" name="icons" id="icons" value="" width="320"/>
		<label for="PSNum">上级编号</label>
		<input type="text" name="PSNum" id="PSNum" value="" class="text ui-widget-content ui-corner-all" readonly="readonly" disabled/>
	</fieldset>
	</form>
</div>
</BODY>
</HTML>