defmodule EctoCellar do
  alias EctoCellar.Version

  def store(%mod{} = model, id_type \\ :id) do
    case Version.create(%{
           model_name: mod |> inspect(),
           model_id: model |> Map.fetch!(id_type) |> inspect(),
           version: model |> Jason.encode!()
         }) do
      {:ok, _} -> {:ok, model}
      error -> error
    end
  end

  def store!(%mod{} = model, id_type \\ :id) do
    Version.create!(%{
      model_name: mod |> inspect(),
      model_id: model |> Map.fetch!(id_type) |> inspect(),
      version: model |> Jason.encode!()
    })

    model
  end

  def one(%mod{} = model, timestamp, id_type \\ :id) do
    Version.one(
      mod,
      timestamp,
      model |> Map.fetch!(id_type)
    )
    |> to_model(mod)
  end

  def all(%mod{} = model, id_type \\ :id) do
    Version.all(
      mod,
      model |> Map.fetch!(id_type)
    )
    |> to_models(mod)
  end

  defp to_models(versions, mod) do
    versions
    |> Enum.map(&to_model(&1, mod))
  end

  defp to_model(version, mod) do
    struct(
      mod.__struct__,
      Jason.decode!(version.version)
    )
  end
end
