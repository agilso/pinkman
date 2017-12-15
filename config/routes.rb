Pinkman::Engine.routes.draw do
  
  namespace :pinkman do
    root to: 'pinkman#hello'
  end
  
end