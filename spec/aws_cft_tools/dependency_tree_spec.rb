# frozen_string_literal: true

require 'spec_helper'

RSpec.describe AwsCftTools::DependencyTree do
  let(:tree) { described_class.new }

  describe 'interdependencies' do
    before do
      tree.provided('vpc/base.yaml', 'vpc-id')
      tree.required('network/vpc.yaml', 'vpc-id')
    end

    it 'has no undefined variables' do
      expect(tree.undefined_variables).to be_empty
    end

    it 'finds the dependency' do # things _this_ depends on
      expect(tree.dependencies_for('network/vpc.yaml')).to eq ['vpc/base.yaml']
    end

    it 'finds the dependents' do # things dependent on _this_
      expect(tree.dependents_for('vpc/base.yaml')).to eq ['network/vpc.yaml']
    end
  end

  describe '#linked' do
    before do
      tree.linked('A', 'B')
    end

    it 'has no undefined variables' do
      expect(tree.undefined_variables).to be_empty
    end

    it 'finds the dependency' do # things _this_ depends on
      expect(tree.dependencies_for('B')).to eq ['A']
    end

    it 'finds the dependents' do # things dependent on _this_
      expect(tree.dependents_for('A')).to eq ['B']
    end
  end

  describe '#closed_subset' do
    before do
      tree.linked('A', 'B')
      tree.linked('C', 'D')
    end

    it 'returns the items with no downstream dependencies' do
      expect(tree.closed_subset(%w[C B])).to eq ['B']
    end

    it 'returns the items that are interdependent but with no downstream dependencies' do
      expect(tree.closed_subset(%w[D C B])).to eq %w[D C B]
    end
  end
end
