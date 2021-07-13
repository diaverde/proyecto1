package main

import (
	"bufio"
	"fmt"
	"log"
	"net/http"
	"strings"
)

// Función para cargar en memoria contenido de archivo de transacciones
func loadProducts() [][]string {

    resp, err := http.Get("https://kqxty15mpg.execute-api.us-east-1.amazonaws.com/products")

    if err != nil {
        fmt.Println("Error cargando datos")
    }

    defer resp.Body.Close()

    scanner := bufio.NewScanner(resp.Body)
    scanner.Split(bufio.ScanLines)

    myData := make([][]string, 0)
    
    for scanner.Scan() {
        //fmt.Println(strings.Split(scanner.Text(), "'"))
        if strings.Contains(scanner.Text(), "\""){
            ind1 := strings.Index(scanner.Text(), "\"")
            ind2 := strings.Index(scanner.Text()[ind1+1:], "\"") + ind1 + 1
            weirdStr := strings.ReplaceAll(scanner.Text()[ind1+1:ind2],"'","$punk$")
            newLine := scanner.Text()[:ind1] + weirdStr + scanner.Text()[ind2+1:]
            finalLine := strings.ReplaceAll(strings.ReplaceAll(newLine,"'",","),"$punk$", "'")
            //fmt.Println(finalLine)
            myData = append(myData, strings.Split(finalLine, ","))
        } else {
            myData = append(myData, strings.Split(scanner.Text(), "'"))
        }
    }

    if err := scanner.Err(); err != nil {
        log.Fatal(err)
    }
    return myData
}