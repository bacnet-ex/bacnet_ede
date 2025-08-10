defmodule BACnetEDE.Project.Object do
  @moduledoc """
  The object struct identifies an object of the EDE.

  The object usually contains minimal information,
  such as key name, device instance, object name and object type.
  However some information, such as the default present value and whether it supports COV reporting,
  can be shared. All optional information is `nil`able and as such may not be present in the EDE.
  All additional information that are not part of the EDE format will be available in the `:more_keys` map.
  Since these information are not known, they are available as string only.

  Information on the keys of the struct can be found in the `t:t/0` docs.
  """

  @dialyzer {:no_contracts, [new: 0]}

  @typedoc """
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
  """
  @type t :: %__MODULE__{
          keyname: String.t(),
          device_instance: non_neg_integer(),
          object_name: String.t(),
          object_type: non_neg_integer(),
          object_instance: non_neg_integer(),
          description: String.t() | nil,
          default_present_value: String.t() | nil,
          min_present_value: float() | nil,
          max_present_value: float() | nil,
          settable: boolean() | nil,
          supports_cov: boolean() | nil,
          high_limit: float() | nil,
          low_limit: float() | nil,
          state_text_ref: non_neg_integer() | nil,
          unit_code: non_neg_integer() | nil,
          vendor_specific_address: String.t() | nil,
          notification_class: non_neg_integer() | nil,
          more_keys: %{
            optional(String.t()) => String.t()
          }
        }

  @enforce_keys [
    :keyname,
    :device_instance,
    :object_name,
    :object_type,
    :object_instance
  ]
  defstruct [
    :keyname,
    :device_instance,
    :object_name,
    :object_type,
    :object_instance,
    :description,
    :default_present_value,
    :min_present_value,
    :max_present_value,
    :settable,
    :supports_cov,
    :high_limit,
    :low_limit,
    :state_text_ref,
    :unit_code,
    :vendor_specific_address,
    :notification_class,
    :more_keys
  ]

  @doc false
  @spec new() :: t()
  def new() do
    %__MODULE__{
      keyname: nil,
      device_instance: nil,
      object_name: nil,
      object_type: nil,
      object_instance: nil,
      more_keys: %{}
    }
  end

  @doc false
  @spec new(Enumerable.t()) :: t()
  def new(keys) do
    __MODULE__
    |> struct(keys)
    |> Map.update!(:more_keys, fn
      nil -> %{}
      val -> val
    end)
  end

  @doc """
  Validates the struct (type validation).
  """
  @spec valid?(t()) :: boolean()
  # credo:disable-for-next-line Credo.Check.Refactor.CyclomaticComplexity
  def valid?(%__MODULE__{} = t) do
    is_binary(t.keyname) and
      is_integer(t.device_instance) and t.device_instance >= 0 and
      t.device_instance <= 4_194_302 and
      is_binary(t.object_name) and t.object_name != "" and
      is_integer(t.object_type) and t.object_type >= 0 and
      is_integer(t.object_instance) and t.object_instance >= 0 and
      t.object_instance <= 4_194_302 and
      (is_binary(t.description) or is_nil(t.description)) and
      (is_binary(t.default_present_value) or is_nil(t.default_present_value)) and
      (is_float(t.min_present_value) or is_nil(t.min_present_value)) and
      (is_float(t.max_present_value) or is_nil(t.max_present_value)) and
      (is_boolean(t.settable) or is_nil(t.settable)) and
      (is_boolean(t.supports_cov) or is_nil(t.supports_cov)) and
      (is_float(t.high_limit) or is_nil(t.high_limit)) and
      (is_float(t.low_limit) or is_nil(t.low_limit)) and
      (is_integer(t.state_text_ref) or is_nil(t.state_text_ref)) and
      ((is_integer(t.unit_code) and t.unit_code >= 0) or is_nil(t.unit_code)) and
      (is_binary(t.vendor_specific_address) or is_nil(t.vendor_specific_address)) and
      is_map(t.more_keys) and
      Enum.all?(t.more_keys, fn {key, value} -> is_binary(key) and is_binary(value) end)
  end
end
