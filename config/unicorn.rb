module Rails
  class <<self
    def root
      File.expand_path(__FILE__).split('/')[0..-3].join('/')
    end
  end
end

rails_env = ENV['RAILS_ENV'] || 'production'
worker_processes (rails_env == 'production' ? 10 : 2)
preload_app true
working_directory Rails.root
listen "#{Rails.root}/tmp/sockets/unicorn.sock", :backlog => 64
listen 5000, :tcp_nopush => false
timeout 120
pid  "#{Rails.root}/tmp/pids/unicorn.pid"

stderr_path "#{Rails.root}/log/unicorn/unicorn.stderr.log"
stdout_path "#{Rails.root}/log/unicorn/unicorn.stdout.log"

if GC.respond_to?(:copy_on_write_friendly=)
GC.copy_on_write_friendly = true
end

before_fork do |server, worker|
  old_pid ="#{Rails.root}/tmp/pids/unicorn.pid.oldbin"
  if File.exists?(old_pid) && server.pid != old_pid
    begin
      Process.kill("QUIT", File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
    puts "Send 'QUIT' signal to unicorn error!"
    end
  end
end  