require 'socket'                # Get sockets from stdlib
require 'thread'
require './chatroom'

$max = 10       #sixe of thread pool
$endMessage = false
$poolSize = 0
$rooms = Hash.new
class ThreadPool
  
  @maxSize = $max
  @clientQueue = Queue.new
  
    def self.pushQueue(c1, c2)
      @clientQueue << [c1, c2]
      $poolSize = $poolSize + 1
    end

    @pool = Array.new(@maxSize) do |i|       #initialize threads 
      Thread.new do
        
        loop do    
      
          if (!(@clientQueue.empty?()))
            
            cl, msg = @clientQueue.pop
            puts "msg= " + msg
            clientInput = msg.split('\n')
           
            
            if msg.start_with?"JOIN_CHATROOM:"     
              
              joinChatroom(msg, clientInput, cl)

            else
              cl.puts "ERROR_CODE: 101\nERROR DESCRIPTION: Incorrect join command"
              
            end
            while  $endMessage != true   #accept client input chat messages
             
              if line = cl.gets 
                
                if line.start_with?"CHAT:"
                  puts line
                  clientInput = line.split('\n')
                  ref = clientInput[0].split(':')[1].strip
                  rRef = ref.to_i
                  clientName = clientInput[2].split(':')[1].strip
                  cMsg = clientInput[3].split(':')[1].strip
                  cRoom = $rooms[rRef]

                  sendChat(cl, cRoom, cMsg, clientName)    #Send chat to all clients in the same room
                elsif line.eql?"KILL_SERVICE\n"
                  $endMessage = true
                  puts "Service killed"
                  Thread.exit
                elsif line.start_with?"HELO"
                  sock_domain, port, hostname, ip = cl.peeraddr
                  newStr = "IP: " + ip.to_s + " ;port: " + port.to_s + " ;student no: 11440638"
                  str2 = line + newStr
                  cl.puts str2
                elsif line.start_with?"LEAVE_CHATROOM:"
                     $endMessage = true
                  end

              end
            end
            # puts cl
             cl.close
          end
        end
       
        Thread.exit
      end
    end 
  
  
  def ThreadPool.djb2(str)
      hash = 5381
     str.each_byte do |b|
       hash = (((hash << 5) + hash) + b) % (2 ** 32)
     end
     hash
  end

  def ThreadPool.sendChat(client, chatroom, msg, name)
   
    for element in chatroom.clientList do
       if(element != client)
         element.puts "CHAT: " + chatroom.roomRef.to_s + "\nCLIENT_NAME: " + name + "\nMESSAGE: " + msg + "\n\n"
       end
    end
  
  end

  def ThreadPool.joinChatroom(msg, clientInput, cl)
    sock_domain, port, hostname, ip = cl.peeraddr
    rname = clientInput[0].split(':')[1].strip
    cname = clientInput[3].split(':')[1].strip
    roomRef = djb2(rname)
    joinID = djb2(cname)
    
    init = "JOINED_CHATROOM: " + rname + "\nSERVER_IP: " + ip.to_s + "\nPORT: 8000\n" + "ROOM_REF: " + roomRef.to_s + "\nJOIN_ID: " + joinID.to_s      
    cl.puts init
    
    if($rooms.has_key?(roomRef))
      puts "room found"
      c = $rooms[roomRef]
      c.addClient(cl)
    else 
      puts "new room"
      arr = [cl]
      c = Chatroom.new(roomRef, rname, arr)
      $rooms[roomRef] = c
      puts "added room"
               
                
    end

  end

end



class Server

  portNo = ARGV[0]
  puts portNo
  server = TCPServer.open(portNo)  
  threadNo = 0
  
  arr = [202]


  endloop = false
  while (!(endloop))                      
        
          client = server.accept       # Wait for a client to connect
          line = client.gets   # Read lines from the socket
          puts "queue size: " + $poolSize.to_s
          if($poolSize < $max)
            ThreadPool.pushQueue(client, line)   #enqueue client and first message
          end
          if(line.eql?"KILL_SERVICE\n")
            endloop = true
          end
	 
  end
  puts "Closing server"
  server.close

end



