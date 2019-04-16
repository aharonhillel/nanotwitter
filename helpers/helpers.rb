require 'date'

helpers do
  def from_dgraph_or_redis(query, options = {})
    ex = options[:ex] || 30
    res = $redis.get(query)
    # query dgraph if redis cache miss
    if res.nil?
      res = $dg.query(query: query)
      $redis.set(query, res.to_json, ex: ex)
      res
    else
      JSON.parse(res, symbolize_names: true)
    end
  end

  def time_since(t)
    return 'unknown date' unless t

    seconds = Time.now - Time.parse(t)
    return "now" if seconds <= 1

    length,label = time_lengths.select{|length,label| seconds >= length }.first
    units = seconds/length
    "#{units.to_i} #{label}#{'s' if units > 1} ago"
  end

  def time_lengths
    [[86400, "day"], [3600, "hour"], [60, "minute"], [1, "second"]]
  end
end