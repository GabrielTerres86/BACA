begin
dbms_aqadm.start_queue(queue_name => 'ADMFILASCECRED.FILA_MSG_EXCEPTION',enqueue => FALSE,dequeue => TRUE);
dbms_aqadm.start_queue(queue_name => 'ADMFILASCECRED.FILA_MSG',enqueue => TRUE,dequeue => TRUE);
commit;
end;