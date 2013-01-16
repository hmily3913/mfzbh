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
<style type="text/css">
.ztree li span.button.add {
    background-position: -144px 0;
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
var setting1 = {
	async: {
		enable: true,
		url:"GroupDt.asp?ProcessType=showGroup",
//		autoParam:["id", "name=n", "level=lv"],
//		otherParam:{"otherParam":"zTreeAsyncTest"},
		dataFilter: filter
	},
	view: {
		expandSpeed: ($.browser.msie && parseInt($.browser.version)<=6)?"":"fast",
		fontCss: getFont,
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
		beforeEditName:beforeEditName,
		beforeDrag: beforeDrag,
		beforeDrop: beforeDrop,
		beforeClick: function(treeId, treeNode) {
			if (treeNode.level==0) {
				setting3.async.otherParam={ "SerialNum":treeNode.id},
				$.fn.zTree.init($("#Permission"), setting3);
				permTree = $.fn.zTree.getZTreeObj("Permission");
				$("#changeCount").text(0);
				return true;
			} else {
				return false;
			}
		},
		beforeExpand:function(treeId,treeNode){
			if(treeNode.level>0)return false;
		}
	}
}; 
function getFont(treeId, node) {
	return node.font ? node.font : {};
}
function filter(treeId, parentNode, childNodes) {
	if (!childNodes) return null;
	for (var i=0, l=childNodes.length; i<l; i++) {
		childNodes[i].name = childNodes[i].name.replace(/\.n/g, '.');
	}
	return childNodes;
}
function beforeDrag(treeId, treeNodes) {
	for (var i=0,l=treeNodes.length; i<l; i++) {
		if (treeNodes[i].drag === false ||treeNodes[i].level<1) {
			return false;
		}
	}
	return true;
}
function beforeDrop(treeId, treeNodes, targetNode, moveType) {
	if(treeId=="Groups"){
		if(targetNode){
			if((targetNode.level!==false&&targetNode.level==0&&moveType=="inner")||(targetNode.level==1&&moveType!="inner"&&targetNode.level!==false)){
			 return true;
			}
			else
			 return false;
		}else
			return false;
	}
	else
		return true;
}

function beforeRemove(treeId, treeNode) {
		zTree.selectNode(treeNode);
		$('#confirmtext').text("是否删除节点-"+treeNode.name+"?");
		$( "#dialog-confirm" ).dialog("open");
		return false;
}		
function beforeEditName(treeId, treeNode) {
	if(treeNode.level==0){
		zTree.selectNode(treeNode);
		$('#GroupName').val(treeNode.name);
		$('#SerialNum').val(treeNode.id);
		$( "#dialog-form" ).dialog("open");
	}
	return false;
}

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
	$('#GroupName').val('');
	$('#SerialNum').val('');
	$( "#dialog-form" ).dialog("open")
}
function removeTreeNode() {
	hideRMenu();
}
function resetTree() {
	hideRMenu();
	$.fn.zTree.init($("#Groups"), setting1);
}
//右键结束------------
//用户树---------------------
		var userTree;
		var setting2 = {
			async: {
				enable: true,
				url:"GroupDt.asp?ProcessType=showUsers",
				dataFilter: filter
			},
			view: {
				selectedMulti: false
			},
			check: {
				enable: true
			},
			data: {
				simpleData: {
					enable: true
				}
			}
		};
//权限树
		var permTree;
		var setting3 = {
			async: {
				enable: true,
				url:"GroupDt.asp?ProcessType=showPurview",
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
		function onCheck(e, treeId, treeNode) {
			var changeCount = permTree.getChangeCheckedNodes().length;
			$("#changeCount").text(changeCount);
		}	
	$(document).ready(function(){
		$.fn.zTree.init($("#Groups"), setting1);
		zTree = $.fn.zTree.getZTreeObj("Groups");
		$.fn.zTree.init($("#Users"), setting2);
		userTree = $.fn.zTree.getZTreeObj("Users");
		rMenu = $("#rMenu");
		//保存权限
		$('#savePerm').button({
			icons: {
				primary: "ui-icon-tag"
			}
		}).click(function() {
			if(permTree.getChangeCheckedNodes().length==0){
				$('#messagetext').text('当前被修改权限共0个，不需要保存！');
				$( "#dialog-message" ).dialog( "open" );
			}
			else if(zTree.getSelectedNodes().length==0){
				$('#messagetext').text('无组别被选中，保存失败！');
				$( "#dialog-message" ).dialog( "open" );
			}else{
				var allNodeID='0';
				for(var i=0;i<permTree.getCheckedNodes().length;i++){
					allNodeID+=','+permTree.getCheckedNodes()[i].id;
//					if(i!=permTree.getCheckedNodes().length-1)allNodeID+=',';
				}
				$.post('GroupDt.asp?ProcessType=setPurview',{
					"allNodeID":allNodeID,
					"UserID":zTree.getSelectedNodes()[0].id
				},function(data){
					var datajson=jQuery.parseJSON(data);//转换后的JSON对象
					$('#messagetext').text(datajson.messages);
					$( "#dialog-message" ).dialog( "open" );
				});
			}
		});
		$('#setUsers').button({
			icons: {
				primary: "ui-icon-plusthick"
			}
		}).click(function() {
			if(userTree.getCheckedNodes().length==0){
				$('#messagetext').text('当前被修改权限共0个，不需要保存！');
				$( "#dialog-message" ).dialog( "open" );
			}
			else if(zTree.getSelectedNodes().length==0){
				$('#messagetext').text('无组别被选中，保存失败！');
				$( "#dialog-message" ).dialog( "open" );
			}
			else if(zTree.getSelectedNodes()[0].level>0){
				$('#messagetext').text('只能对用户组进行添加用户！');
				$( "#dialog-message" ).dialog( "open" );
			}
			else{
				var allNodeID="'admin'";
				var allNodes=new Array();
				var n=1;
				allNodes[0]={id:"admin",name:"admin/admin"}
				for(var i=0;i<userTree.getCheckedNodes().length;i++){
					if(!userTree.getCheckedNodes()[i].isParent){
						allNodeID+=",'"+userTree.getCheckedNodes()[i].id+"'";
						allNodes[n]={id:userTree.getCheckedNodes()[i].id,name:userTree.getCheckedNodes()[i].id+'/'+userTree.getCheckedNodes()[i].id,pId:zTree.getSelectedNodes()[0].id};
						n++;
					}
//					if(i!=permTree.getCheckedNodes().length-1)allNodeID+=',';
				}
				$.post('GroupDt.asp?ProcessType=setUsers',{
					"allNodeID":encodeURI(allNodeID),
					"UserID":zTree.getSelectedNodes()[0].id
				},function(data){
					var datajson=jQuery.parseJSON(data);//转换后的JSON对象
					$('#messagetext').text(datajson.messages);
					$( "#dialog-message" ).dialog( "open" );
					if(datajson.status){
						zTree.removeChildNodes(zTree.getSelectedNodes()[0]);
						zTree.addNodes(zTree.getSelectedNodes()[0], allNodes);
					}
				});
			}
		});
		$('#delUsers').button({
			icons: {
				primary: "ui-icon-minusthick"
			}
		}).click(function() {
			$.fn.zTree.init($("#Users"), setting2);
			userTree = $.fn.zTree.getZTreeObj("Users"); 
		});
		$('#refreshUsers').button({
			icons: {
				primary: "ui-icon-refresh"
			}
		}).click(function() {
			$.fn.zTree.init($("#Users"), setting2);
			userTree = $.fn.zTree.getZTreeObj("Users"); 
		});

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
						$.post('GroupDt.asp?ProcessType=doDel',{
							SerialNum:node[0].id,
							PID:node[0].pId,
							delType:node[0].level
						},function(data){
							$('#dialog-confirm').dialog( "close" );
							var datajson=jQuery.parseJSON(data);//转换后的JSON对象
							$('#messagetext').text(datajson.messages);
							$( "#dialog-message" ).dialog( "open" );
							if(datajson.status) zTree.removeNode(node[0]);
						});
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
				$.post('GroupDt.asp?ProcessType=SaveAdd',{
					SerialNum:$('#SerialNum').val(),
					GroupName:$('#GroupName').val()
					},function(data){
					var datajson=jQuery.parseJSON(data);//转换后的JSON对象
					$('#messagetext').text(datajson.messages);
					$( "#dialog-message" ).dialog( "open" );
					if(datajson.status){
						var nodes = zTree.getSelectedNodes();
						if(datajson.Add){
//							if(nodes[0])
//								zTree.addNodes(nodes[0], datajson.datas);
//							else
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
	});


</script>
</HEAD>

<BODY>
<table width="100%" height="100%">
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

<div class="content_wrap" style="height:100%;">
	<div style="width:250px; height:365px; float:left; background-color:#F0F6E4;border:1px solid #617775; overflow:hidden;">
    <div style="width:250px; height:365px; overflow:auto;">
		<ul id="Groups" class="ztree"></ul>
    </div>
	</div>
  <div style="width:25px; height:365px; float:left;"></div>
	<div style="width:250px; height:365px; float:left; background-color:#F0F6E4;border:1px solid #617775; overflow:hidden;">
    <div style="width:245px; height:340px; overflow:auto;">
			<ul id="Users" class="ztree"></ul>
    </div>
    <div style="height:24px;width:250px; border-top:1px solid #617775;" align="center">
    	<button id="setUsers">添加用户</button>
    	<button id="refreshUsers">重新载入</button>
    </div>
	</div>
  <div style="width:25px; height:365px; float:left;"></div>
	<div style="width:250px; height:365px; float:left; background-color:#F0F6E4;border:1px solid #617775; overflow:hidden;">
    <div style="width:245px; height:340px; overflow:auto;">
      <ul id="Permission" class="ztree"></ul>
    </div>
    <div style="height:24px;width:250px; border-top:1px solid #617775;" align="center">
    	<button id="savePerm">保存权限</button>
    </div>
	</div>
  <div style="width:25px; height:365px; float:left;"></div>
	<div style="width:250px; height:250px; float:left; overflow:auto; padding:10px;">
		当前被修改权限共 <span id="changeCount" style="color:#A60000">0</span> 个
	</div>
</div>
<div style="height:20px;width:95%;"></div>

<div id="dialog-form" title="权限管理" >
	<form id="AddForm">
	<fieldset>
		<label for="SerialNum">组别内码</label>
		<input type="text" name="SerialNum" id="SerialNum" class="text ui-widget-content ui-corner-all" readonly="readonly" disabled/>
		<label for="PermissionID">组别名称</label>
		<input type="text" name="GroupName" id="GroupName" class="text ui-widget-content ui-corner-all"/>
	</fieldset>
	</form>
</div>
</table>
</BODY>
</HTML>