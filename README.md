# BACnetEDE [![CI Tests](https://github.com/bacnet-ex/bacnet_ede/workflows/Elixir%20CI/badge.svg)](https://github.com/bacnet-ex/bacnet_ede/actions?query=branch%3Amaster) [![Hex.pm](https://img.shields.io/hexpm/v/bacnet_ede.svg)](https://hex.pm/packages/bacnet_ede) [![Documentation](https://img.shields.io/badge/documentation-gray)](https://hexdocs.pm/bacnet_ede)

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
