data = File.read!("input.txt")

lines = String.split(data, "\n")

# a = [1, 2, 3]

IO.puts("heyl")
IO.puts(List.first(lines))

defmodule Tree do
  defstruct name: "", dirSize: 0, totalSize: 0, children: []

  def lines do
    data = File.read!("input.txt")
    lines = String.split(data, "\n")
    lines
  end
end

defmodule State do
  defstruct tree: %Tree{},
            currentWorkingTree: [],
            isListing: false

  def run(state, line) do
    state
  end

  def run(state, "$ ls") do
    case state.isListing do
      true -> raise "cannot list while listing"
      false -> %State{state | isListing: true}
    end
  end

  def run(state, "$ cd " <> dir) do
    case dir do
      "/" -> %State{state | currentWorkingTree: []}
      ".." -> %State{state | currentWorkingTree: pop(state.currentWorkingTree)}
    end
  end

  defp pop(list) do
    {_, r} = List.pop_at(list, -1)
    r
  end
end
