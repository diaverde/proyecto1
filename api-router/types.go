package main

import (
	"time"
)

// Definición de los tipos a usar
type DateData struct {
	Date       		time.Time  	 	`json:"date,omitempty"`
	Buyers    		[]Buyer     	`json:"buyers,omitempty"`
	Products 		[]Product  		`json:"products,omitempty"`
	Transactions 	[]Transaction  	`json:"transactions,omitempty"`
	DType    		[]string  		`json:"dgraph.type,omitempty"`	
}
type Transaction struct {
	Id       	string      `json:"id,omitempty"`
	Buyer_id   	string      `json:"buyer_id,omitempty"`
	Ip_address  string  	`json:"ip_address,omitempty"`
	Device		string      `json:"device,omitempty"`
	Product_ids	[]string  	`json:"product_ids,omitempty"`
	DType    	[]string 	`json:"dgraph.type,omitempty"`	
}
type Buyer struct {
	Id       	string     `json:"id,omitempty"`
	Name     	string     `json:"name,omitempty"`
	Age    	 	int        `json:"age,omitempty"`
	DType    	[]string   `json:"dgraph.type,omitempty"`	
}
type Product struct {
	Id       string     `json:"id,omitempty"`
	Name     string     `json:"name,omitempty"`
	Price    float32    `json:"price,omitempty"`
	DType	 []string	`json:"dgraph.type,omitempty"`	
}