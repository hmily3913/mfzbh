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
                columns: [
	{"display":"车牌型号","name":"car_logo","width":60},
	{"display":"车牌号","name":"car_brand","width":80},
	{"display":"车辆类型","name":"typename","width":60},
	{"display":"使用人","name":"userid","width":60},
	{"display":"使用人姓名","name":"empname","width":60},
	{"display":"机动车证书","name":"machine_certificate","width":60},
	{"display":"乘坐人数","name":"ride_number","width":60},
	{"display":"费用标准","name":"exes_standard","width":60},
	{"display":"是否启用","name":"status","width":60},
	{"display":"出厂日期","name":"yield_date","width":60},
	{"display":"生产厂家","name":"yield_plant","width":60},
	{"display":"登记日期","name":"enrol_date","width":60},
	{"display":"购买日期","name":"buy_date","width":60},
	{"display":"发动机号","name":"engine_id","width":60},
	{"display":"车架号","name":"chassis_id","width":60},
	{"display":"车身颜色","name":"car_color","width":60},
	{"display":"轮胎规格","name":"type_spec","width":60},
	{"display":"排气量","name":"up_cast","width":60},
	{"display":"耗油量","name":"oilbox_capability","width":60},
	{"display":"购买价格","name":"price","width":60},
	{"display":"购置证号","name":"buy_id","width":60},
	{"display":"汽油标号","name":"gas_grade","width":60},
	{"display":"油箱容量","name":"oil_consume","width":60},
	{"display":"年审日期","name":"year_check_date","width":60},
	{"display":"到期预警提前","name":"day_count","width":60},
	{"display":"备注","name":"memo","width":60},
	{"display":"最近检查人","name":"inspect_id","width":60},
	{"display":"公里数","name":"mileage_numeric","width":60},
	{"display":"制单人","name":"create_id","width":60},
	{"display":"制单时间","name":"create_time","width":60},
	{"display":"修改人","name":"update_id","width":60},
	{"display":"修改时间","name":"update_time","width":60},
	{"display":"默认驾驶员","name":"chauffeur_id","width":60}],  
//                data: $.extend(true,{},[]), 
								dataAction: 'server',
								record : 'total',
								pageSize:30,
//								where : f_getWhere(),
								url:  'CarDt.asp?ProcessType=DetailsList',
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
					$.post('CarDt.asp?ProcessType=doDel',{SerialNum:selected.SerialNum},function(data)
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
				top.f_addTab(null,'车辆档案明细资料','MANA/Car4Dt.asp?SerialNum='+selected["SerialNum"]+'&chepai='+selected["car_brand"]);
			}else if(it.text=='查看'){
				selected = grid.getSelected();
				if (!selected) { $.ligerDialog.warn('请选择行'); return; }
				top.f_addTab(null,'车辆档案明细资料','MANA/Car4Dt.asp?IsView=1&SerialNum='+selected["SerialNum"]+'&chepai='+selected["car_brand"]);
			}else
				top.f_addTab(null,'车辆档案明细资料','MANA/Car4Dt.asp');
		}

    </script>
</head>
<body style="padding:6px; overflow:hidden;">
    <div id="maingrid4" style="margin:0; padding:0"></div>
</body>
</html>
