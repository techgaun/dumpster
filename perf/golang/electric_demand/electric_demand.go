package sma

func Sma(datapoints []float64, period int) (result []float64) {
    length := len(datapoints)
    var i int
    tmp_total := 0.0

    // range alt. for i, v := range datapoints
    for i = 0; i < period; i++ {
        tmp_total += datapoints[i]
        result = append(result, 0.0)
    }

    result = result[:len(result) - 1]
    tmp_total /= float64(period)
    result = append(result, tmp_total)

    for j := i; j < length; j++ {
        tmp_total = result[j - 1] + ((datapoints[j] - datapoints[j - period])/float64(period))
        result = append(result, tmp_total)
    }

    result = result[period - 1:]

    return
}
