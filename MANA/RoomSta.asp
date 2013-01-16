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
{"display":"标准名称","name":"StandName","width":180},
{"display":"描述","name":"Miaoshu","width":280},
{"display":"押金/套","name":"Money",type:"number","width":180},
{"display":"备注","name":"memo","width":180},
{"display":"禁用","name":"dlfg","width":180}],  
						dataAction: 'server',
						record : 'total',
						pageSize:30,
						checkbox: false,
//								where : f_getWhere(),
						url:  'RoomStaDt.asp?ProcessType=DetailsList',
						rownumbers:true,
						pageSizeOptions:[10, 20, 30, 40, 50],
						headerRowHeight:20,
						width: '100%',height:'100%',
						toolbar: {}
				});
				$("#pageloading").hide();
				LG.setGridDoubleClick(grid, 'MANA-03-01-02');
      //加载toolbar 
      LG.loadToolbar(grid, toolbarBtnItemClick); 

      //工具条事件
      function toolbarBtnItemClick(item) {
          switch (item.id) {
              case "MANA-03-01-01":
									top.f_addTab(null,'房间标准明细资料','MANA/RoomSta4Dt.asp');
                  break;
              case "MANA-03-01-02":
                  var selected = grid.getSelected();
                  if (!selected) { LG.tip('请选择行!'); return }
                  top.f_addTab(null,'房间标准明细资料','MANA/RoomSta4Dt.asp?SerialNum='+selected["SerialNum"]);
                  break;
              case "MANA-03-01-03":
                  grid_delete();
                  break;
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
					$.post('RoomStaDt.asp?ProcessType=doDel',{SerialNum:allsnum},function(data)
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
{"display":"标准名称","name":"StandName","newline":true,"labelWidth":100,"width":220,"space":30,"type":"text","cssClass":"field"},
{"display":"是否禁用","name":"deleteFlag","newline":false,"labelWidth":100,"width":220,"space":30,"type":"select",cssClass: "field","options":{
	valueFieldID:"deleteFlag","data": [{ id: '', text: '全部'},{ id: '1', text: '是'}, { id: '0', text: '否' }]}}
           ],
          appendID: false,
          toJSON: JSON2.stringify
      });

      //增加搜索按钮,并创建事件
      LG.appendSearchButtons("#formsearch", grid);

</script>
</body>
</html>
