import { useEffect, useState } from 'react';

const formatCentralTime = (date) =>
  new Intl.DateTimeFormat('en-US', {
    timeZone: 'America/Chicago',
    weekday: 'long',
    year: 'numeric',
    month: 'long',
    day: 'numeric',
    hour: 'numeric',
    minute: '2-digit',
    second: '2-digit',
    hour12: true,
  }).format(date);

function App() {
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [currentCentralTime, setCurrentCentralTime] = useState(() =>
    formatCentralTime(new Date()),
  );

  useEffect(() => {
    if (!isModalOpen) {
      return undefined;
    }

    const intervalId = window.setInterval(() => {
      setCurrentCentralTime(formatCentralTime(new Date()));
    }, 1000);

    return () => window.clearInterval(intervalId);
  }, [isModalOpen]);

  return (
    <main className="welcome-screen">
      <section className="welcome-card">
        <p className="eyebrow">Bienvenido</p>
        <h1>¡Tu proyecto React está listo!</h1>
        <p className="subtitle">
          Esta es una pantalla de bienvenida simple para empezar a construir tu app.
        </p>
        <button type="button" className="primary-button" onClick={() => setIsModalOpen(true)}>
          Ver hora actual
        </button>
      </section>

      {isModalOpen && (
        <div className="modal-backdrop" onClick={() => setIsModalOpen(false)}>
          <div className="modal" onClick={(event) => event.stopPropagation()}>
            <div className="modal-header">
              <h2>Hora actual en Central Time</h2>
              <button type="button" className="close-button" onClick={() => setIsModalOpen(false)}>
                ×
              </button>
            </div>
            <p className="modal-time">{currentCentralTime}</p>
            <p className="modal-note">Zona horaria: America/Chicago</p>
          </div>
        </div>
      )}
    </main>
  );
}

export default App;
