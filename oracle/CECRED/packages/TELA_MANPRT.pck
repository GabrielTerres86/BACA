CREATE OR REPLACE PACKAGE CECRED.TELA_MANPRT IS

  CURSOR cr_titulos(pr_dtmvtolt IN tbfin_recursos_movimento.dtmvtolt%TYPE,
                    pr_vllanmto IN tbfin_recursos_movimento.vllanmto%TYPE,
                    pr_nrcpf_cnpj IN tbcobran_cartorio_protesto.nrcpf_cnpj%TYPE,
                    pr_nmcartorio IN tbcobran_cartorio_protesto.nmcartorio%TYPE) IS
        SELECT ret.idretorno,
               ret.dtconciliacao,
               ret.vltitulo,
               ret.dtocorre,
               cart.nrcpf_cnpj,
               cart.nmcartorio,
               count(1) over() as rcount
          FROM tbcobran_retorno_ieptb ret
               INNER JOIN crapmun mun ON mun.cdcomarc = ret.cdcomarc
               INNER JOIN tbcobran_cartorio_protesto cart ON cart.idcidade = mun.idcidade AND cart.cdcartorio = ret.cdcartorio
         WHERE ret.dtconciliacao IS NULL
           AND ret.dtocorre >= pr_dtmvtolt
           AND ret.vltitulo <= pr_vllanmto
           AND (cart.nmcartorio = pr_nmcartorio AND cart.nrcpf_cnpj = pr_nrcpf_cnpj);
                        
  rw_titulo cr_titulos%ROWTYPE;

  CURSOR cr_tbfin_recursos_movimento(pr_dtinicial    IN VARCHAR2
                                     ,pr_dtfinal       IN VARCHAR2
                                     ,pr_vlinicial     IN tbfin_recursos_movimento.vllanmto%TYPE
                                     ,pr_vlfinal       IN tbfin_recursos_movimento.vllanmto%TYPE
                                     ,pr_cartorio      IN tbfin_recursos_movimento.nrcnpj_debitada%TYPE
                                     ,pr_flgcon        IN INTEGER) IS
    SELECT ted.idlancto
          ,NVL(( SELECT sys.stragg(cart.nmcartorio) 
               FROM tbcobran_cartorio_protesto cart 
              WHERE cart.nrcpf_cnpj = ted.nrcnpj_debitada 
                AND rownum = 1 ),'CARTORIO NAO CADASTRADO' || ' - ' || ted.nrcnpj_debitada) as nome_cartorio -- pode haver mais de um cartório com o mesmo CPF/CNPJ
          ,ted.nmtitular_debitada as nome_remetente
          ,ted.nrcnpj_debitada as cnpj_cpf
          ,banco.cdbccxlt  as nome_banco
          ,agencia.cdageban as nome_agencia
          ,ted.dsconta_debitada as conta
          ,ted.dtmvtolt as data_recebimento
          ,ted.vllanmto as valor
          ,caf.cdufresd as nome_estado
          ,caf.nmcidade as nome_cidade
          ,'PENDENTE' as status
    FROM tbfin_recursos_movimento ted
         inner join crapban banco on (ted.nrispbif = banco.nrispbif)
         inner join crapagb agencia on (agencia.cddbanco = banco.cdbccxlt and cdagenci_debitada = agencia.cdageban)
         left join crapcaf caf on (caf.cdcidade = agencia.cdcidade)
    WHERE ted.dsdebcre = 'C' AND TED.INDEVTED_MOTIVO = 0 
     and ((ted.dtmvtolt between to_date(pr_dtinicial,'DD/MM/RRRR') and to_date(pr_dtfinal,'DD/MM/RRRR')) 
         or (pr_dtinicial is null and pr_dtfinal is null))
     and ((ted.vllanmto >= pr_vlinicial and ted.vllanmto <= pr_vlfinal) 
         or (pr_vlinicial = 0 and pr_vlfinal = 0))
     and (ted.nrcnpj_debitada = pr_cartorio or pr_cartorio is null)
     and ((pr_flgcon = 1 and ted.dtconciliacao IS NOT NULL) or (pr_flgcon = 0 and ted.dtconciliacao IS NULL))
     
    ORDER BY ted.dtmvtolt, ted.nrcnpj_debitada;  
    rw_tbfin_recursos_movimento cr_tbfin_recursos_movimento%ROWTYPE;


  TYPE titulos_tbl_type IS TABLE OF cr_titulos%ROWTYPE INDEX BY PLS_INTEGER;

  PROCEDURE pc_consulta_teds(pr_dtinicial     IN VARCHAR2 -- Data inicial de recebimento de ted
                         	  ,pr_dtfinal       IN VARCHAR2 -- Data final de recebimento de ted
                            ,pr_vlinicial     IN tbfin_recursos_movimento.vllanmto%TYPE -- Valor inicial de comparação ted
                            ,pr_vlfinal       IN tbfin_recursos_movimento.vllanmto%TYPE -- Valor final de comparação ted
                            ,pr_cartorio      IN tbfin_recursos_movimento.nrcnpj_debitada%TYPE -- Cartorio da ted
                            ,pr_nrregist      IN INTEGER                 -- Quantidade de registros
                            ,pr_nriniseq      IN INTEGER                 -- Qunatidade inicial
                            ,pr_xmllog        IN VARCHAR2                -- XML com informações de LOG
                            ,pr_cdcritic      OUT PLS_INTEGER            -- Código da crítica
                            ,pr_dscritic      OUT VARCHAR2               -- Descrição da crítica
                            ,pr_retxml        IN OUT NOCOPY XMLType      -- Arquivo de retorno do XML
                            ,pr_nmdcampo      OUT VARCHAR2               -- Nome do Campo
                            ,pr_des_erro      OUT VARCHAR2);

  PROCEDURE pc_exporta_consulta_teds(pr_cdcooper  IN craptab.cdcooper%TYPE         --> Cooperativa
                                    ,pr_dtinicial     IN VARCHAR2 -- Data inicial de recebimento de ted
                        	  	    ,pr_dtfinal       IN VARCHAR2 -- Data final de recebimento de ted
                                    ,pr_vlinicial     IN tbfin_recursos_movimento.vllanmto%TYPE -- Valor inicial de comparação ted
                                    ,pr_vlfinal       IN tbfin_recursos_movimento.vllanmto%TYPE -- Valor final de comparação ted
                                    ,pr_cartorio      IN tbfin_recursos_movimento.nrcnpj_debitada%TYPE -- Cartorio da ted
                                    ,pr_nrregist      IN INTEGER                 -- Quantidade de registros
                                    ,pr_nriniseq      IN INTEGER                 -- Qunatidade inicial
                                    ,pr_flgcon        IN INTEGER DEFAULT 0       -- TEDs conciliadas: '1' sim '0' não
                                    ,pr_xmllog        IN VARCHAR2                -- XML com informações de LOG
                                    ,pr_cdcritic      OUT PLS_INTEGER            -- Código da crítica
                                    ,pr_dscritic      OUT VARCHAR2               -- Descrição da crítica
                                    ,pr_retxml        IN OUT NOCOPY XMLType      -- Arquivo de retorno do XML
                                    ,pr_nmdcampo      OUT VARCHAR2               -- Nome do Campo
                                    ,pr_des_erro      OUT VARCHAR2);
  
  PROCEDURE pc_consulta_conciliacoes(pr_dtinicial     IN VARCHAR2 -- Data inicial de recebimento de ted
                            ,pr_dtfinal       IN VARCHAR2 -- Data final de recebimento de ted
                            ,pr_vlinicial     IN tbfin_recursos_movimento.vllanmto%TYPE -- Valor inicial de comparação ted
                            ,pr_vlfinal       IN tbfin_recursos_movimento.vllanmto%TYPE -- Valor final de comparação ted
                            ,pr_cartorio      IN tbfin_recursos_movimento.nrcnpj_debitada%TYPE -- Cartorio da ted                       
                            ,pr_nrregist      IN INTEGER                 -- Quantidade de registros
                            ,pr_nriniseq      IN INTEGER                 -- Qunatidade inicial
                            ,pr_xmllog        IN VARCHAR2                -- XML com informações de LOG
                            ,pr_cdcritic      OUT PLS_INTEGER            -- Código da crítica
                            ,pr_dscritic      OUT VARCHAR2               -- Descrição da crítica
                            ,pr_retxml        IN OUT NOCOPY XMLType      -- Arquivo de retorno do XML
                            ,pr_nmdcampo      OUT VARCHAR2               -- Nome do Campo
                            ,pr_des_erro      OUT VARCHAR2);                                      
                            
  PROCEDURE pc_consulta_custas(pr_cdcooper      IN INTEGER --> Cooperativa
                              ,pr_nrdconta      IN crapceb.nrdconta%TYPE --> Numero da conta do cooperado
                              ,pr_dtinicial     IN VARCHAR2 --> Data inicial de recebimento de ted
                              ,pr_dtfinal       IN VARCHAR2 --> Data final de recebimento de ted
                              ,pr_cdestado      IN VARCHAR2 --> Estado que veio a confirmação
                              ,pr_cartorio      IN VARCHAR2 --> Cartorio da ted
                              ,pr_flcustas      IN INTEGER                 -- Exibir custas/taxas pagas
                              ,pr_xmllog        IN VARCHAR2                -- XML com informações de LOG
                              ,pr_cdcritic      OUT PLS_INTEGER            -- Código da crítica
                              ,pr_dscritic      OUT VARCHAR2               -- Descrição da crítica
                              ,pr_retxml        IN OUT NOCOPY xmltype      -- Arquivo de retorno do XML
                                    ,pr_nmdcampo      OUT VARCHAR2               -- Nome do Campo
                                    ,pr_des_erro      OUT VARCHAR2);   

  PROCEDURE pc_exporta_consulta_teds_pdf(pr_cdcooper  IN craptab.cdcooper%TYPE         --> Cooperativa
                                        ,pr_dtinicial     IN VARCHAR2 -- Data inicial de recebimento de ted
                         	  	        ,pr_dtfinal       IN VARCHAR2 -- Data final de recebimento de ted
                                        ,pr_vlinicial     IN tbfin_recursos_movimento.vllanmto%TYPE -- Valor inicial de comparação ted
                                        ,pr_vlfinal       IN tbfin_recursos_movimento.vllanmto%TYPE -- Valor final de comparação ted
                                        ,pr_cartorio      IN tbfin_recursos_movimento.nrcnpj_debitada%TYPE -- Cartorio da ted
                                        ,pr_xmllog        IN VARCHAR2                -- XML com informações de LOG
                                        ,pr_cdcritic      OUT PLS_INTEGER            -- Código da crítica
                                        ,pr_dscritic      OUT VARCHAR2               -- Descrição da crítica
                                        ,pr_retxml        IN OUT NOCOPY XMLType      -- Arquivo de retorno do XML
                                        ,pr_nmdcampo      OUT VARCHAR2               -- Nome do Campo
                                        ,pr_des_erro      OUT VARCHAR2);

  PROCEDURE pc_exporta_consulta_custas(pr_cdcooper_usr  IN craptab.cdcooper%TYPE --> Cooperativa que está sendo executada
                                      ,pr_cdcooper      IN INTEGER --> Cooperativa
            	                      ,pr_nrdconta      IN crapceb.nrdconta%TYPE --> Numero da conta do cooperado
                                      ,pr_dtinicial     IN VARCHAR2 -- Data inicial de recebimento de ted
                         	  	      ,pr_dtfinal       IN VARCHAR2 -- Data final de recebimento de ted
                                      ,pr_cdestado      IN VARCHAR2 --> Estado que veio a confirmação
                                      ,pr_cartorio      IN tbfin_recursos_movimento.nrcnpj_debitada%TYPE -- Cartorio da ted
                                      ,pr_flcustas      IN INTEGER                 -- Exibir custas/taxas pagas
                                      ,pr_xmllog        IN VARCHAR2                -- XML com informações de LOG
                                      ,pr_cdcritic      OUT PLS_INTEGER            -- Código da crítica
                                      ,pr_dscritic      OUT VARCHAR2               -- Descrição da crítica
                                      ,pr_retxml        IN OUT NOCOPY XMLType      -- Arquivo de retorno do XML
                                      ,pr_nmdcampo      OUT VARCHAR2               -- Nome do Campo
                	                  ,pr_des_erro      OUT VARCHAR2);

  PROCEDURE pc_consulta_nao_conciliados(pr_dtinicial     IN VARCHAR2 -- Data de recebimento do titulo
                            ,pr_vlfinal       IN tbcobran_retorno_ieptb.vltitulo%TYPE -- Valor final titulo
                            ,pr_cartorio      IN INTEGER                 -- Cartorio da ted
                            ,pr_xmllog        IN VARCHAR2                -- XML com informações de LOG
                            ,pr_cdcritic      OUT PLS_INTEGER            -- Código da crítica
                            ,pr_dscritic      OUT VARCHAR2               -- Descrição da crítica
                            ,pr_retxml        IN OUT NOCOPY XMLType      -- Arquivo de retorno do XML
                            ,pr_nmdcampo      OUT VARCHAR2               -- Nome do Campo
                            ,pr_des_erro      OUT VARCHAR2);
                            
  PROCEDURE pc_exporta_consulta_custas_pdf(pr_cdcooper_usr  IN craptab.cdcooper%TYPE --> Cooperativa que está sendo executada
                                          ,pr_cdcooper  IN craptab.cdcooper%TYPE         --> Cooperativa
                                          ,pr_nrdconta      IN crapceb.nrdconta%TYPE --> Numero da conta do cooperado
                                          ,pr_dtinicial     IN VARCHAR2 -- Data inicial de recebimento de ted
                         	  	          ,pr_dtfinal       IN VARCHAR2 -- Data final de recebimento de ted
                                          ,pr_cdestado      IN VARCHAR2 --> Estado que veio a confirmação
                                          ,pr_cartorio      IN tbfin_recursos_movimento.nrcnpj_debitada%TYPE -- Cartorio da ted
                                          ,pr_flcustas      IN INTEGER                 -- tarifas e custas processadas
                                          ,pr_xmllog        IN VARCHAR2                -- XML com informações de LOG
                                          ,pr_cdcritic      OUT PLS_INTEGER            -- Código da crítica
                                          ,pr_dscritic      OUT VARCHAR2               -- Descrição da crítica
                                          ,pr_retxml        IN OUT NOCOPY XMLType      -- Arquivo de retorno do XML
                                          ,pr_nmdcampo      OUT VARCHAR2               -- Nome do Campo
                                          ,pr_des_erro      OUT VARCHAR2);                            


  PROCEDURE pc_devolver_ted(pr_cdcooper      IN craptab.cdcooper%TYPE         --> Cooperativa
                           ,pr_cdoperad      IN VARCHAR2                 -- Codigo Operador
                           ,pr_idlancto      IN TBFIN_RECURSOS_MOVIMENTO.idlancto%TYPE -- Código da TED
                           ,pr_motivo        IN INTEGER                  -- Motivo da devolução (1 - Recebimento da TED em duplicidade, 2 - Cartorio nao localizado/reconhecido, 3 - Algum outro motivo informado pelo IEPTB)
                           ,pr_descricao     IN VARCHAR2                 -- Descrição da devolução
                           ,pr_xmllog        IN VARCHAR2                -- XML com informações de LOG
                           ,pr_cdcritic      OUT PLS_INTEGER            -- Código da crítica
                           ,pr_dscritic      OUT VARCHAR2
                           ,pr_retxml        IN OUT NOCOPY XMLType      -- Arquivo de retorno do XML
                           ,pr_nmdcampo      OUT VARCHAR2               -- Nome do Campo
                           ,pr_des_erro      OUT VARCHAR2);
                           
  PROCEDURE pc_gera_conciliacao_auto(pr_cdprograma IN VARCHAR2,
                                     pr_dscritic  OUT VARCHAR2);
                           
  PROCEDURE pc_gera_conciliacao(pr_idlancto   IN VARCHAR2 -- IDs das TED
                               ,pr_idsretorno IN VARCHAR2                             -- IDs dos títulos
                               ,pr_idconciliacao OUT tbcobran_conciliacao_ieptb.idconciliacao%type --ID da conciliacao
                               ,pr_dscritic  OUT VARCHAR2);
                               
  PROCEDURE pc_gera_conciliacao_web(pr_idlancto IN tbfin_recursos_movimento.idlancto%TYPE -- ID da TED
                                   ,pr_xmllog   IN VARCHAR2                               -- XML com informações de LOG
                                   ,pr_cdcritic OUT PLS_INTEGER                           -- Código da crítica
                                   ,pr_dscritic OUT VARCHAR2                              -- Descrição da crítica
                                   ,pr_retxml   IN OUT NOCOPY XMLType                     -- Arquivo de retorno do XML
                                   ,pr_nmdcampo OUT VARCHAR2                              -- Nome do campo com erro                      
                                   ,pr_des_erro OUT VARCHAR2);
                               
                          
  PROCEDURE pc_exporta_conciliacao_pdf(pr_cdcooper_usr  IN craptab.cdcooper%TYPE --> Cooperativa que está sendo executada
                                      ,pr_cdcooper  	 IN craptab.cdcooper%TYPE         --> Cooperativa
                                      ,pr_nrdconta      IN crapceb.nrdconta%TYPE --> Numero da conta do cooperado
                                      ,pr_dtinicial     IN VARCHAR2 -- Data inicial de recebimento de ted
                                      ,pr_dtfinal       IN VARCHAR2 -- Data final de recebimento de ted
                                      ,pr_vlinicial     IN tbfin_recursos_movimento.vllanmto%TYPE -- Valor inicial de comparação ted
                                      ,pr_vlfinal       IN tbfin_recursos_movimento.vllanmto%TYPE -- Valor final de comparação ted
                                      ,pr_cartorio      IN tbfin_recursos_movimento.nrcnpj_debitada%TYPE -- Cartorio da ted
                                      ,pr_xmllog        IN VARCHAR2                -- XML com informações de LOG
                                      ,pr_cdcritic      OUT PLS_INTEGER            -- Código da crítica
                                      ,pr_dscritic      OUT VARCHAR2               -- Descrição da crítica
                                      ,pr_retxml        IN OUT NOCOPY XMLType      -- Arquivo de retorno do XML
                                      ,pr_nmdcampo      OUT VARCHAR2               -- Nome do Campo
                                      ,pr_des_erro      OUT VARCHAR2);
                                      
   PROCEDURE pc_exporta_conciliacao(pr_cdcooper  IN craptab.cdcooper%TYPE         --> Cooperativa
                                    ,pr_dtinicial     IN VARCHAR2 -- Data inicial de recebimento de ted
                            	      ,pr_dtfinal       IN VARCHAR2 -- Data final de recebimento de ted
                                    ,pr_vlinicial     IN tbfin_recursos_movimento.vllanmto%TYPE -- Valor inicial de comparação ted
                                    ,pr_vlfinal       IN tbfin_recursos_movimento.vllanmto%TYPE -- Valor final de comparação ted
                                    ,pr_cartorio      IN tbfin_recursos_movimento.nrcnpj_debitada%TYPE -- Cartorio da ted                       
                                    ,pr_nrregist      IN INTEGER                 -- Quantidade de registros
                                    ,pr_nriniseq      IN INTEGER                 -- Qunatidade inicial
                                    ,pr_flgcon        IN INTEGER DEFAULT 0       -- TEDs conciliadas: '1' sim '0' não
                                    ,pr_xmllog        IN VARCHAR2                -- XML com informações de LOG
                                    ,pr_cdcritic      OUT PLS_INTEGER            -- Código da crítica
                                    ,pr_dscritic      OUT VARCHAR2               -- Descrição da crítica
                                    ,pr_retxml        IN OUT NOCOPY xmltype      -- Arquivo de retorno do XML
                                    ,pr_nmdcampo      OUT VARCHAR2               -- Nome do Campo
                                    ,pr_des_erro      OUT VARCHAR2);
                         
                         
   PROCEDURE pc_valida_cartorio_web(pr_cdcooper   IN craptab.cdcooper%TYPE
                                   ,pr_idlancto   IN TBFIN_RECURSOS_MOVIMENTO.IDLANCTO%TYPE
                                   ,pr_xmllog     IN VARCHAR2                 -- XML com informações de LOG
                                   ,pr_cdcritic   OUT PLS_INTEGER             -- Código da crítica
                                   ,pr_dscritic   OUT VARCHAR2
                                   ,pr_retxml     IN OUT NOCOPY XMLType       -- Arquivo de retorno do XML
                                   ,pr_nmdcampo   OUT VARCHAR2                -- Nome do Campo
                                   ,pr_des_erro   OUT VARCHAR2);
                              
   PROCEDURE pc_retorna_titulo_web(pr_cdcooper   IN tbcobran_retorno_ieptb.cdcooper%TYPE
                                  ,pr_nrdconta   IN tbcobran_retorno_ieptb.nrdconta%TYPE
                                  ,pr_nrcnvcob   IN tbcobran_retorno_ieptb.nrcnvcob%TYPE
                                  ,pr_nrdocmto   IN tbcobran_retorno_ieptb.nrdocmto%TYPE
                                  ,pr_xmllog     IN VARCHAR2                 -- XML com informações de LOG
                                  ,pr_cdcritic   OUT PLS_INTEGER             -- Código da crítica
                                  ,pr_dscritic   OUT VARCHAR2
                                  ,pr_retxml     IN OUT NOCOPY XMLType       -- Arquivo de retorno do XML
                                  ,pr_nmdcampo   OUT VARCHAR2                -- Nome do Campo
                                  ,pr_des_erro   OUT VARCHAR2);                      

   PROCEDURE pc_estornar_ted(pr_cdcooper      IN craptab.cdcooper%TYPE    -- Cooperativa
                             ,pr_cdoperad      IN VARCHAR2                 -- Codigo Operador
                             ,pr_idlancto      IN TBFIN_RECURSOS_MOVIMENTO.idlancto%TYPE -- Código da TED
                             ,pr_idretorno     IN TBCOBRAN_RETORNO_IEPTB.Idretorno%TYPE -- Código do retorno
                             ,pr_xmllog        IN VARCHAR2                 -- XML com informações de LOG
                             ,pr_cdcritic      OUT PLS_INTEGER             -- Código da crítica
                             ,pr_dscritic      OUT VARCHAR2
                                          ,pr_retxml        IN OUT NOCOPY XMLType      -- Arquivo de retorno do XML
                                          ,pr_nmdcampo      OUT VARCHAR2               -- Nome do Campo
                                          ,pr_des_erro      OUT VARCHAR2);

   PROCEDURE pc_exp_extrado_consolidado_pdf(pr_cdcooper     IN craptab.cdcooper%TYPE   --> Cooperativa
                                          ,pr_dtinimvt      IN VARCHAR2                --> Data inicial
                                          ,pr_dtfimmvt      IN VARCHAR2                --> Data final
                                          ,pr_xmllog        IN VARCHAR2                --> XML com informações de LOG
                                          ,pr_cdcritic      OUT PLS_INTEGER            --> Código da crítica
                                          ,pr_dscritic      OUT VARCHAR2               --> Descrição da crítica
                                          ,pr_retxml        IN OUT NOCOPY xmltype      --> Arquivo de retorno do XML
                                          ,pr_nmdcampo      OUT VARCHAR2               --> Nome do Campo
                                          ,pr_des_erro      OUT VARCHAR2);

END TELA_MANPRT;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_MANPRT IS
  ---------------------------------------------------------------------------
  --
  --  Programa : TELA_MANPRT
  --  Sistema  : Ayllos Web
  --  Autor    : Helinton Steffens (Supero)
  --  Data     : Janeiro - 2018                 Ultima atualizacao: 25/07/2019
  --
  -- Dados referentes ao programa:
  --
  -- Objetivo  : Centralizar rotinas relacionadas a tela PARPRT
  --
  -- Alteracoes: Adaptado script para contemplar os parametros da tela PARPRT
  
  /*
     24/09/2018 - Ajuste no cursor tbfin_recursos_movimento CS 25859 (Andre Supero)
  
     26/09/2018 - inc0024348 Passagem do nome do programa para a execução da rotina 
                  pc_gera_conciliacao_auto para não criticar validações para o job (Carlos)

     28/09/2018 - Alterado select para remover cdcartorio na selecao do cartorio para a conciliacao. (Fabio Stein - Supero)
      
     04/10/2018 - Alterado validação de data da conciliação. Realizando somente para a automatica.. (Fabio Stein - Supero)
                - Ajustado query de conciliações para pois o lcódigo isbp 0 para o banco do brasil retornava varios bancos.
                - Ajustado banco.flgdispb para 1 na query de conciliações.
    
     23/10/2018 - Alterado consulta de tarifas e custas para incluir o cdcartorio. (Fabio Stein - Supero)
     
     23/01/2019 - Tratamento para histórico 2917 - Liq de boleto em cartório via DOC 
                - Desvinculado o cadastro de cartórios no processo de conciliação. (P352 - Cechet)
                
     27/03/2019 - Colocar o tpocorre como texto pois pode haver casos em 
                  que vem campo texto (Lucas Ranghetti INC0036169)

     16/04/2019 - INC0011935 - Melhorias diversas nos layouts de teds e conciliação:
                - modal de conciliação arrastável e correção das colunas para não obstruir as caixas de seleção;
                - aumentadas as alturas das listas de teds e modal de conciliação, reajustes das colunas (Carlos)
                  
     25/07/2019 - inc0021120 Na rotina pc_consulta_nao_conciliados, incluído o tipo de ocorrência 7
                  (liquidacao em condicional) no cursor cr_titulos para que os mesmos apareçam na tela 
                  para serem conciliados (Carlos) 

     24/06/2019 - Permitir conciliar mais de uma TED.(Jose Dill - Mouts RITM0013002)

   ---------------------------------------------------------------------------*/
    
    
    CURSOR cr_tbcobran_conciliacao_ieptb(pr_dtinicial    IN VARCHAR2
                                        ,pr_dtfinal       IN VARCHAR2
                                        ,pr_vlinicial     IN tbfin_recursos_movimento.vllanmto%TYPE
                                        ,pr_vlfinal       IN tbfin_recursos_movimento.vllanmto%TYPE
                                        ,pr_cartorio      IN tbfin_recursos_movimento.nrcnpj_debitada%TYPE
                                        ,pr_flgcon        IN INTEGER) IS
    /*select mun.dscidade || ' - ' || mun.cdestado nmcartorio
          ,mov.vllanmto
          ,ret.nrcnvcob
          ,coop.nmrescop
          ,mov.nrdconta
          ,conc.dtconcilicao
          ,ret.vltitulo
          ,conc.dtdproc
          ,banco.cdbccxlt
          ,mov.cdagenci_debitada
          ,mun.dscidade
          ,mun.cdestado
--          ,cartorio.nrcpf_cnpj
          ,mov.dtmvtolt
    from tbcobran_conciliacao_ieptb conc
        ,tbcobran_retorno_ieptb ret
--        ,tbcobran_cartorio_protesto cartorio
        ,crapmun mun
        ,tbfin_recursos_movimento mov
        ,crapcop coop
        ,crapban banco
    where ret.idretorno = conc.idretorno_ieptb
      and conc.idrecurso_movto = mov.idlancto
      and mun.cdufibge || LPAD(mun.cdcidbge,5,'0') = ret.cdcomarc
      and mov.cdcooper = coop.cdcooper
      and mov.nrispbif = banco.nrispbif
      AND banco.flgdispb = 1
      and ((conc.dtconcilicao between to_date(pr_dtinicial,'DD/MM/RRRR') and to_date(pr_dtfinal,'DD/MM/RRRR')) 
         or (pr_dtinicial is null and pr_dtfinal is null))
      and ((ret.vltitulo >= pr_vlinicial and ret.vltitulo <= pr_vlfinal) 
         or (pr_vlinicial = 0 and pr_vlfinal = 0))
--      and (cartorio.nrcpf_cnpj = pr_cartorio or pr_cartorio is null)
      ;*/
      
      /*RITM0013002 - Querie atualizada de acordo com a nova estrutura de conciliação*/
      select 
           mun.dscidade || ' - ' || mun.cdestado nmcartorio
          , (SELECT (sys.stragg('Vl '||mov.vllanmto ||'  Dt '||to_char(mov.dtmvtolt,'dd/mm/yy') || '  Ct ' || mov.dsconta_debitada || CHR(13) ||'<br>')) 
               FROM tbfin_recursos_movimento mov
                   ,crapban banco
              WHERE mov.idconciliacao = conc.idconciliacao
                AND banco.nrispbif = mov.nrispbif
                AND banco.flgdispb = 1                
                ) inf_teds 
          , (SELECT (sys.stragg('Vl '||mov.vllanmto ||' Dt '||to_char(mov.dtmvtolt,'dd/mm/yy') || ' Ct ' || mov.dsconta_debitada || CHR(13) || CHR(10))) 
               FROM tbfin_recursos_movimento mov
                   ,crapban banco
              WHERE mov.idconciliacao = conc.idconciliacao
                AND banco.nrispbif = mov.nrispbif
                AND banco.flgdispb = 1                
                ) inf_teds_compacta                 
          , (SELECT (sys.stragg(mov.vllanmto ||' - '||to_char(mov.dtmvtolt,'dd/mm/yyyy') || ' - ' || mov.dsconta_debitada||'  ' )) 
               FROM tbfin_recursos_movimento mov
                   ,crapban banco
              WHERE mov.idconciliacao = conc.idconciliacao
                AND banco.nrispbif = mov.nrispbif
                AND banco.flgdispb = 1                
                ) inf_teds_excel                 
          , (SELECT (sys.stragg(banco.cdbccxlt || '/' || mov.cdagenci_debitada || CHR(13) || CHR(10))) 
               FROM tbfin_recursos_movimento mov
                   ,crapban banco
              WHERE mov.idconciliacao = conc.idconciliacao
                AND banco.nrispbif = mov.nrispbif
                AND banco.flgdispb = 1                
                ) ds_banco_age  
          , (SELECT SUM(mov.vllanmto) 
               FROM tbfin_recursos_movimento mov
                   ,crapban banco
              WHERE mov.idconciliacao = conc.idconciliacao
                AND banco.nrispbif = mov.nrispbif
                AND banco.flgdispb = 1                 
                ) vl_total_ted                               
          ,ret.nrcnvcob
          ,ret.idretorno
          ,conc.idconciliacao
          ,coop.nmrescop
          ,conc.dtconcilicao
          ,ret.vltitulo
          ,conc.dtdproc
          ,mun.dscidade
          ,mun.cdestado 
    from tbcobran_conciliacao_ieptb conc
        ,tbcobran_retorno_ieptb ret
        ,crapmun mun
        ,crapcop coop
    where conc.idconciliacao = ret.idconciliacao 
      and coop.cdcooper = ret.cdcooper
      and mun.cdufibge || LPAD(mun.cdcidbge,5,'0') = ret.cdcomarc
      and ((conc.dtconcilicao between to_date(pr_dtinicial,'DD/MM/RRRR') and to_date(pr_dtfinal,'DD/MM/RRRR')) 
         or (pr_dtinicial is null and pr_dtfinal is null))
      and ((ret.vltitulo >= pr_vlinicial and ret.vltitulo <= pr_vlfinal) 
         or (pr_vlinicial = 0 and pr_vlfinal = 0)) 
     Order by ret.dtconciliacao desc, ret.idretorno;    


    rw_tbcobran_conciliacao_ieptb cr_tbcobran_conciliacao_ieptb%ROWTYPE;
                                                                              
    
   CURSOR cr_tbcobran_retorno_ieptb(pr_cdcooper      IN INTEGER
                                   ,pr_nrdconta      IN crapceb.nrdconta%TYPE
                                   ,pr_dtinicial     IN VARCHAR2
                                   ,pr_dtfinal       IN VARCHAR2
                                   ,pr_cdestado      IN VARCHAR2
                                   ,pr_cartorio      IN tbfin_recursos_movimento.nrcnpj_debitada%TYPE
                                   ,pr_flcustas      IN INTEGER) IS
     SELECT retorno.vlgrava_eletronica AS tarifas
         ,retorno.vlcuscar AS custas_cartorarias -- custo cartorio
         ,retorno.vlcustas_cartorio AS custas_distribuidor -- custo distribuicao
         ,retorno.vldemais_despes AS demais_despesas
         ,(retorno.vlcuscar + retorno.vlcustas_cartorio + retorno.vldemais_despes) AS total_despesas -- total saldo
         ,retorno.dtmvtolt -- data do recebimento
         ,crapcop.nmrescop -- cooperativa
         ,cartorio.nmcartorio -- cartorio
         ,crapmun.cdestado -- estado
         ,crapcob.nrnosnum -- nosso numero
         ,NVL(tar.dtmvtolt,NVL(cus.dtmvtolt,NULL)) AS dtcustar
         ,NVL(tar.nrdocmto,NVL(cus.nrdocmto,NULL)) AS nrdocmto
         ,TO_CHAR(TO_DATE(NVL(tar.hrtransa,NVL(cus.hrtransa,NULL)),'SSSSS'),'HH24:MI') AS hrtransa
    FROM tbcobran_retorno_ieptb retorno
         INNER JOIN crapcob ON (retorno.cdcooper = crapcob.cdcooper AND retorno.nrdconta = crapcob.nrdconta AND retorno.nrcnvcob = crapcob.nrcnvcob AND retorno.nrdocmto = crapcob.nrdocmto)
         INNER JOIN crapmun ON retorno.cdcomarc = crapmun.cdcomarc
         INNER JOIN tbcobran_cartorio_protesto cartorio ON crapmun.idcidade = cartorio.idcidade AND retorno.cdcartorio = cartorio.cdcartorio         
         INNER JOIN crapcop ON retorno.cdcooper = crapcop.cdcooper
         LEFT JOIN tbfin_recursos_movimento tar ON tar.idlancto = retorno.idlancto_tarifa
         LEFT JOIN tbfin_recursos_movimento cus ON cus.idlancto = retorno.idlancto_custas
    WHERE (retorno.flcustas_proc = pr_flcustas OR pr_flcustas IS NULL)
          AND (crapmun.cdestado = pr_cdestado OR pr_cdestado IS NULL)
          AND (crapcob.cdcooper = pr_cdcooper OR pr_cdcooper = 3)
          AND (crapcob.nrdconta = pr_nrdconta OR pr_nrdconta IS NULL)
          AND (cartorio.nrcpf_cnpj = pr_cartorio OR pr_cartorio IS NULL)
          AND ((retorno.dtcustas_proc BETWEEN to_date(pr_dtinicial,'DD/MM/RRRR') AND to_date(pr_dtfinal,'DD/MM/RRRR')) 
                 OR (pr_dtinicial IS NULL AND pr_dtfinal IS NULL))

    UNION ALL

    SELECT confirmacao.vlgrava_eletronica AS tarifas
          ,confirmacao.vlcuscar AS custas_cartorarias
          ,confirmacao.vlcustas_cartorio AS custas_distribuidor
          ,confirmacao.vldemais_despes AS demais_despesas
          ,(confirmacao.vlcuscar + confirmacao.vlcustas_cartorio + confirmacao.vldemais_despes) AS total_despesas
          ,confirmacao.dtmvtolt -- data do recebimento
          ,crapcop.nmrescop -- cooperativa
          ,cartorio.nmcartorio -- cartorio
          ,crapmun.cdestado -- estado
          ,crapcob.nrnosnum -- nosso numero
          ,NVL(tar.dtmvtolt,NVL(cus.dtmvtolt,NULL)) AS dtcustar
          ,NVL(tar.nrdocmto,NVL(cus.nrdocmto,NULL)) AS nrdocmto
          ,TO_CHAR(TO_DATE(NVL(tar.hrtransa,NVL(cus.hrtransa,NULL)),'SSSSS'),'HH24:MI') AS hrtransa
    FROM  tbcobran_confirmacao_ieptb confirmacao
          INNER JOIN crapcob ON (confirmacao.cdcooper = crapcob.cdcooper AND confirmacao.nrdconta = crapcob.nrdconta AND confirmacao.nrcnvcob = crapcob.nrcnvcob AND confirmacao.nrdocmto = crapcob.nrdocmto)
          INNER JOIN crapmun ON confirmacao.cdcomarc = crapmun.cdcomarc
          INNER JOIN tbcobran_cartorio_protesto cartorio ON crapmun.idcidade = cartorio.idcidade AND confirmacao.cdcartorio = cartorio.cdcartorio          
          INNER JOIN crapcop ON confirmacao.cdcooper = crapcop.cdcooper
          LEFT JOIN tbfin_recursos_movimento tar ON tar.idlancto = confirmacao.idlancto_tarifa
          LEFT JOIN tbfin_recursos_movimento cus ON cus.idlancto = confirmacao.idlancto_custas
    WHERE (confirmacao.flcustas_proc = pr_flcustas OR pr_flcustas IS NULL)
          AND (crapmun.cdestado = pr_cdestado OR pr_cdestado IS NULL)
          AND (crapcob.cdcooper = pr_cdcooper OR pr_cdcooper = 3)
          AND (crapcob.nrdconta = pr_nrdconta OR pr_nrdconta IS NULL)
          AND (cartorio.nrcpf_cnpj = pr_cartorio OR pr_cartorio IS NULL)
          AND ((confirmacao.dtcustas_proc BETWEEN to_date(pr_dtinicial,'DD/MM/RRRR') AND to_date(pr_dtfinal,'DD/MM/RRRR')) 
                 OR (pr_dtinicial IS NULL AND pr_dtfinal IS NULL));          
   rw_tbcobran_retorno_ieptb cr_tbcobran_retorno_ieptb%ROWTYPE;  

   CURSOR cr_tbcobran_ted(pr_idlancto IN tbfin_recursos_movimento.idlancto%TYPE) IS
   SELECT tr.cdagenci_debitada
         ,tr.dsconta_debitada
         ,tr.inpessoa_debitada
				 ,tr.nmtitular_debitada
				 ,tr.nrcnpj_debitada
				 ,tpconta_debitada
         ,tr.nrispbif
         ,tr.cdagenci_creditada
         ,tr.dsconta_creditada
         ,tr.nmtitular_creditada
         ,tr.nrcnpj_creditada
         ,tr.tpconta_creditada
         ,tr.inpessoa_creditada
         ,tr.vllanmto
         ,tr.cdhistor
         ,tr.nrdocmto
         ,tr.dtmvtolt
    FROM tbfin_recursos_movimento tr
    WHERE tr.idlancto = pr_idlancto;
    rw_tbcobran_ted cr_tbcobran_ted%ROWTYPE;
    
    CURSOR cr_tbcobran_retorno(pr_idretorno IN TBCOBRAN_RETORNO_IEPTB.idretorno%TYPE) IS
    SELECT cdcooper
          ,dtmvtolt
          ,cdcomarc
          ,nrseqrem
          ,nrseqarq
          ,nrdconta
          ,nrcnvcob
          ,nrdocmto
          ,nrremret
          ,nrseqreg
          ,cdcartorio
          ,nrprotoc_cartorio
          ,dtprotocolo
          ,vlcuscar
          ,dtocorre
          ,cdirregu
          ,vlcustas_cartorio
          ,vlgrava_eletronica
          ,cdcomplem_irregular
          ,vldemais_despes
          ,vltitulo
          ,vlsaldo_titulo
          ,dsregist
          ,(vlcuscar + vlcustas_cartorio + vldemais_despes) as custas
          FROM TBCOBRAN_RETORNO_IEPTB
    WHERE idretorno = pr_idretorno;
    rw_tbcobran_retorno cr_tbcobran_retorno%ROWTYPE;
    
    --Extrato das custas
    CURSOR cr_extrato_custas(pr_dtinimvt IN VARCHAR2
                            ,pr_dtfimmvt IN VARCHAR2) IS
      select
         mov.dtmvtolt data
        ,mov.cdhistor || ' - ' || his.dshistor historico
        ,case his.indebcre
              when 'C' then sum(nvl(mov.vllanmto,0))
              else - sum(nvl(mov.vllanmto,0))
        END vllancamento 
      from 
        tbfin_recursos_movimento mov
       ,craphis                  his
      where (
                mov.dtmvtolt between to_date(pr_dtinimvt,'DD/MM/YYYY') AND to_date(pr_dtfimmvt,'DD/MM/YYYY') OR
               (pr_dtinimvt is null OR pr_dtfimmvt is null)
            )
      and mov.cdhistor in ('2636', '2642')
      and mov.cdhistor = his.cdhistor
      and his.cdcooper = mov.cdcooper      
      group by 
         mov.dtmvtolt
        ,mov.cdhistor
        ,his.dshistor
        ,his.indebcre
      order by 
        mov.dtmvtolt desc;
    rw_extrato_custas cr_extrato_custas%ROWTYPE;
    
    --Extrato das tarifas
    CURSOR cr_extrato_tarifas(pr_dtinimvt IN VARCHAR2
                             ,pr_dtfimmvt IN VARCHAR2) IS

      select
         mov.dtmvtolt data
        ,mov.cdhistor || ' - ' || his.dshistor historico
        ,case his.indebcre
              when 'C' then sum(nvl(mov.vllanmto,0))
              else - sum(nvl(mov.vllanmto,0))
        END vllancamento 
      from 
        tbfin_recursos_movimento mov
       ,craphis                  his
      where (
                mov.dtmvtolt between to_date(pr_dtinimvt,'DD/MM/YYYY') AND to_date(pr_dtfimmvt,'DD/MM/YYYY') OR
               (pr_dtinimvt is null OR pr_dtfimmvt is null)
            )
      and mov.cdhistor in ('2644', '2646')
      and mov.cdhistor = his.cdhistor
      and his.cdcooper = mov.cdcooper
      group by 
         mov.dtmvtolt
        ,mov.cdhistor
        ,his.dshistor
         ,his.indebcre
      order by 
        mov.dtmvtolt desc;
        
    rw_extrato_tarifas cr_extrato_tarifas%ROWTYPE;
    
    --Extrato das tarifas
    CURSOR cr_extrato_teds_naoconc_devolv(pr_dtinimvt IN VARCHAR2
                                         ,pr_dtfimmvt IN VARCHAR2) IS

          select  
             mov.dtmvtolt data
            ,mov.cdhistor || ' - ' || his.dshistor  historico
             ,case his.indebcre
              when 'C' then sum(nvl(mov.vllanmto,0))
              else - sum(nvl(mov.vllanmto,0))
        END vllancamento 
      from 
              tbfin_recursos_movimento  mov
             ,craphis                   his
      where  (
                mov.dtmvtolt between to_date(pr_dtinimvt,'DD/MM/YYYY') AND to_date(pr_dtfimmvt,'DD/MM/YYYY') OR
               (pr_dtinimvt is null OR pr_dtfimmvt is null)
             )
              and (mov.cdhistor  in(2663,2734)
              or (mov.cdhistor  IN (2622,2917) and mov.dtconciliacao is null ))
              and his.cdhistor = mov.cdhistor
              and his.cdcooper = mov.cdcooper
      group by 
               mov.dtmvtolt
              ,mov.cdhistor
              ,his.dshistor 
              ,his.indebcre
      order by 
              mov.dtmvtolt desc;
    rw_extrato_teds_naoconc_devolv cr_extrato_teds_naoconc_devolv%ROWTYPE;
    
    
   PROCEDURE pc_gera_log(pr_cdcooper      IN crapcop.cdcooper%TYPE,
                         pr_dscritic      IN VARCHAR2,
                         pr_dstransa      IN VARCHAR2,
                         pr_flgtrans      IN VARCHAR2) IS
  /* ..........................................................................
    
    Programa : pc_gera_log        
    Sistema  : 
    Sigla    : CRED
    Autor    : Augusto Henrique da Conceição (SUPERO)
    Data     : Março/2018.                   Ultima atualizacao: 31/03/2018
    
    Dados referentes ao programa:
    
    Frequencia: ---
    Objetivo  : 
    
    Alteração : 
        
  ..........................................................................*/
  vr_nrdrowid VARCHAR2(500) := NULL;

  BEGIN
    GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                        ,pr_cdoperad => 1
                        ,pr_dscritic => pr_dscritic
                        ,pr_dsorigem => ''
                        ,pr_dstransa => pr_dstransa
                        ,pr_dttransa => TRUNC(SYSDATE)
                        ,pr_flgtrans => pr_flgtrans
                        ,pr_hrtransa => gene0002.fn_busca_time
                        ,pr_idseqttl => 1
                        ,pr_nmdatela => NULL
                        ,pr_nrdconta => 0
                        ,pr_nrdrowid => vr_nrdrowid);
  END pc_gera_log;
  
  
  PROCEDURE pc_consulta_teds(pr_dtinicial     IN VARCHAR2 -- Data inicial de recebimento de ted
                            ,pr_dtfinal       IN VARCHAR2 -- Data final de recebimento de ted
                            ,pr_vlinicial     IN tbfin_recursos_movimento.vllanmto%TYPE -- Valor inicial de comparação ted
                            ,pr_vlfinal       IN tbfin_recursos_movimento.vllanmto%TYPE -- Valor final de comparação ted
                            ,pr_cartorio      IN tbfin_recursos_movimento.nrcnpj_debitada%TYPE -- Cartorio da ted                       
                            ,pr_nrregist      IN INTEGER                 -- Quantidade de registros
                            ,pr_nriniseq      IN INTEGER                 -- Qunatidade inicial
                            ,pr_xmllog        IN VARCHAR2                -- XML com informações de LOG
                            ,pr_cdcritic      OUT PLS_INTEGER            -- Código da crítica
                            ,pr_dscritic      OUT VARCHAR2               -- Descrição da crítica
                            ,pr_retxml        IN OUT NOCOPY XMLType      -- Arquivo de retorno do XML
                            ,pr_nmdcampo      OUT VARCHAR2               -- Nome do Campo
                            ,pr_des_erro      OUT VARCHAR2) IS

  /*---------------------------------------------------------------------------------------------------------------

    Programa : pc_busca_teds                            antiga:
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Helinton Steffens (Supero)
    Data     : Março/2018                           Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: -----
    Objetivo   : Pesquisa de teds recebidas pelo IEPTB

    Alterações :
    -------------------------------------------------------------------------------------------------------------*/

    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);

    --Tabela de Erros
    vr_tab_erro gene0001.typ_tab_erro;

    -- Variaveis de log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);

    --Variaveis Locais
    vr_qtregist INTEGER := 0;
    vr_clob     CLOB;
    vr_xml_temp VARCHAR2(32726) := '';
    vr_nrregist INTEGER;
    vr_contador INTEGER :=0;
    vr_flgfirst BOOLEAN := TRUE;

    --Variaveis de Indice
    vr_index PLS_INTEGER;

    --Variaveis de Excecoes
    vr_exc_ok    EXCEPTION;
    vr_exc_erro  EXCEPTION;

    BEGIN

      --limpar tabela erros
      vr_tab_erro.DELETE;

      --Inicializar Variaveis
      vr_nrregist:= pr_nrregist;
      vr_cdcritic:= 0;
      vr_dscritic:= NULL;

    -- Criar cabeçalho do XML
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="UTF-8"?><Root/>');
    
    GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                          ,pr_tag_pai  => 'Root'
                          ,pr_posicao  => 0
                          ,pr_tag_nova => 'Dados'
                          ,pr_tag_cont => NULL
                          ,pr_des_erro => vr_dscritic);
    
    GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                          ,pr_tag_pai  => 'Dados'
                          ,pr_posicao  => 0
                          ,pr_tag_nova => 'inf'
                          ,pr_tag_cont => NULL
                          ,pr_des_erro => vr_dscritic); 

    FOR rw_tbfin_recursos_movimento IN cr_tbfin_recursos_movimento(pr_dtinicial => pr_dtinicial
                                                ,pr_dtfinal   => pr_dtfinal
                        ,pr_vlinicial => pr_vlinicial
                        ,pr_vlfinal   => pr_vlfinal
                                                                  ,pr_cartorio  => pr_cartorio
                                                                  ,pr_flgcon    => 0) LOOP

      --Incrementar Quantidade Registros do Parametro
      vr_qtregist:= nvl(vr_qtregist,0) + 1;

        
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'idlancto', pr_tag_cont => rw_tbfin_recursos_movimento.idlancto, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nmcartorio', pr_tag_cont => rw_tbfin_recursos_movimento.nome_cartorio, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nmremetente', pr_tag_cont => rw_tbfin_recursos_movimento.nome_remetente, pr_des_erro => vr_dscritic);
        IF LENGTH(rw_tbfin_recursos_movimento.cnpj_cpf) > 11 THEN
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'cnpj_cpf', pr_tag_cont => gene0002.fn_mask_cpf_cnpj(rw_tbfin_recursos_movimento.cnpj_cpf,2), pr_des_erro => vr_dscritic);
        ELSE
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'cnpj_cpf', pr_tag_cont => gene0002.fn_mask_cpf_cnpj(rw_tbfin_recursos_movimento.cnpj_cpf,1), pr_des_erro => vr_dscritic);
        END IF;
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'banco', pr_tag_cont => rw_tbfin_recursos_movimento.nome_banco, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'agencia', pr_tag_cont => rw_tbfin_recursos_movimento.nome_agencia, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'conta', pr_tag_cont => rw_tbfin_recursos_movimento.conta, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'dtrecebimento', pr_tag_cont => to_char(rw_tbfin_recursos_movimento.data_recebimento,'DD/MM/RRRR'), pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'valor', pr_tag_cont => rw_tbfin_recursos_movimento.valor, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'estado', pr_tag_cont => rw_tbfin_recursos_movimento.nome_estado, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'cidade', pr_tag_cont => rw_tbfin_recursos_movimento.nome_cidade, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'status', pr_tag_cont => rw_tbfin_recursos_movimento.status, pr_des_erro => vr_dscritic);

        vr_contador := vr_contador + 1;
        vr_flgfirst := FALSE;

    END LOOP;
                                            
                          
    -- Insere atributo na tag Dados com a quantidade de registros
    gene0007.pc_gera_atributo(pr_xml   => pr_retxml           --> XML que irá receber o novo atributo
                             ,pr_tag   => 'Dados'            --> Nome da TAG XML
                             ,pr_atrib => 'qtregist'             --> Nome do atributo
                             ,pr_atval => vr_qtregist    --> Valor do atributo
                             ,pr_numva => 0                   --> Número da localização da TAG na árvore XML
                             ,pr_des_erro => vr_dscritic);    --> Descrição de erros

    --Se ocorreu erro
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Erro
      pr_cdcritic:= vr_cdcritic;
      pr_dscritic:= vr_dscritic;

      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');

    WHEN OTHERS THEN
      -- Retorno não OK
      pr_des_erro:= 'NOK';

      -- Erro
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na pc_consulta_teds --> '|| SQLERRM;

      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');

  END pc_consulta_teds;
  
  PROCEDURE pc_consulta_conciliacoes(pr_dtinicial     IN VARCHAR2 -- Data inicial de recebimento de ted
                            ,pr_dtfinal       IN VARCHAR2 -- Data final de recebimento de ted
                            ,pr_vlinicial     IN tbfin_recursos_movimento.vllanmto%TYPE -- Valor inicial de comparação ted
                            ,pr_vlfinal       IN tbfin_recursos_movimento.vllanmto%TYPE -- Valor final de comparação ted
                            ,pr_cartorio      IN tbfin_recursos_movimento.nrcnpj_debitada%TYPE -- Cartorio da ted                       
                            ,pr_nrregist      IN INTEGER                 -- Quantidade de registros
                            ,pr_nriniseq      IN INTEGER                 -- Qunatidade inicial
                            ,pr_xmllog        IN VARCHAR2                -- XML com informações de LOG
                            ,pr_cdcritic      OUT PLS_INTEGER            -- Código da crítica
                            ,pr_dscritic      OUT VARCHAR2               -- Descrição da crítica
                            ,pr_retxml        IN OUT NOCOPY XMLType      -- Arquivo de retorno do XML
                            ,pr_nmdcampo      OUT VARCHAR2               -- Nome do Campo
                            ,pr_des_erro      OUT VARCHAR2) IS

  /*---------------------------------------------------------------------------------------------------------------

    Programa : pc_consulta_conciliacoes                            antiga:
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Augusto Henrique da Conceição (Supero)
    Data     : Abril/2018                           Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: -----
    Objetivo   : Pesquisa de conciliações do IEPTB

    Alterações :
    -------------------------------------------------------------------------------------------------------------*/

    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);

    --Tabela de Erros
    vr_tab_erro gene0001.typ_tab_erro;

    -- Variaveis de log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);

    --Variaveis Locais
    vr_qtregist INTEGER := 0;
    vr_clob     CLOB;
    vr_xml_temp VARCHAR2(32726) := '';
    vr_nrregist INTEGER;
    vr_contador INTEGER :=0;
    vr_flgfirst BOOLEAN := TRUE;

    --Variaveis de Indice
    vr_index PLS_INTEGER;

    --Variaveis de Excecoes
    vr_exc_ok    EXCEPTION;
    vr_exc_erro  EXCEPTION;

    BEGIN

      --limpar tabela erros
      vr_tab_erro.DELETE;

      --Inicializar Variaveis
      vr_nrregist:= pr_nrregist;
      vr_cdcritic:= 0;
      vr_dscritic:= NULL;

    -- Criar cabeçalho do XML
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="UTF-8"?><Root/>');
    
    GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                          ,pr_tag_pai  => 'Root'
                          ,pr_posicao  => 0
                          ,pr_tag_nova => 'Dados'
                          ,pr_tag_cont => NULL
                          ,pr_des_erro => vr_dscritic);
    
    GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                          ,pr_tag_pai  => 'Dados'
                          ,pr_posicao  => 0
                          ,pr_tag_nova => 'inf'
                          ,pr_tag_cont => NULL
                          ,pr_des_erro => vr_dscritic); 

    FOR rw_tbcobran_conciliacao_ieptb IN cr_tbcobran_conciliacao_ieptb(pr_dtinicial => pr_dtinicial
                                                                      ,pr_dtfinal   => pr_dtfinal
                                                                      ,pr_vlinicial => pr_vlinicial
                                                                      ,pr_vlfinal   => pr_vlfinal
                                                                      ,pr_cartorio  => pr_cartorio
                                                                      ,pr_flgcon    => 0) LOOP

      --Incrementar Quantidade Registros do Parametro
      vr_qtregist:= nvl(vr_qtregist,0) + 1;

      /* controles da paginacao */
      IF (vr_qtregist < pr_nriniseq) OR
         (vr_qtregist > (pr_nriniseq + pr_nrregist)) THEN
         --Proxima TED
        CONTINUE;
      END IF;

      --Numero Registros
      IF vr_nrregist > 0 THEN

        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nmcartorio', pr_tag_cont => rw_tbcobran_conciliacao_ieptb.nmcartorio, pr_des_erro => vr_dscritic); --
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'infteds', pr_tag_cont => rw_tbcobran_conciliacao_ieptb.inf_teds , pr_des_erro => vr_dscritic); 
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'inftedscomp', pr_tag_cont => rw_tbcobran_conciliacao_ieptb.inf_teds_compacta , pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nrcnvcob', pr_tag_cont => rw_tbcobran_conciliacao_ieptb.nrcnvcob, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nmrescop', pr_tag_cont => rw_tbcobran_conciliacao_ieptb.nmrescop, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'dtconcilicao', pr_tag_cont => to_char(rw_tbcobran_conciliacao_ieptb.dtconcilicao,'DD/MM/RRRR'), pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'vltitulo', pr_tag_cont => rw_tbcobran_conciliacao_ieptb.vltitulo, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'dtdproc', pr_tag_cont => to_char(rw_tbcobran_conciliacao_ieptb.dtdproc,'DD/MM/RRRR'), pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'cdbccxlt', pr_tag_cont => rw_tbcobran_conciliacao_ieptb.ds_banco_age, pr_des_erro => vr_dscritic);  --cdbccxlt
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'dscidade', pr_tag_cont => rw_tbcobran_conciliacao_ieptb.dscidade, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'cdestado', pr_tag_cont => rw_tbcobran_conciliacao_ieptb.cdestado, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'vltotalted', pr_tag_cont => rw_tbcobran_conciliacao_ieptb.vl_total_ted, pr_des_erro => vr_dscritic);


        vr_contador := vr_contador + 1;
        vr_flgfirst := FALSE;

      END IF;

      --Diminuir registros
      vr_nrregist:= nvl(vr_nrregist,0) - 1;

    END LOOP;
                                            
                          
    -- Insere atributo na tag Dados com a quantidade de registros
    gene0007.pc_gera_atributo(pr_xml   => pr_retxml           --> XML que irá receber o novo atributo
                             ,pr_tag   => 'Dados'            --> Nome da TAG XML
                             ,pr_atrib => 'qtregist'             --> Nome do atributo
                             ,pr_atval => vr_qtregist    --> Valor do atributo
                             ,pr_numva => 0                   --> Número da localização da TAG na árvore XML
                             ,pr_des_erro => vr_dscritic);    --> Descrição de erros

    --Se ocorreu erro
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Erro
      pr_cdcritic:= vr_cdcritic;
      pr_dscritic:= vr_dscritic;

      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');

    WHEN OTHERS THEN
      -- Retorno não OK
      pr_des_erro:= 'NOK';

      -- Erro
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na pc_consulta_teds --> '|| SQLERRM;

      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');

  END pc_consulta_conciliacoes;
  
  PROCEDURE pc_consulta_custas(pr_cdcooper      IN INTEGER --> Cooperativa
                              ,pr_nrdconta      IN crapceb.nrdconta%TYPE --> Numero da conta do cooperado
                              ,pr_dtinicial     IN VARCHAR2 --> Data inicial de recebimento de ted
                              ,pr_dtfinal       IN VARCHAR2 --> Data final de recebimento de ted
                              ,pr_cdestado      IN VARCHAR2 --> Estado que veio a confirmação
                              ,pr_cartorio      IN VARCHAR2 --> Cartorio da ted
                              ,pr_flcustas      IN INTEGER  --> Exibir taxas/custas pagas
                              ,pr_xmllog        IN VARCHAR2                -- XML com informações de LOG
                              ,pr_cdcritic      OUT PLS_INTEGER            -- Código da crítica
                              ,pr_dscritic      OUT VARCHAR2               -- Descrição da crítica
                              ,pr_retxml        IN OUT NOCOPY xmltype      -- Arquivo de retorno do XML
                              ,pr_nmdcampo      OUT VARCHAR2               -- Nome do Campo
                              ,pr_des_erro      OUT VARCHAR2) IS

  /*---------------------------------------------------------------------------------------------------------------

    Programa : pc_consulta_custas
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : André Clemer (Supero)
    Data     : Abril/2018                           Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: -----
    Objetivo   : Pesquisa de custas

    Alterações :
    -------------------------------------------------------------------------------------------------------------*/

    -- Variavel de criticas
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(10000);

    -- Tratamento de erros
    vr_exc_saida EXCEPTION;

    -- Variaveis auxiliares
    vr_index INTEGER := 0;
    vr_auxconta INTEGER := 0;

    BEGIN
      
    -- Criar cabeçalho do XML
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="UTF-8"?><Root/>');
    
    GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                          ,pr_tag_pai  => 'Root'
                          ,pr_posicao  => 0
                          ,pr_tag_nova => 'Dados'
                          ,pr_tag_cont => NULL
                          ,pr_des_erro => vr_dscritic);
                          
    GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                          ,pr_tag_pai  => 'Dados'
                          ,pr_posicao  => 0
                          ,pr_tag_nova => 'inf'
                          ,pr_tag_cont => NULL
                          ,pr_des_erro => vr_dscritic);
                          
    FOR rw_tbcobran_retorno_ieptb IN cr_tbcobran_retorno_ieptb(pr_cdcooper 	 => pr_cdcooper
                                                           	  ,pr_nrdconta   => pr_nrdconta
                                                              ,pr_dtinicial  => pr_dtinicial
                                                              ,pr_dtfinal    => pr_dtfinal
                                                              ,pr_cdestado   => pr_cdestado
                                                              ,pr_cartorio   => pr_cartorio
                                                              ,pr_flcustas   => pr_flcustas) LOOP
                                                              
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'custas_cartorarias', pr_tag_cont => rw_tbcobran_retorno_ieptb.custas_cartorarias, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'custas_distribuidor', pr_tag_cont => rw_tbcobran_retorno_ieptb.custas_distribuidor, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'total_despesas', pr_tag_cont => rw_tbcobran_retorno_ieptb.total_despesas, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'dtmvtolt', pr_tag_cont => to_char(rw_tbcobran_retorno_ieptb.dtmvtolt, 'DD/MM/RRRR'), pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'nmrescop', pr_tag_cont => rw_tbcobran_retorno_ieptb.nmrescop, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'nmcartorio', pr_tag_cont => rw_tbcobran_retorno_ieptb.nmcartorio, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'cdestado', pr_tag_cont => rw_tbcobran_retorno_ieptb.cdestado, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'nrnosnum', pr_tag_cont => rw_tbcobran_retorno_ieptb.nrnosnum, pr_des_erro => vr_dscritic);

        vr_auxconta := vr_auxconta + 1;

    END LOOP;
    
  EXCEPTION
    WHEN vr_exc_saida THEN
      IF vr_cdcritic <> 0 THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      END IF;

      -- Carregar XML padrao para variavel de retorno
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;

    WHEN OTHERS THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina da tela MANCAR: ' || SQLERRM;

      -- Carregar XML padrão para variavel de retorno
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
  END pc_consulta_custas;
  
  PROCEDURE pc_exporta_consulta_teds(pr_cdcooper  IN craptab.cdcooper%TYPE         --> Cooperativa
                                    ,pr_dtinicial     IN VARCHAR2 -- Data inicial de recebimento de ted
                            	      ,pr_dtfinal       IN VARCHAR2 -- Data final de recebimento de ted
                                    ,pr_vlinicial     IN tbfin_recursos_movimento.vllanmto%TYPE -- Valor inicial de comparação ted
                                    ,pr_vlfinal       IN tbfin_recursos_movimento.vllanmto%TYPE -- Valor final de comparação ted
                                    ,pr_cartorio      IN tbfin_recursos_movimento.nrcnpj_debitada%TYPE -- Cartorio da ted                       
                                    ,pr_nrregist      IN INTEGER                 -- Quantidade de registros
                                    ,pr_nriniseq      IN INTEGER                 -- Qunatidade inicial
                                    ,pr_flgcon        IN INTEGER DEFAULT 0       -- TEDs conciliadas: '1' sim '0' não
                                    ,pr_xmllog        IN VARCHAR2                -- XML com informações de LOG
                                    ,pr_cdcritic      OUT PLS_INTEGER            -- Código da crítica
                                    ,pr_dscritic      OUT VARCHAR2               -- Descrição da crítica
                                    ,pr_retxml        IN OUT NOCOPY xmltype      -- Arquivo de retorno do XML
                                    ,pr_nmdcampo      OUT VARCHAR2               -- Nome do Campo
                                    ,pr_des_erro      OUT VARCHAR2) IS
	/* ............................................................................

       Programa: pc_exporta_consulta_teds
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Hélinton Steffens
       Data    : Abril/2017                     Ultima atualizacao: --/--/----

       Dados referentes ao programa:

       Frequencia: Sempre que chamado
       Objetivo  : Rotina responsavel por gerar o relatorio de teds a conciliar - Chamada ayllos Web

       Alteracoes: ----

    ............................................................................ */  
 
    -------------->> VARIAVEIS <<----------------
    -- Variavel de criticas
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(10000);
    vr_dsretorn VARCHAR2(1000);
    vr_des_reto VARCHAR2(10);
    vr_typ_saida      VARCHAR2(3);
    
    -- Tratamento de erros
    vr_exc_erro      EXCEPTION;
    vr_exc_saida     EXCEPTION;
    vr_tab_erro GENE0001.typ_tab_erro;

    -- Variaveis de log
    vr_cdoperad      VARCHAR2(100);
    vr_cdcooper_conectado NUMBER;
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
      
    -- Variaveis gerais
    vr_dsxmlrel CLOB;
    vr_xml_temp VARCHAR2(32726) := '';
    vr_clob     CLOB;
    vr_dsdiretorio VARCHAR2(1000);      --> Local onde sera gerado o relatorio
    vr_nmarquivo   VARCHAR2(1000);      --> Nome do relatorio CSV
    
  BEGIN                                                  
    -- Cria a variavel CLOB
    dbms_lob.createtemporary(vr_clob, TRUE);
    dbms_lob.open(vr_clob, dbms_lob.lob_readwrite);
    
    -- Busca o diretorio onde esta os arquivos Sicoob
    vr_dsdiretorio := gene0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                                pr_cdacesso => 'ROOT_DOMICILIO')||'/relatorios';
    vr_nmarquivo := 'MANPRT_'||to_char(SYSDATE,'HHMISS')||'.csv';
    -- Criar cabeçalho do CSV
    GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                           ,pr_texto_completo => vr_xml_temp
                           ,pr_texto_novo     => 'Cartorio;Remetente;CPF/CNPJ;Banco;Agencia;Conta;Data Rec;Valor;Estado;Cidade;Status'||chr(10));
    
    FOR rw_tbfin_recursos_movimento IN cr_tbfin_recursos_movimento(pr_dtinicial => pr_dtinicial
                                                                  ,pr_dtfinal   => pr_dtfinal
                                                                  ,pr_vlinicial => pr_vlinicial
                                                                  ,pr_vlfinal   => pr_vlfinal
                                                                  ,pr_cartorio  => pr_cartorio
                                                                  ,pr_flgcon    => pr_flgcon) LOOP
      -- Carrega os dados
      GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => rw_tbfin_recursos_movimento.nome_cartorio      ||';'||
                                                   rw_tbfin_recursos_movimento.nome_remetente     ||';'||
                                                   gene0002.fn_mask_cpf_cnpj(rw_tbfin_recursos_movimento.cnpj_cpf,1)       ||';'||
                                                   rw_tbfin_recursos_movimento.nome_banco         ||';'||
                                                   rw_tbfin_recursos_movimento.nome_agencia       ||';'||
                                                   rw_tbfin_recursos_movimento.conta              ||';'||
                                                   rw_tbfin_recursos_movimento.data_recebimento   ||';'||
                                                   rw_tbfin_recursos_movimento.valor              ||';'||
                                                   rw_tbfin_recursos_movimento.nome_estado        ||';'||
                                                   rw_tbfin_recursos_movimento.nome_cidade        ||';'||
                                                   rw_tbfin_recursos_movimento.status        ||chr(10));
    END LOOP;
    -- Encerrar o Clob
    GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                           ,pr_texto_completo => vr_xml_temp
                           ,pr_texto_novo     => ' '
                           ,pr_fecha_xml      => TRUE);

    -- Gera o relatorio
    GENE0002.pc_clob_para_arquivo(pr_clob => vr_clob,
                                  pr_caminho => vr_dsdiretorio,
                                  pr_arquivo => vr_nmarquivo,
                                  pr_des_erro => vr_dscritic);
    IF vr_dscritic IS NOT NULL THEN
       RAISE vr_exc_saida;
    END IF;

    -- copia contrato pdf do diretorio da cooperativa para servidor web
    GENE0002.pc_efetua_copia_pdf(pr_cdcooper => pr_cdcooper
                               , pr_cdagenci => NULL
                               , pr_nrdcaixa => NULL
                               , pr_nmarqpdf => vr_dsdiretorio||'/'||vr_nmarquivo
                               , pr_des_reto => vr_des_reto
                               , pr_tab_erro => vr_tab_erro
                               );

    -- caso apresente erro na operação
    IF nvl(vr_des_reto,'OK') <> 'OK' THEN
       IF vr_tab_erro.COUNT > 0 THEN -- verifica pl-table se existe erros
          vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic; -- busca primeira critica
          vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic; -- busca primeira descricao da critica
          RAISE vr_exc_saida; -- encerra programa
        END IF;
     END IF;

     -- Remover relatorio do diretorio padrao da cooperativa
     gene0001.pc_OScommand(pr_typ_comando => 'S'
                          ,pr_des_comando => 'rm '||vr_dsdiretorio||'/'||vr_nmarquivo
                          ,pr_typ_saida   => vr_typ_saida
                          ,pr_des_saida   => vr_dscritic);

     -- Se retornou erro
     IF vr_typ_saida = 'ERR' OR vr_dscritic IS NOT null THEN
        -- Concatena o erro que veio
        vr_dscritic := 'Erro ao remover arquivo: '||vr_dscritic;
        RAISE vr_exc_saida; -- encerra programa
     END IF;

     -- Criar XML de retorno para uso na Web
     pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><nmarqcsv>' || vr_nmarquivo|| '</nmarqcsv>');

     -- Libera a memoria do CLOB
     dbms_lob.close(vr_clob);
     dbms_lob.freetemporary(vr_clob);
                                        
  EXCEPTION
    WHEN vr_exc_erro THEN
      IF vr_cdcritic <> 0 THEN
        vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      END IF;

      vr_dscritic := '<![CDATA['||vr_dscritic||']]>';
      pr_dscritic := REPLACE(REPLACE(REPLACE(vr_dscritic,chr(13),' '),chr(10),' '),'''','´');

      -- Carregar XML padrao para variavel de retorno
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    WHEN OTHERS THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina da tela pc_exporta_consulta_teds: ' || SQLERRM;
      pr_dscritic := '<![CDATA['||pr_dscritic||']]>';
      pr_dscritic := REPLACE(REPLACE(REPLACE(pr_dscritic,chr(13),' '),chr(10),' '),'''','´');
      
      -- Carregar XML padrao para variavel de retorno
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');                                                   
  END pc_exporta_consulta_teds;

  PROCEDURE pc_exporta_consulta_teds_pdf(pr_cdcooper  IN craptab.cdcooper%TYPE         --> Cooperativa
                                    ,pr_dtinicial     IN VARCHAR2 -- Data inicial de recebimento de ted
                            	      ,pr_dtfinal       IN VARCHAR2 -- Data final de recebimento de ted
                                    ,pr_vlinicial     IN tbfin_recursos_movimento.vllanmto%TYPE -- Valor inicial de comparação ted
                                    ,pr_vlfinal       IN tbfin_recursos_movimento.vllanmto%TYPE -- Valor final de comparação ted
                                    ,pr_cartorio      IN tbfin_recursos_movimento.nrcnpj_debitada%TYPE -- Cartorio da ted
                                    ,pr_xmllog        IN VARCHAR2                -- XML com informações de LOG
                                    ,pr_cdcritic      OUT PLS_INTEGER            -- Código da crítica
                                    ,pr_dscritic      OUT VARCHAR2               -- Descrição da crítica
                                    ,pr_retxml        IN OUT NOCOPY xmltype      -- Arquivo de retorno do XML
                                    ,pr_nmdcampo      OUT VARCHAR2               -- Nome do Campo
                                    ,pr_des_erro      OUT VARCHAR2) IS
	/* ............................................................................

       Programa: pc_exporta_consulta_teds
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Hélinton Steffens
       Data    : Abril/2017                     Ultima atualizacao: --/--/----

       Dados referentes ao programa:

       Frequencia: Sempre que chamado
       Objetivo  : Rotina responsavel por gerar o relatorio de teds a conciliar - Chamada ayllos Web

       Alteracoes: ----

    ............................................................................ */  
 
    -------------->> VARIAVEIS <<----------------
    -- Variavel de criticas
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(10000);
    vr_des_reto VARCHAR2(10);
    vr_typ_saida      VARCHAR2(3);
    
    -- Tratamento de erros
    vr_exc_erro      EXCEPTION;
    vr_exc_saida     EXCEPTION;
    vr_tab_erro GENE0001.typ_tab_erro;
    
    -- Data do movimento
    vr_dtmvtolt      crapdat.dtmvtolt%type;
    
    -- Variável para armazenar as informações em XML
    vr_des_xml       clob;
    vr_typsaida     VARCHAR2(100); 
    
    -- Variável para o caminho e nome do arquivo base
    vr_dsdireto   varchar2(200);
    vr_nmarquivo  varchar2(200);
    vr_dscomand   varchar2(200);
    
    -- Subrotina para escrever texto na variável CLOB do XML
    procedure pc_escreve_xml(pr_des_dados in clob) is
    begin
      dbms_lob.writeappend(vr_des_xml, length(pr_des_dados), pr_des_dados);
    end;
    
  BEGIN                                                  
    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'TELA_MANPRT'
                              ,pr_action => null);
    vr_des_xml := null;
    dbms_lob.createtemporary(vr_des_xml, true);
    dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
    -- Inicilizar as informações do XML
    pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><consulta_ted>');
    pc_escreve_xml('<cdcooper>'     ||pr_cdcooper	    ||'</cdcooper>'||
                   '<dtinicial>'    ||pr_dtinicial    ||'</dtinicial>'||
                   '<dtfinal>'      ||pr_dtfinal      ||'</dtfinal>'||
                   '<vlinicial>'    ||pr_vlinicial    ||'</vlinicial>'||
                   '<vlfinal>'      ||pr_vlfinal      ||'</vlfinal>'||
                   '<dscartorio>'   ||pr_cartorio     ||'</dscartorio>'||
                   '<Columns>'      ||
		               '<column1>'      ||'Cartório'      ||'</column1>'||
		               '<column2>'      ||'Remetente'     ||'</column2>'||
		               '<column3>'      ||'Banco'         ||'</column3>'||
		               '<column4>'      ||'Agência'       ||'</column4>'||
		               '<column5>'      ||'Conta'         ||'</column5>'||
		               '<column6>'      ||'Data Rec.'     ||'</column6>'||
		               '<column7>'      ||'Valor'         ||'</column7>'||
		               '<column8>'      ||'Estado'        ||'</column8>'||
		               '<column9>'      ||'Cidade'         ||'</column9>'||
		               '<column10>'     ||'Status Conc.'  ||'</column10>'||
	                 '</Columns>');
                   
    pc_escreve_xml('<teds>');
                   
    FOR rw_tbfin_recursos_movimento IN cr_tbfin_recursos_movimento(pr_dtinicial => pr_dtinicial
                                                                  ,pr_dtfinal   => pr_dtfinal
                                                                  ,pr_vlinicial => pr_vlinicial
                                                                  ,pr_vlfinal   => pr_vlfinal
                                                                  ,pr_cartorio  => pr_cartorio
                                                                  ,pr_flgcon    => 0) LOOP
      pc_escreve_xml('<ted>');
      pc_escreve_xml('<nmcartorio>'     ||rw_tbfin_recursos_movimento.nome_cartorio                            ||'</nmcartorio>'||
                     '<nmremetente>'    ||rw_tbfin_recursos_movimento.nome_remetente                           ||'</nmremetente>'||
                     '<iddocumento>'    ||gene0002.fn_mask_cpf_cnpj(rw_tbfin_recursos_movimento.cnpj_cpf,1)    ||'</iddocumento>'||
                     '<banco>'          ||rw_tbfin_recursos_movimento.nome_banco                               ||'</banco>'||
                     '<agencia>'        ||rw_tbfin_recursos_movimento.nome_agencia                             ||'</agencia>'||
                     '<conta>'          ||rw_tbfin_recursos_movimento.conta                                    ||'</conta>'||
                     '<dtrecebimento>'  ||to_char(rw_tbfin_recursos_movimento.data_recebimento, 'DD/MM/RRRR')  ||'</dtrecebimento>'||
                     '<valor>'          ||to_char(rw_tbfin_recursos_movimento.valor, 'fm999g999g990D00')       ||'</valor>'||
                     '<estado>'         ||rw_tbfin_recursos_movimento.nome_estado                              ||'</estado>'||
                     '<cidade>'         ||rw_tbfin_recursos_movimento.nome_cidade                              ||'</cidade>'||
                     '<status>'         ||rw_tbfin_recursos_movimento.status                                   ||'</status>');
      pc_escreve_xml('</ted>');
    END LOOP;
    
    pc_escreve_xml('</teds>'); 
    -- Fecha a tag principal para encerrar o XML
    pc_escreve_xml('</consulta_ted>');
    --Buscar diretorio da cooperativa
    vr_dsdireto := gene0001.fn_diretorio(pr_tpdireto => 'C', --> cooper 
                                         pr_cdcooper => pr_cdcooper,
                                         pr_nmsubdir => '/rl');
    vr_dscomand := 'rm '||vr_dsdireto ||'/crrl739_' ||0 ||'* 2>/dev/null';
      
    --Executar o comando no unix
    GENE0001.pc_OScommand(pr_typ_comando => 'S'
                         ,pr_des_comando => vr_dscomand
                         ,pr_typ_saida   => vr_typsaida
                         ,pr_des_saida   => vr_dscritic);
    --Se ocorreu erro dar RAISE
    IF vr_typsaida = 'ERR' THEN
      vr_dscritic:= 'Nao foi possivel remover arquivos: '||vr_dscomand||'. Erro: '||vr_dscritic;
      RAISE vr_exc_erro;
    END IF;
    vr_nmarquivo := 'crrl739_'||0 || gene0002.fn_busca_time || '.pdf';
    
    --> Solicita geracao do PDF
    gene0002.pc_solicita_relato(pr_cdcooper   => pr_cdcooper
                               , pr_cdprogra  => 'MANPRT'
                               , pr_dtmvtolt  => vr_dtmvtolt
                               , pr_dsxml     => vr_des_xml
                               , pr_dsxmlnode => '/consulta_ted'
                               , pr_dsjasper  => 'crrl739.jasper'
                               , pr_dsparams  => null
                               , pr_dsarqsaid => vr_dsdireto ||'/'||vr_nmarquivo
                               , pr_flg_gerar => 'S'
                               , pr_qtcoluna  => 132
                               , pr_cdrelato  => 739
                               , pr_sqcabrel  => 1
                               , pr_flg_impri => 'N'
                               , pr_nmformul  => ' '
                               , pr_nrcopias  => 1
                               , pr_nrvergrl  => 1
                               , pr_des_erro  => vr_dscritic);
      
    IF vr_dscritic IS NOT NULL THEN -- verifica retorno se houve erro
      RAISE vr_exc_erro; -- encerra programa
    END IF; 
    
    -- Liberando a memoria alocada pro CLOB
    dbms_lob.close(vr_des_xml);
    dbms_lob.freetemporary(vr_des_xml);
 
    --> AyllosWeb
    -- Copia contrato PDF do diretorio da cooperativa para servidor WEB
    GENE0002.pc_efetua_copia_pdf(pr_cdcooper => pr_cdcooper
                                ,pr_cdagenci => NULL
                                ,pr_nrdcaixa => NULL
                                ,pr_nmarqpdf => vr_dsdireto ||'/'||vr_nmarquivo
                                ,pr_des_reto => vr_des_reto
                                ,pr_tab_erro => vr_tab_erro);
    -- Se retornou erro
    IF NVL(vr_des_reto,'OK') <> 'OK' THEN
      IF vr_tab_erro.COUNT > 0 THEN -- verifica pl-table se existe erros          
        vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic; -- busca primeira descricao da critica
        RAISE vr_exc_erro; -- encerra programa
      END IF;
    END IF;
    
     -- Criar XML de retorno para uso na Web
     pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><nmarqpdf>' || vr_nmarquivo|| '</nmarqpdf>');

    -- Remover relatorio do diretorio padrao da cooperativa
    gene0001.pc_OScommand(pr_typ_comando => 'S'
                         ,pr_des_comando => 'rm '||vr_dsdireto ||'/'||vr_nmarquivo
                         ,pr_typ_saida   => vr_typsaida
                         ,pr_des_saida   => vr_dscritic);
    -- Se retornou erro
    IF vr_typsaida = 'ERR' OR vr_dscritic IS NOT NULL THEN
      -- Concatena o erro que veio
      vr_dscritic := 'Erro ao remover arquivo: '||vr_dscritic;
      RAISE vr_exc_erro; -- encerra programa
    END IF;                                      
                                        
  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_dscritic := 'Erro geral pc_exporta_consulta_teds_pdf : '||SQLERRM;  	                                                                                     
  END pc_exporta_consulta_teds_pdf;
  
  PROCEDURE pc_exporta_consulta_custas(pr_cdcooper_usr  IN craptab.cdcooper%TYPE --> Cooperativa que está sendo executada
            	                        ,pr_cdcooper      IN INTEGER --> Cooperativa
            	                        ,pr_nrdconta      IN crapceb.nrdconta%TYPE --> Numero da conta do cooperado
                                    	,pr_dtinicial     IN VARCHAR2 --> Data inicial de recebimento de ted
                         	  	        ,pr_dtfinal       IN VARCHAR2 --> Data final de recebimento de ted
                                      ,pr_cdestado      IN VARCHAR2 --> Estado que veio a confirmação
                                      ,pr_cartorio      IN tbfin_recursos_movimento.nrcnpj_debitada%TYPE -- Cartorio da ted
                                      ,pr_flcustas      IN INTEGER
                                      ,pr_xmllog        IN VARCHAR2                -- XML com informações de LOG
                                      ,pr_cdcritic      OUT PLS_INTEGER            -- Código da crítica
                                      ,pr_dscritic      OUT VARCHAR2               -- Descrição da crítica
                                      ,pr_retxml        IN OUT NOCOPY xmltype      -- Arquivo de retorno do XML
                                      ,pr_nmdcampo      OUT VARCHAR2               -- Nome do Campo
                                      ,pr_des_erro      OUT VARCHAR2) IS
	/* ............................................................................

       Programa: pc_exporta_consulta_teds
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Hélinton Steffens
       Data    : Abril/2017                     Ultima atualizacao: --/--/----

       Dados referentes ao programa:

       Frequencia: Sempre que chamado
       Objetivo  : Rotina responsavel por gerar o relatorio de teds a conciliar - Chamada ayllos Web

       Alteracoes: ----

    ............................................................................ */  
 
    -------------->> VARIAVEIS <<----------------
    -- Variavel de criticas
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(10000);
    vr_des_reto VARCHAR2(10);
    vr_typ_saida      VARCHAR2(3);
    
    -- Tratamento de erros
    vr_exc_erro      EXCEPTION;
    vr_exc_saida     EXCEPTION;
    vr_tab_erro GENE0001.typ_tab_erro;
    
    -- Variaveis gerais
    vr_linha_csv   VARCHAR2(4000) := ''; --> Linhas csv
    vr_xml_temp VARCHAR2(32726) := '';
    vr_clob     CLOB;
    vr_dsdiretorio VARCHAR2(1000);      --> Local onde sera gerado o relatorio
    vr_nmarquivo   VARCHAR2(1000);      --> Nome do relatorio CSV
    
  BEGIN                                                  
    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'TELA_MANPRT'
                              ,pr_action => null);

    -- Cria a variavel CLOB
    dbms_lob.createtemporary(vr_clob, TRUE);
    dbms_lob.open(vr_clob, dbms_lob.lob_readwrite);
    
    -- Busca o diretorio onde esta os arquivos Sicoob
    vr_dsdiretorio := gene0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                                pr_cdacesso => 'ROOT_DOMICILIO')||'/relatorios';
    vr_nmarquivo := 'MANPRT_'||to_char(SYSDATE,'HHMISS')||'.csv';
    
    -- Criar cabeçalho do CSV
    GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                           ,pr_texto_completo => vr_xml_temp
                           ,pr_texto_novo     => 'Nr Docto TED;Data Envio;Hora Envio;Data Recebimento;Cooperativa;Cartório;UF;Nosso Número;Vlr. Cartório;Vlr Distribuição;Total Custas'||chr(10));
    
    FOR rw_tbcobran_retorno_ieptb IN cr_tbcobran_retorno_ieptb(pr_cdcooper 	 => pr_cdcooper
                                                           	  ,pr_nrdconta   => pr_nrdconta
                                                              ,pr_dtinicial  => pr_dtinicial
                                                              ,pr_dtfinal    => pr_dtfinal
                                                              ,pr_cdestado   => pr_cdestado
                                                              ,pr_cartorio   => pr_cartorio
                                                              ,pr_flcustas   => pr_flcustas) LOOP
                                                              
      vr_linha_csv := vr_linha_csv || to_char(rw_tbcobran_retorno_ieptb.nrdocmto, 'DD/MM/RRRR') || ';';
      vr_linha_csv := vr_linha_csv || to_char(rw_tbcobran_retorno_ieptb.dtcustar, 'DD/MM/RRRR') || ';';
      vr_linha_csv := vr_linha_csv || to_char(rw_tbcobran_retorno_ieptb.hrtransa, 'DD/MM/RRRR') || ';';
      vr_linha_csv := vr_linha_csv || to_char(rw_tbcobran_retorno_ieptb.dtmvtolt, 'DD/MM/RRRR') || ';';
      vr_linha_csv := vr_linha_csv || rw_tbcobran_retorno_ieptb.nmrescop || ';';
      vr_linha_csv := vr_linha_csv || rw_tbcobran_retorno_ieptb.nmcartorio || ';';
      vr_linha_csv := vr_linha_csv || rw_tbcobran_retorno_ieptb.cdestado || ';';
      vr_linha_csv := vr_linha_csv || rw_tbcobran_retorno_ieptb.nrnosnum || ';';
      vr_linha_csv := vr_linha_csv || TRIM(to_char(rw_tbcobran_retorno_ieptb.custas_cartorarias,'fm999g999g990D00')) || ';';
      vr_linha_csv := vr_linha_csv || TRIM(to_char(rw_tbcobran_retorno_ieptb.custas_distribuidor,'fm999g999g990D00')) || ';';
      vr_linha_csv := vr_linha_csv || TRIM(to_char(rw_tbcobran_retorno_ieptb.total_despesas,'fm999g999g990D00')) || chr(10);
      
      -- escreve linha no arquivo xml
      GENE0002.pc_escreve_xml(
         pr_xml => vr_clob, 
         pr_texto_completo => vr_xml_temp, 
         pr_texto_novo => vr_linha_csv
      );
                         
      vr_linha_csv := '';

    END LOOP;
    
    -- Encerrar o Clob
    GENE0002.pc_escreve_xml(
       pr_xml => vr_clob, 
       pr_texto_completo => vr_xml_temp,
       pr_texto_novo => ' ', 
       pr_fecha_xml => TRUE
    );

    -- Gera o relatorio
    GENE0002.pc_clob_para_arquivo(
       pr_clob => vr_clob, 
                                  pr_caminho => vr_dsdiretorio,
                                  pr_arquivo => vr_nmarquivo,
       pr_des_erro => vr_dscritic
    );

    IF vr_dscritic IS NOT NULL THEN
       RAISE vr_exc_saida;
    END IF;

    -- copia contrato pdf do diretorio da cooperativa para servidor web
    GENE0002.pc_efetua_copia_pdf(pr_cdcooper => pr_cdcooper_usr
                               , pr_cdagenci => NULL
                               , pr_nrdcaixa => NULL
                               , pr_nmarqpdf => vr_dsdiretorio||'/'||vr_nmarquivo
                               , pr_des_reto => vr_des_reto
                               , pr_tab_erro => vr_tab_erro
                               );

    -- caso apresente erro na operação
    IF nvl(vr_des_reto,'OK') <> 'OK' THEN
       IF vr_tab_erro.COUNT > 0 THEN -- verifica pl-table se existe erros
          vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic; -- busca primeira critica
          vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic; -- busca primeira descricao da critica
          RAISE vr_exc_saida; -- encerra programa
        END IF;
     END IF;

     -- Remover relatorio do diretorio padrao da cooperativa
     gene0001.pc_OScommand(pr_typ_comando => 'S'
                          ,pr_des_comando => 'rm '||vr_dsdiretorio||'/'||vr_nmarquivo
                          ,pr_typ_saida   => vr_typ_saida
                          ,pr_des_saida   => vr_dscritic);

     -- Se retornou erro
     IF vr_typ_saida = 'ERR' OR vr_dscritic IS NOT null THEN
        -- Concatena o erro que veio
        vr_dscritic := 'Erro ao remover arquivo: '||vr_dscritic;
        RAISE vr_exc_saida; -- encerra programa
     END IF;

     -- Criar XML de retorno para uso na Web
     pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><nmarqcsv>' || vr_nmarquivo|| '</nmarqcsv>');

     -- Libera a memoria do CLOB
     dbms_lob.close(vr_clob);
     dbms_lob.freetemporary(vr_clob);
                                        
  EXCEPTION
    WHEN vr_exc_erro THEN
      IF vr_cdcritic <> 0 THEN
        vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      END IF;

      vr_dscritic := '<![CDATA['||vr_dscritic||']]>';
      pr_dscritic := REPLACE(REPLACE(REPLACE(vr_dscritic,chr(13),' '),chr(10),' '),'''','´');

      -- Carregar XML padrao para variavel de retorno
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    WHEN OTHERS THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina da tela pc_exporta_consulta_teds: ' || SQLERRM;
      pr_dscritic := '<![CDATA['||pr_dscritic||']]>';
      pr_dscritic := REPLACE(REPLACE(REPLACE(pr_dscritic,chr(13),' '),chr(10),' '),'''','´');
      
      -- Carregar XML padrao para variavel de retorno
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');                                                   
  END pc_exporta_consulta_custas;

  PROCEDURE pc_consulta_nao_conciliados(pr_dtinicial     IN VARCHAR2 -- Data de recebimento do titulo
                            ,pr_vlfinal       IN tbcobran_retorno_ieptb.vltitulo%TYPE -- Valor final titulo
                            ,pr_cartorio      IN INTEGER                 -- Cartorio da ted
                            ,pr_xmllog        IN VARCHAR2                -- XML com informações de LOG
                            ,pr_cdcritic      OUT PLS_INTEGER            -- Código da crítica
                            ,pr_dscritic      OUT VARCHAR2               -- Descrição da crítica
                            ,pr_retxml        IN OUT NOCOPY XMLType      -- Arquivo de retorno do XML
                            ,pr_nmdcampo      OUT VARCHAR2               -- Nome do Campo
                            ,pr_des_erro      OUT VARCHAR2) IS

  /*---------------------------------------------------------------------------------------------------------------

    Programa : pc_consulta_nao_conciliados
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : André Clemer (Supero)
    Data     : Abril/2018                           Ultima atualizacao: 27/03/2019

    Dados referentes ao programa:

    Frequencia: -----
    Objetivo   : Pesquisa de títulos não conciliados do retorno do IEPTB

    Alterações :
    
    12/12/2018 - Filtrar apenas titulos pagos em cartório no processo de 
                 conciliação (tpocorre=1) (Cechet/Fabio Supero)
                 
    27/03/2019 - Colocar o tpocorre como texto pois pode haver casos em 
                 que vem campo texto (Lucas Ranghetti INC0036169)
    -------------------------------------------------------------------------------------------------------------*/
    
    CURSOR cr_titulos(pr_dtinicial     IN VARCHAR2
                     ,pr_vlfinal       IN tbcobran_retorno_ieptb.vltitulo%TYPE
                     ,pr_cartorio      IN INTEGER) IS
    SELECT ret.idretorno,
           mun.dscidade || ' - ' || mun.cdestado nmcartorio,
           mun.cdestado, /*RITM0013002*/
           cop.nmrescop,
           ret.nrcnvcob,
           ret.nrdconta,
           ret.nrdocmto,
           to_char(ret.dtocorre,'dd/mm/yyyy') dtocorre,
           ret.vltitulo,
					 ret.vlsaldo_titulo,
           count(1) over() as rcount
      FROM tbcobran_retorno_ieptb ret
           LEFT JOIN crapmun mun ON mun.cdufibge || LPAD(mun.cdcidbge,5,'0') = ret.cdcomarc
           INNER JOIN crapcop cop ON cop.cdcooper = ret.cdcooper
     WHERE ret.dtconciliacao IS NULL
       AND (ret.tpocorre = '1' OR ret.tpocorre = '7') -- titulo pago em cartorio ou liquidacao em condicional
       AND (
               (pr_dtinicial IS NOT NULL AND ret.dtocorre >= to_date(pr_dtinicial,'DD/MM/RRRR'))
           OR
               (pr_dtinicial IS NULL AND ret.dtocorre IS NOT NULL)
           )
       AND (
               (pr_vlfinal IS NOT NULL AND ret.vlsaldo_titulo <= pr_vlfinal)
           OR
               (pr_vlfinal IS NULL AND ret.vlsaldo_titulo IS NOT NULL)
           );

    rw_titulos cr_titulos%ROWTYPE;

    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);

    --Tabela de Erros
    vr_tab_erro gene0001.typ_tab_erro;

    --Variaveis Locais
    vr_qtregist INTEGER := 0;
    vr_nrregist INTEGER;
    vr_contador INTEGER :=0;
    vr_flgfirst BOOLEAN := TRUE;

    --Variaveis de Excecoes
    vr_exc_erro  EXCEPTION;

    BEGIN

    --limpar tabela erros
    vr_tab_erro.DELETE;

    --Inicializar Variaveis
    vr_cdcritic:= 0;
    vr_dscritic:= NULL;

    -- Criar cabeçalho do XML
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="UTF-8"?><Root/>');
    
    GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                          ,pr_tag_pai  => 'Root'
                          ,pr_posicao  => 0
                          ,pr_tag_nova => 'Dados'
                          ,pr_tag_cont => NULL
                          ,pr_des_erro => vr_dscritic);
    
    GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                          ,pr_tag_pai  => 'Dados'
                          ,pr_posicao  => 0
                          ,pr_tag_nova => 'inf'
                          ,pr_tag_cont => NULL
                          ,pr_des_erro => vr_dscritic); 
                          
 
    FOR rw_titulos IN cr_titulos(pr_dtinicial => pr_dtinicial
                                ,pr_vlfinal   => pr_vlfinal
                                ,pr_cartorio  => pr_cartorio) LOOP

        gene0007.pc_insere_tag(pr_xml => pr_retxml
                              ,pr_tag_pai => 'Dados'
                              ,pr_posicao => 0
                              ,pr_tag_nova => 'inf'
                              ,pr_tag_cont => NULL
                              ,pr_des_erro => vr_dscritic);
                              
        gene0007.pc_insere_tag(pr_xml => pr_retxml
                              ,pr_tag_pai => 'inf'
                              ,pr_posicao => vr_contador
                              ,pr_tag_nova => 'idretorno'
                              ,pr_tag_cont => rw_titulos.idretorno
                              ,pr_des_erro => vr_dscritic);

        gene0007.pc_insere_tag(pr_xml => pr_retxml
                              ,pr_tag_pai => 'inf'
                              ,pr_posicao => vr_contador
                              ,pr_tag_nova => 'nmcartorio'
                              ,pr_tag_cont => rw_titulos.nmcartorio
                              ,pr_des_erro => vr_dscritic);
                              
        gene0007.pc_insere_tag(pr_xml => pr_retxml
                              ,pr_tag_pai => 'inf'
                              ,pr_posicao => vr_contador
                              ,pr_tag_nova => 'nmrescop'
                              ,pr_tag_cont => rw_titulos.nmrescop
                              ,pr_des_erro => vr_dscritic);
                              
        gene0007.pc_insere_tag(pr_xml => pr_retxml
                              ,pr_tag_pai => 'inf'
                              ,pr_posicao => vr_contador
                              ,pr_tag_nova => 'nrcnvcob'
                              ,pr_tag_cont => rw_titulos.nrcnvcob
                              ,pr_des_erro => vr_dscritic);
                              
        gene0007.pc_insere_tag(pr_xml => pr_retxml
                              ,pr_tag_pai => 'inf'
                              ,pr_posicao => vr_contador
                              ,pr_tag_nova => 'nrdconta'
                              ,pr_tag_cont => rw_titulos.nrdconta
                              ,pr_des_erro => vr_dscritic);
                              
        gene0007.pc_insere_tag(pr_xml => pr_retxml
                              ,pr_tag_pai => 'inf'
                              ,pr_posicao => vr_contador
                              ,pr_tag_nova => 'nrdocmto'
                              ,pr_tag_cont => rw_titulos.nrdocmto
                              ,pr_des_erro => vr_dscritic);
                              
        gene0007.pc_insere_tag(pr_xml => pr_retxml
                              ,pr_tag_pai => 'inf'
                              ,pr_posicao => vr_contador
                              ,pr_tag_nova => 'dtocorre'
                              ,pr_tag_cont => rw_titulos.dtocorre
                              ,pr_des_erro => vr_dscritic);

        gene0007.pc_insere_tag(pr_xml => pr_retxml
                              ,pr_tag_pai => 'inf'
                              ,pr_posicao => vr_contador
                              ,pr_tag_nova => 'vltitulo'
                              ,pr_tag_cont => rw_titulos.vltitulo
                              ,pr_des_erro => vr_dscritic);
															
		    gene0007.pc_insere_tag(pr_xml => pr_retxml
                              ,pr_tag_pai => 'inf'
                              ,pr_posicao => vr_contador
                              ,pr_tag_nova => 'vltitulo_saldo'
                              ,pr_tag_cont => rw_titulos.vlsaldo_titulo
                              ,pr_des_erro => vr_dscritic);
        /*RITM0013002*/
		    gene0007.pc_insere_tag(pr_xml => pr_retxml
                              ,pr_tag_pai => 'inf'
                              ,pr_posicao => vr_contador
                              ,pr_tag_nova => 'estado'
                              ,pr_tag_cont => rw_titulos.cdestado
                              ,pr_des_erro => vr_dscritic);                              
                              
                              
        vr_contador := vr_contador + 1;

    END LOOP;

    --Se ocorreu erro
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Erro
      pr_cdcritic:= vr_cdcritic;
      pr_dscritic:= vr_dscritic;

      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');

    WHEN OTHERS THEN
      -- Retorno não OK
      pr_des_erro:= 'NOK';

      -- Erro
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na pc_consulta_teds --> '|| SQLERRM;

      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');

  END pc_consulta_nao_conciliados;
  
  PROCEDURE pc_exporta_consulta_custas_pdf(pr_cdcooper_usr  IN craptab.cdcooper%TYPE --> Cooperativa que está sendo executada
                                          ,pr_cdcooper  IN craptab.cdcooper%TYPE         --> Cooperativa
                                          ,pr_nrdconta      IN crapceb.nrdconta%TYPE --> Numero da conta do cooperado
                                          ,pr_dtinicial     IN VARCHAR2 -- Data inicial de recebimento de ted
                         	  	          ,pr_dtfinal       IN VARCHAR2 -- Data final de recebimento de ted
                                          ,pr_cdestado      IN VARCHAR2 --> Estado que veio a confirmação
                                          ,pr_cartorio      IN tbfin_recursos_movimento.nrcnpj_debitada%TYPE -- Cartorio da ted
                                          ,pr_flcustas      IN INTEGER                 -- tarifas e custas processadas
                                          ,pr_xmllog        IN VARCHAR2                -- XML com informações de LOG
                                          ,pr_cdcritic      OUT PLS_INTEGER            -- Código da crítica
                                          ,pr_dscritic      OUT VARCHAR2               -- Descrição da crítica
                                          ,pr_retxml        IN OUT NOCOPY XMLType      -- Arquivo de retorno do XML
                                          ,pr_nmdcampo      OUT VARCHAR2               -- Nome do Campo
                                          ,pr_des_erro      OUT VARCHAR2) IS
	/* ............................................................................

       Programa: pc_exporta_consulta_custas_pdf
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Hélinton Steffens
       Data    : Abril/2017                     Ultima atualizacao: --/--/----

       Dados referentes ao programa:

       Frequencia: Sempre que chamado
       Objetivo  : Rotina responsavel por gerar o relatorio de teds a conciliar - Chamada ayllos Web

       Alteracoes: ----

    ............................................................................ */  
 
    -------------->> VARIAVEIS <<----------------
    -- Variavel de criticas
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(10000);
    vr_des_reto VARCHAR2(10);
    vr_typ_saida      VARCHAR2(3);
    
    -- Tratamento de erros
    vr_exc_erro      EXCEPTION;
    vr_exc_saida     EXCEPTION;
    vr_tab_erro GENE0001.typ_tab_erro;
    
    -- Data do movimento
    vr_dtmvtolt      crapdat.dtmvtolt%type;
    
    -- Variável para armazenar as informações em XML
    vr_des_xml       clob;
    vr_typsaida     VARCHAR2(100); 
    
    -- Variável para o caminho e nome do arquivo base
    vr_dsdireto   varchar2(200);
    vr_nmarquivo  varchar2(200);
    vr_dscomand   varchar2(200);
    
    -- Subrotina para escrever texto na variável CLOB do XML
    procedure pc_escreve_xml(pr_des_dados in clob) is
    begin
      dbms_lob.writeappend(vr_des_xml, length(pr_des_dados), pr_des_dados);
    end;
    
  BEGIN                                                  
    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'TELA_MANPRT'
                              ,pr_action => null);

    vr_des_xml := null;
    dbms_lob.createtemporary(vr_des_xml, true);
    dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
    -- Inicilizar as informações do XML
    pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><consulta_custas>');
    pc_escreve_xml('<cdcooper>'     ||pr_cdcooper	    ||'</cdcooper>'||
				   '<nrdconta>'     ||pr_nrdconta	    ||'</nrdconta>'||
                   '<dtinicial>'    ||pr_dtinicial      ||'</dtinicial>'||
                   '<dtfinal>'      ||pr_dtfinal        ||'</dtfinal>'||
                   '<cduflogr>'     ||pr_cdestado       ||'</cduflogr>'||
                   '<dscartorio>'   ||pr_cartorio       ||'</dscartorio>'||
                   '<Columns>'      ||
                     '<column1>'      ||'Nr. Docto TED'      		||'</column1>'||
                     '<column2>'      ||'Data/Hr Envio'      		||'</column2>'||
                     '<column3>'      ||'Tarifas'      		      ||'</column3>'||
                     '<column4>'      ||'Custas cartorarias'    ||'</column4>'||
                     '<column5>'      ||'Custas distribuidor'   ||'</column5>'||
                     '<column6>'      ||'Outras despesas'       ||'</column6>'||
                     '<column7>'      ||'Total custas'          ||'</column7>'||
	                 '</Columns>');
                   
    pc_escreve_xml('<custas>');
                   
        FOR rw_tbcobran_retorno_ieptb IN cr_tbcobran_retorno_ieptb(pr_cdcooper 	 => pr_cdcooper
                                                           	  ,pr_nrdconta   => pr_nrdconta
                                                              ,pr_dtinicial  => pr_dtinicial
                                                              ,pr_dtfinal    => pr_dtfinal
                                                              ,pr_cdestado   => pr_cdestado
                                                              ,pr_cartorio   => pr_cartorio
                                                              ,pr_flcustas   => pr_flcustas) LOOP
      pc_escreve_xml('<custa>');
          pc_escreve_xml('  <idlancto>'     			    ||rw_tbcobran_retorno_ieptb.nrdocmto                 ||'</idlancto>'||
                         '  <hrenvio>'     			      ||to_char(rw_tbcobran_retorno_ieptb.dtcustar, 'DD/MM/RRRR') || ' ' || rw_tbcobran_retorno_ieptb.hrtransa ||'</hrenvio>'||
                         '  <tarifas>'     			      ||rw_tbcobran_retorno_ieptb.tarifas                  ||'</tarifas>'||
                     '<custas_cartorarias>'     ||TRIM(to_char(rw_tbcobran_retorno_ieptb.custas_cartorarias,'fm999g999g990D00'))       ||'</custas_cartorarias>'||
                     '<custas_distribuidor>'    ||TRIM(to_char(rw_tbcobran_retorno_ieptb.custas_distribuidor,'fm999g999g990D00'))      ||'</custas_distribuidor>'||
                     '<demais_despesas>'        ||TRIM(to_char(rw_tbcobran_retorno_ieptb.demais_despesas,'fm999g999g990D00'))          ||'</demais_despesas>'||
                     '<total_despesas>'         ||TRIM(to_char(rw_tbcobran_retorno_ieptb.total_despesas,'fm999g999g990D00'))           ||'</total_despesas>');
      pc_escreve_xml('</custa>');
    END LOOP;
    
    pc_escreve_xml('</custas>'); 
    -- Fecha a tag principal para encerrar o XML
    pc_escreve_xml('</consulta_custas>');
    --Buscar diretorio da cooperativa
    vr_dsdireto := gene0001.fn_diretorio(pr_tpdireto => 'C', --> cooper 
                                         pr_cdcooper => pr_cdcooper_usr,
                                         pr_nmsubdir => '/rl');
    vr_dscomand := 'rm '||vr_dsdireto ||'/crrl740_' ||0 ||'* 2>/dev/null';
      
    --Executar o comando no unix
    GENE0001.pc_OScommand(pr_typ_comando => 'S'
                         ,pr_des_comando => vr_dscomand
                         ,pr_typ_saida   => vr_typsaida
                         ,pr_des_saida   => vr_dscritic);
    --Se ocorreu erro dar RAISE
    IF vr_typsaida = 'ERR' THEN
      vr_dscritic:= 'Nao foi possivel remover arquivos: '||vr_dscomand||'. Erro: '||vr_dscritic;
      RAISE vr_exc_erro;
    END IF;
    vr_nmarquivo := 'crrl740_'||0 || gene0002.fn_busca_time || '.pdf';
    
    --> Solicita geracao do PDF
    gene0002.pc_solicita_relato(pr_cdcooper   => pr_cdcooper_usr
                               , pr_cdprogra  => 'MANPRT'
                               , pr_dtmvtolt  => vr_dtmvtolt
                               , pr_dsxml     => vr_des_xml
                               , pr_dsxmlnode => '/consulta_custas'
                               , pr_dsjasper  => 'crrl740.jasper'
                               , pr_dsparams  => null
                               , pr_dsarqsaid => vr_dsdireto ||'/'||vr_nmarquivo
                               , pr_flg_gerar => 'S'
                               , pr_qtcoluna  => 132
                               , pr_cdrelato  => 740
                               , pr_sqcabrel  => 1
                               , pr_flg_impri => 'N'
                               , pr_nmformul  => ' '
                               , pr_nrcopias  => 1
                               , pr_nrvergrl  => 1
                               , pr_des_erro  => vr_dscritic);
      
    IF vr_dscritic IS NOT NULL THEN -- verifica retorno se houve erro
      RAISE vr_exc_erro; -- encerra programa
    END IF; 
    
    -- Liberando a memoria alocada pro CLOB
    dbms_lob.close(vr_des_xml);
    dbms_lob.freetemporary(vr_des_xml);
 
    --> AyllosWeb
    -- Copia contrato PDF do diretorio da cooperativa para servidor WEB
    GENE0002.pc_efetua_copia_pdf(pr_cdcooper => pr_cdcooper_usr
                                ,pr_cdagenci => NULL
                                ,pr_nrdcaixa => NULL
                                ,pr_nmarqpdf => vr_dsdireto ||'/'||vr_nmarquivo
                                ,pr_des_reto => vr_des_reto
                                ,pr_tab_erro => vr_tab_erro);
    -- Se retornou erro
    IF NVL(vr_des_reto,'OK') <> 'OK' THEN
      IF vr_tab_erro.COUNT > 0 THEN -- verifica pl-table se existe erros          
        vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic; -- busca primeira descricao da critica
        RAISE vr_exc_erro; -- encerra programa
      END IF;
    END IF;
    
     -- Criar XML de retorno para uso na Web
     pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><nmarqpdf>' || vr_nmarquivo|| '</nmarqpdf>');

    -- Remover relatorio do diretorio padrao da cooperativa
    gene0001.pc_OScommand(pr_typ_comando => 'S'
                         ,pr_des_comando => 'rm '||vr_dsdireto ||'/'||vr_nmarquivo
                         ,pr_typ_saida   => vr_typsaida
                         ,pr_des_saida   => vr_dscritic);
    -- Se retornou erro
    IF vr_typsaida = 'ERR' OR vr_dscritic IS NOT NULL THEN
      -- Concatena o erro que veio
      vr_dscritic := 'Erro ao remover arquivo: '||vr_dscritic;
      RAISE vr_exc_erro; -- encerra programa
    END IF;                                      
                                        
  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_dscritic := 'Erro geral pc_exporta_consulta_custas_pdf : '||SQLERRM;  	                                                                                     
  END pc_exporta_consulta_custas_pdf;

  
  PROCEDURE pc_devolver_ted(pr_cdcooper      IN craptab.cdcooper%TYPE    -- Cooperativa
                           ,pr_cdoperad      IN VARCHAR2                 -- Codigo Operador
                           ,pr_idlancto      IN TBFIN_RECURSOS_MOVIMENTO.idlancto%TYPE -- Código da TED
                           ,pr_motivo        IN INTEGER                  -- Motivo da devolução (1 - Recebimento da TED em duplicidade, 2 - Cartorio nao localizado/reconhecido, 3 - Algum outro motivo informado pelo IEPTB)
                           ,pr_descricao     IN VARCHAR2                 -- Descrição da devolução
                           ,pr_xmllog        IN VARCHAR2                 -- XML com informações de LOG
                           ,pr_cdcritic      OUT PLS_INTEGER             -- Código da crítica
                           ,pr_dscritic      OUT VARCHAR2
                           ,pr_retxml        IN OUT NOCOPY XMLType       -- Arquivo de retorno do XML
                           ,pr_nmdcampo      OUT VARCHAR2                -- Nome do Campo
                           ,pr_des_erro      OUT VARCHAR2) IS
                                          
    --
    vr_exc_erro      EXCEPTION;

    vr_cdfinali INTEGER;

    vr_idlancto INTEGER;
    vr_nrdocmto INTEGER;
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(500);
    
    vr_email_dest VARCHAR2(500);
    vr_emails_cobranca tbcobran_param_protesto.dsemail_cobranca%TYPE;
  
    vr_des_assunto VARCHAR2(500);
    vr_conteudo VARCHAR2(500);
    --  
  BEGIN
    -- Retornar TED a partir do ID
    OPEN cr_tbcobran_ted(pr_idlancto => pr_idlancto);
    --
    FETCH cr_tbcobran_ted INTO rw_tbcobran_ted;
    --
    IF cr_tbcobran_ted%NOTFOUND THEN
      --
      vr_dscritic := 'TED ' || pr_idlancto || ' não encontrada!';
      CLOSE cr_tbcobran_ted;
      raise no_data_found;
      --
    END IF;
    --
    CLOSE cr_tbcobran_ted;
    
    vr_conteudo := '<html><body>A TED ' || rw_tbcobran_ted.nrdocmto || ' recebida no dia ' || rw_tbcobran_ted.dtmvtolt;

    -- Chamar envio c/ dados do retorno
    COBR0011.pc_enviar_ted_IEPTB(pr_cdcooper => pr_cdcooper
                                ,pr_cdagenci => rw_tbcobran_ted.cdagenci_creditada
                                ,pr_nrdconta => rw_tbcobran_ted.dsconta_creditada
                                ,pr_tppessoa => rw_tbcobran_ted.inpessoa_creditada
                                ,pr_origem   => 1 --> Ayllos
                                ,pr_nrispbif => rw_tbcobran_ted.nrispbif
                                ,pr_cdageban => rw_tbcobran_ted.cdagenci_debitada
                                ,pr_nrctatrf => rw_tbcobran_ted.dsconta_debitada
                                ,pr_nmtitula => rw_tbcobran_ted.nmtitular_debitada
                                ,pr_nrcpfcgc => rw_tbcobran_ted.nrcnpj_debitada
                                ,pr_intipcta => rw_tbcobran_ted.tpconta_debitada
                                ,pr_inpessoa => rw_tbcobran_ted.inpessoa_debitada
                                ,pr_vllanmto => rw_tbcobran_ted.vllanmto
                                ,pr_cdfinali => 1 --> Devolução
                                ,pr_operador => pr_cdoperad
                                ,pr_cdhistor => 2663 --arw_tbcobran_ted.cdhistor

                                ,pr_idlancto => vr_idlancto
                                ,pr_nrdocmto => vr_nrdocmto
                                ,pr_cdcritic => vr_cdcritic
                                ,pr_dscritic => vr_dscritic);
    
    IF vr_dscritic IS NOT NULL THEN
      raise vr_exc_erro;
    END IF;
    
    -- Obtem a nova TED
    OPEN cr_tbcobran_ted(pr_idlancto => vr_idlancto);
    --
    FETCH cr_tbcobran_ted INTO rw_tbcobran_ted;
    --
    IF cr_tbcobran_ted%NOTFOUND THEN
      --
      vr_dscritic := 'TED ' || vr_idlancto || ' não encontrada!';
      CLOSE cr_tbcobran_ted;
      raise no_data_found;
      --
    END IF;
    --
    CLOSE cr_tbcobran_ted;
    
    -- Atualiza as informações de devolução
    BEGIN
      --
      UPDATE tbfin_recursos_movimento mv
             SET mv.dsdevted_descricao = pr_descricao
                ,mv.indevted_motivo = pr_motivo
                ,mv.dtdevolucao_ted = sysdate
      WHERE mv.idlancto = pr_idlancto;
      --
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Não foi possível atualizar o motivo/descrição da devolução: ' || SQLERRM;
    END;
    
    -- Cria rastreio da TED anterior com a nova
    BEGIN
      --
      UPDATE tbfin_recursos_movimento mv
             SET mv.idteddevolvida = pr_idlancto
      WHERE mv.idlancto = vr_idlancto;
      --
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Não foi possível atualizar o identificador da TED devolvida: ' || SQLERRM;
    END;
    
    BEGIN
      --
      SELECT tpp.dsemail_cobranca
        INTO vr_emails_cobranca
        FROM tbcobran_param_protesto tpp
       WHERE tpp.cdcooper = pr_cdcooper;
      --
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Não foi possível retornar os e-mails do protesto: ' || SQLERRM;
    END;
    
    --
    IF (vr_emails_cobranca IS NULL) THEN
      vr_dscritic := 'O e-mail de cobrança ou o e-mail do IEPTB não foi configurado.';
      RAISE vr_exc_erro;      
    END IF;
    --
    
    --
    vr_des_assunto := 'CECRED - Devolução de TED';
    vr_conteudo := vr_conteudo || ' foi devolvida no dia ' || rw_tbcobran_ted.dtmvtolt || 
    ' pela TED ' || rw_tbcobran_ted.nrdocmto || '<br>Motivo: ' || pr_motivo ||
    '<br>Descrição: ' || pr_descricao || '</body></html>';
    vr_email_dest := vr_emails_cobranca;
    --
    
    --
    GENE0003.pc_solicita_email(pr_cdcooper        => pr_cdcooper    --> Cooperativa conectada
                              ,pr_cdprogra        => '' --> Programa conectado
                              ,pr_des_destino     => vr_email_dest --> Um ou mais detinatários separados por ';' ou ','
                              ,pr_des_assunto     => vr_des_assunto --> Assunto do e-mail
                              ,pr_des_corpo       => vr_conteudo    --> Corpo (conteudo) do e-mail
                              ,pr_des_anexo       => ''     --> Um ou mais anexos separados por ';' ou ','
                              ,pr_flg_remove_anex => 'N'            --> Remover os anexos passados
                              ,pr_flg_remete_coop => 'N'            --> Se o envio será do e-mail da Cooperativa
                              ,pr_des_nome_reply  => NULL           --> Nome para resposta ao e-mail
                              ,pr_des_email_reply => NULL           --> Endereço para resposta ao e-mail
                              ,pr_flg_enviar      => 'S'            --> Enviar o e-mail na hora
                              ,pr_flg_log_batch    => 'N'           --> Incluir inf. no log
                              ,pr_des_erro        => vr_dscritic);  --> Descricao Erro
                              
    --                          
    IF vr_dscritic IS NOT NULL THEN
      raise vr_exc_erro;
    END IF;
    --

    pc_gera_log(pr_cdcooper
               ,NULL
               ,vr_conteudo
               ,1);

  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_dscritic := 'Erro ao devolver TED : ' || nvl(vr_dscritic, SQLERRM);
  END pc_devolver_ted;
  
  PROCEDURE pc_gera_conciliacao_auto(pr_cdprograma IN VARCHAR2,
                                     pr_dscritic  OUT VARCHAR2) IS
	/* ............................................................................

       Programa: pc_gera_conciliacao_auto
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : André Clemer
       Data    : Abril/2018                     Ultima atualizacao: --/--/----

       Dados referentes ao programa:

       Frequencia: Sempre que chamado
       Objetivo  : Rotina responsavel por gerar a conciliação automática

       Alteracoes: 

    ............................................................................ */  
 
    -------------->> VARIAVEIS <<----------------
    vr_sum_titulos NUMBER := 0;
    x PLS_INTEGER := 1;
    
    -- Variável de críticas
    vr_dscritic    VARCHAR2(10000) := '';
    
    -- Tratamento de erros
    vr_exc_saida   EXCEPTION;
    vr_exc_erro    EXCEPTION;
    
    -- Cursor genérico de calendário
    rw_crapdat     btch0001.cr_crapdat%ROWTYPE;
    
    vr_ids_retorno VARCHAR2(10000) := '';
    vr_teds_nao_conciliadas VARCHAR2(10000) := '';
    
    --actual table
    t_titulos titulos_tbl_type;
    
    vr_idprglog NUMBER := 0;

    vr_idconciliacao number;

    CURSOR cr_teds IS
      SELECT ted.idlancto,
             ted.cdcooper,
             ted.dtconciliacao,
             ted.vllanmto,
             ted.dtmvtolt,
             ted.cdhistor,
             ted.nrcnpj_debitada,
             ted.nmtitular_debitada,
             count(1) over() as rcount
        FROM tbfin_recursos_movimento ted
  INNER JOIN tbcobran_cartorio_protesto cart ON cart.nrcpf_cnpj = ted.nrcnpj_debitada
                                            AND cart.nmcartorio = ted.nmtitular_debitada
       WHERE ted.cdhistor IN (2622,2917)
         AND ted.dtconciliacao IS NULL -- PARA DEBUG, comentar
         -- AND ted.idlancto = 999998      -- PARA DEBUG, retirar comentario
         AND ted.dsdebcre = 'C'
    ORDER BY ted.dtmvtolt ASC,
             ted.vllanmto DESC;

    rw_ted cr_teds%ROWTYPE;
    
    CURSOR cr_ted_cartorio(pr_nrcnpj_debitada    IN tbfin_recursos_movimento.nrcnpj_debitada%TYPE,
                           pr_nmtitular_debitada IN tbfin_recursos_movimento.nmtitular_debitada%TYPE) IS
      SELECT cartorio.idcidade,
             cartorio.idcartorio,
             cartorio.cdcartorio
        FROM tbfin_recursos_movimento ted
             INNER JOIN tbcobran_cartorio_protesto cartorio ON (ted.nrcnpj_debitada = cartorio.nrcpf_cnpj AND
                                                           ted.nmtitular_debitada = cartorio.nmcartorio);
                           
    rw_ted_cartorio cr_ted_cartorio%ROWTYPE;
    
  BEGIN

    -- Validações
    -- Verifica a existencia da TED
    OPEN cr_teds;
    FETCH cr_teds INTO rw_ted;
    IF cr_teds%NOTFOUND THEN
      CLOSE cr_teds;
      vr_dscritic := 'Nenhuma TED encontrada para conciliação automática.';
      RAISE vr_exc_saida;
    END IF;
    CLOSE cr_teds;
    
    OPEN cr_ted_cartorio(pr_nrcnpj_debitada => rw_ted.nrcnpj_debitada,
                         pr_nmtitular_debitada => rw_ted.nmtitular_debitada);
    FETCH cr_ted_cartorio INTO rw_ted_cartorio;
    IF cr_ted_cartorio%NOTFOUND THEN
      CLOSE cr_ted_cartorio;
      vr_dscritic := 'Não foi possível efetuar a conciliação. O cadastro manual do cartório deverá ser realizado';
      RAISE vr_exc_saida;
    END IF;
    CLOSE cr_ted_cartorio;

    -- Leitura do calendario da cooperativa
    OPEN btch0001.cr_crapdat(pr_cdcooper => rw_ted.cdcooper);
    FETCH btch0001.cr_crapdat INTO rw_crapdat;
    -- Fechar o cursor
    CLOSE btch0001.cr_crapdat;

    -- Varre as TEDs pendentes de conciliação
    FOR rw_ted IN cr_teds LOOP
      
      OPEN cr_titulos(pr_dtmvtolt => rw_ted.dtmvtolt,
                      pr_vllanmto => rw_ted.vllanmto,
                      pr_nrcpf_cnpj => rw_ted.nrcnpj_debitada,
                      pr_nmcartorio => rw_ted.nmtitular_debitada);
      FETCH cr_titulos BULK COLLECT INTO t_titulos;
      CLOSE cr_titulos;

      WHILE x <= t_titulos.COUNT() LOOP
        -- Varre os títulos de acordo com os filtros da TED
        FOR i IN x..t_titulos.COUNT() LOOP

          IF vr_sum_titulos < rw_ted.vllanmto THEN
            vr_sum_titulos := vr_sum_titulos + t_titulos(i).vltitulo;
            vr_ids_retorno := vr_ids_retorno || TRIM(t_titulos(i).idretorno) || ',';
          ELSE
            -- Valor bateu
            IF vr_sum_titulos = rw_ted.vllanmto THEN
              
              vr_ids_retorno := SUBSTR(vr_ids_retorno, 1, LENGTH(vr_ids_retorno) - 1);

              -- Valida se a data de recebimento é maior ou igual a da TED
             IF t_titulos(i).dtocorre < rw_ted.dtmvtolt THEN
                vr_dscritic := 'Data de recebimento do título deve ser superior ou igual a TED. Favor verificar!';
             END IF;

              -- Se NAO gerou crítica  
              /*IF TRIM(vr_dscritic) IS NULL THEN
              pc_gera_conciliacao(pr_idlancto   => rw_ted.idlancto,
                                  pr_idsretorno => vr_ids_retorno,
                                  pr_idconciliacao => vr_idconciliacao,
                                  pr_dscritic   => vr_dscritic);
              END IF;*/

              -- Se gerou alguma crítica
              IF TRIM(vr_dscritic) IS NOT NULL THEN
                vr_teds_nao_conciliadas := vr_teds_nao_conciliadas || TRIM(rw_ted.idlancto) || ',';
              END IF;

              -- Finaliza loop caso ainda tenha registros para varrer
              x := t_titulos.COUNT();
              EXIT;
            ELSE
              -- Última interação para conciliar a TED
              IF x = t_titulos.COUNT() THEN
                 vr_teds_nao_conciliadas := vr_teds_nao_conciliadas || TRIM(rw_ted.idlancto) || ',';
              END IF;
              x := x + 1;
              vr_ids_retorno := '';
              vr_sum_titulos := 0;
              EXIT;
            END IF;
          END IF;
          
        END LOOP; -- fim loop titulos
      END LOOP;
      
      x := 1;
      
    END LOOP; -- fim loop teds
    
    -- Enviar TEDs não conciliadas por e-mail
    IF TRIM(vr_teds_nao_conciliadas) IS NOT NULL THEN
      vr_teds_nao_conciliadas := SUBSTR(vr_teds_nao_conciliadas, 1, LENGTH(vr_teds_nao_conciliadas) - 1);
      
      -- disparar e-mails
    END IF;


  EXCEPTION
    WHEN vr_exc_saida THEN
      pr_dscritic := vr_dscritic;
      
      IF pr_cdprograma = 'CRPS730' THEN
        cecred.pc_log_programa(PR_DSTIPLOG      => 'O', 
                               PR_CDPROGRAMA    => pr_cdprograma, 
                               pr_tpexecucao    => 2,           --job
                               pr_tpocorrencia  => 3,           --alerta
                               pr_cdcriticidade => 0,           --baixa
                               pr_dsmensagem    => pr_dscritic,
                               PR_IDPRGLOG      => vr_idprglog);
        -- Não retornar crítica para o programa
        pr_dscritic := '';
      END IF;

    WHEN OTHERS THEN
      cecred.pc_internal_exception;
      pr_dscritic:= vr_dscritic;
  END pc_gera_conciliacao_auto;
  
  PROCEDURE pc_gera_conciliacao(pr_idlancto   IN VARCHAR2 -- ID's das TED
                               ,pr_idsretorno IN VARCHAR2 -- ID's dos titulos
                               ,pr_idconciliacao OUT tbcobran_conciliacao_ieptb.idconciliacao%type --ID da conciliacao                     
                               ,pr_dscritic  OUT VARCHAR2) IS
	/* ............................................................................

       Programa: pc_gera_conciliacao
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : André Clemer
       Data    : Abril/2018                     Ultima atualizacao: --/--/----

       Dados referentes ao programa:

       Frequencia: Sempre que chamado
       Objetivo  : Rotina responsavel por gerar a conciliação

       Alteracoes: 

    ............................................................................ */  
 
    -------------->> VARIAVEIS <<----------------
    vr_sum_titulos NUMBER := 0;
    
    -- Variável de críticas
    vr_dscritic    VARCHAR2(10000) := '';
    
    -- Tratamento de erros
    vr_exc_saida   EXCEPTION;
    vr_exc_erro    EXCEPTION;
    
    -- Cursor genérico de calendário
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;
    
    CURSOR cr_ted IS
      SELECT ted.cdcooper,
             ted.dtconciliacao,
             ted.vllanmto,
             ted.dtmvtolt,
             ted.cdhistor,
             ted.nrcnpj_debitada,
             ted.nmtitular_debitada,
             caf.cdufresd nome_estado
        FROM tbfin_recursos_movimento ted
         inner join crapban banco on (ted.nrispbif = banco.nrispbif)
         inner join crapagb agencia on (agencia.cddbanco = banco.cdbccxlt and cdagenci_debitada = agencia.cdageban)
         left join crapcaf caf on (caf.cdcidade = agencia.cdcidade)         
       WHERE ted.idlancto IN (SELECT to_number(COLUMN_VALUE)
                                 FROM xmltable(pr_idlancto)) ;

    rw_ted cr_ted%ROWTYPE;
    
    CURSOR cr_titulos IS
      SELECT ret.idretorno,
             ret.dtconciliacao,
             ret.vltitulo,
						 ret.vlsaldo_titulo,
             ret.dtocorre,
             ret.cdcomarc,
             ret.cdcartorio             
        FROM tbcobran_retorno_ieptb ret
       WHERE ret.idretorno IN (SELECT to_number(COLUMN_VALUE)
                                 FROM xmltable(pr_idsretorno));
                                 
    rw_titulos cr_titulos%ROWTYPE;
    
    vr_estado          varchar2(02);
    vr_idconciliacao   tbcobran_conciliacao_ieptb.idconciliacao%type;
    vr_qtdreg          integer := 0;
    vr_sum_teds        tbfin_recursos_movimento.vllanmto%type;
    
    --PRAGMA AUTONOMOUS_TRANSACTION;
    
  BEGIN      
    -- Validações
    -- Verifica a existencia da TED
    OPEN cr_ted;
    FETCH cr_ted INTO rw_ted;
    IF cr_ted%NOTFOUND THEN
      CLOSE cr_ted;
      vr_dscritic := 'Movimentação de TED inexistente. Favor verificar!';
      RAISE vr_exc_saida;
    END IF;
    CLOSE cr_ted;
    
    /* Outras validações de TED's*/
    vr_estado:= null;
    FOR rw_ted IN cr_ted LOOP    
    
    IF rw_ted.cdhistor NOT IN (2622,2917) THEN
      vr_dscritic := 'Histórico da TED não permite uso de conciliação. Favor verificar!';
      RAISE vr_exc_saida;
    END IF;
    
    IF rw_ted.dtconciliacao IS NOT NULL THEN
      vr_dscritic := 'Não é possível efetuar a conciliação, pois a TED já foi conciliada.';
      RAISE vr_exc_saida;
    END IF;
    
      IF (rw_ted.nome_estado <> vr_estado) and vr_estado is not null THEN
        vr_dscritic := 'Não é possível efetuar a conciliação entre estados diferentes.';
        RAISE vr_exc_saida;
      END IF;  
      vr_estado:=  rw_ted.nome_estado; 
      --
      vr_sum_teds:= vr_sum_teds + rw_ted.vllanmto;
    
    END LOOP;
    --    
    OPEN cr_titulos;
    FETCH cr_titulos INTO rw_titulos;
    IF cr_titulos%NOTFOUND THEN
      CLOSE cr_titulos;
      vr_dscritic := 'Titulos não selecionados para conciliação.';
      RAISE vr_exc_saida;
    END IF;
    CLOSE cr_titulos;
    
    -- Leitura do calendario da cooperativa
    OPEN btch0001.cr_crapdat(pr_cdcooper => rw_ted.cdcooper);
    FETCH btch0001.cr_crapdat INTO rw_crapdat;
    -- Fechar o cursor
    CLOSE btch0001.cr_crapdat;

    FOR rw_titulos IN cr_titulos LOOP
      
      IF rw_titulos.dtconciliacao IS NOT NULL THEN
        vr_dscritic := 'Não é possível efetuar a conciliação, pois existem títulos já conciliados.';
        RAISE vr_exc_saida;
      END IF;
      
      -- Validações
      -- Valida se o valor do título excede o valor da TED
      IF rw_titulos.vlsaldo_titulo > vr_sum_teds THEN
        vr_dscritic := 'Valor do título não pode exceder o valor da TED. Favor verificar!';
        RAISE vr_exc_saida;
      END IF;

      vr_sum_titulos := vr_sum_titulos + rw_titulos.vlsaldo_titulo;

      IF vr_sum_titulos > vr_sum_teds THEN
        vr_dscritic := 'Valor total de títulos execede o valor da TED. Favor verificar!';
        RAISE vr_exc_saida;
      END IF;
      IF vr_qtdreg = 0 THEN
        /* Para atender a RITM0013002 foi alterado a forma de manter esta tabela, que anteriormente poderia 
           te N registros, de acordo com o numero de titulos. Com a mudança, ela terá somente um registro que será
           o responsável pela ligação entre as tabelas de TED e Titulos, que terão este ID atualizados de 
           acordo com suas conciliações*/
        --
        vr_idconciliacao:= fn_sequence('tbcobran_conciliacao_ieptb','idconciliacao',rw_ted.cdcooper,'N'); -- Sequencial
        pr_idconciliacao:= vr_idconciliacao;
        --
      BEGIN
        INSERT INTO tbcobran_conciliacao_ieptb
               (idconciliacao,
                dtconcilicao,
                inconciliacao,
                idrecurso_movto,
                idretorno_ieptb,
                flgproc,
                dtdproc,
                cdoperad,
                idcartorio
               )
          VALUES (vr_idconciliacao,     -- Sequencial
                rw_crapdat.dtmvtolt, -- Data mvmto
                2,                   -- Conciliação Manual
                  0, -- ID TED Campo não é mais utilizado
                  0, -- ID Titulo Campo não é mais utilizado
                0,
                NULL,
                '1',
                0);
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao gerar conciliação: ' ||SQLERRM;
            RAISE vr_exc_saida;
      END;     
      END IF;   
      vr_qtdreg:= vr_qtdreg + 1;

      -- Atualiza título
      BEGIN
        UPDATE tbcobran_retorno_ieptb
           SET dtconciliacao = rw_crapdat.dtmvtolt
              ,idconciliacao = vr_idconciliacao /*RITM0013002*/
         WHERE idretorno = rw_titulos.idretorno;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao atualizar título: ' ||SQLERRM;
          
          RAISE vr_exc_saida;
      END;
            
    END LOOP;
    
    IF vr_sum_titulos <> vr_sum_teds THEN
      vr_dscritic := 'Valor total dos títulos não pode ser diferente do valor da TED. Favor verificar!';
      RAISE vr_exc_saida;
    END IF;
    
    -- Atualiza TED
    BEGIN
      UPDATE tbfin_recursos_movimento
         SET dtconciliacao = rw_crapdat.dtmvtolt
           , idconciliacao = vr_idconciliacao  /*RITM0013002*/
      WHERE idlancto IN (SELECT to_number(COLUMN_VALUE)
                                 FROM xmltable(pr_idlancto));
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao atualizar movimentação: ' ||SQLERRM;
        RAISE vr_exc_saida;
    END;
    --

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
    
      pr_dscritic:= vr_dscritic;

  END pc_gera_conciliacao;
  
  PROCEDURE pc_gera_conciliacao_web(pr_idlancto IN tbfin_recursos_movimento.idlancto%TYPE -- ID da TED
                                    ,pr_xmllog   IN VARCHAR2                               -- XML com informações de LOG
                                    ,pr_cdcritic OUT PLS_INTEGER                           -- Código da crítica
                                    ,pr_dscritic OUT VARCHAR2                              -- Descrição da crítica
                                    ,pr_retxml   IN OUT NOCOPY XMLType                     -- Arquivo de retorno do XML
                                    ,pr_nmdcampo OUT VARCHAR2                              -- Nome do campo com erro                      
                                    ,pr_des_erro OUT VARCHAR2) IS
	/* ............................................................................

       Programa: pc_gera_conciliacao
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : André Clemer
       Data    : Abril/2018                     Ultima atualizacao: --/--/----

       Dados referentes ao programa:

       Frequencia: Sempre que chamado
       Objetivo  : Rotina responsavel por gerar a conciliação

       Alteracoes: 

    ............................................................................ */  
 
    -------------->> VARIAVEIS <<----------------
    -- Variáveis para tratamento do XML
    vr_xmltype     sys.xmltype;
    vr_parser      xmlparser.Parser;
    vr_doc         xmldom.DOMDocument;
    vr_node_list   xmldom.DOMNodeList;
    vr_lenght      NUMBER;
    vr_item_node   xmldom.DOMNode;
    vr_node_name   VARCHAR2(100);
    
    vr_sum_titulos NUMBER := 0;
    vr_idconciliacao tbcobran_conciliacao_ieptb.idconciliacao%type;
    
    -- Variável de críticas
    vr_dscritic    VARCHAR2(10000);
    
    -- Tratamento de erros
    vr_exc_saida   EXCEPTION;
    vr_exc_erro    EXCEPTION;
    
    vr_ids         VARCHAR2(10000) := '';
    vr_ids_ted     VARCHAR2(10000) := '';
  BEGIN
    -- Debug
/*    pr_retxml := xmltype('<?xml version="1.0" encoding="ISO-8859-1"?>
        <Root>
          <Dados>
            <Titulos>
              <Id>143</Id>
              <Id>142</Id>
              <Id>141</Id>
              <Id>140</Id>
              <Id>139</Id>
            </Titulos>
          </Dados>
        </Root>');*/
    vr_xmltype := pr_retxml;

    -- Faz o parse do XMLTYPE para o XMLDOM e libera o parser ao fim
    vr_parser := xmlparser.newParser;
    xmlparser.parseClob(vr_parser,vr_xmltype.getClobVal());
    vr_doc    := xmlparser.getDocument(vr_parser);
    xmlparser.freeParser(vr_parser);

    -- Faz o get de toda a lista de elementos
    vr_node_list := xmldom.getElementsByTagName(vr_doc, '*');
    vr_lenght    := xmldom.getLength(vr_node_list);
      
    -- Percorrer os elementos
    FOR i IN 0..vr_lenght LOOP
      -- Pega o item
      vr_item_node := xmldom.item(vr_node_list, i);
                     
      -- Captura o nome do nodo
      vr_node_name := xmldom.getNodeName(vr_item_node);
        
      -- Verifica qual nodo esta sendo lido
      IF vr_node_name = 'Id' THEN
         vr_ids := vr_ids || TRIM(xmldom.getnodevalue(xmldom.getfirstchild(vr_item_node))) || ',';
         CONTINUE;
      ELSIF vr_node_name = 'IdTed' THEN  /*RITM0013002*/
          vr_ids_ted := vr_ids_ted || TRIM(xmldom.getnodevalue(xmldom.getfirstchild(vr_item_node))) || ',';
      ELSE
         CONTINUE; -- Descer para o próximo filho
      END IF;
    END LOOP;
      
    vr_ids := SUBSTR(vr_ids, 1, LENGTH(vr_ids) - 1);
    vr_ids_ted := SUBSTR(vr_ids_ted, 1, LENGTH(vr_ids_ted) - 1);
    
    pc_gera_conciliacao(pr_idlancto   => vr_ids_ted
                       ,pr_idsretorno => vr_ids
                       ,pr_idconciliacao => vr_idconciliacao
                       ,pr_dscritic => vr_dscritic);
                       
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;
    
    COBR0011.pc_gera_movimento_pagamento( pr_idconciliacao => vr_idconciliacao
                                        , pr_dscritic => vr_dscritic);
    
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;
    --
    COMMIT;
    --    
  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_dscritic := vr_dscritic;
      
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || vr_dscritic || '</Erro></Root>');
      ROLLBACK;
    WHEN OTHERS THEN
      pr_dscritic := vr_dscritic;
      IF vr_dscritic IS NULL THEN
         pr_dscritic := 'Erro geral pc_gera_conciliacao : '||SQLERRM;
      END IF;
      
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
  END pc_gera_conciliacao_web;

  PROCEDURE pc_exporta_conciliacao_pdf(pr_cdcooper_usr  	 IN craptab.cdcooper%TYPE --> Cooperativa que está sendo executada
											   ,pr_cdcooper  	 IN craptab.cdcooper%TYPE         --> Cooperativa
											   ,pr_nrdconta      IN crapceb.nrdconta%TYPE --> Numero da conta do cooperado
											   ,pr_dtinicial     IN VARCHAR2 -- Data inicial de recebimento de ted
											   ,pr_dtfinal       IN VARCHAR2 -- Data final de recebimento de ted
											   ,pr_vlinicial     IN tbfin_recursos_movimento.vllanmto%TYPE -- Valor inicial de comparação ted
											   ,pr_vlfinal       IN tbfin_recursos_movimento.vllanmto%TYPE -- Valor final de comparação ted
											   ,pr_cartorio      IN tbfin_recursos_movimento.nrcnpj_debitada%TYPE -- Cartorio da ted                         
											   ,pr_xmllog        IN VARCHAR2                -- XML com informações de LOG
											   ,pr_cdcritic      OUT PLS_INTEGER            -- Código da crítica
											   ,pr_dscritic      OUT VARCHAR2               -- Descrição da crítica
											   ,pr_retxml        IN OUT NOCOPY XMLType      -- Arquivo de retorno do XML
											   ,pr_nmdcampo      OUT VARCHAR2               -- Nome do Campo
											   ,pr_des_erro      OUT VARCHAR2) IS
	/* ............................................................................

       Programa: pc_exporta_consulta_conciliacao_pdf
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Hélinton Steffens
       Data    : Abril/2017                     Ultima atualizacao: --/--/----

       Dados referentes ao programa:

       Frequencia: Sempre que chamado
       Objetivo  : Rotina responsavel por gerar o relatorio das conciliações - Chamada ayllos Web

       Alteracoes: ----

    ............................................................................ */

    -------------->> VARIAVEIS <<----------------
    -- Variavel de criticas
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(10000);
    vr_des_reto VARCHAR2(10);
    vr_typ_saida      VARCHAR2(3);
    
    -- Tratamento de erros
    vr_exc_erro      EXCEPTION;
    vr_exc_saida     EXCEPTION;
    vr_tab_erro GENE0001.typ_tab_erro;
    
    -- Data do movimento
    vr_dtmvtolt      crapdat.dtmvtolt%type;
    
    -- Variável para armazenar as informações em XML
    vr_des_xml       clob;
    vr_des_xml_txt   varchar2(32767);
    vr_typsaida     VARCHAR2(100); 
    
    -- Variável para o caminho e nome do arquivo base
    vr_dsdireto   varchar2(200);
    vr_nmarquivo  varchar2(200);
    vr_dscomand   varchar2(200);
    
    --debug
    vr_input_file utl_file.file_type;
    vr_nmdirtxt   VARCHAR2(400);
    
    --RITM0013002
    vr_qtd_ted    number;

    /*RITM0013002 - Agrupa as conciliações de acordo com os parâmetros*/
    CURSOR cr_conc (pr_dtinicial     IN VARCHAR2
                  ,pr_dtfinal       IN VARCHAR2
                  ,pr_vlinicial     IN tbfin_recursos_movimento.vllanmto%TYPE
                  ,pr_vlfinal       IN tbfin_recursos_movimento.vllanmto%TYPE ) IS    
    SELECT    DISTINCT conc.idconciliacao
    FROM tbcobran_conciliacao_ieptb conc
        ,tbcobran_retorno_ieptb ret
    WHERE conc.idconciliacao   = ret.idconciliacao 
      AND ((conc.dtconcilicao BETWEEN to_date(pr_dtinicial,'DD/MM/RRRR') AND to_date(pr_dtfinal,'DD/MM/RRRR')) 
         OR (pr_dtinicial IS NULL AND pr_dtfinal IS NULL))
      AND ((ret.vltitulo >= pr_vlinicial AND ret.vltitulo <= pr_vlfinal) 
         OR (pr_vlinicial = 0 AND pr_vlfinal = 0));
    
    
    CURSOR cr_teds_new(pr_idconciliacao     IN tbcobran_conciliacao_ieptb.idconciliacao%TYPE) IS        
    select gene0002.fn_mask_cpf_cnpj(mov.nrcnpj_debitada,2) nrcpf_cnpj
          , ban.cdbccxlt 
          , mov.cdagenci_debitada 
          , mov.nrdconta 
          , mov.dtmvtolt 
          , mov.vllanmto 
    from tbfin_recursos_movimento mov
        ,crapban ban
    where mov.idconciliacao = pr_idconciliacao
    and   mov.nrispbif      = ban.nrispbif
    and   ban.flgdispb      = 1;
    
    
    CURSOR cr_teds(pr_dtinicial     IN VARCHAR2
                  ,pr_dtfinal       IN VARCHAR2
                  ,pr_vlinicial     IN tbfin_recursos_movimento.vllanmto%TYPE
                  ,pr_vlfinal       IN tbfin_recursos_movimento.vllanmto%TYPE
                  ,pr_cartorio      IN tbfin_recursos_movimento.nrcnpj_debitada%TYPE
                  ,pr_flgcon        IN INTEGER
                  ,pr_idmovto       IN tbcobran_conciliacao_ieptb.idrecurso_movto%TYPE
                  ,pr_idretorno     IN tbcobran_conciliacao_ieptb.idretorno_ieptb%TYPE) IS
                  
      SELECT a.nmcartorio
             ,a.vllanmto
             ,a.nrdconta
             ,a.cdagenci_debitada
             ,gene0002.fn_mask_cpf_cnpj(a.nrcpf_cnpj,2) AS nrcpf_cnpj
             ,a.dtmvtolt
             ,a.idrecurso_movto
             ,a.cdbccxlt
             ,a.idcidade
             ,a.idconciliacao
      FROM (
        SELECT cartorio.nmcartorio
                  ,mov.vllanmto
                  ,mov.nrdconta
                  ,banco.cdbccxlt
                  ,mov.cdagenci_debitada
                  ,cartorio.nrcpf_cnpj
                  ,mov.dtmvtolt
                  ,conc.idrecurso_movto
                  ,conc.idretorno_ieptb
                  ,cartorio.idcidade
                  ,conc.idconciliacao
            FROM tbcobran_conciliacao_ieptb conc
                ,tbcobran_retorno_ieptb ret
                ,tbcobran_cartorio_protesto cartorio
                ,crapmun municipio
                ,tbfin_recursos_movimento mov
                ,crapcop coop
                ,crapban banco
            WHERE --ret.idretorno = conc.idretorno_ieptb
                  conc.idconciliacao = ret.idconciliacao /*RITM0013002*/
              --AND conc.idrecurso_movto = mov.idlancto
              AND conc.idconciliacao = mov.idconciliacao
              AND cartorio.idcidade = municipio.idcidade
              AND cartorio.cdcartorio = ret.cdcartorio
              AND municipio.cdcomarc = ret.cdcomarc
              AND mov.cdcooper = coop.cdcooper
              AND mov.nrispbif = banco.nrispbif
              AND banco.nrispbif (+) = mov.nrispbif
              AND banco.cdbccxlt (+) = decode(mov.nrispbif,0,1,banco.cdbccxlt(+))
              AND ((conc.dtconcilicao BETWEEN to_date(pr_dtinicial,'DD/MM/RRRR') AND to_date(pr_dtfinal,'DD/MM/RRRR')) 
                 OR (pr_dtinicial IS NULL AND pr_dtfinal IS NULL))
              AND ((ret.vltitulo >= pr_vlinicial AND ret.vltitulo <= pr_vlfinal) 
                 OR (pr_vlinicial = 0 AND pr_vlfinal = 0))
              AND (cartorio.nrcpf_cnpj = pr_cartorio OR pr_cartorio IS NULL)
      ) a
      group by a.nmcartorio
             ,a.vllanmto
             ,a.nrdconta
             ,a.cdagenci_debitada
             ,gene0002.fn_mask_cpf_cnpj(a.nrcpf_cnpj,2)
             ,a.dtmvtolt
             ,a.idrecurso_movto
             ,a.cdbccxlt
             ,a.idcidade
             ,a.idconciliacao;

    rw_ted cr_teds%ROWTYPE;
    
    CURSOR cr_titulos(pr_idconciliacao IN tbcobran_conciliacao_ieptb.idconciliacao%TYPE) IS
      /*select ret.nrdconta
            ,ret.nrcnvcob
            ,ret.nrdocmto
            ,ret.cdcooper
            ,coop.nmrescop
            ,ret.vltitulo
      from   tbcobran_conciliacao_ieptb conc
            ,tbcobran_retorno_ieptb ret
            ,crapmun municipio
            ,tbfin_recursos_movimento mov
            ,crapban banco
            ,crapcop coop
      where  conc.idretorno_ieptb = ret.idretorno
        and  conc.idrecurso_movto = mov.idlancto
        and  municipio.cdcomarc   = ret.cdcomarc
        and  banco.nrispbif       = mov.nrispbif
        and  coop.cdcooper = ret.cdcooper
        and  banco.nrispbif (+) = mov.nrispbif
        and  banco.cdbccxlt (+) = decode(mov.nrispbif,0,1,banco.cdbccxlt(+))
        and  conc.idrecurso_movto = pr_idmovto
        and  municipio.idcidade = pr_idcidade; */
        
      /*RITM0013002 - Querie atualizada de acordo com a nova estrutura de conciliação*/    
      select ret.nrdconta
            ,ret.nrcnvcob
            ,ret.nrdocmto
            ,ret.cdcooper
            ,coop.nmrescop
            ,ret.vltitulo
      from   tbcobran_conciliacao_ieptb conc
            ,tbcobran_retorno_ieptb ret
            ,crapcop coop
      where conc.idconciliacao   = ret.idconciliacao
        and  coop.cdcooper = ret.cdcooper
        and  conc.idconciliacao = pr_idconciliacao;
        
    rw_titulo cr_titulos%ROWTYPE;
    
    -- Subrotina para escrever texto na variável CLOB do XML
    procedure pc_escreve_xml(pr_des_dados in clob) is
    begin
      dbms_lob.writeappend(vr_des_xml, length(pr_des_dados), pr_des_dados);
    end;
    
  BEGIN                                                  
    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'TELA_MANPRT', pr_action => null);

    vr_des_xml := null;
    dbms_lob.createtemporary(vr_des_xml, true);
    dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
    -- Inicilizar as informações do XML
    pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><consulta_conciliacoes>');
	
    pc_escreve_xml('<cdcooper>'     ||pr_cdcooper	    ||'</cdcooper>'||
				   '<nrdconta>'     ||pr_nrdconta	    ||'</nrdconta>'||
                   '<dtinicial>'    ||pr_dtinicial      ||'</dtinicial>'||
                   '<dtfinal>'      ||pr_dtfinal        ||'</dtfinal>'||
				           '<vlinicial>'    ||to_char(pr_vlinicial, 'fm999g999g990D00')    ||'</vlinicial>'||
				           '<vlfinal>'      ||to_char(pr_vlfinal, 'fm999g999g990D00')      ||'</vlfinal>'  ||
                   '<dscartorio>'   ||pr_cartorio       ||'</dscartorio>');
                   
                   
    pc_escreve_xml('<conciliacoes>');
                   
    
    FOR rw_conc IN cr_conc(pr_dtinicial  => pr_dtinicial
                                                                ,pr_dtfinal    => pr_dtfinal
                                                                ,pr_vlinicial  => pr_vlinicial
                          ,pr_vlfinal	   => pr_vlfinal) LOOP
       --
       vr_qtd_ted := 0;                   
       SELECT count(*) into vr_qtd_ted                      
       FROM tbfin_recursos_movimento mov
       WHERE mov.idconciliacao = rw_conc.idconciliacao;
       --
      FOR rw_ted IN cr_teds_new(pr_idconciliacao  => rw_conc.idconciliacao) LOOP
        --
      pc_escreve_xml('<recurso_movimento>');
        -- Grava informações das TEDs
      pc_escreve_xml('<cdcartorio>'     ||rw_ted.nrcpf_cnpj                            ||'</cdcartorio>'||
                     '<banco>'     		  ||rw_ted.cdbccxlt       	                      ||'</banco>'||
                     '<agencia>'    	  ||rw_ted.cdagenci_debitada                     ||'</agencia>'||
                     '<nrconta>'        ||rw_ted.nrdconta                              ||'</nrconta>'||
                     '<vlted>'          ||to_char(rw_ted.vllanmto, 'fm999g999g990D00') ||'</vlted>'||
					           '<dtrecebimento>'  ||to_char(rw_ted.dtmvtolt, 'DD/MM/RRRR')       ||'</dtrecebimento>'||
                       '<idconciliacao>'||rw_conc.idconciliacao||'</idconciliacao>'); 	  
        --
        IF vr_qtd_ted = 1 THEN
          /*Grava cabeçalho dos titulos*/
          pc_escreve_xml('<Columns>'        ||
                       '<column1>'      ||'Conta'          ||'</column1>'||
                       '<column2>'      ||'Convenio'       ||'</column2>'||
                       '<column3>'      ||'Documento'      ||'</column3>'||
                       '<column4>'      ||'Cooperativa'    ||'</column4>'||
                       '<column5>'      ||'Valor título'   ||'</column5>'||
	                 '</Columns>');
          --
    pc_escreve_xml('<retornos>');
          -- 
          FOR rw_titulo IN cr_titulos(pr_idconciliacao   => rw_conc.idconciliacao) LOOP
            --
        pc_escreve_xml('<retorno_ieptb>');
		     pc_escreve_xml('<conta>'      ||rw_titulo.nrdconta      ||'</conta>'||
                        '<convenio>'   ||rw_titulo.nrcnvcob      ||'</convenio>'||
                        '<documento>'  ||rw_titulo.nrdocmto      ||'</documento>'||
                        '<cooperativa>'||rw_titulo.nmrescop      ||'</cooperativa>'||
	          				    '<valor>'      ||to_char(rw_titulo.vltitulo, 'fm999g999g990D00')      ||'</valor>');
		pc_escreve_xml('</retorno_ieptb>');
            --
          END LOOP; --Fim Titulos																
          --	  
      pc_escreve_xml('</retornos>');	  
          --
        END IF;  
        --
        vr_qtd_ted:= vr_qtd_ted -1;  
        -- 
      pc_escreve_xml('</recurso_movimento>');
      END LOOP; --Fim Teds
      --
    END LOOP; --Fim Conciliacao
    
    pc_escreve_xml('</conciliacoes>'); 
    -- Fecha a tag principal para encerrar o XML
    pc_escreve_xml('</consulta_conciliacoes>');
    --Buscar diretorio da cooperativa
    vr_dsdireto := gene0001.fn_diretorio(pr_tpdireto => 'C', --> cooper 
                                         pr_cdcooper => pr_cdcooper,
                                         pr_nmsubdir => '/rl');
    vr_dscomand := 'rm '||vr_dsdireto ||'/crrl741_' ||0 ||'* 2>/dev/null';
      
    --Executar o comando no unix
    GENE0001.pc_OScommand(pr_typ_comando => 'S'
                         ,pr_des_comando => vr_dscomand
                         ,pr_typ_saida   => vr_typsaida
                         ,pr_des_saida   => vr_dscritic);
    --Se ocorreu erro dar RAISE
    IF vr_typsaida = 'ERR' THEN
      vr_dscritic:= 'Nao foi possivel remover arquivos: '||vr_dscomand||'. Erro: '||vr_dscritic;
      RAISE vr_exc_erro;
    END IF;
    vr_nmarquivo := 'crrl741_'||0 || gene0002.fn_busca_time || '.pdf';
    
    -- DEBUG
    -- Diretório onde deverá gerar o arquivo de remessa
    --vr_nmdirtxt := '/micros/cecred/ieptb/remessa/';
    vr_nmdirtxt := gene0001.fn_param_sistema (pr_nmsistem => 'CRED'              -- IN
                                             ,pr_cdcooper => 3                   -- IN
                                             ,pr_cdacesso => 'DIR_IEPTB_REMESSA' -- IN
                                             );
    -- Abre o arquivo de dados em modo de gravação
    gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdirtxt   -- IN -- Diretório do arquivo
                            ,pr_nmarquiv => 'arquivo.txt'   -- IN -- Nome do arquivo
                            ,pr_tipabert => 'W'           -- IN -- Modo de abertura (R,W,A)
                            ,pr_utlfileh => vr_input_file -- IN -- Handle do arquivo aberto
                            ,pr_des_erro => pr_dscritic   -- IN -- Erro
                            );
    --
    IF pr_dscritic IS NOT NULL THEN
      --
      RAISE vr_exc_erro;
      --
    END IF;
    
    vr_des_xml_txt := dbms_lob.substr(vr_des_xml, 30000, 1); --         (or DBMS_LOB.READ(v1,1000,1,v2))
    
    -- Escrever o registro no arquivo
    gene0001.pc_escr_linha_arquivo(pr_utlfileh  => vr_input_file            -- Handle do arquivo aberto
                                  ,pr_des_text  => vr_des_xml_txt -- Texto para escrita
                                  );
                                  
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file); --> Handle do arquivo aberto;
    -- END DEBUG
    
    --> Solicita geracao do PDF
    gene0002.pc_solicita_relato(pr_cdcooper   => pr_cdcooper
                               , pr_cdprogra  => 'MANPRT'
                               , pr_dtmvtolt  => vr_dtmvtolt
                               , pr_dsxml     => vr_des_xml
                               , pr_dsxmlnode => '/consulta_conciliacoes'
                               , pr_dsjasper  => 'crrl741.jasper'
                               , pr_dsparams  => null
                               , pr_dsarqsaid => vr_dsdireto ||'/'||vr_nmarquivo
                               , pr_flg_gerar => 'S'
                               , pr_qtcoluna  => 132
                               , pr_cdrelato  => 741
                               , pr_sqcabrel  => 1
                               , pr_flg_impri => 'N'
                               , pr_nmformul  => ' '
                               , pr_nrcopias  => 1
                               , pr_nrvergrl  => 1
                               , pr_des_erro  => vr_dscritic);
      
    IF vr_dscritic IS NOT NULL THEN -- verifica retorno se houve erro
      RAISE vr_exc_erro; -- encerra programa
    END IF; 
    
    -- Liberando a memoria alocada pro CLOB
    dbms_lob.close(vr_des_xml);
    dbms_lob.freetemporary(vr_des_xml);
 
    --> AyllosWeb
    -- Copia contrato PDF do diretorio da cooperativa para servidor WEB
    GENE0002.pc_efetua_copia_pdf(pr_cdcooper => pr_cdcooper
                                ,pr_cdagenci => NULL
                                ,pr_nrdcaixa => NULL
                                ,pr_nmarqpdf => vr_dsdireto ||'/'||vr_nmarquivo
                                ,pr_des_reto => vr_des_reto
                                ,pr_tab_erro => vr_tab_erro);
    -- Se retornou erro
    IF NVL(vr_des_reto,'OK') <> 'OK' THEN
      IF vr_tab_erro.COUNT > 0 THEN -- verifica pl-table se existe erros          
        vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic; -- busca primeira descricao da critica
        RAISE vr_exc_erro; -- encerra programa
      END IF;
    END IF;
    
     -- Criar XML de retorno para uso na Web
     pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><nmarqpdf>' || vr_nmarquivo|| '</nmarqpdf>');

    -- Remover relatorio do diretorio padrao da cooperativa
    gene0001.pc_OScommand(pr_typ_comando => 'S'
                         ,pr_des_comando => 'rm '||vr_dsdireto ||'/'||vr_nmarquivo
                         ,pr_typ_saida   => vr_typsaida
                         ,pr_des_saida   => vr_dscritic);
    -- Se retornou erro
    IF vr_typsaida = 'ERR' OR vr_dscritic IS NOT NULL THEN
      -- Concatena o erro que veio
      vr_dscritic := 'Erro ao remover arquivo: '||vr_dscritic;
      RAISE vr_exc_erro; -- encerra programa
    END IF;                                      
                                        
  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_dscritic := 'Erro geral pc_exporta_consulta_custas_pdf : '||SQLERRM;  	                                                                                     
  END pc_exporta_conciliacao_pdf;
  
  PROCEDURE pc_exporta_conciliacao(pr_cdcooper  IN craptab.cdcooper%TYPE         --> Cooperativa
                                    ,pr_dtinicial     IN VARCHAR2 -- Data inicial de recebimento de ted
                            	      ,pr_dtfinal       IN VARCHAR2 -- Data final de recebimento de ted
                                    ,pr_vlinicial     IN tbfin_recursos_movimento.vllanmto%TYPE -- Valor inicial de comparação ted
                                    ,pr_vlfinal       IN tbfin_recursos_movimento.vllanmto%TYPE -- Valor final de comparação ted
                                    ,pr_cartorio      IN tbfin_recursos_movimento.nrcnpj_debitada%TYPE -- Cartorio da ted                       
                                    ,pr_nrregist      IN INTEGER                 -- Quantidade de registros
                                    ,pr_nriniseq      IN INTEGER                 -- Qunatidade inicial
                                    ,pr_flgcon        IN INTEGER DEFAULT 0       -- TEDs conciliadas: '1' sim '0' não
                                    ,pr_xmllog        IN VARCHAR2                -- XML com informações de LOG
                                    ,pr_cdcritic      OUT PLS_INTEGER            -- Código da crítica
                                    ,pr_dscritic      OUT VARCHAR2               -- Descrição da crítica
                                    ,pr_retxml        IN OUT NOCOPY xmltype      -- Arquivo de retorno do XML
                                    ,pr_nmdcampo      OUT VARCHAR2               -- Nome do Campo
                                    ,pr_des_erro      OUT VARCHAR2) IS
	/* ............................................................................

       Programa: pc_exporta_consulta_teds
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Hélinton Steffens
       Data    : Abril/2017                     Ultima atualizacao: --/--/----

       Dados referentes ao programa:

       Frequencia: Sempre que chamado
       Objetivo  : Rotina responsavel por gerar o relatorio de teds a conciliar - Chamada ayllos Web

       Alteracoes: ----

    ............................................................................ */  
 
    -------------->> VARIAVEIS <<----------------
    -- Variavel de criticas
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(10000);
    vr_des_reto VARCHAR2(10);
    vr_typ_saida      VARCHAR2(3);
    
    -- Tratamento de erros
    vr_exc_erro      EXCEPTION;
    vr_exc_saida     EXCEPTION;
    vr_tab_erro GENE0001.typ_tab_erro;
    
    -- Variaveis gerais
    vr_xml_temp VARCHAR2(32726) := '';
    vr_clob     CLOB;
    vr_dsdiretorio VARCHAR2(1000);      --> Local onde sera gerado o relatorio
    vr_nmarquivo   VARCHAR2(1000);      --> Nome do relatorio CSV
    
  BEGIN                                                  
    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'TELA_MANPRT', pr_action => null);

    -- Cria a variavel CLOB
    dbms_lob.createtemporary(vr_clob, TRUE);
    dbms_lob.open(vr_clob, dbms_lob.lob_readwrite);
    
    -- Busca o diretorio onde esta os arquivos Sicoob
    vr_dsdiretorio := gene0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                                pr_cdacesso => 'ROOT_DOMICILIO')||'/relatorios';
    vr_nmarquivo := 'MANPRT_'||to_char(SYSDATE,'HHMISS')||'.csv';
    -- Criar cabeçalho do CSV
    GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                           ,pr_texto_completo => vr_xml_temp
                           --,pr_texto_novo     => 'Cartorio;Valor TED;Cooperativa;Convenio;Conta;Data Conc.;Vlr. Titulo;Data Pagto'||chr(10));
                           ,pr_texto_novo     => 'Cartorio;Cooperativa;Convenio;Data Conc.;Vlr. Titulo;Informacoes TEDs'||chr(10)); --;
    
    FOR rw_tbcobran_conciliacao_ieptb IN cr_tbcobran_conciliacao_ieptb(pr_dtinicial => pr_dtinicial
                                                                  ,pr_dtfinal   => pr_dtfinal
                                                                  ,pr_vlinicial => pr_vlinicial
                                                                  ,pr_vlfinal   => pr_vlfinal
                                                                  ,pr_cartorio  => pr_cartorio
                                                                      ,pr_flgcon    => 0) LOOP
      -- Carrega os dados
      GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => rw_tbcobran_conciliacao_ieptb.nmcartorio       ||';'||
                                                   rw_tbcobran_conciliacao_ieptb.nmrescop         ||';'||
                                                   rw_tbcobran_conciliacao_ieptb.nrcnvcob         ||';'||
                                                   to_char(rw_tbcobran_conciliacao_ieptb.dtconcilicao,'DD/MM/YYYY')     ||';'||
                                                   to_char(rw_tbcobran_conciliacao_ieptb.vltitulo, 'fm999g999g990D00')         ||';'||
                                                   rw_tbcobran_conciliacao_ieptb.inf_teds_excel         ||';'||chr(10)); /*RITM0013002 - As informacoes de valor, conta e data de recebimento foram agrupados neste campo*/
    END LOOP;
    -- Encerrar o Clob
    GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                           ,pr_texto_completo => vr_xml_temp
                           ,pr_texto_novo     => ' '
                           ,pr_fecha_xml      => TRUE);

    -- Gera o relatorio
    GENE0002.pc_clob_para_arquivo(pr_clob => vr_clob,
                                  pr_caminho => vr_dsdiretorio,
                                  pr_arquivo => vr_nmarquivo,
                                  pr_des_erro => vr_dscritic);
    IF vr_dscritic IS NOT NULL THEN
       RAISE vr_exc_saida;
    END IF;

    -- copia contrato pdf do diretorio da cooperativa para servidor web
    GENE0002.pc_efetua_copia_pdf(pr_cdcooper => pr_cdcooper
                               , pr_cdagenci => NULL
                               , pr_nrdcaixa => NULL
                               , pr_nmarqpdf => vr_dsdiretorio||'/'||vr_nmarquivo
                               , pr_des_reto => vr_des_reto
                               , pr_tab_erro => vr_tab_erro
                               );

    -- caso apresente erro na operação
    IF nvl(vr_des_reto,'OK') <> 'OK' THEN
       IF vr_tab_erro.COUNT > 0 THEN -- verifica pl-table se existe erros
          vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic; -- busca primeira critica
          vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic; -- busca primeira descricao da critica
          RAISE vr_exc_saida; -- encerra programa
        END IF;
     END IF;

     -- Remover relatorio do diretorio padrao da cooperativa
     gene0001.pc_OScommand(pr_typ_comando => 'S'
                          ,pr_des_comando => 'rm '||vr_dsdiretorio||'/'||vr_nmarquivo
                          ,pr_typ_saida   => vr_typ_saida
                          ,pr_des_saida   => vr_dscritic);

     -- Se retornou erro
     IF vr_typ_saida = 'ERR' OR vr_dscritic IS NOT null THEN
        -- Concatena o erro que veio
        vr_dscritic := 'Erro ao remover arquivo: '||vr_dscritic;
        RAISE vr_exc_saida; -- encerra programa
     END IF;

     -- Criar XML de retorno para uso na Web
     pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><nmarqcsv>' || vr_nmarquivo|| '</nmarqcsv>');

     -- Libera a memoria do CLOB
     dbms_lob.close(vr_clob);
     dbms_lob.freetemporary(vr_clob);
                                        
  EXCEPTION
    WHEN vr_exc_erro THEN
      IF vr_cdcritic <> 0 THEN
        vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      END IF;

      vr_dscritic := '<![CDATA['||vr_dscritic||']]>';
      pr_dscritic := REPLACE(REPLACE(REPLACE(vr_dscritic,chr(13),' '),chr(10),' '),'''','´');

      -- Carregar XML padrao para variavel de retorno
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    WHEN OTHERS THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina da tela pc_exporta_consulta_teds: ' || SQLERRM;
      pr_dscritic := '<![CDATA['||pr_dscritic||']]>';
      pr_dscritic := REPLACE(REPLACE(REPLACE(pr_dscritic,chr(13),' '),chr(10),' '),'''','´');
      
      -- Carregar XML padrao para variavel de retorno
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');                                                   
  END pc_exporta_conciliacao;
  
  PROCEDURE pc_valida_cartorio_web(pr_cdcooper   IN craptab.cdcooper%TYPE
                                  ,pr_idlancto   IN TBFIN_RECURSOS_MOVIMENTO.IDLANCTO%TYPE
                                  ,pr_xmllog     IN VARCHAR2                 -- XML com informações de LOG
                                  ,pr_cdcritic   OUT PLS_INTEGER             -- Código da crítica
                                  ,pr_dscritic   OUT VARCHAR2
                                  ,pr_retxml     IN OUT NOCOPY XMLType       -- Arquivo de retorno do XML
                                  ,pr_nmdcampo   OUT VARCHAR2                -- Nome do Campo
                                  ,pr_des_erro   OUT VARCHAR2) IS
  
  vr_nmcartorio tbcobran_cartorio_protesto.nmcartorio%TYPE;
  
  BEGIN
    
    SELECT cartorio.nmcartorio 
      INTO vr_nmcartorio
    FROM tbfin_recursos_movimento ted
        ,crapagb agencia
        ,crapmun municipio
        ,tbcobran_cartorio_protesto cartorio
    WHERE ted.cdagenci_debitada = agencia.cdageban
      and agencia.cdcidade = municipio.cdcidade
      and cartorio.idcidade = municipio.idcidade
      and cartorio.nrcpf_cnpj = ted.nrcnpj_debitada
      and ted.idlancto = pr_idlancto;
    
    IF vr_nmcartorio IS NULL THEN
      raise no_data_found;
    END IF;
    
    -- Criar XML de retorno para uso na Web
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><nmcartorio>' || vr_nmcartorio || '</nmcartorio>');
    
    EXCEPTION
      WHEN no_data_found THEN
        pr_dscritic := 'Cartório inválido.';
      
      
  END pc_valida_cartorio_web;
  
  PROCEDURE pc_retorna_titulo_web(pr_cdcooper   IN tbcobran_retorno_ieptb.cdcooper%TYPE
                                 ,pr_nrdconta   IN tbcobran_retorno_ieptb.nrdconta%TYPE
                                 ,pr_nrcnvcob   IN tbcobran_retorno_ieptb.nrcnvcob%TYPE
                                 ,pr_nrdocmto   IN tbcobran_retorno_ieptb.nrdocmto%TYPE
                                 ,pr_xmllog     IN VARCHAR2                 -- XML com informações de LOG
                                 ,pr_cdcritic   OUT PLS_INTEGER             -- Código da crítica
                                 ,pr_dscritic   OUT VARCHAR2
                                 ,pr_retxml     IN OUT NOCOPY XMLType       -- Arquivo de retorno do XML
                                 ,pr_nmdcampo   OUT VARCHAR2                -- Nome do Campo
                                 ,pr_des_erro   OUT VARCHAR2) IS
  
  
  ---
  vr_custas NUMBER;
  vr_vltitulo tbcobran_retorno_ieptb.vltitulo%TYPE;
  vr_idretorno tbcobran_retorno_ieptb.idretorno%TYPE;
  vr_nmprimtl crapass.nmprimtl%TYPE;
  vr_dtvencto crapcob.dtvencto%TYPE;
  ---
  
  BEGIN
    
  	  ---
      SELECT 
        (retorno.vlcuscar + retorno.vlcustas_cartorio + retorno.vldemais_despes)
        ,retorno.vltitulo
        ,retorno.idretorno
        ,associado.nmprimtl
        ,boleto.dtvencto
      INTO vr_custas
          ,vr_vltitulo
          ,vr_idretorno
          ,vr_nmprimtl
          ,vr_dtvencto
      FROM tbcobran_retorno_ieptb retorno
          ,crapass associado
          ,crapcob boleto
      WHERE retorno.cdcooper = pr_cdcooper
        and retorno.nrdconta = pr_nrdconta
        and retorno.nrcnvcob = pr_nrcnvcob
        and retorno.nrdocmto = pr_nrdocmto
        and associado.nrdconta = retorno.nrdconta
        and associado.cdcooper = retorno.cdcooper
        and boleto.nrdocmto = retorno.nrdocmto
        and boleto.cdcooper = retorno.cdcooper
        and boleto.nrdconta = retorno.nrdconta
        and boleto.nrcnvcob = retorno.nrcnvcob;
      ---
      
      IF vr_idretorno IS NULL THEN
         RAISE no_data_found;
      END IF;
      
      ---
      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Root'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'Dados'
                            ,pr_tag_cont => NULL
                            ,pr_des_erro => pr_dscritic);

      GENE0007.pc_insere_tag(pr_xml => pr_retxml
                            ,pr_tag_pai => 'Dados'
                            ,pr_posicao => 0
                            ,pr_tag_nova => 'custas'
                            ,pr_tag_cont => vr_custas
                            ,pr_des_erro => pr_dscritic);
                            
      GENE0007.pc_insere_tag(pr_xml => pr_retxml
                            ,pr_tag_pai => 'Dados'
                            ,pr_posicao => 0
                            ,pr_tag_nova => 'dtvencto'
                            ,pr_tag_cont => to_char(vr_dtvencto,'DD/MM/RRRR')
                            ,pr_des_erro => pr_dscritic);
                            
      GENE0007.pc_insere_tag(pr_xml => pr_retxml
                            ,pr_tag_pai => 'Dados'
                            ,pr_posicao => 0
                            ,pr_tag_nova => 'vltitulo'
                            ,pr_tag_cont => vr_vltitulo
                            ,pr_des_erro => pr_dscritic);
                            
      GENE0007.pc_insere_tag(pr_xml => pr_retxml
                            ,pr_tag_pai => 'Dados'
                            ,pr_posicao => 0
                            ,pr_tag_nova => 'nmprimtl'
                            ,pr_tag_cont => vr_nmprimtl
                            ,pr_des_erro => pr_dscritic);
                            
      GENE0007.pc_insere_tag(pr_xml => pr_retxml
                            ,pr_tag_pai => 'Dados'
                            ,pr_posicao => 0
                            ,pr_tag_nova => 'idretorno'
                            ,pr_tag_cont => vr_idretorno
                            ,pr_des_erro => pr_dscritic);
      ---
      
  EXCEPTION
    WHEN no_data_found THEN
        pr_dscritic := 'Título não encontrado.';
    WHEN OTHERS THEN
      -- Retorno não OK
      pr_des_erro:= 'NOK';

      -- Erro
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na pc_retorna_titulo_web: '|| SQLERRM;

      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');                            
      
  END pc_retorna_titulo_web;
  
  PROCEDURE pc_estornar_ted(pr_cdcooper      IN craptab.cdcooper%TYPE    -- Cooperativa
                           ,pr_cdoperad      IN VARCHAR2                 -- Codigo Operador
                           ,pr_idlancto      IN TBFIN_RECURSOS_MOVIMENTO.idlancto%TYPE -- Código da TED
                           ,pr_idretorno     IN TBCOBRAN_RETORNO_IEPTB.idretorno%TYPE -- Código do retorno
                           ,pr_xmllog        IN VARCHAR2                 -- XML com informações de LOG
                           ,pr_cdcritic      OUT PLS_INTEGER             -- Código da crítica
                           ,pr_dscritic      OUT VARCHAR2
                           ,pr_retxml        IN OUT NOCOPY XMLType       -- Arquivo de retorno do XML
                           ,pr_nmdcampo      OUT VARCHAR2                -- Nome do Campo
                           ,pr_des_erro      OUT VARCHAR2) IS
                                          
    --
    vr_idretorno TBCOBRAN_RETORNO_IEPTB.idretorno%TYPE;
    
    vr_dscritic VARCHAR2(500);
    vr_exc_erro EXCEPTION;
    
    vr_email_dest VARCHAR2(500);
    vr_emails_cobranca tbcobran_param_protesto.dsemail_cobranca%TYPE;
  
    vr_des_assunto VARCHAR2(500);
    vr_conteudo VARCHAR2(500);
    vr_idconciliacao NUMBER;
    --  
  BEGIN

    -- Gerar novo retorno usando a fn_sequence 
		vr_idretorno := fn_sequence(pr_nmtabela => 'TBCOBRAN_RETORNO_IEPTB'
															 ,pr_nmdcampo => 'IDRETORNO'
															 ,pr_dsdchave => 'IDRETORNO');
                               
                                   
    -- Retornar Título a partir do ID
    OPEN cr_tbcobran_retorno(pr_idretorno => pr_idretorno);
    --
    FETCH cr_tbcobran_retorno INTO rw_tbcobran_retorno;
    --
    IF cr_tbcobran_retorno%NOTFOUND THEN
      --
      vr_dscritic := 'Retorno ' || pr_idretorno || ' não encontrado!';
      CLOSE cr_tbcobran_retorno;
      raise no_data_found;
      --
    END IF;
    --
    CLOSE cr_tbcobran_retorno;
    
    -- Retornar TED a partir do ID
    OPEN cr_tbcobran_ted(pr_idlancto => pr_idlancto);
    --
    FETCH cr_tbcobran_ted INTO rw_tbcobran_ted;
    --
    IF cr_tbcobran_ted%NOTFOUND THEN
      --
      vr_dscritic := 'TED ' || pr_idlancto || ' não encontrada!';
      CLOSE cr_tbcobran_ted;
      raise no_data_found;
      --
    END IF;
    --
    CLOSE cr_tbcobran_ted;
    
    INSERT INTO TBCOBRAN_RETORNO_IEPTB(cdcooper
                                      ,dtmvtolt
                                      ,cdcomarc
                                      ,nrseqrem
                                      ,nrseqarq
                                      ,nrdconta
                                      ,nrcnvcob
                                      ,nrdocmto
                                      ,nrremret
                                      ,nrseqreg
                                      ,cdcartorio
                                      ,nrprotoc_cartorio
                                      ,tpocorre
                                      ,dtprotocolo
                                      ,vlcuscar
                                      ,dtocorre
                                      ,cdirregu
                                      ,vlcustas_cartorio
                                      ,vlgrava_eletronica
                                      ,cdcomplem_irregular
                                      ,vldemais_despes
                                      ,vltitulo
                                      ,vlsaldo_titulo
                                      ,dsregist
                                      ,idretorno)
                                      VALUES(
                                       pr_cdcooper
                                      ,rw_tbcobran_retorno.dtmvtolt
                                      ,rw_tbcobran_retorno.cdcomarc
                                      ,rw_tbcobran_retorno.nrseqrem
                                      ,rw_tbcobran_retorno.nrseqarq
                                      ,rw_tbcobran_retorno.nrdconta
                                      ,rw_tbcobran_retorno.nrcnvcob
                                      ,rw_tbcobran_retorno.nrdocmto
                                      ,rw_tbcobran_retorno.nrremret
                                      ,rw_tbcobran_retorno.nrseqreg
                                      ,rw_tbcobran_retorno.cdcartorio
                                      ,rw_tbcobran_retorno.nrprotoc_cartorio
                                      ,89 -- Estorno
                                      ,rw_tbcobran_retorno.dtprotocolo
                                      ,rw_tbcobran_retorno.vlcuscar
                                      ,rw_tbcobran_retorno.dtocorre
                                      ,rw_tbcobran_retorno.cdirregu
                                      ,rw_tbcobran_retorno.vlcustas_cartorio
                                      ,rw_tbcobran_retorno.vlgrava_eletronica
                                      ,rw_tbcobran_retorno.cdcomplem_irregular
                                      ,rw_tbcobran_retorno.vldemais_despes
                                      ,rw_tbcobran_retorno.vltitulo
                                      ,rw_tbcobran_retorno.vlsaldo_titulo
                                      ,rw_tbcobran_retorno.dsregist
                                      ,vr_idretorno);

    -- Gero a conciliação do título    
    pc_gera_conciliacao(pr_idlancto => pr_idlancto
                       ,pr_idsretorno => pr_idretorno
                       ,pr_idconciliacao => vr_idconciliacao --RITM0013002
                       ,pr_dscritic => pr_dscritic);
                       
    COBR0011.pc_processa_estorno(pr_cdcooper => pr_cdcooper
                       ,pr_dtmvtolt => rw_tbcobran_retorno.dtmvtolt
                       ,pr_nrdconta => rw_tbcobran_retorno.nrdconta
                       ,pr_nrcnvcob => rw_tbcobran_retorno.nrcnvcob
                       ,pr_nrdocmto => rw_tbcobran_retorno.nrdocmto
                       ,pr_vllanmto => rw_tbcobran_retorno.custas
                       ,pr_dscritic => pr_dscritic);
    
    BEGIN
      --
      SELECT tpp.dsemail_cobranca
        INTO vr_emails_cobranca
        FROM tbcobran_param_protesto tpp
       WHERE tpp.cdcooper = pr_cdcooper;
      --
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Não foi possível retornar os e-mails do protesto: ' || SQLERRM;
    END;
    
    --
    IF (vr_emails_cobranca IS NULL) THEN
      vr_dscritic := 'O e-mail de cobrança ou o e-mail do IEPTB não foi configurado.';
      RAISE vr_exc_erro;      
    END IF;
    --

    --
    vr_des_assunto := 'CECRED - Estorno de TED';
    vr_conteudo := '<html><body>Custas estornadas referente ao boleto: ' ||
    '<br>Cooperativa: ' || rw_tbcobran_retorno.cdcooper ||
    '<br>Conta: ' || rw_tbcobran_retorno.nrdconta ||
    '<br>Convenio: ' || rw_tbcobran_retorno.nrcnvcob ||
    '<br>Documento: ' || rw_tbcobran_retorno.nrdocmto ||
    '<br>Devolvidos na TED ' || rw_tbcobran_ted.nrdocmto ||' no ' || ' do cartório ' || rw_tbcobran_ted.cdagenci_debitada || '</body></html>';
    vr_email_dest := vr_emails_cobranca;
    --
    
    --
    GENE0003.pc_solicita_email(pr_cdcooper        => pr_cdcooper    --> Cooperativa conectada
                              ,pr_cdprogra        => '' --> Programa conectado
                              ,pr_des_destino     => vr_email_dest --> Um ou mais detinatários separados por ';' ou ','
                              ,pr_des_assunto     => vr_des_assunto --> Assunto do e-mail
                              ,pr_des_corpo       => vr_conteudo    --> Corpo (conteudo) do e-mail
                              ,pr_des_anexo       => ''     --> Um ou mais anexos separados por ';' ou ','
                              ,pr_flg_remove_anex => 'N'            --> Remover os anexos passados
                              ,pr_flg_remete_coop => 'N'            --> Se o envio será do e-mail da Cooperativa
                              ,pr_des_nome_reply  => NULL           --> Nome para resposta ao e-mail
                              ,pr_des_email_reply => NULL           --> Endereço para resposta ao e-mail
                              ,pr_flg_enviar      => 'S'            --> Enviar o e-mail na hora
                              ,pr_flg_log_batch    => 'N'           --> Incluir inf. no log
                              ,pr_des_erro        => vr_dscritic);  --> Descricao Erro
                              
    --                          
    IF vr_dscritic IS NULL THEN
      raise vr_exc_erro;
    END IF;
    --

    pc_gera_log(pr_cdcooper
               ,NULL
               ,vr_conteudo
               ,1);
    
  END pc_estornar_ted;

  PROCEDURE pc_exp_extrado_consolidado_pdf(pr_cdcooper      IN craptab.cdcooper%TYPE   --> Cooperativa
                                          ,pr_dtinimvt      IN VARCHAR2                --> Data inicial
                                          ,pr_dtfimmvt      IN VARCHAR2                --> Data final
                                          ,pr_xmllog        IN VARCHAR2                --> XML com informações de LOG
                                          ,pr_cdcritic      OUT PLS_INTEGER            --> Código da crítica
                                          ,pr_dscritic      OUT VARCHAR2               --> Descrição da crítica
                                          ,pr_retxml        IN OUT NOCOPY xmltype      --> Arquivo de retorno do XML
                                          ,pr_nmdcampo      OUT VARCHAR2               --> Nome do Campo
                                          ,pr_des_erro      OUT VARCHAR2) IS
	/* ............................................................................

       Programa: pc_exporta_extrado_consolidado_pdf
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Fabio Stein
       Data    : Jun/2018                     Ultima atualizacao: --/--/----

       Dados referentes ao programa:

       Frequencia: Sempre que chamado
       Objetivo  : Rotina responsavel por gerar o relatorio de movimento consilidados para a contabilidade - Chamada ayllos Web

       Alteracoes: ----

    ............................................................................ */  
 
    -------------->> VARIAVEIS <<----------------
    -- Variavel de criticas
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(10000);
    vr_des_reto VARCHAR2(10);
    vr_typ_saida      VARCHAR2(3);
    
    -- Tratamento de erros
    vr_exc_erro      EXCEPTION;
    vr_exc_saida     EXCEPTION;
    vr_tab_erro GENE0001.typ_tab_erro;
    
    -- Data do movimento
    vr_dtmvtolt      crapdat.dtmvtolt%type;
    
    -- Variável para armazenar as informações em XML
    vr_des_xml       clob;
    vr_typsaida     VARCHAR2(100); 
    
    -- Variável para o caminho e nome do arquivo base
    vr_dsdireto   varchar2(200);
    vr_nmarquivo  varchar2(200);
    vr_dscomand   varchar2(200);
    
    -- Subrotina para escrever texto na variável CLOB do XML
    procedure pc_escreve_xml(pr_des_dados in clob) is
    begin
      dbms_lob.writeappend(vr_des_xml, length(pr_des_dados), pr_des_dados);
    end;
    
  BEGIN                                                  
    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'TELA_MANPRT'
                              ,pr_action => null);
    vr_des_xml := null;
    dbms_lob.createtemporary(vr_des_xml, true);
    dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
    -- Inicilizar as informações do XML
    pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?>');
    pc_escreve_xml('<composicao>');

    IF (pr_dtinimvt IS NOT NULL) THEN
       pc_escreve_xml('<dataini>' ||  pr_dtinimvt || '</dataini>');
       pc_escreve_xml('<datafim>' ||  pr_dtfimmvt || '</datafim>');
    END IF;
        
    pc_escreve_xml('<tedsnaoconciliadas>');
    FOR rw_extrato_teds_naoconc_devolv IN cr_extrato_teds_naoconc_devolv(pr_dtinimvt => pr_dtinimvt
                                                                        ,pr_dtfimmvt => pr_dtfimmvt) LOOP
      pc_escreve_xml('<ted>');
      pc_escreve_xml('<data>'     ||to_char(rw_extrato_teds_naoconc_devolv.data,'DD/MM/YYYY') ||'</data>');
      pc_escreve_xml('<historico>'     ||rw_extrato_teds_naoconc_devolv.historico ||'</historico>');
      pc_escreve_xml('<vllancamento>'     ||rw_extrato_teds_naoconc_devolv.vllancamento ||'</vllancamento>');
      pc_escreve_xml('</ted>');
    END LOOP;
    pc_escreve_xml('</tedsnaoconciliadas>'); 

    pc_escreve_xml('<custasnaorepassadas>');
    FOR rw_extrato_custas IN cr_extrato_custas(pr_dtinimvt => pr_dtinimvt
                                              ,pr_dtfimmvt => pr_dtfimmvt) LOOP
      pc_escreve_xml('<custa>');
      pc_escreve_xml('<data>'     ||to_char(rw_extrato_custas.data,'DD/MM/YYYY') ||'</data>');
      pc_escreve_xml('<historico>'     ||rw_extrato_custas.historico ||'</historico>');
      pc_escreve_xml('<vllancamento>'     ||rw_extrato_custas.vllancamento ||'</vllancamento>');
      pc_escreve_xml('</custa>');
    END LOOP;
    pc_escreve_xml('</custasnaorepassadas>'); 

    pc_escreve_xml('<tarifasnaorepassadas>');
    FOR rw_extrato_tarifas IN cr_extrato_tarifas(pr_dtinimvt => pr_dtinimvt
                                                ,pr_dtfimmvt => pr_dtfimmvt) LOOP
      pc_escreve_xml('<tarifa>');
      pc_escreve_xml('<data>'     ||to_char(rw_extrato_tarifas.data,'DD/MM/YYYY') ||'</data>');
      pc_escreve_xml('<historico>'     ||rw_extrato_tarifas.historico ||'</historico>');
      pc_escreve_xml('<vllancamento>'     ||rw_extrato_tarifas.vllancamento ||'</vllancamento>');
      pc_escreve_xml('</tarifa>');
    END LOOP;
    pc_escreve_xml('</tarifasnaorepassadas>'); 


    -- Fecha a tag principal para encerrar o XML

    pc_escreve_xml('</composicao>');
    
    --Buscar diretorio da cooperativa
    vr_dsdireto := gene0001.fn_diretorio(pr_tpdireto => 'C', --> cooper 
                                         pr_cdcooper => 3,
                                         pr_nmsubdir => '/rl');
    vr_dscomand := 'rm '||vr_dsdireto ||'/crrl742_' ||0 ||'* 2>/dev/null';
      
    --Executar o comando no unix
    GENE0001.pc_OScommand(pr_typ_comando => 'S'
                         ,pr_des_comando => vr_dscomand
                         ,pr_typ_saida   => vr_typsaida
                         ,pr_des_saida   => vr_dscritic);
    --Se ocorreu erro dar RAISE
    IF vr_typsaida = 'ERR' THEN
      vr_dscritic:= 'Nao foi possivel remover arquivos: '||vr_dscomand||'. Erro: '||vr_dscritic;
      RAISE vr_exc_erro;
    END IF;
    vr_nmarquivo := 'crrl742_'||0 || gene0002.fn_busca_time || '.pdf';
    
    --> Solicita geracao do PDF
    gene0002.pc_solicita_relato(pr_cdcooper   => pr_cdcooper
                               , pr_cdprogra  => 'MANPRT'
                               , pr_dtmvtolt  => vr_dtmvtolt
                               , pr_dsxml     => vr_des_xml
                               , pr_dsxmlnode => '/composicao'
                               , pr_dsjasper  => 'crrl742.jasper'
                               , pr_dsparams  => null
                               , pr_dsarqsaid => vr_dsdireto ||'/'||vr_nmarquivo
                               , pr_flg_gerar => 'S'
                               , pr_qtcoluna  => 132
                               , pr_cdrelato  => 742
                               , pr_sqcabrel  => 1
                               , pr_flg_impri => 'N'
                               , pr_nmformul  => ' '
                               , pr_nrcopias  => 1
                               , pr_nrvergrl  => 1
                               , pr_des_erro  => vr_dscritic);
      
    IF vr_dscritic IS NOT NULL THEN -- verifica retorno se houve erro
      RAISE vr_exc_erro; -- encerra programa
    END IF; 
    
    -- Liberando a memoria alocada pro CLOB
    dbms_lob.close(vr_des_xml);
    dbms_lob.freetemporary(vr_des_xml);
 
    --> AyllosWeb
    -- Copia contrato PDF do diretorio da cooperativa para servidor WEB
    GENE0002.pc_efetua_copia_pdf(pr_cdcooper => pr_cdcooper
                                ,pr_cdagenci => NULL
                                ,pr_nrdcaixa => NULL
                                ,pr_nmarqpdf => vr_dsdireto ||'/'||vr_nmarquivo
                                ,pr_des_reto => vr_des_reto
                                ,pr_tab_erro => vr_tab_erro);
    -- Se retornou erro
    IF NVL(vr_des_reto,'OK') <> 'OK' THEN
      IF vr_tab_erro.COUNT > 0 THEN -- verifica pl-table se existe erros          
        vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic; -- busca primeira descricao da critica
        RAISE vr_exc_erro; -- encerra programa
      END IF;
    END IF;
    
     -- Criar XML de retorno para uso na Web
     pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><nmarqpdf>' || vr_nmarquivo|| '</nmarqpdf>');

    -- Remover relatorio do diretorio padrao da cooperativa
    gene0001.pc_OScommand(pr_typ_comando => 'S'
                         ,pr_des_comando => 'rm '||vr_dsdireto ||'/'||vr_nmarquivo
                         ,pr_typ_saida   => vr_typsaida
                         ,pr_des_saida   => vr_dscritic);
    -- Se retornou erro
    IF vr_typsaida = 'ERR' OR vr_dscritic IS NOT NULL THEN
      -- Concatena o erro que veio
      vr_dscritic := 'Erro ao remover arquivo: '||vr_dscritic;
      RAISE vr_exc_erro; -- encerra programa
    END IF;                                      
                                        
  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_dscritic := 'Erro geral pc_exporta_extrado_consolidado_pdf : '||SQLERRM;  	                                                                                     
  END pc_exp_extrado_consolidado_pdf;

END TELA_MANPRT;
/
