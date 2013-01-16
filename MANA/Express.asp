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
{"display":"寄件日期","name":"SendDate","width":120,type:"date"},
{"display":"寄件人","name":"Senderer","width":80},
{"display":"寄件部门","name":"Sendbmer","width":80},
{"display":"目的地","name":"Mdd","width":80},
{"display":"快递公司","name":"ECompany","width":80},
{"display":"快递费","name":"Fees","width":80},
{"display":"取件人","name":"Geter","width":80},
{"display":"取件日期","name":"GetDate","width":120,type:"date"},
{"display":"备注","name":"memo","width":120},
{"display":"登记人","name":"Biller","width":80},
{"display":"登记时间","name":"BillDate","width":120,type:"date"},
{"display":"审核","name":"CheckFlag","width":60,
	render: function (item)
	{
			if (parseInt(item.CheckFlag) == 1) return '审核';
			return '待审';
	}
}
],  
						dataAction: 'server',
						record : 'total',
						pageSize:20,
//						checkbox: false,
//								where : f_getWhere(),
						url:  'ExpressDt.asp?ProcessType=DetailsList',
						rownumbers:true,
						pageSizeOptions:[10, 20, 30, 40, 50],
						headerRowHeight:24,
						width: '100%',height:'100%',
						toolbar: {}
				});
				$("#pageloading").hide();
				LG.setGridDoubleClick(grid, 'MANA-05-02');
      //加载toolbar 
      LG.loadToolbar(grid, toolbarBtnItemClick); 

      //工具条事件
      function toolbarBtnItemClick(item) {
          switch (item.id) {
              case "MANA-05-01":
									top.f_addTab(null,'快递管理明细资料','MANA/Express4Dt.asp');
                  break;
              case "MANA-05-02":
                  var selected = grid.getSelected();
                  if (!selected) { LG.tip('请选择行!'); return }
                  top.f_addTab(null,'快递管理明细资料','MANA/Express4Dt.asp?SerialNum='+selected["SerialNum"]);
                  break;
              case "MANA-05-03":
                  grid_delete();
                  break;
              case "MANA-05-04":
                  grid_check();
                  break;
              case "MANA-05-06":
                  grid_count();
                  break;
          }
      }
			
			 $("#SDate").ligerDateEditor();
			 $("#EDate").ligerDateEditor();
		//计算公里单价及汇总报表
		function grid_count(){
       $.ligerDialog.open({
            title: '报表查询',
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
{"display":"部门","name":"bm","width":150},
{"display":"寄件人","name":"jjr","width":80,totalSummary:{type: 'count'}},
{"display":"目的地","name":"Mdd","width":100},
{"display":"寄件日期","name":"SendDate","width":80},
{"display":"费用(元)","name":"Fees","width":80,type:"number",totalSummary:{type: 'sum'}}
],  
	groupColumnName:'bm',
	dataAction: 'server',
	usePager:false,
	url:  'ExpressDt.asp?ProcessType=ctList&SDate='+encodeURIComponent($('#SDate').val())+'&EDate='+encodeURIComponent($('#EDate').val()),
	headerRowHeight:20,
	width: '100%',height:'100%'
});
        $.ligerDialog.open({
            title: '汇总信息',
            target: gridcount,
            width: '100%',height:'100%', 
						isResize: true,
            buttons: [{ text: '导出', onclick: function (item, dialog) { 
							if($('#SDate').val()==''||$('#EDate').val()==''){
								$.ligerDialog.tip({  title: '提示信息',content:'日期不能为空！'});
								return;
							}else{
									window.open('ExpressDt.asp?ProcessType=poexcel&SDate='+encodeURIComponent($('#SDate').val())+'&EDate='+encodeURIComponent($('#EDate').val()));
							}
						} },{ text: '关闭', onclick: function (item, dialog) { dialog.hide(); } }]
        });

							}
						} },
						{ text: '关闭', onclick: function (item, dialog) { dialog.hide(); } }]
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
						$.post('ExpressDt.asp?ProcessType=Check',{SerialNum:allsnum},function(data)
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
						$.post('ExpressDt.asp?ProcessType=unCheck',{SerialNum:allsnum},function(data)
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
					$.post('ExpressDt.asp?ProcessType=doDel',{SerialNum:allsnum},function(data)
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
{"display":"寄件日期","name":"SendDate","newline":true,"labelWidth":100,"width":220,"space":30,"type":"date","cssClass":"field"},
{"display":"寄件人","name":"Sender","newline":false,"labelWidth":100,"width":220,"space":30,"type":"text","cssClass":"field"},
{"display":"寄件部门","name":"Sendbm","newline":true,"labelWidth":100,"width":220,"space":30,"type":"text","cssClass":"field"},
{"display":"目的地","name":"Mdd","newline":false,"labelWidth":100,"width":220,"space":30,"type":"text","cssClass":"field"}
           ],
          appendID: false,
          toJSON: JSON2.stringify
      });

      //增加搜索按钮,并创建事件
      LG.appendSearchButtons("#formsearch", grid);

</script>
</body>
</html>
