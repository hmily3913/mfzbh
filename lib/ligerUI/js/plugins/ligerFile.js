/**
 * Created by IntelliJ IDEA.
 * User: anglny
 * Date: 12-7-12
 * Time: 下午5:39
 * To change this template use File | Settings | File Templates.
 */

(function ($){
    $.fn.ligerFile = function ()
    {
        return $.ligerui.run.call(this, "ligerFile", arguments);
    };

    $.fn.ligerGetFileManager = function ()
    {
        return $.ligerui.run.call(this, "ligerGetFileManager", arguments);
    };

    $.ligerDefaults.File = {
        emptyFn : function(){},
        isMultiple : !1 ,//是否允许多个上传项目
        isPic : !1 ,  ///是否图片
        defaultPic : '' , //默认的图片路径
        //图片点击事件
        onPictureClick : this.emptyFn
    };

    $.ligerui.controls.File = function (element, options)
    {
        $.ligerui.controls.File.base.constructor.call(this, element, options);
    };

    $.ligerui.controls.File.ligerExtend($.ligerui.controls.Input, {
        __getType: function ()
        {
            return 'File'
        },
        __idPrev: function ()
        {
            return 'File';
        },
        _init: function ()
        {
            $.ligerui.controls.File.base._init.call(this);
            var g = this, p = this.options;
            if (!p.width)
            {
                p.width = $(g.element).width();
            }
            if ($(this.element).attr("readonly"))
            {
                p.disabled = true;
            }
        },
        _render: function ()
        {
            var g = this, p = this.options;
            g.inputText = $(this.element);
            //外层
            g.wrapperText = g.inputText.wrap('<div class="l-text" style="float: left;"></div>').parent();
            g.wrapper = g.wrapperText.wrap('<div class="l-text-file"></div>').parent();
            g.wrapperText.append('<div class="l-text-l"></div><div class="l-text-r"></div>');
            g.wrapper.append(g.inputText)
            g.inputText.addClass("l-text-field-file")
            g.wrapper.append('<div class="l-toolbar-item l-panel-btn l-button-file" style="float: right; margin-top: 0px!important;"><span></span><div class="l-panel-btn-l"></div><div class="l-panel-btn-r"></div></div>')
            g.fielList = $("<div style='clear: both;'><ul class='file-item'></ul></div>")
            g.wrapper.append(g.fielList)
            $("span:first" , g.wrapper).html("上传")
            g.inputText.change(function(e){
                !p.isMultiple && g.wrapperText.html($(this).val())
                p.isMultiple && g._changeValue($(this))
            })
            g.set(p);
            if(p.width){
                g.wrapper.css({
                    "width" : p.width+"px"
                })
                g.inputText.css({
                    "width" : p.width+"px"
                })
                g.wrapperText.css({
                    width : p.width-70 + "px" ,
                    position : 'absolute'
                })
            }
        },
        _changeValue : function(obj) {
            var g = this, p = this.options;
            var item = $('<li><div style="position:absolute"><samp></samp></div></li>');
            $("samp" , item).html(obj.val())
            var s = obj.clone(true);
            obj.after(s);
            s.attr('name',g._buildFileName(s.attr("name")))
            item.append(obj);
            obj.hide();
            !p.isPic && item.css({
                "width" : (p.width-7)+"px",
                "height":"20px",
                "margin-top" : "3px",
                "border" : '#ccc 1px solid'
            })
            $("ul",g.fielList).append(item)
            $('.file-item li img' ,g.fielList ).animate({'opacity' : 0.5}).hover(function() {
                obj.animate({'opacity' : 1});
            }, function() {
                obj.animate({'opacity' : 0.5});
            });
            $('.file-item li',g.fielList).hover(function(){
                $("div.delete" , $(this)).length===0 && $("div",$(this)).append("<div class='delete'/>")
                $("div.delete",$(this)).click(function(){
                    $('.file-item li img' ,g.fielList ).stop();
                    var o = $(this).parent().parent();
                    o.stop().slideUp(300,function(){
                        o.remove()
                    })
                })
            },function(){
                $("div.delete" , $(this) ).length>0 && $("div.delete",$(this)).remove();
            })
        },
        _setValue: function (value){
            var g = this, p = this.options;
            if (value != null && $.isArray(value) ){
                $.each(value,function(){
                    g._builderValue(g,p,this)
                })
                g.fileValue = $("<input type='hidden' name='_deleteFileID'/>") ;
                g.fielList.append(g.fileValue)
                $('.file-item li img' ,g.fielList ).animate({'opacity' : 0.5}).hover(function() {
                    obj.animate({'opacity' : 1});
                }, function() {
                    obj.animate({'opacity' : 0.5});
                });
                $('.file-item li',g.fielList).hover(function(){
                    $("div.delete" , $(this)).length===0 && $("div",$(this)).append("<div class='delete'/>")
                    $("div.delete",$(this)).click(function(){
                        g.fileValue.val(g.fileValue.val() + $("samp",$(this).parent()).attr("id")+"_")
                        $('.file-item li img' ,g.fielList ).stop();
                        var o = $(this).parent().parent();
                        o.stop().slideUp(300,function(){
                            o.remove()
                        })
                    })
                },function(){
                    $("div.delete" , $(this) ).length>0 && $("div.delete",$(this)).remove();
                })
            }
        },
        _builderValue : function(g,p , o) {
            var item = $('<li><div style="position:absolute"><samp></samp></div></li>');
            $("samp" , item).html(o['attachName']).attr("id",o['attachId'])
            !p.isPic && item.css({
                "width" : (p.width-7)+"px",
                "height":"20px",
                "margin-top" : "3px",
                "border" : '#ccc 1px solid'
            })
            $("ul",g.fielList).append(item)
        },
        _buildFileName : function(n){
            if(n==='') return 'file(0)'
            var reg = /^(\w+)\((.*)\)/
            var bz = n.replace(reg,"$1,$2");
            var names = bz.split(",");
            var nn = names.length> 1 ?  names[0] +"("+  ++names[1] +")" : names[0]+"(0)"
            return nn;
        }
    })


})(jQuery);