# `BACnetEDE.Project.Object`
[🔗](https://github.com/bacnet-ex/bacnet_ede/blob/master/lib/bacnet_ede/project/object.ex#L1)

The object struct identifies an object of the EDE.

The object usually contains minimal information,
such as key name, device instance, object name and object type.
However some information, such as the default present value and whether it supports COV reporting,
can be shared. All optional information is `nil`able and as such may not be present in the EDE.
All additional information that are not part of the EDE format will be available in the `:more_keys` map.
Since these information are not known, they are available as string only.

Information on the keys of the struct can be found in the `t:t/0` docs.

# `t`

```elixir
@type t() :: %BACnetEDE.Project.Object{
  default_present_value: String.t() | nil,
  description: String.t() | nil,
  device_instance: non_neg_integer(),
  high_limit: float() | nil,
  keyname: String.t(),
  low_limit: float() | nil,
  max_present_value: float() | nil,
  min_present_value: float() | nil,
  more_keys: %{optional(String.t()) =&gt; String.t()},
  notification_class: non_neg_integer() | nil,
  object_instance: non_neg_integer(),
  object_name: String.t(),
  object_type: non_neg_integer(),
  settable: boolean() | nil,
  state_text_ref: non_neg_integer() | nil,
  supports_cov: boolean() | nil,
  unit_code: non_neg_integer() | nil,
  vendor_specific_address: String.t() | nil
}
```

Represents an object of the EDE.

The following keys are present and some are optional (`nil`):
- `keyname` - System wide unique name of the object.
- `device_instance` - The object instance number of the device the object resides in.
- `object_name` - The object name and identical to the `object_name` BACnet property.
  The name must be unique inside the device.
- `object_type` - The object type number as defined per ASHRAE 135 BACnet specification.
- `object_instance` - The object instance number - within a device different objects
  of the same type are distinguished by their instance number.
- `description` - An information text that provides more detailed description of the datapoint.
- `default_present_value` - The default value for the `present_value` BACnet property.
  If the object is commandable, this field should contain the `relinquish_default` value.
- `min_present_value` - The minimum value that can be in the `present_value` BACnet property.
- `max_present_value` - The maximum value that can be in the `present_value` BACnet property.
- `settable` - Indicates whether the `present_value` BACnet property is writable (can be set by a client).
- `supports_cov` - Indicates whether the object supports COV reporting or not.
  An empty field may indicate that it does support COV. Boolean values will indicate if it does or not.
- `high_limit` - Indicates whether the object supports Intrinsic reporting and will contain the value
  of the `high_limit` BACnet property if the field is readonly.
  This value should be absent the field is writable (can be set by a client).
  In practice, this value might also be absent if the object does not support Intrinsic reporting.
- `low_limit` - Indicates whether the object supports Intrinsic reporting and will contain the value
  of the `low_limit` BACnet property if the field is readonly.
  This value should be absent the field is writable (can be set by a client).
  In practice, this value might also be absent if the object does not support Intrinsic reporting.
- `state_text_ref` - The value is used as reference number to refer to entries in the state text file.
  Different objects listed in the EDE may refer to the same entry, if their textual representation are identical.
- `unit_code` - The BACnet engineering unit as defined by ASHRAE 135 BACnet.
  A separate unit file may be used to point the value to a specific text
  (however the reserved numbers must be identical to the BACnet specification).
- `vendor_specific_address` - This may be used to identify addresses used in the server device.
  The address may provide an internal datapoint identification or reference.
- `notification_class` - Contains the instance number of the Notification Class object linked to the object.
  If the object does not support Intrinsic reporting, this value should be absent.
- `more_keys` - Contains additional found (unknown) columns in the EDE that are not part of the EDE specification.
  The keys and values are all strings and may be further parsed, used or converted by the user.

# `valid?`

```elixir
@spec valid?(t()) :: boolean()
```

Validates the struct (type validation).

---

*Consult [api-reference.md](api-reference.md) for complete listing*
