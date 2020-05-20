BEGIN 
  UPDATE Tbjur_prm_quebra_sigilo o 
     SET o.nmestsig = 'CONTA ITG'
   WHERE o.cdestsig = 25;
   COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.put_line('Erro: '||sqlerrm);
END;
