/**
 * jQuery ligerUI 1.1.9
 *
 * http://ligerui.com
 *
 * Author daomi 2012 [ gd_star@163.com ]
 *
 */
(function ($)
{
    $.fn.ligerForm = function ()
    {
        return $.ligerui.run.call(this, "ligerForm", arguments);
    };

    $.ligerDefaults = $.ligerDefaults || {};
    $.ligerDefaults.Form = {
        //控件宽度
        inputWidth: 180,
        //标签宽度
        labelWidth: 90,
        //间隔宽度
        space: 40,
        rightToken: '：',
        //标签对齐方式
        labelAlign: 'left',
        //控件对齐方式
        align: 'left',
        //字段
        fields: [],
        //创建的表单元素是否附加ID
        appendID: true,
        //生成表单元素ID的前缀
        prefixID: "",
        //json解析函数
        toJSON: $.ligerui.toJSON ,
        autoCenter : true ,
        column :  2,
        isAjax :  !1,
        onSuccess : function() {} ,
        onInitialize : function() {} ,
        //加载数据路径
        loadURL : '' ,
        defaultEditorName : '__defaultEditorName__',
        defaultMultipleCls : 'default-multiple-ul',
        isMultiple : !1 , //多条记录编辑
        autoAdd :!0 ,  //是否自动增加
        loadSize :  0 , //加载数量
        isShow : !1 ,  //是否显示
        defaultLoadSize : 4,
        updateURL : ''

    };

    //@description 默认表单编辑器构造器扩展(如果创建的表单效果不满意 建议重载)
    //@param {jinput} 表单元素jQuery对象 比如input、select、textarea 
    $.ligerDefaults.Form.editorBulider = function (jinput, field)
    {
        this.buildData = function(j) {
            jinput.attr("stutaType") && Basic.request("/baseAction.do?method=showResult",{
                type :jinput.attr("stutaType")
            },function(dj){
                var data = Basic.unescapeArray(dj.data)
                inputOptions.data = data
                inputOptions.textField="statusName"
                inputOptions.valueField="statusCD"
                inputOptions.isMultiSelect = jinput.attr("isMultiSelect") || false;

                if(jinput.attr("lwidth") ){
                    
                    inputOptions.width = jinput.attr("lwidth")
                }
                var item = jinput.ligerComboBox(inputOptions);
                jinput.val() && item.setValue(jinput.val())
                g.items.push(item)
            } , this , !1);
            jinput.attr("lurl") &&  Basic.request(jinput.attr("lurl"),{},function(dj){
                var data = Basic.unescapeArray(dj.data)
                inputOptions.data = data
                var fd = jinput.attr("fieldData");
                if(!fd){
                    inputOptions.textField="TEXT"
                    inputOptions.valueField="ID"
                }else {
                    var _d = Basic.decode(fd);
                    $.extend(inputOptions , _d)
                }
                inputOptions.isMultiSelect = jinput.attr("isMultiSelect") || false;
                
                if(jinput.attr("lwidth")){
                    inputOptions.width = jinput.attr("lwidth")
                }
                var item = jinput.ligerComboBox(inputOptions);
                jinput.val() && item.setValue(jinput.val())
                g.items.push(item)
            } , this , !1);
        }
        //这里this就是form的ligerui对象
        var g = this, p = this.options;

        var attribute = jinput.attr('attribute');
        var js = Basic.decode(attribute)
        var inputOptions = js ||{};
        if (p.inputWidth) inputOptions.width = p.inputWidth;
        if (jinput.is("select"))
        {
            this.buildData(jinput);
            !jinput.attr("stutaType") && !jinput.attr("lurl") &&   g.items.push(jinput.ligerComboBox(inputOptions));
        }
        else if (jinput.is(":text") || jinput.is(":password") || (jinput.is(":hidden") && jinput.attr("ltype")==='html') )
        {
            var ltype = jinput.attr("ltype");
            if(jinput.attr('readOnly')){
                var txt = jinput.ligerTextBox();
                txt.setValue(jinput.attr("value"))
                txt.wrapper.addClass("l-txt-readOnly");
                txt.wrapper.removeClass("l-text-disabled")
                $(txt.element).removeClass("l-text-field")
                $(txt.element).addClass("l-text-field-readOnly")
                g.items.push(txt);
            }else{
                switch (ltype)
                {
                    case "select":
                    case "combobox":
                        this.buildData(jinput);
                        !jinput.attr("stutaType") && !jinput.attr("url") &&   g.items.push(jinput.ligerComboBox(inputOptions));
                        break;
                    case "text":
                        g.items.push(jinput.ligerTextBox(inputOptions));
                        break;
                    case "spinner":
                        g.items.push(jinput.ligerSpinner(inputOptions));
                        break;
                    case "date":
                        !WdatePicker && g.items.push(jinput.ligerDateEditor(inputOptions));
                        WdatePicker && g.items.push(jinput.ligerTextBox(inputOptions))
                        break;
                    case "float":
                    case "number":
                        inputOptions.number = true;
                        g.items.push(jinput.ligerTextBox(inputOptions));
                        break;
                    case "file" :
                        g.items.push(jinput.ligerFile());
                        break;
                    case "html" :
                        var editor,
                            config={
                                height:200,
                                uiColor:'#f3f3f3',
                                resize_enabled:false,
                                fontSize_defaultLabel:'12px',
                                fontSize_sizes:'',
                                font_names:'',
                                tabSpaces:4,
                                enterMode:CKEDITOR.ENTER_BR,
                                forcePasteAsPlainText:true
                            };
                        if(CKEDITOR){
                            var targ = CKEDITOR.appendTo( p.defaultEditorName, config, "");
                            if(!this.editor) this.editor={}
                            this.editor[jinput.attr("name")] = targ;
                        }
                        break;
                    case "int":
                    case "digits":
                        inputOptions.digits = true;
                        inputOptions.nullText = true;
                    default:
                        g.items.push(jinput.ligerTextBox(inputOptions));
                        break;
                }
            }

        }
        else if (jinput.is(":radio"))
        {
            g.items.push(jinput.ligerRadio(inputOptions));
        }
        else if (jinput.is(":checkbox"))
        {
            g.items.push(jinput.ligerCheckBox(inputOptions));
        }
        else if (jinput.is("textarea"))
        {
            jinput.wrap("<div></div>")
            jinput.addClass("l-textarea");
            g.items.push(jinput);
        }else if(jinput.is(":file")){
            inputOptions.isMultiple = jinput.attr("isMultiple")==="true";
            g.items.push(jinput.ligerFile(inputOptions))
        }

    }

    //表单组件
    $.ligerui.controls.Form = function (element, options)
    {
        $.ligerui.controls.Form.base.constructor.call(this, element, options);
    };

    $.ligerui.controls.Form.ligerExtend($.ligerui.core.UIComponent, {
        __getType: function ()
        {
            return 'Form'
        },
        __idPrev: function ()
        {
            return 'Form';
        },
        _init: function ()
        {
            $.ligerui.controls.Form.base._init.call(this);
        },
        _render: function ()
        {
            var g = this, p = this.options;
            var jform = $(this.element);
            if(p.isShow) {
                $(p.fields).each(function(i,f){
                    var targ = $(this)[0]
                    if(targ['type']!='hidden' ){
                        targ['type'] = 'text';
                        targ['readOnly'] = !0;

                    }
                })
            }
            //自动创建表单
            if (p.fields && p.fields.length)
            {
                if (!jform.hasClass("l-form"))
                    jform.addClass("l-form");
                this.w = 0;
                if(p.isMultiple) {
                    this.w = (p.inputWidth + p.space) * p.column - p.space
                }else {
                    this.w = (p.inputWidth  + p.labelWidth + p.space ) * p.column;
                }
                if(p.autoCenter){
                    jform.wrap("<div style='text-align:center'/>")
                    jform.css({
                        margin : "0 auto"  ,
                        width : this.w + "px"
                    })
                }
                var out = [];
                g.items = [] ;g.pks = [];g.events=[];g.isum = 0;
                var appendULStartTag = false , buttonsGrpup = false , temp = 0;;
                p.isMultiple && $(p.fields).each(function(i,field){ //先把label画出来
                    if (field.type == "hidden")
                    {
                        var name = field.name || field.id;
                        out.push('<input type="hidden" value="'+(field.value||'')+'" id="' + name + '" name="' + name + '" />');
                        return;
                    }
                    var newLine = field.renderToNewLine || field.newline;
                    if (newLine == null) newLine = true;
                    if (newLine && !buttonsGrpup )
                    {
                        if (appendULStartTag)
                        {
                            out.push('</ul>');
                            appendULStartTag = false;
                        }
                        if(field.type=='button' ||field.type==='buttons') buttonsGrpup=true;
                        if (field.group)
                        {
                            out.push('<div class="l-group');
                            if (field.groupicon)
                                out.push(' l-group-hasicon');
                            out.push('">');
                            if (field.groupicon)
                                out.push('<img src="' + field.groupicon + '" />');
                            out.push('<span>' + field.group + '</span></div>');
                        }
                        out.push('<ul>');
                        appendULStartTag = true;
                    }
                    out.push(g._buliderLabelContainer(field, i != p.fields.length -1));
                    field.pk && g.pks.push(i);
                    if(field.onchange)g.events[temp]=field.onchange;
                    temp++;
                })
                if (appendULStartTag)
                {
                    out.push('</ul>');
                    appendULStartTag = false;
                }
                if(p.isMultiple) {
                    for(var i = 0 ;i < p.defaultLoadSize ; i++) {
                        g._buildInput(p , out, appendULStartTag , buttonsGrpup , i);
                        this.maxulId = i ;
                    }
                } else g._buildInput(p , out, appendULStartTag , buttonsGrpup)
                p.buttons && $(p.buttons).each(function(i , f){
                    i===0 && out.push('<ul style="width:100%;text-align: center">');
                    f.hidden!=true && out.push(g._builderButtonContainer(f));
                    appendULStartTag = true;
                })
                if (appendULStartTag)
                {
                    out.push('</ul>');
                    appendULStartTag = false;
                }
                jform.append(out.join(''));
            }
            //生成ligerui表单样式
            $("input,select,textarea,file", jform).each(function (i)
            {
                p.editorBulider.call(g, $(this),p.fields[i]);
            });
            p.pkId && g._loadData();
            g._validate();
            p.isMultiple && g._initEvent(); //多数据时自定义事件
            p.onInitialize && p.onInitialize(); //初始化事件
        },
        _builder : function(){
            var g = this, p = this.options;
            var appendULStartTag = false , buttonsGrpup = false , out = [];
            var uls = $("ul."+ p.defaultMultipleCls,$(this.element));
            var maxul = uls[uls.length-1];
            g._buildInput(p , out, appendULStartTag , buttonsGrpup , ++this.maxulId)
            $(maxul).after(out.join(''))
            uls = $("ul."+ p.defaultMultipleCls,$(this.element));
            maxul = uls[uls.length-1];
            $("input,select,textarea,file", $(maxul)).each(function (i)
            {
                p.editorBulider.call(g, $(this),p.fields[i]);
            });
            $(":input",$(maxul)).change(function(){
                g.autoInsert()
                var indexer = g.getInputIndex($(this))
                g.events[indexer] && g.events[indexer].apply(g , [indexer , $(this) , $(this).parents("ul").find(":input")])
                if($(this).val().length > 0) g.isum ++ ;
                else g.isum-- ;
            }).keydown(function(event){
                if(event.keyCode==8){
                    if($(this).val()=='') {
                        var ul = $(this).parents("ul");
                        g.autoRemove(ul , $(this) , g.options)
                        return false;
                    }
                }
            })
        },
        _initEvent : function(){
            var g = this, p = this.options;
            $(":input",$('ul.'+ p.defaultMultipleCls)).change(function(){
                g.autoInsert();
                var indexer = g.getInputIndex($(this))
                g.events[indexer] && g.events[indexer].apply(g , [indexer , $(this) , $(this).parents("ul").find(":input")])
                if($(this).val().length > 0) g.isum ++ ;
                else g.isum-- ;
            }).keydown(function(event){
                if(event.keyCode==8){
                    if($(this).val()=='') {
                        var ul = $(this).parents("ul");
                        g.autoRemove(ul , $(this) , g.options)
                        return false;
                    }
                }
            })
        },
        autoInsert : function(){
            var g = this, p = this.options;
            for(var i = 0 , j = $('ul.'+ p.defaultMultipleCls).length ; i< j; i++){
                var input = $(":input" , $('ul.'+ p.defaultMultipleCls)[i]);
                var text=''
                if(g.pks.length>0) {
                    for(var z = 0 , k = g.pks.length ; z< k ; z++){
                        text = $(input[z]).val();
                        if(text=='') return;
                    }
                }else{
                    text = input.val();
                    if(text=='') return;
                }
            }
            g._builder();
        },
        getInputIndex : function(targ) {
            var ul = targ.parents("ul");
            var indexer = -1 ;
            ul.find('input').each(function(i, f){
                if($(this).attr('id')===targ.attr('id') ) {
                    indexer = i ;
                }
            });
            return indexer ;
        },
        autoRemove : function(ul,inp , p){
            var g = this;
            var uls = ul.siblings("."+p.defaultMultipleCls);
            if(uls.length> p.defaultLoadSize -1) {
                if(g.isValue($(":input",ul))){
                    var prInps = ul.prev().find(":input");
                    var prInp = $(prInps[prInps.length-1]);
                    var tx = prInp.val();prInp.val('');prInp.focus();prInp.val(tx)
                    var v = 0, v_ =0 ;
                    for(var i = 0 , j = $('ul.'+ p.defaultMultipleCls).length ; i< j; i++){
                        var input = $(":input" , $('ul.'+ p.defaultMultipleCls)[i]);
                        var text = '';
                        input.each(function(){
                            text = $(this).val();
                            if(text==='') v ++;
                            else v_++;
                        })
                    }
                    if(v>1) {
                        g.isum -=v_;
                        ul.remove();
                    }
                    return ;
                }
            }
            var prev ;
            ul.find('input').each(function(i, f){
                if($(this).attr('id')===inp.attr('id') ) {
                    if(prev){
                        var tx = prev.val();prev.val('');prev.focus();prev.val(tx)
                        return;
                    }else if(ul.prev && ul.prev().find(":input").length > 0) {
                        var prInps = ul.prev().find(":input");
                        var prInp = $(prInps[prInps.length-1]);
                        var tx = prInp.val();prInp.val('');prInp.focus();prInp.val(tx)
                    }
                }
                prev = $(this);
            })
        },
        isValue : function(inpts) {
            var txt = '' ;
            inpts.each(function(i, f){
                txt += $(this).val()
            })
            return txt===''
        },
        isValues : function(ul){
            return false;
        },
        _buildInput : function(p , out , appendULStartTag , buttonsGrpup , i) {
            var g = this;
            $(p.fields).each(function (index, field)
            {
                var name = field.name || field.id;
                if (!name && field.type!=='button' && field.type!=='buttons' && !field['el']) return;
                if (field.type == "hidden")
                {
                    !p.isMultiple && out.push('<input type="hidden" value="'+(field.value||'')+'" id="' + name + '" name="' + name + '" />');
                    return;
                }
                
                var newLine = field.renderToNewLine || field.newline;
                if (newLine == null) newLine = true;
                if (field.merge) newLine = false;
                if (field.group) newLine = true;
                if (newLine && !buttonsGrpup )
                {
                    if (appendULStartTag)
                    {
                        out.push('</ul>');
                        appendULStartTag = false;
                    }
                    if(field.type=='button' ||field.type==='buttons') buttonsGrpup=true;
                    if (field.group)
                    {
                        out.push('<div class="l-group');
                        if (field.groupicon)
                            out.push(' l-group-hasicon');
                        out.push('">');
                        if (field.groupicon)
                            out.push('<img src="' + field.groupicon + '" />');
                        out.push('<span>' + field.group + '</span></div>');
                    }
                    out.push('<ul');
                    p.isMultiple && out.push(" class='"+p.defaultMultipleCls+"' ")
                    out.push('>')
                    appendULStartTag = true;
                }
                if(field.type==='button') {
                    out.push(g._builderButtonContainer(field));
                } else if(field.type==='buttons'){

                }else{
                    var isEnd = index != p.fields.length -1 ;
                    //append label
                    !p.isMultiple && out.push(g._buliderLabelContainer(field));
                    //append input
                    out.push(g._buliderControlContainer(field , i));
                    //append space   。 计算是否需要后面的分隔符
                    //out.push(g._buliderSpaceContainer(field));
                    if(p.isMultiple){
                        (newLine || isEnd) && out.push(g._buliderSpaceContainer(field));
                    }else {
                        (newLine || isEnd) && out.push(g._buliderSpaceContainer(field));
                    }
                }
            });
            if (appendULStartTag)
            {
                out.push('</ul>');
                appendULStartTag = false;
            }
        },
        _validate : function() {
            var g = this, p = this.options;
            $(g.element).validate && $.metadata.setType("attr", "validate");
            $(g.element).validate &&  $(g.element).validate({
                ignore:'.test',
                errorPlacement: function (lable, element)
                {
                    if (element.hasClass("l-textarea"))
                    {
                        element.addClass("l-textarea-invalid");
                    }
                    else if (element.hasClass("l-text-field"))
                    {
                        element.parent().addClass("l-text-invalid");
                    }
                    $(element).removeAttr("title").ligerHideTip();
                    $(element).attr("title", lable.html()).ligerTip();
                },
                success: function (lable)
                {
                    var element = $("#" + lable.attr("for"));
                    if (element.hasClass("l-textarea"))
                    {
                        element.removeClass("l-textarea-invalid");
                    }
                    else if (element.hasClass("l-text-field"))
                    {
                        element.parent().removeClass("l-text-invalid");
                    }
                    $(element).removeAttr("title").ligerHideTip();
                },
                submitHandler: function (f)
                {
                    $("form .l-text,.l-textarea").ligerHideTip();
                    if(g.editor)
                        for(var i in g.editor)
                            if($("#"+i).length>0)
                                $("#"+i).val(g.editor[i].getData())
                    if(!p.isAjax){
                        f.submit()
                    }else{
                       $.ajaxFormTranscoding = true ;
                       $(f).ajaxSubmit({
                            async:true,
                            success:function(data){
                                var d = Basic.decode(data);
                                p.onSuccess(d);
                            }
                       })
                    }

                }

            })
            $.validator.addMethod("repeat" , function(v , e , p){
                var ul = $(e).parents("ul");
                if(g.isum== 0) return false;
                if(g.isValue(ul.find(":input"))) return true;
                else {
                    if(v!='') return true;
                }
                return false;
            })
        },
        _loadData : function() {
            var manager = $.ligerDialog.waitting('数据加载中,请稍候...');
            var g = this, p = this.options;
            $(this.element).append("<input type='hidden' name='id' value='"+p.pkId+"'/> ")
            p.loadURL && Basic.request(p.loadURL,{
                id :p.pkId
            },function(dj){
                var data = Basic.unescpeJson(dj.data);
                if(!p.isMultiple){
                    g._setValues(data);
                }else {
                    dj.data && g._setMultipLeDateValues(data,dj.data.length);
                }
                manager.close();
            } , g);
        },
        _setMultipLeDateValues : function(data , len){
            var g = this, p = this.options ;
            len = !p.isShow ? len + 1 : len;
            for(var i = p.defaultLoadSize ;i < len ; i++) {
                g._builder();
            }
            for(var i = 0 , j = $('ul.'+ p.defaultMultipleCls).length ; i< j; i++){
                var input = $(":input" , $('ul.'+ p.defaultMultipleCls)[i]);
                var d = Basic.unescpeJson(data[i]);
                input.each(function(i,f){
                    var name = $(this).attr("name") || $(this).attr("id");
                    if(name.indexOf("___")>-1) {
                        var n = name.split("___")[0];
                        $(this).val(d[n])
                    }
                })
            }
        },
        _setValues : function(data){
            var g = this;
            $.each(g.items,function(i,f){
                if(f.type){
                    f.setValue(data[f.id]);
                }if(f.type ==='File'){
                    var f_id = f.id.replace(/\(.*\)/ , '');
                    var f_Json = data[f_id];
                    var u_f_json = Basic.unescapeArray(f_Json);
                    f.setValue(u_f_json);
                }else if(f.attr && f.attr("name")) {
                    f.val && f.val(data[f.attr("name")])
                }
            })
        },
        //按钮事件
        _builderButtonContainer : function(f){
            var out=[];
            out.push("<input type='button'  value='"+f.display+"' id='"+f.id+"' class='l-button l-buttongroup'/>")
            return out.join('');
        },
        //标签部分
        _buliderLabelContainer: function (field,isEnd)
        {
            var g = this, p = this.options;
            var label = field.label || field.display;
            var labelWidth = 0 ;
            if(p.isMultiple && isEnd) {
                labelWidth = p.inputWidth + p.space
            }else labelWidth=field.labelWidth || field.labelwidth || p.labelWidth;
            var labelAlign = field.labelAlign || p.labelAlign;
            if(field.validate || field.pk)label+="<font color=red>*</font>"
            if (label) label+= p.rightToken;
            var out = [];
            out.push('<li style="');
            if (labelWidth)
            {
                out.push('width:' + labelWidth + 'px;');
            }
            if (labelAlign)
            {
                out.push('text-align:' + labelAlign + ';');
            }
            out.push('">');
            if (label)
            {
                out.push(label);
            }
            out.push('</li>');
            return out.join('');
        },
        //控件部分
        _buliderControlContainer: function (field , i)
        {
            var g = this, p = this.options;
            var width = field.width || p.inputWidth;
            var align = field.align || field.textAlign || field.textalign || p.align;
            var out = [];
            out.push('<li style="');
            if (width)
            {
                out.push('width:' + width + 'px;');
            }
            if (align)
            {
                out.push('text-align:' + align + ';');
            }
            out.push('">');
            out.push(g._buliderControl(field , i));
            out.push('</li>');
            return out.join('');
        },
        //间隔部分
        _buliderSpaceContainer: function (field)
        {
            var g = this, p = this.options;
            var spaceWidth = field.space || field.spaceWidth || p.space;
            var out = [];
            out.push('<li style="');
            if (spaceWidth)
            {
                out.push('width:' + spaceWidth + 'px;');
            }
            out.push('">');
            out.push('</li>');
            return out.join('');
        },
        _buliderControl: function (field , i)
        {
            var g = this, p = this.options;
            var width = field.width || p.inputWidth;
            var name = field.name || field.id;
            if(i!=undefined) name = name+"___" + i
            var out = [];
            if (field.comboboxName && field.type == "select")
            {
                out.push('<input type="hidden" stutaType="'+field.stutaType +'" id="' + p.prefixID + name + '" name="' + name + '" />');
            }
            if (field.textarea || field.type == "textarea")
            {
                out.push('<textarea style="width:'+(width-2)+'px;"');
            }
            else if(field.type==='html'){
                out.push("<div id='"+p.defaultEditorName+"'></div>")
                out.push("<input type='hidden' ")
            }
            else if (field.type == "checkbox")
            {
                out.push('<input type="checkbox" ');
            }
            else if (field.type == "radio")
            {
                out.push('<input type="radio" ');
            }
            else if (field.type == "password")
            {
                out.push('<input type="password" ');
            }
            else if(field.type==='button') {
                out.push('<input type="button" ')
            }else if(field.type==='file') {
                var isMultiple = field.isMultiple || !1;
                out.push("<input type='file'  isMultiple="+isMultiple + ' ');
            }else if(field.type==='date' &&  !field.readOnly  ){
                var dateFmt = field.dateFmt || 'yyyy-MM-dd HH:mm:ss'
                out.push('<input onfocus="WdatePicker({dateFmt:\''+dateFmt+'\',readOnly:true})\" class=\"NWdate\" type="text" ')
            } else if(field['el'] !== undefined){
                var el = $("#" + field['el']);
                var h = $.trim(el.attr("outerHTML")).replace("/>",'').replace(">",'')
                out.push(h)
                el.remove();
            }
            else
            {
                out.push('<input type="text" ');
            }
            if (field.cssClass)
            {
                out.push('class="' + field.cssClass + '" ');
            }
            if (field.type)
            {
                out.push('ltype="' + field.type + '" ');
            }
            if (field.width)
            {
                out.push('lwidth="' + field.width + '" ');
            }
            if(field.readOnly ) {
                var v = field.value || '';
                out.push('readOnly=' + (field.readOnly || !1) + ' value="'+v +'"')
            }
            if (field.attr)
            {
                for (var attrp in field.attr)
                {
                    out.push(attrp + '="' + field.attr[attrp] + '" ');
                }
            }
            if (field.comboboxName && field.type == "select")
            {
                out.push('name="' + field.comboboxName + '"');
                if (p.appendID)
                {
                    out.push(' id="' + p.prefixID + field.comboboxName + '" ');
                }
            }
            else if(field['el']===undefined)
            {
                out.push('name="' + name + '"');
                if (p.appendID)
                {
                    out.push(' id="' + name + '" ');
                }
            }
            //参数
            var fieldOptions = $.extend({
                width: width - 2
            }, field.options || {});
            out.push(" ligerui='" + p.toJSON(fieldOptions) + "' ");
            //验证参数
            if (field.validate)
            {
                out.push(" validate='" + p.toJSON(field.validate) + "' ");
            }
            out.push(' />');
            return out.join('');
        },
        _getField : function(i){
            if(!i) return ;
            var g = this ,items = $("ul",$(g.element));
            return items && $(items[i]) ;
        },
        removeField : function(i, b) {
            if(!i) return ;
            var g = this ,items = $("ul",$(g.element));
            if(b===undefined){
                if(items && items[i]){
                    g.deleteManagersId(items[i]);
                    $(items[i]).remove()
                }
            }else{
                if(items && items[i] && $("li",items[i]) && $("li",items[i]).length > 3 )
                    for(var j = 0 ; j < 3 ;j++ ){
                        g.deleteManagersId($($("li",items[i])[b*3]));
                        $($("li",items[i])[b*3]).remove();
                    }
            }
        },
        insertField : function(i , field) {
            var g = this  , out = [] , f = g._getField(i) , p = this.options;
            out.push(g._buliderLabelContainer(field));
            //append input
            out.push(g._buliderControlContainer(field));
            //append space
            out.push(g._buliderSpaceContainer(field));
            g._getField(i).append(out.join(''))
            $("input,select,textarea,file", f).each(function (i)
            {
                $(this).attr("name") ===field.name &&
                    p.editorBulider.call(g, $(this));
            });
        },
        deleteManagersId : function(f) {
            var id ;
            $("input,select,textarea,file", f).each(function (i){
                id = $(this).attr("name") || $(this).attr("id");
                if(id){
                    $.ligerui.remove(id);
                }
            })
        }
    });
})(jQuery);