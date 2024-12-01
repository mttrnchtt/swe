CREATE TABLE IF NOT EXISTS items (
     id SERIAL PRIMARY KEY,
     category_id INT REFERENCES category(id) ON DELETE SET NULL,
     farm_id INT REFERENCES farms(id) ON DELETE CASCADE,
     name VARCHAR(255) NOT NULL,
     image TEXT,
     description TEXT,
     unit VARCHAR(50) NOT NULL,
     price NUMERIC(10, 2) NOT NULL,
     quantity INT NOT NULL,
     created_at TIMESTAMP DEFAULT NOW(),
     updated_at TIMESTAMP DEFAULT NOW()
);