Deface::Override.new(:virtual_path => "documents/_form",
                     :name => "change_documents_form",
                     :original => '7db7ec63f500d8a3648fddad01335a374a6ebf44',                     
                     :insert_after => "erb[loud]:contains('f.text_field')",
                     :text => "<%= hidden_field_tag 'back_url', params[:back_url], :id => nil if params[:back_url].present? %><%= hidden_field_tag 'continue', params[:continue], :id => nil if params[:continue].present? %>")
