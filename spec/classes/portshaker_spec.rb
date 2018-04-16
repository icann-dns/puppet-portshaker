require 'spec_helper'

describe 'portshaker' do
  # by default the hiera integration uses hiera data from the shared_contexts.rb file
  # but basically to mock hiera you first need to add a key/value pair
  # to the specific context in the spec/shared_contexts.rb file
  # Note: you can only use a single hiera context per describe/context block
  # rspec-puppet does not allow you to swap out hiera data on a per test block
  # include_context :hiera
  let(:node) { 'portshaker.example.com' }

  # below is the facts hash that gives you the ability to mock
  # facts on a per describe/context block.  If you use a fact in your
  # manifest you should mock the facts below.
  let(:facts) do
    {}
  end

  # below is a list of the resource parameters that you can override.
  # By default all non-required parameters are commented out,
  # while all required parameters will require you to add a value
  let(:params) do
    {
      #:package => "portshaker",
      #:mirror_base_dir => "/var/cache/portshaker",
      #:ports_trees => ["default"],
      #:default_ports_tree => "/usr/ports",
      #:default_merge_from => "freebsd",
      #:default_poudriere_tree => "default",
      #:poudriere_ports_mountpoint => "/usr/local/poudriere/ports",
      #:git_branch => "master",
      #:use_zfs => false,
      #:use_poudriere => false,
      #:portshaker_conf_file => "/usr/local/etc/portshaker.conf",
      #:add_cron => true,
      #:git_clone_uri => :undef,

    }
  end
  # add these two lines in a single test block to enable puppet and hiera debug mode
  # Puppet::Util::Log.level = :debug
  # Puppet::Util::Log.newdestination(:console)
  # This will need to get moved
  # it { pp catalogue.resources }
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end
      describe 'check default config' do
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('portshaker') }
        it { is_expected.to contain_package('portshaker') }
        it do
          is_expected.to contain_file('/usr/local/etc/portshaker.conf').with(
            'ensure' => 'file',
            'require' => 'Package[portshaker]'
          ).with_content(
            %r{mirror_base_dir="/var/cache/portshaker"}
          ).with_content(
            %r{ports_trees="default"}
          ).with_content(
            %r{use_zfs="no"}
          ).with_content(
            %r{default_ports_tree="/usr/ports"}
          ).with_content(
            %r{default_merge_from="freebsd"}
          )
        end
        it do
          is_expected.to contain_file('/usr/local/etc/portshaker.d/freebsd').with(
            'ensure' => 'file',
            'mode' => '0555',
            'source' => 'puppet:///modules/portshaker/usr/local/etc/portshaker.d/freebsd',
            'require' => 'Package[portshaker]'
          )
        end
        it do
          is_expected.not_to contain_file('/usr/local/etc/portshaker.d/gitrepo')
        end
        it do
          is_expected.to contain_cron('portshaker update').with(
            'command' => 'OUT=$(/usr/local/bin/portshaker -UM) || echo ${OUT}',
            'hour' => '0'
          )
        end
      end
      describe 'Change Defaults' do
        context 'package' do
          before { params.merge!(package: 'foobar') }
          it { is_expected.to compile }
          it { is_expected.to contain_package('foobar') }
        end
        context 'mirror_base_dir' do
          before { params.merge!(mirror_base_dir: '/foo/bar') }
          it { is_expected.to compile }
          it do
            is_expected.to contain_file('/usr/local/etc/portshaker.conf').with(
              'ensure' => 'file'
            ).with_content(
              %r{mirror_base_dir="/foo/bar"}
            )
          end
        end
        context 'ports_trees' do
          before { params.merge!(ports_trees: %w(foo bar)) }
          it { is_expected.to compile }
          it do
            is_expected.to contain_file('/usr/local/etc/portshaker.conf').with(
              'ensure' => 'file'
            ).with_content(
              %r{ports_trees="foo bar"}
            )
          end
        end
        context 'default_ports_tree' do
          before { params.merge!(default_ports_tree: '/foo/bar') }
          it { is_expected.to compile }
          it do
            is_expected.to contain_file('/usr/local/etc/portshaker.conf').with(
              'ensure' => 'file'
            ).with_content(
              %r{default_ports_tree="/foo/bar"}
            )
          end
        end
        context 'default_merge_from' do
          before { params.merge!(default_merge_from: 'foobar') }
          it { is_expected.to compile }
          it do
            is_expected.to contain_file('/usr/local/etc/portshaker.conf').with(
              'ensure' => 'file'
            ).with_content(
              %r{default_merge_from="foobar"}
            )
          end
        end
        context 'default_poudriere_tree' do
          before do
            params.merge!(
              use_poudriere: true,
              default_poudriere_tree: 'foobar'
            )
          end
          it { is_expected.to compile }
          it do
            is_expected.to contain_file('/usr/local/etc/portshaker.conf').with(
              'ensure' => 'file'
            ).with_content(
              %r{default_poudriere_tree="foobar"}
            )
          end
        end
        context 'poudriere_ports_mountpoint' do
          before do
            params.merge!(
              use_poudriere: true,
              poudriere_ports_mountpoint: '/foo/bar'
            )
          end
          it { is_expected.to compile }
          it do
            is_expected.to contain_file('/usr/local/etc/portshaker.conf').with(
              'ensure' => 'file'
            ).with_content(
              %r{poudriere_ports_mountpoint="/foo/bar"}
            )
          end
        end
        context 'git_branch' do
          before do
            params.merge!(
              git_clone_uri: {
                'foobar' => {
                  'uri' => 'https://github.com/icann-dns/puppet-portshaker',
                  'branch' => 'foobar'
                }
              }
            )
          end
          it { is_expected.to compile }
          it do
            is_expected.to contain_file('/usr/local/etc/portshaker.d/foobar').with(
              'ensure' => 'file'
            ).with_content(
              %r{git_clone_uri="https://github.com/icann-dns/puppet-portshaker"}
            ).with_content(
              %r{git_branch="foobar"}
            )
          end
        end
        context 'use_zfs' do
          before { params.merge!(use_zfs: true) }
          it { is_expected.to compile }
          it do
            is_expected.to contain_file('/usr/local/etc/portshaker.conf').with(
              'ensure' => 'file'
            ).with_content(
              %r{use_zfs="yes"}
            )
          end
        end
        context 'use_poudriere' do
          before { params.merge!(use_poudriere: true) }
          it { is_expected.to compile }
          it do
            is_expected.to contain_file('/usr/local/etc/portshaker.conf').with(
              'ensure' => 'file'
            ).with_content(
              %r{default_poudriere_tree="default"}
            ).with_content(
              %r{poudriere_ports_mountpoint="/usr/local/poudriere/ports"}
            )
          end
        end
        context 'portshaker_conf_file' do
          before { params.merge!(portshaker_conf_file: '/foo/bar.conf') }
          it { is_expected.to compile }
          it do
            is_expected.to contain_file('/foo/bar.conf').with(
              'ensure' => 'file'
            )
          end
        end
        context 'add_cron' do
          before { params.merge!(add_cron: false) }
          it { is_expected.to compile }
          it { is_expected.not_to contain_cron('portshaker update') }
        end
        context 'git_clone_uri' do
          before do
            params.merge!(
              git_clone_uri: { 
                'foobar' => {
                  'uri' => 'https://foo.bar/icann-dns/puppet-portshaker'
                }
              }
            )
          end
          it { is_expected.to compile }
          it { is_expected.to contain_package('git') }
          it do
            is_expected.to contain_file('/usr/local/etc/portshaker.conf').with(
              'ensure' => 'file'
            ).with_content(
              %r{default_merge_from="freebsd foobar"}
            )
          end
          it do
            is_expected.to contain_file('/usr/local/etc/portshaker.d/foobar').with(
              'ensure' => 'file'
            ).with_content(
              %r{git_clone_uri="https://foo.bar/icann-dns/puppet-portshaker"}
            ).with_content(
              %r{git_branch="master"}
            )
          end
        end
      end
      describe 'check bad type' do
        context 'package' do
          before { params.merge!(package: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'mirror_base_dir' do
          before { params.merge!(mirror_base_dir: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'ports_trees' do
          before { params.merge!(ports_trees: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'default_ports_tree' do
          before { params.merge!(default_ports_tree: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'default_merge_from' do
          before { params.merge!(default_merge_from: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'default_poudriere_tree' do
          before { params.merge!(default_poudriere_tree: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'poudriere_ports_mountpoint' do
          before { params.merge!(poudriere_ports_mountpoint: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'git_branch' do
          before { params.merge!(git_branch: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'use_zfs' do
          before { params.merge!(use_zfs: 'foobar') }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'use_poudriere' do
          before { params.merge!(use_poudriere: 'foobar') }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'portshaker_conf_file' do
          before { params.merge!(portshaker_conf_file: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'add_cron' do
          before { params.merge!(add_cron: 'foobar') }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'git_clone_uri' do
          before { params.merge!(git_clone_uri: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
      end
    end
  end
end
