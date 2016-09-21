
/* ..........................................................................

   Programa: Fontes/lislot.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Elton
   Data    : Agosto/2006                         Ultima atualizacao: 12/03/2015

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela LISLOT.

   
   Alteracoes: 20/09/2006 - Alterado help dos campos (Elton).

               04/10/2006 - Substituido crapcop.cdcooper por glb_cdcooper
                            (Elton).
                            
               14/06/2007 - Retirado tabela craptvl  
               
               09/06/2008 - Incluído a chave de acesso (craphis.cdcooper = 
                            glb_cdcooper) no "find e for each" da tabela
                            CRAPHIS.   
                          - Kbase IT Solutions - Eduardo Silva.

               05/05/2009 - Incluir campo Conta como filtro (Fernando).
               
               09/07/2012 - Incluido novo campo "Tipo" responsavel por 
                            consultar na estrutura atual ou no 
                            caixa-online (David Kruger).
                            
               09/08/2013 - Incluir a opçao "LOTE P/PA" no campo Tipo. (James)
               
               01/10/2013 - Nova forma de chamar as agencias, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).
                            
               05/11/2013 - Incluido o historico 889 para listar no relatorio
                            "LOTE P/PA". (James)

               28/03/2014 - Ajustes necessários para a transformação da 
                            b1wgen0184.p (Jéssica - DB1)
                            
               25/06/2014 - Incluidos os historicos 351, 770, 397, 47, 621 e 521
                            para listar no relatorio "LOTE P/PA" 
                            Bkp de conversao da tela para Web em:
                            sistema\equipe\carlos\tarefas\141531 (Carlos)
                            
               28/01/2015 - Inserido nova tabela craplac no filtro do campo 
                            nmestrut da busca da tabela craphis. (Reinert)
                            
               12/03/2015 - Melhoria na chamada de lislot_3 (Carlos)
............................................................................. */

{includes/var_online.i}

DEF  VAR tel_cdagenci AS INT  FORMAT "zz9"                           NO-UNDO.
DEF  VAR tel_cdhistor AS INT  FORMAT "zzz9"                          NO-UNDO.
DEF  VAR tel_nrdconta AS INT  FORMAT "zzzz,zzz,9"                    NO-UNDO.
DEF  VAR tel_dtinicio AS DATE FORMAT "99/99/9999"                    NO-UNDO.
DEF  VAR tel_dttermin AS DATE FORMAT "99/99/9999"                    NO-UNDO.
DEF  VAR aux_cont     AS INT  INIT 0                                 NO-UNDO.
DEF  VAR aux_cddopcao AS CHAR                                        NO-UNDO.
DEF  VAR tel_tpdopcao AS CHAR FORMAT "x(9)" 
     VIEW-AS COMBO-BOX INNER-LINES 3 
     LIST-ITEMS "COOPERADO", "CAIXA" , "LOTE P/PA"
     INIT "COOPERADO"                                                NO-UNDO.
                                   
DEF  VAR aux_texto     AS CHAR FORMAT "X(9)"                         NO-UNDO.


DEF  VAR aux_qtregist AS INTE                                        NO-UNDO. 
DEF  VAR aux_nmdcampo AS INTE                                        NO-UNDO. 
DEF  VAR aux_nmarqpdf AS CHAR                                        NO-UNDO.
DEF  VAR aux_vllanmto AS DECI                                        NO-UNDO.
DEF  VAR aux_registro AS INTE                                        NO-UNDO.

FORM SPACE(1)
     WITH ROW 4 OVERLAY 16 DOWN WIDTH 80 TITLE glb_tldatela FRAME f_moldura.

FORM 
     SKIP(1)
     "Opcao:"
     glb_cddopcao NO-LABEL AUTO-RETURN
                  HELP "Informe a opcao desejada (T ou I)."
                  VALIDATE (glb_cddopcao = "T" OR glb_cddopcao = "I", 
                            "014 - Opcao errada.") 
     SPACE(1)
     "Tipo:"     
     tel_tpdopcao NO-LABEL 
                  HELP "Informe o tipo desejado"
     SPACE(1)
     "PA:"             
     tel_cdagenci HELP "Informe o numero do PA ou '0'(zero) para listar todos."
     SPACE(1)
     "Historico:"
     tel_cdhistor
     SPACE(1)
     aux_texto
     tel_nrdconta  
     HELP "Informe a conta ou '0'(zero) para listar todos."   
     SKIP(1)
     "Data Inicial:"  AT 5
     tel_dtinicio HELP "Informe a data inicial da consulta." 
     VALIDATE((tel_dtinicio <> ? AND tel_dtinicio <= tel_dttermin), "013 - Data invalida." )
     "Data Final:"    AT 32
     tel_dttermin HELP "Informe a data final da consulta."   
     VALIDATE(tel_dttermin <> ?, "013 - Data invalida." )
     WITH FRAME f_dados OVERLAY NO-BOX  NO-LABEL ROW 5 COLUMN 2.

VIEW FRAME f_moldura.
PAUSE (0).


ON RETURN OF tel_tpdopcao
DO:
    DISABLE tel_nrdconta WITH FRAME f_dados.
    APPLY "GO".
END.

ASSIGN glb_cddopcao = "T".
  
DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:
    
    ASSIGN aux_texto = "".

    CLEAR FRAME f_dados.
    
    DISPLAY glb_cddopcao WITH  FRAME f_dados.

    tel_cdhistor:HELP IN FRAME f_dados = "Informe o codigo do historico.".
    
    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
       UPDATE glb_cddopcao WITH frame f_dados.
       LEAVE.
    END.
    
    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
        DO:
            RUN  fontes/novatela.p.
            IF   CAPS(glb_nmdatela) <> "LISLOT"   THEN
                 LEAVE.
            ELSE
                 NEXT.
        END.

    IF  aux_cddopcao <> glb_cddopcao   THEN
        DO:
            { includes/acesso.i }
            ASSIGN aux_cddopcao = glb_cddopcao
                   glb_cdcritic = 0.
        END.  

   DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:
        UPDATE tel_tpdopcao
               WITH FRAME f_dados.
        LEAVE.
    END.     

    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
        NEXT.

    /*  Estrutura Cooperado */
    IF  tel_tpdopcao = "COOPERADO" THEN
        DO: 
            aux_texto = "Conta/Dv:".

            DISP aux_texto WITH FRAME f_dados.

            DO  WHILE TRUE ON ENDKEY UNDO, LEAVE: 
                UPDATE tel_cdagenci 
                       tel_cdhistor  
                       tel_nrdconta
                       WITH FRAME f_dados.
                LEAVE.
            END.

            IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
                NEXT.
           

                           
               IF  glb_cddopcao = "T" THEN
                   DO:
                       RUN fontes/lislot_1.p(INPUT tel_cdagenci,    
                                             INPUT tel_cdhistor,
                                             INPUT tel_nrdconta,
                                             INPUT glb_cddopcao).
                           
                   END.
               ELSE 
                   IF  glb_cddopcao = "I" THEN
                       DO:
                           RUN fontes/lislot_2.p(INPUT tel_cdagenci,     
                                                 INPUT tel_cdhistor,  
                                                 INPUT tel_nrdconta,  
                                                 INPUT glb_cddopcao). 


                       END.
               
               CLEAR FRAME f_dados.
               ASSIGN tel_cdagenci = 0               
                      tel_cdhistor = 0
                      tel_nrdconta = 0.


        END. /* fim da estrutura do cooperado */
    ELSE 
       IF tel_tpdopcao = "LOTE P/PA" THEN
          DO:
              ASSIGN tel_dtinicio = 
                         DATE(MONTH(glb_dtmvtolt), 01, YEAR(glb_dtmvtolt))
                     tel_dttermin = glb_dtmvtolt.
              
              tel_cdhistor:HELP IN FRAME f_dados = "Informe um Historico ou " +
                     "'0' (zero) para 8, 105, 626, 889, 351, 770, 397, 47, 621, 521.".

              DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                 UPDATE tel_cdhistor
                        tel_dtinicio
                        tel_dttermin
                        WITH FRAME f_dados.
                 LEAVE.
              END.
    
              IF KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
                 NEXT.

              RUN fontes/lislot_4.p(INPUT tel_cdhistor,
                                    INPUT tel_dtinicio,
                                    INPUT tel_dttermin,
                                    INPUT glb_cddopcao).

              CLEAR FRAME f_dados.
              ASSIGN tel_cdhistor = 0.
          END.
    ELSE
       DO: /* Estrutura Caixa-Online  */
          ASSIGN tel_dtinicio = DATE(MONTH(glb_dtmvtolt), 01, YEAR(glb_dtmvtolt))
                 tel_dttermin = glb_dtmvtolt.
          
          DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:
              UPDATE tel_cdagenci
                     tel_cdhistor
                     tel_dtinicio 
                     tel_dttermin
                     WITH FRAME f_dados.
               LEAVE.
          END.     

          IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
              NEXT.

          RUN fontes/lislot_3.p(INPUT tel_cdagenci,
                                INPUT tel_cdhistor,
                                INPUT tel_dtinicio,
                                INPUT tel_dttermin,
                                INPUT glb_cddopcao).

          CLEAR FRAME f_dados.
          ASSIGN tel_cdagenci = 0               
                 tel_cdhistor = 0
                 tel_nrdconta = 0.

       END. /* Fim da estrutura do caixa-online */

    ASSIGN glb_cddopcao = "T".

END. /* Fim DO WHILE TRUE */
