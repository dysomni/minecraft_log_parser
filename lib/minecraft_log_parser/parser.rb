module MinecraftLogParser
  class Parser
    class << self
      def parse(str)
        definition.select do |_test_name, node|
          x = rec_parse(node, str)
          break x if x
        end
      end

      def rec_parse(node, str)
        regex = node[:regex] || /./
        matches = node[:matches] || []
        metadata = node[:metadata] || {}
        process_matches = node[:process_matches] || {}
        regex_response = match_regex_or_array_of_regex(regex, str)
        return unless regex_response

        obj = matches.zip(regex_response.captures).to_h
        obj.merge!(metadata)
        process_matches_iter(obj, process_matches)
      end

      def match_regex_or_array_of_regex(regex, str)
        return regex.map { |r| str.match(r) }.compact.first if regex.is_a?(Array)

        str.match(regex)
      end

      def process_matches_iter(obj, process_matches)
        process_matches.map do |attribute, tests|
          tests.select do |_test_name, sub_node|
            x = rec_parse(sub_node, obj[attribute])
            break x if x
          end
        end.compact.reduce(obj, &:merge!)
      end

      def definition
        @definition ||= {
          base: {
            regex: /^\[([\d:]+?)\] \[(.+?)\/(.+?)\]: (.*)/,
            matches: %i[shown_time executor log_level stripped_log],
            process_matches: {
              stripped_log: {
                server_message: {
                  regex: /^\[(Server)\]\s(.*)/,
                  matches: %i[user_name message],
                  metadata: {
                    log_type: "server message"
                  }
                },
                user_message: {
                  regex: /^<(#{USER_NAME_REGEX})>\s(.*)/,
                  matches: %i[user_name message],
                  metadata: {
                    log_type: "user message"
                  }
                },
                user_uuid: {
                  regex: /^UUID of player (#{USER_NAME_REGEX}) is ([\d\w-]+)/,
                  matches: %i[user_name user_uuid],
                  metadata: {
                    log_type: "user uuid"
                  }
                },
                user_login_details: {
                  regex: /^(#{USER_NAME_REGEX})\[\/(.+):(.+)\] logged in with entity id (\d+) at \((.+)\)/,
                  matches: %i[user_name user_ip user_port user_entity_id user_coordinates],
                  metadata: {
                    log_type: "user login details"
                  },
                  process_matches: {
                    user_coordinates: {
                      coordinates: {
                        regex: /(.*),\s*(.*),\s*(.*)/,
                        matches: %i[user_x_coordinates user_y_coordinates user_z_coordinates]
                      }
                    }
                  }
                },
                user_join: {
                  regex: /(#{USER_NAME_REGEX}) joined the game/,
                  matches: %i[user_name],
                  metadata: {
                    log_type: "user join"
                  }
                },
                user_left: {
                  regex: /(#{USER_NAME_REGEX}) left the game/,
                  matches: %i[user_name],
                  metadata: {
                    log_type: "user left"
                  }
                },
                user_disconnected: {
                  regex: /(#{USER_NAME_REGEX}) lost connection: Disconnected/,
                  matches: %i[user_name],
                  metadata: {
                    log_type: "user disconnected"
                  }
                },
                user_kicked: {
                  regex: /(#{USER_NAME_REGEX}) lost connection: Kicked by an operator/,
                  matches: %i[user_name],
                  metadata: {
                    log_type: "user kicked"
                  }
                },
                user_advancement: {
                  regex: /(#{USER_NAME_REGEX}) has made the advancement \[(.+?)\]/,
                  matches: %i[user_name user_advancement],
                  metadata: {
                    log_type: "user advancement"
                  }
                },
                user_challenge: {
                  regex: /(#{USER_NAME_REGEX}) has completed the challenge \[(.+?)\]/,
                  matches: %i[user_name user_advancement],
                  metadata: {
                    log_type: "user challenge"
                  }
                },
                user_death: {
                  regex: user_death_regex,
                  matches: %i[user_name],
                  metadata: {
                    log_type: "user death"
                  }
                },
                startup_done: {
                  regex: /Done\ \([\d\.\w]+\)!\ For help, type "help"/,
                  metadata: {
                    log_type: "startup done"
                  }
                },
                stopping_server: {
                  regex: /Stopping\ server/,
                  metadata: {
                    log_type: "stopping server"
                  }
                },
                startup: {
                  regex: startup_regex,
                  metadata: {
                    log_type: "startup"
                  }
                },
                fetching_packet: {
                  regex: /^Fetching packet/,
                  metadata: {
                    log_type: "fetching packet"
                  }
                },
                ambiguity: {
                  regex: /^Ambiguity/,
                  metadata: {
                    log_type: "ambiguity"
                  }
                },
                overloaded: {
                  regex: /^Can't keep up!/,
                  metadata: {
                    log_type: "overloaded"
                  }
                },
                command: {
                  regex: /^\/\w+/,
                  metadata: {
                    log_type: "command"
                  }
                },
                could_not_save: {
                  regex: /^Could not save data/,
                  metadata: {
                    log_type: "could not save"
                  }
                },
                unknown_command: {
                  regex: /^Unknown.+?command/,
                  metadata: {
                    log_type: "unknown command"
                  }
                },
                tried_to_load: {
                  regex: /^Tried to load/,
                  metadata: {
                    log_type: "tried to load"
                  }
                },
                time_elapsed: {
                  regex: /^Time elapsed/,
                  metadata: {
                    log_type: "time elapsed"
                  }
                },
                chunks_saved: {
                  regex: /^ThreadedAnvilChunkStorage/,
                  metadata: {
                    log_type: "chunks saved"
                  }
                },
                ignored_advancement: {
                  regex: /^Ignored advancement/,
                  metadata: {
                    log_type: "ignored advancement"
                  }
                },
                here: {
                  regex: /<--\[HERE\]/,
                  metadata: {
                    log_type: "<--[HERE]"
                  }
                },
                vehicle_moved_wrongly: {
                  regex: /^.+? \(vehicle of (#{USER_NAME_REGEX})\) moved wrongly!/,
                  matches: %i[user_name],
                  metadata: {
                    log_type: "vehicle moved wrongly"
                  }
                },
                user_moved_wrongly: {
                  regex: /^(#{USER_NAME_REGEX}) moved wrongly/,
                  matches: %i[user_name],
                  metadata: {
                    log_type: "user moved wrongly"
                  }
                },
                user_moved_quickly: {
                  regex: /^(#{USER_NAME_REGEX}) moved too quickly/,
                  matches: %i[user_name],
                  metadata: {
                    log_type: "user moved quickly"
                  }
                },
                user_timed_out: {
                  regex: /^(#{USER_NAME_REGEX}) lost connection: Timed out/,
                  matches: %i[user_name],
                  metadata: {
                    log_type: "user timed out"
                  }
                },
                entity_with_duplicated_uuid: {
                  regex: /^Trying to add entity with duplicated UUID/,
                  metadata: {
                    log_type: "entity with duplicated UUID"
                  }
                },
                disconnected: {
                  regex: /^.+?id=(.+?),name=(.+?),.+?\(\/(.+):(.+)\).+?lost connection/,
                  matches: %i[user_uuid user_name user_ip user_port],
                  metadata: {
                    log_type: "disconnected"
                  }
                },
                disconnected_not_white_listed: {
                  regex: /^.+?id=(.+?),name=(.+?),.+?\(\/(.+):(.+)\).+?not white-listed/,
                  matches: %i[user_uuid user_name user_ip user_port],
                  metadata: {
                    log_type: "disconnected not white-listed"
                  }
                },
                users_online: {
                  regex: /^There are (\d*?) of a max of (\d*?) players online: (.*)/,
                  matches: %i[users_online users_max user_name],
                  metadata: {
                    log_type: "users online"
                  }
                },
                unknown: { # if we couldnt match anything above, mark it as unknown
                  regex: /.*/,
                  metadata: {
                    log_type: "unknown"
                  }
                }
              }
            }
          },
          invalid: { # if we couldnt match the base regex, the log is invalid
            regex: /.*/,
            metadata: {
              log_type: "invalid"
            }
          }
        }
      end

      def user_death_regex
        @user_death_regex ||= begin
          path = File.join(__dir__, 'store', 'user_death_regex.txt')
          lines = File.read(path).gsub('####', USER_NAME_REGEX).split("\n")
          lines.map { |line| Regexp.new(line) }
        end
      end

      def startup_regex
        @startup_regex ||= begin
          path = File.join(__dir__, 'store', 'startup_regex.txt')
          lines = File.read(path).split("\n")
          lines.map { |line| Regexp.new(line) }
        end
      end
    end
  end
end
