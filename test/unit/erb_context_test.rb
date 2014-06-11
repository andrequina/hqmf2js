require_relative '../test_helper'

class ErbContextTest < Test::Unit::TestCase

  def setup
  end

  def test_data_criteria_js
    
    context = HQMF2JS::Generator::ErbContext.new({})

    criteria = HQMF::DataCriteria.from_json(nil, JSON.parse(File.read(File.join('test','fixtures','json','data_criteria','temporals_with_anynonnull.json'))))

    get_codes = context.js_for_code_list(criteria)
    get_codes.must_equal "getCodes(\"2.16.840.1.113883.3.117.1.7.1.23\")"
    criteria.instance_variable_set(:@code_list_id, nil)
    get_codes = context.js_for_code_list(criteria)
    get_codes.must_equal "null"

    date_bound = context.js_for_date_bound(criteria)
    date_bound.must_equal "MeasurePeriod.high.asDate()"

    criteria.temporal_references[0].instance_variable_set(:@type,"FOO")
    exception = assert_raise RuntimeError do
      context.js_for_date_bound(criteria)
    end
    exception.message.must_equal "do not know how to get a date for this type"
  end  

  def test_value_js
    context = HQMF2JS::Generator::ErbContext.new({})
    value = HQMF::Value.from_json({"type" => "ANYNonNull"})
    result = context.js_for_value(value)
    result.must_equal "new ANYNonNull()"

    
    value = HQMF::Value.from_json({"type"=>"SCALAR", "unit"=>"mm[Hg]", "value"=>"90", "inclusive?"=>false, "derived?"=>false } ) 
    result = context.js_for_value(value)
    result.must_equal "new SCALAR(90, \"mm[Hg]\", false)"

    value = HQMF::Value.from_json({"type"=>"SCALAR", "unit"=>nil, "value"=>"90", "inclusive?"=>true, "derived?"=>false } ) 
    result = context.js_for_value(value)
    result.must_equal "new SCALAR(\"90\", null, true)"

    value = HQMF::Value.from_json({"type"=>"SCALAR", "unit"=>nil, "value"=>"90", "inclusive?"=>nil, "derived?"=>false } )
    value.instance_variable_set(:@inclusive, nil)
    result = context.js_for_value(value)
    result.must_equal "new SCALAR(\"90\")"

  end

  def test_field_library_method
    context = HQMF2JS::Generator::ErbContext.new({})
    result = context.field_library_method('ADMISSION_DATETIME')
    result.must_equal "adjustBoundsForField"

    context = HQMF2JS::Generator::ErbContext.new({})
    result = context.field_library_method('FACILITY_LOCATION_ARRIVAL_DATETIME')
    result.must_equal "denormalizeEventsByLocation"
  end

  

end