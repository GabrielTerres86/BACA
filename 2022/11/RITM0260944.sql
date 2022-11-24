DECLARE   
  CURSOR cr_colaborador  IS    
    SELECT IDCALRIS_COLABORADOR, DHALTERACAO, TPCOLABORADOR
     FROM CECRED.TBCALRIS_COLABORADORES COLAB
    WHERE ((TPCOLABORADOR = 'L')  AND (TRUNC(DHALTERACAO) < SYSDATE)) 
       OR ((TPCOLABORADOR = 'N') AND (TRUNC(DHALTERACAO) <= TO_DATE('18/11/2022','DD/MM/YYYY') AND (TRUNC(DHALTERACAO) >= TO_DATE('09/11/2022','DD/MM/YYYY')))) 
       OR ((VLENDIVIDAMENTO IS NULL) AND (TRUNC(DHALTERACAO) < SYSDATE)) 
       OR ((VLPENDENCIA IS NULL) AND (TRUNC(DHALTERACAO) < SYSDATE)) 
    ORDER BY DHALTERACAO;    
  vr_atualiza     cr_colaborador%ROWTYPE;
  dt_aux          TBCALRIS_COLABORADORES.DHALTERACAO%TYPE;
  dt_atualizacao  TBCALRIS_COLABORADORES.DHALTERACAO%TYPE;
  vr_cont         NUMBER(6) := 0;
BEGIN
  dbms_output.put_line('início');
  dt_atualizacao := sysdate;
  FOR vr_atualiza IN cr_colaborador LOOP
    dt_aux :=  trunc(vr_atualiza.DHALTERACAO) + 15;
    
    IF (trunc(dt_aux) > trunc(dt_atualizacao)) THEN
       dt_atualizacao := dt_aux;
       vr_cont := 0;      
    END IF;
    
    UPDATE CECRED.TBCALRIS_COLABORADORES SET DHALTERACAO = dt_atualizacao
     WHERE IDCALRIS_COLABORADOR = vr_atualiza.IDCALRIS_COLABORADOR; 
   --  dbms_output.put_line(vr_atualiza.DHALTERACAO || ' ' ||  dt_atualizacao || '  ' || vr_cont || ' ' || vr_atualiza.IDCALRIS_COLABORADOR || ' ' || VR_ATUALIZA.TPCOLABORADOR);
    vr_cont := vr_cont + 1;
    
    IF vr_cont = 501 THEN
      vr_cont := 0;
      dt_atualizacao := dt_atualizacao + 1;
    END IF;
    
    COMMIT;    
  END LOOP;
  dbms_output.put_line('Registros alterados com sucesso. ');
EXCEPTION
  WHEN OTHERS THEN
    dbms_output.put_line(SQLERRM);
    dbms_output.put_line(SQLCODE);
    ROLLBACK;
END;