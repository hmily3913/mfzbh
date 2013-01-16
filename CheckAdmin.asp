<%
Response.Charset="utf-8"
'判断是否登录或登录超时===============================================================
dim AdminAction,sqlonline,rsonline
AdminAction=request.QueryString("AdminAction")
select case AdminAction
  case "Out"
    call OutLogin()
  case else
    call Login()
end select
sub Login()
  if session("UserName")="" or session("UserID")="" then
     response.write "[{""id"": ""1"", ""TreeUrl"": ""#"", ""PermissionID"": ""1"", ""name"": ""你没有任何权限，请联系管理员！"", ""pId"": ""0""}]"
     response.end
  end if
	'2012-06-12新增权限判定，根据网址判定
	Dim PDConn,PDConnStr
	On error resume next
	Set PDConn=Server.CreateObject("Adodb.Connection")
	PDConnStr="driver={SQL Server};server=10.0.0.121;UID=sa;PWD=mflogin;Database=XXPT"
	PDConn.open PDConnStr
	if err then
		 err.clear
		 Set PDConn = Nothing
		 response.Write("{""status"":false,""messages"":""系统错误：数据库连接出错，请检查'系统管理>>站点常量设置',请联系管理员!""}")
	'   Response.Write ""
		 Response.End
	end if
	dim PDrs,PDSql,PDid
	set PDrs = server.createobject("adodb.recordset")
	PDSql="select * from sys_Permission where TreeUrl='"&request.servervariables("PATH_INFO")&"'"
	'判断是否带参数，目前设置一个ProcessType参数作为权限控制参数。
	if request("ProcessType")<>"" then PDSql=PDSql&" and ProcessType='"&request("ProcessType")&"' "
	PDrs.open PDSql,PDconn,1,1
	if not PDrs.eof then
	'有权限控制的网址
		'取得权限ID
		PDid=PDrs("SerialNum")
		set PDrs = PDConn.Execute("select PID from sys_PermissionUse a,sys_Users b where a.GroupFlag=0 and a.UID=b.SerialNum and b.UserID='"&Session("UserID")&"' and PID="&PDid&" union select PID from sys_PermissionUse a,sys_Users b,sys_PermissionGroupDetails c where a.GroupFlag=1 and b.UserID='"&Session("UserID")&"' and c.UserID=b.UserID and a.UID=c.GroupSnum and PID="&PDid)
		if PDrs.eof then
			Set PDConn = Nothing
			response.Write("{""status"":false,""messages"":""你没有此权限，请联系管理员！""}")
			response.End()
		end if
	end if
	set PDrs=nothing
	set PDConn = Nothing
end sub
'========
sub OutLogin()
	conn.Execute ("update sys_Online set o_state=0 where UserName = '" &session("UserID")&"'")
	set conn=nothing
  session.contents.remove "UserName"
  session.contents.remove "UserID"
  session.contents.remove "GZSucces"
  response.write "<script language=javascript>top.location.replace('index.htm');</script>"
end sub

function CHKOnePermiss(sUrlVal,sPTypeVal)
	On error resume next
	Set PDConn=Server.CreateObject("Adodb.Connection")
	PDConnStr="driver={SQL Server};server=10.0.0.121;UID=sa;PWD=mflogin;Database=XXPT"
	PDConn.open PDConnStr
	if err then
		 err.clear
		 Set PDConn = Nothing
		 response.Write("{""status"":false,""messages"":""系统错误：数据库连接出错，请检查'系统管理>>站点常量设置',请联系管理员!""}")
	'   Response.Write ""
		 Response.End
	end if
	set PDrs = server.createobject("adodb.recordset")
	PDSql="select * from sys_Permission where TreeUrl='"&sUrlVal&"' and ProcessType='"&sPTypeVal&"' "
	PDrs.open PDSql,PDconn,1,1
	if not PDrs.eof then
	'有权限控制的网址
		'取得权限ID
		PDid=PDrs("SerialNum")
		set PDrs = PDConn.Execute("select PID from sys_PermissionUse a,sys_Users b where a.GroupFlag=0 and a.UID=b.SerialNum and b.UserID='"&Session("UserID")&"' and PID="&PDid&" union select PID from sys_PermissionUse a,sys_Users b,sys_PermissionGroupDetails c where a.GroupFlag=1 and b.UserID='"&Session("UserID")&"' and c.UserID=b.UserID and a.UID=c.GroupSnum and PID="&PDid)
		if PDrs.eof then
			CHKOnePermiss=false
		else
			CHKOnePermiss=true
		end if
	end if
	set PDrs=nothing
	set PDConn = Nothing
end function
'浏览器、操作系统版本侦测
function browser(text)
    if Instr(text,"MSIE 5.5")>0 then
        browser="IE 5.5"
    elseif Instr(text,"MSIE 8.0")>0 then
        browser="IE 8.0"
    elseif Instr(text,"MSIE 7.0")>0 then
        browser="IE 7.0"
    elseif Instr(text,"MSIE 6.0")>0 then
        browser="IE 6.0"
    elseif Instr(text,"MSIE 5.01")>0 then
        browser="IE 5.01"
    elseif Instr(text,"MSIE 5.0")>0 then
        browser="IE 5.00"
    elseif Instr(text,"MSIE 4.0")>0 then
        browser="IE 4.01"
        else
        browser="未知"
    end if
end function
function system(text)
    if Instr(text,"NT 5.1")>0 then
        system="Windows XP"
    elseif Instr(text,"NT 6.1")>0 then
        system="Windows  7"
    elseif Instr(text,"NT 6.0")>0 then
        system="Windows Vista/Server 2008"
    elseif Instr(text,"NT 5.2")>0 then
        system="Windows Server 2003"
    elseif Instr(text,"NT 5.1")>0 then
        system="Windows XP"
    elseif Instr(text,"NT 5")>0 then
        system="Windows 2000"
    elseif Instr(text,"NT 4")>0 then
        system="Windows NT4"
    elseif Instr(text,"4.9")>0 then
        system="Windows ME"
    elseif Instr(text,"98")>0 then
        system="Windows 98"
    elseif Instr(text,"95")>0 then
        system="Windows 95"
    elseif Instr(text,"Mac")>0 then
        system="Mac"
    elseif Instr(text,"Unix")>0 then
        system="Unix"
    elseif Instr(text,"Linux")>0 then
        system="Linux"
    elseif Instr(text,"SunOS")>0 then
        system="SunOS"
        else
        system="未知"
    end if
end function

%>