CREATE TABLE IF NOT EXISTS farms (
     id SERIAL PRIMARY KEY,
     farmer_id UUID NOT NULL,
     farm_name VARCHAR(255) NOT NULL,
     farm_size FLOAT NOT NULL,
     address TEXT NOT NULL,
     created_at TIMESTAMP DEFAULT NOW(),
     updated_at TIMESTAMP DEFAULT NOW()
);