/*--------------------------------------------------- ---------------------------*/
/*  pcrap12.p - Rotina p/imprimir o valor por extenso                            */                                              
/*  Objetivo  : Rotina p/imprimir o valor por extenso (Antigo fontes/extenso.p)  */
/*-------------------------------------------------------------------------------*/

                                      
DEF INPUT  PARAMETER aux_vlnumero AS DECIMAL   DECIMALS 6 NO-UNDO.
DEF INPUT  PARAMETER aux_qtlinha1 AS INTEGER   NO-UNDO.
DEF INPUT  PARAMETER aux_qtlinha2 AS INTEGER   NO-UNDO.
DEF INPUT  PARAMETER aux_tpextens AS CHAR      NO-UNDO.
DEF OUTPUT PARAMETER glb_dslinha1 AS CHAR      NO-UNDO.
DEF OUTPUT PARAMETER glb_dslinha2 AS CHAR      NO-UNDO.

DEF            VAR aux_dslinhas   AS CHAR  EXTENT 2                  NO-UNDO.
DEF            VAR aux_qtlinhas   AS INT   EXTENT 2                  NO-UNDO.
DEF            VAR aux_inlinhas   AS INT                             NO-UNDO.

DEF            VAR aux_vlextens   AS CHAR                            NO-UNDO.
DEF            VAR aux_dsextuni   AS CHAR                            NO-UNDO.
DEF            VAR aux_dsextdz1   AS CHAR                            NO-UNDO.
DEF            VAR aux_dsextdz2   AS CHAR                            NO-UNDO.
DEF            VAR aux_dsextcen   AS CHAR                            NO-UNDO.
DEF            VAR aux_vlinteir   AS CHAR                            NO-UNDO.

DEF            VAR aux_vlconver   AS CHAR     EXTENT 5               NO-UNDO.

DEF            VAR aux_vlint001   AS CHAR                            NO-UNDO.
DEF            VAR aux_vlint002   AS CHAR                            NO-UNDO.
DEF            VAR aux_vlint003   AS CHAR                            NO-UNDO.
DEF            VAR aux_vlint004   AS CHAR                            NO-UNDO.

DEF            VAR aux_ingrandz   AS INT                             NO-UNDO.

DEF            VAR aux_vlposatu   AS INTEGER                         NO-UNDO.
DEF            VAR aux_vlposant   AS INTEGER                         NO-UNDO.
DEF            VAR aux_caracter   AS INTEGER                         NO-UNDO.
DEF            VAR hlp_dsextens   AS CHAR                            NO-UNDO.
DEF            VAR flg_doisbran   AS LOGICAL                         NO-UNDO.
DEF            VAR aux_contador   AS INTEGER                         NO-UNDO.
DEF            VAR aux_vldecima   AS INTEGER                         NO-UNDO.
DEF            VAR aux_dsvsobra   AS CHAR                            NO-UNDO.

IF  NOT CAN-DO("P,M,I",aux_tpextens)  THEN
    DO:
        glb_dslinha1 = "TIPO DE PARAMETRO ERRADO".
        RETURN.
    END.

IF   aux_vlnumero = 0 AND aux_tpextens = "P" THEN
     DO:
         glb_dslinha1 = "SEM INDICE PERCENTUAL".
         RETURN.
     END.

IF   aux_vlnumero = 0 AND aux_tpextens = "I" THEN
     DO:
         glb_dslinha1 = "ZERO".
         RETURN.
     END.

IF   aux_vlnumero = 0                OR
     aux_vlnumero > 99999999999.99   THEN
     DO:
         glb_dslinha1 = "VALOR ZERADO OU MUITO GRANDE PARA GERAR O EXTENSO".
         RETURN.
     END.

IF   INT(SUBSTR(STRING(aux_vlnumero,"999999999999.99"),14,02)) > 0 AND
     aux_tpextens = "I" THEN
     DO:
       glb_dslinha1 = "VALOR COM DECIMAIS, NAO COMPATIVEL COM NUMEROS INTEIROS".
         RETURN.
     END.

IF   aux_vlnumero > 100 AND aux_tpextens = "P" THEN
     DO:
         glb_dslinha1 = "INDICE PERCENTUAL ACIMA DO LIMITE".
         RETURN.
     END.

ASSIGN aux_dsextuni = "UM ,DOIS ,TRES ,QUATRO ,CINCO ,SEIS ,SETE ,OITO ,NOVE "

       aux_dsextdz1 = "DEZ ,VINTE ,TRINTA ,QUARENTA ,CINQUENTA ,SESSENTA ," +
                      "SETENTA ,OITENTA ,NOVENTA "

       aux_dsextdz2 = "DEZ ,ONZE ,DOZE ,TREZE ,QUATORZE ,QUINZE ,DEZESSEIS ," +
                      "DEZESSETE ,DEZOITO ,DEZENOVE "

       aux_dsextcen = "CENTO ,DUZENTOS ,TREZENTOS ,QUATROCENTOS ,QUINHENTOS ," +
                      "SEISCENTOS ,SETECENTOS ,OITOCENTOS ,NOVECENTOS "

       aux_vlconver[1] = SUBSTR(STRING(aux_vlnumero,"999999999999.99"),01,03)
       aux_vlconver[2] = SUBSTR(STRING(aux_vlnumero,"999999999999.99"),04,03)
       aux_vlconver[3] = SUBSTR(STRING(aux_vlnumero,"999999999999.99"),07,03)
       aux_vlconver[4] = SUBSTR(STRING(aux_vlnumero,"999999999999.99"),10,03)
       aux_vlconver[5] = "0" +
                         SUBSTR(STRING(aux_vlnumero,"999999999999.99"),14,02)
       aux_vlinteir    = SUBSTR(STRING(aux_vlnumero,"999999999999.99"),01,12)

       aux_vldecima    = INTEGER(SUBSTR(
                                STRING(aux_vlnumero,"999999999999.99"),14,02))

       aux_vlextens    = ""

       aux_qtlinhas[1] = aux_qtlinha1
       aux_qtlinhas[2] = aux_qtlinha2.

DO aux_ingrandz = 1 TO 5:

   ASSIGN aux_vlint001 = SUBSTRING(aux_vlconver[aux_ingrandz],1,1)
          aux_vlint002 = SUBSTRING(aux_vlconver[aux_ingrandz],2,1)
          aux_vlint003 = SUBSTRING(aux_vlconver[aux_ingrandz],3,1)
          aux_vlint004 = SUBSTRING(aux_vlconver[aux_ingrandz],2,2).

   IF   INTEGER(aux_vlint001) > 0   THEN

        IF   aux_vlint001 = "1"   AND   aux_vlint004 = "00"   THEN
             aux_vlextens = aux_vlextens + "CEM ".
        ELSE
             aux_vlextens = aux_vlextens +
                                ENTRY(INTEGER(aux_vlint001),aux_dsextcen).

   IF   INTEGER(aux_vlint004) >= 10   AND   INTEGER(aux_vlint004) <= 19 THEN
        IF   aux_ingrandz = 5 AND aux_vlextens <> "" THEN
             aux_vlextens = aux_vlextens + "E " +
                            IF   aux_tpextens = "P" AND aux_vlint004 = "10" THEN
                                 ""
                            ELSE
                            ENTRY(INTEGER(aux_vlint004) - 9,aux_dsextdz2).
        ELSE
             aux_vlextens = aux_vlextens + (IF aux_vlint001 <> "0"
                                               THEN "E " ELSE "") +
                            IF   aux_tpextens = "P" AND
                                 aux_vlint004 = "10" THEN "" ELSE
                            ENTRY(INTEGER(aux_vlint004) - 9,aux_dsextdz2).


   IF   INTEGER(aux_vlint002) >= 2   THEN
        IF   aux_ingrandz = 5 AND aux_vlextens <> "" THEN
             aux_vlextens = aux_vlextens + "E " +
                            (IF  aux_tpextens = "P" AND
                              CAN-DO("10,20,30,40,50,60,70,80,90",aux_vlint004)
                                 THEN ""
                            ELSE
                                 ENTRY(INTEGER(aux_vlint002),aux_dsextdz1)).
        ELSE
             aux_vlextens = aux_vlextens +
                            (IF aux_vlint001 <> "0"  THEN  "E " ELSE "")  +
                            (IF aux_tpextens = "P" AND
                              CAN-DO("10,20,30,40,50,60,70,80,90",aux_vlint004)
                              AND (aux_vlint002 = "0" OR aux_vlextens = "")
                              THEN "" ELSE
                              ENTRY(INTEGER(aux_vlint002),aux_dsextdz1)).

   IF   CAN-DO("10,20,30,40,50,60,70,80,90",aux_vlint004)  AND
        aux_tpextens = "P"  AND  aux_ingrandz = 5 THEN
        aux_vlextens = aux_vlextens +
                          ENTRY(INTEGER(SUBSTR(aux_vlint004,1,1)),aux_dsextuni).

   IF   INTEGER(aux_vlint003) > 0    AND
       (INTEGER(aux_vlint004) < 10   OR
        INTEGER(aux_vlint004) > 19)  THEN
        IF   aux_ingrandz = 5 AND aux_vlextens <> "" THEN
             aux_vlextens = aux_vlextens + "E " +
                            ENTRY(INTEGER(aux_vlint003),aux_dsextuni).
        ELSE
             aux_vlextens = aux_vlextens + (IF (aux_vlint001 <> "0" OR
                                                aux_vlint002 <> "0")
                                                THEN "E " ELSE "") +
                             ENTRY(INTEGER(aux_vlint003),aux_dsextuni).

   IF   aux_ingrandz = 1   THEN               /*  Grandeza 1 - para o bilhao  */
        DO:
            IF   INTEGER(aux_vlconver[aux_ingrandz]) > 0   THEN
                 aux_vlextens = aux_vlextens +
                                IF  INTEGER(aux_vlconver[aux_ingrandz]) > 1
                                    THEN "BILHOES, " ELSE "BILHAO, ".
        END.
   ELSE
   IF   aux_ingrandz = 2   THEN               /*  Grandeza 2 - para o milhao  */
        DO:
            IF   INTEGER(aux_vlconver[aux_ingrandz]) > 0   THEN
                 aux_vlextens = aux_vlextens +
                                IF  INTEGER(aux_vlconver[aux_ingrandz]) > 1
                                    THEN "MILHOES, " ELSE "MILHAO, ".
        END.
   ELSE
   IF   aux_ingrandz = 3   THEN               /*  Grandeza 3 - para o milhar  */
        DO:
            IF   INTEGER(aux_vlconver[aux_ingrandz]) > 0   THEN
                 aux_vlextens = aux_vlextens +
                                IF  INTEGER(aux_vlconver[aux_ingrandz]) > 0
                                    THEN "MIL, " ELSE "".
        END.
   ELSE
   IF   aux_ingrandz = 4   THEN              /*  Grandeza 4 - para a centena  */
        DO:
            IF   DECIMAL(aux_vlinteir) > 0   THEN
                 DO:
                     IF   DECIMAL(aux_vlinteir) = 1   THEN
                          aux_vlextens =  aux_vlextens +
                                          IF   aux_tpextens = "M" THEN
                                               "REAL "
                                          ELSE
                                          IF   aux_tpextens = "P" AND
                                               aux_vldecima > 0 THEN
                                               "INTEIRO "
                                          ELSE
                                          IF   aux_tpextens = "P" AND
                                               aux_vldecima = 0 THEN
                                               "POR CENTO "
                                          ELSE "".
                     ELSE
                          aux_vlextens =  aux_vlextens +
                                          IF   aux_tpextens = "M" THEN
                                               "REAIS "
                                          ELSE
                                          IF   aux_tpextens = "P" AND
                                               aux_vldecima > 0 THEN
                                               "INTEIROS "
                                          ELSE
                                          IF   aux_tpextens = "P" AND
                                               aux_vldecima = 0 THEN
                                               "POR CENTO "
                                          ELSE "".

                /*  IF   DECIMAL(aux_vlconver[5]) = 0   AND
                                  aux_tpextens <> "I"    THEN
                          aux_vlextens = SUBSTR(aux_vlextens,1,
                                            LENGTH(aux_vlextens) - 1) + ".".  */
                          /* aux_vlextens = aux_vlextens + ".". */
                 END.
        END.
   ELSE
   IF   aux_ingrandz = 5   THEN              /*  Grandeza 5 - para o centavo  */
        IF   INTEGER(aux_vlint004) > 0   THEN
             aux_vlextens = aux_vlextens +
                            IF   aux_tpextens = "M"  AND
                                 INTEGER(aux_vlint004) > 1 THEN
                                 "CENTAVOS"
                            ELSE
                            IF   aux_tpextens = "M"  AND
                                 INTEGER(aux_vlint004) = 1 THEN
                                 "CENTAVO"
                            ELSE
                            IF   aux_tpextens = "P"  AND
                                 SUBSTR(STRING(aux_vldecima,"99"),1,2) = "10"
                                 THEN   "DECIMO POR CENTO"
                            ELSE
                            IF   aux_tpextens = "P"  AND
                                 SUBSTR(STRING(aux_vldecima,"99"),2,1) = "0"
                                 THEN   "DECIMOS POR CENTO"
                            ELSE
                            IF   aux_tpextens = "P"  AND
                                 SUBSTR(STRING(aux_vldecima,"99"),1,2) = "01"
                                 THEN   "CENTESIMO POR CENTO"
                            ELSE
                            IF   aux_tpextens = "P"  AND
                                 aux_vldecima > 1
                                 THEN   "CENTESIMOS POR CENTO"
                            ELSE "".

END.  /*  Fim do DO .. TO  */

aux_inlinhas = 1.

{ include/separa.i }

IF    LENGTH(aux_dsvsobra) > 0 THEN
      DO:
          ASSIGN aux_inlinhas = 2
                 aux_vlextens = aux_dsvsobra.

          { include/separa.i }

   END.

ASSIGN glb_dslinha1 = aux_dslinhas[1]
       glb_dslinha2 = IF   aux_inlinhas = 1 AND aux_tpextens = "M" THEN
                           FILL("*", aux_qtlinha2)
                      ELSE
                           aux_dslinhas[2].

/* pcrap12.p */
