class Cashier::ProductsController < ApplicationController
  def add_to_order
    @product = Product.find(params[:id])
    
    @order_item = current_order.order_items.build(product_id: params[:id])
    @order_item.quantity = 1
    @order_item.price = @product.price

    @order_item.save!

    render :json => {:id => @product.id, :category => @product.category, :zh_name => @product.zh_name, :price => @product.price, :upc => @product.upc}
  end
  
  
  def index
    @products = Product.all
  end
  
  def new
    
  end

  def import
    Product.update_by_file(params[:file])
    flash[:notice] = "成功匯入商品資訊"
    redirect_to cashier_products_path
  end
end