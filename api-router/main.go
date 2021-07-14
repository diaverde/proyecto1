package main

import (
	"log"
	"net/http"
	"os"

	"github.com/go-chi/chi"
)

func main() {
  
  port := "5000"

  if fromEnv := os.Getenv("PORT"); fromEnv != "" {
    port = fromEnv
  }

  log.Printf("Starting up on http://localhost:%s", port)

  r := chi.NewRouter()

  r.Get("/", func(w http.ResponseWriter, r *http.Request) {
    w.Header().Set("Content-Type", "text/plain")
    w.Write([]byte("Hola, este es mi servidor."))
  })

  r.Mount("/buyers", buyersResource{}.Routes())
  r.Mount("/sync", syncResource{}.Routes())

  log.Fatal(http.ListenAndServe(":" + port, r))
}