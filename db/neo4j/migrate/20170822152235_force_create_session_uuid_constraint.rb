class ForceCreateSessionUuidConstraint < Neo4j::Migrations::Base
  def up
    add_constraint :Session, :uuid, force: true
  end

  def down
    drop_constraint :Session, :uuid
  end
end
