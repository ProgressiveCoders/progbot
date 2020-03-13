#= require active_admin/base
#= require active_admin/select2
$(document).ready ->
  $(".select2").select2()

  $('input:file').on 'change', ->
    if $(this).val()
      $('input:submit').removeAttr 'disabled'
    else
      $('input:submit').attr 'disabled', true
