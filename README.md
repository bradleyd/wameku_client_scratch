# WamekuClientScratch

This is an attempt to write a system monitoring solution in Elixir.


## This is not usable code

This code expects there to be json config and checks to be located at `/tmp/checks`


### Checks

`/tmp/checks/config/check_cpu.json` 

The check configs should look like this

```json
{
  "check": {
      "name": "check-cpu",
      "path": "/tmp/checks/check_cpu.sh",
      "arguments": ["60"],
      "interval": 90,
      "notifier": ["stdout"],
      "actions": [{ 
        "apply_on_error": true,
        "name": "cpu",
        "qualifier": "count",
        "condition": "greater_than",
        "value": 5,
        "command": "/tmp/foobar.sh"
      }]  
  }
}
```

Another example.

```json
{
  "check": {
      "name": "check-disk",
      "path": "/tmp/checks/check_disk.sh",
      "arguments": ["-w60"],
      "interval": 90,
      "notifier": ["foobar"],
      "actions": [{ 
        "apply_on_error": false,
        "name": "disk_full",
        "qualifier": "output",
        "condition": "matches",
        "value": "root",
        "command": "/tmp/foobar.sh"
      }]  
  }
}
```

* name - name of check

* path - location of check to run

* arguments - list of arguments to pass to check

* interval - how frequent to run the check

* notifier - The alerting type living on the server if check fails

### actions - Take an `action` if a qualifier's condition is met

* apply_on_error - Apply the action when check is in error and qualifier is met or anytime qualifier is met.
* name - name of action

* qualifier - The key in check_metadata to apply a condition and value to

* condition - How to evaluate the qualifier and value (greater than, less than, matches, equals)

* value - The right side of our action equation

* command - executable to run if action equation is true

### Running the checks

The check returns a `WamekuClientScratch.Shell.CheckResult` struct with `output, exit_code, error` keys.
This map is merged with a `WamekuClientScratch.Worker.CheckMetadata` struct (see below).

These are the keys an action can be applied to. 

```
%WamekuClientScratch.Worker.CheckMetadata{actions: [%{"apply_on_error" => false, "command" => "/tmp/foobar.sh", "condition" => "matches", "name" => "check-memory", "qualifier" => "output", "value" => "free"}], count: 0, exit_code: 0, history: [0], host: "bradleyd-900X4C", last_checked: 1452746251, name: "check-memory", notifier: ["stdout"], output: "MEM OK - free system memory: 4865 MB\n"}
```

The check itself `/tmp/checks/check_cpu.sh` should behave like so.

* exit either 0,1,2 code

* return a message

* must be executable from a shell path
