require_relative '../test_helper'
require 'hquery-patient-api'

class JSObjectTest < Test::Unit::TestCase

  def setup
  end

  def test_library_functions_with_crosswalk
    result = HQMF2JS::Generator::JS.library_functions(true)
    assert !result.match(/CROSSWALK EXTENSION/).nil?
    assert !result.match(/CrosswalkManager/).nil?
  end

  def test_js_initialize_specifics
    js = HQMF2JS::Generator::JS.new nil
    criteria = HQMF::DataCriteria.from_json(nil, JSON.parse(File.read(File.join('test','fixtures','json','data_criteria','specific_occurrence.json'))))
    expected = "hqmfjs.initializeSpecifics = function(patient_api, hqmfjs) { hqmf.SpecificsManager.initialize(patient_api,hqmfjs,{\"id\":\"\",\"type\":\"ENCOUNTER_PERFORMED_INPATIENT_ENCOUNTER\",\"function\":\"OccurrenceAInpatientEncounter1\"}) }"
    result = js.js_initialize_specifics([criteria])
    result.must_equal expected
  end

  def test_to_js_without_codes
  end


end