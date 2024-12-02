import React, { useState } from 'react';

const SearchComponent = ({ placeholder = "Search...", onSearch }) => {
    const [query, setQuery] = useState('');

    const handleInputChange = (e) => {
        const value = e.target.value;
        setQuery(value);
        if (onSearch) {
            onSearch(value); // Call the callback with the current input
        }
    };

    return (
        <div style={{ margin: '10px 0', textAlign: 'center' }}>
            <input
                type="text"
                value={query}
                onChange={handleInputChange}
                placeholder={placeholder}
                style={{
                    display: 'flex',
                    alignSelf: 'self-start',
                    width: '30%',
                    padding: '10px',
                    border: '1px solid #ccc',
                    borderRadius: '4px',
                    fontSize: '16px',
                    marginLeft: '10px',
                }}
            />
        </div>
    );
};

export default SearchComponent;
