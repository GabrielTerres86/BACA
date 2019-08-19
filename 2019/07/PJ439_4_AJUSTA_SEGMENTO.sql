declare 

  CURSOR cr_subsegmento IS
    select s.cdsubsegmento
          ,24 nrmax_parcela
          ,15000 vlmax_financ
          ,45 nrcarecia
      from tbepr_cdc_subsegmento s
     where s.cdsubsegmento in (104,105);
  rw_subsegmento cr_subsegmento%rowtype;
  
   CURSOR cr_crapcop IS
      SELECT c.cdcooper
        FROM crapcop c
       WHERE c.cdcooper <> 3 -- CECRED
         AND c.flgativo = 1
    ORDER BY c.cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;
    
    vr_IDSUBSEGMENTO_COOP tbepr_cdc_subsegmento_coop.idsubsegmento_coop%type;
    i integer;
    vr_max_id tbepr_cdc_subsegmento_coop.idsubsegmento_coop%type;
    vr_seq_id tbepr_cdc_subsegmento_coop.idsubsegmento_coop%type;

begin
   select max(idsubsegmento_coop) 
      INTO vr_max_id
     from tbepr_cdc_subsegmento_coop;

  FOR i in 1 .. vr_max_id LOOP
    select SEQ_TBEPR_CDC_SUBSEGMENTO_COOP.nextval 
      into vr_seq_id
      from dual;
      
      if vr_seq_id > vr_max_id THEN
        --dbms_output.put_line('Sai fora');
        exit;
      END IF;
  END LOOP;
  
  FOR rw_subsegmento in cr_subsegmento LOOP
    FOR rw_crapcop IN cr_crapcop LOOP
        -- Grava subsegmento coop
        BEGIN
          INSERT INTO tbepr_cdc_subsegmento_coop(cdcooper
                                                ,cdsubsegmento
                                                ,nrmax_parcela
                                                ,vlmax_financ
                                                ,nrcarencia)
               VALUES(rw_crapcop.cdcooper
                     ,rw_subsegmento.cdsubsegmento
                     ,rw_subsegmento.nrmax_parcela
                     ,rw_subsegmento.vlmax_financ
                     ,rw_subsegmento.nrcarecia)
              returning IDSUBSEGMENTO_COOP
                   INTO vr_IDSUBSEGMENTO_COOP;
        EXCEPTION
          WHEN DUP_VAL_ON_INDEX THEN
            dbms_output.put_line('Valor duplicado: ' || rw_crapcop.cdcooper || ' - ' || rw_subsegmento.cdsubsegmento || ' - ' || SQLERRM);             
            null;
          WHEN OTHERS THEN
            dbms_output.put_line('Erro ao inserir registro de Subsegmento Cooperativa. Erro: ' || SQLERRM);
            null;
        END;
      END LOOP; 
  
  END LOOP;
  commit;
  
end;