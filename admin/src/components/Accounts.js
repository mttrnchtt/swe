import React, { useState, useEffect, act } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '../AuthContext';
import ActiveTable from './ActiveTable';
import PendingTable from './PendingTable';
import SearchComponent from './SearchComponent';

const Accounts = () => {
    const { logout } = useAuth();
    const [users, setUsers] = useState([]);
    // const [pending, setPending] = useState([]);
    const [active, setActive] = useState('pending');
    const [searchQuery, setSearchQuery] = useState('');
    const navigate = useNavigate();

    // Fetch farmers data from the backend
    useEffect(() => {
        const fetchFarmers = async () => {
            try {
                const accessToken = localStorage.getItem('access');

                await fetch('http://localhost:8000/auth/admin/users/', {
                    method: 'GET',
                    headers: { 'Content-Type': 'application/json', 'Authorization': 'Bearer ' + accessToken }
                }).then((response) => {
                    if (response && response.status === 200) {
                        response.json().then((data) => {
                            console.log(data);
                            setUsers(data);
                        })
                    }
                })
            } catch (error) {
                console.error('Error fetching farmers:', error);
            }
        };

        fetchFarmers();
        // setFarmers([
        //     {
        //         id: 1,
        //         photo: "aboba",
        //         name: 'Farmer 1',
        //         farmSize: 200,
        //         location: "Astana",
        //         email: "farmer1@gmail.com",
        //         phone: "87007007000"
        //     },
        //     {
        //         id: 2,
        //         photo: "aboba",
        //         name: 'Farmer 2',
        //         farmSize: 200,
        //         location: "Astana",
        //         email: "farmer1@gmail.com",
        //         phone: "87007007000"
        //     },
        //     {
        //         id: 3,
        //         photo: "aboba",
        //         name: 'Farmer 4',
        //         farmSize: 200,
        //         location: "Astana",
        //         email: "farmer1@gmail.com",
        //         phone: "87007007000"
        //     },
        //     {
        //         id: 4,
        //         photo: "aboba",
        //         name: 'Farmer 4',
        //         farmSize: 200,
        //         location: "Astana",
        //         email: "farmer1@gmail.com",
        //         phone: "87007007000"
        //     }
        // ])
    }, [active]);

    const handleLogout = () => {
        logout();
        navigate('/login');
    };

    // const filteredFarmers = farmers.filter((farmer) =>
    //     farmer.toLowerCase().includes(searchQuery.toLowerCase())
    // );

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
        {active === 'pending' && <PendingTable users={users} setActive={setActive} />}
        {active === 'active' && <ActiveTable users={users} active={true} setActive={setActive} />}
        {active === 'disabled' && <ActiveTable users={users} active={false} setActive={setActive} />}
    </div>;
};

export default Accounts;
