  # --- render

#   # Any mustache syntax like will do the job
#   @render = (options) ->
#     if options.template? and $("##{options.template}").length
#       options.object = new Object unless options.object?
#       htmlToRender = if html? then html else $("#" + options.template).html()
#       view = Hogan.compile(htmlToRender,{delimiters: '<< >>'})
#       content = view.render(options.object)
#       $("##{options.target}").html(content) if options.target?
#       options.callback(content) if options.callback? and typeof options.callback == 'function'
#       return content
#     else
#       return false