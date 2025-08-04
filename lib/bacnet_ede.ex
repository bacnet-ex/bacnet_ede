defmodule BACnetEDE do
  @moduledoc "README.md"
             |> File.read!()
             |> String.split("\n")
             |> tl()
             |> Enum.join("\n")
             |> String.trim()

  @external_resource "README.md"

  alias BACnetEDE.CSV
  alias BACnetEDE.Project

  @column_mapping %{
    "#keyname" => :keyname,
    "# keyname" => :keyname,
    "device-obj-instance" => :device_instance,
    "device-object-instance" => :device_instance,
    "device obj.-instance" => :device_instance,
    "object-name" => :object_name,
    "object-type" => :object_type,
    "object-instance" => :object_instance,
    "description" => :description,
    "present-value-default" => :default_present_value,
    "min-present-value" => :min_present_value,
    "max-present-value" => :max_present_value,
    "settable" => :settable,
    "supports COV" => :supports_cov,
    "hi-limit" => :high_limit,
    "low-limit" => :low_limit,
    "state-text-reference" => :state_text_ref,
    "unit-code" => :unit_code,
    "vendor-specific-address" => :vendor_specific_address,
    "notification-class" => :notification_class
  }

  # If not mentioned here, it's a string
  @column_type_mapping %{
    device_instance: :integer,
    object_type: :integer,
    object_instance: :integer,
    default_present_value: :string,
    min_present_value: :float,
    max_present_value: :float,
    settable: :boolean,
    supports_cov: :boolean,
    high_limit: :float,
    low_limit: :float,
    state_text_ref: :integer,
    unit_code: :integer,
    notification_class: :integer
  }

  @bom :unicode.encoding_to_bom(:utf8)

  @doc """
  Parses the given binary as an EDE CSV file.

  The parser will recognize EDE layout version 2.2 and 2.3 without error,
  however other versions will be parsed on "best effort" basis and return a "with error" (see option `disable_with_error`),
  which you should handle, if you intend to parse earlier versions (don't even think about disabling "with error" in such a case).

  The following options are available:
  - `csv_parser: module()` - Optional. A module implementing the Nimble CSV behaviour.
    The default CSV parser uses semicolons and CRLF newlines as separator.
    You may have the need for a different separator (i.e. comma) for your EDE file.
  - `disable_with_error: boolean()` - Optional. After parsing the whole EDE file, the data will be validated.
    By default, if a validation error is found, an error `{:error, string, Project.t()}` will be returned.
    If this is set to `true`, a validation error will turn into a simple error tuple.
    The extended error tuple allows for comparing what is found and may ignore the validation error,
    if the data is still sufficiently valid for the user.
  - `fail_on_unknown_column: boolean()` - Optional. Return an error when an unknown column is encountered.
    By default, the column will be added to the `:more_keys` map of the object.
  - `fixed_mandatory_columns: boolean()` - Optional. Uses fixed columns for the mandatory columns (no parsing).
    All following (optional) columns will be parsed.
    Mandatory columns: `keyname;device obj.-instance;object-name;object-type;object-instance`
  - `skip_type_errors: boolean()` - Optional. Skip type errors (values will stay as `nil`).
    By default, when an invalid value is specified (i.e. string for integer), an error will be returned.
    This option will simply ignore the value and column (value will stay as `nil`).
    Please note, that validation MAY fail when a mandatory field is not set.
  """
  @spec from_binary(binary(), Keyword.t()) ::
          {:ok, Project.t()} | {:with_error, String.t(), Project.t()} | {:error, term()}
  def from_binary(binary, opts \\ []) when is_binary(binary) and is_list(opts) do
    if not Keyword.keyword?(opts) do
      raise ArgumentError, "from_binary/2 expected a keyword list, got: #{inspect(opts)}"
    end

    csv_mod = opts[:csv_parser] || CSV

    binary
    |> csv_mod.parse_string(skip_headers: false)
    |> Enum.with_index(1)
    |> parse_csv_lines(opts)
    |> do_finish_parsing(opts)
  end

  @doc """
  Parses an EDE file from a CSV file path.
  This function uses line streaming for the parsing process.

  The parser will recognize EDE layout version 2.2 and 2.3 without error,
  however other versions will be parsed on "best effort" basis and return a "with error" (see option `disable_with_error`),
  which you should handle, if you intend to parse earlier versions (don't even think about disabling "with error" in such a case).

  See `from_binary/2` for the available options.
  """
  @spec from_file(Path.t(), Keyword.t()) ::
          {:ok, Project.t()} | {:with_error, String.t(), Project.t()} | {:error, term()}
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
  Parses an EDE file from a CSV stream (i.e. a file stream).
  Make sure the stream is line-orientated or use `NimbleCSV.to_line_stream/1` if you can't.

  The parser will recognize EDE layout version 2.2 and 2.3 without error,
  however other versions will be parsed on "best effort" basis and return a "with error" (see option `disable_with_error`),
  which you should handle, if you intend to parse earlier versions (don't even think about disabling "with error" in such a case).

  See `from_binary/2` for the available options.
  """
  @spec from_stream(Enumerable.t(), Keyword.t()) ::
          {:ok, Project.t()} | {:with_error, String.t(), Project.t()} | {:error, term()}
  def from_stream(stream, opts \\ []) when is_list(opts) do
    if not Keyword.keyword?(opts) do
      raise ArgumentError, "from_stream/2 expected a keyword list, got: #{inspect(opts)}"
    end

    csv_mod = opts[:csv_parser] || CSV

    stream
    |> csv_mod.parse_stream(skip_headers: false)
    |> Stream.with_index(1)
    |> parse_csv_lines(opts)
    |> do_finish_parsing(opts)
  end

  @doc """
  Dumps the given Project (EDE data) into a CSV encoded binary.

  By default, only the EDE specified information will be made available into the EDE.
  If you want to also include data from the `more_keys` map of the objects,
  see the available options.

  The following options are available:
  - `csv_encoder: module()` - Optional. A module implementing the Nimble CSV behaviour.
    The default CSV encoder uses semicolons and CRLF newlines as separator.
    You may have the need for a different separator (i.e. comma) for your EDE file.
  - `date_format: :named | :german | :german_with_time` - Optional. The date format to use (defaults to `:named`).
    Formats: `named: 04 Jan 2025`, `german: 04.01.2025`, `german_with_time: 04.01.2025 10:05:30`.
  - `dump_all_keys: boolean()` - Optional. Dumps all, including `:more_keys`, of objects.
    If false, it will only dump the keys of the `Object` struct without any additional data (`:more_keys`).
    Dumping all keys will substantially use more computing resources as the data has to be enumerated twice.
    First to get all available keys and build the header and then once more to dump the values.
  - `fill_all_columns: boolean()` - Optional. Ensures all rows have the same amount of columns.
    By default, only the necessary amount of columns per row is used for the EDE header part.
  """
  @spec to_binary(Project.t(), Keyword.t()) :: {:ok, binary()} | {:error, term()}
  def to_binary(%Project{} = project, opts \\ []) when is_list(opts) do
    if not Keyword.keyword?(opts) do
      raise ArgumentError, "to_binary/2 expected a keyword list, got: #{inspect(opts)}"
    end

    project
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
  Dumps the given Project (EDE data) into a CSV file.

  By default, only the EDE specified information will be made available into the EDE.
  If you want to also include data from the `more_keys` map of the objects,
  see the available options.

  See `to_binary/2` for the available options.
  """
  @spec to_file(Project.t(), Path.t(), Keyword.t()) :: :ok | {:error, term()}
  def to_file(%Project{} = project, path, opts \\ []) when is_binary(path) and is_list(opts) do
    if not Keyword.keyword?(opts) do
      raise ArgumentError, "to_stream/2 expected a keyword list, got: #{inspect(opts)}"
    end

    # Check if file exists, if not, create it
    case File.stat(path) do
      {:ok, _stat} -> :ok
      _else -> File.touch!(path)
    end

    file_stream = File.stream!(path, :line)

    project
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
  Dumps the given Project (EDE data) into a CSV encoded stream.

  By default, only the EDE specified information will be made available into the EDE.
  If you want to also include data from the `more_keys` map of the objects,
  see the available options.

  See `to_binary/2` for the available options.
  """
  @spec to_stream(Project.t(), Keyword.t()) :: {:ok, Enumerable.t()} | {:error, term()}
  def to_stream(%Project{} = project, opts \\ []) when is_list(opts) do
    if not Keyword.keyword?(opts) do
      raise ArgumentError, "to_stream/2 expected a keyword list, got: #{inspect(opts)}"
    end

    if Project.valid?(project) do
      csv_mod = opts[:csv_parser] || CSV

      csv_inclusion = [
        "#mandatory",
        "mandatory",
        "mandatory",
        "mandatory",
        "mandatory",
        "optional",
        "optional",
        "optional",
        "optional",
        "optional",
        "optional",
        "optional",
        "optional",
        "optional",
        "optional",
        "optional"
      ]

      csv_columns = [
        "# keyname",
        "device obj.-instance",
        "object-name",
        "object-type",
        "object-instance",
        "description",
        "present-value-default",
        "min-present-value",
        "max-present-value",
        "settable",
        "supports COV",
        "hi-limit",
        "low-limit",
        "state-text-reference",
        "unit-code",
        "vendor-specific-address"
      ]

      {csv_inclusion, csv_columns} =
        dump_csv_header_columns(project, opts, csv_inclusion, csv_columns)

      fill_all_columns = !!opts[:fill_all_columns]
      header_columns_len = if fill_all_columns, do: length(csv_columns), else: 0

      header_rows = [
        optionally_fill_all_columns(
          ["# Engineering-Data-Exchange - B.I.G.-EU"],
          fill_all_columns,
          header_columns_len
        ),
        optionally_fill_all_columns(
          ["PROJECT_NAME", project.project_name],
          fill_all_columns,
          header_columns_len
        ),
        optionally_fill_all_columns(
          ["VERSION_OF_REFERENCEFILE", project.version],
          fill_all_columns,
          header_columns_len
        ),
        optionally_fill_all_columns(
          [
            "TIMESTAMP_OF_LAST_CHANGE",
            format_date(project.timestamp_last_change, opts[:date_format] || :named)
          ],
          fill_all_columns,
          header_columns_len
        ),
        optionally_fill_all_columns(
          ["AUTHOR_OF_LAST_CHANGE", project.author_last_change],
          fill_all_columns,
          header_columns_len
        ),
        optionally_fill_all_columns(
          ["VERSION_OF_LAYOUT", project.layout_version],
          fill_all_columns,
          header_columns_len
        ),
        csv_inclusion,
        csv_columns
      ]

      maps_iterator = :maps.iterator(project.objects)
      num_header = length(header_rows)

      1..(map_size(project.objects) + num_header)//1
      |> Stream.transform({header_rows, maps_iterator}, fn
        _i, {[row | next_headers], objects} ->
          {[row], {next_headers, objects}}

        _i, {header_rows, objects} ->
          case :maps.next(objects) do
            {_key, %Project.Object{} = object, iterator} ->
              row = create_csv_rows_from_object(object, csv_columns, opts)
              {[row], {header_rows, iterator}}

            _else ->
              {:halt, nil}
          end
      end)
      |> csv_mod.dump_to_stream()
      |> then(&{:ok, &1})
    else
      {:error, :invalid_project}
    end
  end

  @spec parse_csv_lines(Enumerable.t(), Keyword.t()) :: {:ok, Project.t()} | {:error, term()}
  defp parse_csv_lines(rows, opts) do
    fixed_columns = !!opts[:fixed_mandatory_columns]

    rows
    |> Enum.reduce_while({nil, Project.new()}, fn {row, line}, {headers, acc} ->
      # Trim the BOM if present
      row =
        case row do
          [@bom <> rest | tl] -> [rest | tl]
          _other -> row
        end

      case do_parse_csv_line(row, opts, headers, acc, fixed_columns) do
        {:ok, new_acc} ->
          {:cont, {headers, new_acc}}

        {:headers, new_acc} ->
          {:cont, {new_acc, acc}}

        {:error, {err, info}} when is_list(info) ->
          {:halt, {:error, {err, Keyword.put(info, :line, line)}}}

        {:error, err} ->
          {:halt, {:error, {err, line: line}}}
      end
    end)
    |> then(fn
      {:error, _err} = err -> err
      {_headers, %Project{} = acc} -> {:ok, acc}
    end)
  end

  @spec do_parse_csv_line([binary()], Keyword.t(), [binary()] | nil, Project.t(), boolean()) ::
          {:ok, Project.t()} | {:headers, [binary()]} | {:error, term()}

  defp do_parse_csv_line(["PROJECT_NAME", name | _tl], _opts, _headers, acc, _fixed_columns) do
    {:ok, %{acc | project_name: name}}
  end

  defp do_parse_csv_line(["# PROJECT_NAME", name | _tl], _opts, _headers, acc, _fixed_columns) do
    {:ok, %{acc | project_name: name}}
  end

  defp do_parse_csv_line(
         ["VERSION_OF_REFERENCEFILE", version | _tl],
         _opts,
         _headers,
         acc,
         _fixed_columns
       ) do
    {:ok, %{acc | version: version}}
  end

  defp do_parse_csv_line(
         ["# VERSION_OF_REFERENCEFILE", version | _tl],
         _opts,
         _headers,
         acc,
         _fixed_columns
       ) do
    {:ok, %{acc | version: version}}
  end

  defp do_parse_csv_line(
         ["TIMESTAMP_OF_LAST_CHANGE", timestamp | _tl],
         _opts,
         _headers,
         acc,
         _fixed_columns
       ) do
    with {:ok, dt} <- parse_date(timestamp) do
      {:ok, %{acc | timestamp_last_change: dt}}
    end
  end

  defp do_parse_csv_line(
         ["# TIMESTAMP_OF_LAST_CHANGE", timestamp | _tl],
         _opts,
         _headers,
         acc,
         _fixed_columns
       ) do
    with {:ok, dt} <- parse_date(timestamp) do
      {:ok, %{acc | timestamp_last_change: dt}}
    end
  end

  defp do_parse_csv_line(
         ["AUTHOR_OF_LAST_CHANGE", author | _tl],
         _opts,
         _headers,
         acc,
         _fixed_columns
       ) do
    {:ok, %{acc | author_last_change: author}}
  end

  defp do_parse_csv_line(
         ["# AUTHOR_OF_LAST_CHANGE", author | _tl],
         _opts,
         _headers,
         acc,
         _fixed_columns
       ) do
    {:ok, %{acc | author_last_change: author}}
  end

  defp do_parse_csv_line(
         ["VERSION_OF_LAYOUT", version | _tl],
         _opts,
         _headers,
         acc,
         _fixed_columns
       ) do
    {:ok, %{acc | layout_version: version}}
  end

  defp do_parse_csv_line(
         ["# VERSION_OF_LAYOUT", version | _tl],
         _opts,
         _headers,
         acc,
         _fixed_columns
       ) do
    {:ok, %{acc | layout_version: version}}
  end

  defp do_parse_csv_line([header | columns], _opts, _headers, _acc, _fixed_columns)
       when header in ["keyname", "#keyname", "# keyname"] do
    {:headers, columns}
  end

  defp do_parse_csv_line(["#" <> _row | _tl], _opts, _headers, acc, _fixed_columns) do
    # Comment, ignore
    {:ok, acc}
  end

  defp do_parse_csv_line(row, opts, headers, acc, true) when not is_nil(headers) do
    new_headers =
      headers
      |> Enum.drop(5)
      |> then(
        &[
          "device obj.-instance",
          "object-name",
          "object-type",
          "object-instance" | &1
        ]
      )

    do_parse_csv_line(row, opts, new_headers, acc, false)
  end

  defp do_parse_csv_line([keyname | row], opts, headers, acc, _fixed_columns) do
    obj = Project.Object.new(keyname: keyname)

    headers
    |> Enum.zip(row)
    |> Enum.reduce_while({:ok, obj}, fn
      {"", _value}, acc ->
        {:cont, acc}

      {_column, ""}, acc ->
        {:cont, acc}

      {column, value}, {:ok, obj} ->
        case Map.fetch(@column_mapping, column) do
          {:ok, key} ->
            type = Map.get(@column_type_mapping, key, :string)

            case parse_column_value(type, value) do
              {:ok, value} ->
                {:cont, {:ok, %{obj | key => value}}}

              {:error, err} ->
                if opts[:skip_type_errors] do
                  {:cont, {:ok, obj}}
                else
                  {:halt, {:error, {err, column: column}}}
                end
            end

          :error ->
            if opts[:fail_on_unknown_column] do
              {:halt, {:unknown_column, column}}
            else
              {:cont, {:ok, put_in(obj, [Access.key(:more_keys), column], value)}}
            end
        end
    end)
    |> then(fn
      {:ok, value} -> {:ok, put_in(acc, [Access.key(:objects), keyname], value)}
      other -> other
    end)
  end

  @spec do_finish_parsing({:ok, Project.t()} | {:error, term()}, Keyword.t()) ::
          {:ok, Project.t()} | {:error, term()}
  defp do_finish_parsing(return_value, opts)

  defp do_finish_parsing({:ok, project}, opts) do
    cond do
      Project.valid?(project) ->
        case project.layout_version do
          version when version in ["2.2", "2.3"] ->
            {:ok, project}

          _other ->
            if opts[:disable_with_error] do
              {:ok, project}
            else
              {:error,
               "EDE layout version is neither 2.2 nor 2.3 - parsing may be wrong and/or invalid",
               project}
            end
        end

      opts[:disable_with_error] ->
        {:error,
         "Invalid EDE File failed at type validation - " <>
           "some of the mandatory project information may be missing or " <>
           "invalid types for fields may slipped through"}

      true ->
        {:error,
         "Invalid EDE File failed at type validation - " <>
           "some of the mandatory project information may be missing or " <>
           "invalid types for fields may slipped through", project}
    end
  end

  defp do_finish_parsing({:error, _err} = err, _opts) do
    err
  end

  @spec parse_column_value(atom(), String.t()) :: {:ok, term()} | {:error, term()}
  defp parse_column_value(type, value)

  defp parse_column_value(_type, ""), do: {:ok, nil}
  defp parse_column_value(:boolean, "Y"), do: {:ok, true}
  defp parse_column_value(:boolean, "y"), do: {:ok, true}
  defp parse_column_value(:boolean, _else), do: {:ok, false}
  defp parse_column_value(:string, value), do: {:ok, value}

  # Siemens uses string for units (violation of specification)
  defp parse_column_value(:integer, value) do
    case Integer.parse(value, 10) do
      {integer, _rest} -> {:ok, integer}
      :error -> {:error, :invalid_integer_value}
    end
  end

  defp parse_column_value(:float, value) do
    case Float.parse(value) do
      {float, _rest} -> {:ok, float}
      :error -> {:error, :invalid_float_value}
    end
  end

  @spec parse_date(String.t()) :: {:ok, NaiveDateTime.t()} | {:error, term()}
  defp parse_date(date) when is_binary(date) do
    with {:error, _value} <- parse_date_v1(date),
         {:error, _value} <- parse_date_v2(date),
         do: {:error, {:unknown_timestamp_value, date}}
  end

  @spec parse_date_v1(String.t()) :: {:ok, NaiveDateTime.t()} | {:error, term()}
  defp parse_date_v1(date) when is_binary(date) do
    # Parse 19. Dez 05 or 19 Dez 05 (or full year)
    case Regex.run(~r"(\d{1,2})\.? ([A-Za-z]+) (\d{2,4})", date) do
      nil ->
        {:error, nil}

      [_whole, day, word_month, year] ->
        year = String.to_integer(year)
        year = if(year < 1900, do: year + 2000, else: year)

        month =
          case String.downcase(word_month) do
            "jan" -> 1
            "feb" -> 2
            "mar" -> 3
            "apr" -> 4
            "may" -> 5
            "mai" -> 5
            "jun" -> 6
            "jul" -> 7
            "aug" -> 8
            "sep" -> 9
            "oct" -> 10
            "okt" -> 10
            "nov" -> 11
            "dec" -> 12
            "dez" -> 12
            _else -> 0
          end

        NaiveDateTime.from_erl({{year, month, String.to_integer(day)}, {0, 0, 0}})
    end
  end

  @spec parse_date_v2(String.t()) :: {:ok, NaiveDateTime.t()} | {:error, term()}
  defp parse_date_v2(date) when is_binary(date) do
    # Parse 19.08.2025 or 19.08.25 (dd.mm.yyyy / .yy)
    case Regex.run(~r"(\d+)\.?(\d+)\.(\d+)(?:\s*(\d+)\:(\d+)\:(\d+))?", date) do
      nil ->
        {:error, nil}

      [_whole, day, month, year] ->
        year = String.to_integer(year)
        year = if(year < 1900, do: year + 2000, else: year)

        NaiveDateTime.from_erl(
          {{year, String.to_integer(month), String.to_integer(day)}, {0, 0, 0}}
        )

      [_whole, day, month, year, hour, minute, seconds] ->
        year = String.to_integer(year)
        year = if(year < 1900, do: year + 2000, else: year)

        NaiveDateTime.from_erl(
          {{year, String.to_integer(month), String.to_integer(day)},
           {String.to_integer(hour), String.to_integer(minute), String.to_integer(seconds)}}
        )
    end
  end

  @spec dump_csv_header_columns(Project.t(), Keyword.t(), list(), list()) ::
          {csv_inclusion :: list(), csv_columns :: list()}
  defp dump_csv_header_columns(project, opts, csv_inclusion, csv_columns) do
    if opts[:dump_all_keys] do
      additional_keys =
        Enum.reduce(project.objects, MapSet.new(), fn
          {_key, %{more_keys: more_keys}}, acc ->
            Enum.reduce(more_keys, acc, fn
              {key, val}, acc when is_binary(val) and byte_size(val) > 0 -> MapSet.put(acc, key)
              _val, acc -> acc
            end)
        end)

      {csv_inclusion, csv_columns} =
        Enum.reduce(
          additional_keys,
          {Enum.reverse(csv_inclusion), Enum.reverse(csv_columns)},
          fn column, {csv_inclusion, csv_columns} ->
            {["optional" | csv_inclusion], ["#{column}" | csv_columns]}
          end
        )

      {Enum.reverse(csv_inclusion), Enum.reverse(csv_columns)}
    else
      {csv_inclusion, csv_columns}
    end
  end

  @spec create_csv_rows_from_object(Project.Object.t(), [binary()], Keyword.t()) :: [binary()]
  defp create_csv_rows_from_object(%Project.Object{} = object, columns, _opts) do
    Enum.map(columns, fn column ->
      key =
        case Map.get(@column_mapping, column) do
          nil -> [Access.key(:more_keys), Access.key(column)]
          key -> [Access.key(key)]
        end

      case get_in(object, key) do
        nil ->
          ""

        value ->
          cond do
            is_boolean(value) -> if value, do: "Y", else: "N"
            is_float(value) -> :erlang.float_to_binary(value, [:compact, decimals: 15])
            true -> "#{value}"
          end
      end
    end)
  end

  @spec format_date(NaiveDateTime.t(), :named | :german | :german_with_time | atom()) ::
          String.t()
  defp format_date(%NaiveDateTime{} = value, date_format) do
    case date_format do
      :named ->
        word_month =
          case value.month do
            1 -> "Jan"
            2 -> "Feb"
            3 -> "Mar"
            4 -> "Apr"
            5 -> "May"
            6 -> "Jun"
            7 -> "Jul"
            8 -> "Aug"
            9 -> "Sep"
            10 -> "Oct"
            11 -> "Nov"
            12 -> "Dec"
          end

        "#{value.day}. #{word_month} #{value.year}"

      :german ->
        String.pad_leading("#{value.day}", 2, "0") <>
          "." <>
          String.pad_leading("#{value.month}", 2, "0") <>
          "." <>
          "#{value.year}"

      :german_with_time ->
        String.pad_leading("#{value.day}", 2, "0") <>
          "." <>
          String.pad_leading("#{value.month}", 2, "0") <>
          "." <>
          "#{value.year} " <>
          String.pad_leading("#{value.hour}", 2, "0") <>
          ":" <>
          String.pad_leading("#{value.minute}", 2, "0") <>
          "." <>
          String.pad_leading("#{value.second}", 2, "0")

      _else ->
        raise "Invalid date format specified, got: " <> inspect(date_format)
    end
  end

  @spec optionally_fill_all_columns([binary()], boolean(), non_neg_integer()) :: term()
  defp optionally_fill_all_columns(columns, false, _columns_length), do: columns
  defp optionally_fill_all_columns(columns, _fill_all_columns, 0), do: columns

  defp optionally_fill_all_columns(columns, true, headers_length) do
    count_columns = length(columns)

    if count_columns < headers_length do
      columns ++ List.duplicate("", headers_length - count_columns)
    else
      columns
    end
  end
end
