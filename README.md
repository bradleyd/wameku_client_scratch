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
        "name": "disk_full",
        "qualifier": "count",
        "condition": "greater_than",
        "value": 5,
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

* name - name of action

* qualifier - The key in check_metadata to apply a condition and value to

* condition - How to evaluate the qualifier and value (greater than, less than, matches, equals)

* value - The right side of our action equation

* command - executable to run if action equation is true

The check itself `/tmp/checks/check_cpu.sh` should behave like so.

* exit either 0,1,2 code

* return a message

* must be executable from a shell path
