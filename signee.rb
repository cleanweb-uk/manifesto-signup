class Signee
  include Mongoid::Document
  
  field :twitter_id, type: Integer
  field :name, type: String
  field :nickname, type: String  

  field :image, type: String
  field :location, type: String
  field :description, type: String

  field :twitter_url, type: String
  field :website, type: String

end

