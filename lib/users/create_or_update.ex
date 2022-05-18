defmodule Flightex.Users.CreateOrUpdate do
  alias Flightex.Users.Agent, as: UserAgent
  alias Flightex.Users.User

  def call(%{name: name, email: email, cpf: cpf}) do
    User.build(name, email, cpf)
    |> save()
  end

  defp save({:ok, user}) do
    UserAgent.save(user)
  end

  defp save(error), do: error
end
