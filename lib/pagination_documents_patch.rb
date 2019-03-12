module DocumentsControllerPatch
  def self.included(base)
    base.class_eval do
      def index
        @sort_by = %w(category date title author).include?(params[:sort_by]) ? params[:sort_by] : 'category'
        documents = @project.documents.includes(:attachments, :category).to_a
        case @sort_by
        when 'date'
          @grouped = documents.group_by {|d| d.updated_on.to_date }
        when 'title'
          @grouped = documents.group_by {|d| d.title.first.upcase}
        when 'author'
          @grouped = documents.select{|d| d.attachments.any?}.group_by {|d| d.attachments.last.author}
        else
          @grouped = documents.group_by(&:category)
        end
        @document = @project.documents.build
        render :layout => false if request.xhr?
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
