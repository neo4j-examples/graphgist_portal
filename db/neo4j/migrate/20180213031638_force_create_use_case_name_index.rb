class ForceCreateUseCaseNameIndex < Neo4j::Migrations::Base
  def up
    add_index :UseCase, :name, force: true
  end

  def down
    drop_index :UseCase, :name
  end
end
