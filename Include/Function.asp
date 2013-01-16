<%
Sub SelPlay(strUrl,strWidth,StrHeight)
Dim Exts,isExt
If strUrl <> "" Then
    isExt = LCase(Mid(strUrl,InStrRev(strUrl, ".")+1))
Else
    isExt = ""
End If
Exts = "avi,wmv,asf,mov,rm,ra,ram"
If Instr(Exts,isExt)=0 Then
Response.write "非法视频文件"
Else
Select Case isExt
   Case "avi","wmv","asf","mov"
    Response.write "<EMBED id=MediaPlayer src="&strUrl&" width="&strWidth&" height="&strHeight&" loop=""false"" autostart=""true""></EMBED>"
   Case "mov","rm","ra","ram"
    Response.Write "<OBJECT height="&strHeight&" width="&strWidth&" classid=clsid:CFCDAA03-8BE4-11cf-B84B-0020AFBBCCFA>"
    Response.Write "<PARAM NAME=""_ExtentX"" VALUE=""12700"">"
    Response.Write "<PARAM NAME=""_ExtentY"" VALUE=""9525"">"
    Response.Write "<PARAM NAME=""AUTOSTART"" VALUE=""-1"">"
    Response.Write "<PARAM NAME=""SHUFFLE"" VALUE=""0"">"
    Response.Write "<PARAM NAME=""PREFETCH"" VALUE=""0"">"
    Response.Write "<PARAM NAME=""NOLABELS"" VALUE=""0"">"
    Response.Write "<PARAM NAME=""SRC"" VALUE="""&strUrl&""">"
    Response.Write "<PARAM NAME=""CONTROLS"" VALUE=""ImageWindow"">"
    Response.Write "<PARAM NAME=""CONSOLE"" VALUE=""Clip"">"
    Response.Write "<PARAM NAME=""LOOP"" VALUE=""0"">"
    Response.Write "<PARAM NAME=""NUMLOOP"" VALUE=""0"">"
    Response.Write "<PARAM NAME=""CENTER"" VALUE=""0"">"
    Response.Write "<PARAM NAME=""MAINTAINASPECT"" VALUE=""0"">"
    Response.Write "<PARAM NAME=""BACKGROUNDCOLOR"" VALUE=""#000000"">"
    Response.Write "</OBJECT>"
    Response.Write "<BR>"
    Response.Write "<OBJECT height=32 width="&strWidth&" classid=clsid:CFCDAA03-8BE4-11cf-B84B-0020AFBBCCFA>"
    Response.Write "<PARAM NAME=""_ExtentX"" VALUE=""12700"">"
    Response.Write "<PARAM NAME=""_ExtentY"" VALUE=""847"">"
    Response.Write "<PARAM NAME=""AUTOSTART"" VALUE=""0"">"
    Response.Write "<PARAM NAME=""SHUFFLE"" VALUE=""0"">"
    Response.Write "<PARAM NAME=""PREFETCH"" VALUE=""0"">"
    Response.Write "<PARAM NAME=""NOLABELS"" VALUE=""0"">"
    Response.Write "<PARAM NAME=""CONTROLS"" VALUE=""ControlPanel,StatusBar"">"
    Response.Write "<PARAM NAME=""CONSOLE"" VALUE=""Clip"">"
    Response.Write "<PARAM NAME=""LOOP"" VALUE=""0"">"
    Response.Write "<PARAM NAME=""NUMLOOP"" VALUE=""0"">"
    Response.Write "<PARAM NAME=""CENTER"" VALUE=""0"">"
    Response.Write "<PARAM NAME=""MAINTAINASPECT"" VALUE=""0"">"
    Response.Write "<PARAM NAME=""BACKGROUNDCOLOR"" VALUE=""#000000"">"
    Response.Write "</OBJECT>"
End Select
End If
End Sub

function StrReplace(Str)'表单存入替换字符
  if Str="" or isnull(Str) then 
    StrReplace=""
    exit function 
  else
    StrReplace=replace(str," ","&nbsp;") '"&nbsp;"
    StrReplace=replace(StrReplace,chr(13),"&lt;br&gt;")'"<br>"
    StrReplace=replace(StrReplace,"<","&lt;")' "&lt;"
    StrReplace=replace(StrReplace,">","&gt;")' "&gt;"
  end if
end function

function ReStrReplace(Str)'写入表单替换字符
  if Str="" or isnull(Str) then 
    ReStrReplace=""
    exit function 
  else
    ReStrReplace=replace(Str,"&nbsp;"," ") '"&nbsp;"
    ReStrReplace=replace(ReStrReplace,"<br>",chr(13))'"<br>"
    ReStrReplace=replace(ReStrReplace,"&lt;br&gt;",chr(13))'"<br>"
    ReStrReplace=replace(ReStrReplace,"&lt;","<")' "&lt;"
    ReStrReplace=replace(ReStrReplace,"&gt;",">")' "&gt;"
  end if
end function

function HtmlStrReplace(Str)'写入Html网页替换字符
  if Str="" or isnull(Str) then 
    HtmlStrReplace=""
    exit function 
  else
    HtmlStrReplace=replace(Str,"&lt;br&gt;","<br>")'"<br>"
  end if
end function

'================================================
'函数名：FormatDate
'作　用：格式化日期
'参　数：DateAndTime            (原日期和时间)
'       Format                 (新日期格式)
'返回值：格式化后的日期
'================================================
Function FormatDate(DateAndTime, Format)
  On Error Resume Next
  Dim yy,y, m, d, h, mi, s, strDateTime
  FormatDate = DateAndTime
  If Not IsNumeric(Format) Then Exit Function
  If Not IsDate(DateAndTime) Then Exit Function
  yy = CStr(Year(DateAndTime))
  y = Mid(CStr(Year(DateAndTime)),3)
  m = CStr(Month(DateAndTime))
  If Len(m) = 1 Then m = "0" & m
  d = CStr(Day(DateAndTime))
  If Len(d) = 1 Then d = "0" & d
  h = CStr(Hour(DateAndTime))
  If Len(h) = 1 Then h = "0" & h
  mi = CStr(Minute(DateAndTime))
  If Len(mi) = 1 Then mi = "0" & mi
  s = CStr(Second(DateAndTime))
  If Len(s) = 1 Then s = "0" & s
   
  Select Case Format
  Case "1"
    strDateTime = y & "-" & m & "-" & d & " " & h & ":" & mi & ":" & s
  Case "2"
    strDateTime = yy & m & d & h & mi & s
    '返回12位 直到秒 的时间字符串
  Case "3"
    strDateTime = yy & m & d & h & mi    
    '返回12位 直到分 的时间字符串
  Case "4"
    strDateTime = yy & "年 " & m & "月 " & d & "日 "
  Case "5"
    strDateTime = m & "-" & d
  Case "6"
    strDateTime = m & "/" & d
  Case "7"
    strDateTime = m & "月 " & d & "日 "
  Case "8"
    strDateTime = y & "年 " & m & "月 "
  Case "9"
    strDateTime = y & "-" & m
  Case "10"
    strDateTime = y & "/" & m
  Case "11"
    strDateTime = y & "-" & m & "-" & d
  Case "12"
    strDateTime = y & "/" & m & "/" & d
  Case "13"
    strDateTime = yy & "." & m & "." & d
  Case Else
    strDateTime = DateAndTime
  End Select
  FormatDate = strDateTime
End Function

'获取当前时间是第几周函数：
'程序代码
Function GetWeekNo(InputDate)
dim pytY,pytNewYear,pytNewYearWeek,pytAllDay,pytBanWeek,NumWeek,tempx
NumWeek = 0
pytY = Year(InputDate)
pytNewYear=pytY &"-1-1"
pytNewYearWeek = Weekday(pytNewYear)
pytAllDay = DateDiff("d",pytNewYear,InputDate)
pytBanWeek = 8-pytNewYearWeek
if pytBanWeek<7 Then
NumWeek = 1
pytAllDay = pytAllDay - pytBanWeek
end if
tempx = pytAllDay/7
tempx = -Int(-tempx)
NumWeek = NumWeek+tempx
GetWeekNo = NumWeek
end Function 

'指定周数的日期范围函数
'程序代码
'函数名 getDateRange 
'函数 index -数值型:指定周数 
Function getDateRange(byVal Index,byVal years) 
Dim CurDate, retDate, Days, retVal 
if years="" then
CurDate = CDate(Year(Date()) & "-1-1") 
else
CurDate = CDate(years & "-1-1") 
end if
if (WeekDay(CurDate)<>1) Then Index =Index-1 
Days=Index * 7 
retDate=DateAdd("d", (Days - 1), CurDate) 
if (retDate < CurDate) Then retDate=CurDate 
retDate=DateAdd("d", 1-Weekday(retDate), retDate) 
if (retDate< CurDate) then 
retVal=CurDate & "###" & DateAdd("d", 7, retDate) 
else 
retVal=DateAdd("d", 1, retDate) & "###" & DateAdd("d", 7, retDate) 
end if 
getDateRange = retVal 
End Function
'指定月数的日期范围函数
Function getDateRangebyMonth(Index) 
dim stryear,strmonth,edaynum
if Instr(Index,"#")>0 then
stryear=Split(Index,"#")(1)
strmonth=Split(Index,"#")(0)
else
strmonth=Index
stryear=Year(now())
end if
select case strmonth
	case 2
	  if ((stryear mod 4=0) and (stryear mod 100>0)) or (stryear mod 400=0) then
	    edaynum=29
	  else
	    edaynum=28
	  end if
    case 4
	  edaynum=30
    case 6
	  edaynum=30
    case 9
	  edaynum=30
    case 11
	  edaynum=30
	case else
	  edaynum=31
end select
getDateRangebyMonth=stryear&"-"&strmonth&"-1###"&stryear&"-"&strmonth&"-"&edaynum
End Function

Sub SendMail(ToEml,ToSubject,ToSerialNum,ToText,strAttachmentName)
  Const cdoSendUsingMethod="http://schemas.microsoft.com/cdo/configuration/sendusing" 
  Const cdoSendUsingPort=2 
  Const cdoSMTPServer="http://schemas.microsoft.com/cdo/configuration/smtpserver" 
  Const cdoSMTPServerPort="http://schemas.microsoft.com/cdo/configuration/smtpserverport" 
  Const cdoSMTPConnectionTimeout="http://schemas.microsoft.com/cdo/configuration/smtpconnectiontimeout" 
  Const cdoSMTPAuthenticate="http://schemas.microsoft.com/cdo/configuration/smtpauthenticate" 
  Const cdoBasic=1 
  Const cdoSendUserName="http://schemas.microsoft.com/cdo/configuration/sendusername" 
  Const cdoSendPassword="http://schemas.microsoft.com/cdo/configuration/sendpassword" 
  
  Dim objConfig 
  Dim objMessage  
  Dim Fields
  
  Set objConfig = Server.CreateObject("CDO.Configuration") 
  Set Fields = objConfig.Fields 
  
  With Fields 
  .Item(cdoSendUsingMethod) = cdoSendUsingPort 
  .Item(cdoSMTPServer) = "122.228.158.226"   
  .Item(cdoSMTPServerPort) = 25                  
  .Item(cdoSMTPConnectionTimeout) = 300     
  .Item(cdoSMTPAuthenticate) = 1 
  .Item(cdoSendUserName) = "admin"  
  .Item(cdoSendPassword) = "123456789"         
  .Update 
  End With 
  
  Set objMessage = Server.CreateObject("CDO.Message") 
  Set objMessage.Configuration = objConfig 
  
  With objMessage
  .BodyPart.Charset = "utf-8"                     
  .To = ToEml                                  
  .From = "administrator@loverdoor.cn"                       
  .Subject = ToSubject                
  .htmlBody = "单号为:"&ToSerialNum&",内容为："&ToText
	if strAttachmentName <> "" then 
		.AddAttachment strAttachmentName
	end if 
  .Send 
  End With 
  
  Set Fields = Nothing 
  Set objMessage = Nothing 
  Set objConfig = Nothing
End Sub

Function DataTypeName(TypeID)
    Dim DataType(), z
    ReDim DataType(2, 26)
    DataType(0, 0) = "image"
    DataType(1, 0) = 34
    DataType(2, 0) = "text"
    DataType(0, 1) = "text"
    DataType(1, 1) = 35
    DataType(2, 1) = "text"
    DataType(0, 2) = "uniqueidentifier"
    DataType(1, 2) = 36
    DataType(2, 2) = "text"
    DataType(0, 3) = "tinyint"
    DataType(1, 3) = 48
    DataType(2, 3) = "digits"

    DataType(0, 4) = "smallint"
    DataType(1, 4) = 52
    DataType(2, 4) = "digits"
    DataType(0, 5) = "int"
    DataType(1, 5) = 56
    DataType(2, 5) = "digits"
    DataType(0, 6) = "smalldatetime"
    DataType(1, 6) = 58
    DataType(2, 6) = "date"
    DataType(0, 7) = "real"
    DataType(1, 7) = 59
    DataType(2, 7) = "digits"
    DataType(0, 8) = "money"
    DataType(1, 8) = 60
    DataType(2, 8) = "number"
    DataType(0, 9) = "datetime"
    DataType(1, 9) = 61
    DataType(2, 9) = "date"
    DataType(0, 10) = "float"
    DataType(1, 10) = 62
    DataType(2, 10) = "number"
    DataType(0, 11) = "sql_variant"
    DataType(1, 11) = 98
    DataType(2, 11) = "text"
    DataType(0, 12) = "ntext"
    DataType(1, 12) = 99
    DataType(2, 12) = "text"
    DataType(0, 13) = "bit"
    DataType(1, 13) = 104
    DataType(2, 13) = "digits"
    DataType(0, 14) = "decimal"
    DataType(1, 14) = 106
    DataType(2, 14) = "number"
    DataType(0, 15) = "numeric"
    DataType(1, 15) = 108
    DataType(2, 15) = "number"
    DataType(0, 16) = "smallmoney"
    DataType(1, 16) = 122
    DataType(2, 16) = "number"
    DataType(0, 17) = "bigint"
    DataType(1, 17) = 127
    DataType(2, 17) = "digits"
    DataType(0, 18) = "varbinary"
    DataType(1, 18) = 165
    DataType(2, 18) = "bigint"
    DataType(0, 19) = "varchar"
    DataType(1, 19) = 167
    DataType(2, 19) = "text"
    DataType(0, 20) = "binary"
    DataType(1, 20) = 173
    DataType(2, 20) = "bigint"
    DataType(0, 21) = "char"
    DataType(1, 21) = 175
    DataType(2, 21) = "text"
    DataType(0, 22) = "timestamp"
    DataType(1, 22) = 189
    DataType(2, 22) = "text"
    DataType(0, 23) = "nvarchar"
    DataType(1, 23) = 231
    DataType(2, 23) = "text"
    DataType(0, 24) = "nchar"
    DataType(1, 24) = 239
    DataType(2, 24) = "text"
    DataType(0, 25) = "xml"
    DataType(1, 25) = 241
    DataType(2, 25) = "text"
    DataType(0, 26) = "sysname"
    DataType(1, 26) = 231
    DataType(2, 26) = "text"

    For z = 0 To 26
        If DataType(1, z) = TypeID Then
            DataTypeName = DataType(2, z)
            Exit Function
        End If
    Next
End Function

Function JsonStr(valueStr)
if isnull(valueStr) then
JsonStr=""
else
JsonStr=replace(replace(replace(replace(replace(replace(replace(valueStr,chr(92),"\\"),chr(10),"\n"),chr(13),"\r"),chr(34),"\"""),chr(9),"\t"),chr(39),"\"""),chr(47),"\/")
end if
End Function

Function parseJSON(str)
	Dim scriptCtrl
	If Not IsObject(scriptCtrl) Then
		Set scriptCtrl = Server.CreateObject("MSScriptControl.ScriptControl")
		scriptCtrl.Language = "JScript"
		scriptCtrl.AddCode "function ActiveXObject() {}" ' 覆盖 ActiveXObject
		scriptCtrl.AddCode "function GetObject() {}" ' 覆盖 ActiveXObject
		scriptCtrl.AddCode "Array.prototype.get = function(x) { return this[x]; }; var result = null;"
	End If
  On Error Resume Next
	scriptCtrl.ExecuteStatement "result = " & str & ";"
	Set parseJSON = scriptCtrl.CodeObject.result
  If Err Then
	Err.Clear
	Set parseJSON = Nothing
  End If
	If IsObject(scriptCtrl) Then Set scriptCtrl = Nothing
End Function
'Dim json
'json = "{a:""aaa"", b:{ name:""bb"", value:""text"" }, c:[""item0"", ""item1"", ""item2""]}"
'Set obj = parseJSON(json)
'Response.Write obj.a & "<br />"
'Response.Write obj.b.name & "<br />"
'Response.Write obj.c.length & "<br />"
'Response.Write obj.c.get(0) & "<br />"
'Set obj = Nothing

function getBillNo(TbName,NumBit,BillDt)
	dim Zb,Zc,Zd
	Zb=year(now())
	Zc=month(now())
	if Zc<10 then
		Zc="0"+cstr(Zc)
	end if
	Zd=day(now())
	if Zd<10 then
		Zd="0"+cstr(Zd)
	end if
	dim ZBillNo,rsBillno
	ZBillNo=right(cstr(Zb),2)+cstr(Zc)+cstr(Zd)
  set rsBillno = server.createobject("adodb.recordset")
  sql="select top 1 SerialNum from "&TbName&" where SerialNum like '"&ZBillNo&"%' order by SerialNum desc"
  rsBillno.open sql,conn,1,1
	if rsBillno.eof then
		getBillNo=ZBillNo+RIGHT("000000000000",NumBit-1)+"1"
	else
		getBillNo=rsBillno("SerialNum")+1
	end if
	rsBillno.close
	set rsBillno=nothing 
end function
function iif(bExp1,sVal1,sVal2)
	if (bExp1) then
		iif=sval1
	else
		iif=sval2
	end if
end function
Function Getmid(sstr, lstr, rstr)
l = InStr(1, sstr, lstr) + Len(lstr)
s = Right(sstr, Len(sstr) - l + 1)
R = InStr(1, s, rstr)
Getmid = Mid(sstr, l, R - 1)
End Function
%>
