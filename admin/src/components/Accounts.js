import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '../AuthContext';
import PendingTable from './PendingTable';
import SearchComponent from './SearchComponent';

const Accounts = () => {
    const { logout } = useAuth();
    const [active, setActive] = useState('pending');
    const [searchQuery, setSearchQuery] = useState('');
    const navigate = useNavigate();

    const handleLogout = () => {
        logout();
        navigate('/login');
    };

    const farmers = [
        'Alice Johnson',
        'Bob Smith',
        'Charlie Brown',
        'Daisy Miller',
        'Evelyn Harper',
    ];

    const filteredFarmers = farmers.filter((farmer) =>
        farmer.toLowerCase().includes(searchQuery.toLowerCase())
    );

    return <div>
        <h1>Accounts</h1>
        <div style={{
            marginTop: "24px",
            display: "flex",
            flexDirection: "row",
        }}>
            <h2 className={active === 'pending' ? 'active' : ''} onClick={() => setActive('pending')}>Pending farmers</h2>
            <h2 className={active === 'active' ? 'active' : ''} onClick={() => setActive('active')}>Active users</h2>
            <h2 className={active === 'disabled' ? 'active' : ''} onClick={() => setActive('disabled')}>Disabled accounts</h2>
            <h2 onClick={handleLogout}>Log out</h2>
        </div>
        <SearchComponent
            placeholder="Search farmers..."
            onSearch={(query) => setSearchQuery(query)}
        />
        <PendingTable />
    </div>;
};

export default Accounts;
