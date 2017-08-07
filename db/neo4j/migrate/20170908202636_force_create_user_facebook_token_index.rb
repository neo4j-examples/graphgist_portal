class ForceCreateUserFacebookTokenIndex < Neo4j::Migrations::Base
  def up
    add_index :User, :facebook_token, force: true
  end

  def down
    drop_index :User, :facebook_token
  end
end
