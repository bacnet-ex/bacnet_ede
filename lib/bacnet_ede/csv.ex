NimbleCSV.define(BACnetEDE.CSV,
  separator: ";",
  escape: "\"",
  line_separator: "\r\n",
  moduledoc: """
  Default CSV parser and encoder for this library.
  It uses CRLF `\\r\\n` line separator and semicolons `;` as separator.
  """
)

defmodule BACnetEDE.CSV.TwoCellFormat do
  @moduledoc false
  # For internal use only

  alias BACnetEDE.CSV

  @bom :unicode.encoding_to_bom(:utf8)

  @typedoc """
  Top line is the first line in the CSV, if it is prefixed with a `#`,
  and doesn't contain more than one used column.

  Headers is the column "header" in the CSV, which should be prefixed with a `#`.
  Two columns must be present.

  Rows contains the final data.
  """
  @type t :: %__MODULE__{
          top_line: binary() | nil,
          headers: [binary()] | nil,
          rows: %{optional(non_neg_integer()) => binary()}
        }

  defstruct top_line: nil, headers: [], rows: %{}

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
  Parses the given binary as a two-column EDE file (i.e. Units).

  See `t:parse_options/0` for a description of the available options.
  """
  @spec from_binary(binary(), parse_options()) :: {:ok, t()} | {:error, term()}
  def from_binary(binary, opts \\ []) when is_binary(binary) and is_list(opts) do
    if not Keyword.keyword?(opts) do
      raise ArgumentError, "from_binary/2 expected a keyword list, got: #{inspect(opts)}"
    end

    csv_mod = opts[:csv_parser] || CSV

    binary
    |> csv_mod.parse_string(skip_headers: false)
    |> Stream.with_index(1)
    |> parse_csv_lines(opts)
  end

  @doc """
  Parses a two-column EDE file (i.e. Units) from a CSV file path.
  This function uses line streaming for the parsing process.

  See `t:parse_options/0` for a description of the available options.
  """
  @spec from_file(Path.t(), parse_options()) :: {:ok, t()} | {:error, term()}
  def from_file(path, opts \\ []) when is_binary(path) and is_list(opts) do
    if not Keyword.keyword?(opts) do
      raise ArgumentError, "from_file/2 expected a keyword list, got: #{inspect(opts)}"
    end

    # Make sure the file exists before calling File.stream!/3
    with {:ok, _stat} <- File.stat(path) do
      path
      |> File.stream!(:line, encoding: :utf8)
      |> from_stream(opts)
    end
  end

  @doc """
  Parses a two-column EDE file (i.e. Units) from a CSV stream (i.e. a file stream).

  Make sure the stream is line-orientated or use NimbleCSV's `to_line_stream/1` if you can't.
  See `BACnetEDE.CSV.to_line_stream/1` for the default parser's function.

  See `t:parse_options/0` for a description of the available options.
  """
  @spec from_stream(Enumerable.t(), parse_options()) :: {:ok, t()} | {:error, term()}
  def from_stream(stream, opts \\ []) when is_list(opts) do
    if not Keyword.keyword?(opts) do
      raise ArgumentError, "from_stream/2 expected a keyword list, got: #{inspect(opts)}"
    end

    csv_mod = opts[:csv_parser] || CSV

    stream
    |> csv_mod.parse_stream(skip_headers: false)
    |> Stream.with_index(1)
    |> parse_csv_lines(opts)
  end

  @doc """
  Dumps the given two-column EDE data (i.e. Units) into a CSV encoded binary.

  See `t:dump_options/0` for a description of the available options.
  """
  @spec to_binary(t(), dump_options()) :: {:ok, binary()} | {:error, term()}
  def to_binary(%__MODULE__{} = texts, opts \\ []) when is_list(opts) do
    if not Keyword.keyword?(opts) do
      raise ArgumentError, "to_binary/2 expected a keyword list, got: #{inspect(opts)}"
    end

    texts
    |> to_stream(opts)
    |> then(fn
      {:ok, stream} ->
        binary =
          stream
          |> Enum.to_list()
          |> IO.iodata_to_binary()

        {:ok, binary}

      other ->
        other
    end)
  end

  @doc """
  Dumps the given two-column EDE data (i.e. Units) into a CSV file.

  See `t:dump_options/0` for a description of the available options.
  """
  @spec to_file(t(), Path.t(), dump_options()) :: :ok | {:error, term()}
  def to_file(%__MODULE__{} = csv, path, opts \\ []) when is_binary(path) and is_list(opts) do
    if not Keyword.keyword?(opts) do
      raise ArgumentError, "to_file/3 expected a keyword list, got: #{inspect(opts)}"
    end

    # Check if file exists, if not, create it, if it does, clear it
    case File.stat(path) do
      {:ok, _stat} -> File.write(path, "")
      _else -> File.touch!(path)
    end

    file_stream = File.stream!(path)

    csv
    |> to_stream(opts)
    |> then(fn
      {:ok, stream} ->
        stream
        |> Enum.into(file_stream)
        |> Stream.run()

      other ->
        other
    end)
  end

  @doc """
  Dumps the given two-column EDE data (i.e. Units) into a CSV encoded stream.

  See `t:dump_options/0` for a description of the available options.
  """
  @spec to_stream(t(), dump_options()) :: {:ok, Enumerable.t()} | {:error, term()}
  def to_stream(%__MODULE__{} = csv, opts \\ []) when is_list(opts) do
    if not Keyword.keyword?(opts) do
      raise ArgumentError, "to_stream/2 expected a keyword list, got: #{inspect(opts)}"
    end

    if (is_binary(csv.top_line) or is_nil(csv.top_line)) and is_list(csv.headers) and
         is_map(csv.rows) do
      csv_mod = opts[:csv_parser] || CSV

      csv_columns = ["#" <> hd(csv.headers) | tl(csv.headers)]

      fill_all_columns = !!opts[:fill_all_columns]
      header_columns_len = length(csv_columns)

      header_rows =
        if csv.top_line do
          [
            optionally_fill_all_columns(
              ["#" <> csv.top_line],
              fill_all_columns,
              header_columns_len
            ),
            csv_columns
          ]
        else
          [csv_columns]
        end

      maps_iterator = :maps.iterator(csv.rows)
      num_header = length(header_rows)

      1..(map_size(csv.rows) + num_header)//1
      |> Stream.transform({header_rows, maps_iterator}, fn
        _i, {[row | next_headers], objects} ->
          {[row], {next_headers, objects}}

        _i, {header_rows, objects} ->
          case :maps.next(objects) do
            {number, text, iterator} ->
              {[["#{number}", text]], {header_rows, iterator}}

            _else ->
              {:halt, nil}
          end
      end)
      |> csv_mod.dump_to_stream()
      |> then(&{:ok, &1})
    else
      {:error, :invalid_csv}
    end
  end

  @spec parse_csv_lines(Enumerable.t(), Keyword.t()) :: {:ok, t()} | {:error, term()}
  defp parse_csv_lines(rows, opts) do
    rows
    |> Enum.reduce_while({true, %__MODULE__{}}, fn {row, line}, {first_line, acc} ->
      # Trim the BOM if present
      row =
        case row do
          [@bom <> rest | tl] -> [rest | tl]
          _other -> row
        end

      case do_parse_csv_line(row, opts, acc, first_line) do
        {:ok, new_acc} ->
          {:cont, {false, new_acc}}

        {:error, err} ->
          {:halt, {:error, {err, line: line}}}
      end
    end)
    |> then(fn
      {:error, _err} = err -> err
      {_first, %__MODULE__{} = acc} -> {:ok, acc}
    end)
  end

  @spec do_parse_csv_line([binary()], Keyword.t(), t(), boolean()) ::
          {:ok, t()} | {:error, term()}
  defp do_parse_csv_line(cells, opts, acc, first_line)

  defp do_parse_csv_line(["#" <> row | tl], _opts, acc, true) when tl == [] or hd(tl) == "" do
    {:ok, %{acc | top_line: String.trim(row)}}
  end

  defp do_parse_csv_line(["#" <> first_column | columns], _opts, acc, _first_line) do
    {:ok, %{acc | headers: [String.trim(first_column) | columns]}}
  end

  defp do_parse_csv_line([reference, text | _tl], _opts, acc, _first_line) do
    case Integer.parse(reference) do
      {ref_num, _rest} when ref_num >= 0 ->
        {:ok, put_in(acc, [Access.key(:rows), ref_num], text)}

      _else ->
        {:error, :invalid_reference_number}
    end
  end

  @spec optionally_fill_all_columns([binary()], boolean(), non_neg_integer()) :: term()
  defp optionally_fill_all_columns(_columns, _fill_all, _columns_length)

  defp optionally_fill_all_columns(columns, false, _columns_length), do: columns

  defp optionally_fill_all_columns(columns, true, headers_length) do
    columns ++ List.duplicate("", headers_length - length(columns))
  end
end
