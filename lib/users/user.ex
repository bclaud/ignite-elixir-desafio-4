defmodule Flightex.Users.User do
  @keys [:name, :email, :cpf, :id]
  @enforce_keys @keys
  defstruct @keys

  def build(name, email, cpf) when is_bitstring(cpf) do
    id = UUID.uuid4()

    {:ok, %__MODULE__{id: id, name: name, email: email, cpf: cpf}}
  end

  def build(_name, _email, cpf) when is_integer(cpf), do: {:error, "Cpf must be a String"}
end
