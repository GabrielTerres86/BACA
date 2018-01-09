CREATE OR REPLACE PACKAGE CECRED.tela_parmon IS

PROCEDURE pc_alterar_parmon_pld(                             
                              pr_cdcooper                            IN tbcc_monitoramento_parametro.cdcooper%TYPE                       --> codigo da cooperativa
                             ,pr_cdcoptel                            IN VARCHAR2                                                         --> Codigo da cooperativa escolhida pela cecred
                             ,pr_qtrenda_diario_pf                   IN tbcc_monitoramento_parametro.qtrenda_diario_pf%TYPE              --> qt vezes da renda do cooperado para alerta diario
                             ,pr_qtrenda_diario_pj                   IN tbcc_monitoramento_parametro.qtrenda_diario_pj%TYPE              --> qt vezes da renda do cooperado para alerta diario
                             ,pr_vlcredito_diario_pf                 IN tbcc_monitoramento_parametro.vlcredito_diario_pf%TYPE            --> Total creditos pelo cooperado alerta diario
                             ,pr_vlcredito_diario_pj                 IN tbcc_monitoramento_parametro.vlcredito_diario_pj%TYPE            --> Total creditos pelo cooperado alerta diario
                             ,pr_qtrenda_mensal_pf                   IN tbcc_monitoramento_parametro.qtrenda_mensal_pf %TYPE             --> qt vezes da renda do cooperado para alerta mensal
                             ,pr_qtrenda_mensal_pj                   IN tbcc_monitoramento_parametro.qtrenda_mensal_pf%TYPE              --> qt vezes da renda do cooperado para alerta mensal
                             ,pr_vlcredito_mensal_pf                 IN tbcc_monitoramento_parametro.vlcredito_mensal_pf%TYPE            --> Total creditos pelo cooperado alerta mensal
                             ,pr_vlcredito_mensal_pj                 IN tbcc_monitoramento_parametro.vlcredito_mensal_pj%TYPE            --> Total creditos pelo cooperado alerta mensal
                             ,pr_inrenda_zerada                      IN tbcc_monitoramento_parametro.inrenda_zerada%TYPE                 -->indicador de renda zerada
                             ,pr_vllimite_saque                      IN tbcc_monitoramento_parametro.vllimite_saque%TYPE                 --> somatoria valor saques em especie
                             ,pr_vllimite_deposito                   IN tbcc_monitoramento_parametro.vllimite_deposito%TYPE              --> somatorioa deposito em especie
                             ,pr_vllimite_pagamento                  IN tbcc_monitoramento_parametro.vllimite_pagamento%TYPE             --> somatoria pagamentos em especie
                             ,pr_vlprovisao_email                    IN tbcc_monitoramento_parametro.vlprovisao_email%TYPE               --> valor provisao para envio email
                             ,pr_vlprovisao_saque                    IN tbcc_monitoramento_parametro.vlprovisao_saque%TYPE               --> valor provisao saque
                             ,pr_vlmon_pagto                         IN tbcc_monitoramento_parametro.vlmonitoracao_pagamento%TYPE        --> valor monitocarao pagamento
                             ,pr_qtdias_provisao                     IN tbcc_monitoramento_parametro.qtdias_provisao%TYPE                --> dias uteis provisao
                             ,pr_hrlimite_provisao                   IN tbcc_monitoramento_parametro.hrlimite_provisao%TYPE              --> horario limite para provisao
                             ,pr_qtdias_prov_cancelamento            IN tbcc_monitoramento_parametro.qtdias_provisao_cancelamento%TYPE   --> dias uteis para cancelamento provisao
                             ,pr_inlibera_saque                      IN tbcc_monitoramento_parametro.inlibera_saque%TYPE                 -->indicador saque em especie sem provisao                             
                             ,pr_inlibera_provisao_saque             IN tbcc_monitoramento_parametro.inlibera_provisao_saque%TYPE        --> indicador provisao de saque em especie
                             ,pr_inaltera_prov_presencial            IN tbcc_monitoramento_parametro.inaltera_provisao_presencial%TYPE   --> indicador alteracao de provisao nao presencial
                             ,pr_inverifica_saldo                    IN tbcc_monitoramento_parametro.inverifica_saldo%TYPE               -->verifica saldo
                             ,pr_dsdemail                            VARCHAR2                                                     --> email sede da cooperativa
                             ,pr_dsemailcoop                         VARCHAR2                                                     --> email seguranca da cooperativa
                             ,pr_xmllog                              IN VARCHAR2                                                      --> XML com informações de LOG
                             ,pr_cdcritic                            OUT PLS_INTEGER                                                  --> Código da crítica
                             ,pr_dscritic                            OUT VARCHAR2                                                     --> Descrição da crítica
                             ,pr_retxml                              IN OUT NOCOPY XMLType                                            --> Arquivo de retorno do XML
                             ,pr_nmdcampo                            OUT VARCHAR2                                                     --> Nome do campo com erro
                             ,pr_des_erro                            OUT VARCHAR2);                                                   --> Erros do processo
 
PROCEDURE pc_consultar_parmon_pld(pr_cdcooper IN NUMBER       --> Codigo da cooperativa
                                 ,pr_cdcoptel       IN VARCHAR2       --> Codigo da cooperativa escolhida pela cecred
                                 ,pr_xmllog   IN VARCHAR2           --> XML com informações de LOG
                                 ,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
                                 ,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
                                 ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                 ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                                 ,pr_des_erro OUT VARCHAR2);        --> Erros do processo
                           
PROCEDURE pc_consultar_parmon_pld_car(pr_cdcooper  IN tbcc_monitoramento_parametro.cdcooper%TYPE      --> Codigo Cooperativa                                     
                                           ,pr_vllimite OUT NUMBER                                      --> Valor Limite
                                           ,pr_vlcredito_diario_pf OUT NUMBER                           --> valor credito diario pf
                                           ,pr_vlcredito_diario_pj OUT NUMBER                           --> valor credito diario pj
                                           ,pr_vlmonitoracao_pagamento OUT NUMBER                       --> indicador da monitoracao pagamento
                                           ,pr_cdcritic OUT PLS_INTEGER                                 --> Código da crítica
                                           ,pr_dscritic OUT VARCHAR2);                                  --> Descrição da crítica
END tela_parmon;
/
CREATE OR REPLACE PACKAGE BODY CECRED.tela_parmon IS
  ---------------------------------------------------------------------------
  --
  --  Programa : TELA_PARMON
  --  Sistema  : Ayllos Web
  --  Autor    : Antonio Remualdo Junior
  --  Data     : Novembro - 2017.                Ultima atualizacao: 01/11/2017
  --
  -- Dados referentes ao programa:
  --
  -- Objetivo  : Centralizar rotinas relacionadas a tela parmon
  --
  ---------------------------------------------------------------------------
PROCEDURE pc_alterar_parmon_pld(                             
                              pr_cdcooper                            IN tbcc_monitoramento_parametro.cdcooper%TYPE                       --> codigo da cooperativa
                             ,pr_cdcoptel                            IN VARCHAR2                                                         --> Codigo da cooperativa escolhida pela cecred
                             ,pr_qtrenda_diario_pf                   IN tbcc_monitoramento_parametro.qtrenda_diario_pf%TYPE              --> qt vezes da renda do cooperado para alerta diario
                             ,pr_qtrenda_diario_pj                   IN tbcc_monitoramento_parametro.qtrenda_diario_pj%TYPE              --> qt vezes da renda do cooperado para alerta diario
                             ,pr_vlcredito_diario_pf                 IN tbcc_monitoramento_parametro.vlcredito_diario_pf%TYPE            --> Total creditos pelo cooperado alerta diario
                             ,pr_vlcredito_diario_pj                 IN tbcc_monitoramento_parametro.vlcredito_diario_pj%TYPE            --> Total creditos pelo cooperado alerta diario
                             ,pr_qtrenda_mensal_pf                   IN tbcc_monitoramento_parametro.qtrenda_mensal_pf %TYPE             --> qt vezes da renda do cooperado para alerta mensal
                             ,pr_qtrenda_mensal_pj                   IN tbcc_monitoramento_parametro.qtrenda_mensal_pf%TYPE              --> qt vezes da renda do cooperado para alerta mensal
                             ,pr_vlcredito_mensal_pf                 IN tbcc_monitoramento_parametro.vlcredito_mensal_pf%TYPE            --> Total creditos pelo cooperado alerta mensal
                             ,pr_vlcredito_mensal_pj                 IN tbcc_monitoramento_parametro.vlcredito_mensal_pj%TYPE            --> Total creditos pelo cooperado alerta mensal
                             ,pr_inrenda_zerada                      IN tbcc_monitoramento_parametro.inrenda_zerada%TYPE                 -->indicador de renda zerada
                             ,pr_vllimite_saque                      IN tbcc_monitoramento_parametro.vllimite_saque%TYPE                 --> somatoria valor saques em especie
                             ,pr_vllimite_deposito                   IN tbcc_monitoramento_parametro.vllimite_deposito%TYPE              --> somatorioa deposito em especie
                             ,pr_vllimite_pagamento                  IN tbcc_monitoramento_parametro.vllimite_pagamento%TYPE             --> somatoria pagamentos em especie
                             ,pr_vlprovisao_email                    IN tbcc_monitoramento_parametro.vlprovisao_email%TYPE               --> valor provisao para envio email
                             ,pr_vlprovisao_saque                    IN tbcc_monitoramento_parametro.vlprovisao_saque%TYPE               --> valor provisao saque
                             ,pr_vlmon_pagto                         IN tbcc_monitoramento_parametro.vlmonitoracao_pagamento%TYPE        --> valor monitocarao pagamento
                             ,pr_qtdias_provisao                     IN tbcc_monitoramento_parametro.qtdias_provisao%TYPE                --> dias uteis provisao
                             ,pr_hrlimite_provisao                   IN tbcc_monitoramento_parametro.hrlimite_provisao%TYPE              --> horario limite para provisao
                             ,pr_qtdias_prov_cancelamento            IN tbcc_monitoramento_parametro.qtdias_provisao_cancelamento%TYPE   --> dias uteis para cancelamento provisao
                             ,pr_inlibera_saque                      IN tbcc_monitoramento_parametro.inlibera_saque%TYPE                 -->indicador saque em especie sem provisao                             
                             ,pr_inlibera_provisao_saque             IN tbcc_monitoramento_parametro.inlibera_provisao_saque%TYPE        --> indicador provisao de saque em especie
                             ,pr_inaltera_prov_presencial            IN tbcc_monitoramento_parametro.inaltera_provisao_presencial%TYPE   --> indicador alteracao de provisao nao presencial
                             ,pr_inverifica_saldo                    IN tbcc_monitoramento_parametro.inverifica_saldo%TYPE               -->verifica saldo
                             ,pr_dsdemail                            VARCHAR2                                                     --> email sede da cooperativa
                             ,pr_dsemailcoop                         VARCHAR2                                                     --> email seguranca da cooperativa
                             ,pr_xmllog                              IN VARCHAR2                                                      --> XML com informações de LOG
                             ,pr_cdcritic                            OUT PLS_INTEGER                                                  --> Código da crítica
                             ,pr_dscritic                            OUT VARCHAR2                                                     --> Descrição da crítica
                             ,pr_retxml                              IN OUT NOCOPY XMLType                                            --> Arquivo de retorno do XML
                             ,pr_nmdcampo                            OUT VARCHAR2                                                     --> Nome do campo com erro
                             ,pr_des_erro                            OUT VARCHAR2) IS                                                 --> Erros do processo
    /* .............................................................................
    
        Programa: pc_alterar_parmon_pld
        Sistema : CECRED
        Sigla   : PARM
        Autor   : Antonio Remualdo Junior
        Data    : Nov/17.                    Ultima atualizacao: --/--/----
    
        Dados referentes ao programa:
    
        Frequencia: Sempre que for chamado
    
        Objetivo  : Rotina para alterar linha de parametros
    
        Observacao: -----
    
        Alteracoes:
    ..............................................................................*/
    
    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic VARCHAR2(1000); --> Desc. Erro
    
    -- Tratamento de erros
    vr_exc_saida EXCEPTION;
    
    -- Variaveis retornadas da gene0004.pc_extrai_dados
    vr_cdcooper VARCHAR2(100);
    vr_cdcooper_aux VARCHAR2(100);
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    
    vr_cdacesso VARCHAR2(100);
    vr_dsccampo VARCHAR2(1000);    
    
    vr_horalimt NUMBER;
    vr_horalim2 NUMBER;
    vr_encontrou NUMBER(1);
    
    vr_dstextab VARCHAR2(2000);
        
    -- Cursor generico de calendario
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;          
    
    CURSOR cr_crapope(pr_cdcooper IN crapope.cdcooper%TYPE
                     ,pr_cdoperad IN crapope.cdoperad%TYPE) IS
      SELECT dpo.dsdepart
        FROM crapope ope
            ,crapdpo dpo
       WHERE ope.cdcooper = pr_cdcooper
         AND ope.cdoperad = pr_cdoperad
         AND dpo.cddepart = ope.cddepart
         AND dpo.cdcooper = ope.cdcooper;
    rw_crapope cr_crapope%ROWTYPE; 
    
    --CURSOR MONITORAMENTO PARAMETRO
    CURSOR cr_tbcc_monit_param(pr_cdcooper IN tbcc_monitoramento_parametro.cdcooper%TYPE) IS
      SELECT mp.*
        FROM tbcc_monitoramento_parametro mp
       WHERE mp.cdcooper = pr_cdcooper;
    rw_tbcc_monit_param tbcc_monitoramento_parametro%ROWTYPE; 
    
    
   -- CURSOR EXPLODE
   cursor v_cur(pr_str IN VARCHAR2,pr_limit varchar2) is
    select regexp_substr(pr_str,'[^'||pr_limit||']+',1,level) as str from dual
    connect by regexp_substr(pr_str,'[^'||pr_limit||']+',1,level) is not null;  
    
    --------------->>> SUB-ROTINA <<<-----------------
    --> Gerar Log da tela
    PROCEDURE pc_log_parmon_pld(pr_cdcooper IN crapcop.cdcooper%TYPE,
                            pr_cdoperad IN crapope.cdoperad%TYPE,
                            pr_dscdolog IN VARCHAR2) IS
      vr_dscdolog VARCHAR2(500);
    BEGIN
      
      vr_dscdolog := to_char(rw_crapdat.dtmvtolt,'DD/MM/RRRR')||' '|| to_char(SYSDATE,'HH24:MI:SS') ||
                     ' --> '|| vr_cdacesso || ' --> '|| 'Operador '|| pr_cdoperad ||
                     ' '||pr_dscdolog;
      
      btch0001.pc_gera_log_batch(pr_cdcooper => pr_cdcooper, 
                                 pr_ind_tipo_log => 1, 
                                 pr_des_log  => vr_dscdolog, 
                                 pr_nmarqlog => 'parmon', 
                                 pr_flfinmsg => 'N');        
    END;
     
  BEGIN  
     pr_des_erro := 'OK';    
  -- Extrai dados do xml
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
                             pr_cdcooper => vr_cdcooper,
                             pr_nmdatela => vr_nmdatela,
                             pr_nmeacao  => vr_nmeacao,
                             pr_cdagenci => vr_cdagenci,
                             pr_nrdcaixa => vr_nrdcaixa,
                             pr_idorigem => vr_idorigem,
                             pr_cdoperad => vr_cdoperad,
                             pr_dscritic => vr_dscritic);
    -- Se retornou alguma crítica
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      -- Levanta exceção
      RAISE vr_exc_saida;
    END IF;
       
   IF(TRIM(pr_cdcoptel) IS NULL)THEN
       vr_cdcooper_aux:=vr_cdcooper;
   ELSE
       vr_cdcooper_aux:=pr_cdcoptel;
   END IF;
   
   --TODAS AS COOPERATIVAS
   IF(pr_cdcoptel = '0' AND pr_cdcooper = 3)THEN
      select listagg(c.cdcooper,'|') within group(order by cdcooper) INTO vr_cdcooper_aux
      from crapcop C 
      WHERE c.flgativo = 1 
      order by c.nmrescop;
   END IF;
   
   FOR i IN v_cur(vr_cdcooper_aux,'|')
     LOOP
       IF TRIM(i.str) IS NOT NULL AND TRIM(i.str) <> '0' THEN
         BEGIN
            vr_cdcooper:= i.str;                            
            -- Leitura do calendario da cooperativa
            OPEN btch0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
            FETCH btch0001.cr_crapdat
              INTO rw_crapdat;    
            -- Fechar o cursor
            CLOSE btch0001.cr_crapdat;
            
            OPEN cr_crapope(pr_cdcooper => vr_cdcooper, pr_cdoperad => vr_cdoperad);
            FETCH cr_crapope
              INTO rw_crapope;
            
            -- Se nao encontrar
            IF cr_crapope%NOTFOUND THEN
              -- Fechar o cursor
              CLOSE cr_crapope;
              
              -- Montar mensagem de critica
              vr_cdcritic := 0;
              vr_dscritic := 'Erro ao localizar operador!';
              -- volta para o programa chamador
              RAISE vr_exc_saida;
              
            END IF;    
            -- Fechar o cursor
            CLOSE cr_crapope;            
            
            vr_encontrou:=0;    
            --Busca Parametro
            OPEN cr_tbcc_monit_param(pr_cdcooper => vr_cdcooper);
            FETCH cr_tbcc_monit_param
              INTO rw_tbcc_monit_param;
            
            -- Se nao encontrar
            IF cr_tbcc_monit_param%FOUND THEN
              -- Fechar o cursor
              vr_encontrou:=1;      
            END IF;    
            -- Fechar o cursor
            CLOSE cr_tbcc_monit_param;

            BEGIN
              IF(vr_encontrou = 0)THEN
                INSERT INTO tbcc_monitoramento_parametro (
                 cdcooper
                ,qtrenda_diario_pf
                 ,qtrenda_diario_pj
                 ,vlcredito_diario_pf
                 ,vlcredito_diario_pj
                 ,qtrenda_mensal_pf
                 ,qtrenda_mensal_pj
                 ,vlcredito_mensal_pf
                 ,vlcredito_mensal_pj
                 ,inrenda_zerada
                 ,vllimite_saque
                 ,vllimite_deposito
                 ,vllimite_pagamento
                 ,vlprovisao_email
                 ,vlprovisao_saque
                 ,vlmonitoracao_pagamento
                 ,qtdias_provisao
                 ,hrlimite_provisao
                 ,qtdias_provisao_cancelamento
                 ,inlibera_saque
                 ,inlibera_provisao_saque
                 ,inaltera_provisao_presencial
                 ,inverifica_saldo
                 ,dsdemail) 
                VALUES(vr_cdcooper
                       ,pr_qtrenda_diario_pf
                       ,pr_qtrenda_diario_pj
                       ,pr_vlcredito_diario_pf
                       ,pr_vlcredito_diario_pj
                       ,pr_qtrenda_mensal_pf
                       ,pr_qtrenda_mensal_pj
                       ,pr_vlcredito_mensal_pf
                       ,pr_vlcredito_mensal_pj
                       ,pr_inrenda_zerada
                       ,pr_vllimite_saque
                       ,pr_vllimite_deposito
                       ,pr_vllimite_pagamento
                       ,pr_vlprovisao_email
                       ,pr_vlprovisao_saque
                       ,pr_vlmon_pagto
                       ,pr_qtdias_provisao
                       ,pr_hrlimite_provisao
                       ,pr_qtdias_prov_cancelamento
                       ,pr_inlibera_saque
                       ,pr_inlibera_provisao_saque
                       ,pr_inaltera_prov_presencial
                       ,pr_inverifica_saldo
                       ,pr_dsdemail);
              ELSE
                /*se não for cecred*/
                IF(pr_cdcooper <> 3)THEN                
                    UPDATE tbcc_monitoramento_parametro m
                      SET qtrenda_diario_pf   = pr_qtrenda_diario_pf
                         ,qtrenda_diario_pj   = pr_qtrenda_diario_pj
                         ,vlcredito_diario_pf = pr_vlcredito_diario_pf
                         ,vlcredito_diario_pj = pr_vlcredito_diario_pj
                         ,qtrenda_mensal_pf   = pr_qtrenda_mensal_pf
                         ,qtrenda_mensal_pj   = pr_qtrenda_mensal_pj
                         ,vlcredito_mensal_pf = pr_vlcredito_mensal_pf
                         ,vlcredito_mensal_pj = pr_vlcredito_mensal_pj
                         ,inrenda_zerada      = pr_inrenda_zerada
                         ,vllimite_saque      = pr_vllimite_saque
                         ,vllimite_deposito   = pr_vllimite_deposito
                         ,vllimite_pagamento  = pr_vllimite_pagamento
                         ,vlprovisao_email    = pr_vlprovisao_email
                         ,vlprovisao_saque    = pr_vlprovisao_saque
                         ,vlmonitoracao_pagamento = pr_vlmon_pagto
                         ,qtdias_provisao      = pr_qtdias_provisao
                         ,hrlimite_provisao    = pr_hrlimite_provisao
                         ,qtdias_provisao_cancelamento = pr_qtdias_prov_cancelamento
                         ,inlibera_saque       = pr_inlibera_saque
                         ,inlibera_provisao_saque = pr_inlibera_provisao_saque
                         ,inaltera_provisao_presencial = pr_inaltera_prov_presencial
                         ,inverifica_saldo             = pr_inverifica_saldo
                         ,dsdemail                     = pr_dsdemail
                    WHERE m.cdcooper = vr_cdcooper; 
                ELSE
                  UPDATE tbcc_monitoramento_parametro m
                      SET qtrenda_diario_pf   = pr_qtrenda_diario_pf
                         ,qtrenda_diario_pj   = pr_qtrenda_diario_pj
                         ,vlcredito_diario_pf = pr_vlcredito_diario_pf
                         ,vlcredito_diario_pj = pr_vlcredito_diario_pj
                         ,qtrenda_mensal_pf   = pr_qtrenda_mensal_pf
                         ,qtrenda_mensal_pj   = pr_qtrenda_mensal_pj
                         ,vlcredito_mensal_pf = pr_vlcredito_mensal_pf
                         ,vlcredito_mensal_pj = pr_vlcredito_mensal_pj
                         ,inrenda_zerada      = pr_inrenda_zerada
                         ,vllimite_saque      = pr_vllimite_saque
                         ,vllimite_deposito   = pr_vllimite_deposito
                         ,vllimite_pagamento  = pr_vllimite_pagamento
                         ,vlprovisao_email    = pr_vlprovisao_email
                         ,vlprovisao_saque    = pr_vlprovisao_saque
                         ,vlmonitoracao_pagamento = pr_vlmon_pagto
                         ,qtdias_provisao      = pr_qtdias_provisao
                         ,hrlimite_provisao    = pr_hrlimite_provisao
                         ,qtdias_provisao_cancelamento = pr_qtdias_prov_cancelamento
                         ,inlibera_saque       = pr_inlibera_saque
                         ,inlibera_provisao_saque = pr_inlibera_provisao_saque
                         ,inaltera_provisao_presencial = pr_inaltera_prov_presencial
                         ,inverifica_saldo             = pr_inverifica_saldo
                    WHERE m.cdcooper = vr_cdcooper; 
                END IF;          
              END IF;
              
            EXCEPTION
              WHEN OTHERS THEN
                -- Montar mensagem de critica
                vr_cdcritic := 0;
                vr_dscritic := 'Erro ao atualizar Linha de monitoramento parametro!';
                -- volta para o programa chamador
                RAISE vr_exc_saida;        
            END;    
            
            IF(vr_encontrou = 1)THEN
                IF rw_tbcc_monit_param.qtrenda_diario_pf <> pr_qtrenda_diario_pf THEN
                  --> gerar log da tela
                  pc_log_parmon_pld(pr_cdcooper => vr_cdcooper,
                                pr_cdoperad => vr_cdoperad,
                                pr_dscdolog => 'alterou o valor do campo "quantidade de vezes a renda do cooperado para alerta diario pessoa fisica" de ' ||
                                                to_char(rw_tbcc_monit_param.qtrenda_diario_pf,'FM9999999990D00', 'NLS_NUMERIC_CHARACTERS='',.''') || 
                                                ' para ' || to_char(pr_qtrenda_diario_pf,'FM9999999990D00', 'NLS_NUMERIC_CHARACTERS='',.'''));  
                END IF;
                
                IF rw_tbcc_monit_param.qtrenda_diario_pj <> pr_qtrenda_diario_pj THEN
                  --> gerar log da tela
                  pc_log_parmon_pld(pr_cdcooper => vr_cdcooper,
                                pr_cdoperad => vr_cdoperad,
                                pr_dscdolog => 'alterou o valor do campo "quantidade de vezes a renda do cooperado para alerta diario pessoa juridica" de ' ||
                                                to_char(rw_tbcc_monit_param.qtrenda_diario_pj,'FM9999999990D00', 'NLS_NUMERIC_CHARACTERS='',.''') || 
                                                ' para ' || to_char(pr_qtrenda_diario_pj,'FM9999999990D00', 'NLS_NUMERIC_CHARACTERS='',.'''));  
                END IF; 
                
                IF rw_tbcc_monit_param.vlcredito_diario_pf <> pr_vlcredito_diario_pf THEN
                  --> gerar log da tela
                  pc_log_parmon_pld(pr_cdcooper => vr_cdcooper,
                                pr_cdoperad => vr_cdoperad,
                                pr_dscdolog => 'alterou o valor do campo "Total de créditos pelo cooperado para alerta diário pessoa fisica" de ' ||
                                                to_char(rw_tbcc_monit_param.vlcredito_diario_pf,'FM9999999990D00', 'NLS_NUMERIC_CHARACTERS='',.''') || 
                                                ' para ' || to_char(pr_vlcredito_diario_pf,'FM9999999990D00', 'NLS_NUMERIC_CHARACTERS='',.'''));  
                END IF;   
                
                IF rw_tbcc_monit_param.vlcredito_diario_pj <> pr_vlcredito_diario_pj THEN
                  --> gerar log da tela
                  pc_log_parmon_pld(pr_cdcooper => vr_cdcooper,
                                pr_cdoperad => vr_cdoperad,
                                pr_dscdolog => 'alterou o valor do campo "Total de créditos pelo cooperado para alerta diário pessoa juridica" de ' ||
                                                to_char(rw_tbcc_monit_param.vlcredito_diario_pj,'FM9999999990D00', 'NLS_NUMERIC_CHARACTERS='',.''') || 
                                                ' para ' || to_char(pr_vlcredito_diario_pj,'FM9999999990D00', 'NLS_NUMERIC_CHARACTERS='',.'''));  
                END IF;  
                
                IF rw_tbcc_monit_param.qtrenda_mensal_pf <> pr_qtrenda_mensal_pf THEN
                  --> gerar log da tela
                  pc_log_parmon_pld(pr_cdcooper => vr_cdcooper,
                                pr_cdoperad => vr_cdoperad,
                                pr_dscdolog => 'alterou o valor do campo "quantidade de vezes a renda do cooperado para alerta mensal pessoa fisica" de ' ||
                                                to_char(rw_tbcc_monit_param.qtrenda_mensal_pf,'FM9999999990D00', 'NLS_NUMERIC_CHARACTERS='',.''') || 
                                                ' para ' || to_char(pr_qtrenda_mensal_pf,'FM9999999990D00', 'NLS_NUMERIC_CHARACTERS='',.'''));  
                END IF; 
                
                IF rw_tbcc_monit_param.qtrenda_mensal_pj <> pr_qtrenda_mensal_pj THEN
                  --> gerar log da tela
                  pc_log_parmon_pld(pr_cdcooper => vr_cdcooper,
                                pr_cdoperad => vr_cdoperad,
                                pr_dscdolog => 'alterou o valor do campo "quantidade de vezes a renda do cooperado para alerta mensal pessoa juridica" de ' ||
                                                to_char(rw_tbcc_monit_param.qtrenda_mensal_pj,'FM9999999990D00', 'NLS_NUMERIC_CHARACTERS='',.''') || 
                                                ' para ' || to_char(pr_qtrenda_mensal_pj,'FM9999999990D00', 'NLS_NUMERIC_CHARACTERS='',.'''));  
                END IF;      
                
                IF rw_tbcc_monit_param.vlcredito_mensal_pf <> pr_vlcredito_mensal_pf THEN
                  --> gerar log da tela
                  pc_log_parmon_pld(pr_cdcooper => vr_cdcooper,
                                pr_cdoperad => vr_cdoperad,
                                pr_dscdolog => 'alterou o valor do campo "Total de creditos pelo cooperado para alerta mensal pessoa fisica" de ' ||
                                                to_char(rw_tbcc_monit_param.vlcredito_mensal_pf,'FM9999999990D00', 'NLS_NUMERIC_CHARACTERS='',.''') || 
                                                ' para ' || to_char(pr_vlcredito_mensal_pf,'FM9999999990D00', 'NLS_NUMERIC_CHARACTERS='',.'''));  
                END IF; 
                
                IF rw_tbcc_monit_param.vlcredito_mensal_pj <> pr_vlcredito_mensal_pj THEN
                  --> gerar log da tela
                  pc_log_parmon_pld(pr_cdcooper => vr_cdcooper,
                                pr_cdoperad => vr_cdoperad,
                                pr_dscdolog => 'alterou o valor do campo "Total de creditos pelo cooperado para alerta mensal pessoa juridica" de ' ||
                                                to_char(rw_tbcc_monit_param.vlcredito_mensal_pj,'FM9999999990D00', 'NLS_NUMERIC_CHARACTERS='',.''') || 
                                                ' para ' || to_char(pr_vlcredito_mensal_pj,'FM9999999990D00', 'NLS_NUMERIC_CHARACTERS='',.'''));  
                END IF;
                
                IF rw_tbcc_monit_param.inrenda_zerada <> pr_inrenda_zerada THEN
                  --> gerar log da tela
                  pc_log_parmon_pld(pr_cdcooper => vr_cdcooper,
                                pr_cdoperad => vr_cdoperad,
                                pr_dscdolog => 'alterou o valor do campo "renda zerada" de ' ||
                                                rw_tbcc_monit_param.inrenda_zerada || 
                                                ' para ' || pr_inrenda_zerada);  
                END IF;
                
                IF rw_tbcc_monit_param.vllimite_saque <> pr_vllimite_saque THEN
                  --> gerar log da tela
                  pc_log_parmon_pld(pr_cdcooper => vr_cdcooper,
                                pr_cdoperad => vr_cdoperad,
                                pr_dscdolog => 'alterou o valor da somatoria valor do campo "saques em especie" de ' ||
                                                to_char(rw_tbcc_monit_param.vllimite_saque,'FM9999999990D00', 'NLS_NUMERIC_CHARACTERS='',.''') || 
                                                ' para ' || to_char(pr_vllimite_saque,'FM9999999990D00', 'NLS_NUMERIC_CHARACTERS='',.'''));  
                END IF;
                
                IF rw_tbcc_monit_param.vllimite_deposito <> pr_vllimite_deposito THEN
                  --> gerar log da tela
                  pc_log_parmon_pld(pr_cdcooper => vr_cdcooper,
                                pr_cdoperad => vr_cdoperad,
                                pr_dscdolog => 'alterou o valor do campo "somatoria deposito em especie" de ' ||
                                                to_char(rw_tbcc_monit_param.vllimite_deposito,'FM9999999990D00', 'NLS_NUMERIC_CHARACTERS='',.''') || 
                                                ' para ' || to_char(pr_vllimite_deposito,'FM9999999990D00', 'NLS_NUMERIC_CHARACTERS='',.'''));  
                END IF; 
                
                IF rw_tbcc_monit_param.vllimite_pagamento <> pr_vllimite_pagamento THEN
                  --> gerar log da tela
                  pc_log_parmon_pld(pr_cdcooper => vr_cdcooper,
                                pr_cdoperad => vr_cdoperad,
                                pr_dscdolog => 'alterou o valor do campo "somatoria de pagamento em especie" de ' ||
                                                to_char(rw_tbcc_monit_param.vllimite_pagamento,'FM9999999990D00', 'NLS_NUMERIC_CHARACTERS='',.''') || 
                                                ' para ' || to_char(pr_vllimite_pagamento,'FM9999999990D00', 'NLS_NUMERIC_CHARACTERS='',.'''));  
                END IF; 
                
                IF rw_tbcc_monit_param.vlprovisao_email <> pr_vlprovisao_email THEN
                  --> gerar log da tela
                  pc_log_parmon_pld(pr_cdcooper => vr_cdcooper,
                                pr_cdoperad => vr_cdoperad,
                                pr_dscdolog => 'alterou o valor do campo "provisao para envio de e-mail" de ' ||
                                                to_char(rw_tbcc_monit_param.vlprovisao_email,'FM9999999990D00', 'NLS_NUMERIC_CHARACTERS='',.''') || 
                                                ' para ' || to_char(pr_vlprovisao_email,'FM9999999990D00', 'NLS_NUMERIC_CHARACTERS='',.'''));  
                END IF; 
                
                IF rw_tbcc_monit_param.vlprovisao_saque <> pr_vlprovisao_saque THEN
                  --> gerar log da tela
                  pc_log_parmon_pld(pr_cdcooper => vr_cdcooper,
                                pr_cdoperad => vr_cdoperad,
                                pr_dscdolog => 'alterou o valor do campo "provisao de saque" de ' ||
                                                to_char(rw_tbcc_monit_param.vlprovisao_saque,'FM9999999990D00', 'NLS_NUMERIC_CHARACTERS='',.''') || 
                                                ' para ' || to_char(pr_vlprovisao_saque,'FM9999999990D00', 'NLS_NUMERIC_CHARACTERS='',.'''));  
                END IF; 
                
                IF rw_tbcc_monit_param.vlmonitoracao_pagamento <> pr_vlmon_pagto THEN
                  --> gerar log da tela
                  pc_log_parmon_pld(pr_cdcooper => vr_cdcooper,
                                pr_cdoperad => vr_cdoperad,
                                pr_dscdolog => 'alterou o valor do campo "monitoracao pagamento" de ' ||
                                                to_char(rw_tbcc_monit_param.vlmonitoracao_pagamento,'FM9999999990D00', 'NLS_NUMERIC_CHARACTERS='',.''') || 
                                                ' para ' || to_char(pr_vlmon_pagto,'FM9999999990D00', 'NLS_NUMERIC_CHARACTERS='',.'''));  
                END IF;                                 
                
                IF rw_tbcc_monit_param.qtdias_provisao <> pr_qtdias_provisao THEN
                  --> gerar log da tela
                  pc_log_parmon_pld(pr_cdcooper => vr_cdcooper,
                                pr_cdoperad => vr_cdoperad,
                                pr_dscdolog => 'alterou o valor do campo "Dias Uteis para provisao" de ' ||
                                                to_char(rw_tbcc_monit_param.qtdias_provisao,'FM9999999990D00', 'NLS_NUMERIC_CHARACTERS='',.''') || 
                                                ' para ' || to_char(pr_qtdias_provisao,'FM9999999990D00', 'NLS_NUMERIC_CHARACTERS='',.'''));  
                END IF; 
                
                IF rw_tbcc_monit_param.hrlimite_provisao <> pr_hrlimite_provisao THEN
                  --> gerar log da tela
                  pc_log_parmon_pld(pr_cdcooper => vr_cdcooper,
                                pr_cdoperad => vr_cdoperad,
                                pr_dscdolog => 'alterou o valor do campo "Horario maximo para provisao" de ' ||
                                                to_char(rw_tbcc_monit_param.hrlimite_provisao,'FM9999999990D00', 'NLS_NUMERIC_CHARACTERS='',.''') || 
                                                ' para ' || to_char(pr_hrlimite_provisao,'FM9999999990D00', 'NLS_NUMERIC_CHARACTERS='',.'''));  
                END IF; 
                
                IF rw_tbcc_monit_param.qtdias_provisao_cancelamento <> pr_qtdias_prov_cancelamento THEN
                  --> gerar log da tela
                  pc_log_parmon_pld(pr_cdcooper => vr_cdcooper,
                                pr_cdoperad => vr_cdoperad,
                                pr_dscdolog => 'alterou o valor do campo "Dias Uteis para cancelamento de provisao" de ' ||
                                                to_char(rw_tbcc_monit_param.qtdias_provisao_cancelamento,'FM9999999990D00', 'NLS_NUMERIC_CHARACTERS='',.''') || 
                                                ' para ' || to_char(pr_qtdias_prov_cancelamento,'FM9999999990D00', 'NLS_NUMERIC_CHARACTERS='',.'''));  
                END IF; 
                
                IF rw_tbcc_monit_param.inlibera_saque <> pr_inlibera_saque THEN
                  --> gerar log da tela
                  pc_log_parmon_pld(pr_cdcooper => vr_cdcooper,
                                pr_cdoperad => vr_cdoperad,
                                pr_dscdolog => 'alterou o valor do campo "Saque em especie sem provisao" de ' ||
                                                rw_tbcc_monit_param.inlibera_saque || 
                                                ' para ' || pr_inlibera_saque);  
                END IF;                             
                
                IF rw_tbcc_monit_param.inlibera_provisao_saque <> pr_inlibera_provisao_saque THEN
                  --> gerar log da tela
                  pc_log_parmon_pld(pr_cdcooper => vr_cdcooper,
                                pr_cdoperad => vr_cdoperad,
                                pr_dscdolog => 'alterou o valor do campo "Provisao de saque em especie" de ' ||
                                                rw_tbcc_monit_param.inlibera_provisao_saque || 
                                                ' para ' || pr_inlibera_provisao_saque);  
                END IF;                               
                
                IF rw_tbcc_monit_param.inaltera_provisao_presencial <> pr_inaltera_prov_presencial THEN
                  --> gerar log da tela
                  pc_log_parmon_pld(pr_cdcooper => vr_cdcooper,
                                pr_cdoperad => vr_cdoperad,
                                pr_dscdolog => 'alterou o valor do campo "Alteração de provisão não presencial" de ' ||
                                                rw_tbcc_monit_param.inaltera_provisao_presencial || 
                                                ' para ' || pr_inaltera_prov_presencial);  
                END IF;                               
                
                IF rw_tbcc_monit_param.inverifica_saldo <> pr_inverifica_saldo THEN
                  --> gerar log da tela
                  pc_log_parmon_pld(pr_cdcooper => vr_cdcooper,
                                pr_cdoperad => vr_cdoperad,
                                pr_dscdolog => 'alterou o valor do campo "Verifica Saldo" de ' ||
                                                rw_tbcc_monit_param.inverifica_saldo || 
                                                ' para ' || pr_inverifica_saldo);  
                END IF;
                
                 IF rw_tbcc_monit_param.dsdemail <> pr_dsdemail THEN
                  --> gerar log da tela
                  pc_log_parmon_pld(pr_cdcooper => vr_cdcooper,
                                pr_cdoperad => vr_cdoperad,
                                pr_dscdolog => 'alterou o valor do campo "email sede cooperativa" de ' ||
                                                rw_tbcc_monit_param.dsdemail || 
                                                ' para ' || pr_dsdemail);  
                END IF;     
            END IF; 
            COMMIT;
            
          EXCEPTION
            WHEN vr_exc_saida THEN
              
              IF vr_cdcritic <> 0 THEN
                pr_cdcritic := vr_cdcritic;
                pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
              ELSE
                pr_cdcritic := vr_cdcritic;
                pr_dscritic := vr_dscritic;
              END IF;
              
              pr_des_erro := 'NOK';
              -- Carregar XML padrão para variável de retorno não utilizada.
              -- Existe para satisfazer exigência da interface.
              pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                             '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
              ROLLBACK;
            WHEN OTHERS THEN
              
              pr_cdcritic := vr_cdcritic;
              pr_dscritic := 'Erro geral na rotina da tela ' || vr_nmdatela || ': ' || SQLERRM;
              pr_des_erro := 'NOK';
              -- Carregar XML padrão para variável de retorno não utilizada.
              -- Existe para satisfazer exigência da interface.
              pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                             '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
            ROLLBACK;
         END;
       END IF;
     END LOOP;    
     
  END pc_alterar_parmon_pld;

PROCEDURE pc_consultar_parmon_pld(pr_cdcooper IN NUMBER               --> Codigo da cooperativa
                           ,pr_cdcoptel       IN VARCHAR2               --> Codigo da cooperativa escolhida pela cecred
                           ,pr_xmllog         IN VARCHAR2             --> XML com informações de LOG
                           ,pr_cdcritic       OUT PLS_INTEGER         --> Código da crítica
                           ,pr_dscritic       OUT VARCHAR2            --> Descrição da crítica
                           ,pr_retxml         IN OUT NOCOPY XMLType   --> Arquivo de retorno do XML
                           ,pr_nmdcampo       OUT VARCHAR2            --> Nome do campo com erro
                           ,pr_des_erro       OUT VARCHAR2) IS        --> Erros do processo
    /* .............................................................................
    
        Programa: pc_consulta_parmon_pld
        Sistema : CECRED
        Sigla   : PARMON
        Autor   : Antonio Remualdo Junior
        Data    : Novembro/2017.                    Ultima atualizacao: --/--/----
    
        Dados referentes ao programa:
    
        Frequencia: Sempre que for chamado
    
        Objetivo  : Rotina para consultar parametros PLD
    
        Observacao: -----
    
        Alteracoes:
    ..............................................................................*/
      ----------->>> VARIAVEIS <<<--------   
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
      vr_dscritic VARCHAR2(1000);        --> Desc. Erro
    
      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
    
      vr_auxconta INTEGER := 0; -- Contador auxiliar p/ posicao no XML
    
      -- Variaveis retornadas da gene0004.pc_extrai_dados
      vr_cdcooper VARCHAR2(100);
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);                      
      
      ---------->> CURSORES <<--------
      --> Buscar dados operador    
      CURSOR cr_crapope(pr_cdcooper IN crapope.cdcooper%TYPE
                       ,pr_cdoperad IN crapope.cdoperad%TYPE) IS
        SELECT dpo.dsdepart
          FROM crapope ope
              ,crapdpo dpo
         WHERE ope.cdcooper = pr_cdcooper
           AND ope.cdoperad = pr_cdoperad
           AND dpo.cddepart = ope.cddepart
           AND dpo.cdcooper = ope.cdcooper;
      rw_crapope cr_crapope%ROWTYPE;
      
         
     /* Busca cooperativas */
    CURSOR cr_crapcop IS

      select c.cdcooper,c.nmrescop 
      from crapcop C 
      WHERE c.flgativo = 1 
      order by c.nmrescop;

    rw_crapcop cr_crapcop%ROWTYPE;
      
      -- busca monitoramento parametro
      CURSOR cr_tbcc_monit_param(pr_cdcooper IN tbcc_monitoramento_parametro.cdcooper%TYPE) IS
        SELECT c.dsemlcof as dsdemailseg,mp.*
        FROM crapcop c
        LEFT JOIN tbcc_monitoramento_parametro mp on c.cdcooper = mp.cdcooper
        WHERE c.cdcooper = pr_cdcooper;
      rw_tbcc_monit_param cr_tbcc_monit_param%ROWTYPE;      
    
    BEGIN    
      pr_des_erro := 'OK';
      -- Extrai dados do xml
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
                               pr_cdcooper => vr_cdcooper,
                               pr_nmdatela => vr_nmdatela,
                               pr_nmeacao  => vr_nmeacao,
                               pr_cdagenci => vr_cdagenci,
                               pr_nrdcaixa => vr_nrdcaixa,
                               pr_idorigem => vr_idorigem,
                               pr_cdoperad => vr_cdoperad,
                               pr_dscritic => vr_dscritic);
   
      -- Se retornou alguma crítica
      IF TRIM(vr_dscritic) IS NOT NULL THEN
        -- Levanta exceção
        RAISE vr_exc_saida;
      END IF;
      
      IF(TRIM(pr_cdcoptel) IS NOT NULL)THEN      
         vr_cdcooper:=TO_NUMBER(TRIM(pr_cdcoptel));
      END IF;
                                   
      --> Buscar dados do operador
      OPEN cr_crapope(pr_cdcooper => vr_cdcooper, 
                      pr_cdoperad => vr_cdoperad);
      FETCH cr_crapope INTO rw_crapope;
    
      -- Se nao encontrar
      IF cr_crapope%NOTFOUND THEN
        -- Fechar o cursor
        CLOSE cr_crapope;
      
        -- Montar mensagem de critica
        vr_cdcritic := 0;
        vr_dscritic := 'Operador não encontrado!';
        -- volta para o programa chamador
        RAISE vr_exc_saida;
      
      END IF;
    
      -- Fechar o cursor
      CLOSE cr_crapope;      
    
      --Busca Parametro
      OPEN cr_tbcc_monit_param(pr_cdcooper => vr_cdcooper);
      FETCH cr_tbcc_monit_param
        INTO rw_tbcc_monit_param;      
      -- Fechar o cursor
      CLOSE cr_tbcc_monit_param; 
    
      -- Criar cabeçalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Root',
                             pr_posicao  => 0,
                             pr_tag_nova => 'Dados',
                             pr_tag_cont => NULL,
                             pr_des_erro => vr_dscritic);
      -- Insere as tags
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Dados',
                             pr_posicao  => 0,
                             pr_tag_nova => 'inf',
                             pr_tag_cont => NULL,
                             pr_des_erro => vr_dscritic);
    
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'cdcooper',
                             pr_tag_cont => rw_tbcc_monit_param.cdcooper,
                             pr_des_erro => vr_dscritic);
                             
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'qtrenda_diario_pf',
                             pr_tag_cont => rw_tbcc_monit_param.qtrenda_diario_pf,
                             pr_des_erro => vr_dscritic);
                                                    
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'qtrenda_diario_pj',
                             pr_tag_cont => rw_tbcc_monit_param.qtrenda_diario_pj,
                             pr_des_erro => vr_dscritic);
                             
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'vlcredito_diario_pf',
                             pr_tag_cont => to_char(rw_tbcc_monit_param.vlcredito_diario_pf,
                                                    'fm9g999g999g999g999g990d00',
                                                    'NLS_NUMERIC_CHARACTERS='',.'''),
                             pr_des_erro => vr_dscritic);
                             
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'vlcredito_diario_pj',
                             pr_tag_cont => to_char(rw_tbcc_monit_param.vlcredito_diario_pj,
                                                    'fm9g999g999g999g999g990d00',
                                                    'NLS_NUMERIC_CHARACTERS='',.'''),
                             pr_des_erro => vr_dscritic);
                             
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'qtrenda_mensal_pf',
                             pr_tag_cont => rw_tbcc_monit_param.qtrenda_mensal_pf,
                             pr_des_erro => vr_dscritic);
      
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'qtrenda_mensal_pj',
                             pr_tag_cont => rw_tbcc_monit_param.qtrenda_mensal_pj,
                             pr_des_erro => vr_dscritic);
                             
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'vlcredito_mensal_pf',
                             pr_tag_cont => to_char(rw_tbcc_monit_param.vlcredito_mensal_pf,
                                                    'fm9g999g999g999g999g990d00',
                                                    'NLS_NUMERIC_CHARACTERS='',.'''),                                                    
                             pr_des_erro => vr_dscritic);    
      
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'vlcredito_mensal_pj',
                             pr_tag_cont => to_char(rw_tbcc_monit_param.vlcredito_mensal_pj,
                                                    'fm9g999g999g999g999g990d00',
                                                    'NLS_NUMERIC_CHARACTERS='',.'''),                                                   
                             pr_des_erro => vr_dscritic); 
                             
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'vllimite_saque',
                             pr_tag_cont => to_char(rw_tbcc_monit_param.vllimite_saque,
                                                    'fm9g999g999g999g999g990d00',
                                                    'NLS_NUMERIC_CHARACTERS='',.'''),                                                
                             pr_des_erro => vr_dscritic);     
      
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'vllimite_deposito',
                             pr_tag_cont => to_char(rw_tbcc_monit_param.vllimite_deposito,
                                                    'fm9g999g999g999g999g990d00',
                                                    'NLS_NUMERIC_CHARACTERS='',.'''),
                             pr_des_erro => vr_dscritic); 
      
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'vllimite_pagamento',
                             pr_tag_cont => to_char(rw_tbcc_monit_param.vllimite_pagamento, 
                                                    'fm9g999g999g999g999g990d00',
                                                    'NLS_NUMERIC_CHARACTERS='',.'''),                                              
                             pr_des_erro => vr_dscritic); 
                             
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'vlprovisao_email',
                             pr_tag_cont => to_char(rw_tbcc_monit_param.vlprovisao_email,
                                                    'fm9g999g999g999g999g990d00',
                                                    'NLS_NUMERIC_CHARACTERS='',.'''),                                                
                             pr_des_erro => vr_dscritic);                        
      
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'vlprovisao_saque',
                             pr_tag_cont => to_char(rw_tbcc_monit_param.vlprovisao_saque,
                                                    'fm9g999g999g999g999g990d00',
                                                    'NLS_NUMERIC_CHARACTERS='',.'''),                              
                             pr_des_erro => vr_dscritic);
                             
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'vlmonitoracao_pagamento',
                             pr_tag_cont => to_char(rw_tbcc_monit_param.vlmonitoracao_pagamento,
                                                    'fm9g999g999g999g999g990d00',
                                                    'NLS_NUMERIC_CHARACTERS='',.'''),                              
                             pr_des_erro => vr_dscritic);   
      
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'qtdias_provisao',
                             pr_tag_cont => rw_tbcc_monit_param.qtdias_provisao,
                             pr_des_erro => vr_dscritic); 
                             
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'hrlimite_provisao',
                             pr_tag_cont => rw_tbcc_monit_param.hrlimite_provisao,
                             pr_des_erro => vr_dscritic);                         
      
       gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'qtdias_provisao_cancelamento',
                             pr_tag_cont => rw_tbcc_monit_param.qtdias_provisao_cancelamento,
                             pr_des_erro => vr_dscritic); 
                             
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'inlibera_saque',
                             pr_tag_cont => rw_tbcc_monit_param.inlibera_saque,
                             pr_des_erro => vr_dscritic);       
                        
       gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'inlibera_provisao_saque',
                             pr_tag_cont => rw_tbcc_monit_param.inlibera_provisao_saque,
                             pr_des_erro => vr_dscritic);                       
                             
       gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'inaltera_provisao_presencial',
                             pr_tag_cont => rw_tbcc_monit_param.inaltera_provisao_presencial,
                             pr_des_erro => vr_dscritic);                                                        
                                                    
    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'inrenda_zerada',
                             pr_tag_cont => rw_tbcc_monit_param.inrenda_zerada,
                             pr_des_erro => vr_dscritic); 
                             
    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'inverifica_saldo',
                             pr_tag_cont => rw_tbcc_monit_param.inverifica_saldo,
                             pr_des_erro => vr_dscritic);
                             
    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'dsdemail',
                             pr_tag_cont => rw_tbcc_monit_param.dsdemail,
                             pr_des_erro => vr_dscritic);  
                             
    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'dsdemailseg',
                             pr_tag_cont => rw_tbcc_monit_param.dsdemailseg,
                             pr_des_erro => vr_dscritic); 
        
    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'vlmonitoracao_pagamento',
                             pr_tag_cont => rw_tbcc_monit_param.vlmonitoracao_pagamento,
                             pr_des_erro => vr_dscritic);                                                       
                                
    -- BUSCAS COOPERATIVAS QUANDO CECREDI
    IF(pr_cdcooper = 3)THEN 
        gene0007.pc_insere_tag(pr_xml=> pr_retxml,
                               pr_tag_pai  => 'Root',
                               pr_posicao  => 0,
                               pr_tag_nova => 'CRAPCOP',
                               pr_tag_cont => NULL,
                               pr_des_erro => vr_dscritic);                                         
      vr_auxconta := 0;      
      FOR reg IN cr_crapcop LOOP 
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'CRAPCOP',
                               pr_posicao  => 0,
                               pr_tag_nova => 'Registro',
                               pr_tag_cont => NULL,
                               pr_des_erro => vr_dscritic);
                                                           
          gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Registro',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'codcoope',
                             pr_tag_cont => reg.cdcooper,
                             pr_des_erro => vr_dscritic); 
          
          gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Registro',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'nmrescop',
                             pr_tag_cont => reg.nmrescop,
                             pr_des_erro => vr_dscritic); 
          vr_auxconta := vr_auxconta + 1;
      END LOOP;
    
    END IF;                           
                            
  EXCEPTION
    WHEN vr_exc_saida THEN
      
      IF vr_cdcritic <> 0 THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      END IF;
      
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
    WHEN OTHERS THEN
      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina da tela ' || vr_nmdatela || ': ' || SQLERRM;
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
  END pc_consultar_parmon_pld;

 /* Buscar limite de pagamento especie */
  PROCEDURE pc_consultar_parmon_pld_car(pr_cdcooper  IN tbcc_monitoramento_parametro.cdcooper%TYPE      --> Codigo Cooperativa                                     
                                           ,pr_vllimite OUT NUMBER                                      --> Valor Limite
                                           ,pr_vlcredito_diario_pf OUT NUMBER                           --> valor credito diario pf
                                           ,pr_vlcredito_diario_pj OUT NUMBER                           --> valor credito diario pj
                                           ,pr_vlmonitoracao_pagamento OUT NUMBER                       --> indicador da monitoracao pagamento
                                           ,pr_cdcritic OUT PLS_INTEGER                                 --> Código da crítica
                                           ,pr_dscritic OUT VARCHAR2) IS                                --> Descrição da crítica

--------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_busca_limite_pagamento_especie      
  --  Sistema  : Buscar Limite especie
  --  Sigla    : PARMON
  --  Autor    : Antonio R. Junior - mouts
  --  Data     : novembro/2017.                   Ultima atualizacao: 
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Buscar Limite do pagamento especie
  --
  -- Anotações : 
  ---------------------------------------------------------------------------------------------------------------
  -- Tratamento de erros
  vr_exc_saida EXCEPTION;
  ---------->> CURSORES <<--------    
  -- busca monitor
  CURSOR cr_monit_param(pr_cdcooper IN tbcc_monitoramento_parametro.cdcooper%TYPE) IS
  SELECT p.vlmonitoracao_pagamento AS vllimite,
         p.vlcredito_diario_pf,
         p.vlcredito_diario_pj,
         p.vlmonitoracao_pagamento
  FROM tbcc_monitoramento_parametro p
  WHERE p.cdcooper = pr_cdcooper;         
  rw_monit_param cr_monit_param%ROWTYPE;
      
  BEGIN
    DECLARE
      --Variaveis erro
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(4000);
      --Variaveis de Excecao
      vr_exc_erro EXCEPTION;
    BEGIN
      --Inicializar variaveis erro
      pr_cdcritic:= NULL;
      pr_dscritic:= NULL;
      
      --> Buscar parametros
      OPEN cr_monit_param(pr_cdcooper => pr_cdcooper);
      FETCH cr_monit_param INTO rw_monit_param;
    
      -- Se nao encontrar
      IF cr_monit_param%NOTFOUND THEN
        -- Fechar o cursor
        CLOSE cr_monit_param;
      
        -- Montar mensagem de critica
        vr_cdcritic := 0;
        vr_dscritic := 'Parametro nao encontrado!';
        -- volta para o programa chamador
        RAISE vr_exc_saida;
      ELSE
        -- Fechar o cursor
        CLOSE cr_monit_param;   
      END IF;
      
      pr_vllimite := rw_monit_param.vllimite;
      pr_vlcredito_diario_pf := rw_monit_param.vlcredito_diario_pf;
      pr_vlcredito_diario_pj := rw_monit_param.vlcredito_diario_pj;
      pr_vlmonitoracao_pagamento := rw_monit_param.vlmonitoracao_pagamento;   
      
    EXCEPTION
    WHEN vr_exc_saida THEN      
      IF vr_cdcritic <> 0 THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      END IF;      
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      ROLLBACK;
    WHEN OTHERS THEN      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina da tela TRAESP: ' || SQLERRM;
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      ROLLBACK;
    END;
  END pc_consultar_parmon_pld_car;

END tela_parmon;
/
