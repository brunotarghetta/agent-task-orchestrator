import { useEffect, useState } from 'react';

const TIME_ZONES = {
  central: 'America/Chicago',
  egypt: 'Africa/Cairo',
};

const formatTimeForZone = (date, timeZone) =>
  new Intl.DateTimeFormat('en-US', {
    timeZone,
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
  const [activeTimeZone, setActiveTimeZone] = useState(null);
  const [currentTime, setCurrentTime] = useState(() =>
    formatTimeForZone(new Date(), TIME_ZONES.central),
  );

  useEffect(() => {
    if (!activeTimeZone) {
      return undefined;
    }

    const updateCurrentTime = () => {
      setCurrentTime(formatTimeForZone(new Date(), activeTimeZone));
    };

    updateCurrentTime();
    const intervalId = window.setInterval(updateCurrentTime, 1000);

    return () => window.clearInterval(intervalId);
  }, [activeTimeZone]);

  const modalTitle =
    activeTimeZone === TIME_ZONES.egypt ? 'Hora actual en Egipto' : 'Hora actual en Central Time';
  const modalZoneLabel =
    activeTimeZone === TIME_ZONES.egypt ? 'Zona horaria: Africa/Cairo' : 'Zona horaria: America/Chicago';

  return (
    <main className="welcome-screen">
      <section className="welcome-card">
        <p className="eyebrow">Bienvenido</p>
        <h1>¡Tu proyecto React está listo!</h1>
        <p className="subtitle">
          Esta es una pantalla de bienvenida simple para empezar a construir tu app.
        </p>

        <div className="action-buttons">
          <button
            type="button"
            className="primary-button"
            onClick={() => setActiveTimeZone(TIME_ZONES.central)}
          >
            Ver hora actual
          </button>
          <button
            type="button"
            className="secondary-button"
            onClick={() => setActiveTimeZone(TIME_ZONES.egypt)}
          >
            Ver hora en Egipto
          </button>
        </div>
      </section>

      {activeTimeZone && (
        <div className="modal-backdrop" onClick={() => setActiveTimeZone(null)}>
          <div className="modal" onClick={(event) => event.stopPropagation()}>
            <div className="modal-header">
              <h2>{modalTitle}</h2>
              <button type="button" className="close-button" onClick={() => setActiveTimeZone(null)}>
                ×
              </button>
            </div>
            <p className="modal-time">{currentTime}</p>
            <p className="modal-note">{modalZoneLabel}</p>
          </div>
        </div>
      )}
    </main>
  );
}

export default App;
