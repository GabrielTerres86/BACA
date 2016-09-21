/* .............................................................................

   Programa: Fontes/secextc.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Setembro/91                    Ultima atualizacao: 09/08/2013

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de consulta da tela SECEXT.

   Alteracoes: 15/12/2010 - Alteracao do format nmprimtl 
                            (Kbase IT) - Gilnei.
                            
               09/08/2013 - Modificado o termo "PAC" para "PA" (Douglas).

............................................................................. */

DEF        VAR aux_pesquisa AS LOGICAL FORMAT "S/N"                  NO-UNDO.

DEF QUERY q_crapass FOR crapass. 

DEF BROWSE b_crapass QUERY q_crapass
           DISP crapass.cdagenci COLUMN-LABEL "PA"
                crapass.nrdconta COLUMN-LABEL "Conta/dv"
                crapass.nmprimtl COLUMN-LABEL "Nome"     FORMAT "X(40)"
                crapass.dtdemiss COLUMN-LABEL "Demissao" FORMAT "99/99/9999"
                WITH 8 DOWN CENTERED.

DEF FRAME f_crapass 
          SKIP(1)
          b_crapass  HELP  "Pressione <F4> ou <END> para finalizar" 
          WITH NO-BOX NO-LABEL CENTERED OVERLAY ROW 7.
 
FORM "Mostrar os Cooperados da secao?"    AT  2
     aux_pesquisa         AT  34   AUTO-RETURN
     "(S/N) "             AT  36
      WITH NO-LABELS ROW 17 column 19 OVERLAY FRAME f_confirma.

DO WHILE TRUE:

   ASSIGN aux_pesquisa  =  FALSE
          tel_cdsecext  =  crapdes.cdsecext
          tel_nmsecext  =  crapdes.nmsecext
          tel_nmpesext  =  crapdes.nmpesext
          tel_cdagenci  =  crapdes.cdagenci
          tel_nrfonext  =  crapdes.nrfonext
          tel_indespac  =  IF   crapdes.indespac = 0 THEN
                                TRUE
                           ELSE FALSE.
            
   DISPLAY  tel_nmsecext  tel_nmpesext  tel_nrfonext  tel_indespac
            WITH FRAME f_secao.

   PAUSE(0).
   
   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      UPDATE aux_pesquisa WITH FRAME f_confirma.

      LEAVE.
   
   END.
   
   HIDE FRAME f_confirma NO-PAUSE.
   
   IF   KEYFUNCTION(LASTKEY) = "END-ERROR" OR
        NOT aux_pesquisa THEN
        DO:
            glb_cdcritic = 79.
            RUN fontes/critic.p.
            glb_cdcritic = 0.
            BELL.
            MESSAGE glb_dscritic.
            PAUSE 5 NO-MESSAGE.
            HIDE FRAME f_secao.
            RETURN.
        END. 
    
   IF   aux_pesquisa THEN
        DO:
            OPEN QUERY q_crapass
                 FOR EACH crapass WHERE crapass.cdcooper = glb_cdcooper     AND
                                        crapass.cdagenci = crapdes.cdagenci AND
                                        crapass.cdsecext = crapdes.cdsecext
                                        NO-LOCK.
        
            ENABLE b_crapass WITH FRAME f_crapass.

            WAIT-FOR DEFAULT-ACTION OF DEFAULT-WINDOW.
                          
        END.
   
   LEAVE.

END.

/* .......................................................................... */

