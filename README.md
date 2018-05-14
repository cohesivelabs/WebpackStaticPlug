# WebpackStatic
  Phoenix plug to proxy a locally running instance of the webpack dev server.<br />
  This plug will only serve assets when the env parameter has the value of `:dev`.<br />
  Phoenix will be allowed a chance to resolve any assets not resolved by webpack.<br />

## Installation

```elixir
defp deps do
  [
    {:WebpackStaticPlug, "~> 0.1.1"}
  ]
end
```

And run:

  $ mix deps.get

## Usage
Add WebpackStatic.Plug as a plug in the phoenix project's endpoint.

## Arguments
* **port** - *(required)* The port that the webpack dev server is listening on.
* **webpack_assets** - *(required)* a list of the paths in the static folder that webpack will for serve. The plug will ignore requests to any other path.
* **env** - *(required)* the current environment the project is running under.
* **manifest_path** - *(optional)* relative path that will resolve from the static folder of the webpack manifest file.

## Example
in `endpoint.ex`

```elixir
  plug WebpackStatic.Plug,
        port: 9000, webpack_assets: ~w(css fonts images js),
        env: Mix.env, manifest_path: "/manifest.json"
```
