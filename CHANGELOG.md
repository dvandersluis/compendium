# Change Log

## 1.1.0 (unreleased)
* Added query filters (allow a result set to be filtered to remove/translate/etc. data)
* Extract chart providers into their own gems

## 1.0.7
* Added the ability to render a report or a specific query of a report as JSON

## 1.0.6
* Added a built-in renderer for metrics

## 1.0.5
* Fixed the `:only` and `:except` options to `Report#run`
* Give `ThroughQuery` access to params if the definition block has an arity of 2
* Fixed mutating results in a `ThroughQuery` block affecting the parent query