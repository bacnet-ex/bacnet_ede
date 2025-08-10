defmodule BACnetEDE.ObjectTypes do
  @moduledoc """
  The Object Types contain a number of rows or data, identified by its reference number,
  listing an enumeration of BACnet object types.
  BACnet object types are defined by the ASHRAE 135 BACnet protocol standard.

  The library `bacstack` contains BACnet protocol enumerations,
  so if you already use a BACnet library, you do not need to parse object types files,
  because the object types are standardized in the BACnet protocol.
  Only proprietary object types are not standardized (which no one should ever use).
  """

  alias BACnetEDE.CSV.TwoCellFormat

  @typedoc """
  Object Types are keyed by the BACnet protocol enumeration number
  to the text as specified in the EDE data (something like "Analog Input").

  The text is though transformed from underscored to a space separated title case.
  For example `analog_input` is changed to `Analog Input`, `analog output` to `Analog Output`.
  But no further modifications are done.
  """
  @type t :: %__MODULE__{
          object_types: %{optional(non_neg_integer()) => String.t()}
        }

  defstruct object_types: %{}

  @typedoc """
  Available options for `from_binary/2`, `from_file/2` and `from_stream/2`.

  See `t:parse_options/0` for a description of the available options.
  """
  @type parse_option :: {:csv_parser, module()}

  @typedoc """
  Available options for `from_binary/2`, `from_file/2` and `from_stream/2`.

  Available options:
  - `csv_parser: module()` - Optional. A module implementing the Nimble CSV behaviour.
    The default CSV parser uses semicolons and CRLF newlines as separator.
    You may have the need for a different separator (i.e. comma) for your file.
  """
  @type parse_options :: [parse_option()]

  @typedoc """
  Available options for `to_binary/2`, `to_file/3` and `to_stream/2`.

  See `t:dump_options/0` for a description of the available options.
  """
  @type dump_option ::
          {:csv_encoder, module()}
          | {:fill_all_columns, boolean()}

  @typedoc """
  Available options for `to_binary/2`, `to_file/3` and `to_stream/2`.

  Available options:
  - `csv_encoder: module()` - Optional. A module implementing the Nimble CSV behaviour.
    The default CSV encoder uses semicolons and CRLF newlines as separator.
    You may have the need for a different separator (i.e. comma) for your file.
  - `fill_all_columns: boolean()` - Optional. Ensures all rows have the same amount of columns.
    By default, only the necessary amount of columns per row is used for the header part.
  """
  @type dump_options :: [dump_option()]

  @doc """
  Parses the given binary as an Object Types EDE file.

  See `t:parse_options/0` for a description of the available options.
  """
  @spec from_binary(binary(), parse_options()) :: {:ok, t()} | {:error, term()}
  def from_binary(binary, opts \\ []) when is_binary(binary) and is_list(opts) do
    with {:ok, result} <- TwoCellFormat.from_binary(binary, opts) do
      process_parsing(result)
    end
  end

  @doc """
  Parses an Object Types EDE file from a CSV file path.
  This function uses line streaming for the parsing process.

  See `t:parse_options/0` for a description of the available options.
  """
  @spec from_file(Path.t(), parse_options()) :: {:ok, t()} | {:error, term()}
  def from_file(path, opts \\ []) when is_binary(path) and is_list(opts) do
    with {:ok, result} <- TwoCellFormat.from_file(path, opts) do
      process_parsing(result)
    end
  end

  @doc """
  Parses an Object Types EDE file from a CSV stream (i.e. a file stream).

  Make sure the stream is line-orientated or use NimbleCSV's `to_line_stream/1` if you can't.
  See `BACnetEDE.CSV.to_line_stream/1` for the default parser's function.

  See `t:parse_options/0` for a description of the available options.
  """
  @spec from_stream(Enumerable.t(), parse_options()) :: {:ok, t()} | {:error, term()}
  def from_stream(stream, opts \\ []) when is_list(opts) do
    with {:ok, result} <- TwoCellFormat.from_stream(stream, opts) do
      process_parsing(result)
    end
  end

  defp process_parsing(%{} = result) do
    rows =
      Map.new(result.rows, fn {key, value} ->
        new_value =
          value
          |> String.replace("_", " ")
          |> String.split(" ")
          |> Enum.map_join(" ", fn text ->
            String.capitalize(text, :default)
          end)

        {key, new_value}
      end)

    {:ok, %__MODULE__{object_types: rows}}
  end

  @doc """
  Dumps the given Object Types EDE data into a CSV encoded binary.

  See `t:dump_options/0` for a description of the available options.
  """
  @spec to_binary(t(), dump_options()) :: {:ok, binary()} | {:error, term()}
  def to_binary(%__MODULE__{object_types: %{} = object_types} = _object_types, opts \\ [])
      when is_list(opts) do
    if not Keyword.keyword?(opts) do
      raise ArgumentError, "to_binary/2 expected a keyword list, got: #{inspect(opts)}"
    end

    twc = %TwoCellFormat{
      top_line: "Encoding of BACnet Object Types",
      headers: ["Code", "Object Type"],
      rows: object_types
    }

    TwoCellFormat.to_binary(twc, opts)
  end

  @doc """
  Dumps the given Object Types EDE data into a CSV encoded file.

  See `t:dump_options/0` for a description of the available options.
  """
  @spec to_file(t(), Path.t(), dump_options()) :: {:ok, Enumerable.t()} | {:error, term()}
  def to_file(%__MODULE__{object_types: %{} = object_types} = _object_types, path, opts \\ [])
      when is_binary(path) and is_list(opts) do
    if not Keyword.keyword?(opts) do
      raise ArgumentError, "to_file/3 expected a keyword list, got: #{inspect(opts)}"
    end

    twc = %TwoCellFormat{
      top_line: "Encoding of BACnet Object Types",
      headers: ["Code", "Object Type"],
      rows: object_types
    }

    TwoCellFormat.to_file(twc, path, opts)
  end

  @doc """
  Dumps the given Object Types EDE data into a CSV encoded stream.

  See `t:dump_options/0` for a description of the available options.
  """
  @spec to_stream(t(), dump_options()) :: {:ok, Enumerable.t()} | {:error, term()}
  def to_stream(%__MODULE__{object_types: %{} = object_types} = _object_types, opts \\ [])
      when is_list(opts) do
    if not Keyword.keyword?(opts) do
      raise ArgumentError, "to_stream/2 expected a keyword list, got: #{inspect(opts)}"
    end

    twc = %TwoCellFormat{
      top_line: "Encoding of BACnet Object Types",
      headers: ["Code", "Object Type"],
      rows: object_types
    }

    TwoCellFormat.to_stream(twc, opts)
  end
end
