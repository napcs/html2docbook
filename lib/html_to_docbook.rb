require 'nokogiri'

class HtmlToDocbook
  
  attr_accessor :doc
  
  def initialize(infile)
    infile = "<body>#{infile}</body>"
    self.doc = Nokogiri::XML(infile, &:noblanks)
  end
  
  def convert
    make_book
    structurize!
    create_admonishments
    rename_node "p", "para"
    rename_node "ol", "orderedlist"
    rename_node "ul", "itemizedlist"
    rename_node "li", "listitem"
    rename_node "em", "emphasis"
    fix_images
    fix_links
    fix_listitems
    make_pre_language_into_programlisting
    handle_pre_tags
    handle_custom_data_docbook_style_spans
    xsl_transform
  end
  
  def make_book
    body = doc.css("body").first
    body.name="book"
    body.set_attribute("version", "5.0")
    body.set_attribute("xmlns", "http://docbook.org/ns/docbook")
    body.set_attribute("xmlns:xlink", "http://www.w3.org/1999/xlink")
    body.set_attribute("xmlns:xi", "http://www.w3.org/2001/XInclude")
    body.set_attribute("xmlns:svg","http://www.w3.org/2000/svg")
    body.set_attribute("xmlns:mml","http://www.w3.org/1998/Math/MathML")
    body.set_attribute("xmlns:html","http://www.w3.org/1999/xhtml")
    body.set_attribute("xmlns:db","http://docbook.org/ns/docbook")
    
    title = body.children.first.add_previous_sibling Nokogiri::XML::Node.new("title", doc)
    title.add_child Nokogiri::XML::Text.new("My test book", doc)
  end

  # This supports customized PRE tags where a data-language attribute is attached.
  def make_pre_language_into_programlisting
    doc.css("pre[data-language]").each do |p|
      content = p.content
      p.content = nil
      p.add_child Nokogiri::XML::CDATA.new(doc, content)
      p.name = "programlisting"
    end
  end
  
  # This handles the rest of the pre tags in the document
  # It'll be <screen> by default, otherwise
  # it will use the value of data-docbook-verbatim.
  def handle_pre_tags
    doc.css("pre").each do |p|
      content = p.content
      p.content = nil
      if p.attributes["data-docbook-verbatim"].nil?
        p.name="screen"
      else
        p.name = p.attributes["data-docbook-verbatim"]
        p.remove_attribute("data-docbook-verbatim") 
      end
      p.add_child Nokogiri::XML::CDATA.new(doc, content)
      
    end
  end
  
  # converts to a hierarchy.
  # All h1 tags become chapters with titles
  # All h2-h6 become sect1-sect5 with titles
  # h1 ids transform to xml:id on the wrapper element
  def structurize!
    # Assuming doc is a Nokogiri::HTML::Document
    if body = doc.css('book').first then
      stack = []
      
      body.children.each do |node|
        # non-matching nodes will get level of 0
        level = node.name[ /h([1-6])/i, 1 ].to_i
        level = 99 if level == 0
  
        stack.pop while (top=stack.last) && top[:level]>=level
        stack.last[:div].add_child( node ) if stack.last
        if level<99
          if node.name == "h1"
            div = Nokogiri::XML::Node.new("chapter",doc)
          else
            div = Nokogiri::XML::Node.new("sect#{level -1}",doc)
          end
          div.set_attribute("xml:id", node.attr("id").to_s)
          node.remove_attribute("id")
          node.add_next_sibling(div)
          node.name="title"
          div.add_child(node)
          node.delete(node)
          stack << { :div=>div, :level=>level }
        end
      end
    

    end
  end
  
  def rename_node(old_name, new_name)
    doc.css(old_name).each do |node|
      node.name=new_name
    end
  end


  def handle_custom_data_docbook_style_spans
    doc.css("span[data-docbook-style]").each do |span|
      span.name = span.attributes['data-docbook-style']
      span.remove_attribute("data-docbook-style") 
    end
  end

  def create_admonishments
    doc.css("div[data-docbook-admonishment]").each do |ad|
      ad.name = ad.attributes["data-docbook-admonishment"]
      ad.css("h2").each do |title|
        title.name = "title"
      end
      ad.remove_attribute "data-docbook-admonishment"
      
    end
  end

  # Wrap listitem content in paragraphs
  def fix_listitems
    doc.css("listitem").each do |li|
      new_node = Nokogiri::XML::Node.new("para", doc)
      new_node.add_child Nokogiri::XML::Text.new(li.content, li)
      li.content = nil
      li.add_child new_node
    end
  end

  # converts an image into a figure with a mediaobject->screenshot->imageobject->imagedata structure
  def fix_images
    doc.css("img").each do |img|
      figure = Nokogiri::XML::Node.new("figure", doc)
      figure.set_attribute("xml:id", img.attr("id").to_s)
      
      title = figure.add_child(Nokogiri::XML::Node.new("title", doc))
      title.add_child Nokogiri::XML::Text.new(img.attr("title").to_s, doc)
  
      caption = figure.add_child(Nokogiri::XML::Node.new("caption", doc))
      caption.add_child Nokogiri::XML::Text.new(img.attr("alt").to_s, doc)
  
  
      ss = figure.add_child(Nokogiri::XML::Node.new("screenshot", doc))
      mo = ss.add_child(Nokogiri::XML::Node.new("mediaobject", doc))
      io = mo.add_child(Nokogiri::XML::Node.new("imageobject", doc))
      image = io.add_child(Nokogiri::XML::Node.new("imagedata", doc))
      image.set_attribute("fileref", img.attr("src").to_s)

      img.replace(figure)
    end
  end

  # convert anchors to link xlinks
  def fix_links
    doc.css("a").each do |link|
      new_node = Nokogiri::XML::Node.new("link", doc)
      new_node.set_attribute("xlink:href", link.attribute("href").text)
      new_node.add_child Nokogiri::XML::Text.new(link.content, link)
      link.add_next_sibling(new_node)
      link.remove
    end
  end
  
  def xsl_transform
    doc.to_xml(:indent => 4, :indent_text => " ")
  end
  
end