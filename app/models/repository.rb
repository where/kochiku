class Repository < ActiveRecord::Base
  URL_PARSERS = {
    "git@" => /@(.*):(.*)\/(.*)\.git/,
    "git:" => /:\/\/(.*)\/(.*)\/(.*)\.git/,
    "http" => /https?:\/\/(.*)\/(.*)\/([^.]*)\.?/,
  }
  has_many :projects
  serialize :options, Hash
  validates_presence_of :url

  def base_html_url
    params = github_url_params
    "https://#{params[:host]}/#{params[:username]}/#{params[:repository]}"
  end

  def base_api_url
    params = github_url_params
    "https://#{params[:host]}/api/v3/repos/#{params[:username]}/#{params[:repository]}"
  end

  def repository_name
    github_url_params[:repository]
  end

  private
  def github_url_params
    parser = URL_PARSERS[url.slice(0,4)]
    match = url.match(parser)
    {:host => match[1], :username => match[2], :repository => match[3]}
  end

end