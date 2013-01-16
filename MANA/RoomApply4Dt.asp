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
        var IsCheck = <%=request.QueryString("IsCheck") or 0 %>;

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
{"display":"职员","name":"Employee","newline":true,"labelWidth":100,"width":220,"space":30,"type":"select",options:{valueFieldID:"Employee"},comboboxName:"Employeer","validate":{"required":true}},
{"display":"床位","name":"BedSNum","newline":false,"labelWidth":100,"width":220,"space":30,"type":"select",options:{valueFieldID:"BedSNum"},comboboxName:"Bed","validate":{"required":true}},
{"display":"房客类型","name":"FKType","newline":true,"labelWidth":100,"width":220,"space":30,"type":"select","options":{
	valueFieldID:"FKType","data": [{ id: '内部员工', text: '内部员工'}, { id: '员工家属', text: '员工家属'}, { id: '公司客人', text: '公司客人'}]},"validate":{"required":true}},
{"display":"房客姓名","name":"FKName","newline":false,"labelWidth":100,"width":220,"space":30,"type":"text","validate":{"required":true}},
{"display":"房客性别","name":"FKSex","newline":true,"labelWidth":100,"width":220,"space":30,"type":"select","options":{
	valueFieldID:"FKSex","data": [{ id: '男', text: '男'}, { id: '女', text: '女'}]},"validate":{"required":true}},
{"display":"入住时间","name":"InDate","newline":false,"labelWidth":100,"width":220,"space":30,"type":"date",options:{ showTime: true},"validate":{"required":true}},
{"display":"押金","name":"Yajin","newline":true,"labelWidth":100,"width":220,"space":30,"type":"number"},
{"display":"是否寝室长","name":"Qsz","newline":false,"labelWidth":100,"width":220,"space":30,"type":"select","options":{
	valueFieldID:"Qsz","data": [{ id: '否', text: '否'}, { id: '是', text: '是'}]}},
{"display":"预计退房时间","name":"PlanOutDate","newline":true,"labelWidth":100,"width":220,"space":30,options:{ showTime: true},"type":"date"},
{"display":"退房时间","name":"OutDate","newline":true,"labelWidth":100,"width":220,"space":30,options:{ showTime: true},"type":"date"},
{"display":"备注","name":"memo","newline":true,"labelWidth":100,"width":320,"space":30,"type":"textarea"}
	       ],
		 toJSON:JSON2.stringify
        });

        $.ligerui.get("Employeer").openSelect({
            grid:{ 
           columns: [
            {display:"部门编号",name:"pId",width:150,type:"text",align:"left"},
            {display:"部门名称",name:"pName",width:150,type:"text",align:"left"},
            {display:"工号",name:"id",width:150,type:"text",align:"left"},
            {display:"姓名",name:"text",width:150,type:"text",align:"left"},
            {display:"性别",name:"sex",width:60,type:"text",align:"left"}
          ],
           dataAction: 'server', record : 'total',pageSize:30,pageSizeOptions:[10, 20, 30, 40, 50],
           url:  '../Include/UseData.asp?ProcessType=EmpGrid', sortName: 'pId asc,id ' , checkbox: false
           },
					 onseled:function(rowdata){
							if($('#FKName').val()==""){
								$('#FKType').val('内部员工');
								$('#FKName').val(rowdata.empname);
								$('#FKSex').val(rowdata.sex);
							}
						},
            search:{
		        fields:[
                    {display:"姓名或工号",name:"text",newline:true,labelWidth:100,width:220,space:30,type:"text",cssClass:"field"}
                ]
            },  
            valueField:'id',textField:'text',top:90
        });
        $.ligerui.get("Bed").openSelect({
            grid:{ 
           columns: [
{"display":"房间号","name":"RoomNo","width":80},
{"display":"床位号","name":"BedID","width":80},
{"display":"价格","name":"Price","width":80,type:"number"},
{"display":"押金","name":"Money","width":80,type:"number"},
{"display":"房间标准","name":"StandName","width":110},
{"display":"床位配置","name":"Chuangwei","width":100},
{"display":"人数","name":"PCount","width":60,type:"number"},
{"display":"入住资格","name":"Zige","width":80},
{"display":"用途类型","name":"UseType","width":80},
{"display":"楼层","name":"FLows","width":80},
{"display":"平方","name":"Mits","width":80,type:"number"}
          ],
           dataAction: 'server', record : 'total',pageSize:30,pageSizeOptions:[10, 20, 30, 40, 50],
           url:  'RoomApplyDt.asp?ProcessType=BedGrid', sortName: 'RoomNo asc,BedID ' , checkbox: false
           },
					 onseled:function(rowdata){
							if($('#Yajin').val()=="0"){
								$('#Yajin').val(rowdata.Money);
							}
						},
            search:{
		        fields:[
                    {display:"房间号",name:"RoomNo",newline:true,labelWidth:100,width:120,space:30,type:"text",cssClass:"field"},
                    {display:"房间标准",name:"StandName",newline:false,labelWidth:100,width:120,space:30,type:"select","options":{
	valueFieldID:"Zige","data": [{ id: '管理干部', text: '管理干部'}, { id: '专业技术管理员工', text: '专业技术管理员工'}, { id: '固定生产员工', text: '固定生产员工'}, { id: '临时生产员工', text: '临时生产员工'}, { id: '其他', text: '其他'}]},cssClass:"field"}
                ]
            },  
            valueField:'SerialNum',textField:'text',top:90
        });
        if(isEdit){ 
					if(IsCheck)mainform.attr("action", "RoomApplyDt.asp?ProcessType=Check"); 
          else mainform.attr("action", "RoomApplyDt.asp?ProcessType=SaveEdit"); 
        }
        if (isAddNew) {
					$.ligerui.get('InDate').setValue(new Date());
					$.ligerui.get('OutDate').setDisabled()
            mainform.attr("action", "RoomApplyDt.asp?ProcessType=SaveAdd"); 
        }
        else { 
            LG.loadForm(mainform, { ashxUrl:"RoomApplyDt.asp?",type: 'getDt', data: { SerialNum: SerialNum} },f_loaded);
        }  

        if(!isView) 
        {
            //验证
            jQuery.metadata.setType("attr", "validate"); 
            LG.validate(mainform);
        } 

		function f_loaded()
        {
					$.ligerui.get("Employeer").loadText({view:'Emps',idfield:'code',textfield:'text'});
					$.ligerui.get("Bed").loadText({view:'Beds',idfield:'b.SerialNum',textfield:'text'});
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
										win.LG.closeAndReloadParent(null, "83");
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
