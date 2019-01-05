this.Projects || (this.Projects = {})

window.Projects =
  init_form: ->
    self = @
    $(document).ready(() ->
      self.init_skills("#project_tech_stack_names")
      self.init_skills("#project_non_tech_stack_names")
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
    $(input_id).on 'tokenfield:createtoken', (e) ->
      source = e.target.dataset.typeaheadSource
      hash = eval(source)
      skills = hash.map((x) ->
        x.value
      )
      skill = e.attrs.value
      if !skills.includes(skill)
        e.preventDefault()
        $('#modal-invalid-skill').modal keyboard: true
        return
    $(input_id).tokenfield(
      typeahead: [null, { source: engine.ttAdapter() }]
    )
