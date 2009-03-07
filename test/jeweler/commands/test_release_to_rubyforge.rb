require 'test_helper'

class RubyForgeStub
  attr_accessor :userconfig
  
  def initialize
    @userconfig = {}
  end
end

class Jeweler
  module Commands
    class TestReleaseToRubyforge < Test::Unit::TestCase

      context "after running when rubyforge_project is defined" do
        setup do
          @rubyforge = RubyForgeStub.new
          stub(@rubyforge).configure
          stub(@rubyforge).login
          stub(@rubyforge).add_release("MyRubyForgeProjectName", "zomg", "1.2.3", "pkg/zomg-1.2.3.gem")

          @gempsec = Object.new
          stub(@gemspec).description {"The zomg gem rocks."}
          stub(@gemspec).rubyforge_project {"MyRubyForgeProjectName"}
          stub(@gemspec).name {"zomg"}
          
          @gemspec_helper = Object.new
          stub(@gemspec_helper).write
          stub(@gemspec_helper).gem_path {'pkg/zomg-1.2.3.gem'}
          stub(@gemspec_helper).update_version('1.2.3')

          @output = StringIO.new

          @command                = Jeweler::Commands::ReleaseToRubyforge.new
          @command.output         = @output
          @command.repo           = @repo
          @command.gemspec        = @gemspec
          @command.gemspec_helper = @gemspec_helper
          @command.version        = '1.2.3'
          @command.ruby_forge     = @rubyforge

          @command.run
        end

        should "configure" do
          assert_received(@rubyforge) {|rubyforge| rubyforge.configure }
        end

        should "login" do
          assert_received(@rubyforge) {|rubyforge| rubyforge.login }
        end
        
        should "set release notes" do
          assert_equal "The zomg gem rocks.", @rubyforge.userconfig["release_notes"]
        end
        
        should "set preformatted to true" do
          assert_equal true, @rubyforge.userconfig['preformatted']
        end
        
        should "add release" do
          assert_received(@rubyforge) {|rubyforge| rubyforge.add_release("MyRubyForgeProjectName", "zomg", "1.2.3", "pkg/zomg-1.2.3.gem") }
        end
        
      end
      
      context "after running when rubyforge_project is not defined in Jeweler::Tasks block in Rakefile" do
        setup do
          @rubyforge = RubyForgeStub.new
          stub(@rubyforge).configure
          stub(@rubyforge).login
          stub(@rubyforge).add_release(nil, "zomg", "1.2.3", "pkg/zomg-1.2.3.gem")

          @gempsec = Object.new
          stub(@gemspec).description {"The zomg gem rocks."}
          stub(@gemspec).rubyforge_project { nil }
          stub(@gemspec).name {"zomg"}
          
          @gemspec_helper = Object.new
          stub(@gemspec_helper).write
          stub(@gemspec_helper).gem_path {'pkg/zomg-1.2.3.gem'}
          stub(@gemspec_helper).update_version('1.2.3')

          @output = StringIO.new

          @command                = Jeweler::Commands::ReleaseToRubyforge.new
          @command.output         = @output
          @command.repo           = @repo
          @command.gemspec        = @gemspec
          @command.gemspec_helper = @gemspec_helper
          @command.version        = '1.2.3'
          @command.ruby_forge     = @rubyforge
        end
        
        should "raise error" do
          assert_raises RuntimeError, /not configured/i do
            @command.run
          end
        end
      end
      
      context "after running when rubyforge_project is not defined in ~/.rubyforge/auto_config.yml" do
        setup do
          @rubyforge = RubyForgeStub.new
          stub(@rubyforge).configure
          stub(@rubyforge).login
          stub(@rubyforge).add_release("some_project_that_doesnt_exist", "zomg", "1.2.3", "pkg/zomg-1.2.3.gem") do
            raise RuntimeError, "no <group_id> configured for <some_project_that_doesnt_exist>"
          end

          @gempsec = Object.new
          stub(@gemspec).description {"The zomg gem rocks."}
          stub(@gemspec).rubyforge_project { "some_project_that_doesnt_exist" }
          stub(@gemspec).name {"zomg"}
          
          @gemspec_helper = Object.new
          stub(@gemspec_helper).write
          stub(@gemspec_helper).gem_path {'pkg/zomg-1.2.3.gem'}
          stub(@gemspec_helper).update_version('1.2.3')

          @output = StringIO.new

          @command                = Jeweler::Commands::ReleaseToRubyforge.new
          @command.output         = @output
          @command.repo           = @repo
          @command.gemspec        = @gemspec
          @command.gemspec_helper = @gemspec_helper
          @command.version        = '1.2.3'
          @command.ruby_forge     = @rubyforge
        end
        
        should "raise error" do
          assert_raises RuntimeError, /no <group_id> configured/i do
            @command.run
          end
        end
      end
      
    end
  end
end