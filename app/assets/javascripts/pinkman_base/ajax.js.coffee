#   @ajax: 
#     get: (options) ->
#       if options.url?
#         ajax = jQuery.ajax options.url,
#           type: "GET"
#           dataType: 'json'
#         ajax.done (response) =>
#             if response.errors?
#               options.error(response) if options.error? and typeof options.error == 'function'
#               return false
#             else
#               options.success(response) if options.success? and typeof options.success == 'function'
#             options.complete(response) if options.complete? and typeof options.complete == 'function'
#           return this
#       else
#         return false

#     post: (options) ->
#       if options.url?
#         ajax = jQuery.ajax options.url,
#             beforeSend: (xhr) -> 
#               xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))
#             type: "POST"
#             dataType: 'json'
#             data: options.data
#         ajax.done (response) =>
#           if response.errors?
#             options.error(this) if options.error? and typeof options.error == 'function'
#             return false
#           else
#             options.success(response) if options.success? and typeof options.success == 'function'
#           options.complete(response) if options.complete? and typeof options.complete == 'function'
#         return this
#       else
#         return false

#     put: (options) ->
#       if options.url?
#         ajax = jQuery.ajax options.url,
#             beforeSend: (xhr) -> 
#               xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))
#             type: "PUT"
#             dataType: 'json'
#             data: options.data
#           ajax.done (response) =>
#             if response.errors?
#               options.error(this) if options.error? and typeof options.error == 'function'
#               return false
#             else
#               options.success(response) if options.success? and typeof options.success == 'function'
#             options.complete(response) if options.complete? and typeof options.complete == 'function'
#           return this
#       else
#         return false


#     file: (options) ->
#       if options.url?
#         ajax = jQuery.ajax options.url,
#             beforeSend: (xhr) -> 
#               xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))
#             xhr: ->
#               myXhr = $.ajaxSettings.xhr()
#               myXhr.upload.addEventListener 'progress', (e) ->
#                   if e.lengthComputable
#                     options.progress e.loaded/e.total if options.progress?
#                 , false
#               myXhr.addEventListener 'progress', (e) ->
#                   if e.lengthComputable
#                     options.progress e.loaded/e.total if options.progress?
#                 , false
#               return myXhr
#             type: "POST"
#             dataType: 'json'
#             data: options.data
#             processData: false
#             contentType: false
#         ajax.done (response) =>
#           if response? and response.errors?
#             options.error(this) if options.error? and typeof options.error == 'function'
#             return false
#           else
#             options.success(response) if options.success? and typeof options.success == 'function'
#           options.complete(response) if options.complete? and typeof options.complete == 'function'
#         return this
#       else
#         return false

#     upload: (options...) ->
#       @file(options...)