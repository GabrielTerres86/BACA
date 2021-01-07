 BEGIN  
 /*Direto Fontes*/  
 INSERT INTO CREDITO.tbblqj_contrato_bloqueado(cdcooper,nrdconta,nrctremp,dtbloqueio,cdoperador_bloqueio,dtdesbloqueio,cdoperador_desbloqueio,dsobservacao)
                                        VALUES(1,2496380,289361,Sysdate,'1',NULL,NULL,'Bloqueio via Carga, conta era bloqueada direto no fonte.');       
 INSERT INTO CREDITO.tbblqj_contrato_bloqueado(cdcooper,nrdconta,nrctremp,dtbloqueio,cdoperador_bloqueio,dtdesbloqueio,cdoperador_desbloqueio,dsobservacao)
                                        VALUES(1,3044831,146922,Sysdate,'1',NULL,NULL,'Bloqueio via Carga, conta era bloqueada direto no fonte.');           
 /*EMPRESTIMO_ACAO_JUDICIAL*/
 INSERT INTO CREDITO.tbblqj_contrato_bloqueado(cdcooper,nrdconta,nrctremp,dtbloqueio,cdoperador_bloqueio,dtdesbloqueio,cdoperador_desbloqueio,dsobservacao)
                                        VALUES(1,8415005,412485,Sysdate,'1',NULL,NULL,'Bloqueio via Carga, conta era bloqueada direto no fonte.');       
 --INSERT INTO CREDITO.tbblqj_contrato_bloqueado(cdcooper,nrdconta,nrctremp,dtbloqueio,cdoperador_bloqueio,dtdesbloqueio,cdoperador_desbloqueio,dsobservacao)
 --                                       VALUES(1,3044831,146922,Sysdate,'1',NULL,NULL,'Bloqueio via Carga, conta era bloqueada direto no fonte.');                    
 /*CONTAS_ACAO_JUDICIAL*/        
 INSERT INTO CREDITO.tbblqj_contrato_bloqueado(cdcooper,nrdconta,nrctremp,dtbloqueio,cdoperador_bloqueio,dtdesbloqueio,cdoperador_desbloqueio,dsobservacao)
                                        VALUES(1,936600,0,Sysdate,'1',NULL,NULL,'Bloqueio via Carga, conta bloqueada CRAPPRM.');     
 COMMIT;                                             
EXCEPTION
  WHEN OTHERS THEN
    Rollback;
    dbms_output.put_line('Erro ao Inserir: '||sqlerrm);
END;  
