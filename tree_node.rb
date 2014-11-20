class PolyTreeNode

  def initialize(value)
    @value = value
    @parent = nil
    @children = []
  end

  attr_reader :value,:children, :parent

  def parent=(node)
    @parent.children.delete(self) if @parent
    @parent = node
    node.children << self if node
  end

  def add_child(child_node)
    child_node.parent = self
  end

  def remove_child(child)
    raise "not a child" unless is_child?(child)
    child.parent = nil
  end

  def is_child?(node)
    self.children.include?(node)
  end

  def dfs(target_value)
    #base case
    return self if value == target_value

    if children.empty?
      return nil
    else
      children.each do |child|
        dfs_child = child.dfs(target_value)
        return dfs_child if dfs_child
      end
      return nil
    end
  end

  def bfs(target_value)
    queue = [self]

    until queue.empty?
      current_node = queue.shift
      return current_node if current_node.value == target_value
      queue.concat(current_node.children)
    end

    nil
  end

  def trace_path_back
    path = [self.value]
    current_node = self

    until current_node.parent.nil?
      current_node = current_node.parent
      path.unshift(current_node.value)
    end

    path
  end


  protected

    attr_writer :children
end
