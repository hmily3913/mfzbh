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
        var EditAll = <%=request.QueryString("EditAll") or 0 %>;
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
{"display":"车牌","name":"chepai","newline":true,"labelWidth":100,"width":220,"space":30,"type":"select","validate":{"required":true},options:{
                width: 220,
                slide: false,
                selectBoxWidth: 220,
								hideOnLoseFocus :true,
                selectBoxHeight: 200, valueField: 'car_brand', textField: 'car_brand',valueFieldID:"chepai",
                grid: {
									columns: [
									{ display: '车牌', name: 'car_brand', align: 'left', width: 100, minWidth: 60 },
									{ display: '里程数', name: 'mileage_numeric', width: 60 },
									{ display: '费用标准', name: 'exes_standard', width: 60 }
									], switchPageSizeApplyComboBox: false,
									usePager:false,
									dataAction: 'server',
									url:  'ChucheDt.asp?ProcessType=CarList',
									checkbox: false
							}
            },"group":"出发信息","groupicon":groupstr},
{"display":"出发时间","name":"cfsj","newline":false,"labelWidth":100,"width":220,"space":30,options:{ showTime: true},"type":"date","validate":{"required":true}},
{"display":"出发公里表","name":"cflcs","newline":true,"labelWidth":100,"width":220,"space":30,"type":"number",options:{disabled:true}},
{"display":"使用人","name":"syr","newline":false,"labelWidth":100,"width":220,"space":30,"type":"select",comboboxName:"syrer",options:{valueFieldID:"syr"},"validate":{"required":true}},
{"display":"使用部门","name":"ycbm","newline":true,"labelWidth":100,"width":220,"space":30,"type":"select",comboboxName:"ycbmer",options:{valueFieldID:"ycbm"},"validate":{"required":true}},
{"display":"驾驶员","name":"jsy","newline":false,"labelWidth":100,"width":220,"space":30,"type":"select",comboboxName:"jsyer",options:{valueFieldID:"jsy"},"validate":{"required":true}},
{"display":"事由及目的地","name":"syjmdd","newline":true,"labelWidth":100,"width":220,"space":30,"type":"text","validate":{"required":true}},
{"display":"费用类别","name":"fylb","newline":false,"labelWidth":100,"width":220,"space":30,"type":"select","options":{
	valueFieldID:"fylb","initValue":'公司',"initText":'公司',"data": [{ id: '公司', text: '公司'}, { id: '委外', text: '委外'}]}},
{"display":"回来时间","name":"hlsj","newline":true,"labelWidth":100,"width":220,"space":30,"type":"date",options:{ showTime: true},"validate":{"required":true},"group":"回来信息","groupicon":groupstr},
{"display":"回来公里表","name":"hllcs","newline":false,"labelWidth":100,"width":220,"space":30,"type":"number"},
{"display":"使用公里数","name":"sylcs","newline":true,"labelWidth":100,"width":220,"space":30,"type":"number",disabled:true},
{"display":"费用金额","name":"fyje","newline":false,"labelWidth":100,"width":220,"space":30,"type":"number",disabled:true},
{"display":"车箱油量","name":"cxyl","newline":true,"labelWidth":100,"width":220,"space":30,"type":"select","options":{
	valueFieldID:"cxyl","data": [{ id: '1/3以上', text: '1/3以上'}, { id: '2/3以上', text: '2/3以上'}, { id: '满', text: '满'}, { id: '空', text: '空'}]},"group":"车辆检查","groupicon":groupstr},
{"display":"清洁卫生","name":"qjws","newline":false,"labelWidth":100,"width":220,"space":30,"type":"select","options":{
	valueFieldID:"qjws","data": [{ id: '干净', text: '干净'}, { id: '一般', text: '一般'}, { id: '脏', text: '脏'}]}},
{"display":"车体外观","name":"clwg","newline":true,"labelWidth":100,"width":220,"space":30,"type":"select","options":{
	valueFieldID:"clwg","data": [{ id: '完好', text: '完好'}, { id: '刮擦', text: '刮擦'}, { id: '破损', text: '破损'}, { id: '严重毁坏', text: '严重毁坏'}]}},
{"display":"钥匙归还时间","name":"ysghsj","newline":false,"labelWidth":100,"width":220,"space":30,options:{ showTime: true},"type":"date"},
{"display":"备注","name":"memo","newline":true,"labelWidth":100,"width":220,"space":30,"type":"textarea"}
	       ],
		 toJSON:JSON2.stringify
        });

        //客户 在弹出grid中选择
        $.ligerui.get("syrer").openSelect({
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
//							if($('#ycbm').val()==""){
//								$('#ycbm').val(rowdata.pId);
//								$('#ycbmer').val(rowdata.pName);
//							}
							if($('#jsy').val()==""){
								$('#jsy').val(rowdata.id);
								$('#jsyer').val(rowdata.text);
							}
//						 $('#ycbm').val(rowdata.pId);
//						 $.ligerui.get("ycbmer").updateStyle();
						},
            search:{
		        fields:[
                    {display:"姓名或工号",name:"text",newline:true,labelWidth:100,width:220,space:30,type:"text",cssClass:"field"}
                ]
            },  
            valueField:'id',textField:'text',top:90
        });
        $.ligerui.get("jsyer").openSelect({
            grid:{ 
           columns: [
            {display:"部门编号",name:"pId",width:150,type:"text",align:"left"},
            {display:"部门名称",name:"pName",width:150,type:"text",align:"left"},
            {display:"工号",name:"id",width:150,type:"text",align:"left"},
            {display:"姓名",name:"text",width:150,type:"text",align:"left"}
          ],
           dataAction: 'server', record : 'total',pageSize:30,pageSizeOptions:[10, 20, 30, 40, 50],
           url:  '../Include/UseData.asp?ProcessType=EmpGrid', sortName: 'pId' , checkbox: false
           },
            search:{
		        fields:[
                    {display:"姓名",name:"empname",newline:true,labelWidth:100,width:220,space:30,type:"text",cssClass:"field"}
                ]
            },  
            valueField:'id',textField:'text',top:90
        });
				
        $.ligerui.get("ycbmer").openSelect({
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
				
        var actionRoot = "ChucheDt.asp";
        if(isEdit){ 
					if(!EditAll){
						$.ligerui.get('chepai').setDisabled();
						$.ligerui.get('syrer').setDisabled();
						$.ligerui.get('ycbmer').setDisabled();
						$.ligerui.get('jsyer').setDisabled();
						$.ligerui.get('cfsj').setDisabled();
						$("#cflcs").attr("readonly", "readonly");
            mainform.attr("action", "ChucheDt.asp?ProcessType=SaveEdit"); 
					}else
						mainform.attr("action", "ChucheDt.asp?ProcessType=EditAll"); 
        }
        if (isAddNew) {
					$.ligerui.get('cfsj').setValue(new Date());
					$.ligerui.get('hlsj').setDisabled()
					$('#hlsj').removeAttr("validate");
					$("#hllcs").attr("readonly", "readonly");
						$("#cflcs").attr("readonly", "readonly");
            mainform.attr("action", "ChucheDt.asp?ProcessType=SaveAdd"); 
        }
        else { 
            LG.loadForm(mainform, { ashxUrl:"../MANA/ChucheDt.asp?",type: 'getDt', data: { SerialNum: SerialNum} },f_loaded);
        }  

				$.ligerui.get('chepai').gridManager.bind('SelectRow', function (rowdata){
						$('#cflcs').val(rowdata.mileage_numeric);
						$.ligerui.get('chepai').selectBox.hide();
				});        
/****
				$.ligerui.get('syrer').treeManager.bind('Select', function (node){
					if($('#ycbm').val()==""){
						$('#ycbm').val($.ligerui.get(this.id).getParent(node).id);
						$('#ycbmer').val($.ligerui.get(this.id).getParent(node).text);
					}
					if($('#jsy').val()==""){
						$('#jsy').val(node.data.id);
						$('#jsyer').val(node.data.text);
					}
						$.ligerui.get('syrer').selectBox.hide();
				});        
******/
				$.ligerui.get('hllcs').bind('changeValue', function (val){
					$('#sylcs').val(val-parseFloat($('#cflcs').val()));
				});
				$.ligerui.get('syjmdd').bind('changeValue', function (val){
					if(val.indexOf("私")>-1){
						$('#fylb').val("委外");
						$.ligerui.get('fylb').updateStyle();
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
						$.ligerui.get("syrer").loadText({view:'Emps',idfield:'code',textfield:'text'});
						$.ligerui.get("jsyer").loadText({view:'Emps',idfield:'code',textfield:'text'});
						$.ligerui.get("ycbmer").loadText({view:'department',idfield:'fnumber',textfield:'text'});
            if(!isView){
							if(!EditAll)$.ligerui.get('hlsj').setValue(new Date());
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
										win.LG.closeAndReloadParent(null, "49");
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
