package main

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"net/http"
)

// Función para cargar en memoria contenido de archivo de transacciones
func loadBuyers() []Buyer {

    resp, err := http.Get("https://kqxty15mpg.execute-api.us-east-1.amazonaws.com/buyers")

    if err != nil {
        fmt.Println("Error cargando datos")
    }

    defer resp.Body.Close()
  
    var buyers []Buyer
    content, err := ioutil.ReadAll(resp.Body)
    if err != nil {
        fmt.Println("Error cargando datos")
    }
    json.Unmarshal(content, &buyers)
    //fmt.Printf("Buyers : %+v", buyers)
    
    // Agregar tipo
    for i := range buyers {
		buyers[i].DType = []string{"Buyer"}
	}
    
    return buyers
}