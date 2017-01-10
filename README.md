## README

Sorta getting started:

```
rvm install ruby-2.3.0
rvm use 2.3.0
gem install bundler
bundle install
rake neo4j:install[community-latest] 
rake neo4j:start # modify to point to 9999, open http://localhost:9999/ and verify db is there
# try to run tests
# try to run rake
rails s # good luck! 
```

Please feel free to use a different markup language if you do not plan to run
<tt>rake doc:app</tt>.