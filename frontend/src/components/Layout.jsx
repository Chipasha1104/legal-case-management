import React from 'react';
import { Outlet, Link, useNavigate } from 'react-router-dom';
import { useAuthStore } from '../store/authStore';
import { LogOut, Users, FileText, AlertCircle } from 'lucide-react';

const Layout = () => {
  const { user, logout } = useAuthStore();
  const navigate = useNavigate();

  const handleLogout = () => {
    logout();
    navigate('/login');
  };

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <header className="bg-white shadow-sm border-b">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between items-center h-16">
            <Link to="/dashboard" className="flex items-center space-x-2">
              <AlertCircle className="h-8 w-8 text-primary-600" />
              <h1 className="text-2xl font-bold bg-gradient-to-r from-primary-600 to-primary-700 bg-clip-text text-transparent">
                Legal Department
              </h1>
            </Link>
            <div className="flex items-center space-x-4">
              <span className="text-sm text-gray-700">Welcome, {user?.username || user?.role}</span>
              <button
                onClick={handleLogout}
                className="flex items-center space-x-2 px-4 py-2 text-sm font-medium text-gray-700 hover:text-primary-600 transition-colors"
              >
                <LogOut className="h-4 w-4" />
                <span>Logout</span>
              </button>
            </div>
          </div>
        </div>
      </header>

      {/* Sidebar + Main */}
      <div className="flex">
        <aside className="w-64 bg-white border-r shadow-sm">
          <nav className="p-6 space-y-2">
            <Link
              to="/dashboard"
              className="flex items-center space-x-3 px-4 py-3 rounded-xl text-gray-700 hover:bg-primary-50 hover:text-primary-600 transition-all"
            >
              <div className="w-8 h-8 bg-primary-100 rounded-lg flex items-center justify-center">
                📊
              </div>
              <span className="font-medium">Dashboard</span>
            </Link>
            <Link
              to="/clients"
              className="flex items-center space-x-3 px-4 py-3 rounded-xl text-gray-700 hover:bg-primary-50 hover:text-primary-600 transition-all"
            >
              <Users className="h-5 w-5" />
              <span className="font-medium">Clients</span>
            </Link>
            <Link
              to="/cases"
              className="flex items-center space-x-3 px-4 py-3 rounded-xl text-gray-700 hover:bg-primary-50 hover:text-primary-600 transition-all"
            >
              <FileText className="h-5 w-5" />
              <span className="font-medium">Cases</span>
            </Link>
            <Link
              to="/arrears"
              className="flex items-center space-x-3 px-4 py-3 rounded-xl text-gray-700 hover:bg-primary-50 hover:text-primary-600 transition-all"
            >
              <AlertCircle className="h-5 w-5" />
              <span className="font-medium">Arrears</span>
            </Link>
          </nav>
        </aside>
        <main className="flex-1 p-8">
          <Outlet />
        </main>
      </div>
    </div>
  );
};

export default Layout;

