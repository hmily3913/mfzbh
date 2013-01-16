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
<script src="../lib/ligerUI/js/plugins/ligerGrid.js" type="text/javascript"></script>
<script language="javascript" src="../Script/LG.js"></script>
    <script src="../lib/json2.js" type="text/javascript"></script>
<script language="javascript" src="../Script/ligerui.expand.js"></script>
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
        <form id="mainform" method="post">
        <input type="hidden" name="OrderDetailData" id="HOrderDetailData" value="" />
        </form> 
     </div>
     <div title="明细信息" tabid="orders">
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
        var IsDetail = <%=request.QueryString("IsDetail") or 0 %>;
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
{"display":"工作名称","name":"WorkName","newline":true,"labelWidth":100,"width":220,"space":30,"type":"text","validate":{"required":true}},
{"display":"详细描述","name":"XQMS","newline":true,"labelWidth":100,"width":420,"space":30,"type":"textarea"},
{"display":"申请人","name":"Apply","newline":true,"labelWidth":100,"width":220,"space":30,"type":"select",comboboxName:"Applyer",options:{valueFieldID:"Apply"},"validate":{"required":true}},
{"display":"申请时间","name":"ApplyDate","newline":true,"labelWidth":100,"width":220,"space":30,"type":"date","validate":{"required":true}},
{"display":"计划完成时间","name":"PlanFDate","newline":true,"labelWidth":100,"width":220,"space":30,"type":"date"},
{"display":"实际完成时间","name":"ActFDate","newline":true,"labelWidth":100,"width":220,"space":30,"type":"text",disabled:true},
{"display":"进度","name":"CheckFlag","newline":true,"labelWidth":100,"width":220,"space":30,"type":"select","options":{
	valueFieldID:"CheckFlag","data": [{ id: '0', text: '未审核'},{ id: '1', text: '已审核'},{ id: '2', text: '进行中'}, { id: '3', text: '已完成'}]}},
{"display":"备注","name":"memo","newline":true,"labelWidth":100,"width":420,"space":30,"type":"textarea"}
	       ],
		 toJSON:JSON2.stringify
        });

        $.ligerui.get("Applyer").openSelect({
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
            search:{
		        fields:[
                    {display:"姓名或工号",name:"text",newline:true,labelWidth:100,width:220,space:30,type:"text",cssClass:"field"}
                ]
            },  
            valueField:'id',textField:'text',top:90
        });

        var actionRoot = "WorkDt.asp";
				$.ligerui.get('ActFDate').setDisabled();
				$.ligerui.get('CheckFlag').setDisabled();
        if(isEdit){ 
					if(IsDetail)
						mainform.attr("action", "WorkDt.asp?ProcessType=SaveDetail"); 
					else
            mainform.attr("action", "WorkDt.asp?ProcessType=SaveEdit"); 
        }
        if (isAddNew) {
            mainform.attr("action", "WorkDt.asp?ProcessType=SaveAdd"); 
        }
        else { 
            LG.loadForm(mainform, { ashxUrl:"../MANA/WorkDt.asp?",type: 'getDt', data: { SerialNum: SerialNum} },f_loaded);
        }  

        
          
        if(!isView) 
        {
            //验证
            jQuery.metadata.setType("attr", "validate"); 
            LG.validate(mainform);
        } 

		function f_loaded()
        {
					$.ligerui.get("Applyer").loadText({view:'Emps',idfield:'code',textfield:'text'});
					//显示床位信息；
					var tab = $("#tabcontainer").ligerTab();
					var orderDetailLoaded = false;
					tab.bind('afterSelectTabItem', function (tabid)
					{
							if (tabid != "orders" || orderDetailLoaded) return;
							orderDetailLoaded = true;
							var SerialNum = '<%= request.QueryString("SerialNum") %>';
							var where = { op: 'and', rules: [{ field: 'SerialNum', value: SerialNum, op: 'equal'}] };
							$("#ordergrid").ligerGrid({
						columns:
							[
							{ display: '主键', name: 'SerialNum', width: 50, type: 'int'},
							{ display: '工作内容', name: 'WorkText',"width":150, editor: { type: 'text' }},
							{ display: '开始时间', name: 'StartDate',"width":120,type:"date",format: 'yyyy-MM-dd hh:mm',dateFormat: 'yyyy-MM-dd hh:mm', editor: { type: 'date',ext:{showTime: true,"validate":{"required":true}}}},
							{"display":"结束时间","name":"EndDate","width":120,type:"date",format: 'yyyy-MM-dd hh:mm',dateFormat: 'yyyy-MM-dd hh:mm', editor: { type: 'date',ext:{showTime: true }}},
							{"display":"备注","name":"memo","width":180, editor: { type: 'text' }},
							{"display":"完成标志","name":"Flag","width":180, editor: { type: 'select',data:[{ id: '未完成', text: '未完成'},{ id: '完成', text: '完成'}]
							 }},
							{"display":"记录时间","name":"NotDate","width":120}
						],checkbox: false,enabledEdit: true, clickToEdit: true, isScroll: false, showToggleColBtn: false, 
						width: '100%',height:'100%',usePager:false,dataAction: 'server',
						url:  'WorkDt.asp?ProcessType=getText&SerialNum='+SerialNum , showTitle: false, columnWidth: 100
						 , headerRowHeight:20,frozen:false,toolbar: getTollbar()
							});
			
					});

            if(!isView) return; 
            //查看状态，控制不能编辑
            $("input,select,textarea",mainform).attr("readonly", "readonly");
        }
    function getTollbar()
    {
        var o = {
            text: '增加',
            img: '../lib/ligerUI/skins/icons/add.gif'
        };
        o.click = function ()
        {
					$.ligerui.get('ordergrid').addEditRow();
        };
        var itemDel = {
            text: '删除',
            img: '../lib/ligerUI/skins/icons/candle.gif'
        };
        itemDel.click = function ()
        {
            $.ligerui.get('ordergrid').deleteSelectedRow();
        };

        return { items: [o,{line: true},itemDel,{line: true}]};

    }
        function f_save()
        {
            if($.ligerui.get('ordergrid'))
            {
                //保存订单明细 表格的JSON  后台(AjaxOrderManage.AddOrders或UpdateOrders)可接收
								function f(n) {
										// Format integers to have at least two digits.
										return n < 10 ? '0' + n : n;
								}
                $("#HOrderDetailData").val(
									JSON.stringify($.ligerui.get('ordergrid').getChangedRows(), function (key, value) {
											return this[key] instanceof Date ?
													this[key].getFullYear()   + '-' +
                 f(this[key].getMonth() + 1) + '-' +
                 f(this[key].getDate())      + ' ' +
                 f(this[key].getHours())     + ':' +
                 f(this[key].getMinutes())   + ':000': value;
									})
								
//								JSON2.stringify($.ligerui.get('ordergrid').getChangedRows())
								);
            } 
            LG.submitForm(mainform, function (data) {
                var win = parent || window;
                if (data.status) {  
                    win.LG.showSuccess('保存成功', function () { 
//											win.LG.closeCurrentTab(null);
                        win.LG.closeAndReloadParent(null, "89");
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
