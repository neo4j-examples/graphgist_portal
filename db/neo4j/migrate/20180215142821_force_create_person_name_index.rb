class ForceCreatePersonNameIndex < Neo4j::Migrations::Base
  def up
    add_index :Person, :name, force: true
  end

  def down
    drop_index :Person, :name
  end
end
