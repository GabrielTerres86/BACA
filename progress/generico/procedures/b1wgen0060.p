/*.............................................................................

    Programa: b1wgen0060.p
    Autor   : Jose Luis Marchezoni (DB1)
    Data    : Marco/2010                   Ultima atualizacao: 19/06/2017

    Objetivo  : Realiza a busca de dados - retorno de descricoes p/ tela de 
                maneira dinamica

    Alteracoes: 10/08/2010 - Inclusao de parametro na function 
               "BuscaNaturezaJuridica", INPUT "dsnatjur" - (Jose Luis, DB1)
               
               16/06/2011 - Ignorar Nat Opcupacao = 99 (Gabriel)
               
               03/11/2011 - Alterado a funcao "BuscaTopico". Quando for a 
                            CENTRAL, os campos abaixo nao serao obrigatorios
                            - Patr. pessoal dos garant. ou socios livre de onus 
		                    - Percepcao geral com relacao a empresa
                            (Adriano).
               
               27/03/2012 - Incluido "Menor/Maior" no case da funcao 
                            BuscaHabilitacao para quando inhabmen = 0 e 
                            alterado a descrição de Habilitado para Emancipado
                            (Adriano).

               02/08/2016 - Inclusao insitage 3-Temporariamente Indisponivel.
                            (Jaison/Anderson)                                             

               19/06/2017 - Ajuste para inclusao do novo tipo de situacao da conta
  				             "Desligamento por determinação do BACEN" 
							( Jonata - RKAM P364).							

.............................................................................*/


/*................................ DEFINICOES ...............................*/
DEFINE VARIABLE aux_qtregist AS INTEGER     NO-UNDO.

/*................................ PROCEDURES ...............................*/
PROCEDURE Busca_Valor:

    DEFINE INPUT  PARAMETER par_tabela AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_campo  AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_filtro AS CHARACTER   NO-UNDO.
    DEFINE OUTPUT PARAMETER par_qtreg  AS INTEGER     NO-UNDO.
    DEFINE OUTPUT PARAMETER par_valor  AS CHARACTER   NO-UNDO.
    
    DEFINE VARIABLE hQuery     AS HANDLE    NO-UNDO.
    DEFINE VARIABLE hBuffer    AS HANDLE    NO-UNDO.
    DEFINE VARIABLE aux_cont   AS INTEGER   NO-UNDO.
    DEFINE VARIABLE aux_filtro AS CHARACTER NO-UNDO.

    DO aux_cont = 1 TO NUM-ENTRIES(par_filtro):
        ASSIGN aux_filtro = aux_filtro + par_tabela + "." + 
                            TRIM(ENTRY(aux_cont,par_filtro)) + " ".

        IF  aux_cont <> NUM-ENTRIES(par_filtro) THEN
            ASSIGN aux_filtro = aux_filtro + " AND ".
    END.

    /*Cria buffers e Query*/
    CREATE BUFFER hBuffer FOR TABLE par_tabela.
    CREATE QUERY hQuery.
    hQuery:SET-BUFFERS(hBuffer).
    hQuery:QUERY-PREPARE("FOR EACH " + par_tabela + " "  +
                         "FIELDS("   + par_campo  + ") " +
                         "WHERE "    + aux_filtro + " "  +
                         "NO-LOCK") NO-ERROR.
    hQuery:QUERY-OPEN() NO-ERROR.
    IF  ERROR-STATUS:ERROR THEN
        DO:
           ASSIGN par_valor = ERROR-STATUS:GET-MESSAGE(1).
           RETURN "NOK".
        END.

    hQuery:GET-FIRST(NO-LOCK).
    REPEAT:
       IF hQuery:QUERY-OFF-END THEN 
          LEAVE.
    
       DO aux_cont = 1 TO hBuffer:NUM-FIELDS:
           IF  hBuffer:BUFFER-FIELD(aux_cont):NAME = par_campo THEN DO:
               par_valor = STRING(hBuffer:BUFFER-FIELD(aux_cont):BUFFER-VALUE).
               LEAVE.
           END.
       END.
    
       IF  par_valor <> "" THEN
           LEAVE.
    
       hQuery:GET-NEXT(NO-LOCK).
    END.
    
        /* retornar a quantidade de registros encontrados */
    ASSIGN par_qtreg = hQuery:NUM-RESULTS.

    hQuery:QUERY-CLOSE().
    DELETE OBJECT hBuffer.
    DELETE OBJECT hQuery.
    
    RETURN "OK".

END PROCEDURE.

/*................................. FUNCTIONS ................................*/
FUNCTION BuscaCritica RETURNS CHARACTER
        ( INPUT par_cdcritic AS INTEGER ):

    DEFINE VARIABLE aux_dscritic AS CHARACTER   NO-UNDO.

    RUN Busca_Valor 
        ( INPUT "crapcri",
          INPUT "dscritic",
          INPUT "cdcritic = " + STRING(par_cdcritic),
         OUTPUT aux_qtregist,
         OUTPUT aux_dscritic ).

    IF  aux_qtregist = 0 THEN 
        ASSIGN aux_dscritic = "Erro ao pesquisar criticas." .
        
    RETURN aux_dscritic.

END FUNCTION.

/* Estado Civil */
FUNCTION BuscaEstadoCivil RETURNS LOGICAL
        ( INPUT  par_cdestcvl AS INTEGER,
      INPUT  par_nmdcampo AS CHARACTER,
      OUTPUT par_dsestcvl AS CHARACTER,
      OUTPUT par_dscritic AS CHARACTER ):

    RUN Busca_Valor 
        ( INPUT "gnetcvl",
          INPUT par_nmdcampo,
          INPUT "cdestcvl = " + STRING(par_cdestcvl),
         OUTPUT aux_qtregist,
         OUTPUT par_dsestcvl ).

    IF  par_dsestcvl = "" THEN
        ASSIGN par_dsestcvl = "NAO INFORMADO".

    IF  aux_qtregist = 0 THEN
        ASSIGN par_dscritic = BuscaCritica(35).
        
    RETURN (par_dsestcvl <> "NAO INFORMADO").

END FUNCTION.

FUNCTION BuscaTpContrTrab RETURNS LOGICAL
    ( INPUT  par_tpcttrab AS INTEGER,
      OUTPUT par_dsctrtab AS CHARACTER,
      OUTPUT par_dscritic AS CHARACTER ) :

    CASE par_tpcttrab:
        WHEN 1 THEN ASSIGN par_dsctrtab = "PERMANENTE".
        WHEN 2 THEN ASSIGN par_dsctrtab = "TEMP/TERCEIRO".
        WHEN 3 THEN ASSIGN par_dsctrtab = "SEM VINCULO".
        OTHERWISE 
            ASSIGN 
               par_dsctrtab = "NAO CADASTRADO"
               par_dscritic = "Tipo do contrato de trabalho nao cadastrado".
    END CASE.

    RETURN (par_dsctrtab <> "NAO CADASTRADO").

END FUNCTION.

FUNCTION BuscaNivelCargo RETURNS LOGICAL
    ( INPUT  par_cdnvlcgo AS INTEGER,
      OUTPUT par_rsnvlcgo AS CHARACTER,
      OUTPUT par_dscritic AS CHARACTER ) :

    RUN Busca_Valor 
        ( INPUT "gncdncg",
          INPUT "rsnvlcgo",
          INPUT "cdnvlcgo = " + STRING(par_cdnvlcgo),
         OUTPUT aux_qtregist,
         OUTPUT par_rsnvlcgo ).

    IF  par_rsnvlcgo = "" THEN
        ASSIGN par_rsnvlcgo = "NAO INFORMADO".

    IF  aux_qtregist = 0 THEN
        ASSIGN par_dscritic = "Nivel do cargo nao cadastrado".
        
    RETURN (par_rsnvlcgo <> "").

END FUNCTION.

FUNCTION BuscaNatOcupacao RETURNS LOGICAL
    ( INPUT  par_cdnatocp AS INTEGER,
      OUTPUT par_rsnatocp AS CHARACTER,
      OUTPUT par_dscritic AS CHARACTER ) :

    RUN Busca_Valor 
        ( INPUT "gncdnto",
          INPUT "rsnatocp",
          INPUT "cdnatocp = " + STRING(par_cdnatocp),
          OUTPUT aux_qtregist,
         OUTPUT par_rsnatocp ).

    IF  par_rsnatocp = "" THEN
        ASSIGN par_rsnatocp = "NAO INFORMADO".

    IF  par_cdnatocp = 99   THEN
        ASSIGN par_rsnatocp = "NAO CADASTRADO".

    IF  aux_qtregist = 0 OR 
        par_cdnatocp = 99 THEN
        ASSIGN par_dscritic = BuscaCritica(827).

    RETURN (par_rsnatocp <> "NAO CADASTRADO").

END FUNCTION.

FUNCTION BuscaOcupacao    RETURNS LOGICAL
    ( INPUT  par_cddocupa AS INTEGER,
      OUTPUT par_rsdocupa AS CHARACTER,
      OUTPUT par_dscritic AS CHARACTER ) :

    RUN Busca_Valor 
        ( INPUT "gncdocp",
          INPUT "rsdocupa",
          INPUT "cdocupa = " + STRING(par_cddocupa),
         OUTPUT aux_qtregist,
         OUTPUT par_rsdocupa ).

    IF  par_rsdocupa = "" THEN
        ASSIGN par_rsdocupa = "NAO INFORMADO".

    IF  aux_qtregist = 0 THEN
        ASSIGN par_dscritic = "Ocupacao nao cadastrada".

    RETURN (par_rsdocupa <> "NAO CADASTRADO").

END FUNCTION.

FUNCTION BuscaTurnos      RETURNS LOGICAL
    ( INPUT  par_cdcooper AS INTEGER,
      INPUT  par_cdturnos AS INTEGER,
      OUTPUT par_dsturnos AS CHARACTER,
      OUTPUT par_dscritic AS CHARACTER ) :

    RUN Busca_Valor 
        ( INPUT "craptab",
          INPUT "dstextab",
          INPUT ("cdcooper = " + STRING(par_cdcooper) + " ," +
                "nmsistem = " + QUOTER("CRED")       + " ," +
                "tptabela = " + QUOTER("GENERI")     + " ," +
                "cdempres = " + STRING(0)            + " ," +
                "cdacesso = " + QUOTER("DSCDTURNOS") + " ," +
                "tpregist = " + STRING(par_cdturnos)),
         OUTPUT aux_qtregist,
         OUTPUT par_dsturnos ).

    IF  par_dsturnos = "" THEN
        ASSIGN par_dsturnos = "NAO INFORMADO".

    IF  aux_qtregist = 0 THEN
        ASSIGN par_dscritic = BuscaCritica(43).

    RETURN (par_dsturnos <> "NAO CADASTRADO").

END FUNCTION.

FUNCTION BuscaGrauEscolar RETURNS LOGICAL 
        ( INPUT  par_grescola AS INTEGER,
      OUTPUT par_dsescola AS CHARACTER,
      OUTPUT par_dscritic AS CHARACTER ):

    RUN Busca_Valor 
        ( INPUT "gngresc",
          INPUT "dsescola",
          INPUT "grescola = " + STRING(par_grescola),
         OUTPUT aux_qtregist,
         OUTPUT par_dsescola ).

    IF  par_dsescola = "" THEN
        ASSIGN par_dsescola = "NAO INFORMADO".

    IF  aux_qtregist = 0 THEN
        ASSIGN par_dscritic = BuscaCritica(825).

        RETURN (par_dsescola <> "NAO INFORMADO").

END FUNCTION.

FUNCTION BuscaFormacao RETURNS LOGICAL 
    ( INPUT  par_cdfrmttl AS INTEGER,
      OUTPUT par_rsfrmttl AS CHARACTER,
      OUTPUT par_dscritic AS CHARACTER ):

    RUN Busca_Valor 
        ( INPUT "gncdfrm",
          INPUT "rsfrmttl",
          INPUT "cdfrmttl = " + STRING(par_cdfrmttl),
         OUTPUT aux_qtregist,
         OUTPUT par_rsfrmttl ).

    IF  par_rsfrmttl = "" THEN
        ASSIGN par_rsfrmttl = "NAO INFORMADO".

    IF  aux_qtregist = 0 THEN
        ASSIGN par_dscritic = BuscaCritica(826).

        RETURN (par_rsfrmttl <> "NAO INFORMADO").

END FUNCTION.

/* Natureza Juridica */
FUNCTION BuscaNaturezaJuridica RETURNS LOGICAL 
    ( INPUT  par_cdnatjur AS INTEGER,
      INPUT  par_nmdcampo AS CHARACTER,
      OUTPUT par_dsnatjur AS CHARACTER,
      OUTPUT par_dscritic AS CHARACTER ):

    IF  par_nmdcampo = "" THEN
        ASSIGN par_nmdcampo = "dsnatjur".

    RUN Busca_Valor 
        ( INPUT "gncdntj",
          INPUT par_nmdcampo,
          INPUT "cdnatjur = " + STRING(par_cdnatjur),
         OUTPUT aux_qtregist,
         OUTPUT par_dsnatjur ).

    IF  par_dsnatjur = "" THEN
        ASSIGN par_dsnatjur = "NAO CADASTRADO".

    IF  aux_qtregist = 0 THEN
        ASSIGN par_dscritic = "Natureza Juridica nao cadastrada.".

        RETURN (par_dsnatjur <> "NAO CADASTRADO").

END FUNCTION.

/* Setor economico */
FUNCTION BuscaSetorEconomico RETURNS LOGICAL 
    ( INPUT  par_cdcooper AS INTEGER,
      INPUT  par_cdseteco AS INTEGER,
      OUTPUT par_nmseteco AS CHARACTER,
      OUTPUT par_dscritic AS CHARACTER ):

    RUN Busca_Valor 
        ( INPUT "craptab",
          INPUT "dstextab",
          INPUT ("cdcooper = " + STRING(par_cdcooper) + " ," +
                 "cdacesso = " + QUOTER("SETORECONO") + " ," +
                 "tpregist = " + STRING(par_cdseteco)),
         OUTPUT aux_qtregist,
         OUTPUT par_nmseteco ).

    IF  par_nmseteco = "" THEN
        ASSIGN par_nmseteco = "NAO INFORMADO".

    IF  aux_qtregist = 0 THEN
        ASSIGN par_dscritic = BuscaCritica(879).

    RETURN (par_nmseteco <> "NAO INFORMADO").

END FUNCTION.

/* Ramo de Atividade */
FUNCTION BuscaRamoAtividade RETURNS LOGICAL 
    ( INPUT  par_cdseteco AS INTEGER,
      INPUT  par_cdrmativ AS INTEGER,
      OUTPUT par_dsrmativ AS CHARACTER,
      OUTPUT par_dscritic AS CHARACTER ):
    
    RUN Busca_Valor 
        ( INPUT "gnrativ",
          INPUT "nmrmativ",
          INPUT ("cdseteco = " + STRING(par_cdseteco) + " ," +
                 "cdrmativ = " + STRING(par_cdrmativ)),
         OUTPUT aux_qtregist,
         OUTPUT par_dsrmativ ).

    IF  par_dsrmativ = "" THEN
        ASSIGN par_dsrmativ = "NAO CADASTRADO".

    IF  aux_qtregist = 0 THEN
        ASSIGN par_dscritic = BuscaCritica(878).

        RETURN (par_dsrmativ <> "NAO CADASTRADO").

END FUNCTION.

FUNCTION Trata_eou RETURN CHARACTER
    ( INPUT par_nmsegttl AS CHARACTER ):

    DEFINE VARIABLE aux_nmretorn AS CHAR   NO-UNDO.

    ASSIGN aux_nmretorn = "".

    IF   NOT (par_nmsegttl = "") THEN
         DO:
              IF   SUBSTR(par_nmsegttl,1,4) = "E/OU"  OR   
                   SUBSTR(par_nmsegttl,1,5) = " E/OU" OR   
                   SUBSTR(par_nmsegttl,1,5) = "E /OU" OR  
                   SUBSTR(par_nmsegttl,1,5) = "E/ OU" OR  
                   SUBSTR(par_nmsegttl,1,5) = "/ OU " OR  
                   SUBSTR(par_nmsegttl,1,5) = "E OU/" OR  
                   SUBSTR(par_nmsegttl,1,5) = "E OU " OR  
                   SUBSTR(par_nmsegttl,1,5) = "/E OU" OR  
                   SUBSTR(par_nmsegttl,1,2) = "/ "    OR
                   SUBSTR(par_nmsegttl,1,1) = "/"     OR
                   SUBSTR(par_nmsegttl,1,3) = "OU "   OR
                   SUBSTR(par_nmsegttl,1,2) = "E "    THEN
                   ASSIGN aux_nmretorn = par_nmsegttl.
              ELSE     
                   ASSIGN aux_nmretorn = "E/OU " + par_nmsegttl.
         END.  

    RETURN aux_nmretorn.

END FUNCTION.

FUNCTION ValidaCpfCnpj RETURNS LOGICAL 
    ( INPUT  par_nrcpfcgc AS CHARACTER,
      OUTPUT par_dscritic AS CHARACTER ):

    DEFINE VARIABLE h-b1wgen9999 AS HANDLE      NO-UNDO.
    DEFINE VARIABLE aux_stsnrcal AS LOGICAL     NO-UNDO.
    DEFINE VARIABLE aux_inpessoa AS INTEGER     NO-UNDO.

    /* Se houve erro na conversao para DEC, faz a critica */
    DEC(par_nrcpfcgc) NO-ERROR.
    
    IF  ERROR-STATUS:ERROR THEN
        DO:
           ASSIGN par_dscritic = "CPF/CNPJ contem caracteres invalidos, deve" +
                                 " possuir apenas numeros.".
           RETURN FALSE.
        END.

    IF  DECI(par_nrcpfcgc) = 0  THEN
        RETURN TRUE.

    IF  NOT VALID-HANDLE(h-b1wgen9999) THEN
        RUN sistema/generico/procedures/b1wgen9999.p 
            PERSISTENT SET h-b1wgen9999.

    RUN valida-cpf-cnpj IN h-b1wgen9999 (INPUT par_nrcpfcgc,
                                         OUTPUT aux_stsnrcal,
                                         OUTPUT aux_inpessoa).

    DELETE PROCEDURE h-b1wgen9999.

    IF  NOT aux_stsnrcal THEN
        ASSIGN par_dscritic = BuscaCritica(27).

    RETURN aux_stsnrcal.
        
END FUNCTION.

FUNCTION BuscaParentesco RETURNS LOGICAL 
    ( INPUT  par_cdgraupr AS INTEGER,
      OUTPUT par_dsgraupr AS CHARACTER,
      OUTPUT par_dscritic AS CHARACTER ):

    CASE par_cdgraupr:
        WHEN 1 THEN par_dsgraupr = "CONJUGE".
        WHEN 2 THEN par_dsgraupr = "PAI/MAE".
        WHEN 3 THEN par_dsgraupr = "FILHO(A)".
        WHEN 4 THEN par_dsgraupr = "COMPANHEIRO(A)".
        WHEN 5 THEN par_dsgraupr = "".
        WHEN 6 THEN par_dsgraupr = "COOPERADO(A)". 
        OTHERWISE ASSIGN par_dscritic = BuscaCritica(23).
    END CASE.

        RETURN (par_dsgraupr <> "" OR par_cdgraupr = 5).
        
END FUNCTION.

FUNCTION BuscaHabilitacao RETURNS LOGICAL 
    ( INPUT  par_inhabmen AS INTEGER,
      OUTPUT par_dshabmen AS CHARACTER,
      OUTPUT par_dscritic AS CHARACTER ):

    CASE par_inhabmen:
        WHEN 1 THEN ASSIGN par_dshabmen = "- EMANCIPADO".
        WHEN 2 THEN ASSIGN par_dshabmen = "- INC. CIVIL".
        WHEN 0 THEN ASSIGN par_dshabmen = "- MENOR/MAIOR".
        OTHERWISE DO: 
            ASSIGN par_dscritic = "Habilitacao incorreta.".
            RETURN FALSE.
        END.
    END CASE.

        RETURN TRUE.
        
END FUNCTION.

/* Situacao do CPF/CNPJ */
FUNCTION BuscaSituacaoCpf RETURNS LOGICAL 
    ( INPUT  par_cdsitcpf AS INTEGER,
      OUTPUT par_dssitcpf AS CHARACTER,
      OUTPUT par_dscritic AS CHARACTER ):

    CASE par_cdsitcpf:
        WHEN 1 THEN ASSIGN par_dssitcpf = "(Regular)".
        WHEN 2 THEN ASSIGN par_dssitcpf = "(Pendente)".
        WHEN 3 THEN ASSIGN par_dssitcpf = "(CANCELADO)".
        WHEN 4 THEN ASSIGN par_dssitcpf = "(IRREGULAR)".
        WHEN 5 THEN ASSIGN par_dssitcpf = "(SUSPENSO)".
        OTHERWISE ASSIGN par_dscritic = "Situacao do CPF invalida.".
    END CASE.

    RETURN (par_dssitcpf <> "").
        
END FUNCTION.

/* Tipo de Nacionalidade */
FUNCTION BuscaTipoNacion RETURNS LOGICAL 
    ( INPUT  par_tpnacion AS INTEGER,
      INPUT  par_nmdcampo AS CHARACTER,
      OUTPUT par_restpnac AS CHARACTER,
      OUTPUT par_dscritic AS CHARACTER ):

    /* nmdcampo = restpnac (resumido) ou destpnac (completo)*/

    RUN Busca_Valor 
        ( INPUT "gntpnac",
          INPUT par_nmdcampo,
          INPUT "tpnacion = " + STRING(par_tpnacion),
         OUTPUT aux_qtregist,
         OUTPUT par_restpnac ).

    IF  par_restpnac = "" THEN
        ASSIGN par_restpnac = "NAO CADASTRADO".

    IF  aux_qtregist = 0 THEN
        ASSIGN par_dscritic = "Tipo de Nacionalidade nao cadastrada.".

        RETURN (par_restpnac <> "NAO CADASTRADO").

END FUNCTION.

FUNCTION BuscaBanco RETURNS LOGICAL 
    ( INPUT  par_cdbccxlt AS INTEGER,
      OUTPUT par_nmextbcc AS CHARACTER,
      OUTPUT par_dscritic AS CHARACTER ):

    RUN Busca_Valor 
        ( INPUT "crapban",
          INPUT "nmextbcc",
          INPUT "cdbccxlt = " + STRING(par_cdbccxlt),
         OUTPUT aux_qtregist,
         OUTPUT par_nmextbcc ).

    IF  par_nmextbcc = "" THEN
        ASSIGN par_nmextbcc = "NAO CADASTRADO".

    IF  aux_qtregist = 0 THEN
        ASSIGN par_dscritic = BuscaCritica(57).

        RETURN (par_nmextbcc <> "NAO CADASTRADO").

END FUNCTION.

FUNCTION BuscaAgencia RETURNS LOGICAL 
    ( INPUT  par_cddbanco AS INTEGER,
      INPUT  par_cdageban AS INTEGER,
      OUTPUT par_nmageban AS CHARACTER,
      OUTPUT par_dscritic AS CHARACTER ):

    RUN Busca_Valor 
        ( INPUT "crapagb",
          INPUT "nmageban",
          INPUT ("cddbanco = " + STRING(par_cddbanco) + " ," +
                 "cdageban = " + STRING(par_cdageban)),
         OUTPUT aux_qtregist,
         OUTPUT par_nmageban ).

    IF  par_nmageban = "" THEN
        ASSIGN par_nmageban = "NAO CADASTRADO".

    IF  aux_qtregist = 0 THEN
        ASSIGN par_dscritic = BuscaCritica(15).

        RETURN (par_nmageban <> "NAO CADASTRADO").

END FUNCTION.

FUNCTION BuscaTopico RETURNS LOGICAL 
    ( INPUT  par_cdcooper AS INTEGER,
      INPUT  par_nrtopico AS INTEGER,
      INPUT  par_nritetop AS INTEGER,
      INPUT  par_nrseqite AS INTEGER,
      OUTPUT par_dsseqite AS CHARACTER,
      OUTPUT par_dscritic AS CHARACTER ):

          
    IF ((par_nrtopico = 3   AND
         par_nritetop = 9   AND
         par_nrseqite = 0)  OR
        (par_nrtopico = 3   AND
         par_nritetop = 11  AND
         par_nrseqite = 0)) AND
         par_cdcooper = 3  THEN
         RETURN (TRUE).

    RUN Busca_Valor 
        ( INPUT "craprad",
          INPUT "dsseqite",
          INPUT ("cdcooper = " + STRING(par_cdcooper) + " ," +
                 "nrtopico = " + STRING(par_nrtopico) + " ," +
                 "nritetop = " + STRING(par_nritetop) + " ," +
                 "nrseqite = " + STRING(par_nrseqite)),
         OUTPUT aux_qtregist,
         OUTPUT par_dsseqite ).
    
    IF  par_dsseqite = "" THEN
        ASSIGN par_dsseqite = "NAO CADASTRADO".
    
    IF  aux_qtregist = 0 THEN
        DO:
           CASE par_nrtopico:
               WHEN 1 THEN DO:
                   CASE par_nritetop:
                       WHEN 4 THEN 
                           ASSIGN par_dscritic = "Informacoes Cadastrais".
                   END CASE.
               END.
               WHEN 1 THEN DO:
                   CASE par_nritetop:
                       WHEN 8 THEN 
                           ASSIGN par_dscritic = "Patr.pessoal livre de " +
                                                 "endividamento".
                   END CASE.
               END.
               WHEN 3 THEN DO:
                   CASE par_nritetop:
                       WHEN 9 THEN
                           ASSIGN par_dscritic = "Patr.pessoal livre de " +
                                                 "endividamento".
                   END CASE.
               END.
               WHEN 3 THEN DO:
                   CASE par_nritetop:
                       WHEN 3 THEN
                           ASSIGN par_dscritic = "Informacoes Cadastrais".
                       WHEN 11 THEN
                           ASSIGN par_dscritic = "Percepcao Geral da Empresa".
                   END CASE.
               END.
           END CASE.
    
           ASSIGN par_dscritic = par_dscritic + " incorreto(a).".

        END.
    
    RETURN (par_dsseqite <> "NAO CADASTRADO" AND aux_qtregist <> 0).
    


END FUNCTION.

FUNCTION BuscaOperador RETURNS LOGICAL 
    ( INPUT  par_cdcooper AS INTEGER,
      INPUT  par_cdoperad AS CHARACTER,
      OUTPUT par_nmoperad AS CHARACTER,
      OUTPUT par_dscritic AS CHARACTER ):

    RUN Busca_Valor 
        ( INPUT "crapope",
          INPUT "nmoperad",
          INPUT ("cdcooper = " + STRING(par_cdcooper) + " ," +
                 "cdoperad = " + QUOTER(par_cdoperad)),
         OUTPUT aux_qtregist,
         OUTPUT par_nmoperad ).

    IF  par_nmoperad = "" THEN
        ASSIGN par_nmoperad = "NAO CADASTRADO".

    IF  aux_qtregist = 0 THEN
        ASSIGN par_dscritic = BuscaCritica(67).

        RETURN (par_nmoperad <> "NAO CADASTRADO").

END FUNCTION.

FUNCTION BuscaSituacaoConta RETURNS LOGICAL 
    ( INPUT  par_cdsitdct AS INTEGER,
      OUTPUT par_dssitdct AS CHARACTER,
      OUTPUT par_dscritic AS CHARACTER ):

    CASE par_cdsitdct:
        WHEN 1 THEN ASSIGN par_dssitdct = "NORMAL".
        WHEN 2 THEN ASSIGN par_dssitdct = "ENCERRADA PELO ASSOCIADO".
        WHEN 3 THEN ASSIGN par_dssitdct = "ENCERRADA PELA COOP".
        WHEN 4 THEN ASSIGN par_dssitdct = "ENCERRADA PELA DEMISSAO".
        WHEN 5 THEN ASSIGN par_dssitdct = "NAO APROVADA".
        WHEN 6 THEN ASSIGN par_dssitdct = "NORMAL - SEM TALAO".
        WHEN 7 THEN ASSIGN par_dssitdct = "EM PROC. DEMISSAO".
		WHEN 8 THEN ASSIGN par_dssitdct = "EM PROC. DEM. BACEN".
        WHEN 9 THEN ASSIGN par_dssitdct = "ENCERRADA P/ OUTRO MOTIVO".
		
        OTHERWISE 
            ASSIGN par_dssitdct = ""
                   par_dscritic = "Situacao de Conta Inexistente.".
    END CASE.

    RETURN (par_dssitdct <> "").
        
END FUNCTION.

/* Agencia - PAC */
FUNCTION BuscaPac RETURNS LOGICAL 
    ( INPUT  par_cdcooper AS INTEGER,
      INPUT  par_cdagepac AS INTEGER,
      INPUT  par_nmdcampo AS CHARACTER,
      OUTPUT par_dsagepac AS CHARACTER,
      OUTPUT par_dscritic AS CHARACTER ):

    DEFINE VARIABLE aux_insitage AS CHAR     NO-UNDO.

    /* nmdcampo = "nmextage" ou "nmresage" */

    RUN Busca_Valor 
        ( INPUT "crapage",
          INPUT par_nmdcampo,
          INPUT ("cdcooper = " + STRING(par_cdcooper) + " ," +
                 "cdagenci = " + STRING(par_cdagepac)),
         OUTPUT aux_qtregist,
         OUTPUT par_dsagepac ).

    IF  aux_qtregist = 0 THEN
        ASSIGN par_dscritic = BuscaCritica(15).
    ELSE
        DO:
            RUN Busca_Valor 
                ( INPUT "crapage",
                  INPUT "insitage",
                  INPUT ("cdcooper = " + STRING(par_cdcooper) + " ," +
                         "cdagenci = " + STRING(par_cdagepac)),
                 OUTPUT aux_qtregist,
                 OUTPUT aux_insitage ).
        
            IF  INTEGER(aux_insitage) <> 1   AND   /* Ativo */
                INTEGER(aux_insitage) <> 3   THEN  /* Temporariamente Indisponivel */
                ASSIGN par_dscritic = BuscaCritica(856).
        END.
    
        RETURN (par_dscritic = "").

END FUNCTION.

/* Destino do Extrato */
FUNCTION BuscaDestExt RETURNS LOGICAL 
    ( INPUT  par_cdcooper AS INTEGER,
      INPUT  par_cdagepac AS INTEGER,
      INPUT  par_cdsecext AS INTEGER,
      OUTPUT par_dssecext AS CHARACTER,
      OUTPUT par_dscritic AS CHARACTER ):

    RUN Busca_Valor 
        ( INPUT "crapdes",
          INPUT "nmsecext",
          INPUT ("cdcooper = " + STRING(par_cdcooper) + " ," +
                 "cdagenci = " + STRING(par_cdagepac) + " ," +
                 "cdsecext = " + STRING(par_cdsecext)),
         OUTPUT aux_qtregist,
         OUTPUT par_dssecext ).

    IF  aux_qtregist = 0 THEN
        ASSIGN par_dscritic = BuscaCritica(19).

        RETURN (par_dscritic = "").

END FUNCTION.

/* Tipo da Conta */
FUNCTION BuscaTipoConta RETURNS LOGICAL 
    ( INPUT  par_cdcooper AS INTEGER,
      INPUT  par_cdtipcta AS INTEGER,
      OUTPUT par_dstipcta AS CHARACTER,
      OUTPUT par_dscritic AS CHARACTER ):

    RUN Busca_Valor 
        ( INPUT "craptip",
          INPUT "dstipcta",
          INPUT ("cdcooper = " + STRING(par_cdcooper) + " ," +
                 "cdtipcta = " + STRING(par_cdtipcta)),
         OUTPUT aux_qtregist,
         OUTPUT par_dstipcta ).

    IF  aux_qtregist = 0 THEN
        ASSIGN par_dscritic = BuscaCritica(17).

        RETURN (par_dscritic = "").

END FUNCTION.

/* Tipo de Rendimento */
FUNCTION BuscaTipoRendimento RETURNS LOGICAL
    ( INPUT  par_cdcooper AS INTE,
      INPUT  par_tpdrendi AS INTE,
      OUTPUT par_dstipren AS CHAR,
      OUTPUT par_dscritic AS CHAR ):

    /* Descricao do rendimento */
    RUN Busca_Valor 
        ( INPUT "craptab",
          INPUT "dstextab",
          INPUT ("cdcooper = " + STRING(par_cdcooper) + " ," +
                "nmsistem = " + QUOTER("CRED")       + " ," +
                "tptabela = " + QUOTER("GENERI")     + " ," +
                "cdempres = " + STRING(0)            + " ," +
                "cdacesso = " + QUOTER("DSRENDIMEN") + " ," +
                "tpregist = " + STRING(par_tpdrendi)),
         OUTPUT aux_qtregist,
         OUTPUT par_dstipren ).

    IF  par_dstipren = "" THEN
        ASSIGN par_dstipren = "NAO CADASTRADO".

    IF  aux_qtregist = 0 THEN
        ASSIGN par_dscritic = "Tipo do Rendimento nao cadastrado".

    RETURN (par_dstipren <> "NAO CADASTRADO").

END FUNCTION.

/* Empresa */
FUNCTION BuscaEmpresa RETURNS LOGICAL 
    ( INPUT  par_cdcooper AS INTEGER,
      INPUT  par_cdempres AS INTEGER,
      OUTPUT par_nmresemp AS CHARACTER,
      OUTPUT par_dscritic AS CHARACTER ):

    RUN Busca_Valor 
        ( INPUT "crapemp",
          INPUT "nmresemp",
          INPUT ("cdcooper = " + STRING(par_cdcooper) + " ," +
                 "cdempres = " + STRING(par_cdempres)),
         OUTPUT aux_qtregist,
         OUTPUT par_nmresemp ).

    IF  par_nmresemp = "" THEN
        ASSIGN par_nmresemp = "NAO CADASTRADA".

    IF  aux_qtregist = 0 THEN
        ASSIGN par_dscritic = BuscaCritica(40).

        RETURN (par_nmresemp <> "NAO CADASTRADO").

END FUNCTION.

/* Tipo Extrato de Conta */
FUNCTION BuscaTipoExtrato RETURNS LOGICAL 
    ( INPUT  par_tpextcta AS INTEGER,
      OUTPUT par_dsextcta AS CHARACTER,
      OUTPUT par_dscritic AS CHARACTER ):

    CASE par_tpextcta:
        WHEN 0 THEN ASSIGN par_dsextcta = "NAO EMITE".
        WHEN 1 THEN ASSIGN par_dsextcta = "MENSAL".
        WHEN 2 THEN ASSIGN par_dsextcta = "QUINZENAL".
        OTHERWISE ASSIGN par_dscritic = BuscaCritica(264).
    END CASE.

        RETURN (par_dscritic = "").

END FUNCTION.

/* Tipo Emissao de Aviso */
FUNCTION BuscaTipoAviso RETURNS LOGICAL 
    ( INPUT  par_tpavsdeb AS INTEGER,
      OUTPUT par_dsavsdeb AS CHARACTER,
      OUTPUT par_dscritic AS CHARACTER ):

    CASE par_tpavsdeb:
        WHEN 0 THEN ASSIGN par_dsavsdeb = "NAO EMITE".
        WHEN 1 THEN ASSIGN par_dsavsdeb = "EMITE".
        OTHERWISE ASSIGN par_dscritic = "Tipo de Emissao de aviso invalido".
    END CASE.

        RETURN (par_dscritic = "").

END FUNCTION.

/* Motivo Demissao */
FUNCTION BuscaMotivoDemi RETURNS LOGICAL
    ( INPUT  par_cdcooper AS INTE,
      INPUT  par_cdmotdem AS INTE,
      OUTPUT par_dsmotdem AS CHAR,
      OUTPUT par_dscritic AS CHAR ):

    RUN Busca_Valor 
        ( INPUT "craptab",
          INPUT "dstextab",
          INPUT ("cdcooper = " + STRING(par_cdcooper) + " ," +
                 "nmsistem = " + QUOTER("CRED")       + " ," +
                 "tptabela = " + QUOTER("GENERI")     + " ," +
                 "cdempres = " + STRING(0)            + " ," +
                 "cdacesso = " + QUOTER("MOTIVODEMI") + " ," +
                 "tpregist = " + STRING(par_cdmotdem)),
         OUTPUT aux_qtregist,
         OUTPUT par_dsmotdem ).

    IF  par_dsmotdem = "" THEN
        ASSIGN par_dsmotdem = "NAO CADASTRADO".

    IF  aux_qtregist = 0 THEN
        ASSIGN par_dscritic = BuscaCritica(848).

    RETURN (par_dsmotdem <> "NAO CADASTRADO").

END FUNCTION.

/* Buscar as Contas Centralizadoras do BBrasil */
FUNCTION BuscaCtaCe RETURNS LOGICAL
    ( INPUT  par_cdcooper AS INTE,
      INPUT  par_tpregist AS INTE,
      OUTPUT par_lscontas AS CHAR,
      OUTPUT par_dscritic AS CHAR ):

    IF   par_tpregist < 0 AND par_tpregist > 4 THEN
         RETURN TRUE.

    FOR EACH gnctace FIELDS(nrctace cdcooper)
                     WHERE gnctace.cdcooper = par_cdcooper  AND
                           gnctace.cddbanco = 1             AND
                           (IF par_tpregist <> 0 THEN
                            gnctace.tpregist = par_tpregist ELSE TRUE) NO-LOCK
                           BREAK BY gnctace.cdcooper:

        ASSIGN par_lscontas = par_lscontas + TRIM(STRING(gnctace.nrctace)).

        IF  NOT LAST-OF(gnctace.cdcooper) THEN
            ASSIGN par_lscontas = par_lscontas + ",".
    END.

    IF  par_lscontas = "" THEN
        ASSIGN par_dscritic = BuscaCritica(393).

    RETURN TRUE.

END FUNCTION.
