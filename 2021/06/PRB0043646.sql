 /*---------------------------------------------------------------------------------------------------------------------
    Programa    : Tela VERSOA - Script de carga
  ---------------------------------------------------------------------------------------------------------------------*/ 
BEGIN
-- cria dominio
insert into cecred.tbcadast_dominio_campo values ('CDSISTEMASOA', 0, 'SOA');
insert into cecred.tbcadast_dominio_campo values ('CDSISTEMASOA', 1, 'Rightnow');
insert into cecred.tbcadast_dominio_campo values ('CDSISTEMASOA', 2, 'Dynamics');
insert into cecred.tbcadast_dominio_campo values ('CDSISTEMASOA', 3, 'SalesForce');


insert into cecred.tbcadast_campo_historico ( NMTABELA_ORACLE, NMCAMPO, DSCAMPO ) 
                                     values ('TBCADAST_ERROS_COMUNIC_SOA', 'CDSISTEMA', 'Codigo do sistema integrado SOA');


-- remove qualquer "lixo" de BD que possa ter  

DELETE FROM craptel WHERE nmdatela = 'VERSOA';
DELETE FROM crapace WHERE nmdatela = 'VERSOA';
DELETE FROM crapprg WHERE cdprogra = 'VERSOA';



  -- Insere a tela
  INSERT INTO craptel 
      (nmdatela,
       nrmodulo,
       cdopptel,
       tldatela,
       tlrestel,
       flgteldf,
       flgtelbl,
       nmrotina,
       lsopptel,
       inacesso,
       cdcooper,
       idsistem,
       idevento,
       nrordrot,
       nrdnivel,
       nmrotpai,
       idambtel)
      SELECT 'VERSOA', 
             5, 
             '@,C,B,G,X,D,Y', 
             'Log Erros CADASTRO x SOA', 
             'Log Erros CADASTRO x SOA', 
             0, 
             1, -- bloqueio da tela 
             ' ', 
             'Acesso,Consultar,Baixa,Log Erros CADASTRO x SOA', 
             0, 
             cdcooper, -- cooperativa
             1, 
             0, 
             1, 
             1, 
             '', 
             2 
        FROM crapcop          
       WHERE cdcooper = 3; 

  -- Permissões de consulta para os usuários pré-definidos pela CECRED                       
  INSERT INTO crapace (nmdatela,cddopcao,cdoperad,nmrotina,cdcooper,nrmodulo,idevento,idambace) (SELECT 'VERSOA',cddopcao,cdoperad,nmrotina,cdcooper,nrmodulo,idevento,idambace FROM crapace WHERE nmdatela ='COBTIT' AND cdcooper = 3);

  -- Insere o registro de cadastro do programa
  INSERT INTO crapprg
      (nmsistem,
       cdprogra,
       dsprogra##1,
       dsprogra##2,
       dsprogra##3,
       dsprogra##4,
       nrsolici,
       nrordprg,
       inctrprg,
       cdrelato##1,
       cdrelato##2,
       cdrelato##3,
       cdrelato##4,
       cdrelato##5,
       inlibprg,
       cdcooper) 
      SELECT 'CRED',
             'VERSOA',
             'Log Erros CADASTRO x SOA',
             '.',
             '.',
             '.',
              (SELECT max(nrsolici)+1 FROM crapprg where nrsolici < 99999),
             NULL,
             1,
             0,
             0,
             0,
             0,
             0,
             1,
             cdcooper
        FROM crapcop          
       WHERE cdcooper IN 3;

  UPDATE crapprg c SET cdrelato##1=(SELECT cdrelato##1 FROM crapprg WHERE cdprogra = 'VERSOA' AND cdcooper = 3) WHERE cdprogra='COBTIT' AND cdcooper = 3;
 
INSERT INTO craprdr (nmprogra, dtsolici)
              VALUES('CADA0014',SYSDATE);
              
INSERT INTO crapaca (nmdeacao,nmpackag,nmproced,lstparam,nrseqrdr)
              VALUES('CONS_ERROS_SOA','CADA0014','pc_consulta_erros_comunic_soa','pr_dtini,pr_dtfim',
                     (SELECT r.nrseqrdr FROM craprdr r WHERE r.nmprogra = 'CADA0014'));         

INSERT INTO crapaca (nmdeacao,nmpackag,nmproced,lstparam,nrseqrdr)
              VALUES('SALVA_ERROS_SOA','CADA0014','pc_reproc_erros_comunic_soa','pr_logs',
                     (SELECT r.nrseqrdr FROM craprdr r WHERE r.nmprogra = 'CADA0014'));                      

INSERT INTO crapaca (nmdeacao,nmpackag,nmproced,lstparam,nrseqrdr)
              VALUES('REPROC_ERROS_SOA','CADA0014','pc_reproc_erros_comunic_soa','pr_logs',
                     (SELECT r.nrseqrdr FROM craprdr r WHERE r.nmprogra = 'CADA0014'));                            
  
  COMMIT;
END;