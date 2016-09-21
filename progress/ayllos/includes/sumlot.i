/* .............................................................................

   Programa: Includes/sumlot.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah
   Data    : Outubro/91                      Ultima atualizacao: 22/04/2015

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processa parte da rotina da tela SUMLOT.

   Alteracao : 06/11/94 - Alterado para somar as capas de lote dos lotes com
                          tipo 10  e 11 (Odair).

               21/06/95 - Alterado para somar as capas de lote do tipo 12
                          (Odair).

               11/04/96 - Alterado para somar as capas de lote tipo 13 e 14
                          (Odair).

               18/02/99 - Pesquisar o lote de requisicoes conforme a agencia
                          solicitada na tela. (Deborah).

               23/03/1999 - Nao somar o tipo de lote no total a debito
                            (Deborah).
                            
               10/01/2001 - Tratar tipo de lote 21 (Deborah).
               
               11/01/2001 - Somar o total de arrecadoes (Deborah).

               24/02/2003 - Usar agencia e numero do lote para separar
                            as agencias (Margarete).

               19/09/2003 - Se lote de caixa ver associacao (Margarete).

               16/03/2004 - Mostrar lote e programa de requisicoes nao
                            batido (Margarete).

               29/06/2004 - Sem erros dar mensagem de ok (Margarete).

               14/09/2004 - Mostrar os protocolos de custodia nao batidos
                            (Deborah).

               12/12/2005 - Talao normal e TB agora na LANREQ (Magui).
               
               02/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.
               
               14/06/2010 - Tratamento para PAC 91 conforme PAC 90 (Elton).

               06/06/2011 - Incluido tratamento p/ custodia e desconto -
                            Truncagem (Guilherme/Ze).
                            
               08/06/2011 - Mostrar envelopes TAA pendentes (Evandro).
               
               23/08/2011 - Incluir tratamento do horario da crapenl e
                            controle de qtd de dias para busca de envelopes
                            (Gabriel/Evandro).
                            
               09/08/2013 - Modificado o termo "PAC" para "PA" (Douglas).
                            
               22/04/2015 - Alteracao na formatacao do campo crapenl.nrseqenv de
                            6 para 10 caracteres. (Jaison/Elton - SD: 276984)
               
............................................................................. */

    IF   craplot.cdbccxlt = 11   AND
         craplot.nrdcaixa = 0    THEN 
         DO:
             ASSIGN aux_flgerros = YES.
             PUT STREAM str_1
                 "Lote de caixa NAO ASSOCIADO ==> PA: "
                 craplot.cdagenci " Lote: " craplot.nrdolote SKIP.
         END.
                 
    IF   NOT CAN-DO("12,20,21",STRING(craplot.tplotmov))   THEN
         ASSIGN tel_qtcompln = tel_qtcompln + craplot.qtcompln.

    IF   craplot.tplotmov =  9 OR 
         craplot.tplotmov = 10 OR
         craplot.tplotmov = 14 THEN
         ASSIGN tel_vlcompap = tel_vlcompap + craplot.vlcompcr.

    IF   (craplot.qtcompln - craplot.qtinfoln) <> 0 OR
         (craplot.vlcompdb - craplot.vlinfodb) <> 0 OR
         (craplot.vlcompcr - craplot.vlinfocr) <> 0 THEN
         DO:
             ASSIGN aux_flgerros = YES.
             PUT STREAM str_1
                 "Lote NAO BATIDO ==> PA: " 
                 craplot.cdagenci " Bco/Cxa: " craplot.cdbccxlt 
                 " Lote: " craplot.nrdolote SKIP. 
         END.      

    IF   craplot.qtinfocc = craplot.qtcompcc   AND
         craplot.vlinfocc = craplot.vlcompcc   AND
         craplot.qtcompcs = craplot.qtinfocs   AND
         craplot.vlcompcs = craplot.vlinfocs   AND
         craplot.qtcompci = craplot.qtinfoci   AND
         craplot.vlcompci = craplot.vlinfoci   THEN
         .
    ELSE     
         DO: 
             ASSIGN aux_flgerros = YES.
             PUT STREAM str_1
                "Protoc. CUSTODIA nao batido => PA: "
                  craplot.cdagenci 
                 " Bco/Cxa: " craplot.cdbccxlt " Lote: " craplot.nrdolote 
                  SKIP.
         END.
END.

FOR EACH craptrq WHERE craptrq.cdcooper = glb_cdcooper NO-LOCK:

    IF   craptrq.qtinforq = craptrq.qtcomprq   AND
         craptrq.qtinfotl = craptrq.qtcomptl   THEN
         NEXT.

    IF   tel_cdagenci > 0 THEN
         IF   craptrq.cdagelot = tel_cdagenci THEN
              DO:
                  ASSIGN aux_cdprogra = ""
                         aux_flgerros = YES
                         aux_cdprogra = "LANREQ".
                  
                  PUT STREAM str_1
                      "Lote de requisicoes NAO BATIDO. PA: "
                      craptrq.cdagelot " Lote: " 
                      craptrq.nrdolote " Na " aux_cdprogra
                      SKIP.
                  
                  NEXT.
              END.
         ELSE
              NEXT.
    ELSE
         DO:
             ASSIGN aux_cdprogra = ""
                    aux_flgerros = YES
                    aux_cdprogra = "LANREQ".
                               
             PUT STREAM str_1
                 "Lote de requisicoes NAO BATIDO. PA: "
                 craptrq.cdagelot " Lote: " craptrq.nrdolote 
                 " Na " aux_cdprogra SKIP.
             
             NEXT.
         END.

END.

aux_cdagefim = IF   tel_cdagenci = 0 THEN
                    9999
               ELSE
                    tel_cdagenci.
    
/****** PROCESSAMENTO CST ******/
FOR EACH crapcst WHERE crapcst.cdcooper  = glb_cdcooper  AND
                       crapcst.dtmvtolt  = glb_dtmvtolt  AND
                       crapcst.cdagenci >= tel_cdagenci  AND
                       crapcst.cdagenci <= aux_cdagefim  AND
                       crapcst.insitprv < 2
                       NO-LOCK BREAK BY crapcst.nrdolote:
    
    IF   FIRST-OF(crapcst.nrdolote) THEN
         PUT STREAM str_1 "Ha Cheques de Custodia nao digitalizados => PA: "
                          crapcst.cdagenci " Lote: " crapcst.nrdolote
                          SKIP.
    
END.

    
/****** PROCESSAMENTO CDB ******/
FOR EACH crapcdb WHERE crapcdb.cdcooper  = glb_cdcooper       AND
                       crapcdb.dtmvtolt >= glb_dtmvtolt - 30  AND
                       crapcdb.cdagenci >= tel_cdagenci       AND
                       crapcdb.cdagenci <= aux_cdagefim
                       NO-LOCK BREAK BY crapcdb.nrborder:

    IF   crapcdb.dtlibbdc <> glb_dtmvtolt  OR
         crapcdb.insitprv >= 2             THEN
         NEXT.
                           
    IF   FIRST-OF(crapcdb.nrborder) THEN
         PUT STREAM str_1 "Ha Cheques de Desconto nao digitalizados => PA: "
                          crapcdb.cdagenci " Bordero: " crapcdb.nrborder
                          SKIP.
END.



FOR EACH crapbcx WHERE crapbcx.cdcooper = glb_cdcooper   AND 
                       crapbcx.dtmvtolt = glb_dtmvtolt   AND
                       crapbcx.cdagenci <> 90 AND /* INTERNET */
                       crapbcx.cdagenci <> 91 AND /* TAA */
                       crapbcx.cdsitbcx = 1               NO-LOCK
                       USE-INDEX crapbcx1: 
            
    IF   tel_cdagenci > 0   THEN
         IF   tel_cdagenci <> crapbcx.cdagenci   THEN
              NEXT.
            
    FIND crapope WHERE crapope.cdcooper = glb_cdcooper       AND 
                       crapope.cdoperad = crapbcx.cdopecxa   NO-LOCK NO-ERROR.
       
    ASSIGN aux_flgerros = YES.
    
    PUT STREAM str_1
        "Boletim de caixa ABERTO ==> PA: "
        crapbcx.cdagenci " Caixa:" crapbcx.nrdcaixa
        " Operador:" crapbcx.cdopecxa "-" ENTRY(1,crapope.nmoperad," ")
        SKIP.
       
END.  /*  Fim do FOR EACH  --  Leitura do crapbcx  */




/* 
   Envelopes TAA pendentes:
   - Lista envelopes nao recolhidos (SIT = 0)
   - Lista envelopes recolhidos e nao processados (SIT = 3)
   OBS.: Considera horario de corte
*/

/* Envelopes nao recolhidos */
FOR EACH crapenl WHERE
         crapenl.cdcoptfn  = glb_cdcooper                      AND
         crapenl.cdagetfn >= tel_cdagenci                      AND
         crapenl.cdagetfn <= aux_cdagefim                      AND
         crapenl.dtmvtolt >= (glb_dtmvtolt - crapcop.qtdiaenl) AND
         crapenl.cdsitenv = 0
         NO-LOCK:

    /* para envelopes nao recolhidos do dia, que foram depositados
       apos o horaio de corte, desconsidera  */
    IF   crapenl.dtmvtolt = glb_dtmvtolt   THEN
         DO:
             FIND craptab WHERE craptab.cdcooper = crapenl.cdcoptfn   AND
                                craptab.nmsistem = "CRED"             AND
                                craptab.tptabela = "GENERI"           AND
                                craptab.cdempres = 0                  AND
                                craptab.cdacesso = "HRTRENVELO"       AND
                                craptab.tpregist = crapenl.cdagetfn
                                NO-LOCK NO-ERROR.
                                
             ASSIGN aux_hrtransa = IF   AVAIL craptab   THEN
                                        INTE(craptab.dstextab)
                                   ELSE
                                        0.

             IF   NOT AVAIL craptab                 OR 
                  crapenl.hrtransa > aux_hrtransa   THEN
                  NEXT.
         END. 

    ASSIGN aux_flgerros = YES.

    PUT STREAM str_1 UNFORMATTED
               "Envelopes nao recolhidos ==> " +
               "TAA: "              + STRING(crapenl.nrterfin,"999")         + 
               " " +                                                         
               "Data do deposito: " + STRING(crapenl.dtmvtolt,"99/99/9999")  +
               " - " + STRING(INTE(crapenl.hrtransa),"HH:MM")  
               SKIP
               FILL(" ",29) +
               "Conferencia: " + STRING(crapenl.nrseqenv,"9999999999") + " " +
               "Conta/DV: "    + STRING(crapenl.nrdconta,"zzzz,zzz,9")
               SKIP
               FILL(" ",29) + "Valor: ".

    IF   crapenl.vldininf > 0   THEN
         PUT STREAM str_1 UNFORMATTED STRING(crapenl.vldininf,"zzz,zz9.99") +
                                      " - DINHEIRO" SKIP.
    ELSE
         PUT STREAM str_1 UNFORMATTED STRING(crapenl.vlchqinf,"zzz,zz9.99") +
                                      " - CHEQUES" SKIP.
END.

/* Envelopes recolhidos, ainda nao liberados */
FOR EACH crapenl WHERE
         crapenl.cdcoptfn  = glb_cdcooper                      AND
         crapenl.cdagetfn >= tel_cdagenci                      AND
         crapenl.cdagetfn <= aux_cdagefim                      AND
         crapenl.dtmvtolt >= (glb_dtmvtolt - crapcop.qtdiaenl) AND
         crapenl.cdsitenv = 3
         NO-LOCK:

    ASSIGN aux_flgerros = YES.

    PUT STREAM str_1 UNFORMATTED
               "Envelopes nao liberados  ==> " +
               "TAA: "              + STRING(crapenl.nrterfin,"999")         + 
               " " +                                                         
               "Data do deposito: " + STRING(crapenl.dtmvtolt,"99/99/9999")  +
               " - " + STRING(INTE(crapenl.hrtransa),"HH:MM")  
               SKIP
               FILL(" ",29) +
               "Conferencia: " + STRING(crapenl.nrseqenv,"9999999999") + " " +
               "Conta/DV: "    + STRING(crapenl.nrdconta,"zzzz,zzz,9")
               SKIP
               FILL(" ",29) + "Valor: ".

    IF   crapenl.vldininf > 0   THEN
         PUT STREAM str_1 UNFORMATTED STRING(crapenl.vldininf,"zzz,zz9.99") +
                                      " - DINHEIRO" SKIP.
    ELSE
         PUT STREAM str_1 UNFORMATTED STRING(crapenl.vlchqinf,"zzz,zz9.99") +
                                      " - CHEQUES" SKIP.
END.



IF   tel_cdbccxlt = 0    AND
     NOT aux_flgerros        THEN
     PUT STREAM str_1
         "NENHUMA pendencia ENCONTRADA" SKIP.
            
OUTPUT STREAM str_1 CLOSE.
            
CLEAR FRAME f_sumlot.
ASSIGN tel_cdagenci = aux_cdagenci
       tel_cdbccxlt = aux_cdbccxlt.

DISPLAY tel_cdagenci tel_cdbccxlt tel_qtcompln tel_vlcompap 
        WITH FRAME f_sumlot.
            
PAUSE (0).
            
VIEW FRAME f_moldura.
            
PAUSE(0).
           
RUN fontes/visualiza_criticas.p.

/* .......................................................................... */


