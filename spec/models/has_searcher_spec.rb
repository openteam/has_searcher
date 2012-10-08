require 'spec_helper'

describe HasSearcher do
  describe '.cacheble_now' do
    specify { HasSearcher.cacheble_now.should == 1.minute.since.change(:min => 0) }
  end
end
