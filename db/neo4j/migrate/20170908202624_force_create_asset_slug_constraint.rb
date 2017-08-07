class ForceCreateAssetSlugConstraint < Neo4j::Migrations::Base
  def up
    add_constraint :Asset, :slug, force: true
  end

  def down
    drop_constraint :Asset, :slug
  end
end
