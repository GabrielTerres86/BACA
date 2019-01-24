create or replace package cecred.APLI0003 is

   ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : APLI0003
  --  Sistema  : Rotinas genericas referente a tela PCAPTA
  --  Sigla    : APLI
  --  Autor    : Jean Michel - CECRED
  --  Data     : Maio - 2014.                   Ultima atualizacao: 15/07/2018
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Agrupar rotinas genericas referente a tela PCAPTA

  -- Alteracoes: Incluida procedure pc_carrega_produto utilizada na tela PCAPTA (Jean Michel)
  --
  --             15/07/2018 Inclusão da Aplicação Programada - Cláudio (CIS Corporate)
  --
  --             25/09/2018 Inclusão da Aplicação Programada no retorno da pc_carrega_produto - Proj. 411.2 (CIS Corporate)
  --
  ---------------------------------------------------------------------------------------------------------------
  
  /* Rotina referente a consulta de produtos cadastrados */ 
  PROCEDURE pc_carrega_produto(pr_cdprodut IN crapcpc.cdprodut%TYPE --> Codigo do Produto
                              ,pr_idsitpro IN crapcpc.idsitpro%TYPE --> Situacao do produto    
                              ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                              ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                              ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                              ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                              ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                              ,pr_des_erro OUT VARCHAR2);           --> Erros do processo
                              
	 /* Rotina referente a consulta de carencias cadastradas */
  PROCEDURE pc_carrega_carencia(pr_cdprodut IN crapcpc.cdprodut%TYPE --> Codigo do Produto
                               ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                               ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                               ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                               ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                               ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                               ,pr_des_erro OUT VARCHAR2);           --> Erros do processo
                               
	 /* Rotina referente a consulta de prazos cadastrados */
  PROCEDURE pc_carrega_prazo(pr_cdprodut IN crapcpc.cdprodut%TYPE --> Codigo do Produto
            		            ,pr_qtdiacar IN crapmpc.qtdiacar%TYPE      --> Quantidade de dias de carencia
                            ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                            ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                            ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                            ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                            ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                            ,pr_des_erro OUT VARCHAR2);           --> Erros do processo
                            
 /* Rotina referente a consulta de faixas de valor cadastrados */
  PROCEDURE pc_carrega_faixa_valor(pr_cdprodut IN crapcpc.cdprodut%TYPE --> Codigo do Produto
                                  ,pr_qtdiacar IN crapmpc.qtdiacar%TYPE --> Quantidade de dias de carencia
                                  ,pr_qtdiaprz IN crapmpc.qtdiaprz%TYPE --> Quantidade de dias de prazo
                                  ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                  ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                  ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                  ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                  ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                  ,pr_des_erro OUT VARCHAR2);           --> Erros do processo                            

  PROCEDURE pc_carrega_perren_txfixa(pr_cdprodut IN crapcpc.cdprodut%TYPE --> Codigo do Produto
                                    ,pr_qtdiacar IN crapmpc.qtdiacar%TYPE --> Quantidade de dias de carencia
                                    ,pr_qtdiaprz IN crapmpc.qtdiaprz%TYPE --> Quantidade de dias de prazo
                                    ,pr_vlrfaixa IN crapmpc.vlrfaixa%TYPE --> Faixa de valor
                                    ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                    ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                    ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                    ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                    ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                    ,pr_des_erro OUT VARCHAR2);           --> Erros do processo
                            

  /* Rotina referente a consulta cooperativas */
  PROCEDURE pc_carrega_coperativa(pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                 ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                 ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                 ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                 ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                 ,pr_des_erro OUT VARCHAR2);           --> Erros do processo


  /* Rotina referente a consulta cooperativas */
  PROCEDURE pc_lista_movimentacao_carteira(pr_cdcooper IN crapcop.cdcooper%type   --> Código da Cooperativa                
                                          ,pr_dtmvtolt IN VARCHAR2                --> Data do Movimento
                                          ,pr_nrregist IN PLS_INTEGER             --> Numero de Registros da Paginacao
                                          ,pr_nriniseq IN PLS_INTEGER             --> Numero de inicio de sequencia da paginacao
                                          ,pr_xmllog   IN VARCHAR2                --> XML com informações de LOG
                                          ,pr_cdcritic OUT PLS_INTEGER            --> Código da crítica
                                          ,pr_dscritic OUT VARCHAR2               --> Descrição da crítica
                                          ,pr_retxml   IN OUT NOCOPY XMLType      --> Arquivo de retorno do XML
                                          ,pr_nmdcampo OUT VARCHAR2               --> Nome do campo com erro
                                          ,pr_des_erro OUT VARCHAR2);             --> Erros do processo


  PROCEDURE pc_lista_politicas_cooperativa(pr_cdprodut IN crapmpc.cdprodut%TYPE --> Codigo do Produto 
                                          ,pr_cdcooper IN crapcop.cdcooper%TYPE --> Codigo da Cooperativa    
                                          ,pr_nrregist IN PLS_INTEGER           --> Numero de Registros da Paginacao
                                          ,pr_nriniseq IN PLS_INTEGER           --> Numero de inicio de sequencia da paginacao    
                                          ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                          ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                          ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                          ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                          ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                          ,pr_des_erro OUT VARCHAR2);           --> Erros do processo


  PROCEDURE pc_lista_modalidade_produto(pr_cdprodut IN crapmpc.cdprodut%TYPE --> Codigo do Produto 
                                       ,pr_nrregist IN PLS_INTEGER           --> Numero de Registros da Paginacao
                                       ,pr_nriniseq IN PLS_INTEGER           --> Numero de inicio de sequencia da paginacao    
                                       ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                       ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                       ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                       ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                       ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                       ,pr_des_erro OUT VARCHAR2);           --> Erros do processo
                                       
  PROCEDURE pc_lista_modalidade_coope(pr_cdprodut IN crapmpc.cdprodut%TYPE --> Codigo do Produto 
                                     ,pr_cdcooper IN crapcop.cdcooper%TYPE --> Codigo da Cooperativa
                                     ,pr_idsitmod IN crapdpc.idsitmod%TYPE --> Situacao da Modalidade (Bloqueada/Desbloqueada)
                                     ,pr_nrregist IN PLS_INTEGER           --> Numero de Registros da Paginacao
                                     ,pr_nriniseq IN PLS_INTEGER           --> Numero de inicio de sequencia da paginacao    
                                     ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                     ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                     ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                     ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                     ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                     ,pr_des_erro OUT VARCHAR2);           --> Erros do processo                                       

	/* Rotina referente a consulta de historico do produto */
  PROCEDURE pc_lista_historico_produto(pr_cdprodut IN crapmpc.cdprodut%TYPE --> Codigo do Produto 
                                      ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                      ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                      ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                      ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                      ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                      ,pr_des_erro OUT VARCHAR2);           --> Erros do processo

PROCEDURE pc_lista_nomenclatura_produto(pr_cdprodut IN crapcpc.cdprodut%TYPE --> Codigo do Produto
                                       ,pr_cdnomenc IN crapnpc.cdnomenc%TYPE --> Codigo da Nomenclatura
                                       ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                       ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                       ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                       ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                       ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                       ,pr_des_erro OUT VARCHAR2);           --> Erros do processo

  PROCEDURE pc_manter_nomenclatura_produto(pr_cddopcao IN VARCHAR2 --> Codigo do Opção
                                          ,pr_cdprodut IN crapnpc.cdprodut%TYPE --> Codigo do Produto
                                          ,pr_cdnomenc IN crapnpc.cdnomenc%TYPE --> Codigo Nomemclatura
                                          ,pr_dsnomenc IN crapnpc.dsnomenc%TYPE --> Nomemclatura
                                          ,pr_idsitnom IN crapnpc.idsitnom%TYPE --> Situacao da Nomenclatura
                                          ,pr_qtmincar IN crapnpc.qtmincar%TYPE --> Quantidade minima de carencia
                                          ,pr_qtmaxcar IN crapnpc.qtmaxcar%TYPE --> Quantidade maxima de carencia
                                          ,pr_vlminapl IN crapnpc.vlminapl%TYPE --> Valor minimo aplicacao
                                          ,pr_vlmaxapl IN crapnpc.vlmaxapl%TYPE --> Valor maximo aplicacao                                          
                                          ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                          ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                          ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                          ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                          ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                          ,pr_des_erro OUT VARCHAR2);           --> Erros do processo

PROCEDURE pc_manter_historico_produto(pr_cddopcao IN VARCHAR2              --> Codigo do Opção
                                     ,pr_cdprodut IN crapcpc.cdprodut%TYPE --> Codigo do Produto
                                     ,pr_cdhscacc IN crapcpc.cdhscacc%TYPE --> Débito Aplicação
                                     ,pr_cdhsvrcc IN crapcpc.cdhsvrcc%TYPE --> Crédito Resgate/Vencimento Aplicação
                                     ,pr_cdhsraap IN crapcpc.cdhsraap%TYPE --> Crédito Renovação Aplicação
                                     ,pr_cdhsnrap IN crapcpc.cdhsnrap%TYPE --> Crédito Aplicação Recurso Novo
                                     ,pr_cdhsprap IN crapcpc.cdhsprap%TYPE --> Crédito Atualização Juros
                                     ,pr_cdhsrvap IN crapcpc.cdhsrvap%TYPE --> Débito Reversão Atualização Juros
                                     ,pr_cdhsrdap IN crapcpc.cdhsrdap%TYPE --> Crédito Rendimento
                                     ,pr_cdhsirap IN crapcpc.cdhsirap%TYPE --> Débito IRRF
                                     ,pr_cdhsrgap IN crapcpc.cdhsrgap%TYPE --> Débito Resgate
                                     ,pr_cdhsvtap IN crapcpc.cdhsvtap%TYPE --> Débito Vencimento
                                     ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                     ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                     ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                     ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                     ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                     ,pr_des_erro OUT VARCHAR2);           --> Erros do processo


  PROCEDURE pc_manter_modalidade(pr_cddopcao IN VARCHAR2 --> Codigo do Opção
                               ,pr_cdmodali IN VARCHAR2 --> Codigo do Modalidade
                               ,pr_cdprodut IN crapmpc.cdprodut%TYPE --> Codigo do Produto
                               ,pr_qtdiacar IN crapmpc.qtdiacar%TYPE --> Dias de carencia
                               ,pr_qtdiaprz IN crapmpc.qtdiaprz%TYPE --> Dias de prazo
                               ,pr_vlrfaixa IN crapmpc.vlrfaixa%TYPE --> Faixa de valor
                               ,pr_vlperren IN crapmpc.vlperren%TYPE --> Rentabilidade
                               ,pr_vltxfixa IN crapmpc.vltxfixa%TYPE --> Taxa Fixa
                               ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                               ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                               ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                               ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                               ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                               ,pr_des_erro OUT VARCHAR2);         --> Erros do processo
             
  /* Rotina referente a produtos da tela PCAPTA */
  PROCEDURE pc_manter_produto(pr_cddopcao IN VARCHAR2 --> Codigo do Opção
                             ,pr_cdprodut IN crapcpc.cdprodut%TYPE --> Codigo do Produto
                             ,pr_nmprodut IN crapcpc.nmprodut%TYPE --> Nome do Produto
                             ,pr_idsitpro IN crapcpc.idsitpro%TYPE --> Situação
                             ,pr_cddindex IN crapcpc.cddindex%TYPE --> Codigo do Indexador
                             ,pr_idtippro IN crapcpc.idtippro%TYPE --> Tipo
                             ,pr_idtxfixa IN crapcpc.idtxfixa%TYPE --> Taxa Fixa
                             ,pr_idacumul IN crapcpc.idacumul%TYPE --> Taxa Cumulativa
                             ,pr_indplano IN INTEGER               --> Apl. Programada (1 = Sim / 2 = Nao)
                             ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                             ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                             ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                             ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                             ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                             ,pr_des_erro OUT VARCHAR2);           --> Erros do processo  


  PROCEDURE pc_manter_modal_coop(pr_cddopcao IN VARCHAR2              --> Codigo do Opção
                                ,pr_cdcooper IN crapcop.cdcooper%TYPE --> Codigo da Cooperativa    
                                ,pr_cdmodali IN VARCHAR2              --> Codigo da Modalidade
                                ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                ,pr_des_erro OUT VARCHAR2);           --> Erros do processo


  /* Rotina referente a validacao de acesso as opcoes da tela PCAPTA */
  PROCEDURE pc_valida_acesso(pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                            ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                            ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                            ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                            ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                            ,pr_des_erro OUT VARCHAR2);           --> Erros do processo

end APLI0003;
/
create or replace package body cecred.APLI0003 is

  /* Rotina referente a consulta de produtos cadastrados */
  PROCEDURE pc_carrega_produto(pr_cdprodut IN crapcpc.cdprodut%TYPE --> Codigo do Produto
                              ,pr_idsitpro IN crapcpc.idsitpro%TYPE --> Situacao do produto
                              ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                              ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                              ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                              ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                              ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                              ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
  BEGIN
  
    /* .............................................................................

     Programa: pc_carrega_produto
     Sistema : Novos Produtos de Captação
     Sigla   : APLI
     Autor   : Jean Michel
     Data    : Maio/14.                    Ultima atualizacao: 10/06/2014

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina de consulta de produtos cadastrados.

     Observacao: -----

     Alteracoes: Implementacao da possibilidade de consulta de dados do produto
                 pelo codigo do mesmo. {Carlos Rafael Tanholi - 22/07/2014}
                 
                 Implementacao do cursor cr_crapind para recuperacao do nome 
                 do indexador relacionado ao produto {Carlos Rafael Tanholi - 06/08/2014}
                 
                 Alteracao no cursor cr_crapcpc para trazer todos os produtos sem
                 filtro de situacao {Carlos Rafael Tanholi}
                 
                 15/07/2018 - Inclusão do parâmetro pr_idaplpgm em pc_lista_movimentacao_carteira
			                        Claudio - CIS Corporate
                
                 25/09/2018 - Inclusão da Aplicação Programada no retorno 
                              Proj. 411.2 (CIS Corporate)
             
     ..............................................................................*/ 
    DECLARE
          
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      vr_contador INTEGER := 0;
      
      -- Seleciona os produtos de captacao
      CURSOR cr_crapcpc (pr_cdprodut IN crapcpc.cdprodut%TYPE,
                         pr_idsitpro IN crapcpc.idsitpro%TYPE) IS
      SELECT
        cpc.cdprodut,
        cpc.nmprodut,
        cpc.idsitpro,
        cpc.cddindex,
        cpc.idtippro,
        cpc.idtxfixa,
        cpc.idacumul,
        CASE cpc.indplano 
             WHEN 1 THEN cpc.indplano
             ELSE 2 
               END indplano
      FROM
       crapcpc cpc
      WHERE (cpc.cdprodut = pr_cdprodut 
         OR pr_cdprodut = 0)
        AND (cpc.idsitpro = pr_idsitpro
         OR pr_idsitpro = 0);
      
       rw_crapcpc cr_crapcpc%ROWTYPE;

      -- Selecionar as administradoras de cartao
      CURSOR cr_crapind (pr_cddindex IN crapind.cddindex%TYPE) IS
      SELECT
        ind.nmdindex
      FROM
       crapind ind
      WHERE
       ind.cddindex = pr_cddindex OR pr_cddindex = 0;

       rw_crapind cr_crapind%ROWTYPE; 


      BEGIN
        
        -- Criar cabeçalho do XML
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
    
        --Busca administradoras de cartao
        OPEN cr_crapcpc(pr_cdprodut, pr_idsitpro);
        
        IF ( pr_cdprodut > 0 ) THEN 
          
          LOOP
            FETCH cr_crapcpc INTO rw_crapcpc;
            
            OPEN cr_crapind(rw_crapcpc.cddindex);
           FETCH cr_crapind INTO rw_crapind;
            
            -- SAI DO LOOP QUANDO CHEGAR AO FIM DOS REGISTROS
            EXIT WHEN cr_crapcpc%NOTFOUND; 
            
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados'   , pr_posicao => 0     , pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'cdprodut', pr_tag_cont => rw_crapcpc.cdprodut, pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nmprodut', pr_tag_cont => rw_crapcpc.nmprodut, pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'idsitpro', pr_tag_cont => rw_crapcpc.idsitpro, pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'cddindex', pr_tag_cont => rw_crapcpc.cddindex, pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'idtippro', pr_tag_cont => rw_crapcpc.idtippro, pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'idtxfixa', pr_tag_cont => rw_crapcpc.idtxfixa, pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'idacumul', pr_tag_cont => rw_crapcpc.idacumul, pr_des_erro => vr_dscritic);
            --gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nommitra', pr_tag_cont => rw_crapcpc.nommitra, pr_des_erro => vr_dscritic);            
           
            -- campo com o nome do indexador
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nmdindex', pr_tag_cont => rw_crapind.nmdindex, pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'indplano', pr_tag_cont => rw_crapcpc.indplano, pr_des_erro => vr_dscritic);
            
            CLOSE cr_crapind;

            vr_contador := vr_contador + 1;                                
            
          END LOOP;     
        
        ELSE 
          
          LOOP
            FETCH cr_crapcpc INTO rw_crapcpc;
            
            -- SAI DO LOOP QUANDO CHEGAR AO FIM DOS REGISTROS
            EXIT WHEN cr_crapcpc%NOTFOUND; 
            
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados'   , pr_posicao => 0     , pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'cdprodut', pr_tag_cont => rw_crapcpc.cdprodut, pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nmprodut', pr_tag_cont => rw_crapcpc.nmprodut, pr_des_erro => vr_dscritic);
            vr_contador := vr_contador + 1;                                
            
          END LOOP;        
        
        
        END IF;         
        
        CLOSE cr_crapcpc;

        COMMIT;

    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em Consulta de Produtos: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;

  END pc_carrega_produto;


  /* Rotina referente a consulta de carencias cadastrados */
  PROCEDURE pc_carrega_carencia(pr_cdprodut IN crapcpc.cdprodut%TYPE --> Codigo do Produto
                               ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                               ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                               ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                               ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                               ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                               ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
  BEGIN
  
    /* .............................................................................

     Programa: pc_carrega_carencia
     Sistema : Novos Produtos de Captação
     Sigla   : APLI
     Autor   : Carlos Rafael Tanholi
     Data    : Agosto/14.                    Ultima atualizacao: 15/08/2014

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina de consulta de carencias cadastrados.

     Observacao: -----

     Alteracoes:
     ..............................................................................*/ 
    DECLARE
          
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      vr_contador INTEGER := 0;
      
      -- Seleciona os dias de carencia das modalidades cadastradas para o produto
      CURSOR cr_crapmpc (pr_cdprodut IN crapcpc.cdprodut%TYPE) IS
      SELECT mpc.qtdiacar
        FROM crapmpc mpc
       WHERE mpc.cdprodut = pr_cdprodut
    GROUP BY mpc.qtdiacar; 
      
       rw_crapmpc cr_crapmpc%ROWTYPE;


      BEGIN
        
        -- Criar cabeçalho do XML
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
    
        --Busca administradoras de cartao
        OPEN cr_crapmpc(pr_cdprodut);
        
        IF cr_crapmpc%NOTFOUND THEN
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados'   , pr_posicao => 0     , pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'carencia', pr_tag_cont => 0, pr_des_erro => vr_dscritic);            
        ELSE
          
            LOOP
              FETCH cr_crapmpc INTO rw_crapmpc;
              
              -- SAI DO LOOP QUANDO CHEGAR AO FIM DOS REGISTROS
              EXIT WHEN cr_crapmpc%NOTFOUND; 
              
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados'   , pr_posicao => 0     , pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'carencia', pr_tag_cont => rw_crapmpc.qtdiacar, pr_des_erro => vr_dscritic);
              vr_contador := vr_contador + 1;                                
              
            END LOOP;        
               
        END IF;         
        
        CLOSE cr_crapmpc;

        COMMIT;

      EXCEPTION
        WHEN vr_exc_saida THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic;

          -- Carregar XML padrão para variável de retorno não utilizada.
          -- Existe para satisfazer exigência da interface.
          pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
          ROLLBACK;
        WHEN OTHERS THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := 'Erro geral em Consulta de Carencias: ' || SQLERRM;

          -- Carregar XML padrão para variável de retorno não utilizada.
          -- Existe para satisfazer exigência da interface.
          pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
          ROLLBACK;
    END;

  END pc_carrega_carencia;





 /* Rotina referente a consulta de carencias cadastrados */
  PROCEDURE pc_carrega_prazo(pr_cdprodut IN crapcpc.cdprodut%TYPE --> Codigo do Produto
            		            ,pr_qtdiacar IN crapmpc.qtdiacar%TYPE --> Quantidade de dias de carencia
                            ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                            ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                            ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                            ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                            ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                            ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
  BEGIN
  
    /* .............................................................................

     Programa: pc_carrega_prazo
     Sistema : Novos Produtos de Captação
     Sigla   : APLI
     Autor   : Carlos Rafael Tanholi
     Data    : Agosto/14.                    Ultima atualizacao: 15/08/2014

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina de consulta de prazos cadastrados.

     Observacao: -----

     Alteracoes:
     ..............................................................................*/ 
    DECLARE
          
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      vr_contador INTEGER := 0;

      CURSOR cr_crapmpc (pr_cdprodut IN crapcpc.cdprodut%TYPE
                        ,pr_qtdiacar IN crapmpc.qtdiacar%TYPE) IS
      SELECT mpc.qtdiaprz
        FROM crapmpc mpc
       WHERE mpc.cdprodut = pr_cdprodut
         AND mpc.qtdiacar = pr_qtdiacar
    GROUP BY mpc.qtdiaprz; 
      
       rw_crapmpc cr_crapmpc%ROWTYPE;


      BEGIN
        
        -- Criar cabeçalho do XML
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
    
        --Busca administradoras de cartao
        OPEN cr_crapmpc(pr_cdprodut, pr_qtdiacar);
        
        IF cr_crapmpc%NOTFOUND THEN
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados'   , pr_posicao => 0     , pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'prazo', pr_tag_cont => 0, pr_des_erro => vr_dscritic);            
        ELSE
          
            LOOP
              FETCH cr_crapmpc INTO rw_crapmpc;
              
              -- SAI DO LOOP QUANDO CHEGAR AO FIM DOS REGISTROS
              EXIT WHEN cr_crapmpc%NOTFOUND; 
              
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados'   , pr_posicao => 0     , pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'prazo', pr_tag_cont => rw_crapmpc.qtdiaprz, pr_des_erro => vr_dscritic);
              vr_contador := vr_contador + 1;                                
              
            END LOOP;        
               
        END IF;         
        
        CLOSE cr_crapmpc;

        COMMIT;

      EXCEPTION
        WHEN vr_exc_saida THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic;

          -- Carregar XML padrão para variável de retorno não utilizada.
          -- Existe para satisfazer exigência da interface.
          pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
          ROLLBACK;
        WHEN OTHERS THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := 'Erro geral em Consulta de Prazos: ' || SQLERRM;

          -- Carregar XML padrão para variável de retorno não utilizada.
          -- Existe para satisfazer exigência da interface.
          pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
          ROLLBACK;
    END;

  END pc_carrega_prazo;



  /* Rotina referente a consulta de faixas de valor cadastrados */
  PROCEDURE pc_carrega_faixa_valor(pr_cdprodut IN crapcpc.cdprodut%TYPE --> Codigo do Produto
                                  ,pr_qtdiacar IN crapmpc.qtdiacar%TYPE --> Quantidade de dias de carencia
                                  ,pr_qtdiaprz IN crapmpc.qtdiaprz%TYPE --> Quantidade de dias de prazo
                                  ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                  ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                  ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                  ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                  ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                  ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
  BEGIN
  
    /* .............................................................................

     Programa: pc_carrega_faixa_valor
     Sistema : Novos Produtos de Captação
     Sigla   : APLI
     Autor   : Carlos Rafael Tanholi
     Data    : Agosto/14.                    Ultima atualizacao: 15/08/2014

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina de consulta de faixas de valor cadastradas.

     Observacao: -----

     Alteracoes:
     ..............................................................................*/ 
    DECLARE
          
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      vr_contador INTEGER := 0;
      
      CURSOR cr_crapmpc (pr_cdprodut IN crapcpc.cdprodut%TYPE
                        ,pr_qtdiacar IN crapmpc.qtdiacar%TYPE
                        ,pr_qtdiaprz IN crapmpc.qtdiaprz%TYPE) IS
      SELECT mpc.vlrfaixa
        FROM crapmpc mpc
       WHERE mpc.cdprodut = pr_cdprodut
         AND mpc.qtdiacar = pr_qtdiacar
         AND mpc.qtdiaprz = pr_qtdiaprz
    GROUP BY mpc.vlrfaixa; 
      
       rw_crapmpc cr_crapmpc%ROWTYPE;


      BEGIN
        
        -- Criar cabeçalho do XML
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
    
        --Busca administradoras de cartao
        OPEN cr_crapmpc(pr_cdprodut, pr_qtdiacar, pr_qtdiaprz);
        
        IF cr_crapmpc%NOTFOUND THEN
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados'   , pr_posicao => 0     , pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'faixa_valor', pr_tag_cont => 0, pr_des_erro => vr_dscritic);            
        ELSE
          
            LOOP
              FETCH cr_crapmpc INTO rw_crapmpc;
              
              -- SAI DO LOOP QUANDO CHEGAR AO FIM DOS REGISTROS
              EXIT WHEN cr_crapmpc%NOTFOUND; 
              
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados'   , pr_posicao => 0     , pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'faixa_valor', pr_tag_cont => rw_crapmpc.vlrfaixa, pr_des_erro => vr_dscritic);
              vr_contador := vr_contador + 1;                                
              
            END LOOP;        
               
        END IF;         
        
        CLOSE cr_crapmpc;

        COMMIT;

      EXCEPTION
        WHEN vr_exc_saida THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic;

          -- Carregar XML padrão para variável de retorno não utilizada.
          -- Existe para satisfazer exigência da interface.
          pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
          ROLLBACK;
        WHEN OTHERS THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := 'Erro geral em Consulta de Prazos: ' || SQLERRM;

          -- Carregar XML padrão para variável de retorno não utilizada.
          -- Existe para satisfazer exigência da interface.
          pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
          ROLLBACK;
    END;

  END pc_carrega_faixa_valor;



 /* Rotina referente a consulta de faixas de valor cadastrados */
  PROCEDURE pc_carrega_perren_txfixa(pr_cdprodut IN crapcpc.cdprodut%TYPE --> Codigo do Produto
                                    ,pr_qtdiacar IN crapmpc.qtdiacar%TYPE --> Quantidade de dias de carencia
                                    ,pr_qtdiaprz IN crapmpc.qtdiaprz%TYPE --> Quantidade de dias de prazo
                                    ,pr_vlrfaixa IN crapmpc.vlrfaixa%TYPE --> Faixa de valor
                                    ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                    ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                    ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                    ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                    ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                    ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
  BEGIN
  
    /* .............................................................................

     Programa: pc_carrega_perren_txfixa
     Sistema : Novos Produtos de Captação
     Sigla   : APLI
     Autor   : Carlos Rafael Tanholi
     Data    : Agosto/14.                    Ultima atualizacao: 15/08/2014

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina de consulta para o percentual de rentabilidade e
                 taxa fixa cadastrado na modalidade.

     Observacao: -----

     Alteracoes:
     ..............................................................................*/ 
    DECLARE
          
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      vr_contador INTEGER := 0;
      
      CURSOR cr_crapmpc (pr_cdprodut IN crapcpc.cdprodut%TYPE
                        ,pr_qtdiacar IN crapmpc.qtdiacar%TYPE
                        ,pr_qtdiaprz IN crapmpc.qtdiaprz%TYPE
                        ,pr_vlrfaixa IN crapmpc.vlrfaixa%TYPE) IS
      SELECT mpc.cdmodali
            ,mpc.vlperren
            ,mpc.vltxfixa
        FROM crapmpc mpc
       WHERE mpc.cdprodut = pr_cdprodut
         AND mpc.qtdiacar = pr_qtdiacar
         AND mpc.qtdiaprz = pr_qtdiaprz
         AND mpc.vlrfaixa = pr_vlrfaixa; 
      
       rw_crapmpc cr_crapmpc%ROWTYPE;


      BEGIN
        
        -- Criar cabeçalho do XML
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
    
        --Busca administradoras de cartao
        OPEN cr_crapmpc(pr_cdprodut, pr_qtdiacar, pr_qtdiaprz, pr_vlrfaixa);
        
        IF cr_crapmpc%NOTFOUND THEN
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados'   , pr_posicao => 0     , pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'cdmodali', pr_tag_cont => 0, pr_des_erro => vr_dscritic);          
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'vlperren', pr_tag_cont => 0, pr_des_erro => vr_dscritic);          
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'vltxfixa', pr_tag_cont => 0, pr_des_erro => vr_dscritic);

        ELSE
          
          FETCH cr_crapmpc INTO rw_crapmpc;
                
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados'   , pr_posicao => 0     , pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'cdmodali', pr_tag_cont => rw_crapmpc.cdmodali, pr_des_erro => vr_dscritic);          
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'vlperren', pr_tag_cont => rw_crapmpc.vlperren, pr_des_erro => vr_dscritic);          
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'vltxfixa', pr_tag_cont => rw_crapmpc.vltxfixa, pr_des_erro => vr_dscritic);
               
        END IF;         
        
        CLOSE cr_crapmpc;

        COMMIT;

      EXCEPTION
        WHEN vr_exc_saida THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic;

          -- Carregar XML padrão para variável de retorno não utilizada.
          -- Existe para satisfazer exigência da interface.
          pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
          ROLLBACK;
        WHEN OTHERS THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := 'Erro geral em Consulta de Prazos: ' || SQLERRM;

          -- Carregar XML padrão para variável de retorno não utilizada.
          -- Existe para satisfazer exigência da interface.
          pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
          ROLLBACK;
    END;

  END pc_carrega_perren_txfixa;



  /* Rotina referente a consulta cooperativas */
  PROCEDURE pc_carrega_coperativa(pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                 ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                 ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                 ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                 ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                 ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
  BEGIN
  
    /* .............................................................................

     Programa: pc_carrega_coperativa
     Sistema : Novos Produtos de Captação
     Sigla   : APLI
     Autor   : Carlos Rafael Tanholi
     Data    : Julho/14.                    Ultima atualizacao: 10/07/2014

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina de consulta coperativas.

     Observacao: -----

     Alteracoes: -----
     ..............................................................................*/ 
    DECLARE
          
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      vr_contador INTEGER := 0;
      
      -- Variaveis de log
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);       
      
      -- Selecionar cooperativas de credito
      CURSOR cr_crapcop (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
      SELECT
        cop.cdcooper,
        cop.nmrescop
      FROM
       crapcop cop
      WHERE
       cop.cdcooper = pr_cdcooper OR pr_cdcooper = 3 AND
       cop.flgativo = 1;
      
       rw_crapcop cr_crapcop%ROWTYPE;

      BEGIN
        
        gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                                ,pr_cdcooper => vr_cdcooper
                                ,pr_nmdatela => vr_nmdatela
                                ,pr_nmeacao  => vr_nmeacao
                                ,pr_cdagenci => vr_cdagenci
                                ,pr_nrdcaixa => vr_nrdcaixa
                                ,pr_idorigem => vr_idorigem
                                ,pr_cdoperad => vr_cdoperad
                                ,pr_dscritic => vr_dscritic);

        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;
   
        -- Criar cabeçalho do XML
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');

        OPEN cr_crapcop(pr_cdcooper => vr_cdcooper);
          
        LOOP
          FETCH cr_crapcop INTO rw_crapcop;
          
          -- SAI DO LOOP QUANDO CHEGAR AO FIM DOS REGISTROS
          EXIT WHEN cr_crapcop%NOTFOUND; 
          
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados'   , pr_posicao => 0     , pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'cdcooper', pr_tag_cont => rw_crapcop.cdcooper, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nmrescop', pr_tag_cont => rw_crapcop.nmrescop, pr_des_erro => vr_dscritic);
          vr_contador := vr_contador + 1;                                
          
        END LOOP;     

        CLOSE cr_crapcop;

    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em Consulta de Produtos: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;

  END pc_carrega_coperativa;


  /* Rotina referente a consulta cooperativas */
  PROCEDURE pc_lista_movimentacao_carteira(pr_cdcooper IN crapcop.cdcooper%type   --> Código da Cooperativa                
                                          ,pr_dtmvtolt IN VARCHAR2                --> Data do Movimento
                                          ,pr_nrregist IN PLS_INTEGER             --> Numero de Registros da Paginacao
                                          ,pr_nriniseq IN PLS_INTEGER             --> Numero de inicio de sequencia da paginacao
                                          ,pr_xmllog   IN VARCHAR2                --> XML com informações de LOG
                                          ,pr_cdcritic OUT PLS_INTEGER            --> Código da crítica
                                          ,pr_dscritic OUT VARCHAR2               --> Descrição da crítica
                                          ,pr_retxml   IN OUT NOCOPY XMLType      --> Arquivo de retorno do XML
                                          ,pr_nmdcampo OUT VARCHAR2               --> Nome do campo com erro
                                          ,pr_des_erro OUT VARCHAR2) IS           --> Erros do processo
  BEGIN
  
    /* .............................................................................

     Programa: pc_lista_movimentacao_carteira
     Sistema : Novos Produtos de Captação
     Sigla   : APLI
     Autor   : Carlos Rafael Tanholi
     Data    : Julho/14.                    Ultima atualizacao: 14/07/2014

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina de consulta de movimentos da carteira.

     Observacao: -----

     Alteracoes: -----
     ..............................................................................*/ 
    DECLARE
          
      -- Tratamento de erros
      vr_exc_saida EXCEPTION;     
      -- variavel de nome do produto
      vr_nmprodut crapcpc.nmprodut%TYPE;
      -- variavel de total aplicado no dia
      vr_vlaplica craprac.vlaplica%TYPE := 0;
      -- variavel de total de resgates no dia
      vr_vlresgat craprga.vlresgat%TYPE;
      -- variavel de total de saldo das aplicacoes
      vr_sldaplic NUMBER(14,2);
      -- variaveis de retorno pre|pos-fixados
      vr_vlsldtot NUMBER(20,8);
      vr_vlsldrgt NUMBER(20,8);     
      vr_vlultren NUMBER(20,8);
      vr_vlrentot NUMBER(20,8);
      vr_vlrevers NUMBER(20,8);
      vr_vlrdirrf NUMBER(20,8);  
      vr_percirrf NUMBER(20,8); 
      vr_vlbascal NUMBER(20,8); 
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      vr_dtmvtolt DATE;
      vr_contador INTEGER := 0; 
      vr_auxconta INTEGER := 0;
      
      -- Selecionar os produtos
      CURSOR cr_crapcpc IS
      
        SELECT
          cdprodut
          ,nmprodut
        FROM
         crapcpc;
      
       rw_crapcpc cr_crapcpc%ROWTYPE;
       
      -- Selecionar o total aplicado e saldo das aplicacoes
      CURSOR cr_craprac (pr_cdcooper IN crapcop.cdcooper%type                   
                        ,pr_dtmvtolt IN crapdat.dtmvtolt%type
                        ,pr_cdprodut IN crapcpc.cdprodut%type) IS
        SELECT 
           craprac.vlaplica
          ,crapcpc.idtippro
          ,craprac.cdcooper
          ,craprac.nrdconta
          ,craprac.nraplica
          ,craprac.dtmvtolt
          ,craprac.txaplica          
          ,crapcpc.cddindex
          ,craprac.qtdiacar
          ,crapcpc.idtxfixa
        FROM craprac,crapcpc
        WHERE craprac.cdprodut = crapcpc.cdprodut
          AND (pr_cdcooper = 0 OR craprac.cdcooper = pr_cdcooper) 
          AND (pr_dtmvtolt IS NULL OR craprac.dtmvtolt = pr_dtmvtolt)
          AND craprac.cdprodut = pr_cdprodut;
               
       rw_craprac cr_craprac%ROWTYPE;       
       
       --Selecionar o total de resgates
      CURSOR cr_craprga (pr_cdcooper IN crapcop.cdcooper%type                   
                        ,pr_dtmvtolt IN crapdat.dtmvtolt%type
                        ,pr_cdprodut IN crapcpc.cdprodut%type) IS       
         SELECT 
           NVL(SUM(craprga.vlresgat),0) AS vlresgat
         FROM 
           craprga
           ,craprac 
         WHERE craprga.cdcooper = craprac.cdcooper
           AND craprga.nrdconta = craprac.nrdconta
           AND (pr_cdcooper = 0 OR craprga.cdcooper = pr_cdcooper) 
           AND craprga.dtresgat = pr_dtmvtolt  
           AND craprga.idresgat = 1
           AND craprac.cdprodut = pr_cdprodut;
       
       rw_craprga cr_craprga%ROWTYPE;              
       
      BEGIN
        
        vr_dtmvtolt := to_date(pr_dtmvtolt, 'dd/mm/RRRR');                
       
        -- Criar cabeçalho do XML
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'reg', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
        --Busca produtos cadastrados
        OPEN cr_crapcpc;
          
        LOOP -- Percorre os varios produtos
          FETCH cr_crapcpc INTO rw_crapcpc;
          -- armazena o nome 
          vr_nmprodut := rw_crapcpc.nmprodut;
          -- valor aplicado no dia
          vr_vlaplica := 0;
          
          -- SAI DO LOOP QUANDO CHEGAR AO FIM DOS REGISTROS
          EXIT WHEN cr_crapcpc%NOTFOUND; 
          
          -- calcula o total aplicado no dia
          OPEN cr_craprac(pr_cdcooper => pr_cdcooper
                         ,pr_dtmvtolt => vr_dtmvtolt
                         ,pr_cdprodut => rw_crapcpc.cdprodut);

          LOOP -- percorre as aplicacoes cadastradas no dia
            FETCH cr_craprac INTO rw_craprac;
                           
            -- SAI DO LOOP QUANDO CHEGAR AO FIM DOS REGISTROS
            EXIT WHEN cr_craprac%NOTFOUND; 
            
            vr_vlaplica := vr_vlaplica + rw_craprac.vlaplica;  
            
          END LOOP;    

          CLOSE cr_craprac;
          
          -- saldo da aplicacao
          vr_sldaplic := 0;            
                    
          -- calcula o saldo da aplicacao
          OPEN cr_craprac(pr_cdcooper => pr_cdcooper
                         ,pr_dtmvtolt => NULL
                         ,pr_cdprodut => rw_crapcpc.cdprodut);

          LOOP -- Nesta coluna todas as aplicações ativas devem ser lidas
            FETCH cr_craprac INTO rw_craprac;
                           
            -- SAI DO LOOP QUANDO CHEGAR AO FIM DOS REGISTROS
            EXIT WHEN cr_craprac%NOTFOUND;           
          
            IF rw_craprac.idtippro = 1 THEN -- pre-fixada
              APLI0006.pc_posicao_saldo_aplicacao_pre(pr_cdcooper => rw_craprac.cdcooper --> Código da Cooperativa
                                                     ,pr_nrdconta => rw_craprac.nrdconta --> Número da Conta
                                                     ,pr_nraplica => rw_craprac.nraplica --> Número da Aplicação
                                                     ,pr_dtiniapl => rw_craprac.dtmvtolt --> Data de Início da Aplicação
                                                     ,pr_txaplica => rw_craprac.txaplica --> Taxa da Aplicação
                                                     ,pr_idtxfixa => rw_craprac.idtxfixa --> Taxa Fixa (1-SIM/2-NAO)
                                                     ,pr_cddindex => rw_craprac.cddindex --> Código do Indexador
                                                     ,pr_qtdiacar => rw_craprac.qtdiacar --> Dias de Carência
                                                     ,pr_idgravir => 0                   --> Gravar Imunidade IRRF (0-Não/1-Sim)
                                                     ,pr_idaplpgm => 0                   --> Aplicação Programada  (0-Não/1-Sim)
                                                     ,pr_dtinical => rw_craprac.dtmvtolt --> Data Inicial Cálculo
                                                     ,pr_dtfimcal => vr_dtmvtolt         --> Data Final Cálculo
                                                     ,pr_idtipbas => 2                   --> Tipo Base Cálculo – 1-Parcial/2-Total)
                                                     ,pr_vlbascal => vr_vlbascal         --> Valor Base Cálculo (Retorna valor proporcional da base de cálculo de entrada)
                                                     ,pr_vlsldtot => vr_vlsldtot         --> Saldo Total da Aplicação
                                                     ,pr_vlsldrgt => vr_vlsldrgt         --> Saldo Total para Resgate
                                                     ,pr_vlultren => vr_vlultren         --> Valor Último Rendimento
                                                     ,pr_vlrentot => vr_vlrentot         --> Valor Rendimento Total
                                                     ,pr_vlrevers => vr_vlrevers         --> Valor de Reversão
                                                     ,pr_vlrdirrf => vr_vlrdirrf         --> Valor do IRRF
                                                     ,pr_percirrf => vr_percirrf         --> Percentual do IRRF
                                                     ,pr_cdcritic => vr_cdcritic         --> Código da crítica
                                                     ,pr_dscritic => vr_dscritic);       --> Descrição da crítica      
                  
            ELSIF rw_craprac.idtippro = 2 THEN
                
              APLI0006.pc_posicao_saldo_aplicacao_pos(pr_cdcooper => rw_craprac.cdcooper --> Código da Cooperativa
                                                     ,pr_nrdconta => rw_craprac.nrdconta --> Número da Conta
                                                     ,pr_nraplica => rw_craprac.nraplica --> Número da Aplicação
                                                     ,pr_dtiniapl => rw_craprac.dtmvtolt --> Data de Início da Aplicação
                                                     ,pr_txaplica => rw_craprac.txaplica --> Taxa da Aplicação
                                                     ,pr_idtxfixa => rw_craprac.idtxfixa --> Taxa Fixa (1-SIM/2-NAO)
                                                     ,pr_cddindex => rw_craprac.cddindex --> Código do Indexador
                                                     ,pr_qtdiacar => rw_craprac.qtdiacar --> Dias de Carência
                                                     ,pr_idgravir => 0                   --> Gravar Imunidade IRRF (0-Não/1-Sim)
                                                     ,pr_idaplpgm => 0                   --> Aplicação Programada  (0-Não/1-Sim)
                                                     ,pr_dtinical => rw_craprac.dtmvtolt --> Data Inicial Cálculo
                                                     ,pr_dtfimcal => vr_dtmvtolt         --> Data Final Cálculo
                                                     ,pr_idtipbas => 2                   --> Tipo Base Cálculo – 1-Parcial/2-Total)
                                                     ,pr_vlbascal => vr_vlbascal         --> Valor Base Cálculo (Retorna valor proporcional da base de cálculo de entrada)
                                                     ,pr_vlsldtot => vr_vlsldtot         --> Saldo Total da Aplicação
                                                     ,pr_vlsldrgt => vr_vlsldrgt         --> Saldo Total para Resgate
                                                     ,pr_vlultren => vr_vlultren         --> Valor Último Rendimento
                                                     ,pr_vlrentot => vr_vlrentot         --> Valor Rendimento Total
                                                     ,pr_vlrevers => vr_vlrevers         --> Valor de Reversão
                                                     ,pr_vlrdirrf => vr_vlrdirrf         --> Valor do IRRF
                                                     ,pr_percirrf => vr_percirrf         --> Percentual do IRRF
                                                     ,pr_cdcritic => vr_cdcritic         --> Código da crítica
                                                     ,pr_dscritic => vr_dscritic);       --> Descrição da crítica 
                  
            END IF;       
            
            vr_sldaplic := vr_sldaplic + NVL(vr_vlsldtot,0);
          
          END LOOP;          
          
          CLOSE cr_craprac;
          
          -- valor total resgatado no dia
          vr_vlresgat := 0;
          
          OPEN cr_craprga(pr_cdcooper => pr_cdcooper
                         ,pr_dtmvtolt => vr_dtmvtolt
                         ,pr_cdprodut => rw_crapcpc.cdprodut);

          FETCH cr_craprga INTO rw_craprga;
                  
          IF cr_craprga%NOTFOUND THEN
            CLOSE cr_craprga;
          ELSE
            CLOSE cr_craprga;            
            vr_vlresgat  := rw_craprga.vlresgat;
          END IF;  

          vr_contador := vr_contador + 1;

          IF ((vr_contador >= pr_nriniseq) AND (vr_contador < (pr_nriniseq + pr_nrregist))) THEN
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'reg', pr_posicao => 0     , pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'nmprodut', pr_tag_cont => vr_nmprodut, pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'vlaplica', pr_tag_cont => TO_CHAR(vr_vlaplica, 'FM999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=,.'), pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'vlresgat', pr_tag_cont => TO_CHAR(vr_vlresgat, 'FM999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=,.'), pr_des_erro => vr_dscritic);                            
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'salapli', pr_tag_cont => TO_CHAR(vr_sldaplic, 'FM999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=,.'), pr_des_erro => vr_dscritic);
            vr_auxconta := vr_auxconta + 1;
          END IF;
                   
        END LOOP; -- LOOP de PRODUTOS
        -- fecha o cursor de produtos
        CLOSE cr_crapcpc;

        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'QTDREGIST', pr_tag_cont => TO_CHAR(vr_contador), pr_des_erro => vr_dscritic);

    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em Consulta de Produtos: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;

  END pc_lista_movimentacao_carteira;

 
   /* Rotina referente a consulta de politicas relacionadas ao produto que ainda nao estao cadastradas para a cooperativa */
  PROCEDURE pc_lista_politicas_cooperativa(pr_cdprodut IN crapmpc.cdprodut%TYPE --> Codigo do Produto 
                                          ,pr_cdcooper IN crapcop.cdcooper%TYPE --> Codigo da Cooperativa
                                          ,pr_nrregist IN PLS_INTEGER           --> Numero de Registros da Paginacao
                                          ,pr_nriniseq IN PLS_INTEGER           --> Numero de inicio de sequencia da paginacao    
                                          ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                          ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                          ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                          ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                          ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                          ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
  BEGIN
  
    /* .............................................................................

     Programa: pc_lista_politicas_cooperativa
     Sistema : Novos Produtos de Captação
     Sigla   : APLI
     Autor   : Carlos Rafael Tanholi
     Data    : dezembro/14.                    Ultima atualizacao: 10/12/2014

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina de consulta de politicas do produto nao relacionadas ha cooperativa.

     Observacao: -----

     Alteracoes: -----
     ..............................................................................*/ 
    DECLARE
          
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);
      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
      -- contadores
      vr_contador INTEGER := 0; 
      vr_auxconta INTEGER := 0;
      -- Variaveis de log
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);       
      
      -- cursor para recuperar modalidades do produto
      CURSOR cr_crapmpc(pr_cdprodut IN crapcpc.nmprodut%TYPE
             	         ,pr_cdcooper IN crapcop.cdcooper%TYPE) IS      
      SELECT
         cpc.cdprodut
        ,ind.nmdindex              
        ,mpc.cdmodali
        ,mpc.qtdiacar
        ,mpc.qtdiaprz  
        ,mpc.vlrfaixa
        ,mpc.vlperren
        ,mpc.vltxfixa              
      FROM
        crapcpc cpc
       ,crapmpc mpc
       ,crapind ind       
      WHERE cpc.idsitpro = 1
        AND cpc.cdprodut = mpc.cdprodut
        AND cpc.cddindex = ind.cddindex
        AND mpc.cdmodali NOT IN (SELECT cdmodali FROM crapdpc dpc WHERE dpc.cdcooper = pr_cdcooper)  
        AND cpc.cdprodut = pr_cdprodut
      ORDER BY cpc.cdprodut,mpc.qtdiacar,mpc.qtdiaprz,mpc.vlrfaixa;
              
      rw_crapmpc cr_crapmpc%ROWTYPE; 

      BEGIN
        
        gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                                ,pr_cdcooper => vr_cdcooper
                                ,pr_nmdatela => vr_nmdatela
                                ,pr_nmeacao  => vr_nmeacao
                                ,pr_cdagenci => vr_cdagenci
                                ,pr_nrdcaixa => vr_nrdcaixa
                                ,pr_idorigem => vr_idorigem
                                ,pr_cdoperad => vr_cdoperad
                                ,pr_dscritic => vr_dscritic);

        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;
   
        -- Criar cabeçalho do XML
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'reg', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);            

        --Busca modalidades do produto
        OPEN cr_crapmpc(pr_cdprodut, pr_cdcooper);
          
        LOOP
          FETCH cr_crapmpc INTO rw_crapmpc;
          
          -- SAI DO LOOP QUANDO CHEGAR AO FIM DOS REGISTROS
          EXIT WHEN cr_crapmpc%NOTFOUND; 
          
          vr_contador := vr_contador + 1;          
          IF ((vr_contador >= pr_nriniseq) AND (vr_contador < (pr_nriniseq + pr_nrregist))) THEN          
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'reg', pr_posicao => 0     , pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);            
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'cdmodali', pr_tag_cont => rw_crapmpc.cdmodali, pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'nmdindex', pr_tag_cont => rw_crapmpc.nmdindex, pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'qtdiacar', pr_tag_cont => rw_crapmpc.qtdiacar, pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'qtdiaprz', pr_tag_cont => rw_crapmpc.qtdiaprz, pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'vlrfaixa', pr_tag_cont => TO_CHAR(rw_crapmpc.vlrfaixa, 'FM999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=,.'), pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'vlperren', pr_tag_cont => TRIM(TO_CHAR(rw_crapmpc.vlperren, '999G990D00000000', 'NLS_NUMERIC_CHARACTERS=,.')), pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'vltxfixa', pr_tag_cont => TRIM(TO_CHAR(rw_crapmpc.vltxfixa, '999G990D00000000', 'NLS_NUMERIC_CHARACTERS=,.')), pr_des_erro => vr_dscritic);
            vr_auxconta := vr_auxconta + 1;
          END IF;                                
          
        END LOOP;     

        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'QTDREGIST', pr_tag_cont => TO_CHAR(vr_contador), pr_des_erro => vr_dscritic);
        CLOSE cr_crapmpc;

    EXCEPTION
      WHEN vr_exc_saida THEN          
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em Consulta de Modalidades: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;

  END pc_lista_politicas_cooperativa;
 
 
 
  /* Rotina referente a consulta de modalidades do produto */
  PROCEDURE pc_lista_modalidade_produto(pr_cdprodut IN crapmpc.cdprodut%TYPE --> Codigo do Produto 
                                       ,pr_nrregist IN PLS_INTEGER           --> Numero de Registros da Paginacao
                                       ,pr_nriniseq IN PLS_INTEGER           --> Numero de inicio de sequencia da paginacao    
                                       ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                       ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                       ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                       ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                       ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                       ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
  BEGIN
  
    /* .............................................................................

     Programa: pc_lista_modalidade_produto
     Sistema : Novos Produtos de Captação
     Sigla   : APLI
     Autor   : Carlos Rafael Tanholi
     Data    : agosto/14.                    Ultima atualizacao: 5/08/2014

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina de consulta de modalidades do produto.

     Observacao: -----

     Alteracoes: -----
     ..............................................................................*/ 
    DECLARE
          
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);
      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
      -- contadores
      vr_contador INTEGER := 0; 
      vr_auxconta INTEGER := 0;
      -- Variaveis de log
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);       
      
      -- cursor para recuperar modalidades do produto
      CURSOR cr_crapmpc(pr_cdprodut IN crapcpc.nmprodut%TYPE) IS      
      SELECT
         mpc.cdmodali
        ,ind.nmdindex 
        ,mpc.qtdiacar
        ,mpc.qtdiaprz
        ,mpc.vlrfaixa
        ,mpc.vlperren
        ,mpc.vltxfixa
      FROM
        crapmpc mpc
       ,crapcpc cpc
       ,crapind ind
      WHERE cpc.cdprodut = mpc.cdprodut
        AND ind.cddindex = cpc.cddindex    
        AND mpc.cdprodut = pr_cdprodut;
              
      rw_crapmpc cr_crapmpc%ROWTYPE; 

      BEGIN
        
        gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                                ,pr_cdcooper => vr_cdcooper
                                ,pr_nmdatela => vr_nmdatela
                                ,pr_nmeacao  => vr_nmeacao
                                ,pr_cdagenci => vr_cdagenci
                                ,pr_nrdcaixa => vr_nrdcaixa
                                ,pr_idorigem => vr_idorigem
                                ,pr_cdoperad => vr_cdoperad
                                ,pr_dscritic => vr_dscritic);

        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;
   
        -- Criar cabeçalho do XML
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'reg', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);            

        --Busca modalidades do produto
        OPEN cr_crapmpc(pr_cdprodut => pr_cdprodut);
          
        LOOP
          FETCH cr_crapmpc INTO rw_crapmpc;
          
          -- SAI DO LOOP QUANDO CHEGAR AO FIM DOS REGISTROS
          EXIT WHEN cr_crapmpc%NOTFOUND; 
          
          vr_contador := vr_contador + 1;          
          IF ((vr_contador >= pr_nriniseq) AND (vr_contador < (pr_nriniseq + pr_nrregist))) THEN          
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'reg', pr_posicao => 0     , pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);            
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'cdmodali', pr_tag_cont => rw_crapmpc.cdmodali, pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'nmdindex', pr_tag_cont => rw_crapmpc.nmdindex, pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'qtdiacar', pr_tag_cont => rw_crapmpc.qtdiacar, pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'qtdiaprz', pr_tag_cont => rw_crapmpc.qtdiaprz, pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'vlrfaixa', pr_tag_cont => TO_CHAR(rw_crapmpc.vlrfaixa, 'FM999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=,.'), pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'vlperren', pr_tag_cont => TRIM(TO_CHAR(rw_crapmpc.vlperren, '999G990D00000000', 'NLS_NUMERIC_CHARACTERS=,.')), pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'vltxfixa', pr_tag_cont => TRIM(TO_CHAR(rw_crapmpc.vltxfixa, '999G990D00000000', 'NLS_NUMERIC_CHARACTERS=,.')), pr_des_erro => vr_dscritic);
            vr_auxconta := vr_auxconta + 1;
          END IF;                                
          
        END LOOP;     

        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'QTDREGIST', pr_tag_cont => TO_CHAR(vr_contador), pr_des_erro => vr_dscritic);
        CLOSE cr_crapmpc;

    EXCEPTION
      WHEN vr_exc_saida THEN          
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em Consulta de Modalidades: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;

  END pc_lista_modalidade_produto;


  /* Rotina referente a consulta de modalidades do produto */
  PROCEDURE pc_lista_modalidade_coope(pr_cdprodut IN crapmpc.cdprodut%TYPE --> Codigo do Produto 
                                     ,pr_cdcooper IN crapcop.cdcooper%TYPE --> Codigo da Cooperativa
                                     ,pr_idsitmod IN crapdpc.idsitmod%TYPE --> Situacao da Modalidade (Bloqueada/Desbloqueada)
                                     ,pr_nrregist IN PLS_INTEGER           --> Numero de Registros da Paginacao
                                     ,pr_nriniseq IN PLS_INTEGER           --> Numero de inicio de sequencia da paginacao    
                                     ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                     ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                     ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                     ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                     ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                     ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
  BEGIN
  
    /* .............................................................................
    
     Programa: pc_lista_modalidade_cooperativa
     Sistema : Novos Produtos de Captação
     Sigla   : APLI
     Autor   : Carlos Rafael Tanholi
     Data    : agosto/14.                    Ultima atualizacao: 13/08/2014

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina de consulta de modalidades vinculadas as cooperativas.

     Observacao: -----

     Alteracoes: -----
     ..............................................................................*/ 
    DECLARE
          
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);
      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
      -- contadores
      vr_contador INTEGER := 0; 
      vr_auxconta INTEGER := 0;
      -- Variaveis de log
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);       
      
      -- cursor para recuperar modalidades vinculadas a cooperativa
      CURSOR cr_crapmpc(pr_cdprodut IN crapcpc.nmprodut%TYPE
                       ,pr_cdcooper IN crapdpc.cdcooper%TYPE
                       ,pr_idsitmod IN crapdpc.idsitmod%TYPE) IS      
      SELECT
         mpc.cdmodali
        ,ind.nmdindex 
        ,mpc.qtdiacar
        ,mpc.qtdiaprz
        ,mpc.vlrfaixa
        ,mpc.vlperren
        ,mpc.vltxfixa
      FROM
         crapdpc dpc
        ,crapmpc mpc
        ,crapcpc cpc
        ,crapind ind
      WHERE cpc.cdprodut = mpc.cdprodut      
        AND ind.cddindex = cpc.cddindex
        AND dpc.cdmodali = mpc.cdmodali            
        AND mpc.cdprodut = pr_cdprodut
        AND dpc.cdcooper = pr_cdcooper
        AND (dpc.idsitmod = pr_idsitmod 
         OR pr_idsitmod = 0);
              
      rw_crapmpc cr_crapmpc%ROWTYPE; 

      BEGIN
        
        gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                                ,pr_cdcooper => vr_cdcooper
                                ,pr_nmdatela => vr_nmdatela
                                ,pr_nmeacao  => vr_nmeacao
                                ,pr_cdagenci => vr_cdagenci
                                ,pr_nrdcaixa => vr_nrdcaixa
                                ,pr_idorigem => vr_idorigem
                                ,pr_cdoperad => vr_cdoperad
                                ,pr_dscritic => vr_dscritic);

        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;
   
        -- Criar cabeçalho do XML
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'reg', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);            

        --Busca modalidades do produto
        OPEN cr_crapmpc(pr_cdprodut => pr_cdprodut
                       ,pr_cdcooper => pr_cdcooper
                       ,pr_idsitmod => pr_idsitmod);
          
        LOOP
          FETCH cr_crapmpc INTO rw_crapmpc;
          
          -- SAI DO LOOP QUANDO CHEGAR AO FIM DOS REGISTROS
          EXIT WHEN cr_crapmpc%NOTFOUND; 
          
          vr_contador := vr_contador + 1;          
          IF ((vr_contador >= pr_nriniseq) AND (vr_contador < (pr_nriniseq + pr_nrregist))) THEN          
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'reg', pr_posicao => 0     , pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);            
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'cdmodali', pr_tag_cont => rw_crapmpc.cdmodali, pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'nmdindex', pr_tag_cont => rw_crapmpc.nmdindex, pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'qtdiacar', pr_tag_cont => rw_crapmpc.qtdiacar, pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'qtdiaprz', pr_tag_cont => rw_crapmpc.qtdiaprz, pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'vlrfaixa', pr_tag_cont => TO_CHAR(rw_crapmpc.vlrfaixa, 'FM999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=,.'), pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'vlperren', pr_tag_cont => TO_CHAR(rw_crapmpc.vlperren, '999G990D00000000', 'NLS_NUMERIC_CHARACTERS=,.'), pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'vltxfixa', pr_tag_cont => TO_CHAR(rw_crapmpc.vltxfixa, '999G990D00000000', 'NLS_NUMERIC_CHARACTERS=,.'), pr_des_erro => vr_dscritic);
            vr_auxconta := vr_auxconta + 1;
          END IF;                                
          
        END LOOP;     

        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'QTDREGIST', pr_tag_cont => TO_CHAR(vr_contador), pr_des_erro => vr_dscritic);
        CLOSE cr_crapmpc;

    EXCEPTION
      WHEN vr_exc_saida THEN          
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em Consulta de Modalidades: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;

  END pc_lista_modalidade_coope;

 
 
/* Rotina referente a consulta de historico do produto */
  PROCEDURE pc_lista_historico_produto(pr_cdprodut IN crapmpc.cdprodut%TYPE --> Codigo do Produto 
                                      ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                      ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                      ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                      ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                      ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                      ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
  BEGIN
  
    /* .............................................................................
    
     Programa: pc_lista_historico_produto
     Sistema : Novos Produtos de Captação
     Sigla   : APLI
     Autor   : Carlos Rafael Tanholi
     Data    : agosto/14.                    Ultima atualizacao: 13/08/2014

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina de consulta de historico do produto.

     Observacao: -----

     Alteracoes: -----
     ..............................................................................*/ 
    DECLARE
          
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);
      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
      
      -- cursor para recuperar historico do produto
      CURSOR cr_crapcpc(pr_cdprodut IN crapcpc.nmprodut%TYPE) IS      
      SELECT cpc.cdhscacc
            ,cpc.cdhsvrcc 
            ,cpc.cdhsraap
            ,cpc.cdhsnrap
            ,cpc.cdhsprap
            ,cpc.cdhsrvap
            ,cpc.cdhsrdap
            ,cpc.cdhsirap
            ,cpc.cdhsrgap
            ,cpc.cdhsvtap
        FROM crapcpc cpc
       WHERE cpc.cdprodut = pr_cdprodut
             ;
              
      rw_crapcpc cr_crapcpc%ROWTYPE; 

      BEGIN
   
        -- Criar cabeçalho do XML
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);            

        --Busca historico do produto
        OPEN cr_crapcpc(pr_cdprodut => pr_cdprodut);

        FETCH cr_crapcpc INTO rw_crapcpc;          
                  
        IF cr_crapcpc%NOTFOUND THEN
           CLOSE cr_crapcpc;
        ELSE
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'cdhscacc', pr_tag_cont => rw_crapcpc.cdhscacc, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'cdhsvrcc', pr_tag_cont => rw_crapcpc.cdhsvrcc, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'cdhsraap', pr_tag_cont => rw_crapcpc.cdhsraap, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'cdhsnrap', pr_tag_cont => rw_crapcpc.cdhsnrap, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'cdhsprap', pr_tag_cont => rw_crapcpc.cdhsprap, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'cdhsrvap', pr_tag_cont => rw_crapcpc.cdhsrvap, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'cdhsrdap', pr_tag_cont => rw_crapcpc.cdhsrdap, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'cdhsirap', pr_tag_cont => rw_crapcpc.cdhsirap, pr_des_erro => vr_dscritic);          
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'cdhsrgap', pr_tag_cont => rw_crapcpc.cdhsrgap, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'cdhsvtap', pr_tag_cont => rw_crapcpc.cdhsvtap, pr_des_erro => vr_dscritic);
          
          CLOSE cr_crapcpc;          
        END IF;                                

    EXCEPTION
      WHEN vr_exc_saida THEN          
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em Consulta de Historico do Produto: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;

  END pc_lista_historico_produto; 
 

/* Rotina referente a consulta de produtos cadastrados */
PROCEDURE pc_lista_nomenclatura_produto(pr_cdprodut IN crapcpc.cdprodut%TYPE --> Codigo do Produto
                                       ,pr_cdnomenc IN crapnpc.cdnomenc%TYPE --> Codigo da Nomenclatura
                                       ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                       ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                       ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                       ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                       ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                       ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
BEGIN
  
  /* .............................................................................

   Programa: pc_lista_nomenclatura_produto
   Sistema : Novos Produtos de Captação
   Sigla   : APLI
   Autor   : Carlos Rafael Tanholi
   Data    : Agosto/14.                    Ultima atualizacao: 26/08/2014

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado

   Objetivo  : Rotina de consulta as nomenclaturas de produtos cadastrados.

   Observacao: -----

   Alteracoes: 
   ..............................................................................*/ 
  DECLARE
          
    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(10000);

    -- Tratamento de erros
    vr_exc_saida EXCEPTION;

    vr_contador INTEGER := 0;
      
    -- Seleciona os produtos de captacao
    CURSOR cr_crapcpc (pr_cdprodut IN crapcpc.cdprodut%TYPE
                      ,pr_cdnomenc IN crapnpc.cdnomenc%TYPE) IS
    SELECT
      npc.cdnomenc,
      npc.cdprodut,
      npc.dsnomenc,
      npc.idsitnom,
      npc.qtmincar,
      npc.qtmaxcar,
      npc.vlminapl,
      npc.vlmaxapl
     FROM crapcpc cpc
         ,crapnpc npc
    WHERE cpc.idsitpro = 1
      AND cpc.cdprodut = npc.cdprodut    
      AND cpc.cdprodut = pr_cdprodut
      AND (npc.cdnomenc = pr_cdnomenc 
       OR pr_cdnomenc = 0);
      
     rw_crapcpc cr_crapcpc%ROWTYPE;


      -- Verificar se existe aplicacao para o produto com aquela nomenclatura
      CURSOR cr_craprac(pr_cdprodut IN crapcpc.cdprodut%TYPE
                       ,pr_cdnomenc IN crapnpc.cdnomenc%TYPE) IS
      SELECT craprac.nrdconta
        FROM craprac
            ,crapcop
       WHERE craprac.cdcooper = crapcop.cdcooper 
         AND crapcop.flgativo = 1
         AND craprac.cdprodut = pr_cdprodut
         AND craprac.cdnomenc = pr_cdnomenc;    

      rw_craprac cr_craprac%ROWTYPE;


    BEGIN
        
      -- Criar cabeçalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
    
      OPEN cr_crapcpc(pr_cdprodut, pr_cdnomenc);
        
      IF ( pr_cdnomenc > 0 ) THEN 
          
        LOOP
          FETCH cr_crapcpc INTO rw_crapcpc;
            
          -- SAI DO LOOP QUANDO CHEGAR AO FIM DOS REGISTROS
          EXIT WHEN cr_crapcpc%NOTFOUND; 

          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados'   , pr_posicao => 0     , pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'cdnomenc', pr_tag_cont => rw_crapcpc.cdnomenc, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'cdprodut', pr_tag_cont => rw_crapcpc.cdprodut, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'dsnomenc', pr_tag_cont => rw_crapcpc.dsnomenc, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'idsitnom', pr_tag_cont => rw_crapcpc.idsitnom, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'qtmincar', pr_tag_cont => rw_crapcpc.qtmincar, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'qtmaxcar', pr_tag_cont => rw_crapcpc.qtmaxcar, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'vlminapl', pr_tag_cont => TO_CHAR(rw_crapcpc.vlminapl, 'FM999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=,.'), pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'vlmaxapl', pr_tag_cont => TO_CHAR(rw_crapcpc.vlmaxapl, 'FM999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=,.'), pr_des_erro => vr_dscritic);          
          
          vr_contador := vr_contador + 1;                                
            
        END LOOP;     
        
        -- consulta a existencia de uma aplicacao
        OPEN cr_craprac(pr_cdprodut, pr_cdnomenc);       
        FETCH cr_craprac INTO rw_craprac;
                
        IF cr_craprac%NOTFOUND THEN
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'aplicacao', pr_tag_cont => 'N', pr_des_erro => vr_dscritic);
        ELSE 
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'aplicacao', pr_tag_cont => 'S', pr_des_erro => vr_dscritic);
        END IF;          
        CLOSE cr_craprac;        
        
      ELSE 
          
        LOOP
          FETCH cr_crapcpc INTO rw_crapcpc;
            
          -- SAI DO LOOP QUANDO CHEGAR AO FIM DOS REGISTROS
          EXIT WHEN cr_crapcpc%NOTFOUND; 
            
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados'   , pr_posicao => 0     , pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'cdnomenc', pr_tag_cont => rw_crapcpc.cdnomenc, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'dsnomenc', pr_tag_cont => rw_crapcpc.dsnomenc, pr_des_erro => vr_dscritic);
            
          vr_contador := vr_contador + 1;                                
            
        END LOOP;        
        
        
      END IF;         
        
      CLOSE cr_crapcpc;

      COMMIT;

  EXCEPTION
    WHEN vr_exc_saida THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;

      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
    WHEN OTHERS THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral em Consulta de Nomenclaturas de Produtos: ' || SQLERRM;

      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
  END;

END pc_lista_nomenclatura_produto;


  /* Rotina referente a nomenclaturas de produtos da tela PCAPTA */
  PROCEDURE pc_manter_nomenclatura_produto(pr_cddopcao IN VARCHAR2 --> Codigo do Opção
                                          ,pr_cdprodut IN crapnpc.cdprodut%TYPE --> Codigo do Produto
                                          ,pr_cdnomenc IN crapnpc.cdnomenc%TYPE --> Codigo Nomemclatura
                                          ,pr_dsnomenc IN crapnpc.dsnomenc%TYPE --> Nomemclatura
                                          ,pr_idsitnom IN crapnpc.idsitnom%TYPE --> Situacao da Nomenclatura
                                          ,pr_qtmincar IN crapnpc.qtmincar%TYPE --> Quantidade minima de carencia
                                          ,pr_qtmaxcar IN crapnpc.qtmaxcar%TYPE --> Quantidade maxima de carencia
                                          ,pr_vlminapl IN crapnpc.vlminapl%TYPE --> Valor minimo aplicacao
                                          ,pr_vlmaxapl IN crapnpc.vlmaxapl%TYPE --> Valor maximo aplicacao                                          
                                          ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                          ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                          ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                          ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                          ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                          ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
  BEGIN
  
    /* .............................................................................

     Programa: pc_manter_nomenclatura_produto
     Sistema : Novos Produtos de Captação
     Sigla   : APLI
     Autor   : Carlos Rafael Tanholi
     Data    : Agosto/14.                    Ultima atualizacao: 27/08/2014

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina de validacao de dados de nomenclatura de produto tela PCAPTA.

     Observacao: -----

     Alteracoes: 
     ..............................................................................*/ 
    DECLARE
          
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
      vr_null      EXCEPTION;

      -- Variaveis de log
      vr_cdcooper INTEGER := 0;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);
      
      -- codigo sequencial da nomenclatura
      vr_seqcdnom INTEGER := 0;
      -- variavel para LOG do nome do produto
      vr_nmprodut crapcpc.nmprodut%TYPE;
      
      vr_sitnom VARCHAR2(100) := 'ATIVO,INATIVO';      
      vr_idsitnom VARCHAR2(100) := '';
      
      -- Mensagem de log
      vr_dsmsglog VARCHAR2(4000); 
      
           
      -- Seleciona os produtos de captacao
      CURSOR cr_crapcpc (pr_cdprodut IN crapcpc.cdprodut%TYPE) IS
      SELECT
        cpc.cdprodut,
        cpc.nmprodut,
        cpc.idsitpro,
        cpc.cddindex,
        cpc.idtippro,
        cpc.idtxfixa,
        cpc.idacumul
      FROM
       crapcpc cpc
      WHERE
       cpc.cdprodut = pr_cdprodut;
      
       rw_crapcpc cr_crapcpc%ROWTYPE;      


      -- Verificar se existe carteira para o produto
      CURSOR cr_craprac_car(pr_cdprodut IN crapcpc.cdprodut%TYPE
                           ,pr_cdnomenc IN craprac.cdnomenc%TYPE) IS
      SELECT 
         craprac.nrdconta
      FROM 
         craprac
         ,crapcop
      WHERE craprac.cdcooper = crapcop.cdcooper 
        AND crapcop.flgativo = 1
        AND craprac.cdnomenc = pr_cdnomenc
        AND craprac.cdprodut = pr_cdprodut;    

      rw_craprac_car cr_craprac_car%ROWTYPE;


      -- Nao deve existir nomenclatura cadastrada com mesmo nome e ativa para o mesmo produto
      CURSOR cr_crapnpc(pr_cdprodut IN crapcpc.cdprodut%TYPE
                       ,pr_dsnomenc IN crapnpc.dsnomenc%TYPE
                       ,pr_cdnomenc IN crapnpc.cdnomenc%TYPE) IS
      SELECT npc.cdnomenc
        FROM crapcpc cpc
             ,crapnpc npc
       WHERE cpc.cdprodut = npc.cdprodut
         AND npc.idsitnom = 1
         AND npc.cdprodut = pr_cdprodut
         AND (npc.cdnomenc <> pr_cdnomenc 
          OR pr_cdnomenc = 0)
         AND npc.dsnomenc = pr_dsnomenc;

      rw_crapnpc cr_crapnpc%ROWTYPE;


      -- CURSOR PARA LOG DE NOMENCLATURAS
      CURSOR cr_crapnpc_log(pr_cdnomenc IN crapnpc.cdnomenc%TYPE) IS
      SELECT dsnomenc,
             idsitnom,
             qtmincar,
             qtmaxcar,
             vlminapl,
             vlmaxapl
        FROM    
             crapnpc
       WHERE cdnomenc = pr_cdnomenc;
       
       rw_crapnpc_log cr_crapnpc_log%ROWTYPE;


      -- valida a existencia da nomenclatura com mesma faixa de valor e carencia
      -- ou mesma carencia e faixas de valores em comum com ja existentes
      CURSOR cr_crapnpc_valcar(pr_qtmincar IN crapnpc.qtmincar%TYPE
                              ,pr_qtmaxcar IN crapnpc.qtmaxcar%TYPE
                              ,pr_vlminapl IN crapnpc.vlminapl%TYPE
                              ,pr_vlmaxapl IN crapnpc.vlmaxapl%TYPE
                              ,pr_cdprodut IN crapnpc.cdprodut%TYPE
                              ,pr_cdnomenc IN crapnpc.cdnomenc%TYPE) IS
      SELECT npc.cdnomenc
        FROM crapnpc npc
       WHERE npc.idsitnom = 1
         AND (
              (npc.qtmincar = pr_qtmincar AND npc.qtmaxcar = pr_qtmaxcar)
               AND (
                     (npc.vlminapl = pr_vlminapl AND npc.vlmaxapl = pr_vlmaxapl)
                      OR
                       ( pr_vlminapl BETWEEN npc.vlminapl AND npc.vlmaxapl 
                         OR 
                         pr_vlmaxapl BETWEEN npc.vlminapl AND npc.vlmaxapl 
                       )
                   )
             )
         AND ( npc.cdnomenc <> pr_cdnomenc OR pr_cdnomenc = 0 )     
         AND npc.cdprodut = pr_cdprodut;

      rw_crapnpc_valcar cr_crapnpc_valcar%ROWTYPE;


    BEGIN
      
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);    

            
      -- Criar cabeçalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
    
      IF pr_cdnomenc > 0 THEN
        -- Busca nomenclatura pelo codigo
        OPEN cr_crapnpc_log(pr_cdnomenc);

        FETCH cr_crapnpc_log INTO rw_crapnpc_log;
        
        IF cr_crapnpc_log%NOTFOUND THEN
          vr_cdcritic := 001;
          vr_dscritic := 'Nomenclatura inexistente.';
          
          RAISE vr_exc_saida;
          
        END IF;
        
        CLOSE cr_crapnpc_log;
        

      END IF;    	
      
    
   
      -- Verifica opcao
      CASE pr_cddopcao  
      
        WHEN 'V' THEN -- validacao

          -- cria no de validacao
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados'   , pr_posicao => 0     , pr_tag_nova => 'valida', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
                        
          -- valida a existencia do produto
          OPEN cr_crapcpc(pr_cdprodut);                  
            
          FETCH cr_crapcpc INTO rw_crapcpc;
             
          IF cr_crapcpc%NOTFOUND THEN
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'valida', pr_posicao => 0, pr_tag_nova => 'produto', pr_tag_cont => 'N', pr_des_erro => vr_dscritic);
          ELSE 
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'valida', pr_posicao => 0, pr_tag_nova => 'produto', pr_tag_cont => 'S', pr_des_erro => vr_dscritic);
          END IF;
          CLOSE cr_crapcpc; 
              
          -- valida a existencia da nomenclatura a (cadastrar/alterar) com status ativo
          OPEN cr_crapnpc(pr_cdprodut, pr_dsnomenc, pr_cdnomenc);                  
            
          FETCH cr_crapnpc INTO rw_crapnpc;
             
          IF cr_crapnpc%NOTFOUND THEN
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'valida', pr_posicao => 0, pr_tag_nova => 'nomenclatura', pr_tag_cont => 'N', pr_des_erro => vr_dscritic);
          ELSE 
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'valida', pr_posicao => 0, pr_tag_nova => 'nomenclatura', pr_tag_cont => 'S', pr_des_erro => vr_dscritic);
          END IF;          
          CLOSE cr_crapnpc;           

          -- valida a existencia da nomenclatura com mesma faixa de valor e carencia para o produto
          OPEN cr_crapnpc_valcar(pr_qtmincar, pr_qtmaxcar, pr_vlminapl, pr_vlmaxapl, pr_cdprodut, pr_cdnomenc);
            
          FETCH cr_crapnpc_valcar INTO rw_crapnpc_valcar;
             
          IF cr_crapnpc_valcar%NOTFOUND THEN
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'valida', pr_posicao => 0, pr_tag_nova => 'nom_valcar', pr_tag_cont => 'N', pr_des_erro => vr_dscritic);
          ELSE
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'valida', pr_posicao => 0, pr_tag_nova => 'nom_valcar', pr_tag_cont => 'S', pr_des_erro => vr_dscritic);
          END IF;            
          CLOSE cr_crapnpc_valcar;           
          
          -- se foi informado carencia minima e maxima
          IF pr_qtmincar > 0 AND pr_qtmaxcar > 0 THEN
            -- Se a carência mínima é menor que a máxima
            IF pr_qtmincar < pr_qtmaxcar THEN
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'valida', pr_posicao => 0, pr_tag_nova => 'carencia', pr_tag_cont => 'S', pr_des_erro => vr_dscritic);
            ELSE
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'valida', pr_posicao => 0, pr_tag_nova => 'carencia', pr_tag_cont => 'N', pr_des_erro => vr_dscritic);
            END IF;            
          ELSE
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'valida', pr_posicao => 0, pr_tag_nova => 'carencia', pr_tag_cont => 'N', pr_des_erro => vr_dscritic);              
          END IF;

          -- valida valor maior que zero
          IF pr_vlminapl > 0 AND pr_vlmaxapl > 0 THEN
            -- Se o valor mínimo é menor que o máximo.
            IF pr_vlminapl < pr_vlmaxapl THEN
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'valida', pr_posicao => 0, pr_tag_nova => 'valor', pr_tag_cont => 'S', pr_des_erro => vr_dscritic);
            ELSE
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'valida', pr_posicao => 0, pr_tag_nova => 'valor', pr_tag_cont => 'N', pr_des_erro => vr_dscritic);
            END IF;                    
          ELSE 
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'valida', pr_posicao => 0, pr_tag_nova => 'valor', pr_tag_cont => 'N', pr_des_erro => vr_dscritic);            
          END IF;

          -- Se a situacao eh valida
          IF pr_idsitnom >= 1 AND pr_idsitnom <= 2 THEN
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'valida', pr_posicao => 0, pr_tag_nova => 'situacao', pr_tag_cont => 'S', pr_des_erro => vr_dscritic);
          ELSE
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'valida', pr_posicao => 0, pr_tag_nova => 'situacao', pr_tag_cont => 'N', pr_des_erro => vr_dscritic);
          END IF;          
          
          
          RAISE vr_null; -- gera um RAISE para retornar as validacoes feitas

        WHEN 'I' THEN -- insercao
          BEGIN
         
            INSERT INTO crapnpc(cdprodut, dsnomenc, idsitnom, qtmincar, qtmaxcar, vlminapl, vlmaxapl)
                 VALUES(pr_cdprodut, pr_dsnomenc, pr_idsitnom, pr_qtmincar, pr_qtmaxcar, pr_vlminapl, pr_vlmaxapl)
              RETURNING cdnomenc INTO vr_seqcdnom; -- armazena o novo ID gerado
              
          -- Verifica se houve problema na insercao de registros
          EXCEPTION
            WHEN OTHERS THEN
              -- Descricao do erro na insercao de registros
              vr_dscritic := 'Problema ao incluir nomenclatura para o produto: ' || sqlerrm;
              RAISE vr_exc_saida;
          END;          

          OPEN cr_crapcpc(pr_cdprodut);
          FETCH cr_crapcpc INTO rw_crapcpc;
          
          IF cr_crapcpc%NOTFOUND THEN
            vr_nmprodut := 'N/A';
          ELSE
            vr_nmprodut := rw_crapcpc.nmprodut;
          END IF;
          CLOSE cr_crapcpc;

          -- situacao
          vr_idsitnom := gene0002.fn_busca_entrada(pr_postext => pr_idsitnom,pr_dstext => vr_sitnom,pr_delimitador => ',');          

          /* Monta as variaveis de LOG */
          -- 01/05/2014 – 08:00:00 ? Operador 1 incluiu novo nome para o produto 1 – RDCPOS SELIC: código 1, 
          -- nome INVESTFUTURO SELIC, carencia de 180 ate 999, valor de 50.000,00 ate 999.999.999,99.
          vr_dsmsglog := TO_CHAR(SYSDATE,'dd/mm/rrrr hh24:mi:ss') || ' -> Operador: ' || vr_cdoperad || ' incluiu novo nome para o produto ' 
                                                                || pr_cdprodut || ' - ' || vr_nmprodut || ': codigo ' || vr_seqcdnom 
                                                                || ', nome ' || pr_dsnomenc || ', carencia de '|| pr_qtmincar 
                                                                || ' ate ' || pr_qtmaxcar || ', valor de ' || TO_CHAR(pr_vlminapl, 'FM999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=,.') 
                                                                || ' ate ' || TO_CHAR(pr_vlmaxapl, 'FM999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=,.') || ', situacao ' || vr_idsitnom;
          
          -- monta o retorno para a tela
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'cadprod', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'cadprod', pr_posicao => 0, pr_tag_nova => 'msg', pr_tag_cont => 'OK', pr_des_erro => vr_dscritic);          
                  
        WHEN 'A' THEN
          
          IF pr_cdprodut > 0 AND pr_cdnomenc > 0 THEN
          
            -- Busca nomenclatura pelo codigo, para criar o LOG
            OPEN cr_crapnpc_log(pr_cdnomenc);

            FETCH cr_crapnpc_log INTO rw_crapnpc_log;
          
            -- Valida existencia de carteira para o produto
            OPEN cr_craprac_car(pr_cdprodut, pr_cdnomenc); -- Codigo do produto                   
            
            FETCH cr_craprac_car
             INTO rw_craprac_car;        
          
            -- se nao identificar nenhuma carteira cadastrada para o produto
            -- atualiza todos os dados do mesmo
            IF cr_craprac_car%NOTFOUND THEN 
              -- fecha o cursor
              CLOSE cr_craprac_car;
              
              BEGIN   
                -- executa a atualizacao completa do produto
                UPDATE crapnpc 
                   SET crapnpc.dsnomenc = pr_dsnomenc,
                       crapnpc.idsitnom = pr_idsitnom,
                       crapnpc.qtmincar = pr_qtmincar,
                       crapnpc.qtmaxcar = pr_qtmaxcar,
                       crapnpc.vlminapl = pr_vlminapl,
                       crapnpc.vlmaxapl = pr_vlmaxapl
                 WHERE crapnpc.cdprodut = pr_cdprodut
                   AND crapnpc.cdnomenc = pr_cdnomenc; 
                 
              EXCEPTION
                WHEN OTHERS THEN -- Descricao do erro na insercao de registros
                  vr_dscritic := 'Problema ao atualizar nomenclatura do produto: ' || sqlerrm;
                  RAISE vr_exc_saida;                                          
              END;
            
            ELSE -- caso ja possua uma carteira cadastrada para o produto
                 -- permite apenas a alteracao do nome,situacao,indicador de acumulatividade

              CLOSE cr_craprac_car;         
            
              BEGIN   
                 -- executa a atualizacao parcial do produto                
                  UPDATE crapnpc 
                     SET crapnpc.idsitnom = pr_idsitnom
                   WHERE crapnpc.cdprodut = pr_cdprodut
                     AND crapnpc.cdnomenc = pr_cdnomenc;   
                   
              EXCEPTION
                WHEN OTHERS THEN -- Descricao do erro na insercao de registros
                  vr_dscritic := 'Problema ao atualizar nomenclatura do produto: ' || sqlerrm;
                  RAISE vr_exc_saida;                         
              END;          
                
            END IF;

            IF ( rw_crapnpc_log.dsnomenc <> pr_dsnomenc ) THEN
               vr_dsmsglog := vr_dsmsglog || ' nome ' || rw_crapnpc_log.dsnomenc || ' para ' || pr_dsnomenc || ', ';
            END IF;  
                                                     
            IF ( rw_crapnpc_log.qtmincar <> pr_qtmincar OR rw_crapnpc_log.qtmaxcar <> pr_qtmaxcar ) THEN
               vr_dsmsglog := vr_dsmsglog || ' carencia de ' || rw_crapnpc_log.qtmincar || ' ate ' || rw_crapnpc_log.qtmaxcar || 
                              ' para ' || pr_qtmincar || ' ate ' || pr_qtmaxcar || ', ';
            END IF;  
                                                                           
            IF ( rw_crapnpc_log.vlminapl <> pr_vlminapl OR rw_crapnpc_log.vlmaxapl <> pr_vlmaxapl ) THEN
               vr_dsmsglog := vr_dsmsglog || ' valor de ' || rw_crapnpc_log.vlminapl || ' ate ' || rw_crapnpc_log.vlmaxapl || 
                              ' para ' || pr_vlminapl || ' ate ' || pr_vlmaxapl || ', ';
            END IF;  
            
            IF ( rw_crapnpc_log.idsitnom <> pr_idsitnom ) THEN
               vr_dsmsglog := vr_dsmsglog || ' situacao ' || gene0002.fn_busca_entrada(pr_postext =>  rw_crapnpc_log.idsitnom,pr_dstext => vr_sitnom ,pr_delimitador => ',') 
                                          || ' para '     || gene0002.fn_busca_entrada(pr_postext =>  pr_idsitnom,pr_dstext => vr_sitnom ,pr_delimitador => ',');
            END IF;   
            
            -- 02/05/2014 – 08:00:00 ? Operador 1 alterou o nome 1 do produto 1 – RDCPOS SELIC: 
            -- nome INVESTFUTURO SELIC para INVESTFUTUROSELIC, carencia de 180 ate 999 para 181 ate 999, 
            -- valor de 50.000,00 ate 999.999.999,99 para 50.000,00 ate 999.999.999,99.            
            IF vr_dsmsglog is not null THEN
              OPEN cr_crapcpc(pr_cdprodut);  
              FETCH cr_crapcpc INTO rw_crapcpc;
            
              IF cr_crapcpc%NOTFOUND THEN
                 vr_nmprodut := 'N/A';
              ELSE   
                 vr_nmprodut := rw_crapcpc.nmprodut;              
              END IF;
              
              CLOSE cr_crapcpc;
              
              vr_dsmsglog := TO_CHAR(SYSDATE,'dd/mm/rrrr hh24:mi:ss') || ' -> Operador: ' || vr_cdoperad || ' alterou o nome ' 
                                                                    || pr_cdnomenc || ' do produto ' || pr_cdprodut || ' - ' 
                                                                    || vr_nmprodut || ': ' || vr_dsmsglog;
              
            END IF;
            
            CLOSE cr_crapnpc_log;          
            
            -- retorna OK pra tela 
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'excprod', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'excprod', pr_posicao => 0, pr_tag_nova => 'msg', pr_tag_cont => 'OK', pr_des_erro => vr_dscritic);
          END IF;


        WHEN 'E' THEN
          
          -- Busca produto pelo codigo, para criar o LOG
          OPEN cr_crapcpc(pr_cdprodut);

          FETCH cr_crapcpc INTO rw_crapcpc;
        
          -- Valida existencia de carteira para o produto
          OPEN cr_craprac_car(pr_cdprodut, pr_cdnomenc); -- Codigo do produto                   
          
          FETCH cr_craprac_car
           INTO rw_craprac_car;
           
          IF cr_craprac_car%FOUND THEN
            CLOSE cr_craprac_car; 
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'msg', pr_tag_cont => 'Exclusao nao permitida. A nomenclatura ja foi utilizada na carteira.', pr_des_erro => vr_dscritic);
            RAISE vr_null;           
            
          ELSE 
            CLOSE cr_craprac_car;
            BEGIN
                    
              DELETE FROM crapnpc WHERE crapnpc.cdprodut = pr_cdprodut AND crapnpc.cdnomenc = pr_cdnomenc;                          
                    
            -- Verifica se houve problema na exclusao de registros
            EXCEPTION
              WHEN OTHERS THEN -- Descricao do erro na insercao de registros
                vr_dscritic := 'Problema ao excluir nomenclatura do produto: ' || sqlerrm;
                RAISE vr_exc_saida;
            END;
                    
            -- gera LOG de operacao
            vr_dsmsglog := TO_CHAR(SYSDATE,'dd/mm/rrrr hh24:mi:ss') || ' -> Operador: ' || vr_cdoperad || ' excluiu nomenclatura do produto ' || pr_cdprodut || ': ' || rw_crapcpc.nmprodut; 
                   
            CLOSE cr_crapcpc;
            
            -- retorna OK pra tela 
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'msg', pr_tag_cont => 'OK', pr_des_erro => vr_dscritic);            
            
          END IF;

        END CASE;

        IF vr_dsmsglog IS NOT NULL THEN
           -- fecha o cursor do produto

          -- Incluir log de execução.
          BTCH0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                    ,pr_ind_tipo_log => 1
                                    ,pr_des_log      => vr_dsmsglog
                                    ,pr_nmarqlog     => 'pcapta'
                                    ,pr_flnovlog     => 'N');
        END IF;

        COMMIT;

    EXCEPTION
      WHEN vr_null THEN
        NULL;  
      WHEN vr_exc_saida THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;

  END pc_manter_nomenclatura_produto;



PROCEDURE pc_manter_historico_produto(pr_cddopcao IN VARCHAR2              --> Codigo do Opção
                                     ,pr_cdprodut IN crapcpc.cdprodut%TYPE --> Codigo do Produto
                                     ,pr_cdhscacc IN crapcpc.cdhscacc%TYPE --> Débito Aplicação
                                     ,pr_cdhsvrcc IN crapcpc.cdhsvrcc%TYPE --> Crédito Resgate/Vencimento Aplicação
                                     ,pr_cdhsraap IN crapcpc.cdhsraap%TYPE --> Crédito Renovação Aplicação
                                     ,pr_cdhsnrap IN crapcpc.cdhsnrap%TYPE --> Crédito Aplicação Recurso Novo
                                     ,pr_cdhsprap IN crapcpc.cdhsprap%TYPE --> Crédito Atualização Juros
                                     ,pr_cdhsrvap IN crapcpc.cdhsrvap%TYPE --> Débito Reversão Atualização Juros
                                     ,pr_cdhsrdap IN crapcpc.cdhsrdap%TYPE --> Crédito Rendimento
                                     ,pr_cdhsirap IN crapcpc.cdhsirap%TYPE --> Débito IRRF
                                     ,pr_cdhsrgap IN crapcpc.cdhsrgap%TYPE --> Débito Resgate
                                     ,pr_cdhsvtap IN crapcpc.cdhsvtap%TYPE --> Débito Vencimento
                                     ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                     ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                     ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                     ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                     ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                     ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
  BEGIN
  
    /* .............................................................................

     Programa: pc_manter_historico_produto
     Sistema : Novos Produtos de Captação
     Sigla   : APLI
     Autor   : Carlos Rafael Tanholi
     Data    : Agosto/14.                    Ultima atualizacao: 19/08/2014

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina manutencao do historico de produto tela PCAPTA.

     Observacao: -----

     Alteracoes: 
     ..............................................................................*/ 
    DECLARE
          
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
      vr_null      EXCEPTION;
      
      -- Mensagem de log
      vr_dsmsglog VARCHAR2(4000); 
                  
      vr_cdhscacc VARCHAR2(100) := '';
      vr_cdhsvrcc VARCHAR2(100) := '';                                               
      vr_cdhsraap VARCHAR2(100) := '';
      vr_cdhsnrap VARCHAR2(100) := '';
      vr_cdhsprap VARCHAR2(100) := '';
      vr_cdhsrvap VARCHAR2(100) := '';
      vr_cdhsrdap VARCHAR2(100) := '';
      vr_cdhsirap VARCHAR2(100) := '';
      vr_cdhsrgap VARCHAR2(100) := '';
      vr_cdhsvtap VARCHAR2(100) := '';
      
      -- Variaveis de log
      vr_cdcooper INTEGER := 3;
      vr_cdoperad VARCHAR2(100);
      vr_operacao VARCHAR2(100) := '';      
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);
            
      -- variaves de validacao de historicos
      vr_cdhistor craphis.cdhistor%TYPE;
      vr_indebcre craphis.indebcre%TYPE;
      vr_nmestrut craphis.nmestrut%TYPE;
      
      ----------------------CURSORES--------------------------
      
      -- Verificar se existe carteira para o produto
      CURSOR cr_craprac_car(pr_cdprodut IN crapcpc.cdprodut%TYPE) IS
      SELECT 
         craprac.nrdconta
      FROM 
         craprac
         ,crapcop
      WHERE craprac.cdcooper = crapcop.cdcooper 
        AND craprac.cdprodut = pr_cdprodut;    

      rw_craprac_car cr_craprac_car%ROWTYPE;
      
      
      -- Seleciona os produtos de captacao
      CURSOR cr_crapcpc (pr_cdprodut IN crapcpc.cdprodut%TYPE) IS
      SELECT cpc.cdhscacc
            ,cpc.cdhsvrcc 
            ,cpc.cdhsraap
            ,cpc.cdhsnrap
            ,cpc.cdhsprap
            ,cpc.cdhsrvap
            ,cpc.cdhsrdap
            ,cpc.cdhsirap
            ,cpc.cdhsrgap
            ,cpc.cdhsvtap
            ,cpc.nmprodut
        FROM crapcpc cpc
       WHERE cpc.cdprodut = pr_cdprodut;
      
       rw_crapcpc cr_crapcpc%ROWTYPE;     
       
       --cursor para filtro de historicos
       CURSOR cr_craphis (pr_cdhistor IN craphis.cdhistor%TYPE) IS
       SELECT indebcre,
              nmestrut
         FROM craphis 
        WHERE cdcooper = 3
          AND cdhistor = pr_cdhistor;                          
       
       rw_craphis cr_craphis%ROWTYPE;               
       

    BEGIN
      
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);    
    
      
      -- Criar cabeçalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
     
      -- Verifica opcao
      CASE pr_cddopcao  
      
        WHEN 'V' THEN -- validacao
            
          -- cria no de validacao
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados'   , pr_posicao => 0     , pr_tag_nova => 'valida', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
          
          -- executa validacoes para exclusao/alteracao dos produtos
          IF pr_cdprodut > 0 THEN 

            -- Busca produto com carteira  
            OPEN cr_craprac_car(pr_cdprodut); -- Codigo do Produto

            FETCH cr_craprac_car
              INTO rw_craprac_car;
                                        
            -- Se não encontrar nenhuma carteira para o produto
            IF cr_craprac_car%NOTFOUND THEN
              CLOSE cr_craprac_car;
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'valida', pr_posicao => 0, pr_tag_nova => 'carteira', pr_tag_cont => 'N', pr_des_erro => vr_dscritic);              
            ELSE
              CLOSE cr_craprac_car; 
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'valida', pr_posicao => 0, pr_tag_nova => 'carteira', pr_tag_cont => 'S', pr_des_erro => vr_dscritic);
            END IF;          
             
          ELSE --valida codigo de historico

            IF pr_cdhscacc > 0 THEN
               vr_cdhistor := pr_cdhscacc;
               vr_indebcre := 'D';
            ELSIF pr_cdhsvrcc > 0 THEN
               vr_cdhistor := pr_cdhsvrcc;
               vr_indebcre := 'C';
            ELSIF pr_cdhsraap > 0 THEN
               vr_cdhistor := pr_cdhsraap;
               vr_indebcre := 'C';               
            ELSIF pr_cdhsnrap > 0 THEN
               vr_cdhistor := pr_cdhsnrap;
               vr_indebcre := 'C';
            ELSIF pr_cdhsprap > 0 THEN
               vr_cdhistor := pr_cdhsprap;
               vr_indebcre := 'C';
            ELSIF pr_cdhsrvap > 0 THEN
               vr_cdhistor := pr_cdhsrvap;
               vr_indebcre := 'D';
            ELSIF pr_cdhsrdap > 0 THEN
               vr_cdhistor := pr_cdhsrdap;
               vr_indebcre := 'C';
            ELSIF pr_cdhsirap > 0 THEN
               vr_cdhistor := pr_cdhsirap;
               vr_indebcre := 'D';
            ELSIF pr_cdhsrgap > 0 THEN
               vr_cdhistor := pr_cdhsrgap;
               vr_indebcre := 'D';
            ELSIF pr_cdhsvtap > 0 THEN
               vr_cdhistor := pr_cdhsvtap;
               vr_indebcre := 'D';     
            END IF;
          
            IF pr_cdhscacc > 0 OR pr_cdhsvrcc > 0 THEN
              vr_nmestrut := 'CRAPLCM';
            ELSE
              vr_nmestrut := 'CRAPLAC';
            END IF;
          
            -- valida existencia do historico  
            OPEN cr_craphis(vr_cdhistor); 

            FETCH cr_craphis
              INTO rw_craphis;
                                      
            -- Se não encontrar o historico na CRAPHIS
            IF cr_craphis%NOTFOUND THEN
              CLOSE cr_craphis;
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'valida', pr_posicao => 0, pr_tag_nova => 'valido', pr_tag_cont => 'N', pr_des_erro => vr_dscritic);
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'valida', pr_posicao => 0, pr_tag_nova => 'estrutura', pr_tag_cont => 'N', pr_des_erro => vr_dscritic);
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'valida', pr_posicao => 0, pr_tag_nova => 'indebcre', pr_tag_cont => 'N', pr_des_erro => vr_dscritic);
            ELSE
              CLOSE cr_craphis; 
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'valida', pr_posicao => 0, pr_tag_nova => 'valido', pr_tag_cont => 'S', pr_des_erro => vr_dscritic);
              
              IF rw_craphis.indebcre = vr_indebcre THEN
                 gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'valida', pr_posicao => 0, pr_tag_nova => 'indebcre', pr_tag_cont => 'S', pr_des_erro => vr_dscritic);
                 
                 IF rw_craphis.nmestrut = vr_nmestrut THEN
                    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'valida', pr_posicao => 0, pr_tag_nova => 'estrutura', pr_tag_cont => 'S', pr_des_erro => vr_dscritic);
                 ELSE
                    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'valida', pr_posicao => 0, pr_tag_nova => 'estrutura', pr_tag_cont => 'N', pr_des_erro => vr_dscritic);                   
                 END IF;

              ELSE                 
                 gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'valida', pr_posicao => 0, pr_tag_nova => 'indebcre', pr_tag_cont => 'N', pr_des_erro => vr_dscritic);
                 gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'valida', pr_posicao => 0, pr_tag_nova => 'estrutura', pr_tag_cont => 'N', pr_des_erro => vr_dscritic);
              END IF;
             
            END IF;          
          
          END IF;
          
          -- gera um RAISE para retornar as validacoes feitas
          RAISE vr_null;            

        WHEN 'A' THEN
          
          -- Busca produto pelo codigo, para criar o LOG dos historicos
          OPEN cr_crapcpc(pr_cdprodut);
          FETCH cr_crapcpc INTO rw_crapcpc;        
        
          IF cr_crapcpc%NOTFOUND THEN
            vr_dscritic := 'Produto inválido';
            RAISE vr_null;
          ELSE
            -- Valida existencia de carteira para o produto
            OPEN cr_craprac_car(pr_cdprodut);
            FETCH cr_craprac_car INTO rw_craprac_car;
            
            -- se nao identificar nenhuma carteira cadastrada para o produto
            -- atualiza todos os dados de historico do mesmo
            IF cr_craprac_car%NOTFOUND THEN 
              -- fecha o cursor
              CLOSE cr_craprac_car;
              
              BEGIN   
                -- executa a atualizacao completa do produto
                UPDATE crapcpc 
                   SET cdhscacc = pr_cdhscacc
                      ,cdhsvrcc = pr_cdhsvrcc
                      ,cdhsraap = pr_cdhsraap
                      ,cdhsnrap = pr_cdhsnrap
                      ,cdhsprap = pr_cdhsprap
                      ,cdhsrvap = pr_cdhsrvap
                      ,cdhsrdap = pr_cdhsrdap
                      ,cdhsirap = pr_cdhsirap
                      ,cdhsrgap = pr_cdhsrgap
                      ,cdhsvtap = pr_cdhsvtap
                 WHERE cdprodut = pr_cdprodut; 
                 
              EXCEPTION
                WHEN OTHERS THEN -- Descricao do erro na insercao de registros
                  vr_dscritic := 'Problema ao atualizar historico do Produto: ' || sqlerrm;
                  RAISE vr_exc_saida;                                          
              END;
                     
              /*
              01/05/2014 – 08:00:00 ? Operador 1 incluiu os históricos no produto 1 – RDCPOS SELIC: 
              Débito Cadastro Aplicação 1000, Crédito Resgate/Vencimento Aplicação 1001, … descrever todos os campos.
              */             
              IF rw_crapcpc.cdhscacc = 0 OR rw_crapcpc.cdhsvrcc = 0 OR rw_crapcpc.cdhsraap = 0 OR
                 rw_crapcpc.cdhsnrap = 0 OR rw_crapcpc.cdhsprap = 0 OR rw_crapcpc.cdhsrvap = 0 OR
                 rw_crapcpc.cdhsrdap = 0 OR rw_crapcpc.cdhsirap = 0 OR rw_crapcpc.cdhsrgap = 0 OR rw_crapcpc.cdhsvtap = 0 THEN
                 
                vr_operacao := ' incluiu os históricos no ';
                                 
                vr_cdhscacc := ' Débito Aplicação '||TO_CHAR(pr_cdhscacc);
                vr_cdhsvrcc := ', Crédito Resgate/Vencimento Aplicação '||TO_CHAR(pr_cdhsvrcc);
                vr_cdhsraap := ', Crédito Renovação Aplicação '||TO_CHAR(pr_cdhsraap);
                vr_cdhsnrap := ', Crédito Aplicação Recurso Novo '||TO_CHAR(pr_cdhsnrap);
                vr_cdhsprap := ', Crédito Atualização Juros '||TO_CHAR(pr_cdhsprap);
                vr_cdhsrvap := ', Débito Reversão Atualização Juros '||TO_CHAR(pr_cdhsrvap);
                vr_cdhsrdap := ', Crédito Rendimento '||TO_CHAR(pr_cdhsrdap);
                vr_cdhsirap := ', Débito IRRF '||TO_CHAR(pr_cdhsirap);
                vr_cdhsrgap := ', Débito Resgate '||TO_CHAR(pr_cdhsrgap);
                vr_cdhsvtap := ', Débito Vencimento '||TO_CHAR(pr_cdhsvtap);
              ELSE
                /*
                02/05/2014 – 08:00:00 ? Operador 1 alterou históricos do produto 1 – RDCPOS SELIC: Débito Cadastro Aplicação de 1000 
                para 1001, Crédito Resgate/Vencimento Aplicação de 1001 para 2001, … descrever todos os campos alterados.             
                */
                vr_operacao := ' alterou históricos do ';
                
                IF rw_crapcpc.cdhscacc <> pr_cdhscacc THEN
                   vr_cdhscacc := ' Débito Aplicação de '||TO_CHAR(rw_crapcpc.cdhscacc)||' para '||TO_CHAR(pr_cdhscacc);
                END IF;

                IF rw_crapcpc.cdhsvrcc <> pr_cdhsvrcc THEN                   
                   vr_cdhsvrcc := ', Crédito Resgate/Vencimento Aplicação de '||TO_CHAR(rw_crapcpc.cdhsvrcc)||' para '||TO_CHAR(pr_cdhsvrcc);
                END IF;
                
                IF rw_crapcpc.cdhsraap <> pr_cdhsraap THEN
                   vr_cdhsraap := ', Crédito Renovação Aplicação de '||TO_CHAR(rw_crapcpc.cdhsraap)||' para '||TO_CHAR(pr_cdhsraap);
                END IF;
                
                IF rw_crapcpc.cdhsnrap <> pr_cdhsnrap THEN 
                   vr_cdhsnrap := ', Crédito Aplicação Recurso Novo de '||TO_CHAR(rw_crapcpc.cdhsnrap)||' para '||TO_CHAR(pr_cdhsnrap);
                END IF;

                IF rw_crapcpc.cdhsprap <> pr_cdhsprap THEN                 
                   vr_cdhsprap := ', Crédito Atualização Juros de '||TO_CHAR(rw_crapcpc.cdhsprap)||' para '||TO_CHAR(pr_cdhsprap);
                END IF;
                
                IF rw_crapcpc.cdhsrvap <> pr_cdhsrvap THEN                 
                   vr_cdhsrvap := ', Débito Reversão Atualização Juros de '||TO_CHAR(rw_crapcpc.cdhsrvap)||' para '||TO_CHAR(pr_cdhsrvap);
                END IF;
                
                IF rw_crapcpc.cdhsrdap <> pr_cdhsrdap THEN                                 
                   vr_cdhsrdap := ', Crédito Rendimento de '||TO_CHAR(rw_crapcpc.cdhsrdap)||' para '||TO_CHAR(pr_cdhsrdap);
                END IF;
                
                IF rw_crapcpc.cdhsirap <> pr_cdhsirap THEN                                                 
                   vr_cdhsirap := ', Débito IRRF de '||TO_CHAR(rw_crapcpc.cdhsirap)||' para '||TO_CHAR(pr_cdhsirap);
                END IF;
                
                IF rw_crapcpc.cdhsrgap <> pr_cdhsrgap THEN                                                 
                   vr_cdhsrgap := ', Débito Resgate de '||TO_CHAR(rw_crapcpc.cdhsrgap)||' para '||TO_CHAR(pr_cdhsrgap);
                END IF;
                
                IF rw_crapcpc.cdhsvtap <> pr_cdhsvtap THEN                                                                 
                   vr_cdhsvtap := ', Débito Vencimento de '||TO_CHAR(rw_crapcpc.cdhsvtap)||' para '||TO_CHAR(pr_cdhsvtap);               
                END IF;
               
              END IF;
             
              -- gera LOG de operacao          
              vr_dsmsglog := TO_CHAR(SYSDATE,'dd/mm/rrrr hh24:mi:ss') || ' -> Operador: ' || vr_cdoperad || vr_operacao
                                                                    || ' produto ' || pr_cdprodut || '-' || rw_crapcpc.nmprodut || ':'
                                                                    || vr_cdhscacc
                                                                    || vr_cdhsvrcc                                                                    
                                                                    || vr_cdhsraap
                                                                    || vr_cdhsnrap
                                                                    || vr_cdhsprap
                                                                    || vr_cdhsrvap
                                                                    || vr_cdhsrdap
                                                                    || vr_cdhsirap
                                                                    || vr_cdhsrgap
                                                                    || vr_cdhsvtap;
              -- retorna OK pra tela 
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'msg', pr_tag_cont => 'OK', pr_des_erro => vr_dscritic);

            ELSE -- caso ja possua uma carteira cadastrada para o produto
              -- nao sera possivel alterar dados do mesmo
              CLOSE cr_craprac_car;  
            END IF;
          
          END IF;  
  
        END CASE;

        IF vr_dsmsglog IS NOT NULL THEN
           -- fecha o cursor do produto

          -- Incluir log de execução.
          BTCH0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                    ,pr_ind_tipo_log => 1
                                    ,pr_des_log      => vr_dsmsglog
                                    ,pr_nmarqlog     => 'pcapta'
                                    ,pr_flnovlog     => 'N');
        END IF;

        COMMIT;

    EXCEPTION
      WHEN vr_null THEN
        NULL;  
      WHEN vr_exc_saida THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;

  END pc_manter_historico_produto;




 
    /* Rotina referente a produtos da tela PCAPTA */
  PROCEDURE pc_manter_modalidade(pr_cddopcao IN VARCHAR2 --> Codigo do Opção
                                 ,pr_cdmodali IN VARCHAR2 --> Codigo da Modalidade
                                 ,pr_cdprodut IN crapmpc.cdprodut%TYPE --> Codigo do Produto
                                 ,pr_qtdiacar IN crapmpc.qtdiacar%TYPE --> Dias de carencia
                                 ,pr_qtdiaprz IN crapmpc.qtdiaprz%TYPE --> Dias de prazo
                                 ,pr_vlrfaixa IN crapmpc.vlrfaixa%TYPE --> Faixa de valor
                                 ,pr_vlperren IN crapmpc.vlperren%TYPE --> Rentabilidade
                                 ,pr_vltxfixa IN crapmpc.vltxfixa%TYPE --> Taxa Fixa
                                 ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                 ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                 ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                 ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                 ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                 ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
  BEGIN
  
    /* .............................................................................

     Programa: pc_manter_modalidade
     Sistema : Modalidade Produto de Captação
     Sigla   : APLI
     Autor   : Carlos Rafael Tanholi
     Data    : Agosto/14.                    Ultima atualizacao: 01/08/2014

     Dados referentes a modalidade do programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina de manipulacao de modalidades de produtos cadastrados.

     Observacao: -----

     Alteracoes: 05/01/2015 - Alteração do cursor cr_crapmpc_consis que consiste o 
                              cadastro de novas modalidades para o produto, agora 
                              o mesmo consiste o produto relacionado ha modalidade
                              (Carlos Rafael Tanholi - Novos Produtos de Captacao)
     ..............................................................................*/ 
    DECLARE
    
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
      vr_null      EXCEPTION;
   
      vr_nmprodut crapcpc.nmprodut%TYPE;
      
      vr_cooperativas VARCHAR2(300);
      
      -- Mensagem de log
      vr_dsmsglog VARCHAR2(4000); 
      
      -- Variaveis de log
      vr_cdcooper INTEGER := 0;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);
      
      vr_cdmodali INTEGER := 0;
      vr_arrcdmod GENE0002.typ_split;
      
      vr_vlperren crapmpc.vlperren%TYPE;
      vr_vltxfixa crapmpc.vltxfixa%TYPE;
      
      -- cursor para validar existencia do produto
      CURSOR cr_crapcpc(pr_cdprodut IN crapcpc.cdprodut%TYPE) IS      
      SELECT
        cpc.cdprodut
        ,cpc.idtxfixa
        ,cpc.nmprodut
      FROM
       crapcpc cpc
      WHERE cpc.cdprodut = pr_cdprodut
        AND cpc.idsitpro = 1;
              
      rw_crapcpc cr_crapcpc%ROWTYPE;       
      
      -- cursor para validar existencia da modalidade cadastrada 
      -- para o produto com a mesma carência, prazo e faixa de valor
      CURSOR cr_crapmpc(pr_cdprodut IN crapcpc.nmprodut%TYPE
                        ,pr_qtdiacar IN crapmpc.qtdiacar%TYPE
                        ,pr_qtdiaprz IN crapmpc.qtdiaprz%TYPE
                        ,pr_vlrfaixa IN crapmpc.vlrfaixa%TYPE                        
                        ) IS      
      SELECT
        mpc.cdprodut
      FROM
       crapmpc mpc
       ,crapcpc cpc
      WHERE cpc.cdprodut = mpc.cdprodut
        AND cpc.idsitpro = 1
        AND mpc.cdprodut = pr_cdprodut
        AND mpc.qtdiacar = pr_qtdiacar
        AND mpc.qtdiaprz = pr_qtdiaprz
        AND mpc.vlrfaixa = pr_vlrfaixa;        
              
      rw_crapmpc cr_crapmpc%ROWTYPE;           
      
      
      -- consiste o cadastro de modalidades
      CURSOR cr_crapmpc_consis(pr_qtdiacar IN crapmpc.qtdiacar%TYPE
                              ,pr_qtdiaprz IN crapmpc.qtdiaprz%TYPE
                              ,pr_vlrfaixa IN crapmpc.vlrfaixa%TYPE
                              ,pr_vlperren IN crapmpc.vlperren%TYPE
                              ,pr_cdprodut IN crapcpc.cdprodut%TYPE                              
                              ) IS      
      SELECT
        mpc.cdprodut
      FROM
        crapmpc mpc
       ,crapcpc cpc
      WHERE cpc.cdprodut = mpc.cdprodut
        AND mpc.cdprodut = pr_cdprodut
        AND cpc.idsitpro = 1
        AND mpc.qtdiacar = pr_qtdiacar
        AND mpc.qtdiaprz = pr_qtdiaprz
        AND ( (mpc.vlrfaixa <= pr_vlrfaixa 
               AND mpc.vlperren >= pr_vlperren)
             OR  
               (mpc.vlrfaixa >= pr_vlrfaixa 
               AND mpc.vlperren <= pr_vlperren)
            );
              
      rw_crapmpc_consis cr_crapmpc_consis%ROWTYPE;           
          
      
      -- recuperar dados da modalidade
      CURSOR cr_crapmpc_log(pr_cdmodali IN  crapmpc.cdmodali%TYPE) IS      
      SELECT
         mpc.*
        ,cpc.nmprodut
        FROM crapmpc mpc
            ,crapcpc cpc
       WHERE cpc.cdprodut = mpc.cdprodut
         AND mpc.cdmodali = pr_cdmodali;
             
      rw_crapmpc_log cr_crapmpc_log%ROWTYPE;           

      
      -- recupera as cooperativas que usam a modalidade
      CURSOR cr_crapdpc_log(pr_cdmodali IN  crapmpc.cdmodali%TYPE) IS
      SELECT cop.nmrescop
        FROM crapdpc dpc
            ,crapcop cop
            ,crapmpc mpc
       WHERE dpc.cdcooper = cop.cdcooper
         AND dpc.cdmodali = mpc.cdmodali
         AND mpc.cdmodali = pr_cdmodali;
            
      rw_crapdpc_log cr_crapdpc_log%ROWTYPE;
      
      
      BEGIN  
   
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);    
        
      -- Verifica opcao
      CASE pr_cddopcao  


        WHEN 'V' THEN -- validacao

          -- Criar cabeçalho do XML
          pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');

          -- cria no de validacao
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados'   , pr_posicao => 0     , pr_tag_nova => 'valida', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);

          -- Busca produto com carteira  
          OPEN cr_crapcpc(pr_cdprodut); -- Codigo do Produto

          FETCH cr_crapcpc
           INTO rw_crapcpc;
                      
          IF cr_crapcpc%NOTFOUND THEN
            CLOSE cr_crapcpc;
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'valida', pr_posicao => 0, pr_tag_nova => 'produto', pr_tag_cont => 'N', pr_des_erro => vr_dscritic);              
          ELSE
            CLOSE cr_crapcpc;             
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'valida', pr_posicao => 0, pr_tag_nova => 'produto', pr_tag_cont => 'S', pr_des_erro => vr_dscritic);              
          END IF; 
        
        
          -- Busca modalidade ja cadastrada  
          OPEN cr_crapmpc(pr_cdprodut -- Codigo do Produto
                         ,pr_qtdiacar -- Qtde dias carteira
                         ,pr_qtdiaprz -- Qtde dias prazo
                         ,pr_vlrfaixa -- Faixa de valor
                         ); 

          FETCH cr_crapmpc
           INTO rw_crapmpc;
                      
          IF cr_crapmpc%NOTFOUND THEN
            CLOSE cr_crapmpc;
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'valida', pr_posicao => 0, pr_tag_nova => 'modalidade', pr_tag_cont => 'N', pr_des_erro => vr_dscritic);              
          ELSE
            CLOSE cr_crapmpc;             
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'valida', pr_posicao => 0, pr_tag_nova => 'modalidade', pr_tag_cont => 'S', pr_des_erro => vr_dscritic);              
          END IF;         
          
          
          -- valida a carencia deve ser maior ou igual a 30.
          IF pr_qtdiacar >= 30 THEN
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'valida', pr_posicao => 0, pr_tag_nova => 'carencia', pr_tag_cont => 'N', pr_des_erro => vr_dscritic);              
          ELSE        
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'valida', pr_posicao => 0, pr_tag_nova => 'carencia', pr_tag_cont => 'S', pr_des_erro => vr_dscritic);              
          END IF;                   
          
          
          -- valida o prazo deve ser maior ou igual a carencia
          IF pr_qtdiaprz >= pr_qtdiacar THEN
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'valida', pr_posicao => 0, pr_tag_nova => 'prazo', pr_tag_cont => 'N', pr_des_erro => vr_dscritic);              
          ELSE        
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'valida', pr_posicao => 0, pr_tag_nova => 'prazo', pr_tag_cont => 'S', pr_des_erro => vr_dscritic);              
          END IF;           


          -- valida produto taxa fixa 
          OPEN cr_crapcpc(pr_cdprodut); -- Codigo do Produto

          FETCH cr_crapcpc
           INTO rw_crapcpc;
                      
          IF cr_crapcpc%FOUND THEN
            CLOSE cr_crapcpc;
            -- Se for produto de taxa fixa, não permitir informar taxa zerada, 
            IF (rw_crapcpc.idtxfixa = 1 ) THEN 
              -- taxa fixa
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'valida', pr_posicao => 0, pr_tag_nova => 'taxa_fixa', pr_tag_cont => 'S', pr_des_erro => vr_dscritic);

              IF (pr_vltxfixa <= 0) THEN
                 gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'valida', pr_posicao => 0, pr_tag_nova => 'taxa_zerada', pr_tag_cont => 'S', pr_des_erro => vr_dscritic);                
              ELSE
                 gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'valida', pr_posicao => 0, pr_tag_nova => 'taxa_zerada', pr_tag_cont => 'N', pr_des_erro => vr_dscritic);                                    
              END IF;
              -- criar indice(percentual_zerado) necessario para validacoes em tela              
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'valida', pr_posicao => 0, pr_tag_nova => 'percentual_zerado', pr_tag_cont => 'N', pr_des_erro => vr_dscritic);
              
            ELSE -- se for produto sem taxa fixa, não permitir informar percentual zerado.
              -- taxa fixa
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'valida', pr_posicao => 0, pr_tag_nova => 'taxa_fixa', pr_tag_cont => 'N', pr_des_erro => vr_dscritic);

              -- criar indice(taxa_zerada) necessario para validacoes em tela
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'valida', pr_posicao => 0, pr_tag_nova => 'taxa_zerada', pr_tag_cont => 'N', pr_des_erro => vr_dscritic);

              IF (pr_vlperren <= 0) THEN
                 gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'valida', pr_posicao => 0, pr_tag_nova => 'percentual_zerado', pr_tag_cont => 'S', pr_des_erro => vr_dscritic);                
              ELSE
                 gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'valida', pr_posicao => 0, pr_tag_nova => 'percentual_zerado', pr_tag_cont => 'N', pr_des_erro => vr_dscritic);
              END IF;
            END IF;
          ELSE
            CLOSE cr_crapcpc;
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'valida', pr_posicao => 0, pr_tag_nova => 'taxa_fixa', pr_tag_cont => 'N', pr_des_erro => vr_dscritic);                                
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'valida', pr_posicao => 0, pr_tag_nova => 'taxa_zerada', pr_tag_cont => 'N', pr_des_erro => vr_dscritic);                                                  
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'valida', pr_posicao => 0, pr_tag_nova => 'percentual_zerado', pr_tag_cont => 'N', pr_des_erro => vr_dscritic);
          END IF; 


          -- Consiste modalidade com valor >= e %rentabilidade inferior 
          OPEN cr_crapmpc_consis(pr_qtdiacar -- Qtde dias carteira
                                ,pr_qtdiaprz -- Qtde dias prazo
                                ,pr_vlrfaixa -- Faixa de valor
                                ,pr_vlperren -- rentabilidade
                                ,pr_cdprodut -- codigo produto
                                ); 

          FETCH cr_crapmpc_consis
           INTO rw_crapmpc_consis;
                      
          IF cr_crapmpc_consis%NOTFOUND THEN
            CLOSE cr_crapmpc_consis;
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'valida', pr_posicao => 0, pr_tag_nova => 'rentabilidade', pr_tag_cont => 'N', pr_des_erro => vr_dscritic);              
          ELSE
            CLOSE cr_crapmpc_consis;             
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'valida', pr_posicao => 0, pr_tag_nova => 'rentabilidade', pr_tag_cont => 'S', pr_des_erro => vr_dscritic);              
          END IF;   

      
        WHEN 'I' THEN -- insercao
        
          -- executa a insercao           
          BEGIN
                       
            IF pr_vltxfixa IS NULL THEN
               vr_vltxfixa := 0;  
            ELSE   
               vr_vltxfixa := pr_vltxfixa;

            END IF;

            IF pr_vlperren IS NULL THEN
               vr_vlperren := 0;  
            ELSE
               vr_vlperren :=pr_vlperren;
            END IF;

            INSERT INTO crapmpc(cdprodut, qtdiacar, qtdiaprz, vlrfaixa, vlperren, vltxfixa)
                 VALUES(pr_cdprodut, pr_qtdiacar, pr_qtdiaprz, pr_vlrfaixa, vr_vlperren, vr_vltxfixa)
              RETURNING cdmodali INTO vr_cdmodali; -- armazena o novo ID gerado
              
          -- Verifica se houve problema na insercao de registros
          EXCEPTION
            WHEN OTHERS THEN
              -- Descricao do erro na insercao de registros
              vr_dscritic := 'Problema ao incluir Modalidade: ' || sqlerrm;
              RAISE vr_exc_saida;
          END;          

         
          -- Busca nome do produto
          OPEN cr_crapcpc(pr_cdprodut);

          FETCH cr_crapcpc
           INTO rw_crapcpc;
                      
          IF cr_crapcpc%NOTFOUND THEN
            CLOSE cr_crapcpc;
            vr_nmprodut := 'N/A';
          ELSE
            CLOSE cr_crapcpc;
            vr_nmprodut := rw_crapcpc.nmprodut;            
          END IF;           
          
          /* Monta as variaveis de LOG */
         
          -- 01/05/2014 – 08:00:00 ? Operador 1 incluiu nova modalidade: produto 1 - RDCPOS SELIC, código 1, carencia 30, 
          -- prazo 180, valor inicial da faixa 100.000,00, rentabilidade 95,000000, taxa fixa 0,000000.
          -- gera LOG de operacao                
          vr_dsmsglog := TO_CHAR(SYSDATE,'dd/mm/rrrr hh24:mi:ss') || ' -> Operador: ' || vr_cdoperad 
                                                                || ' incluiu nova modalidade para o produto: ' || pr_cdprodut || ' - ' || vr_nmprodut  
                                                                || ', codigo '|| vr_cdmodali || ', carencia '|| pr_qtdiacar ||', prazo '
                                                                || pr_qtdiaprz || ', valor inicial da faixa '
                                                                || TO_CHAR(pr_vlrfaixa, '999G990D000000', 'NLS_NUMERIC_CHARACTERS=,.') ||', rentabilidade'
                                                                || TO_CHAR(vr_vlperren, '999G990D000000')  ||', taxa fixa'
                                                                || TO_CHAR(vr_vltxfixa, '999G990D000000')  ||'.';
          -- monta o retorno para a tela
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'cadmod', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'cadmod', pr_posicao => 0, pr_tag_nova => 'msg', pr_tag_cont => 'OK', pr_des_erro => vr_dscritic);          

          
        WHEN 'E' THEN -- exclusao

          vr_arrcdmod := GENE0002.fn_quebra_string(pr_cdmodali, ',');     
          
          -- valida o codigos da modalidade
          IF vr_arrcdmod.count() > 0 THEN
            -- percore o array de modalidades
            FOR idx IN 1..vr_arrcdmod.count() LOOP

              -- recupera os dados da modalidade          
              OPEN cr_crapmpc_log(vr_arrcdmod(idx));

              -- recupera as cooperativas que utilizam a modalidade
              OPEN cr_crapdpc_log(vr_arrcdmod(idx));          
                       
              vr_cooperativas := '';
              
              IF cr_crapdpc_log%NOTFOUND THEN
                 CLOSE cr_crapdpc_log;
              ELSE
                 LOOP -- Percorre as cooperativas
                    FETCH cr_crapdpc_log INTO rw_crapdpc_log; 
                    IF vr_cooperativas IS NULL THEN
                      vr_cooperativas := rw_crapdpc_log.nmrescop;
                    ELSE 
                      vr_cooperativas := vr_cooperativas || ','||rw_crapdpc_log.nmrescop;
                    END IF;
                                  
                    EXIT WHEN cr_crapdpc_log%NOTFOUND;   
                 END LOOP; 
                 CLOSE cr_crapdpc_log;            
              END IF;
                            
                            
              BEGIN
                DELETE FROM crapdpc WHERE crapdpc.cdmodali = vr_arrcdmod(idx);
                DELETE FROM crapmpc WHERE crapmpc.cdmodali = vr_arrcdmod(idx);
                              
              EXCEPTION -- Verifica se houve problema na exclusao de registros
                             
                 WHEN OTHERS THEN -- Descricao do erro na insercao de registros
                    vr_dscritic := 'Problema ao excluir Produto: ' || sqlerrm;
                 RAISE vr_exc_saida;
              END;
                            
              IF cr_crapmpc_log%NOTFOUND THEN
                CLOSE cr_crapmpc_log;
              ELSE
                FETCH cr_crapmpc_log INTO rw_crapmpc_log;
                -- 02/05/2014 – 08:00:00 ? Operador 1 excluiu modalidade: produto 1 - RDCPOS SELIC, código 1, carencia 30, 
                -- prazo 180, valor inicial da faixa 100.000,00, rentabilidade 95,000000, taxa fixa 0,000000. 
                -- Cooperativas que utilizavam a modalidade: VIACREDI, ACREDI.                      
                vr_dsmsglog := TO_CHAR(SYSDATE,'dd/mm/rrrr hh24:mi:ss') || ' -> Operador: ' || vr_cdoperad || ' excluiu modalidade para o produto: ' 
                                                                      || rw_crapmpc_log.cdprodut || ' - ' || rw_crapmpc_log.nmprodut  
                                                                      || ', codigo '|| rw_crapmpc_log.cdmodali || ', carencia '|| rw_crapmpc_log.qtdiacar 
                                                                      ||', prazo '|| rw_crapmpc_log.qtdiaprz || ', valor inicial da faixa '
                                                                      || TO_CHAR(rw_crapmpc_log.vlrfaixa, '999G990D000000', 'NLS_NUMERIC_CHARACTERS=,.')||', rentabilidade'
                                                                      || TO_CHAR(rw_crapmpc_log.vlperren, '999G990D000000') ||', taxa fixa'
                                                                      || TO_CHAR(rw_crapmpc_log.vltxfixa, '999G990D000000')||'.';
                IF vr_cooperativas IS NOT NULL THEN
                   vr_dsmsglog := vr_dsmsglog ||' Cooperativa(s) que utilizava(m) a modalidade: ' || vr_cooperativas;
                END IF;
                
                -- faz a impressao a cada iteracao
                BTCH0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                          ,pr_ind_tipo_log => 1
                                          ,pr_des_log      => vr_dsmsglog
                                          ,pr_nmarqlog     => 'pcapta'
                                          ,pr_flnovlog     => 'N');
                                              
                
                CLOSE cr_crapmpc_log;
                -- limpa a variavel para nao haver duplicidade no LOG
                vr_dsmsglog := ''; 
              END IF;            
            END LOOP;                        
          END IF;                     
      END CASE;

      IF vr_dsmsglog IS NOT NULL THEN
        -- Incluir log de execução.
        BTCH0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                  ,pr_ind_tipo_log => 1
                                  ,pr_des_log      => vr_dsmsglog
                                  ,pr_nmarqlog     => 'pcapta'
                                  ,pr_flnovlog     => 'N');
      END IF;    
    

      EXCEPTION
        WHEN vr_exc_saida THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic;

          -- Carregar XML padrão para variável de retorno não utilizada.
          -- Existe para satisfazer exigência da interface.
          pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
          ROLLBACK;
        WHEN OTHERS THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := 'Erro geral em Procedure de Modalidades: ' || SQLERRM;

          -- Carregar XML padrão para variável de retorno não utilizada.
          -- Existe para satisfazer exigência da interface.
          pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
          ROLLBACK;
      END;  
    
  END pc_manter_modalidade;


  /* Rotina referente a produtos da tela PCAPTA */
  PROCEDURE pc_manter_produto(pr_cddopcao IN VARCHAR2 --> Codigo do Opção
                             ,pr_cdprodut IN crapcpc.cdprodut%TYPE --> Codigo do Produto
                             ,pr_nmprodut IN crapcpc.nmprodut%TYPE --> Nome do Produto
                             ,pr_idsitpro IN crapcpc.idsitpro%TYPE --> Situação
                             ,pr_cddindex IN crapcpc.cddindex%TYPE --> Codigo do Indexador
                             ,pr_idtippro IN crapcpc.idtippro%TYPE --> Tipo
                             ,pr_idtxfixa IN crapcpc.idtxfixa%TYPE --> Taxa Fixa
                             ,pr_idacumul IN crapcpc.idacumul%TYPE --> Taxa Cumulativa                         
                             ,pr_indplano IN INTEGER               --> Apl. Programada (1 = Sim / 2 = Nao)
                             ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                             ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                             ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                             ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                             ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                             ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
  BEGIN
  
    /* .............................................................................

     Programa: pc_manter_produto
     Sistema : Novos Produtos de Captação
     Sigla   : APLI
     Autor   : Jean Michel
     Data    : Junho/14.                    Ultima atualizacao: 26/09/2018

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina de validacao de dados de produto tela PCAPTA.

     Observacao: -----

     Alteracoes: Implementacao das validacoes necessarias ao cadastro/alteracao de 
                 produtos. Criacao do cursor de listagem de modalidades e tambem
                 de carteira para os produtos, implementacao do LOG de operacoes.
                 {Carlos Rafael Tanholi - 17/07/2014}
                 
                 26/09/2018 - Inclusao do parâmetro indplano para apl. programada
                              Proj. 411.2 - CIS Corporate
     ..............................................................................*/ 
    DECLARE
          
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
      vr_null      EXCEPTION;

      vr_cdprodut crapcpc.cdprodut%TYPE;
      
      -- codigo sequencial produto
      vr_seqcdpro INTEGER := 0;
      
      -- Mensagem de log
      vr_dsmsglog VARCHAR2(4000); 
      
      -- Variaveis de log
      vr_cdcooper INTEGER := 0;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);
      vr_nmdindex crapind.nmdindex %TYPE;
      vr_indplano crapcpc.indplano%TYPE;
      
      vr_idsitpro VARCHAR2(100);
      vr_cdindex VARCHAR2(100);
      vr_idtippro VARCHAR2(100);
      vr_idtxfixa VARCHAR2(100);
      vr_idacumul VARCHAR2(100);       
      vt_indplano VARCHAR2(100);       
      
      vr_vtsitpro VARCHAR2(100) := 'ATIVO,INATIVO';
      vr_vttippro VARCHAR2(100) := 'PRE-FIXADA,POS-FIXADA'; --seguindo a ordem PRE=1/POS=2
      vr_vttfacum VARCHAR2(100) := 'SIM,NAO';            
     
            
      -- Selecionar os produtos com o mesmo nome
      CURSOR cr_crapcpc_nom(pr_nmprodut IN crapcpc.nmprodut%TYPE
             	             ,pr_cdprodut IN crapcpc.cdprodut%TYPE) IS
      SELECT
        cpc.cdprodut
       ,cpc.nmprodut
       ,cpc.idsitpro
       ,cpc.cddindex
       ,cpc.idtippro
       ,cpc.idtxfixa
       ,cpc.idacumul
       ,cpc.indplano
      FROM
       crapcpc cpc
      WHERE cpc.nmprodut = pr_nmprodut
        AND cpc.cdprodut <> pr_cdprodut;
      
      rw_crapcpc_nom cr_crapcpc_nom%ROWTYPE;

      -- Selecionar os produtos com os mesmos parametros
      CURSOR cr_crapcpc_par(pr_idsitpro IN crapcpc.idsitpro%TYPE --> Situação
                           ,pr_cddindex IN crapcpc.cddindex%TYPE --> Codigo do Indexador
                           ,pr_idtippro IN crapcpc.idtippro%TYPE --> Tipo
                           ,pr_idtxfixa IN crapcpc.idtxfixa%TYPE --> Taxa Fixa
                           ,pr_idacumul IN crapcpc.idacumul%TYPE --> Taxa Cumulativa
                           ,pr_cdprodut IN crapcpc.cdprodut%TYPE --> Codigo do Produto
                           ,pr_indplano IN crapcpc.indplano%TYPE --> Apl. Programada (0=Nao, 1=Sim)
                           ) IS
      SELECT
        cpc.cdprodut
       ,cpc.nmprodut
       ,cpc.idsitpro
       ,cpc.cddindex
       ,cpc.idtippro
       ,cpc.idtxfixa
       ,cpc.idacumul
       ,cpc.indplano
      FROM
       crapcpc cpc
      WHERE
           cpc.idsitpro = pr_idsitpro
       AND cpc.cddindex = pr_cddindex
       AND cpc.idtippro = pr_idtippro
       AND cpc.idtxfixa = pr_idtxfixa
       AND cpc.idacumul = pr_idacumul
       AND cpc.indplano = pr_indplano
       AND cpc.cdprodut <> pr_cdprodut;
      
      rw_crapcpc_par cr_crapcpc_par%ROWTYPE; 

      -- Verificar se existe carteira para o produto
      CURSOR cr_craprac_car(pr_cdprodut IN crapcpc.cdprodut%TYPE) IS
      SELECT 
         craprac.nrdconta
      FROM 
         craprac
         ,crapcop
      WHERE craprac.cdcooper = crapcop.cdcooper 
        AND crapcop.flgativo = 1
        AND craprac.cdprodut = pr_cdprodut;    

      rw_craprac_car cr_craprac_car%ROWTYPE;
      
      -- lista modalidades do produto
      CURSOR cr_crapdpc_mod(pr_cdprodut IN crapcpc.cdprodut%TYPE) IS
      SELECT
         crapmpc.cdmodali
        FROM 
         crapcpc 
         ,crapmpc
       WHERE 
         crapcpc.cdprodut = crapmpc.cdprodut 
         AND crapmpc.cdprodut = pr_cdprodut;
         
      rw_crapdpc_mod cr_crapdpc_mod%ROWTYPE;     
      
      
      -- Seleciona os produtos de captacao
      CURSOR cr_crapcpc (pr_cdprodut IN crapcpc.cdprodut%TYPE) IS
      SELECT
        cpc.cdprodut,
        cpc.nmprodut,
        cpc.idsitpro,
        cpc.cddindex,
        cpc.idtippro,
        cpc.idtxfixa,
        cpc.idacumul,
        cpc.indplano
      FROM
       crapcpc cpc
      WHERE
       cpc.cdprodut = pr_cdprodut;
      
       rw_crapcpc cr_crapcpc%ROWTYPE;      


      -- Selecionar as administradoras de cartao
      CURSOR cr_crapind (pr_cddindex IN crapind.cddindex%TYPE) IS
      SELECT
        ind.cddindex,
        ind.nmdindex,
        ind.idperiod,
        ind.idcadast,
        ind.idexpres
      FROM
       crapind ind
      WHERE
       ind.cddindex = pr_cddindex OR pr_cddindex = 0;

       rw_crapind cr_crapind%ROWTYPE;       
       

    BEGIN
      
      IF pr_indplano = 1 THEN
         vr_indplano := 1;
      ELSE
         vr_indplano := 0;
      END IF;
      
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);    
    
      
      IF pr_cdprodut > 0 THEN
        vr_cdprodut := pr_cdprodut;  
         
        OPEN cr_crapcpc(vr_cdprodut);
        
        FETCH cr_crapcpc INTO rw_crapcpc;

        IF cr_crapcpc%NOTFOUND THEN
          vr_cdcritic := 001;
          vr_dscritic := 'Produto inexistente.';
          
          RAISE vr_exc_saida;
          
        END IF;
        
        CLOSE cr_crapcpc;
      ELSE
         vr_cdprodut := 0;
      END IF;
    
      -- Verifica opcao
      CASE pr_cddopcao  
      
        WHEN 'V' THEN -- validacao
            
          -- Criar cabeçalho do XML
          pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');

          -- cria no de validacao
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados'   , pr_posicao => 0     , pr_tag_nova => 'valida', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
          
          -- executa validacoes para exclusao/alteracao dos produtos
          IF pr_cdprodut > 0 THEN 

            -- Busca produto com carteira  
            OPEN cr_craprac_car(pr_cdprodut); -- Codigo do Produto

            FETCH cr_craprac_car
              INTO rw_craprac_car;
                                      
            -- Se não encontrar nenhuma carteira para o produto
            IF cr_craprac_car%NOTFOUND THEN
              CLOSE cr_craprac_car;
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'valida', pr_posicao => 0, pr_tag_nova => 'carteira', pr_tag_cont => 'N', pr_des_erro => vr_dscritic);              
            ELSE
              CLOSE cr_craprac_car; 
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'valida', pr_posicao => 0, pr_tag_nova => 'carteira', pr_tag_cont => 'S', pr_des_erro => vr_dscritic);
            END IF;          
          
          
            -- Busca modalidades do produto
            OPEN cr_crapdpc_mod(pr_cdprodut);
            
            FETCH cr_crapdpc_mod
             INTO rw_crapdpc_mod;
             
             IF cr_crapdpc_mod%NOTFOUND THEN
               CLOSE cr_crapdpc_mod;
               gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'valida', pr_posicao => 0, pr_tag_nova => 'modalidade', pr_tag_cont => 'N', pr_des_erro => vr_dscritic);                             
             ELSE
               CLOSE cr_crapdpc_mod;               
               gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'valida', pr_posicao => 0, pr_tag_nova => 'modalidade', pr_tag_cont => 'S', pr_des_erro => vr_dscritic);              
             END IF;  
             
          ELSE
             -- gera os LOG's necessarios
             gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'valida', pr_posicao => 0, pr_tag_nova => 'carteira', pr_tag_cont => 'N', pr_des_erro => vr_dscritic);                 
             gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'valida', pr_posicao => 0, pr_tag_nova => 'modalidade', pr_tag_cont => 'N', pr_des_erro => vr_dscritic);                                                       
          END IF;
             
          -- Busca produto com mesmo nome
          OPEN cr_crapcpc_nom(pr_nmprodut, vr_cdprodut);

          FETCH cr_crapcpc_nom
            INTO rw_crapcpc_nom;
                                    
          -- Se não encontrar
          IF cr_crapcpc_nom%NOTFOUND THEN
            CLOSE cr_crapcpc_nom;
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'valida', pr_posicao => 0, pr_tag_nova => 'nome_valido', pr_tag_cont => 'N', pr_des_erro => vr_dscritic);              
          ELSE
            CLOSE cr_crapcpc_nom; 
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'valida', pr_posicao => 0, pr_tag_nova => 'nome_valido', pr_tag_cont => 'S', pr_des_erro => vr_dscritic);              
          END IF;
            

          -- Busca produto com mesmos parametros
          OPEN cr_crapcpc_par(pr_idsitpro => pr_idsitpro --> Situação
                             ,pr_cddindex => pr_cddindex --> Codigo do Indexador
                             ,pr_idtippro => pr_idtippro --> Tipo
                             ,pr_idtxfixa => pr_idtxfixa --> Taxa Fixa
                             ,pr_idacumul => pr_idacumul --> Taxa Cumulativa
                             ,pr_cdprodut => pr_cdprodut --> Codigo Produto
                             ,pr_indplano => vr_indplano --> Apl. Programada
                              );

          FETCH cr_crapcpc_par
            INTO rw_crapcpc_par;
                      
          -- Se não encontrar
          IF cr_crapcpc_par%NOTFOUND THEN
            CLOSE cr_crapcpc_par;
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'valida', pr_posicao => 0, pr_tag_nova => 'parametros', pr_tag_cont => 'N', pr_des_erro => vr_dscritic);              
          ELSE
            CLOSE cr_crapcpc_par;             
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'valida', pr_posicao => 0, pr_tag_nova => 'parametros', pr_tag_cont => 'S', pr_des_erro => vr_dscritic);              
          END IF;                         

          -- gera um RAISE para retornar as validacoes feitas
          RAISE vr_null;            

        WHEN 'I' THEN -- insercao
          BEGIN
         
            -- armazena o novo ID gerado      
          
          INSERT INTO crapcpc(nmprodut, idsitpro, cddindex, idtippro, idtxfixa, idacumul)
               VALUES(pr_nmprodut, pr_idsitpro, pr_cddindex, pr_idtippro, pr_idtxfixa, pr_idacumul)
            RETURNING cdprodut INTO vr_seqcdpro; -- armazena o novo ID gerado
              
          -- Verifica se houve problema na insercao de registros
          EXCEPTION
            WHEN OTHERS THEN
              -- Descricao do erro na insercao de registros
              vr_dscritic := 'Problema ao incluir Produto: ' || sqlerrm;
              RAISE vr_exc_saida;
          END;          

          OPEN cr_crapind(pr_cddindex);
          
          FETCH cr_crapind
           INTO rw_crapind;
               

          /* Monta as variaveis de LOG */
          -- situacao
          vr_idsitpro := gene0002.fn_busca_entrada(pr_postext => pr_idsitpro,pr_dstext => vr_vtsitpro,pr_delimitador => ',');
          -- indexador
          vr_cdindex := rw_crapind.nmdindex;
          -- tipo 
          vr_idtippro := gene0002.fn_busca_entrada(pr_postext => pr_idtippro,pr_dstext => vr_vttippro,pr_delimitador => ',');
          -- taxa fixa
          vr_idtxfixa := gene0002.fn_busca_entrada(pr_postext => pr_idtxfixa,pr_dstext => vr_vttfacum,pr_delimitador => ',');
          -- acumulatividade
          vr_idacumul := gene0002.fn_busca_entrada(pr_postext => pr_idacumul,pr_dstext => vr_vttfacum,pr_delimitador => ',');
         
          -- gera LOG de operacao          
          vr_dsmsglog := TO_CHAR(SYSDATE,'dd/mm/rrrr hh24:mi:ss') || ' -> Operador: ' || vr_cdoperad 
                                                                || ' incluiu o produto ' || vr_seqcdpro || ':' 
                                                                || ' nome ' || pr_nmprodut 
                                                                || ', situacao '|| vr_idsitpro || ', indexador '
                                                                || vr_cdindex ||', tipo '|| vr_idtippro 
                                                                || ', taxa fixa '|| vr_idtxfixa ||', cumulatividade '|| vr_idacumul ||'.';
          -- monta o retorno para a tela
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'cadprod', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'cadprod', pr_posicao => 0, pr_tag_nova => 'msg', pr_tag_cont => 'OK', pr_des_erro => vr_dscritic);          
          
          CLOSE cr_crapind;
        
        WHEN 'A' THEN
          
          -- Busca produto pelo codigo, para criar o LOG
          OPEN cr_crapcpc(pr_cdprodut);

          FETCH cr_crapcpc
           INTO rw_crapcpc;        
        
          -- Valida existencia de carteira para o produto
          OPEN cr_craprac_car(pr_cdprodut); -- Codigo do produto                   
          
          FETCH cr_craprac_car
           INTO rw_craprac_car;        
        
          -- se nao identificar nenhuma carteira cadastrada para o produto
          -- atualiza todos os dados do mesmo
          IF cr_craprac_car%NOTFOUND THEN 
            -- fecha o cursor
            CLOSE cr_craprac_car;
            
            BEGIN   
              -- executa a atualizacao completa do produto
              UPDATE crapcpc 
                 SET crapcpc.nmprodut = pr_nmprodut,
                     crapcpc.idsitpro = pr_idsitpro,
                     crapcpc.cddindex = pr_cddindex,
                     crapcpc.idtippro = pr_idtippro,
                     crapcpc.idtxfixa = pr_idtxfixa,
                     crapcpc.idacumul = pr_idacumul,
                     crapcpc.indplano = vr_indplano
               WHERE crapcpc.cdprodut = pr_cdprodut; 
               
            EXCEPTION
              WHEN OTHERS THEN -- Descricao do erro na insercao de registros
                vr_dscritic := 'Problema ao atualizar Produto: ' || sqlerrm;
                RAISE vr_exc_saida;                                          
            END;
          
          ELSE -- caso ja possua uma carteira cadastrada para o produto
               -- permite apenas a alteracao do nome,situacao,indicador de acumulatividade

            CLOSE cr_craprac_car;         
          
            BEGIN   
               -- executa a atualizacao parcial do produto                
                UPDATE crapcpc 
                   SET crapcpc.nmprodut = pr_nmprodut,
                       crapcpc.idsitpro = pr_idsitpro,
                       crapcpc.idacumul = pr_idacumul,
                       crapcpc.indplano = vr_indplano
                 WHERE crapcpc.cdprodut = pr_cdprodut;   
                 
            EXCEPTION
              WHEN OTHERS THEN -- Descricao do erro na insercao de registros
                vr_dscritic := 'Problema ao atualizar Produto: ' || sqlerrm;
                RAISE vr_exc_saida;                         
            END;          
              
          END IF;

          IF ( rw_crapcpc.nmprodut <> pr_nmprodut ) THEN
             vr_dsmsglog := vr_dsmsglog || ' nome ' || rw_crapcpc.nmprodut || ' para ' || pr_nmprodut || ', ';
          END IF;  

          IF ( rw_crapcpc.idsitpro <> pr_idsitpro ) THEN
             vr_dsmsglog := vr_dsmsglog || ' situacao ' || gene0002.fn_busca_entrada(pr_postext =>  rw_crapcpc.idsitpro,pr_dstext => vr_vtsitpro ,pr_delimitador => ',') 
                                        || ' para '     || gene0002.fn_busca_entrada(pr_postext =>  pr_idsitpro,pr_dstext => vr_vtsitpro ,pr_delimitador => ',') 
                                        || ', ';
          END IF;   

          IF ( rw_crapcpc.cddindex <> pr_cddindex ) THEN
            
             -- consulta o novo indexador
             OPEN cr_crapind(pr_cddindex);  
             FETCH cr_crapind
              INTO rw_crapind;            
              -- armazena o nome do novo indexador
              vr_nmdindex := rw_crapind.nmdindex;
              CLOSE cr_crapind;
              
              -- consulta o antigo indexador
              OPEN cr_crapind(rw_crapcpc.cddindex);
             FETCH cr_crapind
              INTO rw_crapind;                          
              
             vr_dsmsglog := vr_dsmsglog || ' indexador ' || rw_crapind.nmdindex || ' para ' || vr_nmdindex || ', ';
             
             CLOSE cr_crapind;
          END IF;            

          IF ( rw_crapcpc.idtippro <> pr_idtippro ) THEN
             vr_dsmsglog := vr_dsmsglog || ' tipo ' || gene0002.fn_busca_entrada(pr_postext =>  rw_crapcpc.idtippro,pr_dstext => vr_vttippro ,pr_delimitador => ',')
                                        || ' para ' || gene0002.fn_busca_entrada(pr_postext =>  pr_idtippro,pr_dstext => vr_vttippro ,pr_delimitador => ',')
                                        || ', ';
          END IF;   
          
          IF ( rw_crapcpc.idtxfixa <> pr_idtxfixa ) THEN
             vr_dsmsglog := vr_dsmsglog || ' taxa fixa ' || gene0002.fn_busca_entrada(pr_postext =>  rw_crapcpc.idtxfixa, pr_dstext => vr_vttfacum ,pr_delimitador => ',')
                                        || ' para '      || gene0002.fn_busca_entrada(pr_postext =>  pr_idtxfixa, pr_dstext => vr_vttfacum ,pr_delimitador => ',')
                                        || ', ';
          END IF;   

          IF ( rw_crapcpc.idacumul <> pr_idacumul ) THEN
             vr_dsmsglog := vr_dsmsglog || ' cumulatividade ' || gene0002.fn_busca_entrada(pr_postext =>  rw_crapcpc.idacumul,  pr_dstext => vr_vttfacum ,pr_delimitador => ',')
                                        || ' para '           || gene0002.fn_busca_entrada(pr_postext =>  pr_idacumul,  pr_dstext => vr_vttfacum ,pr_delimitador => ',')
                                        || ', ';
          END IF;   
          
          IF vr_dsmsglog is not null THEN
            vr_dsmsglog := TO_CHAR(SYSDATE,'dd/mm/rrrr hh24:mi:ss') || ' -> Operador: ' || vr_cdoperad || ' alterou o produto ' || pr_cdprodut || ' - '|| rw_crapcpc.nmprodut ||' :' || vr_dsmsglog;
          END IF;
          
          CLOSE cr_crapcpc;          
          
          -- retorna OK pra tela 
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'excprod', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'excprod', pr_posicao => 0, pr_tag_nova => 'msg', pr_tag_cont => 'OK', pr_des_erro => vr_dscritic);                      

        WHEN 'E' THEN
          
          -- Busca produto pelo codigo, para criar o LOG
          OPEN cr_crapcpc(pr_cdprodut);

          FETCH cr_crapcpc
           INTO rw_crapcpc;
        
          -- Valida existencia de carteira para o produto
          OPEN cr_craprac_car(pr_cdprodut); -- Codigo do produto                   
          
          FETCH cr_craprac_car
           INTO rw_craprac_car;
           
          IF cr_craprac_car%FOUND THEN
            CLOSE cr_craprac_car; 
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'cartprod', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'cartprod', pr_posicao => 0, pr_tag_nova => 'msg', pr_tag_cont => 'Exclusão não permitida. O produto possui carteira.', pr_des_erro => vr_dscritic);
            RAISE vr_null;           
            
          ELSE 
            CLOSE cr_craprac_car;
            BEGIN
                    
              DELETE FROM crapnpc WHERE crapnpc.cdprodut = pr_cdprodut;                          
              DELETE FROM crapmpc WHERE crapmpc.cdprodut = pr_cdprodut;                    
              DELETE FROM crapcpc WHERE crapcpc.cdprodut = pr_cdprodut;
                    
            -- Verifica se houve problema na exclusao de registros
            EXCEPTION
              WHEN OTHERS THEN -- Descricao do erro na insercao de registros
                vr_dscritic := 'Problema ao excluir Produto: ' || sqlerrm;
                RAISE vr_exc_saida;
            END;
            
            -- recupera as modalidades do produto            
            OPEN cr_crapdpc_mod(pr_cdprodut);
            
            FETCH cr_crapdpc_mod
             INTO rw_crapdpc_mod;
             
            IF cr_crapdpc_mod%NOTFOUND THEN 
              CLOSE cr_crapdpc_mod;
            ELSE 
              BEGIN 
               DELETE FROM crapdpc WHERE crapdpc.cdmodali = rw_crapdpc_mod.cdmodali;    
                                
              CLOSE cr_crapdpc_mod;               
                    
              -- Verifica se houve problema na exclusao de registros
              EXCEPTION
                WHEN OTHERS THEN -- Descricao do erro na insercao de registros
                  vr_dscritic := 'Problema ao excluir as modalidades do produto: ' || sqlerrm;
                  RAISE vr_exc_saida;
              END;              
            END IF;    
              
            -- gera LOG de operacao
            vr_dsmsglog := TO_CHAR(SYSDATE,'dd/mm/rrrr hh24:mi:ss') || ' -> Operador: ' || vr_cdoperad || ' excluiu o produto ' || vr_cdprodut || ': ' || rw_crapcpc.nmprodut; 
                   
            CLOSE cr_crapcpc;
            
            -- retorna OK pra tela 
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'excprod', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'excprod', pr_posicao => 0, pr_tag_nova => 'msg', pr_tag_cont => 'OK', pr_des_erro => vr_dscritic);            
            
          END IF;

        END CASE;

        IF vr_dsmsglog IS NOT NULL THEN
           -- fecha o cursor do produto

          -- Incluir log de execução.
          BTCH0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                    ,pr_ind_tipo_log => 1
                                    ,pr_des_log      => vr_dsmsglog
                                    ,pr_nmarqlog     => 'pcapta'
                                    ,pr_flnovlog     => 'N');
        END IF;

        COMMIT;

    EXCEPTION
      WHEN vr_null THEN
        NULL;  
      WHEN vr_exc_saida THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;

  END pc_manter_produto;


  /* Rotina referente a modalidades do produtos da tela PCAPTA */
  PROCEDURE pc_manter_modal_coop(pr_cddopcao IN VARCHAR2              --> Codigo do Opção
                                ,pr_cdcooper IN crapcop.cdcooper%TYPE --> Codigo da Cooperativa    
                                ,pr_cdmodali IN VARCHAR2              --> Codigo da Modalidade
                                ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
  BEGIN
  
    /* .............................................................................

     Programa: pc_manter_modal_coop
     Sistema : Novos Produtos de Captação
     Sigla   : APLI
     Autor   : Carlos Rafael Tanholi
     Data    : Agosto/14.                    Ultima atualizacao: 13/08/2014

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina de manipulacao de definição da politica de captacao tela PCAPTA.

     Observacao: -----

     Alteracoes: 
     
     ..............................................................................*/ 
    DECLARE
            
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);      
      
      -- array com modalidades
      vr_arrcdmod GENE0002.typ_split;  
          
      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
      vr_null      EXCEPTION;      
      
      -- Mensagem de log
      vr_dsmsglog VARCHAR2(4000); 
      
      -- Variaveis de log
      vr_cdcooper INTEGER := 0;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);
      
      -- recuperar dados da modalidade
      CURSOR cr_crapmpc_log(pr_cdmodali IN  crapmpc.cdmodali%TYPE) IS      
      SELECT
         mpc.*
        ,cpc.nmprodut
        FROM crapmpc mpc
            ,crapcpc cpc
       WHERE cpc.cdprodut = mpc.cdprodut
         AND mpc.cdmodali = pr_cdmodali;
             
      rw_crapmpc_log cr_crapmpc_log%ROWTYPE;  


      -- recupera dados da cooperativa
      CURSOR cr_crapcop_log(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
      SELECT cop.nmrescop
        FROM crapcop cop
       WHERE cop.cdcooper = pr_cdcooper
         AND cop.flgativo = 1; 
         
       rw_crapcop_log cr_crapcop_log%ROWTYPE;   
       
       
      -- valida existencia da modalidade para a cooperativa
      CURSOR cr_crapdpc(pr_cdcooper IN crapcop.cdcooper%TYPE
                        ,pr_cdmodali IN crapdpc.cdmodali%TYPE) IS
      SELECT
         cdcooper
        FROM 
         crapdpc 
       WHERE 
         crapdpc.cdmodali = pr_cdmodali
         AND crapdpc.cdcooper = pr_cdcooper;
         
      rw_crapdpc cr_crapdpc%ROWTYPE;           


    BEGIN
      
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);    
    
      
      -- Verifica opcao
      CASE pr_cddopcao  
        
        WHEN 'V' THEN -- validacao
                  
          -- Criar cabeçalho do XML
          pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');

          -- cria no de validacao
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados'   , pr_posicao => 0     , pr_tag_nova => 'valida', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
                  
          -- Busca produto com carteira  
          OPEN cr_crapdpc(pr_cdcooper, pr_cdmodali); -- Codigo do Produto

          FETCH cr_crapdpc
            INTO rw_crapdpc;
                                                
          -- Se não encontrar nenhuma carteira para o produto
          IF cr_crapdpc%NOTFOUND THEN
            CLOSE cr_crapdpc;
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'valida', pr_posicao => 0, pr_tag_nova => 'modalidade', pr_tag_cont => 'N', pr_des_erro => vr_dscritic);              
          ELSE
            CLOSE cr_crapdpc; 
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'valida', pr_posicao => 0, pr_tag_nova => 'modalidade', pr_tag_cont => 'S', pr_des_erro => vr_dscritic);
          END IF;
      
        WHEN 'I' THEN -- insercao
          vr_arrcdmod := GENE0002.fn_quebra_string(pr_cdmodali, ',');     
          
          -- recupera os dados da cooperativa          
          OPEN cr_crapcop_log(pr_cdcooper);          

          FETCH cr_crapcop_log INTO rw_crapcop_log;
          
          -- valida o(s) codigo(s) da modalidade
          IF vr_arrcdmod.count() > 0 AND cr_crapcop_log%FOUND THEN
            -- percore o array de modalidades
            FOR idx IN 1..vr_arrcdmod.count() LOOP          
        
              BEGIN
              
                INSERT INTO crapdpc(cdcooper, cdmodali, idsitmod)
                     VALUES(pr_cdcooper, vr_arrcdmod(idx), 1); -- situacao = desbloqueado
                  
                -- Verifica se houve problema na insercao de registros
                EXCEPTION
                  WHEN OTHERS THEN
                    -- Descricao do erro na insercao de registros
                    vr_dscritic := 'Problema ao incluir Modalidade: ' || sqlerrm;
                    RAISE vr_exc_saida;
              END;          

              -- recupera os dados da modalidade          
              OPEN cr_crapmpc_log(vr_arrcdmod(idx));

              IF cr_crapmpc_log%NOTFOUND THEN
                CLOSE cr_crapmpc_log;
              ELSE
                FETCH cr_crapmpc_log INTO rw_crapmpc_log;
                
                /* Monta as variaveis de LOG */

                -- 01/05/2014 – 08:00:00 ? Operador 1 habilitou a modalidade 1 do produto 1 - RDCPOS SELIC na VIACREDI. 
                -- Carencia 30, prazo 180, valor inicial da faixa 100.000,00, rentabilidade 95,000000, taxa fixa 0,000000.
                -- Gera LOG de operacao                    
                vr_dsmsglog := TO_CHAR(SYSDATE,'dd/mm/rrrr hh24:mi:ss') || ' -> Operador: ' || vr_cdoperad 
                                                                      || ' habilitou a modalidade ' 
                                                                      || rw_crapmpc_log.cdmodali || ' do produto ' 
                                                                      || rw_crapmpc_log.cdprodut || ' - '
                                                                      || rw_crapmpc_log.nmprodut || ' na ' 
                                                                      || rw_crapcop_log.nmrescop || '.'
                                                                      || ' Carencia '|| rw_crapmpc_log.qtdiacar 
                                                                      || ', prazo '|| rw_crapmpc_log.qtdiaprz 
                                                                      || ', valor inicial da faixa ' || TO_CHAR(rw_crapmpc_log.vlrfaixa, '999G990D000000', 'NLS_NUMERIC_CHARACTERS=,.')
                                                                      || ', rentabilidade ' || TO_CHAR(rw_crapmpc_log.vlperren, '999G990D000000') 
                                                                      || ', taxa fixa ' || TO_CHAR(rw_crapmpc_log.vltxfixa, '999G990D000000') ||'.';
                                                                      

                -- Incluir log de execução.
                BTCH0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                          ,pr_ind_tipo_log => 1
                                          ,pr_des_log      => vr_dsmsglog
                                          ,pr_nmarqlog     => 'pcapta'
                                          ,pr_flnovlog     => 'N');

                CLOSE cr_crapmpc_log;           
              END IF;
              
            END LOOP;   
            
          END IF; 

          CLOSE cr_crapcop_log;
              
          -- monta o retorno para a tela
          /*
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'cadprod', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'cadprod', pr_posicao => 0, pr_tag_nova => 'msg', pr_tag_cont => 'OK', pr_des_erro => vr_dscritic);
          */
          
        WHEN 'E' THEN -- exclusao

          vr_arrcdmod := GENE0002.fn_quebra_string(pr_cdmodali, ',');     
          
          -- valida o(s) codigo(s) da modalidade
          IF vr_arrcdmod.count() > 0 AND pr_cdcooper > 0 THEN
            -- percore o array de modalidades
            FOR idx IN 1..vr_arrcdmod.count() LOOP

              -- recupera os dados da modalidade          
              OPEN cr_crapmpc_log(vr_arrcdmod(idx));

              -- recupera as cooperativas que utilizam a modalidade
              OPEN cr_crapcop_log(pr_cdcooper);
                            
              BEGIN
                DELETE FROM crapdpc WHERE crapdpc.cdmodali = vr_arrcdmod(idx)
                                      AND crapdpc.cdcooper = pr_cdcooper;
                              
              EXCEPTION -- Verifica se houve problema na exclusao de registros

                 WHEN OTHERS THEN
                    vr_dscritic := 'Problema ao excluir modalidade: ' || sqlerrm;
                 RAISE vr_exc_saida;
              END;
                            
              IF cr_crapmpc_log%NOTFOUND THEN
                CLOSE cr_crapmpc_log;
                CLOSE cr_crapcop_log;
              ELSE
                FETCH cr_crapmpc_log INTO rw_crapmpc_log;
                FETCH cr_crapcop_log INTO rw_crapcop_log;
                
                -- 02/05/2014 – 08:00:00 ? Operador 1 excluiu modalidade definida na VIACREDI: produto 1 - RDCPOS SELIC, 
                -- código 1, carencia 30, prazo 180, valor inicial da faixa 100.000,00, rentabilidade 95,000000, taxa fixa 0,000000.                
                                    
                vr_dsmsglog := TO_CHAR(SYSDATE,'dd/mm/rrrr hh24:mi:ss') || ' -> Operador: ' || vr_cdoperad || ' excluiu modalidade definida na '
                                                                      || rw_crapcop_log.nmrescop || ': produto ' || rw_crapmpc_log.cdprodut || ' - ' || rw_crapmpc_log.nmprodut  
                                                                      || ', codigo '|| rw_crapmpc_log.cdmodali || ', carencia '|| rw_crapmpc_log.qtdiacar 
                                                                      ||', prazo '|| rw_crapmpc_log.qtdiaprz || ', valor inicial da faixa '
                                                                      || TO_CHAR(rw_crapmpc_log.vlrfaixa, '999G990D000000', 'NLS_NUMERIC_CHARACTERS=,.')||', rentabilidade'
                                                                      || TO_CHAR(rw_crapmpc_log.vlperren, '999G990D000000') ||', taxa fixa'
                                                                      || TO_CHAR(rw_crapmpc_log.vltxfixa, '999G990D000000') ||'.';
                -- faz a impressao a cada iteracao
                BTCH0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                          ,pr_ind_tipo_log => 1
                                          ,pr_des_log      => vr_dsmsglog
                                          ,pr_nmarqlog     => 'pcapta'
                                          ,pr_flnovlog     => 'N');
                                              
                
                CLOSE cr_crapmpc_log;
                CLOSE cr_crapcop_log;
                -- limpa a variavel para nao haver duplicidade no LOG
                vr_dsmsglog := ''; 
              END IF;            
            END LOOP;                        
          END IF; 
          

        WHEN 'D' THEN -- desbloqueio

          vr_arrcdmod := GENE0002.fn_quebra_string(pr_cdmodali, ',');     
          
          -- valida o(s) codigo(s) da modalidade
          IF vr_arrcdmod.count() > 0 AND pr_cdcooper > 0 THEN
            -- percore o array de modalidades
            FOR idx IN 1..vr_arrcdmod.count() LOOP

              -- recupera os dados da modalidade          
              OPEN cr_crapmpc_log(vr_arrcdmod(idx));

              -- recupera as cooperativas que utilizam a modalidade
              OPEN cr_crapcop_log(pr_cdcooper);
                            
              BEGIN
                                      
                UPDATE crapdpc SET crapdpc.idsitmod = 1 /** Desbloqueio **/
                 WHERE crapdpc.cdcooper = pr_cdcooper AND
                       crapdpc.cdmodali = vr_arrcdmod(idx);                                     
                              
              EXCEPTION -- Verifica se houve problema na exclusao de registros

                 WHEN OTHERS THEN
                    vr_dscritic := 'Problema ao desbloquear modalidade: ' || sqlerrm;
                 RAISE vr_exc_saida;
              END;
                            
              IF cr_crapmpc_log%NOTFOUND THEN
                CLOSE cr_crapmpc_log;
                CLOSE cr_crapcop_log;
              ELSE
                FETCH cr_crapmpc_log INTO rw_crapmpc_log;
                FETCH cr_crapcop_log INTO rw_crapcop_log;
                
                -- 02/05/2014 – 08:00:00 ? Operador 1 desbloqueou modalidade definida na VIACREDI: produto 1 - RDCPOS SELIC, 
                -- código 1, carencia 30, prazo 180, valor inicial da faixa 100.000,00, rentabilidade 95,000000, taxa fixa 0,000000.
                vr_dsmsglog := TO_CHAR(SYSDATE,'dd/mm/rrrr hh24:mi:ss') || ' -> Operador: ' || vr_cdoperad || ' desbloqueou modalidade definida na '
                                                                      || rw_crapcop_log.nmrescop || ': produto ' || rw_crapmpc_log.cdprodut || ' - ' || rw_crapmpc_log.nmprodut  
                                                                      || ', codigo '|| rw_crapmpc_log.cdmodali || ', carencia '|| rw_crapmpc_log.qtdiacar 
                                                                      ||', prazo '|| rw_crapmpc_log.qtdiaprz || ', valor inicial da faixa '
                                                                      || TO_CHAR(rw_crapmpc_log.vlrfaixa, '999G990D000000', 'NLS_NUMERIC_CHARACTERS=,.')||', rentabilidade'
                                                                      || TO_CHAR(rw_crapmpc_log.vlperren, '999G990D000000') ||', taxa fixa'
                                                                      || TO_CHAR(rw_crapmpc_log.vltxfixa, '999G990D000000') ||'.';
                -- faz a impressao a cada iteracao
                BTCH0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                          ,pr_ind_tipo_log => 1
                                          ,pr_des_log      => vr_dsmsglog
                                          ,pr_nmarqlog     => 'pcapta'
                                          ,pr_flnovlog     => 'N');
                                              
                
                CLOSE cr_crapmpc_log;
                CLOSE cr_crapcop_log;
                -- limpa a variavel para nao haver duplicidade no LOG
                vr_dsmsglog := ''; 
              END IF;            
            END LOOP;                        
          END IF;     
                
 
       WHEN 'B' THEN -- bloqueio

          vr_arrcdmod := GENE0002.fn_quebra_string(pr_cdmodali, ',');     
          
          -- valida o(s) codigo(s) da modalidade
          IF vr_arrcdmod.count() > 0 AND pr_cdcooper > 0 THEN
            -- percore o array de modalidades
            FOR idx IN 1..vr_arrcdmod.count() LOOP

              -- recupera os dados da modalidade          
              OPEN cr_crapmpc_log(vr_arrcdmod(idx));

              -- recupera as cooperativas que utilizam a modalidade
              OPEN cr_crapcop_log(pr_cdcooper);
                            
              BEGIN
                                      
                UPDATE crapdpc SET crapdpc.idsitmod = 2 /** Bloqueio **/
                 WHERE crapdpc.cdcooper = pr_cdcooper AND
                       crapdpc.cdmodali = vr_arrcdmod(idx);                                     
                              
              EXCEPTION -- Verifica se houve problema na exclusao de registros

                 WHEN OTHERS THEN
                    vr_dscritic := 'Problema ao bloquear modalidade: ' || sqlerrm;
                 RAISE vr_exc_saida;
              END;
                            
              IF cr_crapmpc_log%NOTFOUND THEN
                CLOSE cr_crapmpc_log;
                CLOSE cr_crapcop_log;
              ELSE
                FETCH cr_crapmpc_log INTO rw_crapmpc_log;
                FETCH cr_crapcop_log INTO rw_crapcop_log;
                
                -- 02/05/2014 – 08:00:00 ? Operador 1 bloqueou modalidade definida na VIACREDI: produto 1 - RDCPOS SELIC, 
                -- código 1, carencia 30, prazo 180, valor inicial da faixa 100.000,00, rentabilidade 95,000000, taxa fixa 0,000000.
                vr_dsmsglog := TO_CHAR(SYSDATE,'dd/mm/rrrr hh24:mi:ss') || ' -> Operador: ' || vr_cdoperad || ' bloqueou modalidade definida na '
                                                                      || rw_crapcop_log.nmrescop || ': produto ' || rw_crapmpc_log.cdprodut || ' - ' || rw_crapmpc_log.nmprodut  
                                                                      || ', codigo '|| rw_crapmpc_log.cdmodali || ', carencia '|| rw_crapmpc_log.qtdiacar 
                                                                      ||', prazo '|| rw_crapmpc_log.qtdiaprz || ', valor inicial da faixa '
                                                                      || TO_CHAR(rw_crapmpc_log.vlrfaixa, '999G990D000000', 'NLS_NUMERIC_CHARACTERS=,.')||', rentabilidade'
                                                                      || TO_CHAR(rw_crapmpc_log.vlperren, '999G990D000000') ||', taxa fixa'
                                                                      || TO_CHAR(rw_crapmpc_log.vltxfixa, '999G990D000000') ||'.';
                -- faz a impressao a cada ITERACAO
                BTCH0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                          ,pr_ind_tipo_log => 1
                                          ,pr_des_log      => vr_dsmsglog
                                          ,pr_nmarqlog     => 'pcapta'
                                          ,pr_flnovlog     => 'N');
                                              
                
                CLOSE cr_crapmpc_log;
                CLOSE cr_crapcop_log;
                -- limpa a variavel para nao haver duplicidade no LOG
                vr_dsmsglog := ''; 
              END IF;            
            END LOOP;  

          END IF;       
                              
        END CASE;

        COMMIT;

    EXCEPTION
      WHEN vr_null THEN
        NULL;  
      WHEN vr_exc_saida THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;

  END pc_manter_modal_coop;




  /* Rotina referente a validacao de acesso as opcoes da tela PCAPTA */
  PROCEDURE pc_valida_acesso(pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                            ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                            ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                            ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                            ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                            ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
  BEGIN
  
    /* .............................................................................

     Programa: pc_valida_acesso
     Sistema : Novos Produtos de Captação
     Sigla   : APLI
     Autor   : Carlos Rafael Tanholi
     Data    : Setembro/14.                    Ultima atualizacao: 10/10/2014

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina de validacao de acesso ao sistema

     Observacao: -----

     Alteracoes: 
     ..............................................................................*/ 
    DECLARE
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);
      -- Tratamento de erros
      vr_exc_saida EXCEPTION;          

      BEGIN
        -- Criar cabeçalho do XML
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
    
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados'   , pr_posicao => 0     , pr_tag_nova => 'inf', pr_tag_cont => 'OK', pr_des_erro => vr_dscritic);        
        
      EXCEPTION
        WHEN vr_exc_saida THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic;

          -- Carregar XML padrão para variável de retorno não utilizada.
          -- Existe para satisfazer exigência da interface.
          pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
          ROLLBACK;
        WHEN OTHERS THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := 'Erro geral em validacao de permissao: ' || SQLERRM;

          -- Carregar XML padrão para variável de retorno não utilizada.
          -- Existe para satisfazer exigência da interface.
          pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
          ROLLBACK;
      END;

  END pc_valida_acesso;



end APLI0003;
/
