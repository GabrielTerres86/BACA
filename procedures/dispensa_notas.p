/* ..............................................................................

Procedure : dispensa_notas.p 
Objetivo  : Validar, organizar e dispensar as notas
Autor     : Evandro
Data      : Fevereiro 2010
Observação: O pagamento é balanceado com intuito de consumir as notas dos
            cassetes de forma equivalente e entregar valor "trocado" ao
            cooperado, caso nao seja possivel, sera pago pela nota de
            maior valor, com limite de 30 notas.

Ultima alteração: 15/10/2010 - Ajustes para TAA compartilhado (Evandro).

                  13/04/2011 - Incluido valor quando erro de impossivel
                               compor valor;
                             - Incluido contabilizacao de rejeitados no
                               erro de entrega das notas (Evandro).

............................................................................... */

DEFINE  INPUT PARAMETER par_vldsaque    AS DECIMAL                  NO-UNDO.
DEFINE  INPUT PARAMETER par_executar    AS LOGICAL                  NO-UNDO.
DEFINE  INPUT PARAMETER par_dscomand    AS CHAR                     NO-UNDO.
DEFINE OUTPUT PARAMETER par_flgderro    AS LOGICAL      INIT NO     NO-UNDO.

{ includes/var_taa.i }
{ includes/var_xfs_lite.i }

DEFINE VARIABLE aux_contador            AS INTEGER                  NO-UNDO.
DEFINE VARIABLE aux_contador2           AS INTEGER                  NO-UNDO.
DEFINE VARIABLE aux_tpdpagto            AS INTEGER                  NO-UNDO.
DEFINE VARIABLE aux_flgpagou            AS LOGICAL      INIT NO     NO-UNDO.


DEFINE VARIABLE tmp_vlmainot            AS DECIMAL      EXTENT 5    NO-UNDO.
DEFINE VARIABLE tmp_k7mainot            AS CHAR         EXTENT 5    NO-UNDO.


/* para o calculo da composicao do valor */
DEFINE VARIABLE tmp_vldsaque            AS DECIMAL                  NO-UNDO.

/* saldo do TAA durante o saque */
DEFINE VARIABLE tmp_qtnotK7A            AS INTEGER                  NO-UNDO.
DEFINE VARIABLE tmp_qtnotK7B            AS INTEGER                  NO-UNDO.
DEFINE VARIABLE tmp_qtnotK7C            AS INTEGER                  NO-UNDO.
DEFINE VARIABLE tmp_qtnotK7D            AS INTEGER                  NO-UNDO.

/* notas a serem pagas */
DEFINE VARIABLE pag_qtdnotaA            AS INTEGER                  NO-UNDO.
DEFINE VARIABLE pag_qtdnotaB            AS INTEGER                  NO-UNDO.
DEFINE VARIABLE pag_qtdnotaC            AS INTEGER                  NO-UNDO.
DEFINE VARIABLE pag_qtdnotaD            AS INTEGER                  NO-UNDO.

/* notas rejeitadas no momento da retirada do K7 (nota embolada, por exemplo */
DEFINE VARIABLE rej_qtdnotaA            AS INTEGER                  NO-UNDO.
DEFINE VARIABLE rej_qtdnotaB            AS INTEGER                  NO-UNDO.
DEFINE VARIABLE rej_qtdnotaC            AS INTEGER                  NO-UNDO.
DEFINE VARIABLE rej_qtdnotaD            AS INTEGER                  NO-UNDO.

/* notas que foram retiradas do cassete com sucesso */
DEFINE VARIABLE con_qtdnotaA            AS INTEGER                  NO-UNDO.
DEFINE VARIABLE con_qtdnotaB            AS INTEGER                  NO-UNDO.
DEFINE VARIABLE con_qtdnotaC            AS INTEGER                  NO-UNDO.
DEFINE VARIABLE con_qtdnotaD            AS INTEGER                  NO-UNDO.



ASSIGN tmp_vldsaque = par_vldsaque

       tmp_qtnotK7A = glb_qtnotK7A
       tmp_qtnotK7B = glb_qtnotK7B
       tmp_qtnotK7C = glb_qtnotK7C
       tmp_qtnotK7D = glb_qtnotK7D

       pag_qtdnotaA = 0
       pag_qtdnotaB = 0
       pag_qtdnotaC = 0
       pag_qtdnotaD = 0
    
       aux_tpdpagto = 1. /* K7D -> K7A */



/* Para o pagamento pela MAIOR nota */
ASSIGN tmp_vlmainot[1] = glb_vlnotK7A
       tmp_k7mainot[1] = "A"

       tmp_vlmainot[2] = glb_vlnotK7B
       tmp_k7mainot[2] = "B"

       tmp_vlmainot[3] = glb_vlnotK7C
       tmp_k7mainot[3] = "C"

       tmp_vlmainot[4] = glb_vlnotK7D
       tmp_k7mainot[4] = "D"

       tmp_vlmainot[5] = 0
       tmp_k7mainot[5] = "".

/* Ordena as notas */
DO  aux_contador2 = 1 TO 4:
    IF  tmp_vlmainot[1] < tmp_vlmainot[2]  THEN
        ASSIGN tmp_vlmainot[5] = tmp_vlmainot[1]
               tmp_k7mainot[5] = tmp_k7mainot[1]
               tmp_vlmainot[1] = tmp_vlmainot[2]
               tmp_k7mainot[1] = tmp_k7mainot[2]
               tmp_vlmainot[2] = tmp_vlmainot[5]
               tmp_k7mainot[2] = tmp_k7mainot[5].

    IF  tmp_vlmainot[2] < tmp_vlmainot[3]  THEN
        ASSIGN tmp_vlmainot[5] = tmp_vlmainot[2]
               tmp_k7mainot[5] = tmp_k7mainot[2]
               tmp_vlmainot[2] = tmp_vlmainot[3]
               tmp_k7mainot[2] = tmp_k7mainot[3]
               tmp_vlmainot[3] = tmp_vlmainot[5]
               tmp_k7mainot[3] = tmp_k7mainot[5].

    IF  tmp_vlmainot[3] < tmp_vlmainot[4]  THEN
        ASSIGN tmp_vlmainot[5] = tmp_vlmainot[3]
               tmp_k7mainot[5] = tmp_k7mainot[3]
               tmp_vlmainot[3] = tmp_vlmainot[4]
               tmp_k7mainot[3] = tmp_k7mainot[4]
               tmp_vlmainot[4] = tmp_vlmainot[5]
               tmp_k7mainot[4] = tmp_k7mainot[5].
END.



/* Tenta montar a composicao do valor:
   1- do K7D para o K7A
   2- do K7A para o K7D 
   3- pela MAIOR nota */

DO  aux_contador = 1 TO 30:

    IF  aux_tpdpagto = 1  THEN
        DO:
            /* K7D */
            IF  tmp_vldsaque >= glb_vlnotK7D  AND
                tmp_qtnotK7D > 0              AND
                glb_cassetes[4]               THEN
                ASSIGN tmp_vldsaque = tmp_vldsaque - glb_vlnotK7D
                       tmp_qtnotK7D = tmp_qtnotK7D - 1
                       pag_qtdnotaD = pag_qtdnotaD + 1.

            /* K7C */
            IF  tmp_vldsaque >= glb_vlnotK7C  AND
                tmp_qtnotK7C > 0              AND
                glb_cassetes[3]               THEN
                ASSIGN tmp_vldsaque = tmp_vldsaque - glb_vlnotK7C
                       tmp_qtnotK7C = tmp_qtnotK7C - 1
                       pag_qtdnotaC = pag_qtdnotaC + 1.

            /* K7B */
            IF  tmp_vldsaque >= glb_vlnotK7B  AND
                tmp_qtnotK7B > 0              AND
                glb_cassetes[2]               THEN
                ASSIGN tmp_vldsaque = tmp_vldsaque - glb_vlnotK7B
                       tmp_qtnotK7B = tmp_qtnotK7B - 1
                       pag_qtdnotaB = pag_qtdnotaB + 1.

            /* K7A */
            IF  tmp_vldsaque >= glb_vlnotK7A  AND
                tmp_qtnotK7A > 0              AND
                glb_cassetes[1]               THEN
                ASSIGN tmp_vldsaque = tmp_vldsaque - glb_vlnotK7A
                       tmp_qtnotK7A = tmp_qtnotK7A - 1
                       pag_qtdnotaA = pag_qtdnotaA + 1.
        END.
    ELSE
    IF  aux_tpdpagto = 2  THEN
        DO:
            /* K7A */
            IF  tmp_vldsaque >= glb_vlnotK7A  AND
                tmp_qtnotK7A > 0              AND
                glb_cassetes[1]               THEN
                ASSIGN tmp_vldsaque = tmp_vldsaque - glb_vlnotK7A
                       tmp_qtnotK7A = tmp_qtnotK7A - 1
                       pag_qtdnotaA = pag_qtdnotaA + 1.
            
            /* K7B */
            IF  tmp_vldsaque >= glb_vlnotK7B  AND
                tmp_qtnotK7B > 0              AND
                glb_cassetes[2]               THEN
                ASSIGN tmp_vldsaque = tmp_vldsaque - glb_vlnotK7B
                       tmp_qtnotK7B = tmp_qtnotK7B - 1
                       pag_qtdnotaB = pag_qtdnotaB + 1.
            
            /* K7C */
            IF  tmp_vldsaque >= glb_vlnotK7C  AND
                tmp_qtnotK7C > 0              AND
                glb_cassetes[3]               THEN
                ASSIGN tmp_vldsaque = tmp_vldsaque - glb_vlnotK7C
                       tmp_qtnotK7C = tmp_qtnotK7C - 1
                       pag_qtdnotaC = pag_qtdnotaC + 1.
            
            /* K7D */
            IF  tmp_vldsaque >= glb_vlnotK7D  AND
                tmp_qtnotK7D > 0              AND
                glb_cassetes[4]               THEN
                ASSIGN tmp_vldsaque = tmp_vldsaque - glb_vlnotK7D
                       tmp_qtnotK7D = tmp_qtnotK7D - 1
                       pag_qtdnotaD = pag_qtdnotaD + 1.
        END.
    ELSE
    IF  aux_tpdpagto = 3  THEN
        DO:
            /* Pagamento pela MAIOR nota */
            aux_contador2 = 1.
            DO  WHILE TRUE:

                IF  tmp_vlmainot[aux_contador2] <= tmp_vldsaque  THEN
                    DO:
                       
                        IF  tmp_k7mainot[aux_contador2] = "A"  AND
                            tmp_qtnotK7A                > 0    AND
                            glb_cassetes[1]                    THEN
                            DO:
                                ASSIGN tmp_vldsaque = tmp_vldsaque - glb_vlnotK7A
                                       tmp_qtnotK7A = tmp_qtnotK7A - 1
                                       pag_qtdnotaA = pag_qtdnotaA + 1.
                                NEXT.
                            END.
                
                        IF  tmp_k7mainot[aux_contador2] = "B"  AND
                            tmp_qtnotK7B                > 0    AND
                            glb_cassetes[2]                    THEN
                            DO:
                                ASSIGN tmp_vldsaque = tmp_vldsaque - glb_vlnotK7B
                                       tmp_qtnotK7B = tmp_qtnotK7B - 1
                                       pag_qtdnotaB = pag_qtdnotaB + 1.
                                NEXT.
                            END.
                
                
                        IF  tmp_k7mainot[aux_contador2] = "C"  AND
                            tmp_qtnotK7C                > 0    AND
                            glb_cassetes[3]                    THEN
                            DO:
                                ASSIGN tmp_vldsaque = tmp_vldsaque - glb_vlnotK7C
                                       tmp_qtnotK7C = tmp_qtnotK7C - 1
                                       pag_qtdnotaC = pag_qtdnotaC + 1.
                                NEXT.
                            END.
                
                
                        IF  tmp_k7mainot[aux_contador2] = "D"  AND
                            tmp_qtnotK7D                > 0    AND
                            glb_cassetes[4]                    THEN
                            DO:
                                ASSIGN tmp_vldsaque = tmp_vldsaque - glb_vlnotK7D
                                       tmp_qtnotK7D = tmp_qtnotK7D - 1
                                       pag_qtdnotaD = pag_qtdnotaD + 1.
                                NEXT.
                            END.
                    END.

                aux_contador2 = aux_contador2 + 1.

                IF  aux_contador2 > 4  THEN
                    LEAVE.
            END. /* Fim DO..WHILE.. */
        END.
    ELSE
        LEAVE.
    

    /* Não conseguiu compor, tenta na proxima forma */
    IF (aux_contador = 30 AND tmp_vldsaque > 0)  OR
       (pag_qtdnotaA + pag_qtdnotaB +
        pag_qtdnotaC + pag_qtdnotaD > 30)        THEN
        DO:
            /* Inicializa as variáveis para tentar de outra forma */
            ASSIGN aux_tpdpagto = aux_tpdpagto + 1
            
                   aux_contador = 0
                   tmp_vldsaque = par_vldsaque
            
                   pag_qtdnotaA = 0
                   pag_qtdnotaB = 0
                   pag_qtdnotaC = 0
                   pag_qtdnotaD = 0
            
                   tmp_qtnotK7A = glb_qtnotK7A
                   tmp_qtnotK7B = glb_qtnotK7B
                   tmp_qtnotK7C = glb_qtnotK7C
                   tmp_qtnotK7D = glb_qtnotK7D.
        END.

    
    IF  tmp_vldsaque = 0  THEN
        LEAVE.
END.


/* Impossível compor o valor */
IF  tmp_vldsaque > 0  THEN
    DO:
        RUN procedures/grava_log.p (INPUT "Não foi possível compor o valor solicitado: R$ " + STRING(par_vldsaque,"z,zz9.99")).

        RUN mensagem.w (INPUT YES,
                        INPUT "   ATENÇÃO",
                        INPUT "",
                        INPUT "",
                        INPUT "Não foi possível compor o",
                        INPUT "valor solicitado.",
                        INPUT "").

        PAUSE 3 NO-MESSAGE.
        h_mensagem:HIDDEN = YES.

        par_flgderro = YES.
        RETURN "NOK".
    END.


/* somente para verificar se eh possivel pagar o valor escolhido */
IF  NOT par_executar  THEN
    RETURN "OK".


/* Verifica o Contador de Cedulas */
RUN procedures/inicializa_dispositivo.p ( INPUT 2,
                                         OUTPUT par_flgderro).

IF  par_flgderro  THEN
    DO:
        RUN procedures/grava_log.p (INPUT "Problemas no Contador de Notas.").

        RUN mensagem.w (INPUT YES,
                        INPUT "      ERRO!",
                        INPUT "",
                        INPUT "",
                        INPUT "Problemas no Contador",
                        INPUT "de Notas.",
                        INPUT "").

        PAUSE 3 NO-MESSAGE.
        h_mensagem:HIDDEN = YES.
        
        RETURN "NOK".
    END.

/* Log para auxilio tecnico, quantidade de notas por K7 */
RUN procedures/grava_log.p (INPUT "Notas Solicitadas: ").
RUN procedures/grava_log.p (INPUT STRING(pag_qtdnotaA) + " x K7A (" + STRING(glb_vlnotK7A,"zz9.99") + ") = R$ " + STRING(pag_qtdnotaA * glb_vlnotK7A,"zz,zz9.99")).
RUN procedures/grava_log.p (INPUT STRING(pag_qtdnotaB) + " x K7B (" + STRING(glb_vlnotK7B,"zz9.99") + ") = R$ " + STRING(pag_qtdnotaB * glb_vlnotK7B,"zz,zz9.99")).
RUN procedures/grava_log.p (INPUT STRING(pag_qtdnotaC) + " x K7C (" + STRING(glb_vlnotK7C,"zz9.99") + ") = R$ " + STRING(pag_qtdnotaC * glb_vlnotK7C,"zz,zz9.99")).
RUN procedures/grava_log.p (INPUT STRING(pag_qtdnotaD) + " x K7D (" + STRING(glb_vlnotK7D,"zz9.99") + ") = R$ " + STRING(pag_qtdnotaD * glb_vlnotK7D,"zz,zz9.99")).



/* Conta as Cedulas */
RUN contar_notas.

IF  NOT par_flgderro  THEN
    /* Entrega as Cedulas */
    RUN entregar_notas.



/* globais com o total restante das notas no TAA.
   sao atualizadas mesmo quando ha erro devido aos
   rejeitados */
ASSIGN glb_qtnotK7A = tmp_qtnotK7A
       glb_qtnotK7B = tmp_qtnotK7B
       glb_qtnotK7C = tmp_qtnotK7C
       glb_qtnotK7D = tmp_qtnotK7D.

IF  par_flgderro  THEN
    RETURN "NOK".

RETURN "OK".



PROCEDURE contar_notas:

    DEFINE VARIABLE lpcmd               AS MEMPTR       NO-UNDO.
    DEFINE VARIABLE status_c            AS MEMPTR       NO-UNDO.
    DEFINE VARIABLE status_detalhado    AS INT          NO-UNDO.

    DEFINE VARIABLE aux_flgrejei        AS LOGICAL      NO-UNDO.
    DEFINE VARIABLE aux_LT_Resp         AS INT          NO-UNDO.

    SET-SIZE(lpcmd) = 4.
    PUT-BYTE(lpcmd,1) = pag_qtdnotaA.
    PUT-BYTE(lpcmd,2) = pag_qtdnotaB.
    PUT-BYTE(lpcmd,3) = pag_qtdnotaC.
    PUT-BYTE(lpcmd,4) = pag_qtdnotaD.

    SET-SIZE(status_c)   = 9.
    PUT-BYTE(status_c,1) = 0.
    PUT-BYTE(status_c,2) = 0.
    PUT-BYTE(status_c,3) = 0.
    PUT-BYTE(status_c,4) = 0.
    PUT-BYTE(status_c,5) = 0.
    PUT-BYTE(status_c,6) = 0.
    PUT-BYTE(status_c,7) = 0.
    PUT-BYTE(status_c,8) = 0.
    PUT-BYTE(status_c,9) = 0.

    ASSIGN LT_Resp = 0.

    RUN mensagem.w (INPUT NO,
                    INPUT "  AGUARDE...",
                    INPUT "",
                    INPUT "",
                    INPUT "Contando as Notas.",
                    INPUT "",
                    INPUT "").

    RUN WinContarCedulas IN aux_xfsliteh 
        (INPUT GET-POINTER-VALUE(lpcmd),
         INPUT GET-POINTER-VALUE(status_c),
         OUTPUT LT_Resp).

    /* fecha a tela de mensagem */
    h_mensagem:HIDDEN = YES.

    ASSIGN status_detalhado = GET-BYTE(status_c,01)
           
           /* retiradas com sucesso do K7 */
           con_qtdnotaA     = GET-BYTE(status_c,02)
           con_qtdnotaB     = GET-BYTE(status_c,03)
           con_qtdnotaC     = GET-BYTE(status_c,04)
           con_qtdnotaD     = GET-BYTE(status_c,05)

           /* problemas na retirada do K7 */
           rej_qtdnotaA     = GET-BYTE(status_c,06)
           rej_qtdnotaB     = GET-BYTE(status_c,07)
           rej_qtdnotaC     = GET-BYTE(status_c,08)
           rej_qtdnotaD     = GET-BYTE(status_c,09)

           /* guarda o retorno da contagem, demais funcoes
              tambem alteram o LT_Resp... */
           aux_LT_Resp      = LT_Resp.

    /* notas podem ser rejeitadas de varias maneiras, uma delas eh quando nao consegue
       contar a quantidade suficiente, outra eh quando ha problema com notas emboladas.
       quando ha notas emboladas, automaticamente ele rejeita as notas e tenta sacar
       mais uma vez, entao a operacao pode ser com sucesso e mesmo assim ter notas
       rejeitadas */


    /* verifica se alguma nota vai ser rejeitada por
       insifuciencia de cedulas */
    IF  con_qtdnotaA < pag_qtdnotaA  THEN
        rej_qtdnotaA = rej_qtdnotaA + con_qtdnotaA.
    
    IF  con_qtdnotaB < pag_qtdnotaB  THEN
        rej_qtdnotaB = rej_qtdnotaB + con_qtdnotaB.

    IF  con_qtdnotaC < pag_qtdnotaC  THEN
        rej_qtdnotaC = rej_qtdnotaC + con_qtdnotaC.

    IF  con_qtdnotaD < pag_qtdnotaD  THEN
        rej_qtdnotaD = rej_qtdnotaD + con_qtdnotaD.



    /* se conseguiu pagar, faz a baixa do valor pago e das
       notas rejeitadas */
    IF  LT_Resp = 0  THEN
        /* faz a baixa das notas rejeitadas nos K7s */
        ASSIGN tmp_qtnotK7A = tmp_qtnotK7A - rej_qtdnotaA
               tmp_qtnotK7B = tmp_qtnotK7B - rej_qtdnotaB
               tmp_qtnotK7C = tmp_qtnotK7C - rej_qtdnotaC
               tmp_qtnotK7D = tmp_qtnotK7D - rej_qtdnotaD.
    ELSE
        /* senao, somente baixa as notas rejeitadas com base na
           quantidade original do K7 */
        ASSIGN tmp_qtnotK7A = glb_qtnotK7A - rej_qtdnotaA  
               tmp_qtnotK7B = glb_qtnotK7B - rej_qtdnotaB  
               tmp_qtnotK7C = glb_qtnotK7C - rej_qtdnotaC  
               tmp_qtnotK7D = glb_qtnotK7D - rej_qtdnotaD. 

    
    IF  rej_qtdnotaA + rej_qtdnotaB +
        rej_qtdnotaC + rej_qtdnotaD > 0  THEN
        aux_flgrejei = YES.
    ELSE
        aux_flgrejei = NO.


    IF  aux_flgrejei  THEN
        DO:
            /* Log para auxilio tecnico, quantidade de notas por K7 */
            RUN procedures/grava_log.p (INPUT "Notas Rejeitadas: ").
            RUN procedures/grava_log.p (INPUT STRING(rej_qtdnotaA) + " x K7A (" + STRING(glb_vlnotK7A,"zz9.99") + ") = R$ " + STRING(rej_qtdnotaA * glb_vlnotK7A,"zz,zz9.99")).
            RUN procedures/grava_log.p (INPUT STRING(rej_qtdnotaB) + " x K7B (" + STRING(glb_vlnotK7B,"zz9.99") + ") = R$ " + STRING(rej_qtdnotaB * glb_vlnotK7B,"zz,zz9.99")).
            RUN procedures/grava_log.p (INPUT STRING(rej_qtdnotaC) + " x K7C (" + STRING(glb_vlnotK7C,"zz9.99") + ") = R$ " + STRING(rej_qtdnotaC * glb_vlnotK7C,"zz,zz9.99")).
            RUN procedures/grava_log.p (INPUT STRING(rej_qtdnotaD) + " x K7D (" + STRING(glb_vlnotK7D,"zz9.99") + ") = R$ " + STRING(rej_qtdnotaD * glb_vlnotK7D,"zz,zz9.99")).


            /* contabiliza as notas rejeitadas */
            ASSIGN glb_qtnotK7R = glb_qtnotK7R +
                                  rej_qtdnotaA +
                                  rej_qtdnotaB +
                                  rej_qtdnotaC + 
                                  rej_qtdnotaD

                   glb_vlnotK7R = glb_vlnotK7R +
                                  (rej_qtdnotaA * glb_vlnotK7A) +
                                  (rej_qtdnotaB * glb_vlnotK7B) +
                                  (rej_qtdnotaC * glb_vlnotK7C) +
                                  (rej_qtdnotaD * glb_vlnotK7D).


            RUN procedures/efetua_rejeicao_notas.p (OUTPUT par_flgderro).
        END.


    IF  LT_Resp          <> 0  OR 
        status_detalhado <> 0  THEN
        DO:
            RUN procedures/grava_log.p (INPUT "Problemas na Contagem das Notas - RETORNO: " +
                                              STRING(LT_Resp) + " - DETALHADO: " + STRING(STATUS_detalhado)).
            
            RUN mensagem.w (INPUT YES,
                            INPUT "      ERRO!",
                            INPUT "",
                            INPUT "",
                            INPUT "Problemas na Contagem",
                            INPUT "das Notas.",
                            INPUT "").

            PAUSE 3 NO-MESSAGE.
            h_mensagem:HIDDEN = YES.


            IF  aux_flgrejei   THEN
                RUN rejeitar_notas.

            SET-SIZE(status_c) = 0.
            SET-SIZE(lpcmd) = 0.


            /* verifica se deve desabilitar os cassetes */
            IF  aux_LT_Resp >= 33  AND
                aux_LT_Resp <= 36  THEN
                DO:
                    /* Erro K7A */
                    IF  aux_LT_Resp = 33  THEN
                        DO:
                            sis_cassetes[1] = FALSE.
                            RUN procedures/grava_log.p ("Desabilitando K7A").
                        END.
                    
                    /* Erro K7B */
                    IF  aux_LT_Resp = 34  THEN
                        DO:
                            sis_cassetes[2] = FALSE.
                            RUN procedures/grava_log.p ("Desabilitando K7B").
                        END.
                    
                    /* Erro K7C */
                    IF  aux_LT_Resp = 35  THEN
                        DO:
                            sis_cassetes[3] = FALSE.
                            RUN procedures/grava_log.p ("Desabilitando K7C").
                        END.
                    
                    /* Erro K7D */
                    IF  aux_LT_Resp = 36  THEN
                        DO:
                            sis_cassetes[4] = FALSE.
                            RUN procedures/grava_log.p ("Desabilitando K7D").
                        END.

                    
                    RUN mensagem.w (INPUT YES,
                                    INPUT "   ATENÇÃO",
                                    INPUT "",
                                    INPUT "Reiniciando dispensador.",
                                    INPUT "",
                                    INPUT "Aguarde...",
                                    INPUT "").

                    /* reinicia o dispositivo sem os cassetes desabilitados */
                    RUN procedures/inicializa_dispositivo.p ( INPUT 1,
                                                             OUTPUT par_flgderro).

                    h_mensagem:HIDDEN = YES.
                END.

            par_flgderro = YES.
            RETURN "NOK".
         END.

     SET-SIZE(status_c) = 0.
     SET-SIZE(lpcmd) = 0.

     RETURN "OK".

END PROCEDURE.



PROCEDURE entregar_notas:

    DEFINE VARIABLE lpcmd           AS MEMPTR                   NO-UNDO.
    DEFINE VARIABLE lprsp           AS MEMPTR                   NO-UNDO.
    
    
    aux_flgpagou = NO.

    RUN procedures/grava_log.p (INPUT "Dispensando as Notas.").

    RUN mensagem.w (INPUT NO,
                    INPUT "  AGUARDE...",
                    INPUT "",
                    INPUT "",
                    INPUT "Dispensando as Notas.",
                    INPUT "",
                    INPUT "").
 
    SET-SIZE(lpcmd) = 2.
    PUT-BYTE(lpcmd,1) = 52.      /*  retorno imediato */
    PUT-BYTE(lpcmd,2) = 60.      /*  time-out de 60 segundos  */
    
    SET-SIZE(lprsp) = 1.
    PUT-BYTE(lprsp,1) = 0.
    
    DO  WHILE TRUE:
    
        LT_Resp = 0.
    
        RUN WinEntregarCedulas IN aux_xfsliteh 
                      (INPUT GET-POINTER-VALUE(lpcmd),
                       INPUT GET-POINTER-VALUE(lprsp),
                       OUTPUT LT_Resp).

        h_mensagem:HIDDEN = YES.
    
        IF  LT_Resp <> 0  THEN
            DO:
                RUN procedures/grava_log.p (INPUT "Entrega de Notas: Retorno " + STRING(LT_Resp) + " (WinEntregarCedulas).").

                IF  LT_Resp = 16  THEN  /* 16 - Nao retiradas */
                    DO:
                        /* chegando nesta mensagem, o dinheiro ja é considerado sacado
                           independente se retirar ou nao */
                        IF  NOT aux_flgpagou  THEN
                            RUN atualiza_saque.

                        RUN mensagem.w (INPUT NO,
                                        INPUT "   ATENÇÃO",
                                        INPUT "",
                                        INPUT "",
                                        INPUT "Retire as Notas.",
                                        INPUT "",
                                        INPUT "").

                        PAUSE 3 NO-MESSAGE.
                        NEXT.
                    END.
                ELSE
                    DO:
                        RUN procedures/grava_log.p (INPUT "Problemas na Entrega das Notas - RETORNO: " + 
                                                          STRING(LT_Resp)).

                        /* Neste momento as notas foram contabilizadas com sucesso, porem nao foi possivel
                           entrega-las, por tanto, contabiliza no K7R as notas que foram contadas com sucesso */

                        /* Log para auxilio tecnico, quantidade de notas por K7 */
                        RUN procedures/grava_log.p (INPUT "Notas Rejeitadas: ").
                        RUN procedures/grava_log.p (INPUT STRING(con_qtdnotaA) + " x K7A (" + STRING(glb_vlnotK7A,"zz9.99") + ") = R$ " + STRING(con_qtdnotaA * glb_vlnotK7A,"zz,zz9.99")).
                        RUN procedures/grava_log.p (INPUT STRING(con_qtdnotaB) + " x K7B (" + STRING(glb_vlnotK7B,"zz9.99") + ") = R$ " + STRING(con_qtdnotaB * glb_vlnotK7B,"zz,zz9.99")).
                        RUN procedures/grava_log.p (INPUT STRING(con_qtdnotaC) + " x K7C (" + STRING(glb_vlnotK7C,"zz9.99") + ") = R$ " + STRING(con_qtdnotaC * glb_vlnotK7C,"zz,zz9.99")).
                        RUN procedures/grava_log.p (INPUT STRING(con_qtdnotaD) + " x K7D (" + STRING(glb_vlnotK7D,"zz9.99") + ") = R$ " + STRING(con_qtdnotaD * glb_vlnotK7D,"zz,zz9.99")).
                        
                        
                        /* contabiliza as notas rejeitadas */
                        ASSIGN glb_qtnotK7R = glb_qtnotK7R +
                                              con_qtdnotaA +
                                              con_qtdnotaB +
                                              con_qtdnotaC + 
                                              con_qtdnotaD
                        
                               glb_vlnotK7R = glb_vlnotK7R +
                                              (con_qtdnotaA * glb_vlnotK7A) +
                                              (con_qtdnotaB * glb_vlnotK7B) +
                                              (con_qtdnotaC * glb_vlnotK7C) +
                                              (con_qtdnotaD * glb_vlnotK7D).
                        
                        
                        RUN procedures/efetua_rejeicao_notas.p (OUTPUT par_flgderro).

                        RUN rejeitar_notas.

                        SET-SIZE(lpcmd) = 0.
                        SET-SIZE(lprsp) = 0.

                        par_flgderro = YES.
                        RETURN "NOK".
                    END.
            END.
        ELSE
            RUN procedures/grava_log.p (INPUT "Notas retiradas.").
    
        LEAVE.
    END.
    
    SET-SIZE(lpcmd) = 0.
    SET-SIZE(lprsp) = 0.

    RETURN "OK".

END PROCEDURE.




PROCEDURE rejeitar_notas:

    DEFINE VARIABLE lpcmd       AS MEMPTR       NO-UNDO.
    DEFINE VARIABLE status_c    AS INT          NO-UNDO.

    /* Erro de saque */
    par_flgderro = YES.
    
    SET-SIZE(lpcmd) = 1.
    PUT-BYTE(lpcmd,1) = 0.

    RUN mensagem.w (INPUT NO,
                    INPUT "  AGUARDE...",
                    INPUT "",
                    INPUT "",
                    INPUT "Rejeitando as Notas.",
                    INPUT "",
                    INPUT "").

    RUN WinRejeitarCedulas IN aux_xfsliteh 
        (INPUT GET-POINTER-VALUE(lpcmd),
         OUTPUT LT_Resp).

    h_mensagem:HIDDEN = YES.

    status_c = GET-BYTE(lpcmd,1).
    
    IF  LT_Resp  <> 0  OR 
        status_c <> 0  THEN
        DO:
            RUN procedures/grava_log.p (INPUT "Problemas na Rejeição das Notas - RETORNO: " +
                                              STRING(LT_Resp) + " - DETALHE: " + STRING(status_c)).

            RUN mensagem.w (INPUT YES,
                            INPUT "      ERRO!",
                            INPUT "",
                            INPUT "",
                            INPUT "Problemas na Rejeição",
                            INPUT "das Notas.",
                            INPUT "").

            PAUSE 3 NO-MESSAGE.
            h_mensagem:HIDDEN = YES.

            SET-SIZE(lpcmd) = 0.
            par_flgderro = YES.
            RETURN "NOK".
        END.
    
    SET-SIZE(lpcmd) = 0.

    RETURN "NOK".

END PROCEDURE.




PROCEDURE atualiza_saque:


    /* grava no log local - FireBird */
    DEFINE VARIABLE conexao                 AS COM-HANDLE               NO-UNDO.
    DEFINE VARIABLE resultado               AS COM-HANDLE               NO-UNDO.
    DEFINE VARIABLE comando                 AS COM-HANDLE               NO-UNDO.
    
    
    /* Conexao com o Firebird 
       1-Conexao ODBC criada em Ferramentas ADM do Windows
       2-Usuario
       3-Senha */
	   
	RUN procedures/grava_log.p (INPUT "Entrega de Notas: Conexao para atualizar saque como Efetivado.").   
    
    CREATE "ADODB.Connection" conexao.
    conexao:OPEN("data source=TAA;server=localhost", "taa", "taa", 0) NO-ERROR. 
    
    IF  ERROR-STATUS:NUM-MESSAGES > 0  THEN
        DO:
            RUN procedures/grava_log.p (INPUT "Erro na conexao com o banco de dados FireBird").
    
            RUN mensagem.w (INPUT YES,
                            INPUT "    ATENÇÃO",
                            INPUT "",
                            INPUT "Erro na conexão com o banco de",
                            INPUT "dados. Verifique a instalação",
                            INPUT "do equipamento.",
                            INPUT "").
    
            PAUSE 3 NO-MESSAGE.
            h_mensagem:HIDDEN = YES.
    
            par_flgderro = YES.
            RETURN "NOK".
        END.

    RUN procedures/grava_log.p (INPUT "Entrega de Notas: Atualizando saque como Efetivado.").
    
    CREATE "ADODB.Command" comando.
    comando:ActiveConnection = conexao.
    comando:CommandText = par_dscomand.
    
    CREATE "ADODB.RecordSet" resultado.
    resultado = comando:EXECUTE(,,) NO-ERROR.
    
    
    IF  resultado = ?  THEN
        DO: 
            RUN procedures/grava_log.p (INPUT "Erro no comando SQL.").
            
            /* fechar e liberar a conexao */
            conexao:CLOSE()          NO-ERROR.
            RELEASE OBJECT conexao   NO-ERROR.
            RELEASE OBJECT comando   NO-ERROR.
            RELEASE OBJECT resultado NO-ERROR.
    
            par_flgderro = YES.
            RETURN "NOK".
        END.

	RUN procedures/grava_log.p (INPUT "Entrega de Notas: Atualizado saque como Efetivado.").

END PROCEDURE.
/* Fim atualiza_saque */

/* ............................................................................ */
