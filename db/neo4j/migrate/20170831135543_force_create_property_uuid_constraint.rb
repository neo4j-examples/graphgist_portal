class ForceCreatePropertyUuidConstraint < Neo4j::Migrations::Base
  def up
    add_constraint :Property, :uuid, force: true
  end

  def down
    drop_constraint :Property, :uuid
  end
end
