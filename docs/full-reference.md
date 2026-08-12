# Protocol Documentation
<a name="top"></a>

## Table of Contents

- [inventory_api/inventory/service.proto](#inventory_api_inventory_service-proto)
    - [Check](#inventory_api-Check)
    - [IntegrationStatusRequest](#inventory_api-IntegrationStatusRequest)
    - [IntegrationStatusResponse](#inventory_api-IntegrationStatusResponse)
    - [InventoryItem](#inventory_api-InventoryItem)
    - [InventoryUpdate](#inventory_api-InventoryUpdate)
    - [InventoryUpdateResult](#inventory_api-InventoryUpdateResult)
    - [ListInventoryRequest](#inventory_api-ListInventoryRequest)
    - [ListInventoryResponse](#inventory_api-ListInventoryResponse)
    - [ListWarehousesRequest](#inventory_api-ListWarehousesRequest)
    - [ListWarehousesResponse](#inventory_api-ListWarehousesResponse)
    - [UpdateInventoryRequest](#inventory_api-UpdateInventoryRequest)
    - [UpdateInventoryResponse](#inventory_api-UpdateInventoryResponse)
    - [Warehouse](#inventory_api-Warehouse)
    - [WarehouseStatusRequest](#inventory_api-WarehouseStatusRequest)
    - [WarehouseStatusResponse](#inventory_api-WarehouseStatusResponse)
  
    - [CheckSource](#inventory_api-CheckSource)
    - [CheckState](#inventory_api-CheckState)
    - [WarehouseRole](#inventory_api-WarehouseRole)
  
    - [InventoryIntegrationService](#inventory_api-InventoryIntegrationService)
    - [WarehouseService](#inventory_api-WarehouseService)
  
- [Scalar Value Types](#scalar-value-types)



<a name="inventory_api_inventory_service-proto"></a>
<p align="right"><a href="#top">Top</a></p>

## inventory_api/inventory/service.proto



<a name="inventory_api-Check"></a>

### Check



| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| name | [string](#string) |  | Stable identifier, not prose — an operator or an alert matches on this, so it must not change when the wording does. Lower_snake_case by convention. |
| state | [CheckState](#inventory_api-CheckState) |  |  |
| message | [string](#string) |  | Prose for a human. Say what is wrong and what would fix it. |
| source | [CheckSource](#inventory_api-CheckSource) |  | Who observed this. Zentail sets it; an integration filling it in on a WarehouseStatus response has it overwritten with INTEGRATION. |






<a name="inventory_api-IntegrationStatusRequest"></a>

### IntegrationStatusRequest







<a name="inventory_api-IntegrationStatusResponse"></a>

### IntegrationStatusResponse



| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| checks | [Check](#inventory_api-Check) | repeated | Zentail&#39;s own observations and the integration&#39;s last reported checks, in one list. Read `source` to tell them apart; render them together, because an operator asking &#34;is this working&#34; does not care who noticed. |






<a name="inventory_api-InventoryItem"></a>

### InventoryItem



| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| sku | [string](#string) |  |  |
| warehouse_unique_id | [string](#string) |  | The caller&#39;s own identifier for the warehouse, not Zentail&#39;s internal id. |
| quantity | [int32](#int32) |  | What Zentail currently believes is on hand. |
| last_updated_ts | [google.protobuf.Timestamp](#google-protobuf-Timestamp) |  | When that belief was last updated, by anyone. |






<a name="inventory_api-InventoryUpdate"></a>

### InventoryUpdate



| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| sku | [string](#string) |  |  |
| warehouse_unique_id | [string](#string) |  |  |
| quantity | [int32](#int32) |  | Absolute on-hand, not a delta. What is physically there right now, excluding anything already picked for an order. |
| bin_location | [string](#string) |  | Optional free-text bin or slot, passed through for operator reference. |






<a name="inventory_api-InventoryUpdateResult"></a>

### InventoryUpdateResult
InventoryUpdateResult echoes the full key of the update it answers. SKU alone
is not enough — a batch may carry the same SKU for two warehouses.


| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| sku | [string](#string) |  |  |
| warehouse_unique_id | [string](#string) |  |  |
| success | [bool](#bool) |  |  |
| error_message | [string](#string) |  |  |
| stale | [bool](#bool) |  | True when the update was discarded because observed_ts predated the value Zentail already held. Not an error: the newer reading stands. Treat as success unless it is happening constantly, which means clock skew or a second writer. |






<a name="inventory_api-ListInventoryRequest"></a>

### ListInventoryRequest



| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| updated_since | [google.protobuf.Timestamp](#google-protobuf-Timestamp) |  | Optional: only SKUs whose Zentail-side quantity changed since this time. Omit for a full listing. |
| cursor | [string](#string) |  | Leave empty for the first page; pass next_cursor thereafter. |
| page_size | [int32](#int32) |  | Server-capped. Omit for the default. |






<a name="inventory_api-ListInventoryResponse"></a>

### ListInventoryResponse



| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| items | [InventoryItem](#inventory_api-InventoryItem) | repeated |  |
| next_cursor | [string](#string) |  | Empty when the page is the last one. |






<a name="inventory_api-ListWarehousesRequest"></a>

### ListWarehousesRequest







<a name="inventory_api-ListWarehousesResponse"></a>

### ListWarehousesResponse



| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| warehouses | [Warehouse](#inventory_api-Warehouse) | repeated | Only warehouses the caller can actually name. A warehouse bound to the integration with no identifier set is omitted, because there is no value a caller could send to address it; IntegrationStatus is where that shows up as a problem to fix. |






<a name="inventory_api-UpdateInventoryRequest"></a>

### UpdateInventoryRequest



| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| updates | [InventoryUpdate](#inventory_api-InventoryUpdate) | repeated | Server-capped per call. Exceeding the cap fails the request with the limit in the error rather than silently truncating. |
| observed_ts | [google.protobuf.Timestamp](#google-protobuf-Timestamp) |  | When the caller observed these quantities — not when it sent them. Required: without it Zentail cannot tell a stale retry from a fresh reading, and ordering is the whole basis of the idempotency guarantee. |






<a name="inventory_api-UpdateInventoryResponse"></a>

### UpdateInventoryResponse



| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| results | [InventoryUpdateResult](#inventory_api-InventoryUpdateResult) | repeated | One entry per update. Order is not guaranteed, which is why each result echoes its full key. |






<a name="inventory_api-Warehouse"></a>

### Warehouse



| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| warehouse_unique_id | [string](#string) |  | Send this as warehouse_unique_id on an InventoryUpdate. Never empty. |
| name | [string](#string) |  | Operator-facing label, for logs and support conversations. Not a key, not stable, and not safe to match on. |
| role | [WarehouseRole](#inventory_api-WarehouseRole) |  | Which contract this warehouse participates in. A caller that only ships from a warehouse does not hold stock there and has no reason to report inventory for it. |






<a name="inventory_api-WarehouseStatusRequest"></a>

### WarehouseStatusRequest



| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| warehouse_unique_id | [string](#string) |  | The warehouse being asked about, named with the integration&#39;s own identifier — the same value ListWarehouses vends. |






<a name="inventory_api-WarehouseStatusResponse"></a>

### WarehouseStatusResponse



| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| checks | [Check](#inventory_api-Check) | repeated |  |





 


<a name="inventory_api-CheckSource"></a>

### CheckSource


| Name | Number | Description |
| ---- | ------ | ----------- |
| CHECK_SOURCE_UNSPECIFIED | 0 |  |
| CHECK_SOURCE_ZENTAIL | 1 | Zentail observed this from the outside. |
| CHECK_SOURCE_INTEGRATION | 2 | The integration reported this about itself. |



<a name="inventory_api-CheckState"></a>

### CheckState


| Name | Number | Description |
| ---- | ------ | ----------- |
| CHECK_STATE_UNSPECIFIED | 0 |  |
| CHECK_STATE_PASS | 1 |  |
| CHECK_STATE_WARN | 2 |  |
| CHECK_STATE_FAIL | 3 |  |



<a name="inventory_api-WarehouseRole"></a>

### WarehouseRole


| Name | Number | Description |
| ---- | ------ | ----------- |
| WAREHOUSE_ROLE_UNSPECIFIED | 0 |  |
| WAREHOUSE_ROLE_INVENTORY | 1 | The integration holds stock here. Inventory reports are expected. |
| WAREHOUSE_ROLE_SHIPPING | 2 | The integration only ships from here. Stock is owned by someone else. |


 

 


<a name="inventory_api-InventoryIntegrationService"></a>

### InventoryIntegrationService
InventoryIntegrationService is the contract a system holding physical stock —
a 3PL, a warehouse management system, or a storefront acting as a warehouse —
uses to keep Zentail&#39;s picture of that stock correct.

Every call is scoped to the integration resolved from the API token, and
through it to the warehouses bound to that integration. No request carries a
warehouse id or a company id; supplying one would let a caller report stock
into warehouses that are not theirs.

Reporting is **absolute and timestamped**, never a delta. A caller says &#34;this
SKU is at this quantity, as observed at this time&#34; and Zentail resolves
ordering. A lost, duplicated or out-of-order call therefore cannot drift the
count — which matters because these calls cross a network on a poll loop.

Fulfillment is a separate contract. See shipping-api-proto if you also ship
orders on Zentail&#39;s behalf.

| Method Name | Request Type | Response Type | Description |
| ----------- | ------------ | ------------- | ------------|
| ListInventory | [ListInventoryRequest](#inventory_api-ListInventoryRequest) | [ListInventoryResponse](#inventory_api-ListInventoryResponse) | ListInventory returns what Zentail currently believes about the SKUs stocked in the caller&#39;s warehouses.

Two uses. It scopes a sweep — report only these SKUs rather than your whole catalog. And it lets a caller send only genuine differences, which on a large catalog is the difference between a viable poll loop and a pointless one. |
| UpdateInventory | [UpdateInventoryRequest](#inventory_api-UpdateInventoryRequest) | [UpdateInventoryResponse](#inventory_api-UpdateInventoryResponse) | UpdateInventory sets absolute on-hand quantities.

Idempotent and order-insensitive: replaying a call changes nothing, and an update whose observed_ts predates what Zentail already holds is discarded and reported as stale rather than applied. A slow retry overtaking a newer reading cannot roll the count backwards. |
| ListWarehouses | [ListWarehousesRequest](#inventory_api-ListWarehousesRequest) | [ListWarehousesResponse](#inventory_api-ListWarehousesResponse) | ListWarehouses returns the warehouses bound to the caller&#39;s integration, and the identifier to use for each.

This is the discovery call. Every write keys on warehouse_unique_id, which is the caller&#39;s own identifier rather than Zentail&#39;s internal id, so without this a client would have to be told its identifiers out of band and would silently break when they changed. Call it once at startup.

Distinct from IntegrationStatus, which is prose for a human deciding whether the integration is healthy. This is structured data for a machine deciding what to send. |
| IntegrationStatus | [IntegrationStatusRequest](#inventory_api-IntegrationStatusRequest) | [IntegrationStatusResponse](#inventory_api-IntegrationStatusResponse) | IntegrationStatus returns diagnostic checks for the caller&#39;s integration — whether warehouses are bound to it, when stock was last reported, and whether Zentail considers that reading stale.

If the integration implements WarehouseService, Zentail also asks it about each warehouse and folds those checks in, so one call answers &#34;is this working&#34; from both sides.

An inventory integration fails quietly: nothing errors when a poll loop stops, the numbers simply age. This is how that surfaces. |


<a name="inventory_api-WarehouseService"></a>

### WarehouseService
WarehouseService is implemented by the integration, not by Zentail.

Same shape as listing&#39;s SalesChannelService in api-proto: the integration
stands up this service, Zentail dials it, and the answer is folded into the
surface an operator already reads. Zentail can only observe an integration
from the outside — it knows the numbers stopped arriving, never why. This is
where the integration says why.

Zentail calls it while serving IntegrationStatus, so it must be cheap and it
must not call back into Zentail. If the call fails or times out, Zentail
reports that as a failed check rather than failing the status request: an
integration that cannot answer &#34;am I healthy&#34; has answered it.

| Method Name | Request Type | Response Type | Description |
| ----------- | ------------ | ------------- | ------------|
| WarehouseStatus | [WarehouseStatusRequest](#inventory_api-WarehouseStatusRequest) | [WarehouseStatusResponse](#inventory_api-WarehouseStatusResponse) | WarehouseStatus returns the integration&#39;s own diagnostic checks for one warehouse — the things only it can see, such as expiring credentials, a rate limit, or a location it can no longer reach. |

 



## Scalar Value Types

| .proto Type | Notes | C++ | Java | Python | Go | C# | PHP | Ruby |
| ----------- | ----- | --- | ---- | ------ | -- | -- | --- | ---- |
| <a name="double" /> double |  | double | double | float | float64 | double | float | Float |
| <a name="float" /> float |  | float | float | float | float32 | float | float | Float |
| <a name="int32" /> int32 | Uses variable-length encoding. Inefficient for encoding negative numbers – if your field is likely to have negative values, use sint32 instead. | int32 | int | int | int32 | int | integer | Bignum or Fixnum (as required) |
| <a name="int64" /> int64 | Uses variable-length encoding. Inefficient for encoding negative numbers – if your field is likely to have negative values, use sint64 instead. | int64 | long | int/long | int64 | long | integer/string | Bignum |
| <a name="uint32" /> uint32 | Uses variable-length encoding. | uint32 | int | int/long | uint32 | uint | integer | Bignum or Fixnum (as required) |
| <a name="uint64" /> uint64 | Uses variable-length encoding. | uint64 | long | int/long | uint64 | ulong | integer/string | Bignum or Fixnum (as required) |
| <a name="sint32" /> sint32 | Uses variable-length encoding. Signed int value. These more efficiently encode negative numbers than regular int32s. | int32 | int | int | int32 | int | integer | Bignum or Fixnum (as required) |
| <a name="sint64" /> sint64 | Uses variable-length encoding. Signed int value. These more efficiently encode negative numbers than regular int64s. | int64 | long | int/long | int64 | long | integer/string | Bignum |
| <a name="fixed32" /> fixed32 | Always four bytes. More efficient than uint32 if values are often greater than 2^28. | uint32 | int | int | uint32 | uint | integer | Bignum or Fixnum (as required) |
| <a name="fixed64" /> fixed64 | Always eight bytes. More efficient than uint64 if values are often greater than 2^56. | uint64 | long | int/long | uint64 | ulong | integer/string | Bignum |
| <a name="sfixed32" /> sfixed32 | Always four bytes. | int32 | int | int | int32 | int | integer | Bignum or Fixnum (as required) |
| <a name="sfixed64" /> sfixed64 | Always eight bytes. | int64 | long | int/long | int64 | long | integer/string | Bignum |
| <a name="bool" /> bool |  | bool | boolean | boolean | bool | bool | boolean | TrueClass/FalseClass |
| <a name="string" /> string | A string must always contain UTF-8 encoded or 7-bit ASCII text. | string | String | str/unicode | string | string | string | String (UTF-8) |
| <a name="bytes" /> bytes | May contain any arbitrary sequence of bytes. | string | ByteString | str | []byte | ByteString | string | String (ASCII-8BIT) |

