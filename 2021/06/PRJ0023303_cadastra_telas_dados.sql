begin
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
      SELECT 'SIMCON', 
             5,
             '@',
             'Simulador de Consórcio', 
             'Simulador de Consórcio', 
             0, 
             1, -- bloqueio da tela 
             ' ', 
             'Acesso', 
             0, 
             cdcooper, -- cooperativa
             1, 
             0, 
             1, 
             1, 
             '', 
             2 
        FROM crapcop          
       WHERE cdcooper IN (1,2,3,4,5,6,7,8,9,10,11,12,13,14); 

  -- Permissões de consulta para os usuários pré-definidos pela CECRED                       
INSERT INTO crapace
  (nmdatela,
   cddopcao,
   cdoperad,
   nmrotina,
   cdcooper,
   nrmodulo,
   idevento,
   idambace)
  (SELECT 'SIMCON',
          cddopcao,
          cdoperad,
          'Simulador de Consórcio',
          cdcooper,
          12,
          idevento,
          idambace
     FROM crapace
    WHERE nmdatela = 'TAB049'
      and cdcooper in (1,2,3,4,5,6,7,8,9,10,11,12,13,14));

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
             'SIMCON',
             'Simulador de Consórcio',
             '.',
             '.',
             '.',
             666,
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
       WHERE cdcooper IN (1,2,3,4,5,6,7,8,9,10,11,12,13,14);  
       
 INSERT INTO CRAPRDR (nmprogra, dtsolici) values ('SIMCON', sysdate);       
       
insert into crapaca
  (NRSEQACA, NMDEACAO, NMPACKAG, NMPROCED, NRSEQRDR)
values
  ((select max(NRSEQACA) + 1 from crapaca),
   'BUSCA_SEG',
   'CNSO0002',
   'pc_obtem_segmentos',
   (select nrseqrdr from CRAPRDR WHERE NMprogra = 'SIMCON'));
   
  
 --segunda chamada de planos
 insert into crapaca
  (NRSEQACA, NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
values
  ((select max(NRSEQACA) + 1 from crapaca),
   'LISTA_PLANOS_TAXAS',
   'CNSO0002',
   'pc_obtem_planos',
   'pr_idsegmento',
   (select nrseqrdr from CRAPRDR WHERE NMprogra = 'SIMCON'));

------busca de taxas
insert into crapaca
  (NRSEQACA, NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
values
  ((select max(NRSEQACA) + 1 from crapaca),
   'LISTA_TAXAS',
   'CNSO0002',
   'pc_obtem_taxas',
   'pr_idsegmento',
   (select nrseqrdr from CRAPRDR WHERE NMprogra = 'SIMCON'));  
   
------busca de bens
insert into crapaca
  (NRSEQACA, NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
values
  ((select max(NRSEQACA) + 1 from crapaca),
   'LISTA_BENS',
   'CNSO0002',
   'pc_obtem_bens',
   'pr_idplano',
   (select nrseqrdr from CRAPRDR WHERE NMprogra = 'SIMCON'));

------realiza calculo simulacao
insert into crapaca
  (NRSEQACA, NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
values
  ((select max(NRSEQACA) + 1 from crapaca),
   'BUSCA_SIMULACAO',
   'CNSO0002',
   'pc_obtem_simulacao',
   'pr_txadm, pr_txres, pr_vlrcnso, pr_prazo, pr_vltaxaseguro',
   (select nrseqrdr from CRAPRDR WHERE NMprogra = 'SIMCON'));          

----realiza calculo de criterio de aquisicao
insert into crapaca
  (NRSEQACA, NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
values
  ((select max(NRSEQACA) + 1 from crapaca),
   'CALCULO_CRITERIOAQUI',
   'CNSO0002',
   'pc_criterio_aquisicao',
   'pr_cdsegmentoaqui, pr_anomodelo, pr_sldevetoratual, pr_vlavaliacao, pr_cilindradas',
   (select nrseqrdr from CRAPRDR WHERE NMprogra = 'SIMCON'));          
   
----realiza calculo de carta de 25%
insert into crapaca
  (NRSEQACA, NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
values
  ((select max(NRSEQACA) + 1 from crapaca),
   'CALCULA_UTILIZACARTA',
   'CNSO0002',
   'pc_calculo_utilizarcarta',
   'pr_utilizacarta',
   (select nrseqrdr from CRAPRDR WHERE NMprogra = 'SIMCON'));          


----realiza o calculo do saldo devedor do lance
insert into crapaca
  (NRSEQACA, NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
values
  ((select max(NRSEQACA) + 1 from crapaca),
   'CALCULA_SALDO_DEVEDOR',
   'CNSO0002',
   'pc_calcula_saldo_devedor',
   'pr_txadmlance,pr_fundoreservalance,pr_prctlsegurosaldodevedor,pr_prazolance, pr_vlcnso', 
   (select nrseqrdr from CRAPRDR WHERE NMprogra = 'SIMCON'));           
        
     
   
 ----realiza o calculo do lance embutido em 25% do valor da carta
insert into crapaca
  (NRSEQACA, NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
values
  ((select max(NRSEQACA) + 1 from crapaca),
   'CALCULA_LANCE_EMBUTIDO',
   'CNSO0002',
   'pc_calcula_lance_embutido',
   'pr_utilizacarta', 
   (select nrseqrdr from CRAPRDR WHERE NMprogra = 'SIMCON'));          
         
   
----realiza o calculo das parcelas do lance
insert into crapaca
  (NRSEQACA, NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
values
  ((select max(NRSEQACA) + 1 from crapaca),
   'CALCULA_PARCELAS_LANCE',
   'CNSO0002',
   'pc_calcula_parcelas_lance',
   'pr_txadmlance, pr_fundoreservalance, pr_vlcnso, pr_rcrsproprio, pr_prctlsegurosaldodevedor, pr_embutidovlcarta, pr_prazolance, pr_slddevedorlance', 
   (select nrseqrdr from CRAPRDR WHERE NMprogra = 'SIMCON'));          
        
      
   
   
  
                     
----realiza o insert na tabela TBCONSOR_SIMUECONOMIA dos dados da simulacao de economia
insert into crapaca
  (NRSEQACA, NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
values
  ((select max(NRSEQACA) + 1 from crapaca),
   'GRAVA_SIMU_ECONOMIA',
   'CNSO0002',
   'pc_cadastra_simu_economia',
   'pr_nrdconta, pr_idsegmento, pr_idplano,pr_nrprazo,pr_idtipobem,pr_vlcarta,pr_vltaxaadm,pr_vltxfundores,pr_idsegprest,pr_vltaxaseguro,pr_vlparcela ,pr_vlsaldodev ,pr_vlcustotcoop,pr_vlfundoresarre,pr_vlemprestimo,pr_vltxjuroempre ,pr_nrprazoemprest ,pr_vlparcemprest,pr_vltotaproxempr', 
   (select nrseqrdr from CRAPRDR WHERE NMprogra = 'SIMCON'));          
                        
commit;

end;