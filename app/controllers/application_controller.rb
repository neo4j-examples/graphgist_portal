class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # before_action :authenticate_user!

  layout 'layouts/graph_starter/application'

  # around_filter :performance_test

  def performance_test
    require 'tempfile'
    report_file = Tempfile.new('stackprof_report')
    path = report_file.path

    StackProf.run(mode: :cpu, out: path) do
      yield
    end

    output = StringIO.new
    StackProf::Report.new(Marshal.load(File.read(path))).print_text(false, nil, output)

    logger.debug output.string.split(/[\n\r]+/)[0, 13].join("\n")
  end

  def after_sign_in_path_for(resource)
    request.env['omniauth.origin'] || stored_location_for(resource) || root_path
  end
end
