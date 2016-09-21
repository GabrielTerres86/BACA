/*.........................................................................

   Programa: Includes/gt0002e.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autora  : Mirtes
   Data    : Marco/2004                    Ultima Atualizacao: 22/06/2012

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   
   Objetivo  : Efetuar Exclusao  dos Convenios/Cooperativa(Generico)

   Alteracoes: 22/06/2012 - Substituido gncoper por crapcop (Tiago).          
            
               19/09/2013 - Adaptar fonte para BO. (Gabriel Capoia - DB1)
............................................................................. */

FIND FIRST tt-gt0002 NO-ERROR.

IF  AVAIL tt-gt0002 THEN
    ASSIGN tel_nmempres = tt-gt0002.nmempres
           tel_nmrescop = tt-gt0002.nmrescop.

DISPLAY tel_nmempres tel_nmrescop
     WITH FRAME f_convenio.

DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
    
    ASSIGN aux_confirma = "N"
           glb_cdcritic = 78.

    RUN fontes/critic.p.
    BELL.
    MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
    LEAVE.
END.

IF  KEYFUNCTION(LASTKEY) = "END-ERROR" OR
    aux_confirma <> "S" THEN
    DO:
        glb_cdcritic = 79.
        RUN fontes/critic.p.
        BELL.
        MESSAGE glb_dscritic.
        DISPLAY tel_cdconven WITH FRAME f_convenio.

        NEXT.
    END.

RUN Grava_Dados.

IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN    /*   F4 OU FIM   */
    NEXT.

CLEAR FRAME f_convenio ALL NO-PAUSE.

  
/* .......................................................................... */
