CREATE OR REPLACE PACKAGE CECRED.TELA_SEGEMP AS

  -- Definicao de TEMP TABLE para consulta do segmento
  TYPE typ_reg_tbepr_segmento IS
    RECORD(cdpacote            tbtarif_contas_pacote.cdpacote%TYPE           --> Codigo do pacote
          ,dspacote            tbtarif_pacotes.dspacote%TYPE                 --> Descricao do pacote
          ,dtinicio_vigencia   VARCHAR2(10)                                  --> Data de início da vigencia
          ,dtadesao            VARCHAR2(10)                                  --> Data de adesao do pacote
          ,flgsituacao         VARCHAR2(10)                                  --> Situacao do pacote
          ,dtcancelamento      VARCHAR2(10)                                  --> Data de cancelamento
          ,nrdiadebito         tbtarif_contas_pacote.nrdiadebito%TYPE        --> Dia do debito
          ,perdesconto_manual  tbtarif_contas_pacote.perdesconto_manual%TYPE --> % desconto manual
          ,qtdmeses_desconto   tbtarif_contas_pacote.qtdmeses_desconto%TYPE	 --> Qtd meses desconto
          ,cdreciprocidade     VARCHAR2(10)                                  --> Possui reciprocidade
          ,dtass_eletronica    VARCHAR2(20));                                --> Data assinatura eletronica
  --        
  --/ Definicao de tipo de tabela para consulta do segmento
  TYPE typ_tab_tbepr_segmento IS
    TABLE OF typ_reg_tbepr_segmento
    INDEX BY BINARY_INTEGER;
  --
  --/
  PROCEDURE pc_monta_xml_subsegmento(pr_cdcooper IN crapcop.cdcooper%TYPE
                                    ,pr_idsegmento IN tbepr_segmento.idsegmento%TYPE
                                    ,pr_idsubsegmento IN tbepr_subsegmento.idsubsegmento%TYPE                                 
                                    ,pr_retorno OUT XMLType
                                    ,pr_dscritic OUT VARCHAR2);
  --
  --/
  PROCEDURE pc_consulta_param_segmentos (pr_idsegmento  IN NUMBER                --> id do segmento de emprestimo                                                                      
                                        ,pr_xmllog      IN VARCHAR2              --> XML com informações de LOG
                                        ,pr_cdcritic    OUT PLS_INTEGER          --> Código da crítica
                                        ,pr_dscritic    OUT VARCHAR2             --> Descrição da crítica
                                        ,pr_retxml      IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                                        ,pr_nmdcampo    OUT VARCHAR2             --> Nome do Campo
                                        ,pr_des_erro    OUT VARCHAR2);           --> Saida OK/NOK
 --/
 PROCEDURE pc_consulta_subsegmento(pr_idsegmento IN tbepr_subsegmento.idsegmento%TYPE   --> id do segmento de emprestimo                                                                      
                                   ,pr_idsubsegmento IN tbepr_subsegmento.idsubsegmento%TYPE --> 
                                   ,pr_xmllog      IN VARCHAR2             --> XML com informações de LOG
                                   ,pr_cdcritic    OUT PLS_INTEGER         --> Código da crítica
                                   ,pr_dscritic    OUT VARCHAR2            --> Descrição da crítica
                                   ,pr_retxml      IN OUT NOCOPY xmltype   --> Arquivo de retorno do XML
                                   ,pr_nmdcampo    OUT VARCHAR2            --> Nome do Campo
                                   ,pr_des_erro    OUT VARCHAR2);  
  --/
  PROCEDURE pc_editar_segmento(pr_idsegmento IN tbepr_segmento.idsegmento%TYPE --> codigo do segmento
                              ,pr_dssegmento IN tbepr_segmento.dssegmento%TYPE --> descricao do subsegmento
                              ,pr_qtsimulacoes_padrao IN tbepr_segmento.qtsimulacoes_padrao%TYPE
                              ,pr_nrvariacao_parc	IN tbepr_segmento.nrvariacao_parc%TYPE --> variação de parcelas
                              ,pr_nrmax_proposta IN	tbepr_segmento.nrmax_proposta%TYPE  --> numero máximo de propostas
                              ,pr_nrintervalo_proposta IN tbepr_segmento.nrintervalo_proposta%TYPE --> intervalo de tempo entre as propostas
                              ,pr_dssegmento_detalhada IN tbepr_segmento.dssegmento_detalhada%TYPE --> descrição detalhada do segmento de emprestimo                         
                              ,pr_qtdias_validade IN tbepr_segmento.qtdias_validade%TYPE --> quantidade de dias de validade
                              ,pr_perm_pessoa_fisica IN NUMBER   --> Sem permissao = 0/ Com permissao = 1
                              ,pr_perm_pessoa_juridica IN NUMBER --> Sem permissao = 0/ Com permissao = 1                              
                              ,pr_xmllog      IN VARCHAR2              --> XML com informações de LOG
                              ,pr_cdcritic    OUT PLS_INTEGER          --> Código da crítica
                              ,pr_dscritic    OUT VARCHAR2             --> Descrição da crítica
                              ,pr_retxml      IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                              ,pr_nmdcampo    OUT VARCHAR2             --> Nome do Campo
                              ,pr_des_erro    OUT VARCHAR2);           --> Saida OK/NOK
  --
  --/
  /* Editar subsegmentos de emprestimo */
  PROCEDURE pc_editar_Subsegmento(pr_idsegmento  IN tbepr_segmento.idsegmento%TYPE --> codigo do segmento de emprestimo
                                 ,pr_idsubsegmento  IN tbepr_subsegmento .idsubsegmento%TYPE --> codigo do segmento de emprestimo
                                 ,pr_dssubsegmento IN tbepr_subsegmento.dssubsegmento%TYPE --> descricao do subsegmento de emprestimo
                                 ,pr_cdlinha_credito IN tbepr_subsegmento.cdlinha_credito%TYPE --> codigo da linha de credito
                                 ,pr_cdfinalidade IN tbepr_subsegmento.cdfinalidade%TYPE --> Codigo da finalidade(crapfin)
                                 ,pr_flggarantia IN tbepr_subsegmento.flggarantia%TYPE --> flag para apontar se subsegmento possui garantia 1(sim) ou 0(não) 
                                 ,pr_tpgarantia IN tbepr_subsegmento.tpgarantia%TYPE --> tipo de garantia do subsegmento 0(novo) 1(usado)
                                 ,pr_pemax_autorizado IN tbepr_subsegmento.pemax_autorizado%TYPE --> percentual máximo autorizado
                                 ,pr_peexcedente IN tbepr_subsegmento .peexcedente%TYPE --> percentual excedente
                                 ,pr_vlmax_proposta IN tbepr_subsegmento.vlmax_proposta%TYPE --> valor máximo da proposta                                 
                                 ,pr_xmllog      IN VARCHAR2              --> XML com informações de LOG
                                 ,pr_cdcritic    OUT PLS_INTEGER          --> Código da crítica
                                 ,pr_dscritic    OUT VARCHAR2             --> Descrição da crítica
                                 ,pr_retxml      IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                                 ,pr_nmdcampo    OUT VARCHAR2             --> Nome do Campo
                                 ,pr_des_erro    OUT VARCHAR2);           --> Saida OK/NOK  

  --                              
  --/ Editar subsegmentos de emprestimo 
  PROCEDURE pc_editar_perm_canais(pr_idsegmento IN tbepr_segmento_canais_perm.idsegmento%TYPE --> id do segmento de emprestimo
                                 ,pr_cdcanal IN tbepr_segmento_canais_perm.cdcanal%TYPE --> codigo do canal
                                 ,pr_tppermissao IN tbepr_segmento_canais_perm.tppermissao%TYPE --> tipo de permissao
                                 ,pr_vlmax_autorizado IN tbepr_segmento_canais_perm.vlmax_autorizado%TYPE 
                                 ,pr_xmllog IN VARCHAR2             --> XML com informações de LOG
                                 ,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
                                 ,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
                                 ,pr_retxml  IN OUT NOCOPY xmltype  --> Arquivo de retorno do XML
                                 ,pr_nmdcampo OUT VARCHAR2          --> Nome do Campo
                                 ,pr_des_erro OUT VARCHAR2);        --> Saida OK/NOK   
  --
END TELA_SEGEMP;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_SEGEMP AS
  --
  ---------------------------------------------------------------------------------------------------------------
  --
  -- Programa: TELA_SEGEMP
  -- Autor   : Rafael R. Santos - Amcom
  -- Data    : Fevereiro/2019
  --
  -- Dados referentes ao programa:
  --
  -- Objetivo  : Package ref. a tela SEGEMP
  --
  -- Alteracoes:
  --
  ---------------------------------------------------------------------------------------------------------------
  --
  --/ consulta_parametros_segmento busca os dados de segmentos por cooperativa e retorna-os em formato xml
  --
  --/ Subrotina para formatar valores
  FUNCTION fn_formata_valor (pr_dsprefix    IN VARCHAR2
                            ,pr_vlrvalor    IN NUMBER
                            ,pr_dsformat    IN VARCHAR2
                            ,pr_dsdsufix    IN VARCHAR2) 
        RETURN VARCHAR2 IS
 
    vr_vlformatado VARCHAR2(100);
        
    BEGIN
      vr_vlformatado := pr_dsprefix || TRIM(TO_CHAR(pr_vlrvalor, pr_dsformat)) || pr_dsdsufix;
    
      RETURN vr_vlformatado;
  
  END fn_formata_valor; 
  --
  --/ procedure generica para auxiliar montagem de xml
  PROCEDURE insere_tag(pr_xml      IN OUT NOCOPY XMLType  --> XML que receberá a nova TAG
                      ,pr_tag_pai  IN VARCHAR2            --> TAG que receberá a nova TAG
                      ,pr_posicao  IN PLS_INTEGER         --> Posição da tag na lista
                      ,pr_tag_nova IN VARCHAR2            --> String com a nova TAG
                      ,pr_tag_cont IN VARCHAR2            --> Conteúdo da nova TAG
                      ,pr_des_erro OUT VARCHAR2) IS                       
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : insere_tag
  --  Sistema  : CREDITO
  --  Sigla    : EMPR
  --  Autor    : Rafael R. Santos (AmCom) Projeto P438 - Simulação e Contratação
  --  Data     : Fevereiro/2019
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: Sempre que for chamada
  -- Objetivo  : Rotina generica focando no apoio a criação dos XMl's
  --
  ---------------------------------------------------------------------------------------------------------------														
  BEGIN
      
      GENE0007.pc_insere_tag(pr_xml => pr_xml, 
                             pr_tag_pai => pr_tag_pai, 
                             pr_posicao => pr_posicao, 
                             pr_tag_nova => pr_tag_nova, 
                             pr_tag_cont => pr_tag_cont, 
                             pr_des_erro => pr_des_erro);
      
  EXCEPTION
    WHEN OTHERS THEN
       pr_des_erro := 'Erro pc_insere_tag: ' || SQLERRM;
  END insere_tag;
  --
  --/ consulta_parametros_segmento
  --/ busca os dados de segmentos por cooperativa e retorna-os em formato xml
  PROCEDURE monta_xml_segmento(pr_cdcooper crapcop.cdcooper%TYPE
                              ,pr_idsegmento tbepr_segmento.idsegmento%TYPE
                              ,pr_tppessoa IN NUMBER
                              ,pr_retorno OUT XMLType
                              ,pr_dscritic OUT VARCHAR2) IS
  ---------------------------------------------------------------------------------------------------------------
  --
  -- Programa : monta_xml_segmento
  -- Sistema  : CREDITO
  -- Sigla    : EMPR
  -- Autor    : Rafael R. Santos (AmCom) Projeto P438 - Simulação e Contratação
  -- Data     : Dez/2018
  -- 
  -- Dados referentes ao programa:
  --
  -- Frequencia: Sempre que for chamada
  -- Objetivo  : Rotina focando na montagem do xml de retorno, tornando o fonte principal mais legível
  --
  ---------------------------------------------------------------------------------------------------------------                            
  
   vr_contador_seg NUMBER := 0;
   vr_contador_sub NUMBER := 0;
   vr_cont_pess NUMBER := 0;
   vr_cont_canais NUMBER := 0;
  
   --/  busca as informacoes do segmento
   CURSOR cr_segmento(pc_cdcooper crapcop.cdcooper%TYPE, 
                      pc_idsegmento tbepr_segmento.idsegmento%TYPE,
                      pc_tppessoa IN NUMBER) IS
     SELECT ts.cdcooper AS cod_cooperativa
           ,ts.idsegmento AS cod_segmento
           ,ts.dssegmento AS nome_segmento
           ,ts.qtsimulacoes_padrao 
           ,ts.nrvariacao_parc AS variacao_parc
           ,ts.nrmax_proposta AS limite_max_proposta
           ,ts.nrintervalo_proposta AS intervalo_proposta
           ,ts.dssegmento_detalhada AS descricao_segmento
           ,ts.qtdias_validade           
       FROM cecred.tbepr_segmento ts
      WHERE ts.cdcooper = pc_cdcooper
        AND ts.idsegmento = nvl(pc_idsegmento,ts.idsegmento)
        ORDER BY 1,2;

   --/  busca as informacoes dos subsegmento
   CURSOR cr_subsegmentos(pr_cdcooper crapcop.cdcooper%TYPE, pr_idsegmento NUMBER) IS
      SELECT tss.cdcooper AS cod_cooperativa
            ,tss.idsubsegmento AS codigo_subsegmento
            ,tss.dssubsegmento AS nome_subsegmento
            ,tss.cdlinha_credito AS codigo_linha_credito
            ,lin_cred.dslcremp AS desc_linha_credito
            ,tss.flggarantia AS garantia
            ,tss.tpgarantia AS tipo_garantia
            ,decode(tss.tpgarantia,0,'Novo',1,'USado') desc_tipo_garantia
            ,lin_cred.NRFIMPRE quantidade_max_parcelas
            ,tss.pemax_autorizado AS percent_max_autorizado
            ,tss.vlmax_proposta AS valor_max_proposta
            ,tss.peexcedente AS percent_excedente
            ,tss.cdfinalidade
        FROM tbepr_subsegmento tss , craplcr lin_cred
       WHERE tss.cdcooper = pr_cdcooper
         AND tss.idsegmento = pr_idsegmento
         AND tss.cdlinha_credito = lin_cred.cdlcremp
         AND tss.cdcooper = lin_cred.cdcooper
         ORDER BY 1,2;
  
   --/  busca as informacoes de permissoes do segmento por tipo de pessoa
   CURSOR cr_permissoes_pessoa(pc_cdcooper crapcop.cdcooper%TYPE, pc_idsegmento NUMBER) IS
      SELECT tp_pes.tppessoa tp_pessoa
        FROM tbepr_segmento_tppessoa_perm tp_pes
       WHERE tp_pes.cdcooper = pc_cdcooper
         AND tp_pes.idsegmento = pc_idsegmento;
   
   --/  busca as informacoes de permissoes do segmento por canais de entrada
   CURSOR cr_permissoes_canais(pr_cdcooper crapcop.cdcooper%TYPE, pr_idsegmento NUMBER) IS
      SELECT tce.cdcanal,
             tce.nmcanal, 
             cns.tppermissao,             
             decode(cns.tppermissao,0,'Indisponível',1,'Simulação',2,'Contratação') desc_tppermissao,
             cns.vlmax_autorizado vlr_max_autorizado
        FROM tbepr_segmento_canais_perm cns, tbgen_canal_entrada tce
       WHERE cns.cdcooper = pr_cdcooper
         AND cns.idsegmento = pr_idsegmento
         AND cns.cdcanal = tce.cdcanal;

   FUNCTION get_dsfinemp(pr_cdcooper crapcop.cdcooper%TYPE,
                         pr_cdfinemp crapfin.cdfinemp%TYPE ) 
      RETURN crapfin.dsfinemp%TYPE IS
    vr_dsfinemp crapfin.dsfinemp%TYPE;
   BEGIN
     SELECT fin.dsfinemp
       INTO vr_dsfinemp
       FROM crapfin fin
      WHERE fin.cdcooper = pr_cdcooper
        AND fin.cdfinemp = pr_cdfinemp;
     RETURN nvl(vr_dsfinemp,NULL);
        
   EXCEPTION WHEN OTHERS
     THEN
       RETURN NULL;
   END get_dsfinemp; 

  BEGIN  
  
    pr_retorno := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Segmentos/>');
    
    --/ segmentos
    vr_contador_seg := 0;
    vr_contador_sub := 0;
    FOR rw_segmento IN cr_segmento(pr_cdcooper,pr_idsegmento,pr_tppessoa) LOOP
      -- Loop sobre a tabela de segmentos
        -- Insere o nó principal
        -- Insere os detalhes
        insere_tag(pr_xml      => pr_retorno
                  ,pr_tag_pai  => 'Segmentos'
                  ,pr_posicao  => 0
                  ,pr_tag_nova => 'Segmento'
                  ,pr_tag_cont => NULL
                  ,pr_des_erro => pr_dscritic);

        insere_tag(pr_xml      => pr_retorno
                  ,pr_tag_pai  => 'Segmento'
                  ,pr_posicao  => vr_contador_seg
                  ,pr_tag_nova => 'codigo_cooperativa'
                  ,pr_tag_cont => rw_segmento.cod_cooperativa
                  ,pr_des_erro => pr_dscritic);

        -- Codigo do Segmento
        insere_tag(pr_xml      => pr_retorno
                  ,pr_tag_pai  => 'Segmento'
                  ,pr_posicao  => vr_contador_seg
                  ,pr_tag_nova => 'codigo_segmento'
                  ,pr_tag_cont => rw_segmento.cod_segmento
                  ,pr_des_erro => pr_dscritic);
        -- Nome do Segmento
        insere_tag(pr_xml      => pr_retorno
                  ,pr_tag_pai  => 'Segmento'
                  ,pr_posicao  => vr_contador_seg
                  ,pr_tag_nova => 'nome_segmento'
                  ,pr_tag_cont => rw_segmento.nome_segmento
                  ,pr_des_erro => pr_dscritic);  

        -- Quantidade de Parcelas Padrao
        insere_tag(pr_xml      => pr_retorno
                  ,pr_tag_pai  => 'Segmento'
                  ,pr_posicao  => vr_contador_seg
                  ,pr_tag_nova => 'quantidade_padrao_simulacoes'
                  ,pr_tag_cont => rw_segmento.qtsimulacoes_padrao
                  ,pr_des_erro => pr_dscritic);
        -- Variação de Parcelas               
        insere_tag(pr_xml      => pr_retorno
                  ,pr_tag_pai  => 'Segmento'
                  ,pr_posicao  => vr_contador_seg
                  ,pr_tag_nova => 'variacao_parcelas'
                  ,pr_tag_cont => rw_segmento.variacao_parc
                  ,pr_des_erro => pr_dscritic);
        -- Limite Maximo Proposta
        insere_tag(pr_xml      => pr_retorno
                  ,pr_tag_pai  => 'Segmento'
                  ,pr_posicao  => vr_contador_seg
                  ,pr_tag_nova => 'limite_maximo_proposta'
                  ,pr_tag_cont => rw_segmento.limite_max_proposta
                  ,pr_des_erro => pr_dscritic);
       -- Intervalo Tempo Proposta
        insere_tag(pr_xml      => pr_retorno
                  ,pr_tag_pai  => 'Segmento'
                  ,pr_posicao  => vr_contador_seg
                  ,pr_tag_nova => 'intervalo_tempo_proposta'
                  ,pr_tag_cont => rw_segmento.intervalo_proposta
                  ,pr_des_erro => pr_dscritic);

        -- Descrição detalhada do Segmento
        insere_tag(pr_xml      => pr_retorno
                  ,pr_tag_pai  => 'Segmento'
                  ,pr_posicao  => vr_contador_seg
                  ,pr_tag_nova => 'descricao_segmento'
                  ,pr_tag_cont => rw_segmento.descricao_segmento
                  ,pr_des_erro => pr_dscritic);

        -- Descrição detalhada do Segmento
        insere_tag(pr_xml      => pr_retorno
                  ,pr_tag_pai  => 'Segmento'
                  ,pr_posicao  => vr_contador_seg
                  ,pr_tag_nova => 'qtdias_validade'
                  ,pr_tag_cont => rw_segmento.qtdias_validade
                  ,pr_des_erro => pr_dscritic);
             
        --/ Subsegmentos             
        --vr_contador_sub := 0;            

        -- Insere os detalhes
        insere_tag(pr_xml      => pr_retorno
                  ,pr_tag_pai  => 'Segmento'
                  ,pr_posicao  =>  vr_contador_seg
                  ,pr_tag_nova => 'Subsegmentos'
                  ,pr_tag_cont => NULL  
                  ,pr_des_erro => pr_dscritic);
             
         FOR rw_subsegmento IN cr_subsegmentos(rw_segmento.cod_cooperativa,rw_segmento.cod_segmento) LOOP
         -- Insere o nó principal
         -- Insere os detalhes
         -- Codigo do subSegmento
         --
                 insere_tag(pr_xml      => pr_retorno
                           ,pr_tag_pai  => 'Subsegmentos'
                           ,pr_posicao  =>  vr_contador_seg
                           ,pr_tag_nova => 'Subsegmento'
                           ,pr_tag_cont => NULL  
                           ,pr_des_erro => pr_dscritic);

                  insere_tag(pr_xml      => pr_retorno
                            ,pr_tag_pai  => 'Subsegmento'
                            ,pr_posicao  => vr_contador_sub
                            ,pr_tag_nova => 'codigo_subsegmento'
                            ,pr_tag_cont => rw_subsegmento.codigo_subsegmento
                            ,pr_des_erro => pr_dscritic);
                            
              -- Nome do subSegmento
                  insere_tag(pr_xml      => pr_retorno
                            ,pr_tag_pai  => 'Subsegmento'
                            ,pr_posicao  => vr_contador_sub
                            ,pr_tag_nova => 'nome_subsegmento'
                            ,pr_tag_cont => rw_subsegmento.nome_subsegmento
                            ,pr_des_erro => pr_dscritic);  

              -- Quantidade de Parcelas Padrao
                  insere_tag(pr_xml      => pr_retorno
                            ,pr_tag_pai  => 'Subsegmento'
                            ,pr_posicao  => vr_contador_sub
                            ,pr_tag_nova => 'codigo_linha_credito'
                            ,pr_tag_cont => rw_subsegmento.codigo_linha_credito
                            ,pr_des_erro => pr_dscritic);
                                          
                  insere_tag(pr_xml      => pr_retorno
                            ,pr_tag_pai  => 'Subsegmento'
                            ,pr_posicao  => vr_contador_sub
                            ,pr_tag_nova => 'descricao_linha_credito'
                            ,pr_tag_cont => rw_subsegmento.desc_linha_credito
                            ,pr_des_erro => pr_dscritic);

                  insere_tag(pr_xml      => pr_retorno
                            ,pr_tag_pai  => 'Subsegmento'
                            ,pr_posicao  => vr_contador_sub
                            ,pr_tag_nova => 'codigo_finalidade_credito'
                            ,pr_tag_cont => rw_subsegmento.cdfinalidade
                            ,pr_des_erro => pr_dscritic);

                  insere_tag(pr_xml      => pr_retorno
                            ,pr_tag_pai  => 'Subsegmento'
                            ,pr_posicao  => vr_contador_sub
                            ,pr_tag_nova => 'dsfinemp'
                            ,pr_tag_cont => get_dsfinemp(rw_subsegmento.cod_cooperativa,rw_subsegmento.cdfinalidade)
                            ,pr_des_erro => pr_dscritic);

                  insere_tag(pr_xml      => pr_retorno
                            ,pr_tag_pai  => 'Subsegmento'
                            ,pr_posicao  => vr_contador_sub
                            ,pr_tag_nova => 'garantia'
                            ,pr_tag_cont => rw_subsegmento.garantia
                            ,pr_des_erro => pr_dscritic);

                  insere_tag(pr_xml      => pr_retorno
                            ,pr_tag_pai  => 'Subsegmento'
                            ,pr_posicao  => vr_contador_sub
                            ,pr_tag_nova => 'tipo_garantia'
                            ,pr_tag_cont => rw_subsegmento.tipo_garantia
                            ,pr_des_erro => pr_dscritic);

                  insere_tag(pr_xml      => pr_retorno
                            ,pr_tag_pai  => 'Subsegmento'
                            ,pr_posicao  => vr_contador_sub
                            ,pr_tag_nova => 'desc_tipo_garantia'
                            ,pr_tag_cont => rw_subsegmento.desc_tipo_garantia
                            ,pr_des_erro => pr_dscritic);

                  insere_tag(pr_xml      => pr_retorno
                            ,pr_tag_pai  => 'Subsegmento'
                            ,pr_posicao  => vr_contador_sub
                            ,pr_tag_nova => 'quantidade_maxima_parcelas'
                            ,pr_tag_cont => rw_subsegmento.quantidade_max_parcelas
                            ,pr_des_erro => pr_dscritic);
                                     
                  insere_tag(pr_xml      => pr_retorno
                            ,pr_tag_pai  => 'Subsegmento'
                            ,pr_posicao  => vr_contador_sub
                            ,pr_tag_nova => 'percentual_maximo_autorizado'
                            ,pr_tag_cont => rw_subsegmento.percent_max_autorizado
                            ,pr_des_erro => pr_dscritic);

                  insere_tag(pr_xml      => pr_retorno
                            ,pr_tag_pai  => 'Subsegmento'
                            ,pr_posicao  => vr_contador_sub
                            ,pr_tag_nova => 'valor_maximo_proposta'
                            ,pr_tag_cont => to_char(rw_subsegmento.valor_max_proposta,'fm999g999g990d00','NLS_NUMERIC_CHARACTERS='',.''')
                            ,pr_des_erro => pr_dscritic);
                            
                  insere_tag(pr_xml      => pr_retorno
                            ,pr_tag_pai  => 'Subsegmento'
                            ,pr_posicao  => vr_contador_sub
                            ,pr_tag_nova => 'percentual_excedente'
                            ,pr_tag_cont => rw_subsegmento.percent_excedente
                            ,pr_des_erro => pr_dscritic);
                                     
                 vr_contador_sub := vr_contador_sub + 1;

         END LOOP rw_subsegmento;     
         
         --/ Permissao tipo pessoa             
         insere_tag(pr_xml      => pr_retorno
                   ,pr_tag_pai  => 'Segmento'
                   ,pr_posicao  =>  vr_contador_seg
                   ,pr_tag_nova => 'Permissoes'
                   ,pr_tag_cont => NULL
                   ,pr_des_erro => pr_dscritic);
            
         FOR rw_perm_pessoa IN cr_permissoes_pessoa(rw_segmento.cod_cooperativa,rw_segmento.cod_segmento) LOOP
                
            insere_tag(pr_xml      => pr_retorno
                      ,pr_tag_pai  => 'Permissoes'
                      ,pr_posicao  => vr_contador_seg
                      ,pr_tag_nova => 'permissao_tipo_pessoa'
                      ,pr_tag_cont => NULL
                      ,pr_des_erro => pr_dscritic);

            insere_tag(pr_xml      => pr_retorno
                      ,pr_tag_pai  => 'permissao_tipo_pessoa'
                      ,pr_posicao  => vr_cont_pess
                      ,pr_tag_nova => 'codigo_tipo_pessoa'
                      ,pr_tag_cont => rw_perm_pessoa.tp_pessoa
                      ,pr_des_erro => pr_dscritic);          
           
            vr_cont_pess := vr_cont_pess + 1;                          
          
         END LOOP rw_perm_pessoa;                       

         --/ Permissao canais
         insere_tag(pr_xml      => pr_retorno
                   ,pr_tag_pai  => 'Permissoes'
                   ,pr_posicao  => vr_contador_seg
                   ,pr_tag_nova => 'Canais'
                   ,pr_tag_cont => NULL
                   ,pr_des_erro => pr_dscritic);

         FOR vr_cont_perm_canais IN cr_permissoes_canais(rw_segmento.cod_cooperativa,rw_segmento.cod_segmento) LOOP

              insere_tag(pr_xml      => pr_retorno
                        ,pr_tag_pai  => 'Canais'
                        ,pr_posicao  =>  vr_contador_seg
                        ,pr_tag_nova => 'canal'
                        ,pr_tag_cont => NULL  
                        ,pr_des_erro => pr_dscritic);

              insere_tag(pr_xml      => pr_retorno
                        ,pr_tag_pai  => 'canal'
                        ,pr_posicao  => vr_cont_canais
                        ,pr_tag_nova => 'codigo_canal'
                        ,pr_tag_cont => vr_cont_perm_canais.cdcanal
                        ,pr_des_erro => pr_dscritic);
                
              insere_tag(pr_xml      => pr_retorno
                        ,pr_tag_pai  => 'canal'
                        ,pr_posicao  => vr_cont_canais
                        ,pr_tag_nova => 'descricao_canal'
                        ,pr_tag_cont => vr_cont_perm_canais.nmcanal
                        ,pr_des_erro => pr_dscritic);

              insere_tag(pr_xml      => pr_retorno
                        ,pr_tag_pai  => 'canal'
                        ,pr_posicao  => vr_cont_canais
                        ,pr_tag_nova => 'tipo_permissao'
                        ,pr_tag_cont => vr_cont_perm_canais.tppermissao
                        ,pr_des_erro => pr_dscritic);

              insere_tag(pr_xml      => pr_retorno
                        ,pr_tag_pai  => 'canal'
                        ,pr_posicao  => vr_cont_canais
                        ,pr_tag_nova => 'desc_tipo_permissao'
                        ,pr_tag_cont => vr_cont_perm_canais.desc_tppermissao
                        ,pr_des_erro => pr_dscritic);

              insere_tag(pr_xml      => pr_retorno
                        ,pr_tag_pai  => 'canal'
                        ,pr_posicao  => vr_cont_canais
                        ,pr_tag_nova => 'valor_max_autorizado'
                        ,pr_tag_cont => to_char(vr_cont_perm_canais.vlr_max_autorizado,'fm999g999g990d00','NLS_NUMERIC_CHARACTERS='',.''')
                        ,pr_des_erro => pr_dscritic);

          vr_cont_canais := vr_cont_canais + 1;                          
          
         END LOOP rw_perm_pessoa;                       
         
        vr_contador_seg := vr_contador_seg + 1;

     END LOOP rw_segmento;     
     
     -- Se não encontrou nenhum registro
     IF vr_contador_seg = 0 THEN
       -- Gerar crítica
       pr_dscritic   := 'Não encontrado segmento cadastrado com os parâmetros informados!';
     END IF;
     
   END monta_xml_segmento;    
  --  
  --/
  PROCEDURE pc_retorna_param_segmentos (pr_cdcooper IN NUMBER,
                                        pr_idsegmento IN NUMBER,
                                        pr_tppessoa IN INTEGER,
                                        pr_retorno OUT xmltype,
                                        pr_des_reto OUT VARCHAR2)
  IS                                        
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : consulta_parametros_segmento
  --  Sistema  : CREDITO
  --  Sigla    : EMPR
  --  Autor    : Rafael R. Santos (AmCom) Projeto P438 - Simulação e Contratação
  --  Data     : Dez/2018
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: Sempre que for chamada
  -- Objetivo  : Fornecer Parametros para configurar segmentos de crédito
  --
  ---------------------------------------------------------------------------------------------------------------														

  vr_exc_erro EXCEPTION;
  vr_dscritic VARCHAR2(4000);
  vr_xml      xmltype;
  vr_exc_param EXCEPTION;
  
  BEGIN
  
    vr_xml := NULL;
    --/   
   monta_xml_segmento(pr_cdcooper,
                      pr_idsegmento,
                      pr_tppessoa,
                      vr_xml,
                      vr_dscritic);
    --/ 
   IF NOT (vr_dscritic IS NULL) THEN
      
      RAISE vr_exc_erro;
      
   END IF;

   pr_des_reto    := 'OK';
   pr_retorno     := vr_xml;
  
  EXCEPTION
      
    WHEN vr_exc_erro THEN
      pr_des_reto := 'NOK';      
      pr_retorno := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                      '<Root><Erro>' || vr_dscritic ||
                                      '</Erro></Root>');
    WHEN OTHERS THEN
      pr_des_reto := 'NOK';
      pr_retorno := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                      '<Root><Erro>' ||'erro na pc_consulta_param_segmentos: '|| SQLERRM ||
                                      '</Erro></Root>');      
  END pc_retorna_param_segmentos;
  --
  --/ monta o xml de retorno com os dados do subsegmento
  PROCEDURE pc_monta_xml_subsegmento(pr_cdcooper IN crapcop.cdcooper%TYPE
                                    ,pr_idsegmento IN tbepr_segmento.idsegmento%TYPE
                                    ,pr_idsubsegmento IN tbepr_subsegmento.idsubsegmento%TYPE                                 
                                    ,pr_retorno OUT XMLType
                                    ,pr_dscritic OUT VARCHAR2) IS
  ---------------------------------------------------------------------------------------------------------------
  --
  -- Programa : monta_xml_segmento
  -- Sistema  : CREDITO
  -- Sigla    : EMPR
  -- Autor    : Rafael R. Santos (AmCom) Projeto P438 - Simulação e Contratação
  -- Data     : Fevereiro/2019
  -- 
  -- Dados referentes ao programa:
  --
  -- Frequencia: Sempre que for chamada
  -- Objetivo  : Rotina focando na montagem do xml de retorno, tornando o fonte principal mais legível
  --
  ---------------------------------------------------------------------------------------------------------------                            
  
   vr_contador_seg NUMBER := 0;
   vr_contador_sub NUMBER := 0;
   --
   --/  busca as informacoes dos subsegmento
   CURSOR cr_subsegmentos(pr_cdcooper crapcop.cdcooper%TYPE,
                          pr_idsegmento NUMBER,
                          pr_idsubsegmento NUMBER) IS
      SELECT tss.cdcooper 
            ,tss.idsegmento 
            ,tss.idsubsegmento 
            ,tss.dssubsegmento 
            ,tss.cdlinha_credito
            ,lin_cred.dslcremp AS desc_linha_credito
            ,tss.flggarantia 
            ,tss.tpgarantia 
            ,decode(tss.tpgarantia,0,'Novo',1,'USado') desc_tipo_garantia
            ,lin_cred.NRFIMPRE quantidade_max_parcelas
            ,tss.pemax_autorizado
            ,tss.vlmax_proposta
            ,tss.peexcedente
            ,tss.cdfinalidade
        FROM tbepr_subsegmento tss , craplcr lin_cred
       WHERE tss.cdcooper = pr_cdcooper
         AND tss.idsegmento = pr_idsegmento
         AND tss.idsubsegmento = pr_idsubsegmento
         AND tss.cdlinha_credito = lin_cred.cdlcremp
         AND tss.cdcooper = lin_cred.cdcooper
         ORDER BY 1,2;
   --
   FUNCTION ge_dsfinemp(pr_cdcooper crapfin.cdcooper%TYPE,
                        pr_cdfinemp crapfin.cdfinemp%TYPE) RETURN crapfin.dsfinemp%TYPE IS
   vr_dsfinemp crapfin.dsfinemp%TYPE;
   BEGIN
     SELECT fin.dsfinemp
       INTO vr_dsfinemp
       FROM crapfin fin
      WHERE fin.cdfinemp = pr_cdfinemp
        AND fin.cdcooper = pr_cdcooper ;
     RETURN vr_dsfinemp;
   EXCEPTION WHEN OTHERS
     THEN
       RETURN NULL;  
   END ge_dsfinemp;
   
   --/
  BEGIN  
    --
    pr_retorno := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
    --
    --/ segmentos
    vr_contador_seg := 0;
    vr_contador_sub := 0;
    --
    --/ Subsegmentos
    insere_tag(pr_xml      => pr_retorno
              ,pr_tag_pai  => 'Dados'
              ,pr_posicao  =>  vr_contador_seg
              ,pr_tag_nova => 'Subsegmento'
              ,pr_tag_cont => NULL  
              ,pr_des_erro => pr_dscritic);
     --
     FOR rw_subsegmento IN cr_subsegmentos(pr_cdcooper,pr_idsegmento,pr_idsubsegmento) LOOP
            --
            insere_tag(pr_xml      => pr_retorno
                      ,pr_tag_pai  => 'Subsegmento'
                      ,pr_posicao  => vr_contador_sub
                      ,pr_tag_nova => 'cdcooper'
                      ,pr_tag_cont => rw_subsegmento.cdcooper
                      ,pr_des_erro => pr_dscritic);

            insere_tag(pr_xml      => pr_retorno
                      ,pr_tag_pai  => 'Subsegmento'
                      ,pr_posicao  => vr_contador_sub
                      ,pr_tag_nova => 'idsegmento'
                      ,pr_tag_cont => rw_subsegmento.idsegmento
                      ,pr_des_erro => pr_dscritic);

            insere_tag(pr_xml      => pr_retorno
                      ,pr_tag_pai  => 'Subsegmento'
                      ,pr_posicao  => vr_contador_sub
                      ,pr_tag_nova => 'idsubsegmento'
                      ,pr_tag_cont => rw_subsegmento.idsubsegmento
                      ,pr_des_erro => pr_dscritic);
            --
            --/ Nome do subSegmento
            insere_tag(pr_xml      => pr_retorno
                      ,pr_tag_pai  => 'Subsegmento'
                      ,pr_posicao  => vr_contador_sub
                      ,pr_tag_nova => 'dssubsegmento'
                      ,pr_tag_cont => rw_subsegmento.dssubsegmento
                      ,pr_des_erro => pr_dscritic);  

            -- Quantidade de Parcelas Padrao
            insere_tag(pr_xml      => pr_retorno
                      ,pr_tag_pai  => 'Subsegmento'
                      ,pr_posicao  => vr_contador_sub
                      ,pr_tag_nova => 'cdlinha_credito'
                      ,pr_tag_cont => rw_subsegmento.cdlinha_credito
                      ,pr_des_erro => pr_dscritic);
            --/
            insere_tag(pr_xml      => pr_retorno
                      ,pr_tag_pai  => 'Subsegmento'
                      ,pr_posicao  => vr_contador_sub
                      ,pr_tag_nova => 'descricao_linha_credito'
                      ,pr_tag_cont => rw_subsegmento.desc_linha_credito
                      ,pr_des_erro => pr_dscritic);
            --/
            insere_tag(pr_xml      => pr_retorno
                      ,pr_tag_pai  => 'Subsegmento'
                      ,pr_posicao  => vr_contador_sub
                      ,pr_tag_nova => 'codigo_finalidade_credito'
                      ,pr_tag_cont => rw_subsegmento.cdfinalidade
                      ,pr_des_erro => pr_dscritic);
            --/
            insere_tag(pr_xml      => pr_retorno
                      ,pr_tag_pai  => 'Subsegmento'
                      ,pr_posicao  => vr_contador_sub
                      ,pr_tag_nova => 'dsfinemp'
                      ,pr_tag_cont => ge_dsfinemp(rw_subsegmento.cdcooper,rw_subsegmento.cdfinalidade)
                      ,pr_des_erro => pr_dscritic);
            --/
            insere_tag(pr_xml      => pr_retorno
                      ,pr_tag_pai  => 'Subsegmento'
                      ,pr_posicao  => vr_contador_sub
                      ,pr_tag_nova => 'flggarantia'
                      ,pr_tag_cont => rw_subsegmento.flggarantia
                      ,pr_des_erro => pr_dscritic);
            --/
            insere_tag(pr_xml      => pr_retorno
                      ,pr_tag_pai  => 'Subsegmento'
                      ,pr_posicao  => vr_contador_sub
                      ,pr_tag_nova => 'tpgarantia'
                      ,pr_tag_cont => rw_subsegmento.tpgarantia
                      ,pr_des_erro => pr_dscritic);
            --/
            insere_tag(pr_xml      => pr_retorno
                      ,pr_tag_pai  => 'Subsegmento'
                      ,pr_posicao  => vr_contador_sub
                      ,pr_tag_nova => 'desc_tipo_garantia'
                      ,pr_tag_cont => rw_subsegmento.desc_tipo_garantia
                      ,pr_des_erro => pr_dscritic);
            --/
            insere_tag(pr_xml      => pr_retorno
                      ,pr_tag_pai  => 'Subsegmento'
                      ,pr_posicao  => vr_contador_sub
                      ,pr_tag_nova => 'quantidade_maxima_parcelas'
                      ,pr_tag_cont => rw_subsegmento.quantidade_max_parcelas
                      ,pr_des_erro => pr_dscritic);
            --/                                     
            insere_tag(pr_xml      => pr_retorno
                      ,pr_tag_pai  => 'Subsegmento'
                      ,pr_posicao  => vr_contador_sub
                      ,pr_tag_nova => 'pemax_autorizado'
                      ,pr_tag_cont => to_char(rw_subsegmento.pemax_autorizado,'fm999g999g990d00','NLS_NUMERIC_CHARACTERS='',.''')
                      ,pr_des_erro => pr_dscritic);

            --/
            insere_tag(pr_xml      => pr_retorno
                      ,pr_tag_pai  => 'Subsegmento'
                      ,pr_posicao  => vr_contador_sub
                      ,pr_tag_nova => 'vlmax_proposta'
                      ,pr_tag_cont => to_char(rw_subsegmento.vlmax_proposta,'fm999g999g990d00','NLS_NUMERIC_CHARACTERS='',.''')
                      ,pr_des_erro => pr_dscritic);
            --/
            insere_tag(pr_xml      => pr_retorno
                      ,pr_tag_pai  => 'Subsegmento'
                      ,pr_posicao  => vr_contador_sub
                      ,pr_tag_nova => 'peexcedente'
                      ,pr_tag_cont => to_char(rw_subsegmento.peexcedente,'fm999g999g990d00','NLS_NUMERIC_CHARACTERS='',.''')
                      ,pr_des_erro => pr_dscritic);
           --/               
           vr_contador_sub := vr_contador_sub + 1;

         END LOOP rw_subsegmento;     
     
   END pc_monta_xml_subsegmento;    
  --
  --/ consultar segmentos de emprestimo 
  PROCEDURE pc_consulta_param_segmentos (pr_idsegmento  IN NUMBER               --> id do segmento de emprestimo                                                                      
                                        ,pr_xmllog      IN VARCHAR2             --> XML com informações de LOG
                                        ,pr_cdcritic    OUT PLS_INTEGER         --> Código da crítica
                                        ,pr_dscritic    OUT VARCHAR2            --> Descrição da crítica
                                        ,pr_retxml      IN OUT NOCOPY xmltype   --> Arquivo de retorno do XML
                                        ,pr_nmdcampo    OUT VARCHAR2            --> Nome do Campo
                                        ,pr_des_erro    OUT VARCHAR2) IS        --> Saida OK/NOK
    --
    --
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : consulta_parametros_segmento
    --  Sistema  : CREDITO
    --  Sigla    : EMPR
    --  Autor    : Rafael R. Santos (AmCom) Projeto P438 - Simulação e Contratação
    --  Data     : Fevereiro/2019
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: Sempre que for chamada
    -- Objetivo  : Fornecer Parametros para configurar segmentos de crédito
    --
    ---------------------------------------------------------------------------------------------------------------                            
    --
    -- VARIAVEIS ---
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;        
    vr_des_reto VARCHAR2(10);
    vr_tppessoa tbepr_segmento_tppessoa_perm.tppessoa%TYPE;
    -- Variaveis de log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);   
    vr_dscritic_param VARCHAR2(4000);   
    vr_exc_param EXCEPTION; 
    --
    --Controle de erro
    vr_exc_erro EXCEPTION;
    --
    FUNCTION permissao_cooperativa(pr_cdcooper IN tbepr_segmento_tppessoa_perm.cdcooper%TYPE
                                  ,pr_idsegmento tbepr_segmento_tppessoa_perm.idsegmento%TYPE)
      RETURN tbepr_segmento_tppessoa_perm.tppessoa%TYPE IS
    --/
    vr_tppessoa tbepr_segmento_tppessoa_perm.tppessoa%TYPE;
    --/
    BEGIN
    --/      
     FOR rw IN (SELECT perm.tppessoa                  
                  FROM tbepr_segmento_tppessoa_perm perm
                 WHERE perm.cdcooper = pr_cdcooper
                   AND perm.idsegmento = pr_idsegmento
                 ORDER BY 1  
                 )
     LOOP
        vr_tppessoa := rw.tppessoa;
        EXIT WHEN NOT ( TRIM(vr_tppessoa) IS NULL );
     END LOOP;              
     --/   
     RETURN ( nvl(vr_tppessoa,NULL) );
    --/
    END permissao_cooperativa;
    --/
    FUNCTION valida_param RETURN BOOLEAN IS
    BEGIN
     --/
     IF vr_cdcooper IS NULL
       THEN
         vr_dscritic_param := 'Cooperativa invalida';
         RETURN FALSE;
         
     ELSIF pr_idsegmento IS NULL
       THEN
         vr_dscritic_param := 'Segmento invalido';
         RETURN FALSE;         

     END IF;
     --/  
     RETURN TRUE;

    END valida_param;
    
  BEGIN
    --
    -- Recupera dados de log para consulta posterior
    --/
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);
    --
    --/ faz consistencia dos parametros    
    IF NOT(valida_param) THEN

       RAISE vr_exc_param;
              
    END IF;
    --
    -- Verifica se houve erro recuperando informacoes de log
    --
    IF NOT ( vr_dscritic IS NULL )
      THEN
        RAISE vr_exc_erro;
    END IF;
    --
    --/
    vr_tppessoa := permissao_cooperativa(vr_cdcooper,pr_idsegmento);
    --/
/*    IF ( vr_tppessoa IS NULL )
      THEN
         vr_dscritic := 'Permissoes do segmento nao cadastradas';
         RAISE vr_exc_erro;
    END IF;
*/    --
    --/ chama sub-rotina que retorna os dados em formato XM
     pc_retorna_param_segmentos(pr_cdcooper => vr_cdcooper,
                                pr_idsegmento => pr_idsegmento,
                                pr_tppessoa => vr_tppessoa,
                                pr_retorno => pr_retxml,
                                pr_des_reto => vr_des_reto);
    --/
    IF nvl(vr_des_reto, 'NOK') = 'NOK' THEN
      vr_dscritic := 'Segmento inexistente.'; 
      RAISE vr_exc_erro;
    END IF;
    pr_des_erro := 'OK';
    --
  EXCEPTION

    WHEN vr_exc_param THEN
      pr_des_erro := 'NOK';
      pr_retxml   := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                      '<Root><Erro>' || vr_dscritic_param ||

                                      '</Erro></Root>');
  
   WHEN vr_exc_erro
     THEN
      pr_des_erro := 'NOK';
      pr_dscritic := vr_dscritic;
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || vr_dscritic ||
                                     '</Erro></Root>');
   WHEN OTHERS
     THEN     
      pr_des_erro := 'NOK';  
      pr_dscritic := 'Erro não tratado na tela_segemp.consulta_parametros_segmento: ' || SQLERRM;
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || 'Erro nao tratado na tela_segemp.consulta_parametros_segmento: ' || SQLERRM ||
                                     '</Erro></Root>');
  END pc_consulta_param_segmentos;
  --
  --/ consultar subsegmento de emprestimo
  PROCEDURE pc_consulta_subsegmento(pr_idsegmento IN tbepr_subsegmento.idsegmento%TYPE   --> id do segmento de emprestimo                                                                      
                                   ,pr_idsubsegmento IN tbepr_subsegmento.idsubsegmento%TYPE --> 
                                   ,pr_xmllog      IN VARCHAR2             --> XML com informações de LOG
                                   ,pr_cdcritic    OUT PLS_INTEGER         --> Código da crítica
                                   ,pr_dscritic    OUT VARCHAR2            --> Descrição da crítica
                                   ,pr_retxml      IN OUT NOCOPY xmltype   --> Arquivo de retorno do XML
                                   ,pr_nmdcampo    OUT VARCHAR2            --> Nome do Campo
                                   ,pr_des_erro    OUT VARCHAR2) IS        --> Saida OK/NOK
    -- VARIAVEIS ---
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;
    vr_dstransa VARCHAR2(1000);
    vr_nrdrowid ROWID;
    vr_des_reto VARCHAR2(10);
    vr_tppessoa tbepr_segmento_tppessoa_perm.tppessoa%TYPE;
    vr_xml xmltype;
    -- Variaveis de log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);   
    --
    --Controle de erro
    vr_exc_erro EXCEPTION;
    --    
    FUNCTION get_dsfinemp(pr_cdcooper crapcop.cdcooper%TYPE,
                           pr_cdfinemp crapfin.cdfinemp%TYPE ) 
        RETURN crapfin.dsfinemp%TYPE IS
      vr_dsfinemp crapfin.dsfinemp%TYPE;
     BEGIN
       SELECT fin.dsfinemp
         INTO vr_dsfinemp
         FROM crapfin fin
        WHERE fin.cdcooper = pr_cdcooper
          AND fin.cdfinemp = pr_cdfinemp;
       RETURN nvl(vr_dsfinemp,NULL);
          
     EXCEPTION WHEN OTHERS
       THEN
         RETURN NULL;
    END get_dsfinemp; 
    
  BEGIN
    --
    -- Recupera dados de log para consulta posterior
    --/
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);
    --
    --/ Verifica se houve erro recuperando informacoes de log
    IF NOT ( vr_dscritic IS NULL )
      THEN
        RAISE vr_exc_erro;
    END IF;
    --/
    pc_monta_xml_subsegmento(vr_cdcooper,
                             pr_idsegmento,
                             pr_idsubsegmento,
                             vr_xml,
                             vr_dscritic);
    --/ 
    IF NOT (vr_dscritic IS NULL) THEN
    --
      RAISE vr_exc_erro;
    --  
    END IF;
    --/
    pr_des_erro := 'OK';
    pr_retxml   := vr_xml;
    --/
  EXCEPTION
    WHEN vr_exc_erro
      THEN
        pr_des_erro := 'NOK';        
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || vr_dscritic ||
                                       '</Erro></Root>');
    WHEN OTHERS
      THEN  
        pr_des_erro := 'NOK';            
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || 'Erro não tratado na tela_segemp.consulta_subsegmento: ' || SQLERRM ||
                                       '</Erro></Root>');
  END pc_consulta_subsegmento;
  --
  --/ Editar segmentos de emprestimo 
  PROCEDURE pc_editar_segmento(pr_idsegmento IN tbepr_segmento.idsegmento%TYPE --> codigo do segmento
                              ,pr_dssegmento IN tbepr_segmento.dssegmento%TYPE --> descricao do subsegmento
                              ,pr_qtsimulacoes_padrao IN tbepr_segmento.qtsimulacoes_padrao%TYPE
                              ,pr_nrvariacao_parc	IN tbepr_segmento.nrvariacao_parc%TYPE --> variação de parcelas
                              ,pr_nrmax_proposta IN	tbepr_segmento.nrmax_proposta%TYPE  --> numero máximo de propostas
                              ,pr_nrintervalo_proposta IN tbepr_segmento.nrintervalo_proposta%TYPE --> intervalo de tempo entre as propostas
                              ,pr_dssegmento_detalhada IN tbepr_segmento.dssegmento_detalhada%TYPE --> descrição detalhada do segmento de emprestimo                         
                              ,pr_qtdias_validade IN tbepr_segmento.qtdias_validade%TYPE --> quantidade de dias de validade
                              ,pr_perm_pessoa_fisica IN NUMBER   --> Sem permissao = 0/ Com permissao = 1
                              ,pr_perm_pessoa_juridica IN NUMBER --> Sem permissao = 0/ Com permissao = 1                              
                              ,pr_xmllog      IN VARCHAR2              --> XML com informações de LOG
                              ,pr_cdcritic    OUT PLS_INTEGER          --> Código da crítica
                              ,pr_dscritic    OUT VARCHAR2             --> Descrição da crítica
                              ,pr_retxml      IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                              ,pr_nmdcampo    OUT VARCHAR2             --> Nome do Campo
                              ,pr_des_erro    OUT VARCHAR2) IS         --> Saida OK/NOK
    /* .............................................................................
    Programa: pc_editar_segmento
    Sistema : Credito - Cooperativa de Credito
    Sigla   : 
    Autor   : AmCom
    Data    : Fevereiro/2019                       Ultima atualizacao: 
    --
    Dados referentes ao programa:
    --
    Frequencia: Sempre que for chamado
    Objetivo  : Alterar dados de segmento - tbepr_segmento
    --
    Alteracoes: 
    ............................................................................. */
    --/ 
    CURSOR cr_tbepr_segmento(pr_idsegmento IN tbepr_segmento.idsegmento%TYPE
                            ,pr_cdcooper IN tbepr_segmento.cdcooper%TYPE ) IS
      SELECT cdcooper,
             idsegmento,
             dssegmento,
             qtsimulacoes_padrao,
             nrvariacao_parc,
             nrmax_proposta,
             nrintervalo_proposta,
             dssegmento_detalhada,
             qtdias_validade
        FROM tbepr_segmento
       WHERE idsegmento = pr_idsegmento
         AND cdcooper = pr_cdcooper;
    --/
    --
    -- VARIAVEIS ---
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;
    vr_dstransa  VARCHAR2(1000);
    vr_nrdrowid  ROWID;
    --
    vrow_tbepr_segmento_old cr_tbepr_segmento%ROWTYPE;
    vrow_tbepr_segmento_new cr_tbepr_segmento%ROWTYPE;    
    -- Variaveis de log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    --
    -- Controle de erro
    --
    vr_exc_erro EXCEPTION;
    --/ verifica se existe o segmento informado no cadastro
    FUNCTION existe_segmento(pr_cdcooper IN tbepr_segmento.cdcooper%TYPE,
                             pr_idsegmento IN tbepr_segmento.idsegmento%TYPE ) RETURN BOOLEAN IS
    vcount NUMBER :=0;
    BEGIN
     SELECT COUNT(*)
       INTO vcount
       FROM tbepr_segmento
      WHERE idsegmento = pr_idsegmento
        AND cdcooper = pr_cdcooper;
        RETURN ( vcount > 0 );
    END existe_segmento; 
    --    
    --/ validações diversas dos parametros da procedure
    FUNCTION valida_param(pr_cdcooper IN tbepr_segmento.cdcooper%TYPE,
                          pr_idsegmento IN tbepr_segmento.idsegmento%TYPE,
                          pr_dssegmento IN tbepr_segmento.dssegmento%TYPE) RETURN BOOLEAN IS
     BEGIN
       --/
       IF NOT existe_segmento(pr_cdcooper,pr_idsegmento)
         THEN
           vr_dscritic := 'Segmento nao cadastrado';
           RETURN FALSE;
       END IF;
       
       IF ( TRIM(pr_dssegmento) IS NULL )
         THEN
           vr_dscritic := 'Descrição inválida para o segmento';
           RETURN FALSE;
       END IF;           
       
      RETURN TRUE;       
    END valida_param;
    --
    --/ procedue que efetua o update na tabela de segmento 
    PROCEDURE pc_editar(pr_tbepr_segmento IN cr_tbepr_segmento%ROWTYPE) IS
        BEGIN 
          --/
          BEGIN
              UPDATE tbepr_segmento
                 SET dssegmento = pr_tbepr_segmento.dssegmento,
                     qtsimulacoes_padrao = pr_tbepr_segmento.qtsimulacoes_padrao,
                     nrvariacao_parc = pr_tbepr_segmento.nrvariacao_parc,
                     nrmax_proposta = pr_tbepr_segmento.nrmax_proposta,
                     nrintervalo_proposta = pr_tbepr_segmento.nrintervalo_proposta,
                     dssegmento_detalhada = pr_tbepr_segmento.dssegmento_detalhada,
                     qtdias_validade = pr_tbepr_segmento.qtdias_validade                     
               WHERE cdcooper = pr_tbepr_segmento.cdcooper
                 AND idsegmento = pr_tbepr_segmento.idsegmento;
        
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao alterar o segmento de emprestimo - ' ||
                           SQLERRM;
            RAISE vr_exc_erro;
        END;
        -- Gerar informacoes do log
       /* GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => ' '
                            ,pr_dsorigem => GENE0001.vr_vet_des_origens(vr_idorigem)
                            ,pr_dstransa => vr_dstransa
                            ,pr_dttransa => TRUNC(SYSDATE)
                            ,pr_flgtrans => 1 --> TRUE
                            ,pr_hrtransa => GENE0002.fn_busca_time
                            ,pr_idseqttl => 1
                            ,pr_nmdatela => 'ATENDA'
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrdrowid => vr_nrdrowid);*/
      END pc_editar;      
    --
    --/ procedure que efetua o update nas permissoes por tipo de pessoa (fisica/juridica)
    PROCEDURE pc_editar_pessoa(pr_cdcooper IN tbepr_segmento_tppessoa_perm.cdcooper%TYPE -- codigo da cooperativa
                              ,pr_idsegmento IN tbepr_segmento_tppessoa_perm.idsegmento%TYPE -- id do segmento de emprestimo
                              ,pr_perm_pessoa_fisica IN NUMBER -- Sem permissao = 0/ Com permissao = 1
                              ,pr_perm_pessoa_juridica IN NUMBER -- Sem permissao = 0/ Com permissao = 1
                              ,pr_dscritic OUT crapcri.dscritic%TYPE) IS
    --/
    c_tppessoa_fisica CONSTANT NUMBER := 1; -- 1(pessoa fisica)
    c_tppessoa_juridica CONSTANT NUMBER := 2; -- 2(pessoa jurídica)
    --
    --/
    PROCEDURE pc_grant(pr_cdcooper IN tbepr_segmento_tppessoa_perm.cdcooper%TYPE
                       ,pr_idsegmento IN tbepr_segmento_tppessoa_perm.idsegmento%TYPE
                       ,pr_tppessoa tbepr_segmento_tppessoa_perm.tppessoa%TYPE ) IS
    BEGIN
       --/
       INSERT INTO tbepr_segmento_tppessoa_perm
                   (cdcooper, 
                    idsegmento, 
                    tppessoa)
           VALUES  (pr_cdcooper,
                    pr_idsegmento,
                    pr_tppessoa);
    EXCEPTION 
      WHEN dup_val_on_index
       THEN 
         NULL; -- se tem a permissao cadastrada ok, sem problema
      WHEN OTHERS
        THEN   
         pr_dscritic := 'Erro permissoes tipo pessoa (1) - '|| SQLERRM ;
    END pc_grant;
    --
    --/   
    PROCEDURE pc_revoke(pr_cdcooper IN tbepr_segmento_tppessoa_perm.cdcooper%TYPE
                        ,pr_idsegmento IN tbepr_segmento_tppessoa_perm.idsegmento%TYPE
                        ,pr_tppessoa tbepr_segmento_tppessoa_perm.tppessoa%TYPE ) IS
    BEGIN
      --/
      DELETE tbepr_segmento_tppessoa_perm
       WHERE cdcooper = pr_cdcooper
         AND idsegmento = pr_idsegmento
         AND tppessoa = pr_tppessoa;
     --/        
    EXCEPTION WHEN OTHERS
      THEN     
       pr_dscritic := 'Erro permissoes tipo pessoa (2) - ' ||SQLERRM ;
    END pc_revoke;
    --   
    --
   BEGIN
      --
      --/ Pessoa Fisica
      IF pr_perm_pessoa_fisica = 1 -- conceder permissao pessoa fisica
        THEN
          --/
          pc_grant(pr_cdcooper,pr_idsegmento,c_tppessoa_fisica);
          
      ELSIF pr_perm_pessoa_fisica = 0 -- retirar permissao pessoa fisica
        THEN
          --/
          pc_revoke(pr_cdcooper,pr_idsegmento,c_tppessoa_fisica);        
          
      END IF;
      --
      --/ Pessoa juridica
      IF pr_perm_pessoa_juridica = 1 -- conceder permissao pessoa juridica
        THEN
          --/        
          pc_grant(pr_cdcooper,pr_idsegmento,c_tppessoa_juridica);
          
      ELSIF pr_perm_pessoa_juridica = 0 -- retirar permissao pessoa juridica
        THEN
          --/        
          pc_revoke(pr_cdcooper,pr_idsegmento,c_tppessoa_juridica);
                  
      END IF;
      --     
   END pc_editar_pessoa;
    --/
  BEGIN
    --
    --/ Recupera dados de log para consulta posterior
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);
    --
    -- Verifica se houve erro recuperando informacoes de log                              
    IF NOT ( vr_dscritic IS NULL ) 
      THEN 
        RAISE vr_exc_erro;
    END IF;
    --
    --/ verifica erros de parametros
    --
    IF NOT valida_param(vr_cdcooper,pr_idsegmento,pr_dssegmento) THEN
        RAISE vr_exc_erro;
    END IF;    
    --/
    OPEN cr_tbepr_segmento(pr_idsegmento,vr_cdcooper);
    FETCH cr_tbepr_segmento INTO vrow_tbepr_segmento_old;
     IF cr_tbepr_segmento%NOTFOUND
      THEN
        CLOSE cr_tbepr_segmento;
        vr_dscritic := 'Segmento nao cadastrado';
        RAISE vr_exc_erro;
     END IF;
    CLOSE cr_tbepr_segmento; 
    vr_dstransa := 'Edicao do segmento de emprestimo';
    --
    -- chave
    vrow_tbepr_segmento_new.cdcooper := vrow_tbepr_segmento_old.cdcooper;
    vrow_tbepr_segmento_new.idsegmento := vrow_tbepr_segmento_old.idsegmento;
    --
    --/ parametros para update
    vrow_tbepr_segmento_new.dssegmento := GENE0007.fn_remove_cdata(pr_dssegmento);    
    vrow_tbepr_segmento_new.qtsimulacoes_padrao := pr_qtsimulacoes_padrao;
    vrow_tbepr_segmento_new.nrvariacao_parc := pr_nrvariacao_parc;
    vrow_tbepr_segmento_new.nrmax_proposta := pr_nrmax_proposta;
    vrow_tbepr_segmento_new.nrintervalo_proposta := pr_nrintervalo_proposta;
    vrow_tbepr_segmento_new.dssegmento_detalhada := GENE0007.fn_remove_cdata(pr_dssegmento_detalhada);
    vrow_tbepr_segmento_new.qtdias_validade := pr_qtdias_validade;
    --
    --/
    pc_editar(vrow_tbepr_segmento_new);  -- realiza a edição do segmento
    --/
    --
    pc_editar_pessoa(vr_cdcooper          -- realiza a edição do tipo pessoa
                    ,pr_idsegmento
                    ,pr_perm_pessoa_fisica
                    ,pr_perm_pessoa_juridica
                    ,vr_dscritic);   
    --/
    IF NOT ( vr_dscritic IS NULL )
      THEN
        RAISE vr_exc_erro;
    END IF;    
    --
    -- Criar cabeçalho do XML
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Dados><Resultado>OK</Resultado></Dados></Root>');
    --
    pr_des_erro := 'OK';
    --/
  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Retorno não OK          
      pr_des_erro := 'NOK';

      IF cr_tbepr_segmento%ISOPEN 
        THEN
         CLOSE cr_tbepr_segmento;
      END IF;

      IF NVL(vr_cdcritic,0) > 0 THEN
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;

      -- Erro
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic || '-' ||
                                     pr_dscritic || '</Erro></Root>');
    
    WHEN OTHERS THEN
      -- Retorno não OK
      pr_des_erro := 'NOK';
      
      -- Erro
      pr_cdcritic := 0;
      pr_dscritic := 'Erro nao tratado na tela_segemp.pc_editar_segmento: ' || SQLERRM;
      
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic || '-' ||
                                     pr_dscritic || '</Erro></Root>');
    
  END pc_editar_segmento;
  --
  --/ Editar subsegmentos de emprestimo 
  PROCEDURE pc_editar_Subsegmento(pr_idsegmento  IN tbepr_segmento.idsegmento%TYPE --> codigo do segmento de emprestimo
                                 ,pr_idsubsegmento  IN tbepr_subsegmento .idsubsegmento%TYPE --> codigo do segmento de emprestimo
                                 ,pr_dssubsegmento IN tbepr_subsegmento.dssubsegmento%TYPE --> descricao do subsegmento de emprestimo
                                 ,pr_cdlinha_credito IN tbepr_subsegmento.cdlinha_credito%TYPE --> codigo da linha de credito
                                 ,pr_cdfinalidade IN tbepr_subsegmento.cdfinalidade%TYPE --> Codigo da finalidade(crapfin)
                                 ,pr_flggarantia IN tbepr_subsegmento.flggarantia%TYPE --> flag para apontar se subsegmento possui garantia 1(sim) ou 0(não) 
                                 ,pr_tpgarantia IN tbepr_subsegmento.tpgarantia%TYPE --> tipo de garantia do subsegmento 0(novo) 1(usado)
                                 ,pr_pemax_autorizado IN tbepr_subsegmento.pemax_autorizado%TYPE --> percentual máximo autorizado
                                 ,pr_peexcedente IN tbepr_subsegmento .peexcedente%TYPE --> percentual excedente
                                 ,pr_vlmax_proposta IN tbepr_subsegmento.vlmax_proposta%TYPE --> valor máximo da proposta                                 
                                 ,pr_xmllog      IN VARCHAR2              --> XML com informações de LOG
                                 ,pr_cdcritic    OUT PLS_INTEGER          --> Código da crítica
                                 ,pr_dscritic    OUT VARCHAR2             --> Descrição da crítica
                                 ,pr_retxml      IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                                 ,pr_nmdcampo    OUT VARCHAR2             --> Nome do Campo
                                 ,pr_des_erro    OUT VARCHAR2) IS         --> Saida OK/NOK
    --
    /* .............................................................................
    Programa: pc_editar_segmento
    Sistema : Credito - Cooperativa de Credito
    Sigla   : 
    Autor   : AmCom
    Data    : Fevereiro/2019                       Ultima atualizacao: 
    --
    Dados referentes ao programa:
    --
    Frequencia: Sempre que for chamado
    Objetivo  : Alterar dados de subsegmento - tbepr_subsegmento
    --
    Alteracoes: 
    ............................................................................. */
    --    
    CURSOR cr_tbepr_subsegmento(pr_cdcooper IN tbepr_segmento.cdcooper%TYPE
                               ,pr_idsegmento IN tbepr_segmento.idsegmento%TYPE                               
                               ,pr_idsubsegmento IN tbepr_subsegmento.idsubsegmento%TYPE) IS
      SELECT cdcooper, 
             idsegmento, 
             idsubsegmento, 
             dssubsegmento, 
             cdlinha_credito, 
             flggarantia, 
             tpgarantia, 
             pemax_autorizado, 
             peexcedente, 
             vlmax_proposta, 
             cdfinalidade
        FROM tbepr_subsegmento
       WHERE idsegmento = pr_idsegmento
         AND idsubsegmento = pr_idsubsegmento
         AND cdcooper = pr_cdcooper ;
    --
    --
    vrow_tbepr_subsegmento_old cr_tbepr_subsegmento%ROWTYPE;    
    vrow_tbepr_subsegmento_new cr_tbepr_subsegmento%ROWTYPE;
    --
    -- VARIAVEIS ---
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;
    vr_dstransa  VARCHAR2(1000);
    vr_nrdrowid  ROWID;
    -- Variaveis de log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    --
    --Controle de erro
    vr_exc_erro EXCEPTION;
    --/ verifica se existe o subsegmento informado cadastrada na tabela
    FUNCTION existe_subsegmento(pr_cdcooper IN tbepr_segmento.cdcooper%TYPE,
                                pr_idsegmento IN tbepr_segmento.idsegmento%TYPE,
                                pr_idsubsegmento  IN tbepr_subsegmento .idsubsegmento%TYPE ) RETURN BOOLEAN IS
    vcount NUMBER :=0;
    BEGIN
     SELECT COUNT(*)
       INTO vcount
       FROM tbepr_subsegmento
      WHERE idsegmento = pr_idsegmento
        AND idsubsegmento = pr_idsubsegmento
        AND cdcooper = pr_cdcooper;
        RETURN ( vcount > 0 );
    END existe_subsegmento; 
    --
    --/ validações diversas dos parametros da procedure
    FUNCTION valida_param(pr_cdcooper IN tbepr_segmento.cdcooper%TYPE,
                          pr_idsegmento IN tbepr_segmento.idsegmento%TYPE,
                          pr_idsubsegmento IN tbepr_subsegmento.idsubsegmento%TYPE,
                          pr_dssubsegmento IN tbepr_subsegmento.dssubsegmento%TYPE,
                          pr_cdlinha_credito IN tbepr_subsegmento.cdlinha_credito%TYPE,
                          pr_cdfinalidade IN tbepr_subsegmento.cdfinalidade%TYPE) RETURN BOOLEAN IS
      
      FUNCTION existe_cdlinha_credito(pr_cdcooper IN tbepr_segmento.cdcooper%TYPE,
                                      pr_cdlcremp IN tbepr_subsegmento.cdlinha_credito%TYPE)
        RETURN BOOLEAN IS
        vr_existe NUMBER;
      BEGIN
         SELECT COUNT(*)
           INTO vr_existe
           FROM craplcr lcr
          WHERE lcr.cdcooper = pr_cdcooper
            AND lcr.cdlcremp = NVL(pr_cdlcremp,NULL);

         RETURN ( vr_existe > 0 );   
                    
      END existe_cdlinha_credito;

      FUNCTION existe_finalidade_credito(pr_cdcooper IN tbepr_segmento.cdcooper%TYPE,
                                         pr_cdfinalidade IN tbepr_subsegmento.cdfinalidade%TYPE)
        RETURN BOOLEAN IS
      vr_existe NUMBER;
      BEGIN
         SELECT COUNT(*)
           INTO vr_existe
           FROM crapfin fin 
          WHERE fin.cdcooper = pr_cdcooper
            AND fin.cdfinemp = NVL(pr_cdfinalidade,NULL);
               
         RETURN ( vr_existe > 0 );   
                    
      END existe_finalidade_credito;


     BEGIN
       --/
       IF NOT existe_subsegmento(pr_cdcooper,pr_idsegmento,pr_idsubsegmento)
         THEN
           vr_dscritic := 'SubSegmento nao cadastrado';
           RETURN FALSE;
       END IF;
       --/
       IF ( TRIM(pr_dssubsegmento) IS NULL )
         THEN
           vr_dscritic := 'Descricao para o subsegmento invalida';
           RETURN FALSE;
       END IF;
       --/
       IF NOT ( existe_cdlinha_credito(pr_cdcooper,pr_cdlinha_credito) )
         THEN
           vr_dscritic := 'linha de credito invalida';
           RETURN FALSE;
       END IF;
       
       IF NOT ( existe_finalidade_credito(pr_cdcooper,pr_cdfinalidade) )
         THEN
           vr_dscritic := 'Finalidade de credito invalida';
           RETURN FALSE;
       END IF;
               
       --/       
      RETURN TRUE;    
    END valida_param;
    --    
    --/ procedue que efetua o update na tabela de subsegmento 
    PROCEDURE pc_editar(pr_tbepr_subsegmento IN cr_tbepr_subsegmento%ROWTYPE) IS
    --                 
    BEGIN 
      --/
      BEGIN
          UPDATE tbepr_subsegmento
             SET dssubsegmento = pr_tbepr_subsegmento.dssubsegmento,
                 cdlinha_credito = pr_tbepr_subsegmento.cdlinha_credito,
                 flggarantia = pr_tbepr_subsegmento.flggarantia ,
                 tpgarantia = pr_tbepr_subsegmento.tpgarantia,
                 pemax_autorizado = pr_tbepr_subsegmento.pemax_autorizado,
                 peexcedente = pr_tbepr_subsegmento.peexcedente,
                 vlmax_proposta = pr_tbepr_subsegmento.vlmax_proposta,
                 cdfinalidade = pr_tbepr_subsegmento.cdfinalidade
           WHERE cdcooper = pr_tbepr_subsegmento.cdcooper
             AND idsegmento = pr_tbepr_subsegmento.idsegmento
             AND idsubsegmento = pr_tbepr_subsegmento.idsubsegmento;
    
    EXCEPTION
      WHEN OTHERS THEN
        VR_DSCRITIC := 'Erro ao alterar o segmento de emprestimo - ' ||
                       SQLERRM;
        RAISE VR_EXC_ERRO;
    END;
    -- Gerar informacoes do log
    /*GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                        ,pr_cdoperad => vr_cdoperad
                        ,pr_dscritic => ' '
                        ,pr_dsorigem => GENE0001.vr_vet_des_origens(vr_idorigem)
                        ,pr_dstransa => vr_dstransa
                        ,pr_dttransa => TRUNC(SYSDATE)
                        ,pr_flgtrans => 1 --> TRUE
                        ,pr_hrtransa => GENE0002.fn_busca_time
                        ,pr_idseqttl => 1
                        ,pr_nmdatela => 'ATENDA'
                        ,pr_nrdconta => pr_nrdconta
                        ,pr_nrdrowid => vr_nrdrowid);*/

  END pc_editar;      
    --
    --
  BEGIN
    --
    -- Recupera dados de log para consulta posterior
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);
    --
    -- Verifica se houve erro recuperando informacoes de log
    IF NOT ( vr_dscritic IS NULL ) THEN
      RAISE vr_exc_erro;
    END IF;
    --
    --/ verifica erros de parametros
    IF NOT valida_param(vr_cdcooper,
                        pr_idsegmento,
                        pr_idsubsegmento,
                        pr_dssubsegmento,
                        pr_cdlinha_credito,
                        pr_cdfinalidade)
      THEN
        RAISE vr_exc_erro;
    END IF;
    --
    --
    OPEN cr_tbepr_subsegmento(vr_cdcooper,pr_idsegmento,pr_idsubsegmento);
     FETCH cr_tbepr_subsegmento INTO vrow_tbepr_subsegmento_old;
      IF cr_tbepr_subsegmento%NOTFOUND
       THEN
         CLOSE cr_tbepr_subsegmento;
         vr_dscritic := 'Subsegmento nao cadastrado';
         RAISE vr_exc_erro;
      END IF;
    CLOSE cr_tbepr_subsegmento;
    vr_dstransa := 'Edicao do segmento de emprestimo';
    --
    --/ chave
    vrow_tbepr_subsegmento_new.cdcooper := vrow_tbepr_subsegmento_old.cdcooper;
    vrow_tbepr_subsegmento_new.idsegmento := vrow_tbepr_subsegmento_old.idsegmento;
    vrow_tbepr_subsegmento_new.idsubsegmento := vrow_tbepr_subsegmento_old.idsubsegmento;
    --
    -- parametros para update
    vrow_tbepr_subsegmento_new.dssubsegmento := pr_dssubsegmento;
    vrow_tbepr_subsegmento_new.cdlinha_credito := pr_cdlinha_credito;
    vrow_tbepr_subsegmento_new.flggarantia := pr_flggarantia;
    vrow_tbepr_subsegmento_new.tpgarantia := pr_tpgarantia;
    vrow_tbepr_subsegmento_new.pemax_autorizado := pr_pemax_autorizado;
    vrow_tbepr_subsegmento_new.peexcedente := pr_peexcedente;
    vrow_tbepr_subsegmento_new.vlmax_proposta := pr_vlmax_proposta;
    vrow_tbepr_subsegmento_new.cdfinalidade := pr_cdfinalidade;
    --
    --
    pc_editar(vrow_tbepr_subsegmento_new);
    --
    -- Criar cabeçalho do XML
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Dados><Resultado>OK</Resultado></Dados></Root>');
    --
    pr_des_erro := 'OK';
    --/
  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Retorno não OK          
      pr_des_erro := 'NOK';
    
      IF cr_tbepr_subsegmento%ISOPEN 
        THEN
         CLOSE cr_tbepr_subsegmento;
      END IF;
    
      IF NVL(vr_cdcritic,0) > 0 THEN
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;

      -- Erro
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic || '-' ||
                                     pr_dscritic || '</Erro></Root>');
    
    WHEN OTHERS THEN
      -- Retorno não OK
      pr_des_erro := 'NOK';
      
      -- Erro
      pr_cdcritic := 0;
      pr_dscritic := 'Erro nao tratado na tela_segemp.pc_editar_subsegmento: ' || SQLERRM;
      
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic || '-' ||
                                     pr_dscritic || '</Erro></Root>');
    
  END pc_editar_Subsegmento;
  --
  --/ Editar permissoes dos segmentos
  PROCEDURE pc_editar_perm_canais(pr_idsegmento IN tbepr_segmento_canais_perm.idsegmento%TYPE --> id do segmento de emprestimo
                                 ,pr_cdcanal IN tbepr_segmento_canais_perm.cdcanal%TYPE --> codigo do canal
                                 ,pr_tppermissao IN tbepr_segmento_canais_perm.tppermissao%TYPE --> tipo de permissao
                                 ,pr_vlmax_autorizado IN tbepr_segmento_canais_perm.vlmax_autorizado%TYPE 
                                 ,pr_xmllog IN VARCHAR2             --> XML com informações de LOG
                                 ,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
                                 ,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
                                 ,pr_retxml IN OUT NOCOPY xmltype   --> Arquivo de retorno do XML
                                 ,pr_nmdcampo OUT VARCHAR2          --> Nome do Campo
                                 ,pr_des_erro OUT VARCHAR2) IS      --> Saida OK/NOK
    --/
    --
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;
    --
    vrow_canais_perm_new tbepr_segmento_canais_perm%ROWTYPE;
    --
    --/ Variaveis de log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);   
   --
   -- Controle de erro
   vr_exc_erro EXCEPTION;
   --  
   --/
   CURSOR cr_cnl_permissoes(pr_cdcooper IN tbepr_segmento_canais_perm.cdcooper%TYPE
                            ,pr_idsegmento IN tbepr_segmento_canais_perm.idsegmento%TYPE
                            ,pr_cdcanal IN tbepr_segmento_canais_perm.cdcanal%TYPE) IS
     SELECT cperm.cdcooper,
            cperm.idsegmento,
            cperm.cdcanal,
            cperm.tppermissao,
            cperm.vlmax_autorizado
       FROM tbepr_segmento_canais_perm cperm
      WHERE cperm.cdcooper = pr_cdcooper
        AND cperm.idsegmento = pr_idsegmento
        AND cperm.cdcanal = pr_cdcanal;
   --
   rw_cnl_permissoes  cr_cnl_permissoes%ROWTYPE;
   --/ editar permissoes do canal de entrada no segmento de emprestimo
   PROCEDURE pc_editar_canal(pr_canais_perm IN tbepr_segmento_canais_perm%ROWTYPE
                             ,pr_dscritic OUT crapcri.dscritic%TYPE) IS
   --/
   --
   BEGIN
   --/
     BEGIN
        --/
     INSERT INTO tbepr_segmento_canais_perm
                     (cdcooper, 
                      idsegmento, 
                      cdcanal, 
                      tppermissao, 
                      vlmax_autorizado)
          VALUES     (pr_canais_perm.cdcooper,
                      pr_canais_perm.idsegmento,
                      pr_canais_perm.cdcanal,
                      pr_canais_perm.tppermissao,
                      pr_canais_perm.vlmax_autorizado);
        --/
     EXCEPTION 
       WHEN dup_val_on_index
        THEN
         UPDATE tbepr_segmento_canais_perm
            SET tppermissao = pr_canais_perm.tppermissao,
                vlmax_autorizado = pr_canais_perm.vlmax_autorizado
          WHERE cdcooper = pr_canais_perm.cdcooper
            AND idsegmento = pr_canais_perm.idsegmento
            AND cdcanal = pr_canais_perm.cdcanal;
           --/
        WHEN OTHERS
         THEN
          pr_dscritic := 'Erro ao atualizar permissoes canais '||SQLERRM;
     END;
        
   END pc_editar_canal;
   --
   --/
  BEGIN
   --/
   -- Recupera dados de log para consulta posterior
   gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                           ,pr_cdcooper => vr_cdcooper
                           ,pr_nmdatela => vr_nmdatela
                           ,pr_nmeacao  => vr_nmeacao
                           ,pr_cdagenci => vr_cdagenci
                           ,pr_nrdcaixa => vr_nrdcaixa
                           ,pr_idorigem => vr_idorigem
                           ,pr_cdoperad => vr_cdoperad
                           ,pr_dscritic => vr_dscritic);
    --
    -- Verifica se houve erro recuperando informacoes de log
    IF NOT ( vr_dscritic IS NULL ) THEN
      RAISE vr_exc_erro;
    END IF;
    --
    --/ abre cursor com as permissoes de canais de entrada
    OPEN cr_cnl_permissoes(vr_cdcooper,pr_idsegmento,pr_cdcanal);
    FETCH cr_cnl_permissoes INTO rw_cnl_permissoes;       
    CLOSE cr_cnl_permissoes;
    --
    --/
    vrow_canais_perm_new.cdcooper := vr_cdcooper; --rw_cnl_permissoes.cdcooper;
    vrow_canais_perm_new.idsegmento := pr_idsegmento; -- rw_cnl_permissoes.idsegmento;
    vrow_canais_perm_new.cdcanal := pr_cdcanal; --rw_cnl_permissoes.cdcanal;
    vrow_canais_perm_new.tppermissao := pr_tppermissao;
    vrow_canais_perm_new.vlmax_autorizado := pr_vlmax_autorizado;
    --
    --/
    pc_editar_canal(vrow_canais_perm_new  -- realiza a edição do canal
                    ,vr_dscritic);
    --   
    --/
    IF NOT ( vr_dscritic IS NULL )
      THEN
        RAISE vr_exc_erro;
    END IF;       
    --
    -- Criar cabeçalho do XML
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Dados><Resultado>OK</Resultado></Dados></Root>');
    --
    pr_des_erro := 'OK';
    --
  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Retorno não OK          
      pr_des_erro := 'NOK';
      --
      IF cr_cnl_permissoes%ISOPEN
        THEN
         CLOSE cr_cnl_permissoes;
      END IF;
      --/
      IF NVL(vr_cdcritic,0) > 0 THEN
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      --
      -- Erro
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic || '-' ||
                                     pr_dscritic || '</Erro></Root>');
    
    WHEN OTHERS THEN
      -- Retorno não OK
      pr_des_erro := 'NOK';
      --
      --/ Erro
      pr_cdcritic := 0;
      pr_dscritic := 'Erro nao tratado na tela_segemp.pc_editar_segmento: ' || SQLERRM;
      --
      --/ Existe para satisfazer exigência da interface. 
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic || '-' ||
                                     pr_dscritic || '</Erro></Root>');
  
    END pc_editar_perm_canais;
  --/
  --  
END TELA_SEGEMP;
/
