# frozen_string_literal: true

# Copyright 2018 Tristan Robert

# This file is part of Fog::Proxmox.

# Fog::Proxmox is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# Copyright 2018 Tristan Robert

# This file is part of Fog::Proxmox.

# Fog::Proxmox is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# Fog::Proxmox is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with Fog::Proxmox. If not, see <http://www.gnu.org/licenses/>.

module Fog
  module Compute
    class Proxmox
      # class Snapshot model
      class Snapshot < Fog::Model
        identity  :name
        attribute :description
        attribute :snaptime
        attribute :vmstate
        attribute :node_id
        attribute :server_id
        attribute :server_type
        attribute :server
        attribute :vmgenid

        def server
          requires :node_id, :server_id, :server_type
          attributes[:server] ||= server_id.nil? ? nil : begin
            Fog::Compute::Proxmox::Server.new(service: service, node_id: node_id, type: server_type, vmid: server_id)
          end
        end

        def create(options = {})
          requires :node_id, :server_id, :server_type
          path_params = { node: node_id, type: server_type, vmid: server_id }
          body_params = options
          server.tasks.wait_for(service.create_snapshot(path_params, body_params))
        end

        def update
          requires :name, :node_id, :server_id, :server_type
          path_params = { node: node_id, type: server_type, vmid: server_id, snapname: name }
          body_params = { description: description }
          service.update_snapshot(path_params, body_params)
        end

        def rollback
          requires :name, :node_id, :server_id, :server_type
          path_params = { node: node_id, type: server_type, vmid: server_id, snapname: name }
          server.tasks.wait_for(service.rollback_snapshot(path_params))
        end

        def destroy(force = 0)
          requires :name, :node_id, :server_id, :server_type
          path_params = { node: node_id, type: server_type, vmid: server_id, snapname: name }
          query_params = { force: force }
          server.tasks.wait_for(service.delete_snapshot(path_params, query_params))
        end
      end
    end
  end
end
