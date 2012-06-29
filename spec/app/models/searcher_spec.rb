require 'spec_helper'

describe Searcher do
  let(:searcher) do
    Searcher.new :entry do
      keywords :q

      scope :published do
        with :status, :published
      end
    end
  end

  subject { Sunspot.session }

  describe "#execute" do
    let(:params) { {} }

    before { searcher.params = params }
    before { searcher.execute }

    it { should be_a_search_for(Entry) }

    context 'with q parameter' do
      let(:params) { {q:'test'} }

      it { should have_search_params :keywords, 'test' }
    end
  end

  describe 'scopes' do
    context '#published' do
      before { searcher.published }
      it { should have_search_params :with, :status, :published }
    end
  end
end
