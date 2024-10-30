package main

import (
    "net/http"
    "net/http/httptest"
    "testing"
)

func TestHandler(t *testing.T) {
    req, _ := http.NewRequest("GET", "/", nil)
    rr := httptest.NewRecorder()

    handler := http.HandlerFunc(Handler)
    handler.ServeHTTP(rr, req)

    expected := "Hello, World!"
    if rr.Body.String() != expected {
        t.Errorf("Expected '%s' but got '%s'", expected, rr.Body.String())
    }
}
