/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +---------------------------------+-----------------------------------+
  | Rotina Progress                 | Rotina Oracle PLSQL               |
  +---------------------------------+-----------------------------------+
  |  enviar_email_completo          | GENE0003.PC_ENVIA_EMAIL           |
  |  converte_arquivo               | Nao convertido/necessario         |
  |  enviar_email_spool             | gene0003.pc_solicita_email        |
  +---------------------------------+-----------------------------------+
  
  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.
  
  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - GUILHERME STRUBE    (CECRED)
   - MARCOS MARTINI      (SUPERO)
   
*******************************************************************************/












/*..............................................................................

    Programa: b1wgen0011.p
    Autor   : David
    Data    : Agosto/2006                     Ultima Atualizacao: 21/09/2017
    
    Dados referentes ao programa:

    Objetivo  : BO para envio de e-mail.

    Alteracoes: 23/11/2006 - Acerto no envio de email quando existir mais de
                             um arquivo para anexo (David).

                23/07/2007 - Modificada mensagem do e-mail para os programas
                             crps217 e crps488 (Diego).
                             
                03/09/2007 - Alterada mensagem de e-mail para informativos
                             (Diego).
                             
                01/11/2007 - Nao logar envio de informativos (Diego).

                20/10/2008 - Tratamento diferenciado na hora de enviar
                             alguns programas do progrid (Gabriel).
                             
                14/11/2008 - Incluir procedure enviar_email_completo 
                             (Guilherme).             

                26/12/2008 - Alteracao de mtsend.pl para gnusend.pl (Julio)

                23/01/2009 - Incluir condicao para gravar log na procedure
                             enviar_email_completo (David).
                             
                03/02/2009 - Em caso de anexo em branco fechar com ' o 
                             parametro do gnusend.pl 
                           - procedure enviar_email_completo envia + de 1 anexo
                             (Guilherme).                

                17/03/2009 - Criar arquivo com e-mails enviados utilizando em
                             casos de problemas de envio nos processos (David).
                             
                08/05/2009 - Incluida na linha de comando do gnusend.pl o re-
                             direcionamento da saida padrao e de erro (Edson).
                             
                30/08/2010 - Incluido caminho completo no destino dos arquivos
                             de log (Elton).
                             
                27/04/2011 - Emails enviados a partir dos programas crps507
                             e crps395 terao remetente rosangela@cecred.coop.br
                             (Irlan).
                             
                13/05/2011 - Nova procedure enviar_email_spool. (Irlan)
                
                08/11/2011 - Mudanca na descricao dos campos dos email quando
                             informativos (Gabriel).
                             
                10/02/2012 - Nao registrar envio de e-mail no log do processo
                             batch para programas definidos na variavel
                             aux_lsprglog (David).
                             
                02/04/2012 - Alterado diretorio do SpoolMail (Irlan)
                
                30/08/2012 - Substituido crapcop.nmrescop por crapcop.dsdircop
                             no arquivo "aux_nmarqctg" (Diego).       
                             
                28/12/2012 - Retirar a palavra mensal do email do crps488
                             (Gabriel).                                   
                             
                25/02/2013 - Removido IF com cdprogra = "crps533", na procedure
                             enviar_email_completo. (Fabricio)
                             
                09/05/2013 - Ajustes realizados:
                             - Criado a procedure enviar-email-completo;
                             - Retirado todo o conteudo da procedure 
                               enviar_email_completo e incluido a chamada para
                               a nova procedure (Adriano).
                               
                  10/06/2013 - Alteraçao funçao enviar_email_completo p/ nova versao (Jean Michel).
                  
                  01/10/2013 - Nova forma de chamar as agencias, de PAC agora 
                               a escrita será PA (André Euzébio - Supero).  
                               
                  10/02/2014 - Nao registrar em log o envio de email referente
                               a monitoracao de pagamentos (David).
                               
                  22/08/2014 - Incluido observacao de "e-mail automatico" no corpo 
                               da mensagem de envio de extrato na procedure
                               "enviar_email" (Daniele).
                               
                  10/12/2014 - Ajuste na procedure enviar_email_spool para
                               utilizar o codigo do programa corretamente
                               no "IF" utilizado para criar os arquivos
                               de e-mail 
                               (Adriano).     
                                       
                  22/01/2015 - Nao logar envio de email quando vem da 
                               prevencao ao fraude (Jonata-RKAM).
                               
                  30/07/2015 - Migrado o log de envio de email de proc_batch para 
                               proc_message conforme solicitado no chamado 306987 
                               (Kelvin)

                  07/01/2016 - Alterado a chamada do script gnsend.pl pela rotina
                               convertida do oracle pc_solicita_email 
                               SD356863 (odirlei-AMcom)
                  
				  03/03/2016 - Ajustado rotina devido a agrupar anexo quando possuia mais
				               de um destinatario(Odirlei-AMcom)

									15/09/2017 - Inclusao de acentuaçao na msg relativa a tela wpgd0020
                               do Progrid (Jean Michel).
	    
                  21/09/2017 - #756235 Criada a funcao f_validar_email para nao ter 
                               problemas na geracao dos arquivos de spool (Carlos)

..............................................................................*/

{ sistema/generico/includes/var_oracle.i } 


DEF STREAM str_email.
DEF STREAM str_spool.

DEF VAR aux_qtdemail AS INTE                                           NO-UNDO.
DEF VAR aux_qtarquiv AS INTE                                           NO-UNDO.
DEF VAR aux_qtdanexo AS INTE                                           NO-UNDO.

DEF VAR aux_dsarqlog AS CHAR                                           NO-UNDO.
DEF VAR aux_dsdemail AS CHAR                                           NO-UNDO.
DEF VAR aux_dsarquiv AS CHAR                                           NO-UNDO.
DEF VAR aux_nmarqctg AS CHAR                                           NO-UNDO.
DEF VAR aux_dsanexos AS CHAR                                           NO-UNDO.
DEF VAR aux_dsanexos_ora AS CHAR                                       NO-UNDO.
DEF VAR aux_dsdircop_ora AS CHAR                                       NO-UNDO.
DEF VAR aux_remetent AS CHAR                                           NO-UNDO.
DEF VAR aux_msgremet AS CHAR                                           NO-UNDO.
DEF VAR aux_dscomand AS CHAR                                           NO-UNDO.

DEF VAR aux_nmarqtxt AS CHAR                                           NO-UNDO.

FUNCTION f_validar_email RETURNS LOGICAL (INPUT par_dsdemail AS CHAR):

    IF par_dsdemail = ""              OR /* vazio */
       NOT par_dsdemail MATCHES "*@*" OR /* nao tem arroba */
       par_dsdemail MATCHES "* *"     OR /* tem espaco */
       par_dsdemail MATCHES "*/*"THEN    /* tem barra */
    DO:
        RETURN FALSE.
    END.   

    RETURN TRUE.
    
END FUNCTION.

PROCEDURE converte_arquivo.

    DEFINE   INPUT   PARAM p-cod_cooper      AS INTEGER             NO-UNDO.
    DEFINE   INPUT   PARAM p-nome_arquivo    AS CHARACTER           NO-UNDO.
    DEFINE   INPUT   PARAM p-nome_arq_envio  AS CHARACTER           NO-UNDO.

    /*** Busca dados da cooperativa ***/
    FIND crapcop WHERE crapcop.cdcooper = p-cod_cooper NO-LOCK NO-ERROR.
                                        
    IF  NOT AVAILABLE crapcop  THEN
        DO:
            UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + "' --> '" +
                              "Falta registro de controle da cooperativa - " +
                              "ERRO AO CONVERTER ARQUIVO >> " +
                              "/usr/coop/" + TRIM(crapcop.dsdircop) +
                                             "/log/proc_batch.log").
            RETURN.
        END.

    /*** Salvar arquivo no diretorio "/usr/coop/cooperativa/converte/" ***/
    UNIX SILENT VALUE("ux2dos < " + p-nome_arquivo + ' | tr -d "\032"' + 
                      " > /usr/coop/" + crapcop.dsdircop + "/converte/" +
                      p-nome_arq_envio + " 2>/dev/null").

END PROCEDURE.

PROCEDURE solicita_email_oracle.

    DEFINE   INPUT   PARAM par_cdcooper                  AS INTEGER             NO-UNDO.
    DEFINE   INPUT   PARAM par_cdprogra                  AS CHARACTER           NO-UNDO.
    DEFINE   INPUT   PARAM par_des_destino               AS CHARACTER           NO-UNDO.
    DEFINE   INPUT   PARAM par_des_assunto               AS CHARACTER           NO-UNDO.
    DEFINE   INPUT   PARAM par_des_corpo                 AS CHARACTER           NO-UNDO.
    DEFINE   INPUT   PARAM par_des_anexo                 AS CHARACTER           NO-UNDO.
    DEFINE   INPUT   PARAM par_flg_remove_anex           AS CHARACTER           NO-UNDO.
    DEFINE   INPUT   PARAM par_flg_remete_coop           AS CHARACTER           NO-UNDO.
    DEFINE   INPUT   PARAM par_des_nome_reply            AS CHARACTER           NO-UNDO.
    DEFINE   INPUT   PARAM par_des_email_reply           AS CHARACTER           NO-UNDO.
    DEFINE   INPUT   PARAM par_flg_log_batch             AS CHARACTER           NO-UNDO.
    DEFINE   INPUT   PARAM par_flg_enviar                AS CHARACTER           NO-UNDO.
    DEFINE   OUTPUT  PARAM par_des_erro                  AS CHARACTER           NO-UNDO.
 
    DEFINE   VAR aux_des_corpo                           AS CHARACTER NO-UNDO.

    { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }
    
    ASSIGN aux_des_corpo = replace(par_des_corpo,"\n","<br>").
   
    RUN STORED-PROCEDURE pc_solicita_email_prog
			aux_handproc = PROC-HANDLE NO-ERROR(INPUT par_cdcooper,       
																				  INPUT par_cdprogra,       
																				  INPUT par_des_destino,    
																				  INPUT par_des_assunto,    
																				  INPUT aux_des_corpo ,     
																				  INPUT par_des_anexo,      
																				  INPUT par_flg_remove_anex,
																				  INPUT par_flg_remete_coop,
																				  INPUT par_des_nome_reply,
																				  INPUT par_des_email_reply,
																				  INPUT par_flg_log_batch,  
																				  INPUT par_flg_enviar,            
																				 OUTPUT "" ).
   
		CLOSE STORED-PROCEDURE pc_solicita_email_prog
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
       
    { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

    IF  ERROR-STATUS:ERROR  THEN DO:
        DO  aux_qterrora = 1 TO ERROR-STATUS:NUM-MESSAGES:
            ASSIGN aux_msgerora = aux_msgerora + 
                                  ERROR-STATUS:GET-MESSAGE(aux_qterrora) + " ".
        END.

        ASSIGN par_des_erro = "Erro ao executar Stored Procedure: '" + aux_msgerora.
        RETURN "NOK".
    END.
    
    IF  pc_solicita_email_prog.pr_des_erro <> ? THEN
        DO:
            ASSIGN par_des_erro = pc_solicita_email_prog.pr_des_erro.
            RETURN "NOK".
        END.

    RETURN "OK".

END PROCEDURE.

PROCEDURE enviar_email.
 
    DEFINE   INPUT   PARAM p-cod_cooper      AS INTEGER             NO-UNDO.
    DEFINE   INPUT   PARAM p-cod_programa    AS CHARACTER           NO-UNDO.
    DEFINE   INPUT   PARAM p-lista_emails    AS CHARACTER           NO-UNDO.
    DEFINE   INPUT   PARAM p-assunto_email   AS CHARACTER           NO-UNDO.
    DEFINE   INPUT   PARAM p-nome_arq_envio  AS CHARACTER           NO-UNDO.
    DEFINE   INPUT   PARAM p-flg_binario     AS LOGICAL             NO-UNDO.

    DEF VAR aux_lsprglog AS CHAR                                    NO-UNDO.
    DEF VAR aux_dscritic AS CHAR                                    NO-UNDO.
    DEF VAR aux_nomreply AS CHAR                                    NO-UNDO.
    DEF VAR aux_emailrep AS CHAR                                    NO-UNDO.
    
    /*** Busca dados da cooperativa ***/
    FIND crapcop WHERE crapcop.cdcooper = p-cod_cooper NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE crapcop  THEN
        DO:
            UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + "' --> '" +
                              "Falta registro de controle da cooperativa - " +
                              "ERRO AO ENVIAR E-MAIL >> " +
                              "/usr/coop/" + TRIM(crapcop.dsdircop) +
                                             "/log/proc_batch.log").
            RETURN.
        END.

    /*** Buscar diretorio da cooperativa para utilizar no oracle  ***/
    { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }
                
    RUN STORED-PROCEDURE pc_param_sistema aux_handproc = PROC-HANDLE
       (INPUT "CRED",           /* pr_nmsistem */
        INPUT p-cod_cooper,     /* pr_cdcooper */
        INPUT "ROOT_DIRCOOP",   /* pr_cdacesso */
        OUTPUT ""               /* pr_dsvlrprm */
        ).

    CLOSE STORED-PROCEDURE pc_param_sistema WHERE PROC-HANDLE = aux_handproc.
    { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }
    
    ASSIGN aux_dsdircop_ora = ""
           aux_dsdircop_ora = pc_param_sistema.pr_dsvlrprm 
                              WHEN pc_param_sistema.pr_dsvlrprm <> ?. 

    ASSIGN aux_dsdemail = "" 
           aux_lsprglog = "crps375,crps444,crps464,crps538,crps594"
           aux_nmarqctg = "/usr/coop/" + crapcop.dsdircop + "/converte/envia_" +
                          LC(crapcop.dsdircop) + ".sh".

    /*** Envia arquivo para cada e-mail da lista ***/
    DO aux_qtdemail = 1 TO NUM-ENTRIES(p-lista_emails,","):
    
        ASSIGN aux_dsdemail = TRIM(ENTRY(aux_qtdemail,p-lista_emails,",")).
        
        IF NOT f_validar_email(INPUT aux_dsdemail) THEN
            NEXT.
        
        ASSIGN aux_dsarquiv = ""
               aux_dsanexos = ""
               aux_dsarqlog = ""
			   aux_dsanexos_ora = "".
        
        DO aux_qtarquiv = 1 TO NUM-ENTRIES(p-nome_arq_envio,";"):

            ASSIGN aux_dsarquiv = ENTRY(aux_qtarquiv,p-nome_arq_envio,";")
                   aux_qtdanexo = NUM-ENTRIES(p-nome_arq_envio,";").

            ASSIGN aux_dsanexos = aux_dsanexos + "/usr/coop/" +
                                  crapcop.dsdircop + "/converte/" +
                                  aux_dsarquiv 
                   aux_dsarqlog = aux_dsarqlog + "ARQUIVO /usr/coop/" +
                                  crapcop.dsdircop + "/converte/" +
                                  aux_dsarquiv + " - "
                   aux_dsanexos_ora = aux_dsanexos_ora + aux_dsdircop_ora  +
                                      crapcop.dsdircop + "/converte/" +
                                      aux_dsarquiv .                                  
                                  
            IF aux_qtarquiv < aux_qtdanexo  THEN
                DO:
                    ASSIGN aux_dsanexos = aux_dsanexos + ";"
                           aux_dsanexos_ora = aux_dsanexos_ora + ";".
                END.
            ELSE
                DO:
                    ASSIGN aux_dsanexos = aux_dsanexos
                           aux_dsanexos_ora = aux_dsanexos_ora.
                END.
                                  
        END. /* Fim do DO TO */                         
        
        CASE p-cod_programa:
        
            WHEN "wpgd0014" THEN 
                aux_msgremet = "Esta liberada a lista de sugestoes para nova" +
                               " agenda do PROGRID."                          +
                               "\nSelecione os eventos do interesse de seu "  +
                               "pa, atraves da tela de SELECAO DOS EVENTOS.".
        
            WHEN "wpgd0020" THEN
                aux_msgremet = "A lista de selecão dos eventos já foi "       +
                               "concluida pelo PA. \nVerifique e confirme "   +
                               "através da tela de Confirmacão dos Eventos.".
        
            WHEN "wpgd0026b" THEN
                 aux_msgremet =  "O local para a realizacao do evento ja "    +
                                 "foi selecionado pelo PA.".
        
        END CASE.
            
        /*Rotina crps217 já está no oracle*/
        IF   p-cod_programa = "crps217"  THEN
             DO:

            
                 ASSIGN aux_remetent = " --de_nome='" + crapcop.nmrescop +  
                                       "' --de='" + crapcop.dsdemail + "'"

                     aux_msgremet = "Prezado (a) Cooperado (a),"
                   
                   + "\n\nVoce esta recebendo o extrato da sua "
                   + "conta. Para visualiza-lo, clique no arquivo "
                   + "anexo"   
                   + "\n e digite sua senha. A senha e a mesma "
                   + "utilizada no tele-atendimento. Se voce ainda nao possui "
                   + "\n esta senha, dirija-se ao seu Posto de Atendimento "
                   + "para cadastrar uma."
                   + "\n\nSe voce preferir cancelar o recebimento, basta "
                   + "acessar sua conta no site da cooperativa, opcao de "
                   + "Informativos/Recebimento, ou entrar em contato com o "
                   + "Posto de Atendimento onde voce movimenta sua conta." 
                   + "\n\\nOBS.: Esta mensagem foi enviada automaticamente, em caso de duvidas entre em contato com sua cooperativa!" 
                   + "\n\nAtenciosamente, "
                   + "\n" + crapcop.nmrescop.
                                                                          
            
                 
               
               aux_dscomand = "gnusend.pl --para='" + aux_dsdemail      + 
                                "' --assunto='"     + p-assunto_email     +
                                "' --corpo='"       + aux_msgremet        +
                                "'" + aux_remetent + aux_dsanexos  + 
                                " > /dev/null 2> /dev/null &". 

              

                 UNIX SILENT VALUE (aux_dscomand).                 
             END.
        ELSE
        IF   CAN-DO("wpgd0014,wpgd0020,wpgd0026b",p-cod_programa)   THEN        
             DO:
                 run solicita_email_oracle(    INPUT  p-cod_cooper        /* par_cdcooper         */
                                              ,INPUT  p-cod_programa      /* par_cdprogra         */
                                              ,INPUT  aux_dsdemail        /* par_des_destino      */
                                              ,INPUT  p-assunto_email     /* par_des_assunto      */
                                              ,INPUT  aux_msgremet        /* par_des_corpo        */
                                              ,INPUT  ""                  /* par_des_anexo        */
                                              ,INPUT  "N"                 /* par_flg_remove_anex  */
                                              ,INPUT  "N"                 /* par_flg_remete_coop  */
                                              ,INPUT  "Sistema de Relacionamento"/* par_des_nome_reply   */
                                              ,INPUT  "progrid@cecred.coop.br" /* par_des_email_reply  */
                                              ,INPUT  "N"                 /* par_flg_log_batch    */
                                              ,INPUT  "S"                 /* par_flg_enviar       */
                                              ,OUTPUT aux_dscritic        /* par_des_erro         */
                                               ).
             END.
        ELSE
             DO: 
                 ASSIGN aux_nomreply = ""
                        aux_emailrep = "".

                 /* crps507 já esta no oracle */
                 IF   p-cod_programa = "crps395" OR p-cod_programa = "crps507" THEN
                      /* Enviar com remetente Rosangela - Prod. Negocios*/
                      DO:
                        ASSIGN aux_nomreply = "Rosangela Wirth"
                               aux_emailrep = "rosangela@cecred.coop.br".
                      END.
                      
                 run solicita_email_oracle(    INPUT  p-cod_cooper        /* par_cdcooper         */
                                              ,INPUT  p-cod_programa      /* par_cdprogra         */
                                              ,INPUT  aux_dsdemail        /* par_des_destino      */
                                              ,INPUT  p-assunto_email     /* par_des_assunto      */
                                              ,INPUT  "SEGUE ARQUIVO EM ANEXO." /* par_des_corpo        */
                                              ,INPUT  aux_dsanexos        /* par_des_anexo        */
                                              ,INPUT  "N"                 /* par_flg_remove_anex  */
                                              ,INPUT  "N"                 /* par_flg_remete_coop  */
                                              ,INPUT  aux_nomreply        /* par_des_nome_reply   */
                                              ,INPUT  aux_emailrep        /* par_des_email_reply  */
                                              ,INPUT  "N"                 /* par_flg_log_batch    */
                                              ,INPUT  "S"                 /* par_flg_enviar       */
                                              ,OUTPUT aux_dscritic        /* par_des_erro         */
                                               ).

                 UNIX SILENT VALUE(aux_dscomand).
        
                 IF   p-cod_programa <> "ATENDA"   THEN
                      DO:
                          IF  NOT CAN-DO(aux_lsprglog,p-cod_programa)  THEN
                              UNIX SILENT VALUE("echo " + 
                                   STRING(TIME,"HH:MM:SS") + " - " + 
                                   p-cod_programa + "' --> '" + aux_dsarqlog + 
                                   "ENVIADO PARA " + aux_dsdemail + 
                                   " >> /usr/coop/" + TRIM(crapcop.dsdircop) +
                                   "/log/proc_message.log").

                          OUTPUT STREAM str_email TO VALUE(aux_nmarqctg) APPEND.
                          
                          PUT STREAM str_email UNFORMATTED aux_dscomand SKIP.
                           
                          OUTPUT STREAM str_email CLOSE.
                      END.                
             END.
        
    END. /* Fim do DO TO */

END PROCEDURE.


PROCEDURE enviar_email_spool.
 
    DEFINE   INPUT   PARAM p-cod_cooper      AS INTEGER             NO-UNDO.
    DEFINE   INPUT   PARAM p-cod_programa    AS CHARACTER           NO-UNDO.
    DEFINE   INPUT   PARAM p-lista_emails    AS CHARACTER           NO-UNDO.
    DEFINE   INPUT   PARAM p-assunto_email   AS CHARACTER           NO-UNDO.
    DEFINE   INPUT   PARAM p-nome_arq_envio  AS CHARACTER           NO-UNDO.
    DEFINE   INPUT   PARAM p-nome_arq_spool  AS CHARACTER           NO-UNDO.
    DEFINE   INPUT   PARAM p-flg_binario     AS LOGICAL             NO-UNDO.
                                                       
    /*** Busca dados da cooperativa ***/
    FIND crapcop WHERE crapcop.cdcooper = p-cod_cooper NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE crapcop  THEN
        DO:
            UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + "' --> '" +
                              "Falta registro de controle da cooperativa - " +
                              "ERRO AO ENVIAR E-MAIL >> " +
                              "/usr/coop/" + TRIM(crapcop.dsdircop) +
                                             "/log/proc_batch.log").
            RETURN.
        END.

    ASSIGN aux_dsdemail = ""
           aux_nmarqctg = "/usr/coop/" + crapcop.dsdircop + "/converte/envia_" +
                          LC(crapcop.dsdircop) + ".sh".

    /*** Envia arquivo para cada e-mail da lista ***/
    DO aux_qtdemail = 1 TO NUM-ENTRIES(p-lista_emails,","):
    
        ASSIGN aux_dsdemail = TRIM(ENTRY(aux_qtdemail,p-lista_emails,",")).
        
        IF NOT f_validar_email(INPUT aux_dsdemail) THEN
            NEXT.
        
        ASSIGN aux_dsarquiv = ""
               aux_dsanexos = ""
               aux_dsarqlog = "".
        
        DO aux_qtarquiv = 1 TO NUM-ENTRIES(p-nome_arq_envio,";"):

            ASSIGN aux_dsarquiv = ENTRY(aux_qtarquiv,p-nome_arq_envio,";")
                   aux_qtdanexo = NUM-ENTRIES(p-nome_arq_envio,";").
        
            IF  aux_dsarquiv = ""  THEN
                DO:
                    ASSIGN aux_dsanexos = aux_dsanexos + "'".
                    NEXT.
                END.
                
            IF  aux_qtarquiv = 1  THEN
                DO:
                    IF  p-flg_binario  THEN
                        ASSIGN aux_dsanexos = aux_dsanexos + "--anexo='".
                    ELSE
                        ASSIGN aux_dsanexos = aux_dsanexos + 
                                              "--ascii --anexo='".
                END.

            ASSIGN aux_dsanexos = aux_dsanexos + "/usr/coop/" +
                                  crapcop.dsdircop + "/converte/" +
                                  aux_dsarquiv 
                   aux_dsarqlog = aux_dsarqlog + "ARQUIVO /usr/coop/" +
                                  crapcop.dsdircop + "/converte/" +
                                  aux_dsarquiv + " - ".
                                  
            IF   aux_qtarquiv < aux_qtdanexo  THEN
                 ASSIGN aux_dsanexos = aux_dsanexos + ";".
            ELSE
                 ASSIGN aux_dsanexos = aux_dsanexos + "'".
                                  
        END. /* Fim do DO TO */                         
        
        IF   p-cod_programa = "crps488" THEN
             DO:
                 ASSIGN aux_msgremet = "Prezado (a) Cooperado (a), ~\n~\n" +
                            
                   IF   (p-nome_arq_spool = "INFOR")   THEN
                         "Voce esta recebendo o Informativo da " + 
                         crapcop.nmrescop + ". "
                   ELSE
                         "Voce esta recebendo a agenda dos eventos do PROGRID "
                       + "programados para este mes. "

                   aux_msgremet = aux_msgremet  
                       + "Para visualiza-lo, clique no arquivo "
                       + "anexo."   
                       + "~\n~\n" + "Se voce preferir cancelar o recebimento, basta "
                       + "acessar sua conta no site da cooperativa, opcao de "
                       + "Informativos/Recebimento, ou entrar em contato com o "
                       + "Posto de Atendimento onde voce movimenta sua conta."
                       + "OBS.: Esta mensagem foi enviada automaticamente, em caso de duvidas entre em contato com sua cooperativa!"
                       + "~\n~\n" + "Atenciosamente, "
                       + "~\n" + crapcop.nmrescop

                        aux_nmarqtxt = p-nome_arq_spool          + "_" +
                                       STRING(TODAY, "99999999") + "_" +
                                       aux_dsdemail + ".txt.body".
                 
                 OUTPUT STREAM str_spool TO VALUE ("/usr/local/cecred/SpoolMail/" + aux_nmarqtxt).

                 PUT STREAM str_spool UNFORMATTED 
                                        "--de_nome='" + crapcop.nmrescop + "'"   SKIP  
                                        "--de='"      + crapcop.dsdemail + "'"   SKIP
                                        "--para='"    + aux_dsdemail     + "'"   SKIP
                                        "--assunto='" + p-assunto_email  + "'"   SKIP
                                                        aux_dsanexos             SKIP
                                        "--corpo='"   + aux_msgremet     + "'".

                 OUTPUT STREAM str_spool CLOSE.

             END.
    END. /* Fim do DO TO */

END PROCEDURE.


/*****************************************************************************/
/*   Procedure para enviar email com todos os dados do envio por parametro   */
/*****************************************************************************/

PROCEDURE enviar_email_completo:
/******************************************************************************
                 ATENCAO - PROCEDURE MIGRADA PARA O ORACLE
                VERIFIQUE COMENTARIOS NO INICIO DESSE FONTE
******************************************************************************/
    DEF INPUT PARAM par_cdcooper AS INTE    NO-UNDO.
    DEF INPUT PARAM par_cdprogra AS CHAR    NO-UNDO.
    DEF INPUT PARAM par_remetent AS CHAR    NO-UNDO.
    DEF INPUT PARAM par_lsemails AS CHAR    NO-UNDO.
    DEF INPUT PARAM par_dsassunt AS CHAR    NO-UNDO.
    DEF INPUT PARAM par_responde AS CHAR    NO-UNDO.
    DEF INPUT PARAM par_nmarquiv AS CHAR    NO-UNDO.
    DEF INPUT PARAM par_conteudo AS CHAR    NO-UNDO.
    DEF INPUT PARAM par_flgbinar AS LOGI    NO-UNDO.

    DEF VAR aux_nmremete AS CHARACTER       NO-UNDO.
    DEF VAR aux_dsmailrm AS CHARACTER       NO-UNDO.
    DEF VAR aux_dscritic AS CHARACTER       NO-UNDO.

    /*** Busca dados da cooperativa ***/
    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper 
                       NO-LOCK NO-ERROR.

    IF NOT AVAILABLE crapcop  THEN
       DO:
           UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + "' --> '"  +
                             "Falta registro de controle da cooperativa - " +
                             "ERRO AO ENVIAR E-MAIL >> "                    +
                             "/usr/coop/" + TRIM(crapcop.dsdircop)          +
                             "/log/proc_batch.log").

           RETURN.

       END.

    /*** Buscar diretorio da cooperativa para utilizar no oracle  ***/
    { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }
                
    RUN STORED-PROCEDURE pc_param_sistema aux_handproc = PROC-HANDLE
       (INPUT "CRED",           /* pr_nmsistem */
        INPUT par_cdcooper,     /* pr_cdcooper */
        INPUT "ROOT_DIRCOOP",   /* pr_cdacesso */
        OUTPUT ""               /* pr_dsvlrprm */
        ).

    CLOSE STORED-PROCEDURE pc_param_sistema WHERE PROC-HANDLE = aux_handproc.
    { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }
    
    ASSIGN aux_dsdircop_ora = ""
           aux_dsdircop_ora = pc_param_sistema.pr_dsvlrprm 
                              WHEN pc_param_sistema.pr_dsvlrprm <> ?. 

    ASSIGN aux_dsdemail = ""
           aux_nmarqctg = "/usr/coop/" + crapcop.dsdircop + "/converte/envia_" +
                          LC(crapcop.dsdircop) + ".sh".
    
    /*** Envia arquivo para cada e-mail da lista ***/
    DO aux_qtdemail = 1 TO NUM-ENTRIES(par_lsemails,","):
    
       ASSIGN aux_dsdemail = TRIM(ENTRY(aux_qtdemail,par_lsemails,",")).
       
       IF NOT f_validar_email(INPUT aux_dsdemail) THEN
          NEXT.
           
       ASSIGN aux_dsarquiv = ""
              aux_dsanexos = ""
              aux_dsarqlog = ""
			  aux_dsanexos_ora = "".
       
       DO aux_qtarquiv = 1 TO NUM-ENTRIES(par_nmarquiv,";"):

          ASSIGN aux_dsarquiv = ENTRY(aux_qtarquiv,par_nmarquiv,";")
                 aux_qtdanexo = NUM-ENTRIES(par_nmarquiv,";").
       
          ASSIGN aux_dsanexos = aux_dsanexos + "/usr/coop/"     +
                                crapcop.dsdircop + "/converte/" +
                                aux_dsarquiv
                 aux_dsarqlog = aux_dsarqlog + "ARQUIVO /usr/coop/" +
                                crapcop.dsdircop + "/converte/"     +
                                aux_dsarquiv + " - "
                 aux_dsanexos_ora = aux_dsanexos_ora + aux_dsdircop_ora  +
                                    crapcop.dsdircop + "/converte/" +
                                    aux_dsarquiv .

          IF aux_qtarquiv < aux_qtdanexo  THEN
              DO:
                 ASSIGN aux_dsanexos = aux_dsanexos + ";"
                        aux_dsanexos_ora = aux_dsanexos_ora + ";".
              END.
          ELSE
              DO:
                 ASSIGN aux_dsanexos = aux_dsanexos 
                        aux_dsanexos_ora = aux_dsanexos_ora.
              END.
                
       END. /* Fim do DO TO */                   
       
       IF TRIM(par_remetent) <> "" THEN      
          DO:
             ASSIGN aux_nmremete = SUBSTR(par_remetent, 1, 
                                          INDEX(par_remetent, "<") - 1)
                    aux_dsmailrm = SUBSTR(par_remetent, 
                                          LENGTH(aux_nmremete) + 2,
                                          LENGTH(par_remetent) - 
                                          LENGTH(aux_nmremete) - 2).
          END.
       
/*       IF aux_dsdemail = "testedesen@cecred.coop.br" THEN
       
       DO:
           ASSIGN aux_dscomand = "gnusend-desen.pl --para='" + aux_dsdemail +
                                 "' --assunto='"       + par_dsassunt +
                                 "' --corpo='"         + par_conteudo + 
                                 "' --de_nome='"       + aux_nmremete +
                                 "' --de='"            + aux_dsmailrm +
                                 "' --responder='"     + par_responde +
                                 "'"  + aux_dsanexos                  + 
                                 " > /dev/null 2> /dev/null &".
       
       END.
       ELSE DO: */
       
       IF  par_responde <> "" THEN
       DO:
           ASSIGN aux_nmremete = ""
                  aux_dsmailrm = par_responde.
       END.       

       RUN solicita_email_oracle(  INPUT  par_cdcooper        /* par_cdcooper         */
                                  ,INPUT  par_cdprogra        /* par_cdprogra         */
                                  ,INPUT  aux_dsdemail        /* par_des_destino      */
                                  ,INPUT  par_dsassunt        /* par_des_assunto      */
                                  ,INPUT  par_conteudo        /* par_des_corpo        */
                                  ,INPUT  aux_dsanexos_ora    /* par_des_anexo        */
                                  ,INPUT  "N"                 /* par_flg_remove_anex  */
                                  ,INPUT  IF aux_dsmailrm = crapcop.dsdemail THEN 
                                               "S" 
                                          ELSE "N"            /* par_flg_remete_coop  */
                                  ,INPUT  aux_nmremete        /* par_des_nome_reply   */
                                  ,INPUT  aux_dsmailrm        /* par_des_email_reply  */
                                  ,INPUT  "N"                 /* par_flg_log_batch    */
                                  ,INPUT  "S"                 /* par_flg_enviar       */
                                  ,OUTPUT aux_dscritic        /* par_des_erro         */
                                   ).

       IF  par_cdprogra <> "ATENDA"                               AND 
           par_cdprogra <> "B1WNET0002"                           AND
           aux_dsdemail <> "monitoracaodefraudes@cecred.coop.br"  AND 
           aux_dsdemail <> "prevencaodefraudes@cecred.coop.br"    THEN
           DO:    
               UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - "  +
                                 par_cdprogra + "' --> '"                   + 
                                 aux_dsarqlog + "ENVIADO PARA "             + 
                                 aux_dsdemail + " >> /usr/coop/"            + 
                                 TRIM(crapcop.dsdircop)                     + 
                                 "/log/proc_message.log").  
                                     
               OUTPUT STREAM str_email TO VALUE(aux_nmarqctg) APPEND.
                       
               PUT STREAM str_email UNFORMATTED aux_dscomand SKIP.
                        
               OUTPUT STREAM str_email CLOSE.
           END.                             
    
    END. /* Fim do DO TO */

END PROCEDURE.

/*............................................................................*/
