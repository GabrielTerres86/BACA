/* .............................................................................

   Programa: fontes/lanlci.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Evandro
   Data    : Setembro/2004.                    Ultima atualizacao: 16/04/2012

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela LANLCI.

   Alteracoes: 01/02/2006 - Unificacao dos Bancos - SQLWorks - Andre

               26/02/2009 - Substituir a leitura da tabela craptab pelo
                            ver_ctace.p para informacoes de conta convenio
                            (Sidnei - Precise IT)
                            
               16/04/2012 - Fonte substituido por lanlcip.p (Tiago).             
.............................................................................*/

{ includes/var_online.i } 
{ includes/var_lanlci.i "NEW" }

/*  Le tabela com as contas convenio do Banco do Brasil - talao normal */

RUN fontes/ver_ctace.p(INPUT glb_cdcooper,
                       INPUT 1,
                       OUTPUT aux_lsconta1).

/*  Le tabela com as contas convenio do Banco do Brasil - talao transf.*/

RUN fontes/ver_ctace.p(INPUT glb_cdcooper,
                       INPUT 2,
                       OUTPUT aux_lsconta2).

/*  Le tabela com as contas convenio do Banco do Brasil - chq.salario */

RUN fontes/ver_ctace.p(INPUT glb_cdcooper,
                       INPUT 3,
                       OUTPUT aux_lsconta3).

VIEW FRAME f_moldura.
PAUSE 0.

ASSIGN glb_cddopcao = "I"
       tel_cdhistor = 0
       tel_nrctainv = 0
       tel_nrdocmto = 0
       tel_vllanmto = 0
       tel_dtliblan = ?
       tel_dtmvtolt = glb_dtmvtolt.

IF   glb_nmtelant = "LOTE"   THEN
     ASSIGN tel_cdagenci = glb_cdagenci
            tel_cdbccxlt = glb_cdbccxlt
            tel_nrdolote = glb_nrdolote.

PAUSE(0).

DISPLAY glb_cddopcao  tel_dtmvtolt  tel_cdagenci  tel_cdbccxlt
        tel_nrdolote  WITH FRAME f_lanlci.

DO WHILE TRUE:

   RUN fontes/inicia.p.

   DISPLAY tel_dtmvtolt WITH FRAME f_lanlci.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
      UPDATE glb_cddopcao tel_cdagenci tel_cdbccxlt tel_nrdolote 
             WITH FRAME f_lanlci.
      
      LEAVE.
   END.

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.

            IF   CAPS(glb_nmdatela) <> "LANLCI"  THEN
                 DO:
                     RETURN.
                 END.
            ELSE
                 NEXT.
        END.
        
   FIND craplot WHERE craplot.cdcooper = glb_cdcooper  AND
                      craplot.dtmvtolt = glb_dtmvtolt  AND
                      craplot.cdagenci = tel_cdagenci  AND 
                      craplot.cdbccxlt = tel_cdbccxlt  AND 
                      craplot.nrdolote = tel_nrdolote  EXCLUSIVE-LOCK NO-ERROR.
                      
   IF   NOT AVAILABLE craplot   THEN
        DO: 
            glb_cdcritic = 60. 
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            glb_cdcritic = 0.
            NEXT.
        END.

   IF  craplot.tplotmov <> 29 THEN
       DO:
            glb_cdcritic = 100.
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            glb_cdcritic = 0.
            NEXT.
       END.
   
   IF   craplot.nrseqdig = 0   THEN
        ASSIGN craplot.nrseqdig = 1.

   ASSIGN tel_nrseqdig = craplot.nrseqdig.

   IF   aux_cddopcao <> glb_cddopcao   THEN
        DO:
            { includes/acesso.i }
            aux_cddopcao = glb_cddopcao.
        END.
   
   IF   glb_cddopcao = "C"   THEN
        DO:
            RUN fontes/lanlcic.p.
        END.
   ELSE
   IF   glb_cddopcao = "E"   THEN
        DO:
            RUN fontes/lanlcie.p.
        END.
   ELSE
   IF   glb_cddopcao = "I"   THEN
        DO:
            RUN fontes/lanlcii.p.
        END.
        
   IF   glb_nmdatela = "LOTE"   THEN
        RETURN.                        /* Retorna a tela LOTE */
        
END.

/*...........................................................................*/

