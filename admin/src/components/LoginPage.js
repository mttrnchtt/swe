import React, { useState } from 'react';
import { useAuth } from '../AuthContext';
import { useNavigate } from 'react-router-dom';

const LoginPage = ({ setUser }) => {
    const [email, setEmail] = useState('');
    const [password, setPassword] = useState('');
    const { login } = useAuth();
    const navigate = useNavigate();

    const handleLogin = async (e) => {
        e.preventDefault();
        try {
            await fetch(`http://localhost:8000/auth/login/`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    email,
                    password
                })
            }).then((response) => {
                if (response && response.status === 200) {
                    response.json().then((data) => {
                        localStorage.setItem('refresh', JSON.stringify(data.tokens.refresh));
                        localStorage.setItem('access', JSON.stringify(data.tokens.access));
                        localStorage.setItem('user', data.email);
                        setUser(data.email);
                        login(data.tokens, data.email);
                        navigate('/accounts');
                    })
                }
                else {
                    alert("Нет");
                }
            })
        } catch (error) {
            console.error('Login failed:', error);
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
                        <label htmlFor="email" style={{
                            color: "#000",
                            textAlign: 'center',
                            fontFamily: 'Inter',
                            fontSize: '15px',
                        }}>email:</label>
                        <input
                            type="text"
                            id="email"
                            value={email}
                            onChange={(e) => setEmail(e.target.value)}
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
