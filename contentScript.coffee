App = {}
chrome.extension.onMessage.addListener (data,sender,callback)->
    if App.inited
        return
    App.inited = true
    if data is "init"
        tm = new Leaf.TemplateManager()
        tm.baseUrl = chrome.extension.getURL("template")+"/"
        tm.use "welcome-hint","preview-list"
        tm.start()
        tm.on "ready",(templates)=>
            App.templates = templates
            init()

init = ()->
    items = document.getElementsByTagName("*")
    for item in items
        $(item).mousemove ()->
            App.mouseMask.attachTo this
            App.mouseMask.show()
            return false
        $(item).click (e)->
            groups = App.selector.select(this)
            App.previewList.choose(groups)
            return false
    welcomeHint = new Leaf.Widget(App.templates["welcome-hint"])
    welcomeHint.appendTo document.body
    welcomeHint.node$.show()
    App.selector = new RssSelector()
    App.mouseMask = new DomMask()
    App.maskGroup = new MaskGroup()
    App.previewList = new PreviewList()
    App.previewList.appendTo document.body
    App.previewList.hide()
    App.previewList.__callback = (result)->
        if not result
            return
        console.log "result",result
class MaskGroup extends Leaf.EventEmitter
    constructor:()->
        @items = []
    add:(item)->
        @items.push item
        item.show()
    clear:()->
        for item in @items
            item.hide()
        @items.length = 0
class DomMask extends Leaf.Widget
    constructor:(node,@style)->
        super "<div class='dom-mask'></div>"
        if node
            @attachTo node

    attachTo:(node)->
        @target = node
        @target$ = $ node
        @node$.width(@target$.outerWidth())
        @node$.height(@target$.outerHeight())
        offset = @target$.offset()
        if node.style.display is "none"
            offset.top = -99999
        @node$.css({top:offset.top,left:offset.left})
        if @style
            @node$.css(@style)
    show:()->
        @appendTo document.body
    hide:()->
        @remove()

class PreviewList extends Leaf.Widget
    constructor:()->
        super App.templates["preview-list"]
        @list = Leaf.Widget.makeList @UI.container
        @node.oncontextmenu = ()=>
            @hide()
            return false
    preview:(group)->
        App.maskGroup.clear()
        for item in group.children
            App.maskGroup.add new DomMask(item,{"background-color":"blue"})
        @list.length = 0
        for item in group.children
            @list.push new PreviewListItem(item.outerHTML)
    choose:(groups)->
        @candidates = groups
        @currentGroupIndex = 0
        @preview groups[@currentGroupIndex]
        extractGroupCharactor(groups[0])
        @show()
    show:()->
        @node$.show()
    hide:()->
        @node$.hide()
    onClickConfirm:()->
        @__callback @__data
    onClickCancel:()->
        @__callback null
class PreviewListItem extends Leaf.Widget
    constructor:(content)->
        super "<div class='preview-list-item'></div>"
        if content
            @setContent content
    setContent:(content)->
        content = sanitizer.sanitize content
        @node$.html content
