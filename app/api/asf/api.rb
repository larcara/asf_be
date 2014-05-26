  class Asf::API < Grape::API
    version 'v1',  using: :param
    format :json

    helpers do
      def current_user
        "luca"
      end

      def authenticate!
        error!('401 Unauthorized', 401) unless current_user
      end
    end
    resource :statuses do
      desc "Return root categories"
      get :main_categories do
        Item.where(ps: nil).with_size(cs: 1).map{|x| [x.id,x.name]}
      end

      desc "Import from KlikkaPromo"
      get :import_from_klikkapromo do
        x=KlikkaPromo.new()
        x.get_product(9000)
      end
    end
  end
