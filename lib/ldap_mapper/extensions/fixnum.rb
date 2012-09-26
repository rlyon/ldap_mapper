class Fixnum
  def epoch_days
    Time.at(self * 86400)
  end
end
