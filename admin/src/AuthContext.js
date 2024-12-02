import React, { createContext, useState, useContext, useEffect } from 'react';

const AuthContext = createContext();

export const AuthProvider = ({ children }) => {
    const [user, setUser] = useState(null);

    useEffect(() => {
        const accessToken = localStorage.getItem('access');
        const refreshToken = localStorage.getItem('refresh');

        if (accessToken) {
            // Verify token validity (optional: add an API call to verify token)
            setUser(localStorage.getItem('user')); // Use saved user data
        } else if (refreshToken) {
            // Refresh access token using refreshToken if possible
            setUser(localStorage.getItem('user')); // Use saved user data
            console.log("Хз как рефрешить");
        }
    }, []);

    const login = async (tokens, email) => {
        console.log(tokens.access)
        localStorage.setItem('access', tokens.access);
        localStorage.setItem('refresh', tokens.refresh);
        localStorage.setItem('user', email);
        setUser(email);
    };

    const logout = () => {
        localStorage.removeItem('access');
        localStorage.removeItem('refresh');
        localStorage.removeItem('user');
        setUser(null);
    };

    return (
        <AuthContext.Provider value={{ user, login, logout }}>
            {children}
        </AuthContext.Provider>
    );
};

export const useAuth = () => useContext(AuthContext);
