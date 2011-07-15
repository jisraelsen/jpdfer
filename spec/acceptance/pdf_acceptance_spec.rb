require 'spec_helper'

describe "Pdf Acceptance" do
  before(:each) do
    @pdf_folder_path = File.expand_path(File.join(File.dirname(__FILE__), '..', 'data'))
    pdf_path = File.join(@pdf_folder_path, 'simple_form.pdf')
    @pdf = Pdf.new(pdf_path)
    @values = {}
    @unfilled_fields = {
      :important_field => '',
      :unimportant_field => '',
      :semiimportant_field => '',
      :tuesday_field => '',
      :must_not_be_left_blank_field => ''
    }
    @filled_fields = {
      :important_field => "I am important",
      :unimportant_field => 'I am unimportant',
      :semiimportant_field => 'I am confused',
      :tuesday_field => 'Is it Tuesday already?',
      :must_not_be_left_blank_field => 'NOT BLANK'
    }
  end

  describe 'sanity check' do
    it 'should be sane' do
      69.should == 69
    end
  end

  describe '.new' do
    it 'should create new pdf' do
      @pdf.should_not be_nil
    end

    describe 'given missing file' do
      it 'should raise Errno::ENOENT (File Not Found)' do
        lambda { Pdf.new('derp.pdf') }.should raise_error(Errno::ENOENT)
      end
    end
  end

  describe '#fields' do
    it 'should return a hash of field name value pairs' do
      @pdf.fields.should == @unfilled_fields
    end
  end

  describe '#get_field' do
    it 'should return the field value' do
      @pdf.get_field(:important_field).should == ""
    end

    describe "with nonexistent field name" do
      it "should raise Pdf::NonexistentFieldError" do
        lambda { @pdf.get_field(:monkey) }.should raise_error(Pdf::NonexistentFieldError, /'monkey' field does not exist in form/)
      end
    end
  end

  describe '#set_field' do
    it 'should fill the field with given name with given value' do
      @pdf.set_field(:important_field, "I am important")
      @pdf.get_field(:important_field).should == "I am important"
    end

    it 'should return the value written to the field' do
      @pdf.set_field(:important_field, "I am important").should == 'I am important'
    end

    it 'should update field' do
      @pdf.set_field(:important_field, "I am important")
      @pdf.fields.should == {
        :important_field => 'I am important',
        :unimportant_field => '',
        :semiimportant_field => '',
        :tuesday_field => '',
        :must_not_be_left_blank_field => ''
      }
    end

    describe "with existing field name" do
      it "should not raise an error" do
      end
    end

    describe "with nonexistent field name" do
      it "should raise Pdf::NonexistentFieldError" do
        lambda { @pdf.set_field(:monkey, 'Spider') }.should raise_error(Pdf::NonexistentFieldError, /'monkey' field does not exist in form/)
      end
    end
  end

  describe '#set_fields' do
    it 'should fill the fields with given names with given values' do
      @pdf.set_fields(@filled_fields)
      @pdf.get_field(:important_field).should == "I am important"
      @pdf.get_field(:unimportant_field).should == 'I am unimportant'
      @pdf.get_field(:semiimportant_field).should == 'I am confused'
      @pdf.get_field(:tuesday_field).should == 'Is it Tuesday already?'
      @pdf.get_field(:must_not_be_left_blank_field).should == 'NOT BLANK'
    end

    it 'should update fields' do
      @pdf.set_field(:important_field, "I am important")
      @pdf.fields.should == {
        :important_field => 'I am important',
        :unimportant_field => '',
        :semiimportant_field => '',
        :tuesday_field => '',
        :must_not_be_left_blank_field => ''
      }
    end

    it 'should retun the set fields' do
      @pdf.set_fields(@filled_fields).should == @filled_fields
    end

    describe "with nonexistent field name" do
      it "should raise Pdf::NonexistentFieldError" do
        @filled_fields[:monkey] = "spider"
        lambda { @pdf.set_fields(@filled_fields) }.should raise_error(Pdf::NonexistentFieldError, /'monkey' field does not exist in form/)
      end
    end
  end

  describe '#save_as' do
    before(:each) do
      @new_path = File.join(@pdf_folder_path, 'simple_form_new.pdf')
      FileUtils.rm_f(@new_path)
    end

    after(:each) do
      FileUtils.rm_f(@new_path)
    end

    it 'should write the pdf to a new path' do
      @pdf.save_as(@new_path)

      new_pdf = Pdf.new(@new_path)
      new_pdf.fields.should == {
        :important_field => '',
        :unimportant_field => '',
        :semiimportant_field => '',
        :tuesday_field => '',
        :must_not_be_left_blank_field => ''
      }
    end

    it 'should save updated fields to the new file' do
      @pdf.set_field(:important_field, "I am important")
      @pdf.save_as(@new_path)

      new_pdf = Pdf.new(@new_path)
      new_pdf.get_field(:important_field).should == "I am important"
    end

    describe 'with a saved PDF' do
#       describe 'saving again' do
#         it "should raise IOError" do
#           @pdf.save_as(@new_path)
#           lambda { @pdf.save_as(@new_path) }.should raise_error(IOError, /not opened for writing/)
#         end
#       end

#       describe "#set_field" do
#         it "should raise IOError" do

#         end
#       end

#       describe "#set_fields" do
#         it "should raise IOError" do

#         end
#       end

#       describe 'saving a flattened PDF' do
#         it "should save the PDF flattened" do

#         end
#       end
    end
  end

  describe '#has_field?' do
    describe "with field name as symbol" do
      it 'should return true if the field exists' do
        @pdf.has_field?(:important_field).should be(true)
      end

      it 'should return false if the field does not' do
        @pdf.has_field?(:monkey).should be(false)
      end
    end

    describe "with field name as string" do
      it 'should return true if the field exists' do
        @pdf.has_field?("important_field").should be(true)
      end

      it 'should return false if the field does not' do
        @pdf.has_field?("monkey").should be(false)
      end
    end
  end

  describe '#has_form?' do
    describe 'given a pdf with a form' do
      it 'should return true' do
        @pdf.has_form?.should be(true)
      end
    end

    describe 'given a pdf without a form' do
      it 'should return false' do
        pdf = Pdf.new(File.join(@pdf_folder_path, 'flattened.pdf'))
        pdf.has_form?.should be(false)
      end
    end
  end

  # If you save_as twice, once with flatten false, once with flatten true, PDF doesn't appear to be flattened.
  # set_field returns some error if the form field is incorrect (e.g. setting a checkbox with something silly like 'monkey' or 'true' instead of 'Yes'
  # save_as returns *UNTESTED* if the PDF form is not valid
end
