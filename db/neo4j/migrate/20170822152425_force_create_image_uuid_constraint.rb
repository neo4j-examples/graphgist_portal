class ForceCreateImageUuidConstraint < Neo4j::Migrations::Base
  def up
    add_constraint :Image, :uuid, force: true
  end

  def down
    drop_constraint :Image, :uuid
  end
end
