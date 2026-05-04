import React from 'react';
import { useQuery } from '@tanstack/react-query';
import { useAuthStore } from '../store/authStore';

const fetchClients = async (token) => {
  const res = await fetch('http://localhost:5000/api/clients', {
    headers: { Authorization: `Bearer ${token}` }
  });
  if (!res.ok) throw new Error('Failed');
  return res.json();
};

const Clients = () => {
  const { token } = useAuthStore();
  const { data: clients, isLoading } = useQuery({
    queryKey: ['clients'],
    queryFn: () => fetchClients(token),
  });

  if (isLoading) return <div>Loading clients...</div>;

  return (
    <div className="p-6">
      <h1 className="text-2xl font-bold mb-6">Clients ({clients?.length || 0})</h1>
      <div className="grid gap-4">
        {clients?.map(client => (
          <div key={client.id} className="border p-4 rounded-lg shadow">
            <h3>{client.full_name}</h3>
            <p>NRC: {client.nrc_number}</p>
            <p>Phone: {client.phone}</p>
          </div>
        ))}
      </div>
    </div>
  );
};

export default Clients;

