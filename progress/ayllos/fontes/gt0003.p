/* .............................................................................

   Programa: Fontes/gt0003.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autora  : Mirtes
   Data    : Marco/2004                     Ultima Atualizacao: 25/07/2012

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Efetuar Consulta Controles de Execucao(Generico)
               - Arrecadacao Convenios (Caixa)
               
               13/04/2012 - Substituido programa gt0003p.p pelo gt0003.p (Elton)
               
               22/06/2012 - Substituido gncoper por crapcop (Tiago).          
               
               25/07/2012 - Corrigido problemas da tela gt0003 (Tiago).
............................................................................. */

{ includes/var_online.i  } 

DEF        VAR tel_cdcooper    LIKE gncontr.cdcooper                 NO-UNDO.
DEF        VAR tel_cdconven    LIKE gncontr.cdconven                 NO-UNDO.
DEF        VAR tel_dtmvtolt    LIKE gncontr.dtmvtolt                 NO-UNDO.
DEF        VAR tel_dtcredit    LIKE gncontr.dtcredit                 NO-UNDO.
DEF        VAR tel_nmarquiv    LIKE gncontr.nmarquiv                 NO-UNDO.
DEF        VAR tel_qtdoctos    LIKE gncontr.qtdoctos                 NO-UNDO.
DEF        VAR tel_vldoctos    LIKE gncontr.vldoctos                 NO-UNDO.
DEF        VAR tel_vltarifa    LIKE gncontr.vltarifa                 NO-UNDO.
DEF        VAR tel_vlapagar    LIKE gncontr.vlapagar                 NO-UNDO.
DEF        VAR tel_nrsequen    LIKE gncontr.nrsequen                 NO-UNDO.
DEF        VAR tel_nmrescop    LIKE crapcop.nmrescop                 NO-UNDO.   
DEF        VAR tel_cdcopdom    LIKE gnconve.cdcooper                 NO-UNDO.
DEF        VAR tel_nrcnvfbr    LIKE gnconve.nrcnvfbr                 NO-UNDO.
DEF        VAR tel_nmempres    LIKE gnconve.nmempres                 NO-UNDO.

DEF        VAR tel_tiporel  AS LOG     FORMAT "Convenio/Cooperativa" NO-UNDO.
DEF        VAR tel_dtinici  AS DATE    FORMAT "99/99/9999"           NO-UNDO.
DEF        VAR tel_dtfinal  AS DATE    FORMAT "99/99/9999"           NO-UNDO.

DEF        VAR tel_totqtdoc AS DECI    FORMAT "zz,zz9"               NO-UNDO.
DEF        VAR tel_totvldoc AS DECI    FORMAT "z,zzz,zz9.99"         NO-UNDO.
DEF        VAR tel_tottarif AS DECI    FORMAT "zz,zz9.99"            NO-UNDO.
DEF        VAR tel_totpagar AS DECI    FORMAT "z,zzz,zz9.99"         NO-UNDO.

DEF        VAR aux_confirma AS CHAR    FORMAT "!(1)"                 NO-UNDO.
DEF        VAR aux_contador AS INT     FORMAT "z9"                   NO-UNDO.
DEF        VAR aux_cddopcao AS CHAR                                  NO-UNDO.

DEF        VAR aux_posregis AS ROWID                                 NO-UNDO.

DEF BUFFER b-gncontr FOR gncontr.

FORM SPACE(1)
     WITH ROW 4 OVERLAY 16 DOWN WIDTH 80 TITLE glb_tldatela FRAME f_moldura.

FORM "Opcao:"       AT 6
     glb_cddopcao   AUTO-RETURN
                    HELP "Informe a opcao desejada ( C  ou R)."
                        VALIDATE(CAN-DO("C,R",glb_cddopcao),
                                 "014 - Opcao errada.")
     SKIP (1)
     tel_dtmvtolt    AT  3  LABEL "Data"
     tel_cdcooper    AT  3  LABEL "Cooperativa"
     VALIDATE( CAN-FIND(crapcop WHERE crapcop.cdcooper = tel_cdcooper)
                        OR tel_cdcooper = 0,"Cooperativa nao cadastrada")    
                            HELP "Informe Cooperativa "
     tel_nmrescop    AT 31  LABEL "Nome"
     tel_cdcopdom    AT 31  LABEL "Cooperativa Dominio"
     tel_cdconven    AT  3  LABEL "Convenio"
     VALIDATE(CAN-FIND(gnconve WHERE gnconve.cdcooper = tel_cdcooper  AND
                                     gnconve.cdconven = tel_cdconven  AND
                                     gnconve.flgativo = TRUE) OR
              CAN-FIND(FIRST gnconve WHERE gnconve.cdconven = tel_cdconven AND
                                           gnconve.flgativo = TRUE) OR
              tel_cdconven = 0, "563 - Convenio nao cadastrado." )
     tel_nrcnvfbr    AT 21  LABEL "Febraban"
     tel_nmempres    AT 51  LABEL "Emp"
     tel_dtcredit    AT  3  LABEL "Credito"
     tel_nmarquiv    AT  3  LABEL "Arquivo"
     tel_qtdoctos    AT  3  LABEL "Quantidade Doctos"
     tel_vldoctos    AT  3  LABEL "Total Arrecadado"
     tel_vltarifa    AT  3  LABEL "Total de Tarifas"
     tel_vlapagar    AT  3  LABEL "Total a Pagar"
     tel_nrsequen    AT  3  LABEL "Nro Seq."
     WITH  NO-LABELS 
     ROW 6 OVERLAY COLUMN 2 FRAME f_convenio NO-BOX SIDE-LABELS PFCOLOR 0.


FORM tel_tiporel     AT  1  LABEL "Rel."
                            HELP "Informe Convenio/Cooperativa"
     tel_cdcooper    AT 20  LABEL "Coop."
                            HELP "Informe Cooperativa(0 p/Todas) "
     tel_dtinici     AT 40  LABEL "Inicio " 
                            HELP "Entre com a data inicial"
     tel_dtfinal     AT 60  LABEL "Final"
                            HELP "Entre com a data final"
    WITH ROW 6 COLUMN 3 SIDE-LABELS OVERLAY NO-BOX FRAME f_convenio_r.


/* Variaveis para mostrar a consulta */          
 
DEF QUERY  bgncontrq FOR gncontr , gnconve.

DEF BROWSE bgncontr-b QUERY bgncontrq
      DISP SPACE(1)
           gncontr.cdcooper            COLUMN-LABEL "Cp" FORMAT "99"
           gnconve.cdconven            COLUMN-LABEL "Cnv" FORMAT "999"
           gncontr.dtmvtolt            COLUMN-LABEL "Data"
           gncontr.dtcredit            COLUMN-LABEL "Credito"
           gncontr.qtdoctos            COLUMN-LABEL "Qtd."   FORMAT "zz,zz9"
           gncontr.vldoctos            COLUMN-LABEL "Arrec." FORMAT "z,zzz,zz9.99"
           gncontr.vltarifa            COLUMN-LABEL "Tarifa" FORMAT "zz,zz9.99"
           gncontr.vlapagar            COLUMN-LABEL "Pagar"  FORMAT "z,zzz,zz9.99"
           SPACE(1)
           WITH 9 DOWN OVERLAY.    

DEF FRAME f_convenioc
          bgncontr-b HELP
         "Use  SETAS p/navegar  - <F4> p/sair - ENTER p/Selecionar reg." SKIP
         "TOTAL:" AT 26    
         tel_totqtdoc NO-LABEL AT 33
         tel_totvldoc NO-LABEL AT 40
         tel_tottarif NO-LABEL AT 53
         tel_totpagar NO-LABEL AT 64
         WITH NO-BOX CENTERED OVERLAY ROW 7.


ON VALUE-CHANGED, ENTRY OF bgncontr-b
   DO:
       aux_posregis = ROWID(gncontr).
   END.


ON RETURN OF bgncontr-b
   DO:
                         
      FIND gncontr NO-LOCK  WHERE
           ROWID(gncontr) = aux_posregis  NO-ERROR.
      IF  AVAIL gncontr THEN
          DO:
          
             ASSIGN  tel_cdcooper = gncontr.cdcooper  
                     tel_cdconven = gncontr.cdconven  
                     tel_dtmvtolt = gncontr.dtmvtolt.

             ASSIGN tel_nmrescop = " ".
             FIND first crapcop NO-LOCK WHERE
                        crapcop.cdcooper = tel_cdcooper NO-ERROR.
             IF  AVAIL crapcop THEN
                 ASSIGN tel_nmrescop = crapcop.nmrescop.
            
             ASSIGN  tel_dtcredit   = gncontr.dtcredit   
                     tel_nmarquiv   = gncontr.nmarquiv 
                     tel_qtdoctos   = gncontr.qtdoctos  
                     tel_vldoctos   = gncontr.vldoctos  
                     tel_vltarifa   = gncontr.vltarifa
                     tel_vlapagar   = gncontr.vlapagar    
                     tel_nrsequen   = gncontr.nrsequen .
                      
             ASSIGN  tel_cdcopdom   = 0
                     tel_nrcnvfbr   = ""
                     tel_nmempres   = "".
             FIND gnconve NO-LOCK WHERE
                  gnconve.cdconve = gncontr.cdconven NO-ERROR.
             IF  AVAIL gnconve THEN
                 ASSIGN  tel_cdcopdom   = gnconve.cdcooper
                         tel_nrcnvfbr   = gnconve.nrcnvfbr
                         tel_nmempres   = gnconve.nmempres.
               
             DISPLAY tel_cdcooper   
                     tel_cdconven   
                     tel_dtmvtolt
                     tel_dtcredit 
                     tel_nmarquiv 
                     tel_qtdoctos
                     tel_vldoctos
                     tel_vltarifa  
                     tel_vlapagar 
                     tel_nrsequen
                     tel_nmrescop
                     tel_cdcopdom
                     tel_nrcnvfbr
                     tel_nmempres
                     WITH FRAME f_convenio.
            
             APPLY "GO".
             
          END.
   END.


/**********************************************/


glb_cddopcao = "C".

VIEW FRAME f_moldura.
PAUSE(0).
VIEW FRAME f_convenio.

  
DO WHILE TRUE:

   RUN fontes/inicia.p.
   
    DISPLAY glb_cddopcao WITH FRAME f_convenio.
 
    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      IF   glb_cdcritic > 0   THEN
           DO:
               RUN fontes/critic.p.
               BELL.
               MESSAGE glb_dscritic.
               ASSIGN glb_cdcritic = 0.
           END.

      UPDATE glb_cddopcao  WITH FRAME f_convenio.

      LEAVE.

   END.  /*  Fim do DO WHILE TRUE  */

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.

            IF   CAPS(glb_nmdatela) <> "GT0003"  THEN
                 DO:
                     HIDE FRAME f_convenio_r NO-PAUSE.
                     HIDE FRAME f_convenio_c NO-PAUSE.
                     HIDE FRAME f_convenio   NO-PAUSE.
                     RETURN.
                 END.
            ELSE
                 NEXT.
        END.


     IF   glb_cddopcao = "C" THEN
          DO: 
              ASSIGN tel_dtmvtolt = glb_dtmvtoan
                     tel_cdcooper = 0
                     tel_cdconven = 0.

              DISPLAY tel_dtmvtolt WITH FRAME f_convenio.

              DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                  DISPLAY glb_cddopcao WITH FRAME f_convenio.
              
                  UPDATE tel_dtmvtolt
                         tel_cdcooper
                         tel_cdconven
                         WITH FRAME f_convenio.
                  
                  { includes/gt0003c.i }
              END.
          END.


     IF   glb_cddopcao = "R" THEN
          DO:
             HIDE FRAME f_convenioc.
             HIDE FRAME f_convenio.
             
             ASSIGN tel_tiporel = YES
                    tel_dtinici = glb_dtmvtoan
                    tel_dtfinal = glb_dtmvtoan.
                    
             DISPLAY tel_tiporel
                     tel_dtinici tel_dtfinal WITH FRAME f_convenio_r.

             DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
              
                 UPDATE tel_tiporel
                        tel_cdcooper
                        tel_dtinici
                        tel_dtfinal
                        WITH FRAME f_convenio_r.
             
                 RUN fontes/gt0003_r.p (INPUT tel_tiporel,
                                        INPUT tel_cdcooper, 
                                        INPUT tel_dtinici,
                                        INPUT tel_dtfinal).
             END.

           END.

END.

/* .......................................................................... */

