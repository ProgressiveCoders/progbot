this.Projects || (this.Projects = {})

window.Projects =
  init_aligned_form: ->
    self = @
    $(document).ready(() ->
      self.init_collection("#project_tech_stack_names")
      self.init_collection("#project_non_tech_stack_names")
      self.init_collection("#project_needs_category_names")
      self.init_collection("#project_slack_channel")
    )
    return

  init_form: ->
    self = @
    $(document).ready(() ->
      self.init_collection("#project_tech_stack_names")
      self.init_collection("#project_non_tech_stack_names")
      self.init_collection("#project_needs_category_names")
    )
    return

  init_collection: (input_id, type) ->
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
      collection = hash.map((x) ->
        x.value
      )
      item = e.attrs.value
      # if !collection.includes(item)
      #   if e.target.id == "project_slack_channel"
      #     e.preventDefault()
      #     $('#modal-invalid-channel').modal keyboard: true
      #   else
      #     e.preventDefault()
      #     $('#modal-invalid-skill').modal keyboard: true
        
    $(input_id).tokenfield(
      typeahead: [null, { source: engine.ttAdapter() }]
    )
