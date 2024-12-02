import React, { useState, useEffect } from 'react';

const PendingTable = ({ users, setActive }) => {
  const accessToken = localStorage.getItem('access');

  let pending = users.filter((user) =>
    user.role === 'farmer' && user.is_verified === false
  );

  const approveAcc = async (farmer) => {
    try {
      await fetch(`http://localhost:8000/auth/admin/approve-farmer/`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json', 'Authorization': 'Bearer ' + accessToken },
        body: JSON.stringify({
          "email": farmer.email
        })
      }).then((response) => {
        if (response && response.status === 200) {
          console.log('success');
          pending = users.filter((user) =>
            user.role === 'farmer' && user.is_verified === false
          );
          setActive('pending')
        }
      })
    } catch (error) {
      console.error('Error fetching farmers:', error);
    }
  }

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
            <th style={{ padding: '10px', borderBottom: '2px solid #ddd' }}>Username</th>
            <th style={{ padding: '10px', borderBottom: '2px solid #ddd' }}>Farm size</th>
            <th style={{ padding: '10px', borderBottom: '2px solid #ddd' }}>Farm location</th>
            <th style={{ padding: '10px', borderBottom: '2px solid #ddd' }}>Email</th>
            <th style={{ padding: '10px', borderBottom: '2px solid #ddd' }}>Phone number</th>
            <th style={{ padding: '10px', borderBottom: '2px solid #ddd' }}>Action</th>
          </tr>
        </thead>
        <tbody>
          {pending.map((farmer) => (
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
                <button
                  style={{
                    padding: '5px 10px',
                    backgroundColor: '#28a745',
                    color: 'white',
                    border: 'none',
                    borderRadius: '5px',
                    cursor: 'pointer',
                  }}
                  onClick={() => approveAcc(farmer)}
                >
                  Approve
                </button>
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
};

export default PendingTable;
