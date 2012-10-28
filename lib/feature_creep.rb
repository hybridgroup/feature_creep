class FeatureCreep

  attr_accessor :scopes, :info, :warden

  def initialize(datastore, options = {})
    @datastore = datastore
    @scopes = {"all" => lambda { |agent_id| true }}

    if options.has_key?(:scopes)
      options[:scopes].each do |name,membership_block|
        @scopes[name.to_s] = membership_block
      end
    end

    if options.has_key?(:features)
      options[:features].each do |feature|
        add_feature(feature)
      end
    end

    @warden = if options.has_key?(:warden)
      options[:warden]
    else
      lambda { |feature,agent_id|
        if agent_id
          active_globally?(feature) ||
            agent_id_in_active_scope?(feature, agent_id) ||
            agent_id_active?(feature, agent_id) ||
            agent_id_within_active_percentage?(feature, agent_id)
        else
          active_globally?(feature)
        end
      }
    end

    @info = if options.has_key?(:info)
      options[:info]
    else lambda { |feature|
        if feature
          {
            :percentage => (active_percentage(feature) || 0).to_i,
            :scopes     => active_scopes(feature).map { |g| g.to_sym },
            :agent_ids      => active_agent_ids(feature),
            :global     => active_global_features,
            :available_features => features
          }
        else
          {
            :global     => active_global_features,
            :available_features => features
          }
        end
      }
    end
  end

  def activate_globally(feature)
    @datastore.activate_globally(feature)
  end

  def deactivate_globally(feature)
    @datastore.deactivate_globally(feature)
  end

  def activate_scope(feature, scope)
    @datastore.activate_scope(feature, scope)
  end

  def deactivate_scope(feature, scope)
    @datastore.deactivate_scope(feature, scope)
  end

  def deactivate_all(feature)
    @datastore.deactivate_all(feature)
  end

  def activate_agent_id(feature, agent_id)
    @datastore.activate_agent_id(feature, agent_id)
  end

  def deactivate_agent_id(feature, agent_id)
    @datastore.deactivate_agent_id(feature, agent_id)
  end

  def active?(feature, agent_id = nil)
    @warden.call(feature,agent_id)
  end

  def activate_percentage(feature, percentage)
    @datastore.activate_percentage(feature, percentage)
  end

  def deactivate_percentage(feature)
    @datastore.deactivate_percentage(feature)
  end

  def features
    @datastore.features
  end

  def add_feature(feature)
    @datastore.add_feature(feature)
  end

  def info(feature = nil)
    @info.call(feature)
  end

  def active_scopes(feature)
    @datastore.active_scopes(feature)
  end

  def active_agent_ids(feature)
    @datastore.active_agent_ids(feature)
  end

  def active_global_features
    @datastore.active_global_features
  end

  def active_percentage(feature)
    @datastore.active_percentage(feature)
  end

  def active_globally?(feature)
    @datastore.active_globally?(feature)
  end

  def agent_id_in_active_scope?(feature, agent_id)
    active_scopes(feature).any? do |scope|
      @scopes.key?(scope) && @scopes[scope].call(agent_id)
    end
  end

  def agent_id_active?(feature, agent_id)
    @datastore.agent_id_active?(feature, agent_id)
  end

  def agent_id_within_active_percentage?(feature, agent_id)
    @datastore.agent_id_within_active_percentage?(feature, agent_id)
  end
end
