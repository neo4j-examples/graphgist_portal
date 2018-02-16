class ForceCreateUserRememberTokenIndex < Neo4j::Migrations::Base
  def up
    add_index :User, :remember_token, force: true
  end

  def down
    drop_index :User, :remember_token
  end
end
