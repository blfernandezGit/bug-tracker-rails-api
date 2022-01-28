# Nabi Project

Nabi Project is a simple bug tracking app that allows user to track bugs in a project. This is the github repository for the application's Backend API (Ruby on Rails). See working app in https://blfernandezgit.github.io/nabi-project

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes. See deployment for notes on how to deploy the project on a live system.

Clone the repo and navigate to main app directory

```shell
git clone https://github.com/blfernandezGit/nabi-project-api.git
cd nabi-project-api
```

### Prerequisites

Make sure you have ruby installed. The versions I used for this project is:

```shell
ruby -v
ruby 2.7.2p137
```

### Installing

Install dependencies

Using [Bundler](https://github.com/bundler/bundler) and [Yarn](https://github.com/yarnpkg/yarn):

```shell
bundle && yarn
```

Set environment variables

Using [Figaro](https://github.com/laserlemon/figaro):

Add environment variables for [Cloudinary](http://cloudinary.com) (cloud_name, cloud_api, cloud_secret)

Initialize the database

```shell
rails db:setup
```
Serve

```shell
rails s
```

API will be hosted in http://localhost:3000/ if port is available. Endpoints can be tested using [Postman](http://postman.com)

## Running the tests

Used [RSpec](https://rspec.info) for TDD

Run rspec

```shell
rspec spec --format documentation
```

### Model Specs

Tests associations and validations of the Active Models

```shell
require 'rails_helper'

RSpec.describe Ticket, type: :model do
  context 'Associations' do
    it { is_expected.to have_many(:ticket_relations) }
    it {
      is_expected.to have_many(:related_tickets)
        .through(:ticket_relations)
    }
    it {
      is_expected.to have_many(:inverse_ticket_relations)
        .class_name('TicketRelation')
    }
    it {
      is_expected.to have_many(:inverse_related_tickets)
        .through(:inverse_ticket_relations)
        .source(:ticket)
    }
    it { is_expected.to have_many(:comments) }
    it {
      is_expected.to belong_to(:author)
        .class_name('User')
    }
    it { is_expected.to belong_to(:project) }
  end

  context 'Validations' do
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.not_to validate_presence_of(:description) }
    it { is_expected.to validate_inclusion_of(:status).in_array(%w[Open ForFixing ForTesting Closed Cancelled]) }
  end
end
```

### Request Specs

Tests controller methods and JSON response

```shell
  describe 'View a specific ticket: GET /show' do
    context 'the ticket exists' do
      before(:example) do
        @ticket = create(:ticket, project: @project, author: @user)
        get api_v1_project_ticket_url(@project.code, @ticket.ticket_no), headers: @headers
      end

      it 'renders a successful response' do
        expect(response.status).to eq(200)
      end

      it 'contains expected ticket attributes' do
        json_response_data = JSON.parse(response.body)['data']
        attributes = json_response_data['attributes']
        expect(attributes.keys).to match_array(%w[title description resolution status ticket_no created_at updated_at
                                                  author comments inverse_related_tickets related_tickets project assignee image])
      end

      it 'contains specific ticket' do
        expect(response.body).to include(@ticket.title.to_s)
      end
    end

    context 'the ticket does not exist' do
      before(:example) do
        get "/api/v1/projects/#{@project.code}/tickets/dne", headers: @headers
      end

      it 'throws an error' do
        expect(response.body).to include('errors')
        expect(response.status).to eq(200)
      end
    end
  end
```

## Deployment

Add heroku remotes

Using [Heroku CLI](https://devcenter.heroku.com/articles/heroku-cli):

```shell
heroku git:remote -a project
heroku git:remote --remote heroku-staging -a project-staging
```
### With Heroku pipeline (recommended)

Push to Heroku staging remote:

```shell
git push heroku-staging
```

Go to the Heroku Dashboard and [promote the app to production](https://devcenter.heroku.com/articles/pipelines) or use Heroku CLI:

```shell
heroku pipelines:promote -a project-staging
```

### Directly to production (not recommended)

Push to Heroku production remote:

```shell
git push heroku
```

## Environments

API Endpoints documentation: https://documenter.getpostman.com/view/17602944/UVeCPTfn

API Base URL: https://nabi-project-api.herokuapp.com

Frontend repo: https://github.com/blfernandezGit/nabi-project

Deployed app: https://blfernandezgit.github.io/nabi-project


## Built With

* [Ruby on Rails](http://rubyonrails.org) - The web framework used


## Authors

* **Brigette Elizabeth Fernandez** - *Frontend and Backend* - [Nabi Project](https://github.com/blfernandezGit/nabi-project)
