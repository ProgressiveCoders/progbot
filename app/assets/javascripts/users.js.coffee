this.Users || (this.Users = {})

window.Users =
  init_form: ->
    self = @
    $(document).ready(() ->
      self.init_skills("#user_tech_skill_names")
      self.init_skills("#user_non_tech_skill_names")
    )
    return

  init_skills: (input_id) ->
    engine = new Bloodhound(
      local: $(input_id).data("typeahead-source")
      identify: (obj) ->
        obj.id
      datumTokenizer: (d) ->
        Bloodhound.tokenizers.whitespace d.value
      queryTokenizer: Bloodhound.tokenizers.whitespace
    )
    engine.initialize()
    $(input_id).tokenfield(
      typeahead: [null, { source: engine.ttAdapter() }]
    )
