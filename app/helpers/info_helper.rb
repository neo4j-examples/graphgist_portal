module InfoHelper
  ADOC_LOAD_OPTIONS = {
    attributes: ['experimental', 'env-guide'].freeze,
    header_footer: true,
    safe: 0,
    template_dir: Rails.root.join('graph_guide_templates').to_s
  }

  def graph_guide_parts_for(graph_gist)
    # html_doc = Nokogiri::HTML(graph_gist.html)
    # slide_level = (1..6).find { |i| html_doc.xpath("//h#{i}").size > 1 } - 1

    # Flatten headers
    adoc_text = graph_gist.asciidoc.gsub(/^=+ /, '== ')

    adoc = Asciidoctor.load(adoc_text, ADOC_LOAD_OPTIONS)

    if adoc.blocks[0] != adoc.sections[0]
      end_of_header_position = adoc_text.index(/(\r|\n|\r\n){2}/)
      spliced_text = adoc_text[0, end_of_header_position] + "\n\n== #{adoc.doctitle}" + adoc_text[end_of_header_position..-1]
      adoc = Asciidoctor.load(spliced_text, ADOC_LOAD_OPTIONS)
    end

    # adoc.convert # Why do I need to do this?  No idea...
    # adoc.set_attribute('slide_level', slide_level.to_s)
    adoc.convert
  end
end
