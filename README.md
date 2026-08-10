# inventory-api-proto

This repository contains all of the models and documentation for building an Inventory integration into Zentail via the API.

An **inventory integration** is any system that holds physical stock Zentail needs to know about — a 3PL, a warehouse management system, or a storefront acting as a warehouse. It reports what it has; Zentail decides what to do with it.

Fulfillment is a separate contract. If you are also shipping orders on Zentail's behalf, see
[shipping-api-proto](https://github.com/hdtradeservices/shipping-api-proto) — the two are deliberately independent, so a
system that only holds stock does not have to implement fulfillment, and vice versa.

## Building

```
make        # regenerate go/, openapiv2/ and docs/ from src/
make lint   # protolint
```

Generated artifacts are committed. Regenerate and commit them with any change to `src/`.
