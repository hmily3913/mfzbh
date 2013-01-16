<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=utf-8" />
    <title></title>
    <link href="../lib/ligerUI/skins/Aqua/css/ligerui-all.css" rel="stylesheet" type="text/css" />
    <link href="../lib/ligerUI/skins/ligerui-icons.css" rel="stylesheet" type="text/css" />
    <link href="../css/common.css" rel="stylesheet" type="text/css" />  
<script language="javascript" src="../Script/speedup.js"></script>
<script language="javascript" src="../Script/jquery-1.7.2.min.js"></script>
<script language="javascript" src="../Script/common.js"></script>
<script src="../lib/ligerUI/js/ligerui.min.js" type="text/javascript"></script>
<script language="javascript" src="../Script/LG.js"></script>
<script language="javascript" src="../Script/ligerui.expand.js"></script>
<script src="../lib/json2.js" type="text/javascript"></script>
</head>
<body style="padding:6px; overflow:hidden;">
计算日期： <br />      <input type="text" id="ctDate" /><br /> <br />
报表类型： <br />      <input type="text" id="RptType" /> <br />
      <br /> <br />
         
<a href="javascript:clickee()" class="l-button" style="width:100px">查询</a>
      <br /> <br />
<a href="javascript:unCt()" class="l-button" style="width:100px">反计算</a>

<script language="javascript">
$(function ()
{
	$("#ctDate").ligerComboBox({ 
		url:'FenTanDt.asp?ProcessType=DateList', valueFieldID: 'ctDate'
	}); 
	$("#RptType").ligerComboBox({ 
		"initText":'油费分摊', 
		data: [
				{ text: '油费分摊', id: '油费分摊' },
				{ text: '油费汇总', id: '油费汇总' }
		], valueFieldID: 'RptType'
	}); 
});
function unCt(){
	if($("#ctDate").val()==""||$("#RptType").val()==""){
		$.ligerDialog.warn('计算日期、报表类型不能为空！');
		return ;
	}
	$.ligerDialog.confirm('<br/>确定要对选定的计算方案进行反计算吗？', function (yes)
	 {
		if(yes){
			LG.showLoading('反计算进行中...');
			$.post('FenTanDt.asp?ProcessType=unsetct&ctDate='+encodeURIComponent($("#ctDate").val()),function(data){
				LG.hideLoading('数据更新完毕');
				var datajson=jQuery.parseJSON(data);//转换后的JSON对象
				LG.showSuccess(datajson.messages);
			});
		}
	});
}
function clickee()
{
	if($("#ctDate").val()==""||$("#RptType").val()==""){
		$.ligerDialog.warn('计算日期、报表类型不能为空！');
		return ;
	}
	if($("#RptType").val()=="油费分摊"){
		$.ligerDialog.open({
			title: '分摊信息',
			url:  'ChucheDt.asp?ProcessType=ftList&SDate='+encodeURIComponent($('#ctDate').val()),
			width: 800,height:450, 
			isResize: true,
			buttons: [{ text: '关闭', onclick: function (item, dialog) { dialog.hide(); } }]
		});
	}else if($("#RptType").val()=="油费汇总"){
		var gridcount = $('<div class="countgrid"></div>');
		gridcount.ligerGrid({
			columns: [
		{"display":"费用归属","name":"fygs","width":60},
		{"display":"卡号","name":"oilcardnumber","width":120},
		{"display":"车主姓名","name":"xm","width":100},
		{"display":"车牌号","name":"carbrand","width":80},
		{"display":"实际油费金额","name":"icje","width":80,type:"number"},
		{"display":"分摊后油费金额","name":"分摊后油费金额","width":80,type:"number"},
		{"display":"现金加油金额","name":"xjje","width":80,type:"number"},
		{"display":"合计金额","name":"合计金额","width":80,type:"number"},
		{"display":"本期里程数","name":"kms","width":60,type:"number"},
		{"display":"每公里分配额","name":"每公里分配额","width":80,type:"number"}],  
			dataAction: 'server',
			usePager:false,
			url:  'FenTanDt.asp?ProcessType=ctList&SDate='+encodeURIComponent($('#ctDate').val()),
			headerRowHeight:40,
			width: '100%',height:'100%'
		});
		$.ligerDialog.open({
				title: '汇总信息',
				target: gridcount,
				width: 800,height:400, 
				isResize: true,
				buttons: [{ text: '关闭', onclick: function (item, dialog) { dialog.hide(); } }]
		});
	}
}


</script>
</body>
</html>
