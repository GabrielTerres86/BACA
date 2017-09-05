/* ..........................................................................

   Programa: Fontes/crps662.p  
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Tiago     
   Data    : Fevereiro/2014.                    Ultima atualizacao: 31/08/2017

   Dados referentes ao programa:

   Frequencia: Diario (Batch).
   Objetivo  : Envio automatico dos arquivos de compensacao.
               
   Alteracoes : 27/06/2014 - Alterado para registrar LOG de execucao no 
                             arquivo de log da tela PRCCTL (Diego).
                             
                01/07/2014 - Corrigida passagem do parametro "cdagenci" para
                             procedure arquivos_noturnos (Diego).   
                             
                02/07/2014 - Incluido EMPTY TEMP-TABLE crawage (Diego).    
                
                15/07/2014 - Criar solicitacao 78 nas filiadas quando processar
                             DEVOLU
                           - Eliminar relatorios do diretorio /micros/cecred/compel
                           - Incluido parametro na chamada do script ftpabbc_envia
                            (Diego).            
                            
                02/09/2014 - Desconsiderar cooperativas inativas na efetivacao
                             de agendamentos (David).
                
                30/10/2014 - Automatizacao da DEBCNS (Tiago SD170356)             
                
                06/11/2014 - Envio dos arquivos apenas quando houver 
                             processamento de geracao ou importacao de
                             arquivos (Tiago SD199974)
                
                07/11/2014 - Adicionado tratamento para a migracao VIACON.
                             (Reinert)        
             
                11/11/2014 -  Ajuste para inclusao da chamada do crps688
                                                     (Adriano)
                                                                  
                28/11/2014 - Comentar critica de titulos nao conferem (Ze).
                
                28/04/2015 - Ajustes referente Projeto Cooperativa Emite e Expede 
                             (Daniel/Rafael/Reinert) 
                             
                17/11/2015 - Removido a include do crps509.i e removido as
                             chamadas para os crps509 e crps642 que estavam
                             comentadas, mantendo apenas a chamado Oracle
                             (Douglas - Chamado 285228)
                
                20/11/2015 - Remover execucao da DEBNET e DEBSIC do programa,
                             procedimentos serao executados via job no oracle
                             SD358495 e SD358499 (Odirlei-AMcom)     
                                     
                15/12/2015 - Passado parametro para procedure efetua-debito-consorcio 
                             como FALSE (processo manual) - Tiago/Elton 
                             
                23/02/2016 - Incluido execucao ARQUIVOS SICREDI para todas
                             coops no processo automatico 
                             (Tiago/Elton SD398736)
                             
                05/04/2016 - Alterado para gravar as criticas no log do proc_message
                             e nao mais no proc_batch.log SD402939 (Odirlei-AMcom)
                
                
                21/06/2016 - Ajuste para utilizar o pacote transabbc ao chamar o script
                             de comunicação com a ABBC, ao invés de deixar o IP fixo
                            (Adriano - SD 468880).

                24/10/2016 - Ajustes para terceira execucao dos proocessos
                             DEBSIC, DEBCNS, DEBNET - Melhoria349 (Tiago/Elton).
                             
                03/01/2017 - Ajuste incorporacao no envio de arquivos (Diego).
                
				13/01/2017 - Transposul - Incluido envio DEVDOC (Diego). 
                
                09/03/2017 - Ajuste envio de arquivos devolucao da cobranca
                             sua remessa 085 Cecred - 2*.DVS (Rafael).
                
                17/05/2017 - Remover a procedure proc_verifica_pac_internet e suas chamadas,
                             pois a mensagem de erro do LOOP está comentada desde a 
                             alteracao de "28/11/2014", como nao existe mais validacao do 
                             erro o LOOP nao é mais necessário (Douglas - Chamado 666540)

                31/08/2017 - Ajustado rotina de envio de arquivos para a ABBC
                             para nao enviar arquivos 2*.DVS em feriados. (Rafael)
                             
.............................................................................*/

{ includes/var_batch.i "NEW" }
{ sistema/generico/includes/var_oracle.i }
{ sistema/generico/includes/b1wgen0183tt.i }

DEF VAR aux_cdcooper AS INTEGER                                        NO-UNDO.
DEF VAR aux_cdcoopin AS INTEGER                                        NO-UNDO.


/* Streams*/
DEF STREAM str_1.
DEF STREAM str_2.
DEF STREAM str_3.
DEF STREAM str_4.
DEF STREAM str_5. /* Verifica arquivos importados */ 

DEF STREAM teste.

DEF BUFFER b-craphec FOR craphec.

/* Variaveis auxiliares */
DEF VAR aux_pacfinal AS INTE                                           NO-UNDO.
DEF VAR aux_qtarquiv AS INTE                                           NO-UNDO.
DEF VAR aux_totregis AS INTE                                           NO-UNDO.
DEF VAR aux_vlrtotal AS DECI                                           NO-UNDO.
DEF VAR aux_nrseqsol AS INTE                                           NO-UNDO.
DEF VAR aux_dtmvtopg AS DATE                                           NO-UNDO.
DEF VAR aux_dtrefere AS DATE                                           NO-UNDO.
DEF VAR aux_dstitulo AS CHAR                                           NO-UNDO.
DEF VAR aux_dstiptra AS CHAR                                           NO-UNDO.
DEF VAR aux_qtefetua AS INTE                                           NO-UNDO.
DEF VAR aux_vlefetua AS DECI                                           NO-UNDO.
DEF VAR aux_cdagenci AS INTE                                           NO-UNDO.
DEF VAR aux_contador AS INTE                                           NO-UNDO.
DEF BUFFER crabcop FOR crapcop.
DEF BUFFER crabass FOR crapass.

DEF VAR rel_nmempres AS CHAR    FORMAT "x(15)"                         NO-UNDO.
DEF VAR rel_nmresemp AS CHAR    FORMAT "x(15)"                         NO-UNDO.
DEF VAR rel_nmrelato AS CHAR    FORMAT "x(40)" EXTENT 5                NO-UNDO.
DEF VAR rel_nmmodulo AS CHAR    FORMAT "x(15)" EXTENT 5
                                INIT ["DEP. A VISTA   ","CAPITAL        ",
                                      "EMPRESTIMOS    ","DIGITACAO      ",
                                      "GENERICO       "]               NO-UNDO.

DEF VAR rel_nrmodulo AS INTE    FORMAT "9"                             NO-UNDO.



DEF VAR aux_flsgproc AS LOGICAL                                        NO-UNDO.
DEF VAR aux_nmarqimp AS CHAR                                           NO-UNDO.
DEF VAR aux_nmarquiv AS CHAR                                           NO-UNDO.
DEF VAR aux_nmarqcen AS CHAR                                           NO-UNDO.
DEF VAR aux_nmaqcesv AS CHAR                                           NO-UNDO.
DEF VAR aux_arqlista AS CHAR                                           NO-UNDO.
DEF VAR aux_nrbarras AS INTE                                           NO-UNDO.
DEF VAR aux_arqdolog AS CHAR                                           NO-UNDO.
DEF VAR aux_tparquiv AS CHAR                                           NO-UNDO.
DEF VAR aux_dsarquiv AS CHAR                                           NO-UNDO.
DEF VAR aux_tamarqui AS CHAR                                           NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF VAR aux_tpconsor AS INTE                                           NO-UNDO.
DEF VAR aux_nrctasic AS CHAR                                           NO-UNDO.
DEF VAR aux_dstexarq AS CHAR                                           NO-UNDO.
DEF VAR aux_nrdconta AS INTE                                           NO-UNDO.
DEF VAR aux_nrdolote AS INTE                                           NO-UNDO.
DEF VAR aux_nrdolot1 AS INTE                                           NO-UNDO.
DEF VAR aux_nrdolot2 AS INTE                                           NO-UNDO.
DEF VAR aux_cdcritic AS CHAR                                           NO-UNDO.
                                                                       
DEF VAR aux_cdbccxlt AS INTE                                           NO-UNDO.
                                                                       
DEF VAR aux_flgentra AS LOGICAL                                        NO-UNDO.
DEF VAR flg_ctamigra AS LOGICAL                                        NO-UNDO.
DEF VAR flg_migracao AS LOGICAL                                        NO-UNDO.
DEF VAR flg_envioarq AS LOGICAL       INITIAL FALSE                    NO-UNDO.
DEF VAR aux_nrdocmto AS DECIMAL                                        NO-UNDO.

DEF VAR aux_dscooper AS CHAR FORMAT "x(12)"                            NO-UNDO.
DEF VAR aux_nmprimtl AS CHAR                                           NO-UNDO.
DEF VAR aux_dscopglb AS CHAR                                           NO-UNDO.
DEF VAR aux_cdagencic AS CHAR                                          NO-UNDO.
DEF VAR aux_cdcooperativa AS CHAR                                      NO-UNDO.
DEF VAR aux_nrdcontac AS CHAR                                          NO-UNDO.
DEF VAR aux_nrdoc    AS CHAR FORMAT "x(25)"                            NO-UNDO.                      
/* Arquivo Salvo apos importacao */ 
DEF VAR aux_nmarqslv AS CHAR                                           NO-UNDO.
/* Arquivo integrado/importado */ 
DEF VAR aux_nmarqint AS CHAR                                           NO-UNDO.
DEF VAR aux_dtdebito AS DATE                                           NO-UNDO.
DEF VAR aux_nmrescop AS CHAR                                           NO-UNDO.

{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/b1wgen0001tt.i }
     
/* Buffers */
DEF BUFFER crablcm   FOR craplcm.
DEF BUFFER b-crapcop FOR crapcop.

/* Temp-Tables */
DEF TEMP-TABLE crawarq                                                 NO-UNDO
    FIELD dscooper AS CHAR
    FIELD tparquiv AS CHAR
    FIELD nmarquiv AS CHAR.

DEF TEMP-TABLE w-arquivos                                              NO-UNDO
    FIELD dscooper AS CHAR
    FIELD tparquiv AS CHAR  
    FIELD dsarquiv AS CHAR.

DEF TEMP-TABLE crawage                                                 NO-UNDO
    FIELD cdcooper LIKE crapage.cdcooper
    FIELD cdagenci LIKE crapage.cdagenci
    FIELD nmresage LIKE crapage.nmresage
    FIELD nmcidade LIKE crapage.nmcidade 
    FIELD cdbandoc LIKE crapage.cdbandoc
    FIELD cdbantit LIKE crapage.cdbantit
    FIELD cdagecbn LIKE crapage.cdagecbn
    FIELD cdbanchq LIKE crapage.cdbanchq
    FIELD cdcomchq LIKE crapage.cdcomchq.

DEF TEMP-TABLE tt-obtem-consorcio                                      NO-UNDO
    FIELD cdcooper LIKE crapcop.cdcooper
    FIELD nrdconta LIKE crapcns.nrdconta
    FIELD dsconsor AS   CHAR FORMAT "x(9)"
    FIELD nrcotcns LIKE crapcns.nrcotcns
    FIELD qtparcns LIKE crapcns.qtparcns
    FIELD vlrcarta LIKE crapcns.vlrcarta
    FIELD vlparcns LIKE crapcns.vlparcns
    FIELD dscooper AS   CHAR
    FIELD nmprimtl LIKE crapass.nmprimtl
    FIELD nrctacns LIKE crapcns.nrctacns
    FIELD cdagenci AS   INTE
    FIELD fldebito AS   LOGI
    FIELD dscritic AS   CHAR
    FIELD nrdocmto LIKE craplau.nrdocmto
    FIELD nrdgrupo LIKE crapcns.nrdgrupo
    FIELD nrctrato AS   DECI FORMAT "zzz,zzz,zzz".


/* Handles */
DEF VAR h-b1wgen0012 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0154 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0001 AS HANDLE                                         NO-UNDO.

/* Forms */
FORM SKIP(1)
     "DEBITOS PARA: "                   AT 01
     aux_dtrefere FORMAT "99/99/9999"   AT 15
     aux_dstitulo AT 59 FORMAT "x(13)"
     SKIP(2)
     WITH NO-BOX NO-LABEL WIDTH 132 FRAME f_titulo.

FORM SKIP(1)
     "->"
     aux_dstiptra FORMAT "x(19)" SKIP
     "--->"
     aux_dscooper
     SKIP(1)
     " PA  "
     "CONTA/DV"
     "CTA.CONSOR"
     "NOME                         "
     "TIPO     "
     "GRUPO "
     "      COTA"
     "     VALOR"
     SKIP
     " --- --------- ---------- ----------------------------- ---------"
     "------ ---------- ----------"
     WITH NO-BOX NO-LABEL WIDTH 132 FRAME f_transacao.

FORM SKIP(1)
     "->"
     aux_dstiptra FORMAT "x(19)" SKIP
     "--->"
     aux_dscooper
     WITH NO-BOX NO-LABEL WIDTH 132 FRAME f_transacao1.    

FORM SKIP(1)
     " PA  "
     "CONTA/DV"
     "CTA.CONSOR"
     "NOME                         "
     "TIPO     "
     "GRUPO "
     "      COTA"
     "     VALOR"
     SKIP
     " --- --------- ---------- ----------------------------- ---------"
     "------ ---------- ----------"
     WITH NO-BOX NO-LABEL WIDTH 132 FRAME f_transacao2.

FORM tt-obtem-consorcio.cdagenci FORMAT "zz9"        
     tt-obtem-consorcio.nrdconta FORMAT "zzzz,zzz,9" 
     tt-obtem-consorcio.nrctacns FORMAT "zzzz,zzz,9" 
     tt-obtem-consorcio.nmprimtl FORMAT "x(29)"      
     tt-obtem-consorcio.dsconsor FORMAT "x(9)"       
     tt-obtem-consorcio.nrdgrupo FORMAT "999999"
     tt-obtem-consorcio.nrcotcns FORMAT "zzzz,zzz,9" 
     tt-obtem-consorcio.vlparcns FORMAT "zzz,zz9.99"
     tt-obtem-consorcio.dscritic FORMAT "x(44)"
     WITH NO-BOX NO-LABEL DOWN WIDTH 132 FRAME f_nao_efetuados.

FORM tt-obtem-consorcio.cdagenci FORMAT "zz9"          
     tt-obtem-consorcio.nrdconta FORMAT "zzzz,zzz,9"   
     tt-obtem-consorcio.nrctacns FORMAT "zzzz,zzz,9"   
     tt-obtem-consorcio.nmprimtl FORMAT "x(29)"        
     tt-obtem-consorcio.dsconsor FORMAT "x(9)"         
     tt-obtem-consorcio.nrdgrupo FORMAT "999999"
     tt-obtem-consorcio.nrcotcns FORMAT "zzzz,zzz,9"   
     tt-obtem-consorcio.vlparcns FORMAT "zzz,zz9.99" 
     WITH NO-BOX NO-LABEL DOWN WIDTH 132 FRAME f_efetuados.

FORM SKIP(2)
     "TOTAIS --> Quantidade: "                                      AT 01
     aux_qtefetua FORMAT "zz,zzz,zzz,zz9"                           AT 24
     SKIP
     "                Valor: "                                      AT 01
     aux_vlefetua FORMAT "zzz,zzz,zz9.99"                           AT 24
     WITH NO-BOX NO-LABEL WIDTH 132 FRAME f_total.

/*Include DEBCNS precisa estar nesta posicao no fonte devido a 
 variaveis que precisam estar declaradas antes*/
{ includes/crps663.i }

/******************FUNCTIONS*************************************************/
FUNCTION calcula_dv_bb RETURN CHAR (INPUT par_valor AS CHAR):
    DEF        VAR aux_digito   AS CHAR    INIT ""                   NO-UNDO.
    DEF        VAR aux_posicao  AS INT     INIT 0                    NO-UNDO.
    DEF        VAR aux_peso     AS INT     INIT 9                    NO-UNDO.
    DEF        VAR aux_calculo  AS INT     INIT 0                    NO-UNDO.
    DEF        VAR aux_resto    AS INT     INIT 0                    NO-UNDO.

    DO  aux_posicao = LENGTH(STRING(par_valor)) TO 1 BY -1:
    
        aux_calculo = aux_calculo + (INTEGER(SUBSTRING(STRING(par_valor),
                                                aux_posicao,1)) * aux_peso).
    
        aux_peso = aux_peso - 1.
    
        IF   aux_peso = 1   THEN
             aux_peso = 9.
    
    END.  /*  Fim do DO .. TO  */

    aux_resto = aux_calculo MODULO 11.

    IF aux_resto > 0 AND aux_resto < 10 THEN
       aux_digito = STRING(aux_resto,"9").
    ELSE IF aux_resto = 10 THEN 
       aux_digito = "X".
    ELSE IF aux_resto = 0 THEN 
       aux_digito = "0".

    RETURN aux_digito.

END FUNCTION.

FUNCTION retorna_apenas_dv RETURNS CHAR(INPUT par_valor AS CHAR):

    DEF VAR aux_valor2  AS CHAR NO-UNDO.

    ASSIGN aux_valor2 = SUBSTR(par_valor, 1, LENGTH(par_valor) - 1)
           /*aux_valor2 = REPLACE(aux_valor2, "0", "X").*/
           aux_valor2 = calcula_dv_bb(aux_valor2).

    RETURN aux_valor2.

END FUNCTION.

FUNCTION retorna_sem_dv RETURNS CHAR(INPUT par_valor AS CHAR):

    DEF VAR aux_valor2  AS CHAR NO-UNDO.

    ASSIGN aux_valor2 = SUBSTR(par_valor, 1, LENGTH(par_valor) - 1).

    RETURN aux_valor2.

END FUNCTION.

FUNCTION retorna_complemento RETURNS CHAR   (INPUT par_valor AS CHAR,
                                             INPUT par_zero  AS LOGICAL,
                                             INPUT par_size  AS INT):

    DEF VAR aux_count AS INT NO-UNDO.
    DEF VAR aux_count2 AS INT NO-UNDO.
    
    ASSIGN aux_count = par_size - LENGTH(par_valor)
           aux_count2 = 1.
    
    IF par_zero THEN
    DO:
        DO WHILE aux_count2 <= aux_count:
            ASSIGN par_valor = "0" + par_valor
                   aux_count2 = aux_count2 + 1.
        END.
    END.
    ELSE
    DO:
        DO WHILE aux_count2 <= aux_count:
            ASSIGN par_valor = par_valor + " "
                   aux_count2 = aux_count2 + 1.
        END.
    END.

    RETURN par_valor.

END FUNCTION.


/******************FIM***FUNCTIONS********************************************/


/*************************PRINCIPAL*******************************************/
ASSIGN glb_cdprogra = "crps662"
       glb_cdcooper = 3.
       

/*****************************************************/
FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper
                  NO-LOCK NO-ERROR.

IF NOT AVAIL crapcop THEN
  DO:
     ASSIGN glb_cdcritic = 651.

     RUN fontes/critic.p.
     UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                       " - " + glb_cdprogra + "' --> '"  +
                       glb_dscritic + " >> log/proc_batch.log").

  END.

FIND FIRST crapdat WHERE crapdat.cdcooper = crapcop.cdcooper  
                        NO-LOCK NO-ERROR.

IF NOT AVAIL crapdat THEN
  DO:
      ASSIGN glb_cdcritic = 1.

      RUN fontes/critic.p.
      UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                        " - " + glb_cdprogra + "' --> '"  +
                        glb_dscritic + " >> log/proc_batch.log").

  END.

IF   glb_cdcritic > 0 THEN
     DO:
        UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                          " - " + glb_cdprogra + "' --> '"  +
                          glb_dscritic + " >> log/proc_batch.log").
        RETURN.
     END.

/* Se ainda estiver rodando processo, encerra o programa*/
IF   crapdat.inproces > 3 THEN
     DO: 
        ASSIGN glb_dscritic = "Processo ainda está ativo.".
        UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                          " - " + glb_cdprogra + "' --> '"  +
                          glb_dscritic + " >> log/proc_batch.log").
        RETURN.
     END.


ASSIGN glb_dtmvtolt = crapdat.dtmvtolt
       glb_dtmvtoan = crapdat.dtmvtoan
       glb_cdoperad = "1"
       glb_nmtelant = ""
       glb_flgresta = FALSE
       glb_cdrelato = 0
      
    /* Captura o nome do servidor da variavel de ambiente HOST */ 
       glb_hostname = OS-GETENV("HOST").

/*****************************************************************************/
/*  Geracao dos arquivos, dependendo da rotina ja envia tambem               */
/*****************************************************************************/

/*PRINCIPAL passa pelas cooperativas verificando se ha arquivos para processar
  no dia na tabela craphec olhando data e horario*/
FOR EACH crapcop WHERE crapcop.flgativo = TRUE NO-LOCK:

    /* Se for feriado nao deve processar */
    IF   CAN-DO("1,7",STRING(WEEKDAY(glb_dtmvtolt)))  OR
         CAN-FIND(crapfer WHERE
                  crapfer.cdcooper = crapcop.cdcooper AND
                  crapfer.dtferiad = glb_dtmvtolt)   THEN
         NEXT.

    RUN carrega_agenda_proc(INPUT crapcop.cdcooper,
                            INPUT glb_dtmvtolt,
                            INPUT-OUTPUT TABLE tt-craphec).

    /*Processa os arquivos carregados na temp-table para coop em questão*/
    FOR EACH tt-craphec NO-LOCK:       
            
        /*Criar solicitacao na crapsol dependedo do arquivo que for ser
          gerado ("RELACIONAMENTO", "CCF", "CONTRA-ORDEM", "CUSTODIA") 
                *"RELACIONAMENTO,CONTRA-ORDEM E CCF,ARQUIVOS NOTURNOS" */

        RUN cria_solicitacao(INPUT glb_cdcooper,
                             INPUT glb_dtmvtolt,
                             INPUT tt-craphec.dsprogra,
                             INPUT (IF tt-craphec.dsprogra = "AGENDAMENTO APLICACAO/RESGATE" THEN 
                                       82 
                                    ELSE
                                       199),
                             INPUT 1).

        /*Chama CRPS ou BO correspondente ao arquivo que deve ser gerado*/
        RUN gera_arq(INPUT crapcop.cdcooper,
                     INPUT tt-craphec.dsprogra,
                     INPUT glb_dtmvtolt).

        /*Limpar solicitacao na crapsol dependedo do arquivo que for ser
          gerado ("RELACIONAMENTO", "CCF", "CONTRA-ORDEM", "CUSTODIA") 
                *"RELACIONAMENTO,CONTRA-ORDEM E CCF,ARQUIVOS NOTURNOS" */
        RUN limpa_solicitacao(INPUT glb_cdcooper,
                              INPUT glb_dtmvtolt,
                              INPUT tt-craphec.dsprogra,
                              INPUT (IF tt-craphec.dsprogra = "AGENDAMENTO APLICACAO/RESGATE" THEN 
                                       82 
                                    ELSE
                                       199),
                              INPUT 1).

        /*Se tinha algo pra processar marca a flag de 
         envio dos arquivos*/
        ASSIGN flg_envioarq = TRUE.

    END.

END.
/*****************************************************************************/
/*  Fim da Geracao dos arquivos                                              */
/*****************************************************************************/

/*****************************************************************************/
/*  Inicio da Importacao dos arquivos                                             */
/*****************************************************************************/
FOR EACH crapcop WHERE crapcop.cdcooper <> 3   AND
                       crapcop.flgativo = TRUE NO-LOCK:

    /* Se for feriado nao deve processar */
    IF   CAN-DO("1,7",STRING(WEEKDAY(glb_dtmvtolt)))  OR
         CAN-FIND(crapfer WHERE
                  crapfer.cdcooper = crapcop.cdcooper AND
                  crapfer.dtferiad = glb_dtmvtolt)   THEN
         NEXT.
                   
    RUN carrega_agenda_proc(INPUT crapcop.cdcooper,
                            INPUT glb_dtmvtolt,
                            INPUT-OUTPUT TABLE tt-craphec).
                            
    /*Processa os arquivos carregados na temp-table para coop em questão*/
    FOR EACH tt-craphec NO-LOCK:

        RUN imp_arq(INPUT crapcop.cdcooper,
                    INPUT 0, /*cdagenci*/
                    INPUT tt-craphec.dsprogra,
                    INPUT glb_dtmvtolt,
                    OUTPUT aux_dscritic).

        /*Se tinha algo pra processar marca a flag de 
         envio dos arquivos*/
        ASSIGN flg_envioarq = TRUE.

    END.
END.
/*****************************************************************************/
/*  Fim da Importacao dos arquivos                                                */
/*****************************************************************************/


/*****************************************************************************/
/*  Inicio do Envio dos arquivos                                             */
/*****************************************************************************/

/*So envia os arquivos caso tenha sido agendado alguma operacao de geracao ou
 importacao de arquivos*/
IF  flg_envioarq = TRUE THEN
    DO:
        RUN envia_arq(INPUT 3). /*cdcooper = 3 CECRED*/
    END.

/*****************************************************************************/
/*  Fim do Envio dos arquivos                                                */
/*****************************************************************************/


/*************************FIM**PRINCIPAL**************************************/


/************************************PROCEDURES*******************************/
PROCEDURE carrega_agenda_proc:

    DEF INPUT PARAM par_cdcooper    AS  INTE                        NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt    AS  DATE                        NO-UNDO.
    DEF INPUT-OUTPUT PARAM TABLE FOR tt-craphec.

    /* ler a tabela com os horarios de processamento dos arquivos
     e gravar na temp-table para processamento */

    EMPTY TEMP-TABLE tt-craphec.

    FOR EACH craphec WHERE craphec.cdcooper  =  par_cdcooper AND 
                           craphec.flgativo  =  TRUE         AND
                           craphec.hriniexe  <= TIME         AND
                           craphec.hrfimexe  >= TIME         AND
                           (craphec.dtultexc  < par_dtmvtolt OR
                            craphec.dtultexc = ?)  NO-LOCK:
        CREATE tt-craphec.
        BUFFER-COPY craphec TO tt-craphec.
                
    END.
    
    RETURN "OK".
END PROCEDURE.
                                                                                
PROCEDURE gera_arq:

    DEF INPUT PARAM par_cdcooper    AS  INTE                        NO-UNDO.
    DEF INPUT PARAM par_nmprgexe    AS  CHAR                        NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt    AS  DATE                        NO-UNDO.

    DEF VAR aux_tpdevolu            AS  CHAR                        NO-UNDO.
    DEF VAR aux_nrdbanco            AS  INTE                        NO-UNDO.
    DEF VAR aux_dsmsgerr            AS  CHAR                        NO-UNDO.
    DEF VAR aux_cdagenci            AS  INT                         NO-UNDO.
    DEF VAR tot_qtarquiv            AS  INTE                        NO-UNDO.
    DEF VAR tot_totregis            AS  INTE                        NO-UNDO.
    DEF VAR tot_vlrtotal            AS  INTE                        NO-UNDO.

    /*tratamento para quando par_nmprgexe for DEVOLUCAO trocar para
      DEVOLU e preencher a variavel aux_tpdevolu com o tipo de devolucao*/
    IF  SUBSTR(par_nmprgexe,1,6) = "DEVOLU" THEN
        ASSIGN aux_tpdevolu = TRIM(SUBSTR(par_nmprgexe,10,LENGTH(par_nmprgexe)))
               par_nmprgexe = "DEVOLU".

    CASE par_nmprgexe:

        WHEN "RELACIONAMENTO" THEN DO:
            
            RUN atualiza_status_execucao (INPUT par_nmprgexe,
                                          INPUT par_dtmvtolt,
                                          INPUT par_cdcooper).

            IF   RETURN-VALUE = "NOK" THEN  DO:
            
                 /* Grava Data e Hora da execucao */ 
                 RUN grava_dthr_proc(INPUT par_cdcooper,
                                     INPUT par_dtmvtolt,
                                     INPUT TIME,
                                     INPUT TRIM(par_nmprgexe)). 
         
      
                 RUN gera_log_execucao (INPUT par_nmprgexe,
                                       INPUT "Inicio execucao", 
                                       INPUT par_cdcooper,
                                       INPUT "TODAS").
                 RUN fontes/crps532.p.

                 RUN gera_log_execucao (INPUT par_nmprgexe,
                                       INPUT "Fim execucao", 
                                       INPUT par_cdcooper,
                                       INPUT "TODAS").

            END.
        END.
       
        WHEN "CONTRA-ORDEM E CCF" THEN DO:

            RUN atualiza_status_execucao (INPUT par_nmprgexe,
                                          INPUT par_dtmvtolt,
                                          INPUT par_cdcooper). 

            IF   RETURN-VALUE = "NOK" THEN  DO:

                 /* Grava Data e Hora da execucao */ 
                 RUN grava_dthr_proc(INPUT par_cdcooper,
                                     INPUT par_dtmvtolt,
                                     INPUT TIME,
                                     INPUT TRIM(par_nmprgexe)). 
      
                 RUN gera_log_execucao (INPUT par_nmprgexe + "(CRPS561)",
                                       INPUT "Inicio execucao", 
                                       INPUT par_cdcooper,
                                       INPUT "TODAS").
                 /* CONTRA-ORDEM */ 
                 RUN fontes/crps561.p.
                 RUN gera_log_execucao (INPUT par_nmprgexe + "(CRPS561)",
                                       INPUT "Fim execucao", 
                                       INPUT par_cdcooper,
                                       INPUT "TODAS").
      
                 RUN gera_log_execucao (INPUT par_nmprgexe + "(CRPS549)",
                                       INPUT "Inicio execucao", 
                                       INPUT par_cdcooper,
                                       INPUT "TODAS").
                 /* CCF */ 
                 RUN fontes/crps549.p. 
                 RUN gera_log_execucao (INPUT par_nmprgexe + "(CRPS549)",
                                       INPUT "Fim execucao", 
                                       INPUT par_cdcooper,
                                       INPUT "TODAS").
            END.

        END.
      
        WHEN "ARQUIVOS NOTURNOS" THEN DO: 

            ASSIGN aux_cdagenci = 0. /* TODOS */ 

            /* Grava Data e Hora da execucao */ 
            RUN grava_dthr_proc(INPUT par_cdcooper,
                                INPUT par_dtmvtolt,
                                INPUT TIME,
                                INPUT "ARQUIVOS NOTURNOS"). 
            
            RUN gera_log_execucao (INPUT par_nmprgexe + "(COMPEL)",
                                  INPUT "Inicio execucao", 
                                  INPUT par_cdcooper,
                                  INPUT "").
            /****** COMPEL *****/
            RUN arquivos_noturnos(INPUT par_cdcooper, 
                                  INPUT aux_cdagenci,
                                  INPUT "COMPEL",
                                  INPUT par_dtmvtolt).
            RUN gera_log_execucao (INPUT par_nmprgexe + "(COMPEL)",
                                  INPUT "Fim execucao", 
                                  INPUT par_cdcooper,
                                  INPUT "").
            
            RUN gera_log_execucao (INPUT par_nmprgexe + "(DOCTOS)",
                                  INPUT "Inicio execucao", 
                                  INPUT par_cdcooper,
                                  INPUT "").

            /***** DOCTOS *****/
            RUN arquivos_noturnos(INPUT par_cdcooper,
                                  INPUT aux_cdagenci,
                                  INPUT "DOCTOS",
                                  INPUT par_dtmvtolt).
            RUN gera_log_execucao (INPUT par_nmprgexe + "(DOCTOS)",
                                  INPUT "Fim execucao", 
                                  INPUT par_cdcooper,
                                  INPUT "").

            RUN gera_log_execucao (INPUT par_nmprgexe + "(TITULO)",
                                  INPUT "Inicio execucao", 
                                  INPUT par_cdcooper,
                                  INPUT "").
            /***** TITULO *****/
            RUN arquivos_noturnos(INPUT par_cdcooper,
                                  INPUT aux_cdagenci,
                                  INPUT "TITULO",
                                  INPUT par_dtmvtolt).
            RUN gera_log_execucao (INPUT par_nmprgexe + "(TITULO)",
                                  INPUT "Fim execucao", 
                                  INPUT par_cdcooper,
                                  INPUT "").

            RUN gera_log_execucao (INPUT par_nmprgexe + "(CUSTODIA)",
                                  INPUT "Inicio execucao", 
                                  INPUT par_cdcooper,
                                  INPUT "TODAS").
            
            /***** CUSTODIA *****/
            RUN fontes/crps588.p. 
            
            RUN gera_log_execucao (INPUT par_nmprgexe + "(CUSTODIA)",
                                  INPUT "Fim execucao", 
                                  INPUT par_cdcooper,
                                  INPUT "TODAS").
        END.
      
        WHEN "ICFJUD" THEN DO:

            RUN atualiza_status_execucao (INPUT par_nmprgexe,
                                          INPUT par_dtmvtolt,
                                          INPUT par_cdcooper).

            IF   RETURN-VALUE = "NOK" THEN  DO:
            
                /* Grava Data e Hora da execucao */ 
                RUN grava_dthr_proc(INPUT par_cdcooper,
                                    INPUT par_dtmvtolt,
                                    INPUT TIME,
                                    INPUT TRIM(par_nmprgexe)). 
                
                /* Instancia a BO */
                RUN sistema/generico/procedures/b1wgen0154.p 
                    PERSISTENT SET h-b1wgen0154.
    
                IF   NOT VALID-HANDLE(h-b1wgen0154)  THEN
                     DO:
                       ASSIGN glb_nmdatela = "PRCCTL"
                          glb_dscritic = "Nao foi possivel instanciar b1wgen0154.".
                       RUN gera_critica_procmessage.
                       RETURN "NOK".
                     END.
    
                RUN gera_log_execucao (INPUT par_nmprgexe,
                                      INPUT "Inicio execucao", 
                                      INPUT par_cdcooper,
                                      INPUT "TODAS").
    
                RUN gerar_icf604 IN h-b1wgen0154(INPUT  glb_cdcooper,
                                                 INPUT  par_dtmvtolt,
                                                 OUTPUT aux_dsmsgerr).
    
                RUN gera_log_execucao (INPUT par_nmprgexe,
                                      INPUT "Fim execucao", 
                                      INPUT par_cdcooper,
                                      INPUT "TODAS").
    
                DELETE PROCEDURE h-b1wgen0154.
    
                IF  aux_dsmsgerr <> "" THEN DO:
                    glb_dscritic = aux_dsmsgerr.
                    RUN gera_critica_procmessage.
                END.
            END.
        END.
        
        WHEN "TIC604" THEN DO:

            ASSIGN aux_cdagenci = 0. /* TODOS */

            /* Grava Data e Hora da execucao */ 
            RUN grava_dthr_proc(INPUT par_cdcooper,
                                INPUT par_dtmvtolt,
                                INPUT TIME,
                                INPUT TRIM(par_nmprgexe)). 

            /*Na base esta gravado de uma forma e a procedure
              da BO esta validando de outra*/
            ASSIGN par_nmprgexe = "TIC".

            RUN gera_log_execucao (INPUT par_nmprgexe,
                                  INPUT "Inicio execucao", 
                                  INPUT par_cdcooper,
                                  INPUT "").

            RUN arquivos_noturnos(INPUT par_cdcooper,
                                  INPUT aux_cdagenci,
                                  INPUT par_nmprgexe,
                                  INPUT par_dtmvtolt).

            RUN gera_log_execucao (INPUT par_nmprgexe,
                                  INPUT "Fim execucao", 
                                  INPUT par_cdcooper,
                                  INPUT "").

        END.

        WHEN "DEVOLU" THEN DO:
                  
          /*pegar numero da seq*/
          CASE aux_tpdevolu:
              WHEN "VLB" THEN
                  aux_nrseqsol = 4.
              WHEN "DIURNA" THEN
                  aux_nrseqsol = 5.
              OTHERWISE
                  aux_nrseqsol = 6.
          END CASE.

          /* Cria solicitação na CECRED */ 
          RUN cria_solicitacao(INPUT glb_cdcooper,
                               INPUT par_dtmvtolt,
                               INPUT par_nmprgexe,
                               INPUT 78,
                               INPUT aux_nrseqsol).

         
          IF  TRIM(aux_tpdevolu) = "VLB" THEN 
              DO:
                   /* Grava Data e Hora da execucao */ 
                   RUN grava_dthr_proc(INPUT par_cdcooper,
                                       INPUT par_dtmvtolt,
                                       INPUT TIME,
                                       INPUT "DEVOLUCAO VLB"). 
        
                   RUN gera_log_execucao (INPUT par_nmprgexe + "(VLB)",
                                          INPUT "Inicio execucao", 
                                          INPUT par_cdcooper,
                                          INPUT "").
                   
                    /* Cria solicitação na Coop. filiada. Esta solicitacao 
                       nao deve ser eliminada durante o dia, pois garante 
                       que nao serao marcados novos cheques na DEVOLU depois
                       que o arquivo ja tiver sido processado  */ 
                   RUN cria_solicitacao(INPUT par_cdcooper,
                                        INPUT par_dtmvtolt,
                                        INPUT par_nmprgexe,
                                        INPUT 78,
                                        INPUT aux_nrseqsol).

                   RUN fontes/crps264.p 
                           (INPUT INT(par_cdcooper),
                            INPUT aux_nrseqsol).

                   RUN gera_log_execucao (INPUT par_nmprgexe + "(VLB)",
                                          INPUT "Fim execucao", 
                                          INPUT par_cdcooper,
                                          INPUT "").

              END.
          ELSE
          IF  TRIM(aux_tpdevolu) = "DIURNA" THEN
              DO:

                  /* Grava Data e Hora da execucao */ 
                  RUN grava_dthr_proc(INPUT par_cdcooper,
                                      INPUT par_dtmvtolt,
                                      INPUT TIME,
                                      INPUT "DEVOLUCAO DIURNA"). 

                  RUN gera_log_execucao (INPUT par_nmprgexe + "(DIURNA)",
                                          INPUT "Inicio execucao", 
                                          INPUT par_cdcooper,
                                          INPUT "").
                  
                  /* Cria solicitação na Coop. filiada. Esta solicitacao 
                     nao deve ser eliminada durante o dia, pois garante 
                     que nao serao marcados novos cheques na DEVOLU depois
                     que o arquivo ja tiver sido processado  */ 
                  RUN cria_solicitacao(INPUT par_cdcooper,
                                       INPUT par_dtmvtolt,
                                       INPUT par_nmprgexe,
                                       INPUT 78,
                                       INPUT aux_nrseqsol).

                  RUN fontes/crps264.p
                               (INPUT INT(par_cdcooper),
                                INPUT aux_nrseqsol).
                  RUN gera_log_execucao (INPUT par_nmprgexe + "(DIURNA)",
                                          INPUT "Fim execucao", 
                                          INPUT par_cdcooper,
                                          INPUT "").

              END.
          ELSE
          IF  TRIM(aux_tpdevolu) = "DOC" THEN
          DO:

              /* Grava Data e Hora da execucao */ 
              RUN grava_dthr_proc(INPUT par_cdcooper,
                                  INPUT par_dtmvtolt,
                                  INPUT TIME,
                                  INPUT "DEVOLUCAO DOC"). 

              RUN gera_log_execucao (INPUT par_nmprgexe + "(DOC)",
                                     INPUT "Inicio execucao", 
                                     INPUT par_cdcooper,
                                     INPUT "").
              
              { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }
              
              RUN STORED-PROCEDURE pc_crps680 aux_handproc = PROC-HANDLE
                    (INPUT crapcop.cdcooper,                                                  
                     INPUT glb_nmtelant,
                     INPUT INT(STRING(glb_flgresta,"1/0")),
                     OUTPUT 0,
                     OUTPUT 0,
                     OUTPUT 0, 
                     OUTPUT "").

              IF  ERROR-STATUS:ERROR  THEN 
              DO:
                  DO  aux_qterrora = 1 TO ERROR-STATUS:NUM-MESSAGES:
                      ASSIGN aux_msgerora = aux_msgerora + 
                             ERROR-STATUS:GET-MESSAGE(aux_qterrora) + " ".
                  END.

                  UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                    " - " + glb_cdprogra + "' --> '"  +
                                    "Erro ao executar Stored Procedure: '" +
                                    aux_msgerora + "' >> log/proc_batch.log").
              END.

              CLOSE STORED-PROCEDURE pc_crps680 WHERE PROC-HANDLE = aux_handproc.

              { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

              RUN gera_log_execucao (INPUT par_nmprgexe + "(DOC)",
                                     INPUT "Fim execucao", 
                                     INPUT par_cdcooper,
                                     INPUT "").
                  
           END.
           ELSE 
                DO:

                    /* Grava Data e Hora da execucao */ 
                    RUN grava_dthr_proc(INPUT par_cdcooper,
                                        INPUT par_dtmvtolt,
                                        INPUT TIME,
                                        INPUT "DEVOLUCAO NOTURNA"). 

                    RUN gera_log_execucao (INPUT par_nmprgexe + "(NOTURNA)",
                                           INPUT "Inicio execucao", 
                                           INPUT par_cdcooper,
                                           INPUT "").
                    
                    /* Cria solicitação na Coop. filiada. Esta solicitacao 
                     nao deve ser eliminada durante o dia, pois garante 
                     que nao serao marcados novos cheques na DEVOLU depois
                     que o arquivo ja tiver sido processado  */ 
                    RUN cria_solicitacao(INPUT par_cdcooper,
                                         INPUT par_dtmvtolt,
                                         INPUT par_nmprgexe,
                                         INPUT 78,
                                         INPUT aux_nrseqsol).




                    RUN fontes/crps264.p
                                (INPUT INT(par_cdcooper),
                                 INPUT aux_nrseqsol).
                    RUN gera_log_execucao (INPUT par_nmprgexe + "(NOTURNA)",
                                           INPUT "Fim execucao", 
                                           INPUT par_cdcooper,
                                           INPUT "").
                END.
      
          
           /* Exclui solicitacao na CECRED */ 
           RUN limpa_solicitacao(INPUT glb_cdcooper,
                                 INPUT glb_dtmvtolt,
                                 INPUT tt-craphec.dsprogra,
                                 INPUT 78,
                                 INPUT aux_nrseqsol).

        END.
        
        WHEN "REMCOB" THEN DO:

            /* Grava Data e Hora da execucao */ 
            RUN grava_dthr_proc(INPUT par_cdcooper,
                                INPUT par_dtmvtolt,
                                INPUT TIME,
                                INPUT TRIM(par_nmprgexe)). 

            RUN gera_log_execucao (INPUT par_nmprgexe,
                                   INPUT "Inicio execucao", 
                                   INPUT par_cdcooper,
                                   INPUT "").
            
            ASSIGN aux_nrdbanco = 001.

            RUN gera_remessa(INPUT aux_nrdbanco,
                             INPUT par_dtmvtolt,
                             INPUT par_cdcooper).

            ASSIGN glb_cdrelato = 596.

            RUN gera_relatorio_remcob(INPUT aux_nrdbanco,
                                      INPUT par_dtmvtolt,
                                      INPUT par_cdcooper).

            RUN gera_log_execucao (INPUT par_nmprgexe,
                                   INPUT "Fim execucao", 
                                   INPUT par_cdcooper,
                                   INPUT "").

            RUN gera_log_execucao (INPUT par_nmprgexe + "(ArquivosBB.envia.pl)",
                                   INPUT "Inicio execucao", 
                                   INPUT par_cdcooper,
                                   INPUT "").
            
            IF  OS-GETENV("PKGNAME") = "pkgprod" OR 
                OS-GETENV("PKGNAME") = "PKGPROD" THEN
                UNIX SILENT VALUE("/usr/local/cecred/" +
                                  "bin/ArquivosBB.envia.pl").

            RUN gera_log_execucao (INPUT par_nmprgexe + "(ArquivosBB.envia.pl)",
                                   INPUT "Fim execucao", 
                                   INPUT par_cdcooper,
                                   INPUT "").
        END.

        WHEN "TAA E INTERNET" THEN DO:

            /* Grava Data e Hora da execucao */ 
            RUN grava_dthr_proc(INPUT par_cdcooper,
                                INPUT par_dtmvtolt,
                                INPUT TIME,
                                INPUT TRIM(par_nmprgexe)). 
            
            RUN gera_log_execucao (INPUT par_nmprgexe + "(INTERNET)",
                                   INPUT "Inicio execucao", 
                                   INPUT par_cdcooper,
                                   INPUT "").

            /*Tem que Rodar com PA 90 e PA 91*/
            ASSIGN aux_cdagenci = 90.

            /*Quando for necessario processar PA 90 é feito uma verificacao 
              se os titulos e faturas pagos tiveram os seus devidos debitos 
              efetuados nas contas para a cooperativa. */
            glb_cdcritic = 0.

            /* TITULO */
            RUN arquivos_noturnos(INPUT par_cdcooper,
                                  INPUT aux_cdagenci,
                                  INPUT "TITULO",
                                  INPUT par_dtmvtolt).

            RUN gera_log_execucao (INPUT par_nmprgexe + "(INTERNET)",
                                   INPUT "Fim execucao", 
                                   INPUT par_cdcooper,
                                   INPUT "").


            RUN gera_log_execucao (INPUT par_nmprgexe + "(TAA)",
                                   INPUT "Inicio execucao", 
                                   INPUT par_cdcooper,
                                   INPUT "").

            /*Tem que Rodar com PA 90 e PA 91*/
            ASSIGN aux_cdagenci = 91.

            /*Quando for necessario processar PA 90 é feito uma verificacao 
              se os titulos e faturas pagos tiveram os seus devidos debitos 
              efetuados nas contas para a cooperativa. */
            glb_cdcritic = 0.

            /* TITULO */
            RUN arquivos_noturnos(INPUT par_cdcooper,
                                  INPUT aux_cdagenci,
                                  INPUT "TITULO",
                                  INPUT par_dtmvtolt).

            RUN gera_log_execucao (INPUT par_nmprgexe + "(TAA)",
                                   INPUT "Fim execucao", 
                                   INPUT par_cdcooper,
                                   INPUT "").
        END.                  
        
        WHEN "DEBCNS VESPERTINA" THEN DO:

            /* Grava Data e Hora da execucao */ 
            RUN grava_dthr_proc(INPUT par_cdcooper,
                                INPUT par_dtmvtolt,
                                INPUT TIME,
                                INPUT TRIM(par_nmprgexe)). 

            RUN gera_log_execucao (INPUT par_nmprgexe,
                                   INPUT "Inicio execucao", 
                                   INPUT par_cdcooper,
                                   INPUT "").
                                   
            RUN gera_arq_debcns(INPUT par_cdcooper,
                                INPUT 1). /*Primeira execucao*/
                                
            RUN gera_log_execucao (INPUT par_nmprgexe,
                                   INPUT "Fim execucao", 
                                   INPUT par_cdcooper,
                                   INPUT "").

        END.
        
        WHEN "DEBCNS NOTURNA" THEN DO:

            /* Grava Data e Hora da execucao */ 
            RUN grava_dthr_proc(INPUT par_cdcooper,
                                INPUT par_dtmvtolt,
                                INPUT TIME,
                                INPUT TRIM(par_nmprgexe)). 

            RUN gera_log_execucao (INPUT par_nmprgexe,
                                   INPUT "Inicio execucao", 
                                   INPUT par_cdcooper,
                                   INPUT "").
                                   
            RUN gera_arq_debcns(INPUT par_cdcooper,
                                INPUT 2). /*Segunda execucao*/
            
            RUN gera_log_execucao (INPUT par_nmprgexe,
                                   INPUT "Fim execucao", 
                                   INPUT par_cdcooper,
                                   INPUT "").

        END.

        WHEN "AGENDAMENTO APLICACAO/RESGATE" THEN 
          DO:
             /* Grava Data e Hora da execucao */ 
             RUN grava_dthr_proc(INPUT par_cdcooper,
                                 INPUT par_dtmvtolt,
                                 INPUT TIME,
                                 INPUT TRIM(par_nmprgexe)). 
            
             RUN gera_log_execucao (INPUT par_nmprgexe,
                                    INPUT "Inicio execucao", 
                                    INPUT par_cdcooper,
                                    INPUT "").

             RUN proc_agenda_resg_aplica(INPUT par_cdcooper).

             RUN gera_log_execucao (INPUT par_nmprgexe,
                                    INPUT "Fim execucao", 
                                    INPUT par_cdcooper,
                                    INPUT "").
          END.

        WHEN "ARQUIVOS SICREDI" THEN 
          DO:          
            RUN atualiza_status_execucao (INPUT par_nmprgexe,
                                          INPUT par_dtmvtolt,
                                          INPUT par_cdcooper).

            IF   RETURN-VALUE = "NOK" THEN  DO:          
               /* Grava Data e Hora da execucao */ 
               RUN grava_dthr_proc(INPUT par_cdcooper,
                                   INPUT par_dtmvtolt,
                                   INPUT TIME,
                                   INPUT TRIM(par_nmprgexe)). 

               RUN gera_log_execucao (INPUT par_nmprgexe,
                                      INPUT "Inicio execucao", 
                                      INPUT 3,
                                      INPUT "TODAS").

               /* Cria solicitação na CECRED */ 
               RUN cria_solicitacao(INPUT glb_cdcooper,
                                    INPUT par_dtmvtolt,
                                    INPUT par_nmprgexe,
                                    INPUT 89,
                                    INPUT 1).
            
               RUN fontes/crps636.p.                         
               
               /* Exclui solicitacao na CECRED */ 
               RUN limpa_solicitacao(INPUT glb_cdcooper,
                                     INPUT par_dtmvtolt,
                                     INPUT par_nmprgexe,
                                     INPUT 89,
                                     INPUT 1).
               
               RUN gera_log_execucao (INPUT par_nmprgexe,
                                      INPUT "Fim execucao", 
                                      INPUT 3,
                                      INPUT "TODAS").               
             END.
          END.

    END CASE.

    RETURN "OK".
END PROCEDURE.

PROCEDURE cria_solicitacao:

    DEF INPUT PARAM par_cdcooper    AS  INTE                        NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt    AS  DATE                        NO-UNDO.
    DEF INPUT PARAM par_nmprgexe    AS  CHAR                        NO-UNDO.
    DEF INPUT PARAM par_nrsolici    LIKE crapsol.nrsolici           NO-UNDO.
    DEF INPUT PARAM par_nrseqsol    LIKE crapsol.nrseqsol           NO-UNDO.

    /* Criar solicitacao para estes tipos de programas 
       "RELACIONAMENTO,CCF,CONTRA-ORDEM,CUSTODIA" */
    IF  CAN-DO("RELACIONAMENTO,CONTRA-ORDEM E CCF,ARQUIVOS NOTURNOS,DEVOLU,IMP CONTRA-ORDEM/CCF,CAF,ARQUIVOS SICREDI",par_nmprgexe)  THEN
        DO:
        
            DO TRANSACTION:
                /* Limpa solicitacao se existente */
                FIND FIRST crapsol WHERE 
                           crapsol.cdcooper = par_cdcooper   AND 
                           crapsol.nrsolici = par_nrsolici   AND
                           crapsol.dtrefere = par_dtmvtolt   AND
                           crapsol.nrseqsol = par_nrseqsol
                           NO-LOCK NO-ERROR.
    
                IF  AVAILABLE crapsol  THEN
                     DO:
                         FIND CURRENT crapsol EXCLUSIVE-LOCK.
                         DELETE crapsol.
                     END.
    
                CREATE crapsol. 
                ASSIGN crapsol.nrsolici = par_nrsolici
                       crapsol.dtrefere = par_dtmvtolt
                       crapsol.nrseqsol = par_nrseqsol
                       crapsol.cdempres = 11
                       crapsol.dsparame = ""
                       crapsol.insitsol = 1
                       crapsol.nrdevias = 0
                       crapsol.cdcooper = par_cdcooper.
                VALIDATE crapsol.
            END.

        END.

    RETURN "OK".
END PROCEDURE.
          
PROCEDURE limpa_solicitacao:

    DEF INPUT PARAM par_cdcooper    AS  INTE                        NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt    AS  DATE                        NO-UNDO. 
    DEF INPUT PARAM par_nmprgexe    AS  CHAR                        NO-UNDO.
    DEF INPUT PARAM par_nrsolici    LIKE crapsol.nrsolici           NO-UNDO.
    DEF INPUT PARAM par_nrseqsol    LIKE crapsol.nrseqsol           NO-UNDO.
    

    /* Limpar solicitacao feita anteriormente */
    IF  CAN-DO("RELACIONAMENTO,CONTRA-ORDEM E CCF,ARQUIVOS NOTURNOS,DEVOLU,ARQUIVOS SICREDI",par_nmprgexe)  THEN
        DO: 
            DO TRANSACTION:
                /* Limpa solicitacao se existente */
                FIND FIRST crapsol WHERE 
                           crapsol.cdcooper = par_cdcooper   AND 
                           crapsol.nrsolici = par_nrsolici   AND
                           crapsol.dtrefere = par_dtmvtolt   AND
                           crapsol.nrseqsol = par_nrseqsol
                           NO-LOCK NO-ERROR.
    
                IF  AVAILABLE crapsol  THEN
                     DO:
                         FIND CURRENT crapsol EXCLUSIVE-LOCK.
                         DELETE crapsol.
                     END.
            END. /* Fim TRANSACTION */
        END.

    RETURN "OK".
END PROCEDURE.


PROCEDURE arquivos_noturnos:

    DEF INPUT PARAM par_cdcooper    AS  INTE                        NO-UNDO.
    DEF INPUT PARAM par_cdagenci    AS  INTE                        NO-UNDO.
    DEF INPUT PARAM par_nmprgexe    AS  CHAR                        NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt    AS  DATE                        NO-UNDO.

    DEF VAR aux_dsmsgerr            AS  CHAR                        NO-UNDO.
    DEF VAR tot_qtarquiv            AS  INTE                        NO-UNDO.
    DEF VAR tot_totregis            AS  INTE                        NO-UNDO.
    DEF VAR tot_vlrtotal            AS  INTE                        NO-UNDO.

    /* Instancia a BO */
    RUN sistema/generico/procedures/b1wgen0012.p 
            PERSISTENT SET h-b1wgen0012.
    
    IF   NOT VALID-HANDLE(h-b1wgen0012)  THEN
         DO:
             ASSIGN glb_nmdatela = "PRCCTL"
                    glb_dscritic = "Handle invalido para BO b1wgen0012.".
             RUN gera_critica_procmessage.
             RETURN "NOK".
         END.
          
    ASSIGN tot_qtarquiv = 0 
           tot_totregis = 0 
           tot_vlrtotal = 0.

    IF   par_cdagenci = 0 THEN
         ASSIGN aux_pacfinal = 9999.
    ELSE
         ASSIGN aux_pacfinal = par_cdagenci.
 
    RUN gerar_arquivos_cecred
        IN h-b1wgen0012(INPUT  par_nmprgexe,
                        INPUT  par_dtmvtolt,
                        INPUT  INT(par_cdcooper),
                        INPUT  par_cdagenci, /* cdagenci */
                        INPUT  aux_pacfinal, 
                        INPUT  glb_cdoperad,
                        INPUT  "PRCCTL",
                        INPUT  0,   /* nrdolote */
                        INPUT  0,   /* nrdcaixa */
                        INPUT  "",  /* cdbccxlt */
                        OUTPUT glb_cdcritic,
                        OUTPUT aux_qtarquiv,
                        OUTPUT aux_totregis,
                        OUTPUT aux_vlrtotal).

    ASSIGN tot_qtarquiv = tot_qtarquiv + aux_qtarquiv
           tot_totregis = tot_totregis + aux_totregis
           tot_vlrtotal = tot_vlrtotal + aux_vlrtotal.
 
 
    IF   INT(par_cdcooper) = 16       AND
         par_nmprgexe      = "COMPEL" THEN
         DO:
            RUN gerar_compel_altoVale IN h-b1wgen0012(
                            INPUT  par_dtmvtolt,
                            INPUT  INT(par_cdcooper),
                            INPUT  glb_cdoperad,
                            OUTPUT glb_cdcritic,
                            OUTPUT aux_qtarquiv,
                            OUTPUT aux_totregis,
                            OUTPUT aux_vlrtotal).

            ASSIGN tot_qtarquiv = tot_qtarquiv + 
                                  aux_qtarquiv
                   tot_totregis = tot_totregis + 
                                  aux_totregis
                   tot_vlrtotal = tot_vlrtotal + 
                                  aux_vlrtotal.
         END.

     DELETE PROCEDURE h-b1wgen0012.    

     RUN gera_relatorios(par_cdcooper,
                         par_cdagenci,
                         par_dtmvtolt,
                         par_nmprgexe).
  
     IF   glb_cdcritic > 0   THEN
          DO:
              RUN fontes/critic.p.
              RUN gera_critica_procmessage.
              ASSIGN glb_cdcritic = 0.
              RETURN "NOK".
          END.

    RETURN "OK".
END PROCEDURE.

PROCEDURE gera_remessa.

    DEF INPUT PARAM par_nrdbanco AS INT  NO-UNDO.
    DEF INPUT PARAM par_dtremess AS DATE NO-UNDO.
    DEF INPUT PARAM par_cdcooper LIKE crapcop.cdcooper NO-UNDO.

    DEF VAR aux_dsdircop AS CHAR FORMAT "x(15)"  NO-UNDO.
    DEF VAR aux_linhaarq AS CHAR FORMAT "x(240)" NO-UNDO.
    DEF VAR aux_cddbanco AS CHAR FORMAT "x(3)"   NO-UNDO.
    DEF VAR aux_nrsequen AS INT                  NO-UNDO.
    DEF VAR aux_qtdlinha AS INT                  NO-UNDO.
    DEF VAR aux_nmarquiv AS CHAR FORMAT "x(40)"  NO-UNDO.

    /* variaveis teste CECRED */
    DEF VAR aux_nrdocnpj LIKE crapcop.nrdocnpj   NO-UNDO.
    DEF VAR aux_cdagedbb LIKE crapcop.cdagedbb   NO-UNDO.
    DEF VAR aux_nrctabbd LIKE crapcop.nrctabbd   NO-UNDO.
    DEF VAR aux_nmextcop AS CHAR                 NO-UNDO.
    DEF VAR aux_chave    AS CHAR                 NO-UNDO.

    DEF VAR h-b1wgen0088 AS HANDLE NO-UNDO.

    DO TRANSACTION:

        /* testes CECRED
        FIND FIRST crapcop NO-LOCK WHERE cdcooper = 3.
        
        ASSIGN aux_nrdocnpj = crapcop.nrdocnpj
               aux_nmrescop = LOWER(crapcop.nmrescop)
               aux_cdagedbb = crapcop.cdagedbb
               aux_nrctabbd = crapcop.nrctabbd
               aux_nmextcop = crapcop.nmextcop.
        */
        
        FOR EACH crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK:

            ASSIGN aux_nrdocnpj = crapcop.nrdocnpj
                   aux_dsdircop = LOWER(crapcop.dsdircop)
                   aux_cdagedbb = 34207 /*crapcop.cdagedbb*/
                   aux_nrctabbd = crapcop.nrctabbd
                   aux_nmextcop = crapcop.nmextcop
                   aux_nrsequen = 1
                   aux_qtdlinha = 1.
        
            
            /* Lote de remessa – CRAPCRE */
            FOR EACH crapcre WHERE crapcre.cdcooper = crapcop.cdcooper
                               AND crapcre.dtmvtolt = par_dtremess
                               AND crapcre.intipmvt =  1 /* remessa */
                               AND crapcre.cdcooper <> 3
                               AND crapcre.flgproce = FALSE EXCLUSIVE-LOCK,
        
                /* Parametros da cobranca - busca o convenio */
                EACH crapcco WHERE crapcco.cdcooper = crapcre.cdcooper
                               AND crapcco.nrconven = crapcre.nrcnvcob
                               AND crapcco.flgregis = TRUE
                               AND crapcco.flgativo = TRUE
                               AND crapcco.cddbanco = par_nrdbanco NO-LOCK:

                    INPUT STREAM str_3 THROUGH VALUE( "grep " + aux_dsdircop + 
                            " /usr/local/cecred/etc/TabelaDeCooperativas " + 
                            "| cut -d: -f 10" + " 2> /dev/null") NO-ECHO.
    
                    SET STREAM str_3 aux_chave FORMAT "x(20)".
        
                    ASSIGN aux_nmarquiv = "ied240." + trim(aux_chave) + "." + 
                          string(day(TODAY), "99") +
                          string(month(TODAY),"99") +
                          substr(string(year(TODAY), "9999"),3,2) +
                          substr(string(time,"HH:MM:SS"),1,2) +
                          substr(string(time,"HH:MM:SS"),4,2) +
                          substr(string(time,"HH:MM:SS"),7,2) +
                          substr(string(now),21,03) + /* milesimos de segundo */
                          ".bco001." + 
                          "c" + string(aux_nrdocnpj,"99999999999999")
                           crapcre.nmarquiv = aux_nmarquiv.
            
                    OUTPUT STREAM str_2 TO VALUE 
                            ("/usr/coop/" + aux_dsdircop + "/arq/" + aux_nmarquiv).
        
                    /* Gravacao do header do arquivo - layout FEBRABAN pag. 17 */
                    ASSIGN aux_linhaarq = /* Codigo do banco */  
                                          "001"                       + 
                                          /* Lote de servico */
                                          "0000"                      + 
                                          /* Tipo de registro */
                                          "0"                         + 
                                          /* Uso exclusivo */
                                          retorna_complemento("", FALSE, 9) + 
                                          /* Tipo insc empresa (2 = CNPJ) */ 
                                          "2"                         + 
                                          /* Nro insc empresa */
        /*REPLACE(STRING(crapcop.nrdocnpj), ".", "")                    + */
                                          REPLACE(STRING(aux_nrdocnpj, 
                                                      "99999999999999"), ".", "") + 
                                          /* Cod. convenio banco */
                                          /* "001417019" = fixo exigido pelo banco */
        retorna_complemento(REPLACE(STRING(crapcco.nrconven, "999999999") +  
                                    "0014" + 
                                    STRING(crapcco.cdcartei, "99") + 
                                    STRING(crapcco.nrvarcar, "999"), ".", ""), FALSE, 20) + 
                                          /* Ag da conta */
        retorna_complemento
        /*(retorna_sem_dv(REPLACE(STRING(crapcop.cdagedbb), ".", "")), TRUE, 5)    + */
        (retorna_sem_dv(REPLACE(STRING(aux_cdagedbb), ".", "")), TRUE, 5)    + 
                                          /* DV da agencia */
        retorna_complemento
        /*(retorna_apenas_dv(REPLACE(STRING(crapcop.cdagedbb), ".", "")), FALSE, 1) + */
        (retorna_apenas_dv(REPLACE(STRING(aux_cdagedbb), ".", "")), FALSE, 1) + 
                                          /* Nro da C/C */
        retorna_complemento
        (retorna_sem_dv(REPLACE(STRING(crapcco.nrdctabb), ".", "")), TRUE, 12)    + 
                                          /* DV da C/C */
        retorna_complemento
        (retorna_apenas_dv(REPLACE(STRING(crapcco.nrdctabb), ".", "")), FALSE, 1) + 
                                          /* DV Ag/Conta */
                                          retorna_complemento("", FALSE, 1)       + 
                                          /* Nome da Empresa */
            /*SUBSTR(crapcop.nmextcop, 1, 30)                               + */
        SUBSTR(aux_nmextcop, 1, 30)                               + 
                                          /* Nome do banco */
        retorna_complemento("BANCO DO BRASIL", FALSE, 30)             + 
                                          /* Uso Exclusivo */
        retorna_complemento("", FALSE, 10)                            + 
                                          /* Codigo Remessa (1 = remessa) */
                                          "1"                         + 
                                          /* Data Geração Arq */
        /*STRING(par_dtremess, "99999999")                              + */
        STRING(TODAY, "99999999")                              + 
                                          /* Hora da Geração Arq */
        REPLACE(STRING(TIME, "HH:MM:SS"), ":", "")                    + 
                                          /* Nro Remessa */
        STRING(crapcre.nrremret, "999999")                            +
                                          /* Layout do Arq */
                                                  "084"                       + 
                                          /* Densidade Grav Arq */
                                              "00000"                     + 
                                          /* Reservado Banco */
        retorna_complemento("", FALSE, 20)                            + 
                                          /* Reservado Empresa */
            retorna_complemento("", FALSE, 20)                            + 
                                          /* Uso exclusivo */
        retorna_complemento("", FALSE, 29).

                                                  
                PUT STREAM str_2 aux_linhaarq SKIP.

                ASSIGN aux_linhaarq = ""
                       aux_qtdlinha = aux_qtdlinha + 1


                /* Gravacao do header do lote - layout FEBRABAN pag. 52 */

                       aux_linhaarq = /* Cód Banco Compe */
                                      "001"                                +
                                      /* Lote de Serviço */
                                      "0001"                               +
                                     /* Tipo de Registro */
                                      "1"                                  +
                                     /* Tipo de Operação */
                                      "R" /* remessa */                    +
                                     /* Tipo de Serviço */
                                      "01"                                 +
                                     /* Uso Exclusivo */
                                retorna_complemento("", FALSE, 2)          +
                                     /* Layout Lote */
                                      "043"                                +
                                     /* Uso Exclusivo */
                                retorna_complemento("", FALSE, 1)          +
                                     /* Tipo Insc. Empresa */
                                      "2" /* CNPJ */                       +
                                     /* Nro Insc Empresa */
/*retorna_complemento(REPLACE(STRING(crapcop.nrdocnpj), ".", ""), TRUE, 15)  +*/
retorna_complemento(REPLACE(STRING(aux_nrdocnpj), ".", ""), TRUE, 15)  +
                                     /* Cód. Convenio Bco */
         retorna_complemento(REPLACE(STRING(crapcco.nrconven, "999999999") + 
                     "0014" + 
                     STRING(crapcco.cdcartei, "99") + 
                     STRING(crapcco.nrvarcar, "999") + 
                     "  ", ".", ""), FALSE, 20)
                     /*"TS", ".", ""), FALSE, 20)*/ + /* TS para testes */
                                     /* Ag da conta */
retorna_complemento
     /*(retorna_sem_dv(REPLACE(STRING(crapcop.cdagedbb), ".", "")), TRUE, 5) +*/
    (retorna_sem_dv(REPLACE(STRING(aux_cdagedbb), ".", "")), TRUE, 5) +
                                     /* DV da agencia */
retorna_complemento
 /*(retorna_apenas_dv(REPLACE(STRING(crapcop.cdagedbb), ".", "")), FALSE, 1) +*/
(retorna_apenas_dv(REPLACE(STRING(aux_cdagedbb), ".", "")), FALSE, 1) +
                                     /* Nro da C/C */
retorna_complemento
    (retorna_sem_dv(REPLACE(STRING(crapcco.nrdctabb), ".", "")), TRUE, 12) + 
                                     /* DV da C/C */
retorna_complemento
 (retorna_apenas_dv(REPLACE(STRING(crapcco.nrdctabb), ".", "")), FALSE, 1) + 
                                     /* DV Ag/Conta */
                                      retorna_complemento("", FALSE, 1)    + 
                                     /* Nome da Empresa */
                                    /*SUBSTR(crapcop.nmextcop, 1, 30)            +*/
                                SUBSTR(aux_nmextcop, 1, 30)            +
                                     /* Mensagem 1 */
                                retorna_complemento("", FALSE, 40)         +
                                     /*  Mensagem 2 */
                                retorna_complemento("", FALSE, 40)         +
                                     /* Nro Remessa */
                                STRING(crapcre.nrremret, "99999999")       +
                                     /* Data gravacao */
                                /*STRING(par_dtremess, "99999999")           +*/
                                STRING(TODAY, "99999999")           +    
                                    /* Dt do Crédito */
                                retorna_complemento("", TRUE, 8)           +
                                   /* Uso Exclusivo */
                                retorna_complemento("", FALSE, 33).


                PUT STREAM str_2 aux_linhaarq SKIP.

                ASSIGN aux_qtdlinha = aux_qtdlinha + 1.

                IF NOT VALID-HANDLE(h-b1wgen0088) THEN
                   RUN sistema/generico/procedures/b1wgen0088.p
                           PERSISTENT SET h-b1wgen0088.

                /* DF titulos do lote de remessa */
                FOR EACH craprem WHERE craprem.cdcooper = crapcco.cdcooper
                                   AND craprem.nrcnvcob = crapcco.nrconven
                                   AND craprem.nrremret = crapcre.nrremret
                                   AND craprem.nrdconta > 0
                                   AND craprem.nrseqreg > 0 NO-LOCK 
                                            BY craprem.cdocorre 
                                            BY craprem.nrseqreg:

                    FIND crapcob WHERE crapcob.cdcooper = craprem.cdcooper
                                   AND crapcob.nrdconta = craprem.nrdconta
                                   AND crapcob.cdbandoc = crapcco.cddbanco
                                   AND crapcob.nrdctabb = crapcco.nrdctabb
                                   AND crapcob.nrcnvcob = craprem.nrcnvcob
                                   AND crapcob.nrdocmto = craprem.nrdocmto
                                   AND crapcob.flgregis = TRUE 
                                                            NO-LOCK NO-ERROR.

                    IF AVAIL crapcob THEN
                    DO:

                        FIND crapass WHERE crapass.cdcooper = crapcob.cdcooper
                                       AND crapass.nrdconta = crapcob.nrdconta
                                       NO-LOCK NO-ERROR.

                        /* se titulo for pedido de remessa - logar */
                        IF craprem.cdocorre = 1 THEN
                        DO:
                            RUN cria-log-cobranca IN h-b1wgen0088
                                  (INPUT ROWID(crapcob),
                                   INPUT glb_cdoperad,
                                   INPUT par_dtremess,
                                   INPUT "Enviado ao BB - Remessa " + STRING(crapcre.nrremret)).
                        END.

                        ASSIGN aux_linhaarq = ""

                        /* Gravacao das informacoes do titulo - 
                                                       layout FEBRABAN p. 53 */
                        /* Segmento P */

                               aux_linhaarq = /* Banco */
                                             "001"                           +
                                              /* Lote de Serviço */
                                             "0001"                          +
                                              /* Tipo de Registro */
                                             "3"                             +
                                              /* Nro Seq Reg Lote */
                                             STRING(aux_nrsequen, "99999")   +
                                              /* Segmento */
                                             "P"                             +
                                              /* Uso Exclusivo */
                              retorna_complemento("", FALSE, 1)              +
                                              /* Cód Movimento Rem */
                                             STRING(craprem.cdocorre, "99")  +
                                              /* Ag da conta */
retorna_complemento
       /*(retorna_sem_dv(REPLACE(STRING(crapcop.cdagedbb), ".", "")), TRUE, 5) +*/
        (retorna_sem_dv(REPLACE(STRING(aux_cdagedbb), ".", "")), TRUE, 5) +
                                              /* DV da agencia */
retorna_complemento
   /*(retorna_apenas_dv(REPLACE(STRING(crapcop.cdagedbb), ".", "")), FALSE, 1) +*/
    (retorna_apenas_dv(REPLACE(STRING(aux_cdagedbb), ".", "")), FALSE, 1) +
                                              /* Nro da C/C */
retorna_complemento
 (retorna_sem_dv(REPLACE(STRING(crapcco.nrdctabb), ".", "")), TRUE, 12)      + 
                                              /* DV da C/C */
retorna_complemento
 (retorna_apenas_dv(REPLACE(STRING(crapcco.nrdctabb), ".", "")), FALSE, 1)   + 
                                              /* DV Ag/Conta */
                                           retorna_complemento("", FALSE, 1) +
                                              /* Nosso número */
                            retorna_complemento(crapcob.nrnosnum, FALSE, 20) +
                                              /* Cód. Carteira */
                                             /*STRING(crapcco.nrvarcar, "9")   +*/
                                             "7" + /* 7=Cob Simples - Cart 17 */
                                             /* Forma Cad Tit Banco */
                                             "1" /*com registro */           +
                                             /* Tipo de Documento */
                                             "2" /* escritural */            +
                                             /* Ident Emiss Bloqueto */                                      
                                             /*STRING(crapcob.inemiten, "9")   +*/
                                             "1" + /* banco emite e expede */
                                             /* Ident Distribuição */
                                             /*STRING(crapcob.inemiten, "9")   +*/
                                             "1" + /* banco distribui */
                                             /* Nro Documento */
                            retorna_complemento(crapcob.dsdoccop, FALSE, 15) +
                                             /* Vencimento */
                            STRING(crapcob.dtvencto, "99999999")             +
                                             /* Valor do Título */
retorna_complemento
    (REPLACE(REPLACE(STRING(crapcob.vltitulo,"999999999.99"), ".", ""), 
                                             ",", ""), TRUE, 15) +
                                             /* Ag. Cobradora */
                                             "00000"                         +
                                             /* DV Ag. Cobradora */
                                             "0".
                                             /* Especie Titulo */
                        IF crapcob.cddespec = 1 THEN
                            ASSIGN aux_linhaarq = aux_linhaarq + "02".
                        ELSE
                        IF crapcob.cddespec = 2 THEN
                            ASSIGN aux_linhaarq = aux_linhaarq + "04".
                        ELSE
                        IF crapcob.cddespec = 3 THEN
                            ASSIGN aux_linhaarq = aux_linhaarq + "12".
                        ELSE
                        IF crapcob.cddespec = 4 THEN
                            ASSIGN aux_linhaarq = aux_linhaarq + "21".
                        ELSE
                        IF crapcob.cddespec = 5 THEN
                            ASSIGN aux_linhaarq = aux_linhaarq + "23".
                        ELSE
                        IF crapcob.cddespec = 6 THEN
                            ASSIGN aux_linhaarq = aux_linhaarq + "17".
                        ELSE
                        IF crapcob.cddespec = 7 THEN
                            ASSIGN aux_linhaarq = aux_linhaarq + "99".

                        /* Ident Titulo Aceite */
                        /*IF crapcob.flgaceit = TRUE THEN
                            ASSIGN aux_linhaarq = aux_linhaarq + "A".
                        ELSE
                            ASSIGN aux_linhaarq = aux_linhaarq + "N".*/

                        /* Fixado Aceite como "N" */
                        ASSIGN aux_linhaarq = aux_linhaarq + "N".

                        ASSIGN aux_linhaarq = aux_linhaarq +
                                             /* Data Emissão Tit */
                            (IF  crapcob.dtmvtolt < crapcob.dtvencto THEN
                                STRING(crapcob.dtmvtolt, "99999999")
                            ELSE
                                STRING(crapcob.dtdocmto, "99999999"))      +
                                             /* Cód Juros Mora 
                             1 = Valor por dia, 2 = Valor mensal, 3 = Isento */
                            STRING(crapcob.tpjurmor, "9")                 +
                                             /* Data Juros Mora */
                            retorna_complemento("", TRUE, 8)              +
                                             /* Juros Mora */
retorna_complemento
    (REPLACE(REPLACE(STRING(crapcob.vljurdia, "999.99"), ".", ""), ",", ""), TRUE, 15) +
                                             /* Cód Desc. 1 */
                          (IF (crapcob.vldescto > 0) THEN  "1" ELSE "0")  +
                                             /* Data Desc. 1 */
      retorna_complemento((IF crapcob.vldescto > 0 THEN 
                              STRING(crapcob.dtvencto,"99999999") ELSE ""), TRUE, 8) +
                                             /* Desconto 1 */
retorna_complemento
    (REPLACE(REPLACE(STRING(crapcob.vldescto,"9999999999999.99"), 
                     ".", ""), ",", ""), TRUE, 15) +
                                             /* Vlr IOF */
                            retorna_complemento("", TRUE, 15).

                                             /* Vlr Abatimento */
                        IF craprem.cdocorre = 4 THEN /* concessao abatimento */
                            ASSIGN aux_linhaarq = aux_linhaarq +
retorna_complemento
    (REPLACE(REPLACE(STRING(crapcob.vlabatim,"9999999999999.99"), 
                        ".", ""), ",", ""), TRUE, 15).
                        ELSE
                            ASSIGN aux_linhaarq = aux_linhaarq +
                                          retorna_complemento("0", TRUE, 15).

                                             /* Uso Empresa Ced */
                        ASSIGN aux_linhaarq = aux_linhaarq +
                            /*retorna_complemento(crapcob.dsusoemp, FALSE, 25).*/
                            retorna_complemento(STRING(crapcob.nrcnvcob, "9999999") + 
                                                STRING(crapcob.nrdconta, "99999999") + 
                                                STRING(crapcob.nrdocmto, "999999999"),
                                                FALSE, 25).

                                             /* Código p/ Protesto */
                        IF crapcob.flgdprot = TRUE THEN
                           ASSIGN aux_linhaarq = aux_linhaarq + "1".
                        ELSE
                           ASSIGN aux_linhaarq = aux_linhaarq + "3".

                                             /* Nro Dias Protesto */
                        ASSIGN aux_linhaarq = aux_linhaarq +
                               (IF crapcob.qtdiaprt = 5 AND 
                                   crapcob.flgdprot THEN "06"
                                ELSE (IF crapcob.qtdiaprt >= 6 AND 
                                        crapcob.flgdprot THEN
                                        STRING(crapcob.qtdiaprt, "99")
                                      ELSE "00"))
                                             +
                                             /* Cód p/ baixa/devol */
                                             /* não baixar / não devolver */
                                             "2"                             +
                                             /* Prazo p/ baixa/devol */
                                             "000"                           +
                                             /* Código da Moeda */
                                             "09" /* Real */                 +
                                             /* Nro do Contrato */
                                        retorna_complemento("", TRUE, 10)    +
                                             /* Uso Exclusivo */
                                        retorna_complemento("", FALSE, 1).


                        PUT STREAM str_2 aux_linhaarq SKIP.

                        ASSIGN aux_linhaarq = ""
                               aux_qtdlinha = aux_qtdlinha + 1.

                        FIND crapsab WHERE crapsab.cdcooper = crapcob.cdcooper
                                       AND crapsab.nrdconta = crapcob.nrdconta
                                       AND crapsab.nrinssac = crapcob.nrinssac
                                                            NO-LOCK NO-ERROR.

                        IF AVAIL crapsab THEN
                        DO:
                            /* Gravacao das informacoes do titulo - 
                                                       layout FEBRABAN p. 54 */
                            /* Segmento Q */

                            ASSIGN aux_nrsequen = aux_nrsequen + 1

                                   aux_linhaarq = /* Banco na Compe */
                                                  "001"                      +
                                                  /* Lote de serviço */
                                                  "0001"                     +
                                                  /* Tipo de Registro */
                                                  "3"                        +
                                                  /* Nro Seq Reg Lote */
                                               STRING(aux_nrsequen, "99999") +
                                                  /* Segmento */
                                                  "Q"                        +
                                                  /* Uso exclusivo */
                                           retorna_complemento("", FALSE, 1) +
                                                  /* Cód Mov. Remessa */
                                              STRING(craprem.cdocorre, "99") +
                                                  /* Tipo Insc. */
                                              STRING(crapsab.cdtpinsc, "9")  +
                                                  /* Numero Insc. */
                    retorna_complemento(STRING(crapsab.nrinssac), TRUE, 15)  +
                                                  /* Nome Sacado */
            retorna_complemento(SUBSTR(crapsab.nmdsacad, 1, 40), FALSE, 40)  +
                                                  /* Endereço Sacado */
retorna_complemento(SUBSTR(crapsab.dsendsac + " " + 
                           STRING(crapsab.nrendsac) + "-" + 
                           crapsab.complend, 1, 40), FALSE, 40) +
                                                  /* Bairro do Sacado */
            retorna_complemento(SUBSTR(crapsab.nmbaisac, 1, 15), FALSE, 15)  +
                                                  /* CEP + Sufixo CEP */
                                        STRING(crapsab.nrcepsac, "99999999") +
                                                  /* Cidade */
            retorna_complemento(SUBSTR(crapsab.nmcidsac, 1, 15), FALSE, 15)  +
                                                  /* UF */
            retorna_complemento(SUBSTR(crapsab.cdufsaca, 1, 2), FALSE, 2)    +
                                                  /* Tipo Insc. Avalista */
                                              STRING(crapass.inpessoa, "9")  +
                                                  /* Nro Insc. Avalista */
                    retorna_complemento(STRING(crapass.nrcpfcgc), TRUE, 15)  +
                                                  /* Nome Sac/Avalista */
            retorna_complemento(SUBSTR(crapass.nmprimtl, 1, 40), FALSE, 40)  +
                                                  /* Banco Corresp */
                                                  "000"                      +
                                                  /* Nosso num. Corresp. */
                                          retorna_complemento("", FALSE, 20) +
                                                  /* Uso exclusivo */
                                          retorna_complemento("", FALSE, 8).


                            PUT STREAM str_2 aux_linhaarq SKIP.

                            ASSIGN aux_linhaarq = ""
                                   aux_qtdlinha = aux_qtdlinha + 1.

                        END.

                        /* Quando titulo tiver vlr multa > 0 e for remessa, 
                           entao gravar segmento "R" - Rafael Cechet 15/04/2011 */
                        IF crapcob.vlrmulta > 0 AND craprem.cdocorre = 1 THEN
                        DO:
                            /* Gravacao das informacoes do titulo - 
                                                       layout FEBRABAN p. 55 */
                            /* Segmento R */

                            ASSIGN aux_nrsequen = aux_nrsequen + 1 

                                   aux_linhaarq = /* Banco na Compe */
                                                  "001"                      +
                                                  /* Lote de serviço */
                                                  "0001"                     +
                                                  /* Tipo de Registro */
                                                  "3"                        +
                                                  /* Nro Seq Reg Lote */
                                               STRING(aux_nrsequen, "99999") +
                                                  /* Segmento */
                                                  "R"                        +
                                                  /* Uso exclusivo */
                                           retorna_complemento("", FALSE, 1) +
                                                  /* Cód Mov. Remessa */
                                           STRING(craprem.cdocorre, "99") +
                                                  /* Cód Desc. 2 */
                                           retorna_complemento("0", FALSE, 1) +
                                                  /* Data Desc 2. */
                                            retorna_complemento("", TRUE, 8) +
                                                  /* Vlr Desc 2. */
                                           retorna_complemento("", TRUE, 15) +
                                                  /* Cód Desc. 3 */
                                           retorna_complemento("0", FALSE, 1) +
                                                  /* Data Desc 3. */
                                            retorna_complemento("", TRUE, 8) +
                                                  /* Vlr Desc 3. */
                                           retorna_complemento("", TRUE, 15) +
                                                  /* Cód Multa */
                     retorna_complemento(string(crapcob.tpdmulta), FALSE, 1) +
                                                  /* Data Multa */
                                            retorna_complemento("", TRUE, 8) +
                                                  /* Vlr Multa */
                     retorna_complemento
                    (REPLACE(REPLACE(STRING(crapcob.vlrmulta,"999999999.99"), 
                        ".", ""), ",", ""), TRUE, 15) + 
                                                  /* Informacoes ao sacado */
                                           retorna_complemento("", FALSE, 10) +
                                                  /* Informacoes 3 */
                                           retorna_complemento("", FALSE, 40) +
                                                  /* Informacoes 4 */
                                           retorna_complemento("", FALSE, 40) +
                                                  /* Uso Exclusivo CNAB */
                                           retorna_complemento("", FALSE, 20) +
                                                  /* Cod Ocorr Sacado */
                                           retorna_complemento("0", TRUE, 8) +
                                                  /* Cod Banco Cta Deb */
                                           retorna_complemento("0", TRUE, 3) +
                                                  /* Cod Agencia Cta Deb */
                                           retorna_complemento("0", TRUE, 5) +
                                                  /* DV Cta Deb */
                                           retorna_complemento("", FALSE, 1) +
                                                  /* Cta Corrente Deb */
                                          retorna_complemento("0", TRUE, 12) +
                                                  /* DV Cta Deb */
                                           retorna_complemento("", FALSE, 1) +
                                                  /* DV Ag/Cta Deb */
                                           retorna_complemento("", FALSE, 1) +
                                                  /* Ind aviso 2=nao emite */
                                          retorna_complemento("2", FALSE, 1) +
                                                  /* uso exclusivo CNAB */
                                           retorna_complemento("", FALSE, 9).

                            PUT STREAM str_2 aux_linhaarq SKIP.

                            ASSIGN aux_linhaarq = ""
                                   aux_qtdlinha = aux_qtdlinha + 1.

                        END.

                    END.

                    ASSIGN aux_nrsequen = aux_nrsequen + 1.

                END.
            
                /* Gravacao do Trailer de Lote – layout Febraban p. 64 */

                ASSIGN aux_nrsequen = aux_nrsequen + 1

                       aux_linhaarq = /* Cód Banco Compe */
                                      "001" +
                                      /* Lote de serviço */
                                      "0001" +
                                      /* Tipo de registro */
                                      "5"    +
                                      /* Uso exclusivo */
                                    retorna_complemento("", FALSE, 9) +
                                      /* Qtd de registros lote */
                                     STRING(aux_nrsequen, "999999")   +
                                      /* Qtd Tit em Cob Simp */
                                    retorna_complemento("", TRUE, 6)  +
                                      /* Vlr Tit em Cob Simp */
                                    retorna_complemento("", TRUE, 17) +
                                      /* Qtd Tit Cob Vinc. */
                                    retorna_complemento("", TRUE, 6)  +
                                      /* Vlr Tit Cob Vinc. */
                                    retorna_complemento("", TRUE, 17) +
                                      /* Qtd Tit Cob Cauc. */
                                    retorna_complemento("", TRUE, 6)  +
                                      /* Vlr Tit Cob Cauc. */
                                    retorna_complemento("", TRUE, 17) +
                                      /* Qtd Tit Cob Desc */
                                    retorna_complemento("", TRUE, 6)  +
                                      /* Vlr Tit Cob Desc. */
                                    retorna_complemento("", TRUE, 17) +
                                      /* Nro do aviso Lcto */
                                    retorna_complemento("", TRUE, 8)  +
                                      /* Uso exclusivo */
                                    retorna_complemento("", TRUE, 117).


                PUT STREAM str_2 aux_linhaarq SKIP.

                ASSIGN aux_linhaarq = ""
                       aux_qtdlinha = aux_qtdlinha + 1

                /* Gravacao do Trailer de Arquivo – layout Febraban p. 18 */

                       aux_linhaarq = /* Cód Banco Compe */
                                      "001" +
                                      /* Lote de serviço */
                                      "9999" +
                                      /* Tipo de registro */
                                      "9"    +
                                      /* Uso exclusivo */
                                      retorna_complemento("", FALSE, 9) +
                                      /* Qtd Lotes no arquivo */
                                      "000001"                          +
                                      /* Qtd registros */
                                      STRING(aux_qtdlinha, "999999")    +
                                      /* Qtd Contas p/ conc */
                                      STRING(0, "999999")               +
                                      /* Uso exclusivo */
                                      retorna_complemento("", FALSE, 205).


                PUT STREAM str_2 aux_linhaarq SKIP.

                ASSIGN crapcre.flgproce = TRUE.

                OUTPUT STREAM str_2 CLOSE.

                UNIX SILENT VALUE ("mv /usr/coop/" + aux_dsdircop + "/arq/" + 
                                   aux_nmarquiv + 
                          " /usr/coop/" + aux_dsdircop + "/compbb/remessa/" +
                          /*"ied240." + trim(aux_chave) + "." + 
                          string(day(TODAY), "99") +
                          string(month(TODAY),"99") +
                          substr(string(year(TODAY), "9999"),3,2) +
                          substr(string(time,"HH:MM:SS"),1,2) +
                          substr(string(time,"HH:MM:SS"),4,2) +
                          substr(string(time,"HH:MM:SS"),7,2) +
                          substr(string(now),21,03) + /* milesimos de segundo */
                          ".bco001." + 
                          "c" + string(aux_nrdocnpj,"99999999999999") +*/
                          aux_nmarquiv + 
                          " 2> /dev/null").

            END.
        END.
    END. /* END DO TRANSACTION */

    IF VALID-HANDLE(h-b1wgen0088) THEN
    DO:
        DELETE PROCEDURE h-b1wgen0088.
    END.

    glb_dscritic = "Remessa gerada com sucesso!".
    RUN gera_critica_procbatch.

    RETURN "OK".
END PROCEDURE.

PROCEDURE gera_relatorio_remcob.

    DEF INPUT PARAM par_nrdbanco AS INT                         NO-UNDO.
    DEF INPUT PARAM par_dtremess AS DATE                        NO-UNDO.
    DEF INPUT PARAM par_cdcooper LIKE crapcop.cdcooper          NO-UNDO.

    DEF VAR aux_qtdgeral AS INTE                                NO-UNDO.
    DEF VAR aux_valgeral AS DECI                                NO-UNDO.
    DEF VAR aux_qtdtitu  AS INTE                                NO-UNDO.
    DEF VAR aux_valtitu  AS DECI                                NO-UNDO.

    DEF VAR aux_nmarquiv AS CHAR                                NO-UNDO.
    DEF VAR aux_vltitulo AS DECI FORMAT "zzz,zzz,zz9.99"        NO-UNDO.
    DEF VAR aux_qtdtitul AS INT  FORMAT "zz9"                   NO-UNDO.
    DEF VAR aux_vldescon AS DECI FORMAT "zzz,zz9.99"            NO-UNDO.
    DEF VAR aux_vlabatim AS DECI FORMAT "zzz,zz9.99"            NO-UNDO.
    DEF VAR aux_cdrelato AS CHAR                                NO-UNDO.
    DEF VAR aux_nmarqtmp AS CHAR                                NO-UNDO.
    DEF VAR aux_nmarqpdf AS CHAR                                NO-UNDO.
    DEF VAR aux_tprelato AS INT                                 NO-UNDO.
    DEF VAR aux_nmrelato AS CHAR                                NO-UNDO.
            


    { includes/cabrel132_1.i }

    DO TRANSACTION:

        FOR EACH crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK:

            /* Lote de remessa – CRAPCRE */
            FOR EACH crapcre WHERE crapcre.dtmvtolt = par_dtremess
                               AND crapcre.intipmvt =  1 /* remessa */
                               AND crapcre.cdcooper = crapcop.cdcooper
                               AND crapcre.flgproce = TRUE /*faba*/ NO-LOCK,
        
                EACH crapcco WHERE crapcco.cdcooper = crapcre.cdcooper
                               AND crapcco.nrconven = crapcre.nrcnvcob
                               AND crapcco.flgregis = TRUE
                               AND crapcco.flgativo = TRUE
                               AND crapcco.cddbanco = par_nrdbanco NO-LOCK:
                    
                    
                    ASSIGN aux_qtdgeral = 0
                           aux_valgeral = 0
                           glb_nmrescop = crapcop.nmrescop
                           aux_nmarquiv = "crrl596_" 
                                          + STRING(crapcco.nrconven)
                                          + "_"
                                          + STRING(crapcre.nrremret)
                                          + ".lst".
            
                    OUTPUT STREAM str_1 TO VALUE("/usr/coop/" + 
                                                  crapcop.dsdircop 
                                                  + "/rl/" + aux_nmarquiv) 
                                                            PAGED PAGE-SIZE 84.
                    
                    VIEW STREAM str_1 FRAME f_cabrel132_1.
                    
                    DISP STREAM str_1 "Destino: Cobranca" 
                                      SKIP(1)
                                      "Arquivo: compbb/remessa/" crapcre.nmarquiv 
                                      FORMAT "X(50)" AT 25 NO-LABEL
                                      SKIP(1)
                                      "Data:" par_dtremess FORMAT "99/99/9999"
                                                                      NO-LABEL
                                      SPACE(5)
                                      "Banco: 001"
                                      SPACE(5)
                                      "Tipo: Remessa"
                                      SPACE(5)
                                      "Convenio:" 
                                      crapcco.nrconven AT 64 NO-LABEL
                                      SKIP(2).

                    DOWN STREAM str_1.

        
                    /* DF titulos do lote de remessa – CRAPREM */
                    FOR EACH craprem WHERE craprem.cdcooper = crapcco.cdcooper
                                       AND craprem.nrcnvcob = crapcco.nrconven
                                       AND craprem.nrremret = crapcre.nrremret
                                       AND craprem.nrdconta > 0
                                       AND craprem.nrseqreg > 0 NO-LOCK 
                                                                BREAK BY 
                                                              craprem.cdocorre:

                        /* Busca o valor do titulo correspondente */
                        FIND crapcob WHERE crapcob.cdcooper = craprem.cdcooper
                                       AND crapcob.nrdconta = craprem.nrdconta
                                       AND crapcob.cdbandoc = crapcco.cddbanco
                                       AND crapcob.nrdctabb = crapcco.nrdctabb 
                                       AND crapcob.nrcnvcob = craprem.nrcnvcob
                                       AND crapcob.nrdocmto = craprem.nrdocmto
                                       AND crapcob.flgregis = TRUE NO-LOCK 
                                                                   NO-ERROR.
        
                        IF AVAIL crapcob THEN
                        DO:
                            ASSIGN aux_qtdtitu = aux_qtdtitu + 1
                                   aux_valtitu = aux_valtitu + crapcob.vltitu.
        
                            IF LAST-OF(craprem.cdocorre) THEN
                            DO:
                                /* Busca a descricao da ocorrencia */
                                FIND crapoco WHERE crapoco.cdcooper = 
                                                                craprem.cdcooper
                                               AND crapoco.cddbanco = 
                                                                crapcco.cddbanco
                                               AND crapoco.cdocorre = 
                                                                craprem.cdocorre
                                               AND crapoco.tpocorre = 1 
                                                                /* remessa */
                                                               NO-LOCK NO-ERROR.
        
                                IF AVAIL crapoco THEN
                                DO:
                                    DISP STREAM str_1 craprem.cdocorre 
                                                      COLUMN-LABEL "Cod."
                                                      FORMAT "zz9"            
                                                      crapoco.dsocorre
                                                      COLUMN-LABEL "Descricao"
                                                      FORMAT "x(40)"
                                                      aux_qtdtitu
                                                      COLUMN-LABEL "Qtd"
                                                      FORMAT "zzz,zz9"
                                                      aux_valtitu
                                                      COLUMN-LABEL "Valor"
                                                      FORMAT "zzz,zzz,zz9.99".
        
                                    ASSIGN aux_qtdgeral = aux_qtdgeral + 
                                                          aux_qtdtitu 
                                           aux_valgeral = aux_valgeral + 
                                                          aux_valtitu 
        
                                           aux_qtdtitu = 0
                                           aux_valtitu = 0.
                                END.
        
                            END.
        
                        END.

                    END.

                    PUT STREAM str_1 SKIP(2)
                                     "Total"      AT 06
                                     aux_qtdgeral AT 47
                                     aux_valgeral AT 55
                                     SKIP(1).

                    /*----------- GERACAO DO ANALITICO ---------------------*/
                    
                    ASSIGN aux_qtdtitul = 0
                           aux_vltitulo = 0
                           aux_vldescon = 0
                           aux_vlabatim = 0.

                    FOR EACH craprem WHERE craprem.cdcooper = crapcco.cdcooper
                                       AND craprem.nrcnvcob = crapcco.nrconven
                                       AND craprem.nrremret = crapcre.nrremret
                                       AND craprem.nrdconta > 0
                                       AND craprem.nrseqreg > 0,

                        EACH crapass WHERE craprem.cdcooper = crapass.cdcooper
                                       AND craprem.nrdconta = crapass.nrdconta
                                           NO-LOCK  BREAK BY craprem.cdocorre 
                                                          BY crapass.cdagenci:
                        
                        FIND crapcob WHERE crapcob.cdcooper = craprem.cdcooper
                                       AND crapcob.nrdconta = craprem.nrdconta
                                       AND crapcob.cdbandoc = crapcco.cddbanco
                                       AND crapcob.nrdctabb = crapcco.nrdctabb
                                       AND crapcob.nrcnvcob = craprem.nrcnvcob
                                       AND crapcob.nrdocmto = craprem.nrdocmto
                                       AND crapcob.flgregis = TRUE NO-LOCK 
                                                                   NO-ERROR.
        
                        IF AVAIL crapcob THEN
                        DO:
                            IF FIRST-OF(craprem.cdocorre) THEN
                            DO:
                                /* Busca a descricao da ocorrencia */
                                FIND crapoco WHERE crapoco.cdcooper = 
                                                                craprem.cdcooper
                                               AND crapoco.cddbanco = 
                                                                crapcco.cddbanco
                                               AND crapoco.cdocorre = 
                                                                craprem.cdocorre
                                               AND crapoco.tpocorre = 1 
                                                                /* remessa */
                                                               NO-LOCK NO-ERROR.

                                IF AVAIL crapoco THEN
                                DO:
                                    DISP STREAM str_1 SKIP(2)
                                                      "Ocorrencia:"
                                                      craprem.cdocorre 
                                                        NO-LABEL FORMAT "zz9"
                                                      "-"
                                                      crapoco.dsocorre NO-LABEL
                                                      SKIP(2).

                                    PUT STREAM str_1 "PA"          AT 04
                                                      "Nr. Conta"  AT 08
                                                      "CPF/CNPJ"   AT 24
                                                      "Boleto"     AT 35
                                                      "Doc. Coop"  AT 43
                                                      "Vencto"     AT 62
                                                      "Vlr Titulo" AT 79
                                                      "Desc."      AT 97
                                                      "Abat."      AT 110
                                                      SKIP.
                                END.
                            END.

                            FIND crapsab WHERE crapsab.cdcooper =
                                               crapcob.cdcooper
                                           AND crapsab.nrdconta = 
                                               crapcob.nrdconta
                                           AND crapsab.nrinssac = 
                                               crapcob.nrinssac NO-LOCK 
                                                                NO-ERROR.

                            IF AVAIL crapsab THEN
                            DO:
                                PUT STREAM str_1 crapass.cdagenci
                                                     AT 03
                                                  crapcob.nrdconta
                                                     AT 07
                                                  crapsab.nrinssac
                                                     AT 17
                                                  crapcob.nrdocmto 
                                                     AT 32
                                                  crapcob.dsdoccop 
                                                     AT 43
                                                  crapcob.dtvencto 
                                                     AT 58
                                                  crapcob.vltitulo 
                                                     FORMAT "zzz,zzz,zz9.99" 
                                                     AT 75
                                                  crapcob.vldescto
                                                     FORMAT "zzz,zz9.99" 
                                                     AT 92
                                                  crapcob.vlabatim
                                                     FORMAT "zzz,zz9.99"
                                                     AT 105.

                                ASSIGN aux_qtdtitul = aux_qtdtitul + 1
                                       aux_vltitulo = aux_vltitulo + 
                                                            crapcob.vltitulo
                                       aux_vldescon = aux_vldescon + 
                                                            crapcob.vldescto
                                       aux_vlabatim = aux_vlabatim + 
                                                            crapcob.vlabatim.

                                IF LAST-OF(craprem.cdocorre) THEN
                                DO:
                                    
                                    PUT STREAM str_1 SKIP(1)
                                                     "Total" AT 12
                                                     aux_qtdtitul AT 29 
                                                     aux_vltitulo AT 75 
                                                     aux_vldescon AT 92
                                                     aux_vlabatim AT 105.


                                    ASSIGN aux_qtdtitul = 0
                                           aux_vltitulo = 0
                                           aux_vldescon = 0
                                           aux_vlabatim = 0.
                                END.
                            END.
                                              
                        END.
                    END.

                    OUTPUT STREAM str_1 CLOSE.
                           
                    UNIX SILENT VALUE("cp " + "/usr/coop/" + crapcop.dsdircop + 
                                      "/rl/" + aux_nmarquiv + 
                                      " /usr/coop/" + crapcop.dsdircop + "/rlnsv").

                    ASSIGN aux_tprelato = 0
                           aux_nmrelato = " ".

                    FIND craprel WHERE craprel.cdcooper = crapcop.cdcooper AND
                                       craprel.cdrelato = 596
                                       NO-LOCK NO-ERROR.

                    IF   AVAIL craprel  THEN
                         DO:
                             IF   craprel.tprelato = 2   THEN
                                  ASSIGN aux_tprelato = 1.
                   
                             ASSIGN aux_nmrelato = craprel.nmrelato.
                         END.
                   
                    ASSIGN aux_cdrelato = aux_nmarquiv
                           aux_nmarqtmp = "tmppdf/" + aux_cdrelato + ".txt"
                           aux_nmarqpdf = SUBSTR(aux_cdrelato,1,
                                          LENGTH(aux_cdrelato) - 4) + ".pdf".
                   
                    OUTPUT STREAM str_4 TO VALUE (aux_nmarqtmp).
                    
                    PUT STREAM str_4 crapcop.nmrescop                                 ";"
                                     STRING(YEAR(glb_dtmvtolt),"9999") FORMAT "x(04)" ";"
                                     STRING(MONTH(glb_dtmvtolt),"99")  FORMAT "x(02)" ";"
                                     STRING(DAY(glb_dtmvtolt),"99")    FORMAT "x(02)" ";"
                                     STRING(aux_tprelato,"z9")         FORMAT "x(02)" ";"
                                     aux_nmarqpdf                                     ";"
                                     CAPS(aux_nmrelato)                FORMAT "x(50)" ";"
                                     SKIP.
                   
                    OUTPUT STREAM str_4 CLOSE.
                   
                    
                    UNIX SILENT VALUE("echo script/CriaPDF.sh "               + 
                                      "/usr/coop/" + crapcop.dsdircop         + 
                                      "/rl/"                                  +
                                      aux_nmarquiv + " NAO 132col "           +
                                      STRING(YEAR(glb_dtmvtolt),"9999") + "_" + 
                                      STRING(MONTH(glb_dtmvtolt),"99") + "/"  + 
                                      STRING(DAY(glb_dtmvtolt),"99") + " "    + 
                                      crapcop.dsdircop                        + 
                                      " >> log/CriaPDF.log").
                    
                    UNIX SILENT VALUE("/usr/coop/" + crapcop.dsdircop         + 
                                      "/script/CriaPDF.sh "                   +
                                      "/usr/coop/" + crapcop.dsdircop         + 
                                      "/rl/"                                  +
                                      aux_nmarquiv + " NAO 132col "           +
                                      STRING(YEAR(glb_dtmvtolt),"9999") + "_" + 
                                      STRING(MONTH(glb_dtmvtolt),"99") + "/"  + 
                                      STRING(DAY(glb_dtmvtolt),"99") + " "    + 
                                      crapcop.dsdircop).
                   
                    ASSIGN glb_nrcopias = 1
                               glb_nmformul = "132col"
                                   glb_nmarqimp = "/usr/coop/" + crapcop.dsdircop 
                                          + "/rl/" + aux_nmarquiv.
        
                        RUN fontes/imprim_unif.p (INPUT crapcop.cdcooper).
        
            END.
            
        END.
        
    END. /* END DO TRANSACTION */

    RETURN "OK".
END PROCEDURE.

PROCEDURE gera_arq_debcns:

    DEF INPUT PARAM par_cdcooper    AS  INTE                        NO-UNDO.
    DEF INPUT PARAM par_nrseqexe    AS  INTEGER                     NO-UNDO.
    
   
    ASSIGN glb_cddopcao    = "P"
           glb_cdempres    = 11
           glb_cdrelato[1] = 663
           glb_nmdestin[1] = "DESTINO: ADMINISTRATIVO"
           aux_dtdebito    = glb_dtmvtolt
           aux_cdcooper    = par_cdcooper
           aux_nmarqcen = "crrl663_" + STRING(TIME) + ".lst"
           aux_nmaqcesv = "rlnsv/" + aux_nmarqcen
           aux_nmarqcen = "rl/" + aux_nmarqcen.

    FIND crapdat WHERE crapdat.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

    IF  NOT AVAIL(crapdat) THEN
        DO:
            ASSIGN glb_dscritic = crapcop.nmrescop +
                                " - Registro crapdat nao encontrado.".
            RUN gera_critica_procmessage.
            RETURN "OK".
        END.
    ELSE
        DO:
            ASSIGN glb_dtmvtolt = crapdat.dtmvtolt
                   glb_dtmvtopr = crapdat.dtmvtopr.
        END.

    EMPTY TEMP-TABLE tt-obtem-consorcio.
   
    ASSIGN glb_dscritic = "".

    /*   Verifica somente das cooperativas que tiverem  agendamentos */
    FIND craptab WHERE craptab.cdcooper = crapcop.cdcooper AND
                       craptab.nmsistem = "CRED"           AND
                       craptab.tptabela = "GENERI"         AND
                       craptab.cdempres = 00               AND
                       craptab.cdacesso = "HRPGSICRED"     AND
                       craptab.tpregist = 90  NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE craptab  THEN
        DO:
            ASSIGN glb_dscritic = crapcop.nmrescop +
                                " - Tabela HRPGSICRED nao cadastrada.".
            RUN gera_critica_procbatch.
            RETURN "OK".
        END.
    ELSE
        DO:
            IF  SUBSTR(craptab.dstextab,19,3) = "SIM"  THEN
                ASSIGN aux_flsgproc = TRUE.
            ELSE
                ASSIGN aux_flsgproc = FALSE.
                                                       
            /*Verifica se cooperativa optou pelo segundo processo*/
            IF  NOT aux_flsgproc  THEN
                DO:
                    ASSIGN glb_dscritic = crapcop.nmrescop +
                                         " - Opcao para processo manual " +
                                         "desabilitada.".
                    RUN gera_critica_procbatch.
                    RETURN "OK".
                END.
            
            /** Verifica se horario para pagamentos nao esgotou */
            /* M349 - Deixa de validar o horario pois ocorrera uma execucao
			   do programa durante o dia dentro do horario que ainda nao esgotou 
			   para pagamento					
            IF  TIME > INT(ENTRY(1,craptab.dstextab," ")) AND
                TIME < INT(ENTRY(2,craptab.dstextab," ")) THEN
                DO:
                    ASSIGN glb_dscritic = crapcop.nmrescop   +
                                          " - Horario para " + 
                                          "pagamentos CONSORCIO nao esgotou".
                    RUN gera_critica_procbatch.
                    RETURN "OK".
                END. */
        END.
        
    /*** PROCESSA COOPERATIVA ***/
    RUN obtem-consorcio.

    IF  RETURN-VALUE = "NOK"  THEN
        DO: 
            RUN gera_critica_procmessage.
            RETURN "OK".
        END.
 

    FIND FIRST tt-obtem-consorcio NO-LOCK NO-ERROR.

    IF  NOT AVAIL(tt-obtem-consorcio) THEN
        DO:
            ASSIGN glb_dscritic = "Nao ha consorcios para processar neste momento para cooperativa " + crapcop.nmrescop.
            RUN gera_critica_procbatch.
            RETURN "OK".
        END. 

    /*Debito dos consorcios*/
    RUN efetua-debito-consorcio(INPUT FALSE, 
                                INPUT par_nrseqexe).
    
    HIDE MESSAGE NO-PAUSE.

    ASSIGN aux_nmarquiv = "crrl663_" + STRING(TIME) + ".lst"
           aux_nmarqimp = "/usr/coop/" + crapcop.dsdircop + 
                          "/rl/" + aux_nmarquiv
           aux_nmarquiv = "/usr/coop/" + crapcop.dsdircop + 
                          "/rlnsv/" + aux_nmarquiv.

    RUN imprime-consorcios (INPUT crapcop.cdcooper).

    IF  RETURN-VALUE = "OK"  THEN
        UNIX SILENT VALUE ("cat " + aux_nmarqimp + " >> " + aux_nmarqcen). 

    RETURN "OK".
END PROCEDURE.

PROCEDURE proc_agenda_resg_aplica:
         
    DEF INPUT PARAM par_cdcooper    AS  INTE                        NO-UNDO.

    DEF VAR aux_nmtelant            AS  CHAR                        NO-UNDO.


    ASSIGN aux_nmtelant = glb_nmtelant
           glb_nmtelant = "AUTCOMPE".

    ETIME(TRUE).

    { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }

    RUN STORED-PROCEDURE pc_crps688 aux_handproc = PROC-HANDLE NO-ERROR
           (INPUT par_cdcooper,
            INPUT  0,
            OUTPUT 0,
            OUTPUT 0,
            OUTPUT 0, 
            OUTPUT "").

    IF  ERROR-STATUS:ERROR  THEN DO:
        DO  aux_qterrora = 1 TO ERROR-STATUS:NUM-MESSAGES:
            ASSIGN aux_msgerora = aux_msgerora + 
                                  ERROR-STATUS:GET-MESSAGE(aux_qterrora) + " ".
        END.

        UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                          " - " + glb_cdprogra + "' --> '"  +
                          "Erro ao executar Stored Procedure: '" +
                          aux_msgerora + "' >> log/proc_batch.log").
        RETURN.
    END.

    CLOSE STORED-PROCEDURE pc_crps688 WHERE PROC-HANDLE = aux_handproc.

    { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

    UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS")    + 
                      " - "   + glb_cdprogra + "' --> '"   +
                      "Stored Procedure rodou em "         + 
                      STRING(INT(ETIME / 1000),"HH:MM:SS") + 
                      " >> log/proc_batch.log").


    ASSIGN glb_nmtelant = aux_nmtelant.

    RETURN "OK".

END PROCEDURE.

PROCEDURE envia_arq:

    DEF INPUT PARAM par_cdcooper    AS  INTE                        NO-UNDO.

    RUN carrega_tabela_envio(INPUT par_cdcooper).

    ASSIGN aux_arqlista = "".

    FOR EACH w-arquivos NO-LOCK,
        EACH crawarq WHERE crawarq.dscooper = w-arquivos.dscooper AND
                           crawarq.tparquiv = w-arquivos.tparquiv 
                           NO-LOCK:            

        ASSIGN aux_nrbarras = NUM-ENTRIES(crawarq.nmarquiv,"/")
               aux_nmarquiv = ENTRY(aux_nrbarras,crawarq.nmarquiv,"/")
               aux_arqdolog = aux_arqdolog + aux_nmarquiv + ",".
               aux_arqlista = aux_arqlista + crawarq.nmarquiv + ",".
    END.

    /* Remove a virgula do fim da string */
    ASSIGN aux_arqlista = SUBSTR(aux_arqlista,1,
                          LENGTH(aux_arqlista) - 1).
           aux_arqdolog = SUBSTR(aux_arqdolog,1,
                          LENGTH(aux_arqdolog) - 1).

    IF  aux_arqlista = ""  THEN 
        DO:
            ASSIGN glb_cdcritic = 239.
            RUN fontes/critic.p.
            RUN gera_critica_procmessage.

            ASSIGN glb_cdcritic = 0.
        END.
    ELSE
        DO:

            DO aux_contador = 1 TO NUM-ENTRIES(aux_arqlista,","):

                DOWN STREAM teste.

                IF  OS-GETENV("PKGNAME") = "pkgprod" OR 
                    OS-GETENV("PKGNAME") = "PKGPROD" THEN
                    UNIX SILENT VALUE('/usr/local/cecred/bin/ftpabbc_envia.pl' +
                                      ' --arquivo="' +
                                      ENTRY(aux_contador,aux_arqlista,",") + '" ' +
                                      '--origem="Automatizado"').
                
            END.  

        END.

    RETURN "OK".
END PROCEDURE.

PROCEDURE carrega_tabela_envio.

    DEF INPUT PARAM par_cdcooper    AS  INTE                        NO-UNDO.
    DEF BUFFER b-crapfer FOR crapfer.

    EMPTY TEMP-TABLE crawarq.
    EMPTY TEMP-TABLE w-arquivos.

    FIND crabcop WHERE crabcop.cdcooper = 3 NO-LOCK NO-ERROR.

    IF  AVAIL(crabcop) THEN
        DO:
            /*Devolucao de doc para CECRED*/
            ASSIGN aux_nmarquiv = "/micros/"   + crabcop.dsdircop + 
                                  "/abbc/3" + STRING(crabcop.cdagectl,"9999") +
                                  "*.DVS"
                   aux_tparquiv = "DEVOLU".
        
            RUN verifica_arquivos.
        END.


    FOR EACH crabcop WHERE crabcop.cdcooper <> 3 AND
                           crabcop.flgativo = TRUE NO-LOCK:

        /*** Procura arquivos CHEQUES ***/
        ASSIGN aux_nmarquiv = "/micros/"   + crabcop.dsdircop + 
                              "/abbc/1" + STRING(crabcop.cdagectl,"9999") +
                              "*.*"
               aux_tparquiv = "COMPEL".

        RUN verifica_arquivos.
        
        /* verificar se o dia atual eh um feriado */
        FIND FIRST b-crapfer 
             WHERE b-crapfer.cdcooper = crabcop.cdcooper
               AND b-crapfer.dtferiad = TODAY
               NO-LOCK NO-ERROR.
        
        /* se o dia atual nao for feriado, os arquivos 2* podem
           ser transmitidos para a ABBC */
        IF NOT AVAIL b-crapfer THEN 
        DO:                             
          /*** Procura arquivos TITULOS ***/
          ASSIGN aux_nmarquiv = "/micros/"   + crabcop.dsdircop + 
                                "/abbc/2" + STRING(crabcop.cdagectl,"9999") +
                                "*.*"
                 aux_tparquiv = "TITULOS". 
            
          RUN verifica_arquivos.
        END.

        /*** Procura arquivos TITULOS ***/
        ASSIGN aux_nmarquiv = "/micros/"   + crabcop.dsdircop + 
                              "/abbc/8" + STRING(crabcop.cdagectl,"9999") +
                              "*.*"
               aux_tparquiv = "TITULOS". 
            
        RUN verifica_arquivos.
    
        IF  crabcop.cdcooper = 1 THEN
            DO:
                /*VIACON*/
                FOR EACH b-crapcop WHERE b-crapcop.cdcooper = 1 OR
                                         b-crapcop.cdcooper = 4 NO-LOCK:
                    /*** Procura arquivos DOCs ***/
                    ASSIGN aux_nmarquiv = "/micros/"   + crabcop.dsdircop + 
                                          "/abbc/3" + STRING(b-crapcop.cdagectl,"9999") +
                                          "*.*"
                           aux_tparquiv = "DOCTOS".
                       
                    RUN verifica_arquivos.
            
                    /*** Procura arquivos DEVOLU ***/
                    ASSIGN aux_nmarquiv = "/micros/"   + crabcop.dsdircop + 
                                          "/abbc/1" + STRING(b-crapcop.cdagectl,"9999") +
                                          "*.DV*"
                           aux_tparquiv = "DEVOLU".
                       
                    RUN verifica_arquivos.
                    
                    /*** Procura arquivos DEVOLU ***/
                    ASSIGN aux_nmarquiv = "/micros/"   + crabcop.dsdircop + 
                                          "/abbc/5" + STRING(b-crapcop.cdagectl,"9999") +
                                          "*.DVS"
                           aux_tparquiv = "DEVOLU".
                       
                    RUN verifica_arquivos.
                END.

            END.
        ELSE IF  crabcop.cdcooper = 13 THEN
            DO:
                /*VIACON*/
                FOR EACH b-crapcop WHERE b-crapcop.cdcooper = 13 OR
                                         b-crapcop.cdcooper = 15 NO-LOCK:
                    /*** Procura arquivos DOCs ***/
                    ASSIGN aux_nmarquiv = "/micros/"   + crabcop.dsdircop + 
                                          "/abbc/3" + STRING(b-crapcop.cdagectl,"9999") +
                                          "*.*"
                           aux_tparquiv = "DOCTOS".
                       
                    RUN verifica_arquivos.
            
                    /*** Procura arquivos DEVOLU ***/
                    ASSIGN aux_nmarquiv = "/micros/"   + crabcop.dsdircop + 
                                          "/abbc/1" + STRING(b-crapcop.cdagectl,"9999") +
                                          "*.DV*"
                           aux_tparquiv = "DEVOLU".
                       
                    RUN verifica_arquivos.
                    
                    /*** Procura arquivos DEVOLU ***/
                    ASSIGN aux_nmarquiv = "/micros/"   + crabcop.dsdircop + 
                                          "/abbc/5" + STRING(b-crapcop.cdagectl,"9999") +
                                          "*.DVS"
                           aux_tparquiv = "DEVOLU".
                       
                    RUN verifica_arquivos.
                END.

            END.
        ELSE IF  crabcop.cdcooper = 9 THEN  /* Transulcred */ 
            DO:
                /*TRANSPOSUL*/
                FOR EACH b-crapcop WHERE b-crapcop.cdcooper = 9 OR
                                         b-crapcop.cdcooper = 17 NO-LOCK:
            
                    /*** Procura arquivos DOCs ***/
                    ASSIGN aux_nmarquiv = "/micros/"   + crabcop.dsdircop + 
                                          "/abbc/3" + STRING(b-crapcop.cdagectl,"9999") +
                                          "*.*"
                           aux_tparquiv = "DOCTOS".
                       
                    RUN verifica_arquivos.
					
                    /*** Procura arquivos DEVOLU ***/
                    ASSIGN aux_nmarquiv = "/micros/"   + crabcop.dsdircop + 
                                          "/abbc/1" + STRING(b-crapcop.cdagectl,"9999") +
                                          "*.DV*"
                           aux_tparquiv = "DEVOLU".
                       
                    RUN verifica_arquivos.
                    
                    /*** Procura arquivos DEVOLU ***/
                    ASSIGN aux_nmarquiv = "/micros/"   + crabcop.dsdircop + 
                                          "/abbc/5" + STRING(b-crapcop.cdagectl,"9999") +
                                          "*.DVS"
                           aux_tparquiv = "DEVOLU".
                       
                    RUN verifica_arquivos.
                END.

            END.
        ELSE
            DO:
                /*** Procura arquivos DOCs ***/
                ASSIGN aux_nmarquiv = "/micros/"   + crabcop.dsdircop + 
                                      "/abbc/3" + STRING(crabcop.cdagectl,"9999") +
                                      "*.*"
                       aux_tparquiv = "DOCTOS".
                   
                RUN verifica_arquivos.
        
                /*** Procura arquivos DEVOLU ***/
                ASSIGN aux_nmarquiv = "/micros/"   + crabcop.dsdircop + 
                                      "/abbc/1" + STRING(crabcop.cdagectl,"9999") +
                                      "*.DV*"
                       aux_tparquiv = "DEVOLU".
                   
                RUN verifica_arquivos.
                
                /*** Procura arquivos DEVOLU ***/
                ASSIGN aux_nmarquiv = "/micros/"   + crabcop.dsdircop + 
                                      "/abbc/5" + STRING(crabcop.cdagectl,"9999") +
                                      "*.DVS"
                       aux_tparquiv = "DEVOLU".
                   
                RUN verifica_arquivos.
            END.

        /*** Procura arquivos CUSTODIA ***/
        ASSIGN aux_nmarquiv = "/micros/" + crabcop.dsdircop + "/abbc/C" + 
                              STRING(crabcop.cdagectl,"9999") +
                              "*.001"
               aux_tparquiv = "CUSTODIA ESTOQ".
           
        RUN verifica_arquivos.
        
        /*** Procura arquivos CUSTODIA ***/
        ASSIGN aux_nmarquiv = "/micros/" + crabcop.dsdircop + "/abbc/C" + 
                              STRING(crabcop.cdagectl,"9999") +
                              "*.002"
               aux_tparquiv = "CUSTODIA COMPE".
           
        RUN verifica_arquivos.

        /*** Procura aruivos TIC604***/
        ASSIGN aux_nmarquiv = "/micros/"   + crabcop.dsdircop + 
                              "/abbc/1" + STRING(crabcop.cdagectl,"9999") + 
                              "*.C*"
               aux_tparquiv = "TIC". 
        
        RUN verifica_arquivos.
        
    END.

    /*** TIPO RELACIONAMENTO ***/
    IF   par_cdcooper = 0 THEN 
         par_cdcooper = 3.
        
    FIND crabcop WHERE crabcop.cdcooper = INT(par_cdcooper) NO-LOCK NO-ERROR.
        
    /*** Procura arquivos ICF(RELACIONAMENTO) ***/
    ASSIGN aux_nmarquiv = "/micros/cecred/abbc/ICF" +
                          STRING(crabcop.cdbcoctl,"999") + "01.REM"
           aux_tparquiv = "RELACIONAMENTO"
           par_cdcooper = 0.
           
    RUN verifica_arquivos.


    /*** TIPO ICF604 ***/
    ASSIGN par_cdcooper = 3.

    FIND crabcop WHERE crabcop.cdcooper = INT(par_cdcooper) NO-LOCK NO-ERROR.

    ASSIGN aux_nmarquiv = "/micros/cecred/abbc/i2" +
                          STRING(crabcop.cdbcoctl,"999") + "*.REM"
           aux_tparquiv = "ICFJUD-604"
           par_cdcooper = 0.
           
    RUN verifica_arquivos. 

    /*** TIPO ICF606 ***/
    ASSIGN par_cdcooper = 3.

    FIND crabcop WHERE crabcop.cdcooper = INT(par_cdcooper) NO-LOCK NO-ERROR.

    ASSIGN aux_nmarquiv = "/micros/cecred/abbc/i3" +
                           STRING(crabcop.cdbcoctl,"999") + "*.REM"
           aux_tparquiv = "ICFJUD-606"
           par_cdcooper = 0.
           
    RUN verifica_arquivos. 

    /*** ARQUIVOS DEVOLUCAO - SUA REMESSA 085 ***/
    ASSIGN par_cdcooper = 3.

    FIND crabcop WHERE crabcop.cdcooper = INT(par_cdcooper) NO-LOCK NO-ERROR.

    /* verificar se o dia atual eh um feriado */
    FIND FIRST b-crapfer 
         WHERE b-crapfer.cdcooper = par_cdcooper
           AND b-crapfer.dtferiad = TODAY
           NO-LOCK NO-ERROR.
        
    /* se o dia atual nao for feriado, os arquivos 2* podem
       ser transmitidos para a ABBC */
    IF NOT AVAIL b-crapfer THEN 
    DO:
      ASSIGN aux_nmarquiv = "/micros/cecred/abbc/2*.DVS"
             aux_tparquiv = "DEVSR085" /* devolucao boletos sua remessa 085 */
             par_cdcooper = 0.
           
      RUN verifica_arquivos.     
    END.    
        
    ASSIGN aux_tparquiv = "".

    FOR EACH crawarq NO-LOCK BREAK BY crawarq.tparquiv
                                      BY crawarq.dscooper:
    
        IF   FIRST-OF(crawarq.tparquiv)  OR
             FIRST-OF(crawarq.dscooper)  THEN
             DO:
                 IF   crawarq.tparquiv = "TITULOS"  THEN
                      ASSIGN aux_tparquiv = crawarq.tparquiv
                             aux_dsarquiv = "ARQUIVO TITULOS COMPENSAVEIS".
                 ELSE
                 IF   crawarq.tparquiv = "COMPEL"  THEN
                      ASSIGN aux_tparquiv = crawarq.tparquiv
                             aux_dsarquiv = "ARQUIVO COMPENSACAO ELETRONICA".
                 ELSE
                 IF   crawarq.tparquiv = "DOCTOS"  THEN
                      ASSIGN aux_tparquiv = crawarq.tparquiv
                             aux_dsarquiv = "ARQUIVO DOCTOS".
                 ELSE
                 IF   crawarq.tparquiv = "DEVOLU"  THEN
                      ASSIGN aux_tparquiv = crawarq.tparquiv
                             aux_dsarquiv = "ARQUIVO DE DEVOLUCAO DE CHEQUES".
                 ELSE
                 IF   crawarq.tparquiv = "RELACIONAMENTO"  THEN
                      ASSIGN aux_tparquiv = crawarq.tparquiv
                             aux_dsarquiv = "ARQUIVO DE RELACIONAMENTO ICF".
                 ELSE
                 IF   crawarq.tparquiv = "CUSTODIA ESTOQ"  THEN
                      ASSIGN aux_tparquiv = crawarq.tparquiv
                             aux_dsarquiv = "ESTOQUE TOTAL DE CUSTODIA".
                 ELSE
                 IF   crawarq.tparquiv = "CUSTODIA COMPE"  THEN
                      ASSIGN aux_tparquiv = crawarq.tparquiv
                             aux_dsarquiv = "CHEQUES A COMPENSAR EM CUSTODIA".
                 ELSE
                 IF   crawarq.tparquiv = "TIC" THEN
                      ASSIGN aux_tparquiv = crawarq.tparquiv
                             aux_dsarquiv = "TIC - TROCA INFORM. DE CUSTODIA".
                 ELSE
                 IF   crawarq.tparquiv = "ICFJUD-604" THEN
                      ASSIGN aux_tparquiv = crawarq.tparquiv
                             aux_dsarquiv = "ICFJUD - REQUISICAO INFORMACOES".
                 ELSE
                 IF   crawarq.tparquiv = "ICFJUD-606" THEN
                      ASSIGN aux_tparquiv = crawarq.tparquiv
                             aux_dsarquiv = "ICFJUD - RESPOSTA INFORMACOES".
                 ELSE
                 IF   crawarq.tparquiv = "DEVSR085" THEN
                      ASSIGN aux_tparquiv = crawarq.tparquiv
                             aux_dsarquiv = "DEV COBRANCA - SUA REMESSA 085".                 
                 
                 CREATE w-arquivos.
                 ASSIGN w-arquivos.tparquiv = aux_tparquiv
                        w-arquivos.dsarquiv = aux_dsarquiv
                        w-arquivos.dscooper = crawarq.dscooper.
             END.
    END.

    RETURN "OK".
END PROCEDURE.

PROCEDURE verifica_arquivos:

    INPUT STREAM str_1 THROUGH VALUE("ls " + aux_nmarquiv + " 2> /dev/null")
          NO-ECHO.

    DO WHILE TRUE ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:
       
       SET STREAM str_1 aux_nmarquiv FORMAT "x(60)".
       
       /*** Verifica se o arquivo esta vazio e o remove ***/
       INPUT STREAM str_2 THROUGH VALUE("wc -m " + aux_nmarquiv + 
                                        " 2> /dev/null") NO-ECHO.

       SET STREAM str_2 aux_tamarqui FORMAT "x(30)".
             
       IF   INTEGER(SUBSTRING(aux_tamarqui,1,1)) = 0  THEN
            DO:
                INPUT STREAM str_2 CLOSE.
                NEXT.
            END.

       INPUT STREAM str_2 CLOSE.
                
       DO TRANSACTION:         
          CREATE crawarq.
          ASSIGN crawarq.dscooper = IF   aux_tparquiv = "RELACIONAMENTO" THEN
                                         "CECRED"
                                    ELSE crabcop.nmrescop
                 crawarq.tparquiv = aux_tparquiv
                 crawarq.nmarquiv = aux_nmarquiv.
       END.
    END.  /*  Fim do DO WHILE TRUE  */
    
    INPUT STREAM str_1 CLOSE.

    RETURN "OK".
END PROCEDURE.

PROCEDURE imp_arq:
    
    DEF INPUT PARAM par_cdcooper    AS  INTE                        NO-UNDO.
    DEF INPUT PARAM par_cdagenci    AS  INTE                        NO-UNDO.
    DEF INPUT PARAM par_nmprgexe    AS  CHAR                        NO-UNDO.
    DEF INPUT PARAM par_dtrefere    AS  DATE                        NO-UNDO.
    DEF OUTPUT PARAM par_dsmsgerr   AS  CHAR                        NO-UNDO.

    /* Criar solicitacao para estes tipos de programas */
    /*"RELACIONAMENTO,IMP CONTRA-ORDEM/CCF,CAF"*/
    IF  CAN-DO("IMP CONTRA-ORDEM/CCF,CAF", par_nmprgexe)  THEN
        DO:
           /*
            DO TRANSACTION:
                /* Limpa solicitacao se existente */
                FIND FIRST  crapsol WHERE 
                            crapsol.cdcooper = glb_cdcooper   AND 
                            crapsol.nrsolici = 200            AND
                            crapsol.dtrefere = glb_dtmvtolt   
                            NO-LOCK NO-ERROR.
    
                IF  AVAILABLE crapsol  THEN DO:
                    FIND CURRENT crapsol EXCLUSIVE-LOCK.
                    DELETE crapsol.
                END.                     

                CREATE crapsol. 
                ASSIGN crapsol.nrsolici = 200
                       crapsol.dtrefere = glb_dtmvtolt
                       crapsol.nrseqsol = 1
                       crapsol.cdempres = 11
                       crapsol.dsparame = ""
                       crapsol.insitsol = 1
                       crapsol.nrdevias = 0
                       crapsol.cdcooper = glb_cdcooper.
                VALIDATE crapsol.
            END. /* Fim TRANSACTION */                 
            */

            RUN cria_solicitacao(INPUT glb_cdcooper,
                                 INPUT glb_dtmvtolt,
                                 INPUT par_nmprgexe,
                                 INPUT 200, /*nrsolici*/
                                 INPUT 1).  /*nrseqsol*/
        END.
         


     CASE par_nmprgexe:
         /* comentado pois ainda nao entrou nesta fase do projeto
            mais pode vir a fazer parte
         WHEN "RELACIONAMENTO" THEN
         DO:
             /* executar o script que busca os arquivos */
             UNIX SILENT VALUE("/usr/local/cecred/bin/" +
                               "ftpabbc_recebe_icf_d.pl").
                               
             RUN fontes/crps556.p.
         END.  */

         WHEN "IMP CONTRA-ORDEM/CCF" THEN
         DO:
             RUN atualiza_status_execucao (INPUT par_nmprgexe,
                                           INPUT glb_dtmvtolt,
                                           INPUT par_cdcooper).

             IF  RETURN-VALUE = "NOK" THEN  DO:
                 RUN gera_log_execucao (INPUT par_nmprgexe + "(CRPS562)",
                                        INPUT "Inicio execucao", 
                                        INPUT par_cdcooper,
                                        INPUT "(TODAS)").
                 RUN fontes/crps562.p.
                 RUN gera_log_execucao (INPUT par_nmprgexe + "(CRPS562)",
                                        INPUT "Fim execucao", 
                                        INPUT par_cdcooper,
                                        INPUT "(TODAS)").
                 
                 RUN gera_log_execucao (INPUT par_nmprgexe + "(CRPS550)",
                                        INPUT "Inicio execucao", 
                                        INPUT par_cdcooper,
                                        INPUT "(TODAS)").
                 RUN fontes/crps550.p.
                 RUN gera_log_execucao (INPUT par_nmprgexe + "(CRPS550)",
                                        INPUT "Fim execucao", 
                                        INPUT par_cdcooper,
                                        INPUT "(TODAS)").
    
                 /* Valida se importou os arquivos, caso contrario nao devera
                   gravar data e hora da ultima execucao, pois o programa devera 
                   tentar importar novamente */ 
                 ASSIGN aux_nmarqslv = "/usr/coop/cecred/salvar/SER00005" +
                                       STRING(DAY(glb_dtmvtolt),"99") +
                                       STRING(MONTH(glb_dtmvtolt),"99") +
                                       STRING(YEAR(glb_dtmvtolt),"9999") +
                                       "*".
                 /* CONTRA-ORDEM */ 
                 RUN retorna_arquivo_importado (INPUT aux_nmarqslv).
                 IF   RETURN-VALUE = "OK" THEN
                      RUN grava_dthr_proc(INPUT par_cdcooper,
                                          INPUT glb_dtmvtolt,
                                          INPUT TIME,
                                          INPUT TRIM(par_nmprgexe)). 
                 ELSE
                      DO:
                          ASSIGN aux_nmarqslv = "/usr/coop/cecred/salvar/SER00004" +
                                                STRING(DAY(glb_dtmvtolt),"99") +
                                                STRING(MONTH(glb_dtmvtolt),"99") +
                                                STRING(YEAR(glb_dtmvtolt),"9999") +
                                                "*".
                           /* CCF */ 
                          RUN retorna_arquivo_importado (INPUT aux_nmarqslv).
                          IF   RETURN-VALUE = "OK" THEN
                               RUN grava_dthr_proc(INPUT par_cdcooper,
                                                   INPUT glb_dtmvtolt,
                                                   INPUT TIME,
                                                   INPUT TRIM(par_nmprgexe)). 
                      END.
                 /***** Fim da validacao de importacao do arquivo *********/
             END.
                      
         END.

         WHEN "CAF" THEN
         DO:  
             RUN atualiza_status_execucao (INPUT par_nmprgexe,
                                           INPUT glb_dtmvtolt,
                                           INPUT par_cdcooper).

             IF  RETURN-VALUE = "NOK" THEN  DO:
                 RUN gera_log_execucao (INPUT par_nmprgexe + "(FTP_recebe)",
                                        INPUT "Inicio execucao", 
                                        INPUT par_cdcooper,
                                        INPUT "(TODAS)").
                 /* executar o script que busca os arquivos */
                 UNIX SILENT VALUE("/usr/local/cecred/bin/" +
                                   "ftpabbc_recebe_caf_d.pl").
                                   
                 RUN gera_log_execucao (INPUT par_nmprgexe + "(FTP_recebe)",
                                        INPUT "Fim execucao", 
                                        INPUT par_cdcooper,
                                        INPUT "(TODAS)").
    
                 RUN gera_log_execucao (INPUT par_nmprgexe + "(CRPS564)",
                                        INPUT "Inicio execucao", 
                                        INPUT par_cdcooper,
                                        INPUT "(TODAS)").
                 RUN fontes/crps564.p. /* CAF501 */
                 RUN gera_log_execucao (INPUT par_nmprgexe + "(CRPS564)",
                                        INPUT "Fim execucao", 
                                        INPUT par_cdcooper,
                                        INPUT "(TODAS)").
                 
                 RUN gera_log_execucao (INPUT par_nmprgexe + "(CRPS565)",
                                        INPUT "Inicio execucao", 
                                        INPUT par_cdcooper,
                                        INPUT "(TODAS)").
                 RUN fontes/crps565.p. /* CAF502 */
                 RUN gera_log_execucao (INPUT par_nmprgexe + "(CRPS565)",
                                        INPUT "Fim execucao", 
                                        INPUT par_cdcooper,
                                        INPUT "(TODAS)").
    
                 /* Valida se importou os 2 arquivos, caso contrario nao devera
                   gravar data e hora da ultima execucao, pois o programa devera 
                   tentar importar novamente */ 
                 ASSIGN aux_nmarqslv = "/usr/coop/cecred/salvar/CAF501" +
                                       STRING(DAY(glb_dtmvtolt),"99") +
                                       STRING(MONTH(glb_dtmvtolt),"99") +
                                       STRING(YEAR(glb_dtmvtolt),"9999").
                     
                 /* CAF501 */ 
                 RUN retorna_arquivo_importado (INPUT aux_nmarqslv).
                 IF   RETURN-VALUE = "OK" THEN
                      DO:
                          ASSIGN aux_nmarqslv = "/usr/coop/cecred/salvar/CAF502" +
                                                STRING(DAY(glb_dtmvtolt),"99") +
                                                STRING(MONTH(glb_dtmvtolt),"99") +
                                                STRING(YEAR(glb_dtmvtolt),"9999").
    
                           /* CAF502 */ 
                          RUN retorna_arquivo_importado (INPUT aux_nmarqslv).
                          IF   RETURN-VALUE = "OK" THEN
                               RUN grava_dthr_proc(INPUT par_cdcooper,
                                                   INPUT glb_dtmvtolt,
                                                   INPUT TIME,
                                                   INPUT TRIM(par_nmprgexe)). 
                      END.
                 /***** Fim da validacao de importacao do arquivo *********/
             END.
         END.    

         WHEN "ICF" THEN DO:

             RUN atualiza_status_execucao (INPUT par_nmprgexe,
                                           INPUT glb_dtmvtolt,
                                           INPUT par_cdcooper).

             IF  RETURN-VALUE = "NOK" THEN  DO:

                 aux_dsarquiv = 
                      "ICF614" + STRING(DAY(glb_dtmvtoan),"99") + ".RET," +
                      "ICF616" + STRING(DAY(glb_dtmvtoan),"99") + ".RET," +
                      "ICF674" + STRING(DAY(glb_dtmvtoan),"99") + ".RET," +
                      "ICF676" + STRING(DAY(glb_dtmvtoan),"99") + ".RET".
                 
                 RUN gera_log_execucao (INPUT par_nmprgexe + "(ftpabbc_ICF.pl)",
                                        INPUT "Inicio execucao", 
                                        INPUT par_cdcooper,
                                        INPUT "(TODAS)").
    
                 IF  OS-GETENV("PKGNAME") = "pkgprod" OR 
                     OS-GETENV("PKGNAME") = "PKGPROD" THEN
                     UNIX SILENT VALUE(
                          "/usr/local/cecred/bin/ftpabbc_ICF.pl -recebe " +
                          "-srv transabbc -usr 085 -pass cbba085 " +
                          "-arq '" + STRING(aux_dsarquiv,"x(51)") + "' " +
                          "-dir_local /usr/coop/cecred/integra " +
                          "-dir_remoto /ICF").
    
                 RUN gera_log_execucao (INPUT par_nmprgexe + "(ftpabbc_ICF.pl)",
                                        INPUT "Fim execucao", 
                                        INPUT par_cdcooper,
                                        INPUT "(TODAS)").
    
                 /* Instancia a BO */
                 RUN sistema/generico/procedures/b1wgen0154.p 
                     PERSISTENT SET h-b1wgen0154.
    
                 IF   NOT VALID-HANDLE(h-b1wgen0154)  THEN
                      DO:
                        glb_nmdatela = "PRCCTL".
                        ASSIGN glb_dscritic = "Handle invalido para BO b1wgen0154.".
                        RUN gera_critica_procmessage.
                        RETURN "NOK".
                      END.
    
                 
                 RUN gera_log_execucao (INPUT par_nmprgexe + "(ICF616)",
                                        INPUT "Inicio execucao", 
                                        INPUT par_cdcooper,
                                        INPUT "(TODAS)").     
                 /* IMPORTAR 616 */
                 RUN importar_icf616 IN h-b1wgen0154(INPUT  glb_dtmvtolt,
                                                     INPUT  glb_dtmvtoan,
                                                     OUTPUT par_dsmsgerr).
    
                 IF  par_dsmsgerr <> "" THEN DO:
                     ASSIGN glb_dscritic = "ICF616 - " + par_dsmsgerr.
                     RUN gera_critica_procmessage.
                 END.
    
                 RUN gera_log_execucao (INPUT par_nmprgexe + "(ICF616)",
                                        INPUT "Fim execucao", 
                                        INPUT par_cdcooper,
                                        INPUT "(TODAS)"). 
    
                 ASSIGN par_dsmsgerr = " ".
                 
                 RUN gera_log_execucao (INPUT par_nmprgexe + "(ICF614)",
                                        INPUT "Inicio execucao", 
                                        INPUT par_cdcooper,
                                        INPUT "(TODAS)"). 
    
                 /* IMPORTAR 614 - GERAR 606 */
                 RUN importar_icf614 IN h-b1wgen0154(INPUT  glb_cdcooper,
                                                     INPUT  glb_dtmvtolt,
                                                     INPUT  glb_dtmvtoan,
                                                     INPUT  glb_cdoperad,
                                                     OUTPUT par_dsmsgerr).
    
                 IF  par_dsmsgerr <> "" THEN DO:
                     ASSIGN glb_dscritic = "ICF614 - " + par_dsmsgerr.
                     RUN gera_critica_procmessage.
                 END.
    
                 RUN gera_log_execucao (INPUT par_nmprgexe + "(ICF614)",
                                        INPUT "Fim execucao", 
                                        INPUT par_cdcooper,
                                        INPUT "(TODAS)"). 
    
                 ASSIGN par_dsmsgerr = " ".
    
                 RUN gera_log_execucao (INPUT par_nmprgexe + "(ICF674)",
                                        INPUT "Inicio execucao", 
                                        INPUT par_cdcooper,
                                        INPUT "(TODAS)"). 
                 /* IMPORTAR 674 */
                 RUN icf_validar_retorno
                     IN h-b1wgen0154(INPUT "ICF674",
                                     INPUT glb_dtmvtolt,
                                     INPUT glb_dtmvtoan,
                                     OUTPUT par_dsmsgerr).
    
                 IF  par_dsmsgerr <> "" THEN DO:
                     ASSIGN glb_dscritic = "ICF674 - " + par_dsmsgerr.
                     RUN gera_critica_procmessage.
                 END.
    
                 RUN gera_log_execucao (INPUT par_nmprgexe + "(ICF674)",
                                        INPUT "Fim execucao", 
                                        INPUT par_cdcooper,
                                        INPUT "(TODAS)"). 
    
                 ASSIGN par_dsmsgerr = " ".
    
                 RUN gera_log_execucao (INPUT par_nmprgexe + "(ICF676)",
                                        INPUT "Inicio execucao", 
                                        INPUT par_cdcooper,
                                        INPUT "(TODAS)"). 
                 /* IMPORTAR 676 */
                 RUN icf_validar_retorno
                     IN h-b1wgen0154(INPUT "ICF676",
                                     INPUT glb_dtmvtolt,
                                     INPUT glb_dtmvtoan,
                                     OUTPUT par_dsmsgerr).
    
                 IF  par_dsmsgerr <> "" THEN DO:
                     ASSIGN glb_dscritic = "ICF676 - " + par_dsmsgerr.
                     RUN gera_critica_procmessage.
                 END.
    
                 RUN gera_log_execucao (INPUT par_nmprgexe + "(ICF676)",
                                        INPUT "Fim execucao", 
                                        INPUT par_cdcooper,
                                        INPUT "(TODAS)"). 
    
                 DELETE PROCEDURE h-b1wgen0154.
    
                 /* Valida se importou os arquivos, caso contrario nao devera
                   gravar data e hora da ultima execucao, pois o programa devera 
                   tentar importar novamente */ 
                 ASSIGN aux_nmarqslv = "/usr/coop/cecred/salvar/ICF*" +
                                       STRING(DAY(glb_dtmvtoan),"99") + ".RET".
    
                 /* ICF */ 
                 RUN retorna_arquivo_importado (INPUT aux_nmarqslv).
                 IF   RETURN-VALUE = "OK" THEN
                      RUN grava_dthr_proc(INPUT par_cdcooper,
                                          INPUT glb_dtmvtolt,
                                          INPUT TIME,
                                          INPUT TRIM(par_nmprgexe)). 
                 /***** Fim da validacao de importacao do arquivo *********/
             END.
         END.

         WHEN "IMPORTACAO FAC/ROC" THEN DO:

             RUN atualiza_status_execucao (INPUT par_nmprgexe,
                                           INPUT glb_dtmvtolt,
                                           INPUT par_cdcooper).

             IF  RETURN-VALUE = "NOK" THEN  DO:
             
                 /* criar solicitacao para FAC/ROC */
                 DO  TRANSACTION:
                     /* Limpa solicitacao se existente */
                     FIND FIRST crapsol WHERE 
                                crapsol.cdcooper = glb_cdcooper AND 
                                crapsol.nrsolici = 1            AND
                                crapsol.dtrefere = glb_dtmvtolt   
                                NO-LOCK NO-ERROR.
    
                     IF  AVAILABLE crapsol  THEN DO:
                         FIND CURRENT crapsol EXCLUSIVE-LOCK.
                         DELETE crapsol.
                     END.                     
                     
                     CREATE crapsol. 
                     ASSIGN crapsol.nrsolici = 1
                            crapsol.dtrefere = glb_dtmvtolt
                            crapsol.nrseqsol = 1
                            crapsol.cdempres = 11
                            crapsol.dsparame = ""
                            crapsol.insitsol = 1
                            crapsol.nrdevias = 0
                            crapsol.cdcooper = glb_cdcooper.
                     VALIDATE crapsol.
                 END. /* Fim TRANSACTION */   
    
                 ASSIGN glb_nmdatela = "PRCCTL"
                        glb_nmtelant = "PRCCTL".
    
                 /* executar o script que busca os arquivos */
                 IF  OS-GETENV("PKGNAME") = "pkgprod" OR 
                     OS-GETENV("PKGNAME") = "PKGPROD" THEN
                     UNIX SILENT VALUE("/usr/local/cecred/bin/" +
                                       "ftpabbc_recebe_facroc_d.pl").  
                                           
                 RUN gera_log_execucao (INPUT par_nmprgexe + "(FAC)",
                                        INPUT "Inicio execucao", 
                                        INPUT par_cdcooper,
                                        INPUT "(CECRED)"). 
                 /* Executa FAC */
                 RUN fontes/crps543.p.
    
                 RUN gera_log_execucao (INPUT par_nmprgexe + "(FAC)",
                                        INPUT "Fim execucao", 
                                        INPUT par_cdcooper,
                                        INPUT "(CECRED)").

                 RUN gera_log_execucao (INPUT par_nmprgexe + "(ROC)",
                                        INPUT "Inicio execucao", 
                                        INPUT par_cdcooper,
                                        INPUT "(CECRED)").
                 /* Executa ROC */
                 RUN fontes/crps544.p.
    
                 RUN gera_log_execucao (INPUT par_nmprgexe + "(ROC)",
                                        INPUT "Fim execucao", 
                                        INPUT par_cdcooper,
                                        INPUT "(CECRED)").
    
                 /* Limpa solicitacao se existente */
                 DO  TRANSACTION:
                     FIND FIRST crapsol WHERE 
                                crapsol.cdcooper = glb_cdcooper  AND 
                                crapsol.nrsolici = 1             AND
                                crapsol.dtrefere = glb_dtmvtolt   
                                NO-LOCK NO-ERROR.
    
                     IF  AVAILABLE crapsol  THEN DO:
                         FIND CURRENT crapsol EXCLUSIVE-LOCK.
                         DELETE crapsol.
                     END.             
                 END. /* Fim do TRANSACTION */
    
                 /* Valida se importou os arquivos, caso contrario nao devera
                   gravar data e hora da ultima execucao, pois o programa devera 
                   tentar importar novamente */ 
                 ASSIGN aux_nmarqslv = "/usr/coop/cecred/salvar/FAC640D9." +
                                       STRING(crapcop.cdbcoctl,"999") + 
                                       "-" + 
                                       STRING(YEAR(glb_dtmvtolt),"9999") +
                                       STRING(MONTH(glb_dtmvtolt),"99") +
                                       STRING(DAY(glb_dtmvtolt),"99").
    
                 /* FAC */ 
                 RUN retorna_arquivo_importado (INPUT aux_nmarqslv).
                 IF   RETURN-VALUE = "OK" THEN
                      RUN grava_dthr_proc(INPUT par_cdcooper,
                                          INPUT glb_dtmvtolt,
                                          INPUT TIME,
                                          INPUT TRIM(par_nmprgexe)). 
                 ELSE
                      DO:
                          ASSIGN aux_nmarqslv = 
                                       "/usr/coop/cecred/salvar/ROC640D9." +
                                       STRING(crapcop.cdbcoctl,"999") + 
                                       "-" + 
                                       STRING(YEAR(glb_dtmvtolt),"9999") +
                                       STRING(MONTH(glb_dtmvtolt),"99") +
                                       STRING(DAY(glb_dtmvtolt),"99").
                           /* ROC */ 
                          RUN retorna_arquivo_importado (INPUT aux_nmarqslv).
                          IF   RETURN-VALUE = "OK" THEN
                               RUN grava_dthr_proc(INPUT par_cdcooper,
                                                   INPUT glb_dtmvtolt,
                                                   INPUT TIME,
                                                   INPUT TRIM(par_nmprgexe)). 
                      END.
             END.   
         END.
         WHEN "REMESSA TITULOS PG" THEN DO:

             RUN gera_log_execucao (INPUT par_nmprgexe,
                                    INPUT "Inicio execucao", 
                                    INPUT par_cdcooper,
                                    INPUT "").

             RUN proc_remessa_tit_pg(INPUT par_cdcooper).

             RUN gera_log_execucao (INPUT par_nmprgexe,
                                    INPUT "Fim execucao", 
                                    INPUT par_cdcooper,
                                    INPUT "").

         END.
         WHEN "RETORNO TITULOS PG" THEN DO:

             RUN gera_log_execucao (INPUT par_nmprgexe,
                                    INPUT "Inicio execucao", 
                                    INPUT par_cdcooper,
                                    INPUT "").

             RUN proc_retorno_tit_pg(INPUT par_cdcooper).

             RUN gera_log_execucao (INPUT par_nmprgexe,
                                    INPUT "Fim execucao", 
                                    INPUT par_cdcooper,
                                    INPUT "").

         END.


     END CASE.

     /* Criar solicitacao para estes tipos de programas */
     /* RELACIONAMENTO,CCF,CONTRA-ORDEM,CAF */
     IF  CAN-DO("CCF,CONTRA-ORDEM,CAF",
                par_nmprgexe)  THEN
         DO:
            RUN limpa_solicitacao(INPUT glb_cdcooper,
                                  INPUT glb_dtmvtolt,
                                  INPUT par_nmprgexe,
                                  INPUT 200, /*nrsolici*/
                                  INPUT 1).  /*nrseqsol*/

         END.

     RETURN "OK".
END PROCEDURE.

/* grava data e hora de processamento de um arquivo na craphec
   na cooperativa em que foi rodado */
PROCEDURE grava_dthr_proc:

    DEF INPUT PARAM par_cdcooper    AS  INTE                            NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt    AS  DATE                            NO-UNDO.
    DEF INPUT PARAM par_hrultexc    AS  INTE                            NO-UNDO.
    DEF INPUT PARAM par_nmprgexe    AS  CHAR                            NO-UNDO.

    FIND craphec WHERE craphec.cdcooper = par_cdcooper AND
                       craphec.dsprogra = par_nmprgexe
                       EXCLUSIVE-LOCK NO-ERROR.

    IF  AVAIL(craphec) THEN
        DO:
            ASSIGN craphec.dtultexc = par_dtmvtolt
                   craphec.hrultexc = par_hrultexc.
        END.

    VALIDATE craphec.

    RETURN "OK".
END PROCEDURE.

/* Pega mensagem que esta no glb_dscritic e grava no pro_cbatch.log */
PROCEDURE gera_critica_procbatch:

    UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                      " - crps662 " + "' --> '"  +
                      glb_dscritic + " >> log/proc_batch.log").
    RETURN "OK".

END PROCEDURE.

/* Pega mensagem que esta no glb_dscritic e grava no proc_message.log */
PROCEDURE gera_critica_procmessage:

    UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                      " - crps662 " + "' --> '"  +
                      glb_dscritic + " >> log/proc_message.log").
    RETURN "OK".

END PROCEDURE.

/* LOG de execuaco dos programas */
PROCEDURE gera_log_execucao:

    DEF INPUT PARAM par_nmprgexe    AS  CHAR        NO-UNDO.
    DEF INPUT PARAM par_indexecu    AS  CHAR        NO-UNDO.
    DEF INPUT PARAM par_cdcooper    AS  INT         NO-UNDO.
    DEF INPUT PARAM par_tpexecuc    AS  CHAR        NO-UNDO.
    
    DEF VAR aux_nmarqlog            AS  CHAR        NO-UNDO.

    ASSIGN aux_nmarqlog = "log/prcctl_" + STRING(YEAR(glb_dtmvtolt),"9999") +
                          STRING(MONTH(glb_dtmvtolt),"99") +
                          STRING(DAY(glb_dtmvtolt),"99") + ".log".
    
    UNIX SILENT VALUE("echo " + "Automatizado - " + 
                      STRING(TIME,"HH:MM:SS") + "' --> '"  +
                      "Coop.:" + STRING(par_cdcooper) + " '" +  
                      par_tpexecuc + "' - '" + 
                      par_nmprgexe + "': " + 
                      par_indexecu +  
                      " >> " + aux_nmarqlog).

    RETURN "OK".  
END PROCEDURE.



PROCEDURE atualiza_status_execucao:

    DEF INPUT PARAM par_dsprogra    AS  CHAR    NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt    AS  DATE    NO-UNDO.
    DEF INPUT PARAM par_cdcooper    AS  INT     NO-UNDO.

    FIND FIRST craphec WHERE craphec.dsprogra = par_dsprogra 
                         AND craphec.dtultexc = par_dtmvtolt
                                            NO-LOCK NO-ERROR.

    IF   AVAIL(craphec) THEN  
         DO:
             FIND FIRST b-craphec WHERE 
                        b-craphec.cdcooper = par_cdcooper  AND
                        b-craphec.dsprogra = par_dsprogra 
                        EXCLUSIVE-LOCK NO-ERROR.

             IF   AVAIL b-craphec THEN
                  ASSIGN b-craphec.dtultexc = craphec.dtultexc
                         b-craphec.hrultexc = craphec.hrultexc.

             RETURN "OK".
        
         END.
    ELSE
         RETURN "NOK".

END PROCEDURE.


PROCEDURE retorna_arquivo_importado:
     
  DEF INPUT PARAM par_nmarquiv AS CHAR    NO-UNDO.

  DEF VAR aux_nmarqint AS CHAR      NO-UNDO.
    
  INPUT STREAM str_5 
        THROUGH VALUE("ls " + par_nmarquiv + " 2> /dev/null") NO-ECHO.

   DO WHILE TRUE ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:
           
      SET STREAM str_5 aux_nmarqint FORMAT "x(60)" .
      LEAVE.

   END.   

   IF   aux_nmarqint <> "" THEN
        RETURN "OK".
   ELSE
        RETURN "NOK".

END PROCEDURE.

PROCEDURE gera_relatorios:

  DEF INPUT PARAM par_cdcooper AS INT                       NO-UNDO.
  DEF INPUT PARAM par_cdagenci AS INT                       NO-UNDO.
  DEF INPUT PARAM par_dtrefere AS DATE                      NO-UNDO.
  DEF INPUT PARAM par_nmprgexe AS CHAR                      NO-UNDO.

  DEF         VAR aux_lgparam1 AS LOG            NO-UNDO.
  DEF         VAR aux_lgparam2 AS LOG            NO-UNDO.

  EMPTY TEMP-TABLE crawage.

  /*carrega tabela de agencias*/
  FOR EACH crapage WHERE 
           crapage.cdcooper = INT(par_cdcooper) NO-LOCK:
      CREATE crawage.
      ASSIGN crawage.cdcooper = crapage.cdcooper
             crawage.cdagenci = crapage.cdagenci
             crawage.nmresage = crapage.nmresage
             crawage.cdcomchq = crapage.cdcomchq
             crawage.cdbantit = crapage.cdbantit
             crawage.cdbandoc = crapage.cdbandoc
             crawage.nmcidade = crapage.nmcidade 
             crawage.cdagecbn = crapage.cdagecbn
             crawage.cdbanchq = crapage.cdbanchq.
  END.                          
  /*fim carrega tabela*/

  ASSIGN aux_lgparam1 = TRUE
         aux_lgparam2 = TRUE.
 /*param2: ao chegar nesse ponto o flgenvio da tabela
           ja foi alterado para TRUE, porem no programa
           original, ele somente alterava para TRUE apos
           a emissao do relatorio */

  FIND crabcop WHERE crabcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.
  
  IF par_nmprgexe = "DOCTOS" THEN
      DO ON STOP UNDO, LEAVE:

        UNIX SILENT VALUE ("rm /micros/cecred/compel/O326_" + 
                           STRING(crabcop.cdagectl,"9999") + "* 2> /dev/null"). 

        RUN fontes/prcctl_rd.p (INPUT par_cdcooper,
                                INPUT par_dtrefere, 
                                INPUT par_cdagenci,
                                INPUT aux_lgparam2,   
                                INPUT "D",
                                INPUT " ",
                                INPUT TABLE crawage,
                                INPUT FALSE). /* Nao imprime */ 
        PAUSE 1 NO-MESSAGE.
      END.
  ELSE
  IF par_nmprgexe = "COMPEL" THEN 
      DO ON STOP UNDO, LEAVE:

         UNIX SILENT VALUE ("rm /micros/cecred/compel/crrl262_" +
                            STRING(crabcop.cdagectl,"9999") + "* 2> /dev/null").

         RUN fontes/prcctl_rc.p(INPUT par_cdcooper,
                                INPUT par_dtrefere,
                                INPUT par_cdagenci,
                                INPUT 0,
                                INPUT 0,
                                INPUT aux_lgparam1,
                                INPUT TABLE crawage,
                                INPUT aux_lgparam2,
                                INPUT aux_lgparam2,
                                INPUT FALSE). /* Nao imprime */
         PAUSE 1 NO-MESSAGE.
      END.
  ELSE
  IF par_nmprgexe = "TITULO" THEN
      DO ON STOP UNDO, LEAVE:

        IF  par_cdagenci <> 90 AND
            par_cdagenci <> 91 THEN
            DO:
                UNIX SILENT VALUE ("rm /micros/cecred/compel/O239_" + 
                                   STRING(crabcop.cdagectl,"9999") + 
                                   "* 2> /dev/null").
            END.

        RUN fontes/prcctl_rt.p (INPUT par_cdcooper,
                                INPUT par_dtrefere,
                                INPUT par_cdagenci,
                                INPUT 0,
                                INPUT 0,
                                INPUT aux_lgparam1,
                                INPUT TABLE crawage,
                                INPUT aux_lgparam2,
                                INPUT aux_lgparam2,
                                INPUT FALSE). /* Nao imprime */
        PAUSE 1 NO-MESSAGE.
      END.

END PROCEDURE.

PROCEDURE proc_remessa_tit_pg:
         
    DEF INPUT PARAM par_cdcooper    AS  INTE                        NO-UNDO.

    ETIME(TRUE).

    { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }

    RUN STORED-PROCEDURE pc_crps693 aux_handproc = PROC-HANDLE NO-ERROR
           (INPUT par_cdcooper,
            INPUT  0,
            OUTPUT 0,
            OUTPUT 0,
            OUTPUT 0, 
            OUTPUT "").

    IF  ERROR-STATUS:ERROR  THEN DO:
        DO  aux_qterrora = 1 TO ERROR-STATUS:NUM-MESSAGES:
            ASSIGN aux_msgerora = aux_msgerora + 
                                  ERROR-STATUS:GET-MESSAGE(aux_qterrora) + " ".
        END.

        UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                          " - " + glb_cdprogra + "' --> '"  +
                          "Erro ao executar Stored Procedure: '" +
                          aux_msgerora + "' >> log/proc_batch.log").
        RETURN.
    END.

    CLOSE STORED-PROCEDURE pc_crps693 WHERE PROC-HANDLE = aux_handproc.

    { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

    UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS")    + 
                      " - "   + glb_cdprogra + "' --> '"   +
                      "Stored Procedure rodou em "         + 
                      STRING(INT(ETIME / 1000),"HH:MM:SS") + 
                      " >> log/proc_batch.log").

    RETURN "OK".

END PROCEDURE.


PROCEDURE proc_retorno_tit_pg:
         
    DEF INPUT PARAM par_cdcooper    AS  INTE                        NO-UNDO.

    ETIME(TRUE).

    { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }

    RUN STORED-PROCEDURE pc_crps694 aux_handproc = PROC-HANDLE NO-ERROR
           (INPUT par_cdcooper,
            INPUT  0,
            OUTPUT 0,
            OUTPUT 0,
            OUTPUT 0, 
            OUTPUT "").

    IF  ERROR-STATUS:ERROR  THEN DO:
        DO  aux_qterrora = 1 TO ERROR-STATUS:NUM-MESSAGES:
            ASSIGN aux_msgerora = aux_msgerora + 
                                  ERROR-STATUS:GET-MESSAGE(aux_qterrora) + " ".
        END.

        UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                          " - " + glb_cdprogra + "' --> '"  +
                          "Erro ao executar Stored Procedure: '" +
                          aux_msgerora + "' >> log/proc_batch.log").
        RETURN.
    END.

    CLOSE STORED-PROCEDURE pc_crps694 WHERE PROC-HANDLE = aux_handproc.

    { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

    UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS")    + 
                      " - "   + glb_cdprogra + "' --> '"   +
                      "Stored Procedure rodou em "         + 
                      STRING(INT(ETIME / 1000),"HH:MM:SS") + 
                      " >> log/proc_batch.log").

    RETURN "OK".

END PROCEDURE.
