require 'spec_helper'

describe Searcher do
  let(:searcher) do
    Searcher.new :entry do
      keywords :q
      #with :status, :published
    end
  end

 describe "#execute" do
   subject { Sunspot.session }

   let(:params) { {} }

   before { searcher.params = params }
   before { searcher.execute }

   it { should be_a_search_for(Entry) }

   context "with q parameter" do
     let(:params) { {q:'test'} }

     it { should have_search_params :keywords, 'test' }
   end
 end
end
