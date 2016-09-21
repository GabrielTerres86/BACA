/* .............................................................................

   Programa: Fontes/tab035.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autora  : Diego         
   Data    : Novembro/2005                         Ultima alteracao: 06/03/2014
   
   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Parametros Tarifas Aditivos
   
   Alteracoes: 02/02/2006 - Unificacao dos Bancos - SQLWorks - Luciane.
   
               06/03/2014 - Convertido craptab.tpregist para INTEGER. (Reinert)
                             
............................................................................. */

{ includes/var_online.i }

DEF    VAR tel_dsaditiv  AS CHAR    FORMAT "x(36)"  EXTENT 8
           INIT ["1- Alteracao Data do Debito",
                 "2- Aplicacao Vinculada",
                 "3- Aplicacao Vinculada Terceiro",
                 "4- Inclusao de Fiador/Avalista",
                 "5- Substituicao de Veiculo",
                 "6- Interveniente Garantidor Veiculo",
                 "7- Sub-rogacao - C/ Nota Promissoria",
                 "8- Sub-rogacao - S/ Nota Promissoria"]
                                                                       NO-UNDO.
                                                                       
DEF    VAR aux_vltaradt  AS DECIMAL FORMAT "zzz,zzz,zz9.99"  EXTENT 8  NO-UNDO.

DEF    VAR aux_cddopcao  AS CHAR                                       NO-UNDO.

FORM  SKIP(1)
      glb_cddopcao AT 4 LABEL "Opcao" AUTO-RETURN
                        HELP "Entre com a opcao desejada (A ou C)"
                        VALIDATE(CAN-DO("A,C",glb_cddopcao),
                                 "014 - Opcao errada.")
      SKIP(2)
      "Codigo Aditivo" AT  5
      "Valor Tarifa"   AT 48
      
      SKIP(1)
      tel_dsaditiv[1]  AT  3
      aux_vltaradt[1]  AT 46
      tel_dsaditiv[2]  AT  3
      aux_vltaradt[2]  AT 46
      tel_dsaditiv[3]  AT  3
      aux_vltaradt[3]  AT 46
      tel_dsaditiv[4]  AT  3
      aux_vltaradt[4]  AT 46
      tel_dsaditiv[5]  AT  3
      aux_vltaradt[5]  AT 46
      tel_dsaditiv[6]  AT  3
      aux_vltaradt[6]  AT 46
      tel_dsaditiv[7]  AT  3
      aux_vltaradt[7]  AT 46
      tel_dsaditiv[8]  AT  3
      aux_vltaradt[8]  AT 46
          HELP "Entre com o valor da tarifa"      
      
      SKIP(2)
      WITH NO-LABEL SIDE-LABELS ROW 4 COLUMN 1 WIDTH 80 OVERLAY 
      TITLE glb_tldatela WITH FRAME f_tab035.


glb_cddopcao = "C".

DO WHILE TRUE:

   RUN fontes/inicia.p.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      UPDATE glb_cddopcao WITH FRAME f_tab035.
   
      LEAVE.
   END.

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.
            IF   CAPS(glb_nmdatela) <> "TAB035"   THEN
                 DO:
                     HIDE FRAME f_tab035.
                     RETURN.
                 END.
            ELSE
                 NEXT.
        END.

   IF   aux_cddopcao <> glb_cddopcao THEN
        DO:
            { includes/acesso.i }
            aux_cddopcao = glb_cddopcao.
        END.

   IF   glb_cddopcao = "A" THEN
        DO:
            FOR EACH  craptab WHERE craptab.cdcooper = glb_cdcooper   AND
                                    craptab.nmsistem = "CRED"         AND
                                    craptab.tptabela = "USUARI"       AND
                                    craptab.cdempres = 00             AND
                                    craptab.cdacesso = "VLTARIFADT"   NO-LOCK:
                    
                ASSIGN aux_vltaradt[INTE(craptab.tpregist)] = 
                       DECIMAL(SUBSTR(craptab.dstextab,1,12)).
            END.
              
            DISPLAY tel_dsaditiv aux_vltaradt 
                    WITH FRAME f_tab035.
            
            DO TRANSACTION ON ENDKEY UNDO, LEAVE:

               FOR EACH  craptab WHERE craptab.cdcooper = glb_cdcooper   AND
                                       craptab.nmsistem = "CRED"         AND
                                       craptab.tptabela = "USUARI"       AND
                                       craptab.cdempres = 00             AND
                                       craptab.cdacesso = "VLTARIFADT"
                                       EXCLUSIVE-LOCK:
                    
                   UPDATE  aux_vltaradt[INTE(craptab.tpregist)]
                           WITH FRAME f_tab035.
                   
                   ASSIGN craptab.dstextab = 
                          STRING(aux_vltaradt[INTE(craptab.tpregist)], 
                                              "999999999.99").

               END.
               
            END. /* Fim da transacao */
                       
            IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN  /*   F4 OU FIM */
                 NEXT.

            CLEAR FRAME f_tab035 NO-PAUSE.

        END.
   ELSE
        IF   glb_cddopcao = "C" THEN
             DO:
                 FOR EACH  craptab WHERE craptab.cdcooper = glb_cdcooper   AND
                                         craptab.nmsistem = "CRED"         AND
                                         craptab.tptabela = "USUARI"       AND
                                         craptab.cdempres = 00             AND
                                         craptab.cdacesso = "VLTARIFADT" 
                                         NO-LOCK:   
                                         
                                                   
                     ASSIGN aux_vltaradt[INTE(craptab.tpregist)] = 
                                  DECIMAL(SUBSTR(craptab.dstextab,1,12)).
                 END.                    
                 
                 DISPLAY tel_dsaditiv aux_vltaradt 
                         WITH FRAME f_tab035.

             END.
END.

/* .......................................................................... */
