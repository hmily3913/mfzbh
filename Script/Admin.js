
//check if the next sibling node is an element node

function get_nextsibling(n)
  {
  var x=n.nextSibling;
  while (x.nodeType!=1)
   {
   x=x.nextSibling;
   }
  return x;
  }
function get_previousSibling(n)
  {
  var x=n.previousSibling;
  while (x.nodeType!=1)
   {
   x=x.previousSibling;
   }
  return x;
  }

//改变管理位置标记--------------------------------------------------------------
function changeAdminFlag(Content){
   var row=parent.parent.headFrame.document.all.Trans.rows[0];
   row.cells[3].innerHTML = Content ;
   return true;
}

//通用选择删除条目（反选-全选）--------------------------------------------------------
function CheckOthers(form)
{
   for (var i=0;i<form.elements.length;i++)
   {
      var e = form.elements[i];
      if (e.checked==false)
      {
	     e.checked = true;
      }
      else
      {
	     e.checked = false;
      }
   }
}

function CheckAll(form)
{
   for (var i=0;i<form.elements.length;i++)
   {
      var e = form.elements[i];
      e.checked = true;
   }
}

//检验输入字符的有效性（0-9，a-z,-,_）-------------------------------------------
function voidNum(argValue) 
{
   var flag1=false;
   var compStr="1234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_-";
   var length2=argValue.length;
   for (var iIndex=0;iIndex<length2;iIndex++)
   {
	   var temp1=compStr.indexOf(argValue.charAt(iIndex));
	   if(temp1==-1) 
	   {
	      flag1=false;
			break;							
	   }
	   else
	   { flag1=true; }
   }
   return flag1;
} 
//验证数字的有效性
function checkNum(textId) {
 var num;
 num = textId.value;
 var re = /^(-?\d+)(\.\d+)?$/;   //判断字符串是否为数字 
     //判断正整数 /^[1-9]+[0-9]*]*$/  
     if (!re.test(num))
    {
        alert("请输入数字(例:1.01)");
		textId.value=0;
        textId.focus();
        return false;
     }
	 	return true;
}
//正整数检查
function checkInt(textId){
 var num;
 num = textId.value;
 var re = /^-?\d+$/;   //判断字符串是否为数字 
     //判断正整数 /^[1-9]+[0-9]*]*$/  
     if (!re.test(num))
    {
        alert("请输入整数(例:1)");
		textId.value=0;
        textId.focus();
        return false;
     }
	return true;
}
/**
 * 检查日期格式是否正确
 * 输入:str  字符串
 * 返回:true 或 flase; true表示格式正确
 * 注意：此处不能验证中文日期格式
 * 验证短日期（2007-06-05）
 */
function checkDate(obj){
	var str=obj.value;
	if (obj.value==''){
		return true;
	}else{
		//var value=str.match(/((^((1[8-9]\d{2})|([2-9]\d{3}))(-)(10|12|0?[13578])(-)(3[01]|[12][0-9]|0?[1-9])$)|(^((1[8-9]\d{2})|([2-9]\d{3}))(-)(11|0?[469])(-)(30|[12][0-9]|0?[1-9])$)|(^((1[8-9]\d{2})|([2-9]\d{3}))(-)(0?2)(-)(2[0-8]|1[0-9]|0?[1-9])$)|(^([2468][048]00)(-)(0?2)(-)(29)$)|(^([3579][26]00)(-)(0?2)(-)(29)$)|(^([1][89][0][48])(-)(0?2)(-)(29)$)|(^([2-9][0-9][0][48])(-)(0?2)(-)(29)$)|(^([1][89][2468][048])(-)(0?2)(-)(29)$)|(^([2-9][0-9][2468][048])(-)(0?2)(-)(29)$)|(^([1][89][13579][26])(-)(0?2)(-)(29)$)|(^([2-9][0-9][13579][26])(-)(0?2)(-)(29)$))/);
		var value = str.match(/^(\d{1,4})(-|\/)(\d{1,2})\2(\d{1,2})$/);
		if (value == null) {
			alert("时间错误，格式为：yyyy-mm-dd,注意闰年。");
			var myDate=new Date();
			obj.value=myDate.getFullYear()+"-"+(myDate.getMonth()+1)+"-"+myDate.getDate();
			obj.focus();
			return false;
		}
		else {
			var date = new Date(value[1], value[3] - 1, value[4]);
			return (date.getFullYear() == value[1] && (date.getMonth() + 1) == value[3] && date.getDate() == value[4]);
		}
	}
}
/**
 * 检查时间格式是否正确
 * 输入:str  字符串
 * 返回:true 或 flase; true表示格式正确
 * 验证时间(10:57:10)
 */
function checkTime(obj){
	var str=obj.value;
    var value = str.match(/^(\d{1,2})(:)?(\d{1,2})\2(\d{1,2})$/)
    if (value == null) {
		alert("时间错误，格式为：10:57:10。");
		var myDate=new Date();
		obj.value=myDate.toLocaleTimeString();
		obj.focus();
        return false;
    }
    else {
        if (value[1] > 24 || value[3] > 60 || value[4] > 60) {
			alert("时间错误，格式为：10:57:10。");
			var myDate=new Date();
			obj.value=myDate.toLocaleTimeString();
			obj.focus();
            return false
        }
        else {
            return true;
        }
    }
}

/**
 * 检查全日期时间格式是否正确
 * 输入:str  字符串
 * 返回:true 或 flase; true表示格式正确
 * (2007-06-05 10:57:10)
 */
function checkFullTime(obj){
	var str=obj.value;
	if (obj.value==''){
		return true;
	}else{
		var value = str.match(/^(?:19|20)[0-9][0-9]-(?:(?:0?[1-9])|(?:1[0-2]))-(?:(?:[0-2]?[1-9])|(?:[1-3][0-1])) (?:(?:[0-2]?[0-3])|(?:[0-1]?[0-9])):[0-5]?[0-9]:[0-5]?[0-9]$/);
		if (value == null) {
			alert("日期时间错误，格式为：(2007-06-05 10:57:10)。");
			var myDate=new Date();
			obj.value=myDate.getFullYear()+"-"+(myDate.getMonth()+1)+"-"+myDate.getDate()+" "+myDate.toLocaleTimeString();
			obj.focus();
			return false;
		}
		else {
			return true;
		}
	}
    //var value = str.match(/^(\d{1,4})(-|\/)(\d{1,2})\2(\d{1,2}) (\d{1,2}):(\d{1,2}):(\d{1,2})$/);
    
}

//检查用户登录------------------------------------------------------------------------------
function CheckAdminLogin()
{
   var check; 
   if (!voidNum(document.AdminLogin.LoginName.value))
   {
	  alert("请正确输入用户名称（由0-9,a-z,-_任意组合的字符串）。");
      document.AdminLogin.LoginName.focus();
	  return false;
	  exit;
   }    
   if (!voidNum(document.AdminLogin.LoginPassword.value))
   {
	  alert("请输入用户密码。");
	  document.AdminLogin.LoginPassword.focus();
	  return false;
	  exit;
   }
/*   if (!voidNum(document.AdminLogin.VerifyCode.value))
   {
      alert("请正确输入验证码。");
      document.AdminLogin.VerifyCode.focus();
	  return false;
	  exit;
   }*/
   return true;
}

//用户退出登录提示--------------------------------------------------------------------------
function AdminOut()
{
   if (confirm("您真的要退出管理操作吗？"))
   location.replace("CheckAdmin.asp?AdminAction=Out")
}
//跳转到第几页-------------------------------------------------------------------------------
function GoPage(Myself)
{
   window.location.href=Myself+"Page="+document.formDel.SkipPage.value;
}
function GoPagebySeach()
{
   window.location.href="PurviewSet.asp?seachname="+escape(document.formDel.seachname.value)+"&Page=1";
}
function GoPagebySeach_Flw()
{
   window.location.href="FLW_PurviewSet.asp?seachname="+escape(document.formDel.seachname.value)+"&Page=1";
}

/**
 * 分页导航条
 * 09/01/17
 * @author lym6520@qq.com 
 * @verson v2.0
 * @param {} fnName			翻页时执行的函数名(传入的第一个参数必须是“当前页码”）)
 * @param {} fnNameParams		fnName函数的参数，数组形式（比如：var arr = new Array(); arr[0] = 1;arr[1] = "hello"）
 * @param {} pagetotal			总页码
 * @param {} totalItem			总记录数
 * @param {} showID			页面显示分页导航条的div  ID
 */
function pageNavigation(fnName, fnNameParams, pagetotal, totalItem, showID) {   
    var fnParam = new Array();
    //如果这样 fnParam = fnNameParams;两个都指向同一引用
    for(var i = 0 ; i < fnNameParams.length; i++)
        fnParam[i] = fnNameParams[i];
           
     var pageIndex = parseInt(fnNameParams[0]);//当前页
       
    // 无记录  
    if (pagetotal == 0) {   
        $('#' + showID).empty();//清空翻页导航条   
        return;   
    }   
    // 分页   
    var front = pageIndex - 4;// 前面一截   
    var back = pageIndex + 4;// 后面一截   
    
    $('#' + showID).empty();//清空翻页导航条   
       
    // 页码链接   
    // 首页, 上一页   
    if (pageIndex == 1) {   
        $('#' + showID).append("首页 上一页 ");   
    } else {
        fnParam[0] = 1 ;
        var fn = fnName + "(" + fnParam + ")"; //组装执行的函数  
		var str = "<a href = 'javascript:" + fn + "'>首页</a> ";//创建连接
		$('#' + showID).append(str);
		
		fnParam[0] = pageIndex - 1 ;
	    var fn = fnName + "(" + fnParam + ")"; //组装执行函数         		
		var str = "<a href = 'javascript:" + fn + "'>上一页</a> ";//创建连接
		$('#' + showID).append(str);	         
    }   
  
    if (pagetotal == 1) {   
        $('#' + showID).append("1 ");   
    }   
    // 如果当前页是5,前面一截就是1234,后面一截就是6789   
    if (pagetotal > 1) {   
        var tempBack = pagetotal;   
        var tempFront = 1;   
        if (back < pagetotal)   
            tempBack = back;   
        if (front > 1)   

            tempFront = front;   
        for (var i = tempFront; i <= tempBack; i++) {   
            if (pageIndex == i) {   
                var str = " " + i + " ";   
                $('#' + showID).append(str);   
            } else {   
                fnParam[0] = i;
                var fn = fnName + "(" + fnParam + ")"; //组装执行的函数   
                var str = "<a href = 'javascript:" + fn + "'>[" + i + "]</a>";//创建连接   
                $('#' + showID).append(str);   
            }   
        }   
    }   
  
    // 下一页, 尾页   
    if (pageIndex == pagetotal) {   
        $('#' + showID).append("下一页 尾页 ");   
    } else {   
        fnParam[0] = pageIndex + 1 ;
        var fn = fnName + "(" + fnParam + ")"; //组装执行的函数   
        var str = " <a href = 'javascript:" + fn + "'>下一页</a> ";//创建连接   
        $('#' + showID).append(str);           
           
        fnParam[0] = pagetotal ;
        var fn = fnName + "(" + fnParam +  ")"; //组装执行的函数   
        var str = "<a href = 'javascript:" + fn + "'> 尾页 </a> ";//创建连接   
        $('#' + showID).append(str);           
    }   
       
    // 红色字体显示当前页   
    var str = "<font color = 'red'>" + pageIndex +"</font>";       
    $('#' + showID).append(str);   
       
    // 斜线"/"   
    $('#' + showID).append("/");   
       
    // 蓝色字体显示总页数   
    var str = "<font color = 'blue'>" + pagetotal +"</font>  ";      
    $('#' + showID).append(str);  
    var str = "跳到：第&nbsp;<input id='SkipPage' name='SkipPage' onKeyDown='if(event.keyCode==13)event.returnValue=false' style='HEIGHT: 18px;WIDTH: 30px;'  type='text' class='textfield' value='"+pageIndex+"'>&nbsp;页";
    $('#' + showID).append(str);  
	var fn = fnName + "(get_previousSibling(this).value)"; //组装执行的函数  
	var str="<input style='HEIGHT: 18px;WIDTH: 20px;' name='submitSkip' type='button' class='button' onClick='"+fn+"' value='GO'>";
    $('#' + showID).append(str);  
    var str = "&nbsp;共&nbsp;<font color = 'blue'>"+totalItem+"</font>&nbsp;条记录";      
    $('#' + showID).append(str);  
    //跳转到指定页
}

  Date.prototype.dateDiff = function(interval,objDate){
    //若參數不足或 objDate 不是日期物件則回傳 undefined
    if(arguments.length<2||objDate.constructor!=Date) return undefined;
    switch (interval) {
      //計算秒差
      case "s":return parseInt((objDate-this)/1000);
      //計算分差
      case "n":return parseInt((objDate-this)/60000);
      //計算時差
      case "h":return parseInt((objDate-this)/3600000);
      //計算日差
      case "d":return parseInt((objDate-this)/86400000);
      //計算週差
      case "w":return parseInt((objDate-this)/(86400000*7));
      //計算月差
      case "m":return (objDate.getMonth()+1)+((objDate.getFullYear()-this.getFullYear())*12)-(this.getMonth()+1);
      //計算年差
      case "y":return objDate.getFullYear()-this.getFullYear();
      //輸入有誤
      default:return undefined;
    }
  }
function showdate(n)
{
	var uom = new Date();
	uom.setDate(uom.getDate()+n);
	uom = uom.getFullYear() + "-" + (uom.getMonth()+1) + "-" + uom.getDate();
	return uom;
}
