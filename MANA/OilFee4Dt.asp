<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=utf-8" />
    <title></title>
    <link href="../lib/ligerUI/skins/Aqua/css/ligerui-all.css" rel="stylesheet" type="text/css" />
    <link href="../lib/ligerUI/skins/ligerui-icons.css" rel="stylesheet" type="text/css" />
<script language="javascript" src="../Script/speedup.js"></script>
<script language="javascript" src="../Script/jquery-1.7.2.min.js"></script>
<script language="javascript" src="../Script/jquery.validate.js"></script>
<script language="javascript" src="../Script/jquery.metadata.js"></script>
<script language="javascript" src="../Script/jquery.form.js"></script>
    <script src="../lib/ligerUI/js/ligerui.min.js" type="text/javascript"></script>
    <script src="../lib/ligerUI/js/plugins/ligerTree.js" type="text/javascript"></script>
    <script src="../lib/ligerUI/js/plugins/ligerComboBox.js" type="text/javascript"></script>
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
 <div id="tabcontainer" style="margin:3px;">
     <div title="基本信息">
        <form id="mainform" method="post"></form> 
     </div>
     <div title="订单信息" tabid="orders">
        <div id="ordergrid" style="margin:2px auto;"></div>
     </div>
 </div>
    <script type="text/javascript"> 
        //当前ID
        var SerialNum = '<%= request.QueryString("SerialNum") %>';
        //是否新增状态
        var isAddNew = SerialNum == "" || SerialNum == "0";
        //是否查看状态
        var isView = <%=request.QueryString("IsView") or 0 %>;
        //是否编辑状态
        var isEdit = !isAddNew && !isView;

        //覆盖本页面grid的loading效果
        LG.overrideGridLoading(); 

        //表单底部按钮 
        LG.setFormDefaultBtn(f_cancel,isView ? null : f_save);

        //创建表单结构
        var mainform = $("#mainform");  
				var groupstr="../lib/ligerUI/skins/icons/communication.gif";
        mainform.ligerForm({ 
         inputWidth: 280,
         fields : [
{"name":"SerialNum","type":"hidden"},
{"display":"交易类型","name":"jylx","newline":true,"labelWidth":100,"width":220,"space":30,"type":"select","options":{
//	onSelected:function(val, t){alert('val')},
	valueFieldID:"jylx","initValue":'IC卡消费',"initText":'IC卡消费',"data": [{ id: 'IC卡消费', text: 'IC卡消费'}, { id: '现金消费', text: '现金消费' }, { id: '其他', text: '其他'}]},"validate":{"required":true},"groupicon":groupstr},//
{"display":"交易时间","name":"jysj","newline":true,"labelWidth":100,"width":220,"space":30,"type":"date",options:{ showTime: true},"validate":{"required":true},"groupicon":groupstr},
{"display":"交易地点","name":"jydd","newline":true,"labelWidth":100,"width":220,"space":30,"type":"text","validate":{"required":true},"groupicon":groupstr},
{"display":"卡号","name":"kahao","newline":true,"labelWidth":100,"width":220,"space":30,"type":"select",options:{
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
{"display":"车牌号","name":"carbrand","newline":true,"labelWidth":100,"width":220,"space":30,"type":"select","validate":{"required":true},options:{url:'OilCardDt.asp?ProcessType=CarList'}},

{"display":"交易人","name":"userid","newline":true,"labelWidth":100,"width":220,"space":30,comboboxName:"empname","type":"select",options:{
		width: 220,
		selectBoxWidth: 220,
		valueFieldID:"userid",
		selectBoxHeight: 200, treeLeafOnly:true,
		onSelected: function (newvalue){alert(newvalue);},
		tree: { idFieldName:'id',parentIDFieldName:'pId',url: '../Include/UseData.asp?ProcessType=EmpData',checkbox: false }
}},
{"display":"商品名称","name":"spmc","newline":true,"labelWidth":100,"width":220,"space":30,"type":"text","validate":null,"groupicon":groupstr},
{"display":"油量/L","name":"yl","newline":true,"labelWidth":100,"width":220,"space":30,"type":"number","validate":{"required":true},"groupicon":groupstr},
{"display":"金额/元","name":"je","newline":true,"labelWidth":100,"width":220,"space":30,"type":"number","validate":{"required":true},"groupicon":groupstr},
{"display":"余额/元","name":"ye","newline":true,"labelWidth":100,"width":220,"space":30,"type":"number","validate":null,"groupicon":groupstr},
{"display":"交易流水号","name":"jylsh","newline":true,"labelWidth":100,"width":220,"space":30,"type":"text","validate":null,"groupicon":groupstr},
{"display":"备注","name":"memo","newline":true,"labelWidth":100,"width":350,"space":30,"type":"textarea","validate":null,"groupicon":groupstr}
	       ],
		 toJSON:JSON2.stringify
        });


        var actionRoot = "OilFeeDt.asp";
        if(isEdit){ 
//              $("#CustomerID").attr("readonly", "readonly").removeAttr("validate");
            mainform.attr("action", "OilFeeDt.asp?ProcessType=SaveEdit"); 
        }
        if (isAddNew) {
            mainform.attr("action", "OilFeeDt.asp?ProcessType=SaveAdd"); 
        }
        else { 
            LG.loadForm(mainform, { ashxUrl:"../MANA/OilFeeDt.asp?",type: 'getDt', data: { SerialNum: SerialNum} },f_loaded);
        }  

				$.ligerui.get('kahao').bind('Selected', function (val,t){
					if($.ligerui.get(this.grid).selected[0]){
						$('#userid').val($.ligerui.get(this.grid).selected[0].userid);
						$('#carbrand').val($.ligerui.get(this.grid).selected[0].carbrand);
						$('#empname').val($.ligerui.get(this.grid).selected[0].empname);
					}
				});        
          
        if(!isView) 
        {
            //验证
            jQuery.metadata.setType("attr", "validate"); 
            LG.validate(mainform);
        } 

		function f_loaded()
        {
            if(!isView) return; 
            //查看状态，控制不能编辑
            $("input,select,textarea",mainform).attr("readonly", "readonly");
        }
        function f_save()
        {
            LG.submitForm(mainform, function (data) {
                var win = parent || window;
                if (data.status) {  
                    win.LG.showSuccess('保存成功', function () { 
//											win.LG.closeCurrentTab(null);
                        win.LG.closeAndReloadParent(null, "48");
                    });
                }
                else { 
                    win.LG.showError('错误:' + data.messages);
                }
            });
        }
        function f_cancel()
        {
            var win = parent || window;
            win.LG.closeCurrentTab(null);
        }

		 
    </script>
</body>
</html>
