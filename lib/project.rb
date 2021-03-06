class Project
  include Mongoid::Document
  include Mongoid::Timestamps

  field :user
  field :name
  field :description
  field :watchers, :type => Integer
  field :fork, :type => Boolean
  field :state
  field :visible, :type => Boolean

  has_and_belongs_to_many :users

  scope :visible, where(:visible => true)
  scope :no_forks, where(:fork.ne => true)

  scope :search_by_name, lambda { |query|
    query = /#{query}/i
    where({:name => query})
  }

  def self.create_or_update_from_github_response(data)
    return nil unless data['permissions']['admin']
    if project = where(name: data['name'], user: data['owner']['login']).first
      project.update_attributes!(
        :description => data['description'],
        :watchers => data['watchers']
      )
    else
      project = create!(
        :name => data['name'],
        :user => data['owner']['login'],
        :description => data['description'],
        :watchers => data['watchers'],
        :fork => data['fork']
      )
    end
    project
  end
end
