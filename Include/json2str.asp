<script language="JScript" runat="Server">
function toArray(s){
    var dic = Server.CreateObject("Scripting.Dictionary")
    eval("var a=" + s);
    for(var i=0;i<a.length;i++){
        var obj = Server.CreateObject("Scripting.Dictionary")
        for(x in a[i]) obj.Add(x,a[i][x])
        dic.Add(i, obj);
    }
    return dic
}
function getvalues(i,fld,obj){
	return obj[i];
}
function getobjlen(obj){
	return obj.length;
}
function getjson(str){
  try{
   eval("var jsonStr = (" + str + ")");
  }catch(ex){
   var jsonStr = null;
  }
  return jsonStr;
}
function getwherestr(str){
	var jsonobj=getjson(str);
	return wherejson2str(jsonobj);
}
function wherejson2str(obj){
	var strwhere="(";
	for(var i=0;i<obj.rules.length;i++){
		if(i>0 )strwhere += " "+ obj.op+ " ";
		strwhere+=changeop(obj.rules[i]);//.field+" "+obj.rules[i].op+" "+obj.rules[i].value;
	}
	if(obj.groups==undefined){}
	else{
		for(var i=0;i<obj.groups.length;i++){
			strwhere+=" "+obj.op+" "+wherejson2str(obj.groups[i]);
		}
	}
	
	strwhere +=")";
	return strwhere;
}

function changeop(obj){
	/*
            "equal": "相等",
            "notequal": "不相等",
            "startwith": "以..开始",
            "endwith": "以..结束",
            "like": "相似",
            "greater": "大于",
            "greaterorequal": "大于或等于",
            "less": "小于",
            "lessorequal": "小于或等于",
            "in": "包括在...",
            "notin": "不包括...",
	*/
	switch (obj.op){
		case "equal":
			if(obj.type=="string"||obj.type=="text"){return " "+obj.field+" = '"+obj.value+"' ";}
			else if(obj.type=="number"||obj.type=="digits"){return " "+obj.field+" = "+obj.value+" ";}
			else if(obj.type=="date"){return " datediff(d,"+obj.field+",'"+obj.value+"')=0 ";}
			else{ return " "+obj.field+" = '"+obj.value+"' ";}
			break;
		case "notequal":
			if(obj.type=="string"||obj.type=="text"){return " "+obj.field+" <> '"+obj.value+"' ";}
			else if(obj.type=="number"||obj.type=="digits"){return " "+obj.field+" <> "+obj.value+" ";}
			else if(obj.type=="date"){return " datediff(d,"+obj.field+",'"+obj.value+"')<>0 ";}
			else{ return " "+obj.field+" <> '"+obj.value+"' ";}
			break;
		case "startwith":
			return " "+obj.field+" like '"+obj.value+"%' ";
			break;
		case "endwith":
			return " "+obj.field+" like '%"+obj.value+"' ";
			break;
		case "like":
			return " "+obj.field+" like '%"+obj.value+"%' ";
			break;
		case "greater":
			if(obj.type=="string"||obj.type=="text"){return " "+obj.field+" > '"+obj.value+"' ";}
			else if(obj.type=="number"||obj.type=="digits"){return " "+obj.field+" > "+obj.value+" ";}
			else if(obj.type=="date"){return " datediff(d,"+obj.field+",'"+obj.value+"')<0 ";}
			else{ return " "+obj.field+" > '"+obj.value+"' ";}
			break;
		case "greaterorequal":
			if(obj.type=="string"||obj.type=="text"){return " "+obj.field+" >= '"+obj.value+"' ";}
			else if(obj.type=="number"||obj.type=="digits"){return " "+obj.field+" >= "+obj.value+" ";}
			else if(obj.type=="date"){return " datediff(d,"+obj.field+",'"+obj.value+"')<=0 ";}
			else{ return " "+obj.field+" >= '"+obj.value+"' ";}
			break;
		case "less":
			if(obj.type=="string"||obj.type=="text"){return " "+obj.field+" < '"+obj.value+"' ";}
			else if(obj.type=="number"||obj.type=="digits"){return " "+obj.field+" < "+obj.value+" ";}
			else if(obj.type=="date"){return " datediff(d,"+obj.field+",'"+obj.value+"')>0 ";}
			else{ return " "+obj.field+" < '"+obj.value+"' ";}
			break;
		case "lessorequal":
			if(obj.type=="string"||obj.type=="text"){return " "+obj.field+" <= '"+obj.value+"' ";}
			else if(obj.type=="number"||obj.type=="digits"){return " "+obj.field+" <= "+obj.value+" ";}
			else if(obj.type=="date"){return " datediff(d,"+obj.field+",'"+obj.value+"')>=0 ";}
			else{ return " "+obj.field+" <= '"+obj.value+"' ";}
			break;
		case "in":
			if(obj.type=="string"||obj.type=="text"||obj.type=="date"){return " "+obj.field+" in ('"+obj.value+"') ";}
			else if(obj.type=="number"||obj.type=="digits"){return " "+obj.field+" in ("+obj.value+") ";}
			else{return " "+obj.field+" in ('"+obj.value+"') ";}
			break;
		case "notin":
			if(obj.type=="string"||obj.type=="text"||obj.type=="date"){return " "+obj.field+" not in ('"+obj.value+"') ";}
			else if(obj.type=="number"||obj.type=="digits"){return " "+obj.field+" not in ("+obj.value+") ";}
			else{return " "+obj.field+" not in ('"+obj.value+"') ";}
			break;
	}
}

</script>
