class Group < RDF_Context

  has_one(:curator).from(User, :groups)
  
  def members
    self.following
  end
  
  def set_members(members)
    # clear current members
    self.members.each do |context| 
      self.unfollow(context)
    end
    
    # replace with members array from parameters
    JSON.parse(members).each do |context_id|
      context = RDF_Context.find(context_id)      
      self.follow(context)
    end
  end

end