require 'nokogiri'

class HtmlToDocbook
  
  attr_accessor :doc
  
  def initialize(infile)
    infile = "<body>#{infile}</body>"
    self.doc = Nokogiri::XML(infile)
    #infile = Nokogiri::HTML.parse(infile)
    #self.doc = Nokogiri::XML(infile.xpath("//body").first.to_s)
  end
  
  def convert
    make_book
    structurize!
    rename_node "p", "para"
    rename_node "ol", "orderedlist"
    rename_node "ul", "itemizedlist"
    rename_node "li", "listitem"
    rename_node "em", "emphasis"
    fix_images
    fix_links
    fix_listitems
    make_pre_language_into_programlisting
    make_pre_into_screen
    
    xsl_transform
  end
  
  def make_book
    body = doc.css("body").first
    body.name="book"
    title = body.children.first.add_previous_sibling Nokogiri::XML::Node.new("title", doc)
    title.add_child Nokogiri::XML::Text.new("My test book", doc)
  end

  
  def make_pre_language_into_programlisting
    doc.css("pre[language]").each do |p|
      content = p.content
      p.content = nil
      p.add_child Nokogiri::XML::CDATA.new(doc, content)
      p.name = "programlisting"
    end
  end
  
  def make_pre_into_screen
    doc.css("pre").each do |p|
      content = p.content
      p.content = nil
      p.add_child Nokogiri::XML::CDATA.new(doc, content)
      p.name = "screen"
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
    xsl = Nokogiri::XSLT(File.read("lib/pp.xsl"))
    xsl.apply_to(doc).to_s
  end
  
end