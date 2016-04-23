$.fn.fingerPrint = ()->
    classPrint = this[0].className.split(/\s+/g).join(".")
    idPrint = "#"+ this[0].id or ""
    return [this[0].tagName,idPrint,classPrint].join("")
$.fn.pathFingerPrint = ()->
    parent = this[0]
    prints = []
    while parent
        prints.push $(parent).fingerPrint()
        parent = parent.parentElement
    return prints.join(" ")
$.fn.averageLeafWidth = ()->
    node = this[0]
    total = 0
    count = 0
    traverse node,(item)->
        if not item.children or item.children.length is 0
            total += item.clientWidth
            count += 1
    return count
$.fn.maxLeafWidth = ()->
    max = 0
    node = this[0]
    traverse node,(item)->
        if not item.children or item.children.length is 0
            if item.offsetWidth > max
                max = item.offsetWidth
            
    return max
Math.ln = (a)->
    return Math.log(a)/Math.log(Math.E)
class RssSelector extends Leaf.EventEmitter
    constructor:()->
        super()
    select:(item,callback)->
        nodes = findSimilarNode(item)
        nodes.push item
        groups = findGroup(nodes,item)
        resultGroups = []
        for group,index in groups
            if item not in group.children
                continue
            resultGroups.push group
        return resultGroups
window.RssSelector = RssSelector

likelyStaticAttr = (attr)->
    if /[0-9]+/.test attr
        return false
    return true
$.fn.charactorQuery = ()->
    elem = this[0]
    result = []
    while elem and elem isnt document.body.parentElement
        query = [elem.tagName or ""]
        if elem.id and likelyStaticAttr(elem.id)
            query.push "##{elem.id}"
        if elem.className
            classes = elem.className.split(/\s+/)
            classes = classes.filter (item)->likelyStaticAttr(item)
            query.push.apply query, classes.map (item)->"."+item
        result.push query.join("")
        elem = elem.parentElement
    return result.reverse().join(" > ")
    
extractGroupCharactor = (group)->
    # build container query
    resultCharactor = {}
    containerQueryArr = []
    elem = group.container
    containerQuery = $(elem).charactorQuery()
    totalContainer = $(containerQuery)
    containerIndex = 0
    containerBrotherCount = totalContainer.length
    for item,index in totalContainer
        if item is group.container
            containerIndex = index
            break
    childrenQueries = []
    for child in group.children
        childQuery = $(child).charactorQuery()
        if childQuery not in childrenQueries
            childrenQueries.push childQuery
    
    resultCharactor.strict = false
    resultCharactor.Index = containerIndex
    resultCharactor.containerPath = containerQuery
    resultCharactor.childrenPathes = childrenQueries or []
    resultCharactor.url = window.location.toString()
    resultCharactor.name = window.title
    console.log resultCharactor
    console.log JSON.stringify(resultCharactor)
    console.log window.btoa(escape(JSON.stringify(resultCharactor)))
    return resultCharactor
    
findSimilarNode = (node)->
    nodes = document.getElementsByTagName("*")
    charactor = $(node).charactor()
    glipse = []
    for another in nodes
        if another is node
            continue
        anotherCharactor = $(another).charactor()
        if anotherCharactor.level is charactor.level and anotherCharactor.type is charactor.type
            glipse.push another
    return glipse
findGroup = (nodes,sample)->
    groups = []
    for index in [0...nodes.length]
        for targetIndex in [index+1...nodes.length]
            firstNode = nodes[index]
            secondNode = nodes[targetIndex]
            parent = $(firstNode).commonParent(secondNode)
            if not parent then continue
            hasGroup = false
            for group in groups
                if group.container is parent
                    hasGroup = true
                    if firstNode not in group.children
                        group.children.push
                    if secondNode not in group.children
                        group.children.push secondNode
                    break
            if not hasGroup
                groups.push {container:parent,children:[firstNode,secondNode]}
    for group in groups
        evaluateGroup(group,sample)
    groups.sort (b,a)->
        return a.value - b.value
    return groups
evaluateGroup = (group,sample)->
    # are they aligned like list
    alignFactor = 1
    # does the group has most children?
    countValue = 0
    # the container should be more close to child
    levelFactor = 1
    # like the sample
    matchedCountValue = 0
    masterLevel = $(group.container).charactor().level
    childLevel = $(group.children[0]).charactor().level

    levelFactor *= Math.sqrt(1/(childLevel - masterLevel+1))
    countValue += group.children.length

    verticalAlign = []
    horizentalAlign = []
    
    structureSample = $(sample).charactor().structureSample
    
    for child in group.children
        rect = child.getBoundingClientRect()
        if rect.top not in verticalAlign
            verticalAlign.push rect.top
        if rect.left not in horizentalAlign
            horizentalAlign.push rect.left
        if $(child).charactor().structureSample is structureSample
            matchedCountValue++
    alignFactor *= 1/Math.min(verticalAlign.length,horizentalAlign.length)
    group.value = (countValue + 10 * matchedCountValue) * alignFactor * levelFactor
    group.raw = [countValue , matchedCountValue , alignFactor , levelFactor]
#    console.log "eval",group.value,group.children,countValue,alignFactor,levelFactor
    
$.fn.markAsActive = ()->
    @addClass("analyze-active")
$.fn.markAsInactive = ()->
    @removeClass("analyze-active")
$.fn.markAsSelect = ()->
    @addClass("analyze-select")
$.fn.markAsInselect = ()->
    @removeClass("analyze-select")
$.fn.markAsGroup = (index)->
    @addClass("analyze-group")
    @css({"box-shadow":"0 0 5px 5px yellow"})
$.fn.markAsIngroup = ()->
    @removeClass("analyze-group")

$.fn.charactor = ()->
    if this[0].charactor
        return this[0].charactor
    level = 0
    node = this[0]
    while node
        level++
        node = node.parentElement
    
#    text = @text().replace(/\s+/ig,"").trim()
#    numberOnly = /^[0-9]+$/.test(text)
    innerStructureSample = []
    for item in this[0].children
        innerStructureSample.push item.tagName or "TEXT"
    this[0].charactor = {level:level,type:this[0].tagName,structureSample:innerStructureSample.join(",")}
    
    return this[0].charactor
    

$.fn.commonParent = (node)->
    origin = this[0]
    target = node
    originParents = []
    targetParents = []
    while origin.parentElement
        originParents.push origin.parentElement
        origin = origin.parentElement
    while target.parentElement
        targetParents.push target.parentElement
        target = target.parentElement
    for item in originParents
        if item in targetParents
            return item
    return null
window.extractGroupCharactor = extractGroupCharactor