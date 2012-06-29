require 'spec_helper'

describe Searcher do
  let(:searcher) do
    Searcher.new :entry do
      keywords :q

      property :published_at, :modificator => :greater_than

      scope :published do
        with :state, :published
      end
    end
  end

  subject { Sunspot.session }

  before { searcher.params = params }

  describe "#execute" do
    let(:params) { {} }

    before { searcher.scoped.execute }

    it { should be_a_search_for(Entry) }

    context 'q: test' do
      let(:params) { {q:'test'} }

      it { should have_search_params :keywords, 'test' }
    end

    context 'published_at_greater_than: now' do
      let(:date)   { DateTime.now }
      let(:params) { { :published_at_greater_than => date } }
      it { should have_search_params :with, Proc.new{ with(:published_at).greater_than(date) }  }
    end
  end

  describe 'scopes' do
    context '#published' do
      let(:params) { {q:'test'} }
      before { searcher.published.execute }

      it { should have_search_params :with, :state, :published }
      it { should have_search_params :keywords, 'test'}
    end
  end
end
