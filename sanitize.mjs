#!/usr/bin/env node

import fs from 'fs/promises';

const inputString = await fs.readFile('/Users/martinjaniczek/Downloads/nice.json');
let json = JSON.parse(inputString);
json.players.forEach(player => {
    if (player.data?.messages) {
      player.data.messages = [];
    }
  }
)
const outputString = JSON.stringify(json);
console.log(outputString);
