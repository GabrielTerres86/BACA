/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +---------------------------------+-----------------------------------+
  | Rotina Progress                 | Rotina Oracle PLSQL               |
  +---------------------------------+-----------------------------------+
  | includes/impressao.i            | gene0002.pc_gera_impressao        |                      |
  +---------------------------------+-----------------------------------+

  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.

  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - GUILHERME STRUBE    (CECRED)
   - MARCOS MARTINI      (SUPERO)

*******************************************************************************/




                                                    
                                                    
                                                    
                                                    
                                                    
                                                    

/* .............................................................................

   Programa: Includes/impressao.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Agosto/95.                          Ultima atualizacao: 20/04/2016

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Rotina de impressao para os extratos especiais.

   Alteracoes: 28/02/97 - Alterado para tratar a impressao de varias copias
                          (Edson).

               16/05/97 - Implementada opcao PAUSE no comando CHOOSE para
                          impressao escrava (Edson).

               12/11/98 - Tratar atendimento noturno (Deborah).
               
               06/12/2004 - Identificacao do banco ao referenciar as tabelas
                            (Julio)

               15/12/2004 - Pedir impressora de destino e/ou confirmacao da
                            impressora padrao (Edson).
                          
               26/01/2006 - Unificacao dos Bancos - SQLWorks - Fernando
             
               11/05/2009 - Alteracao CDOPERAD (Kbase).
             
               04/06/2012 - Adaptação dos fontes para projeto Oracle. Retirada
                            do prefixo "banco" (Guilherme Maba). 
                            
               03/04/2014 - Ajustado processo de validacao impressora (Daniel). 
               
               12/12/2014 - #215938 Validacao da existencia do arquivo a ser impresso
                            (Carlos)
                            
               20/04/2016 - Incluir rm caso seja cancelada a impressao dos 
                            documentos (Lucas Ranghetti/Rodrigo #399412 ) 
............................................................................. */

DEF VAR prn_nmdafila AS CHAR                                    NO-UNDO.

DEF VAR aux_retorno  AS CHAR                                    NO-UNDO.

FORM SKIP(1)
     glb_nmdafila LABEL "  Imprimir em" " "
     SKIP(1)
     WITH ROW 14 CENTERED OVERLAY SIDE-LABELS 
          TITLE COLOR NORMAL " Destino " FRAME f_nmdafila.

/*  Gera arquivo para estatistica de emissao de extratos  */

IF   glb_inproces > 2   THEN
     ASSIGN glb_cdoperad = "Sistema"
            aux_nmendter = "Batch".

IF   NOT CAN-DO("fontes/carmag_m.p,fontes/custod_r.p,fontes/imptax.p,
                 fontes/impbcaixa.p,fontes/crps090.p", PROGRAM-NAME(1))   THEN
     UNIX SILENT VALUE("echo " + STRING(YEAR(glb_dtmvtolt),"9999") +
                                 STRING(MONTH(glb_dtmvtolt),"99") +
                                 STRING(DAY(glb_dtmvtolt),"99") + " " +
                                 STRING(crapass.cdagenci,"999") + " " +
                                 STRING(crapass.nrdconta,"99999999") + 
                                 " " + STRING(glb_cdoperad,"x(10)") + " " +
                                 STRING(TIME,"HH:MM:SS") + " " +
                                 STRING(aux_nmendter,"x(15)") + " " +
                                 STRING(PROGRAM-NAME(1),"x(30)") +
                                 " >> arq/.extratos.dat").

IF   NOT par_flgrodar   THEN       /*  Se verdadeiro, imprime na hora  */
     RETURN.

aux_flgescra = FALSE.

FIND crapter WHERE crapter.cdcooper = glb_cdcooper AND
                   crapter.nmendter = aux_nmendter NO-LOCK NO-ERROR.

IF   AVAILABLE crapter   THEN
     IF   crapter.nmdafila = "escrava"   THEN
          aux_flgescra = TRUE.
     ELSE
     IF   crapter.nmdafila <> "Limbo"    THEN
          DO:
              IF   glb_nrdevias = 0   THEN
                   glb_nrdevias = 1.

              aux_dscomand = "lp -d" + crapter.nmdafila + 
                             " -n" + STRING(glb_nrdevias) +
                             " -oMTl88 " + aux_nmarqimp +
                             " > /dev/null".

              UNIX SILENT VALUE(aux_dscomand).
          END.
     ELSE .
ELSE
IF   glb_flgimpre   THEN
     aux_flgescra = TRUE.
ELSE
IF   glb_flgmicro   THEN
     DO:
         prn_nmdafila = glb_nmdafila.
         
         DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
         
            UPDATE glb_nmdafila WITH FRAME f_nmdafila.
            
            IF   glb_nmdafila <> prn_nmdafila   THEN DO:

                 INPUT THROUGH VALUE ('grep -Ew "' + glb_nmdafila + '" /etc/qconfig' ).

                /*  Prever tratamento de Erro */
                DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:
                    IMPORT UNFORMATTED aux_retorno.
                    IF   aux_retorno <> ""  THEN
                         LEAVE.
                END.

                IF aux_retorno = "" THEN DO:
                    BELL.
                    MESSAGE "Impressora nao cadastrada -" glb_nmdafila.
                    NEXT.
                END.
            END.

            HIDE FRAME f_nmdafila NO-PAUSE.
            
            LEAVE.
         
         END.  /*  Fim do DO WHILE TRUE  */
         
         IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN    /*   F4 OU FIM   */
              DO:
                  BELL.
                  glb_nmdafila = prn_nmdafila.
                  HIDE FRAME f_nmdafila NO-PAUSE.
                  MESSAGE "Impressao NAO efetuada...".

                  /* Remover o arquivo gerado para impressao */
                  IF  TRIM(aux_nmarqimp) <> "" THEN                     
                      UNIX SILENT VALUE("rm " + aux_nmarqimp + " 2> /dev/null").          
                                         
                  RETURN.
              END.
         
         IF   glb_nrdevias = 0   THEN
              glb_nrdevias = 1.
              
         IF   TRIM(glb_nmformul) = ""   THEN
              glb_nmformul = "132col".
 
        IF SEARCH(aux_nmarqimp) = ? THEN
        DO:
            glb_nmdafila = prn_nmdafila.
            HIDE FRAME f_nmdafila NO-PAUSE.
            MESSAGE "Erro na impressao. Tente novamente.".
            RETURN "NOK".
        END.

         aux_dscomand = "lp -d" + glb_nmdafila +
                        " -n" + STRING(glb_nrdevias) +   
                        " -oMTl88 " + " -oMTf" + glb_nmformul + " " +
                        aux_nmarqimp +
                        " > /dev/null".

         UNIX SILENT VALUE(aux_dscomand).

         glb_nmdafila = prn_nmdafila.
     END.

IF   aux_flgescra   THEN
     DO:
         IF   par_flgfirst   THEN
              DO:
                  IF   glb_nrdevias = 0   THEN
                       glb_nrdevias = 1.

                  DO aux_contador = 1 TO glb_nrdevias ON ENDKEY UNDO, LEAVE:

                     glb_nmformul = " Impressao da " +
                                    STRING(aux_contador) + " via ".

                     DISPLAY tel_dsimprim tel_dscancel WITH FRAME f_atencao.

                     CHOOSE FIELD tel_dscancel tel_dsimprim PAUSE 5
                                  WITH FRAME f_atencao.

                     IF   LASTKEY <> -1   THEN
                          IF   FRAME-VALUE = tel_dscancel   THEN
                               DO:
                                   par_flgcance = TRUE.
                                   LEAVE.
                               END.

                     HIDE FRAME f_atencao NO-PAUSE.

                     UNIX SILENT VALUE("script/escrava " + aux_nmarqimp).

                  END.  /*  Fim do DO .. TO  */

                  UNIX SILENT VALUE("rm " + aux_nmarqimp + " 2> /dev/null").
                  HIDE FRAME f_atencao NO-PAUSE.
              END.
         ELSE
              DO:
                  UNIX SILENT VALUE("script/escrava " + aux_nmarqimp).
                  UNIX SILENT VALUE("rm " + aux_nmarqimp + " 2> /dev/null").
              END.
     END.
ELSE
IF   NOT AVAILABLE crapter   AND   
     NOT glb_flgmicro   THEN
     DO:
         glb_cdcritic = 458.
         RUN fontes/critic.p.
         BELL.
         HIDE MESSAGE NO-PAUSE.
         MESSAGE glb_dscritic.
         glb_cdcritic = 0.
         PAUSE 2 NO-MESSAGE.
     END.

ASSIGN glb_nrdevias = 0
       glb_nmformul = "".

/* .......................................................................... */
 
