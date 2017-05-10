Pinkman.css = (selector,property,value) ->
  $('style#pinkman-css-injector').append("#{selector} \{ #{property}: #{value}; \}")


$(document).ready ->
  unless $('style#pinkman-css-injector').length
    $('body').append('<style id="pinkman-css-injector" type="text/css"></style>')
