package main

import (
	"fmt"
	"log"
	"net/http"
)

func main() {
	//handle mux with this path = call handle when naigating to route
	http.HandleFunc("/", handle)
	log.Print("Listening on port 3001")
	//Listen and serve on port 3001, exit 1 if not
	log.Fatal(http.ListenAndServe(":3001", nil))
}

//returns response to request
func handle(w http.ResponseWriter, r *http.Request) {
	if r.URL.Path != "/" {
		http.NotFound(w, r)
		return
	}
	fmt.Fprint(w, "Hello world!")
}
