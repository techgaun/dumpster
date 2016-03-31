package main

import (
    "testing"
    "github.com/stretchr/testify/assert"
    "./electric_demand"
)

func TestPositiveSMA(t *testing.T) {
    result := sma.Sma([]float64{1, 2, 3, 4, 5, 6}, 2)
    assert.Equal(t, result, []float64{1.5, 2.5, 3.5, 4.5, 5.5}, "The sma must be equal")
    assert.Equal(t, 5, len(result), "The sma must contain correct number of results")
}

func TestMixedSMA(t *testing.T) {
    result := sma.Sma([]float64{-2, -1, 0, 1, 2, 3}, 2)
    assert.Equal(t, result, []float64{-1.5, -0.5, 0.5, 1.5, 2.5}, "The sma must be equal")
    assert.Equal(t, 5, len(result), "The sma must contain correct number of results")
}
