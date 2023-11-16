BEGIN
  UPDATE tbseg_resumo_contratacao_vida a 
     SET a.flcontratado = 0
   where a.FLCONTRATADO = 1 and a.NRCPFCNPJ = 04064817923;
   commit;
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.put_line('Erro geral: '|| sqlerrm);
END;
/
