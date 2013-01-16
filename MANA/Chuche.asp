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
 <div id="target1" style="width:200px; margin:3px; display:none;">
    <h3>请选择油费计算</h3>
    <div>
        <BR />
        <input type="text" id="SDate" /><br />
    </div>
 </div>
<script language="javascript">
        var grid = null;
				grid = $("#maingrid4").ligerGrid({
						columns: [
{"display":"车牌","name":"chepai","width":60},
{"display":"出发时间","name":"cfsj",type:"date","width":100},
{"display":"出发公里表","name":"cflcs",type:"number","width":60},
{"display":"使用人","name":"syrer","width":60},
{"display":"使用部门","name":"ycbmer","width":80},
{"display":"驾驶员","name":"jsyer","width":60},
{"display":"事由及目的地","name":"syjmdd","width":120},
{"display":"费用类别","name":"fylb","width":40},
{"display":"状态","name":"CheckFlag","width":40,
                    render: function (item){
                        if (parseInt(item.CheckFlag) == 1) return '回车';
//                        if (parseInt(item.CheckFlag) == 2) return '审核';
                        return '否';
                    }
},
{"display":"锁定","name":"HlFlag","width":40,
                    render: function (item){
                        if (parseInt(item.HlFlag) == 1) return '是';
                        return '否';
                    }
},
{"display":"回来时间","name":"hlsj",type:"date","width":100},
{"display":"回来公里表","name":"hllcs",type:"number","width":60},
{"display":"使用公里数","name":"sylcs",type:"number","width":40},
{"display":"费用金额","name":"fyje","width":40},
{"display":"备注","name":"memo","width":120},
{"display":"登记人","name":"Biller","width":60},
{"display":"登记时间","name":"BillDate",type:"date","width":100}
],  
						dataAction: 'server',
						record : 'total',
						pageSize:30,
						checkbox: true,
//								where : f_getWhere(),
						url:  'ChucheDt.asp?ProcessType=DetailsList',
						rownumbers:true,
						pageSizeOptions:[10, 20, 30, 40, 50],
						headerRowHeight:40,
						width: '100%',height:'100%',
						toolbar: {}
				});
				$("#pageloading").hide();
				LG.setGridDoubleClick(grid, 'MANA-02-04-02');
      //加载toolbar 
      LG.loadToolbar(grid, toolbarBtnItemClick); 

      //工具条事件
      function toolbarBtnItemClick(item) {
          switch (item.id) {
              case "MANA-02-04-01":
									top.f_addTab(null,'出车管理明细资料','MANA/Chuche4Dt.asp');
                  break;
              case "MANA-02-04-02":
			var selected = grid.getCheckedRows();
			if (selected.length!=1) { $.ligerDialog.warn('请选择一行进行操作'); return; }
                  top.f_addTab(null,'出车管理明细资料','MANA/Chuche4Dt.asp?SerialNum='+selected[0].SerialNum);
                  break;
              case "MANA-02-04-03":
                  grid_delete();
                  break;
              case "MANA-02-04-04":
                  grid_check();
                  break;
              case "MANA-02-04-05":
                  grid_hl();
                  break;
              case "MANA-02-04-06":
			var selected = grid.getCheckedRows();
			if (selected.length!=1) { $.ligerDialog.warn('请选择一行进行操作'); return; }
                  top.f_addTab(null,'出车管理明细资料','MANA/Chuche4Dt.asp?IsView=1&SerialNum='+selected[0].SerialNum);
                  break;
              case "MANA-02-04-07":
                  grid_count();
                  break;
              case "MANA-02-04-08":
			var selected = grid.getCheckedRows();
			if (selected.length!=1) { $.ligerDialog.warn('请选择一行进行操作'); return; }
                  top.f_addTab(null,'出车管理明细资料','MANA/Chuche4Dt.asp?EditAll=1&SerialNum='+selected[0].SerialNum);
									break;
              case "MANA-02-04-09":
									var rule = LG.bulidFilterGroup($('#formsearch'));
									if (rule.rules.length){
										window.open('ChucheDt.asp?ProcessType=Export&print_tag=1&where='+encodeURIComponent(JSON2.stringify(rule)));
										JSON2.stringify(rule);
									}else{
										window.open('ChucheDt.asp?ProcessType=Export&print_tag=1&where=');
									}
                  break;
          }
      }
		function grid_hl(){
			var selected = grid.getCheckedRows();
			if (selected.length<1) { $.ligerDialog.warn('请选择行'); return; }
			var allsnum="";
			for(var i=0;i<selected.length;i++){
				allsnum+=selected[i].SerialNum;
				if(i<selected.length-1)allsnum+=","
			}
			var checkdio=$.ligerDialog.open({ content : '<br/>请选择要进行的操作！<br/>', height: 120, width: null, buttons: [
					{ text: '锁定', onclick: function (item, dialog) {
						$.post('ChucheDt.asp?ProcessType=hl',{SerialNum:allsnum},function(data)
						{
								var datajson=jQuery.parseJSON(data);
								if(datajson.status){
									$.ligerDialog.success(datajson.messages);
									checkdio.hide();
									grid.loadData();
								}else{
									$.ligerDialog.error(datajson.messages);
								}
						});
					} },
					{ text: '解锁', onclick: function (item, dialog) {
						$.post('ChucheDt.asp?ProcessType=unhl',{SerialNum:allsnum},function(data)
						{
								var datajson=jQuery.parseJSON(data);
								if(datajson.status){
									$.ligerDialog.success(datajson.messages);
									checkdio.hide();
									grid.loadData();
								}else{
									$.ligerDialog.error(datajson.messages);
								}
						});
					} },
					{ text: '取消', onclick: function (item, dialog) { dialog.close(); } }
			 ], isResize: true
			});
		}
		function grid_check()
		{
			var selected = grid.getCheckedRows();
			if (selected.length!=1) { $.ligerDialog.warn('请选择一行'); return; }
			$.ligerDialog.confirm('确定要反审核选择的行？', function (yes)
			 {
				if(yes){
					$.post('ChucheDt.asp?ProcessType=unCheck',{SerialNum:selected[0].SerialNum},function(data)
					{
							var datajson=jQuery.parseJSON(data);
							if(datajson.status){
								$.ligerDialog.success(datajson.messages);
							}else{
								$.ligerDialog.error(datajson.messages);
							}
					});
				}
			 });
		}		
		function grid_count(){
			 $("#SDate").ligerComboBox({url:'FenTanDt.asp?ProcessType=DateList', valueFieldID: 'ctDate'});
       $.ligerDialog.open({
            title: '油费分摊',
            target: $("#target1"),
//            width: 950, height: 530, 
						isResize: true,
            buttons: [{ text: '查报表', onclick: function (item, dialog) { 
							if($('#SDate').val()==''){
								$.ligerDialog.tip({  title: '提示信息',content:'日期不能为空！'});
								return;
							}else{
        $.ligerDialog.open({
            title: '分摊信息',
            url:  'ChucheDt.asp?ProcessType=ftList&SDate='+encodeURIComponent($('#SDate').val()),
            width: 800,height:450, 
						isResize: true,
            buttons: [{ text: '关闭', onclick: function (item, dialog) { dialog.hide(); } }]
        });

							}
						} },{ text: '导出', onclick: function (item, dialog) { 
							if($('#SDate').val()==''||$('#EDate').val()==''){
								$.ligerDialog.tip({  title: '提示信息',content:'日期不能为空！'});
								return;
							}else{
								window.open('ChucheDt.asp?ProcessType=ftList&print_tag=1&SDate='+encodeURIComponent($('#SDate').val()));
							}
						} },
						{ text: '关闭', onclick: function (item, dialog) { dialog.hide(); } }]
        });
		}

		function grid_delete()
		{
			var selected = grid.getCheckedRows();
			if (selected.length<1) { $.ligerDialog.warn('请选择行'); return; }
			$.ligerDialog.confirm('确定要删除选择的行？', function (yes)
			 {
				if(yes){
					var allsnum="";
					for(var i=0;i<selected.length;i++){
						allsnum+=selected[i].SerialNum;
						if(i<selected.length-1)allsnum+=","
					}
					$.post('ChucheDt.asp?ProcessType=doDel',{SerialNum:allsnum},function(data)
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
      //搜索表单应用ligerui样式
      $("#formsearch").ligerForm({
          fields: [
{"display":"费用类别","name":"fylb","newline":true,"labelWidth":100,"width":220,"space":30,"type":"select",cssClass: "field","options":{
	valueFieldID:"fylb","data": [{ id: '', text: '全部'},{ id: '公司', text: '公司'}, { id: '委外', text: '委外' }]}},
{"display":"出发时间","name":"cfsj","newline":false,"labelWidth":100,"width":220,"space":30,"type":"date",cssClass: "field"},
//{"display":"交易地点","name":"jydd","newline":false,"labelWidth":100,"width":220,"space":30,cssClass: "field","type":"text"},
{"display":"车牌","name":"chepai","newline":true,"labelWidth":100,"width":220,"space":30,"type":"select",cssClass: "field",options:{url:'OilCardDt.asp?ProcessType=CarList'}},
{"display":"使用人","name":"syr","newline":false,"labelWidth":100,"width":220,"space":30,cssClass: "field",comboboxName:"syrer","type":"select",options:{
		width: 220,
		selectBoxWidth: 220,
		valueFieldID:"syr",
		selectBoxHeight: 200, treeLeafOnly:true,
		tree: { idFieldName:'id',parentIDFieldName:'pId',url: '../Include/UseData.asp?ProcessType=EmpData',checkbox: false }
}},
{"display":"状态","name":"checkflag","newline":true,"labelWidth":100,"width":220,"space":30,"type":"select",cssClass: "field","options":{
	valueFieldID:"checkflag","data": [{ id: '', text: '全部'},{ id: '1', text: '回车'}, { id: '0', text: '出车' }]}},
{"display":"是否计算","name":"ctflag","newline":false,"labelWidth":100,"width":220,"space":30,"type":"select",cssClass: "field","options":{
	valueFieldID:"ctflag","data": [{ id: '', text: '全部'},{ id: '1', text: '是'}, { id: '0', text: '否' }]}}
           ],
          appendID: false,
          toJSON: JSON2.stringify
      });

      //增加搜索按钮,并创建事件
      LG.appendSearchButtons("#formsearch", grid);

</script>
</body>
</html>
