class Boostificator
  MILLIS_IN_YEAR = 1000 * 60 * 60 * 24 * 365
  PRECISION = 6

  attr_accessor :search, :field

  attr_accessor :m, :x, :a, :b

  attr_accessor :extra_boost

  def initialize(options={})
    options.reverse_merge!(:a => 1.0, :b => 1.0, :m => 1.0 / MILLIS_IN_YEAR, :extra_boost => 1.0)
    options.each do |field, value|
      self.send("#{field}=", value)
    end
  end


  def adjust_solr_params
    search.adjust_solr_params do |params|
      params[:boost] = "product(#{extra_boost},#{recip_s})"
      params[:defType] = 'edismax'
    end
  end

  private
    def recip_s
      @recip_s ||= "map(recip(abs(ms(#{now_s},#{field})),#{m},#{a},#{b}),#{recip_min},#{recip_max},1)"
    end

    def now
      @now ||= DateTime.now.change(:min => 0)
    end

    def recip
      @recip ||= a / (m * now_ms + b)
    end

    def now_ms
      @now_ms ||= now.to_i * 1000
    end

    def now_s
      @now_s ||= now.utc.to_datetime.to_time.iso8601
    end

    def recip_min
      @recip_min ||= sprintf("%f", (recip * 10**PRECISION).floor/10.0**PRECISION)
    end

    def recip_max
      @recip_max ||= sprintf("%f", (recip * 10**PRECISION).ceil/10.0**PRECISION)
    end

end
