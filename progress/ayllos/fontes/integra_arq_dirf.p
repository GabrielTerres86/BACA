/* ............................................................................
                    
   Programa: fontes/integra_arq_dirf.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Evandro
   Data    : Janeiro/2005                        Ultima atualizacao: 10/12/2013

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado.
   Objetivo  : Integrar arquivo para a DIRF.
   
   Alteracoes: 04/07/2005 - Alimentado campo cdcooper da tabela crapdrf (Diego).
   
               28/09/2005 - Modificado FIND FIRST para FIND na tabela 
                            crapcop.cdcooper = glb_cdcooper (Diego).
                            
               27/01/2006 - Unificacao dos Bancos - SQLWorks - Andre

               14/02/2008 - Atualizacao Layout Dirf 2008 (Julio)
               
               27/01/2011 - Atualizacao de layout Dirf 2010 (Diego).
               
               10/12/2013 - Inclusao de VALIDATE crapdrf, crapvir, crapbps e 
                            crapdps (Carlos)

............................................................................ */

{ includes/var_batch.i }
    
DEF STREAM str_1.

DEF INPUT  PARAM par_nmarqint AS CHAR                                  NO-UNDO.
DEF INPUT  PARAM par_nranocal AS INT                                   NO-UNDO.

DEF     VAR aux_nmarqint AS CHAR                                       NO-UNDO.
DEF     VAR aux_dsdlinha AS CHAR                                       NO-UNDO.
DEF     VAR aux_nranocal AS INT                                        NO-UNDO.
DEF     VAR aux_confirma AS CHAR        FORMAT "!(1)"                  NO-UNDO.
DEF     VAR aux_nrseqdig AS INT                                        NO-UNDO.

DEF     VAR aux_nrsequen AS INT                                        NO-UNDO.
DEF     VAR aux_nmarquiv AS CHAR                                       NO-UNDO.

DEF     VAR aux_numidrec AS INT                                        NO-UNDO.
DEF     VAR aux_flginteg AS LOG                                        NO-UNDO.
DEF     VAR aux_contador AS INT                                        NO-UNDO.
DEF     VAR aux_nrcgcops AS DEC                                        NO-UNDO.
DEF     VAR aux_nmempops AS CHAR                                       NO-UNDO.
DEF     VAR aux_nrregops AS INT                                        NO-UNDO.

DEF     BUFFER crabass FOR crapass.

FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

IF   NOT AVAILABLE crapcop   THEN
     RETURN.

/* coloca o caminho completo no nome do arquivo */
aux_nmarqint = "/micros/" + crapcop.dsdircop + "/dirf/integrar/" +
               par_nmarqint.

IF   SEARCH(aux_nmarqint) = ?   THEN
     DO:
        glb_cdcritic = 182.
        RUN fontes/critic.p.
        BELL.
        MESSAGE glb_dscritic.
        RETURN.
     END.
ELSE
     MESSAGE "Aguarde... Integrando Arquivo...".

/* converte o arquivo de DOS para UNIX */
UNIX SILENT VALUE("dos2ux " + aux_nmarqint + " > " + aux_nmarqint + "_ux").
aux_nmarqint = aux_nmarqint + "_ux".

/* cria copia do arquivo como QUOTER  */
UNIX SILENT VALUE("quoter " + aux_nmarqint + " > " + aux_nmarqint + "_q").
aux_nmarqint = aux_nmarqint + "_q".

INPUT STREAM str_1 FROM VALUE (aux_nmarqint)  NO-ECHO.
    
/* le o primeiro registro */
IMPORT STREAM str_1 aux_dsdlinha.

IF   ENTRY(1,aux_dsdlinha,"|") = "DIRF"   THEN
     DO:
        ASSIGN aux_nranocal = INTEGER(ENTRY(3,aux_dsdlinha,"|")).
                
        /* consiste o ano informado com o ano do arquivo*/
        IF   par_nranocal <> aux_nranocal   THEN
             DO:
                HIDE MESSAGE NO-PAUSE.
                MESSAGE "As informacoes do arquivo nao correspondem ao ano"
                        "informado.".
                glb_cdcritic = 182.
                
                RETURN.
             END.

        /* Consiste estrutura de leiaute do arquivo */ 
        IF   ENTRY(6,aux_dsdlinha,"|") <> "6E0E0AF" THEN
             DO:
                 glb_cdcritic = 182.
                 HIDE MESSAGE NO-PAUSE.
                 MESSAGE "Layout nao correspondente! Impossivel continuar.".
                 PAUSE.
            
                 RETURN. 
             END.

     END.
ELSE
     DO:
         glb_cdcritic = 182.
         HIDE MESSAGE NO-PAUSE.
         MESSAGE "Layout nao correspondente! Impossivel continuar.".
         PAUSE.

         RETURN.
     END.

/* Informacoes do responsavel pelo preenchimento da declaracao */
IMPORT STREAM str_1 aux_dsdlinha.

/* Informacoes do declarante pessoa juridica */
IMPORT STREAM str_1 aux_dsdlinha.

IF   ENTRY(1,aux_dsdlinha,"|") = "DECPJ"   THEN
     DO:
        /* consistir o CNPJ do arquivo com o da COOPERATIVA */
         IF   AVAILABLE crapcop   THEN
              DO:
                  IF  crapcop.nrdocnpj <> DECIMAL(ENTRY(2,aux_dsdlinha,"|"))
                       THEN
                      DO:
                          HIDE MESSAGE NO-PAUSE. 
                          MESSAGE "O CNPJ do arquivo nao confere com o da"
                                  "COOPERATIVA! Impossivel continuar.".
                                  
                          glb_cdcritic = 182.
                          RETURN.    
                      END.
              END.
     END.
ELSE
     DO:
         glb_cdcritic = 182.
         HIDE MESSAGE NO-PAUSE.
         MESSAGE "Layout nao correspondente! Impossivel continuar.".
         PAUSE.
         RETURN.
     END.

/* verifica se arquivo ja foi integrado */
FIND FIRST crapdrf WHERE crapdrf.cdcooper = glb_cdcooper   AND
                         crapdrf.tporireg = 3              AND  /*integrado*/
                         crapdrf.nranocal = par_nranocal
                         NO-LOCK NO-ERROR.
                 
IF   AVAILABLE crapdrf   THEN
     DO:
        HIDE MESSAGE NO-PAUSE.
        MESSAGE "Ja existem registros de" par_nranocal "integrados,"
                "deseja substitui-los? (S/N)" UPDATE aux_confirma.
     
        IF   aux_confirma <> "S"                   OR
             KEYFUNCTION(LASTKEY) =  "END-ERROR"   THEN
             RETURN.

        /* apagar todos os registros para serem criados novamente */

        FOR EACH crapdrf WHERE crapdrf.cdcooper = glb_cdcooper AND
                               crapdrf.tporireg = 3            AND
                               crapdrf.nranocal = par_nranocal EXCLUSIVE-LOCK:
                               
            DELETE crapdrf.
        END.

        FOR EACH crapvir WHERE crapvir.cdcooper = glb_cdcooper  AND
                               crapvir.tporireg = 3             AND 
                               crapvir.nranocal = par_nranocal EXCLUSIVE-LOCK:

            DELETE crapvir.
        END.

        FOR EACH crapbps WHERE crapbps.cdcooper = glb_cdcooper  AND
                               crapbps.nranocal = par_nranocal EXCLUSIVE-LOCK:

            DELETE crapbps. 
        END.

        FOR EACH crapdps WHERE crapdps.cdcooper = glb_cdcooper  AND
                               crapdps.nranocal = par_nranocal EXCLUSIVE-LOCK:

            DELETE crapdps.
        END.
     END.

HIDE FRAME f_opcao NO-PAUSE.         
/* fim da verificacao */

/* pega o ultimo numero de sequencia */
FIND LAST crapdrf WHERE crapdrf.cdcooper = glb_cdcooper AND
                        crapdrf.nranocal = aux_nranocal NO-LOCK NO-ERROR.

ASSIGN aux_nrseqdig = IF AVAILABLE crapdrf THEN
                         crapdrf.nrseqdig
                      ELSE
                         0
       aux_flginteg = TRUE.

DO WHILE TRUE ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:

    IMPORT STREAM str_1 aux_dsdlinha.

    /* identificacao de codigo da receita */
    IF  ENTRY(1,aux_dsdlinha,"|") =  "IDREC" THEN
        ASSIGN aux_numidrec = INTEGER(SUBSTRING(aux_dsdlinha,7,4)).
    
    /* beneficiario */ 
    IF  ENTRY(1,aux_dsdlinha,"|") =  "BPFDEC"  OR    /* pessoa fisica */ 
        ENTRY(1,aux_dsdlinha,"|") =  "BPJDEC"  THEN  /* pessoa juridica */
        DO:
            CREATE crapdrf.
            ASSIGN aux_nrseqdig     = aux_nrseqdig + 1
                   crapdrf.cdcooper = glb_cdcooper
                   crapdrf.cdretenc = aux_numidrec
                   crapdrf.tpregist = 2
                   crapdrf.tporireg = 3  /* integrado */
                   crapdrf.dtmvtolt = glb_dtmvtolt
                   crapdrf.nranocal = aux_nranocal
                   crapdrf.nrseqdig = aux_nrseqdig 
                   crapdrf.inpessoa = IF ENTRY(1,aux_dsdlinha,"|") = "BPFDEC"
                                         THEN 1
                                      ELSE 2       
                   crapdrf.nrcpfbnf = DEC(ENTRY(2,aux_dsdlinha,"|"))
                   crapdrf.nrcpfcgc = crapcop.nrdocnpj    
                   crapdrf.nmbenefi = ENTRY(3,aux_dsdlinha,"|").

            /* pegar a conta do associado, se nao for CECRED */
            IF  crapcop.cdcooper <> 3   THEN    
                DO:
                    FIND FIRST crapass WHERE 
                               crapass.cdcooper = glb_cdcooper     AND
                               crapass.nrcpfcgc = crapdrf.nrcpfbnf
                               NO-LOCK NO-ERROR.
         
                    IF  AVAILABLE crapass   THEN
                        ASSIGN crapdrf.nrdconta = crapass.nrdconta.
                END.
            
            VALIDATE crapdrf.

        END.

    /* informacoes mensais do beneficiario */ 
    IF  CAN-DO("RTRT,RTPO,RTPP,RTDP,RTPA,RTIRF,CJAA,CJAC,ESRT,ESPO,ESPP," +
               "ESDP,ESPA,ESIR,ESDJ,RIP65,RIDAC,RIIRP,RIAP,RIMOG",
               ENTRY(1,aux_dsdlinha,"|"))  AND  
        aux_flginteg = TRUE   THEN
        DO aux_contador = 2 TO NUM-ENTRIES(TRIM(aux_dsdlinha),"|"):
               
           IF  DEC(ENTRY(aux_contador,aux_dsdlinha,"|")) > 0 THEN
               DO:
                   /* Neste caso nao eh necessario verificar o campo nrseqdig, 
                      pois o arquivo contem apenas um registro de cada Cod. 
                      de Retencao por beneficiario */ 
                   FIND crapvir WHERE crapvir.cdcooper = crapdrf.cdcooper AND 
                                      crapvir.nrcpfbnf = crapdrf.nrcpfbnf AND
                                      crapvir.nranocal = crapdrf.nranocal AND
                                      crapvir.nrmesref = aux_contador - 1 AND
                                      crapvir.cdretenc = aux_numidrec
                                      EXCLUSIVE-LOCK NO-ERROR.

                   IF  NOT AVAIL crapvir THEN
                       DO:
                           CREATE crapvir.
                           ASSIGN crapvir.cdcooper = crapdrf.cdcooper
                                  crapvir.nrcpfbnf = crapdrf.nrcpfbnf
                                  crapvir.nranocal = crapdrf.nranocal
                                  crapvir.nrmesref = aux_contador - 1
                                  crapvir.cdretenc = aux_numidrec
                                  crapvir.nrseqdig = crapdrf.nrseqdig
                                  crapvir.tporireg = 3 /* integrado */.
                       END.
        
                   /* Rend. Tributaveis - Rendimento Tributavel */
                   IF  ENTRY(1,aux_dsdlinha,"|") = "RTRT" THEN
                       ASSIGN crapvir.vlrdrtrt = 
                                     DEC(ENTRY(aux_contador,aux_dsdlinha,"|")).

                   /* Rend. Tributaveis - Deducao - Previdencia Oficial */
                   IF  ENTRY(1,aux_dsdlinha,"|") = "RTPO" THEN
                       ASSIGN crapvir.vlrdrtpo =
                                     DEC(ENTRY(aux_contador,aux_dsdlinha,"|")).
              
                   /* Rend. Tributaveis - Deducao - Previdencia Privada */ 
                   IF  ENTRY(1,aux_dsdlinha,"|") = "RTPP" THEN
                       ASSIGN crapvir.vlrdrtpp =
                                    DEC(ENTRY(aux_contador,aux_dsdlinha,"|")).
              
                   /* Rend. Tributaveis - Deducao - Dependentes */ 
                   IF  ENTRY(1,aux_dsdlinha,"|") = "RTDP" THEN
                       ASSIGN crapvir.vlrdrtdp =
                                     DEC(ENTRY(aux_contador,aux_dsdlinha,"|")).
              
                   /* Rend. Tributaveis - Deducao - pensao Alimenticia */ 
                   IF  ENTRY(1,aux_dsdlinha,"|") = "RTPA" THEN
                       ASSIGN crapvir.vlrdrtpa =
                                     DEC(ENTRY(aux_contador,aux_dsdlinha,"|")).

                   /* Rend. Tributaveis - Imposto de Renda Retido na Fonte */ 
                   IF  ENTRY(1,aux_dsdlinha,"|") = "RTIRF" THEN
                       ASSIGN crapvir.vlrrtirf =
                                     DEC(ENTRY(aux_contador,aux_dsdlinha,"|")).
              
             /* Compensacao de Imposto por Decisao Judicial - Ano Calendario */ 
                   IF  ENTRY(1,aux_dsdlinha,"|") = "CJAA" THEN
                       ASSIGN crapvir.vlrdcjaa =
                                     DEC(ENTRY(aux_contador,aux_dsdlinha,"|")).
              
            /* Compensacao de Imposto por Decisao Judicial - Anos Anteriores */
                   IF  ENTRY(1,aux_dsdlinha,"|") = "CJAC" THEN
                       ASSIGN crapvir.vlrdcjac =
                                     DEC(ENTRY(aux_contador,aux_dsdlinha,"|")).
              
                /* Tributacao com Exigibilidade Suspensa - Rend. Tributavel */ 
                   IF  ENTRY(1,aux_dsdlinha,"|") = "ESRT" THEN
                       ASSIGN crapvir.vlrdesrt =
                                     DEC(ENTRY(aux_contador,aux_dsdlinha,"|")).
              
              /* Tribut. com Exigibilidade Suspensa - Deducao - Prev.Oficial */
                   IF  ENTRY(1,aux_dsdlinha,"|") = "ESPO" THEN
                       ASSIGN crapvir.vlrdespo =
                                     DEC(ENTRY(aux_contador,aux_dsdlinha,"|")).

             /* Tribut. com Exigibilidade Suspensa - Deducao - Prev.Privada */
                   IF  ENTRY(1,aux_dsdlinha,"|") = "ESPP" THEN
                       ASSIGN crapvir.vlrdespp =
                                     DEC(ENTRY(aux_contador,aux_dsdlinha,"|")).
            
             /* Tribut. com Exigibilidade Suspensa - Deducao - Dependentes */
                   IF  ENTRY(1,aux_dsdlinha,"|") = "ESDP" THEN
                       ASSIGN crapvir.vlrdesdp =
                                     DEC(ENTRY(aux_contador,aux_dsdlinha,"|")).
            
            /* Tribut. com Exigibilidade Suspensa - Deducao - Pensao Aliment.*/
                   IF  ENTRY(1,aux_dsdlinha,"|") = "ESPA" THEN
                       ASSIGN crapvir.vlrdespa =
                                     DEC(ENTRY(aux_contador,aux_dsdlinha,"|")).
            
            /* Tribut. com Exigibil. Suspensa - Imposto de Renda na Fonte */
                   IF  ENTRY(1,aux_dsdlinha,"|") = "ESIR" THEN
                       ASSIGN crapvir.vlrdesir =
                                     DEC(ENTRY(aux_contador,aux_dsdlinha,"|")).
            
                /* Tribut. com Exigibilidade Suspensa - Deposito Judicial */
                   IF  ENTRY(1,aux_dsdlinha,"|") = "ESDJ" THEN
                       ASSIGN crapvir.vlrdesdj =
                                     DEC(ENTRY(aux_contador,aux_dsdlinha,"|")).

                  /* Rendimentos Isentos - Diaria e Ajuda de Custo */ 
                  IF  ENTRY(1,aux_dsdlinha,"|") = "RIDAC" THEN
                      ASSIGN crapvir.vlrridac =
                                     DEC(ENTRY(aux_contador,aux_dsdlinha,"|")).
               
                  /* Rend.Isentos - Indenizacoes por Recisao de Contrato de 
                     Trabalho, inclusive a titulo de PDV */  
                  IF  ENTRY(1,aux_dsdlinha,"|") = "RIIRP" THEN
                      ASSIGN crapvir.vlrriirp =
                                     DEC(ENTRY(aux_contador,aux_dsdlinha,"|")).
               
                  /* Rendimentos Isentos - Abono Pecuniario */ 
                  IF  ENTRY(1,aux_dsdlinha,"|") = "RIAP" THEN
                      ASSIGN crapvir.vlrdriap =
                                     DEC(ENTRY(aux_contador,aux_dsdlinha,"|")).
                  
                  /* Rend. Isentos - Pensao, Aposentadoria ou Reforma por 
                     Molestia Grave */ 
                  IF  ENTRY(1,aux_dsdlinha,"|") = "RIMOG" THEN
                      ASSIGN crapvir.vlrrimog =
                                     DEC(ENTRY(aux_contador,aux_dsdlinha,"|")).
               
                  /* Rend.Isentos - Parcela Isenta de Aposentadoria para 
                     Maiores de 65 anos */ 
                  IF  ENTRY(1,aux_dsdlinha,"|") = "RIP65" THEN
                      ASSIGN crapvir.vlrrip65 =
                                     DEC(ENTRY(aux_contador,aux_dsdlinha,"|")).

                  VALIDATE crapvir.

               END.
        END.

    /* Rend. Isentos Anuais - Lucros e dividendos pagos a partie de 1996 */
    IF   ENTRY(1,aux_dsdlinha,"|") =  "RIL96"  THEN
         ASSIGN crapdrf.vlrril96 = DEC(ENTRY(2,aux_dsdlinha,"|")).

    /* Rend. Isentos Anuais - Valores pagos a titular ou socio ou empresa
       de pequeno porte, exceto prolabore e alugueis */ 
    IF   ENTRY(1,aux_dsdlinha,"|") =  "RIPTS"  THEN
         ASSIGN crapdrf.vlrripts = DEC(ENTRY(2,aux_dsdlinha,"|")).
 
    /* Rendimentos Isentos Anuais - Outros */ 
    IF   ENTRY(1,aux_dsdlinha,"|") =  "RIO"  THEN
         ASSIGN crapdrf.vlrriade = DEC(ENTRY(2,aux_dsdlinha,"|")) 
                crapdrf.dsrenise = ENTRY(3,aux_dsdlinha,"|").        

    IF   CAN-DO("FCI,PROC",ENTRY(1,aux_dsdlinha,"|"))  THEN
         /* Valores do Fundo do Clube de Investimento(FCI) e Processo da 
            justica do trabalho/federal(PROC) nao devem vir no arquivo */  
         ASSIGN aux_flginteg = FALSE.

    /* Operadora de plano privado de assistencia a saude coletivo empresarial*/
    IF   ENTRY(1,aux_dsdlinha,"|") =  "OPSE"  THEN 
         ASSIGN aux_nrcgcops = DEC(ENTRY(2,aux_dsdlinha,"|"))
                aux_nmempops = ENTRY(3,aux_dsdlinha,"|")
                aux_nrregops = INT(ENTRY(4,aux_dsdlinha,"|")).

    /* Titular do plano */
    IF   ENTRY(1,aux_dsdlinha,"|") =  "TPSE"  THEN  
         DO:
             CREATE crapbps.
             ASSIGN crapbps.cdcooper = glb_cdcooper
                    crapbps.nranocal = aux_nranocal
                    crapbps.nrcpfbnf = DEC(ENTRY(2,aux_dsdlinha,"|"))
                    crapbps.nrcgcops = aux_nrcgcops
                    crapbps.nmempops = aux_nmempops
                    crapbps.nrregops = aux_nrregops
                    crapbps.vlrsaude = DEC(ENTRY(4,aux_dsdlinha,"|")).

             VALIDATE crapbps.
         END.

    /* Dependentes do Titular do plano */
    IF   ENTRY(1,aux_dsdlinha,"|") =  "DTPSE"  THEN  
         DO:
             CREATE crapdps.
             ASSIGN crapdps.cdcooper = glb_cdcooper
                    crapdps.nranocal = crapbps.nranocal
                    crapdps.nrcpfbnf = crapbps.nrcpfbnf
                    crapdps.nrcpfdep = DEC(ENTRY(2,aux_dsdlinha,"|"))
                    crapdps.dtnasdep = DATE(
                                INT(SUBSTRING(ENTRY(3,aux_dsdlinha,"|"),5,2)),
                                INT(SUBSTRING(ENTRY(3,aux_dsdlinha,"|"),7,2)),
                                INT(SUBSTRING(ENTRY(3,aux_dsdlinha,"|"),1,4)))
                    crapdps.nmdepbnf = ENTRY(4,aux_dsdlinha,"|") 
                    crapdps.cdreldep = INT(ENTRY(5,aux_dsdlinha,"|"))
                    crapdps.vlrsaude = DEC(ENTRY(6,aux_dsdlinha,"|")).
             
             VALIDATE crapdps.
         END.

    IF   ENTRY(1,aux_dsdlinha,"|") =  "FIMDRF" THEN     
         LEAVE.

END. /* fim do DO WHILE */

INPUT STREAM str_1 CLOSE.

/* apaga a copia - QUOTER  */
UNIX SILENT VALUE("rm " + aux_nmarqint).

/* volta o nome para o "_ux" */
aux_nmarqint = SUBSTRING(aux_nmarqint,1,(LENGTH(aux_nmarqint) - 2)).


/* pega o ultimo nro sequencial dos ja processados */
INPUT STREAM str_1 THROUGH VALUE( "ls /micros/" + crapcop.dsdircop +
                                  "/dirf/processados 2> /dev/null")   NO-ECHO.

aux_nrsequen = 1.
DO WHILE TRUE ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:

   SET STREAM str_1 aux_nmarquiv FORMAT "x(40)".
   

   IF   INTEGER(SUBSTRING(aux_nmarquiv,R-INDEX(aux_nmarquiv,"_") + 1,3)) >=
        aux_nrsequen   THEN
        aux_nrsequen = INTEGER(SUBSTRING(aux_nmarquiv,
                                         R-INDEX(aux_nmarquiv,"_") + 1,3)) + 1.
END.   

/* move o arquivo integrado para o diretorio "processados" */
UNIX SILENT VALUE("mv " + aux_nmarqint + " /micros/" + crapcop.dsdircop + 
                   "/dirf/processados/" + par_nmarqint + "_" +
                   STRING(aux_nrsequen,"999") + " 2> /dev/null").
                   
/* volta o nome do arquivo para o original, sem "_ux" */
aux_nmarqint = SUBSTRING(aux_nmarqint,1,(LENGTH(aux_nmarqint) - 3)).

/* remove o arquivo original */
UNIX SILENT VALUE("rm -f " + aux_nmarqint + " 2> /dev/null").

HIDE MESSAGE NO-PAUSE.
MESSAGE "Arquivo Integrado com Sucesso!!!".
PAUSE(3) NO-MESSAGE.

/* .......................................................................... */
