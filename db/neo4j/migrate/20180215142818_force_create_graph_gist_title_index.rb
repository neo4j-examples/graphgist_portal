class ForceCreateGraphGistTitleIndex < Neo4j::Migrations::Base
  def up
    add_index :GraphGist, :title, force: true
  end

  def down
    drop_index :GraphGist, :title
  end
end
