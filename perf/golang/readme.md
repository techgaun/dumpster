# Performance Tests

### Simple Moving Average

#### Unit Test
```shell
$ go test -covermode=count
PASS
coverage: 0.0% of statements
ok  	_/home/samar/fun/performance-test/lang/golang/sma	0.002s
```

```shell
$ go run main.go
Total time taken : 2 ms
Number of items: 99101

$ go build -o sma_go # build sma_go output

$ parallel ./sma_go ::: {1..20}
Total time taken : 3 ms
Number of items: 99101
Total time taken : 2 ms
Number of items: 99101
Total time taken : 6 ms
Number of items: 99101
Total time taken : 10 ms
Number of items: 99101
Total time taken : 7 ms
Number of items: 99101
Total time taken : 4 ms
Number of items: 99101
Total time taken : 8 ms
Number of items: 99101
Total time taken : 3 ms
Number of items: 99101
Total time taken : 4 ms
Number of items: 99101
Total time taken : 21 ms
Number of items: 99101
Total time taken : 4 ms
Number of items: 99101
Total time taken : 2 ms
Number of items: 99101
Total time taken : 13 ms
Number of items: 99101
Total time taken : 8 ms
Number of items: 99101
Total time taken : 3 ms
Number of items: 99101
Total time taken : 1 ms
Number of items: 99101
Total time taken : 5 ms
Number of items: 99101
Total time taken : 4 ms
Number of items: 99101
Total time taken : 7 ms
Number of items: 99101
Total time taken : 2 ms
Number of items: 99101
```
