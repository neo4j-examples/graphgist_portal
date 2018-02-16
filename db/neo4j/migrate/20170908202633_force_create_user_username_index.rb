class ForceCreateUserUsernameIndex < Neo4j::Migrations::Base
  def up
    add_index :User, :username, force: true
  end

  def down
    drop_index :User, :username
  end
end
