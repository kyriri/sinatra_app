# A Ruby project using Sinatra

This is a study project. Its objectives are:
- [x] developing a non-Rails, Ruby web app
- [x] importing data from CSV files into the DB
- [ ] using open API specs
- [ ] implementing RESTful APIs as described [here](https://r.bluethl.net/how-to-design-better-apis)
- [ ] getting familiar with the use of Postman
- [ ] using a DB server (not SQLite) 
- [ ] getting familiar with the use of Docker
- [ ] implementing an assyncronous (background) job
- [ ] cloud deploying the app
- [ ] applying some sort of continuous integration
- [ ] having a React front-end

## Requirements

Ruby 3.1.2
SQLite

## Installation

Clone this repository and visit its local folder. On it, run  
`$ bundle install`  
  
Then prepare the database with  
`$ bundle exec rake db:create db:migrate`  

## Running the app

On the project folder, run  
`$ bundle exec rackup`  

## Managing the database

The connections are managed via Active Record, through the file `config/database.yml`.
For a list of available automated tasks concerning the database, check  
`$ bundle exec rake --tasks`  

## Test suite

Prepare the database for the Test Environment with  
`$ bundle exec rake db:create db:migrate RACK_ENV='test'`  
  
On the project folder, run  
`$ bundle exec rspec`  

If for any reason the test database is dirty and needs manual cleaning, try  
`$ bundle exec rake db:drop db:create db:migrate RACK_ENV="test"`
