defmodule RedisApp.Pair do
  use Ecto.Schema
  import Ecto.Changeset

  schema "pairs" do
    field :key, :string
    field :value, :string
  end

  def changeset(pair, params) do
    pair
    |> cast(params, [:key, :value])
    |> validate_required([:key, :value])
  end
end
