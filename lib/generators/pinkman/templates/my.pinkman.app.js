// This file will load Pinkman and all of your Pinkman App files: models, controllers, routes, etc.
// You are free to customize it 
// as long as you stick to the loading ordering rules described at the bottom.

// **** IMPORTANT: this file need to be required after jquery. 
// Yes. Pinkman depends on jquery.


// ------ 1. Pinkman & Template Engine
//= require pinkman_with_hogan

// This will load Pinkman.js packed together with a js template engine. (Hogan default)

// **** IMPORTANT: 
// You need to make sure that config/initializers/pinkman.rb 
// matches this template engine. 
// And if you change it, run a 'rake tmp:clear' 
// and restart the server just to make sure.

//   Valid Options: 
//   1. "pinkman_with_hogan"
//   2. "pinkman_with_handlebars"
//   3. "pinkman_with_markup"
//   4. "pinkman" (No template engine. Just Pinkman. See bellow.)

// Use the fourth option if you already have one of handlebars, hogan or markup template engine loaded. And don't forget to setup config/initializers/pinkman properly.


// ------ 2. App (must be after pinkman and before the rest)
//= require pinkman/base/app


// ------ 3. Collections
//= require pinkman/base/collection


// ------ 4. Objects
//= require pinkman/base/object


// ------ 5. Router
//= require pinkman/base/router


// ------ 6. Mixins (must be before models)
//= require_tree ./pinkman/app/mixins/


// ------ 7. Models (must be before controllers)
//= require_tree ./pinkman/app/models/


// ------ 8. Controllers
//= require_tree ./pinkman/app/controllers/


// ------ 9. Routes (must be last)
//= require ./pinkman/config/routes


// ------ Loading Order Rules:
// Follow these rules and you'll be fine. :)

// 1. "pinkman" or "pinkman_with_xxx" - must be first.
// 2. "pinkman/base/app" - must be second.
// 3. "pinkman/base/{colecction,object,router}" - each must be placed in this portion. 
// 4. "pinkman/app/mixins" - mixins can be required here as they need to be available to models. 
// 5. "pinkman/app/models" - your app models can be required here. 
// 6. "pinkman/app/controllers" - your app controllers must be after your models.
// 7. "pinkman/config/routes" - routes needs to be last.