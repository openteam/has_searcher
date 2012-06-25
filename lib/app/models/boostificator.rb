class Boostificator
  MILLIS_IN_YEAR = 1000 * 60 * 60 * 24 * 365

  attr_accessor :search, :field

  def initialize(options)
    self.search = options[:search]
    self.field = options[:field]
  end

  def m
    1.0 / MILLIS_IN_YEAR
  end

  def a
    1.1
  end

  def b
    1
  end

  def precision
    6
  end

  def recip_min
    sprintf("%f", (recip * 10**precision).floor/10.0**precision)
  end

  def recip_max
    sprintf("%f", (recip * 10**precision).ceil/10.0**precision)
  end

  def recip
    a / (m*now_ms + b)
  end

  def now
    1.hour.since.change(:min => 0)
  end

  def now_ms
    now.to_i * 1000
  end

  def now_s
    now.utc.to_datetime.to_time.iso8601
  end

  def adjust_solr_params
    search.adjust_solr_params do |params|
      params[:q] = "{!boost b=map(recip(ms(#{now_s},#{field}),#{m},#{a},#{b}),#{recip_min},#{recip_max},1) defType=dismax}#{params[:q]}"
    end
  end
end
