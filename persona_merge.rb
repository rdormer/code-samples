def merge_personae(target_persona, new_persona, keep_list=[])

  new_persona.sections.each do |section|

    target_section = target_persona.sections.detect{|x| x.name == section.name}
 
    if target_section.nil?
      target_persona.sections << section
    else
      merge_sections(target_section, section, keep_list.include?(section.name))
    end
  end

  responses_uniq(target_persona, "expected_outcomes")
  responses_uniq(target_persona, "underwriting_decision_documents")
  responses_uniq(target_persona, "underwriting_decision_xml_documents")
end

def merge_sections(target, new_section, keep_responses=false)
  
  new_section.pairs.each do |pair|
   
    tpair = pair.clone

    target_pair = target.pairs.detect{|x| x.name == tpair.name}
    tresponses = (target_pair.nil? ? [] : target_pair.responses)
 
    new_responses = (keep_responses ? pair.responses + tresponses : [Response.new(name: ' ')])
    target_pair.destroy unless target_pair.nil?   
    tpair.responses.replace(new_responses)
    target.pairs << tpair
  end

  new_section.child_sections.each do |section|
    receiver = target.child_sections.detect{|x| x.name == section.name}
   
    if receiver.nil?
      target.child_sections << section.clone 
    else
      merge_sections(receiver, section, keep_responses)
    end
  end
end

def responses_uniq(target_persona, target_name)
  section = target_persona.sections.detect {|x| x.name == target_name}
  return if section.nil?

  kept = section.pairs.map(&:responses).flatten
  responses = kept.map(&:name).uniq
  section.pairs.clear

  responses.each do |new_response|
    new_pair = section.pairs.build
    new_pair.responses.build(name: new_response)
  end
end
