class User
  include Neo4j::ActiveNode
  #
  # Neo4j.rb needs to have property definitions before any validations. So, the property block needs to come before
  # loading your devise modules.
  #
  # If you add another devise module (such as :lockable, :confirmable, or :token_authenticatable), be sure to
  # uncomment the property definitions for those modules. Otherwise, the unused property definitions can be deleted.
  #

  property :name
  property :username, type: String
  index :username

  property :twitter_username, type: String
  property :facebook_token, type: String
  index :facebook_token

  property :created_at, type: DateTime
  property :updated_at, type: DateTime

  ## Database authenticatable
  property :email, type: String, null: false, default: ''
  index :email

  property :encrypted_password

  ## If you include devise modules, uncomment the properties below.

  ## Rememberable
  property :remember_created_at, type: DateTime
  property :remember_token, type: String
  index :remember_token

  ## Recoverable
  property :reset_password_token
  index :reset_password_token
  property :reset_password_sent_at, type:   DateTime

  ## Trackable
  property :sign_in_count, type: Integer, default: 0
  property :current_sign_in_at, type: DateTime
  property :last_sign_in_at, type: DateTime
  property :current_sign_in_ip, type:  String
  property :last_sign_in_ip, type: String

  property :image, type: String

  property :provider
  property :uid
  property :info
  serialize :info

  property :admin, type: Boolean, default: false

  has_one :out, :person, type: :IS_PERSON

  after_save :propogate_person_properties

  def propogate_person_properties
    (person || Person.create).tap do |person|
      person.name = name
      person.email = email
      person.twitter_username = twitter_username
      person.save
      self.person = person
    end
  end

  ## Confirmable
  # property :confirmation_token
  # index :confirmation_token
  # property :confirmed_at, type: DateTime
  # property :confirmation_sent_at, type: DateTime

  ## Lockable
  #  property :failed_attempts, type: Integer, :default => 0
  # property :locked_at, type: DateTime
  #  property :unlock_token, type: String,
  # index :unlock_token

  ## Token authenticatable
  # property :authentication_token, type: String, :null => true, :index => :exact

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable, omniauth_providers: [:twitter]
  def self.find_by_provider_and_uid(provider, uid)
    all.find_by(provider: provider, uid: uid)
  end

  # def self.create_with_omniauth(auth)
  #  create! do |user|
  #    user.provider = auth["provider"]
  #    user.uid = auth["uid"]
  #    user.name = auth["info"]["name"]
  #    user.email = auth["info"]["email"]
  #    user.password = Devise.friendly_token[0,20]
  #  end
  # end

  def self.from_omniauth(auth)
    user_from_omniauth(auth).tap do |user|
      user.uid = auth.uid
      user.password = Devise.friendly_token[0, 20]

      user.username = auth.info.nickname

      %w(email name info image).each do |field|
        user.send("#{field}=", auth.info.send(field))
      end

      user.save
    end
  end

  def self.user_from_omniauth(auth)
    params = {provider: auth.provider, uid: auth.uid}

    find_by(params) || new(params)
  end

  def password_required?
    false
  end

  def email_required?
    false
  end
end
