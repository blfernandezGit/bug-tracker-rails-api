class PhotosController < Api::V1::RootController
   before_action :get_ticket
      def create
         result = Cloudinary::Uploader.upload(params[:image])
         photo = Photo.create(ticket_id: @ticket.id, image: result['url'])
            if photo.save
               render json: photo
            else
               render json: photo.errors
            end
      end

      private

      # Use callbacks to share common setup or constraints between actions.
      def get_ticket
         @ticket = Ticket.find_by(ticket_no: params[:ticket_ticket_no],
                                 project_id: Project.find_by(code: params[:project_code]))
      end
end
