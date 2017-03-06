/*.............................................................................

   Programa: Fontes/ccarbb.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Diego   
   Data    : Outubro/2006                     Ultima Atualizacao: 15/02/2017

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Permitir Consulta de Limites Cartao BB e Bradesco.

   Alteracoes: 25/11/2006 - Acrescentada visualizacao por PAC na opcao "V"
                            (Diego).
                            
               20/12/2006 - Alterado help dos campos (Elton).
              
               10/07/2007 - Corrido problema de controle de acesso (Evandro).
               
               26/09/2007 - Incluida opcao X somente para operador 1 (Evandro).
               
               21/11/2007 - Incluida opcao Bradesco/BB (Opcao "C" / "V")
                            (Gabriel).
               
               06/12/2007 - Incluido valor contratado Bradesco/BB (Opcao "C")
                            (Gabriel).

               13/12/2007 - Efetuado acerto na opcao "C" para nao esconder a 
                            opcao escolhida (tel_bradesbb) (Diego).
              
               19/12/2007 - Incluido o valor contratado debito, e         
                            alterdo "valor contratado" para "valor contratado
                            credito" na opcao "C" (Gabriel).
                            
               07/01/2008 - Liberar operador 996 na opcao "X" (Diego).
               
               21/01/2008 - Incluida opcao "E" (Diego).
               
               10/06/2008 - Alteracoes de layout na opcao "C" (Guilherme).

               04/11/2008 - Inclusao da opcao "S" (Martin)
               
               06/02/2009 - Deletar criticas (crapeca) quando "E" (Gabriel)
               
               11/05/2009 - Alteracao CDOPERAD (Kbase).

               18/06/2009 - Eliminar registros crapeca (tipo de arquivo 510)
                            na opcao X (Fernando).

               18/09/2009 - Utilizar o valor limite de debito como metade do
                            valor limite de credito - Somente cartao Bradesco 
                           (Fernando).
               
               27/10/2009 - Alterado para utilizar a BO b1wgen0045.p que sera
                            agrupadora das funcoes compartilhadas com o CRPS524
                            
               15/03/2011 - Inclusao dos totais dos limites dos cartoes com 
                            status cancelado/bloqueado p/ consulta (Vitor)
                            
               03/10/2011 - Incluidas as opcoes "A" e "D" (Henrique).
               
               02/03/2012 - Alterada a opção "D" para filtar por Cod. Adm.
                            (Lucas).
                          
               23/04/2012 - Adicionado campo "Totais valor saque enviado BB" na 
                            opção consulta. (David Kruger).
               
               28/08/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).
                            
               03/12/2013 - Inclusao de VALIDATE crapcrd (Carlos)
               
               22/09/2014 - Alteração da mensagem com critica 77 substituindo pela 
                           b1wgen9999.p procedure acha-lock, que identifica qual 
                           é o usuario que esta prendendo a transaçao. (Vanessa)
                           
               30/11/2016 - Alterado campo dsdepart para cddepart.
                            PRJ341 - BANCENJUD (Odirlei-AMcom)
			  
			   15/02/2017 - Ajustando o format do campo nrctrcrd nos relatórios que o utilizam.
			     		    SD 594718 (Kelvin).	
............................................................................. */

{ includes/var_online.i }

               /* Valores da TAB048 para cartoes BB/ Bradesco  */
DEF   VAR tel_valorbra   AS DECIMAL                                  NO-UNDO.
DEF   VAR tel_valordbb   AS DECIMAL                                  NO-UNDO.
DEF   VAR tel_debitbra   AS DECIMAL                                  NO-UNDO.
DEF   VAR tel_debitabb   AS DECIMAL                                  NO-UNDO.
               /*Valores contratado credito, debito */ 
DEF   VAR tel_valorcre   AS DECIMAL  FORMAT "zzz,zzz,zz9.99"         NO-UNDO.
DEF   VAR tel_valordeb   AS DECIMAL  FORMAT "zzz,zzz,zz9.99"         NO-UNDO.

DEF   VAR tel_bradesbb   AS LOGICAL  FORMAT "Bradesco/BB" 
                                     INITIAL "Bradesco"              NO-UNDO.

DEF   VAR tel_cddopcao   AS CHAR     FORMAT "!"                      NO-UNDO.
DEF   VAR tel_nrdctitg   AS CHAR     FORMAT "x.xxx.xxx-x"            NO-UNDO.
DEF   VAR tel_vlcreuso   AS DECIMAL  FORMAT "zzz,zzz,zz9.99"         NO-UNDO.
DEF   VAR tel_vlsaquso   AS DECIMAL  FORMAT "zzz,zzz,zz9.99"         NO-UNDO.
DEF   VAR tel_vlcresol   AS DECIMAL  FORMAT "zzz,zzz,zz9.99"         NO-UNDO.
DEF   VAR tel_vlsaqsol   AS DECIMAL  FORMAT "zzz,zzz,zz9.99"         NO-UNDO.
DEF   VAR tel_vlcancel   AS DECIMAL  FORMAT "zzz,zzz,zz9.99"         NO-UNDO.
DEF   VAR tel_vltotsaq   AS DECIMAL  FORMAT "zzz,zzz,zz9.99"         NO-UNDO. 
DEF   VAR tel_cdagenci   AS INTEGER  FORMAT "z9"                     NO-UNDO.
DEF   VAR tel_qtcartao   AS INTEGER  FORMAT "zzz,zz9"                NO-UNDO.
DEF   VAR tel_qtcancel   AS INTEGER  FORMAT "zzz,zz9"                NO-UNDO.
DEF   VAR tel_qtdemuso   AS INTEGER  FORMAT "zzz,zz9"                NO-UNDO.
DEF   VAR tel_qtdsolic   AS INTEGER  FORMAT "zzz,zz9"                NO-UNDO.
DEF   VAR tel_nrctrcrd   AS INTEGER  FORMAT "zzz,zzz,zz9"            NO-UNDO.
DEF   VAR tel_cdadmcrd   LIKE crawcrd.cdadmcrd                       NO-UNDO.
DEF   VAR tel_nrcrcard   LIKE crawcrd.nrcrcard                       NO-UNDO.
DEF   VAR tel_nrcrdnov   LIKE crapcrd.nrcrcard                       NO-UNDO.
DEF   VAR tel_nrdconta   LIKE crapcrd.nrdconta                       NO-UNDO.
def   VAR tel_dtsolici   LIKE crawcrd.dtsolici                       NO-UNDO.

DEF   VAR aux_confirma   AS CHAR     FORMAT "!"                      NO-UNDO.
DEF   VAR aux_cddopcao   AS CHAR     FORMAT "!"                      NO-UNDO.
DEF   VAR aux_dssitcrd   AS CHAR     FORMAT "x(10)"                  NO-UNDO.
DEF   VAR aux_valorbra   AS DECIMAL                                  NO-UNDO.
DEF   VAR aux_cdadmcrd   AS INTEGER                                  NO-UNDO.
DEF   VAR aux_nrdconta   AS INTEGER                                  NO-UNDO.
DEF   VAR aux_cdagefim   AS INTEGER                                  NO-UNDO.
DEF   VAR aux_contador   AS INTEGER                                  NO-UNDO.
DEF   VAR aux_flgctitg   AS INTEGER                                  NO-UNDO.
DEF   VAR aux_nrcrcard   LIKE crawcrd.nrcrcard                       NO-UNDO.

DEF   VAR ret_vlcreuso   AS DECIMAL                                  NO-UNDO.
DEF   VAR ret_vllimcom   AS DECIMAL                                  NO-UNDO.
DEF   VAR ret_vlsaquso   AS DECIMAL                                  NO-UNDO.
DEF   VAR ret_valorcre   AS DECIMAL                                  NO-UNDO.  
DEF   VAR ret_valordeb   AS DECIMAL                                  NO-UNDO.
DEF   VAR ret_vlcancel   AS DECIMAL                                  NO-UNDO.
DEF   VAR ret_vlcresol   AS DECIMAL                                  NO-UNDO.
DEF   VAR ret_vlsaqsol   AS DECIMAL                                  NO-UNDO.
DEF   VAR ret_qtdemuso   AS INTEGER                                  NO-UNDO.
DEF   VAR ret_qtdsolic   AS INTEGER                                  NO-UNDO.
DEF   VAR ret_qtcartao   AS INTEGER                                  NO-UNDO.
DEF   VAR ret_qtcancel   AS INTEGER                                  NO-UNDO.

DEF   VAR aux_dadosusr AS CHAR                                       NO-UNDO.
DEF   VAR par_loginusr AS CHAR                                       NO-UNDO.
DEF   VAR par_nmusuari AS CHAR                                       NO-UNDO.
DEF   VAR par_dsdevice AS CHAR                                       NO-UNDO.
DEF   VAR par_dtconnec AS CHAR                                       NO-UNDO.
DEF   VAR par_numipusr AS CHAR                                       NO-UNDO.                                   

{ sistema/generico/includes/b1wgen0045tt.i }
DEF VAR h-b1wgen0045 AS HANDLE                                       NO-UNDO.
DEF VAR h-b1wgen9999 AS HANDLE                                       NO-UNDO.

/** Definicao da w-limites esta na sistema/generico/includes/b1wgen0045tt.i **/

DEF QUERY q_limites   FOR w-limites.
DEF BROWSE b_limites  QUERY q_limites
    DISPLAY w-limites.cdagenci  COLUMN-LABEL "Pa"     
            w-limites.nrdconta  COLUMN-LABEL "Conta"
            w-limites.nmtitcrd  COLUMN-LABEL "Titular"  
            w-limites.vllimcrd  COLUMN-LABEL "Vlr.Credito" 
            w-limites.vllimdeb  COLUMN-LABEL "Vlr.Debito"  
            WITH 7 DOWN WIDTH 78 OVERLAY.


RUN sistema/generico/procedures/b1wgen9999.p PERSISTENT SET h-b1wgen9999.
IF  VALID-HANDLE(h-b1wgen9999)  THEN
    DO:
       RUN p-conectagener IN h-b1wgen9999.
       IF  RETURN-VALUE = "OK"  THEN DO:
           RUN sistema/generico/procedures/b1wgen0045.p PERSISTENT 
               SET h-b1wgen0045.
           IF  NOT VALID-HANDLE(h-b1wgen0045)  THEN
               DO:
                   glb_nmdatela = "CCARBB".
               
                   BELL.
                   MESSAGE "Handle invalido para BO b1wgen0045.".
                   IF (glb_conta_script = 0) THEN
                       PAUSE 3 NO-MESSAGE.
                   RETURN.
               END.
       END.
    END.
ELSE DO:
   glb_nmdatela = "CCARBB".

   BELL.
   MESSAGE "Nao foi possivel efetuar conexao com o banco generico.".
   IF (glb_conta_script = 0) THEN
       PAUSE 3 NO-MESSAGE.
   RETURN.
END.

FORM SKIP(1)
     b_limites  HELP "Use as SETAS para navegar"
     SKIP
     WITH NO-BOX ROW 7 COLUMN 2 OVERLAY FRAME f_wlimites.

FORM crapadc.cdadmcrd    LABEL "Administradora" AT  1
     crapadc.nmresadm    
     w-limites.nrcrcard  LABEL "Cartao"         AT 47
     SKIP
     w-limites.dtmvtolt  LABEL "Data Proposta"  AT  2
     w-limites.dtentreg  LABEL "Data Entrega"   AT 29
     aux_dssitcrd        LABEL "Situacao"       AT 55
     WITH NO-LABEL NO-BOX SIDE-LABELS ROW 19 COLUMN 2 OVERLAY FRAME f_limite.

FORM tel_cddopcao  LABEL "  Opcao"  AUTO-RETURN 
                   HELP "Informe a opcao desejada (A, C, D, E, S, V ou X)." 
                   VALIDATE (tel_cddopcao = "A" OR
                             tel_cddopcao = "C" OR
                             tel_cddopcao = "D" OR
                             tel_cddopcao = "E" OR
                             tel_cddopcao = "V" OR
                             tel_cddopcao = "S" OR 
                             tel_cddopcao = "X",
                             "014 - Opcao errada.") 
     tel_bradesbb  LABEL "Bradesco/BB"
                   HELP 'Informe o banco, Bradesco ou Banco do Brasil'    AT 17
     tel_cdagenci  LABEL "PA"
                   HELP 'Informe o numero do PA ou 0 "zero" para todos.'  AT 41
     tel_qtcartao  LABEL "Quantidade de Cartoes"                          AT 49
     WITH ROW 6 COLUMN 2 OVERLAY SIDE-LABELS NO-BOX FRAME f_opcao.
       
FORM tel_valorcre  AT 6  LABEL "Valor contratado credito" 
     tel_valordeb  AT 6  LABEL "Valor contratado debito "
     SKIP (1)
    
     "==> Em uso"  AT 20 
     tel_vlcreuso  AT 10  LABEL "Totais valor credito"    
     tel_vlsaquso  AT 7  LABEL "Totais valor para saque" 
     tel_vltotsaq  AT 1  LABEL "Totais valor saque enviado BB"  
     tel_qtdemuso  AT 18 LABEL "Qtd. cartoes"            
     SKIP(1)
     "==> Solicitados"   AT 15 SKIP
     tel_vlcresol  AT 10  LABEL "Totais valor credito"    
     tel_vlsaqsol  AT 7  LABEL "Totais valor para saque" 
     tel_qtdsolic  AT 18 LABEL "Qtd. cartoes"            
     WITH ROW 8 COLUMN 2 OVERLAY SIDE-LABELS NO-LABEL NO-BOX FRAME f_limites.

FORM "==> Canc/Bloq" AT 5 SKIP
     tel_vlcancel    AT 3 LABEL "Tot. valor cred"
     tel_qtcancel    AT 6 LABEL "Qtd. cartoes"
     WITH ROW 12 COLUMN 47 OVERLAY SIDE-LABELS NO-LABEL NO-BOX FRAME f_limites2.

FORM tel_nrdctitg  AT 15 LABEL "Conta ITG"
                         HELP "Informe a conta integracao."
                         
     tel_nrcrcard  AT 40 LABEL "Conta Cartao"
                         HELP "Informe a conta cartao."
                         
     WITH ROW 9 COLUMN 2 OVERLAY SIDE-LABELS NO-LABEL NO-BOX FRAME f_opcao_x.
     
FORM tel_nrdctitg  AT 15 LABEL "Conta ITG"
                         HELP "Informe a conta integracao."
                         
     tel_cdadmcrd  AT 40 LABEL "Codigo Admin"
                         HELP "Informe o codigo da administradora."
                         
     WITH ROW 9 COLUMN 2 OVERLAY SIDE-LABELS NO-LABEL NO-BOX FRAME f_opcao_s.
      
FORM tel_nrdctitg  AT 13 LABEL "Conta ITG"
                         HELP "Informe a conta integracao."
                         
     tel_nrctrcrd  AT 40 LABEL "Proposta"
                         HELP "Informe o numero da Proposta."
     SKIP(1)
     tel_nrcrcard  AT 10 LABEL "Conta Cartao"
                         HELP "Informe a conta cartao."
     WITH ROW 9 COLUMN 2 OVERLAY SIDE-LABELS NO-LABEL NO-BOX FRAME f_opcao_e.

FORM tel_nrdconta  AT 18 LABEL "Conta/DV"
     tel_cdadmcrd  AT 40 LABEL "Codigo Admin"
                         HELP "Informe o codigo da administradora."
     SKIP(1)
     tel_dtsolici  AT 7 LABEL "Data de solicitacao"
     WITH ROW 9 COLUMN 2 OVERLAY SIDE-LABELS NO-LABEL NO-BOX FRAME f_opcao_d.

FORM tel_nrcrcard  LABEL "     Numero do cartao"
     SKIP
     tel_nrcrdnov  LABEL "Novo Numero do cartao"
     WITH ROW 10 COLUMN 15 OVERLAY SIDE-LABELS NO-LABEL NO-BOX FRAME f_opcao_a.

FORM WITH NO-LABEL TITLE COLOR MESSAGE " Consulta Limites Cartao Bradesco/BB "
                   ROW 4 COLUMN 1 SIZE 80 BY 18 OVERLAY WITH FRAME f_moldura.
     
     
ON VALUE-CHANGED, ENTRY OF b_limites
   DO:
       IF   AVAILABLE w-limites   THEN
            DO:
                IF   w-limites.insitcrd <> 4  THEN
                     ASSIGN aux_dssitcrd = "Solicitado".
                ELSE
                     ASSIGN aux_dssitcrd = "Em uso".
                     
                FIND crapadc WHERE crapadc.cdcooper = glb_cdcooper  AND
                                   crapadc.cdadmcrd = w-limites.cdadmcrd
                                   NO-LOCK NO-ERROR.
                
                DISPLAY crapadc.cdadmcrd 
                        crapadc.nmresadm 
                        w-limites.nrcrcard
                        aux_dssitcrd 
                        w-limites.dtmvtolt 
                        w-limites.dtentreg   WITH FRAME f_limite.
            END.
   END.

VIEW FRAME f_moldura.                                                
PAUSE(0).                           

ASSIGN tel_cddopcao = "C".

RUN fontes/inicia.p.
                             
DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
      
   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
     
      HIDE tel_cdagenci tel_qtcartao tel_bradesbb IN FRAME f_opcao.  
      UPDATE tel_cddopcao WITH FRAME f_opcao.
      glb_cddopcao = tel_cddopcao.
      LEAVE.  
   
   END.
      
   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 ou fim   */
        DO:
            RUN fontes/novatela.p.
            IF   CAPS(glb_nmdatela) <> "CCARBB"   THEN
                 DO:
                     HIDE FRAME f_moldura.
                     DELETE PROCEDURE h-b1wgen0045.
                     DELETE PROCEDURE h-b1wgen9999.
                     RETURN.
                 END.
            ELSE
                 NEXT. 
        END.
        
   IF   aux_cddopcao <> glb_cddopcao THEN
        DO:
            { includes/acesso.i }
            aux_cddopcao = glb_cddopcao.

            IF  aux_cddopcao = "A" OR 
                aux_cddopcao = "D" THEN
                DO:
                    IF  glb_cddepart <> 20 /* TI      */ AND
                        glb_cddepart <> 18 /* SUPORTE */ AND
                        glb_cddepart <>  2 /* CARTOES */ THEN 
                        NEXT.
                END.
        END.  
        
    CASE tel_cddopcao:             
     WHEN "A" THEN DO:
         ASSIGN aux_confirma = "N"
                tel_nrcrcard = 0
                tel_nrcrdnov = 0.

         UPDATE tel_nrcrcard WITH FRAME f_opcao_a.

         DO TRANSACTION:
            FIND crapcrd WHERE crapcrd.cdcooper = glb_cdcooper 
                           AND crapcrd.nrcrcard = tel_nrcrcard
                           AND crapcrd.cdadmcrd = 3
                           EXCLUSIVE-LOCK NO-ERROR.
            
            IF  AVAIL crapcrd THEN
                DO:
                   UPDATE tel_nrcrdnov WITH FRAME f_opcao_a.
            
                   FIND crawcrd WHERE crawcrd.cdcooper = glb_cdcooper 
                                  AND crawcrd.nrcrcard = tel_nrcrcard
                                  AND crawcrd.cdadmcrd = 3
                                  EXCLUSIVE-LOCK NO-ERROR.
            
                   IF  AVAIL crawcrd THEN
                       DO:
                            RUN fontes/confirma.p 
                                (INPUT "Confirma a alteracao do numero do" + 
                                       " cartao?",
                                 OUTPUT aux_confirma).     

                            IF  aux_confirma = "S" THEN
                                DO:
                                    ASSIGN crapcrd.nrcrcard = tel_nrcrdnov.
                                           crawcrd.nrcrcard = tel_nrcrdnov.
                                    
                                    UNIX SILENT VALUE ("echo " + 
                                           STRING(glb_dtmvtolt,"99/99/9999")  + 
                                           " " + STRING(TIME,"HH:MM:SS")      + 
                                           "' --> '"  + " Operador "          + 
                                           glb_cdoperad                       + 
                                           " Alterou o numero do cartao da "  +
                                           "conta: "                          + 
                                  STRING(crawcrd.nrdconta,"zzzz,zzz,9") +
                                           " >> log/ccarbb.log").     
                                    
                                    MESSAGE "Numero do cartao alterado.".
                                END.
                       END.
                    ELSE
                       DO:
                            UNIX SILENT VALUE ("echo " + 
                                        STRING(glb_dtmvtolt,"99/99/9999")  + 
                                        " " + STRING(TIME,"HH:MM:SS")      + 
                                        "' --> '"  + " Operador "          + 
                                        glb_cdoperad                       + 
                                        " Nao encontrou crawcrd - Conta: " + 
                                  STRING(crapcrd.nrdconta,"zzzz,zzz,9") +
                                        " >> log/ccarbb.log").   

                            MESSAGE "Erro na atualizacao do numero do cartao.".
                       END.
               END.
            ELSE
                MESSAGE "Cartao nao encontrado.".
         END. /* FIM do DO TRANSACTION */
     END. /* Fim da opcao A */ 
     WHEN "D" THEN DO:
         ASSIGN aux_confirma = "N"
                tel_nrdconta = 0 
                tel_dtsolici = ?
                tel_cdadmcrd = 0.

         UPDATE tel_nrdconta tel_cdadmcrd tel_dtsolici WITH FRAME f_opcao_d.

         DO TRANSACTION:

            FIND crawcrd WHERE crawcrd.cdcooper = glb_cdcooper
                           AND crawcrd.nrdconta = tel_nrdconta 
                           AND crawcrd.cdadmcrd = tel_cdadmcrd 
                           AND crawcrd.dtsolici = tel_dtsolici
                           AND crawcrd.nrcrcard = 0
                           EXCLUSIVE-LOCK NO-ERROR.
        
            IF AVAIL crawcrd THEN
               DO:                 

                  RUN fontes/confirma.p 
                                (INPUT "Confirma a exclusao da proposta?",
                                 OUTPUT aux_confirma).
                           
                  IF  aux_confirma = "S" THEN
                      DO:
                         ASSIGN aux_cdadmcrd = crawcrd.cdadmcrd
                                aux_nrdconta = crawcrd.nrdconta.
                         DELETE crawcrd.
                         MESSAGE "Proposta excluida.".

                         UNIX SILENT VALUE ("echo " + 
                                       STRING(glb_dtmvtolt,"99/99/9999")  + 
                                       " " + STRING(TIME,"HH:MM:SS")      + 
                                       "' --> '"  + " Operador "          + 
                                       glb_cdoperad                       + 
                                       " Excluiu o registro da conta: "   + 
                                    STRING(aux_nrdconta,"zzzz,zzz,9")     +
                                       " ADMINISTRADORA: "                + 
                                     STRING(aux_cdadmcrd)                 + 
                                     " >> log/ccarbb.log" ). 

                         HIDE FRAME f_opcao_d.

                      END.
               END.
            ELSE
                MESSAGE "Nenhuma proposta foi encontrada.".
         END.                       
     END. /* Fim da opcao D */ 
     WHEN "C" THEN DO: 
            HIDE FRAME f_opcao_x.
            HIDE FRAME f_opcao_e.
            
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
            
            ASSIGN tel_vlcreuso = 0
                   tel_vlsaquso = 0
                   tel_qtdemuso = 0
                   tel_vlcresol = 0
                   tel_vlsaqsol = 0
                   tel_qtdsolic = 0  
                   tel_valorcre = 0
                   tel_valordeb = 0
                   tel_vlcancel = 0
                   tel_qtcancel = 0
                   tel_vltotsaq = 0.
            
            UPDATE tel_bradesbb WITH FRAME f_opcao.
            
            /* BO INI */

            RUN limite-cartao-credito IN h-b1wgen0045( INPUT glb_cdcooper,
                               /** NO = BB **/         INPUT tel_bradesbb,
                               /** "C" = Consulta **/  INPUT tel_cddopcao,
                               /** Agenc. Ini */       INPUT tel_cdagenci,
                               /** Agenc. Fim */       INPUT aux_cdagefim,
                                                      OUTPUT ret_vllimcom,
                      /** Creditos/Lim. Concedido **/ OUTPUT tel_vlcreuso,
                               /** Debitos **/        OUTPUT tel_vlsaquso,
                                                      OUTPUT tel_qtdemuso,
                                                      OUTPUT tel_vlcresol,
                                                      OUTPUT tel_vlsaqsol,
                                                      OUTPUT tel_qtdsolic,
                                                      OUTPUT tel_qtcartao,
                                /* Limite Credito */  OUTPUT tel_valorcre,
                                /* Limite Debito  */  OUTPUT tel_valordeb,
                                                      OUTPUT tel_vlcancel,
                                                      OUTPUT tel_qtcancel,
                                                      OUTPUT TABLE w-limites,
                                                      OUTPUT tel_vltotsaq).
            /* BO FIM */

            DISPLAY tel_valorcre 
                    tel_valordeb  WITH FRAME f_limites.

            IF tel_bradesbb THEN
               HIDE tel_vltotsaq IN FRAME f_limites.
            ELSE
               DISPLAY tel_vltotsaq WITH FRAME f_limites.

            DISPLAY tel_vlcreuso 
                    tel_vlsaquso 
                    tel_qtdemuso 
                    tel_vlcresol 
                    tel_vlsaqsol 
                    tel_qtdsolic WITH FRAME f_limites.

            DISPLAY tel_vlcancel
                    tel_qtcancel WITH FRAME f_limites2.

            END. /* FIM DO WHILE*/

            HIDE FRAME f_limites.
            HIDE FRAME f_limites2.

     END.     /* Fim da opcao "C"  */

     WHEN "V" THEN
        DO:              
            EMPTY TEMP-TABLE w-limites.

            ASSIGN tel_qtcartao = 0.

            HIDE FRAME f_opcao_x.

            UPDATE tel_bradesbb 
                   tel_cdagenci WITH FRAME f_opcao.

            ASSIGN aux_cdagefim = IF tel_cdagenci = 0  THEN
                                     9999
                                  ELSE
                                     tel_cdagenci.

            /* BO INI */
            RUN limite-cartao-credito IN h-b1wgen0045( INPUT glb_cdcooper,
                               /** NO = BB **/         INPUT tel_bradesbb,
                               /** "C" = Consulta **/  INPUT tel_cddopcao,
                               /** Agenc. Ini */       INPUT tel_cdagenci,
                               /** Agenc. Fim */       INPUT aux_cdagefim,
                                                      OUTPUT ret_vllimcom,
                      /** Creditos/Lim. Concedido **/ OUTPUT ret_vlcreuso,
                               /** Debitos **/        OUTPUT ret_vlsaquso,
                                                      OUTPUT ret_qtdemuso,
                                                      OUTPUT ret_vlcresol,
                                                      OUTPUT ret_vlsaqsol,
                                                      OUTPUT ret_qtdsolic,
                                                      OUTPUT tel_qtcartao,
                                /* Limite Credito */  OUTPUT ret_valorcre,
                                /* Limite Debito  */  OUTPUT ret_valordeb,
                                                      OUTPUT ret_vlcancel,
                                                      OUTPUT ret_qtcancel,
                                                      OUTPUT TABLE w-limites,
                                                      OUTPUT tel_vltotsaq).
            /* BO FIM */

            DISPLAY tel_qtcartao WITH FRAME f_opcao.

            OPEN QUERY q_limites  FOR EACH w-limites BY w-limites.cdagenci.

            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
               UPDATE b_limites WITH FRAME f_wlimites.
               LEAVE.
            END.

            IF   KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
                 DO:
                     HIDE FRAME f_wlimites.
                     HIDE FRAME f_limite.
                     NEXT.
                 END.
        END.     /*    Fim opcao "V"    */

     WHEN "S" THEN
       DO:
        IF   glb_cddepart <> 20  AND /* TI      */
             glb_cddepart <> 18  AND /* SUPORTE */
             glb_cddepart <>  2 THEN /* CARTOES */
             DO:
                 glb_cdcritic = 36.
                 RUN fontes/critic.p.
                 BELL.
                 glb_cdcritic = 0.
                 MESSAGE glb_dscritic.
                 NEXT.
             END.
        
        HIDE tel_bradesbb IN FRAME f_opcao.
        HIDE FRAME f_opcao_e.
            
        UPDATE tel_nrdctitg
               tel_cdadmcrd WITH FRAME f_opcao_s
                               
        EDITING:

            DO WHILE TRUE:
            
               READKEY PAUSE 1.
      
               /* retringe a somente estes caracteres */
               IF   FRAME-FIELD = "tel_nrdctitg"   THEN
                    IF   NOT CAN-DO("0,1,2,3,4,5,6,7,8,9,x,RETURN,TAB," + 
                                    "BACKSPACE,DELETE-CHARACTER," +
                                    "BACK-TAB,CURSOR-LEFT,END-ERROR,HELP",
                                    KEYFUNCTION(LASTKEY))  THEN
                         LEAVE.
                               
               APPLY LASTKEY.
           
               LEAVE. 
    
            END.   /*  Fim do DO WHILE TRUE  */
            
        END.  /*  Fim do EDITING  */  
          
        /* checa se tel_cdadmcrd foi digitado dentro dos parametros */
        IF   tel_cdadmcrd < 83 or tel_cdadmcrd > 88 THEN
             DO:
                 BELL.
                 MESSAGE 
                 "Codigo da administradora fora de faixa (83 ate 88).".
                 HIDE tel_nrdctitg
                      tel_cdadmcrd IN FRAME f_opcao_s.
                 NEXT.
             END.
                                                     
        /* Preenche com ZEROS o que nao foi digitado */
        DO WHILE SUBSTRING(tel_nrdctitg,8,1) = "":
        
           DO aux_contador = 8 TO 2 BY -1:
              ASSIGN SUBSTRING(tel_nrdctitg,aux_contador,1) =
                              SUBSTRING(tel_nrdctitg,aux_contador - 1,1).
           END.
   
           SUBSTRING(tel_nrdctitg,1,1) = "0".
        END.
            
        DISPLAY tel_nrdctitg WITH FRAME f_opcao_s.  

        FIND crapass WHERE crapass.cdcooper = glb_cdcooper AND
                           SUBSTR(crapass.nrdctitg,1,7) = 
                                  SUBSTR(tel_nrdctitg,1,7)
                           NO-LOCK NO-ERROR.
                               
        IF   NOT AVAILABLE crapass   THEN
             DO:
                 glb_cdcritic = 9.
                 RUN fontes/critic.p.
                 BELL.
                 MESSAGE glb_dscritic.
                 glb_cdcritic = 0.
                 HIDE tel_nrdctitg
                      tel_cdadmcrd IN FRAME f_opcao_s.
                 NEXT.
             END.
                      
        /* Procura um cartao da administradoras informada e ITG */
        FIND crawcrd WHERE  crawcrd.cdcooper  = glb_cdcooper       AND
                            crawcrd.nrdconta  = crapass.nrdconta   AND
                            crawcrd.nrcrcard  = 0                  AND
                            crawcrd.cdadmcrd  = tel_cdadmcrd       AND
                            crawcrd.nrcctitg  = 0                  and
                            crawcrd.flgctitg  = 1
                            NO-LOCK NO-ERROR.
            
        /* Verifica se existe mais de 1 cartao zerado */
        IF   NOT AVAILABLE crawcrd   THEN
             DO:
                MESSAGE "Nao existe registro a ser alterado.".
                NEXT.
             END.
                 
        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

           ASSIGN aux_confirma = "N"
                  glb_cdcritic = 78.

           RUN fontes/critic.p.
           BELL.
           glb_cdcritic = 0.
           MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
           LEAVE.
        END.
                             
        IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
             aux_confirma <> "S"  THEN
             DO:
                 glb_cdcritic = 79.
                 RUN fontes/critic.p.
                 BELL.
                 MESSAGE glb_dscritic.
                 glb_cdcritic = 0.
                 NEXT.
             END.
                 
        /* Atualiza o registro do cartao */
        DO TRANSACTION:
    
           /* Procura um cartao das administradoras ITG e zerado */
           FIND crawcrd WHERE  crawcrd.cdcooper  = glb_cdcooper       AND
                               crawcrd.nrdconta  = crapass.nrdconta   AND
                               crawcrd.nrcrcard  = 0                  AND
                               crawcrd.cdadmcrd  = tel_cdadmcrd       AND
                               crawcrd.nrcctitg  = 0                  and
                               crawcrd.flgctitg  = 1
                               EXCLUSIVE-LOCK NO-WAIT NO-ERROR.
    
           IF   NOT AVAILABLE crawcrd   THEN
                DO:
                   IF   LOCKED crawcrd   THEN
                        DO:
                            RUN sistema/generico/procedures/b1wgen9999.p
                            PERSISTENT SET h-b1wgen9999.
                            
                            RUN acha-lock IN h-b1wgen9999 (INPUT RECID(crawcrd),
                            					 INPUT "banco",
                            					 INPUT "crawcrd",
                            					 OUTPUT par_loginusr,
                            					 OUTPUT par_nmusuari,
                            					 OUTPUT par_dsdevice,
                            					 OUTPUT par_dtconnec,
                            					 OUTPUT par_numipusr).
                            
                            DELETE PROCEDURE h-b1wgen9999.
                            
                            ASSIGN aux_dadosusr = 
                            "077 - Tabela sendo alterada p/ outro terminal.".
                            
                            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                            MESSAGE aux_dadosusr.
                            PAUSE 3 NO-MESSAGE.
                            LEAVE.
                            END.
                            
                            ASSIGN aux_dadosusr = "Operador: " + par_loginusr +
                            			  " - " + par_nmusuari + ".".
                            
                            HIDE MESSAGE NO-PAUSE.
                            
                            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                            MESSAGE aux_dadosusr.
                            PAUSE 5 NO-MESSAGE.
                            LEAVE.
                            END.
                                                      
                            NEXT.
                        END.
                   ELSE
                        DO:
                            glb_cdcritic = 276.
                            LEAVE.
                        END.    
                END.
           ELSE
                DO:
                    ASSIGN crawcrd.flgctitg = 4. /* reenvio */
                    RELEASE crawcrd.
                END.
           LEAVE.
          
        END.  /*  Fim do DO... TO TRANSACTION  */

        IF   glb_cdcritic > 0 THEN
             DO:
                 RUN fontes/critic.p.
                 BELL.
                 MESSAGE glb_dscritic.
                 glb_cdcritic = 0.
                 PAUSE 3 NO-MESSAGE.
                 NEXT.
             END.

       END.
     WHEN "X" THEN
        DO:
            IF   glb_cddepart <> 20 AND  /* TI      */
                 glb_cddepart <> 18 AND  /* SUPORTE */
                 glb_cddepart <>  2 THEN /* CARTOES */
                 DO:
                     glb_cdcritic = 36.
                     RUN fontes/critic.p.
                     BELL.
                     glb_cdcritic = 0.
                     MESSAGE glb_dscritic.
                     NEXT.
                 END.
        
            HIDE tel_bradesbb IN FRAME f_opcao.
            HIDE FRAME f_opcao_e.
            
            UPDATE tel_nrdctitg
                   tel_nrcrcard WITH FRAME f_opcao_x
                               
            EDITING:

                DO WHILE TRUE:
            
                   READKEY PAUSE 1.
      
                   /* retringe a somente estes caracteres */
                   IF   FRAME-FIELD = "tel_nrdctitg"   THEN
                        IF   NOT CAN-DO("0,1,2,3,4,5,6,7,8,9,x,RETURN,TAB," + 
                                        "BACKSPACE,DELETE-CHARACTER," +
                                        "BACK-TAB,CURSOR-LEFT,END-ERROR,HELP",
                                        KEYFUNCTION(LASTKEY))  THEN
                             LEAVE.
                               
                   APPLY LASTKEY.
           
                   LEAVE. 
    
                END.   /*  Fim do DO WHILE TRUE  */
            
            END.  /*  Fim do EDITING  */    
                                                     
            /* Preenche com ZEROS o que nao foi digitado */
            DO WHILE SUBSTRING(tel_nrdctitg,8,1) = "":

               DO aux_contador = 8 TO 2 BY -1:
                  ASSIGN SUBSTRING(tel_nrdctitg,aux_contador,1) =
                                  SUBSTRING(tel_nrdctitg,aux_contador - 1,1).
               END.
   
               SUBSTRING(tel_nrdctitg,1,1) = "0".
            END.
            
            DISPLAY tel_nrdctitg WITH FRAME f_opcao_x.  

            FIND crapass WHERE crapass.cdcooper = glb_cdcooper AND
                               SUBSTR(crapass.nrdctitg,1,7) = 
                                      SUBSTR(tel_nrdctitg,1,7)
                               NO-LOCK NO-ERROR.
                               
            IF   NOT AVAILABLE crapass   THEN
                 DO:
                     glb_cdcritic = 9.
                     RUN fontes/critic.p.
                     BELL.
                     MESSAGE glb_dscritic.
                     glb_cdcritic = 0.
                     HIDE tel_nrdctitg
                          tel_nrcrcard IN FRAME f_opcao_x.
                     NEXT.
                 END.
                      
            /* Procura um cartao das administradoras ITG e zerado */
            FIND crawcrd WHERE  crawcrd.cdcooper  = glb_cdcooper       AND
                                crawcrd.nrdconta  = crapass.nrdconta   AND
                                crawcrd.nrcrcard  = 0                  AND
                                crawcrd.cdadmcrd  > 82                 AND
                                crawcrd.cdadmcrd  < 89                     
                                NO-LOCK NO-ERROR.
            
            /* Verifica se existe mais de 1 cartao zerado */
            IF   NOT AVAILABLE crawcrd   THEN
                 DO:
                     FIND FIRST crawcrd WHERE 
                                crawcrd.cdcooper  = glb_cdcooper      AND
                                crawcrd.nrdconta  = crapass.nrdconta  AND
                                crawcrd.nrcrcard  = 0                 AND
                                crawcrd.cdadmcrd  > 82                AND
                                crawcrd.cdadmcrd  < 89                      
                                NO-LOCK NO-ERROR.
                                
                     IF   AVAILABLE crawcrd   THEN
                          MESSAGE "Existe mais de um cartao zerado!.".
                     ELSE
                          MESSAGE "Nao existe cartao zerado!".
                          
                     NEXT.
                 END.
                 
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

               ASSIGN aux_confirma = "N"
                      glb_cdcritic = 78.

               RUN fontes/critic.p.
               BELL.
               glb_cdcritic = 0.
               MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
               LEAVE.
            END.
                             
            IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
                 aux_confirma <> "S"  THEN
                 DO:
                     glb_cdcritic = 79.
                     RUN fontes/critic.p.
                     BELL.
                     MESSAGE glb_dscritic.
                     glb_cdcritic = 0.
                     NEXT.
                 END.
                 
            /* Atualiza o registro do cartao */
            DO aux_contador = 1 TO 10 TRANSACTION:
    
               /* Procura um cartao das administradoras ITG e zerado */
               FIND crawcrd WHERE crawcrd.cdcooper  = glb_cdcooper       AND
                                  crawcrd.nrdconta  = crapass.nrdconta   AND
                                  crawcrd.nrcrcard  = 0                  AND
                                  crawcrd.cdadmcrd  > 82                 AND
                                  crawcrd.cdadmcrd  < 89                     
                                  EXCLUSIVE-LOCK NO-WAIT NO-ERROR.
    
               IF   NOT AVAILABLE crawcrd   THEN
                    DO:
                       IF   LOCKED crawcrd   THEN
                            DO:
                                RUN sistema/generico/procedures/b1wgen9999.p
                                PERSISTENT SET h-b1wgen9999.
                                
                                RUN acha-lock IN h-b1wgen9999 (INPUT RECID(crawcrd),
                                					 INPUT "banco",
                                					 INPUT "crawcrd",
                                					 OUTPUT par_loginusr,
                                					 OUTPUT par_nmusuari,
                                					 OUTPUT par_dsdevice,
                                					 OUTPUT par_dtconnec,
                                					 OUTPUT par_numipusr).
                                
                                DELETE PROCEDURE h-b1wgen9999.
                                
                                ASSIGN aux_dadosusr = 
                                "077 - Tabela sendo alterada p/ outro terminal.".
                                
                                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                MESSAGE aux_dadosusr.
                                PAUSE 3 NO-MESSAGE.
                                LEAVE.
                                END.
                                
                                ASSIGN aux_dadosusr = "Operador: " + par_loginusr +
                                			  " - " + par_nmusuari + ".".
                                
                                HIDE MESSAGE NO-PAUSE.
                                
                                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                MESSAGE aux_dadosusr.
                                PAUSE 5 NO-MESSAGE.
                                LEAVE.
                                END.                                
                               
                                NEXT.
                                                            END.
                       ELSE
                            DO:
                                glb_cdcritic = 276.
                                LEAVE.
                            END.    
                    END.
               ELSE
                    DO:
                        ASSIGN crawcrd.flgctitg = 2 /* cadastrado */
                               crawcrd.insitcrd = 4 /* em uso     */
                               crawcrd.nrcctitg = tel_nrcrcard /* inteiro recebendo decimal */
                               crawcrd.nrcrcard = tel_nrcrcard
                               crawcrd.dtentreg = glb_dtmvtolt
                               crawcrd.dtanuida = glb_dtmvtolt
                               crawcrd.vlanuida = 0
                               crawcrd.inanuida = 0
                               crawcrd.qtanuida = 0
                               crawcrd.qtparcan = 0
                               crawcrd.cdoperad = glb_cdoperad.

                        CREATE crapcrd.
                        ASSIGN crapcrd.nrdconta = crawcrd.nrdconta
                               crapcrd.nrcrcard = crawcrd.nrcrcard
                               crapcrd.nrctrcrd = crawcrd.nrctrcrd
                               crapcrd.nrcpftit = crawcrd.nrcpftit
                               crapcrd.nmtitcrd = crawcrd.nmtitcrd
                               crapcrd.dddebito = crawcrd.dddebito
                               crapcrd.cdlimcrd = crawcrd.cdlimcrd
                               crapcrd.dtvalida = crawcrd.dtvalida
                               crapcrd.tpcartao = crawcrd.tpcartao
                               crapcrd.cdadmcrd = crawcrd.cdadmcrd
                               crapcrd.dtcancel = ?
                               crapcrd.cdmotivo = 0
                               crapcrd.cdcooper = glb_cdcooper.

                        VALIDATE crapcrd.
                        
                        IF  glb_cdcritic = 0 THEN
                            DO:
                               FOR EACH
                                   crapeca WHERE
                                   crapeca.cdcooper = glb_cdcooper       AND
                                   crapeca.nrdconta = crapass.nrdconta   AND
                                   crapeca.tparquiv = 510    EXCLUSIVE-LOCK:
                         
                                   DELETE crapeca.
                               END.
                            END.
                        
                        /*** LOGAR ***/
                        UNIX SILENT VALUE
                                  ("echo " +
                                   STRING(glb_dtmvtolt,"99/99/9999") + 
                                   " " + STRING(TIME,"HH:MM:SS") + 
                                   "' --> '"  + " Operador " + glb_cdoperad + 
                                   " Criou cartao: " + 
                                   STRING(crapcrd.nrcrcard,
                                          "9999,9999,9999,9999") + 
                                   ", Proposta: " + 
                                   STRING(crapcrd.nrctrcrd,"zzz,zz9") +  
                                   ", Conta ITG.: " +
                                   STRING(crapass.nrdctitg,"9.999.999-X")  
                                   + " >> log/ccarbb.log").                  
                                   
                        RELEASE crawcrd.
                        RELEASE crapcrd.
                    END.
               LEAVE.
            
            END.  /*  Fim do DO... TO TRANSACTION  */

            IF   glb_cdcritic > 0 THEN
                 DO:
                     RUN fontes/critic.p.
                     BELL.
                     MESSAGE glb_dscritic.
                     glb_cdcritic = 0.
                     PAUSE 3 NO-MESSAGE.
                     NEXT.
                 END.
                 
        END.   /* Fim da opcao "X"  */
   
     WHEN "E" THEN
        DO:
            IF   glb_cddepart <> 20 AND  /* TI      */
                 glb_cddepart <> 18 AND  /* SUPORTE */
                 glb_cddepart <>  2 THEN /* CARTOES */
                 DO:
                     glb_cdcritic = 36.
                     RUN fontes/critic.p.
                     BELL.
                     glb_cdcritic = 0.
                     MESSAGE glb_dscritic.
                     NEXT.
                 END.
        
            HIDE FRAME f_opcao_x.
            
            UPDATE tel_nrdctitg tel_nrctrcrd
                   tel_nrcrcard WITH FRAME f_opcao_e.
                                                     
            /* Preenche com ZEROS o que nao foi digitado */
            DO WHILE SUBSTRING(tel_nrdctitg,8,1) = "":

               DO aux_contador = 8 TO 2 BY -1:
                  ASSIGN SUBSTRING(tel_nrdctitg,aux_contador,1) =
                                  SUBSTRING(tel_nrdctitg,aux_contador - 1,1).
               END.
   
               SUBSTRING(tel_nrdctitg,1,1) = "0".
            END.
                                                        
            DISPLAY tel_nrdctitg WITH FRAME f_opcao_e.
                                                        
            FIND crapass WHERE crapass.cdcooper = glb_cdcooper AND
                               SUBSTR(crapass.nrdctitg,1,7) = 
                                      SUBSTR(tel_nrdctitg,1,7)
                               NO-LOCK NO-ERROR.
                               
            IF   NOT AVAILABLE crapass   THEN
                 DO:
                     glb_cdcritic = 9.
                     RUN fontes/critic.p.
                     BELL.
                     MESSAGE glb_dscritic.
                     glb_cdcritic = 0.
                     NEXT.
                 END.
           
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

               ASSIGN aux_confirma = "N"
                      glb_cdcritic = 78.

               RUN fontes/critic.p.
               BELL.
               glb_cdcritic = 0.
               MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
               LEAVE.
            END.
                             
            IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
                 aux_confirma <> "S"  THEN
                 DO:
                     glb_cdcritic = 79.
                     RUN fontes/critic.p.
                     BELL.
                     MESSAGE glb_dscritic.
                     glb_cdcritic = 0.
                     NEXT.
                 END.
                  
            /* Atualiza o registro do cartao */
            DO aux_contador = 1 TO 10 TRANSACTION:
              
               FIND crawcrd WHERE crawcrd.cdcooper = glb_cdcooper       AND
                                  crawcrd.nrdconta = crapass.nrdconta   AND
                                  crawcrd.nrctrcrd = tel_nrctrcrd       AND
                                  crawcrd.nrcrcard = tel_nrcrcard       
                                  EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                                  
               IF   NOT AVAILABLE crawcrd   THEN       
                    IF   LOCKED crawcrd   THEN
                         DO:
                             glb_cdcritic = 341.
                             PAUSE 2 NO-MESSAGE.
                             NEXT.
                         END.                            
                    ELSE
                         DO:
                             glb_cdcritic = 546.
                             LEAVE.   
                         END.                          
               ELSE
                    DO:
                        ASSIGN aux_nrcrcard = crawcrd.nrcrcard
                               aux_flgctitg = crawcrd.flgctitg.
                        
                        IF   tel_nrcrcard <> 0  THEN
                             DO aux_contador = 1 TO 10:

                                FIND  crapcrd WHERE 
                                      crapcrd.cdcooper = glb_cdcooper      AND
                                      crapcrd.nrdconta = crawcrd.nrdconta  AND
                                      crapcrd.nrcrcard = crawcrd.nrcrcard
                                      EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
       
                                IF   NOT AVAILABLE crapcrd   THEN
                                     IF   LOCKED crapcrd   THEN
                                          DO:
                                              glb_cdcritic = 341.
                                              PAUSE 2 NO-MESSAGE.
                                              NEXT.
                                          END.
                                     ELSE
                                          DO:
                                              glb_cdcritic = 546.
                                              LEAVE.
                                          END.
                                ELSE
                                     DO:
                                         ASSIGN crawcrd.insitcrd = 5
                                                crawcrd.flgctitg = 3 /*Inativa*/
                                                crawcrd.dtcancel = glb_dtmvtolt
                                                crawcrd.cdmotivo = 0
                                                crawcrd.cdoperad = glb_cdoperad
                                                crawcrd.nrcrcard =
                                            INT("1" + STRING(crawcrd.nrcrcard))

                                                crapcrd.nrcrcard =
                                            INT("1" + STRING(crawcrd.nrcrcard))
                                                crapcrd.dtcancel = glb_dtmvtolt
                                                crapcrd.cdmotivo = 0
                                                glb_cdcritic     = 0. 
                                                
                                     END.
                                     
                                RELEASE crapcrd.
                                     
                                LEAVE.

                             END.
                        ELSE
                             DO:
                                 ASSIGN crawcrd.insitcrd = 5
                                        crawcrd.flgctitg = 3 /*Inativa*/
                                        crawcrd.dtcancel = glb_dtmvtolt
                                        crawcrd.cdmotivo = 0
                                        crawcrd.cdoperad = glb_cdoperad
                                        glb_cdcritic     = 0.
                             END.
                             
                        IF   glb_cdcritic = 0  THEN
                             FOR EACH crapeca WHERE 
                                      crapeca.cdcooper = glb_cdcooper       AND
                                      crapeca.nrdconta = crapass.nrdconta   AND
                                      crapeca.tparquiv = 510    EXCLUSIVE-LOCK:
                                 DELETE crapeca.
                             END.
                             
                        IF   glb_cdcritic = 0  THEN      /* LOGAR */
                             UNIX SILENT VALUE ("echo " +
                                   STRING(glb_dtmvtolt,"99/99/9999") + 
                                   " " + STRING(TIME,"HH:MM:SS") + 
                                   "' --> '"  + " Operador " +
                                   glb_cdoperad + " Cancelou cartao: " +
                                   STRING(aux_nrcrcard,"9999,9999,9999,9999") +
                                   ", Proposta: " +
                                   STRING(tel_nrctrcrd,"zzz,zz9") + 
                                   ", Conta ITG.: " + 
                                   STRING(tel_nrdctitg,"9.999.999-X") + 
                                   ", Situacao de envio: " +
                                   STRING(aux_flgctitg) + ". Numero atual do"
                                   + " cartao: " +
                                 STRING(crawcrd.nrcrcard,"9999,9999,9999,9999")
                                   + " >> log/ccarbb.log").
                        
                        RELEASE crawcrd.
                        
                    END.

               LEAVE.           

            END.  /*  Fim do DO TRANSACTION  */
            
            IF   glb_cdcritic > 0 THEN
                 DO:
                     RUN fontes/critic.p.
                     BELL.
                     MESSAGE glb_dscritic.
                     glb_cdcritic = 0.
                     PAUSE 3 NO-MESSAGE.
                     NEXT.
                 END.    
        END. /* END do "E"*/
     END CASE.
        
END. /* Fim DO WHILE TRUE  */

RUN p_desconectagener IN h-b1wgen9999.
DELETE PROCEDURE h-b1wgen0045.
DELETE PROCEDURE h-b1wgen9999.


PROCEDURE carrega_limites:

   
    FOR EACH crawcrd WHERE crawcrd.cdcooper   = glb_cdcooper  AND
                          ((crawcrd.cdadmcrd > 82             AND
                          crawcrd.cdadmcrd   < 89             AND
                          tel_bradesbb = NO)                  OR
                          (crawcrd.cdadmcrd  =  3             AND
                          tel_bradesbb = YES))                AND
                          CAN-DO("0,1,4,5",STRING(crawcrd.insitcrd))
                          NO-LOCK:
       
       IF   tel_cddopcao = "V"  THEN
            DO:
                 FIND crapass WHERE crapass.cdcooper    = glb_cdcooper      AND
                                    crapass.nrdconta    = crawcrd.nrdconta  AND
                                    ((crapass.cdagenci >= tel_cdagenci      AND
                                    crapass.cdagenci   <= aux_cdagefim)     OR
                                    (crapass.cdagenci   = tel_cdagenci      AND 
                                    tel_cdagenci <> 0)) NO-LOCK NO-ERROR.
                       
                 IF   NOT AVAILABLE crapass  THEN
                      NEXT.
            END.
            
       FIND craptlc WHERE craptlc.cdcooper = glb_cdcooper       AND
                          craptlc.cdadmcrd = crawcrd.cdadmcrd   AND
                          craptlc.tpcartao = crawcrd.tpcartao   AND
                          craptlc.cdlimcrd = crawcrd.cdlimcrd   AND
                          craptlc.dddebito = 0  NO-LOCK NO-ERROR.

       FIND crapass WHERE crapass.cdcooper = glb_cdcooper       AND
                          crapass.nrdconta = crawcrd.nrdconta
                          NO-LOCK NO-ERROR.

       IF   tel_cddopcao = "C"  THEN
            DO:
                IF   crawcrd.insitcrd = 4  THEN  /* Em uso */
                     DO:
                        ASSIGN tel_vlcreuso = tel_vlcreuso + craptlc.vllimcrd
                               tel_qtdemuso = tel_qtdemuso + 1.

                        IF   tel_bradesbb   THEN
                             tel_vlsaquso = tel_vlsaquso + 
                                                     (craptlc.vllimcrd / 2).
                        ELSE
                             tel_vlsaquso = tel_vlsaquso + crapass.vllimdeb.
                     END.
                ELSE
                 IF   crawcrd.insitcrd = 5  THEN  /* Cancelado/Bloqueado */
                     DO:
                        ASSIGN tel_vlcancel = tel_vlcancel + craptlc.vllimcrd
                               tel_qtcancel = tel_qtcancel + 1.

                     END.
                ELSE  /* Solicitado */ 
                     DO:
                        ASSIGN tel_vlcresol = tel_vlcresol + craptlc.vllimcrd
                               tel_qtdsolic = tel_qtdsolic + 1.
                     
                        IF   tel_bradesbb   THEN
                             tel_vlsaqsol = tel_vlsaqsol +
                                                     (craptlc.vllimcrd / 2).
                        ELSE
                             tel_vlsaqsol = tel_vlsaqsol + crapass.vllimdeb.
                     END.
            END.
       ELSE
           IF   crawcrd.insitcrd <> 5  THEN  /* Cancelado/Bloqueado */ 
                DO:
                    CREATE w-limites.
                    ASSIGN w-limites.cdagenci = crapass.cdagenci
                           w-limites.nrdconta = crawcrd.nrdconta
                           w-limites.cdadmcrd = crawcrd.cdadmcrd
                           w-limites.nrcrcard = crawcrd.nrcrcard
                           w-limites.nmtitcrd = crawcrd.nmtitcrd   
                           w-limites.insitcrd = crawcrd.insitcrd
                           w-limites.vllimcrd = craptlc.vllimcrd
                           w-limites.vllimdeb = crapass.vllimdeb
                           w-limites.dtmvtolt = crawcrd.dtmvtolt
                           w-limites.dtentreg = crawcrd.dtentreg
                           
                           tel_qtcartao = tel_qtcartao + 1.
                END.                                               
   END.          /* Fim do FOR EACH */
   
END PROCEDURE.

/*****************************************************************************/
