DECLARE
    	
  -- Variáveis Globais e constantes
  vr_total_registros_recebe   NUMBER(2);
  vr_total_registros_envia    NUMBER(2); 
  vr_mensagem_erro            VARCHAR2(300);
  
  vr_nmarquiv        CONSTANT VARCHAR2(31) := 'APCS108_05463212_20210507_00110';
  vr_dtarquiv        CONSTANT VARCHAR2(10) := '07/05/2021';
  vr_cdmotivo        CONSTANT NUMBER       := 1;
  vr_dsmotivoaceite  CONSTANT VARCHAR2(30) := 'MOTVACTECOMPRIOPORTDDCTSALR';
  
    
BEGIN
       
	vr_total_registros_recebe:=0;
    vr_total_registros_envia:=0;	
	   
    BEGIN      
    
	   -- Atualiza a solicitação para APROVADA
       UPDATE tbcc_portabilidade_envia t
         SET t.idsituacao        = 3 -- Aprovada
           , t.dsdominio_motivo  = vr_dsmotivoaceite
           , t.cdmotivo          = vr_cdmotivo
           , t.dtretorno         = to_date(vr_dtarquiv,'DD/MM/YYYY')
           , t.nmarquivo_retorno = vr_nmarquiv
       WHERE to_char(nrnu_portabilidade) in ('202104260000184073774','202104260000184086100','202104260000184094654','202104260000184111187','202104260000184111200','202104260000184136701','202104260000184136753');

       vr_total_registros_envia:=SQL%ROWCOUNT;
	
    END;	
               
        
    BEGIN
    
       -- Atualiza a solicitação para APROVADA
       UPDATE tbcc_portabilidade_recebe t
         SET t.idsituacao         = 2 -- Aprovada
           , t.dsdominio_motivo   = vr_dsmotivoaceite
           , t.cdmotivo           = vr_cdmotivo
           , t.dtavaliacao        = to_date(vr_dtarquiv,'DD/MM/YYYY')
           , t.dtretorno          = to_date(vr_dtarquiv,'DD/MM/YYYY')
           , t.nmarquivo_resposta = vr_nmarquiv
       WHERE to_char(nrnu_portabilidade) in ('202104260000184018429');

       vr_total_registros_recebe:=SQL%ROWCOUNT;
    
    END;	
      
    COMMIT;
	
	dbms_output.put_line(chr(10) || 'Total de registros atualizados (tabela envia) ' || vr_total_registros_envia);
	
	dbms_output.put_line(chr(10) || 'Total de registros atualizados (tabela recebe) ' || vr_total_registros_recebe);
        
  EXCEPTION
    WHEN OTHERS THEN
	  BEGIN
        vr_mensagem_erro := 'Erro no update envia e recebe portabilidade.' ||SQLERRM;
		
		dbms_output.put_line(chr(10) || 'Erro: ' || vr_mensagem_erro); 
      END;		
	  
END;