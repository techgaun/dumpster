package main

import (
    "fmt"
    "math/rand"
    "time"
    "./electric_demand"
)

func now() int64 {
    return time.Now().UnixNano() / int64(time.Millisecond)
}

func random(min, max int) int {
    return rand.Intn(max - min) + min
}

func main() {
    var datapoints [] float64
    var size int = 100000
    var period int = 900 // 15 * 60
    rand.Seed(time.Now().Unix())
    for i := 0; i < size; i++ {
        datapoints = append(datapoints, float64(random(50, 100)))
    }

    time_start := now()
    result := sma.Sma(datapoints, period)
    // fmt.Printf("%v", result)
    time_end := now()
    fmt.Println("Total time taken :", (time_end - time_start), "ms")
    fmt.Println("Number of items:", len(result))
}
