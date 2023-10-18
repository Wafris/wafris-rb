If you'd like to ensure that Waris is working properly you can launch your application in development. You're going to visit a path
that does not exist in your routes and would normally return a 404. Once blocked it will instead return a page with 'Blocked' and
a status code of 403.

If you're already using Redis locally we recommend that you use a separate Redis DB. Redis allows you to do this by appending
`/<db number>` to the end of your Redis URL. If you'd like to use DB 13 for example, you'd use the following:

```
redis://localhost:6379/13
```

Set a block path using the following command where `<path>` is the path you'd like to block. In the following example we're going to set
the block for any path that contains `wafris-test`:

```sh
redis-cli HSET rules-blocked-p wafris-test "This is a test rule"
```

Note that if you're using a different DB you'd use the `-n` argument to specify the DB number:

```sh
redis-cli -n 13 HSET rules-blocked-p wafris-test "This is a test rule"
```

Then visit this path in your browser: `http://localhost:3000/<path>` and you should see a page with
'blocked' and a 403 status code.
