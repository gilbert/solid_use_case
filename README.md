# Solid Use Case

**Solid Use Case** is a gem to help you implement well-tested and flexible use cases. Solid Use Case is not a framework - it's a **design pattern library**. This means it works *with* your app's workflow, not against it.

## Installation

Add this line to your application's Gemfile:

    gem 'solid_use_case', '~> 1.0.2'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install solid_use_case

## Usage

At its core, this library is a light wrapper around [Deterministic](https://github.com/pzol/deterministic), a practical abstraction over the Either monad. Don't let that scare you - you don't have to understand monad theory to reap its benefits.

The only required method is the `#run` method.

### Rails Example

```ruby
class UserSignup < SolidUseCase::Base
  def run(params)
    attempt_all do
      step { validate(params) }
      step {|params| save_user(params) }
      try {|params| email_user(params) }
    end
  end

  def validate(params)
    user = User.new(params[:user])
    if !user.valid?
      fail :invalid_user, :user => user
    else
      params[:user] = user
      next_step(params)
    end
  end

  def save_user(params)
    user = params[:user]
    if user.save
      fail :user_save_failed, :user => user
    else
      next_step(params)
    end
  end

  def email_user(params)
    UserMailer.async.deliver(:welcome, params[:user].id)
    return params[:user]
  end
end
```

Now you can run your use case in your controller and easily respond to the different outcomes (with **pattern matching**!):

```ruby
class UsersController < ApplicationController
  def create
    UserSignup.run(params).match do
      success do |user|
        flash[:success] = "Thanks for signing up!"
        redirect_to profile_path(user)
      end

      failure(:invalid_user) do |error_data|
        render_new(error_data, "Oops, fix your mistakes and try again")
      end

      failure(:user_save_failed) do |error_data|
        render_new(error_data, "Sorry, something went wrong on our side.")
      end

      failure do |exception|
        flash[:error] = "Something went terribly wrong"
        render 'new'
      end
    end
  end

  private

  def render_new(user, error_message)
    @user = user
    @error_message = error_message
    render 'new'
  end
end
```

## Testing

    $ bundle exec rspec

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
