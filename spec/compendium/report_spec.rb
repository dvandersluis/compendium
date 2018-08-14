require 'compendium/queries'

RSpec.describe Compendium::Report do
  subject { described_class }

  specify { expect(subject.queries).to be_empty }
  specify { expect(subject.options).to be_empty }

  it 'does not do anything when run' do
    report = subject.new
    report.run
    expect(report.results).to be_empty
  end

  context 'with multiple instances' do
    let(:report_class) do
      Class.new(Compendium::Report) do
        query :test
        metric :test_metric, -> {}, through: :test
      end
    end
    let(:report2) { report_class.new }

    subject { report_class.new }

    specify { expect(subject.queries).to_not equal report2.queries }
    specify { expect(subject.queries).to_not equal report_class.queries }
    specify { expect(subject.metrics).to_not equal report2.metrics }
  end

  describe '.report_name' do
    subject { TestReport = Class.new(described_class) }

    specify { expect(subject.report_name).to eq(:test) }
  end

  describe '#run' do
    context 'test' do
      let(:report_class) do
        Class.new(Compendium::Report) do
          option :first, :date
          option :second, :date

          query :test do |params|
            [params[:first].__getobj__, params[:second].__getobj__]
          end

          metric :lambda_metric, -> (results) { results.to_a.max }, through: :test
          metric(:block_metric, through: :test) { |results| results.to_a.max }
          metric(:implicit_metric) { [1, 2, 3].count }
        end
      end
      let!(:report2) { report_class.new }

      subject { report_class.new(first: '2010-10-10', second: '2011-11-11') }

      before do
        allow_any_instance_of(Compendium::Queries::Query).to receive(:fetch_results) { |_instance, c| c }
        subject.run
      end

      specify { expect(subject.test_results.records).to eq [Date.new(2010, 10, 10), Date.new(2011, 11, 11)] }

      it 'allows metric results to be accessed through a query' do
        expect(subject.test.metrics[:lambda_metric].result).to eq(Date.new(2011, 11, 11))
      end

      it 'runs its metrics defined as a lambda' do
        expect(subject.metrics[:lambda_metric].result).to eq(Date.new(2011, 11, 11))
      end

      it 'runs its metrics defined as a block' do
        expect(subject.metrics[:block_metric].result).to eq(Date.new(2011, 11, 11))
      end

      it 'runs its implicit metrics' do
        expect(subject.metrics[:implicit_metric].result).to eq(3)
      end

      it 'does not affect other instances of the report class' do
        expect(report2.test.results).to be_nil
        expect(report2.metrics[:lambda_metric].result).to be_nil
      end

      it 'does not affect the class collections' do
        expect(report_class.test.results).to be_nil
      end

      context 'with through queries' do
        let(:report_class) do
          Class.new(Compendium::Report) do
            option :first, :boolean, default: false
            query(:test) { |params| params[:first].value ? [100, 200, 400, 800] : [1600, 3200, 6400] }
            query(:through, through: :test) { |results| [results.first] }
          end
        end

        subject { report_class.new(first: true) }

        specify { expect(subject.through.results).to eq([100]) }

        it "does not mark other instances' queries as ran" do
          expect(report2.test).to_not have_run
        end

        it 'does not affect other instances' do
          report2.queries.each { |q| allow(q).to receive(:fetch_results) { |c| c } }
          report2.run
          expect(report2.through.results).to eq([1600])
        end
      end
    end

    context 'when specifying which queries to run' do
      let(:report_class) do
        Class.new(Compendium::Report) do
          query :first
          query :second
        end
      end

      subject { report_class.new }

      it 'raises an error if given both :only and :except options' do
        expect { subject.run(nil, only: :first, except: :second) }.to raise_error(ArgumentError)
      end

      it 'raises an error if given an invalid query name' do
        expect { subject.run(nil, only: :foo) }.to raise_error(ArgumentError)
      end

      it 'runs all queries if nothing is specified' do
        subject.run(nil)
        expect(subject.first).to have_run
        expect(subject.second).to have_run
      end

      context 'when :only is given' do
        it 'only run specified queries' do
          subject.run(nil, only: :first)
          expect(subject.first).to have_run
          expect(subject.second).to_not have_run
        end

        it 'allows multiple queries to be specified' do
          report_class.query(:third) {}
          subject.run(nil, only: [:first, :third])
          expect(subject.first).to have_run
          expect(subject.second).to_not have_run
          expect(subject.third).to have_run
        end

        it 'does not run through queries related to a query specified by only if not also specified' do
          report_class.query(:through, through: :first) {}
          subject.run(nil, only: :first)
          expect(subject.through).to_not have_run
        end

        it 'runs through queries related to a query specified by only if also specified' do
          report_class.query(:through, through: :first) {}
          subject.run(nil, only: [:first, :through])
          expect(subject.through).to have_run
        end
      end

      context 'when :except is given' do
        it 'does run queries specified by :except' do
          subject.run(nil, except: :first)
          expect(subject.first).to_not have_run
          expect(subject.second).to have_run
        end

        it 'allows multiple queries to be specified by :except' do
          report_class.query(:third) {}
          subject.run(nil, except: [:first, :third])
          expect(subject.first).to_not have_run
          expect(subject.second).to have_run
          expect(subject.third).to_not have_run
        end

        it 'does not run through queries related to a skipped query even if the main query is not excepted' do
          report_class.query(:through, through: :first) {}
          subject.run(nil, except: :through)
          expect(subject.through).to_not have_run
          expect(subject.first).to have_run
        end
      end
    end
  end

  context 'class name predicates' do
    before do
      OneReport = Class.new(described_class)
      TwoReport = Class.new(described_class)
      ThreeReport = Class.new
    end

    after do
      Object.send(:remove_const, :OneReport)
      Object.send(:remove_const, :TwoReport)
      Object.send(:remove_const, :ThreeReport)
    end

    it { is_expected.to respond_to(:one?) }
    it { is_expected.to respond_to(:two?) }
    it { is_expected.to_not respond_to(:three?) }

    it { is_expected.to_not be_one }
    it { is_expected.to_not be_two }

    specify { expect(OneReport).to be_one }
    specify { expect(TwoReport).to be_two }
  end

  describe 'parameters' do
    let(:report_class) { Class.new(subject) }
    let(:report_class2) { Class.new(report_class) }

    it 'includes ancestors params' do
      expect(report_class.params_class.ancestors).to include subject.params_class
    end

    it 'inherits validations' do
      report_class.params_class.validates :foo, presence: true
      expect(report_class2.params_class.validators_on(:foo)).to_not be_nil
    end
  end

  describe '#valid?' do
    context 'built-in validations' do
      let(:report_class) do
        Class.new(described_class) do
          option :id, :dropdown, choices: (0..10).to_a, validates: { presence: true }
        end
      end

      it 'returns true if there are no validation failures' do
        r = report_class.new(id: 5)
        expect(r).to be_valid
      end

      it 'returns false if there are validation failures' do
        r = report_class.new(id: nil)
        expect(r).to_not be_valid
        expect(r.errors.keys).to include :id
      end
    end

    context 'custom validation' do
      let(:report_class) do
        Class.new(described_class) do
          option :number, :scalar

          validate do
            errors.add(:number, :invalid_number) unless number.even?
          end
        end
      end

      it 'returns true if there are no validation failures' do
        r = report_class.new(number: 4)
        expect(r).to be_valid
      end

      it 'returns false if there are validation failures' do
        r = report_class.new(number: 5)
        expect(r).to_not be_valid
        expect(r.errors.keys).to include :number
      end
    end
  end

  describe '.filter' do
    let(:filter_proc) { -> (*) {} }

    let(:report_class) do
      Class.new(described_class) do
        query :main_query
      end
    end

    let(:subclass1) do
      k = Class.new(report_class)
      k.filter(:main_query, &filter_proc)
      k
    end

    let(:subclass2) { Class.new(report_class) }
    let(:subclass3) { Class.new(subclass1) }

    it 'adds filters to the specified query' do
      expect(subclass1.main_query.filters).to include filter_proc
    end

    it 'adds filters by inheritence' do
      expect(subclass3.main_query.filters).to_not be_empty
    end

    it 'does not bleed filters from a subclass into other subclasses' do
      subclass1
      expect(subclass2.main_query.filters).to be_empty
    end
  end

  describe '#exports?' do
    let(:report_class) do
      Class.new(described_class) do
        exports :csv, :main_query
        exports :pdf, false
      end
    end

    subject { report_class.new }

    it 'returns true if there is an export for the given type' do
      expect(subject).to be_exports(:csv)
    end

    it 'returns false if there is no export for the given type explicitly' do
      expect(subject).to_not be_exports(:pdf)
    end

    it 'returns false if there is no export for the given type implicitly' do
      expect(subject).to_not be_exports(:xls)
    end
  end

  describe '#method_missing' do
    let(:report_class) do
      Class.new(described_class) do
        option :foo, :scalar
        option :bar, :scalar
        query :my_query
      end
    end

    subject { report_class.new(foo: 123) }

    it 'returns a query if given a query name' do
      expect(subject.my_query).to eq(subject.queries[:my_query])
    end

    it 'returns query results if given a query_results' do
      subject.run
      expect(subject.my_query_results).to eql(subject.results[:my_query])
    end

    it 'returns the param value if given a param name' do
      expect(subject.foo).to eq(123)
    end

    it 'returns the param truthiness if given a param predicate' do
      expect(subject).to be_foo
      expect(subject).to_not be_bar
    end
  end

  describe '#respond_to_missing?' do
    let(:report_class) do
      Class.new(described_class) do
        option :foo, :scalar
        query :my_query
      end
    end

    subject { report_class.new }

    it 'accepts the name of a query' do
      expect(subject).to respond_to :my_query
    end

    it 'accepts the name of a query with _results' do
      expect(subject).to respond_to :my_query_results
    end

    it 'accepts the name of an option' do
      expect(subject).to respond_to :foo
    end

    it 'accepts the name of an option as a predicate' do
      expect(subject).to respond_to :foo?
    end

    it 'does not accept the name of an option with _results' do
      expect(subject).to_not respond_to :foo_results
    end

    it 'does not accept the name of a query as a predicate' do
      expect(subject).to_not respond_to :my_query?
    end
  end
end
