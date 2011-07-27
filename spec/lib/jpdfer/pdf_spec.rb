require 'spec_helper'


# IMPORTANT: These are model/unit specs! Test in isolation as much as possible!
describe Pdf do
  before(:each) do
    @data_path = File.join(JPDFER_ROOT, 'spec', 'data')
    @pdf_path = File.join(@data_path, 'simple_form.pdf')
    @pdf = Pdf.new(@pdf_path)
  end

  describe 'sanity check' do
    it 'should be sane' do
      42.should == 42
    end
  end

  describe '.new' do
    it 'should create new pdf' do
      @pdf.should_not be_nil
    end
  end
end
