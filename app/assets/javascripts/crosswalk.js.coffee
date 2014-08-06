class @CrosswalkManager
  @matchedSystems: {}
  @trueMatchedSystems: {}
  @tmpTrueMatchedSystems: {}
  @clearValidateCodeSystemData: () ->
    CrosswalkManager.matchedSystems = {}
    CrosswalkManager.trueMatchedSystems = {}
    CrosswalkManager.tmpTrueMatchedSystems = {}

hQuery.Patient::validateCodeSystems = () ->
  sections = ['encounters','medications','conditions','procedures','results','vitalSigns','immunizations','allergies','pregnancies','socialHistories','careGoals','medicalEquipment','functionalStatuses']
  fullMatch = true
  for section in sections
    for entry in this[section]()
      matchedSystems = CrosswalkManager.matchedSystems[entry.id]
      if (matchedSystems? && _.keys(matchedSystems).length > 0)
        matches = _.keys(entry.json.codes).length == _.keys(matchedSystems).length
        fullMatch = fullMatch && matches
        Logger.info("#{entry.json['description']} -> #{_.keys(entry.json.codes)} != #{_.keys(matchedSystems)}") if !matches
      # trueMatchedSystems = CrosswalkManager.trueMatchedSystems[entry.id]
      # if (trueMatchedSystems? && _.keys(trueMatchedSystems).length > 0)
      #   matches = _.keys(entry.json.codes).length == _.keys(trueMatchedSystems).length
      #   fullMatch = fullMatch && matches
      #   Logger.info("TRUE MATCH: #{entry.json['description']} -> #{_.keys(entry.json.codes)} != #{_.keys(trueMatchedSystems)}") if !matches
  CrosswalkManager.clearValidateCodeSystemData()
  fullMatch

hQuery.CodedEntry::includesCodeFrom = (codeSet) ->
  allTrue = true
  oneTrue = false
  # tmpTrueMatchedSystems = {}
  matchedSystems = CrosswalkManager.matchedSystems[@id]
  for codedValue in @_type
    thisResult = codedValue.includedIn(codeSet)
    oneTrue = oneTrue || thisResult
    allTrue = allTrue && thisResult
    matchedSystems = {} unless matchedSystems?
    matchedSystems[codedValue.codeSystemName()] = true if (thisResult)
    # tmpTrueMatchedSystems[codedValue.codeSystemName()] = true if (thisResult)
  if (oneTrue && !allTrue)
    Logger.info("*** #{@json['description']}")
    for codedValue in @_type
      thisResult = codedValue.includedIn(codeSet)
      Logger.info("*** Logger is #{thisResult} for: #{Logger.toJson(codedValue)}")
  CrosswalkManager.matchedSystems[@id] = matchedSystems
  # CrosswalkManager.tmpTrueMatchedSystems[@id] = tmpTrueMatchedSystems
  oneTrue

instrumentTrueCrosswalk = (hqmfjs) ->
  # CrosswalkManager.clearValidateCodeSystemData()
  # _.each(_.functions(hqmfjs), (method) ->
  #   hqmfjs[method] = _.wrap(hqmfjs[method], (func) ->

  #     args = Array.prototype.slice.call(arguments,1)

  #     results = func.apply(this, args)
  #     tmp_results = results
  #     tmp_results = [results] unless _.isArray(tmp_results)

  #     _.each(tmp_results, (result) ->
  #       if result.json? && CrosswalkManager.tmpTrueMatchedSystems[result.id]?
  #         tmpTrueMatchedSystems = CrosswalkManager.tmpTrueMatchedSystems[result.id]
  #         CrosswalkManager.trueMatchedSystems[result.id] = {} unless CrosswalkManager.trueMatchedSystems[result.id]
  #         Logger.info("TRUE_MATCHED: #{result.json['description']} - #{_.keys(tmpTrueMatchedSystems)}!!!")
  #         _.each(_.keys(tmpTrueMatchedSystems), (key) ->
  #           CrosswalkManager.trueMatchedSystems[result.id][key] = CrosswalkManager.trueMatchedSystems[result.id][key] || tmpTrueMatchedSystems[key]
  #         )
  #     )
  #     results
  #   )
  # )
@instrumentTrueCrosswalk = instrumentTrueCrosswalk