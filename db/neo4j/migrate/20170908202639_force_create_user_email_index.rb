class ForceCreateUserEmailIndex < Neo4j::Migrations::Base
  def up
    add_index :User, :email, force: true
  end

  def down
    drop_index :User, :email
  end
end
