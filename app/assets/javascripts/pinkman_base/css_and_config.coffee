Pinkman.css = (selector,property,value) ->
  $('style#pinkman-css-injector').append("#{selector} \{ #{property}: #{value}; \}")


$(document).ready ->
  unless $('style#pinkman-css-injector').length
    $('head').append('<style id="pinkman-css-injector" type="text/css">pink{display: inline; margin: 0; padding: 0; color: inherit; background-color: inherit; font: inherit;} template, template *{ display: none !important;}</style>')
    document.createElement('pink') if document.createElement?
