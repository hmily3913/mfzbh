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
{"display":"寄件日期","name":"SendDate","newline":true,"labelWidth":100,"width":220,"space":30,"type":"date","validate":{"required":true}},
{"display":"寄件人","name":"Sender","newline":true,"labelWidth":100,"width":220,"space":30,"type":"select",comboboxName:"Senderer",options:{valueFieldID:"Sender"},"validate":{"required":true}},
{"display":"使用部门","name":"Sendbm","newline":true,"labelWidth":100,"width":220,"space":30,"type":"select",comboboxName:"Sendbmer",options:{valueFieldID:"Sendbm"},"validate":{"required":true}},

{"display":"目的地","name":"Mdd","newline":true,"labelWidth":100,"width":220,"space":30,"type":"text","validate":{"required":true}},
{"display":"快递公司","name":"ECompany","newline":true,"labelWidth":100,"width":220,"space":30,"type":"select","options":{
	valueFieldID:"cxyl","initValue":'申通快递',"initText":'申通快递',"data": [
	{ id: '申通快递', text: '申通快递'},
	{ id: '邮政EMS', text: '邮政EMS'},
	{ id: '韵达快递', text: '韵达快递'},
	{ id: '中铁快运', text: '中铁快运'},
	{ id: '顺丰快递', text: '顺丰快递'},
	{ id: '天天快递', text: '天天快递'},
	{ id: '全一快递', text: '全一快递'},
	{ id: '优速快递', text: '优速快递'},
	{ id: '宅急送', text: '宅急送'},
	{ id: '中通快递', text: '中通快递'},
	{ id: '汇通快递', text: '汇通快递'},
	{ id: '圆通快递', text: '圆通快递'},
	{ id: 'DHL快递', text: 'DHL快递'},
	{ id: '大亿快递', text: '大亿快递'},
	{ id: 'TNT快递', text: 'TNT快递'},
	{ id: 'FedEx快递', text: 'FedEx快递'}
	]},"validate":{"required":true}},
{"display":"快递费","name":"Fees","newline":true,"labelWidth":100,"width":220,"space":30,"type":"number","validate":{"required":true}},
{"display":"取件人","name":"Geter","newline":true,"labelWidth":100,"width":220,"space":30,"type":"text"},
{"display":"取件日期","name":"GetDate","newline":true,"labelWidth":100,"width":220,"space":30,"type":"date","validate":{"required":true}},
{"display":"备注","name":"memo","newline":true,"labelWidth":100,"width":220,"space":30,"type":"textarea"}
	       ],
		 toJSON:JSON2.stringify
        });
        $.ligerui.get("Sendbmer").openSelect({
            grid:{ 
           columns: [
            {display:"部门编号",name:"id",width:150,type:"text",align:"left"},
            {display:"部门名称",name:"text",width:150,type:"text",align:"left"}
          ],
           dataAction: 'server', record : 'total',usePager :false,
           url:  '../Include/UseData.asp?ProcessType=departments', checkbox: false
           },
            search:{
		        fields:[
                    {display:"部门名称",name:"fname",newline:true,labelWidth:100,width:220,space:30,type:"text",cssClass:"field"}
                ]
            },  
            valueField:'id',textField:'text',top:90
        });

        //客户 在弹出grid中选择
        $.ligerui.get("Senderer").openSelect({
            grid:{ 
           columns: [
            {display:"部门编号",name:"pId",width:150,type:"text",align:"left"},
            {display:"部门名称",name:"pName",width:150,type:"text",align:"left"},
            {display:"工号",name:"id",width:150,type:"text",align:"left"},
            {display:"姓名",name:"text",width:150,type:"text",align:"left"}
          ],
           dataAction: 'server', record : 'total',pageSize:30,pageSizeOptions:[10, 20, 30, 40, 50],
           url:  '../Include/UseData.asp?ProcessType=EmpGrid', sortName: 'pId asc,id ' , checkbox: false
           },
					 onseled:function(rowdata){
//							if($('#Sendbm').val()==""){
//								$('#Sendbm').val(rowdata.pId);
//								$('#Sendbmer').val(rowdata.pName);
//							}
						},
            search:{
		        fields:[
                    {display:"姓名或工号",name:"text",newline:true,labelWidth:100,width:220,space:30,type:"text",cssClass:"field"}
                ]
            },  
            valueField:'id',textField:'text',top:90
        });

        var actionRoot = "ExpressDt.asp";
        if(isEdit){ 
					mainform.attr("action", "ExpressDt.asp?ProcessType=SaveEdit"); 
        }
        if (isAddNew) {
					$.ligerui.get('SendDate').setValue(new Date());
					$.ligerui.get('GetDate').setValue(new Date());
            mainform.attr("action", "ExpressDt.asp?ProcessType=SaveAdd"); 
        }
        else { 
            LG.loadForm(mainform, { ashxUrl:"../MANA/ExpressDt.asp?",type: 'getDt', data: { SerialNum: SerialNum} },f_loaded);
        }  

        if(!isView) 
        {
            //验证
            jQuery.metadata.setType("attr", "validate"); 
            LG.validate(mainform);
        } 

		function f_loaded()
        {
						$.ligerui.get("Senderer").loadText({view:'Emps',idfield:'code',textfield:'text'});
						$.ligerui.get("Sendbmer").loadText({view:'department',idfield:'fnumber',textfield:'text'});
            if(!isView){
							 return; 
						}
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
										win.LG.closeAndReloadParent(null, "98");
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
