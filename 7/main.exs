data = File.read!("input.txt")
lines = String.split(data, "\n")

# Enum.reduce(lines, %State{}, &State.run/2)

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

  def omg do
    Enum.reduce(lines(), %State{}, &State.run!/2)
  end

  def lines do
    data = File.read!("input.txt")
    lines = String.split(data, "\n")
    lines
  end
end

defmodule State do
  @behaviour Access
  defdelegate get(state, key, default), to: Map
  defdelegate fetch(state, key), to: Map
  defdelegate get_and_update(state, key, func), to: Map
  defdelegate pop(state, key), to: Map

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

  def run!(line, state) do
    IO.puts(inspect(line))
    State.run(line, state)
  end

  def run("$ cd " <> dir, state) do
    IO.puts(dir)
    IO.puts("CDCDCD")

    newState =
      case dir do
        "/" ->
          %State{state | current_working_tree: []}

        ".." ->
          %State{state | current_working_tree: pop(state.current_working_tree)}

        directory ->
          %State{state | current_working_tree: state.current_working_tree ++ [directory]}
      end

    IO.puts("CDCDCD")
    IO.puts(newState.current_working_tree)
    %State{newState | is_listing: false}
  end

  def run("$ ls", state) do
    case state.is_listing do
      true -> raise "cannot list while listing"
      false -> %State{state | is_listing: true}
    end
  end

  def run("dir " <> child_dir_name, %State{is_listing: true} = state) do
    add_child(state, 0, child_dir_name)
  end

  def run(size_and_child_dir_name, %State{is_listing: true} = state) do
    captures =
      Regex.named_captures(~r/(?<dir_size>\w+) (?<child_dir_name>\w+)/, size_and_child_dir_name)

    # IO.puts(inspect(state))
    # IO.puts(inspect(captures))

    add_child(
      state,
      Map.fetch!(captures, "dir_size"),
      Map.fetch!(captures, "child_dir_name")
    )
  end

  # def run(state, line) do
  # state
  # end

  defp add_child(state, size, child_dir_name) do
    child_tree = %Tree{name: child_dir_name, dir_size: size}

    path =
      Enum.intersperse([:tree | state.current_working_tree], :children) ++
        [:children, child_dir_name]

    IO.puts("path: " <> inspect(path))

    put_in(state, path, child_tree)
  end

  defp pop(list) do
    {_, r} = List.pop_at(list, -1)
    r
  end
end
