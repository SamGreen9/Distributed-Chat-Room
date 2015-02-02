# CS4032 Lab 4 - Sam Green - 11440638


# encoding: utf-8
 require 'socket'      


class Client
	def initialize(s)
		@s = s
		@request = nil
		@response = nil
		send
		listen
		@request.join   #don't terminate program til thread is complete
		@response.join
	end


	def listen
		@response = Thread.new do
			while(line = @s.gets)     #receive messages from server
				puts line
			end
		end
	end


	def send
		@request = Thread.new do
			while(true)
				# listen

				usr_msg = gets
			 	@s.puts(usr_msg)  # Send client message to the server
			 	 

			 end
		end
	end

end

hostname = 'localhost'
port = '8000'

s = TCPSocket.open(hostname, port)         #open TCP socket
Client.new(s)
