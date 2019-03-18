module DocumentsControllerPatch
  def self.included(base)
    base.class_eval do
      def search(documents, search_params)
        documents = documents.where(id: CustomValue.where(custom_field_id: CustomField.where(id: search_params['cf-id']).ids, value: search_params['cf-value']).map(&:customized_id).uniq)
      end

      def index
        @custom_fields = CustomField.where(type: 'DocumentCustomField')
        Rails.logger.error params[:sort_by]
        @sort_by = (%w(category date title author).include?(params[:sort_by]) || (params.has_key?(:sort_by) && params[:sort_by].start_with?('cf-') && params[:sort_by].split('cf-')[1].to_i.in?(@custom_fields.ids) )) ? params[:sort_by] : 'category'
        documents = @project.documents
        documents = formPagination(documents)
        documents.includes(:attachments, :category).to_a
        if @sort_by.eql? 'date'
          @grouped = documents.group_by {|d| d.updated_on.to_date }
        elsif @sort_by.eql? 'title'
          @grouped = documents.group_by {|d| d.title.first.upcase}
        elsif @sort_by.eql? 'author'
          @grouped = documents.select{|d| d.attachments.any?}.group_by {|d| d.attachments.last.author}
        elsif @sort_by.start_with?("cf-")
          cf_num = @sort_by.split('cf-')[1].to_i
          @grouped = documents.group_by {|d| d.custom_field_value(cf_num)}
          # @grouped = documents.where(id: CustomValue.where(custom_field_id: CustomField.where(id: ).ids).ids).group_by {|d| d.custom_field_values}
        else
          @grouped = documents.group_by(&:category)
        end
        @document = @project.documents.build
        render :layout => false if request.xhr?
      end

      def formPagination(entries)
    		@entry_count = entries.count
            setLimitAndOffset()
    		@document = entries.order(:created_on).limit(@limit).offset(@offset)
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
