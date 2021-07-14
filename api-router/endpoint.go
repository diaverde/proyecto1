package main

import (
	"context"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"strings"

	"github.com/dgraph-io/dgo/v210"
	"github.com/dgraph-io/dgo/v210/protos/api"
	"github.com/go-chi/chi"
	"google.golang.org/grpc"
)

type buyersResource struct{}

func (rs buyersResource) Routes() chi.Router {
  r := chi.NewRouter()

  r.Get("/", rs.GetBuyers)    // GET /buyers

  r.Route("/{id}", func(r chi.Router) {
    r.Use(BuyerCtx)
    r.Get("/", rs.Get)       // GET /posts/{id} - Read a single post by :id.    
  })
  
  return r
}

// Request Handler - GET /buyers
func (rs buyersResource) GetBuyers(w http.ResponseWriter, r *http.Request) {
  
  fmt.Println("Capturando compradores...")
  
  // Estructura para decodificar datos recibidos
  type Root struct {
    DataOfDate []DateData `json:"data"`
  }
  
  // Conexión a cliente Dgraph
  conn, err := grpc.Dial("localhost:9080", grpc.WithInsecure())
  if err != nil {
    log.Fatal(err)
    http.Error(w, err.Error(), http.StatusInternalServerError)
    return
  }
  defer conn.Close()
  dgraphClient := dgo.NewDgraphClient(api.NewDgraphClient(conn))    
  ctx := context.Background()

  // Armar la búsqueda
  q := `
    query {
      data(func: has(date)) {
        buyers{
          id
          name
          age
        }
      }
    }
  `

  // Crear transacción
  txn := dgraphClient.NewTxn()
  defer txn.Discard(ctx)

  res, err := txn.Query(ctx, q)
  if err != nil {
    log.Fatal(err)
  }
  //fmt.Printf("%s\n", res.Json)

  var root Root
  err = json.Unmarshal(res.Json, &root)
  if err != nil {
    log.Fatal(err)
  }

  // Si se obtuvo información del id indicado
  buyers_list := make([]Buyer, 0)
  for _, item := range root.DataOfDate {
    for _, subitem := range item.Buyers {
      subitem.DType = []string{"Buyer"}
      buyers_list = append(buyers_list, subitem)
    }
  }
  //fmt.Println(buyers_list)

  // Resultado a retornar
  w.Header().Set("Content-Type", "application/json")
  //w.Write(res.Json)
  finalData, err := json.Marshal(buyers_list)
  if err != nil {
    log.Fatal(err)
  }
  w.Write(finalData)   
  
}

// Middleware para manejo de ids de compradores
func BuyerCtx(next http.Handler) http.Handler {
  return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
    ctx := context.WithValue(r.Context(), "id", chi.URLParam(r, "id"))
    next.ServeHTTP(w, r.WithContext(ctx))
  })
}

// Request Handler - GET /buyers/{id} - Read data from user by :id.
func (rs buyersResource) Get(w http.ResponseWriter, r *http.Request) {
  
  id := r.Context().Value("id").(string)
  fmt.Println("Capturando datos de comprador", id)

  // Estructura para decodificar datos recibidos
  type Root struct {
    BuyerData []Buyer `json:"buyer_data"`
    TransData []Transaction `json:"trans_data"`
    ProductData []Product `json:"prod_data"`
    OtherTransData []Transaction `json:"other_trans_data"`
    OtherBuyersData []Buyer `json:"other_buyers_data"`
    OtherProductsData []Product `json:"other_prod_data"`
  }

  //resp, err := http.Get("https://jsonplaceholder.typicode.com/posts/" + id)
    
  // Conexión a cliente Dgraph
  conn, err := grpc.Dial("localhost:9080", grpc.WithInsecure())
  if err != nil {
    log.Fatal(err)
    http.Error(w, err.Error(), http.StatusInternalServerError)
    return
  }
  defer conn.Close()
  dgraphClient := dgo.NewDgraphClient(api.NewDgraphClient(conn))    
  ctx := context.Background()

  // Armar la búsqueda
  variables1 := map[string]string{"$my_id": id}
    q1 := `
      query Query1($my_id: string){
        buyer_data(func: type(Buyer)) @filter(eq(id, $my_id)) {
          id
          name
          age
        }
        trans_data(func: type(Transaction)) @filter(eq(buyer_id, $my_id)) {
          id
          buyer_id
          ip_address
          device
          product_ids
        }
        other_prod_data(func: type(Product), first: 5) {
          id
          name
          price
        }
      }
    `

    // Crear transacción
    txn := dgraphClient.NewTxn()
    defer txn.Discard(ctx)

    res, err := txn.QueryWithVars(ctx, q1, variables1)
    if err != nil {
      log.Fatal(err)
    }
    //fmt.Printf("%s\n", res.Json)
  
    var root Root
    err = json.Unmarshal(res.Json, &root)
    if err != nil {
      log.Fatal(err)
    }

    // Si se obtuvo información del id indicado
    if len(root.BuyerData) > 0 && len(root.TransData) > 0 {
      buyer_products := make([]string, 0)
      for _, item := range root.TransData {		
        buyer_products = append(buyer_products, item.Product_ids...)
      }
      //fmt.Println(buyer_products)
      
      captured_ips := make([]string, 0)
      for _, item := range root.TransData {		
        captured_ips = append(captured_ips, item.Ip_address)
      }
      //fmt.Println(captured_ips)
      
      q2 := `
        query Query2($my_prod_ids: string, $my_ips: string, $my_id: string){
          prod_data(func: type(Product)) @filter(anyofterms(id, $my_prod_ids)) {
            id
            name
            price
          }
          other_trans_data(func: type(Transaction)) @filter(anyofterms(ip_address, $my_ips) AND not eq(buyer_id,$my_id)) {
            id
            buyer_id
            ip_address
            device
            product_ids
          }
        }
      `
      
      variables2 := map[string]string{"$my_prod_ids": strings.Join(buyer_products, " "),
        "$my_ips": strings.Join(captured_ips, " "), "$my_id": id}
      res2, err2 := txn.QueryWithVars(ctx, q2, variables2)
      if err2 != nil {
        log.Fatal(err2)
      }
      //fmt.Printf("%s\n", res2.Json)

      err = json.Unmarshal(res2.Json, &root)
      if err != nil {
        log.Fatal(err)
      }
      
      otherUsersInfo := make([]string, 0)
      for _, v := range root.OtherTransData {		
        otherUsersInfo = append(otherUsersInfo, v.Buyer_id)
      }
      //fmt.Println(otherUsersInfo)

      q3 := `
        query Query3($other_ids: string){
          other_buyers_data(func: type(Buyer)) @filter(anyofterms(id, $other_ids)) {
            id
            name
            age
          }
        }
      `
      variables3 := map[string]string{"$other_ids": strings.Join(otherUsersInfo, " ")}
      res3, err := txn.QueryWithVars(ctx, q3, variables3)
      if err != nil {
        log.Fatal(err)
      }
      //fmt.Printf("%s\n", res3.Json)

      err = json.Unmarshal(res3.Json, &root)
      if err != nil {
        log.Fatal(err)
      }

      //out, _ := json.MarshalIndent(root, "", "\t")
      //fmt.Printf("%s\n", out)
    }
    
    // Resultado a retornar
    w.Header().Set("Content-Type", "application/json")
    finalData, err := json.Marshal(root)
    if err != nil {
      log.Fatal(err)
    }
    w.Write(finalData)
}