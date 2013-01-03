class FeatureCreep

  attr_accessor :scopes, :info, :warden

  def initialize(datastore, warden, info, options = {})
    @datastore = datastore
    @warden = warden
    @info = info
    @scopes = {"all" => lambda { |individual| true }}

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
  end

  # Activate Methods
  def activate_globally(feature)
    add_feature(feature)
    @datastore.activate_globally(feature)
  end

  def activate_scope(feature, scope)
    add_feature(feature)
    @datastore.activate_scope(feature, scope)
  end

  def activate_individual(feature, individual)
    add_feature(feature)
    @datastore.activate_individual(feature, individual)
  end

  def activate_percentage(feature, percentage)
    add_feature(feature)
    @datastore.activate_percentage(feature, percentage)
  end

  # Deactivate Methods
  def deactivate_globally(feature)
    @datastore.deactivate_globally(feature)
  end

  def deactivate_scope(feature, scope)
    @datastore.deactivate_scope(feature, scope)
  end

  def deactivate_individual(feature, individual)
    @datastore.deactivate_individual(feature, individual)
  end

  def deactivate_percentage(feature)
    @datastore.deactivate_percentage(feature)
  end

  def deactivate_all(feature)
    @datastore.deactivate_all(feature)
  end

  # Reporting Methods
  def active_scopes(feature)
    @datastore.active_scopes(feature)
  end

  def active_individuals(feature)
    @datastore.active_individuals(feature)
  end

  def active_global_features
    @datastore.active_global_features
  end

  def active_percentage(feature)
    @datastore.active_percentage(feature)
  end

  # Boolean Methods
  def active?(feature, individual = nil)
    @warden.call(self,feature,individual)
  end

  def active_globally?(feature)
    @datastore.active_globally?(feature)
  end

  def individual_in_active_scope?(feature, individual)
    active_scopes(feature).any? do |scope|
      @scopes.key?(scope) && @scopes[scope].call(individual)
    end
  end

  def individual_active?(feature, individual)
    @datastore.individual_active?(feature, individual)
  end

  def individual_within_active_percentage?(feature, individual)
    @datastore.individual_within_active_percentage?(feature, individual)
  end

  # Utility Methods
  def features
    @datastore.features
  end

  def add_feature(feature)
    @datastore.add_feature(feature)
  end

  def remove_feature(feature)
    @datastore.remove_feature(feature)
  end

  def info(feature = nil)
    @info.call(self,feature)
  end
end
