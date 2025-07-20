import React, { useState } from 'react';
import { db } from './firebase';
import { collection, addDoc } from "firebase/firestore";

function AddTask({ user, sleepData }) {
  const [taskName, setTaskName] = useState('');
  const [scheduleTime, setScheduleTime] = useState(0);

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (taskName.trim() !== '') {
      let scheduledDate = null;
      if (sleepData && scheduleTime > 0) {
        scheduledDate = new Date(sleepData.endDate.seconds * 1000);
        scheduledDate.setMinutes(scheduledDate.getMinutes() + scheduleTime);
      }

      await addDoc(collection(db, "tasks"), {
        name: taskName,
        completed: false,
        userId: user.uid,
        scheduledDate: scheduledDate
      });
      setTaskName('');
      setScheduleTime(0);
    }
  };

  return (
    <form onSubmit={handleSubmit}>
      <input
        type="text"
        value={taskName}
        onChange={(e) => setTaskName(e.target.value)}
        placeholder="New Task"
      />
      {sleepData && (
        <div>
          <label>Schedule {scheduleTime} minutes after waking up</label>
          <input
            type="range"
            min="0"
            max="120"
            step="5"
            value={scheduleTime}
            onChange={(e) => setScheduleTime(parseInt(e.target.value))}
          />
        </div>
      )}
      <button type="submit">Add Task</button>
    </form>
  );
}

export default AddTask;
