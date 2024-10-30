package main

import (
    "fmt"
    "log"
    "net/http"
    "os"
)

func Handler(w http.ResponseWriter, r *http.Request) {
    secret := os.Getenv("SECRET_MESSAGE")
    if secret != "" {
        fmt.Fprintf(w, "Hello, World! Secret: %s", secret)
    } else {
        fmt.Fprintf(w, "Hello, World!")
    }
}
//h
func main() {
    http.HandleFunc("/", Handler)
    port := os.Getenv("PORT")
    if port == "" {
        port = "8080"
    }
    log.Printf("Server starting on port %s", port)
    log.Fatal(http.ListenAndServe(":"+port, nil))
}
