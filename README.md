# Solid Use Case

**Solid Use Case** is a gem to help you implement well-tested and flexible use cases. Solid Use Case is not a framework - it's a **design pattern library**. This means it works *with* your app's workflow, not against it.

[See the Austin on Rails presentation slides](http://library.makersquare.com/learn/fp-in-rails)

## Installation

Add this line to your application's Gemfile:

    gem 'solid_use_case', '~> 2.2.0'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install solid_use_case

## Usage

At its core, this library is a light wrapper around [Deterministic](https://github.com/pzol/deterministic), a practical abstraction over the Either monad. Don't let that scare you - you don't have to understand monad theory to reap its benefits.

The only thing required is using the `#steps` method:

### Rails Example

```ruby
class UserSignup
  include SolidUseCase

  steps :validate, :save_user, :email_user

  def validate(params)
    user = User.new(params[:user])
    if !user.valid?
      fail :invalid_user, :user => user
    else
      params[:user] = user
      continue(params)
    end
  end

  def save_user(params)
    user = params[:user]
    if !user.save
      fail :user_save_failed, :user => user
    else
      continue(params)
    end
  end

  def email_user(params)
    UserMailer.async.deliver(:welcome, params[:user].id)
    # Because this is the last step, we want to end with the created user
    continue(params[:user])
  end
end
```

Now you can run your use case in your controller and easily respond to the different outcomes (with pattern matching!):

```ruby
class UsersController < ApplicationController
  def create
    UserSignup.run(params).match do
      success do |user|
        flash[:success] = "Thanks for signing up!"
        redirect_to profile_path(user)
      end

      failure(:invalid_user) do |error_data|
        render_form_errors(error_data, "Oops, fix your mistakes and try again")
      end

      failure(:user_save_failed) do |error_data|
        render_form_errors(error_data, "Sorry, something went wrong on our side.")
      end

      failure do |exception|
        flash[:error] = "something went terribly wrong"
        render 'new'
      end
    end
  end

  private

  def render_form_errors(user, error_message)
    @user = user
    @error_message = error_message
    render 'new'
  end
end
```

## Control Flow Helpers

Because we're using consistent successes and failures, we can use different functions to gain some nice control flow while avoiding those pesky if-else statements :)

### #check_exists

`check_exists` (alias `maybe_continue`) allows you to implicitly return a failure when a value is nil:

```ruby
# NOTE: The following assumes that #post_comment returns a Success or Failure
video = Video.find_by(id: params[:video_id])
check_exists(video).and_then { post_comment(params) }

# NOTE: The following assumes that #find_tag and #create_tag both return a Success or Failure
check_exists(Tag.find_by(name: tag)).or_else { create_tag(tag) }.and_then { ... }

# If you wanted, you could refactor the above to use a method:
def find_tag(name)
  maybe_continue(Tag.find_by(name: name))
end

# Then, elsewhere...
find_tag(tag)
.or_else { create_tag(tag) }
.and_then do |active_record_tag|
  # At this point you can safely assume you have a tag :)
end
```

### #attempt

`attempt` allows you to catch an exception. It's useful when you want to attempt something that might fail, but don't want to write all that exception-handling boilerplate.

`attempt` also **auto-wraps your values**; in other words, the inner code does **not** have to return a success or failure.

For example, a Stripe API call:

```ruby
# Goal: Only charge customer if he/she exists
attempt {
  Stripe::Customer.retrieve(some_id)
}
.and_then do |stripe_customer|
  stripe_customer.charge(...)
end
```

## RSpec Matchers

If you're using RSpec, Solid Use Case provides some helpful matchers for testing.

First you mix them them into RSpec:

```ruby
# In your spec_helper.rb
require 'solid_use_case'
require 'solid_use_case/rspec_matchers'

RSpec.configure do |config|
  config.include(SolidUseCase::RSpecMatchers)
end
```

And then you can use the matchers, with helpful error messages:

```ruby
describe MyApp::SignUp do
  it "runs successfully" do
    result = MyApp::SignUp.run(:username => 'alice', :password => '123123')
    expect(result).to be_a_success
  end

  it "fails when password is too short" do
    result = MyApp::SignUp.run(:username => 'alice', :password => '5')
    expect(result).to fail_with(:invalid_password)

    # The above `fail_with` line is equivalent to:
    # expect(result.value).to be_a SolidUseCase::Either::ErrorStruct
    # expect(result.value.type).to eq :invalid_password

    # You still have access to your arbitrary error data
    expect(result.value.something).to eq 'whatever'
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
