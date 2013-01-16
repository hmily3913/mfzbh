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
<script language="javascript" src="../Script/jquery.validate.js"></script>
<script language="javascript" src="../Script/jquery.metadata.js"></script>
<script language="javascript" src="../Script/jquery.form.js"></script>
<script src="../lib/ligerUI/js/ligerui.min.js" type="text/javascript"></script>
<script src="../lib/ligerUI/js/plugins/ligerTree.js" type="text/javascript"></script>
<script src="../lib/ligerUI/js/plugins/ligerComboBox.js" type="text/javascript"></script>
<script src="../Script/ligerui.expand.js" type="text/javascript"></script>
<script language="javascript" src="../Script/LG.js"></script>
    <script src="../lib/json2.js" type="text/javascript"></script>
<style>
.form-bar{height:30px; line-height:30px; background:#EAEAEA;border-top:1px solid #C6C6C6; overflow:hidden; margin-bottom:0px; position:fixed; bottom:0; left:0; width:100%; padding-top:5px; text-align:right;}
/* ie6 */
.form-bar{_position:absolute;_bottom:auto;_top:expression(eval(document.documentElement.scrollTop+document.documentElement.clientHeight-this.offsetHeight-(parseInt(this.currentStyle.marginTop,10)||0)-(parseInt(this.currentStyle.marginBottom,10)||0)));}

.form-bar-inner{ margin-right:20px;}
.form-bar .l-dialog-btn{ }

</style>
</head>
<body style="padding-bottom:31px;"> 
    <div class="searchbox">
        <form id="formsearch" class="l-form"></form>
    </div>
    <div id="concact" style="border-bottom:solid 1px #FFF"></div>
    <script type="text/javascript"> 
      //搜索表单应用ligerui样式
			var form = $('#formsearch');
			var now = new Date(); 
			var Weeks=LG.getYearWeek(now.getYear(),now.getMonth()+1,now.getDate());
      form.ligerForm({
          fields: [
{"display":"房间","name":"RoomNo","newline":true,"labelWidth":100,"width":220,"space":30,"type":"text","cssClass":"field"},
{"display":"周数","name":"Weeks","newline":false,"labelWidth":100,"width":220,"space":30,"type":"int","cssClass":"field"}
           ],
          appendID: false,
          toJSON: JSON2.stringify
      });
			$('[name=Weeks]').val(Weeks);
      //增加搜索按钮,并创建事件
			//搜索按钮 附加到第一个li  高级搜索按钮附加到 第二个li
			var container = $('<ul><li style="margin-right:8px"></li><li style="margin-right:8px"></li><li></li></ul><div class="l-clear"></div>').appendTo(form);
			LG.createButton({
					appendTo: container.find("li:eq(0)"),
					text: '搜索',
					click: function ()
					{
						showData($('[name=Weeks]').val(),$('[name=RoomNo]').val());
					}
			});
			LG.createButton({
					appendTo: container.find("li:eq(1)"),
					text: '上一周',
					click: function ()
					{
						var lastwk=parseInt($('[name=Weeks]').val())-1;
						if(lastwk<1){
							$.ligerDialog.warn('已经是第一周，无上周数据！');
						}else{
							$('[name=Weeks]').val(lastwk);
							showData(lastwk,$('[name=RoomNo]').val());
						}
					}
			});
			LG.createButton({
					appendTo: container.find("li:eq(2)"),
					text: '下一周',
					click: function ()
					{
						var nextwk=parseInt($('[name=Weeks]').val())+1;
						if(nextwk>54){
							$.ligerDialog.warn('已经是最后一周，无下周数据！');
						}else{
							$('[name=Weeks]').val(nextwk);
							showData(nextwk,$('[name=RoomNo]').val());
						}
					}
			});
	function showData(wks,RoomNo){
		//加载list内容，ajax提交
		LG.showLoading('数据加载中...');
		$('#concact').load("RoomRptDt.asp #listtable",{
			ProcessType:'showData',
			Year:2012,
			Weeks:wks,
			RoomNo:RoomNo
		 },function(response, status, xhr){
			if (status =="success") {
				LG.hideLoading('数据加载完毕');
			}	
			})
	}
    </script>
</body>
</html>
