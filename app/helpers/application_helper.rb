module ApplicationHelper
  def custom_time_ago_in_words(from_time)
    distance = Time.now - from_time

    case distance
    when 0..59
      "#{distance.to_i}Sec" # Seconds
    when 60..3599
      "#{(distance / 60).to_i}min" # Minutes
    when 3600..86399
      "#{(distance / 3600).to_i}h" # Hours
    else
      "#{(distance / 86400).to_i}Day#{'s' if (distance / 86400).to_i > 1} " # Days
    end
  end


end
