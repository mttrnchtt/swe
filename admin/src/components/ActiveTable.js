import React, { useState, useEffect } from 'react';

const ActiveTable = () => {
    const [farmers, setFarmers] = useState([]);
    const [loading, setLoading] = useState(true);

    // Fetch farmers data from the backend
    useEffect(() => {
        const fetchFarmers = async () => {
            try {
                const response = await fetch('https://example.com/api/farmers'); // Replace with your backend URL
                const data = await response.json();
                setFarmers(data);
            } catch (error) {
                console.error('Error fetching farmers:', error);
            } finally {
                setLoading(false);
            }
        };

        // fetchFarmers();
        setFarmers([
            {
                id: 1,
                photo: "aboba",
                name: 'Farmer 1',
                farmSize: 200,
                location: "Astana",
                email: "farmer1@gmail.com",
                phone: "87007007000"
            },
            {
                id: 2,
                photo: "aboba",
                name: 'Farmer 2',
                farmSize: 200,
                location: "Astana",
                email: "farmer1@gmail.com",
                phone: "87007007000"
            },
            {
                id: 3,
                photo: "aboba",
                name: 'Farmer 4',
                farmSize: 200,
                location: "Astana",
                email: "farmer1@gmail.com",
                phone: "87007007000"
            },
            {
                id: 4,
                photo: "aboba",
                name: 'Farmer 4',
                farmSize: 200,
                location: "Astana",
                email: "farmer1@gmail.com",
                phone: "87007007000"
            }
        ])
    }, []);



    // if (loading) {
    //   return <p>Loading farmers...</p>;
    // }

    return (
        <div style={{ padding: '20px' }}>
            <table
                style={{
                    width: '100%',
                    borderCollapse: 'collapse',
                    margin: '20px 0',
                    fontSize: '16px',
                    textAlign: 'left',
                }}
            >
                <thead>
                    <tr>
                        <th style={{ padding: '10px', borderBottom: '2px solid #ddd' }}>Photo preview</th>
                        <th style={{ padding: '10px', borderBottom: '2px solid #ddd' }}>Name</th>
                        <th style={{ padding: '10px', borderBottom: '2px solid #ddd' }}>Farm size</th>
                        <th style={{ padding: '10px', borderBottom: '2px solid #ddd' }}>Farm location</th>
                        <th style={{ padding: '10px', borderBottom: '2px solid #ddd' }}>Email</th>
                        <th style={{ padding: '10px', borderBottom: '2px solid #ddd' }}>Phone number</th>
                        <th style={{ padding: '10px', borderBottom: '2px solid #ddd' }}>Action</th>
                    </tr>
                </thead>
                <tbody>
                    {farmers.map((farmer) => (
                        <tr key={farmer.id}>
                            <td style={{ padding: '10px', borderBottom: '1px solid #ddd' }}>
                                <img
                                    src={farmer.photo}
                                    alt={farmer.name}
                                    style={{ width: '50px', height: '50px', borderRadius: '50%' }}
                                />
                            </td>
                            <td style={{ padding: '10px', borderBottom: '1px solid #ddd' }}>{farmer.name}</td>
                            <td style={{ padding: '10px', borderBottom: '1px solid #ddd' }}>{farmer.farmSize}</td>
                            <td style={{ padding: '10px', borderBottom: '1px solid #ddd' }}>{farmer.location}</td>
                            <td style={{ padding: '10px', borderBottom: '1px solid #ddd' }}>{farmer.email}</td>
                            <td style={{ padding: '10px', borderBottom: '1px solid #ddd' }}>{farmer.phone}</td>
                            <td style={{ padding: '10px', borderBottom: '1px solid #ddd' }}>
                                <button
                                    style={{
                                        padding: '5px 10px',
                                        backgroundColor: '#28a745',
                                        color: 'white',
                                        border: 'none',
                                        borderRadius: '5px',
                                        cursor: 'pointer',
                                    }}
                                >
                                    View
                                </button>
                            </td>
                        </tr>
                    ))}
                </tbody>
            </table>
        </div>
    );
};

export default ActiveTable;
