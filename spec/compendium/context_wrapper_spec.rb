require 'compendium/context_wrapper'

class Wrapper1
  def test_val
    123
  end
end

class Wrapper2
  def wrapped
    true
  end
end

class Wrapper3
  def wrapper_num
    3
  end
end

class Wrapper4
  def wrapper_num
    4
  end
end

describe Compendium::ContextWrapper do
  describe '.wrap' do
    let(:w1) { Wrapper1.new }
    let(:w2) { Wrapper2.new }
    let(:w3) { Wrapper3.new }
    let(:w4) { Wrapper4.new }

    subject { described_class.wrap(w2, w1) }

    it { is_expected.to respond_to :test_val }
    it { is_expected.to respond_to :wrapped }

    specify { expect(subject.test_val).to eq(123) }
    specify { expect(subject.wrapped).to eq(true) }

    it 'should not affect the original objects' do
      subject
      expect(w1).not_to respond_to :wrapped
      expect(w2).not_to respond_to :test_val
    end

    it 'should yield a block if given' do
      expect(described_class.wrap(w2, w1) { test_val }).to eq(123)
    end

    context 'overriding methods' do
      subject { described_class.wrap(w4, w3) }
      specify { expect(subject.wrapper_num).to eq(4) }
    end

    context 'nested wrapping' do
      let(:inner) { described_class.wrap(w2, w1) }
      subject { described_class.wrap(inner, w3) }

      it { is_expected.to respond_to :test_val }
      it { is_expected.to respond_to :wrapped }
      it { is_expected.to respond_to :wrapper_num }

      it 'should not extend the inner wrap' do
        subject
        expect(inner).not_to respond_to :wrapper_num
      end
    end
  end
end
