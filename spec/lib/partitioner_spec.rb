require 'spec_helper'

describe Partitioner do
  let(:partitioner) { Partitioner.new }

  before do
    YAML.stub(:load_file).with(Partitioner::BUILD_YML).and_return(build_yml)
    YAML.stub(:load_file).with(Partitioner::KOCHIKU_YML).and_return(kochiku_yml)
    File.stub(:exist?).with(Partitioner::KOCHIKU_YML).and_return(kochiku_yml_exists)
  end

  let(:build_yml) {{
    'host1' => {
      'type'  => 'rspec',
      'files' => '<FILES>'
    },
    'bad config' => {}
  }}

  let(:kochiku_yml) {[
    { 'type' => 'rspec', 'glob' => 'spec/**/*_spec.rb', 'workers' => 3, 'balance' => balance }
  ]}

  let(:balance) { 'alphabetically' }

  describe '#partitions' do
    subject { partitioner.partitions }

    context 'when there is not a kochiku.yml' do
      let(:kochiku_yml_exists) { false }
      it { should == [{'type' => 'rspec', 'files' => '<FILES>'}] }
    end

    context 'when there is a kochiku.yml' do
      let(:kochiku_yml_exists) { true }

      before { Dir.stub(:[]).and_return(matches) }

      context 'when there are no files matching the glob' do
        let(:matches) { [] }
        it { should == [] }
      end

      context 'when there is one file matching the glob' do
        let(:matches) { %w(a) }
        it { should == [{ 'type' => 'rspec', 'files' => %w(a) }] }
      end

      context 'when there are many files matching the glob' do
        let(:matches) { %w(a b c d) }
        it { should == [
          { 'type' => 'rspec', 'files' => %w(a b) },
          { 'type' => 'rspec', 'files' => %w(c) },
          { 'type' => 'rspec', 'files' => %w(d) },
        ] }

        context 'and balance is round_robin' do
          let(:balance) { 'round_robin' }
          it { should == [
            { 'type' => 'rspec', 'files' => %w(a d) },
            { 'type' => 'rspec', 'files' => %w(b) },
            { 'type' => 'rspec', 'files' => %w(c) },
          ] }
        end

        context 'and balance is size' do
          let(:balance) { 'size' }

          before do
            File.stub(:size).with('a').and_return(1)
            File.stub(:size).with('b').and_return(1000)
            File.stub(:size).with('c').and_return(100)
            File.stub(:size).with('d').and_return(10)
          end

          it { should == [
            { 'type' => 'rspec', 'files' => %w(b a) },
            { 'type' => 'rspec', 'files' => %w(c) },
            { 'type' => 'rspec', 'files' => %w(d) },
          ] }
        end

        context 'and balance is size_greedy_partitioning' do
          let(:balance) { 'size_greedy_partitioning' }

          before do
            File.stub(:size).with('a').and_return(1)
            File.stub(:size).with('b').and_return(1000)
            File.stub(:size).with('c').and_return(100)
            File.stub(:size).with('d').and_return(10)
          end

          it { should =~ [
            { 'type' => 'rspec', 'files' => %w(b) },
            { 'type' => 'rspec', 'files' => %w(c) },
            { 'type' => 'rspec', 'files' => %w(d a) },
          ] }
        end
      end
    end
  end
end
