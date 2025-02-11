defmodule RedisApp.PairContext do
  def set(key, value) do
    case Redix.command(:redix, ["SET", key, value]) do
      {:ok, _} -> :ok
      {:error, reason} -> {:error, reason}
    end
  end

  def get(key) do
    case Redix.command(:redix, ["GET", key]) do
      {:ok, nil} -> {:error, :not_found}
      {:ok, value} -> {:ok, value}
      {:error, reason} -> {:error, reason}
    end
  end

  def get_pair(key) do
    case Redix.command(:redix, ["GET", key]) do
      {:ok, nil} -> {:error, :not_found}
      {:ok, value} -> %{key: key, value: value}
      {:error, reason} -> {:error, reason}
    end
  end

  def delete(key) do
    case Redix.command(:redix, ["DEL", key]) do
      {:ok, _} -> :ok
      {:error, reason} -> {:error, reason}
    end
  end

  def list_all_pairs do
    with {:ok, keys} <- Redix.command(:redix, ["KEYS", "*"]),
         pairs <-
           Enum.map(keys, fn key ->
             case Redix.command(:redix, ["GET", key]) do
               {:ok, value} -> %{key: key, value: value}
               {:error, _reason} -> {key, nil}
             end
           end) do
      pairs
    else
      {:error, reason} -> {:error, reason}
    end
  end
end
