package main

import "net/http"

func greetHandle(w http.ResponseWriter, r *http.Request) {
	return "hi guys"
}

func main() {

}
