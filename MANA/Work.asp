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
    <link href="../css/jQuery.Gantt.css" rel="stylesheet" type="text/css" />  
<script language="javascript" src="../Script/jquery.fn.gantt.min.js"></script>
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
    	<div class="gantt2"></div>
<script language="javascript">
        var grid = null;
				grid = $("#maingrid4").ligerGrid({
						columns: [
{"display":"工作名称","name":"WorkName","width":100},
{"display":"详细描述","name":"XQMS","width":200},
{"display":"申请人","name":"Applyer","width":80},
{"display":"申请时间","name":"ApplyDate",type:"date","width":120},
{"display":"计划完成时间","name":"PlanFDate",type:"date","width":120},
{"display":"实际完成时间","name":"ActFDate",type:"date","width":120},
{"display":"备注","name":"memo","width":120},
{"display":"进度","name":"CheckFlag","width":60,
                    render: function (item)
                    {
                        if (parseInt(item.CheckFlag) == 1) return '已审核';
                        if (parseInt(item.CheckFlag) == 2) return '进行中';
                        if (parseInt(item.CheckFlag) == 3) return '已完成';
                        return '待审';
                    }
},
{"display":"制单人","name":"Biller","width":80},
{"display":"制单日期","name":"BillDate","width":120},
{"display":"审核人","name":"Checker","width":120},
{"display":"审核日期","name":"CheckDate","width":120}],  
						dataAction: 'server',
						record : 'total',
						pageSize:10,
						checkbox: false,
//								where : f_getWhere(),
						url:  'WorkDt.asp?ProcessType=DetailsList',
						rownumbers:true,
						pageSizeOptions:[10, 20, 30, 40, 50],
						headerRowHeight:20,
						width: '100%',height:'100%',
						detail: { onShowDetail: f_showBed},
						toolbar: {}
				});
				$("#pageloading").hide();
				LG.setGridDoubleClick(grid, 'MANA-04-05');
      //加载toolbar 
      LG.loadToolbar(grid, toolbarBtnItemClick); 
			var manager;
      //工具条事件
      function toolbarBtnItemClick(item) {
          switch (item.id) {
              case "MANA-04-01":
									top.f_addTab(null,'工作明细资料','MANA/Work4Dt.asp');
                  break;
              case "MANA-04-02":
                  var selected = grid.getSelected();
                  if (!selected) { LG.tip('请选择行!'); return }
                  top.f_addTab(null,'工作明细资料','MANA/Work4Dt.asp?SerialNum='+selected["SerialNum"]);
                  break;
              case "MANA-04-03":
                  grid_delete();
                  break;
              case "MANA-04-04":
                  grid_check()
                  break;
              case "MANA-04-05":
                  var selected = grid.getSelected();
                  if (!selected) { LG.tip('请选择行!'); return }
								top.f_addTab(null,'工作明细资料','MANA/Work4Dt.asp?IsView=1&SerialNum='+selected["SerialNum"]);
                  break;
              case "MANA-04-07":
                  var selected = grid.getSelected();
                  if (!selected) { LG.tip('请选择行!'); return }
								top.f_addTab(null,'工作明细资料','MANA/Work4Dt.asp?IsDetail=1&SerialNum='+selected["SerialNum"]);
                  break;
              case "MANA-04-08":
                  grid_count();
								break;
          }
      }
		function grid_check()
		{
			var selected = grid.getSelected();
			if (!selected) { LG.tip('请选择行!'); return }
			
			var checkdio=$.ligerDialog.open({ content : '请选择要进行的操作！', height: 120, width: null, buttons: [
					{ text: '审核', onclick: function (item, dialog) {
						$.post('WorkDt.asp?ProcessType=Check',{SerialNum:selected["SerialNum"]},function(data)
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
						$.post('WorkDt.asp?ProcessType=unCheck',{SerialNum:selected["SerialNum"]},function(data)
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
		//显示明细
		function f_showBed(row, detailPanel,callback)
		{
				var griddt = document.createElement('div'); 
				$(detailPanel).append(griddt);
				manager=$(griddt).css('margin',5).ligerGrid({
						columns:
							[
							{ display: '主键', name: 'SerialNum', width: 50, type: 'int',frozen:true },
							{ display: '工作内容', name: 'WorkText',"width":150},
							{ display: '开始时间', name: 'StartDate',"width":120},
							{"display":"结束时间","name":"EndDate","width":120},
							{"display":"记录时间","name":"NotDate","width":120},
							{"display":"备注","name":"memo","width":180}
						],checkbox: false,isScroll: false, showToggleColBtn: false, 
						width: 'auto',height:'auto',usePager:false,dataAction: 'server',
						url:  'WorkDt.asp?ProcessType=getText&SerialNum='+row.SerialNum , showTitle: false, columnWidth: 100
						 , headerRowHeight:20,onAfterShowData: callback,frozen:false
				});  
		}

		function deleteRow(rowid)
		{
			if (confirm('确定删除?'))
			{
				var datas=manager.getRow(rowid);
				manager.deleteRow(rowid);
			}
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
					$.post('WorkDt.asp?ProcessType=doDel',{SerialNum:allsnum},function(data)
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
{"display":"工作名称","name":"WorkName","newline":true,"labelWidth":100,"width":220,"space":30,"type":"text","cssClass":"field"},
{"display":"计划完成时间","name":"PlanFDate","newline":false,"labelWidth":100,"width":220,"space":30,"type":"date","cssClass":"field"},
{"display":"实际完成时间","name":"ActFDate","newline":true,"labelWidth":100,"width":220,"space":30,"type":"date","cssClass":"field"},
{"display":"进度","name":"CheckFlag","newline":false,"labelWidth":100,"width":220,"space":30,"type":"select","options":{
	valueFieldID:"CheckFlag","data": [{ id: '0', text: '未审核'},{ id: '1', text: '已审核'},{ id: '2', text: '进行中'}, { id: '3', text: '已完成'}]},"cssClass":"field"}
           ],
          appendID: false,
          toJSON: JSON2.stringify
      });

      //增加搜索按钮,并创建事件
      LG.appendSearchButtons("#formsearch", grid);
//产生甘特图
	 $("#SDate").ligerDateEditor();
	 $("#EDate").ligerDateEditor();
		function grid_count(){
       $.ligerDialog.open({
            title: '图表显示',
            target: $("#target1"),
//            width: 950, height: 530, 
						isResize: true,
            buttons: [{ text: '显示报表', onclick: function (item, dialog) { 
							if($('#SDate').val()==''||$('#EDate').val()==''){
								$.ligerDialog.tip({  title: '提示信息',content:'日期不能为空！'});
								return;
							}else{
	        	$(".gantt2").gantt({source: "WorkDt.asp?ProcessType=getGantt&SDate="+$('#SDate').val()+"&EDate="+$('#EDate').val()});
        $.ligerDialog.open({
            title: '图表信息',
            target: $(".gantt2"),
            width: '100%',height:'100%', 
						isResize: true,
            buttons: [{ text: '关闭', onclick: function (item, dialog) { dialog.hide(); } }]
        });

							}
						} },
						{ text: '关闭', onclick: function (item, dialog) { dialog.hide(); } }]
        });
		}

</script>
</body>
</html>
