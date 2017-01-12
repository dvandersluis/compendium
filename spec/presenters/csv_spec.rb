require 'compendium/presenters/csv'

describe Compendium::Presenters::CSV do
  let(:results) { double('Results', records: [{ group: 'A', one: 1, two: 2 }, { group: 'B', one: 3, two: 4 }], keys: [:group, :one, :two]) }
  let(:query) { double('Query', results: results, options: {}, table_settings: nil) }
  let(:presenter) { described_class.new(query) }

  before do
    query.stub(:pos) { raise caller.join("\n") }
  end

  before { I18n.stub(:t) { |key| key } }

  describe '#render' do
    it 'should return a CSV of the results' do
      presenter.render.should == "group,one,two\nA,1.00,2.00\nB,3.00,4.00\n"
    end

    it "should use the query's table settings" do
      query.stub(:table_settings).and_return(-> * { number_format '%0.0f' })
      presenter.render.should == "group,one,two\nA,1,2\nB,3,4\n"
    end

    it 'should output a total row if the query has totals' do
      query.results.records << { group: '', one: 4, two: 6 }
      query.options[:totals] = true
      presenter.render.should == "group,one,two\nA,1.00,2.00\nB,3.00,4.00\ntotal,4.00,6.00\n"
    end
  end
end
