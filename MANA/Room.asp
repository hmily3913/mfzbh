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
{"display":"房间号","name":"RoomNo","width":80},
{"display":"价格","name":"Price","width":80,type:"number"},
{"display":"房间标准","name":"StandName","width":110},
{"display":"床位配置","name":"Chuangwei","width":100},
{"display":"人数","name":"PCount","width":60,type:"number"},
{"display":"入住资格","name":"Zige","width":80},
{"display":"用途类型","name":"UseType","width":80},
{"display":"楼层","name":"FLows","width":80},
{"display":"平方","name":"Mits","width":80,type:"number"},
{"display":"备注","name":"memo","width":150},
{"display":"禁用","name":"dlfg","width":60}],  
						dataAction: 'server',
						record : 'total',
						pageSize:10,
						checkbox: false,
//								where : f_getWhere(),
						url:  'RoomDt.asp?ProcessType=DetailsList',
						rownumbers:true,
						pageSizeOptions:[10, 20, 30, 40, 50],
						headerRowHeight:20,
						width: '100%',height:'100%',
						detail: { onShowDetail: f_showBed},
						toolbar: {}
				});
				$("#pageloading").hide();
				LG.setGridDoubleClick(grid, 'MANA-03-02-04');
      //加载toolbar 
      LG.loadToolbar(grid, toolbarBtnItemClick); 
			var manager;
      //工具条事件
      function toolbarBtnItemClick(item) {
          switch (item.id) {
              case "MANA-03-02-01":
									top.f_addTab(null,'房间明细资料','MANA/Room4Dt.asp');
                  break;
              case "MANA-03-02-02":
                  var selected = grid.getSelected();
                  if (!selected) { LG.tip('请选择行!'); return }
                  top.f_addTab(null,'房间明细资料','MANA/Room4Dt.asp?SerialNum='+selected["SerialNum"]);
                  break;
              case "MANA-03-02-03":
                  grid_delete();
                  break;
              case "MANA-03-02-04":
                  var selected = grid.getSelected();
                  if (!selected) { LG.tip('请选择行!'); return }
								top.f_addTab(null,'房间明细资料','MANA/Room4Dt.asp?IsView=1&SerialNum='+selected["SerialNum"]);
								break;
          }
      }
		//显示床位号
		function f_showBed(row, detailPanel,callback)
		{
				var griddt = document.createElement('div'); 
				$(detailPanel).append(griddt);
				manager=$(griddt).css('margin',5).ligerGrid({
						columns:
							[
							{ display: '主键', name: 'SerialNum', width: 50, type: 'int',frozen:true },
							{ display: '床位号', name: 'BedID',"width":80, editor: { type: 'text' } },
							{ display: '是否入住',"width":60, name: 'deleteFlag',
                    render: function (item)
                    {
                        if (parseInt(item.deleteFlag) == 1) return '是';
                        return '否';
                    }
							},
							{ display: '房客类型', name: 'FKType',"width":80},
							{"display":"房客姓名","name":"FKName","width":80},
							{"display":"房客性别","name":"FKSex","width":60},
							{"display":"入住时间","name":"InDate",type:"date","width":100},
							{"display":"押金","name":"Yajin",type:"number","width":60},
							{"display":"寝室长","name":"Qsz","width":60},
							{"display":"预计退房时间","name":"PlanOutDate",type:"date","width":100}
						],checkbox: false,isScroll: false, showToggleColBtn: false, 
						width: 'auto',height:'auto',usePager:false,dataAction: 'server',
						url:  'RoomDt.asp?ProcessType=getBeds&SerialNum='+row.SerialNum , showTitle: false, columnWidth: 100
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
					$.post('RoomDt.asp?ProcessType=doDel',{SerialNum:allsnum},function(data)
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
{"display":"房间号","name":"RoomNo","newline":true,"labelWidth":100,"width":220,"space":30,"type":"text","cssClass":"field"},
{"display":"人数","name":"PCount","newline":false,"labelWidth":100,"width":220,"space":30,"type":"digits","cssClass":"field"},
{"display":"楼层","name":"FLows","newline":true,"labelWidth":100,"width":220,"space":30,"type":"text","cssClass":"field"},
{"display":"备注","name":"memo","newline":false,"labelWidth":100,"width":400,"space":30,"type":"text","cssClass":"field"}
           ],
          appendID: false,
          toJSON: JSON2.stringify
      });

      //增加搜索按钮,并创建事件
      LG.appendSearchButtons("#formsearch", grid);

</script>
</body>
</html>
