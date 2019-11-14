DECLARE

PROCEDURE pc_update_intpconvenio IS
  -- P565_2_DML0004_RF016_UPDATE_GNCONVE_INTPCONVENIO_TipoConvenio.sql
BEGIN
  
--SELECT * from tbconv_dominio_campo d WHERE d.nmdominio='INTPCONVENIO';
--Script para popular o campo Tipo de Convênio 
--Data:19/09/2019
--Atualizar o script com os novos convênios criados após a dia 19/09/2019
BEGIN 
  --1-ARRECADAÇÃO
  BEGIN  
   UPDATE gnconve
      SET gnconve.intpconvenio = 1
    WHERE gnconve.cdconven in( 6
                              ,7
                              ,12
                              ,17
                              ,18
                              ,21
                              ,27
                              ,29
                              ,40
                              ,44
                              ,56
                              ,59
                              ,60
                              ,84
                              ,97
                              ,98
                              ,102
                              ,103
                              ,104
                              ,105
                              ,106
                              ,107
                              ,109
                              ,110
                              ,113
                              ,116
                              ,117
                              ,119
                              ,120
                              ,121
                              ,123
                              ,130
                              ,131
                              ,134
                              ,137
                              ,141
                              ,144);
  EXCEPTION
    WHEN OTHERS THEN
      dbms_output.put_line('1-ARRECADAÇÃO - ERRO: '|| sqlerrm);
  END; 
  --2-DEBITO AUTOMATICO
  BEGIN  
   UPDATE gnconve
      SET gnconve.intpconvenio = 2
    WHERE gnconve.cdconven in( 14
                              ,22
                              ,28
                              ,32
                              ,35
                              ,36
                              ,37
                              ,38
                              ,39
                              ,43
                              ,46
                              ,47
                              ,50
                              ,52
                              ,55
                              ,57
                              ,58
                              ,61
                              ,63
                              ,64
                              ,65
                              ,66
                              ,67
                              ,68
                              ,69
                              ,70
                              ,71
                              ,72
                              ,73
                              ,74
                              ,75
                              ,76
                              ,77
                              ,78
                              ,79
                              ,80
                              ,81
                              ,82
                              ,83
                              ,85
                              ,87
                              ,89
                              ,90
                              ,92
                              ,93
                              ,94
                              ,95
                              ,108
                              ,111
                              ,112
                              ,114
                              ,115
                              ,118
                              ,122
                              ,124
                              ,125
                              ,126
                              ,127
                              ,128
                              ,129
                              ,132
                              ,133
                              ,135
                              ,136
                              ,138
                              ,139
                              ,140
                              ,143
                              ,145
                              ,146 );
  EXCEPTION
    WHEN OTHERS THEN
      dbms_output.put_line('2-DEBITO AUTOMATICO - ERRO: '|| sqlerrm);
  END;                            
  --3-ARRECADAÇÃO/DEBITO AUTOMATICO
  BEGIN  
   UPDATE gnconve
      SET gnconve.intpconvenio = 3
    WHERE gnconve.cdconven in( 1
                              ,2
                              ,3
                              ,4
                              ,5
                              ,8
                              ,9
                              ,10
                              ,11
                              ,13
                              ,15
                              ,16
                              ,19
                              ,20
                              ,23
                              ,24
                              ,25
                              ,26
                              ,30
                              ,31
                              ,33
                              ,34
                              ,41
                              ,42
                              ,45
                              ,48
                              ,49
                              ,51
                              ,53
                              ,54
                              ,62
                              ,86
                              ,88
                              ,91
                              ,96
                              ,99
                              ,100
                              ,101
                              ,142);
  EXCEPTION
    WHEN OTHERS THEN
      dbms_output.put_line('3-ARRECADAÇÃO/DEBITO AUTOMATICO - ERRO: '|| sqlerrm);
  END;
  --
  COMMIT;
  --
END;

END pc_update_intpconvenio;  


PROCEDURE pc_update_agencia IS
  -- P565_2_DML0006_RF18_UPDATE_AGENCIA.sql
BEGIN

update gnconve a
set a.dsagercb = substr(a.dsagercb, 1, length(a.dsagercb)-1);
commit;
  
END pc_update_agencia;


PROCEDURE pc_flgindeb_origem_inclusao IS
-- P565_2_DML0003_RF015_UPDATE_GNCONVE_FLGINDEB_origem de inclusao.sql  
BEGIN
  
--RF015
declare
 vr_atualizado number := 0 ;
begin
  
  --Verificar se o script já foi executado, NÃO PODE RODAR DUAS VEZES
  select distinct 1
    into vr_atualizado  
    from gnconve t
   where cdconven in(15,30,82)
     and flgindeb = 3;
     
  if vr_atualizado = 0 then
       
    --3 - Misto
    /*begin      
      update gnconve t
         set flgindeb = 3
       where cdconven in(15,30,82);
       dbms_output.put_line('Convênio 15 Vivo, 30 Celesc e 82 WBT passaram a ser 3 - Misto ' );   
    exception
      when others then
        dbms_output.put_line('Erro ao atualizar o campo gnconve.flgindeb para 3 - Misto. '|| sqlerrm); 
    end; 
    --
    commit;
    --2 - Empresa Conveniada
    begin      
      update gnconve t
         set flgindeb = 2
       where flgindeb = 1;
       dbms_output.put_line('Inc.Deb = 1 passou a ser 2 - Empresa Conveniada '); 
    exception
      when others then
        dbms_output.put_line('Erro ao atualizar o campo gnconve.flgindeb para 2 - Empresa Conveniada. '|| sqlerrm); 
    end;
    --
    commit;
    --1 - Cooperativa
    begin      
      update gnconve t
         set flgindeb = 1
       where flgindeb = 0;
       dbms_output.put_line('Inc.Deb = 0 passou a ser 1 - Cooperativa ');    
    exception
      when others then
        dbms_output.put_line('Erro ao atualizar o campo gnconve.flgindeb para 1 - Cooperativa . '|| sqlerrm); 
    end;
    --
    commit;     
    --*/ 
	
	--Popular campo novo INORIGEM_INCLUSAO
	--3 - Misto
    begin      
      update gnconve t
         set inorigem_inclusao = 3
       where cdconven in(15,30,82);
       dbms_output.put_line('Convênio 15 Vivo, 30 Celesc e 82 WBT passaram a ser 3 - Misto no campo Origem de Inclusão' );   
    exception
      when others then
        dbms_output.put_line('Erro ao atualizar o campo gnconve.flgindeb para 3 - Misto. '|| sqlerrm); 
    end; 
    --
    commit;
    --2 - Empresa Conveniada
    begin      
      update gnconve t
         set inorigem_inclusao = 2
       where flgindeb = 1;
       dbms_output.put_line('Inc.Deb = 1 passou a ser 2 - Empresa Conveniada no campo Origem de Inclusão'); 
    exception
      when others then
        dbms_output.put_line('Erro ao atualizar o campo gnconve.flgindeb para 2 - Empresa Conveniada. '|| sqlerrm); 
    end;
    --
    commit;
    --1 - Cooperativa
    begin      
      update gnconve t
         set inorigem_inclusao = 1
       where flgindeb = 0;
       dbms_output.put_line('Inc.Deb = 0 passou a ser 1 - Cooperativa ');    
    exception
      when others then
        dbms_output.put_line('Erro ao atualizar o campo gnconve.flgindeb para 1 - Cooperativa no campo Origem de Inclusão. '|| sqlerrm); 
    end;
    --
    commit; 
	
  else
    dbms_output.put_line('Script já foi executado uma vez, não deve rodar novamente. '); 
	begin      
      update gnconve t
         set inorigem_inclusao = flgindeb;
       
       dbms_output.put_line('Origem de Inclusão recebeu o mesmo valor do campo Inc.Deb');    
    exception
      when others then
        dbms_output.put_line('Erro ao atualizar o campo gnconve.flgindeb para 1 - Cooperativa . '|| sqlerrm); 
    end;
	commit;
  end if;  
end;     

END pc_flgindeb_origem_inclusao;


PROCEDURE pc_permissao_acesso IS
-- P565_2_DML0009_RF022_PERMISSAO_ACESSO.SQL
BEGIN
  
   --RF022 - Permissão de Acesso. 
 --Retirar a opção de Replicação da tela CONVEN e criar a opção de ALTERACAO REPASSE - TABELA CRAPTEL
 --Liberar acesso para os usuários F0030503 e F0030642
  
 UPDATE CRAPTEL T
    SET t.cdopptel = 'A,C,E,I,AR',
        t.tldatela = 'Empresas Conveniadas',
        t.tlrestel = 'EMPRESAS CONVENIADAS',
        t.lsopptel = 'ALTERACAO,CONSULTA,EXCLUSAO,INCLUSAO,ALTERACAO REPASSE'
  WHERE NMDATELA = 'CONVEN';

commit; 

 --'F0030503', 'F0030642'
 DELETE  CRAPACE 
  WHERE UPPER(NMDATELA) = 'CONVEN'
    AND UPPER(CDDOPCAO) = 'AR'
    AND UPPER(CDOPERAD) in('F0030503','F0030642')
    AND IDAMBACE = 2
    AND CDCOOPER = 3; 
	
commit;

INSERT INTO CRAPACE
      (NMDATELA,
       CDDOPCAO,
       CDOPERAD,
       NMROTINA,
       CDCOOPER,
       NRMODULO,
       IDEVENTO,
       IDAMBACE)
      SELECT 'CONVEN', 'AR', OPE.CDOPERAD, ' ', COP.CDCOOPER, 1, 0, 2
        FROM CRAPCOP COP, CRAPOPE OPE
       WHERE COP.CDCOOPER IN (/*PR_CDCOOPER*/3)
         AND OPE.CDSITOPE = 1
         AND COP.CDCOOPER = OPE.CDCOOPER
         AND TRIM(UPPER(OPE.CDOPERAD)) = 'F0030503';

commit;	
	 
INSERT INTO CRAPACE
      (NMDATELA,
       CDDOPCAO,
       CDOPERAD,
       NMROTINA,
       CDCOOPER,
       NRMODULO,
       IDEVENTO,
       IDAMBACE)
      SELECT 'CONVEN', 'AR', OPE.CDOPERAD, ' ', COP.CDCOOPER, 1, 0, 2
        FROM CRAPCOP COP, CRAPOPE OPE
       WHERE COP.CDCOOPER IN (/*PR_CDCOOPER*/3)
         AND OPE.CDSITOPE = 1
         AND COP.CDCOOPER = OPE.CDCOOPER
         AND TRIM(UPPER(OPE.CDOPERAD)) = 'F0030642';
commit;		 

END pc_permissao_acesso;



PROCEDURE pc_dml0001 IS
  -- P565_2_DML0001.sql
BEGIN
  
BEGIN
  
-- substituir
-- nome_da_acao -> nome da acao na crapaca 
-- procedure_da_acao -> nome da procedure na crapaca 
-- package_da_acao -> nome da package na crapaca 
-- parametros_da_acao -> parâmetros de entrada da acao
-- BUSCAR_DESC_CONVENIOS
DECLARE
  -- alterar
  nome_da_acao VARCHAR2(40) := 'BUSCAR_DESC_CONVENIOS';
  procedure_da_acao VARCHAR2(100) := 'pc_busca_convenios';
  package_da_acao VARCHAR2(100) := 'TELA_CONVEN';
                                      
  parametros_da_acao VARCHAR2(4000):= 'pr_cdempres,pr_tparrecd,pr_cdempcon,pr_cdsegmto,pr_nmextcon,pr_nrregist,pr_nriniseq';
                                   -- 'pr_cdempres,pr_tparrecd,pr_cdempcon,pr_cdsegmto,pr_nmextcon,pr_nrregist,pr_nriniseq';
                                   -- 'pr_cdempres,pr_tparrecd,pr_cdempcon,pr_cdsegmento,pr_nmextcon,pr_nrregist,pr_nriniseq';
                                   -- 'pr_cdempres,pr_tparrecd,pr_cdempcon,pr_cdsegmento,pr_nmextcon,pr_nrregist,pr_nriniseq';
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
  parametros_da_acao VARCHAR2(4000):= 'pr_cddopcao,pr_tparrecd,pr_cdconven,pr_nmfantasia,pr_rzsocial,pr_cdhistor,pr_codfebraban,pr_cdsegmento,pr_vltarint,pr_vltartaa,pr_vltarcxa,pr_vltardeb,pr_vltarcor,pr_vltararq,pr_nrrenorm,pr_nrtolera,pr_dsdianor,pr_dtcancel,pr_layout_arrecadacao,pr_flgaccec,pr_flgacsic,pr_flgacbcb,pr_forma_arrecadacao';
                                   -- 'pr_cddopcao,pr_tparrecd,pr_cdconven,pr_nmfantasia,pr_rzsocial,pr_cdhistor,pr_codfebraban,pr_cdsegmento,pr_vltarint,pr_vltartaa,pr_vltarcxa,pr_vltardeb,pr_vltarcor,pr_vltararq,pr_nrrenorm,pr_nrtolera,pr_dsdianor,pr_dtcancel,pr_nrlayout,pr_flgaccec,pr_flgacsic,pr_flgacbcb,pr_forma_arrecadacao';
                                   -- 'pr_cddopcao,pr_tparrecd,pr_cdconven,pr_nmfantasia,pr_rzsocial,pr_cdhistor,pr_codfebraban,pr_cdsegmento,pr_vltarint,pr_vltartaa,pr_vltarcxa,pr_vltardeb,pr_vltarcor,pr_vltararq,pr_nrrenorm,pr_nrtolera,pr_dsdianor,pr_dtcancel,pr_nrlayout,pr_flgaccec,pr_flgacsic,pr_flgacbcb,pr_flginter,pr_forma_arrecadacao';
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
  parametros_da_acao VARCHAR2(4000):= 'pr_cddopcao,pr_tparrecd,pr_cdconven,pr_codfebraban,pr_cdsegmento,pr_nmfantasia,pr_rzsocial,pr_flgaccec,pr_flgacsic,pr_flgacbcb,pr_vltarint,pr_vltarcxa,pr_vltartaa,pr_vltardeb,pr_forma_arrecadacao,pr_layout_arrecadacao,pr_tam_optante,pr_origem_inclusao,pr_cod_arquivo,pr_cdcooper,pr_banco,pr_intpconvenio,pr_envia_relatorio_mensal,pr_arq_unico,pr_tipo_envio,pr_diretorio_accesstage,pr_vencto_contrato,pr_envia_relatorio_para,pr_seq_arrecadacao,pr_arq_arrecadacao,pr_envia_arq_parcial,pr_seq_parcial,pr_arq_parcial,pr_valida_vncto,pr_dias_tolera,pr_seq_integracao,pr_arq_integracao,pr_seq_cadastro_retorno,pr_arq_cadastro_optante,pr_arq_retorno,pr_layout_debito,pr_usa_agencia,pr_acata_duplicacao,pr_inclui_debito_facil,pr_envia_alterta_pos,pr_declaracao,pr_valida_cpfcnpj,pr_debita_sem_saldo,pr_envia_data_repasse,pr_identifica_fatura,pr_gera_reg_j,pr_hist_pagto,pr_hist_deb_auto,pr_hist_rep_ailos,pr_conta_deb_filiada,pr_repasse_banco,pr_repasse_agencia,pr_repasse_conta,pr_repasse_cnpj,pr_repasse_dia,pr_repasse_tipo';
                                  --- 'pr_cddopcao,pr_tparrecd,pr_cdconven,pr_codfebraban,pr_cdsegmento,pr_nmfantasia,pr_rzsocial,pr_flgaccec,pr_flgacsic,pr_flgacbcb,pr_vltarint,pr_vltarcxa,pr_vltartaa,pr_vltardeb,pr_forma_arrecadacao,pr_layout_arrecadacao,pr_tam_optante,pr_origem_inclusao,pr_cod_arquivo,pr_cdcooper,pr_banco,pr_intpconvenio,pr_envia_relatorio_mensal,pr_arq_unico,pr_tipo_envio,pr_diretorio_accesstage,pr_vencto_contrato,pr_envia_relatorio_para,pr_seq_arrecadacao,pr_arq_arrecadacao,pr_envia_arq_parcial,pr_seq_parcial,pr_arq_parcial,pr_valida_vncto,pr_dias_tolera,pr_seq_integracao,pr_arq_integracao,pr_seq_cadastro_retorno,pr_arq_cadastro_optante,pr_arq_retorno,pr_layout_debito,pr_usa_agencia,pr_acata_duplicacao,pr_inclui_debito_facil,pr_envia_alterta_pos,pr_declaracao,pr_valida_cpfcnpj,pr_debita_sem_saldo,pr_envia_data_repasse,pr_identifica_fatura,pr_gera_reg_j,pr_hist_pagto,pr_hist_deb_auto,pr_hist_rep_ailos,pr_conta_deb_filiada,pr_repasse_banco,pr_repasse_agencia,pr_repasse_conta,pr_repasse_cnpj,pr_repasse_dia,pr_repasse_tipo';
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



-- substituir
-- nome_da_acao -> nome da acao na crapaca 
-- procedure_da_acao -> nome da procedure na crapaca 
-- package_da_acao -> nome da package na crapaca 
-- parametros_da_acao -> parâmetros de entrada da acao
-- BUSCAR_DADOS_CONV
DECLARE
  -- alterar
  nome_da_acao VARCHAR2(40) := 'BUSCAR_DADOS_CONV';
  procedure_da_acao VARCHAR2(100) := 'pc_buscar_dados_web';
  package_da_acao VARCHAR2(100) := 'TELA_CONVEN';
  parametros_da_acao VARCHAR2(4000):= 'pr_cddopcao,pr_cdconven,pr_tparrecd';
                                   --   'pr_cddopcao,pr_cdconven,pr_tparrecd';
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



-- substituir
-- nome_da_acao -> nome da acao na crapaca 
-- procedure_da_acao -> nome da procedure na crapaca 
-- package_da_acao -> nome da package na crapaca 
-- parametros_da_acao -> parâmetros de entrada da acao
-- BUSCAR_TARIFAS_CONVEN
DECLARE
  -- alterar
  nome_da_acao VARCHAR2(40) := 'BUSCAR_TARIFAS_CONVEN';
  procedure_da_acao VARCHAR2(100) := 'pc_tarifas_historico_web';
  package_da_acao VARCHAR2(100) := 'TELA_CONVEN';
  parametros_da_acao VARCHAR2(4000):= 'pr_tipo_historico,pr_cdcooper,pr_cdhistor';
                                   -- 'pr_tipo_historico,pr_cdcooper,pr_cdhistor';
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
-- CDSEGMTO
insert into CECRED.TBCONV_DOMINIO_CAMPO (NMDOMINIO, CDDOMINIO, DSCODIGO)
values ('CDSEGMTO', '1', 'Prefeituras');
insert into CECRED.TBCONV_DOMINIO_CAMPO (NMDOMINIO, CDDOMINIO, DSCODIGO)
values ('CDSEGMTO', '2', 'Saneamento');
insert into CECRED.TBCONV_DOMINIO_CAMPO (NMDOMINIO, CDDOMINIO, DSCODIGO)
values ('CDSEGMTO', '3', 'Energia Elétria e Gás');
insert into CECRED.TBCONV_DOMINIO_CAMPO (NMDOMINIO, CDDOMINIO, DSCODIGO)
values ('CDSEGMTO', '4', 'Telecomunicações');
insert into CECRED.TBCONV_DOMINIO_CAMPO (NMDOMINIO, CDDOMINIO, DSCODIGO)
values ('CDSEGMTO', '5', 'Orgãos Governamentais');
insert into CECRED.TBCONV_DOMINIO_CAMPO (NMDOMINIO, CDDOMINIO, DSCODIGO)
values ('CDSEGMTO', '6', 'Orgãos identificados através do CNPJ');
insert into CECRED.TBCONV_DOMINIO_CAMPO (NMDOMINIO, CDDOMINIO, DSCODIGO)
values ('CDSEGMTO', '7', 'Multas de Trânsito');
insert into CECRED.TBCONV_DOMINIO_CAMPO (NMDOMINIO, CDDOMINIO, DSCODIGO)
values ('CDSEGMTO', '9', 'Uso interno do banco');
-- forma cobranca
insert into CECRED.TBCONV_DOMINIO_CAMPO (NMDOMINIO, CDDOMINIO, DSCODIGO)
values ('INCOBRANCA', '1', 'Nenhum');
insert into CECRED.TBCONV_DOMINIO_CAMPO (NMDOMINIO, CDDOMINIO, DSCODIGO)
values ('INCOBRANCA', '2', 'Útil');
insert into CECRED.TBCONV_DOMINIO_CAMPO (NMDOMINIO, CDDOMINIO, DSCODIGO)
values ('INCOBRANCA', '3', 'Corrido');
------------------------------------------Criação de Paramentros------------------------------------------
INSERT into cecred.crapprm
  (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
VALUES
  ('CONV', 0, 'CANAL_ENTRADA_CONVENIO', 'Canais de Entrada para Convenios', '2,3,4');
END;
  COMMIT;  
END;

END pc_dml0001;


PROCEDURE pc_dml19_INSERT_CRAPACA IS
-- P565_2_DML0019_INSERT_CRAPACA.sql
BEGIN
  -- crapaca tela_conven.pc_gera_extr_ted
  INSERT INTO CRAPACA (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
  VALUES ('GERAR_EXTRATO_TED','TELA_CONVEN','pc_gera_extr_ted','pr_cdcooper,pr_cdconven,pr_datarepasse',(SELECT a.nrseqrdr FROM CRAPRDR a WHERE a.nmprogra = 'TELA_CONVEN' AND ROWNUM = 1));
  COMMIT;
END pc_dml19_INSERT_CRAPACA;

PROCEDURE pc_ins_crapprg IS
-- pj565_2_ins_crapprg.sql
BEGIN

DECLARE
 X VARCHAR2(400);
BEGIN
  insert into crapprg (NMSISTEM, CDPROGRA, DSPROGRA##1, DSPROGRA##2, DSPROGRA##3, DSPROGRA##4, NRSOLICI, NRORDPRG, INCTRPRG, CDRELATO##1, CDRELATO##2, CDRELATO##3, CDRELATO##4, CDRELATO##5, INLIBPRG, CDCOOPER, PROGRESS_RECID, QTMINMED)
  values ('CRED', 'CONVEN', 'EMPRESAS CONVENIADAS', '.', '.', '.', 50, 997, 1, 789, 0, 0, 0, 0, 1, 1, 90, null);
EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
   NULL;
END;

END pc_ins_crapprg;

PROCEDURE pc_ins_craprel IS
  -- pj565_2_ins_craprel.sql
BEGIN


insert into craprel (CDRELATO, NRVIADEF, NRVIAMAX, NMRELATO, NRMODULO, NMDESTIN, NMFORMUL, INDAUDIT, CDCOOPER, PERIODIC, TPRELATO, INIMPREL, INGERPDF, DSDEMAIL, CDFILREL, NRSEQPRI)
values (789, 1, 1, 'EXTRADO DE TED', 5, ' ', '80col', 0, 1, 'Online', 1, 1, 1, ' ', null, null);

insert into craprel (CDRELATO, NRVIADEF, NRVIAMAX, NMRELATO, NRMODULO, NMDESTIN, NMFORMUL, INDAUDIT, CDCOOPER, PERIODIC, TPRELATO, INIMPREL, INGERPDF, DSDEMAIL, CDFILREL, NRSEQPRI)
values (789, 1, 1, 'EXTRADO DE TED', 5, ' ', '80col', 0, 2, 'Online', 1, 1, 1, ' ', null, null);

insert into craprel (CDRELATO, NRVIADEF, NRVIAMAX, NMRELATO, NRMODULO, NMDESTIN, NMFORMUL, INDAUDIT, CDCOOPER, PERIODIC, TPRELATO, INIMPREL, INGERPDF, DSDEMAIL, CDFILREL, NRSEQPRI)
values (789, 1, 1, 'EXTRADO DE TED', 5, ' ', '80col', 0, 3, 'Online', 1, 1, 1, ' ', null, null);

insert into craprel (CDRELATO, NRVIADEF, NRVIAMAX, NMRELATO, NRMODULO, NMDESTIN, NMFORMUL, INDAUDIT, CDCOOPER, PERIODIC, TPRELATO, INIMPREL, INGERPDF, DSDEMAIL, CDFILREL, NRSEQPRI)
values (789, 1, 1, 'EXTRADO DE TED', 5, ' ', '80col', 0, 4, 'Online', 1, 1, 1, ' ', null, null);

insert into craprel (CDRELATO, NRVIADEF, NRVIAMAX, NMRELATO, NRMODULO, NMDESTIN, NMFORMUL, INDAUDIT, CDCOOPER, PERIODIC, TPRELATO, INIMPREL, INGERPDF, DSDEMAIL, CDFILREL, NRSEQPRI)
values (789, 1, 1, 'EXTRADO DE TED', 5, ' ', '80col', 0, 5, 'Online', 1, 1, 1, ' ', null, null);

insert into craprel (CDRELATO, NRVIADEF, NRVIAMAX, NMRELATO, NRMODULO, NMDESTIN, NMFORMUL, INDAUDIT, CDCOOPER, PERIODIC, TPRELATO, INIMPREL, INGERPDF, DSDEMAIL, CDFILREL, NRSEQPRI)
values (789, 1, 1, 'EXTRADO DE TED', 5, ' ', '80col', 0, 6, 'Online', 1, 1, 1, ' ', null, null);

insert into craprel (CDRELATO, NRVIADEF, NRVIAMAX, NMRELATO, NRMODULO, NMDESTIN, NMFORMUL, INDAUDIT, CDCOOPER, PERIODIC, TPRELATO, INIMPREL, INGERPDF, DSDEMAIL, CDFILREL, NRSEQPRI)
values (789, 1, 1, 'EXTRADO DE TED', 5, ' ', '80col', 0, 7, 'Online', 1, 1, 1, ' ', null, null);

insert into craprel (CDRELATO, NRVIADEF, NRVIAMAX, NMRELATO, NRMODULO, NMDESTIN, NMFORMUL, INDAUDIT, CDCOOPER, PERIODIC, TPRELATO, INIMPREL, INGERPDF, DSDEMAIL, CDFILREL, NRSEQPRI)
values (789, 1, 1, 'EXTRADO DE TED', 5, ' ', '80col', 0, 8, 'Online', 1, 1, 1, ' ', null, null);

insert into craprel (CDRELATO, NRVIADEF, NRVIAMAX, NMRELATO, NRMODULO, NMDESTIN, NMFORMUL, INDAUDIT, CDCOOPER, PERIODIC, TPRELATO, INIMPREL, INGERPDF, DSDEMAIL, CDFILREL, NRSEQPRI)
values (789, 1, 1, 'EXTRADO DE TED', 5, ' ', '80col', 0, 9, 'Online', 1, 1, 1, ' ', null, null);

insert into craprel (CDRELATO, NRVIADEF, NRVIAMAX, NMRELATO, NRMODULO, NMDESTIN, NMFORMUL, INDAUDIT, CDCOOPER, PERIODIC, TPRELATO, INIMPREL, INGERPDF, DSDEMAIL, CDFILREL, NRSEQPRI)
values (789, 1, 1, 'EXTRADO DE TED', 5, ' ', '80col', 0, 10, 'Online', 1, 1, 1, ' ', null, null);

insert into craprel (CDRELATO, NRVIADEF, NRVIAMAX, NMRELATO, NRMODULO, NMDESTIN, NMFORMUL, INDAUDIT, CDCOOPER, PERIODIC, TPRELATO, INIMPREL, INGERPDF, DSDEMAIL, CDFILREL, NRSEQPRI)
values (789, 1, 1, 'EXTRADO DE TED', 5, ' ', '80col', 0, 11, 'Online', 1, 1, 1, ' ', null, null);

insert into craprel (CDRELATO, NRVIADEF, NRVIAMAX, NMRELATO, NRMODULO, NMDESTIN, NMFORMUL, INDAUDIT, CDCOOPER, PERIODIC, TPRELATO, INIMPREL, INGERPDF, DSDEMAIL, CDFILREL, NRSEQPRI)
values (789, 1, 1, 'EXTRADO DE TED', 5, ' ', '80col', 0, 12, 'Online', 1, 1, 1, ' ', null, null);

insert into craprel (CDRELATO, NRVIADEF, NRVIAMAX, NMRELATO, NRMODULO, NMDESTIN, NMFORMUL, INDAUDIT, CDCOOPER, PERIODIC, TPRELATO, INIMPREL, INGERPDF, DSDEMAIL, CDFILREL, NRSEQPRI)
values (789, 1, 1, 'EXTRADO DE TED', 5, ' ', '80col', 0, 13, 'Online', 1, 1, 1, ' ', null, null);

insert into craprel (CDRELATO, NRVIADEF, NRVIAMAX, NMRELATO, NRMODULO, NMDESTIN, NMFORMUL, INDAUDIT, CDCOOPER, PERIODIC, TPRELATO, INIMPREL, INGERPDF, DSDEMAIL, CDFILREL, NRSEQPRI)
values (789, 1, 1, 'EXTRADO DE TED', 5, ' ', '80col', 0, 14, 'Online', 1, 1, 1, ' ', null, null);

insert into craprel (CDRELATO, NRVIADEF, NRVIAMAX, NMRELATO, NRMODULO, NMDESTIN, NMFORMUL, INDAUDIT, CDCOOPER, PERIODIC, TPRELATO, INIMPREL, INGERPDF, DSDEMAIL, CDFILREL, NRSEQPRI)
values (789, 1, 1, 'EXTRADO DE TED', 5, ' ', '80col', 0, 16, 'Online', 1, 1, 1, ' ', null, null);

END pc_ins_craprel;

PROCEDURE pc_dml0020_update_crapaca IS
 --P565_2_DML0020_UPDATE_CRAPACA.sql
BEGIN
  --RF002 - Ajustes tela PARHPG
UPDATE CRAPACA
   SET CRAPACA.LSTPARAM = 'pr_cddopcao,pr_cdcooper,pr_hrsicatu,pr_hrsicini,pr_hrsicfim,pr_hrbanatu,pr_hrbanini,pr_hrbanfim,pr_hrtitatu,pr_hrtitini,pr_hrtitfim,pr_hrnetatu,pr_hrnetini,pr_hrnetfim,pr_hrtaaatu,pr_hrtaaini,pr_hrtaafim,pr_hrgpsatu,pr_hrgpsini,pr_hrgpsfim,pr_hrsiccau,pr_hrsiccan,pr_hrbancau,pr_hrbancan,pr_hrtitcau,pr_hrtitcan,pr_hrnetcau,pr_hrnetcan,pr_hrtaacau,pr_hrtaacan,pr_hrdiuatu,pr_hrdiuini,pr_hrdiufim,pr_hrnotatu,pr_hrnotini,pr_hrnotfim'
 WHERE nrseqrdr = (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TELA_PARHPG')
   AND NMDEACAO = 'ALTERA_HORARIO_PARHPG';
END pc_dml0020_update_crapaca;

PROCEDURE pc_upd_crapprg IS 
-- pj565_2_upd_crapprg.sql
BEGIN
    --Cadastro na tabela de programas para o relatorio crrl789   
		update crapprg prg
         set cdrelato##1 = 789
         WHERE UPPER(prg.cdprogra) = UPPER('CONVEN');
END pc_upd_crapprg;

PROCEDURE pc_dml0005_insert_crapaca IS
--P565_2_DML0005_INSERT_CRAPACA.sql
BEGIN
  DELETE FROM CRAPACA
 WHERE nrseqrdr =
       (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TELA_CONVEN')
   AND NMDEACAO = 'BUSCAR_DADOS_LIBERACAO_CONV';
  
INSERT INTO cecred.crapaca
  (nrseqaca, nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
VALUES
  (SEQACA_NRSEQACA.NEXTVAL,
   'BUSCAR_DADOS_LIBERACAO_CONV',
   'TELA_CONVEN',
   'pc_busca_liberacao_conve_web',
   'pr_tparrecad,pr_cdempres,pr_cdconven,pr_cdempcon,pr_cdsegmto',
   (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TELA_CONVEN'));
COMMIT;

DELETE FROM CRAPACA
 WHERE nrseqrdr =
       (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TELA_CONVEN')
   AND NMDEACAO = 'GRAVAR_DADOS_CONVEN_LIB';
  
INSERT INTO cecred.crapaca
  (nrseqaca, nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
VALUES
  (SEQACA_NRSEQACA.NEXTVAL,
   'GRAVAR_DADOS_CONVEN_LIB',
   'TELA_CONVEN',
   'pc_gravar_liberacao_conve_web',
   '',
   (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TELA_CONVEN'));
COMMIT;

DELETE CRAPACA
 WHERE nrseqrdr =
       (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TELA_CONVEN')
   AND NMDEACAO = 'BUSCA_COOP_CONVEN_AILOS';
  
INSERT INTO cecred.crapaca
  (nrseqaca, nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
VALUES
  (SEQACA_NRSEQACA.NEXTVAL,
   'BUSCA_COOP_CONVEN_AILOS',
   'TELA_CONVEN',
   'pc_busca_coop_conven_web',
   '',
   (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TELA_CONVEN'));
COMMIT;

DELETE CRAPACA
 WHERE nrseqrdr =
       (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TELA_CONVEN')
   AND NMDEACAO = 'BUSCA_FORMA_ARRECADACAO';
  
INSERT INTO cecred.crapaca
  (nrseqaca, nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
VALUES
  (SEQACA_NRSEQACA.NEXTVAL,
   'BUSCA_FORMA_ARRECADACAO',
   'TELA_CONVEN',
   'pc_busca_forma_arrecad_web',
   'pr_cdcooper,pr_cdempcon,pr_cdsegmto',
   (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TELA_CONVEN'));
COMMIT;

END pc_dml0005_insert_crapaca;

PROCEDURE pc_atualizacao_base IS
  -- pj565_2_scripts_atualizacao_base.sql
BEGIN
 --Script para atualização de Campo 'flgvalidavencto' para as empresas que estavam fixas 
  update cecred.gnconve gnconve
     set gnconve.flgvalidavencto= 1
   where gnconve.cdhiscxa in (2258,2271,2275,2262,659,2268,2297,2295,2286,2273,692,2549,2551);
   
 --Script para atualização de Campo 'nrdias_tolerancia' para empresa 'SANEPAR'
  update cecred.gnconve gnconve
     set gnconve.nrdias_tolerancia = 25
   where gnconve.cdhiscxa = 2262;
   
 --Script para atualização de campo 'flgacata_dup' Unimed(22) e Liberty(55)
  update cecred.gnconve gnconve
     set gnconve.flgacata_dup = 1
   where gnconve.cdconven in (22,55);
   
 --Scrip para atualização campo 'flgdebfacil' SAMAE ILHOTA DA - AGUAS GUARAMIRIM DA - AGUAS SCHROEDER DA
   update cecred.gnconve
	  set gnconve.flgdebfacil = 1
	where gnconve.cdconven in (108,87,126)
	  and gnconve.intpconvenio in(2,3) 
	  and gnconve.inorigem_inclusao in (1,3);

 --Scrip para atualização campo 'flgenv_dt_repasse' PREVISC -    
	update cecred.gnconve 
	  set  gnconve.flgenv_dt_repasse = 1
	where gnconve.cdconven in (128,127,112,085,47,48,50,55,57,58,66,68,22,32,38,46,64,1,25,26,33,39,41,43,62);  	  
	
  --Scrip para atualização campo 'qttamanho_optante'  	
   update cecred.gnconve
	set gnconve.qttamanho_optante = 6
	where gnconve.cdconven in (8, 16, 19, 20, 25, 26, 11, 49); 
	
	update cecred.gnconve
	set gnconve.qttamanho_optante = 8
	where gnconve.cdconven in (4, 24, 31, 33, 53, 54, 108, 96); 
	
	update cecred.gnconve
	set gnconve.qttamanho_optante = 9
	where gnconve.cdconven in (2, 10, 5, 30, 14, 45); 
	
    update cecred.gnconve
	set gnconve.qttamanho_optante = 20
	where gnconve.cdconven in (3, 48); 
	
	update cecred.gnconve
	set gnconve.qttamanho_optante = 11
	where gnconve.cdconven = 15; 
	
	update cecred.gnconve
	set gnconve.qttamanho_optante = 19
	where gnconve.cdconven = 22; 
  
	update cecred.gnconve
     set gnconve.qttamanho_optante = 8
   where gnconve.cdconven = 101;
   
   update cecred.gnconve
     set gnconve.qttamanho_optante = 8
   where gnconve.cdconven = 108;
   
   update cecred.gnconve
     set gnconve.qttamanho_optante = 22
   where gnconve.cdconven = 127;
      
   update cecred.gnconve
     set gnconve.qttamanho_optante = 22
   where gnconve.cdconven = 128;
   
   update cecred.gnconve
     set gnconve.qttamanho_optante = 10
   where gnconve.cdconven = 41;
   
   update cecred.gnconve
     set gnconve.qttamanho_optante = 9
   where gnconve.cdconven = 51;
   
   update cecred.gnconve
     set gnconve.qttamanho_optante = 12
   where gnconve.cdconven = 66;
   
   update cecred.gnconve
     set gnconve.qttamanho_optante = 10
   where gnconve.cdconven = 87;

END pc_atualizacao_base;

PROCEDURE pc_canalcoop_liberado IS
-- P565_2_DML0002_INSERT_TBCONV_CANALCOOP_LIBERADO.sql
BEGIN

declare

  vr_idseqconvelib number := null;
  vr_idsequencia   number := null;
  vr_ativo         number := null;  
  vr_flgliberado   number := null;   
  
  /*
DELETE Tbconv_Canalcoop_Liberado;
DELETE TBCONV_LIBERACAO;
COMMIT;
*/
/*
select * from TBCONV_LIBERACAO t;
select * from Tbconv_Canalcoop_Liberado*/
  
  --Convênios AILOS
  cursor cr_gnconve is  
    select 3  tparrecd, 
           'AILOS' dstparrecd,
           gnconve.cdconven,
           gnconve.cdcooper,--3 - ailos
           gnconve.flgativo,
           gnconve.cdhiscxa,
           gnconve.cdhisdeb,           
           gnconve.intpconvenio,
           decode(gnconve.intpconvenio,1,'ARRECADAÇÃO',2,'DEBITO AUTOMATICO',3,'ARRECADAÇÃO/DEBITO AUTOMATICO',gnconve.intpconvenio) dsintpconvenio
      from gnconve
     where gnconve.intpconvenio is not null
       --and gnconve.cdconven = 48
     order by gnconve.intpconvenio;
     
  --Convênios BANCOOB
  cursor cr_tbconv_arrecadacao is
    select t.tparrecadacao tparrecd, 
           'BANCOOB' dstparrecd,
           t.cdempres cdconven,
           1 flgativo,
           1 intpconvenio, --(para o bancoob só existe tipo de convenio de arrecadação)
           'ARRECADAÇÃO' dsintpconvenio, 
           t.cdempcon,
           t.cdsegmto,
           crapcon.cdcooper           
      from tbconv_arrecadacao t,
           crapcon, 
           crapcop c
     where t.cdempcon = crapcon.cdempcon
       and t.cdsegmto = crapcon.cdsegmto
       and crapcon.cdcooper = c.cdcooper
       and c.flgativo = 1
       and t.cdempres is not null
       and t.tparrecadacao = 2 --bancoob  
       --and t.cdempres = 24756  
     order by t.cdempres, c.cdcooper;
     
  --Cooperativas ativas   
  cursor cr_crapcop is
    select crapcop.cdcooper
      from crapcop 
     where crapcop.flgativo = 1
     ORDER BY crapcop.cdcooper;   
  
  --Arrecadação (AILOS)  
  cursor cr_crapcon( pr_cdhiscxa number
                    ,pr_cdcooper number
                    ,pr_tparrecd number) is
    select crapcon.tparrecd,
           decode(crapcon.tparrecd,1,'SICREDI',2,'BANCOOB',3,'AILOS',crapcon.tparrecd) dstparrecd,--Tipo de arrecadacao efetuada na cooperativa (1-Sicredi/ 2-Bancoob/ 3-Cecred)
           crapcon.cdcooper,
           crapcon.cdsegmto,
           decode(crapcon.cdsegmto,1,' - Prefeituras' 
                                  ,2,' - Saneamento'
                                  ,3,' - Energia Elétria e Gás'
                                  ,4,' - Telecomunicações'
                                  ,5,' - Orgãos Governamentais'
                                  ,6,' - Orgãos identificados através do CNPJ'
                                  ,7,' - Multas de Trânsito'
                                  ,9,' - Uso interno do banco',crapcon.cdsegmto) dscdsegmto,
           crapcon.cdempcon,
           crapcon.NMRESCON           
      from crapcon
     where crapcon.cdhistor = pr_cdhiscxa
       and crapcon.tparrecd = pr_tparrecd --2-Bancoob e 3-AILOS
       and crapcon.cdcooper = pr_cdcooper;
   
  --Canais  
  cursor cr_canal is
    select t.cdcanal,t.nmcanal 
      from tbgen_canal_entrada t
     where t.cdcanal in(2,3,4); 
  
  --Verificar se já existe o Convênio 
  cursor cr_liberacao(pr_tparrecd  tbconv_liberacao.tparrecadacao%type, 
                      pr_cdcooper  tbconv_liberacao.cdcooper%type, 
                      pr_cdconven  tbconv_liberacao.cdcooper%type) is
     select t.idseqconvelib
       from tbconv_liberacao t
      where t.tparrecadacao = pr_tparrecd
        and t.cdcooper = pr_cdcooper
        and ((pr_tparrecd = 3 and t.cdconven = pr_cdconven)
            or(pr_tparrecd = 2 and t.cdempres = pr_cdconven));
  
  --Verificar se já existe o Canal    
  cursor cr_libcanal( pr_idseqconvelib tbconv_canalcoop_liberado.idsequencia%type,
                      pr_cdsegmto      tbconv_canalcoop_liberado.cdsegmto%type, 
                      pr_cdempcon      tbconv_canalcoop_liberado.cdempcon%type, 
                      pr_cdcanal       tbconv_canalcoop_liberado.cdcanal%type) is
    select t.idsequencia 
      from tbconv_canalcoop_liberado t                          
     where t.idseqconvelib = pr_idseqconvelib
       and t.cdsegmto = pr_cdsegmto
       and t.cdempcon = pr_cdempcon
       and t.cdcanal  = pr_cdcanal; 
     
begin
  --------------------------------------------------------------------
  --Convênios BANCOOB
  --------------------------------------------------------------------
  dbms_output.put_line(' ------------------BANCOOB ------------------------------- ');
      
  for rw_conve in cr_tbconv_arrecadacao loop
     
    dbms_output.put_line('   Convênio: '|| rw_conve.cdconven 
                          || ' Cooper.: '||rw_conve.cdcooper
                          || ' - '||rw_conve.dsintpconvenio);
               
    --Inserir Liberação por cooperativa
    vr_idseqconvelib := null; 
    open cr_liberacao(rw_conve.tparrecd, rw_conve.cdcooper, rw_conve.cdconven);
    fetch cr_liberacao into vr_idseqconvelib;
    close cr_liberacao;  
    if vr_idseqconvelib is null then
      --INSERIR tbconv_liberacao    
      begin            
        insert into tbconv_liberacao
          (idseqconvelib, tparrecadacao, cdcooper, cdempres, cdconven, flgautdb)
        values
          (tbconv_liberacao_seq.nextval, rw_conve.tparrecd, rw_conve.cdcooper, rw_conve.cdconven, 0, 0)
         returning tbconv_liberacao.idseqconvelib INTO vr_idseqconvelib;        
      exception
        when others then
          dbms_output.put_line('Erro ao inserir na tabela tbconv_liberacao - '
             || ' tparrecd: '|| rw_conve.tparrecd
             || ' cdcooper: '|| rw_conve.cdcooper
             || ' cdempres: '|| rw_conve.cdconven
             || ' intpconvenio: '|| rw_conve.intpconvenio
             || sqlerrm);      
      end;
          
      /*dbms_output.put_line('        Cadastro na tabela tbconv_liberacao - '
             || ' tparrecd: '|| rw_conve.tparrecd
             || ' cdcooper: '|| rw_conve.cdcooper
             || ' cdconven: '|| rw_conve.cdconven
             || ' intpconvenio: '|| rw_conve.intpconvenio);*/
    else
      --Atualizar a tbconv_liberacao 
      begin            
        update tbconv_liberacao
           set flgautdb = 0
         where idseqconvelib = vr_idseqconvelib;                   
      exception
        when others then
          dbms_output.put_line('Erro ao atualizar na tabela tbconv_liberacao - '
             || ' tparrecd: '|| rw_conve.tparrecd
             || ' cdcooper: '|| rw_conve.cdcooper
             || ' cdconven: '|| rw_conve.cdconven
             || ' intpconvenio: '|| rw_conve.intpconvenio
             || sqlerrm);      
      end; 
        
      /*dbms_output.put_line('    Cadastro na tabela tbconv_liberacao - '
             || ' tparrecd: '|| rw_conve.tparrecd
             || ' cdcooper: '|| rw_conve.cdcooper
             || ' cdconven: '|| rw_conve.cdconven
             || ' intpconvenio: '|| rw_conve.intpconvenio);*/
                  
    end if;
      
    --Se TipoConvênio for 1 - arrecadação OU 3-arrecadacao/deb.aut.
    if rw_conve.intpconvenio in(1,3) and vr_idseqconvelib is not null then
        
      --Inserir os canais   
      for rw_canais in cr_canal loop
        
		--INTERNET
        if rw_canais.cdcanal = 3 then
          vr_flgliberado := 1;
        else
		  vr_flgliberado := 0;
        end if;
  		
        vr_idsequencia := null; 
        open cr_libcanal(vr_idseqconvelib,rw_conve.cdsegmto, rw_conve.cdempcon, rw_canais.cdcanal); 
        fetch cr_libcanal into vr_idsequencia;   
        if cr_libcanal%notfound then
          --inserir tbconv_canalcoop_liberado 
          begin
            insert into tbconv_canalcoop_liberado
              (idsequencia, idseqconvelib, cdsegmto, cdempcon, cdcanal, flgliberado)
            values
              (tbconv_canalcoop_liberado_seq.nextval, vr_idseqconvelib, rw_conve.cdsegmto, rw_conve.cdempcon, rw_canais.cdcanal, vr_flgliberado);
          exception
            when others then
              dbms_output.put_line('Erro ao inserir na tabela tbconv_canalcoop_liberado - '          
               || ' vr_idseqconvelib: '|| vr_idseqconvelib
               || ' cdsegmto: '|| rw_conve.cdsegmto
               || ' cdempcon: '||rw_conve.cdempcon
               || ' cdcanal: '|| rw_canais.cdcanal
               || sqlerrm);     
          end;              
        else
          --Atualizar tbconv_canalcoop_liberado
          begin
            update tbconv_canalcoop_liberado
               set flgliberado = vr_flgliberado
             where idsequencia = vr_idsequencia; 
           
          exception
            when others then
              dbms_output.put_line('Erro ao atualizar na tabela tbconv_canalcoop_liberado - '          
               || ' vr_idseqconvelib: '|| vr_idseqconvelib
               || ' cdsegmto: '|| rw_conve.cdsegmto
               || ' cdempcon: '||rw_conve.cdempcon
               || ' cdcanal: '|| rw_canais.cdcanal
               || sqlerrm);     
          end;  
        end if; 
        close cr_libcanal;
            
        /*dbms_output.put_line('            Canais - '          
               || ' vr_idseqconvelib: '|| vr_idseqconvelib
               || ' cdsegmto: '|| rw_conve.cdsegmto
               || ' cdempcon: '||rw_conve.cdempcon
               || ' cdcanal: '|| rw_canais.cdcanal);*/
                   
      end loop; --Fim Canais -      
    end if;--Fim TipoConvênio for 1 - arrecadação OU 3-arrecadacao/deb.aut.              
  end loop;  --Fim Convênio
  --
  commit;
  --------------------------------------------------------------------
  --Convênios AILOS
  --------------------------------------------------------------------
  dbms_output.put_line(' ------------------AILOS   ------------------------------- ');
  
  for rw_gnconve in cr_gnconve loop
    
    dbms_output.put_line('Convênio: '|| rw_gnconve.cdconven || ' - '|| rw_gnconve.dstparrecd
                          || ' Cooperativa: '|| rw_gnconve.cdcooper
                          || ' Ativo: '|| rw_gnconve.flgativo
                          || ' Tipo Convênio: '||rw_gnconve.intpconvenio||' - '||rw_gnconve.dsintpconvenio);
               
    --Cooperativas Ativas
    for rw_crapcop in cr_crapcop loop
      
      dbms_output.put_line('    Cooperativa - crapcop.cdcooper: '|| rw_crapcop.cdcooper );
      
      --Regra para Ativas Canais/Deb.Aut.  - 3 = AILOS
      if rw_gnconve.cdcooper = 3 then
        if rw_gnconve.flgativo = 1 then
          vr_ativo := 1;
        else
          vr_ativo := 0;
        end if;    
      else
        --Replicar para todas as coopertivas, mas Ativar apenas para a propria cooperativa
        if rw_crapcop.cdcooper = rw_gnconve.cdcooper and rw_gnconve.flgativo = 1 then
          vr_ativo := 1;
        else
          vr_ativo := 0;        
        end if;
      end if;
      
      --Inserir Liberação por cooperativa
      vr_idseqconvelib := null; 
      open cr_liberacao(rw_gnconve.tparrecd, rw_crapcop.cdcooper, rw_gnconve.cdconven);
      fetch cr_liberacao into vr_idseqconvelib;
      close cr_liberacao;  
      if vr_idseqconvelib is null then
        --INSERIR tbconv_liberacao    
        begin            
          insert into tbconv_liberacao
            (idseqconvelib, tparrecadacao, cdcooper, cdempres, cdconven, flgautdb)
          values
            (tbconv_liberacao_seq.nextval, rw_gnconve.tparrecd, rw_crapcop.cdcooper, 0, rw_gnconve.cdconven, decode(rw_gnconve.intpconvenio,3,vr_ativo,2,vr_ativo,0))
           returning tbconv_liberacao.idseqconvelib INTO vr_idseqconvelib;        
        exception
          when others then
            dbms_output.put_line('Erro ao inserir na tabela tbconv_liberacao - '
               || ' tparrecd: '|| rw_gnconve.tparrecd
               || ' cdcooper: '|| rw_crapcop.cdcooper
               || ' cdconven: '|| rw_gnconve.cdconven
               || ' intpconvenio: '|| rw_gnconve.intpconvenio
               || sqlerrm);      
        end;
          
       /* dbms_output.put_line('        Cadastro na tabela tbconv_liberacao - '
               || ' tparrecd: '|| rw_gnconve.tparrecd
               || ' cdcooper: '|| rw_crapcop.cdcooper
               || ' cdconven: '|| rw_gnconve.cdconven
               || ' intpconvenio: '|| rw_gnconve.intpconvenio);*/
      else
        --Atualizar a tbconv_liberacao 
        begin            
          update tbconv_liberacao
             set flgautdb = decode(rw_gnconve.intpconvenio,3,vr_ativo,2,vr_ativo,0)
           where idseqconvelib = vr_idseqconvelib;                   
        exception
          when others then
            dbms_output.put_line('Erro ao atualizar na tabela tbconv_liberacao - '
               || ' tparrecd: '|| rw_gnconve.tparrecd
               || ' cdcooper: '|| rw_crapcop.cdcooper
               || ' cdconven: '|| rw_gnconve.cdconven
               || ' intpconvenio: '|| rw_gnconve.intpconvenio
               || sqlerrm);      
        end; 
        
        /*dbms_output.put_line('    Cadastro na tabela tbconv_liberacao - '
               || ' tparrecd: '|| rw_gnconve.tparrecd
               || ' cdcooper: '|| rw_crapcop.cdcooper
               || ' cdconven: '|| rw_gnconve.cdconven
               || ' intpconvenio: '|| rw_gnconve.intpconvenio);*/
                  
      end if;
      
      --Se TipoConvênio for 1 - arrecadação OU 3-arrecadacao/deb.aut.
      if rw_gnconve.intpconvenio in(1,3) and vr_idseqconvelib is not null then
        --Busca na crapcon
        for rw_crapcon in cr_crapcon(rw_gnconve.cdhiscxa
                                    ,rw_crapcop.cdcooper
                                    ,rw_gnconve.tparrecd )loop
          --Inserir os canais   
          for rw_canais in cr_canal loop
             
            vr_idsequencia := null; 
            open cr_libcanal(vr_idseqconvelib,rw_crapcon.cdsegmto, rw_crapcon.cdempcon, rw_canais.cdcanal); 
            fetch cr_libcanal into vr_idsequencia;   
            if cr_libcanal%notfound then
              --inserir tbconv_canalcoop_liberado 
              begin
                insert into tbconv_canalcoop_liberado
                  (idsequencia, idseqconvelib, cdsegmto, cdempcon, cdcanal, flgliberado)
                values
                  (tbconv_canalcoop_liberado_seq.nextval, vr_idseqconvelib, rw_crapcon.cdsegmto, rw_crapcon.cdempcon, rw_canais.cdcanal, vr_ativo);
              exception
                when others then
                  dbms_output.put_line('Erro ao inserir na tabela tbconv_canalcoop_liberado - '          
                   || ' vr_idseqconvelib: '|| vr_idseqconvelib
                   || ' cdsegmto: '|| rw_crapcon.cdsegmto
                   || ' cdempcon: '||rw_crapcon.cdempcon
                   || ' cdcanal: '|| rw_canais.cdcanal
                   || sqlerrm);     
              end;              
            else
              --Atualizar tbconv_canalcoop_liberado
              begin
                update tbconv_canalcoop_liberado
                   set flgliberado = vr_ativo
                 where idsequencia = vr_idsequencia; 
           
              exception
                when others then
                  dbms_output.put_line('Erro ao atualizar na tabela tbconv_canalcoop_liberado - '          
                   || ' vr_idseqconvelib: '|| vr_idseqconvelib
                   || ' cdsegmto: '|| rw_crapcon.cdsegmto
                   || ' cdempcon: '||rw_crapcon.cdempcon
                   || ' cdcanal: '|| rw_canais.cdcanal
                   || sqlerrm);     
              end;  
            end if; 
            close cr_libcanal;
            
           /* dbms_output.put_line('            Canais - '          
                   || ' vr_idseqconvelib: '|| vr_idseqconvelib
                   || ' cdsegmto: '|| rw_crapcon.cdsegmto
                   || ' cdempcon: '||rw_crapcon.cdempcon
                   || ' cdcanal: '|| rw_canais.cdcanal);*/
                   
          end loop; --Fim Canais -      
        end loop;--Fim  Arrecadação - crapcon
        
      end if;--Fim TipoConvênio for 1 - arrecadação OU 3-arrecadacao/deb.aut.              
      
    end loop;  --Fim Cooperativas ativas
  end loop; --Fim Convênio
  commit;
end;     

END pc_canalcoop_liberado;

BEGIN
  
  pc_update_intpconvenio();  
  pc_update_agencia();
  pc_flgindeb_origem_inclusao();
  pc_permissao_acesso();
  pc_dml0001();
  pc_dml19_insert_crapaca();
  pc_ins_crapprg();
  pc_ins_craprel();
  pc_dml0020_update_crapaca();
  pc_upd_crapprg();
  pc_dml0005_insert_crapaca();
  pc_atualizacao_base();
  pc_canalcoop_liberado();

END;
