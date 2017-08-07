class ForceCreateChallengeNameIndex < Neo4j::Migrations::Base
  def up
    add_index :Challenge, :name, force: true
  end

  def down
    drop_index :Challenge, :name
  end
end
