/* .............................................................................

   Programa: Fontes/pedesenha.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Julio
   Data    : Outubro/2003.                     Ultima atualizacao: 07/12/2015

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Caixa de dialogo para pedir senha para o usuario.

   Alteracoes: 24/01/2006 - Unificacao dos Bancos - SQLWorks - Andre
                
               13/02/2006 - Inclusao do parametro cdcooper para a unificacao
                            dos bancos de dados - SQLWorks - Fernando.
                            
               20/05/2009 - Alteracao CDOPERAD (Kbase).
               
               14/05/2010 - Incluir help nos campos (Gabriel).
               
               09/08/2010 - Melhoria no controle do nivel de operador.
                            (Gabriel).
                            
               27/10/2010 - Alteracao para validar senha atraves da BO
                            b1wgen0000.p (Adriano).             
                            
               07/12/2015 - Ajuste referente a conversao da rotina
                            de validacao da senha para PLSQL
                           (Adriano).
                                                                                          
............................................................................. */

{ sistema/generico/includes/var_internet.i } 
{ sistema/generico/includes/var_oracle.i }


DEFINE  INPUT PARAMETER par_cdcooper AS INTEGER                       NO-UNDO.
DEFINE  INPUT PARAMETER par_nvoperad AS INTEGER                       NO-UNDO.
DEFINE OUTPUT PARAMETER par_nsenhaok AS LOGICAL INIT FALSE            NO-UNDO.
DEFINE OUTPUT PARAMETER par_cdoperad AS CHAR                          NO-UNDO.

DEF VAR aux_cdcritic AS INTE                                          NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                          NO-UNDO.

DEFINE    VAR tel_cdoperad AS CHAR                                    NO-UNDO.  
DEFINE    VAR tel_nrdsenha AS CHAR                                    NO-UNDO.
DEFINE    VAR tel_nvoperad AS CHAR EXTENT 3 INITIAL ["   Operador",
                                                     "Coordenador",
                                                     "    Gerente"]   NO-UNDO.


DEF        VAR h_b1wgen0000 AS HANDLE                                 NO-UNDO.
    
DEFINE FRAME f_moldura WITH ROW 8 SIZE 40 BY 6 
                       OVERLAY CENTERED TITLE " Digite a Senha ".

FORM  SKIP(1)
      tel_nvoperad[par_nvoperad]  FORMAT "x(11)" NO-LABEL AT 4 ":" 
      tel_cdoperad FORMAT "x(10)"  NO-LABEL 
      HELP "Informe o codigo do operador - <F4> ou <END> para sair." 
      SKIP
      "Senha :"    AT 10 
      tel_nrdsenha FORMAT "x(20)" BLANK NO-LABEL 
      HELP "Informe a senha do operador - <F4> ou <END> para sair."
      SKIP(1)
      WITH NO-BOX ROW 9 SIZE 38 BY 3 CENTERED OVERLAY FRAME f_senha.
                           
VIEW FRAME f_moldura.

PAUSE(0).

DISP tel_nvoperad[par_nvoperad] WITH FRAME f_senha.

DO WHILE NOT par_nsenhaok ON ENDKEY UNDO, LEAVE:

   UPDATE tel_cdoperad tel_nrdsenha WITH FRAME f_senha.
   
   EMPTY TEMP-TABLE tt-erro.

   { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
   /* Efetuar a chamada da rotina Oracle */ 
   RUN STORED-PROCEDURE pc_val_senha_coordenador_car
       aux_handproc = PROC-HANDLE NO-ERROR(INPUT par_cdcooper, /*Cooperativa*/
                                           INPUT 0,            /*Agencia    */
                                           INPUT 0,            /*Caixa      */
                                           INPUT "",           /*Operador   */
                                           INPUT "",           /*Nome tela  */
                                           INPUT 1,            /*IdOrigem   */
                                           INPUT 0,            /*Conta*/
                                           INPUT 0,            /*Seq. titular*/ 
                                           INPUT par_nvoperad, /*Nivel Oper.*/
                                           INPUT tel_cdoperad, /*Cod.Operad.*/
                                           INPUT tel_nrdsenha, /*Nr.da Senha*/
                                           INPUT "1",          /*Gera log */
                                          OUTPUT "",         /*Saida OK/NOK */
                                          OUTPUT ?,          /*Tab. Retorno */
                                          OUTPUT 0,          /*Cod. critica */
                                          OUTPUT "").        /*Desc. critica*/

   /* Fechar o procedimento para buscarmos o resultado */ 
   CLOSE STORED-PROC pc_val_senha_coordenador_car
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 

   { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 

   HIDE MESSAGE NO-PAUSE.

   /* Busca possíveis erros */ 
   ASSIGN aux_cdcritic = 0
          aux_dscritic = ""
          aux_cdcritic = pc_val_senha_coordenador_car.pr_cdcritic 
                         WHEN pc_val_senha_coordenador_car.pr_cdcritic <> ?
          aux_dscritic = pc_val_senha_coordenador_car.pr_dscritic 
                         WHEN pc_val_senha_coordenador_car.pr_dscritic <> ?.

   /* Apresenta a crítica */
   IF  aux_cdcritic <> 0 OR aux_dscritic <> "" THEN
       DO: 
          BELL.
          MESSAGE aux_dscritic.
          NEXT.
       END.
       
   ASSIGN par_nsenhaok = TRUE.
          par_cdoperad = tel_cdoperad.
         
END.     
   
HIDE FRAME f_moldura.
HIDE FRAME f_senha.

/* .......................................................................... */

