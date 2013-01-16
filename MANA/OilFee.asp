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
    <h3>请选择油费计算期间</h3>
    <div>
        <BR />
        <input type="text" id="SDate" /><br />
        <input type="text" id="EDate" /><br />
    </div>
 </div>

<script language="javascript">
        var grid = null;
				grid = $("#maingrid4").ligerGrid({
						columns: [
{"display":"交易类型","name":"jylx","width":60},
{"display":"交易时间","name":"jysj","width":100},
{"display":"交易地点","name":"jydd","width":180},
{"display":"卡号","name":"kahao","width":60},
{"display":"使用人","name":"userid","width":60},
{"display":"商品名称","name":"spmc","width":80},
{"display":"油量/L","name":"yl","width":60,type:"number"},
{"display":"金额/元","name":"je","width":60,type:"number"},
{"display":"余额/元","name":"ye","width":60,type:"number"},
{"display":"交易流水号","name":"jylsh","width":60},
{"display":"备注","name":"memo","width":180},
{"display":"审核","name":"CheckFlag","width":40},
{"display":"制单人","name":"Biller","width":60},
{"display":"制单日期","name":"BillDate","width":60},
{"display":"审核人","name":"Checker","width":60},
{"display":"审核日期","name":"CheckDate","width":60}],  
						dataAction: 'server',
						record : 'total',
						pageSize:30,
						checkbox: true,
//								where : f_getWhere(),
						url:  'OilFeeDt.asp?ProcessType=DetailsList',
						rownumbers:true,
						pageSizeOptions:[10, 20, 30, 40, 50],
						headerRowHeight:40,
						width: '100%',height:'100%',
						toolbar: { items: [
							{ text: '增加', click: showDetail, icon: 'add' },
							{ line: true },
							{ text: '修改', click: showDetail, icon: 'modify' },
							{ line: true },
							{ text: '删除', click: grid_delete, img: '../lib/ligerUI/skins/icons/delete.gif' },
							{ line: true },
							{ text: '查看', click: showDetail, img: '../lib/icons/miniicons/page.gif' },
							{ line: true },
							{ text: '导入', click: grid_excelin, img: '../lib/ligerUI/skins/icons/up.gif' },
							{ line: true },
							{ text: '审核', click: grid_check, img: '../lib/ligerUI/skins/icons/process.gif' },
							{ line: true },
							{ text: '计算', click: grid_count, img: '../lib/icons/miniicons/icon_monitor_pc.gif' },
							{ line: true }
							]
						}
				});
				$("#pageloading").hide();
		//计算公里单价及汇总报表
		function grid_count(){
			 $("#SDate").ligerDateEditor();
			 $("#EDate").ligerDateEditor();
       $.ligerDialog.open({
            title: '油费计算',
            target: $("#target1"),
//            width: 950, height: 530, 
						isResize: true,
            buttons: [{ text: '查汇总', onclick: function (item, dialog) { 
							if($('#SDate').val()==''||$('#EDate').val()==''){
								$.ligerDialog.tip({  title: '提示信息',content:'日期不能为空！'});
								return;
							}else{
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
	url:  'OilFeeDt.asp?ProcessType=ctList&SDate='+encodeURIComponent($('#SDate').val())+'&EDate='+encodeURIComponent($('#EDate').val()),
	headerRowHeight:40,
	width: '100%',height:'100%'
});
        $.ligerDialog.open({
            title: '汇总信息',
            target: gridcount,
            width: '100%',height:'100%', 
						isResize: true,
            buttons: [{ text: '关闭', onclick: function (item, dialog) { dialog.hide(); } }]
        });

							}
						} },{ text: '计算', onclick: function (item, dialog) { 
							if($('#SDate').val()==''||$('#EDate').val()==''){
								$.ligerDialog.tip({  title: '提示信息',content:'日期不能为空！'});
								return;
							}else{
								$.post('OilFeeDt.asp?ProcessType=checkct&SDate='+encodeURIComponent($('#SDate').val())+'&EDate='+encodeURIComponent($('#EDate').val()),function(data){
									var datajson=jQuery.parseJSON(data);//转换后的JSON对象
									$.ligerDialog.confirm(datajson.messages+'<br/>确定要继续计算吗？', function (yes)
									 {
										if(yes){
											LG.showLoading('数据更新到出车单中...');
											$.post('OilFeeDt.asp?ProcessType=setct&SDate='+encodeURIComponent($('#SDate').val())+'&EDate='+encodeURIComponent($('#EDate').val()),function(data){
												LG.hideLoading('数据更新完毕');
												var datajson=jQuery.parseJSON(data);//转换后的JSON对象
												LG.showSuccess(datajson.messages);
											});
										}
									});
								});
							}
						} },
						{ text: '关闭', onclick: function (item, dialog) { dialog.hide(); } }]
        });
		}
		
		function grid_excelin(){
        var iframe = $("<iframe />").attr("src","../Script/xheditor_plugins/multiupload/multiupload.html");
        $.ligerDialog.open({
            title: 'JSON',
            target: iframe.wrap('<div></div>').parent().css('margin', 0),
            width: 300, height: 300, isResize: true,
            buttons: [{ text: '导入', onclick: function (item, dialog) {
							if($('#fileurl').val()==''){LG.showError('未找到上传的文件，导入失败！');return false;}
							else{
								LG.showLoading('数据导入进行中...');
								$.post('OilFeeDt.asp?ProcessType=xls2sql&fileurl='+encodeURIComponent($('#fileurl').val()),function(data){
									LG.hideLoading('数据导入完毕');
									var datajson=jQuery.parseJSON(data);//转换后的JSON对象
									LG.showSuccess(datajson.messages);
									if(datajson.status){
										dialog.hide(); 
										grid.loadData();
									}
								});
								
								
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
					$.post('OilFeeDt.asp?ProcessType=doDel',{SerialNum:allsnum},function(data)
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
		function grid_check()
		{
			var selected = grid.getCheckedRows();
			if (selected.length<1) { $.ligerDialog.warn('请选择行'); return; }
			var allsnum="";
			for(var i=0;i<selected.length;i++){
				allsnum+=selected[i].SerialNum;
				if(i<selected.length-1)allsnum+=","
			}
			
			var checkdio=$.ligerDialog.open({ content : '请选择要进行的操作！', height: 120, width: null, buttons: [
					{ text: '审核', onclick: function (item, dialog) {
						$.post('OilFeeDt.asp?ProcessType=Check',{SerialNum:allsnum},function(data)
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
					{ text: '反审核', onclick: function (item, dialog) {
						$.post('OilFeeDt.asp?ProcessType=unCheck',{SerialNum:allsnum},function(data)
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
    function showDetail(it)
    {
			var selected;
			if(it.text=='修改'){
				selected = grid.getSelected();
				if (!selected) { $.ligerDialog.warn('请选择行'); return; }
				top.f_addTab(null,'油费管理明细资料','MANA/OilFee4Dt.asp?SerialNum='+selected["SerialNum"]);
			}else if(it.text=='查看'){
				selected = grid.getSelected();
				if (!selected) { $.ligerDialog.warn('请选择行'); return; }
				top.f_addTab(null,'油费管理明细资料','MANA/OilFee4Dt.asp?IsView=1&SerialNum='+selected["SerialNum"]);
			}else
				top.f_addTab(null,'油费管理明细资料','MANA/OilFee4Dt.asp');
		}
      //搜索表单应用ligerui样式
      $("#formsearch").ligerForm({
          fields: [
{"display":"交易类型","name":"jylx","newline":true,"labelWidth":100,"width":220,"space":30,"type":"select",cssClass: "field","options":{
//	onSelected:function(val, t){alert('val')},
	valueFieldID:"jylx","initValue":'IC卡消费',"initText":'IC卡消费',"data": [{ id: 'IC卡消费', text: 'IC卡消费'}, { id: '现金消费', text: '现金消费' }, { id: '其他', text: '其他'}]}},
//{"display":"交易时间","name":"jysj","newline":false,"labelWidth":100,"width":220,"space":30,"type":"date",cssClass: "field"},
{"display":"交易地点","name":"jydd","newline":false,"labelWidth":100,"width":220,"space":30,cssClass: "field","type":"text"},
{"display":"卡号","name":"kahao","newline":true,"labelWidth":100,"width":220,"space":30,"type":"select",cssClass: "field",options:{
                width: 220,
                slide: false,
                selectBoxWidth: 300,
                selectBoxHeight: 200, valueField: 'oilcardnumber', textField: 'oilcardnumber',valueFieldID:"kahao",
                grid: {
									columns: [
									{ display: '油卡号', name: 'oilcardnumber', align: 'left', width: 100, minWidth: 60 },
									{ display: '使用人', name: 'userid', width: 60 },
									{ display: '使用人', name: 'empname', width: 60 },
									{ display: '车牌', name: 'carbrand', width: 60 }
									], switchPageSizeApplyComboBox: false,
									usePager:false,
									dataAction: 'server',
									url:  'OilFeeDt.asp?ProcessType=getCard',
									checkbox: false
							}
            }},
{"display":"交易人","name":"userid","newline":false,"labelWidth":100,"width":220,"space":30,cssClass: "field",comboboxName:"empname","type":"select",options:{
		width: 220,
		selectBoxWidth: 220,
		valueFieldID:"userid",
		selectBoxHeight: 200, treeLeafOnly:true,
		onSelected: function (newvalue){alert(newvalue);},
		tree: { idFieldName:'id',parentIDFieldName:'pId',url: '../Include/UseData.asp?ProcessType=EmpData',checkbox: false }
}}
           ],
          appendID: false,
          toJSON: JSON2.stringify
      });

      //增加搜索按钮,并创建事件
      LG.appendSearchButtons("#formsearch", grid);

</script>
</body>
</html>
