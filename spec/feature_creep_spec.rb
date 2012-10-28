require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "FeatureCreep" do
  before do
    @datastore = FeatureCreep::RedisDataStore.new
    scopes = {
      :fivesonly => lambda { |agent_id| agent_id == 5 }
    }
    @feature_creep = FeatureCreep.new(@datastore, {:scopes => scopes, :features => [:test1, :test2]})
  end

  describe ".new" do
    it "sets features" do
      @feature_creep.features.should == [:test1, :test2]
    end

    it "sets @scopes" do
      @feature_creep.scopes['fivesonly'].should be_a Proc
    end

    it "sets @info" do
      @feature_creep.info.should be_a Hash
    end

    it "sets @warden" do
      @feature_creep.warden.should be_a Proc
    end
  end

  describe "when a scope is activated" do
    before do
      @feature_creep.activate_scope(:chat, :fivesonly)
    end

    it "the feature is active for agent_ids for which the block evaluates to true" do
      @feature_creep.should be_active(:chat, 5)
    end

    it "is not active for agent_ids for which the block evaluates to false" do
      @feature_creep.should_not be_active(:chat, 1)
    end

    it "is not active if a scope is found in Redis but not defined in FeatureCreep" do
      @feature_creep.activate_scope(:chat, :fake)
      @feature_creep.should_not be_active(:chat, 1)
    end
  end

  describe "the default all scope" do
    before do
      @feature_creep.activate_scope(:chat, :all)
    end

    it "evaluates to true no matter what" do
      @feature_creep.should be_active(:chat, 0)
    end
  end

  describe "deactivating a scope" do
    before do
      @feature_creep.activate_scope(:chat, :all)
      @feature_creep.activate_scope(:chat, :fivesonly)
      @feature_creep.deactivate_scope(:chat, :all)
    end

    it "deactivates the rules for that scope" do
      @feature_creep.should_not be_active(:chat, 10)
    end

    it "leaves the other scopes active" do
      @feature_creep.should be_active(:chat, 5)
    end
  end

  describe "deactivating a feature completely" do
    before do
      @feature_creep.activate_scope(:chat, :all)
      @feature_creep.activate_scope(:chat, :fivesonly)
      @feature_creep.activate_agent_id(:chat, 51)
      @feature_creep.activate_percentage(:chat, 100)
      @feature_creep.activate_globally(:chat)
      @feature_creep.deactivate_all(:chat)
    end

    it "removes all of the scopes" do
      @feature_creep.should_not be_active(:chat, 0)
    end

    it "removes all of the agent_ids" do
      @feature_creep.should_not be_active(:chat, 51)
    end

    it "removes the percentage" do
      @feature_creep.should_not be_active(:chat, 24)
    end

    it "removes globally" do
      @feature_creep.should_not be_active(:chat)
    end
  end

  describe "activating a specific agent_id" do
    before do
      @feature_creep.activate_agent_id(:chat, 42)
    end

    it "is active for that agent_id" do
      @feature_creep.should be_active(:chat, 42)
    end

    it "remains inactive for other agent_ids" do
      @feature_creep.should_not be_active(:chat, 24)
    end
  end

  describe "deactivating a specific agent_id" do
    before do
      @feature_creep.activate_agent_id(:chat, 42)
      @feature_creep.activate_agent_id(:chat, 24)
      @feature_creep.deactivate_agent_id(:chat, 42)
    end

    it "that agent_id should no longer be active" do
      @feature_creep.should_not be_active(:chat, 42)
    end

    it "remains active for other active agent_ids" do
      @feature_creep.should be_active(:chat, 24)
    end
  end

  describe "activating a feature globally" do
    before do
      @feature_creep.activate_globally(:chat)
    end

    it "activates the feature" do
      @feature_creep.should be_active(:chat)
    end
  end

  describe "activating a feature for a percentage of agent_ids" do
    before do
      @feature_creep.activate_percentage(:chat, 20)
    end

    it "activates the feature for that percentage of the agent_ids" do
      (1..120).select { |id| @feature_creep.active?(:chat, id) }.length.should == 39
    end
  end

  describe "activating a feature for a percentage of agent_ids" do
    before do
      @feature_creep.activate_percentage(:chat, 20)
    end

    it "activates the feature for that percentage of the agent_ids" do
      (1..200).select { |id| @feature_creep.active?(:chat, id) }.length.should == 40
    end
  end

  describe "activating a feature for a percentage of agent_ids" do
    before do
      @feature_creep.activate_percentage(:chat, 5)
    end

    it "activates the feature for that percentage of the agent_ids" do
      (1..100).select { |id| @feature_creep.active?(:chat, id) }.length.should == 5
    end
  end


  describe "deactivating the percentage of agent_ids" do
    before do
      @feature_creep.activate_percentage(:chat, 100)
      @feature_creep.deactivate_percentage(:chat)
    end

    it "becomes inactivate for all agent_ids" do
      @feature_creep.should_not be_active(:chat, 24)
    end
  end

  describe "deactivating the feature globally" do
    before do
      @feature_creep.activate_globally(:chat)
      @feature_creep.deactivate_globally(:chat)
    end

    it "becomes inactivate" do
      @feature_creep.should_not be_active(:chat)
    end
  end

  describe "#info" do
    context "global features" do
      let(:features) { [:signup, :chat, :table] }
      let(:available_features) { [:chat, :test1, :signup, :test2, :table] }

      before do
        features.each do |f|
          @feature_creep.activate_globally(f)
        end
      end

      it "returns all global features" do
        @feature_creep.info.should eq({ :global => features.reverse, :available_features => available_features })
      end
    end

    describe "with a percentage set" do
      before do
        @feature_creep.activate_percentage(:chat, 10)
        @feature_creep.activate_scope(:chat, :caretakers)
        @feature_creep.activate_scope(:chat, :greeters)
        @feature_creep.activate_globally(:signup)
        @feature_creep.activate_agent_id(:chat, 42)
      end

      it "returns info about all the activations" do
        @feature_creep.info(:chat).should == {
          :percentage => 10,
          :scopes     => [:greeters, :caretakers],
          :agent_ids      => ["42"],
          :global     => [:signup],
          :available_features => [:chat, :test1, :signup, :test2]
        }
      end
    end

    describe "without a percentage set" do
      it "defaults to 0" do
        @feature_creep.info(:chat).should == {
          :percentage => 0,
          :scopes     => [],
          :agent_ids      => [],
          :global     => [],
          :available_features=>[:test1, :test2]
        }
      end
    end
  end
end
