module Fog
  module Compute
    class Vsphere
      class Real
        def create_folder(datacenter, path, name)
          #Path cannot be nil but it can be an empty string
          raise ArgumentError, "Path cannot be nil" if path.nil?

          parent_folder = get_raw_vmfolder(path, datacenter)
          begin
            new_folder = parent_folder.CreateFolder(:name => name)
            # output is cleaned up to return the new path
            # new path will be path/name, example: "Production/Pool1"
            new_folder.path.reject { |a| a.first.class == "Folder" }.collect { |a| a.first.name }.join("/").sub(/^\/?Datacenters\/#{datacenter}\/vm\/?/, '')
          rescue => e
            raise e, "failed to create folder: #{e}"
          end
        end

        protected

        # Pillaged from request get_folder. Not sure if this is
        # the proper way to do it. --mjblack
        def get_raw_vmfolder(path, datacenter_name)
          # The required path syntax - 'topfolder/subfolder

          # Clean up path to be relative since we're providing datacenter name
          paths          = path.sub(/^\/?Datacenters\/#{datacenter_name}\/vm\/?/, '').split('/')
          dc             = find_raw_datacenter(datacenter_name)
          dc_root_folder = dc.vmFolder

          return dc_root_folder if paths.empty?
          # Walk the tree resetting the folder pointer as we go
          paths.inject(dc_root_folder) do |last_returned_folder, sub_folder|
            # JJM VIM::Folder#find appears to be quite efficient as it uses the
            # searchIndex It certainly appears to be faster than
            # VIM::Folder#inventory since that returns _all_ managed objects of
            # a certain type _and_ their properties.
            sub = last_returned_folder.find(sub_folder, RbVmomi::VIM::Folder)
            raise ArgumentError, "Could not descend into #{sub_folder}.  Please check your path. #{path}" unless sub
            sub
          end
        end
      end
    end
  end
end
