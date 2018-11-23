# lib/tasks/store_name.rake
namespace :import do
  desc 'Importing the store name for existing users'

  task :store_name => :environment do
    Provider.all.each do |provider|
      provider.user.update(store_name: "bundle")
      provider.customers.each do |customer|
        customer.update(store_name: provider.slug)
      end
    end
  end
end
