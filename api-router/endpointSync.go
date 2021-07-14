package main

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"strconv"
	"strings"
	"time"

	"github.com/dgraph-io/dgo/v210"
	"github.com/dgraph-io/dgo/v210/protos/api"
	"github.com/go-chi/chi"
	"google.golang.org/grpc"
)

type syncResource struct{}

func (rs syncResource) Routes() chi.Router {
  r := chi.NewRouter()

  r.Post("/", rs.Sync)  // POST /sync - Synchronize data
  
  return r
}

// Request Handler - POST /sync
func (rs syncResource) Sync(w http.ResponseWriter, r *http.Request) {
  
  type UnixDate struct {
    DateToSync int
  }
  
  buf := new(bytes.Buffer)
  buf.ReadFrom(r.Body)
  newStr := buf.String()
  
  var unixDate UnixDate
  json.Unmarshal([]byte(newStr), &unixDate)
  fmt.Println("Date to synchronize:", unixDate.DateToSync)

  date := fmt.Sprint(unixDate.DateToSync)
  
  if date != "" {

    dateNum, err := strconv.ParseInt(date, 10, 64)
    if err != nil {
      fmt.Println("Error",err)
      http.Error(w, err.Error(), http.StatusInternalServerError)
      return
    }
    // Tiempo para la carga
    unixTime := time.Unix(dateNum, 0)
    timeInRFC3339str := unixTime.Format(time.RFC3339)
    timeInRFC3339, err := time.Parse (time.RFC3339, timeInRFC3339str)
    if err != nil {
      log.Fatal(err)
    }
    
    // Cargar los compradores obtenidos del archivo
    buyerData := loadBuyers()
    //fmt.Println(buyerData)
    // Cargar los productos obtenidos del archivo
    productData := loadProducts()
    //fmt.Println(productData)
    // Cargar las transacciones obtenidas del archivo
    transactionData := loadTransactions()
    //fmt.Println(transactionData)
	
    // Conexión a cliente Dgraph
    conn, err := grpc.Dial("localhost:9080", grpc.WithInsecure())
    if err != nil {
      log.Fatal(err)
    }
    defer conn.Close()
    dgraphClient := dgo.NewDgraphClient(api.NewDgraphClient(conn))
	
    // Definición de esquema
    op := &api.Operation{}
    op.Schema = `
      date: datetime @index(day).
      id: string @index(exact,term) .
      name: string @index(term) .
      age: int .
      ip_address: string @index(term).
      device: string .
      price: float .
      buyer_id: string @index(exact) .
      product_ids: [string] @index(exact) .
      buyers: [uid] .
      products: [uid] .
      transactions: [uid] .
      type DateData {
        date: datetime!
        buyers: [Buyer]
        products: [Product]
        transactions: [Transaction]
      }
      type Transaction {
        id: string!
        buyer_id: string!
        ip_address: string
        device: string
        product_ids: [string]!
      }
      type Buyer {
        id: string!
        name: string!
        age: int			
      }
      type Product {
        id: string!
        name: string!
        price: float
      }
    `

    ctx := context.Background()
    if err := dgraphClient.Alter(ctx, op); err != nil {
      log.Fatal(err)
    }

    // Cargar listas de elementos
    // Productos
    fullProductData := make([]Product, 0)
    for _, v := range productData {		
      // Conversión de precio a flotante
      my_price, err := strconv.ParseFloat(v[2], 32)
      if err != nil {
        log.Fatal(err)
      }
      my_p := Product{
        Id: v[0],
        Name: v[1],
        Price: float32(my_price),
        DType: []string{"Product"},
      }
      fullProductData = append(fullProductData, my_p)
    }
		
    // Transacciones
    fullTransactionData := make([]Transaction, 0)
    for _, v := range transactionData {
      //fmt.Println(v)
      // Capturar cada id de producto por separado
      p_ids := make([]string, 0)
      for _, w := range v {
        if strings.Contains(w, "(") {
          chain := strings.Trim(w, "()")
          p_ids = strings.Split(chain, ",")
          //fmt.Println(p_ids)
        }
      }
      my_t := Transaction{
        Id: v[0],
        Buyer_id : v[1],
        Ip_address: v[2],
        Device: v[3],
        Product_ids: p_ids,
        DType: []string{"Transaction"},
      }	
      fullTransactionData = append(fullTransactionData, my_t)
    }

    // Carga de mutación con los datos capturados
    my_data := DateData {
      Date: timeInRFC3339,
      Buyers: buyerData,
      Products: fullProductData,
      Transactions: fullTransactionData,
      DType: []string{"DateData"},
    }

    // Crear transacción
    txn := dgraphClient.NewTxn()
    defer txn.Discard(ctx)

    mu := &api.Mutation{
      CommitNow: true,
    }
    pb, err := json.Marshal(my_data)
    if err != nil {
      log.Fatal(err)
    }
    //fmt.Println(my_data)
    mu.SetJson = pb
    response, err := txn.Mutate(ctx, mu)
    if err != nil {
      log.Fatal(err)
    }
    if (response.String() == "") {
      fmt.Println(response)
    } else {
      fmt.Println("Datos sincronizados")
      w.Write([]byte("Datos sincronizados"))
    }
    
  } else {
    
    // Sin parámetro de fecha, la solicitud es inválida
    w.Write([]byte("Invalid Request"))

  }
  
}
