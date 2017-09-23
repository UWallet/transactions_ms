class TransactionsController < ApplicationController
  before_action :set_transaction, only: [:show, :update]

  def error(message,code,description)
    render status: code, json:{
      message:message,
      code:code,
      description: description
    }
  end

  # GET /byuserid?userid={id}
  def byUserId
    if params[:userid]
      if !(Integer(params[:userid]) rescue false)
        error("Bad Request", 400, "Userid must be an Integer")
        return -1
      else
        @transactions = Transaction.all.where("useridgiving = ? AND useridreceiving != ?" , (params[:userid]).to_i, (params[:userid]).to_i) #send
        @transactions2 = Transaction.all.where("useridgiving != ? AND useridreceiving = ?" , (params[:userid]).to_i, (params[:userid]).to_i) #receive
        @transactions3 = Transaction.all.where(useridgiving: params[:userid], useridreceiving: params[:userid]) #load money

        if @transactions.count == 0 && @transactions2.count == 0 && @transactions3 == 0
          error("Not Found", 404, "The resource does not exist")
          return -1
        else
          render json: {
            total_send:@transactions.count,list_send:@transactions,
            total_receive: @transactions2.count, list_receive:@transactions2,
            total_load: @transactions3.count, list_load:@transactions3
          }
        end
      end
    else
      error("Not Acceptable (Invalid Params)", 406, "The parameter must be set like userid")
      return -1
    end
  end

# GET /bydate?userid={id}
  def byDate
    if params[:userid] && params[:days]
      cond = !(Integer(params[:userid]) rescue false)
      cond2 = !(Integer(params[:days])rescue false)
      cond3 = cond || cond2
      if cond3
        error("Bad Request", 400, "Userid and days must be an Integer")
        return -1
      else
        @transactions = Transaction.where("state = 'complete' AND useridgiving = ? AND useridreceiving != ? AND created_at >= ?", (params[:userid]).to_i , (params[:userid]).to_i , Time.now - (params[:days]).to_i.days) #send
        @transactions2 = Transaction.where("state = 'complete' AND useridgiving != ? AND useridreceiving = ? AND created_at >= ?", (params[:userid]).to_i , (params[:userid]).to_i , Time.now - (params[:days]).to_i.days) #receive
        @transactions3 = Transaction.where("state = 'complete' AND useridgiving = ? AND useridreceiving = ? AND created_at >= ?", (params[:userid]).to_i , (params[:userid]).to_i , Time.now - (params[:days]).to_i.days) #load money
        if @transactions.count == 0 && @transactions2.count == 0 && @transactions3 == 0
          error("Not Found", 404, "The resource does not exist")
          return -1
        else
          render json: {
            total_send:@transactions.count,list_send:@transactions,
            total_receive: @transactions2.count, list_receive:@transactions2,
            total_load: @transactions3.count, list_load:@transactions3
          }
        end
      end
    else
      error("Not Acceptable (Invalid Params)", 406, "The parameters must be set like userid and days")
      return -1
    end
  end

  # GET /transactions
  def index
    @transactions = Transaction.all
    count = Transaction.count
    if params[:firstResult] || params[:maxResult]
      if params[:firstResult] && !(Integer(params[:firstResult]) rescue false)
        error("Not Acceptable (Invalid Params)",406,"Attribute maxResult is not an Integer")
      elsif params[:firstResult] && (Integer(params[:firstResult])<=0 || Integer(params[:firstResult])>count)
        error("Not Acceptable (Invalid Params)",406,"Attribute maxResult is out of range")
      elsif params[:maxResult] && !(Integer(params[:maxResult]) rescue false)
        error("Not Acceptable (Invalid Params)",406,"Attribute maxResult is not an Integer")
      elsif params[:maxResult] && (Integer(params[:maxResult])>count || Integer(params[:maxResult])<=0)
        error("Not Acceptable (Invalid Params)",406,"Attribute maxResult is out of range")
      elsif params[:firstResult] && params[:maxResult]
        render json: {total:Integer(params[:maxResult])-Integer(params[:firstResult])+1,list:@transactions[Integer(params[:firstResult])-1,Integer(params[:maxResult])]}
      elsif params[:firstResult]
        render json: {total:count-Integer(params[:firstResult]),list:@transactions[Integer(params[:firstResult])-1,count]}
      elsif params[:maxResult]
        render json: {total:Integer(params[:maxResult]),list:@transactions[0,Integer(params[:maxResult])]}
      end
    else
      render json: {total:count,list:@transactions}
    end
  end

  # GET /transactions/1
  def show
    if !(Integer(params[:id]) rescue false)
      error("Not Acceptable (Invalid Params)", 406, "The parameter id is not an Integer")
      return -1
    end
    if(@transaction)
      render json: @transaction
    else
      error("Not Found", 404, "The resource does not exist")
    end
  end

  # POST /transactions
  def create
    cond = !(Integer(params[:useridgiving]) rescue false)
    cond2 = !(Integer(params[:useridreceiving])rescue false)
    cond3 = cond || cond2
    if cond3
      error("Bad Request", 400, "Useridgiving and Useridreceiving must be an Integer")
      return -1
    elsif !(Float(params[:amount]) rescue false)
      error("Bad Request", 400, "Price must be a Float")
      return -1
    else
      @transaction = Transaction.new(transaction_params)
    end

    if @transaction.save
      render json: @transaction, status: 201
    else
      render json: @transaction.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /transactions/1
  def update
    if params[:useridgiving] || params[:useridreceiving]
      cond = !(Integer(params[:useridgiving]) rescue false)
      cond2 = !(Integer(params[:useridreceiving])rescue false)
      cond3 = cond || cond2
      if cond3
        error("Not Acceptable (Invalid Params)", 406, "Useridgiving and Useridreceiving must be an Integer")
        return -1
      elsif !(Float(params[:amount]) rescue false)
        error("Not Acceptable (Invalid Params)", 406, "Price must be a Float")
        return -1
      else
        @transaction = Transaction.new(transaction_params)
      end
    end
    if(@transaction)
      if @transaction.update(transaction_params)
        head 204
      else
        render json: @transaction.errors, status: :unprocessable_entity
      end
    else
      error("Not Found", 404, "The resource does not exist")
    end

  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_transaction
      @transaction = Transaction.transactions_by_id(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def transaction_params
      params.require(:transaction).permit(:useridgiving, :useridreceiving, :amount, :state)
    end
end
