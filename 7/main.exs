data = File.read!("input.txt")

lines = String.split(data, "\n")

# a = [1, 2, 3]

IO.puts("heyl")
IO.puts(List.first(lines))

defmodule Tree do
  @behaviour Access
  defdelegate get(tree, key, default), to: Map
  defdelegate fetch(tree, key), to: Map
  defdelegate get_and_update(tree, key, func), to: Map
  defdelegate pop(tree, key), to: Map

  defstruct name: "",
            dir_size: 0,
            total_size: 0,
            # Map of dir_names to Trees
            children: %{}

  def lines do
    data = File.read!("input.txt")
    lines = String.split(data, "\n")
    lines
  end
end

defmodule State do
  defstruct tree: %Tree{},
            current_working_tree: [],
            is_listing: false

  def example do
    %State{
      tree: %Tree{
        name: "/",
        dir_size: 1,
        children: %{
          a: %Tree{
            name: "a",
            dir_size: 1,
            children: %{}
          },
          b: %Tree{
            name: "b",
            dir_size: 2,
            children: %{
              c: %Tree{
                name: "c",
                dir_size: 3,
                children: %{}
              }
            }
          }
        }
      },
      current_working_tree: [:a, :b]
    }
  end

  def run(%State{is_listing: true} = state, "dir " <> child_dir_name) do
    state
  end

  def run(%State{is_listing: true} = state, sizeAndChildDirName) do
    captures = Regex.named_captures(~r/(?<size>\w+) (?<child_dir_name>\w+)/, sizeAndChildDirName)
    State.add_child(state, captures.size, captures.child_dir_name)
  end

  def add_child(state, size, child_dir_name) do
    child_tree = %Tree{name: child_dir_name, dir_size: size}
    tree = state.tree
    # TODO: more here. Deep insert based on the state current_working_tree
    # children = tree.children
    # tree.children = [child_tree | children]
    %State{state | tree: tree}
  end

  def run(state, line) do
    state
  end

  def run(state, "$ ls") do
    case state.is_listing do
      true -> raise "cannot list while listing"
      false -> %State{state | is_listing: true}
    end
  end

  def run(state, "$ cd " <> dir) do
    newState =
      case dir do
        "/" ->
          %State{state | current_working_tree: []}

        ".." ->
          %State{state | current_working_tree: pop(state.current_working_tree)}

        directory ->
          %State{state | current_working_tree: state.current_working_tree ++ [directory]}
      end

    %State{newState | is_listing: false}
  end

  defp pop(list) do
    {_, r} = List.pop_at(list, -1)
    r
  end
end
