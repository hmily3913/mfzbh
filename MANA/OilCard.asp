<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=utf-8" />
    <title></title>
    <link href="../lib/ligerUI/skins/Aqua/css/ligerui-all.css" rel="stylesheet" type="text/css" />
    <link href="../lib/ligerUI/skins/ligerui-icons.css" rel="stylesheet" type="text/css" />
<script language="javascript" src="../Script/speedup.js"></script>
<script language="javascript" src="../Script/jquery-1.7.2.min.js"></script>
    <script src="../lib/ligerUI/js/ligerui.min.js" type="text/javascript"></script>
<script language="javascript" src="../Script/LG.js"></script>
    <script type="text/javascript">
        var grid = null;
        $(function () {

            grid = $("#maingrid4").ligerGrid({
                columns:[
{"display":"油卡编号","name":"oilcardnumber","width":180},
{"display":"办理公司","name":"blcompany","width":80},
{"display":"使用人","name":"userid","width":80},
{"display":"使用人姓名","name":"empname","width":80},
{"display":"默认车牌号","name":"carbrand","width":80},
{"display":"是否启用","name":"status","width":60},
{"display":"备注","name":"memo","width":200}],  
//                data: $.extend(true,{},[]), 
								dataAction: 'server',
								record : 'total',
								pageSize:10,
								url:  'OilCardDt.asp?ProcessType=DetailsList',
								rownumbers:true,
								pageSizeOptions:[10, 20, 30, 40, 50],
								headerRowHeight:40,
                width: '100%',height:'100%',
                toolbar: { items: [
									{ text: '增加', click: showDetail, icon: 'add' },
									{ line: true },
									{ text: '修改', click: showDetail, icon: 'modify' },
									{ line: true },
									{ text: '删除', click: grid_delete, img: '../lib/ligerUI/skins/icons/delete.gif' }
									]
                }
            });
            $("#pageloading").hide();
        });

		function grid_delete()
		{
			var selected = grid.getSelected();
			if (!selected) { $.ligerDialog.warn('请选择行'); return; }
			$.ligerDialog.confirm('确定要删除选择的行？', function (yes)
			 {
				if(yes){
					$.post('OilCardDt.asp?ProcessType=doDel',{SerialNum:selected.SerialNum},function(data)
					{
							var datajson=jQuery.parseJSON(data);
							if(datajson.status){
								$.ligerDialog.success(datajson.messages);
								grid.deleteSelectedRow();
							}else{
								$.ligerDialog.error(datajson.messages);
							}
					});
				}
			 });
				
		}
    function showDetail(it)
    {
			var selected;
			if(it.text=='修改'){
				selected = grid.getSelected();
				if (!selected) { $.ligerDialog.warn('请选择行'); return; }
				top.f_addTab(null,'油卡档案明细资料','MANA/OilCard4Dt.asp?SerialNum='+selected["SerialNum"]);
			}else if(it.text=='查看'){
				selected = grid.getSelected();
				if (!selected) { $.ligerDialog.warn('请选择行'); return; }
				top.f_addTab(null,'油卡档案明细资料','MANA/OilCard4Dt.asp?IsView=1&SerialNum='+selected["SerialNum"]);
			}else
				top.f_addTab(null,'油卡档案明细资料','MANA/OilCard4Dt.asp');
		}

    </script>
</head>
<body style="padding:6px; overflow:hidden;">
    <div id="maingrid4" style="margin:0; padding:0"></div>
</body>
</html>
