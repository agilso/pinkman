Dir[File.expand_path('../views_helpers/*.rb',__FILE__)].each {|file| require file }

module Pinkman
  module ViewsHelpers
    extend WriterHelper
    extend ConditionalHelper
    extend CollectionHelper
    extend TemplateHelper
    extend FormHelper
  end
end
    
# --- About:
# This file defines the Pinkman helpers we use in views.

# There is an extra layer of code so 
# we can namespace all Pinkman helpers with a 'p'.
# Just call p.method_name in the application.

# --- How this work:

# The Dispatcher's role is binding Rails Helpers and this module.
# It allow us to run this module methods within a Rails Helpers context (scope). 
# In other words, this module acts exactly like a Rails Helper. 
# Every method acessible there also is acessible here.

# The dispatcher, as the name suggests, is responsible to be up front in a Rails 
# Helper and pass this module all the messages received.
#  module NormalRailsHelper 
#    def p
#      Pinkman::ViewsHelpers.dispatcher(self)
#    end
#  end
# 
#  p.some_method => Pinkman::ViewsHelpers.some_method
#

# Another thing to keep in mind is that
# to define new methods, use the 'define_helper' method.

# --- Why not a simple Rails Helper?
# I swear I tried. But:

# 1. Pinkman Helpers should be isolated from Rails and Custom Helpers

# 2. p_some_method would not acomplished that.

# 3. If I were to define these as -- instance -- methods of a common Rails Helper,
# then those methods wouldn't be isolated.

# 4. If I were to define these as -- class -- methods of a common Rails Helper (PinkmanHelper.do_something),
# then the scope would not allow us to call ActionView::Helpers like capture, raw, etc.

# 5. If I were to extend/include ActionViews::Helpers directly here, 
# it would broke. I tried. A lot.

# 6. This what I got for now. 
# If you think of another better way to solve this 
# keeping the p.method_name convention (not p_method_name), 
# just send a pull request.

# --- Attention
# Blocks will be passed to these helpers in the last argument position
# as procs. So...

# Use:
#   define_helper :method_name do |one, two, block=nil|

# DONT't use:
#   define_helper :method_name do |one, two, &block| 
#   (this won't work)