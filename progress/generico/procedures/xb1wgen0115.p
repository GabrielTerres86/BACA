/*.............................................................................

     Programa: sistema/generico/procedures/xb1wgen0115.p
     Autor   : Rogerius Militão
     Data    : Setembro/2011                   Ultima atualizacao: 01/11/2017

     Objetivo  : BO de Comunicacao XML x BO - Telas aditiv

     Alteracoes: 11/11/2014 - Retirar procedure Gera_Termo. Agora vai usar
                              Gera_Impressao. (Jonata-RKAM).
                           
                 15/12/2014 - Adicionado campo tpproapl no recibemento de 
                              parametros da temp-table tt-aplicacoes. (Reinert)

                 01/11/2017 - Passagem do tpctrato e idgaropc. (Jaison/Marcos Martini - PRJ404)

.............................................................................*/



/*...........................................................................*/
DEF VAR aux_cdcooper AS INTE                                           NO-UNDO.
DEF VAR aux_cdagenci AS INTE                                           NO-UNDO.
DEF VAR aux_nrdcaixa AS INTE                                           NO-UNDO.
DEF VAR aux_cdoperad AS CHAR                                           NO-UNDO.
DEF VAR aux_nmdatela AS CHAR                                           NO-UNDO.
DEF VAR aux_idorigem AS INTE                                           NO-UNDO.
DEF VAR aux_cdprogra AS CHAR                                           NO-UNDO.

DEF VAR aux_cddopcao AS CHAR                                           NO-UNDO.
DEF VAR aux_nrdconta AS INTE                                           NO-UNDO.
DEF VAR aux_idseqttl AS INTE                                           NO-UNDO.
DEF VAR aux_nrctremp AS INTE                                           NO-UNDO.
DEF VAR aux_dtmvtolx AS DATE                                           NO-UNDO.
DEF VAR aux_nraditiv AS INTE                                           NO-UNDO.
DEF VAR aux_cdaditiv AS INTE                                           NO-UNDO.

DEF VAR aux_flgpagto AS LOGICAL                                        NO-UNDO.
DEF VAR aux_dtdpagto AS DATE                                           NO-UNDO.
DEF VAR aux_flgaplic AS LOGICAL                                        NO-UNDO.
DEF VAR aux_tpaplica AS INTE                                           NO-UNDO.
DEF VAR aux_nraplica AS INTE                                           NO-UNDO.
DEF VAR aux_nrctagar AS INTE                                           NO-UNDO.
DEF VAR aux_dsbemfin AS CHAR                                           NO-UNDO.
DEF VAR aux_dschassi AS CHAR                                           NO-UNDO.
DEF VAR aux_nrdplaca AS CHAR                                           NO-UNDO.
DEF VAR aux_dscorbem AS CHAR                                           NO-UNDO.
DEF VAR aux_nranobem AS INTE                                           NO-UNDO.
DEF VAR aux_nrmodbem AS INTE                                           NO-UNDO.
DEF VAR aux_nrrenava AS DECI                                           NO-UNDO.
DEF VAR aux_tpchassi AS INTE                                           NO-UNDO.
DEF VAR aux_ufdplaca AS CHAR                                           NO-UNDO.
DEF VAR aux_uflicenc AS CHAR                                           NO-UNDO.
DEF VAR aux_nrcpfcgc AS DECI                                           NO-UNDO.
DEF VAR aux_idseqbem AS INTE                                           NO-UNDO.
DEF VAR aux_nrcpfgar AS DECI                                           NO-UNDO.
DEF VAR aux_nrdocgar AS CHAR                                           NO-UNDO.
DEF VAR aux_nmdgaran AS CHAR                                           NO-UNDO.
DEF VAR aux_nrpromis AS CHAR EXTENT 10                                 NO-UNDO.
DEF VAR aux_vlpromis AS DECI EXTENT 10                                 NO-UNDO.
DEF VAR aux_tpctrato AS INTE                                           NO-UNDO.
DEF VAR aux_idgaropc AS INTE                                           NO-UNDO.
 
DEF VAR aux_dsiduser AS CHAR                                           NO-UNDO.
DEF VAR aux_nmarqimp AS CHAR                                           NO-UNDO. 
DEF VAR aux_nmarqpdf AS CHAR                                           NO-UNDO. 

DEF VAR aux_nmprimtl AS CHAR                                           NO-UNDO.
DEF VAR aux_dtmvtole AS DATE                                           NO-UNDO.
DEF VAR aux_impdocir AS LOGICAL                                        NO-UNDO.

DEF VAR aux_uladitiv AS INTE                                           NO-UNDO.

DEF VAR aux_nrregist AS INTE                                           NO-UNDO.
DEF VAR aux_nriniseq AS INTE                                           NO-UNDO.
DEF VAR aux_qtregist AS INTE                                           NO-UNDO.

{ sistema/generico/includes/b1wgen0115tt.i }
{ sistema/generico/includes/var_internet.i } 
{ sistema/generico/includes/supermetodos.i } 

/*............................... PROCEDURES ................................*/
 PROCEDURE valores_entrada:

    DEFINE VARIABLE aux_rowidaux AS ROWID       NO-UNDO.

     FOR EACH tt-param:

         CASE tt-param.nomeCampo:
            
             WHEN "cdcooper" THEN aux_cdcooper = INTE(tt-param.valorCampo).
             WHEN "cdagenci" THEN aux_cdagenci = INTE(tt-param.valorCampo).
             WHEN "nrdcaixa" THEN aux_nrdcaixa = INTE(tt-param.valorCampo).
             WHEN "cdoperad" THEN aux_cdoperad = tt-param.valorCampo.
             WHEN "nmdatela" THEN aux_nmdatela = tt-param.valorCampo.
             WHEN "idorigem" THEN aux_idorigem = INTE(tt-param.valorCampo).
             WHEN "cdprogra" THEN aux_cdprogra = tt-param.valorCampo. 
             WHEN "dtmvtolt" THEN aux_dtmvtolt = DATE(tt-param.valorCampo).
             WHEN "dtmvtopr" THEN aux_dtmvtopr = DATE(tt-param.valorCampo).
             WHEN "inproces" THEN aux_inproces = INTE(tt-param.valorCampo).

             WHEN "cddopcao" THEN aux_cddopcao = tt-param.valorCampo.
             WHEN "nrdconta" THEN aux_nrdconta = INTE(tt-param.valorCampo).
             WHEN "idseqttl" THEN aux_idseqttl = INTE(tt-param.valorCampo).
             WHEN "nrctremp" THEN aux_nrctremp = INTE(tt-param.valorCampo).
             WHEN "dtmvtolx" THEN aux_dtmvtolx = DATE(tt-param.valorCampo).
             WHEN "nraditiv" THEN aux_nraditiv = INTE(tt-param.valorCampo).
             WHEN "cdaditiv" THEN aux_cdaditiv = INTE(tt-param.valorCampo).
             
             WHEN "flgpagto" THEN aux_flgpagto = LOGICAL(tt-param.valorCampo).           
             WHEN "dtdpagto" THEN aux_dtdpagto = DATE(tt-param.valorCampo).  
             WHEN "flgaplic" THEN aux_flgaplic = LOGICAL(tt-param.valorCampo).  

             WHEN "tpaplica" THEN aux_tpaplica = INTE(tt-param.valorCampo).
             WHEN "nraplica" THEN aux_nraplica = INTE(tt-param.valorCampo).

             WHEN "nrctagar" THEN aux_nrctagar = INTE(tt-param.valorCampo).  
             WHEN "dsbemfin" THEN aux_dsbemfin = tt-param.valorCampo.
             WHEN "dschassi" THEN aux_dschassi = tt-param.valorCampo.
             WHEN "nrdplaca" THEN aux_nrdplaca = tt-param.valorCampo.
             WHEN "dscorbem" THEN aux_dscorbem = tt-param.valorCampo.
             WHEN "nranobem" THEN aux_nranobem = INTE(tt-param.valorCampo).
             WHEN "nrmodbem" THEN aux_nrmodbem = INTE(tt-param.valorCampo).
             WHEN "nrrenava" THEN aux_nrrenava = DECI(tt-param.valorCampo).
             WHEN "tpchassi" THEN aux_tpchassi = INTE(tt-param.valorCampo).
             WHEN "ufdplaca" THEN aux_ufdplaca = tt-param.valorCampo.
             WHEN "uflicenc" THEN aux_uflicenc = tt-param.valorCampo.
             WHEN "nrcpfcgc" THEN aux_nrcpfcgc = DECI(tt-param.valorCampo).
             WHEN "idseqbem" THEN aux_idseqbem = INTE(tt-param.valorCampo).  
             WHEN "nrcpfgar" THEN aux_nrcpfgar = DECI(tt-param.valorCampo).  
             WHEN "nrdocgar" THEN aux_nrdocgar = tt-param.valorCampo.        
             WHEN "nmdgaran" THEN aux_nmdgaran = tt-param.valorCampo.  
             
             WHEN "nrpromis1" THEN aux_nrpromis[1] = tt-param.valorCampo.
             WHEN "nrpromis2" THEN aux_nrpromis[2] = tt-param.valorCampo.
             WHEN "nrpromis3" THEN aux_nrpromis[3] = tt-param.valorCampo.
             WHEN "nrpromis4" THEN aux_nrpromis[4] = tt-param.valorCampo.
             WHEN "nrpromis5" THEN aux_nrpromis[5] = tt-param.valorCampo.
             WHEN "nrpromis6" THEN aux_nrpromis[6] = tt-param.valorCampo.
             WHEN "nrpromis7" THEN aux_nrpromis[7] = tt-param.valorCampo.
             WHEN "nrpromis8" THEN aux_nrpromis[8] = tt-param.valorCampo.
             WHEN "nrpromis9" THEN aux_nrpromis[9] = tt-param.valorCampo.
             WHEN "nrpromis10" THEN aux_nrpromis[10] = tt-param.valorCampo.

             WHEN "vlpromis1" THEN aux_vlpromis[1] = DECI(tt-param.valorCampo).
             WHEN "vlpromis2" THEN aux_vlpromis[2] = DECI(tt-param.valorCampo).
             WHEN "vlpromis3" THEN aux_vlpromis[3] = DECI(tt-param.valorCampo).
             WHEN "vlpromis4" THEN aux_vlpromis[4] = DECI(tt-param.valorCampo).
             WHEN "vlpromis5" THEN aux_vlpromis[5] = DECI(tt-param.valorCampo).
             WHEN "vlpromis6" THEN aux_vlpromis[6] = DECI(tt-param.valorCampo).
             WHEN "vlpromis7" THEN aux_vlpromis[7] = DECI(tt-param.valorCampo).
             WHEN "vlpromis8" THEN aux_vlpromis[8] = DECI(tt-param.valorCampo).
             WHEN "vlpromis9" THEN aux_vlpromis[9] = DECI(tt-param.valorCampo).
             WHEN "vlpromis10" THEN aux_vlpromis[10] = DECI(tt-param.valorCampo).

             WHEN "dsiduser" THEN aux_dsiduser = tt-param.valorCampo.
             WHEN "nmarqimp" THEN aux_nmarqimp = tt-param.valorCampo.  
             WHEN "nmarqpdf" THEN aux_nmarqpdf = tt-param.valorCampo.

             WHEN "nmprimtl" THEN aux_nmprimtl = tt-param.valorCampo.
             WHEN "dtmvtole" THEN aux_dtmvtole = DATE(tt-param.valorCampo).
             WHEN "impdocir" THEN aux_impdocir = LOGICAL(tt-param.valorCampo).

             WHEN "uladitiv" THEN aux_uladitiv = INTE(tt-param.valorCampo).
             WHEN "tpctrato" THEN aux_tpctrato = INT(tt-param.valorCampo).
             WHEN "idgaropc" THEN aux_idgaropc = INT(tt-param.valorCampo).

             WHEN "nrregist" THEN aux_nrregist = INTE(tt-param.valorCampo).
             WHEN "nriniseq" THEN aux_nriniseq = INTE(tt-param.valorCampo).
             WHEN "qtregist" THEN aux_qtregist = INTE(tt-param.valorCampo).

         END CASE.

     END. /** Fim do FOR EACH tt-param **/
    
     
     FOR EACH tt-param-i 
         BREAK BY tt-param-i.nomeTabela
               BY tt-param-i.sqControle:

         CASE tt-param-i.nomeTabela:

             WHEN "Aplicacoes" THEN DO:

                 IF  FIRST-OF(tt-param-i.sqControle) THEN
                     DO:
                        CREATE tt-aplicacoes.
                        ASSIGN aux_rowidaux = ROWID(tt-aplicacoes).
                     END.

                 FIND tt-aplicacoes WHERE ROWID(tt-aplicacoes) = aux_rowidaux
                                       NO-ERROR.

                 CASE tt-param-i.nomeCampo:
                     WHEN "nraplica" THEN
                         tt-aplicacoes.nraplica = INTE(tt-param-i.valorCampo).
                     WHEN "dtmvtolt" THEN
                         tt-aplicacoes.dtmvtolt = DATE(tt-param-i.valorCampo).
                     WHEN "dshistor" THEN
                         tt-aplicacoes.dshistor = tt-param-i.valorCampo.
                     WHEN "nrdocmto" THEN
                         tt-aplicacoes.nrdocmto = tt-param-i.valorCampo.
                     WHEN "dtvencto" THEN
                         tt-aplicacoes.dtvencto = DATE(tt-param-i.valorCampo).
                     WHEN "vlsldapl" THEN
                         tt-aplicacoes.vlsldapl = DECIMAL(tt-param-i.valorCampo).
                     WHEN "sldresga" THEN
                         tt-aplicacoes.sldresga = DECIMAL(tt-param-i.valorCampo).
                     WHEN "flgselec" THEN
                         tt-aplicacoes.flgselec = LOGICAL(tt-param-i.valorCampo).
                     WHEN "tpaplica" THEN
                         tt-aplicacoes.tpaplica = INTE(tt-param-i.valorCampo).
                     WHEN "tpproapl" THEN
                         tt-aplicacoes.tpproapl = INTE(tt-param-i.valorCampo).

                 END CASE.
             END.

         END CASE.
     END.
     

 END PROCEDURE. /* valores_entrada */


/* ------------------------------------------------------------------------ */
/*                   EFETUA A BUSCA DOS DADOS DO ASSOCIADO                  */
/* ------------------------------------------------------------------------ */
PROCEDURE Busca_Dados:

    RUN Busca_Dados IN hBO
                    ( INPUT aux_cdcooper,
                      INPUT aux_cdagenci,
                      INPUT aux_nrdcaixa,
                      INPUT aux_cdoperad,
                      INPUT aux_nmdatela,
                      INPUT aux_idorigem,
                      INPUT aux_dtmvtolt,
                      INPUT aux_dtmvtopr,
                      INPUT aux_inproces,
                      INPUT aux_cddopcao,
                      INPUT aux_nrdconta,
                      INPUT aux_nrctremp,
                      INPUT aux_dtmvtolx,
                      INPUT aux_nraditiv,
                      INPUT aux_cdaditiv,
                      INPUT aux_tpaplica,
                      INPUT aux_nrctagar,
                      INPUT aux_tpctrato,
                      INPUT TRUE,
                      INPUT aux_nrregist, 
                      INPUT aux_nriniseq, 
                      INPUT TRUE,
                     OUTPUT aux_qtregist,
                     OUTPUT TABLE tt-aditiv,
                     OUTPUT TABLE tt-aplicacoes,
                     OUTPUT TABLE tt-erro).
    
    IF  RETURN-VALUE = "NOK" THEN
        DO:
           FIND FIRST tt-erro NO-LOCK NO-ERROR.

           IF  NOT AVAILABLE tt-erro  THEN
               DO:
                   CREATE tt-erro.
                   ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                             "busca de dados.".
               END.
           RUN piXmlNew.
           RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
           RUN piXmlSave.
           
        END.
    ELSE
        DO:
           RUN piXmlNew.
           RUN piXmlExport   (INPUT TEMP-TABLE tt-aditiv:HANDLE,
                              INPUT "Aditivos").
           RUN piXmlAtributo (INPUT "qtregist", INPUT aux_qtregist).
           RUN piXmlExport   (INPUT TEMP-TABLE tt-aplicacoes:HANDLE,
                              INPUT "Aplicacoes").
           RUN piXmlSave.
        END.

END PROCEDURE. /* Busca_Dados */


/* ------------------------------------------------------------------------ */
/*                  EFETUA A VALIDAÇÃO DOS DADOS INFORMADOS                 */
/* ------------------------------------------------------------------------ */
PROCEDURE Valida_Dados:

    /** A validacao no valida_dados é com o campo em branco, porem a web
        define mascara de Zeros, passando direto pela validacao       */
    IF  aux_nrdplaca = "0000000" THEN
        ASSIGN aux_nrdplaca = "".

    RUN Valida_Dados IN hBO
                    ( INPUT aux_cdcooper,
                      INPUT aux_cdagenci,
                      INPUT aux_nrdcaixa,
                      INPUT aux_cdoperad,
                      INPUT aux_nmdatela,
                      INPUT aux_idorigem,
                      INPUT aux_dtmvtolt,
                      INPUT aux_cddopcao,
                      INPUT aux_nrdconta,
                      INPUT aux_cdaditiv,
                      INPUT aux_tpctrato,
                      INPUT aux_nrctremp,
                      INPUT aux_dtdpagto,
                      INPUT aux_flgpagto,
                      INPUT aux_nrctagar,
                      INPUT aux_nrcpfgar,
                      INPUT aux_dsbemfin,
                      INPUT aux_nrrenava,
                      INPUT aux_tpchassi,
                      INPUT aux_dschassi,
                      INPUT aux_nrdplaca,
                      INPUT aux_ufdplaca,
                      INPUT aux_dscorbem,
                      INPUT aux_nranobem,
                      INPUT aux_nrmodbem,
                      INPUT aux_uflicenc,
                      INPUT aux_nrcpfcgc,
                      INPUT aux_nmdgaran,
                      INPUT aux_nrdocgar,
                      INPUT aux_vlpromis[1],
                      INPUT TRUE,
                      INPUT TABLE tt-aplicacoes,
                     OUTPUT aux_nmdgaran,
                     OUTPUT aux_flgaplic,
                     OUTPUT TABLE tt-erro).
    
    IF  RETURN-VALUE = "NOK" THEN
        DO:
           FIND FIRST tt-erro NO-LOCK NO-ERROR.

           IF  NOT AVAILABLE tt-erro  THEN
               DO:
                   CREATE tt-erro.
                   ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                             "busca de dados.".
               END.
           RUN piXmlNew.
           RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
           RUN piXmlSave.
           
        END.
    ELSE
        DO:
           RUN piXmlNew.
           RUN piXmlAtributo (INPUT "nmdgaran", INPUT aux_nmdgaran).
           RUN piXmlAtributo (INPUT "flgaplic", INPUT aux_flgaplic).
           RUN piXmlSave.
        END.

END PROCEDURE. /* Valida_Dados */


/* ------------------------------------------------------------------------ */
/*               REALIZA A GRAVACAO DOS DADOS DA TELA ADITIV                */
/* ------------------------------------------------------------------------ */
PROCEDURE Grava_Dados:

    RUN Grava_Dados IN hBO
                    ( INPUT aux_cdcooper,
                      INPUT aux_cdagenci,
                      INPUT aux_nrdcaixa,
                      INPUT aux_cdoperad,
                      INPUT aux_nmdatela,
                      INPUT aux_idorigem,
                      INPUT aux_dtmvtolt,
                      INPUT aux_nrdconta,
                      INPUT aux_idseqttl,
                      INPUT aux_cddopcao,
                      INPUT aux_nrctremp,
                      INPUT aux_cdaditiv,
                      INPUT aux_nraditiv,
                      INPUT aux_tpctrato,
                      INPUT aux_idgaropc,
                      INPUT aux_flgpagto,
                      INPUT aux_dtdpagto,
                      INPUT aux_flgaplic,
                      INPUT aux_nrctagar,
                      INPUT aux_dsbemfin,
                      INPUT aux_dschassi,
                      INPUT aux_nrdplaca,
                      INPUT aux_dscorbem,
                      INPUT aux_nranobem,
                      INPUT aux_nrmodbem,
                      INPUT aux_nrrenava,
                      INPUT aux_tpchassi,
                      INPUT aux_ufdplaca,
                      INPUT aux_uflicenc,
                      INPUT aux_nrcpfcgc,
                      INPUT aux_idseqbem,
                      INPUT aux_nrcpfgar,
                      INPUT aux_nrdocgar,
                      INPUT aux_nmdgaran,
                      INPUT aux_nrpromis,
                      INPUT aux_vlpromis,
                      INPUT TRUE,
                      INPUT TABLE tt-aplicacoes,
                     OUTPUT aux_uladitiv,
                     OUTPUT TABLE tt-erro).
    
    IF  RETURN-VALUE = "NOK" THEN
        DO:
           FIND FIRST tt-erro NO-LOCK NO-ERROR.

           IF  NOT AVAILABLE tt-erro  THEN
               DO:
                   CREATE tt-erro.
                   ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                             "busca de dados.".
               END.
           RUN piXmlNew.
           RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
           RUN piXmlSave.
           
        END.
    ELSE
        DO:
           RUN piXmlNew.
           RUN piXmlAtributo (INPUT "nraditiv", INPUT aux_uladitiv).
           RUN piXmlSave.
        END.

END PROCEDURE. /* Grava_Dados */
                   
/* ------------------------------------------------------------------------ */
/*                              GERA IMPRESSAO                              */
/* ------------------------------------------------------------------------ */
PROCEDURE Gera_Impressao:

    RUN Gera_Impressao IN  hBO
                    ( INPUT aux_cdcooper,
                      INPUT aux_cdagenci,
                      INPUT aux_nrdcaixa,
                      INPUT aux_idorigem,
                      INPUT aux_nmdatela,
                      INPUT aux_cdprogra,
                      INPUT aux_cdoperad,
                      INPUT aux_dsiduser,
                      INPUT aux_cdaditiv,
                      INPUT aux_nraditiv,
                      INPUT aux_nrctremp,
                      INPUT aux_nrdconta,
                      INPUT aux_dtmvtolt,
                      INPUT aux_dtmvtopr,
                      INPUT aux_inproces,
                      INPUT aux_tpctrato,
                     OUTPUT aux_nmarqimp,
                     OUTPUT aux_nmarqpdf,
                     OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK" THEN
        DO:
           FIND FIRST tt-erro NO-LOCK NO-ERROR.

           IF  NOT AVAILABLE tt-erro  THEN
               DO:
                   CREATE tt-erro.
                   ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                             "busca de dados.".
               END.
           RUN piXmlNew.
           RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
           RUN piXmlSave.
           
        END.
    ELSE
        DO:
           RUN piXmlNew.
           RUN piXmlAtributo (INPUT "nmarqimp", INPUT aux_nmarqimp).
           RUN piXmlAtributo (INPUT "nmarqpdf", INPUT aux_nmarqpdf).
           RUN piXmlSave.
        END.

END PROCEDURE. /* Gera_Impressao */
