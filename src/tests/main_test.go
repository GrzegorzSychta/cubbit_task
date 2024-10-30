// src/tests/main_test.go

package tests

import (
    "net/http"
    "net/http/httptest"
    "testing"

    gohelloapp "github.com/GrzegorzSychta/cubbit/src/{{ENV}}/go-hello-app"
)

func TestHandler(t *testing.T) {
    req, _ := http.NewRequest("GET", "/", nil)
    rr := httptest.NewRecorder()

    handler := http.HandlerFunc(gohelloapp.Handler)
    handler.ServeHTTP(rr, req)

    expected := "Hello, World!"
    if rr.Body.String() != expected {
        t.Errorf("Expected '%s' but got '%s'", expected, rr.Body.String())
    }
}
