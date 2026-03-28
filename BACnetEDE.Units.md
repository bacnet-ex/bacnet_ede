# `BACnetEDE.Units`
[🔗](https://github.com/bacnet-ex/bacnet_ede/blob/master/lib/bacnet_ede/units.ex#L1)

The Units contain a number of rows or data, identified by its reference number,
listing an enumeration of BACnet engineering units. BACnet engineering units
are defined by the ASHRAE 135 BACnet protocol standard.

The library `bacstack` contains BACnet protocol enumerations,
so if you already use a BACnet library, you do not need to parse units files,
because the units are standardized in the BACnet protocol.
Only proprietary units are not standardized (which no one should ever use).

# `dump_option`

```elixir
@type dump_option() :: {:csv_encoder, module()} | {:fill_all_columns, boolean()}
```

Available options for `to_binary/2`, `to_file/3` and `to_stream/2`.

See `t:dump_options/0` for a description of the available options.

# `dump_options`

```elixir
@type dump_options() :: [dump_option()]
```

Available options for `to_binary/2`, `to_file/3` and `to_stream/2`.

Available options:
- `csv_encoder: module()` - Optional. A module implementing the Nimble CSV behaviour.
  The default CSV encoder uses semicolons and CRLF newlines as separator.
  You may have the need for a different separator (i.e. comma) for your file.
- `fill_all_columns: boolean()` - Optional. Ensures all rows have the same amount of columns.
  By default, only the necessary amount of columns per row is used for the header part.

# `parse_option`

```elixir
@type parse_option() :: {:csv_parser, module()}
```

Available options for `from_binary/2`, `from_file/2` and `from_stream/2`.

See `t:parse_options/0` for a description of the available options.

# `parse_options`

```elixir
@type parse_options() :: [parse_option()]
```

Available options for `from_binary/2`, `from_file/2` and `from_stream/2`.

Available options:
- `csv_parser: module()` - Optional. A module implementing the Nimble CSV behaviour.
  The default CSV parser uses semicolons and CRLF newlines as separator.
  You may have the need for a different separator (i.e. comma) for your file.

# `t`

```elixir
@type t() :: %BACnetEDE.Units{units: %{optional(non_neg_integer()) =&gt; String.t()}}
```

Units are keyed by the BACnet protocol enumeration number
to the text as specified in the EDE data.

# `from_binary`

```elixir
@spec from_binary(binary(), parse_options()) :: {:ok, t()} | {:error, term()}
```

Parses the given binary as an Units EDE file.

See `t:parse_options/0` for a description of the available options.

# `from_file`

```elixir
@spec from_file(Path.t(), parse_options()) :: {:ok, t()} | {:error, term()}
```

Parses an Units EDE file from a CSV file path.
This function uses line streaming for the parsing process.

See `t:parse_options/0` for a description of the available options.

# `from_stream`

```elixir
@spec from_stream(Enumerable.t(), parse_options()) :: {:ok, t()} | {:error, term()}
```

Parses an Units EDE file from a CSV stream (i.e. a file stream).

Make sure the stream is line-orientated or use NimbleCSV's `to_line_stream/1` if you can't.
See `BACnetEDE.CSV.to_line_stream/1` for the default parser's function.

See `t:parse_options/0` for a description of the available options.

# `to_binary`

```elixir
@spec to_binary(t(), dump_options()) :: {:ok, binary()} | {:error, term()}
```

Dumps the given Units EDE data into a CSV encoded binary.

See `t:dump_options/0` for a description of the available options.

# `to_file`

```elixir
@spec to_file(t(), Path.t(), dump_options()) ::
  {:ok, Enumerable.t()} | {:error, term()}
```

Dumps the given Units EDE data into a CSV encoded file.

See `t:dump_options/0` for a description of the available options.

# `to_stream`

```elixir
@spec to_stream(t(), dump_options()) :: {:ok, Enumerable.t()} | {:error, term()}
```

Dumps the given Units EDE data into a CSV encoded stream.

See `t:dump_options/0` for a description of the available options.

---

*Consult [api-reference.md](api-reference.md) for complete listing*
