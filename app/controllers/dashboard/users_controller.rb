class Dashboard::UsersController < UsersController
	layout 'dashboard_sidenav'

	def profile
		@user = current_user
	end
end