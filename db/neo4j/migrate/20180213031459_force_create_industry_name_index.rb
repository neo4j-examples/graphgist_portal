class ForceCreateIndustryNameIndex < Neo4j::Migrations::Base
  def up
    add_index :Industry, :name, force: true
  end

  def down
    drop_index :Industry, :name
  end
end
