class UserInputValidator
  
  def validate_credentials_input(name,password)
    errors = []
    if name.empty?
      errors << "Name blank"
    end
    if password.empty?
      errors << "Password blank"
    end
    errors
  end

end