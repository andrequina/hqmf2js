module HQMF2JS
  module Generator
    class CodesToJson      

      
      def self.hash_to_js(hash)
        hash.to_json.gsub(/\"/, "'")
      end
      
      def self.from_value_sets(value_sets)
        # make sure we have a string keyed hash
        translation = {}
        value_sets.each do |value_set|
          code_sets = {}
          value_set.concepts.each do |code_set|
            code_sets[code_set.code_system_name] ||= []
            code_sets[code_set.code_system_name] << code_set.code
          end
          
          translation[value_set.oid] = code_sets
        end
        
        translation
      end
      
      # Create a new Nokogiri::XML::Document instance by parsing at file at the supplied path
      # from an IHE SVS XML document then converts into a JSON format. The original XML is of the format:
      #
      # Originally formatted like this:
      # <CodeSystems>
      #   <ValueSet id="2.16.840.1.113883.3.464.1.14" displayName="birth date">
      #     <ConceptList xml:lang="en-US">
      #       <Concept code="00110" codeSystemName="HL7" displayName="Date/Time of birth (TS)"
      
      #         codeSystemVersion="3"/>
      #      </ConceptList>
      #   </ValueSet>
      # </CodeSystems>
      #
      # The translated JSON will be in this structure:
      # {
      #   '2.16.840.1.113883.3.464.1.14' => {
      #                                       'HL7' => [ 00110 ]
      #                                     }
      # }
      def self.from_xml(code_systems_file)
        doc = HQMF2JS::Generator::CodesToJson.parse(code_systems_file)
        translation = {}
        doc.xpath('//ValueSet').each do |set|
          set_list = {}
          set_id = set.at_xpath('@id').value
            
          set.xpath('ConceptList').each do |list|
            list.xpath('Concept').each do |concept|
              system = concept.at_xpath('@codeSystemName').value
              code = concept.at_xpath('@code').value
              
              codes = set_list[system] || []
              codes << code
              set_list[system] = codes
            end
          end
          
          translation[set_id] = set_list
        end
        
        translation
      end
      
      # Parse an XML document at the supplied path
      # @return [Nokogiri::XML::Document]
      def self.parse(path)
        doc = Nokogiri::XML(File.new(path))
      end
      
    end
  end
end
