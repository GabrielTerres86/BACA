
BEGIN
  UPDATE crapefp p
     SET p.dsdcargo = 'Auxiliar de Estamparia II'
   WHERE p.cdcooper = 1
     AND p.cdempres = 5724
     AND p.nrcpfemp = 4771609136;
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    dbms_output.put_line('Erro ao atualizar crapefp: '|| sqlerrm);
END;
