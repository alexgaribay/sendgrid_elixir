defmodule SendGrid.Response do
  @moduledoc """
  Represents the result from performing a request.
  """

  alias SendGrid.Response

  @type t :: %Response{
          body: map(),
          headers: Keyword.t(),
          status: pos_integer()
        }

  @enforce_keys ~w(body headers status)a
  defstruct ~w(body headers status)a
end
