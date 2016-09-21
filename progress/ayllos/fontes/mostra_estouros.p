/* .............................................................................
   Programa: Fontes/estour.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Elton
   Data    : Novembro/06.                        Ultima atualizacao: 10/11/2006

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Rotina que apresenta os registros de devolucoes de cheques.

   Alteracoes: 

..............................................................................*/

DEF VAR tel_cdhisest    AS CHAR                             NO-UNDO.
DEF VAR tel_dscodatu    AS CHAR                             NO-UNDO.
DEF VAR tel_cdobserv    AS CHAR                             NO-UNDO.
DEF VAR tel_dsobserv    AS CHAR                             NO-UNDO.
DEF VAR tel_dscodant    AS CHAR                             NO-UNDO.
DEF VAR aux_flgretor    AS LOGICAL                          NO-UNDO.
DEF VAR aux_regexist    AS LOGICAL                          NO-UNDO.


{ includes/var_online.i }
{ includes/var_atenda.i }

FORM SKIP
     "Seq.     Inicio Dias Historico        Valor est/devol" AT 2
     "Conta base Documento" AT 56
     "Observacoes      Limite  credito De         Para" AT 23               
 "----- ---------- ---- ---------------- --------------- ---------- ----------"     AT 1                                                           
     WITH ROW 9 COLUMN 2  SIDE-LABELS OVERLAY  SIZE 78 by 13   
     TITLE "Estouro e Devolucoes de Cheques"     
     FRAME f_estour.

FORM 
     crapneg.nrseqdig AT  1   FORMAT        "zzzz9"
     crapneg.dtiniest AT  7   FORMAT        "99/99/9999"
     crapneg.qtdiaest AT 18   FORMAT        "zzzz"
     tel_cdhisest     AT 23   FORMAT        "x(15)"
     crapneg.vlestour AT 39   FORMAT        "z,zzz,zzz,zz9.99"
     crapneg.nrdctabb AT 56   FORMAT        "zzzz,zzz,z"
     crapneg.nrdocmto AT 67   FORMAT        "zzz,zzz,z"
     tel_cdobserv     AT 23   FORMAT        "x(2)"
     tel_dsobserv     AT 26   FORMAT        "x(15)"
     crapneg.vllimcre AT 42   FORMAT        "zzzzzz,zz9.99"
     tel_dscodant     AT 56   FORMAT        "x(10)"
     tel_dscodatu     AT 67   FORMAT        "x(10)"
     WITH ROW 13 COLUMN 3 OVERLAY 4 DOWN  NO-LABEL NO-BOX  
     FRAME f_histori.

VIEW FRAME f_estour .

PAUSE 0.

ASSIGN aux_contador = 0.


FOR EACH crapneg WHERE crapneg.cdcooper = glb_cdcooper  AND
                       crapneg.nrdconta = tel_nrdconta
                       USE-INDEX crapneg1 NO-LOCK:

       ASSIGN aux_regexist = TRUE
              aux_contador = aux_contador + 1.

       IF   aux_contador = 1 THEN
            IF   aux_flgretor  THEN
                 DO:
                 
                     PAUSE MESSAGE
                          "Tecle <Entra> para continuar ou <Fim> para encerrar".
                     CLEAR FRAME f_histori ALL NO-PAUSE.
                 END.
            ELSE
                 aux_flgretor = TRUE.

       ASSIGN tel_cdhisest = ""
              tel_cdobserv = ""
              tel_dsobserv = ""
              tel_dscodant = ""
              tel_dscodatu = "".

       IF   crapneg.cdhisest = 0 THEN
            tel_cdhisest = "Admissao socio".
       ELSE
       IF   crapneg.cdhisest = 1 THEN
            tel_cdhisest = "Devolucao Chq.".
       ELSE
       IF   crapneg.cdhisest = 2 THEN
            tel_cdhisest = "Alt. Tipo Conta".
       ELSE
       IF   crapneg.cdhisest = 3 THEN
            tel_cdhisest = "Alt. Sit. Conta".
       ELSE
       IF   crapneg.cdhisest = 4 THEN
            tel_cdhisest = "Credito Liquid.".
       ELSE
       IF   crapneg.cdhisest = 5 THEN
            tel_cdhisest = "Estouro".
       ELSE
       IF   crapneg.cdhisest = 6 THEN
            tel_cdhisest = "Notificacao".

       IF   (crapneg.cdhisest = 1 AND crapneg.dtfimest <> ?) THEN
            tel_dscodatu = "  ACERTADO".
                            
       IF   (crapneg.cdhisest = 1 OR (crapneg.cdhisest = 5 AND
            crapneg.cdobserv > 0))   THEN
            DO:
                FIND crapali WHERE crapali.cdalinea = crapneg.cdobserv 
                                   NO-LOCK NO-ERROR.

                IF   NOT AVAILABLE crapali  THEN
                     IF    crapneg.cdhisest = 1 THEN
                           ASSIGN tel_dsobserv = 
                                      "Alinea "+ STRING(crapneg.cdobserv)
                                  tel_cdobserv = "".
                     ELSE
                           ASSIGN tel_cdobserv = ""
                                  tel_dsobserv = "" .
                ELSE
                     DO:
                        tel_dsobserv = crapali.dsalinea.
                        tel_cdobserv = STRING(crapali.cdalinea).
                     END.
            END.

       IF   crapneg.cdhisest = 2 THEN
            DO:
                FIND craptip WHERE craptip.cdcooper = glb_cdcooper AND
                                   craptip.cdtipcta = crapneg.cdtctant
                                   NO-LOCK NO-ERROR.
            
                IF   NOT AVAILABLE craptip THEN
                     tel_dscodant = STRING(crapneg.cdtctant).
                ELSE
                     tel_dscodant = craptip.dstipcta.

                FIND craptip WHERE craptip.cdcooper = glb_cdcooper AND
                                   craptip.cdtipcta = crapneg.cdtctatu
                                   NO-LOCK NO-ERROR.

                IF   NOT AVAILABLE craptip THEN
                     tel_dscodatu = STRING(crapneg.cdtctatu).
                ELSE
                     tel_dscodatu = craptip.dstipcta.
            END.

       IF   crapneg.cdhisest = 3 THEN
            DO:
                IF   crapneg.cdtctant = 0  THEN
                     tel_dscodant = STRING(crapneg.cdtctant).
                ELSE
                     IF   crapneg.cdtctant = 1 THEN
                          tel_dscodant = "NORMAL".
                     ELSE
                          tel_dscodant = "ENCERRADA".

                IF   crapneg.cdtctatu = 0  THEN
                     tel_dscodatu = STRING(crapneg.cdtctatu).
                ELSE
                     IF   crapneg.cdtctatu = 1 THEN
                          tel_dscodatu = "NORMAL".
                     ELSE
                          tel_dscodatu = "ENCERRADA".
            END.

       IF   crapneg.vlestour > 0   THEN
            COLOR DISPLAY MESSAGE crapneg.vlestour WITH FRAME f_histori.
       ELSE
            COLOR DISPLAY NORMAL crapneg.vlestour WITH FRAME f_histori.

       DISPLAY   crapneg.nrseqdig crapneg.dtiniest crapneg.qtdiaest
                 tel_cdhisest     crapneg.vlestour WHEN crapneg.vlestour > 0
                 crapneg.nrdctabb crapneg.nrdocmto tel_cdobserv tel_dsobserv
                 crapneg.vllimcre WHEN crapneg.vllimcre > 0
                 tel_dscodant     tel_dscodatu
                 WITH FRAME f_histori NO-LABELS.

       IF   aux_contador = 4   THEN
            aux_contador = 0.
       ELSE
            DOWN WITH FRAME f_histori.

   END.
/*  Fim do FOR EACH  --  Leitura dos negativos automaticos  */


IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN    /*   F4 OU FIM   */
     DO:
         HIDE FRAME f_histori NO-PAUSE.
         HIDE FRAME f_estour NO-PAUSE.
         RETURN.
     END.

IF   aux_contador <= 4   THEN
     DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

        PAUSE MESSAGE "Tecle <Fim> para encerrar".
        LEAVE.

     END.  /*  Fim do DO WHILE TRUE  */

HIDE FRAME f_histori NO-PAUSE.
HIDE FRAME f_estour NO-PAUSE.


