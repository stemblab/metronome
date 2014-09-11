#!vanilla

#$("#run_button").prop("disabled", true)

pi = Math.PI
sin = Math.sin
cos = Math.cos
min = Math.min

#zeros = (m) -> 0 for [1..m]
repRow = (val, m) -> val for [1..m]

# work around unicode issue
char = (id, code) -> $(".#{id}").html "&#{code};"
char "deg", "deg"
char "percent", "#37"
char "equals", "#61"


class d3Object

    constructor: (id) ->
        @element = d3.select "##{id}"
        @element.selectAll("svg").remove()
        @obj = @element.append "svg"
        @initAxes()
        
    append: (obj) -> @obj.append obj
    
    initAxes: ->


{rk, ode} = $blab.ode # Click to see imported functions


class Metronome extends d3Object

    margin = {top: 0, right: 0, bottom: 0, left: 0}
    width = 400
    height = 500
    weightWidth = width*2/16
    weightHeight = height*2/16
    pivotX = width/2
    pivotY = height*4/8
    pivotR = height/64
    armLength = height*7/16
    pendLength = armLength*5/16
    bpmBottom = pivotX*7/8
    bpmTop = pivotX*1/8
    pendR = width/8
    rhoMax = min(width, height)/2 - weightHeight/2
    rhoMin = min(width, height)/8

    markerWidth = 6
    markerHeight = 6
    #cRadius = 0
    #refX = cRadius + (markerWidth * 2)
    #refY = -Math.sqrt(cRadius)
    #drSub = cRadius + refY



    constructor: ()->
    
        @phi = 0
        @tail = 0
        @omega = 10
        @f = (t, z, om) -> [z[1], -om*om*Math.sin(z[0])-10*(z[0]*z[0]/0.01-1)*z[1]]
        @v = 0
    
        super "metronome"
        
        @obj.attr('width', width)
            .attr('height', height)
            #.attr("id", "metronome")

        @obj.append("svg:defs")
            .append("svg:marker")
            .attr("id", "arrow")
            .attr("viewBox", "0 -5 10 10")
            .attr("refX", 10)
            .attr("refY", 0)
            .attr("markerWidth", markerWidth)
            .attr("markerHeight", markerHeight)
            .attr("orient", "auto")
            .append("svg:path")
            .attr("d", "M0,-5L10,0L0,5")
            .style("stroke","ccc")

        @arm = @obj.append('line')
            .attr("x1", pivotX).attr("y1", pivotY + pendLength)
            .attr("x2", pivotX).attr("y2", pivotY - armLength)
            .attr('transform', "rotate(#{@phi} #{pivotX} #{pivotY})")
            .attr('id','arm')
            .style("stroke","000")
            .style("stroke-width","5")

        @weight = @obj.append('rect')
            .attr('width', weightWidth)
            .attr('height', weightHeight)
            .attr("rx","5")
            .attr("ry","5")
            .style("fill","fff")
            .style("stroke","000")
            .style("stroke-width","2")
            .style("shape-rendering", "auto")

        @r1 = @obj.append("g")
            .attr("id", "r1")
            .append("use")
            .style("stroke", "black")
            .attr("xlink:href","#r1")
            
        r1Trans = "translate(#{pivotX-pendLength-pendR-25},#{pivotY-5})" +
            "rotate(#{-15} #{pendLength+pendR+25} #{5})"
        @r1.attr('transform', r1Trans)


        @r2 = @obj.append("g")
            .attr("id", "r2")
            .append("use")
            .style("stroke", "black")
            .attr("xlink:href","#r2")

        @m1 = @obj.append("g")
            .attr("id", "m1")
            .append("use")
            .style("stroke", "black")
            .attr("xlink:href","#m1")

        @m2 = @obj.append("g")
            .attr("id", "m2")
            .append("use")
            .style("stroke", "black")
            .attr("xlink:href","#m2")

        @theta = @obj.append("g")
            .attr("id", "theta")
            .append("use")
            .style("stroke", "black")
            .attr("xlink:href","#theta")
            
        thTrans = "translate(#{pivotX+pendLength},#{pivotY+pendLength})" +
            "rotate(#{0} #{pendLength+pendR+25} #{5})"
        @theta.attr('transform', thTrans)



        @obj.on("click", null)  # Clear any previous event handlers.
        #@obj.on("click", => @click())
        d3.behavior.drag().on("drag", null)  # Clear any previous event handlers.

        @obj.selectAll("rect.tick")
            .data(d3.range(17))
            .enter()
            .append("svg:rect")
            .attr("class", "tick")
            .attr("x", 0)
            .attr("y", -pendLength*7/8)
            .attr("width", 1)
            .attr("height", (d, i) -> (if (i % 2) then 5 else 15))
            .attr("transform", (d, i) -> 
                "translate(#{pivotX},#{pivotY}) rotate(#{i*15+150})"
            )
            .attr "fill", "steelblue"


        @weightGuide = @obj.append("circle")
            .attr('transform', "translate(#{pivotX},#{pivotY})")
            .style("fill","transparent")
            .style("stroke","ddd")
            .style("stroke-width","1")
            #.style("stroke-dasharray", "3, 3")

        @weightGuideDim = @obj.append('line')
            .attr("marker-end", "url(#arrow)")
            .attr("x1", pivotX).attr("y1", pivotY)
            .attr("x2", pivotX-100).attr("y2", pivotY)
            #.attr('transform', "rotate(#{@phi} #{pivotX} #{pivotY})")
            .attr('id','weightGuideDim')
            .style("stroke","ccc")
            .style("stroke-width","1")
            .attr('transform', "rotate(#{15} #{pivotX} #{pivotY})")

        @r1Dim = @obj.append('line')
            .attr("marker-end", "url(#arrow)")
            .attr("x1", pivotX).attr("y1", pivotY)
            .attr("x2", pivotX-pendLength-pendR).attr("y2", pivotY)
            #.attr('transform', "rotate(#{@phi} #{pivotX} #{pivotY})")
            .attr('id','weightGuideDim')
            .style("stroke","ccc")
            .style("stroke-width","1")
            .attr('transform', "rotate(#{-15} #{pivotX} #{pivotY})")


        pivot = @obj.append('circle')
            .attr('transform', "translate(#{pivotX},#{pivotY})")
            .attr("r", pivotR)
            .style("fill","black")
            .style("stroke","000")
            .style("stroke-width","3")

          
        @pend = @obj.append('circle')
            .attr('transform', 
                "translate(#{pivotX},#{pivotY+pendLength+pendR})")
            .attr("r", pendR)
            .style("fill","transparent")
            .style("stroke","000")
            .style("stroke-width","2")

        @dragPend(pivotX-rhoMax*cos(pi/4), pivotY+rhoMax*sin(pi/4))
        
        @weight.call(
            d3.behavior
            .drag()
            .origin(()=>{x:@weight.attr("x"), y:@weight.attr("y")})
            .on("drag", => @dragPend(d3.event.x, d3.event.y))
        )

        @axis = @obj.append("g")
            .attr("id","y-axis")
            .attr("class", "axis")
            .style("fill", "grey")
            .attr("transform", "translate(#{2*width/4},#{pivotY})")
            .call(@yAxis)

        arc = d3.svg.arc()
            .innerRadius(pendLength+pendR)
            .outerRadius(pendLength+pendR+0.5)
            #.startAngle(3*pi/4)
            #.endAngle(9*pi/4)
            .startAngle(0)
            .endAngle(-5*pi/4)


        @obj.append("path")
            .attr("d", arc)
            .style("stroke","ccc")
            .style("stroke-width","1")
            .attr("transform", "translate(#{pivotX},#{pivotY})")
            #.attr("marker-end", "url(#arrow)")


    dragPend: (x, y) ->
        xp = x - pivotX
        yp = y - pivotY
        @phi = Math.atan(xp/yp)
        @rho = Math.sqrt(xp*xp + yp*yp)
        console.log "rho", @rho
        if rhoMin < @rho < rhoMax
            #@omega = @y.invert(pivotY-@rho)
            @omega = @y.invert(@rho)
            #console.log "omega", @omega
            @drawPend(x,y)

    swing: ()->
        [@phi, @v] = ode(rk[4], @f, [0, 0.001], [@phi, @v], @omega)[1]
        x = pivotX - @rho*Math.sin(@phi)
        y = pivotY - @rho*Math.cos(@phi)
        @drawPend(x, y)
        
    drawPend: (x,y) ->
        @tail = pivotX-1*armLength*Math.sin(@phi)
        weightTrans = "translate(#{-weightWidth/2},#{-weightHeight/2})"+
            "rotate(#{-@phi*180/pi} #{x+weightWidth/2} #{y+weightHeight/2})"
        @weight.attr('transform', weightTrans)
        @weight.attr('x', x)
        @weight.attr('y', y)
        @arm.attr('transform', "rotate(#{-@phi*180/pi} #{pivotX} #{pivotY})")    


        @m2.attr('transform', 
            "translate(#{x-12},#{y+6}) rotate(#{-@phi*180/pi} #{12} #{-6})")


        @r = Math.sqrt(x*x+y*y)
        
        ###
        arc = d3.svg.arc()
            .innerRadius(50)
            .outerRadius(51)
            .startAngle(-pi/2)
            .endAngle(pi/2)
            
        @obj.append("path")
            .attr("d", arc)
        ###
           
        @weightGuide.attr("r", @rho)
        @weightGuideDim.attr("x2", pivotX-@rho)
        
        r2Trans = "translate(#{pivotX-@rho-25},#{pivotY-5})" +
            "rotate(#{15} #{@rho+25} #{5})"
        @r2.attr('transform', r2Trans)

        ###
        r1Trans = "translate(#{pivotX-pendLength-pendR-25},#{pivotY-5})" +
            "rotate(#{-15} #{pendLength+pendR+25} #{5})"
        @r1.attr('transform', r1Trans)
        ###


        #@pend.attr('transform', "translate(#{x},#{y})")
        pendTrans = "translate(#{pivotX},#{pivotY+pendLength+pendR})" +
            "rotate(#{-@phi*180/pi} #{0} #{-pendLength - pendR})"
        @pend.attr('transform', pendTrans)

        m1Trans = "translate(#{pivotX-8},#{pivotY+pendLength+pendR+5})" +
            "rotate(#{-@phi*180/pi} #{8} #{-armLength/4-pendR-5})"
        @m1.attr('transform', m1Trans)

    initAxes: ->

        @y = d3.scale.sqrt()
            #.domain([52, 208])
            .domain([208, 52])
            #.tickValues([208, 160, 120, 96, 72])
            .range([bpmTop, bpmBottom]) 

        @yAxis = d3.svg.axis()
            .scale(@y)
            .tickValues([208, 160, 124, 96, 72, 52])
            #.tickValues([52, 72, 96, 120, 160, 208])
            .orient("bottom")

class StopButton

    id: "stop_simulation_button"

    constructor: (@stop) ->
        @button = $ "##{@id}"
        @button.remove() if @button.length
        @button = $ "<button>",
            id: @id
            type: "button"
            text: "Stop"
            title: "Stop simulation"
            click: => @stop()
            css:
                fontSize: "7pt"
                width: "50px"
                marginLeft: "5px"
        $("#run_button_container").append @button
 
    text: (t) ->
        @button.text t
        
    remove: -> @button.remove()


class Trace extends d3Object

    margin = {top: 0, right: 0, bottom: 0, left: 0}
    width = 400 - margin.left - margin.right
    height = 200 - margin.top - margin.bottom

    constructor: (initHist)->

        @N = 101
        @hist = repRow(initHist, @N)
    
        super "trace"

        @obj.attr('width', width + margin.left + margin.right)
            .attr('height', height + margin.top + margin.bottom)
            #.attr("id", "coupling")

        @guide = @obj.append('g')
            .attr('transform', "translate(#{margin.left}, #{margin.top})")
            .attr('width', width)
            .attr('height', height)
            #.attr('id','plot')

        @obj.append("linearGradient")
            .attr("id", "line-gradient")
            .attr("gradientUnits", "userSpaceOnUse")
            .attr("x1", 0).attr("y1", 0)
            .attr("x2", 0).attr("y2", height)
            .selectAll("stop").data([
          {
            offset: "0%"
            color: "white"
          }
          {
            offset: "100%"
            color: "black"
          }
        ]).enter().append("stop").attr("offset", (d) ->
          d.offset
        ).attr "stop-color", (d) ->
          d.color

       
        @line = d3.svg.line()
            .y((d) =>  @y(d))
            .x((d,i) =>  @hist[i])
            .interpolate("basis")

        @guide.selectAll('path.sine')
            .data([[0...@N]])
            .enter()
            .append("path")
            .attr("d", @line)
            .attr("class", "sine")

    initAxes: ->
        
        @y = d3.scale.linear()
            .domain([0, @N-1])
            .range([0, height]) 

        @x = d3.scale.linear()
            .domain([-1, 1])
            .range([0, width])
        
        @xAxis = d3.svg.axis()
            .scale(@x)
            .orient("bottom")
            .tickFormat(d3.format("d"))

        @yAxis = d3.svg.axis()
            .scale(@y)
            .orient("left")


class Simulation

    constructor: ->

        @N = 101
        @metronome = new Metronome
        @trace = new Trace @metronome.tail
        
        setTimeout (=> @animate() ), 200
        #@stopButton = new StopButton => @stop()

        @pause = false
        
        @metronome.weight.on "mousedown", =>
            return if d3.event.defaultPrevented # click suppressed
            #console.log "mousedown!", d3.event.x, d3.event.y
            @metronome.axis.style("fill", "00f")
            @metronome.weightGuide.style("stroke","00f")
            @pause = true
            console.log "???", @metronome.v
            @metronome.v = 1
            
        @metronome.weight.on "mouseup", =>
            return if d3.event.defaultPrevented # click suppressed
            #console.log "mouseup!"
            @metronome.axis.style("fill", "grey")
            @metronome.weightGuide.style("stroke","ccc")
            @pause = false
        
    snapshot: ->
        if not @pause then @metronome.swing()
        (@trace.hist).push @metronome.tail
        @trace.hist = @trace.hist[1...(@trace.hist).length]
        @trace.guide.selectAll('path.sine').attr("d", @trace.line)

    animate: ->
        @timer = setInterval (=> @snapshot()), 10
        #@snapshot()
        #@stop()
        
    stop: ->
        clearInterval @timer
        @timer = null
        @stopButton?.remove()
        $("#run_button").prop("disabled", false)
        
new Simulation

