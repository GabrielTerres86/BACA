CREATE OR REPLACE PACKAGE CECRED.TELA_PARRGP AS

   /*
   Programa: TELA_PARRGP                          antigo:
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED

   Autor   : Jonata - RKAM
   Data    : Maio/2017                       Ultima atualizacao:  

   Dados referentes ao programa:

   Frequencia: Diario (on-line).
   Objetivo  : Mostrar a tela PARRGP para permitir a listagem, inserção, alteração e exclusão dos 
               parâmetros para Provisão das Garantias Prestadas pelas Cooperativas do Grupo.

   Alteracoes: 
   
   */               
   
  PROCEDURE pc_busca_provisoes(pr_cddopcao IN VARCHAR2              --Opção da tela
                              ,pr_nrregist IN INTEGER               --Quantidade de registros                            
                              ,pr_nriniseq IN INTEGER               --Qunatidade inicial
                              ,pr_xmllog   IN VARCHAR2              --XML com informações de LOG
                              ,pr_cdcritic OUT PLS_INTEGER          --Código da crítica
                              ,pr_dscritic OUT VARCHAR2             --Descrição da crítica
                              ,pr_retxml   IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                              ,pr_nmdcampo OUT VARCHAR2             --Nome do Campo
                              ,pr_des_erro OUT VARCHAR2);           --Saida OK/NOK
                              
  PROCEDURE pc_manter_rotina(pr_idproduto                  IN tbrisco_provisgarant_prodt.idproduto%TYPE --Código do produto
                            ,pr_dsproduto                  IN tbrisco_provisgarant_prodt.dsproduto%TYPE --Descrição do produto
                            ,pr_tpdestino                  IN tbrisco_provisgarant_prodt.tpdestino%TYPE --Tipo de destino do produto
                            ,pr_tparquivo                  IN tbrisco_provisgarant_prodt.tparquivo%TYPE --Tipo de arquivo do produto
                            ,pr_idgarantia                 IN tbrisco_provisgarant_prodt.idgarantia%TYPE --Código da garantia do produto
                            ,pr_idmodalidade               IN tbrisco_provisgarant_prodt.idmodalidade%TYPE --Código da modalidade do produto
                            ,pr_idconta_cosif              IN tbrisco_provisgarant_prodt.idconta_cosif%TYPE --Código da conta cosif do produto
                            ,pr_idorigem_recurso           IN tbrisco_provisgarant_prodt.idorigem_recurso%TYPE --Código da origem de recurso do produto
                            ,pr_idindexador                IN tbrisco_provisgarant_prodt.idindexador%TYPE --Código do indexador do produto
                            ,pr_perindexador               IN tbrisco_provisgarant_prodt.perindexador%TYPE --Percentual de indexador do produto
                            ,pr_vltaxa_juros               IN tbrisco_provisgarant_prodt.vltaxa_juros%TYPE --Taxa de juros do produto
                            ,pr_cdclassifica_operacao      IN tbrisco_provisgarant_prodt.cdclassifica_operacao%TYPE --Classificação de operacção do produto
                            ,pr_idvariacao_cambial         IN tbrisco_provisgarant_prodt.idvariacao_cambial%TYPE --Código fa varição cambial do produto
                            ,pr_idorigem_cep               IN tbrisco_provisgarant_prodt.idorigem_cep%TYPE --Código origem do cep do produto
                            ,pr_idnat_operacao             IN tbrisco_provisgarant_prodt.idnat_operacao%TYPE --Código da natureza de operacao do produto
                            ,pr_idcaract_especial          IN tbrisco_provisgarant_prodt.idcaract_especial%TYPE --Código caracteristica do produto
                            ,pr_flpermite_saida_operacao   IN tbrisco_provisgarant_prodt.flpermite_saida_operacao%TYPE --Permite saida de operação do produto
                            ,pr_flpermite_fluxo_financeiro IN tbrisco_provisgarant_prodt.flpermite_fluxo_financeiro%TYPE --Permite fluxo financeiro
                            ,pr_flreaprov_mensal           IN tbrisco_provisgarant_prodt.flreaprov_mensal%TYPE --Permite reaproveitamento mensal
                            ,pr_cddopcao IN VARCHAR2              --Opção da tela
                            ,pr_xmllog   IN VARCHAR2              --XML com informações de LOG
                            ,pr_cdcritic OUT PLS_INTEGER          --Código da crítica
                            ,pr_dscritic OUT VARCHAR2             --Descrição da crítica
                            ,pr_retxml   IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                            ,pr_nmdcampo OUT VARCHAR2             --Nome do Campo
                            ,pr_des_erro OUT VARCHAR2);          --Saida OK/NOK
                                   
                                                                                
END TELA_PARRGP;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_PARRGP AS

/*---------------------------------------------------------------------------------------------------------------
   Programa: TELA_PARRGP                          antigo: 
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED

   Autor   : Jonata - RKAM
   Data    : Maio/2017                       Ultima atualizacao: 15/06/2017

   Dados referentes ao programa:

   Frequencia: Diario (on-line).
   Objetivo  : Mostrar a tela PARRGP para Mostrar a tela PARRGP para permitir a listagem, inserção, alteração e exclusão dos 
               parâmetros para Provisão das Garantias Prestadas pelas Cooperativas do Grupo.
               
   Alteracoes: 15/06/2017 - Ajustes decorrente a homologação do projeto P408 (Jonata - RKAM).

  ---------------------------------------------------------------------------------------------------------------*/
  
   
  
  PROCEDURE pc_gera_log(pr_cdcooper IN crapcop.cdcooper%TYPE
                       ,pr_idproduto IN tbrisco_provisgarant_prodt.idproduto%TYPE
                       ,pr_cdoperad IN crapope.cdoperad%TYPE
                       ,pr_dsdcampo IN VARCHAR2
                       ,pr_vlrcampo IN VARCHAR2
                       ,pr_vlcampo2 IN VARCHAR2
                       ,pr_des_erro OUT VARCHAR2) IS

  /*---------------------------------------------------------------------------------------------------------------

    Programa : pc_gera_log                            antiga:
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Jonata - RKAM
    Data     : Maio/2017                           Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: -----
    Objetivo   : Procedure para gerar log

    Alterações :
    -------------------------------------------------------------------------------------------------------------*/

   BEGIN

     IF pr_vlrcampo <> pr_vlcampo2 THEN

       -- Gera log
       btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                 ,pr_ind_tipo_log => 2 -- Erro tratato
                                 ,pr_nmarqlog     => 'parrgp.log'
                                 ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                     ' -->  Operador '|| pr_cdoperad || ' - ' ||
                                                     'Efetuou a alteracao do produto ' ||
                                                     'Codigo: ' || gene0002.fn_mask(pr_idproduto,'z.zzz.zz9') ||
                                                     ', ' || pr_dsdcampo || ' de ' || nvl(trim(pr_vlrcampo),'""') ||
                                                     ' para ' || nvl(trim(pr_vlcampo2),'""') || '.');

     END IF;

     pr_des_erro := 'OK';

   EXCEPTION
     WHEN OTHERS THEN
       pr_des_erro := 'NOK';
   END pc_gera_log;
  
  
  PROCEDURE pc_busca_provisoes(pr_cddopcao IN VARCHAR2              --Opção da tela
                              ,pr_nrregist IN INTEGER               --Quantidade de registros                            
                              ,pr_nriniseq IN INTEGER               --Qunatidade inicial
                              ,pr_xmllog   IN VARCHAR2              --XML com informações de LOG
                              ,pr_cdcritic OUT PLS_INTEGER          --Código da crítica
                              ,pr_dscritic OUT VARCHAR2             --Descrição da crítica
                              ,pr_retxml   IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                              ,pr_nmdcampo OUT VARCHAR2             --Nome do Campo
                              ,pr_des_erro OUT VARCHAR2)IS          --Saida OK/NOK
      
  /*---------------------------------------------------------------------------------------------------------------
    
    Programa : pc_busca_provisoes                            antiga: 
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Jonata - Mouts
    Data     : Maio/2017                          Ultima atualizacao:
    
    Dados referentes ao programa:
    
    Frequencia: -----
    Objetivo   : Buscas as provisões da tela PARRGP.
    
    Alterações : 
    -------------------------------------------------------------------------------------------------------------*/                                
     
    CURSOR cr_provisoes IS
    SELECT prodt.idproduto
          ,prodt.dsproduto
          ,DECODE(prodt.tpdestino,'S','Singular','Central') dscdestino
          ,prodt.tpdestino
          ,prodt.tparquivo
          ,prodt.idgarantia
          ,prodt.idmodalidade
          ,prodt.idconta_cosif
          ,prodt.idorigem_recurso
          ,prodt.idindexador
          ,prodt.perindexador
          ,prodt.idvariacao_cambial
          ,prodt.idnat_operacao
          ,prodt.idcaract_especial
          ,prodt.idorigem_cep
          ,prodt.flpermite_saida_operacao
          ,prodt.flpermite_fluxo_financeiro
          ,prodt.flreaprov_mensal 
          ,prodt.vltaxa_juros
          ,prodt.cdclassifica_operacao
     FROM tbrisco_provisgarant_prodt prodt
     ORDER BY idproduto;   
    
    -- Variaveis de locais
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100); 
    vr_contador  INTEGER := 0; 
    vr_qtregist  INTEGER := 0; 
    vr_nrregist INTEGER;
    
    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);
           
    --Variaveis de Excecoes
    vr_exc_erro  EXCEPTION; 
    
  BEGIN 
    
    --Inicializar Variaveis
    vr_nrregist:= pr_nrregist;
      
    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'PARRGP'
                              ,pr_action => null); 
                                 
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

    -- Verifica se houve erro recuperando informacoes de log                              
    IF vr_dscritic IS NOT NULL THEN
    
      RAISE vr_exc_erro;
      
    END IF; 

    -- Criar cabeçalho do XML
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="UTF-8"?><dados/>');
    
    -- Incrementa o contador           
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'dados', pr_posicao => 0, pr_tag_nova => 'provisoes', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
            
    FOR rw_provisoes IN cr_provisoes LOOP      
      
     --Incrementar Quantidade Registros do Parametro
      vr_qtregist:= nvl(vr_qtregist,0) + 1;
          
      /* controles da paginacao */
      IF (vr_qtregist < pr_nriniseq) OR
         (vr_qtregist > (pr_nriniseq + pr_nrregist)) THEN
         --Proximo Titular
        CONTINUE;
      END IF; 
          
      --Numero Registros
      IF vr_nrregist > 0 THEN 
                    
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'provisoes', pr_posicao => 0, pr_tag_nova => 'provisao', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'provisao', pr_posicao => vr_contador, pr_tag_nova => 'idproduto', pr_tag_cont => rw_provisoes.idproduto, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'provisao', pr_posicao => vr_contador, pr_tag_nova => 'dsproduto', pr_tag_cont => rw_provisoes.dsproduto, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'provisao', pr_posicao => vr_contador, pr_tag_nova => 'dscdestino', pr_tag_cont => rw_provisoes.dscdestino, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'provisao', pr_posicao => vr_contador, pr_tag_nova => 'tparquivo', pr_tag_cont => rw_provisoes.tparquivo, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'provisao', pr_posicao => vr_contador, pr_tag_nova => 'tpdestino', pr_tag_cont => rw_provisoes.tpdestino, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'provisao', pr_posicao => vr_contador, pr_tag_nova => 'iddominio_idgarantia', pr_tag_cont => rw_provisoes.idgarantia, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'provisao', pr_posicao => vr_contador, pr_tag_nova => 'idgarantia', pr_tag_cont => RISC0003.fn_valor_opcao_dominio(rw_provisoes.idgarantia), pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'provisao', pr_posicao => vr_contador, pr_tag_nova => 'dsgarantia', pr_tag_cont => RISC0003.fn_descri_opcao_dominio(rw_provisoes.idgarantia), pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'provisao', pr_posicao => vr_contador, pr_tag_nova => 'iddominio_idmodalidade', pr_tag_cont => rw_provisoes.idmodalidade, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'provisao', pr_posicao => vr_contador, pr_tag_nova => 'idmodalidade', pr_tag_cont => RISC0003.fn_valor_opcao_dominio(rw_provisoes.idmodalidade), pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'provisao', pr_posicao => vr_contador, pr_tag_nova => 'dsmodalidade', pr_tag_cont => RISC0003.fn_descri_opcao_dominio(rw_provisoes.idmodalidade), pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'provisao', pr_posicao => vr_contador, pr_tag_nova => 'iddominio_idconta_cosif', pr_tag_cont => rw_provisoes.idconta_cosif, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'provisao', pr_posicao => vr_contador, pr_tag_nova => 'idconta_cosif', pr_tag_cont => RISC0003.fn_valor_opcao_dominio(rw_provisoes.idconta_cosif), pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'provisao', pr_posicao => vr_contador, pr_tag_nova => 'dsconta_cosif', pr_tag_cont => RISC0003.fn_descri_opcao_dominio(rw_provisoes.idconta_cosif), pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'provisao', pr_posicao => vr_contador, pr_tag_nova => 'iddominio_idorigem_recurso', pr_tag_cont => rw_provisoes.idorigem_recurso, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'provisao', pr_posicao => vr_contador, pr_tag_nova => 'idorigem_recurso', pr_tag_cont => RISC0003.fn_valor_opcao_dominio(rw_provisoes.idorigem_recurso), pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'provisao', pr_posicao => vr_contador, pr_tag_nova => 'dsorigem_recurso', pr_tag_cont => RISC0003.fn_descri_opcao_dominio(rw_provisoes.idorigem_recurso), pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'provisao', pr_posicao => vr_contador, pr_tag_nova => 'iddominio_idindexador', pr_tag_cont => rw_provisoes.idindexador, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'provisao', pr_posicao => vr_contador, pr_tag_nova => 'idindexador', pr_tag_cont => RISC0003.fn_valor_opcao_dominio(rw_provisoes.idindexador), pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'provisao', pr_posicao => vr_contador, pr_tag_nova => 'dsindexador', pr_tag_cont => RISC0003.fn_descri_opcao_dominio(rw_provisoes.idindexador), pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'provisao', pr_posicao => vr_contador, pr_tag_nova => 'perindexador', pr_tag_cont => to_char(rw_provisoes.perindexador,'990D0000000','NLS_NUMERIC_CHARACTERS='',.''') , pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'provisao', pr_posicao => vr_contador, pr_tag_nova => 'iddominio_idvariacao_cambial', pr_tag_cont => rw_provisoes.idvariacao_cambial, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'provisao', pr_posicao => vr_contador, pr_tag_nova => 'idvariacao_cambial', pr_tag_cont => RISC0003.fn_valor_opcao_dominio(rw_provisoes.idvariacao_cambial), pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'provisao', pr_posicao => vr_contador, pr_tag_nova => 'dsvariacao_cambial', pr_tag_cont => RISC0003.fn_descri_opcao_dominio(rw_provisoes.idvariacao_cambial), pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'provisao', pr_posicao => vr_contador, pr_tag_nova => 'iddominio_idnat_operacao', pr_tag_cont => rw_provisoes.idnat_operacao, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'provisao', pr_posicao => vr_contador, pr_tag_nova => 'idnat_operacao', pr_tag_cont => RISC0003.fn_valor_opcao_dominio(rw_provisoes.idnat_operacao), pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'provisao', pr_posicao => vr_contador, pr_tag_nova => 'dsnat_operacao', pr_tag_cont => RISC0003.fn_descri_opcao_dominio(rw_provisoes.idnat_operacao), pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'provisao', pr_posicao => vr_contador, pr_tag_nova => 'iddominio_idcaract_especial', pr_tag_cont => rw_provisoes.idcaract_especial, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'provisao', pr_posicao => vr_contador, pr_tag_nova => 'idcaract_especial', pr_tag_cont => RISC0003.fn_valor_opcao_dominio(rw_provisoes.idcaract_especial), pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'provisao', pr_posicao => vr_contador, pr_tag_nova => 'dscaract_especial', pr_tag_cont => RISC0003.fn_descri_opcao_dominio(rw_provisoes.idcaract_especial), pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'provisao', pr_posicao => vr_contador, pr_tag_nova => 'idorigem_cep', pr_tag_cont => rw_provisoes.idorigem_cep, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'provisao', pr_posicao => vr_contador, pr_tag_nova => 'flpermite_saida_operacao', pr_tag_cont => rw_provisoes.flpermite_saida_operacao, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'provisao', pr_posicao => vr_contador, pr_tag_nova => 'flpermite_fluxo_financeiro', pr_tag_cont => rw_provisoes.flpermite_fluxo_financeiro, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'provisao', pr_posicao => vr_contador, pr_tag_nova => 'flreaprov_mensal', pr_tag_cont => rw_provisoes.flreaprov_mensal, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'provisao', pr_posicao => vr_contador, pr_tag_nova => 'vltaxa_juros', pr_tag_cont => to_char(rw_provisoes.vltaxa_juros,'990D0000000','NLS_NUMERIC_CHARACTERS='',.'''), pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'provisao', pr_posicao => vr_contador, pr_tag_nova => 'cdclassifica_operacao', pr_tag_cont => rw_provisoes.cdclassifica_operacao, pr_des_erro => vr_dscritic);
        
        vr_contador := vr_contador + 1;  
        
      END IF;
      
      --Diminuir registros
      vr_nrregist:= nvl(vr_nrregist,0) - 1;
                                           
    END LOOP;
    
    -- Insere atributo na tag Dados com a quantidade de registros
    gene0007.pc_gera_atributo(pr_xml   => pr_retxml           --> XML que irá receber o novo atributo
                             ,pr_tag   => 'dados'            --> Nome da TAG XML
                             ,pr_atrib => 'qtregist'             --> Nome do atributo
                             ,pr_atval => vr_qtregist    --> Valor do atributo
                             ,pr_numva => 0                   --> Número da localização da TAG na árvore XML
                             ,pr_des_erro => vr_dscritic);    --> Descrição de erros
                               
    --Se ocorreu erro
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF; 
    
    pr_des_erro := 'OK';  
  
  EXCEPTION
    WHEN vr_exc_erro THEN 
                     
      -- Erro
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      pr_nmdcampo := 'cdcooper';
      pr_des_erro := 'NOK'; 
                
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');    
                                                                                                     
    WHEN OTHERS THEN 
        
      -- Erro
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na pc_busca_provisoes --> '|| SQLERRM;
      pr_des_erro:= 'NOK';
          
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');     
    
  END pc_busca_provisoes;
  
  PROCEDURE pc_manter_rotina(pr_idproduto                  IN tbrisco_provisgarant_prodt.idproduto%TYPE --Código do produto
                            ,pr_dsproduto                  IN tbrisco_provisgarant_prodt.dsproduto%TYPE --Descrição do produto
                            ,pr_tpdestino                  IN tbrisco_provisgarant_prodt.tpdestino%TYPE --Tipo de destino do produto
                            ,pr_tparquivo                  IN tbrisco_provisgarant_prodt.tparquivo%TYPE --Tipo de arquivo do produto
                            ,pr_idgarantia                 IN tbrisco_provisgarant_prodt.idgarantia%TYPE --Código da garantia do produto
                            ,pr_idmodalidade               IN tbrisco_provisgarant_prodt.idmodalidade%TYPE --Código da modalidade do produto
                            ,pr_idconta_cosif              IN tbrisco_provisgarant_prodt.idconta_cosif%TYPE --Código da conta cosif do produto
                            ,pr_idorigem_recurso           IN tbrisco_provisgarant_prodt.idorigem_recurso%TYPE --Código da origem de recurso do produto
                            ,pr_idindexador                IN tbrisco_provisgarant_prodt.idindexador%TYPE --Código do indexador do produto
                            ,pr_perindexador               IN tbrisco_provisgarant_prodt.perindexador%TYPE --Percentual de indexador do produto
                            ,pr_vltaxa_juros               IN tbrisco_provisgarant_prodt.vltaxa_juros%TYPE --Taxa de juros do produto
                            ,pr_cdclassifica_operacao      IN tbrisco_provisgarant_prodt.cdclassifica_operacao%TYPE --Classificação de operacção do produto
                            ,pr_idvariacao_cambial         IN tbrisco_provisgarant_prodt.idvariacao_cambial%TYPE --Código fa varição cambial do produto
                            ,pr_idorigem_cep               IN tbrisco_provisgarant_prodt.idorigem_cep%TYPE --Código origem do cep do produto
                            ,pr_idnat_operacao             IN tbrisco_provisgarant_prodt.idnat_operacao%TYPE --Código da natureza de operacao do produto
                            ,pr_idcaract_especial          IN tbrisco_provisgarant_prodt.idcaract_especial%TYPE --Código caracteristica do produto
                            ,pr_flpermite_saida_operacao   IN tbrisco_provisgarant_prodt.flpermite_saida_operacao%TYPE --Permite saida de operação do produto
                            ,pr_flpermite_fluxo_financeiro IN tbrisco_provisgarant_prodt.flpermite_fluxo_financeiro%TYPE --Permite fluxo financeiro
                            ,pr_flreaprov_mensal           IN tbrisco_provisgarant_prodt.flreaprov_mensal%TYPE --Permite reaproveitamento mensal
                            ,pr_cddopcao IN VARCHAR2              --Opção da tela
                            ,pr_xmllog   IN VARCHAR2              --XML com informações de LOG
                            ,pr_cdcritic OUT PLS_INTEGER          --Código da crítica
                            ,pr_dscritic OUT VARCHAR2             --Descrição da crítica
                            ,pr_retxml   IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                            ,pr_nmdcampo OUT VARCHAR2             --Nome do Campo
                            ,pr_des_erro OUT VARCHAR2)IS          --Saida OK/NOK
      
  /*---------------------------------------------------------------------------------------------------------------
    
    Programa : pc_manter_rotina                            antiga: 
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Jonata - Mouts
    Data     : Maio/2017                          Ultima atualizacao: 15/06/2017
    
    Dados referentes ao programa:
    
    Frequencia: -----
    Objetivo   : Responsável pela inclusão/exclusão/alteração de provisão da tela PARRGP.
    
    Alterações : 15/06/2017 - Ajustes decorrente a homologação do projeto P408 (Jonata - RKAM).

    -------------------------------------------------------------------------------------------------------------*/                                
     
    CURSOR cr_mvto_1(pr_idproduto IN tbrisco_provisgarant_movto.idproduto%TYPE) IS
    SELECT 1
      FROM tbrisco_provisgarant_movto
      WHERE idproduto = pr_idproduto; 
    rw_mvto_1 cr_mvto_1%ROWTYPE;
    
    CURSOR cr_provisgarant_2(pr_idproduto IN tbrisco_provisgarant_movto.idproduto%TYPE) IS
    SELECT 1
      FROM tbrisco_provisgarant_movto
      WHERE idproduto = pr_idproduto
        AND dtbase = LAST_DAY(add_months(sysdate,-1));
    rw_provisgarant_2 cr_provisgarant_2%ROWTYPE;

    CURSOR cr_tbrisco_prodt_1(pr_dsproduto IN tbrisco_provisgarant_prodt.dsproduto%TYPE) IS
    SELECT *
      FROM tbrisco_provisgarant_prodt
      WHERE dsproduto = pr_dsproduto; 
    rw_tbrisco_prodt_1 cr_tbrisco_prodt_1%ROWTYPE;
    
    CURSOR cr_tbrisco_prodt_2(pr_idproduto IN tbrisco_provisgarant_prodt.idproduto%TYPE
                             ,pr_dsproduto IN tbrisco_provisgarant_prodt.dsproduto%TYPE) IS
    SELECT *
      FROM tbrisco_provisgarant_prodt
      WHERE idproduto <> pr_idproduto 
        AND dsproduto = pr_dsproduto; 
    rw_tbrisco_prodt_2 cr_tbrisco_prodt_2%ROWTYPE;
    
    CURSOR cr_tbrisco_prodt_3(pr_idproduto IN tbrisco_provisgarant_prodt.idproduto%TYPE) IS
    SELECT *
      FROM tbrisco_provisgarant_prodt
      WHERE idproduto = pr_idproduto; 
    rw_tbrisco_prodt_3 cr_tbrisco_prodt_3%ROWTYPE;
    
    CURSOR cr_tbrisco_prodt_4(pr_cddopcao IN VARCHAR2 
                             ,pr_idproduto IN tbrisco_provisgarant_prodt.idproduto%TYPE
                             ,pr_tparquivo IN tbrisco_provisgarant_prodt.tparquivo%TYPE) IS
    SELECT 1
      FROM tbrisco_provisgarant_prodt
      WHERE (pr_cddopcao = 'I' OR
             tbrisco_provisgarant_prodt.idproduto <> pr_idproduto)
        AND tparquivo = pr_tparquivo; 
    rw_tbrisco_prodt_4 cr_tbrisco_prodt_4%ROWTYPE;
    
    -- Variaveis de locais
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    vr_des_erro VARCHAR2(10);
    vr_idproduto tbrisco_provisgarant_prodt.idproduto%TYPE;
    
    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);
           
    --Variaveis de Excecoes
    vr_exc_erro  EXCEPTION; 
    
  BEGIN 
    
    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'PARRGP'
                              ,pr_action => null); 
                                 
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

    -- Verifica se houve erro recuperando informacoes de log                              
    IF vr_dscritic IS NOT NULL THEN
    
      RAISE vr_exc_erro;
      
    END IF; 
    
    IF pr_cddopcao NOT IN('A','E','I') THEN
      
      -- Montar mensagem de critica
      pr_nmdcampo := 'dsproduto';
      vr_dscritic := 'Opção inválida.';
      RAISE vr_exc_erro;
      
    END IF;
    
    IF pr_cddopcao <> 'I'      AND
       NVL(pr_idproduto,0) = 0 THEN               
      
      -- Montar mensagem de critica
      pr_nmdcampo := 'dsproduto';
      vr_dscritic := 'Código do produto inválido.';
      RAISE vr_exc_erro;
        
    END IF;
      
    IF pr_cddopcao IN ('A','I') THEN
      
      IF TRIM(pr_dsproduto) IS NULL THEN
      
        -- Montar mensagem de critica
        pr_nmdcampo := 'dsproduto';
        vr_dscritic := 'Descrição do produto inválida.';
        RAISE vr_exc_erro;
        
      END IF;
      
      IF NVL(TRIM(UPPER(pr_tpdestino)), ' ') NOT IN ('S','C') THEN 
        
        -- Montar mensagem de critica
        pr_nmdcampo := 'tpdestino';
        vr_dscritic := 'Tipo de destino inválido.';
        RAISE vr_exc_erro;
        
      END IF;
                                
      IF NVL(TRIM(pr_tparquivo), ' ') NOT IN ('Nao','Cartao_Bancoob','Cartao_BB','Cartao_BNDES_BRDE','Inovacred_BRDE','Finame_BRDE') THEN 
        
        -- Montar mensagem de critica
        pr_nmdcampo := 'tparquivo';
        vr_dscritic := 'Tipo de arquivo inválido.';
        RAISE vr_exc_erro;
        
      END IF;
      
      IF NVL(TRIM(pr_tparquivo), ' ') IN ('Cartao_Bancoob','Cartao_BB','Cartao_BNDES_BRDE','Inovacred_BRDE','Finame_BRDE') THEN 
        
        OPEN cr_tbrisco_prodt_4(pr_cddopcao  => pr_cddopcao
                               ,pr_idproduto => pr_idproduto
                               ,pr_tparquivo => pr_tparquivo);
                               
        FETCH cr_tbrisco_prodt_4 INTO rw_tbrisco_prodt_4;
        
        IF cr_tbrisco_prodt_4%FOUND THEN
          
          --Fechar o cursor
          CLOSE cr_tbrisco_prodt_4;
          
          -- Montar mensagem de critica
          pr_nmdcampo := 'tparquivo';
          vr_dscritic := 'Tipo de opção de importação de Arquivo já utilizada por outro Produto! Favor selecionar outra opção.';
          RAISE vr_exc_erro;
          
        ELSE
          
          --Fechar o cursor
          CLOSE cr_tbrisco_prodt_4;
          
        END IF;
        
      END IF;            
                       
      IF NVL(pr_idgarantia,0) = 0                           OR
         RISC0003.fn_valor_opcao_dominio(pr_idgarantia) = 0 THEN
        
        -- Montar mensagem de critica
        pr_nmdcampo := 'idgarantia';
        vr_dscritic := 'Código da garantia inválida.';
        RAISE vr_exc_erro;
        
      END IF;
      
      IF NVL(pr_idmodalidade,0) = 0                           OR
         RISC0003.fn_valor_opcao_dominio(pr_idmodalidade) = 0 THEN
       
        -- Montar mensagem de critica
        pr_nmdcampo := 'idmodalidade';
        vr_dscritic := 'Código da modalidade inválida';
        RAISE vr_exc_erro;
         
      END IF;
      
      IF NVL(pr_idconta_cosif,0) = 0                           OR
         RISC0003.fn_valor_opcao_dominio(pr_idconta_cosif) = 0 THEN
        
        -- Montar mensagem de critica
        pr_nmdcampo := 'idconta_cosif';
        vr_dscritic := 'Conta COSIF inválida.';
        RAISE vr_exc_erro;
        
      END IF;
      
      IF instr(pr_tparquivo,'BRDE') = 0 THEN
        
        IF NVL(pr_idorigem_recurso,0) = 0                           OR
           RISC0003.fn_valor_opcao_dominio(pr_idorigem_recurso) = 0 THEN
          
          -- Montar mensagem de critica
          pr_nmdcampo := 'idorigem_recurso';
          vr_dscritic := 'Código de origem do recurso inválida.';
          RAISE vr_exc_erro;
          
        END IF;
        
        IF NVL(pr_idindexador,0) = 0                           OR
           RISC0003.fn_valor_opcao_dominio(pr_idindexador) = 0 THEN
          
          -- Montar mensagem de critica
          pr_nmdcampo := 'idindexador';
          vr_dscritic := 'Indexador inválido.';
          RAISE vr_exc_erro;
          
        END IF;
        
        IF NVL(pr_idnat_operacao,0) = 0                           OR
           RISC0003.fn_valor_opcao_dominio(pr_idnat_operacao) = 0 THEN
          
          -- Montar mensagem de critica
          pr_nmdcampo := 'idnat_operacao';
          vr_dscritic := 'Natureza de operaçãO inválida.';
          RAISE vr_exc_erro;
          
        END IF;
      
      END IF;
      
      IF NVL(pr_idvariacao_cambial,0) = 0                           OR
         RISC0003.fn_valor_opcao_dominio(pr_idvariacao_cambial) = 0 THEN
        
        -- Montar mensagem de critica
        pr_nmdcampo := 'idvariacao_cambial';
        vr_dscritic := 'Variação cambial inválida.';
        RAISE vr_exc_erro;
         
      END IF;   
      
      IF NVL(TRIM(UPPER(pr_idorigem_cep)), ' ') NOT IN ('S','C') THEN
      
        -- Montar mensagem de critica
        pr_nmdcampo := 'idorigem_cep';
        vr_dscritic := 'Código de origem do CEP inválido.';
        RAISE vr_exc_erro;
          
      END IF;
      
      IF NVL(pr_idcaract_especial,0) <> 0                          AND
         RISC0003.fn_valor_opcao_dominio(pr_idcaract_especial) = 0 THEN
        
        -- Montar mensagem de critica
        pr_nmdcampo := 'idcaract_especial';
        vr_dscritic := 'Código da característica inválida.';
        RAISE vr_exc_erro;
        
      END IF;
      
      IF pr_flpermite_saida_operacao NOT IN(0,1) THEN
        
        -- Montar mensagem de critica
        pr_nmdcampo := 'flpermite_saida_operacao';
        vr_dscritic := 'Saída de operação inválida.';
        RAISE vr_exc_erro;
        
      END IF;
      
      IF pr_flpermite_fluxo_financeiro  NOT IN(0,1) THEN
        
        -- Montar mensagem de critica
        pr_nmdcampo := 'flpermite_fluxo_financeiro';
        vr_dscritic := 'Permite fluxo financeiro não informado.';
        RAISE vr_exc_erro;
        
      END IF;
      
      IF pr_flreaprov_mensal  NOT IN(0,1)  THEN
        
        -- Montar mensagem de critica
        pr_nmdcampo := 'flreaprov_mensal';
        vr_dscritic := 'Permite reaproveitamento mensal não informado.';
        RAISE vr_exc_erro;
        
      END IF;  
      
      IF NVL(TRIM(UPPER(pr_cdclassifica_operacao)), ' ')  NOT IN('AA','RS')  THEN
        
        -- Montar mensagem de critica
        pr_nmdcampo := 'cdclassifica_operacao';
        vr_dscritic := 'Classificação da operação não informada.';
        RAISE vr_exc_erro;
        
      END IF;  
      
    END IF;
    
    IF pr_cddopcao = 'E' THEN
      
      OPEN cr_mvto_1(pr_idproduto => pr_idproduto);
      
      FETCH cr_mvto_1 INTO rw_mvto_1;
      
      IF cr_mvto_1%FOUND THEN
        
        --Fecha o cursor
        CLOSE cr_mvto_1;
        
        -- Montar mensagem de critica
        vr_dscritic := 'Produto não pode ser excluído! Motivo: Já existem movimentos cadastrados para ele.';
        RAISE vr_exc_erro;
      
      ELSE
        
        --Fecha o curosr
        CLOSE cr_mvto_1;
        
      END IF;
      
      OPEN cr_tbrisco_prodt_3(pr_idproduto => pr_idproduto);
                                        
      FETCH cr_tbrisco_prodt_3 INTO rw_tbrisco_prodt_3;
        
      IF cr_tbrisco_prodt_3%NOTFOUND THEN
          
        CLOSE cr_tbrisco_prodt_3;
        
        -- Montar mensagem de critica
        vr_dscritic := 'Produto não encontrado!';
        RAISE vr_exc_erro; 
              
      END IF;
      
      CLOSE cr_tbrisco_prodt_3; 
      
      BEGIN
        
        DELETE FROM tbrisco_provisgarant_prodt t
         WHERE t.idproduto = pr_idproduto;
      
      EXCEPTION
        WHEN OTHERS THEN
          -- Montar mensagem de critica
          vr_dscritic := 'Não foi possível exluir o registro.';
          RAISE vr_exc_erro;
          
      END;
      
      -- Criar cabeçalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="UTF-8"?><avisos/>');
      
      -- Incrementa o contador           
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'avisos', pr_posicao => 0, pr_tag_nova => 'mensagem', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'mensagem', pr_posicao => 0, pr_tag_nova => 'descricao', pr_tag_cont => 'Produto excluído com sucesso!', pr_des_erro => vr_dscritic);
                
      -- Gera log
      btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_nmarqlog     => 'parrgp.log'
                                ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                    ' -->  Operador '|| vr_cdoperad || ' - ' ||
                                                    'Efetuou a exclusao do produto ' || 
                                                    gene0002.fn_mask(pr_idproduto,'z.zzz.zz9') || 
                                                    ' - ' ||  rw_tbrisco_prodt_3.dsproduto || '.');
    
    ELSIF pr_cddopcao = 'A' THEN
      
      OPEN cr_tbrisco_prodt_2(pr_idproduto => pr_idproduto
                             ,pr_dsproduto => upper(pr_dsproduto));
                                        
      FETCH cr_tbrisco_prodt_2 INTO rw_tbrisco_prodt_2;
      
      IF cr_tbrisco_prodt_2%FOUND THEN
        
        CLOSE cr_tbrisco_prodt_2;
        
        -- Montar mensagem de critica
        vr_dscritic := 'Já existe outro produto com este nome, favor revisar o cadastro!';
        pr_nmdcampo := 'dsproduto';
        RAISE vr_exc_erro; 
      
      END IF;
      
      CLOSE cr_tbrisco_prodt_2;
      
      OPEN cr_tbrisco_prodt_3(pr_idproduto => pr_idproduto);
                                        
      FETCH cr_tbrisco_prodt_3 INTO rw_tbrisco_prodt_3;
        
      IF cr_tbrisco_prodt_3%NOTFOUND THEN
          
        CLOSE cr_tbrisco_prodt_3;
        
        -- Montar mensagem de critica
        vr_dscritic := 'Produto não encontrado!';
        RAISE vr_exc_erro; 
              
      END IF;
      
      CLOSE cr_tbrisco_prodt_3; 
      
      BEGIN
        
        UPDATE tbrisco_provisgarant_prodt
           SET tbrisco_provisgarant_prodt.dsproduto = upper(pr_dsproduto)           
              ,tbrisco_provisgarant_prodt.tpdestino = upper(pr_tpdestino)
              ,tbrisco_provisgarant_prodt.tparquivo = pr_tparquivo
              ,tbrisco_provisgarant_prodt.idgarantia = pr_idgarantia
              ,tbrisco_provisgarant_prodt.idmodalidade = pr_idmodalidade
              ,tbrisco_provisgarant_prodt.idconta_cosif = pr_idconta_cosif
              ,tbrisco_provisgarant_prodt.idorigem_recurso = pr_idorigem_recurso
              ,tbrisco_provisgarant_prodt.idindexador = pr_idindexador
              ,tbrisco_provisgarant_prodt.perindexador = pr_perindexador
              ,tbrisco_provisgarant_prodt.idvariacao_cambial = pr_idvariacao_cambial
              ,tbrisco_provisgarant_prodt.idorigem_cep = pr_idorigem_cep
              ,tbrisco_provisgarant_prodt.idnat_operacao = pr_idnat_operacao
              ,tbrisco_provisgarant_prodt.idcaract_especial = pr_idcaract_especial
              ,tbrisco_provisgarant_prodt.flpermite_saida_operacao = pr_flpermite_saida_operacao
              ,tbrisco_provisgarant_prodt.flpermite_fluxo_financeiro = pr_flpermite_fluxo_financeiro
              ,tbrisco_provisgarant_prodt.flreaprov_mensal = pr_flreaprov_mensal
              ,tbrisco_provisgarant_prodt.vltaxa_juros = pr_vltaxa_juros
              ,tbrisco_provisgarant_prodt.cdclassifica_operacao = UPPER(pr_cdclassifica_operacao)
         WHERE tbrisco_provisgarant_prodt.idproduto = pr_idproduto;

      EXCEPTION
        WHEN OTHERS THEN
          -- Montar mensagem de critica
          vr_dscritic := 'Não foi possível atualizar o registro.';
          
          RAISE vr_exc_erro;
          
      END;
            
      OPEN cr_provisgarant_2(pr_idproduto => pr_idproduto);
      
      FETCH cr_provisgarant_2 INTO rw_provisgarant_2;
      
      IF cr_provisgarant_2%FOUND THEN
        
        CLOSE cr_provisgarant_2;
      
        -- Criar cabeçalho do XML
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="UTF-8"?><avisos/>');
    
        -- Incrementa o contador           
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'avisos', pr_posicao => 0, pr_tag_nova => 'mensagem', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'mensagem', pr_posicao => 0, pr_tag_nova => 'descricao', pr_tag_cont => 'Produto atualizado com sucesso! Atenção: Existem movimentos vinculados ao produto nesta data-base, suas informações não serão atualizadas, somente no próximo mês.', pr_des_erro => vr_dscritic);
      
      ELSE
        
        CLOSE cr_provisgarant_2;
        
        -- Criar cabeçalho do XML
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="UTF-8"?><avisos/>');
    
        -- Incrementa o contador           
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'avisos', pr_posicao => 0, pr_tag_nova => 'mensagem', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'mensagem', pr_posicao => 0, pr_tag_nova => 'descricao', pr_tag_cont => 'Produto atualizado com sucesso!', pr_des_erro => vr_dscritic);
      
      END IF;
      
      pc_gera_log(pr_cdcooper => vr_cdcooper -- Código da cooperativa
                 ,pr_idproduto => pr_idproduto --Código do produto
                 ,pr_cdoperad => vr_cdoperad -- Operador
                 ,pr_dsdcampo => 'Descricao'  --Descrição do campo
                 ,pr_vlrcampo => rw_tbrisco_prodt_3.dsproduto   --Valor antigo
                 ,pr_vlcampo2 => pr_dsproduto  --Valor atual
                 ,pr_des_erro => vr_des_erro); --Erro

      IF vr_des_erro <> 'OK' THEN

        -- Montar mensagem de critica
        vr_cdcritic := 0;
        vr_dscritic := 'Erro ao registar no log.';
        -- volta para o programa chamador
        RAISE vr_exc_erro;

      END IF;
      
      pc_gera_log(pr_cdcooper => vr_cdcooper -- Código da cooperativa
                 ,pr_idproduto => pr_idproduto --Código do produto
                 ,pr_cdoperad => vr_cdoperad -- Operador
                 ,pr_dsdcampo => 'Tp. Destino'  --Descrição do campo
                 ,pr_vlrcampo => (CASE 
                                   WHEN rw_tbrisco_prodt_3.tpdestino = 'S' THEN 'Singular' 
                                   WHEN rw_tbrisco_prodt_3.tpdestino = 'C' THEN 'Central' 
                                   WHEN rw_tbrisco_prodt_3.tpdestino = 'A' THEN 'Ambas' 
                                 END)    
                 ,pr_vlcampo2 => (CASE 
                                   WHEN pr_tpdestino = 'S' THEN 'Singular' 
                                   WHEN pr_tpdestino = 'C' THEN 'Central' 
                                   ELSE 'Ambas' 
                                 END)   
                 ,pr_des_erro => vr_des_erro); --Erro

      IF vr_des_erro <> 'OK' THEN

        -- Montar mensagem de critica
        vr_cdcritic := 0;
        vr_dscritic := 'Erro ao registar no log.';
        -- volta para o programa chamador
        RAISE vr_exc_erro;

      END IF;
      
      pc_gera_log(pr_cdcooper => vr_cdcooper -- Código da cooperativa
                 ,pr_idproduto => pr_idproduto --Código do produto
                 ,pr_cdoperad => vr_cdoperad -- Operador
                 ,pr_dsdcampo => 'Tp. Arquivo'  --Descrição do campo
                 ,pr_vlrcampo => (CASE 
                                   WHEN rw_tbrisco_prodt_3.tparquivo = 'Nao' THEN 'Nao' 
                                   WHEN rw_tbrisco_prodt_3.tparquivo = 'Cartao_Bancoob' THEN 'Singular' 
                                   WHEN rw_tbrisco_prodt_3.tparquivo = 'Cartao_BB' THEN 'Ambos' 
                                   WHEN rw_tbrisco_prodt_3.tparquivo = 'Cartao_BNDES_BRDE' THEN 'Cartao BNDES BRDE' 
                                   WHEN rw_tbrisco_prodt_3.tparquivo = 'Inovacred_BRDE' THEN 'Inovacred BRDE' 
                                   WHEN rw_tbrisco_prodt_3.tparquivo = 'Finame_BRDE' THEN 'Finame BRDE' 
                                 END)     --Valor antigo
                 ,pr_vlcampo2 => (CASE 
                                   WHEN pr_tparquivo = 'Nao' THEN 'Nao' 
                                   WHEN pr_tparquivo = 'Cartao_Bancoob' THEN 'Singular' 
                                   WHEN pr_tparquivo = 'Cartao_BB' THEN 'Ambos' 
                                   WHEN pr_tparquivo = 'Cartao_BNDES_BRDE' THEN 'Cartao BNDES BRDE' 
                                   WHEN pr_tparquivo = 'Inovacred_BRDE' THEN 'Inovacred BRDE' 
                                   WHEN pr_tparquivo = 'Finame_BRDE' THEN 'Finame BRDE' 
                                 END)    --Valor atual
                 ,pr_des_erro => vr_des_erro); --Erro

      IF vr_des_erro <> 'OK' THEN

        -- Montar mensagem de critica
        vr_cdcritic := 0;
        vr_dscritic := 'Erro ao registar no log.';
        -- volta para o programa chamador
        RAISE vr_exc_erro;

      END IF;
      
      pc_gera_log(pr_cdcooper => vr_cdcooper -- Código da cooperativa
                 ,pr_idproduto => pr_idproduto --Código do produto
                 ,pr_cdoperad => vr_cdoperad -- Operador
                 ,pr_dsdcampo => 'Garantia'  --Descrição do campo
                 ,pr_vlrcampo => RISC0003.fn_valor_opcao_dominio(rw_tbrisco_prodt_3.idgarantia )  --Valor antigo
                 ,pr_vlcampo2 => RISC0003.fn_valor_opcao_dominio(pr_idgarantia )  --Valor atual
                 ,pr_des_erro => vr_des_erro); --Erro

      IF vr_des_erro <> 'OK' THEN

        -- Montar mensagem de critica
        vr_cdcritic := 0;
        vr_dscritic := 'Erro ao registar no log.';
        -- volta para o programa chamador
        RAISE vr_exc_erro;

      END IF;
      
      pc_gera_log(pr_cdcooper => vr_cdcooper -- Código da cooperativa
                 ,pr_idproduto => pr_idproduto --Código do produto
                 ,pr_cdoperad => vr_cdoperad -- Operador
                 ,pr_dsdcampo => 'Modalidade'  --Descrição do campo
                 ,pr_vlrcampo => RISC0003.fn_valor_opcao_dominio(rw_tbrisco_prodt_3.idmodalidade)   --Valor antigo
                 ,pr_vlcampo2 => RISC0003.fn_valor_opcao_dominio(pr_idmodalidade)  --Valor atual
                 ,pr_des_erro => vr_des_erro); --Erro

      IF vr_des_erro <> 'OK' THEN

        -- Montar mensagem de critica
        vr_cdcritic := 0;
        vr_dscritic := 'Erro ao registar no log.';
        -- volta para o programa chamador
        RAISE vr_exc_erro;

      END IF;
      
      pc_gera_log(pr_cdcooper => vr_cdcooper -- Código da cooperativa
                 ,pr_idproduto => pr_idproduto --Código do produto
                 ,pr_cdoperad => vr_cdoperad -- Operador
                 ,pr_dsdcampo => 'Conta COSIF'  --Descrição do campo
                 ,pr_vlrcampo => RISC0003.fn_valor_opcao_dominio(rw_tbrisco_prodt_3.idconta_cosif)   --Valor antigo
                 ,pr_vlcampo2 => RISC0003.fn_valor_opcao_dominio(pr_idconta_cosif)  --Valor atual
                 ,pr_des_erro => vr_des_erro); --Erro

      IF vr_des_erro <> 'OK' THEN

        -- Montar mensagem de critica
        vr_cdcritic := 0;
        vr_dscritic := 'Erro ao registar no log.';
        -- volta para o programa chamador
        RAISE vr_exc_erro;

      END IF;
      
      pc_gera_log(pr_cdcooper => vr_cdcooper -- Código da cooperativa
                 ,pr_idproduto => pr_idproduto --Código do produto
                 ,pr_cdoperad => vr_cdoperad -- Operador
                 ,pr_dsdcampo => 'Origem Recurso'  --Descrição do campo
                 ,pr_vlrcampo => RISC0003.fn_valor_opcao_dominio(rw_tbrisco_prodt_3.idorigem_recurso)   --Valor antigo
                 ,pr_vlcampo2 => RISC0003.fn_valor_opcao_dominio(pr_idorigem_recurso)  --Valor atual
                 ,pr_des_erro => vr_des_erro); --Erro

      IF vr_des_erro <> 'OK' THEN

        -- Montar mensagem de critica
        vr_cdcritic := 0;
        vr_dscritic := 'Erro ao registar no log.';
        -- volta para o programa chamador
        RAISE vr_exc_erro;

      END IF;
      
      pc_gera_log(pr_cdcooper => vr_cdcooper -- Código da cooperativa
                 ,pr_idproduto => pr_idproduto --Código do produto
                 ,pr_cdoperad => vr_cdoperad -- Operador
                 ,pr_dsdcampo => 'Indexador'  --Descrição do campo
                 ,pr_vlrcampo => RISC0003.fn_valor_opcao_dominio(rw_tbrisco_prodt_3.idindexador)  --Valor antigo
                 ,pr_vlcampo2 => RISC0003.fn_valor_opcao_dominio(pr_idindexador)  --Valor atual
                 ,pr_des_erro => vr_des_erro); --Erro

      IF vr_des_erro <> 'OK' THEN

        -- Montar mensagem de critica
        vr_cdcritic := 0;
        vr_dscritic := 'Erro ao registar no log.';
        -- volta para o programa chamador
        RAISE vr_exc_erro;

      END IF;
      
      pc_gera_log(pr_cdcooper => vr_cdcooper -- Código da cooperativa
                 ,pr_idproduto => pr_idproduto --Código do produto
                 ,pr_cdoperad => vr_cdoperad -- Operador
                 ,pr_dsdcampo => 'Perc. Indexador'  --Descrição do campo
                 ,pr_vlrcampo => to_char(rw_tbrisco_prodt_3.perindexador,'990D0000000','NLS_NUMERIC_CHARACTERS='',.''') --Valor antigo 
                 ,pr_vlcampo2 => to_char(pr_perindexador,'990D0000000','NLS_NUMERIC_CHARACTERS='',.''')  --Valor atual
                 ,pr_des_erro => vr_des_erro); --Erro

      IF vr_des_erro <> 'OK' THEN

        -- Montar mensagem de critica
        vr_cdcritic := 0;
        vr_dscritic := 'Erro ao registar no log.';
        -- volta para o programa chamador
        RAISE vr_exc_erro;

      END IF;
      
      pc_gera_log(pr_cdcooper => vr_cdcooper -- Código da cooperativa
                 ,pr_idproduto => pr_idproduto --Código do produto
                 ,pr_cdoperad => vr_cdoperad -- Operador
                 ,pr_dsdcampo => 'Valor taxa de juros'  --Descrição do campo
                 ,pr_vlrcampo => to_char(rw_tbrisco_prodt_3.vltaxa_juros,'990D0000000','NLS_NUMERIC_CHARACTERS='',.''') --Valor antigo
                 ,pr_vlcampo2 => to_char(pr_vltaxa_juros,'990D0000000','NLS_NUMERIC_CHARACTERS='',.''') --Valor atual
                 ,pr_des_erro => vr_des_erro); --Erro

      IF vr_des_erro <> 'OK' THEN

        -- Montar mensagem de critica
        vr_cdcritic := 0;
        vr_dscritic := 'Erro ao registar no log.';
        -- volta para o programa chamador
        RAISE vr_exc_erro;

      END IF;
      
      pc_gera_log(pr_cdcooper => vr_cdcooper -- Código da cooperativa
                 ,pr_idproduto => pr_idproduto --Código do produto
                 ,pr_cdoperad => vr_cdoperad -- Operador
                 ,pr_dsdcampo => 'Classificacao da operacao'  --Descrição do campo
                 ,pr_vlrcampo => (CASE 
                                   WHEN rw_tbrisco_prodt_3.cdclassifica_operacao = 'AA' THEN 'AA' 
                                   WHEN rw_tbrisco_prodt_3.cdclassifica_operacao = 'RS' THEN 'Singular'
                                 END)   --Valor antigo
                 ,pr_vlcampo2 => (CASE 
                                   WHEN pr_cdclassifica_operacao = 'AA' THEN 'AA' 
                                   WHEN pr_cdclassifica_operacao = 'RS' THEN 'Singular'
                                 END)    --Valor atual
                 ,pr_des_erro => vr_des_erro); --Erro

      IF vr_des_erro <> 'OK' THEN

        -- Montar mensagem de critica
        vr_cdcritic := 0;
        vr_dscritic := 'Erro ao registar no log.';
        -- volta para o programa chamador
        RAISE vr_exc_erro;

      END IF;      
      
      pc_gera_log(pr_cdcooper => vr_cdcooper -- Código da cooperativa
                 ,pr_idproduto => pr_idproduto --Código do produto
                 ,pr_cdoperad => vr_cdoperad -- Operador
                 ,pr_dsdcampo => 'Var. Cambial'  --Descrição do campo
                 ,pr_vlrcampo => RISC0003.fn_valor_opcao_dominio(rw_tbrisco_prodt_3.idvariacao_cambial)   --Valor antigo
                 ,pr_vlcampo2 => RISC0003.fn_valor_opcao_dominio(pr_idvariacao_cambial)  --Valor atual
                 ,pr_des_erro => vr_des_erro); --Erro

      IF vr_des_erro <> 'OK' THEN

        -- Montar mensagem de critica
        vr_cdcritic := 0;
        vr_dscritic := 'Erro ao registar no log.';
        -- volta para o programa chamador
        RAISE vr_exc_erro;

      END IF;
      
      pc_gera_log(pr_cdcooper => vr_cdcooper -- Código da cooperativa
                 ,pr_idproduto => pr_idproduto --Código do produto
                 ,pr_cdoperad => vr_cdoperad -- Operador
                 ,pr_dsdcampo => 'Origem CEP'  --Descrição do campo
                 ,pr_vlrcampo => (CASE 
                                   WHEN rw_tbrisco_prodt_3.idorigem_cep = 'C' THEN 'Central' 
                                   WHEN rw_tbrisco_prodt_3.idorigem_cep = 'S' THEN 'Singular'
                                 END)   --Valor antigo
                 ,pr_vlcampo2 => (CASE 
                                   WHEN pr_idorigem_cep = 'C' THEN 'Central' 
                                   WHEN pr_idorigem_cep = 'S' THEN 'Singular'
                                 END)    --Valor atual
                 ,pr_des_erro => vr_des_erro); --Erro

      IF vr_des_erro <> 'OK' THEN

        -- Montar mensagem de critica
        vr_cdcritic := 0;
        vr_dscritic := 'Erro ao registar no log.';
        -- volta para o programa chamador
        RAISE vr_exc_erro;

      END IF;
      
      pc_gera_log(pr_cdcooper => vr_cdcooper -- Código da cooperativa
                 ,pr_idproduto => pr_idproduto --Código do produto
                 ,pr_cdoperad => vr_cdoperad -- Operador
                 ,pr_dsdcampo => 'Nat. Ocupacao'  --Descrição do campo
                 ,pr_vlrcampo => RISC0003.fn_valor_opcao_dominio(rw_tbrisco_prodt_3.idnat_operacao)   --Valor antigo
                 ,pr_vlcampo2 => RISC0003.fn_valor_opcao_dominio(pr_idnat_operacao)  --Valor atual
                 ,pr_des_erro => vr_des_erro); --Erro

      IF vr_des_erro <> 'OK' THEN

        -- Montar mensagem de critica
        vr_cdcritic := 0;
        vr_dscritic := 'Erro ao registar no log.';
        -- volta para o programa chamador
        RAISE vr_exc_erro;

      END IF;
      
      pc_gera_log(pr_cdcooper => vr_cdcooper -- Código da cooperativa
                 ,pr_idproduto => pr_idproduto --Código do produto
                 ,pr_cdoperad => vr_cdoperad -- Operador
                 ,pr_dsdcampo => 'Caract. Especial'  --Descrição do campo
                 ,pr_vlrcampo => RISC0003.fn_valor_opcao_dominio(rw_tbrisco_prodt_3.idcaract_especial)   --Valor antigo
                 ,pr_vlcampo2 => RISC0003.fn_valor_opcao_dominio(pr_idcaract_especial)  --Valor atual
                 ,pr_des_erro => vr_des_erro); --Erro

      IF vr_des_erro <> 'OK' THEN

        -- Montar mensagem de critica
        vr_cdcritic := 0;
        vr_dscritic := 'Erro ao registar no log.';
        -- volta para o programa chamador
        RAISE vr_exc_erro;

      END IF;
      
      pc_gera_log(pr_cdcooper => vr_cdcooper -- Código da cooperativa
                 ,pr_idproduto => pr_idproduto --Código do produto
                 ,pr_cdoperad => vr_cdoperad -- Operador
                 ,pr_dsdcampo => 'Saida de operacao'  --Descrição do campo
                 ,pr_vlrcampo => (CASE WHEN rw_tbrisco_prodt_3.flpermite_saida_operacao = 0 THEN 'Nao' ELSE 'Sim' END)   --Valor antigo
                 ,pr_vlcampo2 => (CASE WHEN pr_flpermite_saida_operacao = 0 THEN 'Nao' ELSE 'Sim' END)  --Valor atual
                 ,pr_des_erro => vr_des_erro); --Erro

      IF vr_des_erro <> 'OK' THEN

        -- Montar mensagem de critica
        vr_cdcritic := 0;
        vr_dscritic := 'Erro ao registar no log.';
        -- volta para o programa chamador
        RAISE vr_exc_erro;

      END IF;
      
      pc_gera_log(pr_cdcooper => vr_cdcooper -- Código da cooperativa
                 ,pr_idproduto => pr_idproduto --Código do produto
                 ,pr_cdoperad => vr_cdoperad -- Operador
                 ,pr_dsdcampo => 'Fluxo financeiro'  --Descrição do campo
                 ,pr_vlrcampo => (CASE WHEN rw_tbrisco_prodt_3.flpermite_fluxo_financeiro = 0 THEN 'Nao' ELSE 'Sim' END)   --Valor antigo
                 ,pr_vlcampo2 => (CASE WHEN pr_flpermite_fluxo_financeiro = 0 THEN 'Nao' ELSE 'Sim' END)  --Valor atual
                 ,pr_des_erro => vr_des_erro); --Erro

      IF vr_des_erro <> 'OK' THEN

        -- Montar mensagem de critica
        vr_cdcritic := 0;
        vr_dscritic := 'Erro ao registar no log.';
        -- volta para o programa chamador
        RAISE vr_exc_erro;

      END IF;
      
      pc_gera_log(pr_cdcooper => vr_cdcooper -- Código da cooperativa
                 ,pr_idproduto => pr_idproduto --Código do produto
                 ,pr_cdoperad => vr_cdoperad -- Operador
                 ,pr_dsdcampo => 'Reaprova mensal'  --Descrição do campo
                 ,pr_vlrcampo => (CASE WHEN rw_tbrisco_prodt_3.flreaprov_mensal = 0 THEN 'Nao' ELSE 'Sim' END) --Valor antigo
                 ,pr_vlcampo2 => (CASE WHEN pr_flreaprov_mensal = 0 THEN 'Nao' ELSE 'Sim' END)  --Valor atual
                 ,pr_des_erro => vr_des_erro); --Erro

      IF vr_des_erro <> 'OK' THEN

        -- Montar mensagem de critica
        vr_cdcritic := 0;
        vr_dscritic := 'Erro ao registar no log.';
        -- volta para o programa chamador
        RAISE vr_exc_erro;

      END IF;
      
    ELSIF pr_cddopcao = 'I' THEN
      
      OPEN cr_tbrisco_prodt_1(pr_dsproduto => upper(pr_dsproduto));
                                        
      FETCH cr_tbrisco_prodt_1 INTO rw_tbrisco_prodt_1;
        
      IF cr_tbrisco_prodt_1%FOUND THEN
          
        CLOSE cr_tbrisco_prodt_1;
        
        -- Montar mensagem de critica
        vr_dscritic := 'Já existe outro produto com este nome, favor revisar o cadastro!';
        pr_nmdcampo := 'dsproduto';
        RAISE vr_exc_erro; 
        
      END IF;
      
      CLOSE cr_tbrisco_prodt_1; 
      
      BEGIN
        
        INSERT INTO tbrisco_provisgarant_prodt(tbrisco_provisgarant_prodt.dsproduto
                                              ,tbrisco_provisgarant_prodt.tpdestino
                                              ,tbrisco_provisgarant_prodt.tparquivo
                                              ,tbrisco_provisgarant_prodt.idgarantia
                                              ,tbrisco_provisgarant_prodt.idmodalidade
                                              ,tbrisco_provisgarant_prodt.idconta_cosif
                                              ,tbrisco_provisgarant_prodt.idorigem_recurso
                                              ,tbrisco_provisgarant_prodt.idindexador
                                              ,tbrisco_provisgarant_prodt.perindexador
                                              ,tbrisco_provisgarant_prodt.idvariacao_cambial
                                              ,tbrisco_provisgarant_prodt.idorigem_cep
                                              ,tbrisco_provisgarant_prodt.idnat_operacao
                                              ,tbrisco_provisgarant_prodt.idcaract_especial
                                              ,tbrisco_provisgarant_prodt.flpermite_saida_operacao
                                              ,tbrisco_provisgarant_prodt.flpermite_fluxo_financeiro
                                              ,tbrisco_provisgarant_prodt.flreaprov_mensal
                                              ,tbrisco_provisgarant_prodt.vltaxa_juros
                                              ,tbrisco_provisgarant_prodt.cdclassifica_operacao)
                                       VALUES(UPPER(pr_dsproduto)
                                              ,upper(pr_tpdestino)
                                              ,pr_tparquivo
                                              ,pr_idgarantia
                                              ,pr_idmodalidade
                                              ,pr_idconta_cosif
                                              ,pr_idorigem_recurso
                                              ,pr_idindexador
                                              ,pr_perindexador
                                              ,pr_idvariacao_cambial
                                              ,pr_idorigem_cep
                                              ,pr_idnat_operacao
                                              ,pr_idcaract_especial
                                              ,pr_flpermite_saida_operacao
                                              ,pr_flpermite_fluxo_financeiro
                                              ,pr_flreaprov_mensal
                                              ,pr_vltaxa_juros
                                              ,upper(pr_cdclassifica_operacao))
                                         RETURNING tbrisco_provisgarant_prodt.idproduto INTO vr_idproduto;
         
      EXCEPTION
        WHEN OTHERS THEN
          -- Montar mensagem de critica
          vr_dscritic := 'Não foi possível incluir o produto.';
          RAISE vr_exc_erro;
          
      END;
      
      -- Criar cabeçalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="UTF-8"?><avisos/>');
    
      -- Incrementa o contador           
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'avisos', pr_posicao => 0, pr_tag_nova => 'mensagem', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'mensagem', pr_posicao => 0, pr_tag_nova => 'descricao', pr_tag_cont => 'Produto cadastrado com sucesso!', pr_des_erro => vr_dscritic);
      
      
      -- Gera log
      btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_nmarqlog     => 'parrgp.log'
                                ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                    ' -->  Operador '|| vr_cdoperad || ' - ' ||
                                                    'Efetuou a inclusao do produto: ' || 
                                                    'Codigo: ' || gene0002.fn_mask(vr_idproduto,'z.zzz.zz9') ||
                                                    ', Descricao: ' || pr_dsproduto ||
                                                    ', Tp. Destino: ' || (CASE 
                                                                           WHEN pr_tpdestino = 'S' THEN 'Singular' 
                                                                           WHEN pr_tpdestino = 'C' THEN 'Central' 
                                                                           ELSE 'Ambas' 
                                                                         END) ||
                                                    ', Tp. Arquivo: ' || (CASE 
                                                                           WHEN pr_tparquivo = 'Nao' THEN 'Nao' 
                                                                           WHEN pr_tparquivo = 'Cartao_Bancoob' THEN 'Singular' 
                                                                           WHEN pr_tparquivo = 'Cartao_BB' THEN 'Ambos' 
                                                                           WHEN pr_tparquivo = 'Cartao_BNDES_BRDE' THEN 'Cartao BNDES BRDE' 
                                                                           WHEN pr_tparquivo = 'Inovacred_BRDE' THEN 'Inovacred BRDE' 
                                                                           WHEN pr_tparquivo = 'Finame_BRDE' THEN 'Finame BRDE' 
                                                                         END) ||
                                                    ', Garantia: '   || RISC0003.fn_valor_opcao_dominio(pr_idgarantia) ||
                                                    ', Modalidade: ' || RISC0003.fn_valor_opcao_dominio(pr_idmodalidade) ||
                                                    ', Conta COSIF: ' || RISC0003.fn_valor_opcao_dominio(pr_idconta_cosif) ||
                                                    ', Origem Recurso: ' || RISC0003.fn_valor_opcao_dominio(pr_idorigem_recurso) ||
                                                    ', Indexador: ' || RISC0003.fn_valor_opcao_dominio(pr_idindexador) ||
                                                    ', Perc. Indexador: ' || to_char(pr_perindexador,'990D0000000','NLS_NUMERIC_CHARACTERS='',.''') ||
                                                    ', Valor taxa de juros: ' || to_char(pr_vltaxa_juros,'990D0000000','NLS_NUMERIC_CHARACTERS='',.''') ||
                                                    ', Classificacao da operacao: ' ||(CASE
                                                                                         WHEN pr_cdclassifica_operacao = 'AA' THEN 'AA'
                                                                                         WHEN pr_cdclassifica_operacao = 'RS' THEN 'Singular' 
                                                                                       END) ||                                                   
                                                    ', Var. Cambial: ' || RISC0003.fn_valor_opcao_dominio(pr_idvariacao_cambial) ||
                                                    ', Origem CEP: ' || (CASE 
                                                                           WHEN pr_idorigem_cep = 'C' THEN 'Central' 
                                                                           WHEN pr_idorigem_cep = 'S' THEN 'Singular'
                                                                         END) ||
                                                    ', Nat. Ocupacao: ' || RISC0003.fn_valor_opcao_dominio(pr_idnat_operacao) ||
                                                    ', Caract. Especial: ' || RISC0003.fn_valor_opcao_dominio(pr_idcaract_especial) ||
                                                    ', Saida de operacao: ' || (CASE WHEN pr_flpermite_saida_operacao = 0 THEN 'Nao' ELSE 'Sim' END) ||
                                                    ', Fluxo financeiro: ' || (CASE WHEN pr_flpermite_fluxo_financeiro = 0 THEN 'Nao' ELSE 'Sim' END) ||
                                                    ', Reaprova mensal: ' || (CASE WHEN pr_flreaprov_mensal = 0 THEN 'Nao' ELSE 'Sim' END) 
                                                     || '.');
                                                    
    END IF;
    
    pr_des_erro := 'OK';  
  
    COMMIT;
    
  EXCEPTION
    WHEN vr_exc_erro THEN 
                     
      -- Erro
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      pr_des_erro := 'NOK'; 
                
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');    
          
      ROLLBACK;
                                                                                                  
    WHEN OTHERS THEN 
        
      -- Erro
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na pc_manter_rotina --> '|| SQLERRM;
      pr_nmdcampo := 'dsproduto';
      pr_des_erro:= 'NOK';
          
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');     
    
      ROLLBACK;
       
  END pc_manter_rotina;
 
END TELA_PARRGP;
/
