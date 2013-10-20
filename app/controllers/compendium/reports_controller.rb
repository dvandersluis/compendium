module Compendium
  class ReportsController < ::ApplicationController
    helper Compendium::ReportsHelper

    before_filter :find_report
    before_filter :run_report, only: :run

    def setup
      render locals: { report: setup_report, prefix: @prefix }
    end

    def run
      template = template_exists?(@prefix, get_template_prefixes) ? @prefix : 'run'
      render action: template, locals: { report: @report }
    end

    private

    def find_report
      @prefix = params[:report_name]
      @report_name = "#{@prefix}_report"

      begin
        require(@report_name) unless Module.const_defined?(@report_name.classify)
        @report_class = @report_name.camelize.constantize
      rescue LoadError
        flash[:error] = t(:invalid_report)
        redirect_to action: :index
      end
    end

    def setup_report
      @report_class.new(params[:report] || {})
    end

    def run_report
      @report = @report_class.new(params[:report]).run(self)
    end

    def get_template_prefixes
      paths = []
      klass = self.class

      begin
        paths << klass.name.underscore.gsub(/_controller$/, '')
        klass = klass.superclass
      end while(klass != ActionController::Base)

      paths
    end
  end
end