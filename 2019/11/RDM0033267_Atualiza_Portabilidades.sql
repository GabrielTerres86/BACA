rem PL/SQL Developer Test Script

set feedback off
set autoprint off

rem Execute PL/SQL Block
DECLARE 
  i integer;
  
  CURSOR cur_ispb (prm_nr_portabilidade VARCHAR2) IS
    SELECT substr(a.dsxml_mensagem,
                  instr(a.dsxml_mensagem, '<ISPBIFDebtd>') + 13,
                  instr(a.dsxml_mensagem, '</ISPBIFDebtd>') -
                  (instr(a.dsxml_mensagem, '<ISPBIFDebtd>') + 13)) ISPB
      FROM tbspb_msg_xml a
     WHERE trunc(a.dhmensagem) >= to_date('01112019', 'ddmmyyyy')
       AND trunc(a.dhmensagem) <= to_date('03122019', 'ddmmyyyy')
       AND a.nmmensagem     = 'STR0047R2'
       and a.dsxml_mensagem LIKE '%'||prm_nr_portabilidade||'%'
       and a.dsobservacao   IS NULL;

  ww_nr_ispb NUMBER;
         
BEGIN
  -- Test statements here
  FOR reg IN (SELECT a.progress_recid,
                     a.nrunico_portabilidade
                FROM tbepr_portabilidade a
               WHERE trunc(a.dtaprov_portabilidade) >= to_date('01/11/2019','dd/mm/yyyy')
                 AND trunc(a.dtaprov_portabilidade) <  to_date('04/12/2019','dd/mm/yyyy')
                 AND a.tpoperacao = 2 -- operações de venda
               ORDER BY a.nrunico_portabilidade) LOOP

    ww_nr_ispb := NULL;
    
    -- Busca o ISPB
    OPEN cur_ispb(reg.nrunico_portabilidade);
      FETCH cur_ispb
       INTO ww_nr_ispb;
    CLOSE cur_ispb;   
    
    -- Se achou registra na tabela de portabilidade.
    IF ww_nr_ispb > 0 THEN
      
      UPDATE tbepr_portabilidade porta
         SET porta.nrcnpjbase_if_origem = ww_nr_ispb
       WHERE porta.progress_recid       = reg.progress_recid;
      
      dbms_output.put_line('Portabilidade ('||reg.nrunico_portabilidade||') Progress: '||reg.progress_recid||' e ISPB: '||ww_nr_ispb);
        
    ELSE
      dbms_output.put_line('Portabilidade ('||reg.nrunico_portabilidade||') Progress: '||reg.progress_recid||' e ISPB não localizado. ');
    END IF;

  END LOOP;

  COMMIT;

END;
/
