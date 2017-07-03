window.sleep = (s,callback) -> 
  ms = s*1000
  window['_sleeping'] = setTimeout(callback,ms)

Number.prototype.print = (precision, delimiter, separator) ->
  n = this
  precision = if isNaN(precision = Math.abs(precision)) then 2 else precision
  separator = if separator == undefined then "." else separator 
  delimiter = if delimiter == undefined then "," else delimiter 
  s = if n < 0 then "-" else ""
  i = String(parseInt(n = Math.abs(Number(n) || 0).toFixed(precision)))
  j = if (j = i.length) > 3 then j % 3 else 0
  return s + (if j then i.substr(0, j) + delimiter else "") + i.substr(j).replace(/(\d{3})(?=\d)/g, "$1" + delimiter) + (if precision then separator + Math.abs(n - i).toFixed(precision).slice(2) else "")