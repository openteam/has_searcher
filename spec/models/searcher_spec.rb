require 'spec_helper'

describe Searcher do
  let(:searcher) do
    Searcher.new do
      models :entry

      keywords :q

      property :published_at, :modificator => :greater_than
      property :categories

      scope :published do |sunspot|
        sunspot.with :state, :published
      end

      scope do |sunspot|
        categories_filter = sunspot.with(:categories, search_object.categories)
        sunspot.facet :categories, :exclude => categories_filter
      end
    end
  end

  subject { Sunspot.session }

  let(:params) { {} }

  before { searcher.search_object.attributes = params }

  describe "#execute" do

    before { searcher.scoped.execute }

    it { should be_a_search_for(Entry) }

    context 'q: test' do
      let(:params) { {q:'test'} }

      it { should have_search_params :keywords, 'test' }
    end

    context 'published_at_greater_than: now' do
      let(:date)   { DateTime.now }
      let(:params) { { :published_at_greater_than => date } }
      it { should have_search_params :with, Proc.new{ with(:published_at).greater_than(date) } }
    end
  end

  describe '#search_object' do
    let(:params) { {:q => 'test'} }
    subject { searcher.search_object }
    it { should respond_to :published_at_greater_than }
    it { should respond_to :q }
    its(:q) { should == 'test' }
  end

  describe 'scopes' do
    context '#published' do
      let(:params) { {q:'test'} }
      before { searcher.published.execute }

      it { should have_search_params :with, :state, :published }
      it { should have_search_params :keywords, 'test'}
    end
  end

  describe 'facets' do
    let(:params) { {:categories => ['One', 'Two']} }
    before { searcher.execute }
    it do
      should have_search_params :facet, Proc.new {
        category_filter = with(:categories, ['One', 'Two'])
        facet :categories, :exclude => category_filter
      }
    end
  end
end
