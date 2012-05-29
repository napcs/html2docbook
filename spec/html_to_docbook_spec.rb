require_relative 'spec_helper'
describe HtmlToDocbook do
  describe "loading the document" do
    it "parses the html into a document" do
      h = HtmlToDocbook.new("<h1>test</h1>")
      h.doc.should be_a Nokogiri::XML::Document
    end
    it "gracefully handles malformed HTML" do
      h = HtmlToDocbook.new("<h1>Woo</h2>")
      h.doc.should be_a Nokogiri::XML::Document
    end
  end
  
  describe "hierarchy" do
  
    it "makes h1 tags chapter tags with titles" do
      doc = "<h1>This is a test</h1>"
      results = HtmlToDocbook.new(doc).convert
      results.should include("<chapter")
      results.should include("<title>This is a test</title>")
    end
  
  end
  
  describe "parsing custom docbook attributes" do
    
    it "does methodnames properly" do
      doc = "<span data-docbook-style='methodname'>Foo</span>"
      results = HtmlToDocbook.new(doc).convert
      results.should include("<methodname>Foo</methodname>")  
    end 
    
    it "does programlistings with data-docbook-style" do
      doc = "<pre data-docbook-style='programlisting'>Foo</pre>"
      results = HtmlToDocbook.new(doc).convert
      results.should include("<programlisting>Foo</programlisting>")  
    end
    
    it "does screen for pre tags without data-docbook-style" do
      doc = "<pre>Foo</pre>"
      results = HtmlToDocbook.new(doc).convert
      results.should include("<screen>Foo</screen>")  
    end
    
  end
  describe "admonishments" do
    it "creates sidebars with titles" do
      doc = "<h1>Chapter one</h1><h2>section one</h2><div data-docbook-admonishment='sidebar'><h2>This is a test</h2><p>This is a para</p></div>"
      results = HtmlToDocbook.new(doc).convert
      results.should include("<sidebar>")
      results.should include("<title>This is a test</title>")
      results.should_not include("<h2>")
      results.should_not include("<div>")
    end
  end
  
  
  
  
end
