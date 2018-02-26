CREATE OR REPLACE PACKAGE CECRED.TELA_PARCDC AS
  
  -- Rotina para manter Parâmetros CDC
  PROCEDURE pc_manter_parametros(pr_cddopcao IN VARCHAR2                                          --> Código da Opção
                                ,pr_cdcooper_param   IN tbepr_cdc_parametro.cdcooper%TYPE         --> Código da Cooperativa
                                ,pr_inintegra_cont   IN tbepr_cdc_parametro.inintegra_cont%TYPE   --> Flag de Integração de Contingência
                                ,pr_nrprop_env       IN tbepr_cdc_parametro.nrprop_env%TYPE       --> Limite máximo de propostas
                                ,pr_intempo_prop_env IN tbepr_cdc_parametro.intempo_prop_env%TYPE --> Intervalo de tempo de propostas
                                ,pr_xmllog   IN VARCHAR2                                          --> XML com informações de LOG
                                ,pr_cdcritic OUT PLS_INTEGER                                      --> Código da crítica
                                ,pr_dscritic OUT VARCHAR2                                         --> Descrição da crítica
                                ,pr_retxml   IN OUT NOCOPY xmltype                                --> Arquivo de retorno do XML
                                ,pr_nmdcampo OUT VARCHAR2                                         --> Nome do Campo
                                ,pr_des_erro OUT VARCHAR2);                                       --> Saida OK/NOK

  -- Rotina para manter Segmentos CDC
  PROCEDURE pc_manter_segmentos(pr_cddopcao IN VARCHAR2                             --> Código da Opção
	                             ,pr_tpproduto IN tbepr_cdc_segmento.tpproduto%TYPE   --> Tipo de produto		
                               ,pr_cdsegmento IN tbepr_cdc_segmento.cdsegmento%TYPE --> Código do Segmento
                               ,pr_dssegmento IN tbepr_cdc_segmento.dssegmento%TYPE --> Descrição do Segmento
                               ,pr_xmllog   IN VARCHAR2                             --> XML com informações de LOG
                               ,pr_cdcritic OUT PLS_INTEGER                         --> Código da crítica
                               ,pr_dscritic OUT VARCHAR2                            --> Descrição da crítica
                               ,pr_retxml   IN OUT NOCOPY xmltype                   --> Arquivo de retorno do XML
                               ,pr_nmdcampo OUT VARCHAR2                            --> Nome do Campo
                               ,pr_des_erro OUT VARCHAR2);                          --> Saida OK/NOK

  -- Rotina para manter Subsegmentos CDC
  PROCEDURE pc_manter_subsegmentos(pr_cddopcao       IN VARCHAR2                                 --> Código da Opção
                                  ,pr_cdsegmento     IN tbepr_cdc_subsegmento.cdsegmento%TYPE    --> Código do Segmento
                                  ,pr_cdsubsegmento  IN tbepr_cdc_subsegmento.cdsegmento%TYPE    --> Código do Subsegmento
                                  ,pr_dssubsegmento  IN tbepr_cdc_subsegmento.dssubsegmento%TYPE --> Descrição do Subsegmento
                                  ,pr_nrmax_parcela  IN tbepr_cdc_subsegmento.nrmax_parcela%TYPE --> Número máximo de parcelas
                                  ,pr_vlmax_financ   IN tbepr_cdc_subsegmento.vlmax_financ%TYPE  --> Valor máximo de financiamento
                                  ,pr_xmllog         IN VARCHAR2                                 --> XML com informações de LOG
                                  ,pr_cdcritic      OUT PLS_INTEGER                              --> Código da crítica
                                  ,pr_dscritic      OUT VARCHAR2                                 --> Descrição da crítica
                                  ,pr_retxml        IN OUT NOCOPY xmltype                        --> Arquivo de retorno do XML
                                  ,pr_nmdcampo      OUT VARCHAR2                                 --> Nome do Campo
                                  ,pr_des_erro      OUT VARCHAR2);                               --> Saida OK/NOK
    
END TELA_PARCDC;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_PARCDC AS
  ---------------------------------------------------------------------------------------------------------------
  --
  --    Programa: TELA_PARCDC
  --    Autor   : Jean Michel
  --    Data    : Dezembro/2017                   Ultima Atualizacao: 
  --
  --    Dados referentes ao programa:
  --
  --    Objetivo  : Package ref. a tela PARCDC (Ayllos Web)
  --
  --    Alteracoes:                              
  --    
  ---------------------------------------------------------------------------------------------------------------

  -- Rotina para manter Parâmetros CDC
  PROCEDURE pc_manter_parametros(pr_cddopcao         IN VARCHAR2                                  --> Código da Opção
                                ,pr_cdcooper_param   IN tbepr_cdc_parametro.cdcooper%TYPE         --> Código da Cooperativa
                                ,pr_inintegra_cont   IN tbepr_cdc_parametro.inintegra_cont%TYPE   --> Flag de Integração de Contingência
                                ,pr_nrprop_env       IN tbepr_cdc_parametro.nrprop_env%TYPE       --> Limite máximo de propostas
                                ,pr_intempo_prop_env IN tbepr_cdc_parametro.intempo_prop_env%TYPE --> Intervalo de tempo de propostas
                                ,pr_xmllog   IN VARCHAR2                                          --> XML com informações de LOG
                                ,pr_cdcritic OUT PLS_INTEGER                                      --> Código da crítica
                                ,pr_dscritic OUT VARCHAR2                                         --> Descrição da crítica
                                ,pr_retxml   IN OUT NOCOPY xmltype                                --> Arquivo de retorno do XML
                                ,pr_nmdcampo OUT VARCHAR2                                         --> Nome do Campo
                                ,pr_des_erro OUT VARCHAR2) IS                                     --> Saida OK/NOK

    /* .............................................................................
    Programa: pc_manter_parametros
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Jean Michel
    Data    : Dezembro/2017                       Ultima atualizacao: 
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para manter cadastro de parametros CDC da tela PARCDC
    
    Alteracoes: 
    ............................................................................. */
      
    -- CURSORES --
    CURSOR cr_tbepr_cdc_parametro(pr_cdcooper tbepr_cdc_parametro.cdcooper%TYPE) IS
      SELECT cdc.cdcooper
            ,cdc.inintegra_cont
            ,cdc.nrprop_env
            ,cdc.intempo_prop_env
        FROM tbepr_cdc_parametro cdc
       WHERE cdc.cdcooper = pr_cdcooper;

    rw_tbepr_cdc_parametro cr_tbepr_cdc_parametro%ROWTYPE;  
  
    CURSOR cr_crapcop(pr_cdcooper crapcop.cdcooper%TYPE) IS
      SELECT cop.cdcooper
        FROM crapcop cop
       WHERE (cop.cdcooper = pr_cdcooper OR pr_cdcooper = 99)
         AND cop.flgativo = 1;

    rw_crapcop cr_crapcop%ROWTYPE;

    --- VARIAVEIS ---
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;
       
    --Controle de erro
    vr_exc_erro EXCEPTION;
  
  BEGIN

    IF UPPER(pr_cddopcao) = 'C' THEN
      OPEN cr_tbepr_cdc_parametro(pr_cdcooper => pr_cdcooper_param);

      FETCH cr_tbepr_cdc_parametro INTO rw_tbepr_cdc_parametro;

      IF cr_tbepr_cdc_parametro%NOTFOUND THEN
        CLOSE cr_tbepr_cdc_parametro;
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf',   pr_posicao => 0, pr_tag_nova => 'cdcooper',         pr_tag_cont => '99', pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf',   pr_posicao => 0, pr_tag_nova => 'inintegra_cont',   pr_tag_cont => '0', pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf',   pr_posicao => 0, pr_tag_nova => 'nrprop_env',       pr_tag_cont => '10', pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf',   pr_posicao => 0, pr_tag_nova => 'intempo_prop_env', pr_tag_cont => '60', pr_des_erro => vr_dscritic);
      ELSE
        CLOSE cr_tbepr_cdc_parametro;
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf',   pr_posicao => 0, pr_tag_nova => 'cdcooper',         pr_tag_cont => TO_CHAR(rw_tbepr_cdc_parametro.cdcooper), pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf',   pr_posicao => 0, pr_tag_nova => 'inintegra_cont',   pr_tag_cont => TO_CHAR(rw_tbepr_cdc_parametro.inintegra_cont), pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf',   pr_posicao => 0, pr_tag_nova => 'nrprop_env',       pr_tag_cont => TO_CHAR(rw_tbepr_cdc_parametro.nrprop_env), pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf',   pr_posicao => 0, pr_tag_nova => 'intempo_prop_env', pr_tag_cont => TO_CHAR(rw_tbepr_cdc_parametro.intempo_prop_env), pr_des_erro => vr_dscritic);
      END IF;

    ELSIF UPPER(pr_cddopcao) = 'I' THEN
      FOR rw_crapcop IN cr_crapcop(pr_cdcooper => pr_cdcooper_param) LOOP
        BEGIN
          INSERT INTO tbepr_cdc_parametro(cdcooper, inintegra_cont, nrprop_env, intempo_prop_env)
            VALUES(rw_crapcop.cdcooper, pr_inintegra_cont, pr_nrprop_env, pr_intempo_prop_env);
        EXCEPTION
          WHEN DUP_VAL_ON_INDEX THEN
            BEGIN
              UPDATE tbepr_cdc_parametro
                SET inintegra_cont   = pr_inintegra_cont  
                   ,nrprop_env       = pr_nrprop_env      
                   ,intempo_prop_env = pr_intempo_prop_env
                WHERE tbepr_cdc_parametro.cdcooper = rw_crapcop.cdcooper;
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao atualizar registro de parâmetros CDC. Erro: ' || SQLERRM;
                RAISE vr_exc_erro;
            END;
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao inserir registro de parâmetros CDC. Erro: ' || SQLERRM;
            RAISE vr_exc_erro;
        END;
      END LOOP;
    END IF;
      
    pr_des_erro := 'OK';
  
  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Retorno nao OK          
      pr_des_erro := 'NOK';
    
      IF NVL(vr_cdcritic,0) > 0 THEN
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);       
      END IF;

      -- Erro
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_cdcritic || '-' || pr_dscritic || '</Erro></Root>');
    
    WHEN OTHERS THEN
      -- Retorno nao OK
      pr_des_erro := 'NOK';
      
      -- Erro
      pr_cdcritic := 0;
      pr_dscritic := 'Erro na TELA_PARCDC.PC_MANTER_PARAMETROS --> ' || SQLERRM;
      
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_cdcritic || '-' || pr_dscritic || '</Erro></Root>');
    
  END pc_manter_parametros;

  -- Rotina para manter Segmentos CDC
  PROCEDURE pc_manter_segmentos(pr_cddopcao IN VARCHAR2                             --> Código da Opção
	                             ,pr_tpproduto IN tbepr_cdc_segmento.tpproduto%TYPE   --> Tipo de produto
                               ,pr_cdsegmento IN tbepr_cdc_segmento.cdsegmento%TYPE --> Código do Segmento
                               ,pr_dssegmento IN tbepr_cdc_segmento.dssegmento%TYPE --> Descrição do Segmento
                               ,pr_xmllog   IN VARCHAR2                             --> XML com informações de LOG
                               ,pr_cdcritic OUT PLS_INTEGER                         --> Código da crítica
                               ,pr_dscritic OUT VARCHAR2                            --> Descrição da crítica
                               ,pr_retxml   IN OUT NOCOPY xmltype                   --> Arquivo de retorno do XML
                               ,pr_nmdcampo OUT VARCHAR2                            --> Nome do Campo
                               ,pr_des_erro OUT VARCHAR2) IS                        --> Saida OK/NOK

    /* .............................................................................
    Programa: pc_manter_segmentos
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Jean Michel
    Data    : Dezembro/2017                       Ultima atualizacao: 
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para manter cadastro de segmentos da tela PARCDC
    
    Alteracoes: 
    ............................................................................. */
      
    -- CURSORES --
    CURSOR cr_tbepr_cdc_segmento IS
      SELECT decode(seg.tpproduto, 0, 'CDC Diversos', 1, 'CDC Veículos') dsproduto
			      ,seg.cdsegmento
            ,seg.dssegmento
        FROM tbepr_cdc_segmento seg
     WHERE seg.cdsegmento = pr_cdsegmento OR pr_cdsegmento = 0; 

    rw_tbepr_cdc_segmento cr_tbepr_cdc_segmento%ROWTYPE;  

    CURSOR cr_tbepr_cdc_subsegmento IS
      SELECT sub.cdsubsegmento
        FROM tbepr_cdc_subsegmento sub
     WHERE sub.cdsegmento = pr_cdsegmento; 

    rw_tbepr_cdc_subsegmento cr_tbepr_cdc_subsegmento%ROWTYPE;
  
    --- VARIAVEIS ---
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;
  
    --Variáveis auxiliares
    vr_dstexto   VARCHAR2(32700);
    vr_clobxml   CLOB;
    
    --Controle de erro
    vr_exc_erro EXCEPTION;
    vr_contaseg INTEGER := 0;

  BEGIN
    IF UPPER(pr_cddopcao) = 'A' THEN
     
      BEGIN
        UPDATE tbepr_cdc_segmento 
           SET tbepr_cdc_segmento.dssegmento = UPPER(pr_dssegmento)
					    ,tbepr_cdc_segmento.tpproduto = pr_tpproduto
         WHERE tbepr_cdc_segmento.cdsegmento = pr_cdsegmento;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao atualizar registro de Segmento. Erro: ' || SQLERRM;
          RAISE vr_exc_erro; 
      END;

    ELSIF UPPER(pr_cddopcao) = 'C' THEN

      -- Informacoes de cabecalho de pacote
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Root', pr_posicao => 0, pr_tag_nova => 'segmentos', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);

      FOR rw_tbepr_cdc_segmento IN cr_tbepr_cdc_segmento LOOP
        -- Informacoes de cabecalho de pacote
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'segmentos', pr_posicao => 0, pr_tag_nova => 'segmento', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'segmento',   pr_posicao => vr_contaseg, pr_tag_nova => 'dsproduto', pr_tag_cont => TO_CHAR(rw_tbepr_cdc_segmento.dsproduto), pr_des_erro => vr_dscritic);				
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'segmento',   pr_posicao => vr_contaseg, pr_tag_nova => 'cdsegmento', pr_tag_cont => TO_CHAR(rw_tbepr_cdc_segmento.cdsegmento), pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'segmento',   pr_posicao => vr_contaseg, pr_tag_nova => 'dssegmento', pr_tag_cont => TO_CHAR(rw_tbepr_cdc_segmento.dssegmento), pr_des_erro => vr_dscritic);
        
        vr_contaseg := vr_contaseg + 1;
      END LOOP;  

    ELSIF UPPER(pr_cddopcao) = 'E' THEN

      OPEN cr_tbepr_cdc_subsegmento;

      FETCH cr_tbepr_cdc_subsegmento INTO rw_tbepr_cdc_subsegmento;

      IF cr_tbepr_cdc_subsegmento%NOTFOUND THEN
        BEGIN
          DELETE tbepr_cdc_segmento WHERE tbepr_cdc_segmento.cdsegmento = pr_cdsegmento;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao excluir registro de Segmento. Erro: ' || SQLERRM;
            RAISE vr_exc_erro;
        END;
      ELSE
        vr_dscritic := 'Segmento não pode ser excluído, possui subsegmentos vinculados.';
        RAISE vr_exc_erro;
      END IF;

    ELSIF UPPER(pr_cddopcao) = 'I' THEN

      BEGIN
        INSERT INTO tbepr_cdc_segmento(cdsegmento,dssegmento,tpproduto) VALUES(pr_cdsegmento,UPPER(pr_dssegmento),pr_tpproduto); 
      EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
          vr_dscritic := 'Código de Segmento já cadastrado.';
          RAISE vr_exc_erro; 
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao inserir registro de Segmento. Erro: ' || SQLERRM;
          RAISE vr_exc_erro; 
      END;

    END IF;

    pr_des_erro := 'OK';
  
  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Retorno nao OK          
      pr_des_erro := 'NOK';
    
      IF NVL(vr_cdcritic,0) > 0 THEN
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);       
      END IF;

      -- Erro
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_cdcritic || '-' || pr_dscritic || '</Erro></Root>');
    
    WHEN OTHERS THEN
      -- Retorno nao OK
      pr_des_erro := 'NOK';
      
      -- Erro
      pr_cdcritic := 0;
      pr_dscritic := 'Erro na TELA_PARCDC.PC_MANTER_SEGMENTOS --> ' || SQLERRM;
      
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_cdcritic || '-' || pr_dscritic || '</Erro></Root>');
    
  END pc_manter_segmentos;

  -- Rotina para manter Subsegmentos CDC
  PROCEDURE pc_manter_subsegmentos(pr_cddopcao       IN VARCHAR2                                 --> Código da Opção
                                  ,pr_cdsegmento     IN tbepr_cdc_subsegmento.cdsegmento%TYPE    --> Código do Segmento
                                  ,pr_cdsubsegmento  IN tbepr_cdc_subsegmento.cdsegmento%TYPE    --> Código do Subsegmento
                                  ,pr_dssubsegmento  IN tbepr_cdc_subsegmento.dssubsegmento%TYPE --> Descrição do Subsegmento
                                  ,pr_nrmax_parcela  IN tbepr_cdc_subsegmento.nrmax_parcela%TYPE --> Número máximo de parcelas
                                  ,pr_vlmax_financ   IN tbepr_cdc_subsegmento.vlmax_financ%TYPE  --> Valor máximo de financiamento
                                  ,pr_xmllog         IN VARCHAR2                                 --> XML com informações de LOG
                                  ,pr_cdcritic      OUT PLS_INTEGER                              --> Código da crítica
                                  ,pr_dscritic      OUT VARCHAR2                                 --> Descrição da crítica
                                  ,pr_retxml        IN OUT NOCOPY xmltype                        --> Arquivo de retorno do XML
                                  ,pr_nmdcampo      OUT VARCHAR2                                 --> Nome do Campo
                                  ,pr_des_erro      OUT VARCHAR2) IS                             --> Saida OK/NOK

    /* .............................................................................
    Programa: pc_manter_subsegmentos
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Jean Michel
    Data    : Dezembro/2017                       Ultima atualizacao: 
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para manter cadastro de subsegmentos da tela PARCDC
    
    Alteracoes: 
    ............................................................................. */

    -- CURSORES --
    CURSOR cr_tbepr_cdc_subsegmento(pr_cdsegmento tbepr_cdc_subsegmento.cdsegmento%TYPE
                                   ,pr_cdsubsegmento tbepr_cdc_subsegmento.cdsubsegmento%TYPE) IS
      SELECT sub.cdsegmento
            ,sub.cdsubsegmento
            ,sub.dssubsegmento
            ,sub.nrmax_parcela
            ,sub.vlmax_financ
        FROM tbepr_cdc_subsegmento sub
       WHERE sub.cdsegmento = pr_cdsegmento
         AND (sub.cdsubsegmento = pr_cdsubsegmento OR pr_cdsubsegmento = 0);

    rw_tbepr_cdc_subsegmento cr_tbepr_cdc_subsegmento%ROWTYPE;   
  
    CURSOR cr_tbepr_cdc_lojista_subseg(pr_cdsubsegmento tbepr_cdc_lojista_subseg.cdsubsegmento%TYPE) IS
      SELECT loj.idcooperado_cdc
            ,loj.cdsubsegmento
        FROM tbepr_cdc_lojista_subseg loj
       WHERE loj.cdsubsegmento = pr_cdsubsegmento;

    rw_tbepr_cdc_lojista_subseg cr_tbepr_cdc_lojista_subseg%ROWTYPE;

    --- VARIAVEIS ---
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;
  
    --Controle de erro
    vr_exc_erro EXCEPTION;
  
    vr_contasub INTEGER := 0;

  BEGIN
  
    IF UPPER(pr_cddopcao) = 'A' THEN
      BEGIN
        UPDATE tbepr_cdc_subsegmento 
           SET tbepr_cdc_subsegmento.cdsegmento = pr_cdsegmento
              ,tbepr_cdc_subsegmento.dssubsegmento = UPPER(pr_dssubsegmento)
              ,tbepr_cdc_subsegmento.nrmax_parcela = pr_nrmax_parcela
              ,tbepr_cdc_subsegmento.vlmax_financ  = pr_vlmax_financ
         WHERE tbepr_cdc_subsegmento.cdsubsegmento = pr_cdsubsegmento;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao atualizar registro de Subsegmento. Erro: ' || SQLERRM;
          RAISE vr_exc_erro; 
      END;
    ELSIF UPPER(pr_cddopcao) = 'C' THEN

      -- Informacoes de cabecalho de pacote
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Root', pr_posicao => 0, pr_tag_nova => 'subsegmentos', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);

      FOR rw_tbepr_cdc_subsegmento IN cr_tbepr_cdc_subsegmento(pr_cdsegmento    => pr_cdsegmento
                                                              ,pr_cdsubsegmento => pr_cdsubsegmento) LOOP
        -- Informacoes de cabecalho de pacote
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'subsegmentos', pr_posicao => 0, pr_tag_nova => 'subsegmento', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'subsegmento',  pr_posicao => vr_contasub, pr_tag_nova => 'cdsegmento', pr_tag_cont => TO_CHAR(rw_tbepr_cdc_subsegmento.cdsegmento), pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'subsegmento',  pr_posicao => vr_contasub, pr_tag_nova => 'cdsubsegmento', pr_tag_cont => TO_CHAR(rw_tbepr_cdc_subsegmento.cdsubsegmento), pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'subsegmento',  pr_posicao => vr_contasub, pr_tag_nova => 'dssubsegmento', pr_tag_cont => TO_CHAR(rw_tbepr_cdc_subsegmento.dssubsegmento), pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'subsegmento',  pr_posicao => vr_contasub, pr_tag_nova => 'nrmax_parcela', pr_tag_cont => TO_CHAR(rw_tbepr_cdc_subsegmento.nrmax_parcela), pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'subsegmento',  pr_posicao => vr_contasub, pr_tag_nova => 'vlmax_financ', pr_tag_cont => TO_CHAR(rw_tbepr_cdc_subsegmento.vlmax_financ,'FM999G999G990D00'), pr_des_erro => vr_dscritic);

        vr_contasub := vr_contasub + 1;
      END LOOP;  
    
    ELSIF UPPER(pr_cddopcao) = 'E' THEN
    
      OPEN cr_tbepr_cdc_lojista_subseg(pr_cdsubsegmento => pr_cdsubsegmento);
      
      FETCH cr_tbepr_cdc_lojista_subseg INTO rw_tbepr_cdc_lojista_subseg;

      IF cr_tbepr_cdc_lojista_subseg%NOTFOUND THEN

        CLOSE cr_tbepr_cdc_lojista_subseg;

        BEGIN
          DELETE tbepr_cdc_subsegmento WHERE tbepr_cdc_subsegmento.cdsubsegmento = pr_cdsubsegmento;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao excluir registro de Subsegmento. Erro: ' || SQLERRM;
            RAISE vr_exc_erro; 
        END;
      ELSE
        CLOSE cr_tbepr_cdc_lojista_subseg;
        vr_dscritic := 'Subsegmento não pode ser excluído, possui lojistas vinculados. Cod: ' || pr_cdsubsegmento;
        RAISE vr_exc_erro;
      END IF;      

    ELSIF UPPER(pr_cddopcao) = 'I' THEN

      BEGIN
        INSERT INTO tbepr_cdc_subsegmento(cdsubsegmento, dssubsegmento, cdsegmento, nrmax_parcela, vlmax_financ)
          VALUES(pr_cdsubsegmento,UPPER(pr_dssubsegmento),pr_cdsegmento,pr_nrmax_parcela,pr_vlmax_financ); 
      EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
          vr_dscritic := 'Código de Subsegmento já cadastrado.';
          RAISE vr_exc_erro; 
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao inserir registro de Segmento. Erro: ' || SQLERRM;
          RAISE vr_exc_erro; 
      END;

    END IF;

    pr_des_erro := 'OK';
  
  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Retorno nao OK          
      pr_des_erro := 'NOK';
    
      IF NVL(vr_cdcritic,0) > 0 THEN
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);       
      END IF;

      -- Erro
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_cdcritic || '-' || pr_dscritic || '</Erro></Root>');
    
    WHEN OTHERS THEN
      -- Retorno nao OK
      pr_des_erro := 'NOK';
      
      -- Erro
      pr_cdcritic := 0;
      pr_dscritic := 'Erro na TELA_PARCDC.PC_MANTER_SUBSEGMENTOS --> ' || SQLERRM;
      
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_cdcritic || '-' || pr_dscritic || '</Erro></Root>');
    
  END pc_manter_subsegmentos;

END TELA_PARCDC;
/
