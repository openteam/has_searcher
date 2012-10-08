require 'spec_helper'

describe HasSearcher do
  describe '.cacheable_now' do
    specify { HasSearcher.cacheable_now.should == 1.minute.since.change(:sec => 0) }
  end
end
