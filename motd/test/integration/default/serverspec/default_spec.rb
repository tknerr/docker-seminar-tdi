require 'spec_helper'

describe 'motd::default' do

  # Serverspec examples can be found at
  # http://serverspec.org/resource_types.html

  describe file('/var/run/motd') do
    it { should be_file }
    it { should be_mode 644 }
    it { should contain "hellooooo" }
  end

end
