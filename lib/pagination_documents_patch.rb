module DocumentsControllerPatch
  def self.included(base)
    base.class_eval do
      def search(documents, search_params)
        documents = documents.where(id: CustomValue.where(custom_field_id: CustomField.where(id: search_params['cf-id']).ids, value: search_params['cf-value']).map(&:customized_id).uniq)
      end

      def prepare_document_custom_field_values(documents_ids)
        document_custom_fields = CustomField.where(type: 'DocumentCustomField').ids
        document_custom_fields_values = CustomValue.where(custom_field_id: document_custom_fields, customized_id: documents_ids).to_a
        @document_custom_fields_values_hash = document_custom_fields_values.to_a.group_by {|x| x['customized_id']}
      end

      def index
        @custom_fields = CustomField.where(type: 'DocumentCustomField')
        @sort_by = (%w(category date title author).include?(params[:sort_by]) || (params.has_key?(:sort_by) && params[:sort_by].start_with?('cf-') && params[:sort_by].split('cf-')[1].to_i.in?(@custom_fields.ids) )) ? params[:sort_by] : 'category'
        @entry_count = @project.documents.includes(:attachments, :category).count
        setLimitAndOffset
        if @sort_by.eql? 'date'
          @sorted = @project.documents.includes(:attachments, :category).order('attachments.created_on').offset(@offset).limit(@limit).to_a
        elsif @sort_by.eql? 'title'
          @sorted = @project.documents.includes(:attachments, :category).order(:title).offset(@offset).limit(@limit).to_a
        elsif @sort_by.eql? 'author'
          @sorted = @project.documents.includes(:attachments, :category).order('attachments.author_id').offset(@offset).limit(@limit).to_a
        elsif @sort_by.start_with?("cf-")
          cf_num = @sort_by.split('cf-')[1].to_i
          @sorted = @project.documents.joins("LEFT OUTER JOIN custom_values ON custom_values.customized_id = documents.id AND custom_values.custom_field_id = "+cf_num.to_s).order('custom_values.value').offset(@offset).limit(@limit).to_a
        else
          @sorted = @project.documents.includes(:attachments, :category).order(:category_id).offset(@offset).limit(@limit).to_a
        end
        @document = @project.documents.build
        prepare_document_custom_field_values(@sorted.map{|x| x['id']})
        render :layout => false if request.xhr?
      end

      def setLimitAndOffset
  			@entry_pages = Paginator.new @entry_count, per_page_option, params['page']
  			@limit = @entry_pages.per_page
  			@offset = @entry_pages.offset
      end

      def create
        @document = @project.documents.build
        @document.safe_attributes = params[:document]
        @document.save_attachments(params[:attachments])
        if @document.save
          render_attachment_warning_if_needed(@document)
          flash[:notice] = l(:notice_successful_create)
          if params[:continue]
            back_url = params[:back_url].to_s
            if back_url.present? && valid_url = validate_back_url(back_url)
              redirect_to(valid_url)
            else
              redirect_to project_documents_path(@project)
            end
          else
            redirect_to project_documents_path(@project)
          end
        else
          render :action => 'new'
        end
      end

    end
  end
end
