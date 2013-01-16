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
<script src="../lib/ligerUI/js/plugins/ligerTree.js" type="text/javascript"></script>
<script src="../lib/ligerUI/js/plugins/ligerComboBox.js" type="text/javascript"></script>
<script src="../Script/ligerui.expand.js" type="text/javascript"></script>
<script language="javascript" src="../Script/LG.js"></script>
    <script src="../lib/json2.js" type="text/javascript"></script>
</head>
<body style="padding:6px; overflow:hidden;">
    <input type="hidden" id="fileurl" name="fileurl" />
  <div id="mainsearch" style=" width:98%">
    <div class="searchtitle">
        <span>搜索</span><img src="../lib/icons/32X32/searchtool.gif" />
        <div class="togglebtn"></div> 
    </div>
    <div class="navline" style="margin-bottom:4px; margin-top:4px;"></div>
    <div class="searchbox">
        <form id="formsearch" class="l-form"></form>
    </div>
  </div>
    <div id="maingrid4" style="margin:0; padding:0"></div>
<script language="javascript">
        var grid = null;
				grid = $("#maingrid4").ligerGrid({
						columns: [
{"display":"客户编号","name":"FNumber","width":80},
{"display":"客户名称","name":"custName","width":250},
{"display":"市场","name":"departname","width":80},
{"display":"专营业务员","name":"empname","width":80}],  
						dataAction: 'server',
						record : 'total',
						pageSize:10,
						checkbox: true,
//								where : f_getWhere(),
						url:  'KhzkdyDt.asp?ProcessType=DetailsList',
						rownumbers:true,
						pageSizeOptions:[10,15, 20, 30, 40, 50],
						headerRowHeight:20,
						width: '100%',height:'100%'
				});
				$("#pageloading").hide();

			function grid_printall(){
					if($('[name=SDate]').val()==''||$('[name=EDate]').val()==''){
						$.ligerDialog.tip({  title: '提示信息',content:'日期，不能为空！'});
						return;
					}
					else{
						var selected = grid.getCheckedRows();
						if (selected.length<1) { $.ligerDialog.warn('请选择行'); return; }
						var allsnum="";
						for(var i=0;i<selected.length;i++){
							allsnum+=selected[i].SerialNum;
							if(i<selected.length-1)allsnum+=","
						}
						window.open('KhzkdyDt.asp?ProcessType=PrintAll&SDate='+encodeURIComponent($('[name=SDate]').val())+'&EDate='+encodeURIComponent($('[name=EDate]').val())+'&CustID='+allsnum);
					}
			}
      $("#formsearch").ligerForm({
          fields: [
{"display":"开始日期","name":"SDate","newline":true,"labelWidth":100,"width":220,"space":30,cssClass: "field","type":"date"},
{"display":"截止日期","name":"EDate","newline":false,"labelWidth":100,"width":220,"space":30,cssClass: "field","type":"date"},
{"display":"市场","name":"departname","newline":true,"labelWidth":100,"width":220,"space":30,"type":"select",cssClass: "field",options:{valueFieldID:"departname",valueField:"text",url:'../Include/UseData.asp?ProcessType=SaleDept'}},
{"display":"客户","name":"text","newline":false,"labelWidth":100,"width":220,"space":30,cssClass: "field","type":"text"},
{"display":"业务员","name":"empname","newline":true,"labelWidth":100,"width":220,"space":30,cssClass: "field","type":"text"}
           ],
          appendID: false,
          toJSON: JSON2.stringify
      });
			var form=$('#formsearch');
			var container = $('<ul><li style="margin-right:8px"></li><li style="margin-right:8px"></li><li></li></ul><div class="l-clear"></div>').appendTo(form);
			LG.createButton({
					appendTo: container.find("li:eq(0)"),
					text: '搜索',
					click: function ()
					{
						var temp1=$('[name=SDate]').val();
						var temp2=$('[name=EDate]').val();
						$('[name=SDate]').val('');
						$('[name=EDate]').val('');
                    var rule = LG.bulidFilterGroup(form);
                    if (rule.rules.length)
                    {
                        grid.set('parms', { where: JSON2.stringify(rule) });
                    } else
                    {
                        grid.set('parms', {});
                    }
                    grid.loadData();
						$('[name=SDate]').val(temp1);
						$('[name=EDate]').val(temp2);
					}
			});
			LG.createButton({
					appendTo: container.find("li:eq(1)"),
					text: '打印',
					click: function ()
					{
						grid_printall();
					}
			});
</script>
</body>
</html>
