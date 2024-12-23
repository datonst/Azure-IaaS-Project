package main

import "net/http"

func greetHandle(w http.ResponseWriter, r *http.Request) {
	w.Write([]byte("hi guys"))
}

func main() {

}
