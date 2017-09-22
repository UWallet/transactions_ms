class TransactionsController < ApplicationController
  before_action :set_transaction, only: [:show]

  def error(message,code,description)
    render status: code, json:{
      message:message,
      code:code,
      description: description
    }
  end

  # GET /byuserid
  def byUserId
    if params[:userid]
      if !(Integer(params[:userid]) rescue false)
        error("Bad Request", 400, "Userid must be an Integer")
        return -1
      else
        @transactions= Transaction.all.where(useridgiving: params[:userid]) #send
        @transactions2= Transaction.all.where(useridreceiving: params[:userid]) #receive

        if @transactions.count == 0 && @transactions2.count ==0
          error("Not Found", 404, "The resource does not exist")
          return -1
        else
          render json: {total_send:@transactions.count,list_send:@transactions,total_receive: @transactions2.count, list_receive:@transactions2}
        end
      end
    else
      error("Not Acceptable (Invalid Params)", 406, "The parameter must be set like userid")
      return -1
    end
  end

  def byDate
    if params[:userid] && params[:days]
      cond = !(Integer(params[:userid]) rescue false)
      cond2 = !(Integer(params[:days])rescue false)
      cond3 = cond || cond2
      if cond3
        error("Bad Request", 400, "Userid and days must be an Integer")
        return -1
      else
        @transactions = Transaction.where("useridgiving = ? AND created_at >= ?",(params[:userid]).to_i , Time.now - (params[:days]).to_i.days) #send
        @transactions2 = Transaction.where("useridreceiving = ? AND created_at >= ?",(params[:userid]).to_i , Time.now - (params[:days]).to_i.days) #receive

        if @transactions.count == 0 && @transactions2.count ==0
          error("Not Found", 404, "The resource does not exist")
          return -1
        else
          render json: {total_send:@transactions.count,list_send:@transactions,total_receive: @transactions2.count, list_receive:@transactions2}
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
      error("Bad Request", 400, "Useridgiving and Useridreceiving must a Integer")
      return -1
    elsif !(Float(params[:amount]) rescue false)
      error("Bad Request", 400, "Price must be a Float")
      return -1
    else
      @transaction = Transaction.new(transaction_params)
    end

    if @transaction.save
      head 201
    else
      render json: @transaction.errors, status: :unprocessable_entity
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_transaction
      @transaction = Transaction.transactions_by_id(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def transaction_params
      params.require(:transaction).permit(:useridgiving, :useridreceiving, :amount)
    end
end
