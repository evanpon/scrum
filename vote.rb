class Vote
  include Comparable
  
  attr_accessor :display, :value
  def initialize(string)
    self.display = string
    self.value = case string.strip
    when '4 hours'
      0.5
    when '1 day'
      1
    when '2 days'
      2
    when '3 days'
      3
    else
      100
    end
  end
    
  def <=>(other)
    self.value <=> other.value
  end
end