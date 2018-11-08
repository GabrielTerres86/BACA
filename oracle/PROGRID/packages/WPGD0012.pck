CREATE OR REPLACE PACKAGE PROGRID.WPGD0012 is
 ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : WPGD0019
  --  Sistema  : Replica as propostas do ano origem para o ano destino
  --  Sigla    : WPGD
  --  Autor    : Andrey Formigari (Mouts)
  --  Data     : Outubro/2018.                   Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Replica as propostas do ano origem para o ano destino
  --
  -- Alteracoes: 
  --
  ---------------------------------------------------------------------------------------------------------------

   PROCEDURE pc_replica_proposta(pr_cdcooper       IN crapppc.cdcooper%TYPE --> Codigo da Cooperativa
                                ,pr_cdagenci       IN crapage.cdagenci%TYPE --> Codigo da Cooperativa
                                ,pr_cdoperad       IN crapppc.cdoperad%TYPE
                                ,pr_idevento       IN crapsde.idevento%TYPE
                                ,pr_dtanoini       IN VARCHAR2
                                ,pr_dtanofim       IN VARCHAR2
                                ,pr_nrcpfcgc       IN VARCHAR2
                                ,pr_xmllog         IN VARCHAR2              --> XML com informações de LOG
                                ,pr_cdcritic       OUT PLS_INTEGER          --> Código da crítica
                                ,pr_dscritic       OUT VARCHAR2             --> Descrição da crítica
                                ,pr_retxml         IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                ,pr_nmdcampo       OUT VARCHAR2             --> Nome do campo com erro
                                ,pr_des_erro       OUT VARCHAR2);
END WPGD0012;
/
CREATE OR REPLACE PACKAGE BODY PROGRID.WPGD0012 IS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : WPGD0012
  --  Sistema  : Replica as propostas do ano origem para o ano destino
  --  Sigla    : WPGD
  --  Autor    : Andrey Formigari (Mouts)
  --  Data     : Outubro/2018.                   Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Replica as propostas do ano origem para o ano destino
  --
  -- Alteracoes: 
  ---------------------------------------------------------------------------------------------------------------
  
  PROCEDURE pc_replica_proposta(pr_cdcooper       IN crapppc.cdcooper%TYPE --> Codigo da Cooperativa
                               ,pr_cdagenci       IN crapage.cdagenci%TYPE --> Codigo da Cooperativa
                               ,pr_cdoperad       IN crapppc.cdoperad%TYPE
                               ,pr_idevento       IN crapsde.idevento%TYPE
                               ,pr_dtanoini       IN VARCHAR2
                               ,pr_dtanofim       IN VARCHAR2
                               ,pr_nrcpfcgc       IN VARCHAR2
                               ,pr_xmllog         IN VARCHAR2              --> XML com informações de LOG
                               ,pr_cdcritic       OUT PLS_INTEGER          --> Código da crítica
                               ,pr_dscritic       OUT VARCHAR2             --> Descrição da crítica
                               ,pr_retxml         IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                               ,pr_nmdcampo       OUT VARCHAR2             --> Nome do campo com erro
                               ,pr_des_erro       OUT VARCHAR2) IS
  
  
  -- Variável de críticas
  vr_cdcritic      crapcri.cdcritic%TYPE;
  vr_dscritic      VARCHAR2(10000);
  vr_exc_saida     EXCEPTION;
  
  BEGIN

    FOR rw_fornecedores IN (SELECT gnapfdp.nrcpfcgc
                              FROM gnapfdp
                             WHERE gnapfdp.nrcpfcgc = pr_nrcpfcgc) LOOP     -- buscando todos os fornecedores

       FOR rw_propostas IN (SELECT g.*
                              FROM gnappdp g
                      /*INNER JOIN crapedp c ON c.cdevento = g.cdevento*/
                             WHERE g.cdcooper = 0
                               AND g.nrcpfcgc = rw_fornecedores.nrcpfcgc
                             /*AND c.cdcooper = 0
                               AND c.dtanoage = 0*/
                               AND to_char(g.dtvalpro, 'YYYY') = pr_dtanoini) LOOP -- buscando todas as propostas de 2018

                 BEGIN -- duplica as propostas alterando o NRPROPOS PARA /2019
                     INSERT INTO gnappdp
                     (
                      IDEVENTO,
                      CDCOOPER,
                      NRCPFCGC,
                      NRPROPOS,
                      DTMVTOLT,
                      DTVALPRO,
                      NMEVEFOR,
                      CDEVENTO,
                      DSMETODO,
                      DSPUBLIC,
                      VLINVEST,
                      QTCARHOR,
                      DSRECURS,
                      DSOBSERV,
                      NRCTRPRO,
                      DSIDADPA,
                      DSPREREQ,
                      IDTRAINC,
                      NRSEQPAP,
                      IDFORREV,
                      DSCONTEU
                     )
                     VALUES
                     (
                      rw_propostas.IDEVENTO,
                      rw_propostas.CDCOOPER,
                      rw_propostas.NRCPFCGC,
                      SUBSTR(rw_propostas.NRPROPOS, 0, INSTR(rw_propostas.NRPROPOS, '/')) || pr_dtanofim ,
                      '01/01/' || pr_dtanofim,
                      '31/12/' || pr_dtanofim,
                      rw_propostas.NMEVEFOR,
                      rw_propostas.CDEVENTO,
                      rw_propostas.DSMETODO,
                      rw_propostas.DSPUBLIC,
                      rw_propostas.VLINVEST,
                      rw_propostas.QTCARHOR,
                      rw_propostas.DSRECURS,
                      rw_propostas.DSOBSERV,
                      rw_propostas.NRCTRPRO,
                      rw_propostas.DSIDADPA,
                      rw_propostas.DSPREREQ,
                      rw_propostas.IDTRAINC,
                      rw_propostas.NRSEQPAP,
                      rw_propostas.IDFORREV,
                      rw_propostas.DSCONTEU
                     );
                 EXCEPTION  -- exception handlers begin
                   WHEN OTHERS THEN  -- handles all other errors
                      --dbms_output.put_line('Erro ao Duplicar a proposta: '||SQLERRM);
                      vr_dscritic := 'Erro ao duplicar a proposta (CPF: ' || rw_propostas.NRCPFCGC || ');';
                   END;
                 
                 BEGIN
                     INSERT INTO gnfacep -- insere os Facilitador
                         (
                          CDCOOPER,
                          CDFACILI,
                          IDEVENTO,
                          NRCPFCGC,
                          NRPROPOS
                         )
                         SELECT
                            cep.cdcooper,
                            cep.cdfacili,
                            cep.idevento,
                            cep.nrcpfcgc,
                            SUBSTR(cep.nrpropos, 0, INSTR(cep.nrpropos, '/')) || pr_dtanofim AS nrpropos
                          FROM gnfacep cep
                         WHERE cep.cdcooper = rw_propostas.CDCOOPER
                           AND cep.idevento = rw_propostas.IDEVENTO
                           AND cep.nrcpfcgc = rw_propostas.NRCPFCGC
                           AND cep.nrpropos = rw_propostas.NRPROPOS;
                     
                 EXCEPTION   -- exception handlers begin
                     WHEN OTHERS THEN  -- handles all other errors
                         --dbms_output.put_line('Erro ao Duplicar o Facilitador: ' || SQLERRM);
                         vr_dscritic := vr_dscritic || 'Erro ao Duplicar o Facilitador (CPF: ' || rw_propostas.NRCPFCGC || ');';
                     END;
                     
                 BEGIN
                     INSERT INTO craprdf -- insere os Recursos
                     (
                        IDEVENTO,
                        CDCOOPER,
                        NRCPFCGC,
                        DSPROPOS,
                        NRSEQDIG,
                        QTRECFOR,
                        QTGRPPAR,
                        CDOPERAD,
                        DTATUALI,
                        CDCOPOPE
                     )
                     SELECT 
                        rdf.IDEVENTO,
                        rdf.CDCOOPER,
                        rdf.NRCPFCGC,
                        SUBSTR(rdf.DSPROPOS, 0, INSTR(rdf.DSPROPOS, '/')) || pr_dtanofim ,
                        rdf.NRSEQDIG,
                        rdf.QTRECFOR,
                        rdf.QTGRPPAR,
                        rdf.CDOPERAD,
                        rdf.DTATUALI,
                        rdf.CDCOPOPE
                       FROM craprdf rdf
                      WHERE rdf.idevento = rw_propostas.IDEVENTO
                        AND rdf.cdcooper = rw_propostas.CDCOOPER
                        AND rdf.dspropos = rw_propostas.NRPROPOS
                        AND rdf.nrcpfcgc = rw_propostas.NRCPFCGC;
                 EXCEPTION   -- exception handlers begin
                     WHEN OTHERS THEN  -- handles all other errors
                         --dbms_output.put_line('Erro ao Duplicar o Recurso: ' || SQLERRM);
                         vr_dscritic := vr_dscritic || 'Erro ao Duplicar o Recurso (CPF: ' || rw_propostas.NRCPFCGC || ');';
                     END;
                     
                 BEGIN
                     INSERT INTO GNAPPOB -- insere os Objetivos da proposta
                     (
                        IDEVENTO,
                        CDCOOPER,
                        NRCPFCGC,
                        NRPROPOS,
                        DSOBJETI
                     )
                     SELECT 
                        pop.IDEVENTO,
                        pop.CDCOOPER,
                        pop.NRCPFCGC,
                        SUBSTR(pop.NRPROPOS, 0, INSTR(pop.NRPROPOS, '/')) || pr_dtanofim,
                        pop.DSOBJETI
                       FROM GNAPPOB pop
                      WHERE pop.idevento = rw_propostas.IDEVENTO
                        AND pop.cdcooper = rw_propostas.CDCOOPER
                        AND pop.nrpropos = rw_propostas.NRPROPOS
                        AND pop.nrcpfcgc = rw_propostas.NRCPFCGC;
                 EXCEPTION   -- exception handlers begin
                     WHEN OTHERS THEN  -- handles all other errors
                         --dbms_output.put_line('Erro ao Duplicar o Objetivo da Proposta: ' || SQLERRM);
                         vr_dscritic := vr_dscritic || 'Erro ao Duplicar o Objetivo da Proposta (CPF: ' || rw_propostas.NRCPFCGC || ');';
                     END;

        END LOOP;
    END LOOP;
    
    IF vr_dscritic IS NOT NULL THEN
        pr_dscritic := 'Replicação concluída com sucesso, porém algumas críticas foram encontradas no processo. Verifique se suas propostas estão de acordo! Atenção: A página será atualizada!';
        pr_cdcritic := 0;
    END IF;
    
    COMMIT;
      
  EXCEPTION
    WHEN vr_exc_saida THEN

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;

      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

    WHEN OTHERS THEN

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral em PC_WPGD0012: ' || SQLERRM;

      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
  
  END pc_replica_proposta;
  
  
  
END WPGD0012;