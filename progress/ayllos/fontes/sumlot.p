/* .............................................................................

   Programa: Fontes/sumlot.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Outubro/91                      Ultima atualizacao: 02/06/2014
   
   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela SUMLOT.

   Alteracao : 06/11/94 - Alterado para ajustar o tipo de lote para 2 posicoes
                          (Odair).

               03/08/95 - Alterado para permitir consultar todos os lotes de
                          um banco/caixa, independente de agencia (Deborah).

               16/08/96 - Acerto na alteracao anterior (Deborah).

               16/04/98 - Tratamento para milenio e troca para V8 (Margarete).
               
               16/11/00 - Alterar nrdolote p/6 posicoes (Margarete/Planner).

               11/01/2001 - Mostrar o total de arrecadacoes no lugar do 
                            total de limite (Deborah)

               16/03/2004 - Mostrar lote e programa de requisicoes nao
                            batido (Margarete).

               09/06/2004 - Alteracao no layout da tela (Margarete).
               
               29/06/2004 - Sem erros dar mensagem de ok (Margarete).
               
               31/01/2005 - Modificados os termos "Agencia" ou "Ag" por "PAC"
                            (Evandro).

               02/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.
               
               26/04/2011 - Alterado a validacao do cdbccxlt atraves do crapban 
                            para crapbcl (Adriano). 
                            
               23/08/2011 - Incluir tratamento do horario da crapenl e
                            controle de qtd de dias para busca de envelopes
                            (Gabriel/Evandro).

               26/10/2011 - Adaptado para uso de BO (Rogerius Militao - DB1).
               
               27/04/2012 - Alterado chamada de função Gera_Criticas da b1wgen0121
                            para passar parâmetro glb_dtmvtoan (Guilherme Maba).
               
               15/08/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).   
                            
               02/06/2014 - Concatena o numero do servidor no endereco do
                            terminal (Tiago-RKAM).
............................................................................. */

{ includes/var_online.i }
{ sistema/generico/includes/var_internet.i }

DEF NEW SHARED VAR aux_nmarqimp AS CHAR                              NO-UNDO.
 
DEF            VAR tel_cdagenci AS INT  FORMAT "zz9"                 NO-UNDO.
DEF            VAR tel_cdbccxlt AS INT  FORMAT "zz9"                 NO-UNDO.
DEF            VAR tel_qtcompln AS INT                               NO-UNDO.
DEF            VAR tel_vlcompap AS DEC                               NO-UNDO.
DEF            VAR aux_cddopcao AS CHAR                              NO-UNDO.
DEF            VAR aux_nmdcampo AS CHAR                              NO-UNDO.

DEF            VAR h-b1wgen0121 AS HANDLE                            NO-UNDO.

FORM tel_cdagenci FORMAT "zz9"
                  AT 2 LABEL "PA"
                  HELP "Informe o PA ou nao preencha p/saber o total."

     "Banco/Caixa:" AT 15
     tel_cdbccxlt FORMAT "zz9"
                  AT 28 NO-LABEL
                  HELP "Informe o banco/caixa ou nao preencha p/saber o total."
     SKIP(1)
     "Tot. de Lanctos:" AT 2
     tel_qtcompln FORMAT "z,zzz,zz9" NO-LABEL
     "Total Aplicado no Dia:" AT 30                        
     tel_vlcompap FORMAT "zzzz,zzz,zz9.99" NO-LABEL
     SKIP(13)         
     WITH SIDE-LABELS TITLE glb_tldatela
          ROW 4 COLUMN 1 OVERLAY 1 DOWN WIDTH 80 WITH FRAME f_sumlot.

FORM SKIP(11)
     WITH FRAME f_moldura OVERLAY NO-LABELS ROW 9 WIDTH 80 TITLE "CRITICAS". 

RUN fontes/inicia.p.

ASSIGN glb_cddopcao = "C".

DO WHILE TRUE:

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

        UPDATE tel_cdagenci tel_cdbccxlt WITH FRAME f_sumlot.
        LEAVE.
    END.

    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN    /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.
            IF  glb_nmdatela <> "SUMLOT"   THEN
                DO:
                    HIDE FRAME f_sumlot.
                    RETURN.
                END.
            ELSE
                NEXT.
        END.

    IF  aux_cddopcao <> glb_cddopcao THEN
        DO:
            { includes/acesso.i }
            ASSIGN aux_cddopcao = glb_cddopcao.
        END.

    RUN Gera_Criticas.            
    
END.

/* ......................................................................... */

PROCEDURE Gera_Criticas:
    
    DEF   VAR aux_nmarqpdf AS CHAR                                    NO-UNDO.
    DEF   VAR aux_nmendter AS CHAR       FORMAT "x(20)"               NO-UNDO.
    
    EMPTY TEMP-TABLE tt-erro.

    INPUT THROUGH basename `tty` NO-ECHO.
      SET aux_nmendter WITH FRAME f_terminal.
    INPUT CLOSE.
    
    aux_nmendter = substr(glb_hostname,length(glb_hostname) - 1) +
                          aux_nmendter.

    IF  NOT VALID-HANDLE(h-b1wgen0121) THEN
        RUN sistema/generico/procedures/b1wgen0121.p
            PERSISTENT SET h-b1wgen0121.

    RUN Gera_Criticas IN h-b1wgen0121
        ( INPUT glb_cdcooper,
          INPUT glb_cdagenci,
          INPUT 0,
          INPUT glb_dtmvtolt,
          INPUT glb_dtmvtoan,
          INPUT 1,
          INPUT aux_nmendter,
          INPUT tel_cdagenci,
          INPUT tel_cdbccxlt,
         OUTPUT tel_qtcompln,
         OUTPUT tel_vlcompap,
         OUTPUT aux_nmdcampo,
         OUTPUT aux_nmarqimp, 
         OUTPUT aux_nmarqpdf, 
         OUTPUT TABLE tt-erro).
    
    IF  VALID-HANDLE(h-b1wgen0121) THEN
        DELETE OBJECT h-b1wgen0121.
 
    IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
        DO:
            HIDE MESSAGE NO-PAUSE.
 
            FIND FIRST tt-erro NO-ERROR.
 
            IF  AVAILABLE tt-erro THEN
                DO:
                    BELL.
                    MESSAGE tt-erro.dscritic.
                    CLEAR FRAME f_sumlot NO-PAUSE.
                    DISPLAY tel_cdagenci tel_cdbccxlt WITH FRAME f_sumlot.
                    NEXT-PROMPT tel_cdbccxlt WITH FRAME f_sumlot.
                    NEXT.
                END.

            RETURN "NOK".  
        END.
    ELSE 
        DO:
            CLEAR FRAME f_sumlot.

            DISPLAY tel_cdagenci tel_cdbccxlt tel_qtcompln tel_vlcompap 
                    WITH FRAME f_sumlot.
    
            PAUSE (0).
    
            VIEW FRAME f_moldura.
    
            PAUSE(0).
    
            RUN fontes/visualiza_criticas.p.

        END.

    RETURN "OK".

END PROCEDURE. /* Gera_Criticas */


