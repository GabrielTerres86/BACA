DECLARE 
 CURSOR cr_boletos IS
    SELECT cob.rowid
      FROM crapcob cob 
     WHERE (cob.cdcooper, cob.nrdconta, cob.nrcnvcob, cob.nrdocmto) IN ((7, 311715, 106002, 402), 
                                                       (7, 311715, 106002, 408), 
                                                       (9, 270148, 108002, 9657), 
                                                       (1, 8956812, 101002, 769), 
                                                       (1, 8682763, 101090, 871), 
                                                       (1, 8682763, 101090, 872))
       AND cob.incobran = 0
       AND cob.inenvcip = 2;
      
      --Variaveis de erro
      vr_des_erro     VARCHAR2(4000);
      vr_dscritic     VARCHAR2(4000);            
BEGIN
        
   FOR rw_boletos IN cr_boletos LOOP
    BEGIN
         UPDATE crapcob cra
          SET cra.inenvcip = 3 
        WHERE cra.rowid = rw_boletos.rowid;
        
        --Cria log cobranca
        PAGA0001.pc_cria_log_cobranca(pr_idtabcob => rw_boletos.rowid   --ROWID da Cobranca
                                     ,pr_cdoperad => '1'                --Operador
                                     ,pr_dtmvtolt => sysdate            --Data movimento
                                     ,pr_dsmensag => 'Boleto registrado no Sistema Financeiro Nacional - Manual'   --Descricao Mensagem
                                     ,pr_des_erro => vr_des_erro   --Indicador erro
                                     ,pr_dscritic => vr_dscritic); --Descricao erro
        
    END;
  END LOOP;
  COMMIT;
   
  EXCEPTION
    WHEN OTHERS THEN
      SISTEMA.excecaoInterna(pr_compleme => 'INC289372');
      ROLLBACK;
  
END;