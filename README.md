# Playbook - The Underpinnings to Your Rails API

Playbook provides your rails application with a simple way to create a customized, clean, and fast api. It lays out the groundwork for versioning, deprecation, rendering, reusability, authorization, and authentication. This README will show each major section of playbook with an example and an explanation of the code.


#### Routing

Playbook provides you with simple way of defining versioned routes. By extending your router with the `Playbook::Router` module you are given a `versions` method. The `versions` method allows you to pass in as many float, integer, or string versions as you'd like. Your routes will be drawn explicitly for each of those versions. Regular expressions and conditions are not used.

```ruby
# routes.rb
extend ::Playbook::Router

namespace :api do
  versions(1.0, 2.0) do
    
    resources :cities, :only => [:index, :show] do
      member do
        post :express_interest
      end
    end
  
  end
end
```

#### Controllers

You are provided with a `Playbook::BaseController` if you'd like to get things done quickly. If you're more interested in what's going on, check out the modules included into the `Playbook::BaseController`, specifically:

  * Playbook::Controller
  * Playbook::Authorization
  * Playbook::Authentication
  * Playbook::ApiStandards


```ruby
# app/api/controllers/api/v1/cities_controller.rb
class Api::V1::CitiesController < ::Playbook::BaseController
  
  forward_to_adapter :express_interest, :render => '/api/v1/cities/show', :status => 201
  forward_to_adapter :show,             :render => '/api/v1/cities/show'
  forward_to_adapter :index,            :render => '/api/v2/cities/index'

  require_auth :express_interest
end
```


```ruby
# app/api/adapters/api/v1/city_adapter.rb
class Api::V1::CityAdapter < ::Playbook::Adapter
  
  require_params :id, :on => [:show, :express_interest]
  whitelist :page,    :on => :index

  def show
    success(:city => city)
  end

  def index
    cities = Cities.page(params[:page] || 1).per(20)
    success(:cities => cities)
  end

  def express_interest
    interest = CityInterest.new(:city => city, :user => current_user)
    failure(interest) unless interest.save
    
    success(:city => city)
  end

  protected

  def city
    @city ||= City.find(params[:city_id] || params[:id])
  end

end
```


```ruby
# app/api/views/v1/cities/_show.json.jbuilder
json.extract! city, :id, :name, :lat, :lng, :created_at
```


```ruby
# app/api/views/v1/cities/index.json.jbuilder
json.collection!(@cities, :partial => '/api/v1/cities/show', :as => :city)
```


```ruby
# app/api/views/v1/cities/show.json.jbuilder
json.partial! '/api/v1/cities/show', :city => @city
```


```
GET /api/v1/cities.json?page=2
```


```js
{
  request : {
    path : '/api/v1/cities.json',
    server_time : 1335039034,
    api_version : '1.0',
    computation_time : 30,
    current_user_id : null,
    params : {
      page : 2
    }

  },
  response : {
    page : 2,
    total_items : 35,
    total_pages : 2,
    api_type : 'PaginatedCollection',
    item_type : 'City',
    items : [
      {
        id : 35,
        name : 'San Francisco',
        lat : 37.777,
        lng : -124.444,
        created_at : 1335005399,
        api_type : 'City'
      }
      ...
    ]
  }
}
```



#### Utilities

  * version stuff