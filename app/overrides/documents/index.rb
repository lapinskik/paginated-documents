Deface::Override.new(:virtual_path => "documents/index",
                     :name => "change_documents_index",
                     :insert_before => "erb[silent]:contains('content_for :sidebar')",
                     :text => "<span class=\"pagination\"><%= pagination_links_full @entry_pages, @entry_count %></span>")
