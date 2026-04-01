admin_email = ENV.fetch("ADMIN_EMAIL")
admin_password = ENV.fetch("ADMIN_PASSWORD")

Admin::User.find_or_initialize_by(id: 1).tap do |admin|
  admin.email = admin_email

  if admin.new_record? || admin.encrypted_password.blank?
    admin.password = admin_password
    admin.password_confirmation = admin_password
  end

  admin.save!
end
