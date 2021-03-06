require 'thor'
require 'orca'
require 'pvcglue'

module Pvcglue
  class Manager < Thor # must be 'Manager' (as opposed to 'Manager_CLI') or Thor's `subcommand` gets confused using Thor <= 0.19.1

    desc "bootstrap", "bootstrap"

    def bootstrap
      Pvcglue::PvcManager.new.bootstrap
    end

    desc "push", "push"

    def push
      Pvcglue::PvcManager.new.push
    end

    desc "pull", "pull"

    def pull
      Pvcglue::PvcManager.new.pull
    end

    desc "show", "show"

    def show
      Pvcglue::PvcManager.new.show
    end

  end

  class CLI < Thor

    def initialize(args = [], local_options = {}, config = {})
      super
      Pvcglue.cloud.set_stage(options[:stage]) if options[:stage]
      # puts "/\\"*80
      # puts options.inspect
      # puts "*"*80
    end

    desc "version", "show the version of PVC..."

    def version
      puts Pvcglue::Version.version
    end

    desc "info", "show the pvcglue version and cloud settings"

    def info
      puts "Pvcglue version #{Pvcglue::Version.version}"
      puts "  Manager settings:"
      Pvcglue.configuration.options.each { |k, v| puts "    #{k}=#{v}" }
    end

    desc "bootstrap", "bootstrap..."
    method_option :stage, :required => true, :aliases => "-s"

    def bootstrap
      puts Pvcglue::Bootstrap.run(options[:stage])
    end

    desc "console", "open rails console"
    method_option :stage, :required => true, :aliases => "-s"
    def console(server='web')
      node = Pvcglue.cloud.find_node(server)
      node_name = node.keys.first
      node_data = node.values.first
      puts "*"*80
      puts node.inspect
      puts "Connection to #{node_name} (#{node_data[:public_ip]}) as user 'deploy'..."
      working_dir = Pvcglue.cloud.deploy_to_app_current_dir
      system(%(ssh -t deploy@#{node_data[:public_ip]} "cd #{working_dir} && echo 'Starting #{options[:stage].upcase} Rails console in #{working_dir}' && RAILS_ENV=#{options[:stage].downcase} script/rails c"))

    end

    desc "c", "shortcut for console"
    method_option :stage, :required => true, :aliases => "-s"
    def c(server='web')
      console(server)
    end

    #desc "manager", "manager bootstrap|pull|push"

    desc "manager SUBCOMMAND ...ARGS", "manage manager"
    #banner 'manager'
    subcommand "manager", Manager

  end

end