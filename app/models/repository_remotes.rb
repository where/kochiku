class RepositoryRemotes < ActiveRecord::Base
  belongs_to :repository
  belongs_to :remote

end
