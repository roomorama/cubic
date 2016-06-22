module Redis
  class Pool
    def self.get_instance(url)
      ::Redis.new(url: url)
    end
  end
end
