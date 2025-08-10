defmodule BACnetEDE.Project do
  @moduledoc """
  The `Project` is the main struct and contains the project information as included in the EDE.

  Each EDE file has a header which includes key information, such as:
  - Project Name
  - Version of the EDE file
  - Timestamp of the last change
  - Author of the last change
  - Version of the EDE file layout (2.3 is the latest currently)
  - Available columns, additionally to the mandatory ones

  The struct then contains a map of all the objects included in the EDE file,
  they are keyed by the `keyname`. See `BACnetEDE.Project.Object` for further details on objects.

  Validation on the project struct will happen:
  - Validating types as per `t:t/0` type
  - Validating each object passes their type test

  Information on the keys of the struct can be found in the `t:t/0` docs.
  """

  alias BACnetEDE.Project.Object

  @dialyzer {:no_contracts, [new: 0]}

  @typedoc """
  Represents an EDE project and contains basic project information
  and objects that were part of the EDE.

  Layout version is ideally 2.2 or 2.3, as those were the ones used for testing.
  Layout version 2.3 is the current latest version.
  """
  @type t :: %__MODULE__{
          project_name: String.t(),
          version: String.t(),
          timestamp_last_change: NaiveDateTime.t(),
          author_last_change: String.t(),
          layout_version: String.t(),
          objects: %{
            optional(String.t()) => Object.t()
          }
        }

  @enforce_keys [
    :project_name,
    :version,
    :timestamp_last_change,
    :author_last_change
  ]
  defstruct [
    :project_name,
    :version,
    :timestamp_last_change,
    author_last_change: "",
    layout_version: "2.3",
    objects: %{}
  ]

  @doc false
  @spec new() :: t()
  def new() do
    %__MODULE__{
      project_name: nil,
      version: nil,
      timestamp_last_change: nil,
      author_last_change: "",
      objects: %{}
    }
  end

  @doc false
  @spec new(Enumerable.t()) :: t()
  def new(keys) do
    __MODULE__
    |> struct(keys)
    |> Map.update!(:author_last_change, fn
      nil -> ""
      other -> other
    end)
    |> Map.update!(:objects, fn
      nil -> %{}
      other -> other
    end)
  end

  @doc """
  Validates the struct (type validation).
  """
  @spec valid?(t()) :: boolean()
  def valid?(%__MODULE__{} = t) do
    is_binary(t.project_name) and
      is_binary(t.version) and
      is_struct(t.timestamp_last_change, NaiveDateTime) and
      (is_binary(t.author_last_change) or is_nil(t.author_last_change)) and
      is_binary(t.layout_version) and
      is_map(t.objects) and
      Enum.all?(t.objects, fn
        {key, %Object{} = value} -> is_binary(key) and Object.valid?(value)
        _else -> false
      end)
  end
end
