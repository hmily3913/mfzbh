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
        <form id="mainform" method="post"></form> 
     </div>
     <div title="出车信息" tabid="orders">
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
	{"display":"序列号","name":"SerialNum","type":"hidden"},
	{"display":"车牌型号","name":"car_logo","newline":true,"labelWidth":100,"width":220,"space":30,"type":"text","validate":{"required":true},"group":"基本信息","groupicon":groupstr},
	{"display":"车牌号","name":"car_brand","newline":false,"labelWidth":100,"width":220,"space":30,"type":"text","validate":{"required":true,"minlength":3}},
	{"display":"车辆类型","name":"typename","newline":true,"labelWidth":100,"width":220,"space":30,"type":"select","options":{valueFieldID:"typename","data": [{ id: '货柜车', text: '货柜车' }, { id: '小轿车', text: '小轿车'}, { id: '商务车', text: '商务车'}, { id: '中巴', text: '中巴'}, { id: '大巴', text: '大巴'}]},"validate":{"required":true}},
	{"display":"费用归属","name":"fygs","newline":false,"labelWidth":100,"width":220,"space":30,"type":"select","options":{valueFieldID:"fygs","data": [{ id: '公司', text: '公司' }, { id: '个人', text: '个人'}]},"validate":{"required":true}},
{"display":"使用人","name":"userid","newline":true,"labelWidth":100,"width":220,"space":30,comboboxName:"empname","type":"select",options:{
		width: 220,
		selectBoxWidth: 220,
		valueFieldID:"userid",
		selectBoxHeight: 200, treeLeafOnly:true,
		onSelected: function (newvalue){alert(newvalue);},
		tree: { idFieldName:'id',parentIDFieldName:'pId',url: '../Include/UseData.asp?ProcessType=EmpData',checkbox: false }
}},
{"display":"当前公里数","name":"mileage_numeric","newline":false,"labelWidth":100,"width":220,"space":30,"type":"number"},
	{"display":"机动车证书","name":"machine_certificate","newline":true,"labelWidth":100,"width":220,"space":30,"type":"text"},
	{"display":"乘坐人数","name":"ride_number","newline":false,"labelWidth":100,"width":220,"space":30,"type":"digits"},
	{"display":"费用标准","name":"exes_standard","newline":true,"labelWidth":100,"width":220,"space":30,"type":"text","validate":{"required":true}},
	{"display":"是否启用","name":"status","newline":false,"labelWidth":100,"width":220,"space":30,"type":"select",comboboxName:"statusname","options":{valueFieldID:"status","initValue":'1',"initText":'是',"data": [{ id: '1', text: '是' }, { id: '0', text: '否'}]},"validate":{"required":true}},
	{"display":"出厂日期","name":"yield_date","newline":true,"labelWidth":100,"width":220,"space":30,"type":"date","group":"详细信息","groupicon":groupstr},
	{"display":"生产厂家","name":"yield_plant","newline":false,"labelWidth":100,"width":220,"space":30,"type":"text"},
	{"display":"登记日期","name":"enrol_date","newline":true,"labelWidth":100,"width":220,"space":30,"type":"date"},
	{"display":"购买日期","name":"buy_date","newline":false,"labelWidth":100,"width":220,"space":30,"type":"date"},
	{"display":"发动机号","name":"engine_id","newline":true,"labelWidth":100,"width":220,"space":30,"type":"text"},
	{"display":"车架号","name":"chassis_id","newline":false,"labelWidth":100,"width":220,"space":30,"type":"text"},
	{"display":"车身颜色","name":"car_color","newline":true,"labelWidth":100,"width":220,"space":30,"type":"text"},
	{"display":"轮胎规格","name":"type_spec","newline":false,"labelWidth":100,"width":220,"space":30,"type":"text"},
	{"display":"排气量","name":"up_cast","newline":true,"labelWidth":100,"width":220,"space":30,"type":"text"},
	{"display":"耗油量","name":"oilbox_capability","newline":false,"labelWidth":100,"width":220,"space":30,"type":"text"},
	{"display":"购买价格","name":"price","newline":true,"labelWidth":100,"width":220,"space":30,"type":"text"},
	{"display":"购置证号","name":"buy_id","newline":false,"labelWidth":100,"width":220,"space":30,"type":"text"},
	{"display":"汽油标号","name":"gas_grade","newline":true,"labelWidth":100,"width":220,"space":30,"type":"text"},
	{"display":"油箱容量","name":"oil_consume","newline":false,"labelWidth":100,"width":220,"space":30,"type":"text"},
	{"display":"年审日期","name":"year_check_date","newline":true,"labelWidth":100,"width":220,"space":30,"type":"date"},
	{"display":"到期预警提前","name":"day_count","newline":false,"labelWidth":100,"width":220,"space":30,"type":"digits"},
	{"display":"备注","name":"memo","newline":true,"labelWidth":100,"width":220,"space":30,"type":"textarea"}
	       ],
		 toJSON:JSON2.stringify
        });

        var actionRoot = "CarDt.asp";
        if(isEdit){ 
            $("#car_brand").attr("readonly", "readonly").removeAttr("validate");
            $("#mileage_numeric").attr("readonly", "readonly").removeAttr("validate");
            mainform.attr("action", "CarDt.asp?ProcessType=SaveEdit"); 
        }
        if (isAddNew) {
            mainform.attr("action", "CarDt.asp?ProcessType=SaveAdd"); 
        }
        else { 
            LG.loadForm(mainform, { ashxUrl:"../MANA/CarDt.asp?",type: 'getDt', data: { SerialNum: SerialNum} },f_loaded);
        }  

        
          
        if(!isView) 
        {
            //验证
            jQuery.metadata.setType("attr", "validate"); 
            LG.validate(mainform);
        } 

		function f_loaded()
        {
					//显示出车信息；
					var tab = $("#tabcontainer").ligerTab();
					var orderDetailLoaded = false;
					tab.bind('afterSelectTabItem', function (tabid)
					{
							if (tabid != "orders" || orderDetailLoaded) return;
							orderDetailLoaded = true;
							var chepai = '<%= request.QueryString("chepai") %>';
							var where = { op: 'and', rules: [{ field: 'chepai', value: chepai, op: 'equal'}] };
							$("#ordergrid").ligerGrid({
						columns: [
{"display":"车牌","name":"chepai","width":80},
{"display":"出发时间","name":"cfsj",type:"date","width":100},
{"display":"出发公里表","name":"cflcs",type:"number","width":60},
{"display":"使用人","name":"syrer","width":60},
{"display":"使用部门","name":"ycbmer","width":80},
{"display":"驾驶员","name":"jsyer","width":60},
{"display":"事由及目的地","name":"syjmdd","width":120},
{"display":"费用类别","name":"fylb","width":60},
{"display":"回来时间","name":"hlsj",type:"date","width":100},
{"display":"回来公里表","name":"hllcs",type:"number","width":60},
{"display":"使用公里数","name":"sylcs",type:"number","width":60},
{"display":"费用金额","name":"fyje","width":60},
{"display":"备注","name":"memo","width":120},
{"display":"登记人","name":"Biller","width":60},
{"display":"登记时间","name":"BillDate",type:"date","width":100}
],  
						dataAction: 'server',
						record : 'total',
						pageSize:30,
						checkbox: false,
						url:  'ChucheDt.asp?ProcessType=DetailsList',
						rownumbers:true,
						pageSizeOptions:[10, 20, 30, 40, 50],
						headerRowHeight:40,
						parms: { where: JSON2.stringify(where) },
						width: '100%',height:'100%'
							});
			
					});


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
                        win.LG.closeAndReloadParent(null, "39");
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
