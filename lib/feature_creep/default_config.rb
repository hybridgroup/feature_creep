class FeatureCreep
	class DefaultConfig
		def self.info
			lambda { |creep,feature|
        if feature
          {
            :percentage => (creep.active_percentage(feature) || 0).to_i,
            :scopes     => creep.active_scopes(feature).map { |g| g.to_sym },
            :agent_ids      => creep.active_agent_ids(feature),
            :global     => creep.active_global_features,
            :available_features => creep.features
          }
        else
          {
            :global     => creep.active_global_features,
            :available_features => creep.features
          }
        end
      }

		end

		def self.warden
      lambda { |creep,feature,agent_id|
        if agent_id
          creep.active_globally?(feature) ||
            creep.agent_id_in_active_scope?(feature, agent_id) ||
            creep.agent_id_active?(feature, agent_id) ||
            creep.agent_id_within_active_percentage?(feature, agent_id)
        else
          creep.active_globally?(feature)
        end
      }
		end
	end
end