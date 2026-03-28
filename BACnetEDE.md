# `BACnetEDE`
[🔗](https://github.com/bacnet-ex/bacnet_ede/blob/master/lib/bacnet_ede.ex#L1)

BACnetEDE is a BACnet EDE File parser and writer. EDE stands for Engineering Data Exchange.

EDE is a data exchange format specified by the BACnet Interest Group Europe - B.I.G.-EU.
You can download the official specification on their [website](https://www.big-eu.org/resources/).

The EDE format is basically an Excel sheet (or CSV) to help exchange engineering data,
such as datapoint types and addresses information in a standardized form.
It was never intended for more than just human to human data exchange,
because it only carries minimum information.
However it has grown by convenience to use for machine-to-machine data exchange in CSV form.

The following naming conventions exist for EDE files (including additional files, such as state texts):
- Prefix: Name agreed by the involved parties (e.g. the project name)
- Separator: `_` Underscore
- Suffix:
  - `EDE` identifies the main EDE file/table
  - `ObjTypes` identifies the object type table
  - `StateTexts` identifies the state texts used in Binary and Multistate objects
  - `Units` identifies the table of BACnet engineering units
- Extension: `.csv`

Example of naming convention:
- Project Name: FlightRadar
- EDE file: `FlightRadar_EDE.csv`
- Object types file: `FlightRadar_ObjTypes.csv`
- State texts file: `FlightRadar_StateTexts.csv`
- Units file: `FlightRadar_Units.csv`

See the specification for more information on the specification itself.
See the documentation for more information about the library and its modules.

## Installation

The package can be installed by adding `bacnet_ede` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:bacnet_ede, "~> 0.1.0"}
  ]
end
```

The docs can be found at <https://hexdocs.pm/bacnet_ede>.

## Usage

This library can be used to read and write BACnet EDE files.

### Parse EDE

An EDE file can be simply parsed by using `BACnetEDE.from_file/2` (or any other of `from_*`):

```elixir
{:ok, ede} = BACnetEDE.from_file("path/to/file.csv")
```

For example reading the official EDE sample will look like this:

```elixir
iex(4)> BACnetEDE.from_file("./samples/EDE_2_2_example_EDE.csv")
{:ok,
 %BACnetEDE.Project{
   project_name: "EDEexample",
   version: "1",
   timestamp_last_change: ~N[2005-12-19 00:00:00],
   author_last_change: "G. Sampler",
   layout_version: "2.2",
   objects: %{
     "Building03Room15" => %BACnetEDE.Project.Object{
       keyname: "Building03Room15",
       device_instance: 10,
       object_name: "ASB03R15",
       object_type: 8,
       object_instance: 10,
       description: "Controller10",
       default_present_value: nil,
       min_present_value: nil,
       max_present_value: nil,
       settable: false,
       supports_cov: false,
       high_limit: nil,
       low_limit: nil,
       state_text_ref: nil,
       unit_code: nil,
       vendor_specific_address: "A1.19.02",
       notification_class: nil,
       more_keys: %{}
     },
     "Building03Room15Damper" => %BACnetEDE.Project.Object{
       keyname: "Building03Room15Damper",
       device_instance: 10,
       object_name: "Damper",
       object_type: 2,
       object_instance: 1111,
       description: "Raw Value Damper",
       default_present_value: "555",
       min_present_value: 0.0,
       max_present_value: 1000.0,
       settable: false,
       supports_cov: true,
       high_limit: nil,
       low_limit: nil,
       state_text_ref: nil,
       unit_code: 95,
       vendor_specific_address: "DR12.111.2345",
       notification_class: nil,
       more_keys: %{}
     },
     "Building03Room15DamperPosition" => %BACnetEDE.Project.Object{
       keyname: "Building03Room15DamperPosition",
       device_instance: 10,
       object_name: "Damper",
       object_type: 1,
       object_instance: 1234,
       description: "Damper in Duct 2",
       default_present_value: "55",
       min_present_value: 0.0,
       max_present_value: 100.0,
       settable: true,
       supports_cov: true,
       high_limit: nil,
       low_limit: nil,
       state_text_ref: nil,
       unit_code: 98,
       vendor_specific_address: "D12.111.2345",
       notification_class: nil,
       more_keys: %{}
     },
     "Building03Room15Temperature" => %BACnetEDE.Project.Object{
       keyname: "Building03Room15Temperature",
       device_instance: 10,
       object_name: "RoomTemperature",
       object_type: 0,
       object_instance: 4123,
       description: "This is a Room Temperature",
       default_present_value: "20",
       min_present_value: nil,
       max_present_value: nil,
       settable: false,
       supports_cov: false,
       high_limit: 24.0,
       low_limit: 18.0,
       state_text_ref: nil,
       unit_code: 62,
       vendor_specific_address: "T1.128.15",
       notification_class: nil,
       more_keys: %{}
     },
     # ...
   }
 }}
 ```

### Write EDE

An EDE file can be created by calling the  `BACnetEDE.to_*` functions with the `BACnetEDE.Project` struct.
You have to create such a struct yourself in a valid form, however that shouldn't be too hard.
Check the EDE sample example above.

Once you have such a struct, call `BACnetEDE.to_file/3` (or any other of `to_*`) to create the CSV file:

```elixir
BACnetEDE.to_file(project_struct, "path/to/file.csv")
```

# `dump_option`

```elixir
@type dump_option() ::
  {:csv_encoder, module()}
  | {:date_format, :named | :german | :german_with_time | :iso8601}
  | {:dump_all_keys, boolean()}
  | {:fill_all_columns, boolean()}
  | {:unlock_layout_version, boolean()}
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
  You may have the need for a different separator (i.e. comma) for your EDE file.
- `date_format: :named | :german | :german_with_time | :iso8601` - Optional.
  The date format to use (defaults to `:named`).
  Formats: `named: 04 Jan 2025`, `german: 04.01.2025`, `german_with_time: 04.01.2025 10:05:30`.
- `dump_all_keys: boolean()` - Optional. Dumps all, including `:more_keys`, of objects.
  If false, it will only dump the keys of the `BACnetEDE.Project.Object` struct
  without any additional data (`:more_keys`).
  Dumping all keys will substantially use more computing resources as the data has to be enumerated twice.
  First to get all available keys and build the header and then once more to dump the values.
- `fill_all_columns: boolean()` - Optional. Ensures all rows have the same amount of columns.
  By default, only the necessary amount of columns per row is used for the EDE header part.
- `unlock_layout_version: boolean()` - Optional. Uses the layout version of the project
  instead of defaulting to the latest.

# `naming_convention`

```elixir
@type naming_convention() ::
  {:EDE, :&quot;_EDE.csv&quot;}
  | {:object_types, :&quot;_ObjTypes.csv&quot;}
  | {:state_texts, :&quot;_StateTexts.csv&quot;}
  | {:units, :&quot;_Units.csv&quot;}
```

Naming conventions for the EDE files.

The following naming conventions exist for EDE files (including additional files, such as state texts):
- Prefix: Name agreed by the involved parties (e.g. the project name)
- Separator: `_` Underscore
- Suffix:
  - `EDE` identifies the main EDE file/table
  - `ObjTypes` identifies the object type table
  - `StateTexts` identifies the state texts used in Binary and Multistate objects
  - `Units` identifies the table of BACnet engineering units
- Extension: `.csv`

# `parse_option`

```elixir
@type parse_option() ::
  {:csv_parser, module()}
  | {:disable_with_error, boolean()}
  | {:fixed_mandatory_columns, boolean()}
  | {:skip_type_errors, boolean()}
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
  You may have the need for a different separator (i.e. comma) for your EDE file.
- `disable_with_error: boolean()` - Optional. After parsing the whole EDE file, the data will be validated.
  By default, if a validation error is found, an error `{:error, string, Project.t()}` will be returned.
  If this is set to `true`, a validation error will turn into a simple error tuple.
  The extended error tuple allows for comparing what is found and may ignore the validation error,
  if the data is still sufficiently valid for the user.
- `fixed_mandatory_columns: boolean()` - Optional. Uses fixed columns for the mandatory columns (no parsing).
  All following (optional) columns will be parsed.
  Mandatory columns: `keyname;device obj.-instance;object-name;object-type;object-instance`
- `skip_type_errors: boolean()` - Optional. Skip type errors (values will stay as `nil`).
  By default, when an invalid value is specified (i.e. string for integer), an error will be returned.
  This option will simply ignore the value and column (value will stay as `nil`).
  Please note, that validation MAY fail when a mandatory field is not set.

# `from_binary`

```elixir
@spec from_binary(binary(), parse_options()) ::
  {:ok, BACnetEDE.Project.t()}
  | {:with_error, String.t(), BACnetEDE.Project.t()}
  | {:error, term()}
```

Parses the given binary as an EDE CSV file.

The parser will recognize EDE layout version 2.2 and 2.3 without error,
however other versions will be parsed on "best effort" basis and return a "with error" (see option `disable_with_error`),
which you should handle, if you intend to parse earlier versions (don't even think about disabling "with error" in such a case).

See `t:parse_options/0` for a description of the available options.

# `from_file`

```elixir
@spec from_file(Path.t(), parse_options()) ::
  {:ok, BACnetEDE.Project.t()}
  | {:with_error, String.t(), BACnetEDE.Project.t()}
  | {:error, term()}
```

Parses an EDE file from a CSV file path.
This function uses line streaming for the parsing process.

The parser will recognize EDE layout version 2.2 and 2.3 without error,
however other versions will be parsed on "best effort" basis and return a "with error" (see option `disable_with_error`),
which you should handle, if you intend to parse earlier versions (don't even think about disabling "with error" in such a case).

See `t:parse_options/0` for a description of the available options.

# `from_stream`

```elixir
@spec from_stream(Enumerable.t(), parse_options()) ::
  {:ok, BACnetEDE.Project.t()}
  | {:with_error, String.t(), BACnetEDE.Project.t()}
  | {:error, term()}
```

Parses an EDE file from a CSV stream (i.e. a file stream).

Make sure the stream is line-orientated or use NimbleCSV's `to_line_stream/1` if you can't.
See `BACnetEDE.CSV.to_line_stream/1` for the default parser's function.

The parser will recognize EDE layout version 2.2 and 2.3 without error,
however other versions will be parsed on "best effort" basis and return a "with error" (see option `disable_with_error`),
which you should handle, if you intend to parse earlier versions (don't even think about disabling "with error" in such a case).

See `t:parse_options/0` for a description of the available options.

# `to_binary`

```elixir
@spec to_binary(BACnetEDE.Project.t(), dump_options()) ::
  {:ok, binary()} | {:error, term()}
```

Dumps the given Project (EDE data) into a CSV encoded binary.

Layout version should always be 2.3 (the current latest one).

By default, only the EDE specified information will be made available into the EDE.
If you want to also include data from the `more_keys` map of the objects,
see the available options.

See `t:dump_options/0` for a description of the available options.

# `to_file`

```elixir
@spec to_file(BACnetEDE.Project.t(), Path.t(), dump_options()) ::
  :ok | {:error, term()}
```

Dumps the given Project (EDE data) into a CSV file.

Layout version should always be 2.3 (the current latest one).

By default, only the EDE specified information will be made available into the EDE.
If you want to also include data from the `more_keys` map of the objects,
see the available options.

See `t:dump_options/0` for a description of the available options.

# `to_stream`

```elixir
@spec to_stream(BACnetEDE.Project.t(), dump_options()) ::
  {:ok, Enumerable.t()} | {:error, term()}
```

Dumps the given Project (EDE data) into a CSV encoded stream.

Layout version should always be 2.3 (the current latest one).

By default, only the EDE specified information will be made available into the EDE.
If you want to also include data from the `more_keys` map of the objects,
see the available options.

See `t:dump_options/0` for a description of the available options.

---

*Consult [api-reference.md](api-reference.md) for complete listing*
