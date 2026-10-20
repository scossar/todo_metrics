defmodule TodoSupervised.Database do
  @pool_size 3
  @db_folder "./persist"

  def start_link do
    File.mkdir_p!(@db_folder)

    children = Enum.map(1..@pool_size, &worker_spec/1)
    Supervisor.start_link(children, strategy: :one_for_one)
  end

  defp worker_spec(worker_id) do
    default_worker_spec = {TodoSupervised.DatabaseWorker, {@db_folder, worker_id}}
    Supervisor.child_spec(default_worker_spec, id: worker_id)
  end

  # Since the module is a supervisor and doesn't contain `use GenServer`
  # `child_spec` needs to be explicitly implemented.
  def child_spec(_) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, []},
      # defaults to `:worker`
      type: :supervisor
    }
  end

  def store(key, data) do
    key
    |> choose_worker()
    |> TodoSupervised.DatabaseWorker.store(key, data)
  end

  def get(key) do
    key
    |> choose_worker()
    |> TodoSupervised.DatabaseWorker.get(key)
  end

  defp choose_worker(key) do
    :erlang.phash2(key, @pool_size) + 1
  end
end
