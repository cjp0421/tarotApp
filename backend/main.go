package main

import (
	"encoding/json"
	"fmt"
	"net/http"

	"github.com/gorilla/mux"
	"github.com/rs/cors"
)

// Card represents a tarot card
type Card struct {
	ID       string `json:"id"`
	Name     string `json:"name"`
	Arcana   string `json:"arcana"`
	Suit     string `json:"suit"`
	Rank     string `json:"rank"`
	KeyWords string `json:"keyWords"`
	Image    string `json:"image"`
}

func getAllCards(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(Cards)
}

func getCardByID(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	params := mux.Vars(r)
	cardID := params["cardId"]

	for _, card := range Cards {
		if card.ID == cardID {
			json.NewEncoder(w).Encode(card)
			return
		}
	}

	w.WriteHeader(http.StatusNotFound)
	fmt.Fprintf(w, "Card with ID %s not found", cardID)
}

func getMajorArcana(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	majorArcana := filterCardsByArcana("Major Arcana")
	json.NewEncoder(w).Encode(majorArcana)
}

func getMinorArcana(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	minorArcana := filterCardsByArcana("Minor Arcana")
	json.NewEncoder(w).Encode(minorArcana)
}

func getMinorArcanaBySuit(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	params := mux.Vars(r)
	suit := params["suit"]

	minorArcana := filterCardsBySuit(suit)
	json.NewEncoder(w).Encode(minorArcana)
}

func filterCardsByArcana(arcana string) []Card {
	var filteredCards []Card
	for _, card := range Cards {
		if card.Arcana == arcana {
			filteredCards = append(filteredCards, card)
		}
	}
	return filteredCards
}

func filterCardsBySuit(suit string) []Card {
	var filteredCards []Card
	for _, card := range Cards {
		if card.Suit == suit {
			filteredCards = append(filteredCards, card)
		}
	}
	return filteredCards
}

func main() {
	r := mux.NewRouter()

	r.HandleFunc("/cards", getAllCards).Methods("GET")
	r.HandleFunc("/cards/{cardId}", getCardByID).Methods("GET")
	r.HandleFunc("/majorArcana", getMajorArcana).Methods("GET")
	r.HandleFunc("/minorArcana", getMinorArcana).Methods("GET")
	r.HandleFunc("/minorArcana/{suit}", getMinorArcanaBySuit).Methods("GET")

	c := cors.New(cors.Options{
		AllowedOrigins: []string{"*"}, // Update this based on your requirements
		AllowedMethods: []string{"GET", "OPTIONS"},
	})

	// Use the CORS handler
	handler := c.Handler(r)

	port := ":8080"
	fmt.Printf("Server listening on port %s\n", port)
	http.ListenAndServe(port, handler)
}
