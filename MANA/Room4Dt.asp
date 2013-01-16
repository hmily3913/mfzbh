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
     <div title="住宿信息" tabid="orders">
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
{"display":"房间号","name":"RoomNo","newline":true,"labelWidth":100,"width":220,"space":30,"type":"text","validate":{"required":true},"groupicon":groupstr},
{"display":"价格","name":"Price","newline":false,"labelWidth":100,"width":220,"space":30,"type":"number"},
{"display":"房间标准","name":"SSNum","newline":true,"labelWidth":100,"width":220,"space":30,"type":"select",comboboxName:"SSNumer",options:{valueFieldID:"SSNum"},"validate":{"required":true}},
{"display":"床位配置","name":"Chuangwei","newline":false,"labelWidth":100,"width":220,"space":30,"type":"text"},
{"display":"人数","name":"PCount","newline":true,"labelWidth":100,"width":220,"space":30,"type":"digits","validate":{"required":true}},
{"display":"入住资格","name":"Zige","newline":false,"labelWidth":100,"width":220,"space":30,"type":"select","options":{
	valueFieldID:"Zige","data": [{ id: '管理干部', text: '管理干部'}, { id: '专业技术管理员工', text: '专业技术管理员工'}, { id: '固定生产员工', text: '固定生产员工'}, { id: '临时生产员工', text: '临时生产员工'}, { id: '其他', text: '其他'}]}},
{"display":"用途类型","name":"UseType","newline":true,"labelWidth":100,"width":220,"space":30,"type":"select","options":{
	valueFieldID:"UseType","data": [{ id: '内宿', text: '内宿'}, { id: '出租', text: '出租'}, { id: '其他', text: '其他'}]}},
{"display":"楼层","name":"FLows","newline":false,"labelWidth":100,"width":220,"space":30,"type":"digits"},
{"display":"平方","name":"Mits","newline":true,"labelWidth":100,"width":220,"space":30,"type":"number"},
{"display":"备注","name":"memo","newline":true,"labelWidth":100,"width":400,"space":30,"type":"textarea"}
	       ],
		 toJSON:JSON2.stringify
        });

        //房间标准 在弹出grid中选择
        $.ligerui.get("SSNumer").openSelect({
            grid:{ 
           columns: [
            {display:"房间标准",name:"StandName",width:110,type:"text",align:"left"},
            {display:"描述",name:"Miaoshu",width:580,type:"text",align:"left"},
            {display:"押金",name:"Money",width:60,type:"text",align:"left"}
          ],
           dataAction: 'server', usePager:false,
           url:  '../MANA/RoomDt.asp?ProcessType=getSSNum', checkbox: false
           },
					 onseled:function(rowdata){
						},
            valueField:'SerialNum',textField:'StandName',top:90
        });

        var actionRoot = "RoomDt.asp";
        if(isEdit){ 
            $("#car_brand").attr("readonly", "readonly").removeAttr("validate");
            mainform.attr("action", "RoomDt.asp?ProcessType=SaveEdit"); 
        }
        if (isAddNew) {
            mainform.attr("action", "RoomDt.asp?ProcessType=SaveAdd"); 
        }
        else { 
            LG.loadForm(mainform, { ashxUrl:"../MANA/RoomDt.asp?",type: 'getDt', data: { SerialNum: SerialNum} },f_loaded);
        }  

        
          
        if(!isView) 
        {
            //验证
            jQuery.metadata.setType("attr", "validate"); 
            LG.validate(mainform);
        } 

		function f_loaded()
        {
					$.ligerui.get("SSNumer").loadText({view:'RoomStas',idfield:'SerialNum',textfield:'StandName'});
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
							{ display: '床位号', name: 'BedID', editor: { type: 'text' } },
							{ display: '是否入住', name: 'deleteFlag',
                    render: function (item)
                    {
                        if (parseInt(item.deleteFlag) == 1) return '是';
                        return '否';
                    }
							},
							{ display: '房客类型', name: 'FKType'},
							{"display":"房客姓名","name":"FKName","width":80},
							{"display":"房客性别","name":"FKSex","width":60},
							{"display":"入住时间","name":"InDate",type:"date","width":100},
							{"display":"押金","name":"Yajin",type:"number","width":60},
							{"display":"寝室长","name":"Qsz","width":60},
							{"display":"预计退房时间","name":"PlanOutDate",type:"date","width":100}
						],checkbox: false,enabledEdit: true, clickToEdit: true, isScroll: false, showToggleColBtn: false, 
						width: '100%',height:'100%',usePager:false,dataAction: 'server',
						url:  'RoomDt.asp?ProcessType=getBeds&SerialNum='+SerialNum , showTitle: false, columnWidth: 100
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
                $("#HOrderDetailData").val(JSON2.stringify($.ligerui.get('ordergrid').getChangedRows()));
            } 
            LG.submitForm(mainform, function (data) {
                var win = parent || window;
                if (data.status) {  
                    win.LG.showSuccess('保存成功', function () { 
//											win.LG.closeCurrentTab(null);
                        win.LG.closeAndReloadParent(null, "75");
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
