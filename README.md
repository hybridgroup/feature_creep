feature_creep
=============

I've got your feature flags implementation right here.

This is a fork/rewrite of James Golick's Rollout with messy and incomplete docs.

So far, the specs are green and are mostly inherited from Rollout.
This is not a drop in replacement. The API has aleadey changed.

Namely, `groups` are now `scopes` and `users` are `agent_ids`.
Agent_ids are expected to be uuids, not the object itself.

The class constructor now takes a datastore and an options hash.

options[:info] should be a lambda that returns a hash when called

options[:warden] is also a lambda that encapsulates the business logic for FeatureCreep#active?

options[:scopes] is a hash that expects a string key and a lambda that encapsulates the business logic for membership in a scope


At this point it should be easy to extend.
I would expect the API to stablize over the next couple of weeks.

