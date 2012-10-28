class FeatureCreep
  class RedisDataStore

    def initialize(datastore = nil, key_prefix = "feature_creep")
      @key_prefix = key_prefix
      @redis = datastore || Redis.new
    end

    def activate_globally(feature)
      add_feature(feature)
      @redis.sadd(global_key, feature)
    end

    def deactivate_globally(feature)
      @redis.srem(global_key, feature)
    end

    def activate_scope(feature, scope)
      add_feature(feature)
      @redis.sadd(scope_key(feature), scope)
    end

    def deactivate_scope(feature, scope)
      @redis.srem(scope_key(feature), scope)
    end

    def deactivate_all(feature)
      @redis.del(scope_key(feature))
      @redis.del(agent_id_key(feature))
      @redis.del(percentage_key(feature))
      deactivate_globally(feature)
    end

    def activate_agent_id(feature, agent_id)
      add_feature(feature)
      @redis.sadd(agent_id_key(feature), agent_id)
    end

    def deactivate_agent_id(feature, agent_id)
      @redis.srem(agent_id_key(feature), agent_id)
    end

    def active?(feature, agent_id = nil)
      if agent_id
        active_globally?(feature) ||
          agent_id_in_active_scope?(feature, agent_id) ||
          agent_id_active?(feature, agent_id) ||
          agent_id_within_active_percentage?(feature, agent_id)
      else
        active_globally?(feature)
      end
    end

    def activate_percentage(feature, percentage)
      @redis.set(percentage_key(feature), percentage)
    end

    def deactivate_percentage(feature)
      @redis.del(percentage_key(feature))
    end

    def active_scopes(feature)
      @redis.smembers(scope_key(feature)) || []
    end

    def active_agent_ids(feature)
      @redis.smembers(agent_id_key(feature))
    end

    def active_global_features
      (@redis.smembers(global_key) || []).map(&:to_sym)
    end

    def active_percentage(feature)
      @redis.get(percentage_key(feature))
    end

    def active_globally?(feature)
      @redis.sismember(global_key, feature)
    end

    def agent_id_active?(feature, agent_id)
      @redis.sismember(agent_id_key(feature), agent_id)
    end

    def agent_id_within_active_percentage?(feature, agent_id)
      percentage = active_percentage(feature)
      return false if percentage.nil?
      agent_id % 100 < percentage.to_i
    end

    def features
      @redis.smembers(@key_prefix).map(&:to_sym)
    end

    def add_feature(feature)
      @redis.sadd(@key_prefix, feature)
    end

    private
    def key(name)
      "#{@key_prefix}:#{name}"
    end

    def scope_key(name)
      "#{key(name)}:scopes"
    end

    def agent_id_key(name)
      "#{key(name)}:agent_ids"
    end

    def percentage_key(name)
      "#{key(name)}:percentage"
    end

    def global_key
      "#{@key_prefix}:__global__"
    end
  end
end
