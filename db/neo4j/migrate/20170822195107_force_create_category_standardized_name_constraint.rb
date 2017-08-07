class ForceCreateCategoryStandardizedNameConstraint < Neo4j::Migrations::Base
  def up
    add_constraint :Category, :standardized_name, force: true
  end

  def down
    drop_constraint :Category, :standardized_name
  end
end
