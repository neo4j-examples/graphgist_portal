class ForceCreateGraphGistUrlConstraint < Neo4j::Migrations::Base
  def up
    add_constraint :GraphGist, :url, force: true
  end

  def down
    drop_constraint :GraphGist, :url
  end
end
