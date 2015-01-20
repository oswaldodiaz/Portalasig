	worker_processes 5
	preload_app true
	listen 3000

	after_fork do |server, worker|
		ActiveRecord::Base.establish_connection
	end
