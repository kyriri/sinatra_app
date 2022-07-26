# A Ruby project using Sinatra

This is a study project. Its objectives are:
- [ ] developing a non-Rails, Ruby web app
- [ ] applying some sort of continuous integration
- [ ] getting familiar with the use of Docker
- [ ] using a DB server (not SQLite) 
- [ ] importing data from CSV files into the DB
- [ ] implementing RESTful APIs as described [here](https://r.bluethl.net/how-to-design-better-apis)
- [ ] getting familiar with the use of Postman
- [ ] implementing an assyncronous (background) job
- [ ] cloud deploying the app
- [ ] having a React front-end

## Requirements

Ruby 3.1.2

## Installation

Clone this repository. On its folder, run  
`$ bundle install`  

## Running the app

On the project folder, run  
`$ bundle exec rackup`  

## Managing the database

The connections are managed via Active Record, through the file `config/database.yml`.
For a list of available automated tasks concerning the database, check  
`$ bundle exec rake -T`  

## Test suite

On the project folder, run  
`$ bundle exec rspec`    
