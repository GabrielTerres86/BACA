/* .............................................................................

    Programa: Fontes/crps527.p
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : GATI - Peixoto
    Data    : Junho/2009                      Ultima atualizacao: 02/06/2015

    Dados referentes ao programa:

    Frequencia: Diario (on-line)
    Objetivo  : Rotina para Geracao de relatorio 513  
                Estatistica Lancamentos Conta Integracao BB - Arquivo COO553.
               
    Alteracoes: 30/07/2009 - Efetuar chamada de fontes/imprim.p, incluir
                             mensagens de processamento no log da tela PRCITG,
                             excluir arquivos processados (David).

                25/08/2009 - Retirado relatorio de inconsistencias(Mirtes)
                
                21/06/2010 - Alteracao extensao .ret (Vitor).
                                                     
                24/01/2013 - Incluído cópia do arquivo COO553 para diretório
                             da cooperativa (Rodrigo).
                
                13/11/2013 - Nova forma de chamar as agências, de PAC agora 
                             a escrita será PA (Guilherme Gielow)
                             
                14/10/2014 - Alteração da contagem do totalizador das contas
                            ITG (Dionathan).
                            
                02/06/2015 - #287514 Correcao da contagem de contas itg ativas
                             (Carlos)

		            07/03/2018 - Ajuste para buscar os tipo de conta integracao 
                             da Package CADA0006 do orcale. PRJ366 (Lombardi). 
............................................................................. */
                            
{ sistema/generico/includes/var_oracle.i } 

{ includes/var_batch.i }

DEF STREAM str_1.
DEF STREAM str_2.
DEF STREAM srt_3.

DEF VAR aux_strlinha AS CHAR                                           NO-UNDO.
DEF VAR aux_nmarqlog AS CHAR                                           NO-UNDO.
DEF VAR aux_nmarquiv AS CHAR                                           NO-UNDO.
DEF VAR aux_nmarqdat AS CHAR                                           NO-UNDO.
DEF VAR aux_nmarqimp AS CHAR                                           NO-UNDO.
DEF VAR aux_nmendter AS CHAR FORMAT "x(20)"                            NO-UNDO.
DEF VAR aux_dscomand AS CHAR                                           NO-UNDO.
DEF VAR aux_cdevento AS CHAR                                           NO-UNDO.

DEF VAR aux_dtmvtolt AS DATE                                           NO-UNDO.

DEF VAR aux_contador AS INTE                                           NO-UNDO. 
DEF VAR aux_qtctaitg AS INTE FORMAT "zzzzz9"                           NO-UNDO.
DEF VAR aux_qttrctbb AS INTE FORMAT "zzzzz9"                           NO-UNDO.
DEF VAR aux_qtsaqtaa AS INTE FORMAT "zzzzz9"                           NO-UNDO.
DEF VAR aux_qtdepdin AS INTE FORMAT "zzzzz9"                           NO-UNDO.
DEF VAR aux_qtprcchq AS INTE FORMAT "zzzzz9"                           NO-UNDO.
DEF VAR aux_qtcopdoc AS INTE FORMAT "zzzzz9"                           NO-UNDO.
DEF VAR aux_qtchqadi AS INTE FORMAT "zzzzz9"                           NO-UNDO.
DEF VAR aux_qtdevchq AS INTE FORMAT "zzzzz9"                           NO-UNDO.
DEF VAR aux_qtcordem AS INTE FORMAT "zzzzz9"                           NO-UNDO.
DEF VAR aux_qttrfitg AS INTE FORMAT "zzzzz9"                           NO-UNDO.
DEF VAR aux_qtdcompe AS INTE FORMAT "zzzzz9"                           NO-UNDO.
DEF VAR aux_qtoutros AS INTE FORMAT "zzzzz9"                           NO-UNDO.
DEF VAR aux_qtevento AS INTE FORMAT "zzzzz9"                           NO-UNDO.
DEF VAR tot_qtctaitg AS INTE FORMAT "zzzzz9"                           NO-UNDO.
DEF VAR tot_qttrctbb AS INTE FORMAT "zzzzz9"                           NO-UNDO.
DEF VAR tot_qtsaqtaa AS INTE FORMAT "zzzzz9"                           NO-UNDO.
DEF VAR tot_qtdepdin AS INTE FORMAT "zzzzz9"                           NO-UNDO.
DEF VAR tot_qtprcchq AS INTE FORMAT "zzzzz9"                           NO-UNDO.
DEF VAR tot_qtcopdoc AS INTE FORMAT "zzzzz9"                           NO-UNDO.
DEF VAR tot_qtchqadi AS INTE FORMAT "zzzzz9"                           NO-UNDO.
DEF VAR tot_qtdevchq AS INTE FORMAT "zzzzz9"                           NO-UNDO.
DEF VAR tot_qtcordem AS INTE FORMAT "zzzzz9"                           NO-UNDO.
DEF VAR tot_qttrfitg AS INTE FORMAT "zzzzz9"                           NO-UNDO.
DEF VAR tot_qtdcompe AS INTE FORMAT "zzzzz9"                           NO-UNDO.
DEF VAR tot_qtoutros AS INTE FORMAT "zzzzz9"                           NO-UNDO.
DEF VAR tot_qtevento AS INTE FORMAT "zzzzz9"                           NO-UNDO.
                                                                       
DEF VAR aux_flgencer AS LOGI                                           NO-UNDO.
DEF VAR aux_flpaczer AS LOGI                                           NO-UNDO.
DEF VAR aux_flgescra AS LOGI                                           NO-UNDO.

DEF VAR aux_nrdctitg LIKE crapass.nrdctitg                             NO-UNDO.

DEF VAR rel_nmrelato AS CHAR FORMAT "x(40)" EXTENT 5                   NO-UNDO.
DEF VAR rel_nmempres AS CHAR FORMAT "x(15)"                            NO-UNDO.

DEF VAR rel_nmmodulo AS CHAR FORMAT "x(15)" EXTENT 5                  
                             INIT ["DEP. A VISTA   ",                 
                                   "CAPITAL        ",                 
                                   "EMPRESTIMOS    ",                 
                                   "DIGITACAO      ",                 
                                   "GENERICO       "]                  NO-UNDO.
                                                                      
DEF VAR rel_nrmodulo AS INTE FORMAT "9"                                NO-UNDO.
                                                                      
DEF VAR tel_cddopcao AS CHAR FORMAT "!(1)"                             NO-UNDO.
DEF VAR tel_dsimprim AS CHAR FORMAT "x(8)" INIT "Imprimir"             NO-UNDO.
DEF VAR tel_dscancel AS CHAR FORMAT "x(8)" INIT "Cancelar"             NO-UNDO.

DEF VAR par_flgrodar AS LOGI INIT TRUE                                 NO-UNDO.
DEF VAR par_flgfirst AS LOGI INIT TRUE                                 NO-UNDO.
DEF VAR par_flgcance AS LOGI                                           NO-UNDO. 
                                                                      
/* Variaveis para o XML */ 
DEF VAR xDoc          AS HANDLE                                        NO-UNDO.   
DEF VAR xRoot         AS HANDLE                                        NO-UNDO.  
DEF VAR xRoot2        AS HANDLE                                        NO-UNDO.  
DEF VAR xField        AS HANDLE                                        NO-UNDO. 
DEF VAR xText         AS HANDLE                                        NO-UNDO. 
DEF VAR aux_cont_raiz AS INTEGER                                       NO-UNDO. 
DEF VAR aux_cont      AS INTEGER                                       NO-UNDO. 
DEF VAR ponteiro_xml  AS MEMPTR                                        NO-UNDO. 
DEF VAR aux_tpsconta  AS LONGCHAR                                      NO-UNDO.
DEF VAR aux_des_erro  AS CHAR                                          NO-UNDO.
DEF VAR aux_dscritic  AS CHAR                                          NO-UNDO.

DEF TEMP-TABLE tt-553                                                  NO-UNDO
    FIELD cdagenci LIKE crapage.cdagenci
    FIELD dtmvtolt LIKE crapdat.dtmvtolt
    FIELD nrdctitg LIKE crapass.nrdctitg
    FIELD qtprcchq AS INTE FORMAT "zzzzz9"
    FIELD qtchqadi AS INTE FORMAT "zzzzz9"
    FIELD qttrctbb AS INTE FORMAT "zzzzz9"
    FIELD qttrfitg AS INTE FORMAT "zzzzz9"
    FIELD qtsaqtaa AS INTE FORMAT "zzzzz9"
    FIELD qtcopdoc AS INTE FORMAT "zzzzz9"
    FIELD qtdevchq AS INTE FORMAT "zzzzz9"
    FIELD qtcordem AS INTE FORMAT "zzzzz9"
    FIELD qtdepdin AS INTE FORMAT "zzzzz9"
    FIELD qtdcompe AS INTE FORMAT "zzzzz9"
    FIELD qtoutros AS INTE FORMAT "zzzzz9"
    INDEX tt-553-i1 nrdctitg.

DEF TEMP-TABLE tt-pac-zero                                             NO-UNDO
    FIELD nrdctitg LIKE crapass.nrdctitg                               
    FIELD nmprimtl LIKE crapass.nmprimtl                               
    FIELD nrcpfcgc AS CHAR FORMAT "x(14)"                              
    FIELD dsdifere AS CHAR FORMAT "x(50)"                              
    INDEX tt-pac-zero1 nrdctitg.                                       
                                                                       
DEF TEMP-TABLE tt-dep-compe                                            NO-UNDO
    FIELD dtevento AS DATE FORMAT "99/99/9999"                         
    FIELD cdevento AS CHAR FORMAT "x(12)"                              
    FIELD dsevento AS CHAR FORMAT "x(50)"                              
    FIELD qtevento AS INTE FORMAT "zzzzzzzz9"                        
    INDEX tt-dep-compe-i1 dtevento cdevento.                           
                                                                       
DEF TEMP-TABLE crawarq                                                 NO-UNDO
    FIELD nmarquiv AS CHAR              
    FIELD nrsequen AS INTE
    FIELD dtarquiv AS DATE 
    INDEX crawarq1 nmarquiv nrsequen.

DEF TEMP-TABLE tt_tipos_conta
    FIELD inpessoa AS INTEGER
    FIELD cdtipcta AS INTEGER.

DEF BUFFER bb-dep-compe FOR tt-dep-compe.
DEF BUFFER crabarq      FOR crawarq.

FORM tt-553.dtmvtolt COLUMN-LABEL "Data!Movimento"
     aux_qtctaitg    COLUMN-LABEL "Conta!ITG"
     aux_qtprcchq    COLUMN-LABEL "Proces!Chq"
     aux_qtchqadi    COLUMN-LABEL "Proces Chq!Adicional SPB1"
     aux_qttrctbb    COLUMN-LABEL "Transf.!Conta BB"
     aux_qttrfitg    COLUMN-LABEL "Transf Contas!ITG TAA2"
     aux_qtsaqtaa    COLUMN-LABEL "Saque!TAA2"
     aux_qtcopdoc    COLUMN-LABEL "Copia!Docum"
     aux_qtdevchq    COLUMN-LABEL "Dev Cheque!Coop"
     aux_qtcordem    COLUMN-LABEL "Contra!Ordem"
     aux_qtdepdin    COLUMN-LABEL "Dep!Dinheiro"
     aux_qtdcompe    COLUMN-LABEL "Dep Dinheiro!Compe"
     aux_qtoutros    COLUMN-LABEL "Outros"
     aux_qtevento    COLUMN-LABEL "Total!Eventos"
     WITH DOWN NO-BOX NO-ATTR-SPACE WIDTH 132 FRAME f_rel_dt_movto.

FORM tt-553.cdagenci COLUMN-LABEL "PA"
     aux_qtctaitg    COLUMN-LABEL "Conta!ITG"
     aux_qtprcchq    COLUMN-LABEL "Proces!Chq"
     aux_qtchqadi    COLUMN-LABEL "Proces Chq!Adicional SPB1"
     aux_qttrctbb    COLUMN-LABEL "Transf.!Conta BB"
     aux_qttrfitg    COLUMN-LABEL "Transf Contas!ITG TAA2"
     aux_qtsaqtaa    COLUMN-LABEL "Saque!TAA2"
     aux_qtcopdoc    COLUMN-LABEL "Copia!Docum"
     aux_qtdevchq    COLUMN-LABEL "Dev Cheque!Coop"
     aux_qtcordem    COLUMN-LABEL "Contra!Ordem"
     aux_qtdepdin    COLUMN-LABEL "Dep!Dinheiro"
     aux_qtdcompe    COLUMN-LABEL "Dep Dinheiro!Compe"
     aux_qtoutros    COLUMN-LABEL "Outros"
     aux_qtevento    COLUMN-LABEL "Total por!PA"
     WITH DOWN NO-BOX NO-ATTR-SPACE WIDTH 132 FRAME f_rel_pac.

FORM tt-pac-zero.nrdctitg COLUMN-LABEL "Conta  ITG" 
     tt-pac-zero.nmprimtl COLUMN-LABEL "Titular"
     tt-pac-zero.nrcpfcgc COLUMN-LABEL "CPF"
     tt-pac-zero.dsdifere COLUMN-LABEL "Erro"
     WITH DOWN NO-BOX NO-ATTR-SPACE WIDTH 132 FRAME f_pac-zero.

FORM tt-dep-compe.dtevento COLUMN-LABEL "Data"
     tt-dep-compe.cdevento COLUMN-LABEL "Evento"
     tt-dep-compe.dsevento COLUMN-LABEL "Descricao"
     tt-dep-compe.qtevento COLUMN-LABEL "Quantidade!Registros"
     WITH DOWN NO-BOX NO-ATTR-SPACE WIDTH 132 FRAME f_dep-compe.

ASSIGN glb_cdprogra = "crps527"
       glb_flgbatch = FALSE
       aux_nmarqlog = "log/prcitg_" + STRING(YEAR(glb_dtmvtolt),"9999") + 
                      STRING(MONTH(glb_dtmvtolt),"99") + 
                      STRING(DAY(glb_dtmvtolt),"99") + ".log".

RUN fontes/iniprg.p.

IF  glb_cdcritic > 0  THEN
    RETURN.

FIND FIRST crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR. 

IF  NOT AVAILABLE crapcop  THEN
    DO:
        glb_cdcritic = 651.
        RUN fontes/critic.p.
        UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                          " - " + glb_cdprogra + "' --> '"  +
                          glb_dscritic + " >> " + aux_nmarqlog).
        RUN fontes/fimprg.p.
        RETURN.
    END.

INPUT STREAM str_1 THROUGH VALUE("ls /micros/" + crapcop.dsdircop + 
             "/compel/recepcao/COO553*.ret 2> /dev/null") NO-ECHO.

DO WHILE TRUE ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:
   
   IMPORT STREAM str_1 UNFORMATTED aux_nmarquiv.
   
   ASSIGN aux_contador = aux_contador + 1
          aux_nmarqdat = "/micros/" + crapcop.dsdircop + "/compel/recepcao/" + 
                         "COO553" + STRING(DAY(glb_dtmvtolt),"99") +
                         STRING(MONTH(glb_dtmvtolt),"99") +
                         STRING(YEAR(glb_dtmvtolt),"9999") +
                         STRING(aux_contador,"999").

   UNIX SILENT VALUE("dos2ux " + aux_nmarquiv + " > " + aux_nmarqdat + 
                     " 2> /dev/null").
   
   UNIX SILENT VALUE("cp " + aux_nmarquiv + " " + "/micros/" + 
                     crapcop.dsdircop + "/compel/recepcao/retornos").

   UNIX SILENT VALUE("rm " + aux_nmarquiv + " 2> /dev/null").
                     
   INPUT STREAM str_2 FROM VALUE(aux_nmarqdat) NO-ECHO.
       
   IMPORT STREAM str_2 UNFORMATTED aux_strlinha.

   CREATE crawarq.
   ASSIGN crawarq.nrsequen = INTE(SUBSTR(aux_strlinha,26,5))
          crawarq.nmarquiv = aux_nmarqdat.

   INPUT STREAM str_2 CLOSE.
                                                       
END. /** Fim do DO WHILE TRUE **/  

INPUT STREAM str_1 CLOSE.

ASSIGN tot_qtctaitg  = 0.

FOR EACH crawarq NO-LOCK:

    INPUT STREAM str_1 FROM VALUE(crawarq.nmarquiv) NO-ECHO.

    DO WHILE TRUE ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:
              
        IMPORT STREAM str_1 UNFORMATTED aux_strlinha.

        IF  SUBSTR(aux_strlinha,1,5) = ""       OR 
            SUBSTR(aux_strlinha,1,5) = "00000"  OR    /** Header  **/
            SUBSTR(aux_strlinha,1,5) = "99999"  THEN  /** Trailer **/
            NEXT.
      
        ASSIGN aux_nrdctitg = SUBSTR(aux_strlinha,6,8)
               aux_dtmvtolt = DATE(SUBSTR(aux_strlinha,84,8))
               aux_cdevento = SUBSTR(aux_strlinha,14,12).

        FIND crapass WHERE crapass.cdcooper = glb_cdcooper AND
                           crapass.nrdctitg = aux_nrdctitg NO-LOCK NO-ERROR.

        CREATE tt-553.
        ASSIGN tt-553.cdagenci = IF  AVAILABLE crapass  THEN
                                     crapass.cdagenci 
                                 ELSE
                                     0
               tt-553.dtmvtolt = aux_dtmvtolt
               tt-553.nrdctitg = aux_nrdctitg.

        CASE aux_cdevento: 
            WHEN "000600270006" THEN 
                 ASSIGN tt-553.qttrctbb = tt-553.qttrctbb + 1.
            WHEN "000600270003" THEN 
                 ASSIGN tt-553.qtsaqtaa = tt-553.qtsaqtaa + 1.
            WHEN "000600270004" OR 
            WHEN "000600270008" THEN 
                 ASSIGN tt-553.qtdepdin = tt-553.qtdepdin + 1.
            WHEN "000600020035" OR 
            WHEN "000600010042" THEN 
                 ASSIGN tt-553.qtprcchq = tt-553.qtprcchq + 1.
            WHEN "000600010038" OR 
            WHEN "000600010235" THEN 
                 ASSIGN tt-553.qtcopdoc = tt-553.qtcopdoc + 1.
             
            WHEN "000600020053" THEN 
                 ASSIGN tt-553.qtchqadi = tt-553.qtchqadi + 1.
            WHEN "000600010048" OR 
            WHEN "000600010047" OR
            WHEN "000600020236" THEN  
                 ASSIGN tt-553.qtdevchq = tt-553.qtdevchq + 1.
            WHEN "000600010051" THEN 
                 ASSIGN tt-553.qtcordem = tt-553.qtcordem + 1.
            WHEN "000600270005" THEN 
                 ASSIGN tt-553.qttrfitg = tt-553.qttrfitg + 1.
            WHEN "000600010035" OR 
            WHEN "000600010045" OR 
            WHEN "000600020210" OR 
            WHEN "000600020211" THEN 
                 ASSIGN tt-553.qtoutros = tt-553.qtoutros + 1.
            OTHERWISE 
                DO: 
                    ASSIGN tt-553.qtdcompe = tt-553.qtdcompe + 1.

                    FIND tt-dep-compe WHERE 
                         tt-dep-compe.dtevento = aux_dtmvtolt AND
                         tt-dep-compe.cdevento = aux_cdevento
                         EXCLUSIVE-LOCK NO-ERROR.
                            
                    IF  NOT AVAIL tt-dep-compe  THEN 
                        DO:
                            CREATE tt-dep-compe.
                            ASSIGN tt-dep-compe.dtevento = aux_dtmvtolt
                                   tt-dep-compe.cdevento = aux_cdevento
                                   tt-dep-compe.dsevento = SUBSTR(aux_strlinha,
                                                                  26,50)
                                   tt-dep-compe.qtevento = 0.
                        END.
                          
                    ASSIGN tt-dep-compe.qtevento = tt-dep-compe.qtevento + 1.
                END.
        END CASE.

    END. /** Fim do DO WHILE TRUE **/

   UNIX SILENT VALUE("mv " + crawarq.nmarquiv + " /usr/coop/" + 
                     crapcop.dsdircop + "/salvar/").
                   
   INPUT STREAM str_1 CLOSE.

   UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                     " - COO553 - " + glb_cdprogra + "' --> '"  +
                     "ARQUIVO PROCESSADO COM SUCESSO - " +
                     SUBSTR(crawarq.nmarquiv,R-INDEX(crawarq.nmarquiv,"/") + 1)
                     + " >> " + aux_nmarqlog).
   
END. /** Fim do FOR EACH crawarq **/

/* .............................. ARQUIVO COO552 ............................ */

EMPTY TEMP-TABLE crawarq.

INPUT STREAM str_1 THROUGH VALUE("ls /usr/coop/" + crapcop.dsdircop + 
                                 "/salvar/coo552* 2> /dev/null") NO-ECHO.

DO WHILE TRUE ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:

   IMPORT STREAM str_1 UNFORMATTED aux_nmarquiv.

   INPUT STREAM str_2 FROM VALUE(aux_nmarquiv) NO-ECHO.

   IMPORT STREAM str_2 UNFORMATTED aux_strlinha.
   
   CREATE crawarq.
   ASSIGN crawarq.nrsequen = INTE(SUBSTR(aux_strlinha,26,5)) 
          crawarq.nmarquiv = aux_nmarquiv
          aux_nmarquiv     = ENTRY(NUM-ENTRIES(aux_nmarquiv,"/"),
                                   aux_nmarquiv,"/")
          crawarq.dtarquiv = DATE((INTE(SUBSTR(aux_nmarquiv,9,2))),
                                  (INTE(SUBSTR(aux_nmarquiv,7,2))),
                                  (INTE(SUBSTR(aux_nmarquiv,11,4)))).

   INPUT STREAM str_2 CLOSE.

END.  

INPUT STREAM str_1 CLOSE.

/** Verifica qual arquivo eh mais recente **/
FOR EACH crawarq NO-LOCK BY crawarq.dtarquiv DESC:
    
    FOR EACH crabarq WHERE crabarq.dtarquiv < crawarq.dtarquiv EXCLUSIVE-LOCK:

        DELETE crabarq.

    END.

END.

FOR EACH crawarq NO-LOCK:

    INPUT STREAM str_1 FROM VALUE(crawarq.nmarquiv) NO-ECHO.
    
    DO WHILE TRUE ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:
       
        IMPORT STREAM str_1 UNFORMATTED aux_strlinha.

        IF  SUBSTR(aux_strlinha,1,5) = ""       OR
            SUBSTR(aux_strlinha,1,5) = "00000"  OR
            SUBSTR(aux_strlinha,1,5) = "99999"  THEN
            NEXT.
          
        IF  INTE(SUBSTR(aux_strlinha,6,2)) = 1  THEN
            DO:
                IF  SUBSTR(aux_strlinha,52,9) = "ENCERRADA"  THEN
                    ASSIGN aux_flgencer = TRUE.
                ELSE
                    ASSIGN aux_flgencer = FALSE.
            END. 
        ELSE 
        IF  INTE(SUBSTR(aux_strlinha,06,02)) = 2  AND
            INTE(SUBSTR(aux_strlinha,16,02)) = 1  THEN /** 1o. Titular **/
            DO:
                FIND crapass WHERE crapass.cdcooper = glb_cdcooper AND
                                   crapass.nrcpfcgc = DECI(SUBSTR(aux_strlinha,
                                                           18,14))
                                   NO-LOCK NO-ERROR.
                   
                ASSIGN aux_flpaczer = FALSE.

                IF  AVAILABLE crapass  THEN 
                    DO:
                        IF (crapass.nrdctitg = ""  OR 
                            crapass.flgctitg <> 2) AND
                            NOT aux_flgencer       THEN
                            DO: 
                                FOR EACH tt-553 WHERE 
                                         tt-553.nrdctitg = crapass.nrdctitg
                                         EXCLUSIVE-LOCK:
                                      
                                    ASSIGN tt-553.cdagenci = 0
                                           aux_flpaczer    = TRUE.
                                                 
                                END.           
                            END.
                             
                        IF  crapass.flgctitg = 2    AND 
                            crapass.nrdctitg <> ""  AND 
                            aux_flgencer            THEN
                            DO:
                                FOR EACH tt-553 WHERE 
                                         tt-553.nrdctitg = crapass.nrdctitg
                                         EXCLUSIVE-LOCK:
  
                                    ASSIGN tt-553.cdagenci = 0 
                                           aux_flpaczer    = TRUE.
                                  
                                END.
                            END.

                        IF  aux_flpaczer  THEN 
                            DO:
                                FIND tt-pac-zero WHERE 
                                     tt-pac-zero.nrdctitg = crapass.nrdctitg
                                     EXCLUSIVE-LOCK NO-ERROR.
                                      
                                IF  NOT AVAIL tt-pac-zero  THEN   
                                    CREATE tt-pac-zero.
                                      
                                ASSIGN tt-pac-zero.nrdctitg = crapass.nrdctitg
                                       tt-pac-zero.nmprimtl = crapass.nmprimtl
                                       tt-pac-zero.nrcpfcgc = 
                                                     STRING(crapass.nrcpfcgc).
                                    
                                IF  crapass.flgctitg = 2 THEN
                                    DO:
                                        { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

                                        RUN STORED-PROCEDURE pc_lista_tipo_conta_itg
                                        aux_handproc = PROC-HANDLE NO-ERROR (INPUT 1,    /* Flag conta itg */
                                                                             INPUT 0,    /* modalidade */
                                                                            OUTPUT "",   /* Tipos de conta */
                                                                            OUTPUT "",   /* Flag Erro */
                                                                            OUTPUT "").  /* Descrição da crítica */

                                        CLOSE STORED-PROC pc_lista_tipo_conta_itg
                                              aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

                                        { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

                                        ASSIGN aux_tpsconta = ""
                                               aux_des_erro = ""
                                               aux_dscritic = ""
                                               aux_tpsconta = pc_lista_tipo_conta_itg.pr_tiposconta 
                                                              WHEN pc_lista_tipo_conta_itg.pr_tiposconta <> ?
                                               aux_des_erro = pc_lista_tipo_conta_itg.pr_des_erro 
                                                              WHEN pc_lista_tipo_conta_itg.pr_des_erro <> ?
                                               aux_dscritic = pc_lista_tipo_conta_itg.pr_dscritic
                                                              WHEN pc_lista_tipo_conta_itg.pr_dscritic <> ?.

                                        IF aux_des_erro = "NOK"  THEN
                                            DO:
                                                glb_dscritic = aux_dscritic.
                                                UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                                                  " - " + glb_cdprogra + "' --> '"  +
                                                                  glb_dscritic + " >> " + aux_nmarqlog).
                                                RUN fontes/fimprg.p.
                                                RETURN.
                                            END.
                                        
                                        /* Inicializando objetos para leitura do XML */ 
                                        CREATE X-DOCUMENT xDoc.    /* Vai conter o XML completo */ 
                                        CREATE X-NODEREF  xRoot.   /* Vai conter a tag DADOS em diante */ 
                                        CREATE X-NODEREF  xRoot2.  /* Vai conter a tag INF em diante */ 
                                        CREATE X-NODEREF  xField.  /* Vai conter os campos dentro da tag INF */ 
                                        CREATE X-NODEREF  xText.   /* Vai conter o texto que existe dentro da tag xField */ 
                                        
                                        EMPTY TEMP-TABLE tt_tipos_conta.
                                        
                                        /* Efetuar a leitura do XML*/ 
                                        SET-SIZE(ponteiro_xml) = LENGTH(aux_tpsconta) + 1. 
                                        PUT-STRING(ponteiro_xml,1) = aux_tpsconta. 
                                           
                                        IF ponteiro_xml <> ? THEN
                                            DO:
                                                xDoc:LOAD("MEMPTR",ponteiro_xml,FALSE). 
                                                xDoc:GET-DOCUMENT-ELEMENT(xRoot).
                                            
                                                DO  aux_cont_raiz = 1 TO xRoot:NUM-CHILDREN: 
                                            
                                                    xRoot:GET-CHILD(xRoot2,aux_cont_raiz).
                                            
                                                    IF xRoot2:SUBTYPE <> "ELEMENT" THEN 
                                                     NEXT. 
                                            
                                                    IF xRoot2:NUM-CHILDREN > 0 THEN
                                                      CREATE tt_tipos_conta.
                                            
                                                    DO aux_cont = 1 TO xRoot2:NUM-CHILDREN:
                                                        
                                                        xRoot2:GET-CHILD(xField,aux_cont).
                                                            
                                                        IF xField:SUBTYPE <> "ELEMENT" THEN 
                                                            NEXT. 
                                                        
                                                        xField:GET-CHILD(xText,1).
                                                       
                                                        ASSIGN tt_tipos_conta.inpessoa =  INT(xText:NODE-VALUE) WHEN xField:NAME = "inpessoa".
                                                        ASSIGN tt_tipos_conta.cdtipcta =  INT(xText:NODE-VALUE) WHEN xField:NAME = "cdtipo_conta".
                                                        
                                                    END. 
                                                    
                                                END.
                                            
                                                SET-SIZE(ponteiro_xml) = 0. 
                                            END.

                                        DELETE OBJECT xDoc. 
                                        DELETE OBJECT xRoot. 
                                        DELETE OBJECT xRoot2. 
                                        DELETE OBJECT xField. 
                                        DELETE OBJECT xText.
                                        
                                        FIND tt_tipos_conta WHERE tt_tipos_conta.inpessoa = crapass.inpessoa AND
                                                                  tt_tipos_conta.cdtipcta = crapass.cdtipcta NO-LOCK NO-ERROR.

                                        IF AVAILABLE tt_tipos_conta THEN
                                    ASSIGN tt-pac-zero.dsdifere = 
                                                "CONTA INTEGRACAO ATIVA NA " +
                                                "COOP E ENCERRADA NO BB".
                                    END.

                                IF  crapass.nrdctitg = ""  OR
                                    crapass.flgctitg <> 2  THEN
                                    ASSIGN tt-pac-zero.dsdifere = 
                                                "CONTA INTEGRACAO ATIVA NO " +
                                                "BB E ENCERRADA NA COOP".
                            END.                       
                    END.
                ELSE 
                    DO:
                        FIND crapass WHERE 
                             crapass.cdcooper = glb_cdcooper AND
                             crapass.nrdctitg = SUBSTR(aux_strlinha,8,8)
                             NO-LOCK NO-ERROR.

                        IF  AVAILABLE crapass  THEN 
                            DO:
                                FOR EACH tt-553 WHERE 
                                         tt-553.nrdctitg = crapass.nrdctit 
                                         EXCLUSIVE-LOCK:
                                                    
                                    ASSIGN tt-553.cdagenci = 0
                                           aux_flpaczer    = TRUE.
                                                  
                                END.
                                                  
                                IF  aux_flpaczer  THEN 
                                    DO:         
                                        FIND tt-pac-zero WHERE
                                        tt-pac-zero.nrdctitg = crapass.nrdctitg
                                        EXCLUSIVE-LOCK NO-ERROR.

                                        IF  NOT AVAILABLE tt-pac-zero  THEN 
                                            CREATE tt-pac-zero.
                                           
                                        ASSIGN tt-pac-zero.nrdctitg = 
                                                           crapass.nrdctitg
                                               tt-pac-zero.nmprimtl = 
                                                           crapass.nmprimtl
                                               tt-pac-zero.nrcpfcgc = 
                                                    STRING(crapass.nrcpfcgc)
                                               tt-pac-zero.dsdifere = 
                                                           "CPF NAO CONFERE".
                                    END. 
                            END.               
                    END.
            END.  
    
        ASSIGN tot_qtctaitg  = tot_qtctaitg + 1.

    END. /** Fim do DO WHILE TRUE **/

    INPUT STREAM str_1 CLOSE.

END. /** Fim do FOR EACH crawarq **/

/* ............................. Saida Relatorio ............................ */

ASSIGN aux_nmarqimp = "/usr/coop/" + crapcop.dsdircop + "/rl/crrl513.lst"
       glb_cdrelato = 513
       glb_progerad = "527"
       glb_nmarqimp = aux_nmarqimp
       glb_nmformul = "132col"
       glb_nrdevias = 1
       glb_nrcopias = 1.

{ includes/cabrel132_1.i }  

OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 84.

VIEW STREAM str_1 FRAME f_cabrel132_1.

ASSIGN tot_qtctaitg = 0   tot_qttrctbb = 0
       tot_qtsaqtaa = 0   tot_qtdepdin = 0
       tot_qtprcchq = 0   tot_qtcopdoc = 0
       tot_qtchqadi = 0   tot_qtdevchq = 0
       tot_qtcordem = 0   tot_qttrfitg = 0
       tot_qtdcompe = 0   tot_qtoutros = 0
       tot_qtevento = 0.

/* totaliza numero de contas itg ativas */
FOR EACH crapass WHERE crapass.cdcooper  = glb_cdcooper AND
                       crapass.flgctitg  = 2            AND
                       crapass.nrdctitg <> ""           NO-LOCK:

    ASSIGN tot_qtctaitg = tot_qtctaitg + 1.

END.

FOR EACH tt-553 NO-LOCK BREAK BY tt-553.dtmvtolt:

    IF  FIRST-OF(tt-553.dtmvtolt)  THEN 
        DO:
            DISPLAY STREAM str_1 tt-553.dtmvtolt WITH FRAME f_rel_dt_movto.
               
            ASSIGN aux_qtctaitg = 0   aux_qttrctbb = 0
                   aux_qtsaqtaa = 0   aux_qtdepdin = 0
                   aux_qtprcchq = 0   aux_qtcopdoc = 0
                   aux_qtchqadi = 0   aux_qtdevchq = 0
                   aux_qtcordem = 0   aux_qttrfitg = 0
                   aux_qtdcompe = 0   aux_qtoutros = 0
                   aux_qtevento = 0.
        END.

    ASSIGN aux_qttrctbb = aux_qttrctbb + tt-553.qttrctbb  
           aux_qtsaqtaa = aux_qtsaqtaa + tt-553.qtsaqtaa         
           aux_qtdepdin = aux_qtdepdin + tt-553.qtdepdin    
           aux_qtprcchq = aux_qtprcchq + tt-553.qtprcchq      
           aux_qtcopdoc = aux_qtcopdoc + tt-553.qtcopdoc     
           aux_qtchqadi = aux_qtchqadi + tt-553.qtchqadi 
           aux_qtdevchq = aux_qtdevchq + tt-553.qtdevchq    
           aux_qtcordem = aux_qtcordem + tt-553.qtcordem      
           aux_qttrfitg = aux_qttrfitg + tt-553.qttrfitg
           aux_qtdcompe = aux_qtdcompe + tt-553.qtdcompe       
           aux_qtoutros = aux_qtoutros + tt-553.qtoutros
           aux_qtevento = aux_qtevento + 1.

    IF  LAST-OF (tt-553.dtmvtolt)  THEN 
        DO:
            DISPLAY STREAM str_1 aux_qtprcchq aux_qtchqadi 
                                 aux_qttrctbb aux_qttrfitg 
                                 aux_qtsaqtaa aux_qtcopdoc 
                                 aux_qtdevchq aux_qtcordem 
                                 aux_qtdepdin aux_qtdcompe 
                                 aux_qtoutros aux_qtevento 
                                 WITH FRAME f_rel_dt_movto.
             
            DOWN STREAM str_1 WITH FRAME f_rel_dt_movto.

            ASSIGN tot_qttrctbb = aux_qttrctbb + tot_qttrctbb
                   tot_qtsaqtaa = aux_qtsaqtaa + tot_qtsaqtaa       
                   tot_qtdepdin = aux_qtdepdin + tot_qtdepdin
                   tot_qtprcchq = aux_qtprcchq + tot_qtprcchq
                   tot_qtcopdoc = aux_qtcopdoc + tot_qtcopdoc
                   tot_qtchqadi = aux_qtchqadi + tot_qtchqadi
                   tot_qtdevchq = aux_qtdevchq + tot_qtdevchq
                   tot_qtcordem = aux_qtcordem + tot_qtcordem
                   tot_qttrfitg = aux_qttrfitg + tot_qttrfitg
                   tot_qtdcompe = aux_qtdcompe + tot_qtdcompe
                   tot_qtoutros = aux_qtoutros + tot_qtoutros
                   tot_qtevento = aux_qtevento + tot_qtevento.
        END.

END. /** Fim do FOR EACH tt-553 **/

DISPLAY STREAM str_1 "TOTAL:"     @ tt-553.dtmvtolt
                     tot_qtctaitg @ aux_qtctaitg        
                     tot_qtprcchq @ aux_qtprcchq       
                     tot_qtchqadi @ aux_qtchqadi  
                     tot_qttrctbb @ aux_qttrctbb   
                     tot_qttrfitg @ aux_qttrfitg 
                     tot_qtsaqtaa @ aux_qtsaqtaa          
                     tot_qtcopdoc @ aux_qtcopdoc      
                     tot_qtdevchq @ aux_qtdevchq     
                     tot_qtcordem @ aux_qtcordem       
                     tot_qtdepdin @ aux_qtdepdin     
                     tot_qtdcompe @ aux_qtdcompe        
                     tot_qtoutros @ aux_qtoutros           
                     tot_qtevento @ aux_qtevento             
                     WITH FRAME f_rel_dt_movto.

ASSIGN tot_qtctaitg = 0   tot_qttrctbb = 0
       tot_qtsaqtaa = 0   tot_qtdepdin = 0
       tot_qtprcchq = 0   tot_qtcopdoc = 0
       tot_qtchqadi = 0   tot_qtdevchq = 0
       tot_qtcordem = 0   tot_qttrfitg = 0
       tot_qtdcompe = 0   tot_qtoutros = 0
       tot_qtevento = 0.

PUT STREAM str_1 SKIP(2) "Resumo de Movimentos por PA:" SKIP(2).

FOR EACH tt-553 NO-LOCK BREAK BY tt-553.cdagenci BY tt-553.nrdctitg:  

    IF  FIRST-OF(tt-553.cdagenci)  THEN 
        ASSIGN aux_qtctaitg = 0   aux_qttrctbb = 0
               aux_qtsaqtaa = 0   aux_qtdepdin = 0
               aux_qtprcchq = 0   aux_qtcopdoc = 0
               aux_qtchqadi = 0   aux_qtdevchq = 0
               aux_qtcordem = 0   aux_qttrfitg = 0
               aux_qtdcompe = 0   aux_qtoutros = 0
               aux_qtevento = 0.

    IF  FIRST-OF(tt-553.nrdctitg)  THEN 
        ASSIGN aux_qtctaitg = aux_qtctaitg + 1.
         
    ASSIGN aux_qttrctbb = aux_qttrctbb + tt-553.qttrctbb  
           aux_qtsaqtaa = aux_qtsaqtaa + tt-553.qtsaqtaa         
           aux_qtdepdin = aux_qtdepdin + tt-553.qtdepdin    
           aux_qtprcchq = aux_qtprcchq + tt-553.qtprcchq      
           aux_qtcopdoc = aux_qtcopdoc + tt-553.qtcopdoc     
           aux_qtchqadi = aux_qtchqadi + tt-553.qtchqadi 
           aux_qtdevchq = aux_qtdevchq + tt-553.qtdevchq    
           aux_qtcordem = aux_qtcordem + tt-553.qtcordem      
           aux_qttrfitg = aux_qttrfitg + tt-553.qttrfitg
           aux_qtdcompe = aux_qtdcompe + tt-553.qtdcompe       
           aux_qtoutros = aux_qtoutros + tt-553.qtoutros
           aux_qtevento = aux_qtevento + 1.

    IF  LAST-OF(tt-553.cdagenci)  THEN 
        DO:
            DISPLAY STREAM str_1 tt-553.cdagenci aux_qtctaitg        
                                 aux_qtprcchq    aux_qtchqadi 
                                 aux_qttrctbb    aux_qttrfitg 
                                 aux_qtsaqtaa    aux_qtcopdoc 
                                 aux_qtdevchq    aux_qtcordem 
                                 aux_qtdepdin    aux_qtdcompe
                                 aux_qtoutros    aux_qtevento
                                 WITH FRAME f_rel_pac.
             
            DOWN STREAM str_1 WITH FRAME f_rel_pac.

            ASSIGN tot_qttrctbb = aux_qttrctbb + tot_qttrctbb
                   tot_qtsaqtaa = aux_qtsaqtaa + tot_qtsaqtaa       
                   tot_qtdepdin = aux_qtdepdin + tot_qtdepdin
                   tot_qtprcchq = aux_qtprcchq + tot_qtprcchq
                   tot_qtcopdoc = aux_qtcopdoc + tot_qtcopdoc
                   tot_qtchqadi = aux_qtchqadi + tot_qtchqadi
                   tot_qtdevchq = aux_qtdevchq + tot_qtdevchq
                   tot_qtcordem = aux_qtcordem + tot_qtcordem
                   tot_qttrfitg = aux_qttrfitg + tot_qttrfitg
                   tot_qtdcompe = aux_qtdcompe + tot_qtdcompe
                   tot_qtoutros = aux_qtoutros + tot_qtoutros
                   tot_qtevento = aux_qtevento + tot_qtevento.
        END.
                        
END. /** Fim do FOR EACH tt-553 **/

DISPLAY STREAM str_1 "TOTAL:"     @ tt-553.cdagenci
                     tot_qtctaitg @ aux_qtctaitg        
                     tot_qtprcchq @ aux_qtprcchq       
                     tot_qtchqadi @ aux_qtchqadi  
                     tot_qttrctbb @ aux_qttrctbb   
                     tot_qttrfitg @ aux_qttrfitg 
                     tot_qtsaqtaa @ aux_qtsaqtaa          
                     tot_qtcopdoc @ aux_qtcopdoc      
                     tot_qtdevchq @ aux_qtdevchq     
                     tot_qtcordem @ aux_qtcordem       
                     tot_qtdepdin @ aux_qtdepdin     
                     tot_qtdcompe @ aux_qtdcompe        
                     tot_qtoutros @ aux_qtoutros           
                     tot_qtevento @ aux_qtevento
                     WITH FRAME f_rel_pac.

PUT STREAM str_1 SKIP(2)
    "1 - Processamento de cheque superior a R$ 5.000,00"        SKIP
    "2 - TAA = Terminal de Auto-Atendimento do Banco do Brasil" SKIP.

FIND FIRST bb-dep-compe NO-LOCK NO-ERROR.

IF  AVAILABLE bb-dep-compe  THEN 
    DO:
        PUT STREAM str_1 SKIP(2) 
                         "Eventos Deposito Compe" AT 32
                         "----------------------" AT 32.

        ASSIGN tot_qtdcompe = 0.

        FOR EACH tt-dep-compe NO-LOCK BREAK BY tt-dep-compe.dtevento:
         
            IF  FIRST-OF(tt-dep-compe.dtevento)  THEN
                DO:
                    DISPLAY STREAM str_1 tt-dep-compe.dtevento 
                                         WITH FRAME f_dep-compe.
                      
                    ASSIGN tot_qtevento = 0.
                END.

            DISPLAY STREAM str_1 tt-dep-compe.cdevento 
                                 tt-dep-compe.dsevento 
                                 tt-dep-compe.qtevento WITH FRAME f_dep-compe.
             
            DOWN STREAM str_1 wITH FRAME f_dep-compe.
             
            ASSIGN tot_qtdcompe = tot_qtdcompe + tt-dep-compe.qtevento
                   tot_qtevento = tot_qtevento + tt-dep-compe.qtevento.
            
            IF  LAST-OF(tt-dep-compe.dtevento)  THEN 
                DO:
                    DISPLAY STREAM str_1 
                            "               Total do Dia " + 
                            STRING(tt-dep-compe.dtevento,"99/99/9999") +
                            ".......:"   @ tt-dep-compe.dsevento
                            tot_qtevento @ tt-dep-compe.qtevento 
                            WITH FRAME f_dep-compe.
                      
                    DOWN STREAM str_1 WITH FRAME f_dep-compe.
                END.
        
        END. /** Fim do FOR EACH tt-dep-compe **/

        DISPLAY STREAM str_1 "TOTAL GERAL....:" @ tt-dep-compe.dsevento
                             tot_qtdcompe       @ tt-dep-compe.qtevento 
                             WITH FRAME f_dep-compe.
         
        DOWN STREAM str_1 WITH FRAME f_dep-compe.
    END.


/*--------------------------------Retirado 25/08/2009

PUT STREAM str_1 SKIP(2) "Detalhes das contas com divergencia"
                 SKIP    "-----------------------------------".

FOR EACH tt-pac-zero NO-LOCK BREAK BY tt-pac-zero.nrdctitg:

    DISPLAY STREAM str_1 tt-pac-zero.nrdctitg  
                         tt-pac-zero.nmprimtl       
                         tt-pac-zero.nrcpfcgc           
                         tt-pac-zero.dsdifere WITH FRAME f_pac-zero.
    
    DOWN STREAM str_1 WITH FRAME f_pac-zero.

END. /** Fim do FOR EACH tt-pac-zero **/
--------------------------------------------------------------*/



OUTPUT STREAM str_1 CLOSE.

/** Salvar copia relatorio para "/rlnsv" **/
UNIX SILENT VALUE("cp " + aux_nmarqimp + " rlnsv").

RUN fontes/imprim.p.
                                         
DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

    MESSAGE "(T)erminal ou (I)mpressora: " UPDATE tel_cddopcao.

    HIDE MESSAGE NO-PAUSE.  
         
    IF  tel_cddopcao = "I"  THEN
        DO:
            FIND FIRST crapass WHERE crapass.cdcooper = glb_cdcooper
                                     NO-LOCK NO-ERROR.
                            
            { includes/impressao.i }  
        END.    
    ELSE
    IF  tel_cddopcao = "T"  THEN
        RUN fontes/visrel.p (INPUT aux_nmarqimp).

    LEAVE.

END. /** Fim do DO WHILE TRUE **/

RUN fontes/fimprg.p. 

/* .......................................................................... */
