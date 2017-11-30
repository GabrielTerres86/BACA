/* ..............................................................................

Procedure: inicializa_dispositivo.p 
Objetivo : Inicializar os dispositivos
Autor    : Evandro
Data     : Janeiro 2010


Ultima alteração: 15/10/2010 - Ajustes para TAA compartilhado (Evandro).

                  07/10/2014 - Incluir variavel xfs_imppapelsaida para 
				               identificar se existe papel no sensor de saida
							   da impressora (David).
                               
                  27/08/2015 - Detalhamento de log na inicialização do TAA
                               Lucas Lunelli (SD 291639)
                               
                 29/12/2015 - Composição da linha de log para monitoração
                              via Nagios (Lunelli - SD 359409)

............................................................................... */

DEFINE  INPUT PARAMETER par_cdoperac    AS INT                  NO-UNDO.
DEFINE OUTPUT PARAMETER par_flgderro    AS LOGICAL  INIT NO     NO-UNDO.

{ includes/var_taa.i }
{ includes/var_xfs_lite.i }


/* Operação 1 - Abrir Dispensador */
IF  par_cdoperac = 1  THEN
    DO:
        DEFINE VARIABLE cnt_retorno     AS MEMPTR   NO-UNDO.
        DEFINE VARIABLE cnt_detalhe     AS INT      NO-UNDO.
        DEFINE VARIABLE cnt_present     AS INT      NO-UNDO.
        DEFINE VARIABLE cnt_conta       AS INT      NO-UNDO.
        
        ASSIGN SET-SIZE(cnt_retorno)   = 2
               PUT-BYTE(cnt_retorno,1) = 0
               PUT-BYTE(cnt_retorno,2) = 0.
        
        DO  cnt_conta = 1 TO 2:
           
            LT_resp = 0.       
           
            RUN WinIniciaContador IN aux_xfsliteh 
                (INPUT GET-POINTER-VALUE(cnt_retorno), OUTPUT LT_Resp).
        
            ASSIGN cnt_detalhe = GET-BYTE(cnt_retorno,1)
                   cnt_present = GET-BYTE(cnt_retorno,2).
        
            IF  LT_Resp = 0  THEN
                DO:
                    IF  cnt_detalhe = 0  THEN
                        DO:
                            IF  cnt_present = 0  THEN
                                xfs_dispensador = TRUE.
                            ELSE
                                xfs_dispensador = FALSE.
                        END.
                    ELSE
                        xfs_dispensador = FALSE.
                END.
            ELSE  
                xfs_dispensador = FALSE.
        
            IF  xfs_dispensador  THEN
                LEAVE.
        
        END.  /*  Fim do DO .. TO  */
        
        IF  xfs_dispensador  THEN
            par_flgderro = NO.
        ELSE
            par_flgderro = YES.
        
        SET-SIZE(cnt_retorno) = 0.

        RUN procedures/grava_log.p (INPUT "DISPENSADOR - RETORNO:" + STRING(LT_Resp) + " - DETALHE:" + STRING(cnt_detalhe) + " P32CONTA.DLL (WinIniciaContador)").
    END.
/* Fim Operação 1 - Abrir Dispensador */
ELSE

/* Operação 2 - Verificar Cassetes */
IF  par_cdoperac = 2  THEN
    DO:
        DEFINE VARIABLE v_status_contador   AS MEMPTR   NO-UNDO.
        DEFINE VARIABLE aux_qtcassetes      AS INT      NO-UNDO.
        DEFINE VARIABLE aux_contador        AS INT      NO-UNDO.
        DEFINE VARIABLE aux_contak7         AS INT      NO-UNDO.
        
        SET-SIZE(v_status_contador) = 19.
        
        PUT-BYTE(v_status_contador,01) = 0. /* Status detalhado do contador */
        PUT-BYTE(v_status_contador,02) = 0. /* Status do cassete A */
        PUT-BYTE(v_status_contador,03) = 0. /* Status do cassete B */
        PUT-BYTE(v_status_contador,04) = 0. /* Status do cassete C */
        PUT-BYTE(v_status_contador,05) = 0. /* Status do cassete D */
        PUT-BYTE(v_status_contador,06) = 0. /* Status da caixa de rejeição */
        PUT-BYTE(v_status_contador,07) = 0. /* Status dos sensores de contagem */
        PUT-BYTE(v_status_contador,08) = 0. /* Status detalhado do presenter */
        PUT-BYTE(v_status_contador,09) = 0. /* Status do alimentador 1 */
        PUT-BYTE(v_status_contador,10) = 0. /* Status do alimentador 2 */
        PUT-BYTE(v_status_contador,11) = 0. /* Status do alimentador 3 */
        PUT-BYTE(v_status_contador,12) = 0. /* Status do alimentador 4 */
        PUT-BYTE(v_status_contador,13) = 0. /* Status do Xport Sensor */
        PUT-BYTE(v_status_contador,14) = 0. /* Status da bandeja */
        PUT-BYTE(v_status_contador,15) = 0. /* Status da posicao do CAM */
        PUT-BYTE(v_status_contador,16) = 0. /* Status do sensor de saída */
        PUT-BYTE(v_status_contador,17) = 0. /* Status do shutter */
        PUT-BYTE(v_status_contador,18) = 0. /* Status do push plate */
        PUT-BYTE(v_status_contador,19) = 0. /* Status do trap */
        
        DO  WHILE TRUE:
           
            RUN WinStatusContador IN aux_xfsliteh 
                (INPUT GET-POINTER-VALUE(v_status_contador), OUTPUT LT_Resp).
            
            IF  LT_Resp <> 0  THEN
                DO:
                    ASSIGN xfs_dispensador = FALSE
                           glb_cassetes    = FALSE
                           par_flgderro    = YES.


                    RUN procedures/grava_log.p (INPUT "CONTADOR - RETORNO: " + STRING(LT_Resp) + " P32CONTA.DLL (WinStatusContador)").

                    SET-SIZE(v_status_contador) = 0.
                    RETURN.
                END.

            LEAVE.
        END.  /*  Fim do DO WHILE TRUE  */
        
        ASSIGN glb_cassetes   = FALSE
               aux_qtcassetes = 0.
        
        IF   GET-BYTE(v_status_contador,1) <> 0   THEN
             DO:
                 ASSIGN glb_cassetes    = FALSE
                        xfs_dispensador = FALSE
                        par_flgderro    = YES.

                 
                 RUN procedures/grava_log.p (INPUT "CONTADOR - DETALHE: " + STRING(GET-BYTE(v_status_contador,1)) + " P32CONTA.DLL (WinStatusContador)").
                 
                 SET-SIZE(v_status_contador) = 0.
                 RETURN.
             END.
        
        DO  aux_contak7 = 2 TO 5:
        
            IF  GET-BYTE(v_status_contador,aux_contak7) = 50  THEN 
                glb_cassetes[aux_contak7 - 1] = FALSE.
            ELSE 
            IF  sis_cassetes[aux_contak7 - 1] = TRUE  THEN
                ASSIGN glb_cassetes[aux_contak7 - 1] = TRUE
                       aux_qtcassetes = aux_qtcassetes + 1.
                      
        END.  /*  Fim do DO .. TO  */


        IF  GET-BYTE(v_status_contador,6) = 49  OR    /* K7R Cheio */
            GET-BYTE(v_status_contador,6) = 50  THEN  /* K7R Nao Encontrado */
            DO:
                ASSIGN glb_cassetes[5] = FALSE
                       xfs_dispensador = FALSE
                       par_flgderro    = YES.

                RUN procedures/grava_log.p (INPUT "CONTADOR - PROBLEMAS NO K7R - P32CONTA.DLL (WinStatusContador)").
        
                SET-SIZE(v_status_contador) = 0.
                RETURN.
            END.
        ELSE
            ASSIGN glb_cassetes[5] = YES
                   xfs_dispensador = YES.
   
        
        /* sem cassetes no contador */
        IF  aux_qtcassetes = 0   THEN
            DO:
                ASSIGN xfs_dispensador = FALSE
                       glb_cassetes    = FALSE
                       par_flgderro    = YES.
                 
                RUN procedures/grava_log.p (INPUT "CONTADOR - SEM CASSETES - P32CONTA.DLL (WinStatusContador)").
                
                SET-SIZE(v_status_contador) = 0.
                RETURN.
            END.
        
        par_flgderro = NO.
        SET-SIZE(v_status_contador) = 0.

        RUN procedures/grava_log.p (INPUT "CONTADOR - CASSETE A: " + STRING(glb_cassetes[1],"OK/NOK") + " P32CONTA.DLL (WinStatusContador)").
        RUN procedures/grava_log.p (INPUT "CONTADOR - CASSETE B: " + STRING(glb_cassetes[2],"OK/NOK") + " P32CONTA.DLL (WinStatusContador)").
        RUN procedures/grava_log.p (INPUT "CONTADOR - CASSETE C: " + STRING(glb_cassetes[3],"OK/NOK") + " P32CONTA.DLL (WinStatusContador)").
        RUN procedures/grava_log.p (INPUT "CONTADOR - CASSETE D: " + STRING(glb_cassetes[4],"OK/NOK") + " P32CONTA.DLL (WinStatusContador)").
    END.
/* Fim Operação 2 - Verificar Cassetes */
ELSE

/* Operação 3 - Abrir Depositário */
IF  par_cdoperac = 3  THEN
    DO:
        /* Sem Depositário */
        IF  glb_tpenvelo = 0  THEN
            par_flgderro = NO.
        ELSE
        /* Depositário Interbold - Matricial */
        IF  glb_tpenvelo = 1  THEN
            DO:
                DEFINE VARIABLE ErroDep     AS MEMPTR   NO-UNDO.
                
                ASSIGN SET-SIZE(ErroDep)   = 1
                       PUT-BYTE(ErroDep,1) = 0.
                
                LT_resp = 0.       
                
                RUN WinIniciaDepIbold IN aux_xfsliteh 
                      (INPUT GET-POINTER-VALUE(ErroDep), OUTPUT LT_Resp).
                
                ASSIGN cnt_detalhe = GET-BYTE(ErroDep,1).
                
                IF  LT_resp = 0  THEN
                    ASSIGN xfs_envelope = TRUE
                           par_flgderro = NO.
                ELSE
                    ASSIGN xfs_envelope = FALSE
                           par_flgderro = YES.
                
                SET-SIZE(ErroDep) = 0.
            END.
        ELSE
        /* Depositário Pentasys - Jato de Tinta */
        IF  glb_tpenvelo = 2  THEN
            DO:
                ASSIGN LT_resp     = 0
                       cnt_detalhe = 0.
    
                RUN WinIniciaDepositario IN aux_xfsliteh 
                    (INPUT 20, 
                     INPUT 20,
                     INPUT 1,
                     INPUT 1,
                     OUTPUT LT_Resp,
                     OUTPUT cnt_detalhe).   
    
                 IF  LT_resp = 0  THEN
                     ASSIGN xfs_envelope = TRUE
                            par_flgderro = NO.
                 ELSE
                     ASSIGN xfs_envelope = FALSE
                            par_flgderro = YES.
            END.
        ELSE
            par_flgderro = YES.


        RUN procedures/grava_log.p (INPUT "DEPOSITARIO - RETORNO:" + STRING(LT_Resp) + " - DETALHE:" + STRING(cnt_detalhe) + " P32DEPIB.DLL" + IF  glb_tpenvelo = 1  THEN " (WinIniciaDepIbold)" ELSE " (WinIniciaDepositario)" ).
    END.
/* Fim Operação 3 - Abrir Depositário */
ELSE

/* Operação 4 - Verificar Leitora de Cartão */
IF  par_cdoperac = 4  THEN
    DO:
        /* Sempre inicializa a leitora DIP mesmo se a máquina
           for leitora de PASSAGEM devido a criptografia */
        DEFINE VARIABLE modeloleitor    AS INT      NO-UNDO.
            
        LT_resp = 0.
                
        RUN WinIniciaLDIP IN aux_xfsliteh 
            (3,2,1,OUTPUT modeloleitor, OUTPUT LT_Resp).

        /* Leitora de Inserção - DIP */
        IF  glb_tpleitor = 1  THEN
            DO:
                IF  LT_resp = 0  THEN
                    ASSIGN xfs_leitoraDIP = TRUE
                           par_flgderro   = NO.
                ELSE
                    ASSIGN xfs_leitoraDIP = FALSE
                           par_flgderro   = YES.
                
                xfs_leitoraPASS = FALSE.
            END.
        ELSE
        /* Leitora de Passagem */
        IF  glb_tpleitor = 2  THEN
            ASSIGN xfs_leitoraPASS = TRUE
                   par_flgderro    = NO
                   LT_Resp         = 0.
        ELSE
            par_flgderro = YES.

        RUN procedures/grava_log.p (INPUT "LEITORA DE CARTAO - RETORNO: " + STRING(LT_Resp) + " P32LDIP.DLL (WinIniciaLDIP)").
    END.
/* Fim Operação 4 - Verificar Leitora de Cartão */
ELSE

/* Operação 5 - Abrir a Impressora */
IF  par_cdoperac = 5  THEN
    DO:
        LT_resp = 0.       
       
        RUN WinIniciaPrtCh IN aux_xfsliteh (OUTPUT LT_Resp).
       
        IF  LT_Resp = 0  THEN
            ASSIGN xfs_impressora = TRUE
                   par_flgderro   = NO.
        ELSE
            ASSIGN xfs_impressora = FALSE
                   par_flgderro   = YES.

        RUN procedures/grava_log.p (INPUT "ABRIR IMPRESSORA - RETORNO: " + STRING(LT_Resp) + " P32PRTCH.DLL (WinIniciaPrtCh)").
    END.
/* Fim Operação 5 - Abrir a Impressora */
ELSE

/* Operação 6 - Verificar a Impressora */
IF  par_cdoperac = 6  THEN
    DO:
        LT_resp = 0.
    
        DEFINE VARIABLE v_status_impressora     AS MEMPTR       NO-UNDO.

        SET-SIZE(v_status_impressora) = 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1.

        ASSIGN PUT-BYTE(v_status_impressora,1) = 0
               PUT-BYTE(v_status_impressora,2) = 0
               PUT-BYTE(v_status_impressora,3) = 0
               PUT-BYTE(v_status_impressora,4) = 0
               PUT-BYTE(v_status_impressora,5) = 0
               PUT-BYTE(v_status_impressora,6) = 0
               PUT-BYTE(v_status_impressora,7) = 0
               PUT-BYTE(v_status_impressora,8) = 0.
        
        RUN WinStatusPrtCh IN aux_xfsliteh 
                        (INPUT GET-POINTER-VALUE(v_status_impressora),
                         OUTPUT LT_Resp).

        RUN procedures/grava_log.p (INPUT "STATUS IMPRESSORA - RETORNO: " + STRING(LT_Resp) + " P32PRTCH.DLL (WinStatusPrtCh)").

        /* datalhado */
        ASSIGN glb_cdstaimp[1] = GET-BYTE(v_status_impressora,1)
               glb_cdstaimp[2] = GET-BYTE(v_status_impressora,2)
               glb_cdstaimp[3] = GET-BYTE(v_status_impressora,3)
               glb_cdstaimp[4] = GET-BYTE(v_status_impressora,4)
               glb_cdstaimp[5] = GET-BYTE(v_status_impressora,5)
               glb_cdstaimp[6] = GET-BYTE(v_status_impressora,6)
               glb_cdstaimp[7] = GET-BYTE(v_status_impressora,7)
               glb_cdstaimp[8] = GET-BYTE(v_status_impressora,8).
               
        SET-SIZE(v_status_impressora) = 0.

        ASSIGN par_flgderro      = NO
               xfs_impsempapel   = NO
			   xfs_imppapelsaida = NO
               xfs_impressora    = YES.
                 
        IF  glb_cdstaimp[1] <> 0  THEN   /* = 0 - impressora on-line  */
            DO: 
                RUN procedures/grava_log.p (INPUT "STATUS IMPRESSORA - DETALHE: NAO ESTA ON-LINE - P32PRTCH.DLL (WinStatusPrtCh)").
                ASSIGN par_flgderro   = YES
                       xfs_impressora = NO.
            END.

        IF  glb_cdstaimp[3]  = 2  THEN   /* Sem papel  */
            DO:
                RUN procedures/grava_log.p (INPUT "STATUS IMPRESSORA - DETALHE: SEM PAPEL - P32PRTCH.DLL (WinStatusPrtCh)").
                ASSIGN par_flgderro    = YES 
                       xfs_impsempapel = YES
                       xfs_impressora  = YES.
            END.

        IF  glb_cdstaimp[4] <> 1  THEN   /* = 1 - bocal presente  */
            DO: 
                RUN procedures/grava_log.p (INPUT "STATUS IMPRESSORA - DETALHE: BOCAL NAO ESTA PRESENTE - P32PRTCH.DLL (WinStatusPrtCh)").
                ASSIGN par_flgderro   = YES
                       xfs_impressora = NO.
            END.

        IF  glb_cdstaimp[5] <> 0  THEN   /* = 0 - bocal ok  */
            DO: 
                RUN procedures/grava_log.p (INPUT "STATUS IMPRESSORA - DETALHE: PROBLEMAS NO BOCAL - P32PRTCH.DLL (WinStatusPrtCh)").
                ASSIGN par_flgderro   = YES
                       xfs_impressora = NO.
            END.

        IF  glb_cdstaimp[6]  = 1  THEN   /* = 1 - bocal obstruido  */
            DO: 
                RUN procedures/grava_log.p (INPUT "STATUS IMPRESSORA - DETALHE: BOCAL OBSTRUIDO - P32PRTCH.DLL (WinStatusPrtCh)").
                ASSIGN par_flgderro   = YES
                       xfs_impressora = NO.
            END.
        
        IF  glb_cdstaimp[7]  = 1  THEN   /* = 1 - com papel no sensor de entrada */
            DO: 
                RUN procedures/grava_log.p (INPUT "STATUS IMPRESSORA - DETALHE: COM PAPEL NO SENSOR DE ENTRADA - P32PRTCH.DLL (WinStatusPrtCh)").
                ASSIGN par_flgderro   = YES
                       xfs_impressora = NO.
            END.

        IF  glb_cdstaimp[8]  = 1  THEN /* = 1 - com papel no sensor de saida  */
            DO: 
                RUN procedures/grava_log.p (INPUT "STATUS IMPRESSORA - DETALHE: COM PAPEL NO SENSOR DE SAIDA - P32PRTCH.DLL (WinStatusPrtCh)").
                ASSIGN par_flgderro      = YES
                       xfs_impressora    = NO
					   xfs_imppapelsaida = YES.
            END.

    END. 
/* Operação 6 - Verificar a Impressora */
ELSE

/* Operação 7 - Veridicar leitora de codigo de barras */
IF  par_cdoperac = 7  THEN
    DO:
        LT_resp = 0.

        /* Cancela qualquer leitura em andamento */
        RUN WinCancelaLeituraCodBarLcbCh IN aux_xfsliteh (OUTPUT LT_Resp).

        /* Finaliza a leitora */
        RUN WinFinalizaLcbCh IN aux_xfsliteh (OUTPUT LT_Resp).

        /* Inicializa a leitora */
        RUN WinIniciaLcbCh IN aux_xfsliteh (OUTPUT LT_Resp).

        /* Inicializacao OK */
        IF  LT_Resp = 1  THEN
            ASSIGN xfs_lcbarras = TRUE
                   par_flgderro = NO.
        ELSE
            ASSIGN xfs_lcbarras = FALSE
                   par_flgderro = YES.

        RUN procedures/grava_log.p (INPUT "LEITORA DE COD. BARRAS - RETORNO: " + STRING(LT_Resp) + " P32LCBCH.DLL (WinIniciaLcbCh)").
    END.
/* Fim Operação 7 - Verificar leitora de codigo de barras */

ELSE

/* Operação 8 - Iniciar Teclados (Frontal + PAINOP) */
IF  par_cdoperac = 8  THEN
    DO:
        LT_resp = 0.

        RUN WinIniciaTeclados IN aux_xfsliteh (OUTPUT LT_Resp).

        /* Inicializacao OK */
        IF  LT_Resp = 0  THEN
            par_flgderro = NO.
        ELSE
            par_flgderro = YES.

        RUN procedures/grava_log.p (INPUT "TECLADOS - RETORNO: " + STRING(LT_Resp) + " P32TCATM.DLL (WinIniciaTeclados)").
    END.
/* Fim Operação 8 - Iniciar Teclados (Frontal + PAINOP) */


ELSE

/* Operação 9 - Verificar Teclado PAINOP */
IF  par_cdoperac = 9  THEN
    DO:
        DEF VAR VersTec          AS MEMPTR      NO-UNDO.
        DEF VAR StaEEPROM        AS INT         NO-UNDO.
        DEF VAR TemSmart         AS INT         NO-UNDO.
        DEF VAR TipoCrtMagn      AS INT         NO-UNDO.
        DEF VAR TrCrtMagn        AS INT         NO-UNDO.
        DEF VAR LayoutTec        AS INT         NO-UNDO.
        DEF VAR NLinhasDisplay   AS INT         NO-UNDO.
        DEF VAR NColDisplay      AS INT         NO-UNDO.

        ASSIGN LT_resp    = 0
               xfs_painop = FALSE.


        SET-SIZE(VersTec) = 3.

        RUN WinLeConfiguraTeclados IN aux_xfsliteh (
            INPUT  2, /* Teclado PAINOP */
            INPUT GET-POINTER-VALUE(VersTec),
            OUTPUT StaEEPROM,
            OUTPUT TemSmart,
            OUTPUT TipoCrtMagn,
            OUTPUT TrCrtMagn,
            OUTPUT LayoutTec,
            OUTPUT NLinhasDisplay,
            OUTPUT NColDisplay,
            OUTPUT LT_Resp).


        /* verifica se possui PAINOP 8x40 */
        IF  NLinhasDisplay =  8  AND
            NColDisplay    = 40  THEN
            xfs_painop = YES.
    

        /* Verificacao OK */
        IF  LT_Resp = 0  THEN
            par_flgderro = NO.
        ELSE
            par_flgderro = YES.

        RUN procedures/grava_log.p (INPUT "TECLADO PAINOP - RETORNO: " + STRING(LT_Resp) + " P32TCATM.DLL (WinLeConfiguraTeclados)").
    END.
/* Fim Operação 9 - Verificar Teclado PAINOP */

ELSE

/* Operação 10 - Logar para o Nagios */
IF  par_cdoperac = 10 THEN
    DO:
        DEFINE VARIABLE aux_cdsittfn        AS LOGICAL              NO-UNDO.
        DEFINE VARIABLE aux_flgblsaq        AS LOGICAL              NO-UNDO.
        DEFINE VARIABLE aux_flgderro        AS LOGICAL              NO-UNDO.
        DEFINE VARIABLE aux_totnotas        AS INTEGER              NO-UNDO.

        IF  glb_cdsittfn = 2 /* Fechado */ THEN
            ASSIGN aux_cdsittfn = NO.
        ELSE
            ASSIGN aux_cdsittfn = YES.
        
        /* Verifica bloqueio de saque */
        RUN procedures/verifica_bloqueio_saque.p(OUTPUT aux_flgblsaq,
                                                 OUTPUT aux_flgderro).

        ASSIGN aux_totnotas = glb_qtnotk7A + glb_qtnotk7B + glb_qtnotk7C + glb_qtnotk7D + glb_qtnotk7R.

        RUN procedures/grava_log.p (INPUT "NOTAS TA - K7A: " + STRING(glb_qtnotk7A,'zz,zz9-') +
                                                    " K7B: " + STRING(glb_qtnotk7B,'zz,zz9-') +
                                                    " K7C: " + STRING(glb_qtnotk7C,'zz,zz9-') +
                                                    " K7D: " + STRING(glb_qtnotk7D,'zz,zz9-') +
                                                    " K7R: " + STRING(glb_qtnotk7R,'zz,zz9-') +
                                                    " TOTAL: " + STRING(aux_totnotas,'zz,zz9-')).

        RUN procedures/grava_log.p (INPUT "STATUS SAQUE - K7A: " + STRING(glb_cassetes[1],"OK/NOK") + 
                                                        " K7B: " + STRING(glb_cassetes[2],"OK/NOK") + 
                                                        " K7C: " + STRING(glb_cassetes[3],"OK/NOK") + 
                                                        " K7D: " + STRING(glb_cassetes[4],"OK/NOK") + 
                                                        " K7R: " + STRING(glb_cassetes[5],"OK/NOK") + 
                                                        " SUPRIDO: "    + STRING(glb_flgsupri,"OK/NOK") +
                                                        " ABERTO: "     + STRING(aux_cdsittfn,"OK/NOK") +
                                                         /* Inversão do sentido, pois campo no banco se refere à BLOQUEADO */
                                                        " HABILITADO: " + STRING(aux_flgblsaq,"NOK/OK")).
    END.
/* Fim Operação 10 - Logar para o Nagios */

ELSE
    par_flgderro = YES.


IF  par_flgderro  THEN
    RETURN "NOK".

RETURN "OK".

/* ............................................................................ */
