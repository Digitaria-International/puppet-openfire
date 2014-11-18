require 'spec_helper'

describe 'openfire::user' do
	let(:name) { 'myuser' }

	it { should contain_class('openfire::params') }
	it do 
		should contain_exec('CreateUser:${name}').with({
			'command'   => "mysql ${dbname} -e \"${sql}\"",
      'path'      => '/usr/bin/',
      'logoutput' => 'true',
		})
	end

	context 'empty password' do
		let(:params) { :password => '' }
		it { shoould fail() }

	end

end