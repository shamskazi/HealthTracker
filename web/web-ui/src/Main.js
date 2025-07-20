import React, { useState, useEffect } from 'react';
import { auth, db } from './firebase';
import { signOut } from "firebase/auth";
import { collection, query, where, onSnapshot, doc, updateDoc, deleteDoc, orderBy, limit } from "firebase/firestore";
import AddTask from './AddTask';
import Notifications from './Notifications';

function Main({ user }) {
  const [tasks, setTasks] = useState([]);
  const [sleepData, setSleepData] = useState(null);

  useEffect(() => {
    const tasksQuery = query(collection(db, "tasks"), where("userId", "==", user.uid));
    const tasksUnsubscribe = onSnapshot(tasksQuery, (querySnapshot) => {
      const tasks = [];
      querySnapshot.forEach((doc) => {
        tasks.push({ id: doc.id, ...doc.data() });
      });
      setTasks(tasks);
    });

    const sleepQuery = query(collection(db, "sleepData"), where("userId", "==", user.uid), orderBy("endDate", "desc"), limit(1));
    const sleepUnsubscribe = onSnapshot(sleepQuery, (querySnapshot) => {
      if (!querySnapshot.empty) {
        setSleepData(querySnapshot.docs[0].data());
      }
    });

    return () => {
      tasksUnsubscribe();
      sleepUnsubscribe();
    };
  }, [user.uid]);

  const handleSignOut = () => {
    signOut(auth);
  };

  const toggleComplete = async (task) => {
    const taskRef = doc(db, "tasks", task.id);
    await updateDoc(taskRef, {
      completed: !task.completed
    });
  };

  const deleteTask = async (taskId) => {
    const taskRef = doc(db, "tasks", taskId);
    await deleteDoc(taskRef);
  };

  return (
    <div>
      <Notifications tasks={tasks} />
      <h1>Welcome, {user.email}</h1>
      <button onClick={handleSignOut}>Sign Out</button>
      {sleepData && (
        <div>
          <h2>Last Sleep Session</h2>
          <p>Start: {new Date(sleepData.startDate.seconds * 1000).toLocaleString()}</p>
          <p>End: {new Date(sleepData.endDate.seconds * 1000).toLocaleString()}</p>
        </div>
      )}
      <AddTask user={user} sleepData={sleepData} />
      <ul>
        {tasks.map((task) => (
          <li key={task.id}>
            <span
              style={{ textDecoration: task.completed ? 'line-through' : 'none' }}
              onClick={() => toggleComplete(task)}
            >
              {task.name}
            </span>
            <button onClick={() => deleteTask(task.id)}>Delete</button>
          </li>
        ))}
      </ul>
    </div>
  );
}

export default Main;
