feature_creep
=============

I've got your feature flags implementation right here.

This is a fork/rewrite of James Golick's Rollout with messy and incomplete docs.

So far, the specs are green and are mostly inherited from Rollout.
This is not a drop in replacement. The API has already changed.

Namely, `groups` are now `scopes` and `users` are `individuals`.
Agent_ids are expected to be uuids, not the object itself.

There are currently 3 gems in this ecosystem:
`gem 'feature_creep'`
`gem 'feature_creep-redis'`
`gem 'feature_creep-simple_strategy'`

The class constructor now takes

`datastore` -- FeatureCreep::RedisDatastore is provided with more to come.

`info` -- should be a lambda that takes two parameters and returns a hash when called

`warden` -- is also a lambda that takes two parameters and returns a boolean. It encapsulates the business logic for FeatureCreep#active?

`options` -- an aptly named options hash

`options[:scopes]` is a hash that expects a string key and a lambda that encapsulates the business logic for membership in a scope

`options[:features]` is an array of strings or symbols that will add  to the list of all possible features.

@feature_creep = FeatureCreep.new(FeatureCreep::RedisDataStore.new(Redis.new,"parent_namespace"),
                                  FeatureCreep::SimpleStrategy.warden,
                                  FeatureCreep::SimpleStrategy.info,
                                  {:scopes => {:some_scope_name => lambda { |individual| User.find(individual).can?(:some_scope) }}, :features => [:feature_1, :feature_2]})

At this point it should be easy to extend.
I would expect the API to stablize over the next couple of weeks.

