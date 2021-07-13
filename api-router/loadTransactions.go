package main

import (
	"bufio"
	"fmt"
	"log"
	"net/http"
)

// Función para cargar en memoria contenido de archivo de transacciones
func loadTransactions() [][]string {

    resp, err := http.Get("https://kqxty15mpg.execute-api.us-east-1.amazonaws.com/transactions")

    if err != nil {
        fmt.Println("Error cargando datos")
    }

    defer resp.Body.Close()

    scanner := bufio.NewScanner(resp.Body)
    scanner.Split(bufio.ScanBytes)

    foundToken := false
    myData := make([][]string, 0)
    mySlice := make([]string, 0)
    tempChain := ""

    for scanner.Scan() {
        if scanner.Bytes()[0] == 00 {
            if foundToken {
                myData = append(myData, mySlice)
                mySlice = nil
            } else {
                mySlice = append(mySlice, tempChain)
                tempChain = ""
            }
            foundToken = true
        } else {
            tempChain += scanner.Text()
            foundToken = false
        }        
    }
    //fmt.Println(myData)

    if err := scanner.Err(); err != nil {
        log.Fatal(err)
    }
    return myData
}