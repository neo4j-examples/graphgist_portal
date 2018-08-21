class ForceCreateAssetUuidConstraint < Neo4j::Migrations::Base
  def up
    add_constraint :Asset, :uuid, force: true
  end

  def down
    drop_constraint :Asset, :uuid
  end
end
