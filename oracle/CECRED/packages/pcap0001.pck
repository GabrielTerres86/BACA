create or replace package cecred.PCAP0001 is
  /*.............................................................................

    Programa: PCAP0001      (Antiga: b1wgen0140.p)
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Tiago
    Data    : Setembro/12                            Ultima alteracao: 03/03/2016

    Objetivo  : Procedures referentes ao PROCAP.

    Alteracao : 30/08/2013 - Convers�o Progress >> Oracle PLSQL (Edison-AMcom)

                23/10/2013 - Removido o uso da global glb_dtmvtolt. Substituido
                             por FIND na crapdat. (Fabricio)

                12/11/2013 - Tratamento historico 1511 (Migracao). (Irlan )

                18/12/2013 - Ajustes ref. as altera��es citadas acima. (Edison-AMcom)

				03/03/2016 - Ajustes ref. as altera��es de layout do procapcred 
				             (Guilherme F. Gielow - Chamado 400291)
  ............................................................................ */

  -- Definicao do tipo de registro de cotas de associados
  TYPE typ_reg_craplct IS
  RECORD ( nrchave VARCHAR2(100) -- lpad(cdagenci,5,'0')||lpad(nrdconta,10,'0')
          ,dtmvtolt craplct.dtmvtolt%TYPE
          ,cdagenci craplct.cdagenci%TYPE
          ,cdbccxlt craplct.cdbccxlt%TYPE
          ,nrdolote craplct.nrdolote%TYPE
          ,nrdconta craplct.nrdconta%TYPE
          ,dspessoa VARCHAR2(2)
          ,nrdocmto craplct.nrdocmto%TYPE
          ,cdhistor craplct.cdhistor%TYPE
          ,nrseqdig craplct.nrseqdig%TYPE
          ,vllanmto craplct.vllanmto%TYPE
          ,nrctrpla craplct.nrctrpla%TYPE
          ,qtlanmfx craplct.qtlanmfx%TYPE
          ,nrautdoc craplct.nrautdoc%TYPE
          ,nrsequni craplct.nrsequni%TYPE
          ,cdcooper craplct.cdcooper%TYPE
          ,dtlibera craplct.dtlibera%TYPE
          ,dtcrdcta craplct.dtcrdcta%TYPE
          ,progress_recid craplct.progress_recid%TYPE
          ,dsdesblq VARCHAR2(1)
          ,dtdsaque DATE
          ,nmprimtl crapass.nmprimtl%TYPE -- nome do associado
          ,cdtpdata NUMBER
          ,totinteg NUMBER
          ,qtdreg   NUMBER                -- qtde de ref. partition by para controle FIRST OF
          ,nrseqreg NUMBER                -- sequencia do registro para controle do FIRST OFF
          );



  -- Definicao do tipo de tabela de associados
  TYPE typ_tab_craplct IS
    TABLE OF typ_reg_craplct
    INDEX BY VARCHAR2(100);
    
  -- TempTable para armazenamento das informa��es dos avalistas
  -- antiga tt-avalistas   
  TYPE typ_reg_avalistas IS
  RECORD (nrcpfcgc NUMBER,
          nrdctato NUMBER,
          nmdavali crapass.nmprimtl%type,
          cddosexo VARCHAR2(5),
          dsendere VARCHAR2(200),
          nrcepend NUMBER,
          flgcheck BOOLEAN);
          
  TYPE typ_tab_avalistas IS TABLE OF typ_reg_avalistas 
       INDEX BY VARCHAR2(15); --nrcpfcgc(15)
  
  -- TempTable para armazenamento das informa��es para gera��o do arq.BRDE
  -- Antiga tt-brde
  TYPE typ_reg_brde IS
  RECORD ( nrdconta crapass.nrdconta%type,
           nmextttl crapttl.nmextttl%type,
           dtnasttl crapttl.dtnasttl%type,
           vlsalari crapttl.vlsalari%type,
           dtrefere date,
           nrcpfcgc crapttl.nrcpfcgc%type,
           dsendere crapenc.dsendere%type,
           nrendere crapenc.nrendere%type,
           compleme crapenc.complend%type,
           nmbairro crapenc.nmbairro%type,
           nrcepend crapenc.nrcepend%type,
           cdufende crapenc.cdufende%type,
           nmcidade crapenc.nmcidade%type,
           nrdddtfc craptfc.nrdddtfc%type,
           nrtelefo craptfc.nrtelefo%type);
           
  TYPE typ_tab_brde IS TABLE OF typ_reg_brde 
       INDEX BY VARCHAR2(10); --nrdconta(10)   
       
  -- Antiga tt-arq-brde 
  TYPE typ_reg_arq_brde IS
      RECORD( cdseqlin PLS_INTEGER,
              dsdlinha VARCHAR2(4000));
  TYPE typ_tab_arq_brde IS TABLE OF typ_reg_arq_brde 
       INDEX BY PLS_INTEGER; --cdseqlin
       
  -- PL Table para armazenar valores totais ativos por PF e PJ
  TYPE typ_reg_ativos IS
    RECORD(totativo NUMBER DEFAULT 0
          ,vlativos NUMBER DEFAULT 0);
          
  -- Instancia e indexa por tipo de pessoa com o index - 1-Fisico/2-Juridico
  TYPE typ_tab_ativos IS TABLE OF typ_reg_ativos INDEX BY PLS_INTEGER;
  
  -- PL Table para armazenar valores totais desbloqueado nao sacado por PF e PJ
  TYPE typ_reg_desb_nsacado IS
    RECORD(todbnsac NUMBER DEFAULT 0
          ,vldbnsac NUMBER DEFAULT 0);
          
  -- Instancia e indexa por tipo de pessoa com o index - 1-Fisico/2-Juridico
  TYPE typ_tab_desb_nsacado IS TABLE OF typ_reg_desb_nsacado INDEX BY PLS_INTEGER;
  
  -- PL Table para armazenar valores totais capital sacado por PF e PJ
  TYPE typ_reg_capsac IS
    RECORD(tocapsac NUMBER DEFAULT 0
          ,vlcapsac NUMBER DEFAULT 0);
          
  -- Instancia e indexa por tipo de pessoa com o index - 1-Fisico/2-Juridico
  TYPE typ_tab_capsac IS TABLE OF typ_reg_capsac INDEX BY PLS_INTEGER;
  
  -- PL Table para armazenar valores totais por PF e PJ
  TYPE typ_reg_integralizado IS
    RECORD(qtprocap NUMBER DEFAULT 0
          ,totinteg NUMBER DEFAULT 0);
          
  -- Instancia e indexa por tipo de pessoa com o index - 1-Fisico/2-Juridico
  TYPE typ_tab_integralizado IS TABLE OF typ_reg_integralizado INDEX BY PLS_INTEGER;

  /* Procedimento para buscar os lan�amentos de cotas de capital ativos */
  PROCEDURE pc_busca_procap_ativos( pr_cdcooper IN crapcop.cdcooper%TYPE -- c�digo da cooperativa
                                   ,pr_totativo OUT NUMBER               -- qtde total de lan�amentos
                                   ,pr_vlativos OUT NUMBER               -- valor total dos lan�amentos
                                   ,pr_tab_craplct OUT typ_tab_craplct   -- listagem com os lan�amentos
                                   ,pr_typ_tab_ativos OUT typ_tab_ativos   -- listagem de lantos separados por tipo de pessoa
                                   ,pr_dscritic   OUT VARCHAR2); -- descri��o do erro se ocorrer

  /* Procedimento para buscar os lan�amentos de cotas de capital desbloqueadas e n�o sacadas */
  PROCEDURE pc_busca_procap_desbl_naosac ( pr_cdcooper IN crapcop.cdcooper%TYPE -- c�digo da coopertativa
                                          ,pr_todbnsac OUT NUMBER               -- qtde total de lan�amentos
                                          ,pr_vldbnsac OUT NUMBER               -- valor total dos lan�amentos
                                          ,pr_tab_craplct OUT typ_tab_craplct   -- listagem com os lan�amentos
                                          ,pr_typ_tab_desb_nsacado OUT typ_tab_desb_nsacado   -- listagem de lantos separados por tipo de pessoa
                                          ,pr_dscritic   OUT VARCHAR2); -- descri��o do erro se ocorrer

  /* Procedimento para buscar a data do �ltimo saque */
  PROCEDURE pc_busca_data_saque( pr_cdcooper IN crapcop.cdcooper%TYPE -- c�digo da cooperativa
                                ,pr_nrdconta IN crapass.nrdconta%TYPE -- n�mero da conta do associado
                                ,pr_dtdsaque OUT DATE                 -- data do �ltimo saque
                                ,pr_dscritic OUT VARCHAR2); -- descri��o do erro se ocorrer

  /* Procedimento para buscar os lan�amentos de cotas decapital sacadas */
  PROCEDURE pc_busca_procap_capital_sacado ( pr_cdcooper     IN crapcop.cdcooper%TYPE -- c�digo da cooperativa
                                            ,pr_tocapsac    OUT NUMBER                -- qtde total dos lan�amentos
                                            ,pr_vlcapsac    OUT NUMBER                -- valor total dos lan�amentos
                                            ,pr_tab_craplct OUT typ_tab_craplct       -- listagem com os lan�amentos
                                            ,pr_typ_tab_capsac OUT typ_tab_capsac   -- listagem de lantos separados por tipo de pessoa
                                            ,pr_dscritic    OUT VARCHAR2);            -- descri��o do erro se ocorrer

  /* Procedimentos para buscar a quantidade e o valor total dos lan�amentos de cotas de capital
     integralizadas para determinada conta do associado */
  PROCEDURE pc_total_integralizado ( pr_cdcooper IN crapcop.cdcooper%TYPE -- c�digo da cooperativa
                                    ,pr_nrdconta IN NUMBER                -- n�mero da conta do associado
                                    ,pr_inpessoa OUT PLS_INTEGER           -- Tipo de pessoa
                                    ,pr_qtprocap OUT NUMBER               -- qtde de cotas integralizadas
                                    ,pr_totinteg OUT NUMBER               -- valor total das cotas integralizadas
                                    ,pr_typ_tab_integralizado OUT typ_tab_integralizado   -- listagem de lantos separados por tipo de pessoa
                                    ,pr_dscritic OUT VARCHAR2);           -- descri��o do erro se ocorrer
                                    
  /******************************************************************************
    Gerar arquivo para encaminhamento ao BRDE
   ******************************************************************************/
  PROCEDURE pc_gerar_arq_enc_brde	(pr_cdcooper IN crapcop.cdcooper%TYPE      --> c�digo da cooperativa
                                  ,pr_cdagenci IN crapage.cdagenci%TYPE      --> codigo da agencia
                                  ,pr_nrdcaixa IN NUMBER                     --> numero do caixa
                                  ,pr_cdoperad IN crapope.cdoperad%TYPE      --> Codigo do operador
                                  ,pr_dtmvtolt IN DATE                       --> Data do movimento
                                  ,pr_nrdolote IN INTEGER                    --> Numero do lote
                                  ,pr_nmarquiv OUT VARCHAR2                  --> Nome do arquivo gerado
                                  ,pr_nmdcampo OUT VARCHAR2                  --> Nome do campo a ser retornado
                                  ,pr_des_reto OUT VARCHAR2                   --> Indicador de saida com erro (OK/NOK)
                                  ,pr_tab_erro OUT GENE0001.typ_tab_erro);   --> Tabela com erros                                  


  /*****************************************************************************
    Gerar arquivo para encaminhamento ao BRDE - vers�o para ser chamada pelo progress e web
   ******************************************************************************/
  PROCEDURE pc_gerar_arq_enc_brde_web	(pr_cdcooper IN crapcop.cdcooper%TYPE      --> c�digo da cooperativa
                                      ,pr_cdagenci IN crapage.cdagenci%TYPE      --> codigo da agencia
                                      ,pr_nrdcaixa IN NUMBER                     --> numero do caixa
                                      ,pr_cdoperad IN crapope.cdoperad%TYPE      --> Codigo do operador
                                      ,pr_dtmvtolt IN DATE                       --> Data do movimento
                                      ,pr_nrdolote IN INTEGER                    --> Numero do lote
                                      ,pr_nmarquiv OUT VARCHAR2                  --> Nome do arquivo gerado
                                      ,pr_nmdcampo OUT VARCHAR2                  --> Nome do campo a ser retornado
                                      ,pr_des_reto OUT VARCHAR2                  --> Indicador de saida com erro (OK/NOK)
                                      ,pr_xml_erro OUT CLOB) ;                   --> Tabela com erros
END PCAP0001;
/

create or replace package body cecred.PCAP0001 is
  /*.............................................................................

    Programa: PCAP0001      (Antiga: b1wgen0140.p)
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Tiago
    Data    : Setembro/12                            Ultima alteracao: 31/03/2015

    Objetivo  : Procedures referentes ao PROCAP (Programa de capitaliza��o).

    Altera��es: 30/08/2013 - Convers�o Progress --> Oracle PLSQL (Edison - AMcom)

                23/10/2013 - Removido o uso da global glb_dtmvtolt. Substituido
                             por FIND na crapdat. (Fabricio)

                12/11/2013 - Tratamento historico 1511 (Migracao). (Irlan )

                18/12/2013 - Ajustes ref. as altera��es citadas acima. (Edison-AMcom)

                31/03/2015 - Projeto de separa��o cont�beis de PF e PJ.
                                (Andre Santos - SUPERO
  ............................................................................ */

  -- Cursor de associados
  CURSOR cr_crapass ( pr_cdcooper IN crapass.cdcooper%TYPE
                     ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
    SELECT  crapass.nrdconta
           ,crapass.cdagenci
           ,crapass.vllimcre
           ,crapass.tpextcta
           ,crapass.inpessoa
           ,DECODE(crapass.inpessoa,1,'PF',2,'PJ',' ') dspessoa
           ,crapass.nrcpfcgc
           ,crapass.nmprimtl
           ,rowid
    FROM  crapass
    WHERE crapass.cdcooper = pr_cdcooper
    AND   crapass.nrdconta = pr_nrdconta;

  rw_crapass cr_crapass%ROWTYPE;

  /* Procedimento para buscar os lan�amentos de cotas de capital ativos */
  PROCEDURE pc_busca_procap_ativos( pr_cdcooper IN crapcop.cdcooper%TYPE -- c�digo da cooperativa
                                   ,pr_totativo OUT NUMBER               -- qtde total de lan�amentos
                                   ,pr_vlativos OUT NUMBER               -- valor total dos lan�amentos
                                   ,pr_tab_craplct OUT typ_tab_craplct   -- listagem com os lan�amentos
                                   ,pr_typ_tab_ativos OUT typ_tab_ativos   -- listagem de lantos separados por tipo de pessoa
                                   ,pr_dscritic   OUT VARCHAR2) IS -- descri��o do erro se ocorrer
  ---------------------------------------------------------------------------------------------------------------
  --  Programa : pc_busca_procap_ativos (Antigo: busca_procap_ativos)
  --  Sistema  : Conta-Corrente - Cooperativa de Credito
  --  Sigla    : PCAP
  --  Autor   : Tiago
  --  Data    : Setembro/12                            Ultima alteracao: 30/08/2013
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: sempre que chamado
  -- Objetivo  : Retornar os lan�amentos ativos de cotas de capital
  --
  --  Altera��es: 30/08/2013 - Convers�o Progress --> Oracle PLSQL (Edison - AMcom)
  ---------------------------------------------------------------------------------------------------------------
  BEGIN
    DECLARE
      -- Seleciona os lan�amentos de cotas de capital ativas
      CURSOR cr_craplct( pr_cdcooper craplct.cdcooper%TYPE) IS
        SELECT craplct.dtmvtolt
              ,craplct.cdagenci
              ,craplct.cdbccxlt
              ,craplct.nrdolote
              ,craplct.nrdconta
              ,craplct.nrdocmto
              ,craplct.cdhistor
              ,craplct.nrseqdig
              ,craplct.vllanmto
              ,craplct.nrctrpla
              ,craplct.qtlanmfx
              ,craplct.nrautdoc
              ,craplct.nrsequni
              ,craplct.cdcooper
              ,craplct.dtlibera
              ,craplct.dtcrdcta
              ,craplct.progress_recid
        FROM   craplct
        WHERE  craplct.cdcooper = pr_cdcooper
        AND    craplct.cdhistor = 930
        AND    craplct.dtlibera IS NULL;

      vr_chave VARCHAR2(100);

    BEGIN
      -- Inicializando as vari�veis
      pr_totativo := 0;
      pr_vlativos := 0;

      -- limpando a tabela de mem�ria
      pr_tab_craplct.delete;
      pr_typ_tab_ativos.delete;
      
      -- Inicializando as vari�veis de tipo de pessoa
      FOR idx IN 1..2 LOOP
         pr_typ_tab_ativos(idx).vlativos :=0;
         pr_typ_tab_ativos(idx).totativo :=0;
      END LOOP;

      -- Abre o cursor dos lan�amentos
      FOR rw_craplct IN cr_craplct( pr_cdcooper => pr_cdcooper)
      LOOP
        -- Verifica se o associado existe
        OPEN cr_crapass( pr_cdcooper => pr_cdcooper
                        ,pr_nrdconta => rw_craplct.nrdconta);
        FETCH cr_crapass INTO rw_crapass;
        -- Verifica se o associado existe
        IF cr_crapass%FOUND THEN
          -- criando a chave para ordena��o
          vr_chave := lpad(rw_crapass.cdagenci,5,'0')||
                      lpad(rw_craplct.nrdconta,10,'0')||
                      to_char(rw_craplct.dtmvtolt,'YYYYMMDD')||
                      lpad(rw_craplct.progress_recid,10,'0');

          -- Alimentando a tabela tempor�ria
          pr_tab_craplct(vr_chave).nrchave := vr_chave;
          pr_tab_craplct(vr_chave).dtmvtolt := rw_craplct.dtmvtolt;
          pr_tab_craplct(vr_chave).cdagenci := rw_crapass.cdagenci; -- Agencia do associado
          pr_tab_craplct(vr_chave).cdbccxlt := rw_craplct.cdbccxlt;
          pr_tab_craplct(vr_chave).nrdolote := rw_craplct.nrdolote;
          pr_tab_craplct(vr_chave).nrdconta := rw_craplct.nrdconta;
          pr_tab_craplct(vr_chave).dspessoa := rw_crapass.dspessoa;
          pr_tab_craplct(vr_chave).nrdocmto := rw_craplct.nrdocmto;
          pr_tab_craplct(vr_chave).cdhistor := rw_craplct.cdhistor;
          pr_tab_craplct(vr_chave).nrseqdig := rw_craplct.nrseqdig;
          pr_tab_craplct(vr_chave).vllanmto := rw_craplct.vllanmto;
          pr_tab_craplct(vr_chave).nrctrpla := rw_craplct.nrctrpla;
          pr_tab_craplct(vr_chave).qtlanmfx := rw_craplct.qtlanmfx;
          pr_tab_craplct(vr_chave).nrautdoc := rw_craplct.nrautdoc;
          pr_tab_craplct(vr_chave).nrsequni := rw_craplct.nrsequni;
          pr_tab_craplct(vr_chave).cdcooper := rw_craplct.cdcooper;
          pr_tab_craplct(vr_chave).dtlibera := rw_craplct.dtlibera;
          pr_tab_craplct(vr_chave).dtcrdcta := rw_craplct.dtcrdcta;
          pr_tab_craplct(vr_chave).progress_recid := rw_craplct.progress_recid;
          pr_tab_craplct(vr_chave).nmprimtl :=  rw_crapass.nmprimtl; -- Nome do associado

          -- Totalizando a quantidade e o valor de cotas
          pr_totativo := nvl(pr_totativo,0) + 1;
          pr_vlativos := nvl(pr_vlativos,0) + nvl(rw_craplct.vllanmto,0);
          
          -- Totalizando a quantidade e o valor das cotas por tipo de pessoa
          pr_typ_tab_ativos(rw_crapass.inpessoa).vlativos := pr_typ_tab_ativos(rw_crapass.inpessoa).vlativos + nvl(rw_craplct.vllanmto,0);
          pr_typ_tab_ativos(rw_crapass.inpessoa).totativo := pr_typ_tab_ativos(rw_crapass.inpessoa).totativo + 1;          
        END IF;
        -- Fecha o cursor
        CLOSE cr_crapass;
      END LOOP;

    EXCEPTION
      WHEN OTHERS THEN
        -- fecha o cursor caso ele esteja aberto
        IF cr_crapass%ISOPEN THEN
          -- Fecha o cursor
          CLOSE cr_crapass;
        END IF;
        -- Retorna o erro
        pr_dscritic := 'Erro n�o tratado na pcap0001.pc_busca_procap_ativos --> '||SQLERRM;
    END;
  END pc_busca_procap_ativos;

  /* Procedimento para buscar os lan�amentos de cotas de capital desbloqueadas e n�o sacadas */
  PROCEDURE pc_busca_procap_desbl_naosac ( pr_cdcooper IN crapcop.cdcooper%TYPE -- c�digo da coopertativa
                                          ,pr_todbnsac OUT NUMBER               -- qtde total de lan�amentos
                                          ,pr_vldbnsac OUT NUMBER               -- valor total dos lan�amentos
                                          ,pr_tab_craplct OUT typ_tab_craplct   -- listagem com os lan�amentos
                                          ,pr_typ_tab_desb_nsacado OUT typ_tab_desb_nsacado   -- listagem de lantos separados por tipo de pessoa
                                          ,pr_dscritic   OUT VARCHAR2) IS -- descri��o do erro se ocorrer
  ---------------------------------------------------------------------------------------------------------------
  --  Programa : pc_busca_procap_desbl_naosac (Antigo: busca_procap_desbl_naosac)
  --  Sistema  : Conta-Corrente - Cooperativa de Credito
  --  Sigla    : PCAP
  --  Autor   : Tiago
  --  Data    : Setembro/12                            Ultima alteracao: 30/08/2013
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: sempre que chamado
  -- Objetivo  : retornar os lan�amentos de cotas de capital desbloqueadas e n�o sacadas
  --
  --  Altera��es: 30/08/2013 - Convers�o Progress --> Oracle PLSQL (Edison - AMcom)
  ---------------------------------------------------------------------------------------------------------------
  BEGIN
    DECLARE
      -- Seleciona os lan�amentos de cotas de capital desbloqueadas e n�o sacadas
      CURSOR cr_craplct( pr_cdcooper IN craplct.cdcooper%TYPE) IS
        SELECT craplct.dtmvtolt
              ,craplct.cdagenci
              ,craplct.cdbccxlt
              ,craplct.nrdolote
              ,craplct.nrdconta
              ,craplct.nrdocmto
              ,craplct.cdhistor
              ,craplct.nrseqdig
              ,craplct.vllanmto
              ,craplct.nrctrpla
              ,craplct.qtlanmfx
              ,craplct.nrautdoc
              ,craplct.nrsequni
              ,craplct.cdcooper
              ,craplct.dtlibera
              ,craplct.dtcrdcta
              ,craplct.progress_recid
        FROM   craplct
        WHERE  craplct.cdcooper = pr_cdcooper
        AND    craplct.cdhistor = 930
        AND    craplct.dtlibera IS NOT NULL;

      -- Data do �ltimo saque
      vr_dtdsaque DATE;
      vr_chave    VARCHAR2(100);
    BEGIN
      -- Inicializando as vari�veis
      pr_todbnsac := 0;
      pr_vldbnsac := 0;

      -- limpando a tabela de mem�ria
      pr_tab_craplct.delete;
      pr_typ_tab_desb_nsacado.delete;
      
      -- Inicializando as vari�veis de tipo de pessoa
      FOR idx IN 1..2 LOOP
         pr_typ_tab_desb_nsacado(idx).todbnsac :=0;
         pr_typ_tab_desb_nsacado(idx).vldbnsac :=0;
      END LOOP;

      -- Abre o cursor dos lan�amentos
      FOR rw_craplct IN cr_craplct( pr_cdcooper => pr_cdcooper)
      LOOP
        -- Verifica se o associado existe
        OPEN cr_crapass( pr_cdcooper => pr_cdcooper
                        ,pr_nrdconta => rw_craplct.nrdconta);
        FETCH cr_crapass INTO rw_crapass;
        -- Verifica se o associado existe
        IF cr_crapass%FOUND THEN
          -- criando a chave para ordena��o
          vr_chave := lpad(rw_crapass.cdagenci,5,'0')||
                      lpad(rw_craplct.nrdconta,10,'0')||
                      to_char(rw_craplct.dtmvtolt,'YYYYMMDD')||
                      lpad(rw_craplct.progress_recid,10,'0');

          -- Busca a data do �ltimo saque do associado
          pc_busca_data_saque( pr_cdcooper => pr_cdcooper
                              ,pr_nrdconta => rw_craplct.nrdconta
                              ,pr_dtdsaque => vr_dtdsaque
                              ,pr_dscritic => pr_dscritic);

          -- Se n�o der erro e se o associado n�o efetuou saque
          IF pr_dscritic IS NULL AND vr_dtdsaque IS NULL THEN

            -- Alimentando a tabela tempor�ria
            pr_tab_craplct(vr_chave).nrchave := vr_chave;
            pr_tab_craplct(vr_chave).dtmvtolt := rw_craplct.dtmvtolt;
            pr_tab_craplct(vr_chave).cdagenci := rw_crapass.cdagenci; -- Agencia do associado
            pr_tab_craplct(vr_chave).cdbccxlt := rw_craplct.cdbccxlt;
            pr_tab_craplct(vr_chave).nrdolote := rw_craplct.nrdolote;
            pr_tab_craplct(vr_chave).nrdconta := rw_craplct.nrdconta;
            pr_tab_craplct(vr_chave).dspessoa := rw_crapass.dspessoa;            
            pr_tab_craplct(vr_chave).nrdocmto := rw_craplct.nrdocmto;
            pr_tab_craplct(vr_chave).cdhistor := rw_craplct.cdhistor;
            pr_tab_craplct(vr_chave).nrseqdig := rw_craplct.nrseqdig;
            pr_tab_craplct(vr_chave).vllanmto := rw_craplct.vllanmto;
            pr_tab_craplct(vr_chave).nrctrpla := rw_craplct.nrctrpla;
            pr_tab_craplct(vr_chave).qtlanmfx := rw_craplct.qtlanmfx;
            pr_tab_craplct(vr_chave).nrautdoc := rw_craplct.nrautdoc;
            pr_tab_craplct(vr_chave).nrsequni := rw_craplct.nrsequni;
            pr_tab_craplct(vr_chave).cdcooper := rw_craplct.cdcooper;
            pr_tab_craplct(vr_chave).dtlibera := rw_craplct.dtlibera;
            pr_tab_craplct(vr_chave).dtcrdcta := rw_craplct.dtcrdcta;
            pr_tab_craplct(vr_chave).progress_recid := rw_craplct.progress_recid;
            pr_tab_craplct(vr_chave).nmprimtl :=  rw_crapass.nmprimtl; -- Nome do associado
            --Totaliza a quantidade de cotas n�o sacados
            pr_todbnsac := nvl(pr_todbnsac,0) + 1;
            --Totaliza o valor das cotas que n�o foram sacadas
            pr_vldbnsac := nvl(pr_vldbnsac,0) + nvl(rw_craplct.vllanmto,0);
            
            -- Totalizando a quantidade e o valor das cotas cotas que n�o foram sacadas por tipo de pessoa
            pr_typ_tab_desb_nsacado(rw_crapass.inpessoa).vldbnsac := pr_typ_tab_desb_nsacado(rw_crapass.inpessoa).vldbnsac + nvl(rw_craplct.vllanmto,0);
            pr_typ_tab_desb_nsacado(rw_crapass.inpessoa).todbnsac := pr_typ_tab_desb_nsacado(rw_crapass.inpessoa).todbnsac + 1;          
          END IF;
        END IF;
        -- Fecha o cursor
        CLOSE cr_crapass;
      END LOOP;

    EXCEPTION
      WHEN OTHERS THEN
        -- fecha o cursor caso ele esteja aberto
        IF cr_crapass%ISOPEN THEN
          -- Fecha o cursor
          CLOSE cr_crapass;
        END IF;
        -- Retorna o erro
        pr_dscritic := 'Erro n�o tratado na pcap0001.pc_busca_procap_desbl_naosac --> '||SQLERRM;
    END;
  END pc_busca_procap_desbl_naosac;

  /* Procedimento para buscar a data do �ltimo saque */
  PROCEDURE pc_busca_data_saque( pr_cdcooper IN crapcop.cdcooper%TYPE -- c�digo da cooperativa
                                ,pr_nrdconta IN crapass.nrdconta%TYPE -- n�mero da conta do associado
                                ,pr_dtdsaque OUT DATE                 -- data do �ltimo saque
                                ,pr_dscritic OUT VARCHAR2) IS -- descri��o do erro se ocorrer
  ---------------------------------------------------------------------------------------------------------------
  --  Programa : pc_busca_data_saque (Antigo: busca_data_saque)
  --  Sistema  : Conta-Corrente - Cooperativa de Credito
  --  Sigla    : PCAP
  --  Autor   : Tiago
  --  Data    : Setembro/12                            Ultima alteracao: 30/08/2013
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: sempre que chamado
  -- Objetivo  : Retornar a data do �ltimo saque
  --
  --  Altera��es: 30/08/2013 - Convers�o Progress --> Oracle PLSQL (Edison - AMcom)
  --
  --              18/12/2013 - Incluida a clausula "craplct.cdhistor = 1511 OR"
  --                           no cursor cr_craplct (Edison - AMcom)
  --
  ---------------------------------------------------------------------------------------------------------------
  BEGIN
    DECLARE
      -- Seleciona a data do �ltimo saque de cotas efetuado pelo associado
      CURSOR cr_craplct IS
        SELECT craplct.dtmvtolt
        FROM   craplct
        WHERE  craplct.cdcooper = pr_cdcooper
        AND    craplct.nrdconta = pr_nrdconta
        AND    (craplct.cdhistor = 932  OR
                craplct.cdhistor = 1511 OR
                craplct.cdhistor = 1093)
        ORDER BY craplct.progress_recid DESC;

      -- Tipo do registro
      rw_craplct cr_craplct%ROWTYPE;
    BEGIN
      -- Abre o cursor dos lan�amentos
      OPEN cr_craplct;
      FETCH cr_craplct INTO rw_craplct;
      -- Verifica se possui lan�amento de saque
      IF cr_craplct%NOTFOUND THEN
        pr_dtdsaque := NULL;
      ELSE
        -- Retorna a maior data de saque
        pr_dtdsaque := rw_craplct.dtmvtolt;
      END IF;
      -- Fechando o cursor
      CLOSE cr_craplct;
    EXCEPTION
      WHEN OTHERS THEN
        -- Verifica se o cursor est� aberto
        IF cr_craplct%ISOPEN THEN
          -- Fechando o cursor
          CLOSE cr_craplct;
        END IF;
        pr_dscritic := 'Erro n�o tratado na pcap0001.pc_busca_data_saque --> '||SQLERRM;
    END;
  END pc_busca_data_saque;

  /* Procedimento para buscar os lan�amentos de cotas decapital sacadas */
  PROCEDURE pc_busca_procap_capital_sacado (pr_cdcooper IN crapcop.cdcooper%TYPE -- c�digo da cooperativa
                                           ,pr_tocapsac OUT NUMBER                 -- qtde total dos lan�amentos
                                           ,pr_vlcapsac OUT NUMBER                 -- valor total dos lan�amentos
                                           ,pr_tab_craplct OUT typ_tab_craplct     -- listagem com os lan�amentos
                                           ,pr_typ_tab_capsac OUT typ_tab_capsac   -- listagem de lantos separados por tipo de pessoa
                                           ,pr_dscritic   OUT VARCHAR2) IS -- descri��o do erro se ocorrer
  ---------------------------------------------------------------------------------------------------------------
  --  Programa : pc_busca_procap_capital_sacado (Antigo: busca_procap_capital_sacado)
  --  Sistema  : Conta-Corrente - Cooperativa de Credito
  --  Sigla    : PCAP
  --  Autor   : Tiago
  --  Data    : Setembro/12                            Ultima alteracao: 30/08/2013
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: sempre que chamado
  -- Objetivo  : Retornar os lan�amentos de cotas de capital sacadas
  --
  --  Altera��es: 30/08/2013 - Convers�o Progress --> Oracle PLSQL (Edison - AMcom)
  --
  --              18/12/2013 - Incluida a clausula "craplct.cdhistor = 1511 OR"
  --                           no cursor cr_craplct (Edison - AMcom)
  ---------------------------------------------------------------------------------------------------------------
  BEGIN
    DECLARE
      -- Seleciona os lan�amentos de cotas de capital sacadas
      CURSOR cr_craplct( pr_cdcooper IN craplct.cdcooper%TYPE) IS
        SELECT craplct.dtmvtolt
              ,craplct.cdagenci
              ,craplct.cdbccxlt
              ,craplct.nrdolote
              ,craplct.nrdconta
              ,craplct.nrdocmto
              ,craplct.cdhistor
              ,craplct.nrseqdig
              ,craplct.vllanmto
              ,craplct.nrctrpla
              ,craplct.qtlanmfx
              ,craplct.nrautdoc
              ,craplct.nrsequni
              ,craplct.cdcooper
              ,craplct.dtlibera
              ,craplct.dtcrdcta
              ,craplct.progress_recid
              -- Efetua a quebra por conta
              ,COUNT(1) OVER (PARTITION BY craplct.nrdconta) qtdreg
              -- Para controle do FIRST-OF
              ,Row_Number() OVER (PARTITION BY craplct.nrdconta
                           ORDER BY craplct.nrdconta, craplct.progress_recid) nrseqreg
        FROM   craplct
        WHERE  craplct.cdcooper = pr_cdcooper
          AND  (craplct.cdhistor = 932 OR
                craplct.cdhistor = 1511 OR
                craplct.cdhistor = 1093);

      vr_chave VARCHAR2(100);

    BEGIN
      -- Inicializando as vari�veis
      pr_tocapsac := 0;
      pr_vlcapsac := 0;

      -- Limpando a tabela tempor�ria
      pr_tab_craplct.delete;
      pr_typ_tab_capsac.delete;
      
      -- Inicializando as vari�veis de tipo de pessoa
      FOR idx IN 1..2 LOOP
         pr_typ_tab_capsac(idx).tocapsac :=0;
         pr_typ_tab_capsac(idx).vlcapsac :=0;
      END LOOP;

      -- Abre o cursor dos lan�amentos
      FOR rw_craplct IN cr_craplct( pr_cdcooper => pr_cdcooper)
      LOOP
        -- Verifica se o associado existe
        OPEN cr_crapass( pr_cdcooper => pr_cdcooper
                        ,pr_nrdconta => rw_craplct.nrdconta);
        FETCH cr_crapass INTO rw_crapass;
        -- Verifica se o associado existe
        IF cr_crapass%FOUND THEN
          -- Gerando a chave de ordena��o do registro
          vr_chave := lpad(rw_craplct.nrdconta,10,'0')||
                      lpad(rw_craplct.progress_recid,10,'0');

          -- Alimentando a tabela tempor�ria
          pr_tab_craplct(vr_chave).nrchave := vr_chave;
          pr_tab_craplct(vr_chave).dtmvtolt := rw_craplct.dtmvtolt;
          pr_tab_craplct(vr_chave).cdagenci := rw_crapass.cdagenci; -- Agencia do associado
          pr_tab_craplct(vr_chave).cdbccxlt := rw_craplct.cdbccxlt;
          pr_tab_craplct(vr_chave).nrdolote := rw_craplct.nrdolote;
          pr_tab_craplct(vr_chave).nrdconta := rw_craplct.nrdconta;
          pr_tab_craplct(vr_chave).dspessoa := rw_crapass.dspessoa;
          pr_tab_craplct(vr_chave).nrdocmto := rw_craplct.nrdocmto;
          pr_tab_craplct(vr_chave).cdhistor := rw_craplct.cdhistor;
          pr_tab_craplct(vr_chave).nrseqdig := rw_craplct.nrseqdig;
          pr_tab_craplct(vr_chave).vllanmto := rw_craplct.vllanmto;
          pr_tab_craplct(vr_chave).nrctrpla := rw_craplct.nrctrpla;
          pr_tab_craplct(vr_chave).qtlanmfx := rw_craplct.qtlanmfx;
          pr_tab_craplct(vr_chave).nrautdoc := rw_craplct.nrautdoc;
          pr_tab_craplct(vr_chave).nrsequni := rw_craplct.nrsequni;
          pr_tab_craplct(vr_chave).cdcooper := rw_craplct.cdcooper;
          pr_tab_craplct(vr_chave).dtlibera := rw_craplct.dtlibera;
          pr_tab_craplct(vr_chave).dtcrdcta := rw_craplct.dtcrdcta;
          pr_tab_craplct(vr_chave).progress_recid := rw_craplct.progress_recid;
          pr_tab_craplct(vr_chave).nmprimtl :=  rw_crapass.nmprimtl; -- Nome do associado
          pr_tab_craplct(vr_chave).qtdreg   :=  rw_craplct.qtdreg;   -- Quantidade de registros por ag�ncia/conta
          pr_tab_craplct(vr_chave).nrseqreg :=  rw_craplct.nrseqreg; -- Sequencia do registro para a ag�ncia/conta

          --Totaliza a quantidade de saques
          pr_tocapsac := nvl(pr_tocapsac,0) + 1;
          --Totaliza o valor total dos saques
          pr_vlcapsac := nvl(pr_vlcapsac,0) + nvl(rw_craplct.vllanmto,0);
          
          -- Totalizando a quantidade e o valor total dos saques por tipo de pessoa
          pr_typ_tab_capsac(rw_crapass.inpessoa).vlcapsac := pr_typ_tab_capsac(rw_crapass.inpessoa).vlcapsac + nvl(rw_craplct.vllanmto,0);
          pr_typ_tab_capsac(rw_crapass.inpessoa).tocapsac := pr_typ_tab_capsac(rw_crapass.inpessoa).tocapsac + 1;          
        END IF;
        -- Fecha o cursor
        CLOSE cr_crapass;
      END LOOP;

    EXCEPTION
      WHEN OTHERS THEN
        -- fecha o cursor caso ele esteja aberto
        IF cr_crapass%ISOPEN THEN
          -- Fecha o cursor
          CLOSE cr_crapass;
        END IF;
        -- Retorna o erro
        pr_dscritic := 'Erro n�o tratado na pcap0001.pc_busca_procap_capital_sacado --> '||SQLERRM;
    END;
  END pc_busca_procap_capital_sacado;

  /* Procedimentos para buscar a quantidade e o valor total dos lan�amentos de cotas de capital
     integralizadas para determinada conta do associado */
  PROCEDURE pc_total_integralizado ( pr_cdcooper IN crapcop.cdcooper%TYPE -- c�digo da cooperativa
                                    ,pr_nrdconta IN NUMBER                -- n�mero da conta do associado
                                    ,pr_inpessoa OUT PLS_INTEGER           -- Tipo de pessoa
                                    ,pr_qtprocap OUT NUMBER               -- qtde de cotas integralizadas
                                    ,pr_totinteg OUT NUMBER               -- valor total das cotas integralizadas
                                    ,pr_typ_tab_integralizado OUT typ_tab_integralizado   -- listagem de lantos separados por tipo de pessoa
                                    ,pr_dscritic   OUT VARCHAR2) IS -- descri��o do erro se ocorrer
  ---------------------------------------------------------------------------------------------------------------
  --  Programa : pc_total_integralizado (Antigo: total_integralizado)
  --  Sistema  : Conta-Corrente - Cooperativa de Credito
  --  Sigla    : PCAP
  --  Autor   : Tiago
  --  Data    : Setembro/12                            Ultima alteracao: 30/08/2013
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: Sempre que chamado
  -- Objetivo  : Retornar a quantidade e o valor total dos lan�amentos de cotas de capital integralizadas
  --
  --  Altera��es: 30/08/2013 - Convers�o Progress --> Oracle PLSQL (Edison - AMcom)
  ---------------------------------------------------------------------------------------------------------------
  BEGIN
    DECLARE
      -- Seleciona os lan�amentos de cotas de capital
      CURSOR cr_craplct( pr_cdcooper IN craplct.cdcooper%TYPE
                        ,pr_nrdconta IN craplct.nrdconta%TYPE) IS
        SELECT SUM(craplct.vllanmto) totinteg
              ,COUNT(PROGRESS_RECID) qtprocap
        FROM   craplct
        WHERE  craplct.cdcooper = pr_cdcooper
          AND  craplct.nrdconta = pr_nrdconta
          AND  craplct.cdhistor = 930;

      -- Registro do cursor de lan�amentos
      rw_craplct cr_craplct%ROWTYPE;

    BEGIN
      -- Inicializando as vari�veis
      pr_qtprocap := 0;
      pr_totinteg := 0;
      pr_inpessoa := 0;
      pr_typ_tab_integralizado.delete;
      
      -- Inicializando as vari�veis de tipo de pessoa
      FOR idx IN 1..2 LOOP
         pr_typ_tab_integralizado(idx).qtprocap :=0;
         pr_typ_tab_integralizado(idx).totinteg :=0;
      END LOOP;
      
      -- Abre o cursor dos lan�amentos
      OPEN cr_craplct( pr_cdcooper => pr_cdcooper
                       ,pr_nrdconta => pr_nrdconta);
      FETCH cr_craplct INTO rw_craplct;
      -- Fecha o cursor
      CLOSE cr_craplct;
      -- Valor total integralizado pelo associado
      pr_totinteg := nvl(rw_craplct.totinteg,0);
      -- Quantidade de integraliza��es do associado
      pr_qtprocap := nvl(rw_craplct.qtprocap,0);
      
      -- Abre o cursor dos associados para verificar o tipo de pessoa
      OPEN cr_crapass( pr_cdcooper => pr_cdcooper
                      ,pr_nrdconta => pr_nrdconta);
      FETCH cr_crapass INTO rw_crapass;
      -- Fecha o cursor
      CLOSE cr_crapass;
      
      -- Guarda o tipo de pessoa
      pr_inpessoa := rw_crapass.inpessoa;
      
      -- Totalizando a quantidade e o valor integralizado pelo associado por tipo de pessoa
      pr_typ_tab_integralizado(rw_crapass.inpessoa).totinteg := nvl(rw_craplct.totinteg,0);
      pr_typ_tab_integralizado(rw_crapass.inpessoa).qtprocap := nvl(rw_craplct.qtprocap,0);

    EXCEPTION
      WHEN OTHERS THEN
        -- se o cursor estiver aberto, fecha para retornar a cr�tica
        IF cr_craplct%ISOPEN THEN
          CLOSE cr_craplct;
        END IF;
        -- se o cursor estiver aberto, fecha para retornar a cr�tica
        IF cr_crapass%ISOPEN THEN
          CLOSE cr_crapass;
        END IF;
        -- retorna a cr�tica
        pr_dscritic := 'Erro n�o tratado na pcap0001.pc_total_integralizado --> '||SQLERRM;
    END;
  END pc_total_integralizado;
  
  /*****************************************************************************
    Verificar permissao de acesso conforme departamento
   ******************************************************************************/
  PROCEDURE pc_valida_operad_depto ( pr_cdcooper IN crapcop.cdcooper%TYPE      --> c�digo da cooperativa
                                    ,pr_cdagenci IN crapage.cdagenci%TYPE      --> codigo da agencia
                                    ,pr_nrdcaixa IN NUMBER                     --> numero do caixa
                                    ,pr_cdoperad IN crapope.cdoperad%TYPE      --> Codigo do operador
                                    ,pr_nmdcampo OUT VARCHAR2                  --> Nome do campo a ser retornado
                                    ,pr_des_reto OUT VARCHAR                   --> Indicador de saida com erro (OK/NOK)
                                    ,pr_tab_erro OUT GENE0001.typ_tab_erro) IS --> Tabela com erros
  ---------------------------------------------------------------------------------------------------------------
  --  Programa : pc_valida_operad_depto       (Antigo: b1wgen0156.valida_operad_depto)
  --  Sistema  : Conta-Corrente - Cooperativa de Credito
  --  Sigla    : PCAP
  --  Autor    : Jorge I. Hamaguchi
  --  Data     : Maio/2013                             Ultima alteracao: 18/11/2014
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: Sempre que chamado
  -- Objetivo  : Verificar permissao de acesso conforme departamento
  --
  --  Altera��es: 18/11/2014 - Convers�o Progress --> Oracle PLSQL (Odirlei - AMcom)
  ---------------------------------------------------------------------------------------------------------------
    
    --------------> VARIAVEIS <---------------
    /* Tratamento de erro */
    vr_exc_erro   EXCEPTION;

    /* Descricao e codigo da critica */
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(4000);
  
    ---------------> CURSOR <-----------------
    -- Buscar informa��es do operador
    CURSOR cr_crapope (pr_cdcooper IN crapcop.cdcooper%TYPE,
                       pr_cdoperad IN crapope.cdoperad%TYPE ) IS
      SELECT dsdepart 
        FROM crapope 
       WHERE crapope.cdcooper = pr_cdcooper  
         AND crapope.cdoperad = pr_cdoperad ;
    rw_crapope cr_crapope%rowtype;
  
  BEGIN
    
    -- Buscar informa��es do operador
    OPEN cr_crapope (pr_cdcooper => pr_cdcooper,
                     pr_cdoperad =>  pr_cdoperad);
    FETCH cr_crapope INTO rw_crapope;
    
    -- caso n�o encontrar o operador
    IF cr_crapope%NOTFOUND THEN
      CLOSE cr_crapope;
      vr_cdcritic := 0;
      vr_dscritic := 'Nao foi possivel encontrar o operador.';
      pr_nmdcampo := 'cdoperad';                   
      -- gerar critica e retornar ao programa chamador
      RAISE vr_exc_erro;
    END IF;
    
    -- validar departamento
    IF rw_crapope.dsdepart not in ('TI','PRODUTOS') THEN
      vr_cdcritic := 0;
      vr_dscritic := 'Voce nao tem permissao para realizar esta acao.';
      -- gerar critica e retornar ao programa chamador
      RAISE vr_exc_erro;      
    END IF;
    
    pr_des_reto := 'OK';
    
  EXCEPTION
    WHEN vr_exc_erro THEN
    
      -- Chamar rotina de gravacao de erro
      gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => pr_cdagenci
                           ,pr_nrdcaixa => pr_nrdcaixa
                           ,pr_nrsequen => 1 --> Fixo
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic
                           ,pr_tab_erro => pr_tab_erro);
       pr_des_reto := 'NOK';
    
    WHEN OTHERS THEN
      
      vr_dscritic := 'Erro na rotina pc_valida_operad_depto: '||SQLErrm;
      -- Chamar rotina de gravacao de erro
      gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => pr_cdagenci
                           ,pr_nrdcaixa => pr_nrdcaixa
                           ,pr_nrsequen => 1 --> Fixo
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic
                           ,pr_tab_erro => pr_tab_erro);
       pr_des_reto := 'NOK';
          
  END pc_valida_operad_depto;
  
  /*****************************************************************************
    Localizar codigo do municipio conforme BNDES
   ******************************************************************************/
  PROCEDURE pc_cod_cidade_bacen_bndes (pr_cdcooper IN crapcop.cdcooper%TYPE      --> c�digo da cooperativa
                                      ,pr_cdagenci IN crapage.cdagenci%TYPE      --> codigo da agencia
                                      ,pr_nrdcaixa IN NUMBER                     --> numero do caixa
                                      ,pr_cdoperad IN crapope.cdoperad%TYPE      --> Codigo do operador
                                      ,pr_dtmvtolt IN DATE                       --> Data do movimento
                                      ,pr_cdcidbac OUT INTEGER                   --> Codigo da cidade Bacen 
                                      ,pr_cdcidbnd OUT INTEGER                   --> Codigo da cidade BNDES
                                      ,pr_nmdcampo OUT VARCHAR2                  --> Nome do campo a ser retornado
                                      ,pr_des_reto OUT VARCHAR                   --> Indicador de saida com erro (OK/NOK)
                                      ,pr_tab_erro OUT GENE0001.typ_tab_erro) IS --> Tabela com erros
  /*---------------------------------------------------------------------------------------------------------------
  --  Programa : pc_cod_cidade_bacen_bndes       (Antigo: b1wgen0156.codigo_cidade_bacen_bndes )
  --  Sistema  : Conta-Corrente - Cooperativa de Credito
  --  Sigla    : PCAP
  --  Autor    : Jorge I. Hamaguchi
  --  Data     : Maio/2013                             Ultima alteracao: 18/11/2014
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: Sempre que chamado
  -- Objetivo  : Localizar codigo do municipio conforme BNDES
  --
  --  Altera��es: 18/11/2014 - Convers�o Progress --> Oracle PLSQL (Odirlei - AMcom)
  --
  ---------------------------------------------------------------------------------------------------------------*/
    
    --------------> VARIAVEIS <---------------
    /* Tratamento de erro */
    vr_exc_erro   EXCEPTION;

    /* Descricao e codigo da critica */
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(4000);
    
    ---------------> CURSOR <-----------------
  BEGIN
    /* codigos BACEN e BNDES das cidades sedes das cooperativas */
    
    CASE 
      WHEN pr_cdcooper IN (1,2,3,4) THEN /* cooperativas de Blumenau SC */
        pr_cdcidbac := 12311;	
        pr_cdcidbnd := 4202404;
      WHEN pr_cdcooper IN (5) THEN /* cooperativa de Criciuma SC */
        pr_cdcidbac := 9379;	
        pr_cdcidbnd := 4204608;
      WHEN pr_cdcooper IN (6,7,8,9) THEN  /* cooperativas de Florianopolis SC */
        pr_cdcidbac := 21216;
        pr_cdcidbnd := 4205407;
      WHEN pr_cdcooper IN (10) THEN /* cooperativa de Lages SC */
        pr_cdcidbac := 38003;	
        pr_cdcidbnd := 4209300;
      WHEN pr_cdcooper IN (11) THEN /* cooperativa de Itajai SC */
        pr_cdcidbac := 4556;
        pr_cdcidbnd := 4208203;
      WHEN pr_cdcooper IN (12) THEN /* cooperativa de Guaramirim SC */
        pr_cdcidbac := 23025;
        pr_cdcidbnd := 4206504;
      WHEN pr_cdcooper IN (13) THEN /* cooperativa de Sao Bento do Sul SC */
        pr_cdcidbac := 14632;	
        pr_cdcidbnd := 4215802;
      WHEN pr_cdcooper IN (14) THEN /* cooperativa de Francisco Beltrao PR */
        pr_cdcidbac := 17938;	
        pr_cdcidbnd := 4108403;
      WHEN pr_cdcooper IN (15) THEN /* cooperativa de Porto Uniao SC */
        pr_cdcidbac := 3595;	
        pr_cdcidbnd := 4213609;
      WHEN pr_cdcooper IN (16) THEN /* cooperativa de Ibirama SC */
        pr_cdcidbac := 15765;	
        pr_cdcidbnd := 4206900;
    END CASE;
    
    pr_des_reto := 'OK';
  
  EXCEPTION  
    WHEN OTHERS THEN
      
      vr_dscritic := 'Erro na rotina pc_cod_cidade_bacen_bndes: '||SQLErrm;
      -- Chamar rotina de gravacao de erro
      gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => pr_cdagenci
                           ,pr_nrdcaixa => pr_nrdcaixa
                           ,pr_nrsequen => 1 --> Fixo
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic
                           ,pr_tab_erro => pr_tab_erro);
       pr_des_reto := 'NOK';   
  END pc_cod_cidade_bacen_bndes;
  
  /*****************************************************************************
    Gerar arquivo para encaminhamento ao BRDE
   ******************************************************************************/
  PROCEDURE pc_gerar_arq_enc_brde	(pr_cdcooper IN crapcop.cdcooper%TYPE      --> c�digo da cooperativa
                                  ,pr_cdagenci IN crapage.cdagenci%TYPE      --> codigo da agencia
                                  ,pr_nrdcaixa IN NUMBER                     --> numero do caixa
                                  ,pr_cdoperad IN crapope.cdoperad%TYPE      --> Codigo do operador
                                  ,pr_dtmvtolt IN DATE                       --> Data do movimento
                                  ,pr_nrdolote IN INTEGER                    --> Numero do lote
                                  ,pr_nmarquiv OUT VARCHAR2                  --> Nome do arquivo gerado
                                  ,pr_nmdcampo OUT VARCHAR2                  --> Nome do campo a ser retornado
                                  ,pr_des_reto OUT VARCHAR2                  --> Indicador de saida com erro (OK/NOK)
                                  ,pr_tab_erro OUT GENE0001.typ_tab_erro) IS --> Tabela com erros
  /*---------------------------------------------------------------------------------------------------------------
  --  Programa : pc_gerar_arq_enc_brde	       (Antigo: b1wgen0156.gerar_arq_enc_brde	 )
  --  Sistema  : Conta-Corrente - Cooperativa de Credito
  --  Sigla    : PCAP
  --  Autor    : Jorge I. Hamaguchi
  --  Data     : Maio/2013                             Ultima alteracao: 18/11/2014
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: Sempre que chamado
  -- Objetivo  : Gerar arquivo para encaminhamento ao BRDE
  --
  --  Altera��es: 18/11/2014 - Convers�o Progress --> Oracle PLSQL (Odirlei - AMcom)
  --
  --              26/02/2016 - Ajustes no layout do arquivo ao BRDE. (Jorge/Gielow) - SD 400291
  --
  ---------------------------------------------------------------------------------------------------------------*/
    --------------> TempTable <---------------
    vr_tab_avalistas typ_tab_avalistas;
    vr_tab_brde      typ_tab_brde;
    vr_tab_arq_brde  typ_tab_arq_brde;
    
    --Tabela Memoria Avalistas
    vr_tab_crapavt CADA0001.typ_tab_crapavt_58;
    --Tabela Representanes Legais
    vr_tab_crapcrl CADA0001.typ_tab_crapcrl;
    --Tabela memoria Bens
    vr_tab_bens CADA0001.typ_tab_bens;
    
    vr_tab_erro  GENE0001.typ_tab_erro;
    
    --------------> VARIAVEIS <---------------
    /* Tratamento de erro */
    vr_exc_erro   EXCEPTION;

    /* Descricao e codigo da critica */
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(4000);
    
    vr_nmcopcuf VARCHAR2(500);
    vr_dsdlinha VARCHAR2(2000);
    vr_endcoope VARCHAR2(400);
    vr_inpessoa INTEGER;
    vr_ctrcapit VARCHAR2(50);
    vr_dtnascim crapttl.dtnasttl%type;
    vr_nrcpfcgc crapttl.nrcpfcgc%type;
    vr_vlrendim NUMBER;
    vr_nmdavali crapavt.nmdavali%type;
    vr_idxbrde  VARCHAR2(10);
    vr_idxaval  VARCHAR2(15);
    vr_indxavt  INTEGER;
    vr_fldosexo VARCHAR2(10);
    vr_cdseqlin PLS_INTEGER := 0;
    vr_vltotope NUMBER := 0;
    vr_nr1conta NUMBER := 0;
    vr_nr5conta NUMBER := 0;
    vr_cdcidbac INTEGER;
    vr_cdcidbnd INTEGER;
    vr_dtpedido DATE;
    
    -- Vari�veis para armazenar as informa��es em XML
    vr_des_xml         CLOB;
    -- Vari�vel para armazenar os dados do XML antes de incluir no CLOB
    vr_texto_completo  VARCHAR2(32600);
    -- diretorio de geracao do relatorio
    vr_nom_direto      VARCHAR2(100);
    vr_nom_direto_cop  VARCHAR2(100);
    vr_nmarqind        VARCHAR2(100);
    ---------------> CURSOR <-----------------
    /* Busca dos dados da cooperativa */
    CURSOR cr_crapcop(pr_cdcooper IN craptab.cdcooper%TYPE) IS
      SELECT crapcop.cdcooper,
             crapcop.nmrescop,
             crapcop.cdufdcop,
             crapcop.nrdocnpj,
             crapcop.dsendcop,
             crapcop.nrcepend,
             crapcop.nrendcop,
             crapcop.nmbairro,
             crapcop.dtrjunta
        FROM crapcop
       WHERE crapcop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;
    
    /* Busca dos dados de lotes do procapcred. */
    CURSOR cr_craplpc(pr_cdcooper IN craptab.cdcooper%TYPE,
                      pr_nrdolote IN craplot.nrdolote%TYPE) IS
      SELECT craplpc.cdcooper,
             craplpc.dtfeclot,  
             craplpc.dtcontrt,
             craplpc.dtfincar,
             craplpc.dtpriamo,
             craplpc.dtultamo,
             craplpc.cdmunbce,
             craplpc.cdsetpro,
             craplpc.dtpricar       
        FROM craplpc
       WHERE craplpc.cdcooper = pr_cdcooper
         AND craplpc.nrdolote = pr_nrdolote
         ORDER BY cdcooper, nrdolote;
    rw_craplpc cr_craplpc%rowtype;
    
    /* Busca dos dados de itens do PROCAPCRED. */
    CURSOR cr_crapipc(pr_cdcooper IN craptab.cdcooper%TYPE,
                      pr_nrdolote IN craplot.nrdolote%TYPE) IS
      SELECT crapass.nrdconta,
             crapass.inpessoa,
             crapass.nrcpfcgc,
             crapass.nmprimtl,
             crapass.cdcooper,
             crapipc.dtvencnd,
             crapipc.cdmunben,
             crapipc.cdgenben,
             crapipc.cdporben,
             crapipc.cdsetben,
             crapipc.vlprocap,
             
             -- simular first of
             row_number() over (partition by crapipc.nrdolote 
                                order by crapipc.nrdolote, crapipc.cdcooper, crapipc.nrdconta) nrseqlot,
             count(1)     over (partition by crapipc.nrdolote 
                                order by crapipc.nrdolote) qtseqlot
        FROM crapipc
            ,crapass
       WHERE crapipc.cdcooper = pr_cdcooper
         AND crapipc.nrdolote = pr_nrdolote
         AND crapass.cdcooper = crapipc.cdcooper
         AND crapass.nrdconta = crapipc.nrdconta
       ORDER BY crapipc.nrdolote, crapipc.cdcooper, crapipc.nrdconta ;
    
    /* buscar informa��es do titular*/   
    CURSOR cr_crapttl(pr_cdcooper IN craptab.cdcooper%TYPE,
                      pr_nrdconta IN crapttl.nrdconta%TYPE) IS
      SELECT crapttl.dtnasttl
            ,crapttl.nrcpfcgc
            ,crapttl.vlsalari
            ,crapttl.vldrendi##1
            ,crapttl.vldrendi##2
            ,crapttl.vldrendi##3
            ,crapttl.vldrendi##4
            ,crapttl.vldrendi##5
            ,crapttl.vldrendi##6
            ,crapttl.nmextttl
            ,crapttl.idseqttl
            ,crapttl.nrdconta
            ,crapttl.cdcooper
            ,crapttl.cdestcvl
            ,crapttl.cdsexotl
        FROM crapttl
       WHERE crapttl.cdcooper = pr_cdcooper
         AND crapttl.nrdconta = pr_nrdconta
         AND crapttl.idseqttl = 1;
    rw_crapttl cr_crapttl%rowtype;
    
    /* buscar informa��es do titular*/   
    CURSOR cr_crabttl(pr_cdcooper IN craptab.cdcooper%TYPE,
                      pr_nrdconta IN crapttl.nrdconta%TYPE,
                      pr_nrcpfcgc IN crapttl.nrcpfcgc%TYPE) IS
      SELECT crapttl.dtnasttl
            ,crapttl.nrcpfcgc
            ,crapttl.vlsalari
            ,crapttl.vldrendi##1
            ,crapttl.vldrendi##2
            ,crapttl.vldrendi##3
            ,crapttl.vldrendi##4
            ,crapttl.vldrendi##5
            ,crapttl.vldrendi##6
            ,crapttl.nmextttl
            ,crapttl.idseqttl
            ,crapttl.nrdconta
            ,crapttl.cdcooper
            ,crapttl.cdsexotl
        FROM crapttl
       WHERE crapttl.cdcooper = pr_cdcooper
         AND (crapttl.nrdconta = pr_nrdconta or
              pr_nrdconta      = 0)
         AND (crapttl.nrcpfcgc = pr_nrcpfcgc or
              pr_nrcpfcgc      = 0);
    rw_crabttl cr_crabttl%rowtype;
    
    /* buscar informa��es do endere�o do titular */   
    CURSOR cr_crapenc(pr_cdcooper IN craptab.cdcooper%TYPE,
                      pr_nrdconta IN crapttl.nrdconta%TYPE,
                      pr_idseqttl IN crapttl.idseqttl%TYPE,
                      pr_tpendass IN crapenc.tpendass%TYPE) IS
      SELECT crapenc.nrdconta
            ,crapenc.dsendere
            ,crapenc.nrendere
            ,crapenc.complend
            ,crapenc.nmbairro
            ,crapenc.nrcepend
            ,crapenc.nmcidade
            ,crapenc.cdufende
            
        FROM crapenc
       WHERE crapenc.cdcooper = pr_cdcooper
         AND crapenc.nrdconta = pr_nrdconta
         AND crapenc.idseqttl = pr_idseqttl
         AND crapenc.tpendass = pr_tpendass; /* 10-Residencial 9-Comercial */
    rw_crapenc cr_crapenc%rowtype;
    
    /* buscar telefone do cooperado */   
    CURSOR cr_craptfc(pr_cdcooper IN craptab.cdcooper%TYPE,
                      pr_nrdconta IN crapttl.nrdconta%TYPE,
                      pr_idseqttl IN crapttl.idseqttl%TYPE) IS
      SELECT craptfc.nrdddtfc,
             craptfc.nrtelefo
        FROM craptfc
       WHERE craptfc.cdcooper = pr_cdcooper
         AND craptfc.nrdconta = pr_nrdconta
         AND craptfc.idseqttl = pr_idseqttl
       -- ordernar por tipo de telefone para pegar na ordem 
       -- 1-Resid, 2-Cel, 3-Comer e 4-Contato  
       ORDER BY craptfc.tptelefo,craptfc.cdseqtfc;
    rw_craptfc cr_craptfc%rowtype;     
    
    
    /* buscar dados do conjuge do associado */
    CURSOR cr_crapcje(pr_cdcooper IN craptab.cdcooper%TYPE,
                      pr_nrdconta IN crapttl.nrdconta%TYPE,
                      pr_idseqttl IN crapttl.idseqttl%TYPE) IS
      SELECT crapcje.nrcpfcjg
            ,crapcje.nrctacje
            ,crapcje.cdcooper
            ,crapcje.nmconjug
        FROM crapcje
       WHERE crapcje.cdcooper = pr_cdcooper
         AND crapcje.nrdconta = pr_nrdconta
         AND crapcje.idseqttl = pr_idseqttl
       ORDER BY cdcooper, nrdconta, idseqttl;
    rw_crapcje cr_crapcje%rowtype;   
    
    /* buscar dados pessoa juridica */
    CURSOR cr_crapjur(pr_cdcooper IN crapjur.cdcooper%TYPE,
                      pr_nrdconta IN crapjur.nrdconta%TYPE) IS
      SELECT crapjur.dtiniatv
        FROM crapjur
       WHERE crapjur.cdcooper = pr_cdcooper
         AND crapjur.nrdconta = pr_nrdconta;
    rw_crapjur cr_crapjur%rowtype;
    
    /* buscar dados financeiros dos cooperados pessoa juridica */
    CURSOR cr_crapjfn(pr_cdcooper IN crapjur.cdcooper%TYPE,
                      pr_nrdconta IN crapjur.nrdconta%TYPE) IS
      SELECT crapjfn.mesftbru##1
            ,crapjfn.mesftbru##2
            ,crapjfn.mesftbru##3
            ,crapjfn.mesftbru##4
            ,crapjfn.mesftbru##5
            ,crapjfn.mesftbru##6
            ,crapjfn.mesftbru##7
            ,crapjfn.mesftbru##8
            ,crapjfn.mesftbru##9
            ,crapjfn.mesftbru##10
            ,crapjfn.mesftbru##11
            ,crapjfn.mesftbru##12
            ,crapjfn.anoftbru##1
            ,crapjfn.anoftbru##2
            ,crapjfn.anoftbru##3
            ,crapjfn.anoftbru##4
            ,crapjfn.anoftbru##5
            ,crapjfn.anoftbru##6
            ,crapjfn.anoftbru##7
            ,crapjfn.anoftbru##8
            ,crapjfn.anoftbru##9
            ,crapjfn.anoftbru##10
            ,crapjfn.anoftbru##11
            ,crapjfn.anoftbru##12
            ,(  crapjfn.vlrftbru##1 +
                crapjfn.vlrftbru##2 +
                crapjfn.vlrftbru##3 +
                crapjfn.vlrftbru##4 +
                crapjfn.vlrftbru##5 +
                crapjfn.vlrftbru##6 +
                crapjfn.vlrftbru##7 +
                crapjfn.vlrftbru##8 +
                crapjfn.vlrftbru##9 +
                crapjfn.vlrftbru##10 +
                crapjfn.vlrftbru##11 +
                crapjfn.vlrftbru##12 ) vlrendim
            ,crapjfn.cdopejfn##1
            ,crapjfn.cdopejfn##2
            ,crapjfn.cdopejfn##3
            ,crapjfn.cdopejfn##4
            ,crapjfn.cdopejfn##5
            ,crapjfn.dtaltjfn##1
            ,crapjfn.dtaltjfn##2
            ,crapjfn.dtaltjfn##3
            ,crapjfn.dtaltjfn##4
            ,crapjfn.dtaltjfn##5
        FROM crapjfn
       WHERE crapjfn.cdcooper = pr_cdcooper
         AND crapjfn.nrdconta = pr_nrdconta;
    rw_crapjfn cr_crapjfn%ROWTYPE;
    
    
    /* buscar dados Avalistas de operacoes procapcred. */
    CURSOR cr_crapapc(pr_cdcooper IN crapapc.cdcooper%TYPE,
                      pr_nrdconta IN crapapc.nrdolote%TYPE,
                      pr_nrdolote IN crapapc.nrdconta%TYPE) IS
      SELECT crapapc.cdcooper,
             crapapc.nrdconta,
             crapapc.nrcpfrep,
             crapapc.nrctarep
        FROM crapapc
       WHERE crapapc.cdcooper = pr_cdcooper
         AND crapapc.nrdolote = pr_nrdolote
         AND crapapc.nrdconta = pr_nrdconta;
         
    /* buscar dados avalistas terceiro */
    CURSOR cr_crapavt(pr_cdcooper IN crapavt.cdcooper%TYPE,
                      pr_nrdconta IN crapavt.nrdconta%TYPE,
                      pr_tpctrato IN crapavt.tpctrato%TYPE,
                      pr_nrcpfrep IN crapavt.nrcpfcgc%TYPE) IS
      SELECT crapavt.cdcooper
            ,crapavt.nrdconta
            ,crapavt.nrcpfcgc
            ,crapavt.nmdavali
            ,crapavt.cdsexcto
            ,crapavt.dsendres##1
            ,crapavt.nrendere
            ,crapavt.nmbairro
            ,crapavt.nmcidade 
            ,crapavt.nrcepend
        FROM crapavt
       WHERE crapavt.cdcooper = pr_cdcooper
         AND crapavt.tpctrato = pr_tpctrato
         AND crapavt.nrdconta = pr_nrdconta
         AND crapavt.nrcpfcgc = pr_nrcpfrep
       ORDER BY cdcooper, tpctrato, nrdconta, nrctremp, nrcpfcgc;
      rw_crapavt cr_crapavt%rowtype;
    
    
    --------------------------- SUBROTINAS INTERNAS --------------------------
    -- Subrotina para escrever texto na vari�vel CLOB do XML
    PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2,
                             pr_fecha_xml IN BOOLEAN DEFAULT FALSE) IS
    BEGIN
      gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo, pr_des_dados, pr_fecha_xml);
    END;
         
  BEGIN
    
    --Verificar permissao de acesso conforme departamento
    pc_valida_operad_depto(pr_cdcooper => pr_cdcooper      --> c�digo da cooperativa
                          ,pr_cdagenci => pr_cdagenci      --> codigo da agencia
                          ,pr_nrdcaixa => pr_nrdcaixa      --> numero do caixa
                          ,pr_cdoperad => pr_cdoperad      --> Codigo do operador
                          ,pr_nmdcampo => pr_nmdcampo      --> Nome do campo a ser retornado
                          ,pr_des_reto => pr_des_reto      --> Indicador de saida com erro (OK/NOK)
                          ,pr_tab_erro => pr_tab_erro);    --> Tabela com erros
                          
    -- se retornou com erro da rotina, deve abortar programa
    IF pr_des_reto = 'NOK' THEN
      RETURN;
    END IF;
    
    --Verificar se a cooperativa existe
    OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
    FETCH cr_crapcop INTO rw_crapcop;
    --Se nao encontrou
    IF cr_crapcop%NOTFOUND THEN
      --Fechar Cursor
      CLOSE cr_crapcop; 
      vr_cdcritic := 0;
      vr_dscritic := 'Problema ao consultar dados da Cooperativa.';               
      -- gerar critica e retornar ao programa chamador
      RAISE vr_exc_erro;              
    END IF;
    CLOSE cr_crapcop;
    
    -- Busca dos dados de lotes do procapcred. 
    OPEN cr_craplpc(pr_cdcooper => pr_cdcooper,
                    pr_nrdolote => pr_nrdolote);
    FETCH cr_craplpc INTO rw_craplpc;
    --Se encontrou
    IF cr_craplpc%FOUND THEN
      close cr_craplpc; 
      
      IF rw_craplpc.dtfeclot IS NULL THEN
        vr_dscritic := 'O Lote '|| pr_nrdolote ||'nao esta fechado.';
        vr_cdcritic := 0;
        pr_nmdcampo := 'nrdolote';
        -- gerar critica e retornar ao programa chamador
        RAISE vr_exc_erro; 
      END IF;
      
    ELSE
      close cr_craplpc; 
      vr_cdcritic := 0;
      vr_dscritic := 'Lote nao existe.';
      pr_nmdcampo := 'nrdolote';
      -- gerar critica e retornar ao programa chamador
      RAISE vr_exc_erro;  
    END IF;
    
    vr_nmcopcuf := rw_crapcop.nmrescop ||'-'|| rw_crapcop.cdufdcop;
    
    FOR rw_crapipc in cr_crapipc(pr_cdcooper => pr_cdcooper,
                                 pr_nrdolote => pr_nrdolote) LOOP
                                 
      vr_tab_avalistas.delete;
      vr_dsdlinha := null;
      vr_vlrendim := 0;
      
      -- Tratamento para pessoa fisica
      IF rw_crapipc.inpessoa = 1 THEN
        vr_inpessoa := 1;
        vr_ctrcapit := ' ';
        -- Buscar inf. do titular 
        OPEN cr_crapttl(pr_cdcooper => pr_cdcooper,
                        pr_nrdconta => rw_crapipc.nrdconta);
        FETCH cr_crapttl INTO rw_crapttl;
        --quando encontrar
        IF cr_crapttl%FOUND THEN
          CLOSE cr_crapttl;
          
          vr_dtnascim := rw_crapttl.dtnasttl;
          vr_nrcpfcgc := rw_crapttl.nrcpfcgc;
          vr_vlrendim := rw_crapttl.vlsalari  +
                         (rw_crapttl.vldrendi##1 +
                          rw_crapttl.vldrendi##2 +
                          rw_crapttl.vldrendi##3 +
                          rw_crapttl.vldrendi##4 +
                          rw_crapttl.vldrendi##5 +
                          rw_crapttl.vldrendi##6);
          -- definir index
          vr_idxbrde := lpad(rw_crapipc.nrdconta,10,0);
          -- criar registro na temptable
          vr_tab_brde(vr_idxbrde).nrdconta := rw_crapttl.nrdconta;
          vr_tab_brde(vr_idxbrde).nmextttl := rw_crapttl.nmextttl;
          vr_tab_brde(vr_idxbrde).dtnasttl := rw_crapttl.dtnasttl;
          vr_tab_brde(vr_idxbrde).vlsalari := rw_crapttl.vlsalari;
          vr_tab_brde(vr_idxbrde).dtrefere := null;
          vr_tab_brde(vr_idxbrde).nrcpfcgc := rw_crapttl.nrcpfcgc;
          
          -- Buscar inf. do endere�o do titular 
          OPEN cr_crapenc(pr_cdcooper => rw_crapttl.cdcooper,
                          pr_nrdconta => rw_crapttl.nrdconta,
                          pr_idseqttl => rw_crapttl.idseqttl,
                          pr_tpendass => 10 /* residencial*/);
          FETCH cr_crapenc INTO rw_crapenc;
          --quando encontrar
          IF cr_crapenc%FOUND THEN
            CLOSE cr_crapenc;
            
            vr_tab_brde(vr_idxbrde).dsendere := rw_crapenc.dsendere;
            vr_tab_brde(vr_idxbrde).nrendere := rw_crapenc.nrendere;
            vr_tab_brde(vr_idxbrde).compleme := rw_crapenc.complend;
            vr_tab_brde(vr_idxbrde).nmbairro := rw_crapenc.nmbairro;
            vr_tab_brde(vr_idxbrde).nrcepend := rw_crapenc.nrcepend;
            vr_tab_brde(vr_idxbrde).nmcidade := rw_crapenc.nmcidade;
            vr_tab_brde(vr_idxbrde).cdufende := rw_crapenc.cdufende;

          ELSE
            CLOSE cr_crapenc;
            vr_cdcritic := 0;
            vr_dscritic := 'Endereco nao encontrado.';
            pr_nmdcampo := null;
            -- gerar critica e retornar ao programa chamador
            RAISE vr_exc_erro;
      
          END IF; -- Fim IF cr_crapenc
          
          -- Buscar inf. do telefone do titular 
          OPEN cr_craptfc(pr_cdcooper => rw_crapttl.cdcooper,
                          pr_nrdconta => rw_crapttl.nrdconta,
                          pr_idseqttl => rw_crapttl.idseqttl);
          FETCH cr_craptfc INTO rw_craptfc;
          --quando encontrar
          IF cr_craptfc%FOUND THEN
            CLOSE cr_craptfc;
            vr_tab_brde(vr_idxbrde).nrdddtfc := rw_craptfc.nrdddtfc;
            vr_tab_brde(vr_idxbrde).nrtelefo := rw_craptfc.nrtelefo;
          ELSE
            CLOSE cr_craptfc;
          END IF;  
          
          vr_fldosexo := NULL;
          
          /* se tiver estado civil casado */
          IF rw_crapttl.cdestcvl in (2,3,4,8,9,11,12) THEN
            -- Buscar inf. do telefone do titular 
            OPEN cr_crapcje(pr_cdcooper => rw_crapttl.cdcooper,
                            pr_nrdconta => rw_crapttl.nrdconta,
                            pr_idseqttl => rw_crapttl.idseqttl);
            FETCH cr_crapcje INTO rw_crapcje;
            --quando encontrar
            IF cr_crapcje%FOUND THEN
              CLOSE cr_crapcje;
                               
              /* se conjuge nao tiver conta */
              IF rw_crapcje.nrctacje = 0 AND 
                 rw_crapcje.nrcpfcjg = 0 THEN
                vr_cdcritic := 0;
                vr_dscritic := 'CPF do conjuge invalido -> Conta = '|| 
                                gene0002.fn_mask_conta(rw_crapipc.nrdconta) ||'.';
                pr_nmdcampo := NULL;
                -- gerar critica e retornar ao programa chamador
                RAISE vr_exc_erro;
              ELSE
                -- Buscar inf. do cta titular do conjuge
                OPEN cr_crabttl(pr_cdcooper => rw_crapcje.cdcooper,
                                pr_nrdconta => rw_crapcje.nrctacje,
                                pr_nrcpfcgc => rw_crapcje.nrcpfcjg);
                FETCH cr_crabttl INTO rw_crabttl;
                --quando encontrar
                IF cr_crabttl%FOUND THEN
                  CLOSE cr_crabttl;
                  IF rw_crabttl.cdsexotl = 1 THEN
                    vr_fldosexo := 'M';
                  ELSE
                    vr_fldosexo := 'F';
                  END IF;  
                  
                  /* avalistas */
                  vr_idxaval := LPAD(rw_crabttl.nrcpfcgc,15,'0');
                  
                  vr_tab_avalistas(vr_idxaval).nmdavali := rw_crabttl.nmextttl;
                  vr_tab_avalistas(vr_idxaval).cddosexo := vr_fldosexo;
                  vr_tab_avalistas(vr_idxaval).nrcpfcgc := rw_crabttl.nrcpfcgc;
                  
                  rw_crapenc := null;
                  -- Buscar inf. do endere�o do conjuge
                  OPEN cr_crapenc(pr_cdcooper => rw_crabttl.cdcooper,
                                  pr_nrdconta => rw_crabttl.nrdconta,
                                  pr_idseqttl => rw_crabttl.idseqttl,
                                  pr_tpendass => 10 /*residencial*/ );
                  FETCH cr_crapenc INTO rw_crapenc;
                  --quando encontrar
                  IF cr_crapenc%FOUND THEN
                    CLOSE cr_crapenc;
                    -- usar endere�o do conjuge
                    vr_tab_avalistas(vr_idxaval).dsendere := UPPER( rw_crapenc.dsendere 
                                                            ||' '||rw_crapenc.nrendere
                                                            ||' '|| rw_crapenc.nmbairro
                                                            ||' '|| rw_crapenc.nmcidade);
                    vr_tab_avalistas(vr_idxaval).nrcepend := rw_crapenc.nrcepend;
                    
                  ELSE
                    CLOSE cr_crapenc;
                    -- senao usar a endere�o do titular principal
                    vr_tab_avalistas(vr_idxaval).dsendere := UPPER(vr_tab_brde(vr_idxbrde).dsendere 
                                                             ||' '|| vr_tab_brde(vr_idxbrde).nrendere
                                                             ||' '|| vr_tab_brde(vr_idxbrde).nmbairro
                                                             ||' '|| vr_tab_brde(vr_idxbrde).nmcidade);
                    vr_tab_avalistas(vr_idxaval).nrcepend := vr_tab_brde(vr_idxbrde).nrcepend;
                    
                  END IF;  
                  
                ELSE
                  CLOSE cr_crabttl;
                  -- se n�o localizou titular do conjuge criar com as informa��es da cta principal
                  IF rw_crapcje.nrcpfcjg <> 0 THEN 
                    
                    /* avalistas */
                    vr_idxaval := lpad(rw_crapcje.nrcpfcjg,15,0);
                  
                    -- atribuir nome
                    IF LENGTH(TRIM(rw_crapcje.nmconjug)) <> 0 THEN 
                      vr_tab_avalistas(vr_idxaval).nmdavali := rw_crapcje.nmconjug;
                    ELSE 
                      vr_tab_avalistas(vr_idxaval).nmdavali := 'A';
                    END IF;
                      
                    vr_tab_avalistas(vr_idxaval).nrcpfcgc := rw_crapcje.nrcpfcjg;
                    vr_tab_avalistas(vr_idxaval).dsendere := UPPER(vr_tab_brde(vr_idxbrde).dsendere 
                                                             ||' '|| vr_tab_brde(vr_idxbrde).nrendere
                                                             ||' '|| vr_tab_brde(vr_idxbrde).nmbairro
                                                             ||' '|| vr_tab_brde(vr_idxbrde).nmcidade);
                    vr_tab_avalistas(vr_idxaval).nrcepend := vr_tab_brde(vr_idxbrde).nrcepend;
                    
                    vr_tab_avalistas(vr_idxaval).cddosexo := (CASE rw_crapttl.cdsexotl 
                                                               WHEN  1 THEN 'F' 
                                                               ELSE 'M'
                                                               END); 
                    /*contrario do titular */
                  
                  END IF;                  
                END IF; -- Fim IF cr_crabttl
              END IF; -- Fim IF crapcje.nrctacje
            ELSE
              CLOSE cr_crapcje;
            END IF; -- Fim IF crapcje
          END IF; -- Fim if casado 
        ELSE
          CLOSE cr_crapttl;
          vr_cdcritic := 0;
          vr_dscritic := 'Problema ao consultar dados do Titular.';
          -- gerar critica e retornar ao programa chamador
          RAISE vr_exc_erro;
          
        END IF; -- Fim IF cr_crapttl 
      
      ELSE
        /* Pessoa Juridica */
        vr_inpessoa := 2;
        vr_nrcpfcgc := rw_crapipc.nrcpfcgc;
        vr_ctrcapit := 'N';
        
        -- Buscar dados pessoa juridica
        OPEN cr_crapjur(pr_cdcooper => pr_cdcooper,
                        pr_nrdconta => rw_crapipc.nrdconta);
        FETCH cr_crapjur INTO rw_crapjur;
        --quando encontrar
        IF cr_crapjur%FOUND THEN
          CLOSE cr_crapjur;
          
          vr_dtnascim := rw_crapjur.dtiniatv;
          
          rw_crapjfn  := NULL;
          -- Buscar dados financeiros de pessoa juridica
          OPEN cr_crapjfn(pr_cdcooper => pr_cdcooper,
                          pr_nrdconta => rw_crapipc.nrdconta);
          FETCH cr_crapjfn INTO rw_crapjfn;
          CLOSE cr_crapjfn;
          
          vr_vlrendim := rw_crapjfn.vlrendim;
            
          -- definir index
          vr_idxbrde := lpad(rw_crapipc.nrdconta,10,0);
          -- criar registro na temptable
          vr_tab_brde(vr_idxbrde).nrdconta := rw_crapipc.nrdconta;
          vr_tab_brde(vr_idxbrde).nmextttl := rw_crapipc.nmprimtl;
          vr_tab_brde(vr_idxbrde).nrcpfcgc := rw_crapipc.nrcpfcgc;
            
          -- Buscar inf. do endere�o do titular 
          OPEN cr_crapenc(pr_cdcooper => rw_crapipc.cdcooper,
                          pr_nrdconta => rw_crapipc.nrdconta,
                          pr_idseqttl => 1,
                          pr_tpendass => 9 /* Comercial */ );
          FETCH cr_crapenc INTO rw_crapenc;
          --quando encontrar
          IF cr_crapenc%FOUND THEN
            CLOSE cr_crapenc;
              
            vr_tab_brde(vr_idxbrde).dsendere := rw_crapenc.dsendere;
            vr_tab_brde(vr_idxbrde).nrendere := rw_crapenc.nrendere;
            vr_tab_brde(vr_idxbrde).compleme := rw_crapenc.complend;
            vr_tab_brde(vr_idxbrde).nmbairro := rw_crapenc.nmbairro;
            vr_tab_brde(vr_idxbrde).nrcepend := rw_crapenc.nrcepend;
            vr_tab_brde(vr_idxbrde).nmcidade := rw_crapenc.nmcidade;
            vr_tab_brde(vr_idxbrde).cdufende := rw_crapenc.cdufende;

          ELSE
            CLOSE cr_crapenc;        
          END IF; -- Fim IF cr_crapenc              
            
          -- Buscar inf. do telefone do titular 
          OPEN cr_craptfc(pr_cdcooper => rw_crapipc.cdcooper,
                          pr_nrdconta => rw_crapipc.nrdconta,
                          pr_idseqttl => 1);
          FETCH cr_craptfc INTO rw_craptfc;
          --quando encontrar
          IF cr_craptfc%FOUND THEN
            CLOSE cr_craptfc;
            vr_tab_brde(vr_idxbrde).nrdddtfc := rw_craptfc.nrdddtfc;
            vr_tab_brde(vr_idxbrde).nrtelefo := rw_craptfc.nrtelefo;
          ELSE
            CLOSE cr_craptfc;
          END IF; 
            
          /* Avalistas */
          FOR rw_crapapc IN cr_crapapc(pr_cdcooper => pr_cdcooper,
                                       pr_nrdconta => rw_crapipc.nrdconta,
                                       pr_nrdolote => pr_nrdolote) LOOP
                                         
            /* buscar dados avalistas terceiro */
            OPEN cr_crapavt ( pr_cdcooper => rw_crapapc.cdcooper,
                              pr_nrdconta => rw_crapapc.nrdconta,
                              pr_tpctrato =>  6,
                              pr_nrcpfrep => rw_crapapc.nrcpfrep);
            FETCH cr_crapavt into rw_crapavt;
            IF cr_crapavt%NOTFOUND THEN
              CLOSE cr_crapavt;
              vr_cdcritic := 0;
              vr_dscritic := 'Problema ao consultar dados do Avalista.';
              -- gerar critica e retornar ao programa chamador
              RAISE vr_exc_erro;
            END IF;
            CLOSE cr_crapavt;
              
            IF rw_crapapc.nrctarep = 0 THEN
              /* avalistas */
              vr_idxaval := LPAD(rw_crapapc.nrcpfrep,15,'0');
                
              vr_tab_avalistas(vr_idxaval).nrcpfcgc := rw_crapapc.nrcpfrep;
              vr_tab_avalistas(vr_idxaval).nrdctato := rw_crapapc.nrctarep;
              vr_tab_avalistas(vr_idxaval).nmdavali := rw_crapavt.nmdavali;
              vr_tab_avalistas(vr_idxaval).cddosexo := (CASE rw_crapavt.cdsexcto 
                                                         WHEN  1 THEN 'M' 
                                                         ELSE 'F'
                                                         END); 
                                                               
              vr_tab_avalistas(vr_idxaval).dsendere := UPPER(rw_crapavt.dsendres##1
                                                             ||' '|| rw_crapavt.nrendere
                                                             ||' '|| rw_crapavt.nmbairro
                                                             ||' '|| rw_crapavt.nmcidade);
              vr_tab_avalistas(vr_idxaval).nrcepend := rw_crapavt.nrcepend;
              vr_tab_avalistas(vr_idxaval).flgcheck := FALSE;
  
            ELSE /* caso o avalista tenha conta na coop. */
              /* Buscar dados dos representantes/procuradores */
              CADA0001.pc_busca_dados_58 (pr_cdcooper => pr_cdcooper        --Codigo Cooperativa
                                         ,pr_cdagenci => 0                  --Codigo Agencia
                                         ,pr_nrdcaixa => 0                  --Numero Caixa
                                         ,pr_cdoperad => pr_cdoperad        --Codigo Operador
                                         ,pr_nmdatela => 'LOTPRC'           --Nome Tela
                                         ,pr_idorigem => 1                  --Origem da chamada
                                         ,pr_nrdconta => rw_crapipc.nrdconta   --Numero da Conta
                                         ,pr_idseqttl => 0                  --Sequencial Titular
                                         ,pr_flgerlog => TRUE               --Erro no Log
                                         ,pr_cddopcao => 'C'                --Codigo opcao
                                         ,pr_nrdctato => rw_crapapc.nrctarep--Numero Contato
                                         ,pr_nrcpfcto => rw_crapapc.nrcpfrep--Numero Cpf Contato
                                         ,pr_nrdrowid => NULL               --Rowid Empresa participante
                                         ,pr_tab_crapavt => vr_tab_crapavt  --Tabela Avalistas
                                         ,pr_tab_bens => vr_tab_bens        --Tabela bens
                                         ,pr_tab_erro => vr_tab_erro        --Tabela Erro
                                         ,pr_cdcritic => vr_cdcritic        --Codigo de erro
                                         ,pr_dscritic => vr_dscritic);      --Retorno de Erro
                
              --Se ocorreu erro
              IF nvl(vr_cdcritic,0) <> 0 OR 
                 TRIM(vr_dscritic) IS NOT NULL THEN                  
                --Levantar Excecao
                RAISE vr_exc_erro;
              END IF;
                
              --Se Encontrou Procurador
              vr_indxavt := vr_tab_crapavt.FIRST;
                
              IF vr_indxavt IS NULL THEN
                vr_cdcritic := 0;
                vr_dscritic := 'Problema ao consultar dados do Avalista.';
                --Levantar Excecao
                RAISE vr_exc_erro;
              END IF;
                
              vr_nmdavali := vr_tab_crapavt(vr_indxavt).nmdavali;
                
              -- avalistas 
              vr_idxaval := LPAD(vr_tab_crapavt(vr_indxavt).nrcpfcgc,15,'0');
                
              vr_tab_avalistas(vr_idxaval).nrcpfcgc := vr_tab_crapavt(vr_indxavt).nrcpfcgc;
              vr_tab_avalistas(vr_idxaval).nrdctato := vr_tab_crapavt(vr_indxavt).nrdctato;
              vr_tab_avalistas(vr_idxaval).nmdavali := vr_nmdavali;
              vr_tab_avalistas(vr_idxaval).cddosexo := (CASE vr_tab_crapavt(vr_indxavt).cdsexcto 
                                                         WHEN  1 THEN 'M' 
                                                         ELSE 'F'
                                                         END); 
                                                               
              vr_tab_avalistas(vr_idxaval).dsendere := UPPER(vr_tab_crapavt(vr_indxavt).dsendres(1)
                                                             ||' '|| vr_tab_crapavt(vr_indxavt).nrendere
                                                             ||' '|| vr_tab_crapavt(vr_indxavt).nmbairro
                                                             ||' '|| vr_tab_crapavt(vr_indxavt).nmcidade);
              vr_tab_avalistas(vr_idxaval).nrcepend := vr_tab_crapavt(vr_indxavt).nrcepend;
              vr_tab_avalistas(vr_idxaval).flgcheck := FALSE;
                
               
            END IF; -- Fim  if crapapc.nrctarep <> 0
          END LOOP;  -- Fim FOR rw_crapapc                           
        ELSE
          CLOSE cr_crapjur;
          vr_cdcritic := 0;
          vr_dscritic := 'Problema ao consultar dados do Titular.';
          --Levantar Excecao
          RAISE vr_exc_erro;          
        END IF;  -- Fim crapjur
      END IF; -- Fim IF inpessoa
      
      -- Simular First-of
      IF rw_crapipc.nrseqlot = 1 THEN
        vr_cdseqlin := 1;
        
        /******** HEADER DO ARQUIVO ************/
        vr_dsdlinha := '0'||                               /* Tipo de registro */
                    to_char(rw_crapcop.nrdocnpj, 'fm00000000000000' )||
                    LPAD(' ',12,' ')                               ||
                    to_char(pr_dtmvtolt,'RRRRMMDD')                ||
                    LPAD(' ',560,' ')                              ||
                    LPAD(vr_cdseqlin,5,'0');
                    
        -- incluir linha do arquivo
        vr_tab_arq_brde(vr_cdseqlin).cdseqlin := vr_cdseqlin;
        vr_tab_arq_brde(vr_cdseqlin).dsdlinha := vr_dsdlinha;
        
        vr_cdseqlin := vr_cdseqlin + 1;
        vr_vltotope := 0;
      END IF;
      
      vr_idxbrde := lpad(rw_crapipc.nrdconta,10,'0');
      
      IF vr_idxbrde is null THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Problema ao consultar dados cadastrais.';
        -- gerar critica e abortar
        raise vr_exc_erro;                              
      END IF;
      
      /*************** TIPO 1 - DADOS CADASTRAIS *****************/
      vr_dsdlinha := '1'                                                    ||  
                      TO_CHAR(rw_crapcop.nrdocnpj, 'fm00000000000000')      ||
                      '999999'                                              ||
                      RPAD(rw_crapipc.nmprimtl,30,' ')                      ||
                      vr_inpessoa                                           ||
                      NVL(TO_CHAR(rw_crapipc.dtvencnd,'RRRRMMDD')
                          ,LPAD(' ',8,' '))                                 ||
                      LPAD(' ',6,' ')                                       ||
                      TO_CHAR(vr_dtnascim,'RRRRMMDD')                       ||
                      TO_CHAR(vr_vlrendim * 100,'fm00000000000000000')      ||
                      (TO_CHAR(pr_dtmvtolt,'RRRR') - 1) || '1231'          ||
                      'E'                                                   ||
                      LPAD(' ',18,' ')                                      ||
                      TO_CHAR(vr_nrcpfcgc, 'fm00000000000000')              ||
                      LPAD(' ',60,' ')                                      ||
                      RPAD(vr_tab_brde(vr_idxbrde).dsendere,'35',' ')       ||
                      to_char(vr_tab_brde(vr_idxbrde).nrcepend,'fm00000000')||
                      TO_CHAR(rw_crapipc.cdmunben,'fm0000000')              ||
                      LPAD(' ',25,' ')                                      ||
                      TO_CHAR(vr_tab_brde(vr_idxbrde).nrdddtfc,'fm00')      ||
                      TO_CHAR(vr_tab_brde(vr_idxbrde).nrtelefo,'fm00000000')||
                      LPAD(' ',4,' ')                                       ||
                      TO_CHAR(rw_crapipc.cdgenben,'fm000')                     ||
                      TO_CHAR(rw_crapipc.cdporben,'fm00')                      ||
                      TO_CHAR(rw_crapipc.cdsetben,'fm0000000')                 ||
                      LPAD(' ',302,' ')                                     ||
                      TO_CHAR(vr_cdseqlin,'fm00000');
                      
      -- incluir linha do arquivo
      vr_tab_arq_brde(vr_cdseqlin).cdseqlin := vr_cdseqlin;
      vr_tab_arq_brde(vr_cdseqlin).dsdlinha := vr_dsdlinha;

      vr_cdseqlin := vr_cdseqlin + 1;
      vr_nr1conta := vr_nr1conta + 1;
      
      /*************** TIPO 4 - Avalistas *****************/
      vr_idxaval := vr_tab_avalistas.first;
      -- ler avalistas
      WHILE vr_idxaval IS NOT NULL LOOP
        vr_dsdlinha :=  '4'                                                            ||  
                        TO_CHAR(rw_crapcop.nrdocnpj, 'fm00000000000000')               ||
                        TO_CHAR(vr_nrcpfcgc,'fm00000000000000')                        ||
                        RPAD(vr_tab_avalistas(vr_idxaval).nmdavali,35,' ')             ||
                        vr_tab_avalistas(vr_idxaval).cddosexo                          ||
                        TO_CHAR(vr_tab_avalistas(vr_idxaval).nrcpfcgc,'fm00000000000') ||
                        LPAD(' ',20,' ')                                               ||
                        RPAD(vr_tab_avalistas(vr_idxaval).dsendere,35,' ')             ||
                        TO_CHAR(vr_tab_avalistas(vr_idxaval).nrcepend,'fm00000000')    ||
                        LPAD(' ',32,' ')                                               ||
                        LPAD(' ',2,' ')                                                ||
                        LPAD(' ',8,' ')                                                ||
                        LPAD(' ',414,' ')                                              ||
                        TO_CHAR(vr_cdseqlin,'fm00000');
      
        -- incluir linha do arquivo
        vr_tab_arq_brde(vr_cdseqlin).cdseqlin := vr_cdseqlin;
        vr_tab_arq_brde(vr_cdseqlin).dsdlinha := vr_dsdlinha;

        vr_cdseqlin := vr_cdseqlin + 1;
        
        vr_idxaval := vr_tab_avalistas.next(vr_idxaval);
      END LOOP;
      
      /*************** TIPO 5 - Operacao *****************/
      
      -- Data do pedido de financiamento 
      vr_dtpedido := gene0005.fn_valida_dia_util(pr_cdcooper  => pr_cdcooper,
                                                 pr_dtmvtolt  => (rw_craplpc.dtcontrt - 30),
                                                 pr_tipo      => 'A',
                                                 pr_feriado   => TRUE,
                                                 pr_excultdia => FALSE);                                     
      
      vr_dsdlinha :=  '5'                                                  ||
                      TO_CHAR(rw_crapcop.nrdocnpj, 'fm00000000000000')     ||
                      TO_CHAR(vr_nrcpfcgc,'fm00000000000000')              ||
                      LPAD(' ',2,' ')                                      ||
                      TO_CHAR(rw_craplpc.dtcontrt,'RRRRMMDD')              || 
                      '155'                                                || 
                      'M'                                                  ||
                      TO_CHAR(rw_craplpc.dtfincar,'RRRRMMDD')              || 
                      TO_CHAR(rw_craplpc.dtpriamo,'RRRRMMDD')              || 
                      TO_CHAR(rw_craplpc.dtultamo,'RRRRMMDD')              || 
                      TO_CHAR(rw_crapipc.cdmunben,'fm0000000')             ||
                      TO_CHAR(rw_craplpc.cdmunbce,'fm000000')              ||
                      TO_CHAR(rw_crapipc.vlprocap * 100,'fm00000000000000000') ||
                      '001'                                                ||
                      LPAD(' ', 8,' ')                                     ||
                      LPAD('0',11,'0')                                     ||
                      LPAD(' ',11,' ')                                     ||
                      LPAD(' ', 4,' ')                                     ||
                      LPAD(' ', 1,' ')                                     ||
                      'I'                                                  ||
                      LPAD(' ',14,' ')                                     ||
                      LPAD(' ', 3,' ')                                     ||
                      LPAD(' ', 6,' ')                                     ||
                      LPAD(' ',15,' ')                                     ||
                      LPAD(' ',14,' ')                                     ||
                      LPAD(' ', 1,' ')                                     ||
                      RPAD(rw_crapcop.dsendcop,35,' ')                     ||
                      TO_CHAR(rw_crapcop.nrcepend,'fm00000000')            ||
                      TO_CHAR(vr_tab_brde(vr_idxbrde).nrdconta,'fm00000000000000000000') ||
                      LPAD(' ', 5,' ')                                     ||
                      LPAD(' ', 1,' ')                                     ||
                      LPAD(' ', 8,' ')                                     ||
                      LPAD(' ',10,' ')                                     ||
                      LPAD(' ', 2,' ')                                     ||
                      LPAD(' ', 4,' ')                                     ||
                      'N'                                                  ||
                      'N'                                                  || 
                      LPAD('0', 5,'0')                                     ||
                      LPAD('0', 5,'0')                                     ||
                      LPAD(' ', 1,' ')                                     ||
                      LPAD(' ',15,' ')                                     ||
                      LPAD(' ', 2,' ')                                     ||
                      LPAD(' ', 8,' ')                                     ||
                      LPAD(' ', 8,' ')                                     ||
                      LPAD(' ',50,' ')                                     ||
                      LPAD(' ', 2,' ')                                     ||
                      LPAD(' ',100,' ')                                    ||
                      LPAD(' ',10,' ')                                     ||
                      TO_CHAR(rw_craplpc.cdsetpro,'fm0000000')             ||
                      'CCB'                                                ||
                      LPAD(' ',14,' ')                                     ||
                      LPAD(' ',14,' ')                                     ||
                      LPAD(' ', 1,' ')                                     ||
                      LPAD(' ', 1,' ')                                     ||
                      LPAD(' ', 5,' ')                                     ||
                      LPAD(' ', 3,' ')                                     ||
                      LPAD(' ',17,' ')                                     ||
                      TO_CHAR(vr_dtpedido,'RRRRMMDD')                      ||
                      'N'                                                  ||
                      TO_CHAR(rw_craplpc.dtpricar,'RRRRMMDD')              ||
                      LPAD(' ',23,' ')                                     ||
                      TO_CHAR(vr_cdseqlin,'fm00000');
      
      -- incluir linha do arquivo
      vr_tab_arq_brde(vr_cdseqlin).cdseqlin := vr_cdseqlin;
      vr_tab_arq_brde(vr_cdseqlin).dsdlinha := vr_dsdlinha;

      vr_cdseqlin := vr_cdseqlin + 1;    
      vr_nr5conta := vr_nr5conta + 1;
      vr_vltotope := vr_vltotope + rw_crapipc.vlprocap;
      
      /*************** TIPO 7 - Complemento *****************/
      
      -- Localizar codigo do municipio conforme BNDES
      pc_cod_cidade_bacen_bndes (pr_cdcooper => pr_cdcooper     --> c�digo da cooperativa
                                ,pr_cdagenci => pr_cdagenci     --> codigo da agencia
                                ,pr_nrdcaixa => pr_nrdcaixa     --> numero do caixa
                                ,pr_cdoperad => pr_cdoperad     --> Codigo do operador
                                ,pr_dtmvtolt => pr_dtmvtolt     --> Data do movimento
                                ,pr_cdcidbac => vr_cdcidbac     --> Codigo da cidade Bacen 
                                ,pr_cdcidbnd => vr_cdcidbnd     --> Codigo da cidade BNDES
                                ,pr_nmdcampo => pr_nmdcampo     --> Nome do campo a ser retornado
                                ,pr_des_reto => pr_des_reto     --> Indicador de saida com erro (OK/NOK)
                                ,pr_tab_erro => vr_tab_erro);   --> Tabela com erros
      IF pr_des_reto = 'NOK' THEN
        
        IF vr_tab_erro.first is not null THEN
          vr_cdcritic := vr_tab_erro(vr_tab_erro.first).cdcritic;
          vr_dscritic := vr_tab_erro(vr_tab_erro.first).dscritic;
        ELSE
          vr_cdcritic := 0;
          vr_dscritic := 'Erro ao buscar cidade Bacen/BNDES(pc_cod_cidade_bacen_bndes).';
        END IF;
        -- gerar critica e abortar
        raise vr_exc_erro; 
      
      END IF;
      
      vr_endcoope := rw_crapcop.dsendcop ||' '|| rw_crapcop.nrendcop;
      vr_dsdlinha :=  '7'                                                  ||
                      TO_CHAR(rw_crapcop.nrdocnpj, 'fm00000000000000')     ||
                      TO_CHAR(vr_nrcpfcgc,'fm00000000000000')              ||
                      TO_CHAR(vr_cdcidbnd,'fm0000000')                    ||
                      LPAD(vr_ctrcapit,1,' ')                              ||
                      LPAD(rw_crapcop.cdufdcop,2,' ')                      ||
                      '10000'                                              ||
                      TO_CHAR(rw_crapcop.nrdocnpj, 'fm00000000000000')     ||
                      TO_CHAR(rw_craplpc.dtpricar,'RRRRMMDD')              || 
                      '05'                                                 ||
                      RPAD(vr_nmcopcuf,18,' ')                            ||
                      RPAD(vr_endcoope,30,' ')                            ||
                      RPAD(rw_crapcop.nmbairro,15,' ')                        ||
                      SUBSTR(rw_crapcop.nrcepend,1,5) || SUBSTR(rw_crapcop.nrcepend,6,3) ||
                      TO_CHAR(rw_crapcop.dtrjunta,'RRRRMMDD')              ||
                      LPAD(' ',448,' ')                                    ||
                      TO_CHAR(vr_cdseqlin,'fm00000');
      
      -- incluir linha do arquivo
      vr_tab_arq_brde(vr_cdseqlin).cdseqlin := vr_cdseqlin;
      vr_tab_arq_brde(vr_cdseqlin).dsdlinha := vr_dsdlinha;

      vr_cdseqlin := vr_cdseqlin + 1;
      
      /****************** TRAILER DO ARQUIVO ************/
      -- Simulando last-of
      IF rw_crapipc.qtseqlot = rw_crapipc.nrseqlot THEN
        vr_dsdlinha :=  '9'                                                  ||
                        TO_CHAR(rw_crapcop.nrdocnpj, 'fm00000000000000')     ||
                        TO_CHAR(vr_nr1conta,'fm00000')                         ||
                        TO_CHAR(vr_nr5conta,'fm00000')                         ||
                        TO_CHAR(vr_vltotope * 100,'fm0000000000000000000') ||
                        LPAD(' ',551,' ')                              ||
                        TO_CHAR(vr_cdseqlin,'fm00000');
                        
        -- incluir linha do arquivo
        vr_tab_arq_brde(vr_cdseqlin).cdseqlin := vr_cdseqlin;
        vr_tab_arq_brde(vr_cdseqlin).dsdlinha := vr_dsdlinha;

        vr_cdseqlin := vr_cdseqlin + 1;                
      END IF;         
    END LOOP; -- Fim For rw_crapipc                             
    
    IF vr_dsdlinha IS NULL THEN
       vr_cdcritic := 0;
       vr_dscritic := 'Arquivo n�o gerado: Lote vazio.';
       RAISE vr_exc_erro;  
    END IF;
    
    vr_nmarqind := to_char(pr_cdcooper,'fm00')     ||
                   to_char(pr_nrdolote,'fm000000') ||
                   to_char(SYSDATE,'DDMMRRRR')     || '.txt';
    
    -- Busca do diret�rio base da cooperativa 
    vr_nom_direto := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                          ,pr_cdcooper => pr_cdcooper
                                          ,pr_nmsubdir => '/arq'); 
                                            
    vr_nom_direto_cop := gene0001.fn_diretorio(pr_tpdireto => 'M' -- /micros
                                              ,pr_cdcooper => pr_cdcooper
                                              ,pr_nmsubdir => '/procap'); 
    
    
    -- Inicializar o CLOB
    vr_des_xml := NULL;
    dbms_lob.createtemporary(vr_des_xml, TRUE);
    dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
    -- Inicilizar as informa��es do XML
    vr_texto_completo := NULL;
    
    -- Ler linhas para o arquivo
    IF vr_tab_arq_brde.count > 0 THEN
      FOR i IN vr_tab_arq_brde.FIRST..vr_tab_arq_brde.LAST LOOP
        pc_escreve_xml(vr_tab_arq_brde(i).dsdlinha||chr(10));
      END LOOP;
    END IF;
    
    --descarregar buffer
    if vr_texto_completo is not null THEN
      pc_escreve_xml('',TRUE);
    END IF;
    
    GENE0002.pc_solicita_relato_arquivo( pr_cdcooper  => pr_cdcooper                     --> Cooperativa conectada
                                        ,pr_cdprogra  => 'LOTPRC'                        --> Programa chamador
                                        ,pr_dtmvtolt  => pr_dtmvtolt                     --> Data do movimento atual
                                        ,pr_dsxml     => vr_des_xml                      --> Arquivo XML de dados
                                        ,pr_dsarqsaid => vr_nom_direto||'/'||vr_nmarqind --> Path/Nome do arquivo PDF gerado
                                        ,pr_cdrelato  => null                            --> Como n�o h�, usamos o c�digo do programa mesmo
                                        ,pr_flg_impri => 'N'                             --> Chamar a impress?o (Imprim.p)
                                        ,pr_flg_gerar => 'S'                             --> Gerar o arquivo na hora
                                        ,pr_dspathcop => vr_nom_direto_cop               --> Copiar apos geracao
                                        ,pr_fldoscop  => 'S'                             --> Converter para DOS ap�s c�pia
                                        ,pr_flgremarq => 'N'                             --> Flag para remover o arquivo apos copia/email
                                        ,pr_des_erro  => vr_dscritic);                   --> Saida com erro
    -- Testar se houve erro
    IF vr_dscritic IS NOT NULL THEN
      vr_cdcritic := 0;
      vr_dscritic := 'Erro na gera��o do arquivo procap: '||vr_dscritic;
      -- Gerar exce��o
      RAISE vr_exc_erro;
    END IF;
    
    pr_nmarquiv := vr_nom_direto_cop ||'/'|| vr_nmarqind;
    
    -- Testar se o arquivo existe
    IF NOT gene0001.fn_exis_arquivo(pr_nmarquiv) THEN
      -- Levantar exce��o
      vr_dscritic := 'Erro na gera��o do arquivo procap.';
      RAISE vr_exc_erro;
    END IF;
    
    ------- 
    COMMIT;
    -------
    pr_des_reto := 'OK';
    
  EXCEPTION
    WHEN vr_exc_erro THEN
    
      -- Chamar rotina de gravacao de erro
      gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => pr_cdagenci
                           ,pr_nrdcaixa => pr_nrdcaixa
                           ,pr_nrsequen => 1 --> Fixo
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic
                           ,pr_tab_erro => pr_tab_erro);
       pr_des_reto := 'NOK';
    
    WHEN OTHERS THEN
      
      vr_dscritic := 'Erro na rotina pc_gerar_arq_enc_brde: '||SQLErrm;
      -- Chamar rotina de gravacao de erro
      gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => pr_cdagenci
                           ,pr_nrdcaixa => pr_nrdcaixa
                           ,pr_nrsequen => 1 --> Fixo
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic
                           ,pr_tab_erro => pr_tab_erro);
       pr_des_reto := 'NOK';            
  END pc_gerar_arq_enc_brde;
  
  /*****************************************************************************
    Gerar arquivo para encaminhamento ao BRDE - vers�o para ser chamada pelo progress e web
   ******************************************************************************/
  PROCEDURE pc_gerar_arq_enc_brde_web	(pr_cdcooper IN crapcop.cdcooper%TYPE      --> c�digo da cooperativa
                                      ,pr_cdagenci IN crapage.cdagenci%TYPE      --> codigo da agencia
                                      ,pr_nrdcaixa IN NUMBER                     --> numero do caixa
                                      ,pr_cdoperad IN crapope.cdoperad%TYPE      --> Codigo do operador
                                      ,pr_dtmvtolt IN DATE                       --> Data do movimento
                                      ,pr_nrdolote IN INTEGER                    --> Numero do lote
                                      ,pr_nmarquiv OUT VARCHAR2                  --> Nome do arquivo gerado
                                      ,pr_nmdcampo OUT VARCHAR2                  --> Nome do campo a ser retornado
                                      ,pr_des_reto OUT VARCHAR2                  --> Indicador de saida com erro (OK/NOK)
                                      ,pr_xml_erro OUT CLOB) IS              --> Tabela com erros
  /*---------------------------------------------------------------------------------------------------------------
  --  Programa : pc_gerar_arq_enc_brde_web	       
  --  Sistema  : Conta-Corrente - Cooperativa de Credito
  --  Sigla    : PCAP
  --  Autor    : Jorge I. Hamaguchi
  --  Data     : Maio/2013                             Ultima alteracao: 18/11/2014
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: Sempre que chamado
  -- Objetivo  : Gerar arquivo para encaminhamento ao BRDE - vers�o para ser chamada pelo progress e web
  --
  --  Altera��es: 18/11/2014 - Convers�o Progress --> Oracle PLSQL (Odirlei - AMcom)
  --
  ---------------------------------------------------------------------------------------------------------------*/
  
  vr_tab_erro GENE0001.typ_tab_erro;
  vr_dscritic varchar2(4000);
  
  BEGIN
    
    -- chamar rotina original
    pc_gerar_arq_enc_brde	
                          (pr_cdcooper => pr_cdcooper  --> c�digo da cooperativa
                          ,pr_cdagenci => pr_cdagenci  --> codigo da agencia
                          ,pr_nrdcaixa => pr_nrdcaixa  --> numero do caixa
                          ,pr_cdoperad => pr_cdoperad  --> Codigo do operador
                          ,pr_dtmvtolt => pr_dtmvtolt  --> Data do movimento
                          ,pr_nrdolote => pr_nrdolote  --> Numero do lote
                          ,pr_nmarquiv => pr_nmarquiv  --> Nome do arquivo gerado
                          ,pr_nmdcampo => pr_nmdcampo  --> Nome do campo a ser retornado
                          ,pr_des_reto => pr_des_reto  --> Indicador de saida com erro (OK/NOK)
                          ,pr_tab_erro => vr_tab_erro);--> Tabela com erros
                          
    -- Gerar xml apartir da temptable
    IF vr_tab_erro.count > 0 THEN
      GENE0001.pc_xml_tab_erro(pr_tab_erro => vr_tab_erro, --> TempTable de erro
                               pr_xml_erro => pr_xml_erro, --> XML dos registros da temptable de erro
                               pr_tipooper => 1,           --> Tipo de opera��o, 1 - Gerar XML, 2 --Gerar pltable
                               pr_dscritic => vr_dscritic);
      IF trim(vr_dscritic) IS NOT NULL THEN                         
        pr_des_reto := 'NOK';
      END IF; 
      
    END IF;
     
  END pc_gerar_arq_enc_brde_web;
  
END PCAP0001;
/

