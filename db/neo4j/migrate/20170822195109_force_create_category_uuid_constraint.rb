class ForceCreateCategoryUuidConstraint < Neo4j::Migrations::Base
  def up
    add_constraint :Category, :uuid, force: true
  end

  def down
    drop_constraint :Category, :uuid
  end
end
