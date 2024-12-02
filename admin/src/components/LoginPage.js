import React, { useState } from 'react';
import { useAuth } from '../AuthContext';
import { useNavigate } from 'react-router-dom';

const LoginPage = () => {
    const [username, setUsername] = useState('');
    const [password, setPassword] = useState('');
    const { login } = useAuth();
    const navigate = useNavigate();

    const handleLogin = (e) => {
        e.preventDefault();
        // Example: Simple validation or authentication logic
        if (username === 'admin' && password === 'password') {
            login();
            navigate('/accounts');
        } else {
            alert('Invalid username or password!');
        }
    };

    return (
        <div className='loginWrapper'>
            <h1 style={{ marginTop: "100px" }}>Farmer Market System</h1>
            <div style={{
                display: 'flex',
                flexDirection: 'column',
                alignItems: 'center',
                width: '520px',
                height: 'auto',
                marginTop: '150px',
                padding: '40px',
                gap: "50px",
                borderRadius: "15px",
                background: "#FFF",
                boxShadow: "0px 4px 20px 0px rgba(0, 0, 0, 0.10)",
            }}>
                <h1 style={{
                    color: "#000",
                    textAlign: 'center',
                    fontFamily: 'Inter',
                }}>Welcome!</h1>
                <form
                    onSubmit={handleLogin}
                    style={{
                        display: 'flex',
                        flexDirection: 'column',
                        width: '300px',
                        gap: '17px',
                    }}
                >
                    <div>
                        <label htmlFor="username" style={{
                            color: "#000",
                            textAlign: 'center',
                            fontFamily: 'Inter',
                            fontSize: '15px',
                        }}>Username:</label>
                        <input
                            type="text"
                            id="username"
                            value={username}
                            onChange={(e) => setUsername(e.target.value)}
                            required
                            style={{ width: '100%', padding: '8px', marginTop: '5px', borderRadius: '5px', background: '#F6F6F6' }}
                        />
                    </div>
                    <div>
                        <label htmlFor="password" style={{
                            color: "#000",
                            textAlign: 'center',
                            fontFamily: 'Inter',
                            fontSize: '15px',
                        }}>Password:</label>
                        <input
                            type="password"
                            id="password"
                            value={password}
                            onChange={(e) => setPassword(e.target.value)}
                            required
                            style={{ width: '100%', padding: '8px', marginTop: '5px', borderRadius: '5px', background: '#F6F6F6' }}
                        />
                    </div>
                    <button
                        type="submit"
                        style={{
                            width: '320px',
                            height: '40px',
                            padding: '10px 0px',
                            background: '#2CB56C',
                            color: 'white',
                            border: 'none',
                            cursor: 'pointer',
                            marginTop: '10px',
                            borderRadius: '5px',
                        }}
                    >
                        Continue
                    </button>
                </form>
            </div>
        </div >
    );
};

export default LoginPage;
