defmodule TodoSupervised.System do
  def start_link do
    Supervisor.start_link(
      [
        TodoSupervised.Database,
        TodoSupervised.Cache
      ],
      strategy: :one_for_one
    )
  end
end
