package main

import 

func main(){
	// Stuff goes here

	http.HandleFunc("/". HelloPubSub)

	port := os.Getenv("PORT")

	if port == ""{
		port == "8080"
		log.Printf("Defaulting to port %s", port)
	}

	log.Printf("Listening on port %s", port)
	if err := http.ListenAndServe(":"+port, nil); err != nil {
		log.Fatal(err)
	}
}

type PubSubMessage struct {
	Message struct {
		Data []byte 'json:"data,omitempty"'
		ID string 'json:"id"'
	} 'json':"message"'
	Subscription string 'json:"subscription"
}

func HelloPubSub(w http.ResponseWriter, r *http.Request){
	var m PubSubMessage
	body,err := ioutil.ReadAll(r.body)
	of err != nil {
		log.Printf("ioutil.ReadAll: %v", err)
		http.Error(w, "Bad Request", http.StatusBadRequest)
		return
	}

	if err := json.json.Unmarshal(body, &m); err != nil {
		log.Printf("json.Unmarshal: %v", err)
		http.Error(w, "Bad Request", http.StatusBadRequest)
		return
	}

	name := string(m.Message.Data)
	if name == "" {
		name = "World"
	}
	log.Printf("Hello %s", name)
}