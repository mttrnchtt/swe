import { set } from 'date-fns';
import React, { useState, useEffect } from 'react';

const ActiveTable = ({ users, active, setActive }) => {
    const accessToken = localStorage.getItem('access');

    let farmers = users.filter((user) =>
        user.role === 'farmer' && user.is_active === active
    );

    let buyers = users.filter((user) =>
        user.role === 'buyer' && user.is_active === active
    );

    const disableAcc = async (farmer) => {
        try {
            await fetch(`http://localhost:8000/auth/admin/users/${farmer.id}/`, {
                method: 'PUT',
                headers: { 'Content-Type': 'application/json', 'Authorization': 'Bearer ' + accessToken },
                body: JSON.stringify({
                    "username": farmer.username,
                    "role": farmer.role,
                    "is_active": false,
                    "is_verified": farmer.is_verified,
                    "phone_number": farmer.phone_number,
                    "address": farmer.address
                })
            }).then((response) => {
                if (response && response.status === 200) {
                    console.log('success');
                    farmers = users.filter((user) =>
                        user.role === 'farmer' && user.is_active === active
                    );

                    buyers = users.filter((user) =>
                        user.role === 'buyer' && user.is_active === active
                    );

                    setActive('disabled');
                }
            })
        } catch (error) {
            console.error('Error fetching farmers:', error);
        }
    }

    const restoreAcc = async (farmer) => {
        try {
            await fetch(`http://localhost:8000/auth/admin/users/${farmer.id}/`, {
                method: 'PUT',
                headers: { 'Content-Type': 'application/json', 'Authorization': 'Bearer ' + accessToken },
                body: JSON.stringify({
                    "username": farmer.username,
                    "role": farmer.role,
                    "is_active": true,
                    "is_verified": farmer.is_verified,
                    "phone_number": farmer.phone_number,
                    "address": farmer.address
                })
            }).then((response) => {
                if (response && response.status === 200) {
                    console.log('success');
                    farmers = users.filter((user) =>
                        user.role === 'farmer' && user.is_active === active
                    );

                    buyers = users.filter((user) =>
                        user.role === 'buyer' && user.is_active === active
                    );

                    setActive('active')
                }
            })
        } catch (error) {
            console.error('Error fetching farmers:', error);
        }
    }

    return (
        <div style={{ padding: '20px' }}>
            <h1>Farmers</h1>
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
                        <th style={{ padding: '10px', borderBottom: '2px solid #ddd' }}>Username</th>
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
                            <td style={{ padding: '10px', borderBottom: '1px solid #ddd' }}>{farmer.username}</td>
                            <td style={{ padding: '10px', borderBottom: '1px solid #ddd' }}>{farmer.farmSize}</td>
                            <td style={{ padding: '10px', borderBottom: '1px solid #ddd' }}>{farmer.location}</td>
                            <td style={{ padding: '10px', borderBottom: '1px solid #ddd' }}>{farmer.email}</td>
                            <td style={{ padding: '10px', borderBottom: '1px solid #ddd' }}>{farmer.phone_number}</td>
                            <td style={{ padding: '10px', borderBottom: '1px solid #ddd' }}>
                                {active ? (
                                    <>
                                        <button
                                            style={{
                                                padding: '5px 10px',
                                                backgroundColor: '#28a745',
                                                color: 'white',
                                                border: 'none',
                                                borderRadius: '5px',
                                                cursor: 'pointer',
                                            }}
                                            onClick={() => disableAcc(farmer)}
                                        >
                                            Disable
                                        </button>
                                        {/* <button
                                            style={{
                                                padding: '5px 10px',
                                                backgroundColor: '#28a745',
                                                color: 'white',
                                                border: 'none',
                                                borderRadius: '5px',
                                                cursor: 'pointer',
                                            }}
                                            onClick={editAcc}
                                        >
                                            Edit
                                        </button> */}
                                    </>
                                ) : (
                                    <button
                                        style={{
                                            padding: '5px 10px',
                                            backgroundColor: '#28a745',
                                            color: 'white',
                                            border: 'none',
                                            borderRadius: '5px',
                                            cursor: 'pointer',
                                        }}
                                        onClick={() => restoreAcc(farmer)}
                                    >
                                        Restore
                                    </button>
                                )}
                            </td>
                        </tr>
                    ))}
                </tbody>
            </table>

            <h1>Buyers</h1>
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
                        <th style={{ padding: '10px', borderBottom: '2px solid #ddd' }}>Username</th>
                        <th style={{ padding: '10px', borderBottom: '2px solid #ddd' }}>Farm size</th>
                        <th style={{ padding: '10px', borderBottom: '2px solid #ddd' }}>Farm location</th>
                        <th style={{ padding: '10px', borderBottom: '2px solid #ddd' }}>Email</th>
                        <th style={{ padding: '10px', borderBottom: '2px solid #ddd' }}>Phone number</th>
                        <th style={{ padding: '10px', borderBottom: '2px solid #ddd' }}>Action</th>
                    </tr>
                </thead>
                <tbody>
                    {buyers.map((farmer) => (
                        <tr key={farmer.id}>
                            <td style={{ padding: '10px', borderBottom: '1px solid #ddd' }}>
                                <img
                                    src={farmer.photo}
                                    alt={farmer.name}
                                    style={{ width: '50px', height: '50px', borderRadius: '50%' }}
                                />
                            </td>
                            <td style={{ padding: '10px', borderBottom: '1px solid #ddd' }}>{farmer.username}</td>
                            <td style={{ padding: '10px', borderBottom: '1px solid #ddd' }}>{farmer.farmSize}</td>
                            <td style={{ padding: '10px', borderBottom: '1px solid #ddd' }}>{farmer.location}</td>
                            <td style={{ padding: '10px', borderBottom: '1px solid #ddd' }}>{farmer.email}</td>
                            <td style={{ padding: '10px', borderBottom: '1px solid #ddd' }}>{farmer.phone_number}</td>
                            <td style={{ padding: '10px', borderBottom: '1px solid #ddd' }}>
                                {active ? (
                                    <>
                                        <button
                                            style={{
                                                padding: '5px 10px',
                                                backgroundColor: '#28a745',
                                                color: 'white',
                                                border: 'none',
                                                borderRadius: '5px',
                                                cursor: 'pointer',
                                            }}
                                            onClick={() => disableAcc(farmer)}
                                        >
                                            Disable
                                        </button>
                                        {/* <button
                                            style={{
                                                padding: '5px 10px',
                                                backgroundColor: '#28a745',
                                                color: 'white',
                                                border: 'none',
                                                borderRadius: '5px',
                                                cursor: 'pointer',
                                            }}
                                            onClick={editAcc}
                                        >
                                            Edit
                                        </button> */}
                                    </>
                                ) : (
                                    <button
                                        style={{
                                            padding: '5px 10px',
                                            backgroundColor: '#28a745',
                                            color: 'white',
                                            border: 'none',
                                            borderRadius: '5px',
                                            cursor: 'pointer',
                                        }}
                                        onClick={() => restoreAcc(farmer)}
                                    >
                                        Restore
                                    </button>
                                )}
                            </td>
                        </tr>
                    ))}
                </tbody>
            </table>
        </div>
    );
};

export default ActiveTable;
