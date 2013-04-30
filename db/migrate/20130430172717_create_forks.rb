class CreateForks < ActiveRecord::Migration
  def change
    create_table "remotes" do |t|
      t.string :url
      t.timestamps
    end

    add_index :remotes, :url

    create_table "repository_remotes" do |t|
      t.integer :repository_id
      t.integer :remote_id
      t.string :remote_name
      t.timestamps
    end

    add_index :repository_remotes, :remote_id
    add_index :repository_remotes, :repository_id

    add_column :projects, :repository_remote_id, :integer
    add_index :projects, :repository_remote_id

    repos = Repository.all
    repos.each do |repo|
      remote = Remote.find_or_create_by_url(repo.url)
      repository_remote = repo.repository_remotes.create!(:remote => remote, :remote_name => "origin")
      repo.projects.update_all(:repository_remote_id => repository_remote.id)
    end
    # IN subsequent deploy drop unused columns repositories.url, projects.repository_id
  end
end
