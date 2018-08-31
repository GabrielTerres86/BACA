create or replace package cecred.TELA_LISLOT is

  /*Programa: visualização de detalhes da contab. do prejuízo na Lislot
    Sistema : contab. do prejuízo na Lislot
    Sigla   : CRED
    Autor   : Fabio Adriano
    Data    : Agosto/2018                       Ultima atualizacao: */
  
  PROCEDURE pc_lista_det_prej_lislot(pr_cdcooper IN crapcop.cdcooper%TYPE --> Código da cooperativa
                                    ,pr_nrdconta IN crapass.nrdconta%TYPE --> Numero da conta
                                    ,pr_cdhistor IN craphis.cdhistor%TYPE --> Código do histórico
                                    ,pr_xmllog   IN VARCHAR2              --> XML com informacoes de LOG
                                    ,pr_cdcritic OUT PLS_INTEGER          --> Codigo da critica
                                    ,pr_dscritic OUT VARCHAR2             --> Descricao da critica
                                    ,pr_retxml   IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                                    ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                    ,pr_des_erro OUT VARCHAR2);
end TELA_LISLOT;
/
create or replace package body cecred.TELA_LISLOT is

  /*..............................................................................

     Sistema : contab. do prejuízo na Lislot
     Sigla   : CRED
     Autor   : Fabio Adriano
     Data    : Agosto/2018                       Ultima atualizacao: 

     Frequencia: Sempre que for chamado

     Alteracoes: */
     

/*Procedure para visualização de detalhes da contab. do prejuízo na Lislot*/
PROCEDURE pc_lista_det_prej_lislot(pr_cdcooper IN crapcop.cdcooper%TYPE --> Código da cooperativa
                                  ,pr_nrdconta IN crapass.nrdconta%TYPE --> Numero da conta
                                  ,pr_cdhistor IN craphis.cdhistor%TYPE --> Código do histórico
                                  ,pr_xmllog   IN VARCHAR2              --> XML com informacoes de LOG
                                  ,pr_cdcritic OUT PLS_INTEGER          --> Codigo da critica
                                  ,pr_dscritic OUT VARCHAR2             --> Descricao da critica
                                  ,pr_retxml   IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                                  ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                  ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
BEGIN
/* .............................................................................

  Programa: pc_lista_det_prej_lislot
  Sistema : Ayllos Web
  Autor   : Fabio Adriano
  Data    : 30/08/2018                 Ultima atualizacao:

  Frequencia: Sempre que for chamado

  Objetivo  : Rotina para visualização de detalhes da contab. do prejuízo na Lislot.

  Alteracoes: -----
  ..............................................................................*/
  
  DECLARE

    ----------->>> VARIAVEIS <<<--------
    
    -- Variavel de criticas
    vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic VARCHAR2(10000);       --> Desc. Erro
   
    -- Tratamento de erros
    vr_exc_erro EXCEPTION;

    -- Variáveis gerais da procedure
    vr_contador INTEGER := 0; -- Contador para inserção dos dados no XML
    
    -- Variáveis retornadas da gene0004.pc_extrai_dados
    /*vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);*/
    
    ----------->>> CURSORES <<<--------
    
    --busca detalhes da contab. do prejuízo na Lislot
    CURSOR cr_det_prej_lislot(pr_cdcooper IN crapcop.cdcooper%TYPE --> Código da cooperativa
                             ,pr_nrdconta IN crapass.nrdconta%TYPE --> Numero da conta
                             ,pr_cdhistor IN craphis.cdhistor%TYPE --> Código do histórico
                              ) IS
    SELECT v.idlancto   ,
           v.dtmvtolt   ,
           v.nrdconta   ,
           v.cdhistor   ,
           v.vllanmto   ,
           v.dthrtran   ,
           v.cdoperad   ,
           v.cdcooper   ,
           v.idprejuizo  
    FROM TBCC_PREJUIZO_DETALHE v             
     WHERE v.cdcooper = pr_cdcooper
      and  v.nrdconta = pr_nrdconta
      and  v.cdhistor = pr_cdhistor
    ORDER BY v.dtmvtolt desc;       
    rw_det_prej_lislot cr_det_prej_lislot%ROWTYPE;
    
        
  BEGIN

    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao  => 0, pr_tag_nova => 'historicos', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);

    FOR rw_det_prej_lislot 
      IN cr_det_prej_lislot(pr_cdcooper, pr_nrdconta, pr_cdhistor) LOOP
                                                    
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'historicos', pr_posicao  => 0, pr_tag_nova => 'historico', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'historico', pr_posicao  => vr_contador, pr_tag_nova => 'idlancto', pr_tag_cont => rw_det_prej_lislot.idlancto, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'historico', pr_posicao  => vr_contador, pr_tag_nova => 'dtmvtolt', pr_tag_cont => rw_det_prej_lislot.dtmvtolt, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'historico', pr_posicao  => vr_contador, pr_tag_nova => 'nrdconta', pr_tag_cont => rw_det_prej_lislot.nrdconta, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'historico', pr_posicao  => vr_contador, pr_tag_nova => 'cdhistor', pr_tag_cont => rw_det_prej_lislot.cdhistor, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'historico', pr_posicao  => vr_contador, pr_tag_nova => 'vllanmto', pr_tag_cont => rw_det_prej_lislot.vllanmto, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'historico', pr_posicao  => vr_contador, pr_tag_nova => 'dthrtran', pr_tag_cont => rw_det_prej_lislot.dthrtran, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'historico', pr_posicao  => vr_contador, pr_tag_nova => 'cdcooper', pr_tag_cont => rw_det_prej_lislot.cdcooper, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'historico', pr_posicao  => vr_contador, pr_tag_nova => 'idprejuizo', pr_tag_cont => rw_det_prej_lislot.idprejuizo, pr_des_erro => vr_dscritic);
        
        vr_contador := vr_contador + 1;
      
    END LOOP;

  EXCEPTION
    WHEN vr_exc_erro THEN
      IF vr_cdcritic <> 0 THEN
        vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      END IF;

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;

      -- Carregar XML padrao para variavel de retorno
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

    WHEN OTHERS THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina da tela TELA_LISLOT(pc_lista_det_prej_lislot): ' || SQLERRM;

      -- Carregar XML padrao para variavel de retorno
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
  END;
  
END pc_lista_det_prej_lislot;
  
end TELA_LISLOT;
/
