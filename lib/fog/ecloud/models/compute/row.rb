module Fog
  module Compute
    class Ecloud
      class Row < Fog::Ecloud::Model
        identity :href

        attribute :name, :aliases => :Name
        attribute :type, :aliases => :Type
        attribute :other_links, :aliases => :Links
        attribute :index, :aliases => :Index

        def groups
          @groups = Fog::Compute::Ecloud::Groups.new(:service => service, :href => href)
        end

        def edit(options)
          options[:uri] = href
          service.rows_edit(options).body
        end

        def move_up(options)
          options[:uri] = href + "/action/moveup"
          service.rows_moveup(options).body
        end

        def move_down(options)
          options[:uri] = href + "/action/movedown"
          service.rows_movedown(options).body
        end

        def delete
          service.rows_delete(href).body
        end

        def create_group(options = {})
          options[:uri] = "/cloudapi/ecloud/layoutGroups/environments/#{environment_id}/action/createLayoutGroup"
          options[:row_name] = name
          options[:href] = href
          data = service.groups_create(options).body
          group = Fog::Compute::Ecloud::Groups.new(:service => service, :href => data[:href])[0]
        end

        def environment_id
          other_links[:Link][:href].scan(/\d+/)[0]
        end

        def id
          href.scan(/\d+/)[0]
        end
      end
    end
  end
end
