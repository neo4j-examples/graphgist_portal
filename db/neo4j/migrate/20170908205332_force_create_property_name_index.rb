class ForceCreatePropertyNameIndex < Neo4j::Migrations::Base
  def up
    add_index :Property, :name, force: true
  end

  def down
    drop_index :Property, :name
  end
end
