ExUnit.start()

defmodule KnineTest.Assertion do
  @doc """
  Helper for refute assertion on pattern match
  """

  defmacro refute_match({:=, _, [left, right]}) do
    quote do
      case unquote(right) do
        unquote(left) -> assert false
        _ -> assert 1==1
      end
    end
  end
end
