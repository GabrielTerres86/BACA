/*..............................................................................

   Programa: fontes/crps_cnab.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Evandro
   Data    : Agosto/2004.                       Ultima atualizacao: 10/10/2012

   Dados referentes ao programa:

   Frequencia: Diario.
   Objetivo  : Gerar o arquivo de extratos no padrao CNAB (Evandro).

   Alteracoes: 31/01/2012 - Ajuste na posicao 170 a 172 do segmento E, pois 
                            esta utilizando cdhistor que eh maior que o espaco 
                            disponibilizado no padrao (David).
                            
               10/10/2012 - Tratamento para novo campo da 'craphis' de descrição
                            do histórico em extratos (Lucas) [Projeto Tarifas].

.............................................................................*/
{ includes/var_batch.i } 

{ includes/var_cnab.i }   /* Declaracao da tabela cratarq */

DEF     INPUT PARAM par_nmarqimp AS CHAR                             NO-UNDO.
DEF     INPUT PARAM par_cdsegmto AS CHAR                             NO-UNDO.
        /* "E" = Extrato   
           "H" = Emprestimo */

DEF     STREAM str_1. /*para o arquivo*/

DEF     VAR   aux_dsdlinha      AS CHAR      FORMAT "x(240)"         NO-UNDO.
DEF     VAR   aux_nrseqlan      AS INT       INIT 0                  NO-UNDO.
DEF     VAR   aux_qtreglot      AS INT       INIT 0                  NO-UNDO.
DEF     VAR   aux_qtregtot      AS INT       INIT 0                  NO-UNDO.
DEF     VAR   aux_vltotdeb      AS DECIMAL   INIT 0                  NO-UNDO.
DEF     VAR   aux_vltotcre      AS DECIMAL   INIT 0                  NO-UNDO.

OUTPUT STREAM str_1 TO VALUE("arq/" + par_nmarqimp).

FIND cratarq WHERE cratarq.tpregist = 0 NO-LOCK NO-ERROR.

glb_nrcalcul = INTEGER(STRING(cratarq.cdagenci) + "0").

RUN fontes/digfun.p.

glb_nrcalcul = INTEGER(SUBSTRING(STRING(glb_nrcalcul),
                                 LENGTH(STRING(glb_nrcalcul)), 1)).

FOR EACH cratarq NO-LOCK BY cratarq.tpregist
                         BY cratarq.dtlanmto.

    ASSIGN aux_dsdlinha = ""
           aux_qtregtot = aux_qtregtot + 1.

    IF   cratarq.tpregist = 0   THEN
         DO:
             aux_dsdlinha = STRING(cratarq.cdbccxlt,"999") +
                            STRING(cratarq.nrdolote,"9999") +
                            STRING(cratarq.tpregist,"9") + "         " +
                            STRING(cratarq.inpessoa,"9") +
                            STRING(cratarq.nrcpfcgc,"99999999999999") +
                            "                    " + 
                            STRING(cratarq.cdagenci,"99999") + 
                            STRING(glb_nrcalcul,"9") +
                            STRING(cratarq.nrdconta,"999999999999") +
                            STRING(cratarq.nrdigcta,"9") + 
                            STRING(glb_nrcalcul,"9") +
                            STRING(cratarq.nmprimtl,"x(30)") +
                            STRING(cratarq.nmrescop,"x(30)") + "          " +
                            STRING(cratarq.cdremess,"9") +
                            STRING(cratarq.dtmvtolt,"99999999") +
                            STRING(cratarq.hrtransa,"999999") + 
                            "000001" +  "060" + "00000" + 
                            "                    " +
                            "                    ".
                            /*o resto eh exclusivo FEBRABAN*/
         END.
    ELSE
    IF   cratarq.tpregist = 1   THEN
         DO:
             aux_qtreglot = aux_qtreglot + 1.
         
             IF   par_cdsegmto = "E"   THEN
                  DO:
                      aux_dsdlinha = STRING(cratarq.cdbccxlt,"999") +
                                     STRING(cratarq.nrdolote,"9999") +
                                     STRING(cratarq.tpregist,"9") + "E" +
                                     "04" + "40" + "032" + " " +
                                     STRING(cratarq.inpessoa,"9") + 
                                     STRING(cratarq.nrcpfcgc,"99999999999999") +
                                     "                    " + 
                                     STRING(cratarq.cdagenci,"99999") +
                                     STRING(glb_nrcalcul,"9") +
                                     STRING(cratarq.nrdconta,"999999999999") +
                                     STRING(cratarq.nrdigcta,"9") + 
                                     STRING(glb_nrcalcul,"9") +
                                     STRING(cratarq.nmprimtl,"x(30)") +
                                   "                                        " +
                                     STRING(cratarq.dtsldini,"99999999") +
                                     REPLACE(STRING(cratarq.vlsldini,
                                               "9999999999999999.99"),",","") +
                                     STRING(cratarq.insldini,"x(1)") + 
                                     "F" + "BRL" + "00001". 
                                     /* o resto eh exlusivo FEBRABAN*/
                  END.
             ELSE
             IF   par_cdsegmto = "H"   THEN
                  DO:
                      aux_dsdlinha = STRING(cratarq.cdbccxlt,"999") + "0000" +
                                     STRING(cratarq.tpregist,"9") + " " +
                                     STRING(cratarq.tpservco,"99") + "000" +
                                     STRING(cratarq.dtmesref,"99") +
                                     STRING(cratarq.dtanoref,"9999") +
                                     STRING(cratarq.nrdolote,"9999") + 
                                     "0000001" +
                                     STRING(cratarq.inpessoa,"9") + 
                                     STRING(cratarq.nrcpfcgc,"99999999999999") +
                                     STRING(cratarq.cdempres, "999999") + 
                                     STRING(cratarq.cdconven, "x(20)") +
                                     STRING(cratarq.cdagenci,"99999") +
                                     STRING(glb_nrcalcul,"9") +
                                     STRING(cratarq.nrdconta,"999999999999") +
                                     STRING(cratarq.nrdigcta,"9") + 
                                     STRING(glb_nrcalcul,"9") +
                                     STRING(cratarq.nmresemp,"x(30)") + "00" +
                                     FILL(" ", 116).
                  END.
         END.
    ELSE
    IF   cratarq.tpregist = 3   THEN
         DO:
             aux_nrseqlan = aux_nrseqlan + 1.

             IF   par_cdsegmto = "E"   THEN
                  DO:
                      IF   cratarq.indebcre = "C"   THEN
                           aux_vltotcre = aux_vltotcre + cratarq.vllanmto.
                      ELSE
                           aux_vltotdeb = aux_vltotdeb + cratarq.vllanmto.

                      aux_dsdlinha = STRING(cratarq.cdbccxlt,"999") +
                                     STRING(cratarq.nrdolote,"9999") +
                                     STRING(cratarq.tpregist,"9") + 
                                     STRING(aux_nrseqlan,"99999") + "E" + 
                                     "   " + 
                                     STRING(cratarq.inpessoa,"9") + 
                                     STRING(cratarq.nrcpfcgc,"99999999999999") +
                                     "                    " + 
                                     STRING(cratarq.cdagenci,"99999") +
                                     STRING(glb_nrcalcul,"9") +
                                     STRING(cratarq.nrdconta,"999999999999") + 
                                     STRING(cratarq.nrdigcta,"9") +
                                     STRING(glb_nrcalcul,"9") +
                                     STRING(cratarq.nmprimtl,"x(30)") + 
                                     "      " + "   " + "00" +
                                     "                    " +
                                     STRING(cratarq.iniscpmf,"x(1)") +
                                     STRING(cratarq.dtliblan,"99999999") +
                                     STRING(cratarq.dtlanmto,"99999999") + 
                                     REPLACE(STRING(cratarq.vllanmto,
                                     "9999999999999999.99"),",","") +
                                     STRING(cratarq.indebcre,"x(1)") + 
                                     "000" + 
                                     STRING(cratarq.cdhistor,"9999") + 
                                     STRING(cratarq.dsextrat,"x(25)") +
                                     cratarq.nrdocmto.
                                     /*o resto seria o complemento*/
                  END.
             ELSE
             IF   par_cdsegmto = "H"   THEN
                  DO:
                      aux_vltotdeb = aux_vltotdeb + cratarq.vlpreemp.
                      
                      aux_dsdlinha = STRING(cratarq.cdbccxlt,"999") +
                                     STRING(cratarq.nrdolote,"9999") +
                                     STRING(cratarq.tpregist,"9") + 
                                     STRING(aux_nrseqlan,"99999") + "H" + 
                                     STRING(cratarq.tpmovmto,"9") + 
                                     STRING(cratarq.nmprimtl,"x(30)") + 
                                     STRING(cratarq.cdempres,"999999") +
                                     STRING(cratarq.nrcpfcgc,"99999999999") +
                                     STRING(cratarq.nrcadast,"999999999999") 
                                     + "0" + "   00000000000000000 " +
                                     STRING(cratarq.tpoperac,"9") + 
                                     STRING(cratarq.dtdiavec,"99") +
                                     STRING(cratarq.dtmesvec,"99") +
                                     STRING(cratarq.dtanovec,"9999") +
                                     STRING(cratarq.qtprepag,"99") +
                                     STRING(cratarq.qtpreemp,"99") +
                                     STRING(cratarq.dtdpagto,"99999999") + 
                                     STRING(cratarq.dtultpag,"99999999") + 
                                     REPLACE(STRING(cratarq.vlemprst,
                                             "9999999.99"), ",", "") + 
                                     REPLACE(STRING(cratarq.vlemprst,
                                             "9999999.99"), ",", "") + 
                                     REPLACE(STRING(cratarq.vlpreemp,
                                             "9999999.99"), ",", "") + 
                                     REPLACE(STRING(cratarq.vlsdeved,
                                             "9999999.99"), ",", "") +
                                     STRING(cratarq.nrctremp,
                                                  "99999999999999999999") +   
                                     FILL("0", 20) + FILL(" ",39).
                  END.
         END.
    ELSE
    IF   cratarq.tpregist = 5   THEN
         DO:
             ASSIGN aux_qtreglot = aux_qtreglot + 1
                    aux_qtreglot = aux_qtreglot + aux_nrseqlan.
             
             IF   par_cdsegmto = "E"   THEN
                  DO:
                      aux_dsdlinha = STRING(cratarq.cdbccxlt,"999") +
                                     STRING(cratarq.nrdolote,"9999") +
                                     STRING(cratarq.tpregist,"9") + 
                                     "         " + 
                                     STRING(cratarq.inpessoa,"9") +
                                     STRING(cratarq.nrcpfcgc,"99999999999999") +
                                     "                    " +
                                     STRING(cratarq.cdagenci,"99999") +
                                     STRING(glb_nrcalcul,"9") +
                                     STRING(cratarq.nrdconta,"999999999999") + 
                                     STRING(cratarq.nrdigcta,"9") +
                                     STRING(glb_nrcalcul,"9") +
                                     "                " +
                                     REPLACE(STRING(cratarq.vlmais24,
                                               "9999999999999999.99"),",","") +
                                     REPLACE(STRING(cratarq.vllimite,
                                               "9999999999999999.99"),",","") +
                                     REPLACE(STRING(cratarq.vlmeno24,
                                               "9999999999999999.99"),",","") +
                                     STRING(cratarq.dtsldfin,"99999999") +
                                     REPLACE(STRING(cratarq.vlsldfin,
                                               "9999999999999999.99"),",","") +
                                     STRING(cratarq.insldfin,"9") + "F" + 
                                     STRING(aux_qtreglot,"999999") + 
                                     REPLACE(STRING(aux_vltotdeb,
                                               "9999999999999999.99"),",","") +
                                     REPLACE(STRING(aux_vltotcre,
                                               "9999999999999999.99"),",","") +
                                     "                            ".
                  END.
             ELSE
             IF   par_cdsegmto = "H"   THEN
                  DO:
                      aux_dsdlinha = STRING(cratarq.cdbccxlt,"999") +
                                     STRING(cratarq.nrdolote,"9999") +
                                     STRING(cratarq.tpregist,"9") + 
                                     "0000001" + 
                                     STRING(aux_qtreglot,"999999") + 
                                     STRING(aux_nrseqlan,"99999") + 
                                     REPLACE(STRING(aux_vltotdeb,
                                              "9999999999999.99"),",","") +
                                     STRING(aux_nrseqlan,"99999") + 
                                     REPLACE(STRING(aux_vltotdeb,
                                              "9999999999999.99"),",","") +
                                     FILL("0",49) + FILL(" ",130).
                  END.
         END.
    ELSE
    IF   cratarq.tpregist = 9   THEN
         DO:
             aux_dsdlinha = STRING(cratarq.cdbccxlt,"999") +
                            STRING(cratarq.nrdolote,"9999") +
                            STRING(cratarq.tpregist,"9") + "         " +
                            "000001" + STRING(aux_qtregtot,"999999") +
                            "000001". /*o resto e exclusivo FEBRABAN*/
         END.
         
    
    IF   cratarq.tpregist <> 9  THEN
         DO:
             PUT STREAM str_1 aux_dsdlinha SKIP.           
             DOWN STREAM str_1.
         END.
    ELSE
         PUT STREAM str_1 aux_dsdlinha.
        
END.

OUTPUT STREAM str_1 CLOSE.  
/*...........................................................................*/ 
