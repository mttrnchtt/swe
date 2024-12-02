CREATE TABLE chats (
   id SERIAL PRIMARY KEY,
   buyer_id UUID NOT NULL,
   farmer_id UUID NOT NULL,
   created_at TIMESTAMP DEFAULT NOW(),
   last_message TEXT,
   last_message_time TIMESTAMP DEFAULT NOW()
);