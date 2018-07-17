CREATE OR REPLACE PACKAGE CECRED.CYBE0003 AS
---------------------------------------------------------------------------------------------------------------
--
--    Programa: CYBE0003
--    Autor   : Douglas Quisinski
--    Data    : Agosto/2015                     Ultima Atualizacao:   /  /    
--
--    Dados referentes ao programa:
--
  --  Objetivo  : Package referente aos cadastros do CYBER
--
--    Alteracoes: 
--                13/01/2017 - Jean Calao - Mout�S - Melhorias envio informacoes CYBER - altera�ao das procedures 
--                             pc_consultar_param_histor e pc_manter_param_histor - inclus�o do campo cdtrscyb na
--							   tabela CRAPHIS. Inclus�o dos campos flgjudic e flextjud na tabela TBCOBRAN_ASSESSORIAS
--    
--                05/06/2018 - Adicionado procedure para inserir registro na tabela tbdsct_titulo_cyber (Paulo Penteado (GFT))
---------------------------------------------------------------------------------------------------------------

  /* Rotina para consultar as assessorias cadastradas */
  PROCEDURE pc_consultar_assessorias(pr_cdassess   IN INTEGER            --> C�digo da Assessoria
                                    ,pr_xmllog     IN VARCHAR2           --> XML com informa��es de LOG
                                    ,pr_cdcritic  OUT PLS_INTEGER        --> C�digo da cr�tica
                                    ,pr_dscritic  OUT VARCHAR2           --> Descri��o da cr�tica
                                    ,pr_retxml     IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                    ,pr_nmdcampo  OUT VARCHAR2           --> Nome do campo com erro
                                    ,pr_des_erro  OUT VARCHAR2);         --> Erros do processo

  /* Rotina para buscar as assessorias cadastradas filtrando parte do nome*/
  PROCEDURE pc_buscar_assessorias(pr_nmassessoria  IN VARCHAR2           --> Descri��o parcial da Assessoria 
                                 ,pr_xmllog        IN VARCHAR2           --> XML com informa��es de LOG
                                 ,pr_cdcritic     OUT PLS_INTEGER        --> C�digo da cr�tica
                                 ,pr_dscritic     OUT VARCHAR2           --> Descri��o da cr�tica
                                 ,pr_retxml        IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                 ,pr_nmdcampo     OUT VARCHAR2           --> Nome do campo com erro
                                 ,pr_des_erro     OUT VARCHAR2);         --> Erros do processo

  /* Rotina para manter as assessorias */
 

  PROCEDURE pc_manter_assessorias(pr_cddopcao   IN VARCHAR2           --> Op��o (IA-Incluir/AA-Alterar/EA-Excluir)
                                 ,pr_cdassess   IN INTEGER            --> C�digo da Assessoria
                                 ,pr_dsassess   IN VARCHAR2           --> Descri��o da Assessoria
                                 ,pr_cdasscyb   IN INTEGER            --> C�digo da Assessoria Cyber
								                 ,pr_flgjudic   IN NUMBER			        --> flag cobran�a judicial (0 ou 1)
								                 ,pr_flextjud	IN NUMBER			          --> flag cobran�a extrajudicial (0 ou 1)
                                 ,pr_cdsigcyb   IN VARCHAR2           --> Sigla da assessoria no Cyber
                                 ,pr_xmllog     IN VARCHAR2           --> XML com informa��es de LOG
                                 ,pr_cdcritic  OUT PLS_INTEGER        --> C�digo da cr�tica
                                 ,pr_dscritic  OUT VARCHAR2           --> Descri��o da cr�tica
                                 ,pr_retxml     IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                 ,pr_nmdcampo  OUT VARCHAR2           --> Nome do campo com erro
                                 ,pr_des_erro  OUT VARCHAR2);         --> Erros do processo

  /* Rotina para consultar motivos CIN cadastrados */
  PROCEDURE pc_consultar_motivos_cin(pr_cdmotivo  IN INTEGER            --> C�digo do Motivo CIN
                                    ,pr_xmllog    IN VARCHAR2           --> XML com informa��es de LOG
                                    ,pr_cdcritic OUT PLS_INTEGER        --> C�digo da cr�tica
                                    ,pr_dscritic OUT VARCHAR2           --> Descri��o da cr�tica
                                    ,pr_retxml    IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                    ,pr_nmdcampo OUT VARCHAR2           --> Nome do campo com erro
                                    ,pr_des_erro OUT VARCHAR2);         --> Erros do processo

  /* Rotina para consultar motivos CIN cadastrados */
  PROCEDURE pc_buscar_motivos_cin(pr_dsmotivocin  IN VARCHAR2           --> Descri��o do Motivo CIN
                                 ,pr_xmllog       IN VARCHAR2           --> XML com informa��es de LOG
                                 ,pr_cdcritic    OUT PLS_INTEGER        --> C�digo da cr�tica
                                 ,pr_dscritic    OUT VARCHAR2           --> Descri��o da cr�tica
                                 ,pr_retxml       IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                 ,pr_nmdcampo    OUT VARCHAR2           --> Nome do campo com erro
                                 ,pr_des_erro    OUT VARCHAR2);         --> Erros do processo
                                    
  /* Rotina para manter os motivos CIN */
  PROCEDURE pc_manter_motivos_cin(pr_cddopcao   IN VARCHAR2           --> Op��o (IM-Incluir/AM-Alterar/EM-Excluir)
                                 ,pr_cdmotivo   IN INTEGER            --> C�digo do Motivo CIN
                                 ,pr_dsmotivo   IN VARCHAR2           --> Descri��o do Motivo CIN
                                 ,pr_xmllog     IN VARCHAR2           --> XML com informa��es de LOG
                                 ,pr_cdcritic  OUT PLS_INTEGER        --> C�digo da cr�tica
                                 ,pr_dscritic  OUT VARCHAR2           --> Descri��o da cr�tica
                                 ,pr_retxml     IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                 ,pr_nmdcampo  OUT VARCHAR2           --> Nome do campo com erro
                                 ,pr_des_erro  OUT VARCHAR2);         --> Erros do processo
                                 
  /* Rotina para pesquisar a parametriza��o dos hist�ricos */
  PROCEDURE pc_consultar_param_histor(pr_cddopcao   IN VARCHAR2           --> Op��o de Filtro(C-Codigo/D-Descricao/F-Filtro/T-Todos)
                                     ,pr_cdfiltro   IN INTEGER            --> C�digo do Filtro (1-C�lculo Empr�stimo/2-C�lculo Conta Corrente/3-Ambos)
                                     ,pr_cdhistor   IN INTEGER            --> C�digo do Hist�rico
                                     ,pr_dshistor   IN VARCHAR2           --> Descri��o do Hist�rico
                                     ,pr_xmllog     IN VARCHAR2           --> XML com informa��es de LOG
                                     ,pr_cdcritic  OUT PLS_INTEGER        --> C�digo da cr�tica
                                     ,pr_dscritic  OUT VARCHAR2           --> Descri��o da cr�tica
                                     ,pr_retxml     IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                     ,pr_nmdcampo  OUT VARCHAR2           --> Nome do campo com erro
                                     ,pr_des_erro  OUT VARCHAR2);         --> Erros do processo

  /* Rotina para pesquisar a parametriza��o dos hist�ricos */
  PROCEDURE pc_manter_param_histor(pr_cddopcao   IN VARCHAR2           --> Op��o (AH-Alterar)
                                  ,pr_dshistor   IN VARCHAR2           --> Hist�ricos para alterar (CDHISTOR;INDCALEM;INDCALCC|)
                                  ,pr_xmllog     IN VARCHAR2           --> XML com informa��es de LOG
                                  ,pr_cdcritic  OUT PLS_INTEGER        --> C�digo da cr�tica
                                  ,pr_dscritic  OUT VARCHAR2           --> Descri��o da cr�tica
                                  ,pr_retxml     IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                  ,pr_nmdcampo  OUT VARCHAR2           --> Nome do campo com erro
                                  ,pr_des_erro  OUT VARCHAR2);         --> Erros do processo
                                  
  PROCEDURE pc_buscar_titulos_bordero (pr_nrdconta  IN crapass.nrdconta%TYPE --> Numero da Conta
                                 ,pr_nrborder       IN craptdb.nrborder%TYPE --> Numero do Bordero
                                 ,pr_nrdocmto  IN craptdb.nrdocmto%TYPE --> Numero do Documento
                                 ,pr_xmllog        IN VARCHAR2             --> XML com informa��es de LOG
                                 ,pr_cdcritic     OUT PLS_INTEGER          --> C�digo da cr�tica
                                 ,pr_dscritic     OUT VARCHAR2             --> Descri��o da cr�tica
                                 ,pr_retxml        IN OUT NOCOPY XMLType   --> Arquivo de retorno do XML
                                 ,pr_nmdcampo     OUT VARCHAR2             --> Nome do campo com erro
                                 ,pr_des_erro     OUT VARCHAR2);           --> Erros do processo
                                 
                                 
  PROCEDURE pc_buscar_tbdsct_titulo (pr_cdcooper IN crapass.cdcooper%TYPE --> C�digo da cooperativa
                                     ,pr_nrdconta  IN crapass.nrdconta%TYPE --> Numero da Conta
                                     ,pr_nrctremp IN crapcyc.nrctremp%TYPE --> Numero do contrato de desconto  
                                     ,pr_tbdsct_nrctrdsc OUT tbdsct_titulo_cyber.nrctrdsc%TYPE --> Numero do contrato de desconto
                                     ,pr_tbdsct_nrborder OUT tbdsct_titulo_cyber.nrborder%TYPE --> Numero do bordero
                                     ,pr_tbdsct_nrtitulo OUT tbdsct_titulo_cyber.nrtitulo%TYPE --> Numero do titulo
                                     ,pr_cdcritic OUT PLS_INTEGER          --> C�digo da cr�tica
                                     ,pr_dscritic OUT VARCHAR2);
                                     
  PROCEDURE pc_inserir_titulo_cyber(pr_cdcooper  IN crapcop.cdcooper%TYPE --> Codigo da Cooperativa
                                   ,pr_nrdconta  IN crapass.nrdconta%TYPE --> Numero da Conta
                                   ,pr_nrborder  IN crapbdt.nrborder%TYPE --> Numero do bordero do titulo em atraso no cyber
                                   ,pr_nrtitulo  IN craptdb.nrtitulo%TYPE --> Numero do titulo em atraso no cyber
                                   ,pr_nrctrdsc OUT tbdsct_titulo_cyber.nrctrdsc%TYPE --> Numero do contrato de desconto de titulo a ser enviado para o cyber
                                   ,pr_dscritic OUT VARCHAR2);            --> Descri��o da cr�tica
                                   
END CYBE0003;
/
CREATE OR REPLACE PACKAGE BODY CECRED.CYBE0003 AS
---------------------------------------------------------------------------------------------------------------
--
--    Programa: CYBE0003
--    Autor   : Douglas Quisinski
--    Data    : Agosto/2015                     Ultima Atualizacao:   /  /    
--
--    Dados referentes ao programa:
--
  --  Objetivo  : Package referente aos cadastros do CYBER
--
--    Alteracoes: ??/08/2015 - Cria��o (Douglas Quisinski)
--    
--                05/06/2018 - Adicionado procedure para inserir registro na tabela tbdsct_titulo_cyber (Paulo Penteado (GFT))
---------------------------------------------------------------------------------------------------------------

  PROCEDURE pc_consultar_assessorias(pr_cdassess   IN INTEGER            --> C�digo da Assessoria
                                    ,pr_xmllog     IN VARCHAR2           --> XML com informa��es de LOG
                                    ,pr_cdcritic  OUT PLS_INTEGER        --> C�digo da cr�tica
                                    ,pr_dscritic  OUT VARCHAR2           --> Descri��o da cr�tica
                                    ,pr_retxml     IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                    ,pr_nmdcampo  OUT VARCHAR2           --> Nome do campo com erro
                                    ,pr_des_erro  OUT VARCHAR2) IS       --> Erros do processo
  BEGIN
    /* .............................................................................
    Programa: pc_consultar_assessorias
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Douglas Quisinski
    Data    : 25/08/2015                        Ultima atualizacao: 17/01/2017

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para consultar as assessorias cadastradas

    Alteracoes:
	            17/01/2017 - PRJ. 432 - inclus�o dos campos flgjudic e flextjud (Jean/Mout�S)
    ............................................................................. */
    DECLARE
      -- Exce��o
      vr_exc_erro  EXCEPTION;
      
      -- Vari�veis de erro
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic crapcri.dscritic%TYPE;
      vr_cdsigcyb varchar2(10);

      CURSOR cr_assessorias(pr_cdassessoria IN tbcobran_assessorias.cdassessoria%TYPE) IS
      SELECT tbcobran_assessorias.cdassessoria
            ,tbcobran_assessorias.nmassessoria
            ,tbcobran_assessorias.cdassessoria_cyber
			      ,tbcobran_assessorias.flgjudicial
			      ,tbcobran_assessorias.flgextra_judicial
          --  ,tbcobran_assessorias.cdsigla_cyber
        FROM tbcobran_assessorias
       WHERE tbcobran_assessorias.cdassessoria = NVL(pr_cdassessoria,tbcobran_assessorias.cdassessoria)
       ORDER BY tbcobran_assessorias.cdassessoria;
      
    BEGIN
      -- Criar cabecalho do XML                
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><assessorias></assessorias></Root>');
      FOR rw_assessoria IN cr_assessorias(pr_cdassess) LOOP
        -- Criar nodo filho
        BEGIN
          select  DSVLRPRM
          into    vr_cdsigcyb
          from    crapprm
          where   NMSISTEM = 'CRED'
           and    CDACESSO = 'CYBER_CD_SIGLA'||lpad(rw_assessoria.cdassessoria,2,'0')
           and    dstexprm = lpad(rw_assessoria.cdassessoria,2,'0');
        exception
           when no_data_found then
                vr_cdsigcyb := null;
        end;
        pr_retxml := XMLTYPE.appendChildXML(pr_retxml
                                            ,'/Root/assessorias'
                                            ,XMLTYPE('<assessoria>'
                                                   ||'  <cdassessoria>'||rw_assessoria.cdassessoria||'</cdassessoria>'
                                                   ||'  <nmassessoria>'||UPPER(rw_assessoria.nmassessoria)||'</nmassessoria>'
                                                   ||'  <cdasscyb>'||UPPER(rw_assessoria.cdassessoria_cyber)||'</cdasscyb>'
												                           ||'  <flgjudic>'||UPPER(rw_assessoria.flgjudicial)||'</flgjudic>'
												                           ||'  <flextjud>'||UPPER(rw_assessoria.flgextra_judicial)||'</flextjud>'
                                                  -- ||'  <cdsigcyb>'||UPPER(rw_assessoria.cdsigla_cyber)||'</cdsigcyb>'
                                                   ||'  <cdsigcyb>'||UPPER(vr_cdsigcyb)||'</cdsigcyb>'
                                                   ||'</assessoria>'));
      END LOOP;
      
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
        -- Carregar XML padr�o para vari�vel de retorno n�o utilizada.
        -- Existe para satisfazer exig�ncia da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral (CYBE0003.pc_consultar_assessorias): ' || SQLERRM;
        -- Carregar XML padr�o para vari�vel de retorno n�o utilizada.
        -- Existe para satisfazer exig�ncia da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;
  END pc_consultar_assessorias;

  PROCEDURE pc_buscar_assessorias(pr_nmassessoria  IN VARCHAR2           --> Descri��o parcial da Assessoria 
                                 ,pr_xmllog        IN VARCHAR2           --> XML com informa��es de LOG
                                 ,pr_cdcritic     OUT PLS_INTEGER        --> C�digo da cr�tica
                                 ,pr_dscritic     OUT VARCHAR2           --> Descri��o da cr�tica
                                 ,pr_retxml        IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                 ,pr_nmdcampo     OUT VARCHAR2           --> Nome do campo com erro
                                 ,pr_des_erro     OUT VARCHAR2) IS       --> Erros do processo
  BEGIN
    /* .............................................................................
    Programa: pc_buscar_assessorias
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Douglas Quisinski
    Data    : 27/08/2015                        Ultima atualizacao: 17/01/2017

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para buscar as assessorias por parte do nome

    Alteracoes:	17/01/2017-PRJ.432-inclus�o dos campos flgjudic, flextjud (Jean/Mout�S)

    ............................................................................. */
    DECLARE
      -- Exce��o
      vr_exc_erro  EXCEPTION;
      
      -- Vari�veis de erro
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic crapcri.dscritic%TYPE;
      vr_cdsigcyb varchar2(10);
      
      CURSOR cr_assessorias(pr_nmassessoria IN tbcobran_assessorias.nmassessoria%TYPE) IS
      SELECT tbcobran_assessorias.cdassessoria
            ,tbcobran_assessorias.nmassessoria
            ,tbcobran_assessorias.cdassessoria_cyber
			      ,decode(tbcobran_assessorias.flgjudicial, 1, 'S','N')        flgjudicial
			      ,decode(tbcobran_assessorias.flgextra_judicial, 1, 'S', 'N') flgextra_judicial
            --,tbcobran_assessorias.cdsigla_cyber
        FROM tbcobran_assessorias
       WHERE UPPER(tbcobran_assessorias.nmassessoria) LIKE UPPER('%' || pr_nmassessoria || '%')
       ORDER BY tbcobran_assessorias.cdassessoria;
      
    BEGIN
      -- Criar cabecalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><assessorias></assessorias></Root>');
      
      FOR rw_assessoria IN cr_assessorias(NVL(pr_nmassessoria,'')) LOOP
        -- Criar nodo filho
        -- retirar este select ap�s alteracao da estrutura da tabela
        begin
          select  DSVLRPRM
          into    vr_cdsigcyb
          from    crapprm
          where   NMSISTEM = 'CRED'
           and    CDACESSO = 'CYBER_CD_SIGLA'||lpad(rw_assessoria.cdassessoria,2,'0')
           and    dstexprm = lpad(rw_assessoria.cdassessoria,2,'0');
        exception
           when no_data_found then
                vr_cdsigcyb := null;
        end;
         
        pr_retxml := XMLTYPE.appendChildXML(pr_retxml
                                            ,'/Root/assessorias'
                                            ,XMLTYPE('<assessoria>'
                                                   ||'  <cdassessoria>'||rw_assessoria.cdassessoria||'</cdassessoria>'
                                                   ||'  <nmassessoria>'||UPPER(rw_assessoria.nmassessoria)||'</nmassessoria>'
                                                   ||'  <cdasscyb>'||UPPER(rw_assessoria.cdassessoria_cyber)||'</cdasscyb>'
												                           ||'  <flgjudic>'||UPPER(rw_assessoria.flgjudicial)||'</flgjudic>'
												                           ||'  <flextjud>'||UPPER(rw_assessoria.flgextra_judicial)||'</flextjud>'
                                                  -- ||'  <cdsigcyb>'||UPPER(rw_assessoria.cdsigla_cyber)||'</cdsigcyb>'
												                           ||'  <cdsigcyb>'||UPPER(vr_cdsigcyb)||'</cdsigcyb>'
												                           ||'</assessoria>'));
      END LOOP;
      
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
        -- Carregar XML padr�o para vari�vel de retorno n�o utilizada.
        -- Existe para satisfazer exig�ncia da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral (CYBE0003.pc_buscar_assessorias): ' || SQLERRM;
        -- Carregar XML padr�o para vari�vel de retorno n�o utilizada.
        -- Existe para satisfazer exig�ncia da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;
  END pc_buscar_assessorias;
  
  PROCEDURE pc_manter_assessorias(pr_cddopcao   IN VARCHAR2           --> Op��o (I-Incluir/A-Alterar/E-Excluir)
                                 ,pr_cdassess   IN INTEGER            --> C�digo da Assessoria
                                 ,pr_dsassess   IN VARCHAR2           --> Descri��o da Assessoria
                                 ,pr_cdasscyb   IN INTEGER            --> C�digo da Assessoria Cyber
								                 ,pr_flgjudic   IN NUMBER			        --> flag cobran�a judicial (0 ou 1)
								                 ,pr_flextjud	IN NUMBER			          --> flag cobran�a extrajudicial (0 ou 1)
                                 ,pr_cdsigcyb in varchar2             --> sigla da assessoria no Cyber
                                 ,pr_xmllog     IN VARCHAR2           --> XML com informa��es de LOG
                                 ,pr_cdcritic  OUT PLS_INTEGER        --> C�digo da cr�tica
                                 ,pr_dscritic  OUT VARCHAR2           --> Descri��o da cr�tica
                                 ,pr_retxml     IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                 ,pr_nmdcampo  OUT VARCHAR2           --> Nome do campo com erro
                                 ,pr_des_erro  OUT VARCHAR2) IS       --> Erros do processo
  BEGIN
    /* .............................................................................
    Programa: pc_manter_assessorias
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Douglas Quisinski
    Data    : 25/08/2015                        Ultima atualizacao: 17/01/2017

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para manter as assessorias 

    Alteracoes: 17/01/2017-PRJ.432-inclus�o dos campos flgjudic, flextjud (Jean/Mout�S)
    ............................................................................. */
    DECLARE
      -- Exce��o
      vr_exc_erro  EXCEPTION;
      
      -- Vari�veis de erro
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic crapcri.dscritic%TYPE;
      
      -- Vari�vies
      vr_cdassess INTEGER;  
      vr_existe   integer;
      
      CURSOR cr_crapcyc(pr_cdassessoria IN crapcyc.cdassess%TYPE) IS
      SELECT 1
        FROM crapcyc
       WHERE crapcyc.cdassess = pr_cdassessoria;
      rw_crapcyc cr_crapcyc%ROWTYPE;
      
    BEGIN
      
      CASE pr_cddopcao  
        WHEN 'IA' THEN -- Incluir Assessoria
          vr_cdassess:= fn_sequence(pr_nmtabela => 'TBCOBRAN_ASSESSORIAS'
                                   ,pr_nmdcampo => 'CDASSESSORIA'
                                   ,pr_dsdchave => ' '
                                   ,pr_flgdecre => 'N');
          BEGIN
            INSERT INTO TBCOBRAN_ASSESSORIAS
              (CDASSESSORIA,
               NMASSESSORIA,
               CDASSESSORIA_CYBER,
               FLGJUDICIAL,
               FLGEXTRA_JUDICIAL/*,
               CDSIGLA_CYBER*/)
            VALUES
              (VR_CDASSESS,
               UPPER(PR_DSASSESS),
               PR_CDASSCYB,
               PR_FLGJUDIC,
               PR_FLEXTJUD);
               --, UPPER(pr_cdsigcyb));
          EXCEPTION
            WHEN OTHERS THEN
            -- Descricao do erro na insercao de registros
            vr_dscritic := 'Problema ao incluir Assessoria: ' || SQLERRM;
            RAISE vr_exc_erro;
          END;
          -- Cadastro temporario
          BEGIN
            insert into CRAPPRM 
                (NMSISTEM
               , CDCOOPER
               , CDACESSO
               , DSTEXPRM
               , DSVLRPRM)
            VALUES ('CRED'
                    ,0
                    ,'CYBER_CD_SIGLA' || LPAD(VR_CDASSESS,2,'0')
                    ,LPAD(VR_CDASSESS,2,'0')
                    ,UPPER(pr_cdsigcyb));
          EXCEPTION
             WHEN OTHERS THEN
                   -- Descricao do erro na insercao de registros
                vr_dscritic := 'Problema ao incluir Assessoria: ' || SQLERRM;
                RAISE vr_exc_erro;
          END;
        WHEN 'AA' THEN -- Alterar Assessoria
          BEGIN
            UPDATE tbcobran_assessorias 
               SET nmassessoria = UPPER(pr_dsassess)
                 , cdassessoria_cyber = pr_cdasscyb
                 , flgjudicial = pr_flgjudic
                 , flgextra_judicial = pr_flextjud
                 --, cdsigla_cyber = UPPER(pr_cdsigcyb)
             WHERE cdassessoria = pr_cdassess;
          EXCEPTION
            WHEN OTHERS THEN
            -- Descricao do erro na altera��o de registros
            vr_dscritic := 'Problema ao alterar Assessoria: ' || sqlerrm;
            RAISE vr_exc_erro;
          END;        
          BEGIN
            SELECT 1
            INTO   vr_existe
            from   crapprm
            where  NMSISTEM = 'CRED'
              and    CDACESSO = 'CYBER_CD_SIGLA' || lpad(pr_cdassess,2,'0')
              and    dstexprm = lpad(pr_cdassess,2,'0');
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
               vr_existe :=0;
          END;
          if nvl(vr_existe,0) = 0 then
             BEGIN
              insert into CRAPPRM 
                  (NMSISTEM
                 , CDCOOPER
                 , CDACESSO
                 , DSTEXPRM
                 , DSVLRPRM)
              VALUES ('CRED'
                      ,0
                      ,'CYBER_CD_SIGLA'||lpad(pr_cdassess,2,'0')
                      ,LPAD(pr_cdassess,2,'0')
                      ,UPPER(pr_cdsigcyb));
             EXCEPTION
               WHEN OTHERS THEN
                     -- Descricao do erro na insercao de registros
                  vr_dscritic := 'Problema ao incluir Assessoria: ' || SQLERRM;
                  RAISE vr_exc_erro;
             END;
          else
            BEGIN  
              UPDATE CRAPPRM
              SET    DSVLRPRM = UPPER(pr_cdsigcyb)
              where  NMSISTEM = 'CRED'
              and    CDACESSO = 'CYBER_CD_SIGLA'||lpad(pr_cdassess,2,'0')
              and    dstexprm = lpad(pr_cdassess,2,'0');
            EXCEPTION
               WHEN OTHERS THEN
              -- Descricao do erro na altera��o de registros
                  vr_dscritic := 'Problema ao alterar Assessoria: ' || sqlerrm;
                  RAISE vr_exc_erro;
            END;
          end if;
        WHEN 'EA' THEN -- Excluir Assessoria
          OPEN cr_crapcyc(pr_cdassessoria => pr_cdassess);
          FETCH cr_crapcyc INTO rw_crapcyc;
          IF cr_crapcyc%FOUND THEN
            CLOSE cr_crapcyc;
            vr_dscritic := GENE0007.fn_convert_db_web('N�o � possivel excluir a assessoria. ' ||
                                                      'Existem cadastros de contrato no sistema CYBER ' ||
                                                      'vinculados com essa assessoria.');
            RAISE vr_exc_erro;
          END IF;
          CLOSE cr_crapcyc;
        
          BEGIN
            DELETE tbcobran_assessorias 
             WHERE cdassessoria = pr_cdassess;
          EXCEPTION
            WHEN OTHERS THEN
            -- Descricao do erro na exclus�o de registros
                vr_dscritic := 'Problema ao excluir Assessoria: ' || sqlerrm;
                RAISE vr_exc_erro;
          END;          
          begin
            DELETE CRAPPRM
            where  NMSISTEM = 'CRED'
            and    CDACESSO = 'CYBER_CD_SIGLA'||lpad(pr_cdassess,2,'0')
            and    dstexprm = lpad(pr_cdassess,2,'0');  
          exception
            WHEN OTHERS THEN
            -- Descricao do erro na exclus�o de registros
                vr_dscritic := 'Problema ao excluir Assessoria: ' || sqlerrm;
                RAISE vr_exc_erro;
          end;
      END CASE;                              

    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
        -- Carregar XML padr�o para vari�vel de retorno n�o utilizada.
        -- Existe para satisfazer exig�ncia da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral (CYBE0003.pc_manter_assessorias): ' || SQLERRM;
        -- Carregar XML padr�o para vari�vel de retorno n�o utilizada.
        -- Existe para satisfazer exig�ncia da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;
  END pc_manter_assessorias;

  PROCEDURE pc_consultar_motivos_cin(pr_cdmotivo   IN INTEGER            --> C�digo do Motivo CIN
                                    ,pr_xmllog     IN VARCHAR2           --> XML com informa��es de LOG
                                    ,pr_cdcritic  OUT PLS_INTEGER        --> C�digo da cr�tica
                                    ,pr_dscritic  OUT VARCHAR2           --> Descri��o da cr�tica
                                    ,pr_retxml     IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                    ,pr_nmdcampo  OUT VARCHAR2           --> Nome do campo com erro
                                    ,pr_des_erro  OUT VARCHAR2) IS       --> Erros do processo
  BEGIN
    /* .............................................................................
    Programa: pc_consultar_motivos_cin
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Douglas Quisinski
    Data    : 25/08/2015                        Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para consultar os motivos CIN cadastrados

    Alteracoes:
    ............................................................................. */
    DECLARE
      -- Exce��o
      vr_exc_erro  EXCEPTION;
      
      -- Vari�veis de erro
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic crapcri.dscritic%TYPE;

      CURSOR cr_motivo(pr_cdmotivo IN tbcobran_motivos_cin.cdmotivo%TYPE) IS
      SELECT tbcobran_motivos_cin.cdmotivo
            ,tbcobran_motivos_cin.dsmotivo
        FROM tbcobran_motivos_cin
       WHERE tbcobran_motivos_cin.cdmotivo = NVL(pr_cdmotivo,tbcobran_motivos_cin.cdmotivo)
       ORDER BY tbcobran_motivos_cin.cdmotivo;
      
    BEGIN
      -- Criar cabecalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><motivos></motivos></Root>');
      FOR rw_motivo IN cr_motivo(pr_cdmotivo) LOOP
        -- Criar nodo filho
        pr_retxml := XMLTYPE.appendChildXML(pr_retxml
                                            ,'/Root/motivos'
                                            ,XMLTYPE('<motivo>'
                                                   ||'  <cdmotivo>'||rw_motivo.cdmotivo||'</cdmotivo>'
                                                   ||'  <dsmotivo>'||UPPER(rw_motivo.dsmotivo)||'</dsmotivo>'
                                                   ||'</motivo>'));
      END LOOP;
      
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
        -- Carregar XML padr�o para vari�vel de retorno n�o utilizada.
        -- Existe para satisfazer exig�ncia da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral (CYBE0003.pc_consultar_motivos_cin): ' || SQLERRM;
        -- Carregar XML padr�o para vari�vel de retorno n�o utilizada.
        -- Existe para satisfazer exig�ncia da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;
  END pc_consultar_motivos_cin;

  PROCEDURE pc_buscar_motivos_cin(pr_dsmotivocin  IN VARCHAR2           --> Descri��o do Motivo CIN
                                 ,pr_xmllog       IN VARCHAR2           --> XML com informa��es de LOG
                                 ,pr_cdcritic    OUT PLS_INTEGER        --> C�digo da cr�tica
                                 ,pr_dscritic    OUT VARCHAR2           --> Descri��o da cr�tica
                                 ,pr_retxml       IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                 ,pr_nmdcampo    OUT VARCHAR2           --> Nome do campo com erro
                                 ,pr_des_erro    OUT VARCHAR2) IS       --> Erros do processo
  BEGIN
    /* .............................................................................
    Programa: pc_buscar_motivos_cin
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Douglas Quisinski
    Data    : 27/08/2015                        Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para buscar os motivos CIN que possuem a descri��o informada

    Alteracoes:
    ............................................................................. */
    DECLARE
      -- Exce��o
      vr_exc_erro  EXCEPTION;
      
      -- Vari�veis de erro
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic crapcri.dscritic%TYPE;

      CURSOR cr_motivo(pr_dsmotivo IN tbcobran_motivos_cin.dsmotivo%TYPE) IS
      SELECT tbcobran_motivos_cin.cdmotivo
            ,tbcobran_motivos_cin.dsmotivo
        FROM tbcobran_motivos_cin
       WHERE UPPER(tbcobran_motivos_cin.dsmotivo)  LIKE UPPER('%' || pr_dsmotivo || '%')
       ORDER BY tbcobran_motivos_cin.cdmotivo;
      
    BEGIN
      -- Criar cabecalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><motivos></motivos></Root>');
      FOR rw_motivo IN cr_motivo(NVL(pr_dsmotivocin,'')) LOOP
        -- Criar nodo filho
        pr_retxml := XMLTYPE.appendChildXML(pr_retxml
                                            ,'/Root/motivos'
                                            ,XMLTYPE('<motivo>'
                                                   ||'  <cdmotivo>'||rw_motivo.cdmotivo||'</cdmotivo>'
                                                   ||'  <dsmotivo>'||UPPER(rw_motivo.dsmotivo)||'</dsmotivo>'
                                                   ||'</motivo>'));
      END LOOP;
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
        -- Carregar XML padr�o para vari�vel de retorno n�o utilizada.
        -- Existe para satisfazer exig�ncia da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral (CYBE0003.pc_buscar_motivos_cin): ' || SQLERRM;
        -- Carregar XML padr�o para vari�vel de retorno n�o utilizada.
        -- Existe para satisfazer exig�ncia da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;
  END pc_buscar_motivos_cin;
  
  PROCEDURE pc_manter_motivos_cin(pr_cddopcao   IN VARCHAR2           --> Op��o (I-Incluir/A-Alterar/E-Excluir)
                                 ,pr_cdmotivo   IN INTEGER            --> C�digo do Motivo CIN
                                 ,pr_dsmotivo   IN VARCHAR2           --> Descri��o do Motivo CIN
                                 ,pr_xmllog     IN VARCHAR2           --> XML com informa��es de LOG
                                 ,pr_cdcritic  OUT PLS_INTEGER        --> C�digo da cr�tica
                                 ,pr_dscritic  OUT VARCHAR2           --> Descri��o da cr�tica
                                 ,pr_retxml     IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                 ,pr_nmdcampo  OUT VARCHAR2           --> Nome do campo com erro
                                 ,pr_des_erro  OUT VARCHAR2) IS       --> Erros do processo
  BEGIN
    /* .............................................................................
    Programa: pc_manter_motivos_cin
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Douglas Quisinski
    Data    : 25/08/2015                        Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para manter os motivos CIN

    Alteracoes:
    ............................................................................. */
    DECLARE
      -- Exce��o
      vr_exc_erro  EXCEPTION;
      
      -- Vari�veis de erro
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic crapcri.dscritic%TYPE;
      
      -- Vari�vies
      vr_cdmotivo INTEGER;  
      
      CURSOR cr_crapcyc(pr_cdmotcin IN crapcyc.cdmotcin%TYPE) IS
      SELECT 1
        FROM crapcyc
       WHERE crapcyc.cdmotcin = pr_cdmotcin;
      rw_crapcyc cr_crapcyc%ROWTYPE;
      
    BEGIN
      
      CASE pr_cddopcao  
        WHEN 'IM' THEN -- Incluir Motivo CIN
          vr_cdmotivo:= fn_sequence(pr_nmtabela => 'TBCOBRAN_MOTIVOS_CIN'
                                   ,pr_nmdcampo => 'CDMOTIVO'
                                   ,pr_dsdchave => ' '
                                   ,pr_flgdecre => 'N');
          BEGIN
            INSERT INTO tbcobran_motivos_cin(cdmotivo,dsmotivo)
                 VALUES(vr_cdmotivo,UPPER(pr_dsmotivo));
          EXCEPTION
            WHEN OTHERS THEN
            -- Descricao do erro na insercao de registros
            vr_dscritic := 'Problema ao incluir Motivo CIN: ' || sqlerrm;
            RAISE vr_exc_erro;
          END;

        WHEN 'AM' THEN -- Alterar Motivo CIN
          BEGIN
            UPDATE tbcobran_motivos_cin SET dsmotivo = UPPER(pr_dsmotivo)
             WHERE cdmotivo = pr_cdmotivo;
          EXCEPTION
            WHEN OTHERS THEN
            -- Descricao do erro na altera��o de registros
            vr_dscritic := 'Problema ao alterar Motivo CIN: ' || sqlerrm;
            RAISE vr_exc_erro;
          END;          
          
        WHEN 'EM' THEN -- Excluir Motivo CIN
          OPEN cr_crapcyc(pr_cdmotcin => pr_cdmotivo);
          FETCH cr_crapcyc INTO rw_crapcyc;
          IF cr_crapcyc%FOUND THEN
            CLOSE cr_crapcyc;
            vr_dscritic := GENE0007.fn_convert_db_web('N�o � possivel excluir o motivo CIN. ' ||
                                                      'Existem cadastros de contrato no sistema CYBER ' ||
                                                      'vinculados com essa assessoria.');
            RAISE vr_exc_erro;
          END IF;
          CLOSE cr_crapcyc;
        
          BEGIN
            DELETE tbcobran_motivos_cin
             WHERE cdmotivo = pr_cdmotivo;
          EXCEPTION
            WHEN OTHERS THEN
            -- Descricao do erro na altera��o de registros
            vr_dscritic := 'Problema ao excluir Motivo CIN: ' || sqlerrm;
            RAISE vr_exc_erro;
          END;          
      END CASE;                              

    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
        -- Carregar XML padr�o para vari�vel de retorno n�o utilizada.
        -- Existe para satisfazer exig�ncia da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral (CYBE0003.pc_manter_motivos_cin): ' || SQLERRM;
        -- Carregar XML padr�o para vari�vel de retorno n�o utilizada.
        -- Existe para satisfazer exig�ncia da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;
  END pc_manter_motivos_cin;
  
  PROCEDURE pc_consultar_param_histor(pr_cddopcao  IN VARCHAR2           --> Op��o de Filtro(C-Codigo/D-Descricao/F-Filtro)
                                     ,pr_cdfiltro  IN INTEGER            --> C�digo do Filtro (1-C�lculo Empr�stimo/2-C�lculo Conta Corrente/3-Ambos)
                                     ,pr_cdhistor  IN INTEGER            --> C�digo do Hist�rico
                                     ,pr_dshistor  IN VARCHAR2           --> Descri��o do Hist�rico
                                     ,pr_xmllog    IN VARCHAR2           --> XML com informa��es de LOG
                                     ,pr_cdcritic OUT PLS_INTEGER        --> C�digo da cr�tica
                                     ,pr_dscritic OUT VARCHAR2           --> Descri��o da cr�tica
                                     ,pr_retxml    IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                     ,pr_nmdcampo OUT VARCHAR2           --> Nome do campo com erro
                                     ,pr_des_erro OUT VARCHAR2) IS       --> Erros do processo
  BEGIN
    /* .............................................................................
    Programa: pc_consultar_param_histor
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Douglas Quisinski
    Data    : 10/09/2015                        Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para consultar a parametriza��o dos hist�rico

    Alteracoes: 
	     13/01/2017 - Jean Cal�o - Mout�S - inclus�o campo cdtrscyb na craphis
    ............................................................................. */
    DECLARE
      -- Exce��o
      vr_exc_erro  EXCEPTION;
      
      -- Vari�veis de erro
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic crapcri.dscritic%TYPE;
      
      -- CURSOR
      -- Pesquisar todos os hist�ricos
      CURSOR cr_craphis(pr_cddopcao IN VARCHAR2
                       ,pr_cdfiltro IN INTEGER
                       ,pr_cdhistor IN craphis.cdhistor%TYPE
                       ,pr_dshistor IN craphis.dshistor%TYPE) IS
      SELECT craphis.cdhistor
            ,craphis.dshistor
            ,CASE 
              WHEN craphis.indebcre = 'C' 
                THEN 'CREDITO'
              ELSE 'DEBITO' 
             END indebcre
            ,craphis.indcalem
            ,craphis.indcalcc
			      ,craphis.cdtrscyb
        FROM craphis
       WHERE craphis.cdcooper = 3 -- Ler os hist�ricos da CECRED 
         AND ((pr_cddopcao = 'C' AND craphis.cdhistor = pr_cdhistor)
           OR (pr_cddopcao = 'D' AND UPPER(craphis.dshistor) LIKE '%' || UPPER(pr_dshistor) || '%')
           OR (pr_cddopcao = 'F' AND ((pr_cdfiltro = 1 AND craphis.indcalem = 'S')
                                   OR (pr_cdfiltro = 2 AND craphis.indcalcc = 'S')
                                   OR (pr_cdfiltro = 3 AND (craphis.indcalem = 'S' OR craphis.indcalcc = 'S'))))
           OR pr_cddopcao = 'T')
       ORDER BY craphis.cdhistor;
      
    BEGIN
      CASE pr_cddopcao 
        WHEN 'C' THEN
          IF NVL(pr_cdhistor,0) = 0 THEN
            vr_dscritic := 'Codigo do historico invalido para pesquisa.';
            RAISE vr_exc_erro;
          END IF;

        WHEN 'F' THEN
          IF NVL(pr_cdfiltro,0) = 0 OR
             pr_cdfiltro NOT IN (1,2,3) THEN
            vr_dscritic := 'Filtro invalido para pesquisa.';
            RAISE vr_exc_erro;
          END IF;

        WHEN 'D' THEN
          NULL; -- Na descri��o n�o possui valida��o
          
        WHEN 'T' THEN
          NULL; -- Quando for todos n�o precisamos validar nada
          
        ELSE 
          vr_dscritic := 'Erro na pc_consultar_param_histor. Filtros nao informados';
          RAISE vr_exc_erro;
      END CASE;
      
      -- Criar cabecalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><parametrizar_historicos></parametrizar_historicos></Root>');
      
      FOR rw_craphis IN cr_craphis(pr_cddopcao => pr_cddopcao
                                  ,pr_cdfiltro => pr_cdfiltro
                                  ,pr_cdhistor => pr_cdhistor
                                  ,pr_dshistor => pr_dshistor) LOOP
        -- Criar nodo filho
        pr_retxml := XMLTYPE.appendChildXML(pr_retxml
                                            ,'/Root/parametrizar_historicos'
                                            ,XMLTYPE('<historico>'
                                                   ||'  <cdhistor>' || rw_craphis.cdhistor || '</cdhistor>'
                                                   ||'  <dshistor>' || rw_craphis.dshistor || '</dshistor>'
                                                   ||'  <indebcre>' || rw_craphis.indebcre || '</indebcre>'
                                                   ||'  <indcalem>' || rw_craphis.indcalem || '</indcalem>'
                                                   ||'  <indcalcc>' || rw_craphis.indcalcc || '</indcalcc>'
												                           ||'  <cdtrscyb>' || rw_craphis.cdtrscyb || '</cdtrscyb>' -- 13/01/2017 - Jean Calao
                                                   ||'</historico>'));
          
      END LOOP;
      
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
        -- Carregar XML padr�o para vari�vel de retorno n�o utilizada.
        -- Existe para satisfazer exig�ncia da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral (CYBE0003.pc_consultar_param_histor): ' || SQLERRM;
        -- Carregar XML padr�o para vari�vel de retorno n�o utilizada.
        -- Existe para satisfazer exig�ncia da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;
  END pc_consultar_param_histor;
      
  PROCEDURE pc_manter_param_histor(pr_cddopcao  IN VARCHAR2           --> Op��o (AH-Alterar)
                                  ,pr_dshistor  IN VARCHAR2           --> Hist�ricos para alterar (CDHISTOR;INDCALEM;INDCALCC;CDTRSCYB|)
                                  ,pr_xmllog    IN VARCHAR2           --> XML com informa��es de LOG
                                  ,pr_cdcritic OUT PLS_INTEGER        --> C�digo da cr�tica
                                  ,pr_dscritic OUT VARCHAR2           --> Descri��o da cr�tica
                                  ,pr_retxml    IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                  ,pr_nmdcampo OUT VARCHAR2           --> Nome do campo com erro
                                  ,pr_des_erro OUT VARCHAR2) IS       --> Erros do processo
  BEGIN
    /* .............................................................................
    Programa: pc_consultar_param_histor
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Douglas Quisinski
    Data    : 10/09/2015                        Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para alterar a parametriza��o dos hist�rico

    Alteracoes:
	             13/01/2017 - Jean Calao - Mout�S - inclusao do campo cdtrscyb
    ............................................................................. */
    DECLARE
      -- Exce��o
      vr_exc_erro  EXCEPTION;
      
      -- Vari�veis de erro
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic crapcri.dscritic%TYPE;
      
      -- Array de Historicos Alterados
      vr_ret_all_historicos gene0002.typ_split;
      vr_ret_historico      gene0002.typ_split;
      
      vr_auxcont  INTEGER := 0;
      vr_cdhistor craphis.cdhistor%TYPE;
      vr_indcalem VARCHAR2(1); --craphis.indcalem%TYPE;
      vr_indcalcc VARCHAR2(1); --craphis.indcalcc%TYPE;
	    vr_cdtrscyb VARCHAR2(2); --13/01/2017 - Jean Calao
      
    BEGIN
      CASE pr_cddopcao 
        WHEN 'AH' THEN
          IF TRIM(pr_dshistor) IS NULL THEN
            vr_dscritic := 'Nenhum historico foi alterado.';
            RAISE vr_exc_erro;
          END IF;
          
          -- Criando um Array com todos os historicos que possuem alteracao no campo de C�lculo Empr�stimo ou C�lculo Conta Corrente
          vr_ret_all_historicos := gene0002.fn_quebra_string(pr_dshistor, '|');
          
          -- Percorre todos os cheques para process�-los
          FOR vr_auxcont IN 1..vr_ret_all_historicos.count LOOP
            -- Zerar as informa��es do Tipo de Movimenta��o e da Ocorrencia
            vr_cdhistor := NULL;
            vr_indcalem := 'N';
            vr_indcalcc := 'N';
			      vr_cdtrscyb := NULL;

            -- Criando um array com todas as informa��es do cheque
            vr_ret_historico := gene0002.fn_quebra_string(vr_ret_all_historicos(vr_auxcont), ';');

            vr_cdhistor := to_number(vr_ret_historico(1));
            vr_indcalem := vr_ret_historico(2);
            vr_indcalcc := vr_ret_historico(3);
			      vr_cdtrscyb := vr_ret_historico(4); -- 13/01/2017 - Jean Cal�o -- altera��o projeto melhorias envio CYBER
            
            -- Ser� atualizado os campos de C�lculo de Empr�stimo e C�lculo de Conta Corrente para o hist�rico em todas as cooperativas
            UPDATE craphis
               SET craphis.indcalem = vr_indcalem
                  ,craphis.indcalcc = vr_indcalcc
				          ,craphis.cdtrscyb = vr_cdtrscyb -- 13/01/2017 - Jean Cal�o				  
             WHERE craphis.cdhistor = vr_cdhistor;
          END LOOP;
        ELSE 
          vr_dscritic := 'Erro na pc_manter_param_histor. Opcao invalida.';
          RAISE vr_exc_erro;
      END CASE;
      
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
        -- Carregar XML padr�o para vari�vel de retorno n�o utilizada.
        -- Existe para satisfazer exig�ncia da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral (CYBE0003.pc_manter_param_histor): ' || SQLERRM;
        -- Carregar XML padr�o para vari�vel de retorno n�o utilizada.
        -- Existe para satisfazer exig�ncia da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;
  END pc_manter_param_histor;

  PROCEDURE pc_buscar_titulos_bordero (pr_nrdconta  IN crapass.nrdconta%TYPE --> Numero da Conta
                                 ,pr_nrborder  IN craptdb.nrborder%TYPE --> Numero do Bordero
                                 ,pr_nrdocmto  IN craptdb.nrdocmto%TYPE --> Numero do Documento
                                 ,pr_xmllog        IN VARCHAR2             --> XML com informa��es de LOG
                                 ,pr_cdcritic     OUT PLS_INTEGER          --> C�digo da cr�tica
                                 ,pr_dscritic     OUT VARCHAR2             --> Descri��o da cr�tica
                                 ,pr_retxml        IN OUT NOCOPY XMLType   --> Arquivo de retorno do XML
                                 ,pr_nmdcampo     OUT VARCHAR2             --> Nome do campo com erro
                                 ,pr_des_erro     OUT VARCHAR2) IS         --> Erros do processo
    /*---------------------------------------------------------------------------------------------------------------------
      Programa : pc_buscar_titulos_bordero
      Sistema  : 
      Sigla    : CRED
      Autor    : Vitor Shimada Assanuma (GFT)
      Data     : 26/05/2018
      Frequencia: Sempre que for chamado
      Objetivo  : Trazer todo os t�tulos de um n�mero de conta e cooperativa espec�fica
    ---------------------------------------------------------------------------------------------------------------------*/
    -- Exce��o
    vr_exc_erro  EXCEPTION;
      
    -- Vari�veis de erro
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;
    
    -- Variaveis de entrada vindas no xml
    vr_cdcooper integer;
    vr_cdoperad varchar2(100);
    vr_nmdatela varchar2(100);
    vr_nmeacao  varchar2(100);
    vr_cdagenci varchar2(100);
    vr_nrdcaixa varchar2(100);
    vr_idorigem varchar2(100);
    
    -- Cursor dos titulos
    CURSOR cr_craptdb(vr_cdcooper IN crapcop.cdcooper%TYPE) IS
       SELECT tdb.*
       FROM  craptdb tdb
       WHERE tdb.nrdconta = pr_nrdconta
         AND tdb.cdcooper = vr_cdcooper
         AND tdb.insitapr <> 2
         AND tdb.nrborder = DECODE(pr_nrborder, NULL, tdb.nrborder, pr_nrborder)
         AND tdb.nrdocmto = DECODE(pr_nrdocmto, NULL, tdb.nrdocmto, pr_nrdocmto);
    rw_craptdb cr_craptdb%ROWTYPE;
      
    BEGIN
       -- Leitura dos dados
       gene0004.pc_extrai_dados(pr_xml       => pr_retxml
                                ,pr_cdcooper => vr_cdcooper
                                ,pr_nmdatela => vr_nmdatela
                                ,pr_nmeacao  => vr_nmeacao
                                ,pr_cdagenci => vr_cdagenci
                                ,pr_nrdcaixa => vr_nrdcaixa
                                ,pr_idorigem => vr_idorigem
                                ,pr_cdoperad => vr_cdoperad
                                ,pr_dscritic => vr_dscritic);

      -- Criar cabecalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><titulos></titulos></Root>');
                       
      -- Abertura do cursor dos titulos
      OPEN  cr_craptdb(vr_cdcooper);
      LOOP
        FETCH cr_craptdb INTO rw_craptdb;
        EXIT WHEN cr_craptdb%NOTFOUND;
        pr_retxml := XMLTYPE.appendChildXML(pr_retxml
                                            ,'/Root/titulos'
                                            ,XMLTYPE('<titulo>' 
                                                   ||'  <nrborder>'||rw_craptdb.nrborder||'</nrborder>'
                                                   ||'  <nrtitulo>'||rw_craptdb.nrtitulo||'</nrtitulo>'
                                                   ||'  <nrdocmto>'||rw_craptdb.nrdocmto||'</nrdocmto>'
                                                   ||'  <vltitulo>'||TO_CHAR(rw_craptdb.vltitulo,'999G999G990D00')||'</vltitulo>'
                                                   ||'  <dtvencto>'||to_char(rw_craptdb.dtvencto,'dd/mm/rrrr')||'</dtvencto>'
                                                   ||'  <nrdconta>'||rw_craptdb.nrdconta||'</nrdconta>'
												                           ||'</titulo>'));
      END LOOP;
      
      -- Fecha cursor
      CLOSE cr_craptdb;                                                      
                                
  END pc_buscar_titulos_bordero;
  
  
  
  -- nrctrdsc nrborder nrtitulo
    PROCEDURE pc_buscar_tbdsct_titulo (pr_cdcooper IN crapass.cdcooper%TYPE --> C�digo da cooperativa
                                      ,pr_nrdconta IN crapass.nrdconta%TYPE --> Numero da Conta
                                      ,pr_nrctremp IN crapcyc.nrctremp%TYPE --> Numero do contrato de desconto  
                                      ,pr_tbdsct_nrctrdsc OUT tbdsct_titulo_cyber.nrctrdsc%TYPE --> Numero do contrato de desconto
                                      ,pr_tbdsct_nrborder OUT tbdsct_titulo_cyber.nrborder%TYPE --> Numero do bordero
                                      ,pr_tbdsct_nrtitulo OUT tbdsct_titulo_cyber.nrtitulo%TYPE --> Numero do titulo
                                      ,pr_cdcritic OUT PLS_INTEGER          --> C�digo da cr�tica
                                      ,pr_dscritic OUT VARCHAR2) IS            --> Descri��o da cr�tica
                                   
    /*---------------------------------------------------------------------------------------------------------------------
      Programa : pc_buscar_tbdsct_titulo
      Sistema  : 
      Sigla    : CRED
      Autor    : Alex Sandro (GFT)
      Data     : 28/05/2018
      Frequencia: Sempre que for chamado
      Objetivo  : 
    ---------------------------------------------------------------------------------------------------------------------*/
    -- Exce��o
    vr_exc_erro  EXCEPTION;
      
    -- Vari�veis de erro
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;
    
    -- Cursor dos titulos
    CURSOR cr_tbdsct_titulo_cyber IS
       SELECT tbdsct.nrctrdsc, tbdsct.cdcooper, tbdsct.nrdconta, tbdsct.nrborder, tbdsct.nrtitulo
       FROM tbdsct_titulo_cyber  tbdsct
       WHERE tbdsct.cdcooper = pr_cdcooper
       AND  tbdsct.nrdconta = pr_nrdconta
       AND  tbdsct.nrctrdsc = pr_nrctremp;
         
    rw_tbdsct_titulo_cybe cr_tbdsct_titulo_cyber%ROWTYPE;
      
    BEGIN
      OPEN cr_tbdsct_titulo_cyber();
      FETCH cr_tbdsct_titulo_cyber INTO rw_tbdsct_titulo_cybe;
      CLOSE cr_tbdsct_titulo_cyber;
      
      pr_tbdsct_nrborder := rw_tbdsct_titulo_cybe.nrborder;
      pr_tbdsct_nrtitulo := rw_tbdsct_titulo_cybe.nrtitulo;
              
  END pc_buscar_tbdsct_titulo;
  
  PROCEDURE pc_inserir_titulo_cyber(pr_cdcooper  IN crapcop.cdcooper%TYPE --> Codigo da Cooperativa
                                   ,pr_nrdconta  IN crapass.nrdconta%TYPE --> Numero da Conta
                                   ,pr_nrborder  IN crapbdt.nrborder%TYPE --> Numero do bordero do titulo em atraso no cyber
                                   ,pr_nrtitulo  IN craptdb.nrtitulo%TYPE --> Numero do titulo em atraso no cyber
                                   ,pr_nrctrdsc OUT tbdsct_titulo_cyber.nrctrdsc%TYPE --> Numero do contrato de desconto de titulo a ser enviado para o cyber
                                   ,pr_dscritic OUT VARCHAR2              --> Descri��o da cr�tica
                                   ) IS
    /*---------------------------------------------------------------------------------------------------------------------
      Programa : pc_inserir_titulo_cyber
      Sistema  : CRED
      Sigla    : DSCT0003
      Autor    : Paulo Penteado (GFT)
      Data     : Junho/2018
      
      Objetivo  : Inserir registros da CYBER do border� na tabela tbdsct_titulo_cyber

      Altera��o : 05/06/2018 - Cria��o (Paulo Penteado (GFT))

    ---------------------------------------------------------------------------------------------------------------------*/
    vr_nrctrdsc tbdsct_titulo_cyber.nrctrdsc%TYPE; 
    
    -- Vari�vel de cr�ticas
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(10000);

    -- Tratamento de erros
    vr_exc_erro EXCEPTION;
    
    CURSOR cr_crapbdt IS
    SELECT 1
    FROM   crapbdt bdt
    WHERE  bdt.nrdconta = pr_nrdconta
    AND    bdt.nrborder = pr_nrborder
    AND    bdt.cdcooper = pr_cdcooper;
    rw_crapbdt cr_crapbdt%ROWTYPE;
    
    CURSOR cr_craptdb IS
    SELECT 1
    FROM   craptdb tdb
    WHERE  tdb.nrdconta = pr_nrdconta
    AND    tdb.nrborder = pr_nrborder
    AND    tdb.nrtitulo = pr_nrtitulo
    AND    tdb.cdcooper = pr_cdcooper;
    rw_craptdb cr_craptdb%ROWTYPE;
    
    CURSOR cr_tbdsct_titulo_cyber IS
      SELECT nrctrdsc
        FROM tbdsct_titulo_cyber
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta
         AND nrborder = pr_nrborder
         AND nrtitulo = pr_nrtitulo;
    rw_tbdsct_titulo_cyber cr_tbdsct_titulo_cyber%ROWTYPE;
    
  BEGIN
    
    -- Valida a exist�ncia do bordero
    OPEN  cr_crapbdt;
    FETCH cr_crapbdt INTO rw_crapbdt;
    IF    cr_crapbdt%NOTFOUND THEN
          CLOSE cr_crapbdt;
          pr_dscritic := 'Border� '||pr_nrborder||' n�o encontrado.';
          RAISE vr_exc_erro;
    END   IF;
    CLOSE cr_crapbdt;  
      
    -- Valida a exist�ncia do titulo
    OPEN  cr_craptdb;
    FETCH cr_craptdb INTO rw_craptdb;
    IF    cr_craptdb%NOTFOUND THEN
        CLOSE cr_craptdb;
        pr_dscritic := 'T�tulo '||pr_nrborder||' n�o encontrado.';
        RAISE vr_exc_erro;
    END   IF;
    CLOSE cr_craptdb;
    
    OPEN cr_tbdsct_titulo_cyber;
    FETCH cr_tbdsct_titulo_cyber INTO rw_tbdsct_titulo_cyber;
    
    -- Verifica se o registro do titulo j� foi inserido na tabela. 
    IF cr_tbdsct_titulo_cyber%NOTFOUND THEN
      
      /* Buscar a proxima sequencia tbdsct_titulo_cyber.nrctrdsc */
      pc_sequence_progress(pr_nmtabela => 'TBDSCT_TITULO_CYBER'
                          ,pr_nmdcampo => 'NRCTRDSC'
                          ,pr_dsdchave => pr_cdcooper
                          ,pr_flgdecre => 'N'
                          ,pr_sequence => vr_nrctrdsc);

      BEGIN
        INSERT INTO tbdsct_titulo_cyber
               (/*01*/ cdcooper
               ,/*02*/ nrdconta
               ,/*03*/ nrborder
               ,/*04*/ nrtitulo
               ,/*05*/ nrctrdsc )
        VALUES (/*01*/ pr_cdcooper
               ,/*02*/ pr_nrdconta
               ,/*03*/ pr_nrborder
               ,/*04*/ pr_nrtitulo
               ,/*05*/ vr_nrctrdsc );
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao inserir o titulo cyber do border�: '||SQLERRM;
          RAISE vr_exc_erro;
      END;          
      
    ELSE -- Caso o registro j� exista, retorna o sequencial j� existente
      
      vr_nrctrdsc := rw_tbdsct_titulo_cyber.nrctrdsc;     
    END IF;
    
    CLOSE cr_tbdsct_titulo_cyber;
    
    pr_nrctrdsc := vr_nrctrdsc;
  EXCEPTION
    WHEN vr_exc_erro THEN
         IF  vr_cdcritic <> 0 THEN
             vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
         END IF;
         pr_dscritic := vr_dscritic;

    WHEN OTHERS THEN
         pr_dscritic := 'Erro geral na rotina cybe0003.pc_inserir_titulo_cyber: '||SQLERRM;

  END pc_inserir_titulo_cyber;

END CYBE0003;
/
