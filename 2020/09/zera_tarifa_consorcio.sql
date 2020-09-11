BEGIN
  UPDATE crapthi i SET i.vltarifa = 0
   WHERE i.cdhistor IN (1230, 1231, 1232, 1233, 1234, 2027)
     AND i.dsorigem = 'AIMARO';
     COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    dbms_output.put_line('Erro: '||sqlerrm);
END;
