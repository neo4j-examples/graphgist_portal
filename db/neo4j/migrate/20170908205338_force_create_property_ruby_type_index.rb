class ForceCreatePropertyRubyTypeIndex < Neo4j::Migrations::Base
  def up
    add_index :Property, :ruby_type, force: true
  end

  def down
    drop_index :Property, :ruby_type
  end
end
