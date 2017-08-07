class ForceCreateSessionSessionIdConstraint < Neo4j::Migrations::Base
  def up
    add_constraint :Session, :session_id, force: true
  end

  def down
    drop_constraint :Session, :session_id
  end
end
