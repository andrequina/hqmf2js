module HQMF2JS
  class Converter
    def self.generate_map_reduce(hqmf_contents, codes=nil)
      # First compile the CoffeeScript that enables our converted HQMF JavaScript
      hqmf_utils = HQMF2JS::Generator::JS.library_functions

      if !codes
        # Parse the code systems that are mapped to the OIDs we support
        codes_file_path = File.expand_path("../../../test/fixtures/codes/codes.xml", __FILE__)
        codes = HQMF2JS::Generator::CodesToJson.from_xml(codes_file_path)
      end
      codes_json = HQMF2JS::Generator::CodesToJson.hash_to_js(codes)

      # Convert the HQMF document included as a fixture into JavaScript
      converter = HQMF2JS::Generator::JS.new(hqmf_contents)
      data_criteria_code = converter.js_for_data_criteria
      population_criteria_code = HQMF::PopulationCriteria::ALL_POPULATION_CODES.collect do |code|
        converter.js_for(code, nil, true)
      end
      converted_hqmf = [
        data_criteria_code,
        population_criteria_code.join("\n")
      ].join("\n")
      
      # Pretty stock map/reduce functions that call out to our converted HQMF code stored in the functions variable
      map = "function map(patient) {
  var ipp = hqmfjs.IPP(patient);
  if (hqmf.SpecificsManager.validate(ipp)) {
    emit('ipp', 1);
    if (hqmf.SpecificsManager.validate(hqmfjs.DENEX(patient), ipp)) {
      emit('denex', 1);    
    } else {
      var denom = hqmfjs.DENOM(patient);
      if (hqmf.SpecificsManager.validate(denom, ipp)) {
        if (hqmf.SpecificsManager.validate(hqmfjs.NUMER(patient), denom, ipp)) {
          emit('denom', 1);
          emit('numer', 1);
        } else if (hqmf.SpecificsManager.validate(hqmfjs.DENEXCEP(patient), denom, ipp)) {
          emit('excep', 1);
        } else {
          emit('denom', 1);
          emit('antinum', 1);
        }
      }
    }
  }
};"
      reduce = "function reduce(bucket, counts) {
  var sum = 0;
  while(counts.hasNext()){
    sum += counts.next();
  }
  return sum;
};"
      functions = "#{hqmf_utils}\nvar OidDictionary = #{codes_json};\n#{converted_hqmf}"

      return { :map => map, :reduce => reduce, :functions => functions }
    end
  end
end