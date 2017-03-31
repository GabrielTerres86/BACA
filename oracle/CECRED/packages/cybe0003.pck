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
---------------------------------------------------------------------------------------------------------------

  /* Rotina para consultar as assessorias cadastradas */
  PROCEDURE pc_consultar_assessorias(pr_cdassess   IN INTEGER            --> Código da Assessoria
                                    ,pr_xmllog     IN VARCHAR2           --> XML com informações de LOG
                                    ,pr_cdcritic  OUT PLS_INTEGER        --> Código da crítica
                                    ,pr_dscritic  OUT VARCHAR2           --> Descrição da crítica
                                    ,pr_retxml     IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                    ,pr_nmdcampo  OUT VARCHAR2           --> Nome do campo com erro
                                    ,pr_des_erro  OUT VARCHAR2);         --> Erros do processo

  /* Rotina para buscar as assessorias cadastradas filtrando parte do nome*/
  PROCEDURE pc_buscar_assessorias(pr_nmassessoria  IN VARCHAR2           --> Descrição parcial da Assessoria 
                                 ,pr_xmllog        IN VARCHAR2           --> XML com informações de LOG
                                 ,pr_cdcritic     OUT PLS_INTEGER        --> Código da crítica
                                 ,pr_dscritic     OUT VARCHAR2           --> Descrição da crítica
                                 ,pr_retxml        IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                 ,pr_nmdcampo     OUT VARCHAR2           --> Nome do campo com erro
                                 ,pr_des_erro     OUT VARCHAR2);         --> Erros do processo

  /* Rotina para manter as assessorias */

  PROCEDURE pc_manter_assessorias(pr_cddopcao   IN VARCHAR2           --> Opção (IA-Incluir/AA-Alterar/EA-Excluir)
                                 ,pr_cdassess   IN INTEGER            --> Código da Assessoria
                                 ,pr_dsassess   IN VARCHAR2           --> Descrição da Assessoria

                                 ,pr_xmllog     IN VARCHAR2           --> XML com informações de LOG
                                 ,pr_cdcritic  OUT PLS_INTEGER        --> Código da crítica
                                 ,pr_dscritic  OUT VARCHAR2           --> Descrição da crítica
                                 ,pr_retxml     IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                 ,pr_nmdcampo  OUT VARCHAR2           --> Nome do campo com erro
                                 ,pr_des_erro  OUT VARCHAR2);         --> Erros do processo

  /* Rotina para consultar motivos CIN cadastrados */
  PROCEDURE pc_consultar_motivos_cin(pr_cdmotivo  IN INTEGER            --> Código do Motivo CIN
                                    ,pr_xmllog    IN VARCHAR2           --> XML com informações de LOG
                                    ,pr_cdcritic OUT PLS_INTEGER        --> Código da crítica
                                    ,pr_dscritic OUT VARCHAR2           --> Descrição da crítica
                                    ,pr_retxml    IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                    ,pr_nmdcampo OUT VARCHAR2           --> Nome do campo com erro
                                    ,pr_des_erro OUT VARCHAR2);         --> Erros do processo

  /* Rotina para consultar motivos CIN cadastrados */
  PROCEDURE pc_buscar_motivos_cin(pr_dsmotivocin  IN VARCHAR2           --> Descrição do Motivo CIN
                                 ,pr_xmllog       IN VARCHAR2           --> XML com informações de LOG
                                 ,pr_cdcritic    OUT PLS_INTEGER        --> Código da crítica
                                 ,pr_dscritic    OUT VARCHAR2           --> Descrição da crítica
                                 ,pr_retxml       IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                 ,pr_nmdcampo    OUT VARCHAR2           --> Nome do campo com erro
                                 ,pr_des_erro    OUT VARCHAR2);         --> Erros do processo
                                    
  /* Rotina para manter os motivos CIN */
  PROCEDURE pc_manter_motivos_cin(pr_cddopcao   IN VARCHAR2           --> Opção (IM-Incluir/AM-Alterar/EM-Excluir)
                                 ,pr_cdmotivo   IN INTEGER            --> Código do Motivo CIN
                                 ,pr_dsmotivo   IN VARCHAR2           --> Descrição do Motivo CIN
                                 ,pr_xmllog     IN VARCHAR2           --> XML com informações de LOG
                                 ,pr_cdcritic  OUT PLS_INTEGER        --> Código da crítica
                                 ,pr_dscritic  OUT VARCHAR2           --> Descrição da crítica
                                 ,pr_retxml     IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                 ,pr_nmdcampo  OUT VARCHAR2           --> Nome do campo com erro
                                 ,pr_des_erro  OUT VARCHAR2);         --> Erros do processo
                                 
  /* Rotina para pesquisar a parametrização dos históricos */
  PROCEDURE pc_consultar_param_histor(pr_cddopcao   IN VARCHAR2           --> Opção de Filtro(C-Codigo/D-Descricao/F-Filtro/T-Todos)
                                     ,pr_cdfiltro   IN INTEGER            --> Código do Filtro (1-Cálculo Empréstimo/2-Cálculo Conta Corrente/3-Ambos)
                                     ,pr_cdhistor   IN INTEGER            --> Código do Histórico
                                     ,pr_dshistor   IN VARCHAR2           --> Descrição do Histórico
                                     ,pr_xmllog     IN VARCHAR2           --> XML com informações de LOG
                                     ,pr_cdcritic  OUT PLS_INTEGER        --> Código da crítica
                                     ,pr_dscritic  OUT VARCHAR2           --> Descrição da crítica
                                     ,pr_retxml     IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                     ,pr_nmdcampo  OUT VARCHAR2           --> Nome do campo com erro
                                     ,pr_des_erro  OUT VARCHAR2);         --> Erros do processo

  /* Rotina para pesquisar a parametrização dos históricos */
  PROCEDURE pc_manter_param_histor(pr_cddopcao   IN VARCHAR2           --> Opção (AH-Alterar)
                                  ,pr_dshistor   IN VARCHAR2           --> Históricos para alterar (CDHISTOR;INDCALEM;INDCALCC|)
                                  ,pr_xmllog     IN VARCHAR2           --> XML com informações de LOG
                                  ,pr_cdcritic  OUT PLS_INTEGER        --> Código da crítica
                                  ,pr_dscritic  OUT VARCHAR2           --> Descrição da crítica
                                  ,pr_retxml     IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                  ,pr_nmdcampo  OUT VARCHAR2           --> Nome do campo com erro
                                  ,pr_des_erro  OUT VARCHAR2);         --> Erros do processo
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
--    Alteracoes: 01/03/2017 - Alteracoes projeto 432 - Jean (Mout´S)
--    
---------------------------------------------------------------------------------------------------------------

  PROCEDURE pc_consultar_assessorias(pr_cdassess   IN INTEGER            --> Código da Assessoria
                                    ,pr_xmllog     IN VARCHAR2           --> XML com informações de LOG
                                    ,pr_cdcritic  OUT PLS_INTEGER        --> Código da crítica
                                    ,pr_dscritic  OUT VARCHAR2           --> Descrição da crítica
                                    ,pr_retxml     IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                    ,pr_nmdcampo  OUT VARCHAR2           --> Nome do campo com erro
                                    ,pr_des_erro  OUT VARCHAR2) IS       --> Erros do processo
  BEGIN
    /* .............................................................................
    Programa: pc_consultar_assessorias
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Douglas Quisinski

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para consultar as assessorias cadastradas

    Alteracoes:

    ............................................................................. */
    DECLARE
      -- Exceção
      vr_exc_erro  EXCEPTION;
      
      -- Variáveis de erro
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic crapcri.dscritic%TYPE;
      vr_cdsigcyb varchar2(10);

      CURSOR cr_assessorias(pr_cdassessoria IN tbcobran_assessorias.cdassessoria%TYPE) IS
      SELECT tbcobran_assessorias.cdassessoria
            ,tbcobran_assessorias.nmassessoria

        FROM tbcobran_assessorias
       WHERE tbcobran_assessorias.cdassessoria = NVL(pr_cdassessoria,tbcobran_assessorias.cdassessoria)
       ORDER BY tbcobran_assessorias.cdassessoria;
      
    BEGIN
      -- Criar cabecalho do XML                
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><assessorias></assessorias></Root>');
      FOR rw_assessoria IN cr_assessorias(pr_cdassess) LOOP
        -- Criar nodo filho

        pr_retxml := XMLTYPE.appendChildXML(pr_retxml
                                            ,'/Root/assessorias'
                                            ,XMLTYPE('<assessoria>'
                                                   ||'  <cdassessoria>'||rw_assessoria.cdassessoria||'</cdassessoria>'
                                                   ||'  <nmassessoria>'||UPPER(rw_assessoria.nmassessoria)||'</nmassessoria>'

                                                   ||'</assessoria>'));
      END LOOP;
      
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral (CYBE0003.pc_consultar_assessorias): ' || SQLERRM;
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;
  END pc_consultar_assessorias;

  PROCEDURE pc_buscar_assessorias(pr_nmassessoria  IN VARCHAR2           --> Descrição parcial da Assessoria 
                                 ,pr_xmllog        IN VARCHAR2           --> XML com informações de LOG
                                 ,pr_cdcritic     OUT PLS_INTEGER        --> Código da crítica
                                 ,pr_dscritic     OUT VARCHAR2           --> Descrição da crítica
                                 ,pr_retxml        IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                 ,pr_nmdcampo     OUT VARCHAR2           --> Nome do campo com erro
                                 ,pr_des_erro     OUT VARCHAR2) IS       --> Erros do processo
  BEGIN
    /* .............................................................................
    Programa: pc_buscar_assessorias
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Douglas Quisinski

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para buscar as assessorias por parte do nome

    ............................................................................. */
    DECLARE
      -- Exceção
      vr_exc_erro  EXCEPTION;
      
      -- Variáveis de erro
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic crapcri.dscritic%TYPE;
      CURSOR cr_assessorias(pr_nmassessoria IN tbcobran_assessorias.nmassessoria%TYPE) IS
      SELECT tbcobran_assessorias.cdassessoria
            ,tbcobran_assessorias.nmassessoria

        FROM tbcobran_assessorias
       WHERE UPPER(tbcobran_assessorias.nmassessoria) LIKE UPPER('%' || pr_nmassessoria || '%')
       ORDER BY tbcobran_assessorias.cdassessoria;
      
    BEGIN
      -- Criar cabecalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><assessorias></assessorias></Root>');
      
      FOR rw_assessoria IN cr_assessorias(NVL(pr_nmassessoria,'')) LOOP
        -- Criar nodo filho

        pr_retxml := XMLTYPE.appendChildXML(pr_retxml
                                            ,'/Root/assessorias'
                                            ,XMLTYPE('<assessoria>'
                                                   ||'  <cdassessoria>'||rw_assessoria.cdassessoria||'</cdassessoria>'
                                                   ||'  <nmassessoria>'||UPPER(rw_assessoria.nmassessoria)||'</nmassessoria>'
      END LOOP;
      
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral (CYBE0003.pc_buscar_assessorias): ' || SQLERRM;
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;
  END pc_buscar_assessorias;
  
  PROCEDURE pc_manter_assessorias(pr_cddopcao   IN VARCHAR2           --> Opção (I-Incluir/A-Alterar/E-Excluir)
                                 ,pr_cdassess   IN INTEGER            --> Código da Assessoria
                                 ,pr_dsassess   IN VARCHAR2           --> Descrição da Assessoria

                                 ,pr_xmllog     IN VARCHAR2           --> XML com informações de LOG
                                 ,pr_cdcritic  OUT PLS_INTEGER        --> Código da crítica
                                 ,pr_dscritic  OUT VARCHAR2           --> Descrição da crítica
                                 ,pr_retxml     IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                 ,pr_nmdcampo  OUT VARCHAR2           --> Nome do campo com erro
                                 ,pr_des_erro  OUT VARCHAR2) IS       --> Erros do processo
  BEGIN
    /* .............................................................................
    Programa: pc_manter_assessorias
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Douglas Quisinski

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para manter as assessorias 

    ............................................................................. */
    DECLARE
      -- Exceção
      vr_exc_erro  EXCEPTION;
      
      -- Variáveis de erro
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic crapcri.dscritic%TYPE;
      
      -- Variávies
      vr_cdassess INTEGER;  

      
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
          EXCEPTION
            WHEN OTHERS THEN
            -- Descricao do erro na insercao de registros
            RAISE vr_exc_erro;
          END;
        WHEN 'AA' THEN -- Alterar Assessoria
          BEGIN
             WHERE cdassessoria = pr_cdassess;
          EXCEPTION
            WHEN OTHERS THEN
            -- Descricao do erro na alteração de registros
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
            -- Descricao do erro na alteração de registros
            vr_dscritic := 'Problema ao alterar Assessoria: ' || sqlerrm;
            RAISE vr_exc_erro;
        WHEN 'EA' THEN -- Excluir Assessoria
          OPEN cr_crapcyc(pr_cdassessoria => pr_cdassess);
          FETCH cr_crapcyc INTO rw_crapcyc;
          IF cr_crapcyc%FOUND THEN
            CLOSE cr_crapcyc;
            vr_dscritic := GENE0007.fn_convert_db_web('Não é possivel excluir a assessoria. ' ||
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
            -- Descricao do erro na exclusão de registros
                vr_dscritic := 'Problema ao excluir Assessoria: ' || sqlerrm;
                RAISE vr_exc_erro;
          END;          

      END CASE;                              

    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral (CYBE0003.pc_manter_assessorias): ' || SQLERRM;
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;
  END pc_manter_assessorias;

  PROCEDURE pc_consultar_motivos_cin(pr_cdmotivo   IN INTEGER            --> Código do Motivo CIN
                                    ,pr_xmllog     IN VARCHAR2           --> XML com informações de LOG
                                    ,pr_cdcritic  OUT PLS_INTEGER        --> Código da crítica
                                    ,pr_dscritic  OUT VARCHAR2           --> Descrição da crítica
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
      -- Exceção
      vr_exc_erro  EXCEPTION;
      
      -- Variáveis de erro
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
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral (CYBE0003.pc_consultar_motivos_cin): ' || SQLERRM;
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;
  END pc_consultar_motivos_cin;

  PROCEDURE pc_buscar_motivos_cin(pr_dsmotivocin  IN VARCHAR2           --> Descrição do Motivo CIN
                                 ,pr_xmllog       IN VARCHAR2           --> XML com informações de LOG
                                 ,pr_cdcritic    OUT PLS_INTEGER        --> Código da crítica
                                 ,pr_dscritic    OUT VARCHAR2           --> Descrição da crítica
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
    Objetivo  : Rotina para buscar os motivos CIN que possuem a descrição informada

    Alteracoes:
    ............................................................................. */
    DECLARE
      -- Exceção
      vr_exc_erro  EXCEPTION;
      
      -- Variáveis de erro
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
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral (CYBE0003.pc_buscar_motivos_cin): ' || SQLERRM;
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;
  END pc_buscar_motivos_cin;
  
  PROCEDURE pc_manter_motivos_cin(pr_cddopcao   IN VARCHAR2           --> Opção (I-Incluir/A-Alterar/E-Excluir)
                                 ,pr_cdmotivo   IN INTEGER            --> Código do Motivo CIN
                                 ,pr_dsmotivo   IN VARCHAR2           --> Descrição do Motivo CIN
                                 ,pr_xmllog     IN VARCHAR2           --> XML com informações de LOG
                                 ,pr_cdcritic  OUT PLS_INTEGER        --> Código da crítica
                                 ,pr_dscritic  OUT VARCHAR2           --> Descrição da crítica
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
      -- Exceção
      vr_exc_erro  EXCEPTION;
      
      -- Variáveis de erro
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic crapcri.dscritic%TYPE;
      
      -- Variávies
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
            -- Descricao do erro na alteração de registros
            vr_dscritic := 'Problema ao alterar Motivo CIN: ' || sqlerrm;
            RAISE vr_exc_erro;
          END;          
          
        WHEN 'EM' THEN -- Excluir Motivo CIN
          OPEN cr_crapcyc(pr_cdmotcin => pr_cdmotivo);
          FETCH cr_crapcyc INTO rw_crapcyc;
          IF cr_crapcyc%FOUND THEN
            CLOSE cr_crapcyc;
            vr_dscritic := GENE0007.fn_convert_db_web('Não é possivel excluir o motivo CIN. ' ||
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
            -- Descricao do erro na alteração de registros
            vr_dscritic := 'Problema ao excluir Motivo CIN: ' || sqlerrm;
            RAISE vr_exc_erro;
          END;          
      END CASE;                              

    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral (CYBE0003.pc_manter_motivos_cin): ' || SQLERRM;
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;
  END pc_manter_motivos_cin;
  
  PROCEDURE pc_consultar_param_histor(pr_cddopcao  IN VARCHAR2           --> Opção de Filtro(C-Codigo/D-Descricao/F-Filtro)
                                     ,pr_cdfiltro  IN INTEGER            --> Código do Filtro (1-Cálculo Empréstimo/2-Cálculo Conta Corrente/3-Ambos)
                                     ,pr_cdhistor  IN INTEGER            --> Código do Histórico
                                     ,pr_dshistor  IN VARCHAR2           --> Descrição do Histórico
                                     ,pr_xmllog    IN VARCHAR2           --> XML com informações de LOG
                                     ,pr_cdcritic OUT PLS_INTEGER        --> Código da crítica
                                     ,pr_dscritic OUT VARCHAR2           --> Descrição da crítica
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
    Objetivo  : Rotina para consultar a parametrização dos histórico

    ............................................................................. */
    DECLARE
      -- Exceção
      vr_exc_erro  EXCEPTION;
      
      -- Variáveis de erro
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic crapcri.dscritic%TYPE;
      
      -- CURSOR
      -- Pesquisar todos os históricos
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

        FROM craphis
       WHERE craphis.cdcooper = 3 -- Ler os históricos da CECRED 
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
          NULL; -- Na descrição não possui validação
          
        WHEN 'T' THEN
          NULL; -- Quando for todos não precisamos validar nada
          
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

                                                   ||'</historico>'));
          
      END LOOP;
      
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral (CYBE0003.pc_consultar_param_histor): ' || SQLERRM;
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;
  END pc_consultar_param_histor;
      
  PROCEDURE pc_manter_param_histor(pr_cddopcao  IN VARCHAR2           --> Opção (AH-Alterar)
                                  ,pr_xmllog    IN VARCHAR2           --> XML com informações de LOG
                                  ,pr_cdcritic OUT PLS_INTEGER        --> Código da crítica
                                  ,pr_dscritic OUT VARCHAR2           --> Descrição da crítica
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
    Objetivo  : Rotina para alterar a parametrização dos histórico

    Alteracoes:

    ............................................................................. */
    DECLARE
      -- Exceção
      vr_exc_erro  EXCEPTION;
      
      -- Variáveis de erro
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic crapcri.dscritic%TYPE;
      
      -- Array de Historicos Alterados
      vr_ret_all_historicos gene0002.typ_split;
      vr_ret_historico      gene0002.typ_split;
      
      vr_auxcont  INTEGER := 0;
      vr_cdhistor craphis.cdhistor%TYPE;
      vr_indcalem VARCHAR2(1); --craphis.indcalem%TYPE;
      vr_indcalcc VARCHAR2(1); --craphis.indcalcc%TYPE;

      
    BEGIN
      CASE pr_cddopcao 
        WHEN 'AH' THEN
          IF TRIM(pr_dshistor) IS NULL THEN
            vr_dscritic := 'Nenhum historico foi alterado.';
            RAISE vr_exc_erro;
          END IF;
          
          -- Criando um Array com todos os historicos que possuem alteracao no campo de Cálculo Empréstimo ou Cálculo Conta Corrente
          vr_ret_all_historicos := gene0002.fn_quebra_string(pr_dshistor, '|');
          
          -- Percorre todos os cheques para processá-los
          FOR vr_auxcont IN 1..vr_ret_all_historicos.count LOOP
            -- Zerar as informações do Tipo de Movimentação e da Ocorrencia
            vr_cdhistor := NULL;
            vr_indcalem := 'N';
            vr_indcalcc := 'N';


            -- Criando um array com todas as informações do cheque
            vr_ret_historico := gene0002.fn_quebra_string(vr_ret_all_historicos(vr_auxcont), ';');

            vr_cdhistor := to_number(vr_ret_historico(1));
            vr_indcalem := vr_ret_historico(2);
            vr_indcalcc := vr_ret_historico(3);

            
            -- Será atualizado os campos de Cálculo de Empréstimo e Cálculo de Conta Corrente para o histórico em todas as cooperativas
            UPDATE craphis
               SET craphis.indcalem = vr_indcalem
                  ,craphis.indcalcc = vr_indcalcc

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
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral (CYBE0003.pc_manter_param_histor): ' || SQLERRM;
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;
  END pc_manter_param_histor;

END CYBE0003;
/
