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
    def results
      doc = "<h1>This is a test</h1>
      <h2>This is section 1</h2>
      <h3>This is section 2</h3>
      <h4>This is section 3</h4>
      "
      # convert and throw it back to nokogiri to test it
      Nokogiri::XML(HtmlToDocbook.new(doc).convert)
    end
    
    it "makes h1 tags chapter tags with titles" do
      results.css("chapter>title").text.should == "This is a test"
    end
    
    it "makes h2 tags after h1 tags into sect1s with titles" do
      results.css("chapter>sect1>title").text.should == "This is section 1"
    end
    
    it "makes h3 tags after h2 tags after h1 tags into sect2s with titles" do
      results.css("chapter>sect1>sect2>title").text.should == "This is section 2"
    end
  
    it "makes h4 tags after h3 tags after h2 tags after h1 tags into sect3s with titles" do
      results.css("chapter>sect1>sect2>sect3>title").text.should == "This is section 3"
    end
    
  end
  
  
  describe "straight conversion of tags" do
    it "converts p to para" do
      doc = "<p>This is a test</p>"
      results = HtmlToDocbook.new(doc).convert
      results.should include("<para>This is a test</para>")
    end  
  end
  
  
  describe "list items" do
    it "must have content wrapped in para tags" do
      doc = "<li>This is a test</li>"
      results = HtmlToDocbook.new(doc).convert
      results.should include("<listitem><para>This is a test</para></listitem>")
    end
  end
  
  describe "parsing custom docbook attributes" do
    
    it "does methodnames properly" do
      doc = "<span data-docbook-style='methodname'>Foo</span>"
      results = HtmlToDocbook.new(doc).convert
      results.should include("<methodname>Foo</methodname>")  
    end 
    
  end
  
  describe "verbatims" do
    it "does programlistings with data-docbook-verbatim" do
      doc = "<pre data-docbook-verbatim='programlisting'>Foo</pre>"
      results = HtmlToDocbook.new(doc).convert
      results.should include("<programlisting><![CDATA[Foo]]></programlisting>")  
    end
    
    it "does screen for pre tags without data-docbook-verbatim" do
      doc = "<pre>Foo</pre>"
      results = HtmlToDocbook.new(doc).convert
      results.should include("<screen><![CDATA[Foo]]></screen>")  
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
