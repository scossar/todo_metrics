defmodule TodoSupervisedTest do
  use ExUnit.Case
  doctest TodoSupervised

  test "greets the world" do
    assert TodoSupervised.hello() == :world
  end
end
