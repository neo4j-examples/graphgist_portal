class ForceCreateGraphGistCandidateTitleIndex < Neo4j::Migrations::Base
  def up
    add_index :GraphGistCandidate, :title, force: true
  end

  def down
    drop_index :GraphGistCandidate, :title
  end
end
