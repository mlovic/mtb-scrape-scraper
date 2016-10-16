require 'timeout'
require 'yaml'

module Helpers

  def write_fixture(name, str)
    f = File.new("#{fixture_path}/#{name}", 'w')
    f.write str
    f.close
  end
  
  # figure this out. how to do fixtures
  def fixture_path
    File.expand_path('fixtures', 'spec')
  end

  def fixture(file)
    f = File.read(fixture_path + '/' + file)
    if file.match(/\.yml$/)
      YAML::load(f)
    else
      f
    end
  end

  def wait_until(timeout = 1, sleep_time = 0.01)
    Timeout::timeout(timeout) do # raises exception if timeout
      while !yield
        sleep sleep_time
      end
    end
  end

end
