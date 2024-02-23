import React, { useState, useEffect } from 'react';
import axios from 'axios';
import './App.css';

function App() {
  const [randomCard, setRandomCard] = useState(null);

  useEffect(() => {
    const fetchRandomCard = async () => {
      try {
        const response = await axios.get('http://localhost:8080/cards');
        const cards = response.data;

        const randomIndex = Math.floor(Math.random() * cards.length);

        setRandomCard(cards[randomIndex]);
      } catch (error) {
        console.error('Error fetching random card:', error);
      }
    };

    fetchRandomCard();
  }, []);

  return (
    <div className="App">
      <h1>Hello Tarot!</h1>
      {randomCard && (
        <div>
          <h2>Random Card</h2>
          <p>ID: {randomCard.id}</p>
          <p>Name: {randomCard.name}</p>
          <p>Arcana: {randomCard.arcana}</p>
          <p>Suit: {randomCard.suit}</p>
          <p>Rank: {randomCard.rank}</p>
          <img src={randomCard.image} alt={randomCard.name} />
        </div>
      )}
    </div>
  );
}

export default App;
