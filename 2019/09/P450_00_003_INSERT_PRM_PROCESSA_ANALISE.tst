PL/SQL Developer Test script 3.0
25
-- Created on 29/07/2019 by T0032420 
DECLARE 
  CURSOR cr_crapaca IS
    SELECT lstparam
      FROM crapaca
      WHERE nmdeacao = 'PROCESSA_ANALISE';
  vr_lstparam VARCHAR2(500);
BEGIN
  dbms_output.put_line('Início: ' || to_char(SYSDATE,'hh24:mi:ss'));
  OPEN cr_crapaca;
  FETCH cr_crapaca INTO vr_lstparam;
  IF cr_crapaca%NOTFOUND THEN
    dbms_output.put_line('ERRO: CRAPACA não existe.');
  ELSE
    IF INSTR(vr_lstparam, ',pr_scorerat') > 0 THEN
      dbms_output.put_line('AVISO: Parâmetro pr_scorerat já existe.');
    ELSE
      UPDATE crapaca SET LSTPARAM = LSTPARAM || ',pr_scorerat' WHERE nmdeacao = 'PROCESSA_ANALISE';
      COMMIT;
      dbms_output.put_line('AVISO: Parâmetro pr_scorerat criado com sucesso.');
    END IF;
  END IF;
  CLOSE cr_crapaca;
  dbms_output.put_line('Fim: ' || to_char(SYSDATE,'hh24:mi:ss'));
END;
0
0
