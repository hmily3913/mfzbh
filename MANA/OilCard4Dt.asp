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
{"display":"油卡编号","name":"oilcardnumber","newline":false,"labelWidth":100,"width":220,"space":30,"type":"text","validate":{"required":true},"groupicon":groupstr},
{"display":"办理公司","name":"blcompany","newline":true,"labelWidth":100,"width":220,"space":30,"type":"select","options":{valueFieldID:"blcompany","initValue":'中石油',"initText":'中石油',"data": [{ id: '中石油', text: '中石油' }, { id: '中石化', text: '中石化'}, { id: '其他', text: '其他'}]},"validate":null,"groupicon":groupstr},
{"display":"使用人","name":"userid","newline":true,"labelWidth":100,"width":220,"space":30,comboboxName:"empname","type":"select",options:{
		width: 220,
		selectBoxWidth: 220,
		valueFieldID:"userid",
		selectBoxHeight: 200, treeLeafOnly:true,
		onSelected: function (newvalue){alert(newvalue);},
		tree: { idFieldName:'id',parentIDFieldName:'pId',url: '../Include/UseData.asp?ProcessType=EmpData',checkbox: false }
}},
{"display":"默认车牌号","name":"carbrand","newline":true,"labelWidth":100,"width":220,"space":30,"type":"select",options:{url:'OilCardDt.asp?ProcessType=CarList'}},
{"display":"是否启用","name":"status","newline":true,"labelWidth":100,"width":220,"space":30,comboboxName:"statusname","options":{valueFieldID:"status","initValue":'1',"initText":'是',"data": [{ id: '1', text: '是' }, { id: '0', text: '否'}]},"type":"select","validate":{"required":true},"groupicon":groupstr},
{"display":"备注","name":"memo",newline: true, labelWidth: 100, width: 200, space: 30,options:{width:400}, type: "textarea"}
	       ],
		 toJSON:JSON2.stringify
        });

        var actionRoot = "OilCardDt.asp";
        if(isEdit){ 
            $("#oilcardnumber").attr("readonly", "readonly").removeAttr("validate");
            mainform.attr("action", "OilCardDt.asp?ProcessType=SaveEdit"); 
        }
        if (isAddNew) {
            mainform.attr("action", "OilCardDt.asp?ProcessType=SaveAdd"); 
        }
        else { 
            LG.loadForm(mainform, { ashxUrl:"../MANA/OilCardDt.asp?",type: 'getDt', data: { SerialNum: SerialNum} },f_loaded);
        }  

        
          
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
                        win.LG.closeAndReloadParent(null, "44");
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
