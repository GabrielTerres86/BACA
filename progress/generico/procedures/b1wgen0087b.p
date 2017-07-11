/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +--------------------------------+-----------------------------------------+
  | Rotina Progress                | Rotina Oracle PLSQL                     |
  +--------------------------------+-----------------------------------------+
  | b1wgen0087.p                   | DDDA0001                                |
  |   busca-cedente-DDA            | DDDA0001.pc_busca_cedente_DDA           |
  |   remessa-titulos-dda          | DDDA0001.pc_remessa_titulos_dda         |
  |   Retorno-Operacao-Titulos-DDA | DDDA0001.pc_retorno_operacao_titulos_DDA|
  |   grava-congpr-dda             | DDDA0001.pc_grava_congpr_dda            |
  |   verifica-sacado-dda          | DDDA0001.pc_verifica_sacado_dda         |
  |   chegada-titulos-dda          | DDDA0001.pc_chegada_titulos_dda         |
  |   titulos-a-pagar              | DDDA0001.pc_titulos_a_pagar             | 
  +--------------------------------+-----------------------------------------+

  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.

  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - GUILHERME STRUBE    (CECRED)
   - MARCOS MARTINI      (SUPERO)

*******************************************************************************/









/*.............................................................................

    Programa  : b1wgen0087.p
    Autor     : Elton
    Data      : Maio/2011                   Ultima Atualizacao: 02/04/2014
    
    Dados referentes ao programa:

    Objetivo  :     PROCEDURES - DDA/COBRANCA REGISTRADA
                
    
    Alteracoes: 01/06/2011 - Retirado MESSAGE "Processando DDA... Aguarde".
                             1- Solicitacao da Rosangela
                             2- Message deve ser utilizado somente para ayllos 
                             caracter que deve ser tratado com idorigem
                             (Guilherme).
                 
                 08/07/2011 - Reduzido de 10 para 5 as tentativas de 
                              recebimento de retorno da JD (Elton).
                              
                 15/09/2011 - Retirado FIND CURRENT que esta provocando
                              erro nos logs (Rafael).
                              
                 18/10/2011 - Ajustado rotina grava-congpr-dda - crps524
                              a fim de economizar conexoes MS-SQL/Server
                              (Rafael).
                              
                 19/10/2011 - Incluida procedure chegada-titulos-dda (Henrique).
                 
                 28/12/2011 - Buscar titulos DDA com chegada em atraso (Rafael).
                 
                 08/03/2012 - Incluido 2 novos campos no registro/alteracao
                              de titulos DDA. (Rafael)
                              
                 31/08/2012 - Incluido parametro "0" - procedure gerar-mensagem
                              devido a melhoria no Servico de Mensagens. (Jorge)
                 
                 03/07/2013 - Incluida procedure titulos-a-pagar (Carlos)

                 16/12/2013 - Conversao de procedures para o projeto Oracle
                              (Gabriel).
                            - Projeto Oracle - adicionado includes (Guilherme).
                            
                 02/04/2014 - Ajuste nas procedures de remessa/retorno de 
                              titulos DDA com blocos de transacao (Rafael).
 ............................................................................*/

{ sistema/generico/includes/b1wgen0087tt.i }
{ sistema/generico/includes/var_oracle.i }

DEF VAR aux_cdcritic AS INTE                                  NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                  NO-UNDO.

PROCEDURE verifica-sacado-dda:

    DEFINE INPUT-OUTPUT PARAM TABLE FOR tt-verifica-sacado.

    
    ASSIGN aux_msgerora = "".
    
    FOR EACH tt-verifica-sacado:
        
        { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }
        
        RUN STORED-PROCEDURE pc_verifica_sacado_DDA 
            aux_handproc = PROC-HANDLE NO-ERROR
                             (INPUT tt-verifica-sacado.tppessoa, 
                              INPUT tt-verifica-sacado.nrcpfcgc,   
                             OUTPUT 0, 
                             OUTPUT 0,
                             OUTPUT "").
        
        CLOSE STORED-PROCEDURE pc_verifica_sacado_DDA 
              WHERE PROC-HANDLE = aux_handproc.
        
        { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }
        
        ASSIGN aux_dscritic = pc_verifica_sacado_DDA.pr_dscritic 
                                WHEN pc_verifica_sacado_DDA.pr_dscritic <> ?.

        IF  aux_dscritic <> ""  THEN
            DO:
                UNIX SILENT VALUE ("echo " + STRING(TIME,"HH:MM:SS")   +
                                   " - B1wgen0087.p ' --> '" +
                                   aux_dscritic + " >> log/stored_procedure.log").
                RETURN "NOK".
            END.

        ASSIGN tt-verifica-sacado.flgsacad = 
                (pc_verifica_sacado_DDA.pr_flgsacad = 1) .

    END.
        
    RETURN "OK".

END PROCEDURE.

PROCEDURE remessa-titulos-DDA:
                         
    DEFINE INPUT-OUTPUT     PARAM TABLE FOR tt-remessa-dda.
    DEFINE OUTPUT           PARAM TABLE FOR tt-retorno-dda.

    DEFINE VARIABLE         aux_data    AS CHAR             NO-UNDO.
    DEFINE VARIABLE         aux_hora    AS CHAR             NO-UNDO.
        
        
    ASSIGN  aux_data =  STRING(YEAR(TODAY),"9999") +
                        STRING(MONTH(TODAY),"99")  +
                        STRING(DAY(TODAY),"99").

    ASSIGN  aux_hora =  STRING(TIME,"HH:mm:ss")
            aux_hora =  SUBSTR(aux_hora,1,2) +
                        SUBSTR(aux_hora,4,2) +
                        SUBSTR(aux_hora,7,2).

    ASSIGN aux_msgerora = "".
    
    DO TRANSACTION:
    
    FOR EACH wt_remessa_dda EXCLUSIVE-LOCK:
        DELETE wt_remessa_dda.
    END.

    FOR EACH wt_retorno_dda EXCLUSIVE-LOCK:
        DELETE wt_retorno_dda.
    END.
 
    FOR EACH tt-remessa-dda NO-LOCK: 
    
        CREATE wt_remessa_dda.
        ASSIGN wt_remessa_dda.nrispbif = tt-remessa-dda.nrispbif
               wt_remessa_dda.cdlegado = tt-remessa-dda.cdlegado
               wt_remessa_dda.idopeleg = tt-remessa-dda.idopeleg
               wt_remessa_dda.idtitleg = tt-remessa-dda.idtitleg
               wt_remessa_dda.tpoperad = tt-remessa-dda.tpoperad
               wt_remessa_dda.dtoperac = INTE(aux_data)
               wt_remessa_dda.hroperac = INTE(aux_hora)
               wt_remessa_dda.cdifdced = tt-remessa-dda.cdifdced
               wt_remessa_dda.tppesced = tt-remessa-dda.tppesced
               wt_remessa_dda.nrdocced = tt-remessa-dda.nrdocced
               wt_remessa_dda.nmdocede = tt-remessa-dda.nmdocede
               wt_remessa_dda.cdageced = tt-remessa-dda.cdageced
               wt_remessa_dda.nrctaced = tt-remessa-dda.nrctaced
               wt_remessa_dda.tppesori = tt-remessa-dda.tppesori 
               wt_remessa_dda.nrdocori = tt-remessa-dda.nrdocori
               wt_remessa_dda.nmdoorig = tt-remessa-dda.nmdoorig
               wt_remessa_dda.tppessac = tt-remessa-dda.tppessac
               wt_remessa_dda.nrdocsac = tt-remessa-dda.nrdocsac
               wt_remessa_dda.nmdosaca = tt-remessa-dda.nmdosaca
               wt_remessa_dda.dsendsac = tt-remessa-dda.dsendsac
               wt_remessa_dda.dscidsac = tt-remessa-dda.dscidsac
               wt_remessa_dda.dsufsaca = tt-remessa-dda.dsufsaca 
               wt_remessa_dda.tpdocava = tt-remessa-dda.tpdocava
               wt_remessa_dda.nrdocava = tt-remessa-dda.nrdocava
               wt_remessa_dda.nmdoaval = tt-remessa-dda.nmdoaval
               wt_remessa_dda.cdcartei = tt-remessa-dda.cdcartei
               wt_remessa_dda.cddmoeda = tt-remessa-dda.cddmoeda
               wt_remessa_dda.dsnosnum = tt-remessa-dda.dsnosnum
               wt_remessa_dda.dscodbar = tt-remessa-dda.dscodbar
               wt_remessa_dda.dtvencto = tt-remessa-dda.dtvencto
               wt_remessa_dda.vlrtitul = tt-remessa-dda.vlrtitul
               wt_remessa_dda.nrddocto = tt-remessa-dda.nrddocto
               wt_remessa_dda.cdespeci = tt-remessa-dda.cdespeci
               wt_remessa_dda.dtemissa = tt-remessa-dda.dtemissa
               wt_remessa_dda.nrdiapro = tt-remessa-dda.nrdiapro
               wt_remessa_dda.tpdepgto = tt-remessa-dda.tpdepgto
               wt_remessa_dda.indnegoc = tt-remessa-dda.indnegoc
               wt_remessa_dda.vlrabati = tt-remessa-dda.vlrabati 
               wt_remessa_dda.dtdjuros = tt-remessa-dda.dtdjuros
               wt_remessa_dda.dsdjuros = tt-remessa-dda.dsdjuros
               wt_remessa_dda.vlrjuros = tt-remessa-dda.vlrjuros
               wt_remessa_dda.dtdmulta = tt-remessa-dda.dtdmulta 
               wt_remessa_dda.cddmulta = tt-remessa-dda.cddmulta
               wt_remessa_dda.vlrmulta = tt-remessa-dda.vlrmulta
               wt_remessa_dda.flgaceit = tt-remessa-dda.flgaceit
               wt_remessa_dda.dtddesct = tt-remessa-dda.dtddesct
               wt_remessa_dda.cdddesct = tt-remessa-dda.cdddesct
               wt_remessa_dda.vlrdesct = tt-remessa-dda.vlrdesct
               wt_remessa_dda.DSINSTRU = tt-remessa-dda.DSINSTRU
               wt_remessa_dda.DTLIPGTO = tt-remessa-dda.DTLIPGTO
               wt_remessa_dda.TPDBAIXA = tt-remessa-dda.TPDBAIXA
               wt_remessa_dda.DSSITUAC = tt-remessa-dda.DSSITUAC
               wt_remessa_dda.INSITPRO = tt-remessa-dda.INSITPRO
               wt_remessa_dda.TPMODCAL = tt-remessa-dda.TPMODCAL
               wt_remessa_dda.DTVALCAL = tt-remessa-dda.DTVALCAL
               wt_remessa_dda.FLAVVENC = tt-remessa-dda.FLAVVENC
               wt_remessa_dda.VLDSCCAL = tt-remessa-dda.VLDSCCAL
               wt_remessa_dda.NRCEPSAC = tt-remessa-dda.NRCEPSAC
               wt_remessa_dda.VLJURCAL = tt-remessa-dda.VLJURCAL
               wt_remessa_dda.VLMULCAL = tt-remessa-dda.VLMULCAL
               wt_remessa_dda.VLTOTCOB = tt-remessa-dda.VLTOTCOB.
                   
    END.
    
    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} } 
    
    RUN STORED-PROCEDURE pc_remessa_titulos_dda 
        aux_handproc = PROC-HANDLE NO-ERROR
                          (OUTPUT 0,
                           OUTPUT "").

    IF  ERROR-STATUS:ERROR  THEN 
        DO:
            DO  aux_qterrora = 1 TO ERROR-STATUS:NUM-MESSAGES:
                ASSIGN aux_msgerora = aux_msgerora +
                          ERROR-STATUS:GET-MESSAGE(aux_qterrora) + " ".
            END.

            IF  aux_msgerora <> ""  THEN
                DO:
                    UNIX SILENT VALUE ("echo " + STRING(TIME,"HH:MM:SS")   +
                                       " - B1wgen0087.p ' --> '" +
                                       aux_msgerora + 
                                       " >> log/stored_procedure.log").
                    RETURN "NOK".
                END.
        END.
    
    CLOSE STORED-PROCEDURE pc_remessa_titulos_dda 
          WHERE PROC-HANDLE = aux_handproc.
    
    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }    
    
    ASSIGN aux_dscritic = pc_remessa_titulos_dda.pr_dscritic
                                WHEN pc_remessa_titulos_dda.pr_dscritic <> ?.
                                
    IF  aux_dscritic <> ""  THEN
        DO:
            UNIX SILENT VALUE ("echo " + STRING(TIME,"HH:MM:SS")   +
                               " - B1wgen0087.p ' --> '" +
                               aux_dscritic + " >> log/stored_procedure.log").
            RETURN "NOK".
        END.
    
    EMPTY TEMP-TABLE tt-remessa-dda.
    EMPTY TEMP-TABLE tt-retorno-dda.
    
    FOR EACH wt_remessa_dda NO-LOCK:
        CREATE tt-remessa-dda.
        BUFFER-COPY wt_remessa_dda TO tt-remessa-dda.
    END.
    
    FOR EACH wt_retorno_dda NO-LOCK:
        CREATE tt-retorno-dda.
        BUFFER-COPY wt_retorno_dda TO tt-retorno-dda.
    END.

    FOR EACH wt_remessa_dda EXCLUSIVE-LOCK:
        DELETE wt_remessa_dda.
    END.
                
    FOR EACH wt_retorno_dda EXCLUSIVE-LOCK:
        DELETE wt_retorno_dda.
    END.

    END. /* do transaction */

    RETURN "OK".

END PROCEDURE.

PROCEDURE grava-congpr-dda:

   DEF INPUT PARAM par_cdcooper AS INT                             NO-UNDO.
   DEF INPUT PARAM par_datini   AS DATE                            NO-UNDO.
   DEF INPUT PARAM par_datfim   AS DATE                            NO-UNDO.
   DEF INPUT PARAM par_dtmvtolt AS DATE                            NO-UNDO.
   DEF INPUT PARAM par_cdprogra AS CHAR                            NO-UNDO.
    

   ASSIGN aux_msgerora = "".

   { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }

   RUN STORED-PROCEDURE pc_grava_congpr_dda 
       aux_handproc = PROC-HANDLE NO-ERROR 
                       (INPUT par_cdcooper, 
                        INPUT par_datini, 
                        INPUT par_datfim,  
                        INPUT par_dtmvtolt, 
                        OUTPUT "").

   CLOSE STORED-PROCEDURE pc_grava_congpr_dda
         WHERE PROC-HANDLE = aux_handproc.
   
   { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }
   
   ASSIGN aux_dscritic = pc_grava_congpr_dda.pr_dscritic 
                            WHEN pc_grava_congpr_dda.pr_dscritic <> ?.

   IF  aux_dscritic <> ""  THEN
       DO:
           UNIX SILENT VALUE ("echo " + STRING(TIME,"HH:MM:SS")   +
                              " - " + par_cdprogra  +  " ' --> '" + 
                              aux_dscritic + " >> log/stored_procedure.log").

           RETURN "NOK".
       END.

   RETURN "OK".

END PROCEDURE.


PROCEDURE chegada-titulos-dda:

    DEF INPUT PARAM par_cdcooper    AS INT                            NO-UNDO.
    DEF INPUT PARAM par_cdprogra    AS CHAR                           NO-UNDO.
    DEF INPUT PARAM par_dtemiini    AS DATE                           NO-UNDO.
    DEF INPUT PARAM par_dtemifim    AS DATE                           NO-UNDO.
    
    
    ASSIGN aux_msgerora = "".
    
    { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }
    
    RUN STORED-PROCEDURE pc_chegada_titulos_DDA 
        aux_handproc = PROC-HANDLE NO-ERROR
                        (INPUT par_cdcooper, 
                         INPUT par_cdprogra, 
                         INPUT par_dtemiini, 
                         INPUT par_dtemifim,
                        OUTPUT 0,
                        OUTPUT "").   

    CLOSE STORED-PROCEDURE pc_chegada_titulos_DDA
          WHERE PROC-HANDLE = aux_handproc.
    
    { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

    RETURN "OK".

END PROCEDURE. /* FIM chegada-titulos-dda */

PROCEDURE busca-cedente-DDA:

    DEF  INPUT PARAM par_cdcooper    AS INT                           NO-UNDO.
    DEF  INPUT PARAM par_idtitdda    AS DECI                          NO-UNDO.
    DEF OUTPUT PARAM par_nrinsced    AS DECI                          NO-UNDO.
    
    DEF VAR aux_nrinsced             AS DECI                          NO-UNDO.


    ASSIGN aux_msgerora = "".

    { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }
    
    RUN STORED-PROCEDURE pc_busca_cedente_DDA 
        aux_handproc = PROC-HANDLE NO-ERROR 
                        (INPUT par_cdcooper,
                         INPUT par_idtitdda,
                        OUTPUT 0,
                        OUTPUT 0,
                        OUTPUT "").

    CLOSE STORED-PROCEDURE pc_busca_cedente_DDA
          WHERE PROC-HANDLE = aux_handproc.
    
    { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }
    
    ASSIGN aux_cdcritic = pc_busca_cedente_DDA.pr_cdcritic 
                            WHEN pc_busca_cedente_DDA.pr_cdcritic <> ?    
           aux_dscritic = pc_busca_cedente_DDA.pr_dscritic 
                            WHEN pc_busca_cedente_DDA.pr_dscritic <> ?.

    IF  aux_cdcritic <> 0   OR
        aux_dscritic <> ""  THEN 
        DO:
            UNIX SILENT VALUE ("echo " + STRING(TIME,"HH:MM:SS") +
                               " - B1wgen0087 ' --> '" + aux_dscritic +
                               " >> log/stored_procedure.log").
    
            RETURN "NOK".                   
        END.
    
    ASSIGN aux_nrinsced = pc_busca_cedente_DDA.pr_nrinsced
                           WHEN pc_busca_cedente_DDA.pr_nrinsced <> ?
                           
           par_nrinsced = aux_nrinsced.

    RETURN "OK".

END PROCEDURE. /* FIM busca-cedente-DDA */

/**
    Popula tt-pagar com os titulos a pagar a partir de R$ 250.000 de todas as
    cooperativas nos proximos 7 dias.
*/
PROCEDURE titulos-a-pagar:

    DEF INPUT  PARAM           par_dtmvtolt AS DATE     NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-pagar.

    RETURN "OK".
    
END PROCEDURE. /* FIM */
