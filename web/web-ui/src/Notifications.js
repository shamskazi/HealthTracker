import React, { useEffect } from 'react';

function Notifications({ tasks }) {
  useEffect(() => {
    if ('Notification' in window) {
      Notification.requestPermission();
    }
  }, []);

  useEffect(() => {
    tasks.forEach(task => {
      if (task.scheduledDate && !task.completed) {
        const scheduledTime = new Date(task.scheduledDate.seconds * 1000).getTime();
        const now = new Date().getTime();
        const delay = scheduledTime - now;

        if (delay > 0) {
          setTimeout(() => {
            new Notification('Health Tracker', {
              body: task.name,
            });
          }, delay);
        }
      }
    });
  }, [tasks]);

  return null;
}

export default Notifications;
