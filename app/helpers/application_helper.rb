module ApplicationHelper
  def flash_div(bootstrapped = true, opts = {})
    tag = opts.delete(:tag) || :div
    (opts[:class] ||= "") << (flash.blank? ? " d-none" : "")
    (flash.blank? ? [:notice, :alert, :warning] : flash).map do |k, v|
      content_tag(tag, flash[k], :class => bootstrap_alert_class(k, opts.dup))
    end.compact.join("\n").html_safe
  end
  
  def bootstrap_alert_class(key, opts = {})
    # debugger
    klass_name = %w(alert alert-dismissable)
    klass_name << case key.to_sym
    when :notice, :success
      "alert-success"
    when :alert, :error
      "alert-danger"
    when :info
      "alert-info"
    when :warning, :note
      "alert-warning"
    else
      ""
    end
    klass_name << opts.delete(:class)
    klass_name.compact.join(" ")
  end


end
