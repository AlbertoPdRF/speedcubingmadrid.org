class ApplicationController < ActionController::Base
  include ApplicationHelper

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  helper_method :current_user

  rescue_from ActiveRecord::RecordNotFound, with: -> { raise ActionController::RoutingError.new('Not Found') }

  def current_user
    begin
      @current_user ||= User.find(session[:user_id]) if session[:user_id]
    rescue Exception => e
      nil
    end
  end

  def authenticate_user!
    if !current_user
      session[:return_to] ||= request.original_url
      redirect_to signin_url
    end
  end

  def redirect_unless_admin!
    unless current_user&.admin?
      redirect_to root_url, :alert => 'Sólo los administradores tienen acceso a esta página.'
    end
  end

  def redirect_unless_authorized_delegate!
    unless current_user&.can_manage_delegate_matters?
      redirect_to root_url, :alert => 'Sólo los Delegados WCA tienen acceso a esta página.'
    end
  end

  def redirect_unless_comm!
    unless current_user&.can_manage_communication_matters?
      redirect_to root_url, :alert => 'Sólo los responsables de comunicación tienen acceso a esta página.'
    end
  end

  private :current_user, :authenticate_user!, :redirect_unless_admin!, :redirect_unless_authorized_delegate!
end
