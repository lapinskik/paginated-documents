require 'redmine'
require 'pagination_documents_patch'

Redmine::Plugin.register :paginated_documents do
  name 'Paginated Documents plugin'
  author 'Krystian Łapiński'
  description 'This is a plugin for Redmine that adds pagination to documents'
  version '0.0.1'
  url 'https://github.com/lapinskik/paginated-documents'
  author_url 'https://github.com/lapinskik'
end

Rails.configuration.to_prepare do
  DocumentsController.send(:include, DocumentsControllerPatch)
end
