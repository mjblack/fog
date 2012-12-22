module Fog
  module Compute
    class Ecloud
      class Layout < Fog::Ecloud::Model
        identity :href

        attribute :type, :aliases => :Type
        attribute :other_links, :aliases => :Links

        def rows
          @rows = Fog::Compute::Ecloud::Rows.new(:service => service, :href => href)
        end

        def id
          href.scan(/\d+/)[0]
        end
      end
    end
  end
end
