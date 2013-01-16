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
<script language="javascript" src="../Script/highcharts.js"></script>
<script language="javascript" src="../Script/modules/exporting.js"></script>
<script src="../lib/ligerUI/js/ligerui.min.js" type="text/javascript"></script>
</head>
<body style="padding:6px; overflow:hidden;">
<a href="javascript:showChart()" class="l-button" style="width:100px">查询</a>
<div id="chartDiv" style="width: 100%; height: 400px; margin: 0 auto; display:none;"></div>
<script language="javascript">
function showChart(){
	$('#chartDiv').show();
	options = {
		 chart: {
				renderTo: 'chartDiv',
				zoomType: 'x',
				defaultSeriesType: 'line'
		 },
		 title: {
				text:'相关图表信息'
		 },
		 subtitle: {
			text: '各月份信息'
		 },
		 xAxis: {
			gridLineWidth: 1
		 },
		 yAxis: {
				title: {
					 text: '数值'
				}
		 },
		 tooltip: {
			shared  :true,
			crosshairs  :true
		 }
	};
	$.get('SaRptDt.asp',{ ProcessType: "getData1"},
	  function(data){
		 	var datajson=jQuery.parseJSON(data);
			options.xAxis.categories = [];
			$.each(datajson,function(i){
				options.xAxis.categories.push(datajson[i].Monthdata[0].value+'月');
			});
			
			options.series = [];
			$.each(datajson,function(i){
				for(var j=0;j<datajson[i].Monthdata.length;j++){
					if (j > 0) { // get the name and init the series
						if(i==0){
							options.series[j-1] = { 
								name: datajson[i].Monthdata[j].name,
								dataLabels:{enabled: true,formatter: function() {return this.y;}},
								data: []
							};
						} 
						options.series[j-1].data.push(parseFloat(datajson[i].Monthdata[j].value));
					}
				}
			});
			var chart = new Highcharts.Chart(options);
		});
	
	
}
</script>
</body>
</html>
