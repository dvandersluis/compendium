# Upgrading Compendium

## Upgrading to >= 2.0.0

### Queries
* The `collect` option has been replaced with `sql` (default `false`), in order to decouple queries from
active record. Replace `collect: :active_record` with `sql: false`. 

### Rails
#### Routes
* The `mount_compendium` routing monkey patch was removed in favour of actual routes. The actual routes
 are slightly less configurable. Replace `mount_compendium` with `mount Compendium::Engine => '/path'` 
