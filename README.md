Overview (TODO)
---


How to Run
---
#### Using Docker
If you are familiar with Docker (or wish to lear it), this is the
easiest way of getting the API up and running so you may send requests
to it through a Front End app, Postman or Swagger. That said, this setup 
is not ideal for development on this API.

1. Install Docker (Docker )
2. Navigate to the root of the project folder where the `Dockerfile` should be
3. Run `$ docker build -t opentt-scheduler .` (NOTICE THE DOT `.` AT THE END OF THE COMMAND, tiny but powerful) 
which will create the server image and name it `opentt-scheduler`
    1. to confirm this step was successful run `$ docker images | grep opentt-scheduler` and expect the 
    opentt-scheduler image data to show
4. To create a fully working server run `$ docker run -p 3001:3000 opentt-scheduler`
5. On your browser visit the Swagger Docs at http://localhost:3001/api-docs/index.html  

#### Using Rails
The Ruby on Rails local setup will require a lot of perseverance from developers
unfamiliar with its intricacies. This drawback is overshadowed by the ease it provides 
at development time once you have ramped up. Therefore this is an appropriate choice
for projects which can benefit from quick prototyping and delivery.

These are not instructions, but rather things to keep in mind when installing RoR 
1. Will need Ruby version: `2.5.1` and Rails version: `5.0.0`


Useful Commands
---
- Generate rspec files for controller
    - `$ rails generate rspec:swagger API::MyController`
- Generates Swagger docs from rspec files
    - `$ RAILS_ENV=test rails rswag`
- Heroku run migration
    - `$ heroku run rake db:migrate`
- Heroku add config
    - `$ heroku config:set SECRET_KEY_BASE='put here new generated key'`

3rd party gem instructions and docs
---
- [How To PayPal][8]
- [Stripe Set Up delayed payments][10]
- [strftime Cheatsheet][9]
- [Deployment to Heroku][6]
- [rswag gem][1] for testing and swagger docs
    
    - Adding `gem 'rswag'` to gemfile alone did not work. Had to install individual gems. 

- [Test Models with Rspec][7]    
- [Authentication with JWT][4]
- [Simple Command Gem][5]. Used instead of Services and Helpers
             
  > The simple command gem is an easy way to create services. Its role is similar to the role of a helper, 
    but it instead facilitates the connection between the controller and the model, rather than the controller and the view. In this way, we can shorten the code in the models and controllers. 

Errors and Fixes
---
- ERROR in `'require': cannot load such file -- spec_helper`: [Solved here with solution for V3][2]
- How to override `devise` user session controller. [Stack Overflow Link][3]
    
[1]: https://github.com/rswag/rswag
[2]: https://stackoverflow.com/questions/25800122/error-when-trying-to-run-rspec-require-cannot-load-such-file-rails-helper
[3]: https://stackoverflow.com/a/31818869/4379762
[4]: https://www.pluralsight.com/guides/token-based-authentication-with-ruby-on-rails-5-api
[5]: https://github.com/nebulab/simple_command
[6]: https://www.codecademy.com/articles/deploy-rails-to-heroku
[7]: https://www.digitalocean.com/community/tutorials/how-to-use-comments-in-ruby
[8]: https://stackoverflow.com/questions/23411337/how-to-integrate-paypal-with-ruby-on-rails
[9]: https://apidock.com/ruby/DateTime/strftime
[10]: https://stripe.com/docs/payments/save-and-reuse