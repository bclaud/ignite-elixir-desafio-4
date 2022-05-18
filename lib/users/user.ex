defmodule Flightex.Users.User do
  @keys [:name, :email, :cpf, :id]
  @enforce_keys @keys
  defstruct @keys

  def build(%{name: _name, email: _email, cpf: _cpf} = params) do
    params = Map.put(params, :id, UUID.uuid4())
    struct(__MODULE__, params)
  end
end
