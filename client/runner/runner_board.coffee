#-----------------------------------------------------------------------------
# Canvas Templates
#-----------------------------------------------------------------------------
Template.main_canvas.rendered = ->
  main_canvas = new fabric.Canvas("main_canvas")
  main_canvas.hoverCursor = "pointer"

  show_game_start_images main_canvas, game()
  
  main_canvas.findTarget = ((originalFn) ->
    ->
      target = originalFn.apply(this, arguments)
      if target
        if @_hoveredTarget isnt target
          main_canvas.fire "object:over",
            target: target

          if @_hoveredTarget
            main_canvas.fire "object:out",
              target: @_hoveredTarget

          @_hoveredTarget = target
      else if @_hoveredTarget
        main_canvas.fire "object:out",
          target: @_hoveredTarget

        @_hoveredTarget = null
      target
  )(main_canvas.findTarget)
  
  # now we can observe "object:over" and "object:out" events
  main_canvas.on "object:over", (e) ->
    $("img#magnifier").attr "src", e.target._element.attributes.src.value

  main_canvas.on "object:out", (e) ->
    $("img#magnifier").attr "src", "data:image/gif;base64,R0lGODlhAQABAIAAAAAAAP///ywAAAAAAQABAAACAUwAOw=="



#-----------------------------------------------------------------------------
# Canvas Events
#-----------------------------------------------------------------------------
Template.main_canvas.events {}