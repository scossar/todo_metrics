defmodule TodoSupervised.Server do
  # A temporary worker isn't restarted on termination. Having the processes under
  # a supervision tree makes it possible to terminate the entire supervision subtree
  # without leaving dangling subprocesses though.
  use GenServer, restart: :temporary

  def start_link(name) do
    # Use the `via_tuple` name to register the processes with the
    # ProcessRegistry.
    GenServer.start_link(__MODULE__, name, name: via_tuple(name))
  end

  defp via_tuple(name) do
    # Using `{__MODULE__, name}` as the name avoids possible naming
    # conflicts between todo server keys and database worker keys.
    TodoSupervised.ProcessRegistry.via_tuple({__MODULE__, name})
  end

  def add_entry(todo_server, new_entry) do
    GenServer.cast(todo_server, {:add_entry, new_entry})
  end

  def entries(todo_server, date) do
    GenServer.call(todo_server, {:entries, date})
  end

  @impl GenServer
  def init(name) do
    IO.puts("Starting TodoSupervised.Server for #{name}.")
    {:ok, {name, nil}, {:continue, :init}}
  end

  @impl GenServer
  def handle_continue(:init, {name, nil}) do
    todo_list = TodoSupervised.Database.get(name) || TodoSupervised.List.new()
    {:noreply, {name, todo_list}}
  end

  @impl GenServer
  def handle_cast({:add_entry, new_entry}, {name, todo_list}) do
    new_list = TodoSupervised.List.add_entry(todo_list, new_entry)
    TodoSupervised.Database.store(name, new_list)
    {:noreply, {name, new_list}}
  end

  @impl GenServer
  def handle_call({:entries, date}, _, {name, todo_list}) do
    {
      :reply,
      TodoSupervised.List.entries(todo_list, date),
      {name, todo_list}
    }
  end
end
