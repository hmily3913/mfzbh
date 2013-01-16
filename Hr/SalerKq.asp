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
<script src="../lib/ligerUI/js/ligerui.min.js" type="text/javascript"></script>
</head>
<body style="padding:6px; overflow:hidden;">
<table><tr>
<td>年份：</td>
<td><input type="text" id="y" /> </td>
<td width="10px">&nbsp;</td>
<td>月份：</td>
<td><input type="text" id="m" /> </td>
<td width="10px">&nbsp;</td>
<td>
<a href="javascript:showChart()" class="l-button" style="width:100px">查询</a></td>
</tr></table>
<div id="listDiv" style="width: 100%; height: 400px; margin: 0 auto; overflow:auto"></div>
<script language="javascript">
$(function ()
{
	var y=(new Date()).getFullYear();
	var m=(new Date()).getMonth()+1;
	$("#y").ligerComboBox({ 
		"initText":y, 
		data: [
				{ text: '2012', id: '2012' },
				{ text: '2013', id: '2013' },
				{ text: '2014', id: '2014' }
		], valueFieldID: 'y'
	}); 
	$("#m").ligerComboBox({ 
		"initText":m, 
		data: [
				{ text: '01', id: '1' },
				{ text: '02', id: '2' },
				{ text: '03', id: '3' },
				{ text: '04', id: '4' },
				{ text: '05', id: '5' },
				{ text: '06', id: '6' },
				{ text: '07', id: '7' },
				{ text: '08', id: '8' },
				{ text: '09', id: '9' },
				{ text: '10', id: '10' },
				{ text: '11', id: '11' },
				{ text: '12', id: '12' }
		], valueFieldID: 'm'
	}); 
});
function showChart(){
	if($("#y").val()==""||$("#m").val()==""){
		$.ligerDialog.warn('查询年份、月份不能为空！');
		return ;
	}
	$('#listDiv').load("SalerKqDt.asp",{
	  ProcessType:'SumList',
	  y:$('#y').val(),
	  m:$("#m").val()
	 });
}
function f_open(mb){
	$.ligerDialog.open({ height: 200, url: 'SalerKqDt.asp?ProcessType=List&mobi='+mb+'&y='+$('#y').val()+'&m='+$('#m').val(), isResize: true,width:'600',height:'400'});
}
</script>
</body>
</html>
