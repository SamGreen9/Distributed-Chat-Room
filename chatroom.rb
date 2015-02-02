class Chatroom
  
  def initialize(roomRef, roomName, clientList)
    @roomRef= roomRef
    @roomName= roomName
    @clientList= clientList
    @current = ".."
  end
  def roomRef
    @roomRef
  end
  def roomName
    @roomName
  end
  def clientList
    @clientList
  end
  def addClient(val)
    @clientList.push(val)
  end

  def update(msg)
    @current = msg
  end


  def current
    @current 
  end

   def djb2(str)
     hash = 5381
     str.each_byte do |b|
       hash = (((hash << 5) + hash) + b) % (2 ** 32)
     end
     hash
  end
  
end