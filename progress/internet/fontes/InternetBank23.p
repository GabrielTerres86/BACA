/*..............................................................................
   
   Programa: sistema/internet/fontes/InternetBank23.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : David
   Data    : Abril/2007.                       Ultima atualizacao: 09/04/2018
   
   Dados referentes ao programa:
   
   Frequencia: Sempre que for chamado (On-Line)
   Objetivo  : Listar contas destino para transferencia via Internet.
   
   Alteracoes: 10/08/2007 - Alterado para usar os horarios de disponibilidade
                            da transferencia (Evandro).

               28/09/2007 - Acrescentada validacao pela procedure da BO 15
                            verifica_operacao (David).

               09/10/2007 - Gerar log com data TODAY e nao dtmvtolt (David).
               
               06/03/2008 - Utilizar include de temp-tables (David).
               
               24/04/2008 - Adaptacao para agendamentos (David).
               
               25/06/2008 - Nova procedures para obter contas destino (David).
                            
               03/11/2008 - Inclusao widget-pool (martin)
               
               27/07/2009 - Alteracoes do Projeto de Transferencia para 
                            Credito de Salario (David).
                            
               25/01/2010 - Retirado by no for each tt-contas-destino(Guilherme)
               
               04/11/2010 - Criar novo registro na temp-table para cada linha
                            do XML (David).
                            
               05/10/2011 - Parametro cpf operador na verifica_operacao
                            (Guilherme).
                            
               14/05/2012 - Projeto TED Internet (David).
               
               26/03/2013 - Transferencia intecooperativa (Gabriel).
               
               05/09/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).
                            
               30/06/2014 - Retornar a situacao do beneficiario da TED
                            (Chamado 161848) (Jonata - RKAM).
                            
               20/04/2015 - Inclusão do campo ISPB SD271603 FDR041 (Vanessa)                
                            
               20/04/2015 - Inclusão do campos de tipo de Transação nos limites.
                            (Dionathan)
                            
               28/07/2015 - Adição de parâmetro flmobile para indicar que a origem
                            da chamada é do mobile (Dionathan)
                            
               20/01/2016 - Ajuste para chamada efetuada por operador PJ.
                            Projeto 131 - Assinatura Conjunta (David).
                            
               17/02/2016 - Melhorias para o envio e cadastro de contas para
                            efetivar TED, M. 118 (Jean Michel).
                            
               29/02/2016 - Inclusão da lista de Bancos para cadastro de favorecido
                            via Mobile (Dionathan)
                            
               09/04/2018 - Ajuste para que o caixa eletronico possa utilizar o mesmo
                            servico da conta online (PRJ 363 - Rafael Muniz Monteiro)

..............................................................................*/
 
CREATE WIDGET-POOL.
    
{ sistema/internet/includes/var_ibank.i    }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/b1wgen0015tt.i }
{ sistema/generico/includes/b1wgen0142tt.i }
{ sistema/generico/includes/var_oracle.i }


DEF VAR h-b1wgen0014 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0015 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0142 AS HANDLE                                         NO-UNDO.

DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF VAR aux_dstransa AS CHAR                                           NO-UNDO.
DEF VAR aux_dstrans1 AS CHAR                                           NO-UNDO.
DEF VAR aux_nrdrowid AS ROWID                                          NO-UNDO.
DEF VAR aux_nmcooper AS CHAR                                           NO-UNDO.
DEF VAR aux_nmresbcc AS CHAR                                           NO-UNDO.

DEF VAR aux_xml_con_contas_cadastradas AS LONGCHAR                     NO-UNDO.
DEF VAR aux_xml_finalidades            AS LONGCHAR                     NO-UNDO.
DEF VAR aux_xml_crapcop                AS LONGCHAR                     NO-UNDO.

DEF VAR aux_cdlantar LIKE craplat.cdlantar                             NO-UNDO.
DEF VAR aux_xml_operacao23 AS LONGCHAR                                 NO-UNDO.
DEF VAR aux_dsretorn AS CHAR                                           NO-UNDO.
DEF VAR aux_iteracoes AS INTEGER                                       NO-UNDO.
DEF VAR aux_posini    AS INTEGER                                       NO-UNDO.
DEF VAR aux_contador  AS INTEGER                                       NO-UNDO.

DEF INPUT  PARAM par_cdcooper LIKE crapcop.cdcooper                    NO-UNDO.
DEF INPUT  PARAM par_nrdconta LIKE crapttl.nrdconta                    NO-UNDO.
DEF INPUT  PARAM par_idseqttl LIKE crapttl.idseqttl                    NO-UNDO.
DEF INPUT  PARAM par_dtmvtolt LIKE crapdat.dtmvtolt                    NO-UNDO.
DEF INPUT  PARAM par_tppeslst AS INTE                                  NO-UNDO.
DEF INPUT  PARAM par_tpoperac AS INTE                                  NO-UNDO.
DEF INPUT  PARAM par_intipdif LIKE crapcti.intipdif                    NO-UNDO.
DEF INPUT  PARAM par_nrcpfope LIKE crapopi.nrcpfope                    NO-UNDO.
DEF INPUT  PARAM par_nmtitpes LIKE crapcti.nmtitula                    NO-UNDO.
DEF INPUT  PARAM par_flgpesqu AS LOGI                                  NO-UNDO.
DEF INPUT  PARAM par_flmobile AS LOGI                                  NO-UNDO.
/* Projeto 363 - Novo ATM */
DEF  INPUT PARAM par_cdorigem AS INT                                   NO-UNDO.
DEF INPUT  PARAM par_dsorigem AS CHAR                                  NO-UNDO.
DEF  INPUT PARAM par_cdagenci AS INT                                   NO-UNDO.
DEF  INPUT PARAM par_nrdcaixa AS INT                                   NO-UNDO.
DEF INPUT  PARAM par_nmprogra AS CHAR                                  NO-UNDO.
/* Projeto 363 - Novo ATM */

DEF OUTPUT PARAM xml_dsmsgerr AS CHAR                                  NO-UNDO.

DEF OUTPUT PARAM TABLE FOR xml_operacao.

IF  par_flgpesqu  THEN
    ASSIGN aux_dstransa = "Consulta favorecidos".
ELSE
IF  par_tpoperac = 1  THEN
    ASSIGN aux_dstransa = "Acesso a tela de transferencias".
ELSE
    ASSIGN aux_dstransa = "Acesso a tela de TED".

function roundUp returns integer ( x as decimal ):
  if x = truncate( x, 0 ) then
    return integer( x ).
  else
    return integer( truncate( x, 0 ) + 1 ).
end.


  /* Procedimento do internetbank operaçao 23 - Validar/efetuar transferencia */
  { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }
  RUN STORED-PROCEDURE pc_InternetBank23
      aux_handproc = PROC-HANDLE NO-ERROR      
        (INPUT  par_cdcooper           /* --> Codigo da cooperativa         */
        ,INPUT  par_nrdconta           /* --> Numero da conta               */
        ,INPUT  par_idseqttl           /* --> Sequencial titular            */
        ,INPUT  par_dtmvtolt           /* --> Data de movimento             */
        ,INPUT  par_tppeslst           
        ,INPUT  par_tpoperac           /* --> Tipo de transacao             */
        ,INPUT  par_intipdif           /* --> Tipo de opracao               */
        ,INPUT  par_nrcpfope           /* --> CPF do operador juridico      */
        ,INPUT  par_nmtitpes           
        ,INPUT  INT(par_flgpesqu)           
        ,INPUT  INT(par_flmobile)      /* --> Indicativo de operacao mobile */
        
        ,INPUT  aux_dstransa           /* --> Descricao da transferencia    */        
        ,INPUT  par_cdorigem
        ,INPUT  par_dsorigem
        ,INPUT  par_cdagenci
        ,INPUT  par_nrdcaixa
        ,INPUT  par_nmprogra
        ,OUTPUT ""                     /* --> Retorno XML de critica        */
        ,OUTPUT ""                     /* --> Retorno XML da operaçao 26    */
        ,OUTPUT "" ).                  /* --> Retorno de critica (OK ou NOK)*/
                                                                           

  IF  ERROR-STATUS:ERROR  THEN DO:
      DO  aux_qterrora = 1 TO ERROR-STATUS:NUM-MESSAGES:
          ASSIGN aux_msgerora = aux_msgerora + 
                                ERROR-STATUS:GET-MESSAGE(aux_qterrora) + " ".
      END.
          
      ASSIGN aux_dscritic = "pc_InternetBank23 --> "  +
                            "Erro ao executar Stored Procedure: " +
                            aux_msgerora.
      
      ASSIGN xml_dsmsgerr = "<dsmsgerr>" + 
                                 "Erro inesperado. Nao foi possivel efetuar a transferencia." + 
                                 " Tente novamente ou contacte seu PA" +
                            "</dsmsgerr>".
                        
      RUN proc_geracao_log(INPUT FALSE).
      
      RETURN "NOK".
      
  END. 

  CLOSE STORED-PROC pc_InternetBank23
        aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.     

  { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl}}


  ASSIGN aux_dsretorn       = ""
         xml_dsmsgerr       = ""
         aux_xml_operacao23 = ""
         aux_dsretorn = pc_InternetBank23.pr_dsretorn 
                        WHEN pc_InternetBank23.pr_dsretorn <> ?
         xml_dsmsgerr = pc_InternetBank23.pr_xml_dsmsgerr 
                        WHEN pc_InternetBank23.pr_xml_dsmsgerr <> ?
         aux_xml_operacao23 = pc_InternetBank23.pr_xml_operacao23 
                              WHEN pc_InternetBank23.pr_xml_operacao23 <> ?               .

  /* Verificar se retornou critica */
  IF aux_dsretorn <> "OK" THEN
     RETURN "NOK".
   
  /* Atribuir xml de retorno a temptable*/ 
  IF aux_xml_operacao23 <> "" THEN
  DO:
    ASSIGN aux_iteracoes = roundUp(LENGTH(aux_xml_operacao23) / 31000)
           aux_posini    = 1.    

    DO aux_contador = 1 TO aux_iteracoes:
                CREATE xml_operacao.
      ASSIGN xml_operacao.dslinxml = SUBSTRING(aux_xml_operacao23, aux_posini, 31000)
             aux_posini            = aux_posini + 31000.
                END.

    END.

  RETURN "OK".
    


/*................................ PROCEDURES ................................*/

PROCEDURE proc_geracao_log:

    DEF INPUT PARAM par_flgtrans AS LOGICAL                         NO-UNDO.
    DEF   VAR       aux_dsorigem AS CHAR                            NO-UNDO.
    																		
    IF par_flmobile THEN
        ASSIGN aux_dsorigem = "MOBILE".
    ELSE
        ASSIGN aux_dsorigem = par_dsorigem.
    
    RUN sistema/generico/procedures/b1wgen0014.p PERSISTENT 
        SET h-b1wgen0014.
        
    IF  VALID-HANDLE(h-b1wgen0014)  THEN
        DO:
            RUN gera_log IN h-b1wgen0014 (INPUT par_cdcooper,
                                          INPUT "996",
                                          INPUT aux_dscritic,
                                          INPUT par_dsorigem, /* Projeto 363 - Novo ATM -> estava fixo "INTERNET",*/
                                          INPUT aux_dstransa,
                                          INPUT aux_datdodia,
                                          INPUT par_flgtrans,
                                          INPUT TIME,
                                          INPUT par_idseqttl,
                                          INPUT par_nmprogra, /* Projeto 363 - Novo ATM -> estava fixo "INTERNETBANK",*/
                                          INPUT par_nrdconta,
                                          OUTPUT aux_nrdrowid).
            
            RUN gera_log_item IN h-b1wgen0014
							  (INPUT aux_nrdrowid,
							   INPUT "Origem",
							   INPUT "",
							   INPUT aux_dsorigem).
            
            DELETE PROCEDURE h-b1wgen0014.
        END.
    
END PROCEDURE. 

/*............................................................................*/