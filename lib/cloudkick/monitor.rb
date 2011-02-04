# Copyright 2010 Cloudkick, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
require 'crack'
require 'uri'

module Cloudkick
  class Monitor < Base

    attr_reader :name, :receivers, :created_at
    attr_reader :monitor_id, :query, :notes

    def initialize(name, receivers, created_at, active,
                   monitor_id, query, notes)
      @name = name
      @receivers = receivers
      @created_at = Time.at created_at
      @active = active
      @monitor_id = monitor_id
      @query = query
      @notes = notes
    end

    def active?
      @active
    end

    def disable!
      resp, data = access_token.put("/2.0/monitor/#{@monitor_id}/disable")
      # TODO: Haven't been able to verify that this works.
      puts resp.inspect
      puts data.inspect
    end

  end

  # TODO: Compare Nodes and Monitors more closely to see if they can
  # be DRY'd out. 
  class Monitors < Base
    attr_accessor :monitors, :query

    def initialize(query=nil)
      @query = query
      @monitors = get
    end

    def each
      @nodes.each { |node| yield node }
    end

    def get
      resp, data = access_token.get("/2.0/monitors")
      hash = Crack::JSON.parse(data)
      monitors = hash["items"].map do |m|
        Monitor.new(m["name"], m["notification_receivers"], m["created_at"],
                    m["is_active"], m["id"], m["query"], m["notes"])
      end
    end
  end
end
