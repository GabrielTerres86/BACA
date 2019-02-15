/* ............................................................................

   Programa: Fontes/sldccr.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Marco/97.                          Ultima atualizacao: 26/05/2018

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Rotina para montar o limite de cartoes de credito.

   Alteracoes: Tratar novo cartao (Odair)
       
               15/12/2000 - Exluir proposta cartao credito (Margarete/Planner)

               23/02/2001 - Acerta o erro do aux_cdadmcrd. (Ze Eduardo).

               01/08/2001 - Incluir geracao de nota promissoria (Margarete).

               19/07/2002 - Imprimir promissoria no contrato (Margarete).

               11/06/2004 - Criacao de procedure para atualizacao da tela a 
                            cada alteracao (Julio)

               18/06/2004 - Alterada a aux_iddopcao de "Liberar" para "Alterar"
                            (Julio) 

               26/01/2006 - Unificacao dos Bancos - SQLWorks - Luciane.
               
               10/04/2006 - Chamar progr. com administ. de 2 digitos (Evandro).
               
               19/06/2006 - Modificada Situacao "Em Uso" para "Prc.BB" se for
                            Cartao BB (Diego).
                            
               05/07/2006 - Chamar novo programa para Contrato de Utilizacao de
                            Cartao das administradoras BB (Diego).
                            
               19/09/2006 - Alterado o nome da rotina e permitir o uso do
                            F2-AJUDA (Evandro).
                            
               29/01/2008 - Alterado LABEL de Cancelar para "Canc/Blq"
                            (Guilherme).
                            
               04/03/2008 - Nao permitido solicitar novo cartao para Pessoa
                            Juridica (Elton).          
                               
               21/08/2008 - Adaptar permissoes devido a nova atenda (David).
               
               20/05/2009 - Alteracao para utilizacao de BOs - Temp-tables -
                            GATI - Eder
                            
               26/08/2010 - Alteracao PJ -
                            GATI - Sandro
                            
               25/11/2010 - Incluido parametro flgliber na proc. lista_cartoes
                            para tratar bloqueio das op. de cartoes do Pac 5 da 
                            Coop.2 (Transferencia do Pac) (Irlan)
                            
               17/01/2011 - Desbloquear rotia Habilitar (Diego).  
               
               21/02/2011 - Incluida a opção Encerrar para atender o cartão do 
                            Banco do Brasil. (Isara - RKAM) 
                            
               21/03/2011 - Desabilitado temporariamente a opcao "Encerrar"
                            (Irlan)           
                            
               12/04/2011 - Trocado permissão: "SUPORTE" por "CARTOES" (Irlan)
               
               13/04/2011 - Retirar a restrição do grupo de usuario na opção
                            "Encerrar". (Irlan)
                            
               12/07/2011 - Atualizacao da variavel aux_nrctrhcj antes
                            de verificar condicao inpessoa, no momento da
                            impressao; corrigindo assim, a impressao para
                            PJ, que pegava o numero do contrato de habilitacao.
                            (Fabricio)
                            
               18/07/2011 - Inclusao da opcao extrato na tela.
                            (Andre E/Supero)
                            
               12/09/2011 - Incluir parametro para a chamada do 
                            fontes/sldccr_2vop.p (Ze/Fabricio).
                            
               04/01/2012 - Ajuste na restricao do ano no filtro de extrato,
                            de "ano atual" para "ano atual + 1" (Adriano).
                                
               17/08/2012 - Corrigido a impressao do contrato e emissao  
                            proposta cartao (Tiago).      
                            
               20/06/2013 - Retirado tratamento da opcao 4 - Liberar 
                            conforme solicitado softdesk 71086 (Daniel).          
                            
               06/08/2013 - Alterado tamanho do extend tab_dsdopcao e retirado a 
                            opcao "L" Liberar (Daniel).
                            
               17/03/2014 - Bloqueio de alteracao de limite para cartoes cecred 
                            visa por setor diferente de CARTOES (Carlos).
                            
               29/05/2014 - Bloqueio de opcoes para Cartoes BANCOOB (Jean Michel).
               
               14/07/2014 - Permitir exlcusão de cartões bancoob se situação for
                            1 (aprovado) (Lucas Lunelli - Projeto Cartões Bancoob).
                            
               18/07/2014 - Incluso tratamento para nao lista todo numero
				            do cartao de credito (Daniel) SD 179666.
                            
               28/07/2014 - Novo tratamento para exibição parcial do
                            número do cartão (Lunelli).
                                                      
               06/12/2016 - Alterado campo dsdepart para cddepart.
                            PRJ341 - BANCENJUD (Odirlei-AMcom)       
							
			   26/05/2018 - Ajustes referente alteracao da nova marca (P413 - Jonata Mouts).      
                                                      
.............................................................................*/

{ sistema/generico/includes/b1wgen0028tt.i }
{ sistema/generico/includes/var_internet.i }
{ includes/var_sldccr.i "NEW" }
{ includes/var_online.i }
{ includes/var_atenda.i }

DEF  INPUT PARAM par_flgtecla AS LOGI                                  NO-UNDO.

DEF VAR tel_dsimppro AS CHAR INIT "Proposta"                           NO-UNDO.
DEF VAR tel_dsimpctr AS CHAR INIT "Contrato"                           NO-UNDO.
DEF VAR tel_dsipepro AS CHAR INIT "Emissao"                            NO-UNDO.
DEF VAR tel_dtextrat AS CHAR                                           NO-UNDO.

DEF VAR tel_dslimite AS CHAR INIT "Limite Cartao Credito"  
                             FORMAT "x(22)"                            NO-UNDO.
DEF VAR tel_dsdatavc AS CHAR INIT "Data Vencimento"  
                             FORMAT "x(15)"                            NO-UNDO.
DEF VAR tel_dslimdeb AS CHAR INIT "Limite Debito"    
                             FORMAT "x(13)"                            NO-UNDO.
                             
DEF VAR tab_dsdopcao AS CHAR EXTENT 12 INIT
                             ["N","M","C","F","A",
                              "2","R","X","Z","E","T","H"]             NO-UNDO.
                              
DEF VAR aux_confirma AS CHAR FORMAT "!"                                NO-UNDO.
DEF VAR aux_dsproctr AS CHAR                                           NO-UNDO.
DEF VAR aux_dsdopcao AS CHAR EXTENT 11 INIT  
                             ["Novo","Impr","Consult",
                              "Entreg","Alter","2via","Renov",
                              "Canc/Blq","Encerrar","Excl","Extrat"]   NO-UNDO.
                              
DEF VAR aux_dsdopcao_pj AS CHAR EXTENT 12 INIT  
                             ["Novo","Impr","Consul",
                              "Entr","Alter","2via","Renov",
                              "Canc/Blq","Encerrar","Excl",
                              "Extrat","Habil"]                        NO-UNDO.


DEF VAR aux_inpessoa AS INTE                                           NO-UNDO.
DEF VAR aux_flgativo AS LOGI                                           NO-UNDO.
DEF VAR aux_nrctrhcj AS INTE                                           NO-UNDO.
DEF VAR aux_flgliber AS LOGI                                           NO-UNDO.
DEF VAR aux_dtassele AS DATE                                           NO-UNDO. /* Data assinatura eletronica */
DEF VAR aux_dsvlrprm AS CHAR                                           NO-UNDO. /* Data de corte */

DEF VAR aux_iddopcao AS INTE                                           NO-UNDO.
DEF VAR aux_nrdlinha AS INTE                                           NO-UNDO.

DEF VAR aux_flglimit AS LOGI                                           NO-UNDO.
DEF VAR aux_flglimdb AS LOGI                                           NO-UNDO.
DEF VAR aux_flgreabr AS LOGI INIT TRUE                                 NO-UNDO.
DEF VAR aux_flgadmbb AS LOGI                                           NO-UNDO.

DEF VAR aux_qtopcoes AS INTE                                           NO-UNDO.

DEF VAR h_b1wgen0028 AS HANDLE                                         NO-UNDO.

DEF VAR aux_rowidcar AS ROWID                                          NO-UNDO.

/* variaveis para impressao */
DEF VAR aux_nmendter AS CHAR FORMAT "x(20)"                            NO-UNDO.
DEF VAR aux_nmarqimp AS CHAR FORMAT "x(40)"                            NO-UNDO.
DEF VAR tel_cddopcao AS CHAR FORMAT "x(1)"                             NO-UNDO.
DEF VAR par_flgrodar AS LOGI INIT TRUE                                 NO-UNDO.
DEF VAR aux_flgescra AS LOGI                                           NO-UNDO.
DEF VAR aux_dscomand AS CHAR                                           NO-UNDO.
DEF VAR par_flgfirst AS LOGI INIT TRUE                                 NO-UNDO.
DEF VAR tel_dsimprim AS CHAR FORMAT "x(8)" INIT "Imprimir"             NO-UNDO.
DEF VAR tel_dscancel AS CHAR FORMAT "x(8)" INIT "Cancelar"             NO-UNDO.
DEF VAR par_flgcance AS LOGI                                           NO-UNDO.
DEF VAR aux_dtvctini AS DATE                                           NO-UNDO.
DEF VAR aux_dtvctfim AS DATE                                           NO-UNDO.


DEF QUERY q_cartoes FOR tt-cartoes.

DEF QUERY q_cartoes_pj FOR tt-cartoes.
     
DEF BROWSE b_cartoes QUERY q_cartoes
    DISP tt-cartoes.nmtitcrd COLUMN-LABEL "Titular"        FORMAT "X(26)"
         tt-cartoes.nmresadm COLUMN-LABEL "Administradora" FORMAT "X(18)"
         tt-cartoes.dscrcard COLUMN-LABEL "Numero Cartao"  FORMAT "X(19)"
         tt-cartoes.dssitcrd COLUMN-LABEL "Situac"         FORMAT "X(6)"
         WITH 7 DOWN NO-BOX.
         
DEF BROWSE b_cartoes_pj QUERY q_cartoes_pj
    DISP tt-cartoes.nrdconta COLUMN-LABEL "Conta/dv"       FORMAT "zzzz,zzz,9"
         tt-cartoes.nmtitcrd COLUMN-LABEL "Titular"        FORMAT "X(15)"
         tt-cartoes.nmresadm COLUMN-LABEL "Administradora" FORMAT "X(18)"          
         tt-cartoes.dscrcard COLUMN-LABEL "Numero Cartao"  FORMAT "X(19)"         
         tt-cartoes.dssitcrd COLUMN-LABEL "Situac"         FORMAT "X(6)"
         WITH 7 DOWN NO-BOX.

FORM SPACE(2)
     aux_dsdopcao[1]  FORMAT "x(4)"
     aux_dsdopcao[2]  FORMAT "x(4)"
     aux_dsdopcao[3]  FORMAT "x(7)"
     aux_dsdopcao[4]  FORMAT "x(6)"    
     aux_dsdopcao[5]  FORMAT "x(5)"
     aux_dsdopcao[6]  FORMAT "x(4)"
     aux_dsdopcao[7]  FORMAT "x(5)"
     aux_dsdopcao[8]  FORMAT "x(8)"
     aux_dsdopcao[9]  FORMAT "x(8)"
     aux_dsdopcao[10] FORMAT "x(4)"
     aux_dsdopcao[11] FORMAT "x(6)"
     SPACE(3)
     WITH ROW 20 CENTERED NO-BOX NO-LABELS OVERLAY FRAME f_opcoes.


FORM SPACE(2)
     aux_dsdopcao_pj[1]  FORMAT "x(4)"
     aux_dsdopcao_pj[2]  FORMAT "x(4)"
     aux_dsdopcao_pj[3]  FORMAT "x(6)"
     aux_dsdopcao_pj[4]  FORMAT "x(4)"
     aux_dsdopcao_pj[5]  FORMAT "x(5)"
     aux_dsdopcao_pj[6]  FORMAT "x(4)"
     aux_dsdopcao_pj[7]  FORMAT "x(5)"
     aux_dsdopcao_pj[8]  FORMAT "x(8)"
     aux_dsdopcao_pj[9] FORMAT "x(4)"
     aux_dsdopcao_pj[10] FORMAT "x(5)"
     aux_dsdopcao_pj[11] FORMAT "x(7)"
     aux_dsdopcao_pj[12] FORMAT "x(5)"
     SPACE(3)
     WITH ROW 20 CENTERED NO-BOX NO-LABELS OVERLAY FRAME f_opcoes_pj.


FORM b_cartoes
     WITH ROW 9 CENTERED TITLE COLOR NORMAL " Cartoes de Credito " 
          FRAME f_cartoes OVERLAY.

FORM b_cartoes_pj
     WITH ROW 9 CENTERED TITLE COLOR NORMAL " Cartoes de Credito "
          FRAME f_cartoes_pj OVERLAY.

FORM SKIP(1)
     tel_dsimppro AT 10
     HELP "Tecle <Entra> para confirmar ou <Fim> para retornar."
     tel_dsimpctr AT 30
     HELP "Tecle <Entra> para confirmar ou <Fim> para retornar."
     SKIP(1)
     WITH ROW 14 COLUMN 14 OVERLAY CENTERED  WIDTH 48
     NO-LABELS TITLE COLOR NORMAL " Impressao " FRAME f_imprimir.
     
FORM SKIP(1)
     tel_dsimppro AT 10
     HELP "Tecle <Entra> para confirmar ou <Fim> para retornar."
     tel_dsimpctr AT 30
     HELP "Tecle <Entra> para confirmar ou <Fim> para retornar."
     tel_dsipepro AT 50
     HELP "Tecle <Entra> para confirmar ou <Fim> para retornar."
     SKIP(1)
     WITH ROW 14 COLUMN 14 OVERLAY CENTERED  WIDTH 68
     NO-LABELS TITLE COLOR NORMAL " Impressao " FRAME f_imprimir_pj.

FORM SKIP(1)
     tel_dslimite AT 05
     HELP "Tecle <Entra> para confirmar ou <Fim> para retornar."
     tel_dsdatavc AT 34
     HELP "Tecle <Entra> para confirmar ou <Fim> para retornar."
     SKIP(1)
     WITH ROW 14 COLUMN 8 OVERLAY CENTERED  WIDTH 55
     NO-LABELS TITLE COLOR NORMAL "Alterar Limite ou Data de Vencimento" 
               FRAME f_opcao.
                     
FORM SKIP(1)
     tel_dslimdeb AT  2
     HELP "Tecle <Entra> para confirmar ou <Fim> para retornar."
     tel_dslimite AT 18 
     HELP "Tecle <Entra> para confirmar ou <Fim> para retornar."
     tel_dsdatavc AT 43
     HELP "Tecle <Entra> para confirmar ou <Fim> para retornar."
     SKIP(1)
     WITH ROW 14 COLUMN 8 OVERLAY CENTERED  WIDTH 60
     NO-LABELS TITLE COLOR NORMAL "Alterar Limites ou Data de Vencimento" 
               FRAME f_opcao2. 
FORM SKIP(1)
      tt-cartoes.dscrcard LABEL "Numero Cartao" 
                   FORMAT "X(19)"  COLON 25 
     SKIP(1)
     tel_dtextrat LABEL "Periodo Extrato" COLON 25
                  FORMAT "99/9999"
     WITH SIDE-LABELS ROW 10 WIDTH 60
     OVERLAY CENTERED TITLE COLOR NORMAL " Extrato "
                FRAME f_extrato.
                                              
ON ANY-KEY OF b_cartoes    IN FRAME f_cartoes OR 
   ANY-KEY OF b_cartoes_pj IN FRAME f_cartoes_pj
    DO:

    IF  aux_inpessoa = 2 THEN
        ASSIGN aux_qtopcoes = 12.
    ELSE
        ASSIGN aux_qtopcoes = 11.
               
    IF   KEYFUNCTION(LASTKEY) = "CURSOR-RIGHT"   THEN
         DO:
             aux_iddopcao = aux_iddopcao + 1.
    
             IF   aux_iddopcao > aux_qtopcoes   THEN
                  aux_iddopcao = 1.

             IF  aux_qtopcoes = 12 THEN

                 CHOOSE FIELD aux_dsdopcao_pj[aux_iddopcao] PAUSE 0
                        WITH FRAME f_opcoes_pj.

             ELSE

                 CHOOSE FIELD aux_dsdopcao[aux_iddopcao] PAUSE 0
                        WITH FRAME f_opcoes.


         END.
    ELSE
    IF   KEYFUNCTION(LASTKEY) = "CURSOR-LEFT"   THEN
         DO:
             aux_iddopcao = aux_iddopcao - 1.
 
             IF   aux_iddopcao < 1   THEN
                  aux_iddopcao = aux_qtopcoes.

             IF  aux_qtopcoes = 12 THEN

                CHOOSE FIELD aux_dsdopcao_pj[aux_iddopcao] PAUSE 0
                    WITH FRAME f_opcoes_pj.

             ELSE

                 CHOOSE FIELD aux_dsdopcao[aux_iddopcao] PAUSE 0
                        WITH FRAME f_opcoes.

         END.
    ELSE
    IF   KEYFUNCTION(LASTKEY) = "HELP"   THEN
         APPLY "HELP".
    ELSE
    IF   CAN-DO("GO,RETURN",KEYFUNCTION(LASTKEY))   THEN
         DO:
             ASSIGN aux_nrdlinha = 0.
                            
             IF   CAN-FIND(FIRST tt-cartoes)   THEN 
                  DO:

                      IF  aux_qtopcoes = 12 THEN
                          ASSIGN aux_nrdlinha = CURRENT-RESULT-ROW("q_cartoes_pj").
                      ELSE
                          ASSIGN aux_nrdlinha = CURRENT-RESULT-ROW("q_cartoes").
                  END.

             APPLY "GO".
         END.
END.


IF  NOT VALID-HANDLE(h_b1wgen0028) THEN
    RUN sistema/generico/procedures/b1wgen0028.p
        PERSISTENT SET h_b1wgen0028.

ASSIGN aux_inpessoa = DYNAMIC-FUNCTION("f_tipo_assoc" IN h_b1wgen0028,glb_cdcooper,tel_nrdconta).

DELETE PROCEDURE h_b1wgen0028.

RUN sistema/generico/procedures/b1wgen0028.p PERSISTENT SET h_b1wgen0028.

RUN lista_cartoes IN h_b1wgen0028 ( INPUT glb_cdcooper,
                                    INPUT 0,
                                    INPUT 0,
                                    INPUT glb_cdoperad,
                                    INPUT tel_nrdconta,
                                    INPUT 1,
                                    INPUT 1,
                                    INPUT glb_nmdatela,
                                    INPUT par_flgtecla,
                                   OUTPUT aux_flgativo,
                                   OUTPUT aux_nrctrhcj,
                                   OUTPUT aux_flgliber,
                                   OUTPUT TABLE tt-erro,
                                   OUTPUT TABLE tt-cartoes,
                                   OUTPUT TABLE tt-lim_total).
                                  
DELETE PROCEDURE h_b1wgen0028.

IF  RETURN-VALUE = "NOK"  THEN
    DO:
        FIND FIRST tt-erro NO-LOCK NO-ERROR.
        
        IF  AVAIL tt-erro  THEN
            DO:
                BELL.
                MESSAGE tt-erro.dscritic.
                RETURN "NOK".
            END.
    END.
                                 
FIND tt-lim_total NO-ERROR.

IF  AVAIL tt-lim_total  THEN
    ASSIGN aux_vltotccr = tt-lim_total.vltotccr.

IF  par_flgtecla  THEN
    DO:    
        IF  aux_iddopcao = 0  THEN
            IF  CAN-FIND(FIRST tt-cartoes)  THEN
                ASSIGN aux_iddopcao = 3. /* Consulta */
            ELSE
                ASSIGN aux_iddopcao = 1. /* Inclusao */

         IF  aux_inpessoa = 2 THEN
             DO:

                 DISPLAY aux_dsdopcao_pj WITH FRAME f_opcoes_pj.

                 CHOOSE FIELD aux_dsdopcao_pj[aux_iddopcao] PAUSE 0
                        WITH FRAME f_opcoes_pj.

             END.
        ELSE
             DO:

                 DISPLAY aux_dsdopcao WITH FRAME f_opcoes.

                 CHOOSE FIELD aux_dsdopcao[aux_iddopcao] PAUSE 0
                        WITH FRAME f_opcoes.

             END.

        DO WHILE TRUE:
         
            IF  aux_flgreabr  THEN 
                DO:
                    RUN sistema/generico/procedures/b1wgen0028.p 
                        PERSISTENT SET h_b1wgen0028.
                    
                    RUN lista_cartoes IN h_b1wgen0028
                                               ( INPUT glb_cdcooper,
                                                 INPUT 0,
                                                 INPUT 0,
                                                 INPUT glb_cdoperad,
                                                 INPUT tel_nrdconta,
                                                 INPUT 1,
                                                 INPUT 1,
                                                 INPUT glb_nmdatela,
                                                 INPUT par_flgtecla,
                                                OUTPUT aux_flgativo,
                                                OUTPUT aux_nrctrhcj,
                                                OUTPUT aux_flgliber,
                                                OUTPUT aux_dtassele,
                                                OUTPUT aux_dsvlrprm,
                                                OUTPUT TABLE tt-erro,
                                                OUTPUT TABLE tt-cartoes,
                                                OUTPUT TABLE tt-lim_total).
                    
                    DELETE PROCEDURE h_b1wgen0028.
                    
                    IF  RETURN-VALUE = "NOK"  THEN
                        DO:
                            FIND FIRST tt-erro NO-LOCK NO-ERROR.
                            
                            IF  AVAIL tt-erro  THEN
                                DO:
                                    BELL.
                                    MESSAGE tt-erro.dscritic.
                                END.
                        
                            LEAVE.
                        END.
     
                    FIND tt-lim_total NO-LOCK NO-ERROR.
                     
                    IF  AVAIL tt-lim_total  THEN
                        ASSIGN aux_vltotccr = tt-lim_total.vltotccr.

                    IF  aux_inpessoa = 2 THEN DO:

                        OPEN QUERY q_cartoes_pj FOR EACH tt-cartoes NO-LOCK.

                        IF  aux_nrdlinha > 0  THEN
                            REPOSITION q_cartoes_pj TO ROW(aux_nrdlinha).

                    END.
                    ELSE DO:


                        OPEN QUERY q_cartoes FOR EACH tt-cartoes NO-LOCK.

                        IF  aux_nrdlinha > 0  THEN
                            REPOSITION q_cartoes TO ROW(aux_nrdlinha).


                    END.
                    
                    ASSIGN aux_flgreabr = FALSE.
                END.
                
            IF  aux_inpessoa = 2 THEN DO:

                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                    UPDATE b_cartoes_pj WITH FRAME f_cartoes_pj.
                    LEAVE.

                END.


            END.
            ELSE DO:

                    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                
                        UPDATE b_cartoes WITH FRAME f_cartoes.
                        LEAVE.
            
                    END.

            END.

            IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
                LEAVE.      
                 
            IF  NOT CAN-FIND(FIRST tt-cartoes) AND
                ((aux_inpessoa = 1             AND  
                  aux_iddopcao <> 1)            OR /* Novo PF */
                 (aux_inpessoa = 2             AND 
                  aux_iddopcao <> 1            AND /* novo */
                  aux_iddopcao <> 12           AND /* habilitar pj */
                  aux_flgativo = FALSE)         OR 
                 (aux_inpessoa = 2             AND 
                  aux_iddopcao <> 12           AND  /* habilitar pj */
                  aux_iddopcao <> 1            AND  /* novo */
                  aux_iddopcao <> 2            AND  /* imprimir */
                  aux_flgativo = TRUE)    )   THEN
                NEXT.

            ASSIGN glb_cddopcao = tab_dsdopcao[aux_iddopcao]
                   glb_nmrotina = "CARTAO CRED".
                    
            { includes/acesso.i }

            IF  aux_iddopcao = 1  THEN /* NOVO */
                IF  aux_flgliber THEN 
                    DO:        
                        RUN fontes/sldccr_n.p.

                        IF  RETURN-VALUE = "OK"  THEN
                            ASSIGN aux_flgreabr = TRUE.
                    END.
                ELSE
                    RUN mensagem_transf_pac.p.
            ELSE
            IF  aux_iddopcao = 2  THEN /* IMPRIMIR */
                DO:
                    
                    IF tt-cartoes.cdadmcrd <= 80  AND
                                tt-cartoes.cdadmcrd >= 10 THEN
                        DO:
                            BELL.
                            MESSAGE "Opcao indisponivel para CARTOES BANCOOB".
                            NEXT.
                        END.

                        DO WHILE TRUE ON ENDKEY UNDO, LEAVE.
                    
                            IF  aux_inpessoa = 1 THEN
                                DO:
                                    DISPLAY tel_dsimppro tel_dsimpctr
                                            WITH FRAME f_imprimir.
    
                                    CHOOSE FIELD tel_dsimppro tel_dsimpctr
                                            WITH FRAME f_imprimir.
    
                                END.
                            ELSE
                                DO:
                                    DISPLAY tel_dsimppro tel_dsimpctr tel_dsipepro
                                            WITH FRAME f_imprimir_pj.
    
                                    CHOOSE FIELD tel_dsimppro tel_dsimpctr tel_dsipepro
                                            WITH FRAME f_imprimir_pj.
    
                                END.
                            
                            ASSIGN aux_flgimp2v = NO.
                                       
                            IF  aux_inpessoa = 1 THEN
                                DO:
                                    ASSIGN aux_nrctrhcj = tt-cartoes.nrctrcrd.
    
                                    IF  tt-cartoes.cdadmcrd >= 83  AND
                                        tt-cartoes.cdadmcrd <= 88   THEN  
                                        ASSIGN aux_dsproctr = "fontes/sldccr_ctbb.p".
                                    ELSE  
                                        ASSIGN aux_dsproctr = "fontes/sldccr_ct" + 
                                                              STRING(tt-cartoes.cdadmcrd) +
                                                              ".p".                     
    
                                END.
                            ELSE
                                ASSIGN aux_dsproctr = "fontes/sldccr_ct2.p".
    
                            IF  FRAME-VALUE = tel_dsimppro  THEN
                                RUN fontes/sldccr_ip.p (INPUT aux_nrctrhcj,1).
                            ELSE
                                IF  aux_inpessoa = 1 THEN
                                    RUN VALUE(aux_dsproctr) (INPUT aux_nrctrhcj).
                                ELSE
                                    IF  FRAME-VALUE = tel_dsimpctr  THEN
                                        RUN fontes/sldccr_ct2.p (INPUT aux_nrctrhcj).
                                    ELSE
                                        DO:
                                            
                                            IF  AVAIL tt-cartoes THEN
                                                RUN fontes/sldccr_ip.p (INPUT tt-cartoes.nrctrcrd,2).
                                        END.
                                        
    
                        END. /* Fim do DO WHILE TRUE */
                              
                        IF  aux_inpessoa = 1 THEN
                            HIDE FRAME f_imprimir NO-PAUSE.
                        ELSE
                            HIDE FRAME f_imprimir_pj NO-PAUSE.
    
                    END.

                    
            ELSE
            IF  aux_iddopcao = 3  THEN /* CONSULTAR */
                RUN fontes/sldccr_c.p (INPUT tt-cartoes.nrctrcrd).
            ELSE
            IF  aux_iddopcao = 4  THEN /* ENTREGAR */
                IF  aux_flgliber THEN
                    DO:
                        RUN sistema/generico/procedures/b1wgen0028.p
                                PERSISTENT SET h_b1wgen0028.
                        
                        RUN verifica_cartao_bb IN h_b1wgen0028
                                                 (INPUT glb_cdcooper,
                                                  INPUT 0,
                                                  INPUT 0,
                                                  INPUT tt-cartoes.cdadmcrd,
                                                 OUTPUT TABLE tt-erro).
                        
                        DELETE PROCEDURE h_b1wgen0028.
                                          
                        IF  RETURN-VALUE = "NOK"  THEN
                            DO:
                                FIND FIRST tt-erro NO-LOCK NO-ERROR.
                                
                                IF  AVAIL tt-erro THEN
                                    DO:
                                            BELL.
                                            MESSAGE tt-erro.dscritic.
                                    END.
                            
                                NEXT.
                            END.
                        
                        RUN fontes/sldccr_e.p (INPUT tt-cartoes.nrctrcrd,
                                               INPUT tt-cartoes.cdadmcrd).
                                                                 
                        IF  RETURN-VALUE = "OK"  THEN
                                ASSIGN aux_flgreabr = TRUE.
                    END.
                ELSE
                    RUN mensagem_transf_pac.p.
            ELSE
            IF  aux_iddopcao = 5  THEN /* ALTERAR */
                IF  aux_flgliber THEN
                    DO:
                        IF tt-cartoes.cdadmcrd <= 80  AND
                                tt-cartoes.cdadmcrd >= 10 THEN
                            DO:
                                BELL.
                                MESSAGE "Opcao indisponivel para CARTOES BANCOOB".
                                NEXT.
                            END.
                        ELSE
                            DO:
                                RUN sistema/generico/procedures/b1wgen0028.p
                                PERSISTENT SET h_b1wgen0028.
                                
                                RUN verifica_acesso_alterar IN h_b1wgen0028
                                                      (INPUT glb_cdcooper,
                                                       INPUT 0,
                                                       INPUT 0,
                                                       INPUT glb_cdoperad,
                                                       INPUT tel_nrdconta,
                                                       INPUT tt-cartoes.nrctrcrd,
                                                      OUTPUT aux_flgadmbb,
                                                      OUTPUT TABLE tt-erro).
                                        
                                DELETE PROCEDURE h_b1wgen0028.
                                                          
                                IF  RETURN-VALUE = "NOK"  THEN
                                    DO:
                                        FIND FIRST tt-erro NO-LOCK NO-ERROR.
                                          
                                        IF  AVAILABLE tt-erro  THEN
                                            DO:
                                                    BELL.
                                                    MESSAGE tt-erro.dscritic.
                                            END.
                                                        
                                        NEXT.
                                    END.
                                                
                                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                                  
                                    IF  aux_flgadmbb = TRUE  THEN
                                        DO:
                                            DISPLAY tel_dslimdeb tel_dslimite tel_dsdatavc
                                                            WITH FRAME f_opcao2.
                                            
                                            CHOOSE FIELD tel_dslimdeb
                                                                     tel_dslimite
                                                                     tel_dsdatavc
                                                                     WITH FRAME f_opcao2.
                                        END.
                                    ELSE
                                        DO:
                                            DISPLAY tel_dslimite tel_dsdatavc 
                                                            WITH FRAME f_opcao.
                                            
                                            CHOOSE FIELD tel_dslimite tel_dsdatavc
                                                                     WITH FRAME f_opcao.
                                        END.
        
                                    ASSIGN aux_flglimit = (FRAME-VALUE = tel_dslimite)
                                               aux_flglimdb = (FRAME-VALUE = tel_dslimdeb).
        
                                    HIDE FRAME f_opcao  NO-PAUSE.
                                    HIDE FRAME f_opcao2 NO-PAUSE.
                            
                                    IF  aux_flglimit  THEN
                                        DO:
                                            /* Bloqueio de alteracao de limite para cartoes cecred visa por 
                                              setor diferente de CARTOES */
                                            IF  aux_flgadmbb  = FALSE AND 
                                                glb_cddepart <> 2     THEN /* CARTOES */
                                                DO:
                                                    glb_dscritic = "Administradora de cartoes AILOS VISA bloqueada.".
                                                    MESSAGE glb_dscritic.
                                                    glb_dscritic = "".
                                                    PAUSE 2 NO-MESSAGE.
                                                    NEXT.
                                                END.
        
                                            RUN fontes/sldccr_t.p (INPUT tt-cartoes.nrctrcrd,
                                                                       INPUT tt-cartoes.nrcrcard).
                                        END.
                                    ELSE
                                    IF  aux_flglimdb  THEN
                                            RUN fontes/sldccr_db.p (INPUT tt-cartoes.nrctrcrd,
                                                                    INPUT tt-cartoes.nrcrcard).
                                    ELSE
                                            RUN fontes/sldccr_dt.p (INPUT tt-cartoes.nrctrcrd,
                                                                    INPUT tt-cartoes.nrcrcard,
                                                                    INPUT tt-cartoes.cdadmcrd).
        
                                    IF  RETURN-VALUE = "OK"  THEN
                                        ASSIGN aux_flgreabr = TRUE.
                                        
                                END. /* DO WHILE TRUE */
                            END.
                    END.
                ELSE
                        RUN mensagem_transf_pac.p.
            ELSE
            IF  aux_iddopcao = 6  THEN /* 2a. VIA */
                IF  aux_flgliber THEN
                    DO:
                        RUN fontes/sldccr_2vop.p (INPUT tt-cartoes.nrctrcrd,
                                                  INPUT tt-cartoes.nrcrcard,
                                                  INPUT tt-cartoes.cdadmcrd).
                                                                           
                        IF  RETURN-VALUE = "OK"  THEN
                            ASSIGN aux_flgreabr = TRUE.
                    END.
                ELSE
                        RUN mensagem_transf_pac.p.
            ELSE
            IF  aux_iddopcao = 7  THEN /* RENOVAR */
                IF  aux_flgliber THEN
                    DO:
                        IF tt-cartoes.cdadmcrd <= 80  AND
                                tt-cartoes.cdadmcrd >= 10 THEN
                            DO:
                                BELL.
                                MESSAGE "Opcao indisponivel para CARTOES BANCOOB".
                                NEXT.
                            END.
                        ELSE
                            DO:
                                RUN fontes/sldccr_r.p (INPUT tt-cartoes.nrctrcrd,
                                                       INPUT tt-cartoes.nrcrcard,
                                                       INPUT tt-cartoes.cdadmcrd).
                              
                                IF  RETURN-VALUE = "OK"  THEN
                                        ASSIGN aux_flgreabr = TRUE.
                            END.
                    END. 
                ELSE
                        RUN mensagem_transf_pac.p.
            ELSE
            IF  aux_iddopcao = 8  THEN /* CANCELAMENTO/BLOQUEIO */
                IF  aux_flgliber THEN  
                    DO:
                        IF tt-cartoes.cdadmcrd <= 80  AND
                                tt-cartoes.cdadmcrd >= 10 THEN
                            DO:
                                BELL.
                                MESSAGE "Opcao indisponivel para CARTOES BANCOOB".
                                NEXT.
                            END.
                        ELSE
                            DO:
                                RUN fontes/sldccr_x.p (INPUT tt-cartoes.nrctrcrd,
                                                       INPUT tt-cartoes.nrcrcard,
                                                       INPUT tt-cartoes.cdadmcrd).
                                                              
                                IF  RETURN-VALUE = "OK"  THEN
                                        ASSIGN aux_flgreabr = TRUE.
                            END.
                    END.
                ELSE
                        RUN mensagem_transf_pac.p.  
            ELSE
            IF  aux_iddopcao = 9  THEN DO:  /* ENCERRAR */
                DO:
                    IF  aux_flgliber THEN  
                    DO:
                        IF NOT (tt-cartoes.cdadmcrd > 82  AND
                                tt-cartoes.cdadmcrd < 89) THEN
                        DO:
                            BELL.
                            MESSAGE "Opcao valida somente para CARTOES VISA BB".
                        END.
                        ELSE
                        DO:
                            RUN fontes/sldccr_enc.p (INPUT tt-cartoes.nrctrcrd,
                                                     INPUT tt-cartoes.nrcrcard,
                                                     INPUT tt-cartoes.cdadmcrd).
                                                                              
                            IF  RETURN-VALUE = "OK"  THEN
                                ASSIGN aux_flgreabr = TRUE.
                        END.
                    END.
                    ELSE
                        RUN mensagem_transf_pac.p.
                END.
            END.
            ELSE
            IF  aux_iddopcao = 10  THEN /* EXCLUIR */
                IF  aux_flgliber THEN
                    DO:                       
                        IF (tt-cartoes.cdadmcrd <= 80             AND
                            tt-cartoes.cdadmcrd >= 10)            AND
                            CAPS(tt-cartoes.dssitcrd) <> "APROV." THEN
                            DO:
                                BELL.
                                MESSAGE "Opcao disponivel apenas para cartoes situacao ESTUDO/APROV.".
                                NEXT.
                            END.
                        ELSE
                            DO:

                            ASSIGN aux_confirma = "N".
                            
                            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
    
                                    MESSAGE COLOR NORMAL "Confirma exclusao da proposta?" 
                                                    UPDATE aux_confirma.
                                    LEAVE.
                            
                            END.  
    
                            IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  OR
                                    aux_confirma <> "S"                 THEN
                                    NEXT.
    
                            RUN sistema/generico/procedures/b1wgen0028.p
                                    PERSISTENT SET h_b1wgen0028.
                            
                            RUN exclui_cartao IN h_b1wgen0028
                                                (INPUT glb_cdcooper,
                                                 INPUT 0,
                                                 INPUT 0,
                                                 INPUT glb_cdoperad,
                                                 INPUT tel_nrdconta,
                                                 INPUT tt-cartoes.nrctrcrd,
                                                 INPUT glb_dtmvtolt,
                                                 INPUT 1,
                                                 INPUT 1,
                                                 INPUT glb_nmdatela,
                                                OUTPUT TABLE tt-erro).
                            
                            DELETE PROCEDURE h_b1wgen0028.
                                                               
                            IF  RETURN-VALUE = "NOK"  THEN
                                DO:
                                    FIND FIRST tt-erro NO-LOCK NO-ERROR.
                                    
                                    IF  AVAIL tt-erro  THEN
                                        DO:
                                                BELL.
                                                MESSAGE tt-erro.dscritic.
                                        END.
                            
                                    NEXT.
                                END.
                                                       
                            ASSIGN aux_flgreabr = TRUE.
                        END.
                    END.
                ELSE
                        RUN mensagem_transf_pac.p.
            ELSE
            IF  aux_iddopcao = 11 THEN DO: /* EXTRATO */
                IF  aux_flgliber THEN DO:
                    IF tt-cartoes.cdadmcrd <= 80  AND
                       tt-cartoes.cdadmcrd >= 10 THEN
                        DO:
                            BELL.
                            MESSAGE "Opcao indisponivel para CARTOES BANCOOB".
                            NEXT.
                        END.
                    ELSE
                        DO:
                        IF  tt-cartoes.cdadmcrd = 3 THEN DO:
                            
                            DISP tt-cartoes.dscrcard WITH FRAME f_extrato.
    
                            ASSIGN tel_dtextrat = "".
    
                            DO WHILE TRUE ON ENDKEY UNDO, LEAVE.
    
                                UPDATE tel_dtextrat 
                                       WITH FRAME f_extrato.
    
                                IF INTE(SUBSTR(tel_dtextrat,01,02)) > 12 OR
                                   INTE(SUBSTR(tel_dtextrat,01,02)) = 0  OR
                                   INTE(SUBSTR(tel_dtextrat,03,04)) > (YEAR(glb_dtmvtolt) + 1) THEN
    
                                   MESSAGE "Periodo informado invalido".
    
                                ELSE DO:
                                     ASSIGN aux_dtvctini = DATE (INTE(SUBSTR(tel_dtextrat,1,2)),
                                                                 1,
                                                                 inte(SUBSTR(tel_dtextrat,3,4))).
                                     ASSIGN aux_dtvctfim = IF (INTE(SUBSTR(tel_dtextrat,1,2)) + 1) = 13 THEN
                                                              DATE(12,31,INTE(SUBSTR(tel_dtextrat,3,4)))
                                                          ELSE
                                                              DATE (INTE(SUBSTR(tel_dtextrat,1,2)) + 1,
                                                                   1,
                                                                   INTE(SUBSTR(tel_dtextrat,3,4))) - 1.
    
                                    RUN fontes/sldccr_j.p(INPUT glb_cdcooper,
                                                          INPUT tel_nrdconta,
                                                          INPUT DECI(tt-cartoes.nrcrcard),
                                                          INPUT aux_dtvctini,
                                                          INPUT aux_dtvctfim).
                                    LEAVE.
                                
                                END. /* Fim do ELSE DO */
    
                            END. /* Fim do DO WHILE TRUE */
    
                         END. /* Fim do IF  tt-cartoes.cdadmcrd = 3 */
                    ELSE
                        MESSAGE "Opcao valida somente para cartoes AILOS VISA".
                    END.

                END. /* Fim do IF  aux_flgliber */

            END. /* Fim do IF  aux_iddopcao = 12 */
            ELSE
            IF  aux_iddopcao = 12  THEN /* HABILITAR */ DO:
                IF  aux_flgliber THEN
                    DO:
                        RUN fontes/sldccr_h.p(OUTPUT aux_flgativo, OUTPUT aux_nrctrhcj).

                        IF  RETURN-VALUE = "OK"  THEN
                            ASSIGN aux_flgreabr = TRUE.

                    END.
                ELSE
                    RUN mensagem_transf_pac.p.
            END.

        END. /* Fim do DO WHILE TRUE: */
            
        HIDE FRAME f_opcoes  NO-PAUSE.
        HIDE FRAME f_cartoes NO-PAUSE.

        HIDE FRAME f_cartoes_pj NO-PAUSE.
        HIDE FRAME f_opcoes_pj  NO-PAUSE.

    END.

IF  VALID-HANDLE(h_b1wgen0028)  THEN
    DELETE PROCEDURE h_b1wgen0028.

RETURN "OK".

PROCEDURE mensagem_transf_pac.p:
    
    MESSAGE "Opção indisponivel. Motivo: Transferencia do PAC.".
    PAUSE(3) NO-MESSAGE.

END PROCEDURE.

/* ......................................................................... */
