Deface::Override.new(:virtual_path => "documents/index",
                     :name => "change_documents_index",
                     :insert_before => "erb[silent]:contains('content_for :sidebar')",
                     :original => 'f44a5806e3ffcdada08cc5e8a82a40febd332182',
                     :text => "<span class=\"pagination\"><%= pagination_links_full @entry_pages, @entry_count %></span>")
Deface::Override.new(:virtual_path => "documents/index",
                    :name => "change_documents_index_sort_by",
                    :original => '276eed496c1426f88b5a60efda7f6d80d026b1c1',
                    :insert_after => "erb[loud]:contains('l(:field_author)')",
                    # :text => '<%= render "overrides/documents/search" %>'
                    # :partial => 'overrides/documents/search'
                    :partial => 'overrides/documents/search'
                )
