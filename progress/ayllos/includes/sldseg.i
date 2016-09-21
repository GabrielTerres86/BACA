/* ..........................................................................

   Programa: Includes/sldseg.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Junho/97.                           Ultima atualizacao: 23/11/2006

   Dados referentes ao programa:

   Frequencia: Diario (On-line/Batch)
   Objetivo  : Rotina de leitura dos seguros.

   Alteracoes: 11/11/97 - Alterado para permitir substituicao de seguro AUTO
                          com pagamento a vista (Edson).

               02/08/1999 - Tratar seguro de vida em grupo (Deborah).

               18/01/2000 - Trata seguro prestamista (Deborah).

               11/12/2003 - Desprezar seguros vencidos ou cancelados a mais 
                            de um ano (Deborah).
                            
               24/03/2005 - Tratamento para tipo de seguro 11 - CASA (Evandro).
               
               01/02/2006 - Unificacao dos Bancos - SQLWorks - Luciane.

               23/11/2006 - Ajuste na demonstracao de quantidade de prestacoes
                            pagas, se for seguro tipo 11, mostrar o que 
                            realmente esta no crapseg.qtprepag, independente do
                            indicador de debito. (Julio)
............................................................................. */

ASSIGN aux_contador = 0
       aux_qtsegass = 0
       aux_vltotseg = 0
       s_chextent   = 0
       s_chlist     = "".

/*  Leitura da poupanca programada  */

FOR EACH crapseg WHERE crapseg.cdcooper = glb_cdcooper  AND
                       crapseg.nrdconta = tel_nrdconta  NO-LOCK:

    IF   (crapseg.cdsitseg = 2 AND
         crapseg.dtcancel < (glb_dtmvtolt - 365)) OR
         (crapseg.cdsitseg = 4 AND
         crapseg.dtfimvig < (glb_dtmvtolt - 365)) THEN
         NEXT.
         
    ASSIGN aux_contador = aux_contador + 1
           aux_qtsegass = aux_qtsegass + 1

           s_chlist[aux_contador] = " " +
                   STRING(crapseg.dtiniseg,"99/99/9999")     + " " +
                   STRING(crapseg.nrctrseg,"zzz,zzz,zz9")        + "  " +
                   STRING(DAY(crapseg.dtdebito),"99")        + " " +
                   (IF (crapseg.tpseguro = 1 OR
                        crapseg.tpseguro = 11 ) THEN "CASA" ELSE
                       IF crapseg.tpseguro = 2 THEN "AUTO"
                       ELSE IF crapseg.tpseguro = 3 THEN "VIDA"
                               ELSE 
                               IF crapseg.tpseguro = 4 THEN "PRST"
                               ELSE "    ") + "  " +
                   STRING(crapseg.vlpreseg,"zzz,zzz,zz9.99") + " " +
                   STRING(crapseg.dtinivig,"99/99/9999") + "  "

           s_nrctrseg[aux_contador] = crapseg.nrctrseg
           s_tpseguro[aux_contador] = crapseg.tpseguro
           s_recid[aux_contador]    = RECID(crapseg)
           s_cdtiparq[aux_contador] = 0  /* IF crapseg.flgunica THEN 1 ELSE 0 */

           s_qtprevig[aux_contador] = IF crapseg.tpseguro = 11 THEN
                                         crapseg.qtprepag
                                      ELSE
                                         (crapseg.qtprepag -
                                          (IF crapseg.indebito > 0 THEN 
                                              1 ELSE 0)).

    IF   crapseg.cdsitseg = 1   THEN
         ASSIGN s_chlist[aux_contador] = s_chlist[aux_contador] + "Ativo"
                aux_vltotseg = aux_vltotseg + IF crapseg.flgunica
                                                 THEN 0
                                                 ELSE crapseg.vlpreseg.
    ELSE
    IF   crapseg.cdsitseg = 2   THEN
         s_chlist[aux_contador] = s_chlist[aux_contador] + "Cancelado".
    ELSE
    IF   crapseg.cdsitseg = 3   THEN
         s_chlist[aux_contador] = s_chlist[aux_contador] + "S" +
                                  TRIM(STRING(crapseg.nrctratu,"zzzzz,zz9")).
    ELSE
    IF   crapseg.cdsitseg = 4   THEN
         s_chlist[aux_contador] = s_chlist[aux_contador] + "Vencido".
    ELSE
         s_chlist[aux_contador] = s_chlist[aux_contador] + "?????????".
         
    IF   crapseg.tpseguro = 3 OR crapseg.tpseguro = 4 THEN
         DO:
             FIND crawseg WHERE crawseg.cdcooper = glb_cdcooper      AND
                                crawseg.nrdconta = crapseg.nrdconta  AND
                                crawseg.nrctrseg = crapseg.nrctrseg 
                                NO-LOCK NO-ERROR.
                                
             IF   AVAILABLE crawseg THEN
                  s_recid[aux_contador] = RECID(crawseg).
         END.

END.  /*  Fim da leitura do crapseg  */

FOR EACH crawseg WHERE crawseg.cdcooper = glb_cdcooper  AND
                       crawseg.nrdconta = tel_nrdconta  AND 
                       NOT CAN-DO("3,4",TRIM(STRING(crawseg.tpseguro,"z9")))
                       NO-LOCK.

    IF   CAN-FIND(crapseg WHERE crapseg.cdcooper = glb_cdcooper       AND
                                crapseg.nrdconta = crawseg.nrdconta   AND
                                crapseg.tpseguro = crawseg.tpseguro   AND
                                crapseg.nrctrseg = crawseg.nrctrseg)  THEN
         NEXT.

    ASSIGN aux_contador = aux_contador + 1

           s_chlist[aux_contador] = " " +
                   STRING(crawseg.dtiniseg,"99/99/9999")     + " " +
                   STRING(crawseg.nrctrseg,"zzz,zzz,zz9")        + "  " +
                   STRING(DAY(crawseg.dtdebito),"99")        + " " +
                   (IF (crawseg.tpseguro = 1 OR
                        crawseg.tpseguro = 11 ) THEN "CASA" ELSE 
                       IF crawseg.tpseguro = 2 THEN "AUTO"
                       ELSE IF crawseg.tpseguro = 3 THEN "VIDA"
                               ELSE
                               IF crawseg.tpseguro = 4 THEN "PRST"
                               ELSE "    ") + "  " +
                   STRING(crawseg.vlpreseg,"zzz,zzz,zz9.99") + " " +
                   STRING(crawseg.dtinivig,"99/99/9999") +
                   (IF TRIM(crawseg.lsctrant) = ""
                       THEN "  Em estudo"
                       ELSE "  PS" +
                            TRIM(STRING(INT(ENTRY(NUM-ENTRIES(crawseg.lsctrant),
                                             crawseg.lsctrant)),"zzzzz,zz9")))

           s_nrctrseg[aux_contador] = crawseg.nrctrseg
           s_tpseguro[aux_contador] = crawseg.tpseguro
           s_recid[aux_contador]    = RECID(crawseg)
           s_cdtiparq[aux_contador] = 1.

END.  /*  Fim do FOR EACH -- Leitura do crawseg  */

s_chextent = aux_contador.

/* .......................................................................... */
