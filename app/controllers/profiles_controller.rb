class ProfilesController < ApplicationController
  def edit
    @user = current_user
  end

  def update
    @user = current_user
    if @user.update(profile_params)
      redirect_to edit_profile_path, notice: "Profile was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def profile_params
    if params[:user][:password].blank?
      params.require(:user).permit(:name, :email, :profile_image)
    else
      params.require(:user).permit(:name, :email, :profile_image, :password, :password_confirmation)
    end
  end
end
