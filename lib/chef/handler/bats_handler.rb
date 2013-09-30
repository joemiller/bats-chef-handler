class Chef
  class Handler
    class BatsHandler < Chef::Handler
      include Chef::Mixin::ShellOut

      def report
        # do not run tests if chef failed
        return if failed?

        Chef::Log.debug "BatsHandler#report called"
        Chef::Log.debug "found tests: #{test_file_paths}"

        test_failures = []

        Dir.glob(test_file_paths).each do |test_path|
          Chef::Log.info "Running test: #{test_path}"
          cmd = shell_out("bats #{test_path}", :live_stream => STDOUT)
          if cmd.exitstatus == 0
            Chef::Log.debug "#{test_path}: test passed"
          else
            Chef::Log.debug "#{test_path}: test failed"
            test_failures << test_path
          end
        end

        if test_failures.size > 0
          ::Chef::Client.when_run_completes_successfully do |run_status|
            error_msg = "BATS tests failed with #{test_failures.size} failures"
            raise error_msg
          end
        end 
      end

      def test_file_paths
        used_recipe_names.map do |recipe_name|
          cookbook_name, recipe_short_name = ::Chef::Recipe.parse_recipe_name(recipe_name)
          base_path = ::Chef::Config[:cookbook_path]

          cookbook_paths = lookup_cookbook(base_path, cookbook_name)
          Chef::Log.debug "cookbook_paths: #{cookbook_paths}"

          # TODO: also support test-kitchen's default path somehow? eg: tests/integration/<test_suite_name>/bats/<test_name>.bats
          cookbook_paths.map do |path|
            file_test_pattern = "%s/tests/%s_test.bats" % [path, recipe_short_name]
            dir_test_pattern  = "%s/tests/%s/*.bats" % [path, recipe_short_name]

            [file_test_pattern, dir_test_pattern]
          end.flatten
        end.flatten
      end

      def used_recipe_names
        if recipes = run_status.node.run_state[:seen_recipes]
          recipes.keys
        else
          # chef 11 - see http://docs.opscode.com/breaking_changes_chef_11.html#node-run-state-replaced
          run_status.run_context.loaded_recipes
        end
      end

      def lookup_cookbook(path, name)
        path_expr = Array(path).join(',')

        Dir.glob("{%s}/%s" % [path_expr, name])
      end

    end
  end
end
