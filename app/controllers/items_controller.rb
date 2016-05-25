class ItemsController < ApplicationController

  def_param_group :auth_and_client_and_item do
    param :auth_token, String, desc: 'Client is logged in with auth token', required: true
    param :client_id, String, desc: 'The client who owns the item', required: true
    param :item_id, String, desc: 'The item being referenced', required: true
  end

  def_param_group :auth_and_client do
    param :auth_token, String, desc: 'Client is logged in with auth token', required: true
    param :client_id, String, desc: 'The client who owns the item', required: true
  end



  api :GET, '/clients/:client_id/items', 'Lists all items for a client'
  formats ['json']
  param_group :auth_and_client
  example <<-EOT
  Response:
  {
    
  }
  EOT
  def index
    @client = Client.find(session[:current_client_id])
    @items = @client.items.without_deleted.search(params[:search])
    @selected_category = params[:search]

    render :items, :layout => false if params[:skip_layout]

  end

  def new
  end

  def create
    @client = Client.find(session[:current_client_id])
    @item = Item.new(item_params)
    @item.client_id = session[:current_client_id]
    if @item.save
        @item.create_activity :create, owner: @client
        redirect_to items_path, notice: "Item was created."
    else
      render :new
    end
  end

  def show
    @item = Item.without_deleted.find(params[:id])
  end


  def update
    @client = Client.find(session[:current_client_id])
    @item = Item.find(params[:id])
    if @item.update_attributes(item_params)
      @item.create_activity :update, owner: @client
      redirect_to items_path, notice: "item details were updated."
    end
  end

  def destroy
    @client = Client.find(session[:current_client_id])
    @item = Item.find(params[:id])
    @item.create_activity :destroy, owner: @client
    @item.deleted_at = Time.now   #here we are soft deleting items in the database to still be able to use them in the activity feed
    @item.save
    redirect_to items_path, notice: "Item was destroyed."
  end

private

  def item_params
    params.permit(:name, :notes, :id_number, :status, :new, :category, :type, :color, :season, :size, :description, :price, :picture)
  end
end
