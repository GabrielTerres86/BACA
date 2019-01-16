
/* ............................................................................
   Programa: siscaixa/web/InternetBank69.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Jorge
   Data    : Setembro/2011                        Ultima atualizacao: 24/12/2018
   Dados referentes ao programa:
   Frequencia: Sempre que for chamado (On-Line)
   Objetivo  : Importar dados de remessa de cobrança enviado pelo cooperado.
   
   Alteracoes: 03/07/2012 - tratamento do cdoperad "operador" de INTE para CHAR.
                           (Lucas R.)   
                           
               25/04/2013 - Projeto Melhorias da Cobranca - implementar rotina
                            de importacao de titulos CNAB240 - 085. (Rafael)
                            
               28/09/2013 - Projeto Melhorias da Cobranca - Retornar cddbanco 
                            no XML. (Rafael)
                            
               11/03/2014 - Correcao fechamento instancia b1wgen0090 (Daniel) 
                          
			   23/03/2016 - Conversao para PL SQL (Andrei - RKAM ).
			   
               24/12/2018 - Somente retornar "NOK" se a proc retornou a mensagem de erro 
                            caso contrário deverá retornar o XML da Operacao com "OK" pois existem mensagens de 
                            validacao do arquivo que devem ser retornadas para o cooperado (Douglas - INC0029384)
 ............................................................................ */
 
create widget-pool.
 
{ sistema/internet/includes/var_ibank.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/b1wgen0010tt.i }
{ sistema/generico/includes/var_oracle.i }

DEF INPUT  PARAM par_cdcooper AS INTE                                  NO-UNDO.
DEF INPUT  PARAM par_nrdconta AS INTE                                  NO-UNDO.
DEF INPUT  PARAM par_nmarquiv AS CHAR                                  NO-UNDO.
DEF INPUT  PARAM par_idorigem AS INTE                                  NO-UNDO.
DEF INPUT  PARAM par_dtmvtolt AS DATE                                  NO-UNDO.
DEF INPUT  PARAM par_cdoperad AS CHAR                                  NO-UNDO.
DEF INPUT  PARAM par_nmdatela AS CHAR                                  NO-UNDO.
DEF INPUT  PARAM par_flvalarq AS LOGI                                  NO-UNDO.
DEF INPUT  PARAM par_iddirarq AS INTE                                  NO-UNDO.

DEF OUTPUT PARAM xml_dsmsgerr AS CHAR                                  NO-UNDO.
DEF OUTPUT PARAM TABLE FOR xml_operacao.

DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF VAR aux_dstransa AS CHAR                                           NO-UNDO.
DEF VAR aux_qtreqimp AS INTE                                           NO-UNDO.
DEF VAR aux_nrremret AS INTE                                           NO-UNDO.
DEF VAR aux_nrprotoc AS CHAR                                           NO-UNDO.
DEF VAR aux_cdcritic AS INTE                                           NO-UNDO.
DEF VAR aux_hrtransa AS INTE                                           NO-UNDO.
DEF VAR aux_tparquiv AS CHAR                                           NO-UNDO.
DEF VAR aux_cddbanco AS INTE                                           NO-UNDO.
DEF VAR aux_dsretorn AS CHAR                                           NO-UNDO.
DEF VAR aux_xml_operacao69 AS LONGCHAR                                 NO-UNDO.

/* Procedimento do internetbank operaçao 69 - Importacao de arquivos de cobranca */
  { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }
  RUN STORED-PROCEDURE pc_InternetBank69
      aux_handproc = PROC-HANDLE NO-ERROR      
        (INPUT  par_cdcooper           /* --> Codigo da cooperativa         */
        ,INPUT  par_nrdconta           /* --> Numero da conta               */
	    	,INPUT  par_nmarquiv           /* --> Nome do arquivo de cobranca   */
		    ,INPUT  par_idorigem           /* --> Origem                        */
		    ,INPUT  par_dtmvtolt           /* --> Data de movimento             */
        ,INPUT  par_cdoperad           /* --> Operador                      */
		    ,INPUT  par_nmdatela           /* --> Nome da tela                  */
		    ,INPUT  int(par_flvalarq)      /* --> Valida arquivo                */
        ,INPUT  par_iddirarq           /* --> Importar de novo diretorio devido ao SOA */
		    ,INPUT  0                      /* --> Mobile                        */
		    ,INPUT  ''                     /* --> IP                            */
		    ,OUTPUT ""                     /* --> Retorno XML de critica        */
        ,OUTPUT ""                     /* --> Retorno XML da operaçao 26    */
        ,OUTPUT "" ).                  /* --> Retorno de critica (OK ou NOK)*/
		
IF ERROR-STATUS:ERROR  THEN 
   DO:
      DO  aux_qterrora = 1 TO ERROR-STATUS:NUM-MESSAGES:
          ASSIGN aux_msgerora = aux_msgerora + 
                                ERROR-STATUS:GET-MESSAGE(aux_qterrora) + " ".
      END.
          
      ASSIGN aux_dscritic = "pc_InternetBank69 --> "  +
                            "Erro ao executar Stored Procedure: " +
                            aux_msgerora.
      
      ASSIGN xml_dsmsgerr = "<dsmsgerr>" + 
                                 "Erro inesperado. Nao foi possivel importar arquivo de cobranca." + 
                                 " Tente novamente ou contacte seu PA" +
                            "</dsmsgerr>".
                        
      RETURN "NOK".
      
   END. 

CLOSE STORED-PROC pc_InternetBank69
      aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.     

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl}}

ASSIGN aux_dsretorn       = ""
       xml_dsmsgerr       = ""
       aux_xml_operacao69 = ""
       aux_dsretorn = pc_InternetBank69.pr_dsretorn 
                      WHEN pc_InternetBank69.pr_dsretorn <> ?
       xml_dsmsgerr = pc_InternetBank69.pr_xml_dsmsgerr 
                      WHEN pc_InternetBank69.pr_xml_dsmsgerr <> ?
       aux_xml_operacao69 = pc_InternetBank69.pr_xml_operacao69 
                            WHEN pc_InternetBank69.pr_xml_operacao69 <> ?               .

/* Verificar se retornou critica */
/* Somente retornar "NOK" se a proc retornou a mensagem de erro 
   caso contrário deverá retornar o XML da Operacao com "OK" pois existem mensagens de 
   validacao do arquivo que devem ser retornadas para o cooperado */
IF xml_dsmsgerr <> "" THEN
   RETURN "NOK".
   
  
/* Atribuir xml de retorno a temptable*/ 
IF aux_xml_operacao69 <> "" THEN
   DO:
      CREATE xml_operacao.
      ASSIGN xml_operacao.dslinxml = aux_xml_operacao69. 
   END.  
  
RETURN "OK".					   
						   
	
