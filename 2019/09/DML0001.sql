BEGIN
-- substituir
-- nome_da_acao -> nome da acao na crapaca 
-- procedure_da_acao -> nome da procedure na crapaca 
-- package_da_acao -> nome da package na crapaca 
-- parametros_da_acao -> parâmetros de entrada da acao
-- GRAVAR_DADOS_CONVEN_PARC
DECLARE
  -- alterar
  nome_da_acao VARCHAR2(40) := 'GRAVAR_DADOS_CONVEN_PARC';
  procedure_da_acao VARCHAR2(100) := 'pc_grava_conv_parceiros';
  package_da_acao VARCHAR2(100) := 'TELA_CONVEN';
  parametros_da_acao VARCHAR2(4000):= 'pr_cddopcao,pr_tparrecd,pr_cdconven,pr_nmfantasia,pr_rzsocial,pr_cdhistor,pr_codfebraban,pr_cdsegmto,pr_nmrescon,pr_vltarint,pr_vltartaa,pr_vltarcxa,pr_vltardeb,pr_vltarcor,pr_vltararq,pr_nrrenorm,pr_nrtolera,pr_dsdianor,pr_dtcancel,pr_nrlayout,pr_flgaccec,pr_flgacsic,pr_flgacbcb,pr_flginter,pr_forma_arrecadacao';
  -- fim alterar

  CURSOR cr_craprdr(pr_nmprogra in craprdr.nmprogra%TYPE) IS
  SELECT * FROM craprdr
   WHERE craprdr.nmprogra = pr_nmprogra;
  rw_craprdr cr_craprdr%ROWTYPE;

  CURSOR cr_crapaca(pr_nmdeacao IN crapaca.nmdeacao%TYPE
                   ,pr_nmpackag IN crapaca.nmpackag%TYPE
                   ,pr_nmproced IN crapaca.nmproced%TYPE
                   ,pr_nrseqrdr IN crapaca.nrseqrdr%TYPE) IS
  SELECT * FROM crapaca
   WHERE UPPER(crapaca.nmdeacao) = UPPER(pr_nmdeacao)
     AND UPPER(crapaca.nmpackag) = UPPER(pr_nmpackag)
     AND UPPER(crapaca.nmproced) = UPPER(pr_nmproced)
     AND crapaca.nrseqrdr = pr_nrseqrdr;
  rw_crapaca cr_crapaca%ROWTYPE;
  
  vr_exec_erro EXCEPTION;
  vr_dscritic  VARCHAR2(1000);  

BEGIN
  
  dbms_output.put_line('inicio do programa');
  
  -- mensageria
  OPEN cr_craprdr(pr_nmprogra => package_da_acao);
  FETCH cr_craprdr INTO rw_craprdr;
    
  -- verifica se existe a tela do ayllos web
  IF cr_craprdr%NOTFOUND THEN
   
    -- se não encontrar
    CLOSE cr_craprdr;

    -- insere ação da tela do aylloas web
    INSERT INTO craprdr(nmprogra
                       ,dtsolici) 
                 VALUES(package_da_acao
                       ,SYSDATE);
    -- posiciona no registro criado
    OPEN cr_craprdr(pr_nmprogra => package_da_acao);
    FETCH cr_craprdr INTO rw_craprdr;

    dbms_output.put_line('insere craprdr -> '||package_da_acao||': ' || rw_craprdr.nrseqrdr);

  END IF;  
  
  -- fecha o cursor
  CLOSE cr_craprdr;

  -- inicio mensageria   
  
  OPEN cr_crapaca(pr_nmdeacao => nome_da_acao
                 ,pr_nmpackag => package_da_acao
                 ,pr_nmproced => procedure_da_acao
                 ,pr_nrseqrdr => rw_craprdr.nrseqrdr);
                   
  FETCH cr_crapaca INTO rw_crapaca;
    
  -- verifica se existe a ação tela do ayllos web
  IF cr_crapaca%NOTFOUND THEN
    
    -- insere ação da tela do ayllos web
    INSERT INTO crapaca(nmdeacao, 
                        nmpackag, 
                        nmproced, 
                        lstparam, 
                        nrseqrdr) 
                 VALUES(nome_da_acao,
                        package_da_acao,
                        procedure_da_acao,
                        parametros_da_acao,
                        rw_craprdr.nrseqrdr);
                             
    dbms_output.put_line('insere crapaca -> '||nome_da_acao||' -> '||package_da_acao||'.'||procedure_da_acao);
    
  END IF;
  
  CLOSE cr_crapaca;    
  dbms_output.put_line('fim do programa');   

EXCEPTION
  WHEN vr_exec_erro THEN    
    dbms_output.put_line('erro:' || vr_dscritic);
    ROLLBACK;   
  WHEN OTHERS THEN
    dbms_output.put_line('erro a executar o programa:' || SQLERRM);
    ROLLBACK;    
END;


-- GRAVAR_DADOS_CONVEN_AILOS
DECLARE
  -- alterar
  nome_da_acao VARCHAR2(40) := 'GRAVAR_DADOS_CONVEN_AILOS';
  procedure_da_acao VARCHAR2(100) := 'pc_grava_conv_ailos';
  package_da_acao VARCHAR2(100) := 'TELA_CONVEN';
  parametros_da_acao VARCHAR2(4000):= 'pr_cddopcao,pr_tparrecd,pr_cdconven,pr_cod_arquivo,pr_codfebraban,pr_cdcooper,pr_banco,pr_flg_arrecadacao,pr_flg_debito,pr_nmfantasia,pr_rzsocial,pr_cdsegmento,pr_envia_relatorio_mensal,pr_arq_unico,pr_tipo_envio,pr_diretorio_accesstage,pr_vencto_contrato,pr_envia_relatorio_para,pr_seq_arrecadacao,pr_arq_arrecadcao,pr_envia_arq_parcial,pr_seq_parcial,pr_arq_parcial,pr_layout_arrecadacao,pr_valida_vncto,pr_dias_tolera,pr_flgaccec,pr_flgacsic,pr_flgacbcb,pr_seq_integracao,pr_arq_integracao,pr_seq_cadastro_retorno,pr_arq_cadastro_optante,pr_arq_retorno,pr_layout_debito,pr_tam_optante,pr_origem_inclusao,pr_usa_agencia,pr_acata_duplicacao,pr_inclui_debito_facil,pr_envia_alterta_pos,pr_identifica_fatura,pr_declaracao,pr_valida_cpfcnpj,pr_gera_reg_j,pr_debita_sem_saldo,pr_envia_data_repasse,pr_hist_pagto,pr_hist_deb_auto,pr_hist_rep_ailos,pr_vltarcxa,pr_vltarint,pr_vltartaa,pr_vltardeb,pr_conta_deb_filiada,pr_repasse_banco,pr_repasse_agencia,pr_repasse_conta,pr_repasse_cnpj,pr_repasse_tipo,pr_repasse_dia,pr_flginter,pr_forma_arrecadacao';
  -- fim alterar

  CURSOR cr_craprdr(pr_nmprogra in craprdr.nmprogra%TYPE) IS
  SELECT * FROM craprdr
   WHERE craprdr.nmprogra = pr_nmprogra;
  rw_craprdr cr_craprdr%ROWTYPE;

  CURSOR cr_crapaca(pr_nmdeacao IN crapaca.nmdeacao%TYPE
                   ,pr_nmpackag IN crapaca.nmpackag%TYPE
                   ,pr_nmproced IN crapaca.nmproced%TYPE
                   ,pr_nrseqrdr IN crapaca.nrseqrdr%TYPE) IS
  SELECT * FROM crapaca
   WHERE UPPER(crapaca.nmdeacao) = UPPER(pr_nmdeacao)
     AND UPPER(crapaca.nmpackag) = UPPER(pr_nmpackag)
     AND UPPER(crapaca.nmproced) = UPPER(pr_nmproced)
     AND crapaca.nrseqrdr = pr_nrseqrdr;
  rw_crapaca cr_crapaca%ROWTYPE;
  
  vr_exec_erro EXCEPTION;
  vr_dscritic  VARCHAR2(1000);  

BEGIN
  
  dbms_output.put_line('inicio do programa');
  
  -- mensageria
  OPEN cr_craprdr(pr_nmprogra => package_da_acao);
  FETCH cr_craprdr INTO rw_craprdr;
    
  -- verifica se existe a tela do ayllos web
  IF cr_craprdr%NOTFOUND THEN
   
    -- se não encontrar
    CLOSE cr_craprdr;

    -- insere ação da tela do aylloas web
    INSERT INTO craprdr(nmprogra
                       ,dtsolici) 
                 VALUES(package_da_acao
                       ,SYSDATE);
    -- posiciona no registro criado
    OPEN cr_craprdr(pr_nmprogra => package_da_acao);
    FETCH cr_craprdr INTO rw_craprdr;

    dbms_output.put_line('insere craprdr -> '||package_da_acao||': ' || rw_craprdr.nrseqrdr);

  END IF;  
  
  -- fecha o cursor
  CLOSE cr_craprdr;

  -- inicio mensageria   
  
  OPEN cr_crapaca(pr_nmdeacao => nome_da_acao
                 ,pr_nmpackag => package_da_acao
                 ,pr_nmproced => procedure_da_acao
                 ,pr_nrseqrdr => rw_craprdr.nrseqrdr);
                   
  FETCH cr_crapaca INTO rw_crapaca;
    
  -- verifica se existe a ação tela do ayllos web
  IF cr_crapaca%NOTFOUND THEN
    
    -- insere ação da tela do ayllos web
    INSERT INTO crapaca(nmdeacao, 
                        nmpackag, 
                        nmproced, 
                        lstparam, 
                        nrseqrdr) 
                 VALUES(nome_da_acao,
                        package_da_acao,
                        procedure_da_acao,
                        parametros_da_acao,
                        rw_craprdr.nrseqrdr);
                             
    dbms_output.put_line('insere crapaca -> '||nome_da_acao||' -> '||package_da_acao||'.'||procedure_da_acao);
    
  END IF;
  
  CLOSE cr_crapaca;    
  dbms_output.put_line('fim do programa');   
EXCEPTION
  WHEN vr_exec_erro THEN    
    dbms_output.put_line('erro:' || vr_dscritic);
    ROLLBACK;   
  WHEN OTHERS THEN
    dbms_output.put_line('erro a executar o programa:' || SQLERRM);
    ROLLBACK;    
END;

-- BUSCA_DESC_CONVENIOS
DECLARE
  -- alterar
  nome_da_acao VARCHAR2(40) := 'BUSCAR_DESC_CONVENIOS';
  procedure_da_acao VARCHAR2(100) := 'pc_busca_convenios';
  package_da_acao VARCHAR2(100) := 'TELA_CONVEN';
  parametros_da_acao VARCHAR2(4000):= 'pr_cdempres,pr_tparrecd,pr_cdempcon,pr_cdsegmento,pr_nmextcon,pr_nrregist,pr_nriniseq';
  -- fim alterar

  CURSOR cr_craprdr(pr_nmprogra in craprdr.nmprogra%TYPE) IS
  SELECT * FROM craprdr
   WHERE craprdr.nmprogra = pr_nmprogra;
  rw_craprdr cr_craprdr%ROWTYPE;

  CURSOR cr_crapaca(pr_nmdeacao IN crapaca.nmdeacao%TYPE
                   ,pr_nmpackag IN crapaca.nmpackag%TYPE
                   ,pr_nmproced IN crapaca.nmproced%TYPE
                   ,pr_nrseqrdr IN crapaca.nrseqrdr%TYPE) IS
  SELECT * FROM crapaca
   WHERE UPPER(crapaca.nmdeacao) = UPPER(pr_nmdeacao)
     AND UPPER(crapaca.nmpackag) = UPPER(pr_nmpackag)
     AND UPPER(crapaca.nmproced) = UPPER(pr_nmproced)
     AND crapaca.nrseqrdr = pr_nrseqrdr;
  rw_crapaca cr_crapaca%ROWTYPE;
  
  vr_exec_erro EXCEPTION;
  vr_dscritic  VARCHAR2(1000);  

BEGIN
  
  dbms_output.put_line('inicio do programa');
  
  -- mensageria
  OPEN cr_craprdr(pr_nmprogra => package_da_acao);
  FETCH cr_craprdr INTO rw_craprdr;
    
  -- verifica se existe a tela do ayllos web
  IF cr_craprdr%NOTFOUND THEN
   
    -- se não encontrar
    CLOSE cr_craprdr;

    -- insere ação da tela do aylloas web
    INSERT INTO craprdr(nmprogra
                       ,dtsolici) 
                 VALUES(package_da_acao
                       ,SYSDATE);
    -- posiciona no registro criado
    OPEN cr_craprdr(pr_nmprogra => package_da_acao);
    FETCH cr_craprdr INTO rw_craprdr;

    dbms_output.put_line('insere craprdr -> '||package_da_acao||': ' || rw_craprdr.nrseqrdr);

  END IF;  
  
  -- fecha o cursor
  CLOSE cr_craprdr;

  -- inicio mensageria   
  
  OPEN cr_crapaca(pr_nmdeacao => nome_da_acao
                 ,pr_nmpackag => package_da_acao
                 ,pr_nmproced => procedure_da_acao
                 ,pr_nrseqrdr => rw_craprdr.nrseqrdr);
                   
  FETCH cr_crapaca INTO rw_crapaca;
    
  -- verifica se existe a ação tela do ayllos web
  IF cr_crapaca%NOTFOUND THEN
    
    -- insere ação da tela do ayllos web
    INSERT INTO crapaca(nmdeacao, 
                        nmpackag, 
                        nmproced, 
                        lstparam, 
                        nrseqrdr) 
                 VALUES(nome_da_acao,
                        package_da_acao,
                        procedure_da_acao,
                        parametros_da_acao,
                        rw_craprdr.nrseqrdr);
                             
    dbms_output.put_line('insere crapaca -> '||nome_da_acao||' -> '||package_da_acao||'.'||procedure_da_acao);
    
  END IF;
  
  CLOSE cr_crapaca;    
  dbms_output.put_line('fim do programa');   
    
EXCEPTION
  WHEN vr_exec_erro THEN    
    dbms_output.put_line('erro:' || vr_dscritic);
    ROLLBACK;   
  WHEN OTHERS THEN
    dbms_output.put_line('erro a executar o programa:' || SQLERRM);
    ROLLBACK;    
END;

----------- //  Dominios de Atributos //-----------------------
BEGIN
--TPDENVIO
insert into CECRED.TBCONV_DOMINIO_CAMPO (NMDOMINIO, CDDOMINIO, DSCODIGO)
values ('TPDENVIO', '1', 'E-MAIL');
insert into CECRED.TBCONV_DOMINIO_CAMPO (NMDOMINIO, CDDOMINIO, DSCODIGO)
values ('TPDENVIO', '2', 'E-SALES');
insert into CECRED.TBCONV_DOMINIO_CAMPO (NMDOMINIO, CDDOMINIO, DSCODIGO)
values ('TPDENVIO', '3', 'NEXXERA');
insert into CECRED.TBCONV_DOMINIO_CAMPO (NMDOMINIO, CDDOMINIO, DSCODIGO)
values ('TPDENVIO', '4', 'MAIL(SENHA)');
insert into CECRED.TBCONV_DOMINIO_CAMPO (NMDOMINIO, CDDOMINIO, DSCODIGO)
values ('TPDENVIO', '5', 'ACCESSTAGE');
insert into CECRED.TBCONV_DOMINIO_CAMPO (NMDOMINIO, CDDOMINIO, DSCODIGO)
values ('TPDENVIO', '6', 'WEBSERVI');
-- INTPCONVENIO
insert into CECRED.TBCONV_DOMINIO_CAMPO (NMDOMINIO, CDDOMINIO, DSCODIGO)
values ('INTPCONVENIO', '1', 'ARRECADAÇÃO');
insert into CECRED.TBCONV_DOMINIO_CAMPO (NMDOMINIO, CDDOMINIO, DSCODIGO)
values ('INTPCONVENIO', '2', 'DEBITO AUTOMATICO');
insert into CECRED.TBCONV_DOMINIO_CAMPO (NMDOMINIO, CDDOMINIO, DSCODIGO)
values ('INTPCONVENIO', '3', 'ARRECADAÇÃO/DEBITO AUTOMATICO');
-- TPARRECADACAO
insert into CECRED.TBCONV_DOMINIO_CAMPO (NMDOMINIO, CDDOMINIO, DSCODIGO)
values ('TPARRECADACAO', '1', 'SICREDI');
insert into CECRED.TBCONV_DOMINIO_CAMPO (NMDOMINIO, CDDOMINIO, DSCODIGO)
values ('TPARRECADACAO', '2', 'BANCOOB');
insert into CECRED.TBCONV_DOMINIO_CAMPO (NMDOMINIO, CDDOMINIO, DSCODIGO)
values ('TPARRECADACAO', '3', 'AILOS');
-- FLGINDEB
insert into CECRED.TBCONV_DOMINIO_CAMPO (NMDOMINIO, CDDOMINIO, DSCODIGO)
values ('FLGINDEB', '1', 'COOPERATIVA');
insert into CECRED.TBCONV_DOMINIO_CAMPO (NMDOMINIO, CDDOMINIO, DSCODIGO)
values ('FLGINDEB', '2', 'EMPRESA CONVENIADA');
insert into CECRED.TBCONV_DOMINIO_CAMPO (NMDOMINIO, CDDOMINIO, DSCODIGO)
values ('FLGINDEB', '3', 'MISTO');

------------------------------------------Criação de Paramentros------------------------------------------

INSERT into cecred.crapprm
  (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
VALUES
  ('CONV', 0, 'CANAL_ENTRADA_CONVENIO', 'Canais de Entrada para Convenios', '2,3,4');

END;

  COMMIT;  

END;


