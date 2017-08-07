class ForceCreateModelNameConstraint < Neo4j::Migrations::Base
  def up
    add_constraint :Model, :name, force: true
  end

  def down
    drop_constraint :Model, :name
  end
end
