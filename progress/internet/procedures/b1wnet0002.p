/*..............................................................................

   Programa: b1wnet0002.p                  
   Autor   : David
   Data    : 03/10/2006                        Ultima atualizacao: 28/05/2018

   Dados referentes ao programa:

   Objetivo  : BO GERENCIAMENTO DE ACESSO A CONTA PELA INTERNET

   Alteracoes: 28/12/2006 - Verificar liberacao do acesso a conta (David).
   
               07/02/2007 - Alteracao no FIND crapass, para usar indice
                            crapass1, e rotina de verificacao de acesso
                            alterada (verificando se a senha/frase nao foi
                            alterada ha mais de 30 dias) (Junior/David).
                            
               09/02/2007 - Remover dtdemiss, para permitir que associado
                            demitido possa consultar a Internet (Junior).

               27/08/2007 - Criada procedure para validar senhas (David).
               
               19/09/2007 - ENCODE na validacao de senha e frase e no cadas-
                            tramento de frase (Junior).

               27/09/2007 - Tratamento na verificacao da frase secreta (David).
               
               09/10/2007 - Gerar log ao acessar a conta on-line (David).
               
               09/11/2007 - Implementar bloqueio de senha (David).

               28/12/2007 - Bloquear primeiro acesso ao site da Transpocred
                            30 dias apos a liberacao (David).

               07/01/2008 - Bloquear primeiro acesso baseado na craptab de
                            limites da internet 
                          - Tratamento de limites para pessoa juridica (David).
                          
               06/02/2008 - Mostrar nome completo ao carregar titulares com 
                            permissao de acesso ao InternetBank (David).

               06/03/2008 - Nova include para temp-tables (David).

               11/11/2008 - Implementacao e adaptacao para novo modulo de acesso
                            ao InternetBank por pessoas juridicas (David).

               23/03/2009 - Correcao na liberacao de operadores (David).
               
               25/06/2010 - Acerto na procedure carrega-titulares para gravar
                            log somente em caso de erro (David).
                            
               20/08/2010 - Enviar email para diego.gomes@cecred.coop.br quando
                            a senha informada estiver incorreta (David).
                            
               28/09/2010 - Enviar email de senha incorreta somente na penultima
                            tentativa (David).
                            
               21/03/2011 - Verificar permissao do usuario para acesso ao item
                            "Pagamento - DDA" (David).
                            
               12/07/2011 - Ajuste na configuracao do modulo DDA no menu do 
                            InternetBank (David).
                                                  
               03/10/2011 - Alterado procedure permissoes-menu, ajustes na
                            disponibilidade para operadores da conta. (Jorge)
                            
               04/10/2011 - Gera nova senha operadores internet(Guilherme)
               
               25/11/2011 - Utilizar dados de origem do IP do usuario na 
                            validacao de senha (David).
                            
               02/02/2012 - Alterar data de liberacao quando nova senha for
                            gerada para o operador da conta PJ (David).
                            
               21/08/2012 - Ajuste validacao senha (David).
               
               07/11/2012 - Implementar letras de seguranca (David).
               
               10/06/2013 - Alteraçao funçao enviar_email_completo para
                            nova versao (Jean Michel).
                            
               23/07/2013 - Ajustes para bloqueio e historico de senha. Criado 
                            procedure validar-senha-hsh e cadastrar-senha-hsh.
                            (Jorge).
                            
               21/08/2013 - Ajuste em proc. confirma-senha, adicionado verifica-
                            cao de avail em craptab. (Jorge)
                            
               10/09/2013 - Ajustar carregamento dos parametros de bloqueio de
                            senha (David).             
                            
               28/02/2014 - Incluso VALIDATE (Daniel).             
               
               03/07/2014 - Permitir acessar o dda aos operadores das PJ 
                            (Chamado 159339) (Jonata - RKAM).  
                            
               04/09/2014 - Ajuste na procedure "permissoes-menu" para
                            somente mostrar a opcao Credito Pre-Aprovado
                            caso possuir saldo. (James)
                            
               16/09/2014 - Bloquear acesso de cooperados migrados da Concredi
                            e Credimilsul nas novas contas antes e durante a 
                            incorporacao (David).
               
               14/10/2014 - Ajuste na procedure "permissoes-menu" pois
                            existem telas(urls) que estao disponiveis em mais
                            de uma posiçao no menu, e ajustado para verificar se o usuario
                            tem permissao em ambas a posiçoes(SD 202972 - Odirlei/Amcom)

               11/11/2014 - Inclusao do parametro "nrcpfope" na chamada da
                            procedure "busca_dados" da "b1wgen0188". (Jaison)
                            
               13/11/2014 - (Chamado 217240) Alterado formato tab045, retirado
                            o substr e usado o entry (Tiago Castro - RKAM).
                            
               10/02/2015 - Alterado rotina confirma-senha  para buscar o email 
                            da segurança corporativa para envio do email de acesso 
                            bloqueado ou indevido SD 252306 (Odirlei-AMcom)
                            
               02/06/2015 - Adição do campo inpessoa na temp-table tt-titulares
                            (Dionathan)
                            
               28/07/2015 - Adição de parâmetro flmobile para indicar que a origem
                            da chamada é do mobile (Dionathan)
                            
               23/11/2015 - Verificacao da situacao da senha apenas quando nao for
                            conta com assinatura conjunta PJ. em proc.
                            carrega-titulares. (Jorge/David)
                                      
               10/12/2015 - PRJ 131.Adicionado tratamento na procedure verifica-acesso 
                            para verificar vencimento de procuracao. (Reinert)             
                            
               21/12/2015 - Adição de parâmetro flmobile para indicar que a origem
                            da chamada é do mobile - procedure verifica-acesso (Dionathan)
               
               11/03/2016 - Adição da procedure permissoes-menu-mobile para obter 
                            permissoes do menu do Mobile. Projeto 286/3 - Mobile (Lombardi)
               
               11/05/2016 - Remocao de logica para somente mostrar Comprovantes Salariais
			                      quanto houver. Esta busca estava honerando o processo (Marcos-Supero)	
               
               18/08/2016 - Adicionada a propriedade qtdiaace na carrega-tutulares
                            PRJ286.5 - Cecred Mobile (Dionathan)
               
               18/08/2016 - Alteracoes na verifica-acesso para chamada no mobile
                            PRJ286.5 - Cecred Mobile (Dionathan)
               
               06/09/2016 - Removido a busca do preposto pelo proprio CPF do titular (Pessoa Jurídica)
							              (Andrey - RKAM)
               
               09/09/2016 - Alterado procedure Busca_Dados, retorno do parametro
						    aux_qtminast referente a quantidade minima de assinatura
						    conjunta, procedure carrega_titulares SD 514239 (Jean Michel).
               
			   17/10/2016 - Ajuste feito para que possa visualizar as opcoes de transacoes para
							contas com inpessoa = 3 ao criar um novo operador. (SD 538293 - Kelvin)
               
               24/01/2017 - Ajuste na procedure "permissoes-menu" para somente mostrar a 
                            opcao Desconto de Cheques quando possuir contrato de limite de
                            desconto de cheque. Projeto 300 (Lombardi)
               

               07/08/2017 - Ajuste na procedure "permissoes-menu" para somente mostrar a 
                            opcao de Pagamento por arquivo, quando possuir convenio homologado
                            ou arquivo de remessa enviado 
                            (Douglas - M271.3 Upload de Arquivo de Pagamento)

               06/10/2017 - Criar a procedure obtem-acesso-anterior (David)	 
                           
               04/04/2018 - Adicionada chamada pc_permite_lista_prod_tipo para verificar se o 
                            tipo de conta permite a contrataçao dos produtos. PRJ366 (Lombardi).

			   28/05/2018 - Ajustes referente alteracao da nova marca (P413 - Jonata Mouts).
               
			   03/06/2019 - Retirada validação de bloqueio de conta. (RITM0019350 - Lombardi).
         
               21/08/2019 - Ajustado para nao bloquear mais a conta por tempo de alteraçao de senha. (INC0023036 - Lombardi)

               22/07/2019 - Incluido validacao no permissoes-menu-mobile para menu 1004 
                             Simulacao de emprestimo. (P438 Douglas Pagel - AMcom).
               
..............................................................................*/


{ sistema/internet/includes/b1wnet0002tt.i }
{ sistema/generico/includes/b1wgen0017tt.i }
{ sistema/generico/includes/b1wgen0058tt.i }
{ sistema/generico/includes/b1wgen0079tt.i }
{ sistema/generico/includes/b1wgen0188tt.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/gera_log.i }
{ sistema/generico/includes/var_oracle.i }

DEF VAR aux_nrdrowid AS ROWID                                          NO-UNDO.

DEF VAR aux_cdcritic AS INTE                                           NO-UNDO.

DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF VAR aux_dstransa AS CHAR                                           NO-UNDO.
DEF VAR aux_dsorigem AS CHAR                                           NO-UNDO.


DEF TEMP-TABLE tt-titulares-nomes LIKE tt-titulares.

/*................................. FUNCTIONS ................................*/

FUNCTION valida-senha-numerica RETURN LOGICAL (INPUT par_dssenori AS CHAR,
                                               INPUT par_dssendig AS CHAR):

    DEF VAR aux_qtgrupos AS INTE          NO-UNDO.
    DEF VAR aux_dsgrupos AS CHAR EXTENT 8 NO-UNDO.
    DEF VAR aux_dsdiggrp AS CHAR EXTENT 8 NO-UNDO.
    DEF VAR aux_qtdiggrp AS INTE INIT 2   NO-UNDO.
    DEF VAR aux_dssendig AS CHAR          NO-UNDO.
    DEF VAR aux_contado1 AS INTE          NO-UNDO.
    DEF VAR aux_contado2 AS INTE          NO-UNDO.
    DEF VAR aux_contado3 AS INTE          NO-UNDO.
    DEF VAR aux_contado4 AS INTE          NO-UNDO.
    DEF VAR aux_contado5 AS INTE          NO-UNDO.
    DEF VAR aux_contado6 AS INTE          NO-UNDO.
    DEF VAR aux_contado7 AS INTE          NO-UNDO.
    DEF VAR aux_contado8 AS INTE          NO-UNDO.

    aux_qtgrupos = NUM-ENTRIES(par_dssendig,".").
           
    /** Senha numerica deve conter 8 digitos **/
    IF  aux_qtgrupos < 8  THEN
        RETURN FALSE.
    
    DO aux_contado1 = 1 TO aux_qtgrupos:
        aux_dsgrupos[aux_contado1] = ENTRY(aux_contado1,par_dssendig,".").
    END.

    /** Leitura Grupo 1 **/
    DO aux_contado1 = 1 TO aux_qtdiggrp:
        
      aux_dsdiggrp[1] = SUBSTR(aux_dsgrupos[1],aux_contado1,1).

      /** Leitura Grupo 2 **/
      DO aux_contado2 = 1 TO aux_qtdiggrp:
        
        aux_dsdiggrp[2] = SUBSTR(aux_dsgrupos[2],aux_contado2,1).
            
        /** Leitura Grupo 3 **/
        DO aux_contado3 = 1 TO aux_qtdiggrp:
        
          aux_dsdiggrp[3] = SUBSTR(aux_dsgrupos[3],aux_contado3,1).

          /** Leitura Grupo 4 **/
          DO aux_contado4 = 1 TO aux_qtdiggrp:
        
            aux_dsdiggrp[4] = SUBSTR(aux_dsgrupos[4],aux_contado4,1).

            /** Leitura Grupo 5 **/
            DO aux_contado5 = 1 TO aux_qtdiggrp:
        
              aux_dsdiggrp[5] = SUBSTR(aux_dsgrupos[5],aux_contado5,1).

              /** Leitura Grupo 6 **/
              DO aux_contado6 = 1 TO aux_qtdiggrp:
        
                aux_dsdiggrp[6] = SUBSTR(aux_dsgrupos[6],aux_contado6,1).

                /** Leitura Grupo 7 **/
                DO aux_contado7 = 1 TO aux_qtdiggrp:
        
                  aux_dsdiggrp[7] = SUBSTR(aux_dsgrupos[7],aux_contado7,1).

                  /** Leitura Grupo 8 **/
                  DO aux_contado8 = 1 TO aux_qtdiggrp:
        
                    aux_dsdiggrp[8] = SUBSTR(aux_dsgrupos[8],aux_contado8,1).

                    /** Monta combinacao de senha com os digitos extraidos **/
                    aux_dssendig = ENCODE(aux_dsdiggrp[1] + aux_dsdiggrp[2] +
                                          aux_dsdiggrp[3] + aux_dsdiggrp[4] +
                                          aux_dsdiggrp[5] + aux_dsdiggrp[6] +
                                          aux_dsdiggrp[7] + aux_dsdiggrp[8]).
                    
                    /** Valida combinacao da senha **/
                    IF  par_dssenori = aux_dssendig  THEN 
                        RETURN TRUE.
        
                  END. /** Fim do DO .. TO - Grupo 8 **/
        
                END. /** Fim do DO .. TO - Grupo 7 **/
                
              END. /** Fim do DO .. TO - Grupo 6 **/
                
            END. /** Fim do DO .. TO - Grupo 5 **/
        
          END. /** Fim do DO .. TO - Grupo 4 **/
        
        END. /** Fim do DO .. TO - Grupo 3 **/

      END. /** Fim do DO .. TO - Grupo 2 **/
        
    END. /** Fim do DO .. TO - Grupo 1 **/

    RETURN FALSE.

END FUNCTION.

FUNCTION obtem-nova-senha RETURN CHAR (INPUT par_dssennew AS CHAR,
                                       INPUT par_dssenrep AS CHAR):

    DEF VAR aux_qtgrpnew AS INTE          NO-UNDO.
    DEF VAR aux_dsgrpnew AS CHAR EXTENT 8 NO-UNDO.
    DEF VAR aux_dggrpnew AS CHAR EXTENT 8 NO-UNDO.
    DEF VAR aux_qtgrprep AS INTE          NO-UNDO.
    DEF VAR aux_dsgrprep AS CHAR EXTENT 8 NO-UNDO.
    DEF VAR aux_dggrprep AS CHAR EXTENT 8 NO-UNDO.
    DEF VAR aux_qtdiggrp AS INTE INIT 2   NO-UNDO.
    DEF VAR aux_contado1 AS INTE          NO-UNDO.
    DEF VAR aux_contado2 AS INTE          NO-UNDO.
    DEF VAR aux_contado3 AS INTE          NO-UNDO.
    DEF VAR aux_dssendig AS CHAR          NO-UNDO.
    
    ASSIGN aux_qtgrpnew = NUM-ENTRIES(par_dssennew,".")
           aux_qtgrprep = NUM-ENTRIES(par_dssenrep,".").
           
    /** Senha numerica deve conter 8 digitos **/
    IF  aux_qtgrpnew < 8 OR aux_qtgrprep < 8  THEN
        RETURN "".
    
    DO aux_contado1 = 1 TO aux_qtgrpnew:
        ASSIGN aux_dsgrpnew[aux_contado1] = ENTRY(aux_contado1,
                                                  par_dssennew,".")
               aux_dsgrprep[aux_contado1] = ENTRY(aux_contado1,
                                                  par_dssenrep,".").
    END.

    ASSIGN aux_dssendig = "".

    GRUPO:

    DO aux_contado1 = 1 TO aux_qtgrpnew:

        DO aux_contado2 = 1 TO aux_qtdiggrp:
        
            ASSIGN aux_dggrpnew[aux_contado1] = 
                       SUBSTR(aux_dsgrpnew[aux_contado1],aux_contado2,1).
    
            DO aux_contado3 = 1 TO aux_qtdiggrp:
    
                ASSIGN aux_dggrprep[aux_contado1] = 
                           SUBSTR(aux_dsgrprep[aux_contado1],aux_contado3,1).
                
                IF  aux_dggrpnew[aux_contado1] = aux_dggrprep[aux_contado1]  THEN
                    DO:
                        ASSIGN aux_dssendig = aux_dssendig + 
                                              aux_dggrpnew[aux_contado1].
                        NEXT GRUPO.
                    END.
                
            END. /** Fim do DO ... TO (3) **/

        END. /** Fim do DO ... TO (2) **/

    END. /** Fim do DO ... TO (1) **/

    IF  LENGTH(aux_dssendig) <> 8  THEN
        ASSIGN aux_dssendig = "".
      
    RETURN aux_dssendig.

END FUNCTION.

/*............................ PROCEDURES EXTERNAS ...........................*/


/******************************************************************************/
/**     Procedure para carregar titulares/operadores para acesso a conta     **/
/******************************************************************************/
PROCEDURE carrega-titulares.

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_flmobile AS LOGI                           NO-UNDO.
            
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-titulares.
    DEF OUTPUT PARAM par_qtdiaace AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_nmprimtl AS CHAR                          NO-UNDO.

    DEF VAR aux_inbloque AS INTE INIT 0                             NO-UNDO.
    DEF VAR aux_incadsen AS INTE INIT 0                             NO-UNDO.
    DEF VAR aux_qtdiaace AS INTE                                    NO-UNDO.
    DEF VAR aux_qtminast AS INTE									NO-UNDO.
    
    DEF VAR tmp_dsprnome AS CHAR									NO-UNDO.
    DEF VAR tmp_contador AS INTE									NO-UNDO.
    
    DEF VAR h-b1wgen0058 AS HANDLE                                  NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-crapavt.
    EMPTY TEMP-TABLE tt-bens.
    EMPTY TEMP-TABLE tt-titulares.
    
    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Obter titulares/operadores para acesso a conta"
           aux_cdcritic = 0
           aux_dscritic = "".
           
    DO WHILE TRUE:

        /* Bloqueio internet durante e apos incorporacoes */
        IF (par_cdcooper = 4            OR
            par_cdcooper = 15)          AND
            aux_datdodia >= 11/29/2014  THEN
            DO:
                ASSIGN aux_dscritic = "Sistema indisponivel. Tente " +
                                      "novamente mais tarde!".
                LEAVE.
            END.
        
        /* Bloqueio internet Transulcred durante e apos incorporacoes */
        IF  par_cdcooper = 17           AND
            aux_datdodia >= 12/31/2016  THEN
            DO:
                ASSIGN aux_dscritic = "Sistema indisponivel. Tente " +
                                      "novamente mais tarde!".
                LEAVE.
            END.        
        
        FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                           crapass.nrdconta = par_nrdconta NO-LOCK NO-ERROR.
                                 
        IF  NOT AVAILABLE crapass  THEN
            DO:
                ASSIGN aux_cdcritic = 9.
                LEAVE.
            END.

        /** Verifica se existe pelo menos uma senha cadastrada **/
        FIND FIRST crapsnh WHERE crapsnh.cdcooper = par_cdcooper AND
                                 crapsnh.nrdconta = par_nrdconta AND
                                 crapsnh.tpdsenha = 1            
                                 NO-LOCK NO-ERROR.
             
        IF  NOT AVAILABLE crapsnh  THEN
            DO:
                ASSIGN aux_dscritic = "A senha para Conta On-Line nao foi " +
                                      "cadastrada".
                LEAVE.
            END.
        
        /* verififcar situacao apenas contas sem assinatura conjunta */
        IF crapass.idastcjt = 0 AND crapsnh.cdsitsnh <> 1  THEN
            DO:
                IF  crapsnh.cdsitsnh = 2  THEN
                    ASSIGN aux_dscritic = "A senha para Conta On-Line " +
                                          "foi bloqueada".
                ELSE
                IF  crapsnh.cdsitsnh = 3  THEN
                    ASSIGN aux_dscritic = "A senha para Conta On-Line foi " +
                                          "cancelada".
                ELSE
                    ASSIGN aux_dscritic = "A senha para Conta On-Line nao " +
                                          "foi cadastrada".

                LEAVE.
            END.
    
        IF  crapass.inpessoa = 1  AND  /** Pessoa Fisica **/
            NOT CAN-FIND(FIRST crapttl WHERE 
                               crapttl.cdcooper = par_cdcooper AND
                               crapttl.nrdconta = par_nrdconta NO-LOCK)  THEN 
            DO:
                ASSIGN aux_dscritic = "Nao existem titulares cadastrados.".
                LEAVE.
            END.

        /* Seta o nome da conta apenas se for assinatura conjunta */
        IF crapass.idastcjt = 1 THEN
          ASSIGN par_nmprimtl = crapass.nmprimtl.
		  
        LEAVE. 

    END. /** Fim do DO WHILE TRUE **/

    IF  aux_cdcritic > 0 OR aux_dscritic <> ""  THEN
        DO: 
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                           
            IF  par_flgerlog  THEN
                RUN proc_gerar_log (INPUT par_cdcooper,
                                    INPUT par_cdoperad,
                                    INPUT aux_dscritic,
                                    INPUT aux_dsorigem,
                                    INPUT aux_dstransa,
                                    INPUT FALSE,
                                    INPUT par_idseqttl,
                                    INPUT par_nmdatela,
                                    INPUT par_nrdconta,
                                   OUTPUT aux_nrdrowid).

            RETURN "NOK".
        END.
    
    IF  crapass.inpessoa = 1  THEN  /** Pessoa Fisica **/
        DO:
            /** Tabela com os limites para internet **/
            FIND craptab WHERE craptab.cdcooper = par_cdcooper AND
                               craptab.nmsistem = "CRED"       AND
                               craptab.tptabela = "GENERI"     AND
                               craptab.cdempres = 0            AND
                               craptab.cdacesso = "LIMINTERNT" AND
                               craptab.tpregist = 1            NO-LOCK NO-ERROR.
                        
            IF  AVAILABLE craptab  THEN
                ASSIGN aux_qtdiaace = INTE(ENTRY(3,craptab.dstextab,";")).
            ELSE
                ASSIGN aux_qtdiaace = 3.
        
            FOR EACH crapttl WHERE crapttl.cdcooper = par_cdcooper AND
                                   crapttl.nrdconta = par_nrdconta NO-LOCK
                                   BY crapttl.idseqttl:
        
                FIND crapsnh WHERE crapsnh.cdcooper = par_cdcooper     AND
                                   crapsnh.nrdconta = par_nrdconta     AND
                                   crapsnh.idseqttl = crapttl.idseqttl AND
                                   crapsnh.tpdsenha = 1                AND
                                   crapsnh.cdsitsnh = 1 /** ATIVO **/
                                   NO-LOCK NO-ERROR.
               
                IF  NOT AVAILABLE crapsnh  THEN
                    NEXT.

                IF  crapsnh.dssenweb = ""  THEN
                    DO:      
                        ASSIGN aux_incadsen = 1.
                        
                        IF  (aux_datdodia - crapsnh.dtlibera) > aux_qtdiaace  THEN 
                            ASSIGN aux_inbloque = 1.
                        ELSE
                            ASSIGN aux_inbloque = 0.
                    END.
                ELSE
                    ASSIGN aux_inbloque = 0
                           aux_incadsen = 0.

                CREATE tt-titulares.
                ASSIGN tt-titulares.idseqttl = crapttl.idseqttl
                       tt-titulares.nmtitula = TRIM(crapttl.nmextttl)
                       tt-titulares.nrcpfope = 0
                       tt-titulares.incadsen = aux_incadsen
                       tt-titulares.inbloque = aux_inbloque
                       tt-titulares.inpessoa = crapass.inpessoa.
            
            END. /** Fim do FOR EACH crapttl **/
                                   
            /* Selecionar apenas primeiro nome. */            
            FIND FIRST tt-titulares NO-LOCK NO-ERROR NO-WAIT.
            
            IF  TEMP-TABLE tt-titulares:HAS-RECORDS AND 
                par_flmobile <> YES                       THEN
                DO:                
                    RUN organiza-nomes-titulares (INPUT-OUTPUT TABLE tt-titulares).                
        END.
                
        END.
    ELSE /** Pessoa Juridica **/
        DO:
            /** Tabela com os limites para internet **/
            FIND craptab WHERE craptab.cdcooper = par_cdcooper AND
                               craptab.nmsistem = "CRED"       AND
                               craptab.tptabela = "GENERI"     AND
                               craptab.cdempres = 0            AND
                               craptab.cdacesso = "LIMINTERNT" AND
                               craptab.tpregist = 2            NO-LOCK NO-ERROR.
                        
            IF  AVAILABLE craptab  THEN
                ASSIGN aux_qtdiaace = INTE(ENTRY(3,craptab.dstextab,";")).
            ELSE
                ASSIGN aux_qtdiaace = 3.
            
            /* se nao nescessita assinatura conjunta */
            IF  crapass.idastcjt = 0 THEN DO:
                IF crapsnh.dssenweb = ""  THEN
                   DO:      
                       ASSIGN aux_incadsen = 1.
                                
                       IF (aux_datdodia - crapsnh.dtlibera) > aux_qtdiaace THEN
                          ASSIGN aux_inbloque = 1.
                       ELSE
                          ASSIGN aux_inbloque = 0.
                   END.
                ELSE
                   ASSIGN aux_inbloque = 0
                          aux_incadsen = 0.
         
                CREATE tt-titulares.
                ASSIGN tt-titulares.idseqttl = 1
                       tt-titulares.nmtitula = TRIM(crapass.nmprimtl)
                       tt-titulares.nrcpfope = 0
                       tt-titulares.incadsen = aux_incadsen
                       tt-titulares.inbloque = aux_inbloque
                       tt-titulares.inpessoa = crapass.inpessoa
                       tt-titulares.idastcjt = crapass.idastcjt.
            END.
            ELSE DO: /* Exige assinatura conjunta */

                RUN sistema/generico/procedures/b1wgen0058.p PERSISTENT 
                    SET h-b1wgen0058.
        
                IF  NOT VALID-HANDLE(h-b1wgen0058)  THEN
                    DO:
                        ASSIGN aux_cdcritic = 0
                               aux_dscritic = "Handle invalido para BO " +
                                              "b1wgen0058.".
                       
                        RUN gera_erro (INPUT par_cdcooper,
                                       INPUT par_cdagenci,
                                       INPUT par_nrdcaixa,
                                       INPUT 1,            /** Sequencia **/
                                       INPUT aux_cdcritic,
                                       INPUT-OUTPUT aux_dscritic).
                                       
                        IF  par_flgerlog  THEN
                            RUN proc_gerar_log (INPUT par_cdcooper,
                                                INPUT par_cdoperad,
                                                INPUT aux_dscritic,
                                                INPUT aux_dsorigem,
                                                INPUT aux_dstransa,
                                                INPUT FALSE,
                                                INPUT par_idseqttl,
                                                INPUT par_nmdatela,
                                                INPUT par_nrdconta,
                                               OUTPUT aux_nrdrowid).
            
                        RETURN "NOK".
                    END.
    
                RUN Busca_Dados IN h-b1wgen0058 (INPUT par_cdcooper,
                                                 INPUT 0,     /* par_cdagenci */
                                                 INPUT 0,     /* par_nrdcaixa */
                                                 INPUT par_cdoperad,
                                                 INPUT par_nmdatela,
                                                 INPUT par_idorigem,
                                                 INPUT par_nrdconta,
                                                 INPUT 0,     /* par_idseqttl */
                                                 INPUT FALSE, /* par_flgerlog */
                                                 INPUT 'C',   /* par_cddopcao */
                                                 INPUT 0,     /* par_nrdctato */
                                                 INPUT 0,     /* par_nrcpfcgc */
                                                 INPUT ?,     /* par_nrdrowid */
                                                OUTPUT TABLE tt-crapavt,
                                                OUTPUT TABLE tt-bens,
												OUTPUT aux_qtminast,
                                                OUTPUT TABLE tt-erro) NO-ERROR.

                DELETE PROCEDURE h-b1wgen0058.

                FOR EACH tt-crapavt WHERE tt-crapavt.idrspleg = 1 NO-LOCK: 
                    
                    FOR FIRST crapsnh WHERE crapsnh.cdcooper = tt-crapavt.cdcooper AND
                                            crapsnh.nrdconta = tt-crapavt.nrdconta AND
                                            crapsnh.nrcpfcgc = tt-crapavt.nrcpfcgc AND
                                            crapsnh.tpdsenha = 1                   AND
                                            crapsnh.cdsitsnh = 1
                                            NO-LOCK. END.

                    IF NOT AVAIL crapsnh THEN 
                       NEXT.
                                           
                    IF crapsnh.dssenweb = ""  THEN
                       DO:      
                          ASSIGN aux_incadsen = 1.
                                
                          IF (aux_datdodia - crapsnh.dtlibera) > aux_qtdiaace THEN
                             ASSIGN aux_inbloque = 1.
                          ELSE
                             ASSIGN aux_inbloque = 0.
                       END.
                    ELSE
                       ASSIGN aux_inbloque = 0
                              aux_incadsen = 0.
                    CREATE tt-titulares.
                    ASSIGN tt-titulares.idseqttl = crapsnh.idseqttl
                           tt-titulares.nmtitula = TRIM(tt-crapavt.nmdavali)
                           tt-titulares.nrcpfope = 0
                           tt-titulares.incadsen = aux_incadsen
                           tt-titulares.inbloque = aux_inbloque
                           tt-titulares.inpessoa = crapass.inpessoa
                           tt-titulares.idastcjt = crapass.idastcjt.
                END.
            END.
            
            /** Não deve carregar operadores quando for Mobile **/
            IF par_flmobile <> YES THEN
            DO:
                /** Carregar operadores liberados para a conta juridica **/
                FOR EACH crapopi WHERE crapopi.cdcooper = par_cdcooper AND
                                       crapopi.nrdconta = par_nrdconta AND
                                       crapopi.flgsitop = TRUE         NO-LOCK
                                       BY crapopi.nmoperad:
    
                    IF  crapopi.dsdfrase = ""  THEN
                        DO:      
                            ASSIGN aux_incadsen = 1.
                            
                            IF  (aux_datdodia - crapopi.dtlibera) > aux_qtdiaace  THEN 
                                ASSIGN aux_inbloque = 1.
                            ELSE
                                ASSIGN aux_inbloque = 0.
                        END.
                    ELSE
                        ASSIGN aux_inbloque = 0
                               aux_incadsen = 0.
                               
                    CREATE tt-titulares.
                    ASSIGN tt-titulares.idseqttl = 1
                           tt-titulares.nmtitula = TRIM(crapopi.nmoperad)
                           tt-titulares.nrcpfope = crapopi.nrcpfope
                           tt-titulares.incadsen = aux_incadsen
                           tt-titulares.inbloque = aux_inbloque
                           tt-titulares.inpessoa = crapass.inpessoa
                           tt-titulares.idastcjt = crapass.idastcjt.
    
                END. /** Fim do FOR EACH crapopi **/
            END. /** Fim do IF par_flmobile **/
            
            /* Selecionar apenas primeiro nome. */
            FIND FIRST tt-titulares NO-LOCK NO-ERROR NO-WAIT.
                    
            IF  TEMP-TABLE tt-titulares:HAS-RECORDS AND 
                par_flmobile <> YES                       THEN
                DO:                
                    RUN organiza-nomes-titulares (INPUT-OUTPUT TABLE tt-titulares).
        END.
        END.

    IF  NOT TEMP-TABLE tt-titulares:HAS-RECORDS THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "A senha para Conta On-Line nao foi " +
                                  "cadastrada".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                           
            IF  par_flgerlog  THEN
                RUN proc_gerar_log (INPUT par_cdcooper,
                                    INPUT par_cdoperad,
                                    INPUT aux_dscritic,
                                    INPUT aux_dsorigem,
                                    INPUT aux_dstransa,
                                    INPUT FALSE,
                                    INPUT par_idseqttl,
                                    INPUT par_nmdatela,
                                    INPUT par_nrdconta,
                                   OUTPUT aux_nrdrowid).

            RETURN "NOK".
        END.

    par_qtdiaace = aux_qtdiaace.
    RETURN "OK".
    
END PROCEDURE.


/******************************************************************************/
/**                 Procedure para obter operadores da conta                 **/
/******************************************************************************/
PROCEDURE obtem-operadores.

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
            
    DEF OUTPUT PARAM TABLE FOR tt-operadores.

    EMPTY TEMP-TABLE tt-operadores.
    
    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Obter operadores da conta".
           
    /** Carregar operadores liberados para a conta juridica **/
    FOR EACH crapopi WHERE crapopi.cdcooper = par_cdcooper AND
                           crapopi.nrdconta = par_nrdconta NO-LOCK:

        CREATE tt-operadores.
        ASSIGN tt-operadores.nmoperad = crapopi.nmoperad
               tt-operadores.nrcpfope = crapopi.nrcpfope
               tt-operadores.dsdcargo = crapopi.dsdcargo
               tt-operadores.flgsitop = crapopi.flgsitop
               tt-operadores.dsdemail = crapopi.dsdemail
               /* inicio: melhoria conta conjunta */
			   tt-operadores.vllbolet = crapopi.vllbolet
			   tt-operadores.vllimtrf = crapopi.vllimtrf
			   tt-operadores.vllimted = crapopi.vllimted
			   tt-operadores.vllimvrb = crapopi.vllimvrb
			   tt-operadores.vllimflp = crapopi.vllimflp.
			   /* fim da melhoria */

    END. /** Fim do FOR EACH crapopi **/
        
    IF  par_flgerlog  THEN
        RUN proc_gerar_log (INPUT par_cdcooper,
                            INPUT par_cdoperad,
                            INPUT "",
                            INPUT aux_dsorigem,
                            INPUT aux_dstransa,
                            INPUT TRUE,
                            INPUT par_idseqttl,
                            INPUT par_nmdatela,
                            INPUT par_nrdconta,
                           OUTPUT aux_nrdrowid).
                                           
    RETURN "OK".
    
END PROCEDURE.


/******************************************************************************/
/**          Procedure para cadastrar ou alterar operador da conta           **/
/******************************************************************************/
PROCEDURE gerenciar-operador.

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrcpfope LIKE crapopi.nrcpfope             NO-UNDO.
    DEF  INPUT PARAM par_desdacao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dsdemail AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dsdcargo AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_flgsitop AS LOGI                           NO-UNDO.
	DEF  INPUT PARAM par_geraflux AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdditens AS CHAR                           NO-UNDO.
	DEF  INPUT PARAM par_vllbolet LIKE crapopi.vllbolet             NO-UNDO.
	DEF  INPUT PARAM par_vllimtrf LIKE crapopi.vllimtrf             NO-UNDO.
	DEF  INPUT PARAM par_vllimted LIKE crapopi.vllimted             NO-UNDO.
	DEF  INPUT PARAM par_vllimvrb LIKE crapopi.vllimvrb             NO-UNDO.
	DEF  INPUT PARAM par_vllimflp LIKE crapopi.vllimflp             NO-UNDO.

    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR h-b1wgen0011 AS HANDLE                                  NO-UNDO.
    DEF VAR h-b1wgen9999 AS HANDLE                                  NO-UNDO.

    DEF VAR aux_contador AS INTE                                    NO-UNDO.

    DEF VAR aux_nmoperad AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsdemail AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsdcargo AS CHAR                                    NO-UNDO.
    DEF VAR aux_desacebl AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsdsenha AS CHAR                                    NO-UNDO.
    DEF VAR aux_cdditens AS CHAR                                    NO-UNDO.
    DEF VAR aux_conteudo AS CHAR                                    NO-UNDO.

    DEF VAR aux_vllbolet AS DECI                                     NO-UNDO.
    DEF VAR aux_vllimtrf AS DECI                                     NO-UNDO.
    DEF VAR aux_vllimted AS DECI                                     NO-UNDO.
    DEF VAR aux_vllimvrb AS DECI                                     NO-UNDO.
    DEF VAR aux_vllimflp AS DECI                                     NO-UNDO.	

    DEF VAR aux_flgsitop AS LOGI                                    NO-UNDO.
    DEF VAR aux_flgtrans AS LOGI                                    NO-UNDO.
    DEF VAR aux_flgstcpf AS LOGI                                    NO-UNDO.
    DEF VAR aux_flexiste AS LOGI                                    NO-UNDO.

    DEF BUFFER crabaci FOR crapaci.
    
    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-itens-menu.
    
    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Gerenciar operador da conta."
           aux_cdcritic = 0
           aux_dscritic = "".

    FIND FIRST crapass WHERE crapass.cdcooper = par_cdcooper AND
                             crapass.nrdconta = par_nrdconta NO-LOCK NO-ERROR.           

    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.
   
    IF  NOT AVAILABLE crapcop  THEN
        DO:
            ASSIGN aux_cdcritic = 651 
                   aux_dscritic = "".
                
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                               
            IF  par_flgerlog  THEN
                DO:
                    RUN proc_gerar_log (INPUT par_cdcooper,
                                        INPUT par_cdoperad,
                                        INPUT aux_dscritic,
                                        INPUT aux_dsorigem,
                                        INPUT aux_dstransa,
                                        INPUT FALSE,
                                        INPUT par_idseqttl,
                                        INPUT par_nmdatela,
                                        INPUT par_nrdconta,
                                       OUTPUT aux_nrdrowid).
                
                    RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                             INPUT "Operador",
                                             INPUT "",
                                             INPUT STRING(STRING(par_nrcpfope,
                                                          "99999999999"),
                                                          "xxx.xxx.xxx-xx")).
                END.
                
            RETURN "NOK".
        END.

    DO aux_contador = 1 TO NUM-ENTRIES(par_cdditens,"/"):
    
        ASSIGN aux_cdditens = ENTRY(aux_contador,par_cdditens,"/").
        
        CREATE tt-itens-menu.
        ASSIGN tt-itens-menu.cditemmn = INTE(ENTRY(1,aux_cdditens,","))
               tt-itens-menu.cdsubitm = INTE(ENTRY(2,aux_cdditens,","))
               tt-itens-menu.flgacebl = TRUE
               tt-itens-menu.flcreate = TRUE.
    
    END.
    
    TRANSACAO:
    
    DO TRANSACTION ON ERROR UNDO TRANSACAO, LEAVE TRANSACAO:
    
        RUN sistema/generico/procedures/b1wgen9999.p PERSISTENT 
            SET h-b1wgen9999.
    
        IF  NOT VALID-HANDLE(h-b1wgen9999)  THEN
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Handle invalido para BO b1wgen9999.".
                       
                UNDO TRANSACAO, LEAVE TRANSACAO.       
            END.

        RUN valida-cpf IN h-b1wgen9999 (INPUT par_nrcpfope,
                                       OUTPUT aux_flgstcpf).

        DELETE PROCEDURE h-b1wgen9999.
            
        IF  NOT aux_flgstcpf  THEN
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "CPF invalido.".
                       
                UNDO TRANSACAO, LEAVE TRANSACAO.       
            END.
        
        IF  par_desdacao = "GERARNOVASENHA"  THEN
        DO:
            /* gerar nova senha e enviar e-mail ao operador */
            RUN gerar_nova_senha (INPUT par_cdcooper,
                                  INPUT par_nrdconta,
                                  INPUT par_idseqttl,
                                  INPUT par_nrcpfope,
                                  OUTPUT aux_dsdsenha,
                                  OUTPUT aux_cdcritic,
                                  OUTPUT aux_dscritic).

            IF  RETURN-VALUE <> "OK"  THEN
            DO:
                UNDO TRANSACAO, LEAVE TRANSACAO.       
            END.
            ELSE
            DO:
                ASSIGN aux_flgtrans = TRUE.
                /* sai da transacao gera os logs e msg */
                LEAVE TRANSACAO.
            END.
        END.
        ELSE
        DO:
            IF  par_nmoperad = ""  THEN
                DO:
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = "Informe o nome do operador.".
                           
                    UNDO TRANSACAO, LEAVE TRANSACAO.       
                END.
    
            IF  par_dsdemail = ""  THEN
                DO:
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = "Informe o e-mail do operador.".
                           
                    UNDO TRANSACAO, LEAVE TRANSACAO.       
                END.
                    
            IF  par_dsdcargo = ""  THEN
                DO:
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = "Informe o cargo do operador.".
                           
                    UNDO TRANSACAO, LEAVE TRANSACAO.       
                END.
                
            IF  par_geraflux = 1 THEN
                DO:
                    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
                    
                    RUN STORED-PROCEDURE pc_valida_limite_operador aux_handproc = PROC-HANDLE NO-ERROR
                                 (INPUT par_cdcooper,
                                  INPUT par_nrdconta,
                                  INPUT par_nrcpfope,
                                  INPUT par_idseqttl,
                                  INPUT par_vllbolet,
                                  INPUT par_vllimtrf,
                                  INPUT par_vllimted,
                                  INPUT par_vllimvrb,
                                  INPUT par_vllimflp,
                                  OUTPUT ?,
                                  OUTPUT 0).

                    CLOSE STORED-PROC pc_valida_limite_operador aux_statproc = PROC-STATUS
                        WHERE PROC-HANDLE = aux_handproc.
                        
                    ASSIGN aux_dscritic = pc_valida_limite_operador.pr_dscritic
                                                    WHEN pc_valida_limite_operador.pr_dscritic <> ?
                           aux_cdcritic = pc_valida_limite_operador.pr_cdcritic
                                                    WHEN pc_valida_limite_operador.pr_cdcritic <> ?.

                    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

                    IF  aux_cdcritic > 0 THEN
                        DO:
                            FIND crapcri WHERE crapcri.cdcritic = aux_cdcritic
                                               NO-LOCK NO-ERROR.

                            IF  AVAIL crapcri  THEN    
                                DO:
                                    ASSIGN aux_cdcritic = 0
                                           aux_dscritic = crapcri.dscritic.                          
                                           
                                    UNDO TRANSACAO, LEAVE TRANSACAO. 
                                END.
                        END. 
                END.
                        
            IF  par_desdacao = "ALTERAR"  THEN
                DO:
                    DO aux_contador = 1 TO 10:
                
                        ASSIGN aux_cdcritic = 0
                               aux_dscritic = "".
            
                        FIND crapopi WHERE crapopi.cdcooper = par_cdcooper AND
                                           crapopi.nrdconta = par_nrdconta AND
                                           crapopi.nrcpfope = par_nrcpfope 
                                           EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
    
                        IF  NOT AVAILABLE crapopi  THEN
                            DO:
                                IF  LOCKED crapopi  THEN
                                    DO:
                                        aux_dscritic = "Registro do operador esta" +
                                                       " sendo alterado. Tente " +
                                                       "novamente.".
                                        PAUSE 1 NO-MESSAGE.
                                        NEXT.
                                    END.
                                ELSE
                                    aux_dscritic = "Operador nao cadastrado ou " +
                                                   "bloqueado.".
                            END.
                        
                        LEAVE.
            
                    END. /** Fim do DO .. TO **/
        
                    IF  aux_dscritic <> ""  THEN
                        UNDO TRANSACAO, LEAVE TRANSACAO.
                END.
            ELSE
            IF  par_desdacao = "CADASTRAR"  THEN
                DO:
                    FIND crapopi WHERE crapopi.cdcooper = par_cdcooper AND
                                       crapopi.nrdconta = par_nrdconta AND
                                       crapopi.nrcpfope = par_nrcpfope 
                                       NO-LOCK NO-ERROR.
    
                    IF  AVAILABLE crapopi  THEN
                        DO:
                            ASSIGN aux_cdcritic = 0
                                   aux_dscritic = "Operador ja cadastrado.".
                                   
                            UNDO TRANSACAO, LEAVE TRANSACAO.    
                        END.
    
                    CREATE crapopi.
                    ASSIGN crapopi.cdcooper = par_cdcooper
                           crapopi.nrdconta = par_nrdconta
                           crapopi.nrcpfope = par_nrcpfope
                           crapopi.dtlibera = aux_datdodia
                           crapopi.flgsitop = FALSE.
                    VALIDATE crapopi.
                END.
                
            IF  NOT crapopi.flgsitop AND par_flgsitop  THEN
                DO:
                    /* gerar uma nova senha diferente das 
                       existentes em craphsh.             */
                    DO aux_contador = 1 TO 10:

                       RUN gerar-senha (OUTPUT aux_dsdsenha).
                       
                       RUN validar-senha-hsh (INPUT par_cdcooper,
                                              INPUT par_nrdconta,
                                              INPUT par_idseqttl,
                                              INPUT par_nrcpfope,
                                              INPUT aux_dsdsenha,
                                              INPUT "",
                                              INPUT 0, /* valida senha num */
                                             OUTPUT aux_dscritic).
                       
                       IF  RETURN-VALUE = "OK"  THEN
                           LEAVE.

                    END.

                    IF  aux_dscritic <> "" THEN
                        UNDO TRANSACAO, LEAVE TRANSACAO.
                    
                    RUN cadastrar-senha-hsh (INPUT par_cdcooper,
                                             INPUT par_nrdconta,
                                             INPUT par_idseqttl,
                                             INPUT par_nrcpfope,
                                             INPUT aux_dsdsenha,
                                             INPUT "",
                                             INPUT 1,
                                            OUTPUT aux_dscritic).
                    
                    IF  RETURN-VALUE <> "OK" THEN
                    DO:
                         ASSIGN aux_cdcritic = 0 
                                aux_dscritic = "Problema ao cadastrar senha " +
                                               " no historico de senhas.".
                                
                         RUN gera_erro (INPUT par_cdcooper,
                                        INPUT par_cdagenci,
                                        INPUT par_nrdcaixa,
                                        INPUT 1,            /** Sequencia **/
                                        INPUT aux_cdcritic,
                                        INPUT-OUTPUT aux_dscritic).
                                           
                         IF  par_flgerlog  THEN
                             DO:
                                RUN proc_gerar_log (INPUT par_cdcooper,
                                                    INPUT par_cdoperad,
                                                    INPUT aux_dscritic,
                                                    INPUT aux_dsorigem,
                                                    INPUT aux_dstransa,
                                                    INPUT FALSE,
                                                    INPUT par_idseqttl,
                                                    INPUT par_nmdatela,
                                                    INPUT par_nrdconta,
                                                   OUTPUT aux_nrdrowid).
                            
                                RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                                         INPUT "Operador",
                                                         INPUT "",
                                                         INPUT STRING(STRING(
                                                            par_nrcpfope,
                                                            "99999999999"),
                                                            "xxx.xxx.xxx-xx")).
                             END.
                                
                         RETURN "NOK".
                    END.

                    ASSIGN crapopi.dsdsenha = ENCODE(aux_dsdsenha)
                           crapopi.dsdfrase = ""
                           crapopi.dtblutsh = ?
                           crapopi.dtlibera = aux_datdodia
                           crapopi.dtaltsnh = aux_datdodia.
                END.             
                                
            ASSIGN aux_nmoperad     = crapopi.nmoperad
                   aux_dsdemail     = crapopi.dsdemail
                   aux_dsdcargo     = crapopi.dsdcargo
                   aux_flgsitop     = crapopi.flgsitop
				   aux_vllbolet		= crapopi.vllbolet
				   aux_vllimtrf		= crapopi.vllimtrf
				   aux_vllimted		= crapopi.vllimted
				   aux_vllimvrb		= crapopi.vllimvrb
				   aux_vllimflp		= crapopi.vllimflp
                   crapopi.dtultalt = aux_datdodia
                   crapopi.nmoperad = par_nmoperad
                   crapopi.dsdemail = par_dsdemail
                   crapopi.dsdcargo = par_dsdcargo
				   crapopi.flgsitop = IF par_desdacao = "CADASTRAR" AND crapass.idastcjt = 1 THEN
										            FALSE
									            ELSE
										            par_flgsitop.
    
            FOR EACH crapaci WHERE crapaci.cdcooper = par_cdcooper AND
                                   crapaci.nrdconta = par_nrdconta AND
                                   crapaci.nrcpfope = par_nrcpfope NO-LOCK:
                                   
                DO aux_contador = 1 TO 10:
                
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = "".
            
                    FIND crabaci WHERE RECID(crabaci) = RECID(crapaci)
                                       EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
    
                    IF  NOT AVAILABLE crabaci  THEN
                        DO:
                            IF  LOCKED crabaci  THEN
                                DO:
                                    aux_dscritic = "Registro de permissao esta " +
                                                   "sendo alterado. Tente " +
                                                   "novamente.".
                                    PAUSE 1 NO-MESSAGE.
                                    NEXT.
                                END.
                            ELSE
                                aux_dscritic = "Permissao nao cadastrada.".
                        END.
                        
                    LEAVE.
                        
                END. /** Fim do DO .. TO **/
            
                IF  aux_dscritic <> ""  THEN
                    UNDO TRANSACAO, LEAVE TRANSACAO.
            
                FIND tt-itens-menu WHERE 
                     tt-itens-menu.cditemmn = crapaci.cditemmn AND
                     tt-itens-menu.cdsubitm = crapaci.cdsubitm 
                     EXCLUSIVE-LOCK NO-ERROR.
    
                IF  AVAILABLE tt-itens-menu  THEN
                    DO:
                        IF  NOT crapaci.flgacebl  THEN
                            ASSIGN crapaci.flgacebl       = TRUE
                                   tt-itens-menu.flgacebl = TRUE
                                   tt-itens-menu.flcreate = FALSE.
                        ELSE
                            DELETE tt-itens-menu.
                    END.
                ELSE
                    DO:
                        IF  crapaci.flgacebl  THEN
                            DO:
                                ASSIGN crapaci.flgacebl = FALSE.
    
                                CREATE tt-itens-menu.
                                ASSIGN tt-itens-menu.cditemmn = crapaci.cditemmn
                                       tt-itens-menu.cdsubitm = crapaci.cdsubitm
                                       tt-itens-menu.flgacebl = FALSE
                                       tt-itens-menu.flcreate = FALSE.
                            END.
                    END.
    
            END. /** Fim do FOR EACH crapaci **/
            
            FOR EACH tt-itens-menu WHERE tt-itens-menu.flcreate = TRUE NO-LOCK:
            
                CREATE crapaci.
                ASSIGN crapaci.cdcooper = par_cdcooper 
                       crapaci.nrdconta = par_nrdconta
                       crapaci.nrcpfope = par_nrcpfope
                       crapaci.cditemmn = tt-itens-menu.cditemmn
                       crapaci.cdsubitm = tt-itens-menu.cdsubitm
                       crapaci.flgacebl = TRUE.
                VALIDATE crapaci.
            
            END. /** Fim do FOR EACH tt-itens-menu **/
            
            IF  par_geraflux = 1 THEN
                DO:      
                    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
                    
                    RUN STORED-PROCEDURE pc_gera_msg_preposto aux_handproc = PROC-HANDLE NO-ERROR
                                 (INPUT par_cdcooper,
                                  INPUT par_nrdconta,
                                  INPUT par_nrcpfope,
                                  INPUT par_idseqttl,
                                  INPUT par_vllbolet,
                                  INPUT par_vllimtrf,
                                  INPUT par_vllimted,
                                  INPUT par_vllimvrb,
                                  INPUT par_vllimflp,
                                 OUTPUT ?).

                    CLOSE STORED-PROC pc_gera_msg_preposto aux_statproc = PROC-STATUS
                        WHERE PROC-HANDLE = aux_handproc.

                    ASSIGN aux_dscritic = pc_gera_msg_preposto.pr_dscritic
                              WHEN pc_gera_msg_preposto.pr_dscritic <> ?.
                                
                    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
                    
                    IF  aux_dscritic <> "" THEN
                        DO:
                            ASSIGN aux_cdcritic = 0.
                            
                            UNDO TRANSACAO, LEAVE TRANSACAO.
                        END.                        
                END.

            IF  aux_dsdsenha <> ""  THEN
                DO:
                    RUN sistema/generico/procedures/b1wgen0011.p PERSISTENT 
                        SET h-b1wgen0011.
        
                    IF  NOT VALID-HANDLE(h-b1wgen0011)  THEN
                        DO:
                            ASSIGN aux_cdcritic = 0
                                   aux_dscritic = "Handle invalido para BO " +
                                                  "b1wgen0011.".
                           
                            UNDO TRANSACAO, LEAVE TRANSACAO.       
                        END.                    
                                                                  
                    RUN conteudo-email (INPUT crapcop.nmrescop,
                                        INPUT crapcop.dsendweb,
                                        INPUT par_nmoperad,
                                        INPUT aux_dsdsenha,
                                       OUTPUT aux_conteudo).

                    RUN enviar_email_completo IN h-b1wgen0011 
                                             (INPUT par_cdcooper,
                                              INPUT "B1WNET0002",
                                              INPUT CAPS(crapcop.nmrescop) +
                                                    "<" + crapcop.dsdemail + ">",
                                              INPUT par_dsdemail,
                                              INPUT "Cadastramento de Operador",
                                              INPUT "",
                                              INPUT "",
                                              INPUT aux_conteudo,
                                              INPUT FALSE).
                                                                    
                    DELETE PROCEDURE h-b1wgen0011.

                END.
        END.
        
        ASSIGN aux_flgtrans = TRUE.
        
    END. /** Fim do DO TRANSACTION - TRANSACAO **/    

    IF  NOT aux_flgtrans  THEN
        DO:
            IF  aux_cdcritic = 0 AND aux_dscritic = ""  THEN
                aux_dscritic = "Nao foi possivel concluir a requisicao.".
                
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                               
            IF  par_flgerlog  THEN
                DO:
                    RUN proc_gerar_log (INPUT par_cdcooper,
                                        INPUT par_cdoperad,
                                        INPUT aux_dscritic,
                                        INPUT aux_dsorigem,
                                        INPUT aux_dstransa,
                                        INPUT FALSE,
                                        INPUT par_idseqttl,
                                        INPUT par_nmdatela,
                                        INPUT par_nrdconta,
                                       OUTPUT aux_nrdrowid).
                
                    RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                             INPUT "Operador",
                                             INPUT "",
                                             INPUT STRING(STRING(par_nrcpfope,
                                                          "99999999999"),
                                                          "xxx.xxx.xxx-xx")).
                END.
                
            RETURN "NOK".
        END.

    IF  aux_dsdsenha <> ""  THEN
        DO:
            ASSIGN aux_cdcritic = 0 
                   aux_dscritic = "A senha numerica para acesso a conta " +
                                  "on-line sera enviada para o e-mail " +
                                  "do operador.".
                
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
        END.
        
    IF  par_flgerlog  THEN
        DO:
            RUN proc_gerar_log (INPUT par_cdcooper,
                                INPUT par_cdoperad,
                                INPUT "",
                                INPUT aux_dsorigem,
                                INPUT aux_dstransa,
                                INPUT TRUE,
                                INPUT par_idseqttl,
                                INPUT par_nmdatela,
                                INPUT par_nrdconta,
                               OUTPUT aux_nrdrowid).
        
            RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                     INPUT "Operador",
                                     INPUT "",
                                     INPUT STRING(STRING(par_nrcpfope,
                                             "99999999999"),"xxx.xxx.xxx-xx")).

            IF  par_desdacao = "ALTERAR"   OR 
                par_desdacao = "CADASTRAR" THEN
            DO:
                IF  aux_nmoperad <> par_nmoperad  THEN
                    RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                             INPUT "Nome",
                                             INPUT aux_nmoperad,
                                             INPUT par_nmoperad).
                                             
                IF  aux_dsdemail <> par_dsdemail  THEN
                    RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                             INPUT "E-Mail",
                                             INPUT aux_dsdemail,
                                             INPUT par_dsdemail).
                                                                          
                IF  aux_dsdcargo <> par_dsdcargo  THEN
                    RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                             INPUT "Cargo",
                                             INPUT aux_dsdcargo,
                                             INPUT par_dsdcargo).
                                                                                   
                IF  aux_flgsitop <> par_flgsitop  THEN
                    RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                             INPUT "Situacao",
                                             INPUT STRING(aux_flgsitop,
                                                          "Liberado/Bloqueado"),
                                             INPUT STRING(par_flgsitop,
                                                          "Liberado/Bloqueado")).
                                                          
				IF par_geraflux = 1 THEN
					DO:
				IF  aux_vllbolet <> par_vllbolet  THEN
                    RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                             INPUT "Boleto/Convenio/Tributos",
                                             INPUT TRIM(STRING(aux_vllbolet,
															"zzz,zzz,zz9.99-")),
                                             INPUT TRIM(STRING(par_vllbolet,
															"zzz,zzz,zz9.99-"))).
															
				IF  aux_vllimtrf <> par_vllimtrf  THEN
                    RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                             INPUT "Transferencia",
                                             INPUT TRIM(STRING(aux_vllimtrf,
															"zzz,zzz,zz9.99-")),
                                             INPUT TRIM(STRING(par_vllimtrf,
															"zzz,zzz,zz9.99-"))).
															
				IF  aux_vllimted <> par_vllimted  THEN
                    RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                             INPUT "TED",
                                             INPUT TRIM(STRING(aux_vllimted,
															"zzz,zzz,zz9.99-")),
                                             INPUT TRIM(STRING(par_vllimted,
															"zzz,zzz,zz9.99-"))).
															
				IF  aux_vllimvrb <> par_vllimvrb  THEN
                    RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                             INPUT "VR Boleto",
                                             INPUT TRIM(STRING(aux_vllimvrb,
															"zzz,zzz,zz9.99-")),
                                             INPUT TRIM(STRING(par_vllimvrb,
															"zzz,zzz,zz9.99-"))).
															
				IF  aux_vllimflp <> par_vllimflp  THEN
                    RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                             INPUT "Folha de Pagamento",
                                             INPUT TRIM(STRING(aux_vllimflp,
															"zzz,zzz,zz9.99-")),
                                             INPUT TRIM(STRING(par_vllimflp,
															"zzz,zzz,zz9.99-"))).
				END.
                                                          
                FOR EACH tt-itens-menu NO-LOCK:
            
                    IF  tt-itens-menu.flcreate  THEN
                        ASSIGN aux_desacebl = "".
                    ELSE
                        ASSIGN aux_desacebl = IF  tt-itens-menu.flgacebl  THEN
                                                  "Bloqueado"
                                              ELSE
                                                  "Liberado".
                                                  
                    RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                             INPUT "Item de Menu (" + 
                                                   STRING(tt-itens-menu.cditemmn) +
                                                   "," +
                                                   STRING(tt-itens-menu.cdsubitm) +
                                                   ")",
                                             INPUT aux_desacebl,
                                             INPUT STRING(tt-itens-menu.flgacebl,
                                                          "Liberado/Bloqueado")).
                END. /** Fim do FOR EACH tt-itens-menu **/
            END.
            ELSE
            IF  par_desdacao = "GERARNOVASENHA" THEN
            DO:
                RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                         INPUT "Gerar Nova Senha",
                                         INPUT "",
                                         INPUT "").
            END.
            
        END.
             
    RETURN "OK".
               
END PROCEDURE.

/* Gerar uma nova senha numerica para o operador e enviar por e-mail */
PROCEDURE gerar_nova_senha:

    DEFINE INPUT  PARAMETER par_cdcooper AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrdconta AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_idseqttl AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrcpfope AS DECIMAL     NO-UNDO.

    DEFINE OUTPUT PARAMETER par_dsdsenha AS CHARACTER   NO-UNDO.
    DEFINE OUTPUT PARAMETER par_cdcritic AS INTEGER     NO-UNDO.
    DEFINE OUTPUT PARAMETER par_dscritic AS CHARACTER   NO-UNDO.

    DEFINE VARIABLE aux_dsdsenha AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE aux_conteudo AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE h-b1wgen0011 AS HANDLE      NO-UNDO.
    DEFINE VARIABLE aux_contador AS INTEGER     NO-UNDO.
    DEFINE VARIABLE aux_flexiste AS LOGICAL     NO-UNDO.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".

    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.
   
    IF  NOT AVAILABLE crapcop  THEN
    DO:
        ASSIGN par_cdcritic = 651 
               par_dscritic = "".
            
        RETURN "NOK".
    END.

    DO aux_contador = 1 TO 10:
    
        ASSIGN par_cdcritic = 0
               par_dscritic = "".
    
        FIND crapopi WHERE crapopi.cdcooper = par_cdcooper AND
                           crapopi.nrdconta = par_nrdconta AND
                           crapopi.nrcpfope = par_nrcpfope 
                           EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
    
        IF  NOT AVAILABLE crapopi  THEN
            DO:
                IF  LOCKED crapopi  THEN
                    DO:
                        par_dscritic = "Registro do operador esta" +
                                       " sendo alterado. Tente " +
                                       "novamente.".
                        PAUSE 1 NO-MESSAGE.
                        NEXT.
                    END.
                ELSE
                    par_dscritic = "Operador nao cadastrado ou " +
                                   "bloqueado.".
            END.
        
        LEAVE.
    
    END. /** Fim do DO .. TO **/
    
    IF  par_dscritic <> ""  THEN
        RETURN "NOK".

    IF  NOT crapopi.flgsitop  THEN
    DO:
        ASSIGN par_dscritic = "Situacao do operador deve estar como Liberada".        
        RETURN "NOK".
    END.

    RUN sistema/generico/procedures/b1wgen0011.p PERSISTENT 
        SET h-b1wgen0011.

    IF  NOT VALID-HANDLE(h-b1wgen0011)  THEN
        DO:
            ASSIGN par_cdcritic = 0
                   par_dscritic = "Handle invalido para BO " +
                                  "b1wgen0011.".

            RETURN "NOK".
        END.

    /* gerar uma nova senha diferente das existentes em craphsh. */
    DO aux_contador = 1 TO 10:
       
        RUN gerar-senha (OUTPUT aux_dsdsenha).
       
        RUN validar-senha-hsh (INPUT par_cdcooper,
                               INPUT par_nrdconta,
                               INPUT par_idseqttl,
                               INPUT par_nrcpfope,
                               INPUT aux_dsdsenha,
                               INPUT "",
                               INPUT 0, /* valida senha numerica*/
                              OUTPUT aux_dscritic).

        IF  RETURN-VALUE = "OK" THEN
            LEAVE.
    END.
     
    IF  aux_dscritic <> "" THEN
        RETURN "NOK".
    
    RUN cadastrar-senha-hsh (INPUT par_cdcooper,
                             INPUT par_nrdconta,
                             INPUT par_idseqttl,
                             INPUT par_nrcpfope,
                             INPUT aux_dsdsenha,
                             INPUT "",
                             INPUT 1,
                            OUTPUT aux_dscritic).

    IF  RETURN-VALUE <> "OK" THEN
    DO:
         ASSIGN par_cdcritic = 0
                par_dscritic = "Problema ao cadastrar senha no historico " +
                               "de senhas.".
         RETURN "NOK".
    END.

    ASSIGN crapopi.dsdsenha = ENCODE(aux_dsdsenha)
           crapopi.dsdfrase = ""
           crapopi.dtblutsh = ?
           crapopi.dtlibera = aux_datdodia
           crapopi.dtultalt = aux_datdodia
           crapopi.dtaltsnh = aux_datdodia.

    RUN conteudo-email (INPUT crapcop.nmrescop,
                        INPUT crapcop.dsendweb,
                        INPUT crapopi.nmoperad,
                        INPUT aux_dsdsenha,
                       OUTPUT aux_conteudo).

    RUN enviar_email_completo IN h-b1wgen0011 
                             (INPUT par_cdcooper,
                              INPUT "B1WNET0002",
                              INPUT CAPS(crapcop.nmrescop) +
                                    "<" + crapcop.dsdemail + ">",
                              INPUT crapopi.dsdemail,
                              INPUT "Nova senha de acesso a conta-online",
                              INPUT "",
                              INPUT "",
                              INPUT aux_conteudo,
                              INPUT FALSE).

    DELETE PROCEDURE h-b1wgen0011.

    RETURN "OK".
END.


/******************************************************************************/
/**             Procedure para atualizar ultimo acesso a conta               **/
/******************************************************************************/
PROCEDURE verifica-acesso.

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrcpfope LIKE crapopi.nrcpfope             NO-UNDO.
    DEF  INPUT PARAM par_nripuser AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dsorigip AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_flmobile AS LOGI                           NO-UNDO.
            
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-acesso.

    DEF VAR aux_contador AS INTE                                    NO-UNDO.
    DEF VAR aux_qtdiauso AS INTE                                    NO-UNDO.
    DEF VAR aux_qtdiaalt AS INTE                                    NO-UNDO.
    DEF VAR aux_qtdiablq AS INTE                                    NO-UNDO.    

    DEF VAR aux_flgtrans AS LOGI                                    NO-UNDO.

    DEF VAR aux_dscidori AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsuforig AS CHAR                                    NO-UNDO.
    DEF VAR aux_dspaisor AS CHAR                                    NO-UNDO.

    DEF VAR aux_dtaltsnh AS DATE                                    NO-UNDO.
    
    DEF VAR aux_nrcpfcgc AS DECI                                    NO-UNDO.
    DEF VAR aux_nmprimtl AS CHAR                                    NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-acesso.
    
    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Efetuado login de acesso a conta on-line." 
           aux_cdcritic = 0
           aux_dscritic = ""
           aux_flgtrans = FALSE.

    IF  par_flgerlog  THEN
        RUN formata-dados-origem-ip (INPUT par_dsorigip,
                                    OUTPUT aux_dscidori,
                                    OUTPUT aux_dsuforig,
                                    OUTPUT aux_dspaisor).

    FIND FIRST crapass WHERE crapass.cdcooper = par_cdcooper AND
                             crapass.nrdconta = par_nrdconta
                             NO-LOCK NO-ERROR.

    TRANSACAO:

    DO TRANSACTION ON ERROR UNDO TRANSACAO, LEAVE TRANSACAO:
    
        DO aux_contador = 1 TO 10:
            
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "".
        
            IF  par_nrcpfope = 0  THEN
                DO:
                    FIND crapsnh WHERE crapsnh.cdcooper = par_cdcooper AND
                                       crapsnh.nrdconta = par_nrdconta AND
                                       crapsnh.idseqttl = par_idseqttl AND
                     /** Internet **/  crapsnh.tpdsenha = 1            AND 
                     /** Ativo    **/  crapsnh.cdsitsnh = 1  
                                       EXCLUSIVE-LOCK NO-WAIT NO-ERROR.
                       
                    IF  NOT AVAILABLE crapsnh  THEN
                        DO:
                            IF  LOCKED crapsnh  THEN
                                DO:
                                    aux_dscritic = "Nao foi possivel acessar " +
                                                   "a conta. Tente novamente.".
                                    PAUSE 1 NO-MESSAGE.
                                    NEXT.
                                END.
                            ELSE
                                aux_dscritic = "Registro de senha nao " +
                                               "cadastrado ou bloqueado.".
                        END.
                END.
            ELSE
                DO:
                    FIND crapopi WHERE crapopi.cdcooper = par_cdcooper AND
                                       crapopi.nrdconta = par_nrdconta AND
                                       crapopi.nrcpfope = par_nrcpfope AND
                      /** Liberado **/ crapopi.flgsitop = TRUE
                                       EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                    IF  NOT AVAILABLE crapopi  THEN
                        DO:
                            IF  LOCKED crapopi  THEN
                                DO:
                                    aux_dscritic = "Registro do operador esta" +
                                                   " sendo alterado. Tente " +
                                                   "novamente.".
                                    PAUSE 1 NO-MESSAGE.
                                    NEXT.
                                END.
                            ELSE
                                aux_dscritic = "Operador nao cadastrado ou " +
                                               "bloqueado.".
                        END.
                END.    
                          
            LEAVE.
        
        END. /** Fim do DO .. TO **/
    
        IF  aux_dscritic <> ""  THEN
            UNDO TRANSACAO, LEAVE TRANSACAO.
        
        CREATE tt-acesso.
        
        IF  par_nrcpfope = 0  THEN
            DO:
                IF  crapass.idastcjt = 1 THEN 
                    DO:
                        /* Buscar dados do responsavel legal */
                        { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
                      
                        RUN STORED-PROCEDURE pc_verifica_validade_procurac
                            aux_handproc = PROC-HANDLE NO-ERROR
                                          (INPUT par_cdcooper,     /* Codigo da Cooperativa */
                                           INPUT par_nrdconta,     /* Numero da Conta */
                                           INPUT crapass.inpessoa, /* PF/PJ*/
                                           INPUT par_idseqttl,     /* Sequencia Titularidade */
                                           INPUT crapsnh.nrcpfcgc, /* CPF procurador */                                            
                                          OUTPUT 0,                /* Cód. da crítica */
                                          OUTPUT "").              /* Descricao da critica */
                        
                        CLOSE STORED-PROC pc_verifica_validade_procurac
                              aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
                      
                        { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
                       
                        ASSIGN aux_cdcritic = 0
                               aux_dscritic = ""
                               aux_cdcritic = pc_verifica_validade_procurac.pr_cdcritic
                                              WHEN pc_verifica_validade_procurac.pr_cdcritic <> ?
                               aux_dscritic = pc_verifica_validade_procurac.pr_dscritic
                                              WHEN pc_verifica_validade_procurac.pr_dscritic <> ?.
                           
                        IF  aux_cdcritic <> 0   OR 
                            aux_dscritic <> ""  THEN
                            UNDO TRANSACAO, LEAVE TRANSACAO.
                    END.
    
                IF  NOT par_flmobile THEN /* Conta Online */
				    DO:
                ASSIGN tt-acesso.dtaltsnh = crapsnh.dtaltsnh
                       tt-acesso.flgsenha = FALSE
                       tt-acesso.dtultace = crapsnh.dtultace
                       tt-acesso.hrultace = crapsnh.hrultace.
                       
                        ASSIGN crapsnh.dtaibant = crapsnh.dtultace
                               crapsnh.hraibant = crapsnh.hrultace
                               crapsnh.dtultace = aux_datdodia
                           crapsnh.hrultace = TIME.
            END.
                ELSE /* Cecred Mobile */
				    DO:
					    ASSIGN tt-acesso.dtaltsnh = crapsnh.dtaltsnh
                               tt-acesso.flgsenha = FALSE
                               tt-acesso.dtultace = crapsnh.dtacemob
                               tt-acesso.hrultace = crapsnh.hracemob.
							   
                        ASSIGN crapsnh.dtambant = crapsnh.dtacemob
                               crapsnh.hrambant = crapsnh.hracemob
                               crapsnh.dtacemob = aux_datdodia
                               crapsnh.hracemob = TIME.
				    END.
            END.
        ELSE
            ASSIGN tt-acesso.dtaltsnh = crapopi.dtaltsnh
                   tt-acesso.flgsenha = FALSE
                   tt-acesso.dtultace = crapopi.dtultace
                   tt-acesso.hrultace = crapopi.hrultace
                   crapopi.dtaibant   = crapopi.dtultace
                   crapopi.hraibant   = crapopi.hrultace
                   crapopi.dtultace   = aux_datdodia
                   crapopi.hrultace   = TIME.
        
        IF  crapass.inpessoa = 1  THEN
            FIND craptab WHERE craptab.cdcooper = par_cdcooper AND
                               craptab.nmsistem = "CRED"       AND
                               craptab.tptabela = "GENERI"     AND
                               craptab.cdempres = 0            AND
                               craptab.cdacesso = "LIMINTERNT" AND
                               craptab.tpregist = 1   
                               NO-LOCK NO-ERROR.
        ELSE
            FIND craptab WHERE craptab.cdcooper = par_cdcooper AND
                               craptab.nmsistem = "CRED"       AND
                               craptab.tptabela = "GENERI"     AND
                               craptab.cdempres = 0            AND
                               craptab.cdacesso = "LIMINTERNT" AND
                               craptab.tpregist = 2   
                               NO-LOCK NO-ERROR.

        IF  NOT AVAIL craptab  THEN
            DO:
                aux_dscritic = "Registro LIMINTERNT nao encontrado.".
                UNDO TRANSACAO, LEAVE TRANSACAO.
            END.
        
        ASSIGN aux_qtdiauso = INTEGER(ENTRY(17,craptab.dstextab,";"))
               aux_qtdiaalt = INTEGER(ENTRY(18,craptab.dstextab,";"))
               aux_qtdiablq = INTEGER(ENTRY(19,craptab.dstextab,";"))
               aux_dtaltsnh = IF par_nrcpfope = 0 THEN
                                 crapsnh.dtaltsnh
                              ELSE
                                 crapopi.dtaltsnh.
        
        ASSIGN  tt-acesso.qtdiams1 = aux_datdodia - aux_dtaltsnh
                tt-acesso.qtdiams2 = (aux_dtaltsnh + aux_qtdiauso + 
                                      aux_qtdiaalt) - aux_datdodia.
        
        IF  (aux_dtaltsnh + aux_qtdiauso + aux_qtdiaalt) <= aux_datdodia   THEN
            ASSIGN tt-acesso.qtdiams2 = (aux_dtaltsnh + aux_qtdiauso + 
                                         aux_qtdiaalt + aux_qtdiablq) - 
                                         aux_datdodia. 
        
        ASSIGN tt-acesso.cdblqsnh = 0.

        ASSIGN aux_flgtrans = TRUE.
        
    END. /** Fim do DO TRANSACTION - TRANSACAO **/
    
    
    IF  NOT aux_flgtrans  THEN
        DO:
            IF  aux_cdcritic = 0 AND aux_dscritic = ""  THEN
                aux_dscritic = "Nao foi possivel concluir a requisicao.".
                
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                               
            IF  par_flgerlog  THEN
                DO:
                    RUN proc_gerar_log (INPUT par_cdcooper,
                                        INPUT par_cdoperad,
                                        INPUT aux_dscritic,
                                        INPUT aux_dsorigem,
                                        INPUT aux_dstransa,
                                        INPUT FALSE,
                                        INPUT par_idseqttl,
                                        INPUT par_nmdatela,
                                        INPUT par_nrdconta,
                                       OUTPUT aux_nrdrowid).

                    RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                             INPUT "Origem",
                                             INPUT "",
                                             INPUT STRING(par_flmobile,"MOBILE/INTERNETBANK")).
                
                    IF  par_nrcpfope > 0  THEN
                        RUN proc_gerar_log_item 
                                          (INPUT aux_nrdrowid,
                                           INPUT "Operador",
                                           INPUT "",
                                           INPUT STRING(STRING(par_nrcpfope,
                                                        "99999999999"),
                                                        "xxx.xxx.xxx-xx")).
                    
                    RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                             INPUT "IP",
                                             INPUT "",
                                             INPUT par_nripuser).

                    IF  aux_dscidori <> ""  THEN
                        RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                                 INPUT "Cidade IP",
                                                 INPUT "",
                                                 INPUT aux_dscidori).

                    IF  aux_dsuforig <> ""  THEN
                        RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                                 INPUT "Estado IP",
                                                 INPUT "",
                                                 INPUT aux_dsuforig).

                    IF  aux_dspaisor <> ""  THEN
                        RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                                 INPUT "Pais IP",
                                                 INPUT "",
                                                 INPUT aux_dspaisor).
                END.
                
            RETURN "NOK".
        END.
       

    IF  par_flgerlog  THEN
        DO:
            RUN proc_gerar_log (INPUT par_cdcooper,
                                INPUT par_cdoperad,
                                INPUT "",
                                INPUT aux_dsorigem,
                                INPUT aux_dstransa,
                                INPUT TRUE,
                                INPUT par_idseqttl,
                                INPUT par_nmdatela,
                                INPUT par_nrdconta,
                               OUTPUT aux_nrdrowid).

            RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                     INPUT "Origem",
                                     INPUT "",
                                     INPUT STRING(par_flmobile,"MOBILE/INTERNETBANK")).

            IF  par_nrcpfope > 0  THEN
                RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                         INPUT "Operador",
                                         INPUT "",
                                         INPUT STRING(STRING(par_nrcpfope,
                                                      "99999999999"),
                                                      "xxx.xxx.xxx-xx")).

            RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                     INPUT "IP",
                                     INPUT "",
                                     INPUT par_nripuser).

            IF  aux_dscidori <> ""  THEN
                RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                         INPUT "Cidade IP",
                                         INPUT "",
                                         INPUT aux_dscidori).

            IF  aux_dsuforig <> ""  THEN
                RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                         INPUT "Estado IP",
                                         INPUT "",
                                         INPUT aux_dsuforig).

            IF  aux_dspaisor <> ""  THEN
                RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                         INPUT "Pais IP",
                                         INPUT "",
                                         INPUT aux_dspaisor).

            IF crapass.inpessoa > 1 THEN
            DO:
              /* Buscar dados do responsavel legal */
              { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }
              RUN STORED-PROCEDURE pc_verifica_rep_assinatura
                  aux_handproc = PROC-HANDLE NO-ERROR
                                (INPUT par_cdcooper, /* Codigo da Cooperativa */
                                 INPUT par_nrdconta, /* Numero da Conta */
                                 INPUT par_idseqttl, /* Sequencia Titularidade */
                                 INPUT par_idorigem, /* Codigo Origem */
                                OUTPUT 0,            /* Flag de Assinatura Multipla pr_idastcjt */
                                OUTPUT 0,            /* Numero do CPF pr_nrcpfcgc */
                                OUTPUT "",           /* Nome do Representante/Procurador pr_nmprimtl */
                                OUTPUT 0,            /* Flag de Preposto Cartao Mag. pr_flcartma */
                                OUTPUT 0,            /* Codigo da critica */
                                OUTPUT "").          /* Descricao da critica */
              
              CLOSE STORED-PROC pc_verifica_rep_assinatura
                    aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
            
              { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }
              
              ASSIGN aux_nrcpfcgc = 0
                     aux_nmprimtl = ""
                     aux_cdcritic = 0
                     aux_dscritic = ""
                     aux_nrcpfcgc = pc_verifica_rep_assinatura.pr_nrcpfcgc 
                                    WHEN pc_verifica_rep_assinatura.pr_nrcpfcgc <> ?
                     aux_nmprimtl = pc_verifica_rep_assinatura.pr_nmprimtl 
                                    WHEN pc_verifica_rep_assinatura.pr_nmprimtl <> ?
                     aux_cdcritic = pc_verifica_rep_assinatura.pr_cdcritic 
                                    WHEN pc_verifica_rep_assinatura.pr_cdcritic <> ?
                     aux_dscritic = pc_verifica_rep_assinatura.pr_dscritic
                                    WHEN pc_verifica_rep_assinatura.pr_dscritic <> ?.
              
              IF aux_cdcritic <> 0   OR
                 aux_dscritic <> ""  THEN
              DO:
                   IF aux_dscritic = "" THEN
                      DO:
                         FIND crapcri WHERE crapcri.cdcritic = aux_cdcritic
                                            NO-LOCK NO-ERROR.
              
                         IF AVAIL crapcri THEN
                            ASSIGN aux_dscritic = crapcri.dscritic.
              
                      END.
                     
                      RUN gera_erro (INPUT par_cdcooper,
                                     INPUT par_cdagenci,
                                     INPUT par_nrdcaixa,
                                     INPUT 1,            /** Sequencia **/
                                     INPUT aux_cdcritic,
                                     INPUT-OUTPUT aux_dscritic).
                   RETURN "NOK".
                                  
              END.
              
              /* Gerar o log com CPF do Rep./Proc. */
              IF  aux_nrcpfcgc > 0 THEN
                  RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                          INPUT "CPF Representate/Procurador" ,
                                          INPUT "",
                                          INPUT STRING(STRING(aux_nrcpfcgc,
                                                  "99999999999"),"xxx.xxx.xxx-xx")).
              
              /* Gerar o log com Nome do Rep./Proc. */                                
              IF  aux_nmprimtl <> ""   THEN
                  RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                          INPUT "Nome Representate/Procurador" ,
                                          INPUT "",
                                          INPUT aux_nmprimtl).
                                      
              /* FIM Buscar dados responsavel legal */
            END.
        END.
                                                         
    RETURN "OK".
    
END PROCEDURE.

/******************************************************************************/
/**             Procedure para dados do acesso anterior a conta              **/
/******************************************************************************/
PROCEDURE obtem-acesso-anterior.

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrcpfope LIKE crapopi.nrcpfope             NO-UNDO.    
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_flmobile AS LOGI                           NO-UNDO.
            
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-acesso.

    DEF VAR aux_contador AS INTE                                    NO-UNDO.
    DEF VAR aux_qtdiauso AS INTE                                    NO-UNDO.
    DEF VAR aux_qtdiaalt AS INTE                                    NO-UNDO.
    DEF VAR aux_qtdiablq AS INTE                                    NO-UNDO.    

    DEF VAR aux_flgtrans AS LOGI                                    NO-UNDO.

    DEF VAR aux_dscidori AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsuforig AS CHAR                                    NO-UNDO.
    DEF VAR aux_dspaisor AS CHAR                                    NO-UNDO.

    DEF VAR aux_dtaltsnh AS DATE                                    NO-UNDO.
    
    DEF VAR aux_nrcpfcgc AS DECI                                    NO-UNDO.
    DEF VAR aux_nmprimtl AS CHAR                                    NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-acesso.
    
    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))           
           aux_cdcritic = 0
           aux_dscritic = ""
           aux_flgtrans = FALSE.
           
    IF  par_flmobile  THEN
        ASSIGN aux_dstransa = "Consulta data do acesso anterior ao AILOS Mobile".
    ELSE
        ASSIGN aux_dstransa = "Consulta data do acesso anterior a Conta On-Line".    

    DO WHILE TRUE:
    
      FOR FIRST crapass WHERE crapass.cdcooper = par_cdcooper AND
                              crapass.nrdconta = par_nrdconta 
                              NO-LOCK. END.
                              
      IF  NOT AVAILABLE crapass  THEN
          DO:
              ASSIGN aux_dscritic = "Associado nao cadastrado.".
              LEAVE.     
          END.                                     
        
      IF  par_nrcpfope = 0  THEN
          DO:
              FOR FIRST crapsnh WHERE crapsnh.cdcooper = par_cdcooper AND
                                      crapsnh.nrdconta = par_nrdconta AND
                                      crapsnh.idseqttl = par_idseqttl AND
                    /** Internet **/  crapsnh.tpdsenha = 1            AND 
                    /** Ativo    **/  crapsnh.cdsitsnh = 1     
                                      NO-LOCK. END.
                 
              IF  NOT AVAILABLE crapsnh  THEN
                  DO:
                      ASSIGN aux_dscritic = "Registro de senha nao " +
                                            "cadastrado ou bloqueado.".
                      LEAVE.     
                  END.
          END.
      ELSE
          DO:
              FOR FIRST crapopi WHERE crapopi.cdcooper = par_cdcooper AND
                                      crapopi.nrdconta = par_nrdconta AND
                                      crapopi.nrcpfope = par_nrcpfope AND
                     /** Liberado **/ crapopi.flgsitop = TRUE
                                      NO-LOCK. END.

              IF  NOT AVAILABLE crapopi  THEN
                  DO:
                      ASSIGN aux_dscritic = "Operador nao cadastrado ou " +
                                            "bloqueado.".
                      LEAVE. 
                  END.
          END.    
                    
      CREATE tt-acesso.
        
      IF  par_nrcpfope = 0  THEN
          DO:                
              IF  NOT par_flmobile THEN /* Conta Online */
                  DO:
                      ASSIGN tt-acesso.dtultace = crapsnh.dtaibant
                             tt-acesso.hrultace = crapsnh.hraibant.
                  END.
              ELSE /* Cecred Mobile */
                  DO:
                      ASSIGN tt-acesso.dtultace = crapsnh.dtambant
                             tt-acesso.hrultace = crapsnh.hrambant.
                  END.
          END.
      ELSE
          ASSIGN tt-acesso.dtultace = crapopi.dtaibant
                 tt-acesso.hrultace = crapopi.hraibant.

      ASSIGN aux_flgtrans = TRUE.
      
      LEAVE.
      
    END. /** Fim do DO WHILE TRUE - CONSULTA **/    
    
    IF  NOT aux_flgtrans  THEN
        DO:
            IF  aux_cdcritic = 0 AND aux_dscritic = ""  THEN
                aux_dscritic = "Nao foi possivel concluir a requisicao.".
                
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                               
            IF  par_flgerlog  THEN
                DO:
                    RUN proc_gerar_log (INPUT par_cdcooper,
                                        INPUT par_cdoperad,
                                        INPUT aux_dscritic,
                                        INPUT aux_dsorigem,
                                        INPUT aux_dstransa,
                                        INPUT FALSE,
                                        INPUT par_idseqttl,
                                        INPUT par_nmdatela,
                                        INPUT par_nrdconta,
                                       OUTPUT aux_nrdrowid).

                    RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                             INPUT "Origem",
                                             INPUT "",
                                             INPUT STRING(par_flmobile,"MOBILE/INTERNETBANK")).
                
                    IF  par_nrcpfope > 0  THEN
                        RUN proc_gerar_log_item 
                                          (INPUT aux_nrdrowid,
                                           INPUT "Operador",
                                           INPUT "",
                                           INPUT STRING(STRING(par_nrcpfope,
                                                        "99999999999"),
                                                        "xxx.xxx.xxx-xx")).                   
                END.
                
            RETURN "NOK".
        END.

    IF  par_flgerlog  THEN
        DO:
            RUN proc_gerar_log (INPUT par_cdcooper,
                                INPUT par_cdoperad,
                                INPUT "",
                                INPUT aux_dsorigem,
                                INPUT aux_dstransa,
                                INPUT TRUE,
                                INPUT par_idseqttl,
                                INPUT par_nmdatela,
                                INPUT par_nrdconta,
                               OUTPUT aux_nrdrowid).

            RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                     INPUT "Origem",
                                     INPUT "",
                                     INPUT STRING(par_flmobile,"MOBILE/INTERNETBANK")).

            IF  par_nrcpfope > 0  THEN
                RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                         INPUT "Operador",
                                         INPUT "",
                                         INPUT STRING(STRING(par_nrcpfope,
                                                      "99999999999"),
                                                      "xxx.xxx.xxx-xx")).
            
            IF  crapass.inpessoa > 1  THEN
                DO:
                    /* Buscar dados do responsavel legal */
                    { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }
                    RUN STORED-PROCEDURE pc_verifica_rep_assinatura
                        aux_handproc = PROC-HANDLE NO-ERROR
                                      (INPUT par_cdcooper, /* Codigo da Cooperativa */
                                       INPUT par_nrdconta, /* Numero da Conta */
                                       INPUT par_idseqttl, /* Sequencia Titularidade */
                                       INPUT par_idorigem, /* Codigo Origem */
                                      OUTPUT 0,            /* Flag de Assinatura Multipla pr_idastcjt */
                                      OUTPUT 0,            /* Numero do CPF pr_nrcpfcgc */
                                      OUTPUT "",           /* Nome do Representante/Procurador pr_nmprimtl */
                                      OUTPUT 0,            /* Flag de Preposto Cartao Mag. pr_flcartma */
                                      OUTPUT 0,            /* Codigo da critica */
                                      OUTPUT "").          /* Descricao da critica */
                    
                    CLOSE STORED-PROC pc_verifica_rep_assinatura
                          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
                  
                    { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }
                    
                    ASSIGN aux_nrcpfcgc = 0
                           aux_nmprimtl = ""
                           aux_cdcritic = 0
                           aux_dscritic = ""
                           aux_nrcpfcgc = pc_verifica_rep_assinatura.pr_nrcpfcgc 
                                          WHEN pc_verifica_rep_assinatura.pr_nrcpfcgc <> ?
                           aux_nmprimtl = pc_verifica_rep_assinatura.pr_nmprimtl 
                                          WHEN pc_verifica_rep_assinatura.pr_nmprimtl <> ?
                           aux_cdcritic = pc_verifica_rep_assinatura.pr_cdcritic 
                                          WHEN pc_verifica_rep_assinatura.pr_cdcritic <> ?
                           aux_dscritic = pc_verifica_rep_assinatura.pr_dscritic
                                          WHEN pc_verifica_rep_assinatura.pr_dscritic <> ?.                    
                    
                    /* Gerar o log com CPF do Rep./Proc. */
                    IF  aux_nrcpfcgc > 0 THEN
                        RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                                INPUT "CPF Representate/Procurador" ,
                                                INPUT "",
                                                INPUT STRING(STRING(aux_nrcpfcgc,
                                                        "99999999999"),"xxx.xxx.xxx-xx")).
                    
                    /* Gerar o log com Nome do Rep./Proc. */                                
                    IF  aux_nmprimtl <> ""   THEN
                        RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                                INPUT "Nome Representate/Procurador" ,
                                                INPUT "",
                                                INPUT aux_nmprimtl).                    
                END.
        END.
                                                         
    RETURN "OK".
    
END PROCEDURE.

/******************************************************************************/
/**            Procedure para gerenciar senha para acesso a conta            **/
/******************************************************************************/
PROCEDURE gerencia-senha.

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrcpfope LIKE crapopi.nrcpfope             NO-UNDO.
    DEF  INPUT PARAM par_cddsenha AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdsennew AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdsenrep AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dssenweb AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dssennew AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dssenrep AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_vldfrase AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_inbloque AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nripuser AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dsorigip AS CHAR                           NO-UNDO.
	DEF  INPUT PARAM par_flmobile AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
        
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_flgtrans AS LOGI                                    NO-UNDO.
    DEF VAR aux_flgfirst AS LOGI                                    NO-UNDO.
    DEF VAR aux_flexiste AS LOGI                                    NO-UNDO.

    DEF VAR aux_contador AS INTE                                    NO-UNDO.

    DEF VAR aux_dscidori AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsuforig AS CHAR                                    NO-UNDO.
    DEF VAR aux_dspaisor AS CHAR                                    NO-UNDO.
    
    DEF VAR aux_nrcpfcgc AS DECI                                    NO-UNDO.
    DEF VAR aux_nmprimtl AS CHAR                                    NO-UNDO.
    
    /**********************************************************************/
    /**    par_vldfrase = 0 --> VALIDA SENHA NUMERICA                    **/
    /**    par_vldfrase = 1 --> VALIDA SENHA NUMERICA E FRASE SECRETA    **/
    /**********************************************************************/
    
    EMPTY TEMP-TABLE tt-erro.
    
    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = IF  par_vldfrase = 0  THEN
                              "Cadastrar frase secreta para acesso a conta " +
                              "on-line"
                          ELSE
                              "Alterar senha e frase secreta para acesso a " +
                              "conta on-line"
           aux_cdcritic = 0
           aux_dscritic = ""
           aux_flgtrans = FALSE.

    FOR FIRST crapass WHERE crapass.cdcooper = par_cdcooper 
                        AND crapass.nrdconta = par_nrdconta
                         NO-LOCK. END.
    IF  NOT AVAIL crapass THEN
      DO:
          ASSIGN aux_cdcritic = 9.
          RUN gera_erro (INPUT par_cdcooper,
                         INPUT par_cdagenci,
                         INPUT par_nrdcaixa,
                         INPUT 1,            /** Sequencia **/
                         INPUT aux_cdcritic,
                         INPUT-OUTPUT aux_dscritic).
          RETURN "NOK".
    END.

    IF  par_inbloque = 1  THEN
        RUN formata-dados-origem-ip (INPUT par_dsorigip,
                                    OUTPUT aux_dscidori,
                                    OUTPUT aux_dsuforig,
                                    OUTPUT aux_dspaisor).
    
    RUN confirma-senha (INPUT par_cdcooper,
                        INPUT par_nrdconta,
                        INPUT par_idseqttl,
                        INPUT par_nrcpfope,
                        INPUT par_cddsenha,
                        INPUT-OUTPUT par_cdsennew,
                        INPUT par_cdsenrep,
                        INPUT par_dssenweb,
                        INPUT par_dssennew,
                        INPUT par_dssenrep,
                        INPUT "",
                        INPUT FALSE,
                        INPUT TRUE,
                        INPUT par_vldfrase,
                        INPUT par_inbloque,
                        INPUT par_nripuser,
                        INPUT aux_dscidori,
                        INPUT aux_dsuforig,
                        INPUT aux_dspaisor,
                       OUTPUT aux_dscritic).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            ASSIGN aux_cdcritic = 0.

            IF  aux_dscritic = ""  THEN
                ASSIGN aux_dscritic = "Nao foi possivel concluir a requisicao.".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                                   
            IF  par_flgerlog  THEN
                DO:
                    RUN proc_gerar_log (INPUT par_cdcooper,
                                        INPUT par_cdoperad,
                                        INPUT aux_dscritic,
                                        INPUT aux_dsorigem,
                                        INPUT aux_dstransa,
                                        INPUT FALSE,
                                        INPUT par_idseqttl,
                                        INPUT par_nmdatela,
                                        INPUT par_nrdconta,
                                       OUTPUT aux_nrdrowid).        
                
					RUN proc_gerar_log_item
                                  (INPUT aux_nrdrowid,
                                   INPUT "Origem",
                                   INPUT "",
                                   INPUT STRING(par_flmobile,"MOBILE/INTERNETBANK")).
                
                    IF  par_nrcpfope > 0  THEN
                        RUN proc_gerar_log_item 
                                          (INPUT aux_nrdrowid,
                                           INPUT "Operador",
                                           INPUT "",
                                           INPUT STRING(STRING(par_nrcpfope,
                                                        "99999999999"),
                                                        "xxx.xxx.xxx-xx")).

                    RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                             INPUT "IP",
                                             INPUT "",
                                             INPUT par_nripuser).

                    IF  aux_dscidori <> ""  THEN
                        RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                                 INPUT "Cidade IP",
                                                 INPUT "",
                                                 INPUT aux_dscidori).

                    IF  aux_dsuforig <> ""  THEN
                        RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                                 INPUT "Estado IP",
                                                 INPUT "",
                                                 INPUT aux_dsuforig).

                    IF  aux_dspaisor <> ""  THEN
                        RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                                 INPUT "Pais IP",
                                                 INPUT "",
                                                 INPUT aux_dspaisor).
                END.
                
            RETURN "NOK".
        END.
    
    TRANSACAO:
    
    DO TRANSACTION ON ERROR UNDO TRANSACAO, LEAVE TRANSACAO:
    
        DO aux_contador = 1 TO 10:
        
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "".
               
            IF  par_nrcpfope = 0  THEN
                DO:
                    FIND crapsnh WHERE crapsnh.cdcooper = par_cdcooper AND
                                       crapsnh.nrdconta = par_nrdconta AND
                                       crapsnh.idseqttl = par_idseqttl AND
                                       crapsnh.tpdsenha = 1            AND
                                       crapsnh.cdsitsnh = 1
                                       EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                    IF  NOT AVAILABLE crapsnh  THEN
                        DO:
                            IF  LOCKED crapsnh  THEN
                                DO:
                                    aux_dscritic = "Registro de senha esta " +
                                                   "sendo alterado. Tente " +
                                                   "novamente.".
                                    PAUSE 1 NO-MESSAGE.
                                    NEXT.
                                END.
                            ELSE
                                aux_dscritic = "Registro de senha nao " +
                                               "cadastrado ou bloqueado.".
                        END.
                END.
            ELSE
                DO:
                    FIND crapopi WHERE crapopi.cdcooper = par_cdcooper AND
                                       crapopi.nrdconta = par_nrdconta AND
                                       crapopi.nrcpfope = par_nrcpfope AND
                                       crapopi.flgsitop = TRUE
                                       EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                    IF  NOT AVAILABLE crapopi  THEN
                        DO:
                            IF  LOCKED crapopi  THEN
                                DO:
                                    aux_dscritic = "Registro do operador esta" +
                                                   " sendo alterado. Tente " +
                                                   "novamente.".
                                    PAUSE 1 NO-MESSAGE.
                                    NEXT.
                                END.
                            ELSE
                                aux_dscritic = "Operador nao cadastrado ou " +
                                               "bloqueado.".
                        END.
                END.
                
            LEAVE.
            
        END. /** Fim do DO ... TO **/

        IF  aux_dscritic <> ""  THEN
            UNDO TRANSACAO, LEAVE TRANSACAO.

        RUN validar-senha-hsh (INPUT par_cdcooper,
                               INPUT par_nrdconta,
                               INPUT par_idseqttl,
                               INPUT par_nrcpfope,
                               INPUT par_cdsennew,
                               INPUT par_dssennew,
                               INPUT IF par_vldfrase = 0 THEN 2 ELSE 1,
                              OUTPUT aux_dscritic).
       
       IF  RETURN-VALUE <> "OK" THEN
           UNDO TRANSACAO, LEAVE TRANSACAO.    
        
        RUN cadastrar-senha-hsh (INPUT par_cdcooper,
                                 INPUT par_nrdconta,
                                 INPUT par_idseqttl,
                                 INPUT par_nrcpfope,
                                 INPUT par_cdsennew,
                                 INPUT par_dssennew,
                                 INPUT 1,
                                OUTPUT aux_dscritic).

        IF  RETURN-VALUE <> "OK" THEN            
            UNDO TRANSACAO, LEAVE TRANSACAO.
        
        IF  par_nrcpfope = 0  THEN
            DO: 
                IF  par_vldfrase = 1  THEN
                    ASSIGN crapsnh.cddsenha = ENCODE(par_cdsennew).

                ASSIGN crapsnh.dssenweb = IF par_dssennew = "" THEN "" 
                                          ELSE ENCODE(CAPS(par_dssennew))
                       crapsnh.dtaltsnh = aux_datdodia.
            END.       
        ELSE
            DO:
                IF  par_vldfrase = 1  THEN
                    ASSIGN crapopi.dsdsenha = ENCODE(par_cdsennew).

                ASSIGN crapopi.dsdfrase = IF par_dssennew = "" THEN "" 
                                          ELSE ENCODE(CAPS(par_dssennew))
                       crapopi.dtaltsnh = aux_datdodia.
            END.
                   
        ASSIGN aux_flgtrans = TRUE.
        
    END. /** Fim do DO TRANSACTION - TRANSACAO **/
    
    IF  NOT aux_flgtrans  THEN
        DO:
            IF  aux_cdcritic = 0 AND aux_dscritic = ""  THEN
                aux_dscritic = "Nao foi possivel concluir a requisicao.".
                
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                               
            IF  par_flgerlog  THEN
                DO:
                    RUN proc_gerar_log (INPUT par_cdcooper,
                                        INPUT par_cdoperad,
                                        INPUT aux_dscritic,
                                        INPUT aux_dsorigem,
                                        INPUT aux_dstransa,
                                        INPUT FALSE,
                                        INPUT par_idseqttl,
                                        INPUT par_nmdatela,
                                        INPUT par_nrdconta,
                                       OUTPUT aux_nrdrowid).

					RUN proc_gerar_log_item
                                  (INPUT aux_nrdrowid,
                                   INPUT "Origem",
                                   INPUT "",
                                   INPUT STRING(par_flmobile,"MOBILE/INTERNETBANK")).

                    IF  par_nrcpfope > 0  THEN
                        RUN proc_gerar_log_item 
                                          (INPUT aux_nrdrowid,
                                           INPUT "Operador",
                                           INPUT "",
                                           INPUT STRING(STRING(par_nrcpfope,
                                                        "99999999999"),
                                                        "xxx.xxx.xxx-xx")).

                    RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                             INPUT "IP",
                                             INPUT "",
                                             INPUT par_nripuser).

                    IF  aux_dscidori <> ""  THEN
                        RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                                 INPUT "Cidade IP",
                                                 INPUT "",
                                                 INPUT aux_dscidori).

                    IF  aux_dsuforig <> ""  THEN
                        RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                                 INPUT "Estado IP",
                                                 INPUT "",
                                                 INPUT aux_dsuforig).

                    IF  aux_dspaisor <> ""  THEN
                        RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                                 INPUT "Pais IP",
                                                 INPUT "",
                                                 INPUT aux_dspaisor).
                END.                                          
        
            RETURN "NOK".
        END.
        
    IF  par_flgerlog  THEN
        DO:
            RUN proc_gerar_log (INPUT par_cdcooper,
                                INPUT par_cdoperad,
                                INPUT "",
                                INPUT aux_dsorigem,
                                INPUT aux_dstransa,
                                INPUT TRUE,
                                INPUT par_idseqttl,
                                INPUT par_nmdatela,
                                INPUT par_nrdconta,
                               OUTPUT aux_nrdrowid).
        
			RUN proc_gerar_log_item
                                  (INPUT aux_nrdrowid,
                                   INPUT "Origem",
                                   INPUT "",
                                   INPUT STRING(par_flmobile,"MOBILE/INTERNETBANK")).
        
            IF  par_nrcpfope > 0  THEN
                RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                         INPUT "Operador",
                                         INPUT "",
                                         INPUT STRING(STRING(par_nrcpfope,
                                                      "99999999999"),
                                                      "xxx.xxx.xxx-xx")).

            RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                     INPUT "IP",
                                     INPUT "",
                                     INPUT par_nripuser).

            IF  aux_dscidori <> ""  THEN
                RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                         INPUT "Cidade IP",
                                         INPUT "",
                                         INPUT aux_dscidori).

            IF  aux_dsuforig <> ""  THEN
                RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                         INPUT "Estado IP",
                                         INPUT "",
                                         INPUT aux_dsuforig).

            IF  aux_dspaisor <> ""  THEN
                RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                         INPUT "Pais IP",
                                         INPUT "",
                                         INPUT aux_dspaisor).

            IF crapass.inpessoa > 1 THEN
            DO:
              /* Buscar dados do responsavel legal */
              { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }
              RUN STORED-PROCEDURE pc_verifica_rep_assinatura
                  aux_handproc = PROC-HANDLE NO-ERROR
                                (INPUT par_cdcooper, /* Codigo da Cooperativa */
                                 INPUT par_nrdconta, /* Numero da Conta */
                                 INPUT par_idseqttl, /* Sequencia Titularidade */
                                 INPUT par_idorigem, /* Codigo Origem */
                                OUTPUT 0,            /* Flag de Assinatura Multipla pr_idastcjt */
                                OUTPUT 0,            /* Numero do CPF pr_nrcpfcgc */
                                OUTPUT "",           /* Nome do Representante/Procurador pr_nmprimtl */
                                OUTPUT 0,            /* Flag de Preposto Cartao Mag. pr_flcartma */
                                OUTPUT 0,            /* Codigo da critica */
                                OUTPUT "").          /* Descricao da critica */
              
              CLOSE STORED-PROC pc_verifica_rep_assinatura
                    aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
            
              { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }
              
              ASSIGN aux_nrcpfcgc = 0
                     aux_nmprimtl = ""
                     aux_cdcritic = 0
                     aux_dscritic = ""
                     aux_nrcpfcgc = pc_verifica_rep_assinatura.pr_nrcpfcgc 
                                    WHEN pc_verifica_rep_assinatura.pr_nrcpfcgc <> ?
                     aux_nmprimtl = pc_verifica_rep_assinatura.pr_nmprimtl 
                                    WHEN pc_verifica_rep_assinatura.pr_nmprimtl <> ?
                     aux_cdcritic = pc_verifica_rep_assinatura.pr_cdcritic 
                                    WHEN pc_verifica_rep_assinatura.pr_cdcritic <> ?
                     aux_dscritic = pc_verifica_rep_assinatura.pr_dscritic
                                    WHEN pc_verifica_rep_assinatura.pr_dscritic <> ?.
              
              IF aux_cdcritic <> 0   OR
                 aux_dscritic <> ""  THEN
              DO:
                   IF aux_dscritic = "" THEN
                      DO:
                         FIND crapcri WHERE crapcri.cdcritic = aux_cdcritic
                                            NO-LOCK NO-ERROR.
              
                         IF AVAIL crapcri THEN
                            ASSIGN aux_dscritic = crapcri.dscritic.
              
                      END.
                     
                      RUN gera_erro (INPUT par_cdcooper,
                                     INPUT par_cdagenci,
                                     INPUT par_nrdcaixa,
                                     INPUT 1,            /** Sequencia **/
                                     INPUT aux_cdcritic,
                                     INPUT-OUTPUT aux_dscritic).
                   RETURN "NOK".
                                  
              END.
              
              /* Gerar o log com CPF do Rep./Proc. */
              IF  aux_nrcpfcgc > 0 THEN
                  RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                          INPUT "CPF Representate/Procurador" ,
                                          INPUT "",
                                          INPUT STRING(STRING(aux_nrcpfcgc,
                                                  "99999999999"),"xxx.xxx.xxx-xx")).
              
              /* Gerar o log com Nome do Rep./Proc. */                                
              IF  aux_nmprimtl <> ""   THEN
                  RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                          INPUT "Nome Representate/Procurador" ,
                                          INPUT "",
                                          INPUT aux_nmprimtl).
                                      
              /* FIM Buscar dados responsavel legal */
            END.
        END.

    RETURN "OK".
    
END PROCEDURE.


/******************************************************************************/
/**             Procedure para validar senha do acesso a conta               **/
/******************************************************************************/
PROCEDURE valida-senha:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrcpfope LIKE crapopi.nrcpfope             NO-UNDO.
    DEF  INPUT PARAM par_cddsenha AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dssenweb AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dssenlet AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_vldshlet AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_vldfrase AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_inaceblq AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nripuser AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dsorigip AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_flmobile AS LOGI                           NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_dscidori AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsuforig AS CHAR                                    NO-UNDO.
    DEF VAR aux_dspaisor AS CHAR                                    NO-UNDO.
    DEF VAR aux_nrcpfcgc AS DECI                                    NO-UNDO.
    DEF VAR aux_nmprimtl AS CHAR                                    NO-UNDO.   

    EMPTY TEMP-TABLE tt-erro.
    
    FOR FIRST crapass WHERE crapass.cdcooper = par_cdcooper 
                        AND crapass.nrdconta = par_nrdconta
                        NO-LOCK. END.
    IF  NOT AVAIL crapass THEN
    DO:
        ASSIGN aux_cdcritic = 9.
        RUN gera_erro (INPUT par_cdcooper,
                       INPUT par_cdagenci,
                       INPUT par_nrdcaixa,
                       INPUT 1,            /** Sequencia **/
                       INPUT aux_cdcritic,
                       INPUT-OUTPUT aux_dscritic).
        RETURN "NOK".
    END.

    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = IF  par_vldfrase = 0  THEN
                              "Validar senha numerica do InternetBank"
                          ELSE
                              "Validar senha numerica e frase secreta do " +
                              "InternetBank"
           aux_cdcritic = 0
           aux_dscritic = "".        

    IF  par_inaceblq = 1  THEN
        RUN formata-dados-origem-ip (INPUT par_dsorigip,
                                    OUTPUT aux_dscidori,
                                    OUTPUT aux_dsuforig,
                                    OUTPUT aux_dspaisor).

    RUN confirma-senha (INPUT par_cdcooper,
                        INPUT par_nrdconta,
                        INPUT par_idseqttl,
                        INPUT par_nrcpfope,
                        INPUT par_cddsenha,
                        INPUT-OUTPUT par_cddsenha,
                        INPUT "",
                        INPUT par_dssenweb,
                        INPUT "",
                        INPUT "",
                        INPUT par_dssenlet,
                        INPUT par_vldshlet,
                        INPUT FALSE,
                        INPUT par_vldfrase,
                        INPUT par_inaceblq,
                        INPUT par_nripuser,
                        INPUT aux_dscidori,
                        INPUT aux_dsuforig,
                        INPUT aux_dspaisor,
                       OUTPUT aux_dscritic).
                      
    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            ASSIGN aux_cdcritic = 0.
                   
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                                   
            IF  par_flgerlog  THEN
                DO:
                    RUN proc_gerar_log (INPUT par_cdcooper,
                                        INPUT par_cdoperad,
                                        INPUT aux_dscritic,
                                        INPUT aux_dsorigem,
                                        INPUT aux_dstransa,
                                        INPUT FALSE,
                                        INPUT par_idseqttl,
                                        INPUT par_nmdatela,
                                        INPUT par_nrdconta,
                                       OUTPUT aux_nrdrowid).
                                       
                    RUN proc_gerar_log_item
                                  (INPUT aux_nrdrowid,
                                   INPUT "Origem",
                                   INPUT "",
                                   INPUT STRING(par_flmobile,"MOBILE/INTERNETBANK")).
                
                    IF  par_nrcpfope > 0  THEN
                        RUN proc_gerar_log_item 
                                          (INPUT aux_nrdrowid,
                                           INPUT "Operador",
                                           INPUT "",
                                           INPUT STRING(STRING(par_nrcpfope,
                                                        "99999999999"),
                                                        "xxx.xxx.xxx-xx")).

                    RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                             INPUT "IP",
                                             INPUT "",
                                             INPUT par_nripuser).

                    IF  aux_dscidori <> ""  THEN
                        RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                                 INPUT "Cidade IP",
                                                 INPUT "",
                                                 INPUT aux_dscidori).

                    IF  aux_dsuforig <> ""  THEN
                        RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                                 INPUT "Estado IP",
                                                 INPUT "",
                                                 INPUT aux_dsuforig).

                    IF  aux_dspaisor <> ""  THEN
                        RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                                 INPUT "Pais IP",
                                                 INPUT "",
                                                 INPUT aux_dspaisor).
                END.
                
            RETURN "NOK".
        END.

    IF crapass.inpessoa > 1 THEN
    DO:
      /* Buscar dados do responsavel legal */
      { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }
      RUN STORED-PROCEDURE pc_verifica_rep_assinatura
          aux_handproc = PROC-HANDLE NO-ERROR
                        (INPUT par_cdcooper, /* Codigo da Cooperativa */
                         INPUT par_nrdconta, /* Numero da Conta */
                         INPUT par_idseqttl, /* Sequencia Titularidade */
                         INPUT par_idorigem, /* Codigo Origem */
                        OUTPUT 0,            /* Flag de Assinatura Multipla pr_idastcjt */
                        OUTPUT 0,            /* Numero do CPF pr_nrcpfcgc */
                        OUTPUT "",           /* Nome do Representante/Procurador pr_nmprimtl */
                        OUTPUT 0,            /* Flag de Preposto Cartao Mag. pr_flcartma */
                        OUTPUT 0,            /* Codigo da critica */
                        OUTPUT "").          /* Descricao da critica */
      
      CLOSE STORED-PROC pc_verifica_rep_assinatura
            aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
    
      { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }
      
      ASSIGN aux_nrcpfcgc = 0
             aux_nmprimtl = ""
             aux_cdcritic = 0
             aux_dscritic = ""
             aux_nrcpfcgc = pc_verifica_rep_assinatura.pr_nrcpfcgc 
                            WHEN pc_verifica_rep_assinatura.pr_nrcpfcgc <> ?
             aux_nmprimtl = pc_verifica_rep_assinatura.pr_nmprimtl 
                            WHEN pc_verifica_rep_assinatura.pr_nmprimtl <> ?
             aux_cdcritic = pc_verifica_rep_assinatura.pr_cdcritic 
                            WHEN pc_verifica_rep_assinatura.pr_cdcritic <> ?
             aux_dscritic = pc_verifica_rep_assinatura.pr_dscritic
                            WHEN pc_verifica_rep_assinatura.pr_dscritic <> ?.
      
      IF aux_cdcritic <> 0   OR
         aux_dscritic <> ""  THEN
      DO:
           IF aux_dscritic = "" THEN
              DO:
                 FIND crapcri WHERE crapcri.cdcritic = aux_cdcritic
                                    NO-LOCK NO-ERROR.
      
                 IF AVAIL crapcri THEN
                    ASSIGN aux_dscritic = crapcri.dscritic.
      
              END.
             
              RUN gera_erro (INPUT par_cdcooper,
                             INPUT par_cdagenci,
                             INPUT par_nrdcaixa,
                             INPUT 1,            /** Sequencia **/
                             INPUT aux_cdcritic,
                             INPUT-OUTPUT aux_dscritic).
           RETURN "NOK".
                          
      END.
      
      /* Gerar o log com CPF do Rep./Proc. */
      IF  aux_nrcpfcgc > 0 THEN
          RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                  INPUT "CPF Representate/Procurador" ,
                                  INPUT "",
                                  INPUT STRING(STRING(aux_nrcpfcgc,
                                          "99999999999"),"xxx.xxx.xxx-xx")).
      
      /* Gerar o log com Nome do Rep./Proc. */                                
      IF  aux_nmprimtl <> ""   THEN
          RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                  INPUT "Nome Representate/Procurador" ,
                                  INPUT "",
                                  INPUT aux_nmprimtl).
                              
      /* FIM Buscar dados responsavel legal */
    END.

    RETURN "OK".
        
END PROCEDURE.

/******************************************************************************/
/**            Procedure para obter permissoes do menu do Mobile             **/
/******************************************************************************/

PROCEDURE permissoes-menu-mobile:
    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrcpfope LIKE crapopi.nrcpfope             NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-itens-menu-mobile.
    
    DEF VAR aux_flgsittp AS LOGI                                    NO-UNDO.
    DEF VAR aux_flgaprov AS LOGI                                    NO-UNDO.
    DEF VAR aux_flgdebau AS LOGI                                    NO-UNDO.
    DEF VAR aux_flgsitrc AS LOGI                                    NO-UNDO.
    DEF VAR aux_flgaplic AS LOGI                                    NO-UNDO.
    DEF VAR aux_flgresga AS LOGI                                    NO-UNDO.
    DEF VAR h-b1wgen0188 AS HANDLE                                  NO-UNDO.
    DEF VAR h-b1wgen0018 AS HANDLE                                  NO-UNDO.
    DEF VAR aux_possuipr AS CHAR NO-UNDO.
    
    DEF VAR aux_cdmodali AS INTE                                    NO-UNDO.
    DEF VAR aux_contador AS INTE                                    NO-UNDO.
    DEF VAR aux_itens    AS CHAR                                    NO-UNDO.
    DEF VAR aux_des_erro AS CHAR                                    NO-UNDO.
    
    DEF VAR aux_dscctsal AS CHAR                                    NO-UNDO.

    DEF VAR aux_flgsimul AS LOGI                                    NO-UNDO.
    DEF VAR aux_desc_prm AS CHAR                                    NO-UNDO.

    
    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-itens-menu.
    
    RUN sistema/generico/procedures/b1wgen0188.p PERSISTENT SET h-b1wgen0188.
    RUN sistema/generico/procedures/b1wgen0018.p PERSISTENT SET h-b1wgen0018.
            
    FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                       crapass.nrdconta = par_nrdconta NO-LOCK NO-ERROR. 

    IF  NOT AVAILABLE crapass  THEN
        DO:
            ASSIGN aux_cdcritic = 9
                   aux_dscritic = "".
                   
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                                    
            RETURN "NOK".                
        END.
    
    /* TRANSACOES PENDENTES */
    FIND FIRST crapopi WHERE crapopi.cdcooper = par_cdcooper AND
							 crapopi.nrdconta = par_nrdconta NO-LOCK NO-ERROR. 
    
    IF crapass.idastcjt = 1 OR AVAILABLE crapopi THEN
      DO:
          ASSIGN aux_flgsittp = TRUE.
    END.
            
    /*CRÉDITO PRE-APROVADO*/
    IF  VALID-HANDLE(h-b1wgen0188)  THEN
        DO:
            /** Verifica se possui credito pre-aprovado **/
            RUN busca_dados IN h-b1wgen0188 (INPUT par_cdcooper,
                                             INPUT par_cdagenci,
                                             INPUT par_nrdcaixa,
                                             INPUT par_cdoperad,
                                             INPUT par_nmdatela,
                                             INPUT par_idorigem,
                                             INPUT par_nrdconta,
                                             INPUT IF crapass.idastcjt = 0 THEN par_idseqttl ELSE 1,
                                             INPUT par_nrcpfope,
                                             OUTPUT TABLE tt-dados-cpa,
                                             OUTPUT TABLE tt-erro).
            
            DELETE PROCEDURE h-b1wgen0188.

            IF RETURN-VALUE <> "OK" THEN
               EMPTY TEMP-TABLE tt-erro.

            FIND FIRST tt-dados-cpa NO-LOCK NO-ERROR.
            IF AVAIL tt-dados-cpa AND tt-dados-cpa.vldiscrd > 0 AND crapass.idastcjt = 0 THEN DO:
              ASSIGN aux_flgaprov = TRUE.
            END.
        END.
    
    /*RECARGA DE CELULAR*/
    IF  VALID-HANDLE(h-b1wgen0018)  THEN
        DO:
            /** Verifica se o item de Recarga de Celular deve ser habilitado no Menu do Mobile **/
            RUN pc_situacao_canal_recarga IN h-b1wgen0018 (INPUT par_cdcooper,
                                                           INPUT par_idorigem,
                                                           OUTPUT aux_flgsitrc).
            
            DELETE PROCEDURE h-b1wgen0018.
    END.
    
    /* buscar quantidade maxima de digitos aceitos para o convenio */
    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }    
    
    RUN STORED-PROCEDURE pc_permite_lista_prod_tipo
        aux_handproc = PROC-HANDLE NO-ERROR
                                (INPUT "29,3,41", /* DEBITO AUTOMATICO, INCLUIR APLICACAO, RESGATAR APLICACAO */
                                 INPUT crapass.cdtipcta,
                                 INPUT par_cdcooper,
                                 INPUT crapass.inpessoa,
                                 OUTPUT "",  /* pr_possuipr */
                                 OUTPUT 0,   /* pr_cdcritic */
                                 OUTPUT ""). /* pr_dscritic */
    
    CLOSE STORED-PROC pc_permite_lista_prod_tipo
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
    
    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
    
    ASSIGN aux_possuipr = ""
           aux_cdcritic = 0
           aux_dscritic = ""
           aux_possuipr = pc_permite_lista_prod_tipo.pr_possuipr                          
                              WHEN pc_permite_lista_prod_tipo.pr_possuipr <> ?
           aux_cdcritic = pc_permite_lista_prod_tipo.pr_cdcritic                          
                              WHEN pc_permite_lista_prod_tipo.pr_cdcritic <> ?
           aux_dscritic = pc_permite_lista_prod_tipo.pr_dscritic
                              WHEN pc_permite_lista_prod_tipo.pr_dscritic <> ?.
    
    IF  aux_cdcritic <> 0 OR aux_dscritic <> "" THEN
      DO:
          RUN gera_erro (INPUT par_cdcooper,
                         INPUT par_cdagenci,
                         INPUT par_nrdcaixa,
                         INPUT 1,            /** Sequencia **/
                         INPUT aux_cdcritic,
                         INPUT-OUTPUT aux_dscritic).
                                  
          RETURN "NOK".                
      END.
    
    IF SUBSTRING(aux_possuipr,1,1) = "S" THEN
      aux_flgdebau = TRUE.
    ELSE
      aux_flgdebau = FALSE.
    
    IF SUBSTRING(aux_possuipr,3,1) = "S" THEN
      aux_flgaplic = TRUE.
    ELSE
      aux_flgaplic = FALSE.
    
    IF SUBSTRING(aux_possuipr,5,1) = "S" THEN
      aux_flgresga = TRUE.
    ELSE
      aux_flgresga = FALSE.
      
    /* VERIFICAR SE A CONTA PERMITE SIMULAR E CONTRATAR EMPRESTIMOS */
    ASSIGN aux_flgsimul =  FALSE.
    
    /* Verifica se o menu esta habilitado para a cooperativa */
    
    { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }
                
    RUN STORED-PROCEDURE pc_param_sistema aux_handproc = PROC-HANDLE
       (INPUT "CRED",           /* pr_nmsistem */
        INPUT par_cdcooper,     /* pr_cdcooper */
        INPUT "LIBERA_COOP_SIMULA_IB",  /* pr_cdacesso */
        OUTPUT ""               /* pr_dsvlrprm */
        ).

    CLOSE STORED-PROCEDURE pc_param_sistema WHERE PROC-HANDLE = aux_handproc.
    { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }
    
    ASSIGN aux_desc_prm = ""
           aux_desc_prm = pc_param_sistema.pr_dsvlrprm 
                          WHEN pc_param_sistema.pr_dsvlrprm <> ?. 
    
    /*Se a cooperativa pode exibir o menu*/
    IF LOOKUP(STRING(par_cdcooper), aux_desc_prm, ";") > 0 THEN
      DO:
        /*Se NAO eh um operador*/
        IF par_nrcpfope = ?  OR par_nrcpfope = 0 THEN
          DO:
            /*Se a conta tem permissao para o produto*/
            { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }    
                     
            RUN STORED-PROCEDURE pc_valida_adesao_produto
                aux_handproc = PROC-HANDLE NO-ERROR
                                        (INPUT par_cdcooper,
                                         INPUT par_nrdconta,
                                         INPUT 31,   /* EMPRESTIMO */
                                         OUTPUT 0,   /* pr_cdcritic */
                                         OUTPUT ""). /* pr_dscritic */
                        
            CLOSE STORED-PROC pc_valida_adesao_produto
                  aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
             { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }
             ASSIGN aux_cdcritic = 0
                   aux_dscritic = ""
                   aux_cdcritic = pc_valida_adesao_produto.pr_cdcritic                          
                                      WHEN pc_valida_adesao_produto.pr_cdcritic <> ?
                   aux_dscritic = pc_valida_adesao_produto.pr_dscritic
                                      WHEN pc_valida_adesao_produto.pr_dscritic <> ?.
            
            IF  aux_cdcritic = 0 AND aux_dscritic = "" THEN
              DO:
                /*Verifica se eh PF e primeiro titular, ou PJ*/
                IF AVAILABLE crapass THEN
                  DO:
                    IF ( (crapass.inpessoa = 1 AND par_idseqttl = 1) 
                      OR (crapass.inpessoa = 2) ) THEN
                      DO:
                        /*Pode exibir o menu*/
                        ASSIGN aux_flgsimul = TRUE.  
                      END.
                  END. 
              END.
          END.
      END.
    
    /* FIM VERIFICAR SE A CONTA PERMITE SIMULAR E CONTRATAR EMPRESTIMOS */
    
    CREATE tt-itens-menu-mobile.
    ASSIGN tt-itens-menu-mobile.cditemmn = 204. /*TRANSAÇOES PENDENTES*/
           tt-itens-menu-mobile.flcreate = aux_flgsittp.
      
    CREATE tt-itens-menu-mobile.
    ASSIGN tt-itens-menu-mobile.cditemmn = 700. /*PRÉ-APROVADO*/
           tt-itens-menu-mobile.flcreate = aux_flgaprov. 

    RUN STORED-PROCEDURE pc_busca_itens_menumobile
    aux_handproc = PROC-HANDLE NO-ERROR (OUTPUT "",               /* Itens */
                                         OUTPUT "",               /* Flag Erro */
                                         OUTPUT "").              /* Descriçao da crítica */

    CLOSE STORED-PROC pc_busca_itens_menumobile
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

    ASSIGN aux_itens = ""
           aux_des_erro = ""
           aux_dscritic = ""
           aux_itens = pc_busca_itens_menumobile.pr_itens 
                       WHEN pc_busca_itens_menumobile.pr_itens <> ?
           aux_des_erro = pc_busca_itens_menumobile.pr_des_erro 
                          WHEN pc_busca_itens_menumobile.pr_des_erro <> ?
           aux_dscritic = pc_busca_itens_menumobile.pr_dscritic
                          WHEN pc_busca_itens_menumobile.pr_dscritic <> ?.

    IF aux_des_erro = "NOK"  THEN
        DO:
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT 0,
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
        END.  
     
    DO aux_contador = 1  TO  NUM-ENTRIES(aux_itens, ","):
      CREATE tt-itens-menu-mobile.
      ASSIGN tt-itens-menu-mobile.cditemmn = INTE(ENTRY(aux_contador, aux_itens ,",")).
             tt-itens-menu-mobile.flcreate = TRUE.
    END.
      
    FIND FIRST tt-itens-menu-mobile WHERE tt-itens-menu-mobile.cditemmn = 204 EXCLUSIVE-LOCK NO-ERROR. /*TRANSAÇOES PENDENTES*/    
    IF AVAILABLE tt-itens-menu-mobile THEN
      DO:
        ASSIGN tt-itens-menu-mobile.flcreate = aux_flgsittp.
      END.
    
    
    FIND FIRST tt-itens-menu-mobile WHERE tt-itens-menu-mobile.cditemmn = 700 EXCLUSIVE-LOCK NO-ERROR. /*PRÉ-APROVADO*/
    IF AVAILABLE tt-itens-menu-mobile THEN
      DO:
        ASSIGN tt-itens-menu-mobile.flcreate = aux_flgaprov.
      END.
      
      
    FIND FIRST tt-itens-menu-mobile WHERE tt-itens-menu-mobile.cditemmn = 901 EXCLUSIVE-LOCK NO-ERROR. /*RECARGA DE CELULAR*/
    IF AVAILABLE tt-itens-menu-mobile THEN
      DO:
        ASSIGN tt-itens-menu-mobile.flcreate = aux_flgsitrc.
      END.
      
      
    FIND FIRST tt-itens-menu-mobile WHERE tt-itens-menu-mobile.cditemmn = 902 EXCLUSIVE-LOCK NO-ERROR. /*DEBITO AUTOMATICO*/
    IF AVAILABLE tt-itens-menu-mobile THEN
      DO:
        ASSIGN tt-itens-menu-mobile.flcreate = aux_flgdebau.
      END.
    
    IF aux_flgsitrc = FALSE AND 
       aux_flgdebau = FALSE THEN
        DO:
            FIND FIRST tt-itens-menu-mobile WHERE tt-itens-menu-mobile.cditemmn = 900 EXCLUSIVE-LOCK NO-ERROR. /*CONVENIENCIA*/
            IF AVAILABLE tt-itens-menu-mobile THEN
              DO:
                ASSIGN tt-itens-menu-mobile.flcreate = FALSE.
              END.
        END.

    FIND FIRST tt-itens-menu-mobile WHERE tt-itens-menu-mobile.cditemmn = 602 EXCLUSIVE-LOCK NO-ERROR. /*APLICACAO*/
    IF AVAILABLE tt-itens-menu-mobile THEN
      DO:
        ASSIGN tt-itens-menu-mobile.flcreate = aux_flgaplic.
      END.
      
    FIND FIRST tt-itens-menu-mobile WHERE tt-itens-menu-mobile.cditemmn = 603 EXCLUSIVE-LOCK NO-ERROR. /* RESGATE APLICACAO*/
    IF AVAILABLE tt-itens-menu-mobile THEN
      DO:
        ASSIGN tt-itens-menu-mobile.flcreate = aux_flgresga.
      END.

    FIND FIRST tt-itens-menu-mobile WHERE tt-itens-menu-mobile.cditemmn = 1004 EXCLUSIVE-LOCK NO-ERROR. /* SIMULACAO EMPRESTIMO*/
    IF AVAILABLE tt-itens-menu-mobile THEN
      DO:
        ASSIGN tt-itens-menu-mobile.flcreate = aux_flgsimul.
      END.

    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

    RUN STORED-PROCEDURE pc_busca_modalidade_tipo
    aux_handproc = PROC-HANDLE NO-ERROR (INPUT crapass.inpessoa, /* Tipo de pessoa */
                                         INPUT crapass.cdtipcta, /* Tipo de conta */
                                        OUTPUT 0,                /* Modalidade */
                                        OUTPUT "",               /* Flag Erro */
                                        OUTPUT "").              /* Descriçao da crítica */

    CLOSE STORED-PROC pc_busca_modalidade_tipo
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

    ASSIGN aux_cdmodali = 0
           aux_des_erro = ""
           aux_dscritic = ""
           aux_cdmodali = pc_busca_modalidade_tipo.pr_cdmodalidade_tipo 
                          WHEN pc_busca_modalidade_tipo.pr_cdmodalidade_tipo <> ?
           aux_des_erro = pc_busca_modalidade_tipo.pr_des_erro 
                          WHEN pc_busca_modalidade_tipo.pr_des_erro <> ?
           aux_dscritic = pc_busca_modalidade_tipo.pr_dscritic
                          WHEN pc_busca_modalidade_tipo.pr_dscritic <> ?.

    IF aux_des_erro = "NOK"  THEN
        DO:
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT 0,
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
        END.

    
    /*
    1) modalidade é 2? se sim goto 2 senao goto -1
    2) inativa todos os itens da temp-table
    3) ativa somente os itens retornados no select
    */
    IF aux_cdmodali = 2 THEN
      DO:
      
        ASSIGN aux_dscctsal = "10,20,103,104,30,200,300,301,302,400,401,402,500,804,902,40,1001,1004".

        FOR EACH tt-itens-menu-mobile NO-LOCK:
          IF NOT CAN-DO(aux_dscctsal, STRING(tt-itens-menu-mobile.cditemmn)) THEN
          DO:
            ASSIGN tt-itens-menu-mobile.flcreate = FALSE.
          END.
        END.
      END.
    
  RETURN "OK".
    
END PROCEDURE.

/******************************************************************************/
/**         Procedure para obter permissoes do menu do InternetBank          **/
/******************************************************************************/
PROCEDURE permissoes-menu:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrcpfope LIKE crapopi.nrcpfope             NO-UNDO.
    DEF  INPUT PARAM par_dsurlace AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_flgtelop AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-itens-menu.
        
    DEF VAR aux_dstipitm AS CHAR                                    NO-UNDO.

    DEF VAR aux_cditmpag AS INTE                                    NO-UNDO.
    DEF VAR aux_cditmdda AS INTE                                    NO-UNDO.
    DEF VAR aux_qtdiauso AS INTE                                    NO-UNDO.
    DEF VAR aux_qtdiaalt AS INTE                                    NO-UNDO.

    DEF VAR aux_dtaltsnh AS DATE                                    NO-UNDO.

    DEF VAR aux_flginfor AS LOGI                                    NO-UNDO.
    DEF VAR aux_flgconve AS LOGI                                    NO-UNDO.
    DEF VAR aux_flgtitul AS LOGI                                    NO-UNDO.
    DEF VAR aux_flgpagto AS LOGI                                    NO-UNDO.
    DEF VAR aux_flgpgdda AS LOGI                                    NO-UNDO.
    DEF VAR aux_flgtbdda AS LOGI                                    NO-UNDO.
    DEF VAR aux_flgprepo AS LOGI                                    NO-UNDO.
    DEF VAR aux_flgblque AS LOGI                                    NO-UNDO.
    DEF VAR aux_flgaprov AS LOGI                                    NO-UNDO.
    DEF VAR aux_flgdesct AS LOGI                                    NO-UNDO.
    /* Identificar se o cooperado possui convenio para upload do arquivo de 
       pagamento, ou se possui remessa ja enviada */
    DEF VAR aux_flguppgt AS LOGI                                    NO-UNDO.
    DEF VAR aux_flgrepgt AS LOGI                                    NO-UNDO.

    DEF VAR h-b1wgen0016 AS HANDLE                                  NO-UNDO.
    DEF VAR h-b1wgen0079 AS HANDLE                                  NO-UNDO.
    DEF VAR h-b1wgen0188 AS HANDLE                                  NO-UNDO.
        
    DEF BUFFER crabmni FOR crapmni.
    
    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-itens-menu.
     
    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Obter permissoes para o menu do InternetBank" +
                         (IF  par_nrcpfope > 0  THEN
                              " (Operador: " +
                              STRING(STRING(par_nrcpfope,
                                     "99999999999"),"xxx.xxx.xxx-xx") +
                              ")"
                          ELSE
                              "")
           aux_cdcritic = 0
           aux_dscritic = "".   
            
    FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                       crapass.nrdconta = par_nrdconta NO-LOCK NO-ERROR. 

    IF  NOT AVAILABLE crapass  THEN
        DO:
            ASSIGN aux_cdcritic = 9
                   aux_dscritic = "".
                   
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                                   
            IF  par_flgerlog  THEN
                RUN proc_gerar_log (INPUT par_cdcooper,
                                    INPUT par_cdoperad,
                                    INPUT aux_dscritic,
                                    INPUT aux_dsorigem,
                                    INPUT aux_dstransa,
                                    INPUT FALSE,
                                    INPUT par_idseqttl,
                                    INPUT par_nmdatela,
                                    INPUT par_nrdconta,
                                   OUTPUT aux_nrdrowid).        
                                    
            RETURN "NOK".                
        END.

    /** Tipos de itens permitidos para a conta - crapmni.intipitm **/
    ASSIGN aux_dstipitm = "0," + (IF  crapass.inpessoa = 1  THEN
                                      "1"
                                  ELSE
                                      "2")
           aux_flginfor = FALSE
           aux_flgconve = FALSE
           aux_flgpagto = FALSE
           aux_flgaprov = FALSE
           aux_flgdesct = FALSE
           /** DDA nao sera validado no momento - 12/07/2011 (David) **/
           aux_flgpgdda = TRUE 
           aux_flgtbdda = TRUE.
    
    /** Verifica se existe algum registro de informativo **/
    FIND FIRST crapifc WHERE crapifc.cdcooper = par_cdcooper NO-LOCK NO-ERROR.
                                    
    IF  AVAILABLE crapifc  THEN
        ASSIGN aux_flginfor = TRUE.

    RUN sistema/generico/procedures/b1wgen0016.p PERSISTENT SET h-b1wgen0016.
               
    IF  VALID-HANDLE(h-b1wgen0016)  THEN
        DO:
            /** Verifica tipos de pagamentos disponiveis **/
            RUN pagamentos_liberados IN h-b1wgen0016 (INPUT par_cdcooper,
                                                     OUTPUT aux_flgconve,
                                                     OUTPUT aux_flgtitul).
                                                         
            DELETE PROCEDURE h-b1wgen0016.
        
            ASSIGN aux_flgpagto = IF  NOT aux_flgconve  AND 
                                      NOT aux_flgtitul  THEN 
                                      FALSE 
                                  ELSE 
                                      TRUE.
        END.

    RUN sistema/generico/procedures/b1wgen0188.p PERSISTENT SET h-b1wgen0188.
               
    IF  VALID-HANDLE(h-b1wgen0188)  THEN
        DO:
            /** Verifica se possui credito pre-aprovado **/
            RUN busca_dados IN h-b1wgen0188 (INPUT par_cdcooper,
                                             INPUT par_cdagenci,
                                             INPUT par_nrdcaixa,
                                             INPUT par_cdoperad,
                                             INPUT par_nmdatela,
                                             INPUT par_idorigem,
                                             INPUT par_nrdconta,
                                             INPUT IF crapass.idastcjt = 0 THEN par_idseqttl ELSE 1,
                                             INPUT par_nrcpfope,
                                             OUTPUT TABLE tt-dados-cpa,
                                             OUTPUT TABLE tt-erro).
            
            DELETE PROCEDURE h-b1wgen0188.

            IF RETURN-VALUE <> "OK" THEN
               EMPTY TEMP-TABLE tt-erro.

            FIND FIRST tt-dados-cpa NO-LOCK NO-ERROR.
            IF AVAIL tt-dados-cpa AND tt-dados-cpa.vldiscrd > 0 THEN
               ASSIGN aux_flgaprov = TRUE.
        END.
    
    /* Verifica se possui limite de desconto de cheque */
    FIND FIRST craplim WHERE craplim.cdcooper = par_cdcooper AND
                             craplim.nrdconta = par_nrdconta AND
                             craplim.tpctrlim = 2            AND
                             craplim.insitlim > 1
                             NO-LOCK NO-ERROR.
    IF AVAILABLE craplim THEN
       DO:
         ASSIGN aux_flgdesct = TRUE.
       END.
        
    /** DDA nao sera validado no momento - 12/07/2011 (David) **
    RUN sistema/generico/procedures/b1wgen0079.p PERSISTENT SET h-b1wgen0079.
     
    IF  VALID-HANDLE(h-b1wgen0079)   THEN
        DO: 
            RUN requisicao-consulta-situacao IN h-b1wgen0079 
                                            (INPUT par_cdcooper,
                                             INPUT par_cdagenci,
                                             INPUT par_nrdcaixa,
                                             INPUT par_cdoperad,
                                             INPUT par_nmdatela,
                                             INPUT par_idorigem,
                                             INPUT par_nrdconta,
                                             INPUT par_idseqttl,
                                             INPUT FALSE,
                                            OUTPUT TABLE tt-erro,
                                            OUTPUT TABLE tt-consulta-situacao).

            DELETE PROCEDURE h-b1wgen0079.

            FIND FIRST tt-consulta-situacao NO-LOCK NO-ERROR.
            
            IF  AVAILABLE tt-consulta-situacao  THEN
                ASSIGN aux_flgpgdda = (tt-consulta-situacao.flgativo AND
                                       tt-consulta-situacao.cdsituac = 6)
                       aux_flgtbdda = (NOT tt-consulta-situacao.flgativo AND
                                       tt-consulta-situacao.cdsituac = 17).
        END.
    **/
                                           
    ASSIGN aux_cditmpag = 5    /** Modulo Transacoes **/
           aux_cditmdda = 14.  /** Modulo DDA        **/
    
    /** Utilizada para verificar permissao do item acessado via menu **/
    IF  par_dsurlace <> ""  THEN
        DO:
            FIND FIRST crapmni WHERE crapmni.cdcooper = par_cdcooper AND
                                     crapmni.flgitmbl = TRUE         AND
                                     crapmni.dsurlace = par_dsurlace 
                                     NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE crapmni                              OR
                NOT CAN-DO(aux_dstipitm,STRING(crapmni.intipitm))  THEN
                DO:  
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = "Alteracao nas permissoes do menu. " +
                                          "Efetue novo acesso.".
                   
                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT 1,            /** Sequencia **/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
                                   
                    IF  par_flgerlog  THEN
                        RUN proc_gerar_log (INPUT par_cdcooper,
                                            INPUT par_cdoperad,
                                            INPUT aux_dscritic,
                                            INPUT aux_dsorigem,
                                            INPUT aux_dstransa,
                                            INPUT FALSE,
                                            INPUT par_idseqttl,
                                            INPUT par_nmdatela,
                                            INPUT par_nrdconta,
                                           OUTPUT aux_nrdrowid).        
                                    
                    RETURN "NOK".
                END.
        
            IF  crapmni.cdsubitm > 0  THEN
                DO:
                    FIND crabmni WHERE crabmni.cdcooper = par_cdcooper     AND
                                       crabmni.cditemmn = crapmni.cditemmn AND
                                       crabmni.cdsubitm = 0                AND
                                       crabmni.flgitmbl = TRUE
                                       NO-LOCK NO-ERROR.

                    IF  NOT AVAILABLE crabmni  THEN
                        DO:
                            ASSIGN aux_cdcritic = 0
                                   aux_dscritic = "Alteracao nas permissoes " +
                                                  "do menu. Efetue novo " +
                                                  "acesso.".
                   
                            RUN gera_erro (INPUT par_cdcooper,
                                           INPUT par_cdagenci,
                                           INPUT par_nrdcaixa,
                                           INPUT 1,            /** Sequencia **/
                                           INPUT aux_cdcritic,
                                           INPUT-OUTPUT aux_dscritic).
                                   
                            IF  par_flgerlog  THEN
                                RUN proc_gerar_log (INPUT par_cdcooper,
                                                    INPUT par_cdoperad,
                                                    INPUT aux_dscritic,
                                                    INPUT aux_dsorigem,
                                                    INPUT aux_dstransa,
                                                    INPUT FALSE,
                                                    INPUT par_idseqttl,
                                                    INPUT par_nmdatela,
                                                    INPUT par_nrdconta,
                                                   OUTPUT aux_nrdrowid).        
                                        
                            RETURN "NOK".
                        END.
                END.
        END.
        

    /* Verifica se ha um Preposto cadastrado para PJ*/
    IF  crapass.inpessoa = 2 OR
        crapass.inpessoa = 3 THEN
        DO:
            IF crapass.idastcjt = 0 THEN
            DO:
                FIND crapsnh WHERE  crapsnh.cdcooper = par_cdcooper AND
                                    crapsnh.nrdconta = par_nrdconta AND
                                    crapsnh.idseqttl = 1 AND
                                    crapsnh.tpdsenha = 1 NO-LOCK NO-ERROR.
                IF  AVAIL crapsnh THEN
                    DO:
                        FIND FIRST crapavt WHERE  crapavt.cdcooper = crapsnh.cdcooper AND
                                            crapavt.nrdconta = crapsnh.nrdconta AND
                                            crapavt.tpctrato = 6
                                            NO-LOCK NO-ERROR.
        
                        IF  AVAIL crapavt THEN
                            ASSIGN aux_flgprepo = TRUE.
                    END.
            END.
            ELSE
                ASSIGN aux_flgprepo = TRUE.
        END.

    IF  crapass.inpessoa = 1  THEN
        FIND craptab WHERE craptab.cdcooper = par_cdcooper AND
                           craptab.nmsistem = "CRED"       AND
                           craptab.tptabela = "GENERI"     AND
                           craptab.cdempres = 0            AND
                           craptab.cdacesso = "LIMINTERNT" AND
                           craptab.tpregist = 1   
                           NO-LOCK NO-ERROR.
    ELSE
        FIND craptab WHERE craptab.cdcooper = par_cdcooper AND
                           craptab.nmsistem = "CRED"       AND
                           craptab.tptabela = "GENERI"     AND
                           craptab.cdempres = 0            AND
                           craptab.cdacesso = "LIMINTERNT" AND
                           craptab.tpregist = 2   
                           NO-LOCK NO-ERROR.

    IF  NOT AVAIL craptab  THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Registro LIMINTERNT nao encontrado.".
                   
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                   
            IF  par_flgerlog  THEN
                RUN proc_gerar_log (INPUT par_cdcooper,
                                    INPUT par_cdoperad,
                                    INPUT aux_dscritic,
                                    INPUT aux_dsorigem,
                                    INPUT aux_dstransa,
                                    INPUT FALSE,
                                    INPUT par_idseqttl,
                                    INPUT par_nmdatela,
                                    INPUT par_nrdconta,
                                   OUTPUT aux_nrdrowid).        
                        
            RETURN "NOK".
        END.
    
    ASSIGN aux_qtdiauso = INTEGER(ENTRY(17,craptab.dstextab,";"))
           aux_qtdiaalt = INTEGER(ENTRY(18,craptab.dstextab,";")).

    /* Verificar se o cooperado possui convenio homologado e enviou algum arquivo */
    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

    RUN STORED-PROCEDURE pc_verifica_conv_pgto
        aux_handproc = PROC-HANDLE NO-ERROR
                      (INPUT par_cdcooper, /* Codigo da Cooperativa */
                       INPUT par_nrdconta, /* Numero da Conta */
                      OUTPUT 0,            /* Numero do Convenio */
                      OUTPUT ?,            /* Data de adesao */
                      OUTPUT 0,            /* Convenio esta homologado */
                      OUTPUT 0,            /* Retorno para o Cooperado (1-Internet/2-FTP) */
                      OUTPUT 0,            /* Flag convenio homologado */
                      OUTPUT 0,            /* Flag enviou arquivo remessa */
                      OUTPUT 0,            /* Cód. da crítica */
                      OUTPUT "").          /* Descricao da critica */
    
    CLOSE STORED-PROC pc_verifica_conv_pgto
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
   
    ASSIGN aux_flguppgt = FALSE
           aux_flgrepgt = FALSE
           aux_cdcritic = 0
           aux_dscritic = ""
           aux_flguppgt = (IF pc_verifica_conv_pgto.pr_fluppgto = 1 THEN
                               TRUE
                           ELSE
                               FALSE)
           aux_flgrepgt = (IF pc_verifica_conv_pgto.pr_flrempgt = 1 THEN
                               TRUE
                           ELSE
                               FALSE)
           aux_cdcritic = pc_verifica_conv_pgto.pr_cdcritic
                          WHEN pc_verifica_conv_pgto.pr_cdcritic <> ?
           aux_dscritic = pc_verifica_conv_pgto.pr_dscritic
                          WHEN pc_verifica_conv_pgto.pr_dscritic <> ?.
      
    IF  par_nrcpfope = 0  THEN  
        DO: 
            FIND crapsnh WHERE crapsnh.cdcooper = par_cdcooper AND
                               crapsnh.nrdconta = par_nrdconta AND
                               crapsnh.tpdsenha = 1            AND
                               crapsnh.idseqttl = par_idseqttl 
                               NO-LOCK NO-ERROR.
                               
            IF  NOT AVAILABLE crapsnh  THEN
                DO:
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = "Registro de senha nao encontrado.".
                   
                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT 1,            /** Sequencia **/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
                                   
                    IF  par_flgerlog  THEN
                        RUN proc_gerar_log (INPUT par_cdcooper,
                                            INPUT par_cdoperad,
                                            INPUT aux_dscritic,
                                            INPUT aux_dsorigem,
                                            INPUT aux_dstransa,
                                            INPUT FALSE,
                                            INPUT par_idseqttl,
                                            INPUT par_nmdatela,
                                            INPUT par_nrdconta,
                                           OUTPUT aux_nrdrowid).        
                                    
                    RETURN "NOK".                
                END.     
                           
            IF  crapsnh.cdsitsnh <> 1  THEN
                DO:
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = "Senha " + 
                                         (IF  crapsnh.cdsitsnh = 0  THEN
                                              "inativa."
                                          ELSE
                                          IF  crapsnh.cdsitsnh = 2  THEN
                                              "bloqueada."
                                          ELSE
                                              "cancelada.").
                   
                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT 1,            /** Sequencia **/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
                                   
                    IF  par_flgerlog  THEN
                        RUN proc_gerar_log (INPUT par_cdcooper,
                                            INPUT par_cdoperad,
                                            INPUT aux_dscritic,
                                            INPUT aux_dsorigem,
                                            INPUT aux_dstransa,
                                            INPUT FALSE,
                                            INPUT par_idseqttl,
                                            INPUT par_nmdatela,
                                            INPUT par_nrdconta,
                                           OUTPUT aux_nrdrowid).        
                                    
                    RETURN "NOK".
                END.

            ASSIGN aux_dtaltsnh = crapsnh.dtaltsnh.
            
            IF  (aux_dtaltsnh + aux_qtdiauso + aux_qtdiaalt) <= aux_datdodia  THEN
                ASSIGN aux_flgblque = TRUE.
            
            FOR EACH crapmni WHERE crapmni.cdcooper = par_cdcooper AND
                                   crapmni.cdsubitm = 0            AND
                                   crapmni.flgitmbl = TRUE         NO-LOCK:
                
                IF aux_flgblque AND crapmni.nmdoitem <> "Alterar Senha"  THEN
                    NEXT.
                
                IF (NOT CAN-DO(aux_dstipitm,STRING(crapmni.intipitm))) OR
                   (NOT crapmni.flgopepj AND par_flgtelop)             THEN
                    NEXT.

                IF (crapmni.nmdoitem = "Comprovante Salarial"  AND
                    crapass.inpessoa <> 1)                     OR
                   (crapmni.nmdoitem = "Informativos"          AND
                    NOT aux_flginfor)                          OR
                   (crapmni.nmdoitem = "Operadores"            AND
                    par_flgtelop)                              OR
                   (crapmni.nmdoitem = "Alterar Senha"         AND
                    par_flgtelop)                              OR
                   (crapmni.nmdoitem = "Operadores"            AND
                    crapass.inpessoa = 1)                      OR
                   (crapmni.cditemmn = aux_cditmpag            AND
                    par_flgtelop                               AND
                    NOT aux_flgprepo)                          THEN
                    NEXT.
 
                /* Verificar se eh o menu 20 (Upload de Pagamento)
                   e se possui algum item ativo */
                IF crapmni.cditemmn = 20 AND 
                   NOT aux_flguppgt      AND 
                   NOT aux_flgrepgt      THEN
                    NEXT.
 
                CREATE tt-itens-menu.
                ASSIGN tt-itens-menu.cditemmn = crapmni.cditemmn
                       tt-itens-menu.cdsubitm = crapmni.cdsubitm
                       tt-itens-menu.nmdoitem = crapmni.nmdoitem
                       tt-itens-menu.dsurlace = REPLACE(crapmni.dsurlace,"&",
                                                        "%26")
                       tt-itens-menu.nrorditm = crapmni.nrorditm.
                       
                FOR EACH crabmni WHERE crabmni.cdcooper = par_cdcooper     AND
                                       crabmni.cditemmn = crapmni.cditemmn AND
                                       crabmni.cdsubitm > 0                AND
                                       crabmni.flgitmbl = TRUE             
                                       NO-LOCK:

                    /* se nao for liberado para operadores e tipo de conta */
                    IF (NOT CAN-DO(aux_dstipitm,STRING(crabmni.intipitm))) OR
                       (NOT crabmni.flgopepj AND par_flgtelop)             THEN
                        NEXT.
                    
                    /** Verifica permissao de pagamento **/
                    IF  crabmni.cditemmn = aux_cditmpag  AND
                        crabmni.cdsubitm = 3             AND
                        NOT aux_flgpagto                 THEN
                        NEXT.

                   /** Verifica permissao de pagamento DDA **/ 
                    IF  crabmni.cditemmn = aux_cditmdda  AND
                      ((crabmni.cdsubitm = 2             AND
                        NOT aux_flgpgdda)                OR
                       (crabmni.cdsubitm = 3             AND
                        NOT aux_flgtbdda))               THEN
                        NEXT.

                    /* Verifica permissao para o credito pre-aprovado */
                    IF crabmni.cditemmn = 4 AND crabmni.cdsubitm = 2 AND
                       NOT aux_flgaprov THEN
                       NEXT.
                    
                    /* Verifica permissao para custodia de cheque */
                    IF crabmni.cditemmn = 4 AND crabmni.cdsubitm = 5 AND
                       NOT aux_flgdesct THEN
                       NEXT.
                    
                    /* Verifica se eh o item de upload de arquivo e se 
                       possui permissao para acessar o envio do arquivo 
                       de agendamento dos pagamentos */
                    IF crabmni.cditemmn = 20 AND 
                       crabmni.cdsubitm = 1  AND 
                       NOT aux_flguppgt      THEN
                        NEXT.

                    /* Verifica se eh o item de upload de arquivo e se 
                       possui permissao para acessar arquivo de retorno (2),
                       consulta das remessas (3) e relatório (4) */
                    IF crabmni.cditemmn = 20 AND 
                      (crabmni.cdsubitm = 2  OR
                       crabmni.cdsubitm = 3  OR
                       crabmni.cdsubitm = 4) AND 
                       NOT aux_flgrepgt      THEN
                       NEXT.
                    
                    CREATE tt-itens-menu.
                    ASSIGN tt-itens-menu.cditemmn = crabmni.cditemmn
                           tt-itens-menu.cdsubitm = crabmni.cdsubitm
                           tt-itens-menu.nmdoitem = crabmni.nmdoitem
                           tt-itens-menu.dsurlace = REPLACE(crabmni.dsurlace,
                                                            "&","%26")
                           tt-itens-menu.nrorditm = crabmni.nrorditm.
                
                END. /** Fim do FOR EACH crabmni **/
                    
            END. /** Fim do FOR EACH crapmni **/                       
        END.
    ELSE
        DO: 
            IF  par_dsurlace <> "" AND par_dsurlace <> "alterar_chave.php"  THEN
                DO:
                    /* Buscar no cadastro de menu, onde a url deve estar posiionada
                       existe casos que pode estar em mais de uma posiçao, 
                       conforme o tipo de acesso (titular, operador juridico) */
                    FOR EACH crapmni 
                       WHERE crapmni.cdcooper = par_cdcooper AND
                             crapmni.flgitmbl = TRUE         AND
                             crapmni.dsurlace = par_dsurlace 
                             NO-LOCK:
                    
                      FIND FIRST crapaci WHERE    
                                 crapaci.cdcooper = par_cdcooper     AND
                                 crapaci.nrdconta = par_nrdconta     AND
                                 crapaci.nrcpfope = par_nrcpfope     AND
                                 crapaci.cditemmn = crapmni.cditemmn AND
                                 crapaci.cdsubitm = crapmni.cdsubitm AND
                                 crapaci.flgacebl = TRUE
                                 NO-LOCK NO-ERROR.

                      IF  NOT AVAILABLE crapaci  THEN
                          DO:
                              ASSIGN aux_cdcritic = 0
                                     aux_dscritic = "Alteracao nas permissoes " +
                                                    "do menu. Efetue novo " +
                                                    "acesso.".                    
                          END.        
                      ELSE
                      DO:
                        ASSIGN aux_cdcritic = 0
                               aux_dscritic = "".
                        LEAVE.
                      END.
                      
                    END. /* Fim for each crapmni*/  
                     
                    IF aux_dscritic <> "" THEN 
                    DO: 
                        RUN gera_erro (INPUT par_cdcooper,
                                       INPUT par_cdagenci,
                                       INPUT par_nrdcaixa,
                                       INPUT 1,            /** Sequencia **/
                                       INPUT aux_cdcritic,
                                       INPUT-OUTPUT aux_dscritic).
                                     
                        IF  par_flgerlog  THEN
                          RUN proc_gerar_log (INPUT par_cdcooper,
                                              INPUT par_cdoperad,
                                              INPUT aux_dscritic,
                                              INPUT aux_dsorigem,
                                              INPUT aux_dstransa,
                                              INPUT FALSE,
                                              INPUT par_idseqttl,
                                              INPUT par_nmdatela,
                                              INPUT par_nrdconta,
                                             OUTPUT aux_nrdrowid).        
                                  
                        RETURN "NOK".
                    END.       
                END.
                
            FIND crapopi WHERE crapopi.cdcooper = par_cdcooper AND
                               crapopi.nrdconta = par_nrdconta AND
                               crapopi.nrcpfope = par_nrcpfope 
                               NO-LOCK NO-ERROR.
        
            IF  NOT AVAILABLE crapopi  THEN
                DO:
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = "Operador nao cadastrado.".
                   
                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT 1,            /** Sequencia **/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
                                   
                    IF  par_flgerlog  THEN
                        RUN proc_gerar_log (INPUT par_cdcooper,
                                            INPUT par_cdoperad,
                                            INPUT aux_dscritic,
                                            INPUT aux_dsorigem,
                                            INPUT aux_dstransa,
                                            INPUT FALSE,
                                            INPUT par_idseqttl,
                                            INPUT par_nmdatela,
                                            INPUT par_nrdconta,
                                           OUTPUT aux_nrdrowid).        
                                    
                    RETURN "NOK".                
                END.

            IF  NOT par_flgtelop AND NOT crapopi.flgsitop THEN
                DO:
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = "Operador bloqueado.".
                   
                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT 1,            /** Sequencia **/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
                                   
                    IF  par_flgerlog  THEN
                        RUN proc_gerar_log (INPUT par_cdcooper,
                                            INPUT par_cdoperad,
                                            INPUT aux_dscritic,
                                            INPUT aux_dsorigem,
                                            INPUT aux_dstransa,
                                            INPUT FALSE,
                                            INPUT par_idseqttl,
                                            INPUT par_nmdatela,
                                            INPUT par_nrdconta,
                                           OUTPUT aux_nrdrowid).        
                                    
                    RETURN "NOK".
                END.
            
            ASSIGN aux_dtaltsnh = crapopi.dtaltsnh.

            IF  NOT par_flgtelop AND 
               (aux_dtaltsnh + aux_qtdiauso + aux_qtdiaalt) <= aux_datdodia  THEN
                ASSIGN aux_flgblque = TRUE.
            
            IF NOT aux_flgblque THEN
            DO:
                FOR EACH crapaci WHERE crapaci.cdcooper = par_cdcooper AND
                                       crapaci.nrdconta = par_nrdconta AND
                                       crapaci.nrcpfope = par_nrcpfope AND
                                       crapaci.flgacebl = TRUE         NO-LOCK:
                                       
                    FIND crapmni WHERE crapmni.cdcooper = par_cdcooper     AND
                                       crapmni.cditemmn = crapaci.cditemmn AND
                                       crapmni.cdsubitm = crapaci.cdsubitm AND
                                       crapmni.flgitmbl = TRUE             
                                       NO-LOCK NO-ERROR.
                                        
                    IF (NOT AVAILABLE crapmni)                              OR
                       (NOT CAN-DO(aux_dstipitm,STRING(crapmni.intipitm)))  OR 
                       (NOT crapmni.flgopepj)              THEN
                        NEXT.
    
                    IF (crapmni.nmdoitem = "Comprovante Salarial"  AND
                        crapass.inpessoa <> 1)                     OR
                       (crapmni.nmdoitem = "Informativos"          AND
                        NOT aux_flginfor)                          OR
                        crapmni.nmdoitem = "Operadores"            OR
                        crapmni.nmdoitem = "Pré-Aprovado"          OR
                       (crapmni.cditemmn = aux_cditmpag            AND 
                        NOT aux_flgprepo)                          OR
                       (crapmni.nmdoitem = "Alterar Senha"         AND
                        par_flgtelop)                              THEN
                        NEXT.
                        
                    IF  crapmni.cdsubitm > 0  THEN
                        DO:
                            FIND crabmni WHERE 
                                 crabmni.cdcooper = par_cdcooper     AND
                                 crabmni.cditemmn = crapmni.cditemmn AND
                                 crabmni.cdsubitm = 0                AND
                                 crabmni.flgitmbl = TRUE             
                                 NO-LOCK NO-ERROR.
                                 
                            IF  NOT AVAILABLE crabmni                 OR
                                NOT crabmni.flgopepj                  OR
                                NOT CAN-DO(aux_dstipitm,
                                           STRING(crabmni.intipitm))  THEN
                                NEXT.
    
                            /** Verifica permissao de pagamento **/
                            IF  crapmni.cditemmn = aux_cditmpag  AND
                                crapmni.cdsubitm = 3             AND
                                NOT aux_flgpagto                 THEN
                                NEXT.
        
                           /** Verifica permissao de pagamento DDA **/ 
                            IF  crapmni.cditemmn = aux_cditmdda  AND
                              ((crapmni.cdsubitm = 2             AND
                                NOT aux_flgpgdda)                OR
                               (crapmni.cdsubitm = 3             AND
                                NOT aux_flgtbdda))               THEN
                                NEXT.
                        END.     
                
                    CREATE tt-itens-menu.
                    ASSIGN tt-itens-menu.cditemmn = crapmni.cditemmn
                           tt-itens-menu.cdsubitm = crapmni.cdsubitm
                           tt-itens-menu.nmdoitem = crapmni.nmdoitem
                           tt-itens-menu.dsurlace = REPLACE(
                                                    crapmni.dsurlace,"&","%26")
                           tt-itens-menu.nrorditm = crapmni.nrorditm.
                                       
                END. /** Fim do FOR EACH crapaci **/
            END. /* if not aux_flgblque */
            
            IF  NOT par_flgtelop  THEN
                DO:
                    FIND crapmni WHERE crapmni.cdcooper = par_cdcooper    AND
                                       crapmni.nmdoitem = "Alterar Senha" AND
                                       crapmni.flgitmbl = TRUE
                                       NO-LOCK NO-ERROR.
                                       
                    IF  AVAILABLE crapmni  THEN
                        DO:
                            CREATE tt-itens-menu.
                            ASSIGN tt-itens-menu.cditemmn = crapmni.cditemmn
                                   tt-itens-menu.cdsubitm = crapmni.cdsubitm
                                   tt-itens-menu.nmdoitem = crapmni.nmdoitem
                                   tt-itens-menu.dsurlace =
                                            REPLACE(crapmni.dsurlace,"&","%26")
                                   tt-itens-menu.nrorditm = crapmni.nrorditm.
                        END.
                END.
        END.
        
    RETURN "OK".            

END PROCEDURE.


/*............................ PROCEDURES INTERNAS ...........................*/
PROCEDURE organiza-nomes-titulares:

    DEF INPUT-OUTPUT PARAM TABLE FOR tt-titulares.

    DEF VAR aux_contador AS INTE                                    NO-UNDO.
    DEF VAR aux_posinome AS INTE                                    NO-UNDO.
    DEF VAR aux_novonome AS CHAR                                    NO-UNDO.
    
    FOR EACH tt-titulares NO-LOCK BY tt-titulares.nmtitula:
        CREATE tt-titulares-nomes.
        BUFFER-COPY tt-titulares TO tt-titulares-nomes.
    END.
    
    FOR EACH tt-titulares-nomes EXCLUSIVE-LOCK BY tt-titulares-nomes.nmtitula:
        
        IF tt-titulares-nomes.inpessoa = 2 AND    /* Pessoa Jur */                
           tt-titulares-nomes.idastcjt = 0 AND    /* Sem Ass. Conj */
           tt-titulares-nomes.nrcpfope = 0 THEN   /* Nao é operador, é preposto */
           NEXT.

        ASSIGN aux_novonome = "".
        
        loop:
        DO aux_posinome = 1 TO NUM-ENTRIES(tt-titulares-nomes.nmtitula, " "):
        
            ASSIGN aux_contador = 0.
            FOR EACH tt-titulares NO-LOCK:
            
                IF (aux_posinome <= NUM-ENTRIES(tt-titulares.nmtitula, " ")) THEN
                    DO:
                        IF (TRIM(ENTRY(aux_posinome, tt-titulares.nmtitula, " ")) =
                            TRIM(ENTRY(aux_posinome, tt-titulares-nomes.nmtitula , " "))) THEN 
                            ASSIGN aux_contador = aux_contador + 1.
                    END.                
            END.
            
            ASSIGN aux_novonome = aux_novonome + " " + TRIM(ENTRY(aux_posinome, tt-titulares-nomes.nmtitula, " ")).
            
            /* Forçar adquirir próximo nome quando for DE, DAS, DOS (p.ex. THIAGO DOS SANTOS) */
            if (CAPS(TRIM(ENTRY(aux_posinome, tt-titulares-nomes.nmtitula, " "))) = "DE"   OR
                CAPS(TRIM(ENTRY(aux_posinome, tt-titulares-nomes.nmtitula, " "))) = "DOS"  OR
                CAPS(TRIM(ENTRY(aux_posinome, tt-titulares-nomes.nmtitula, " "))) = "DAS") THEN
                ASSIGN aux_contador = aux_contador + 1.
            
            IF (aux_contador > 1) THEN
                DO:
                    NEXT loop.
                END.
            ELSE
                DO:
                    LEAVE loop.
                END.
        END.
        
        ASSIGN tt-titulares-nomes.nmtitula = TRIM(aux_novonome).
    
    END.
    
    EMPTY TEMP-TABLE tt-titulares.
    
    FOR EACH tt-titulares-nomes NO-LOCK BY tt-titulares-nomes.nmtitula:
        CREATE tt-titulares.
        BUFFER-COPY tt-titulares-nomes TO tt-titulares.
    END.
    
END PROCEDURE.
    
    

/******************************************************************************/
/**       Procedure para confirmar e bloquear senha de acesso a conta        **/
/******************************************************************************/
PROCEDURE confirma-senha:

    DEF  INPUT        PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF  INPUT        PARAM par_nrdconta AS INTE                    NO-UNDO.
    DEF  INPUT        PARAM par_idseqttl AS INTE                    NO-UNDO.
    DEF  INPUT        PARAM par_nrcpfope LIKE crapopi.nrcpfope      NO-UNDO.
    DEF  INPUT        PARAM par_cddsenha AS CHAR                    NO-UNDO.
    DEF  INPUT-OUTPUT PARAM par_cdsennew AS CHAR                    NO-UNDO.
    DEF  INPUT        PARAM par_cdsenrep AS CHAR                    NO-UNDO.
    DEF  INPUT        PARAM par_dssenweb AS CHAR                    NO-UNDO.
    DEF  INPUT        PARAM par_dssennew AS CHAR                    NO-UNDO.
    DEF  INPUT        PARAM par_dssenrep AS CHAR                    NO-UNDO.
    DEF  INPUT        PARAM par_dssenlet AS CHAR                    NO-UNDO.
    DEF  INPUT        PARAM par_vldshlet AS LOGI                    NO-UNDO.
    DEF  INPUT        PARAM par_flgalter AS LOGI                    NO-UNDO.
    DEF  INPUT        PARAM par_vldfrase AS INTE                    NO-UNDO.
    DEF  INPUT        PARAM par_inaceblq AS INTE                    NO-UNDO.
    DEF  INPUT        PARAM par_nripuser AS CHAR                    NO-UNDO.
    DEF  INPUT        PARAM par_dscidori AS CHAR                    NO-UNDO.
    DEF  INPUT        PARAM par_dsuforig AS CHAR                    NO-UNDO.
    DEF  INPUT        PARAM par_dspaisor AS CHAR                    NO-UNDO.
                      
    DEF OUTPUT        PARAM par_dscritic AS CHAR                    NO-UNDO.
    
    DEF VAR aux_flgtrans AS LOGI                                    NO-UNDO.
    
    DEF VAR aux_contador AS INTE                                    NO-UNDO.
    DEF VAR aux_qtacerro AS INTE                                    NO-UNDO.
    DEF VAR aux_qttenper AS INTE                                    NO-UNDO.
    DEF VAR aux_qttentat AS INTE                                    NO-UNDO.
    DEF VAR aux_qtdiauso AS INTE                                    NO-UNDO. 
    DEF VAR aux_qtdiaalt AS INTE                                    NO-UNDO. 
    DEF VAR aux_qtdiablq AS INTE                                    NO-UNDO. 
    DEF VAR aux_totdiabq AS INTE                                    NO-UNDO.

    DEF VAR aux_dtaltsnh AS DATE                                    NO-UNDO. 

    DEF VAR aux_conteudo AS CHAR                                    NO-UNDO.
    DEF VAR aux_grpletr1 AS CHAR                                    NO-UNDO.
    DEF VAR aux_grpletr2 AS CHAR                                    NO-UNDO.
    DEF VAR aux_grpletr3 AS CHAR                                    NO-UNDO.
    DEF VAR aux_emailseg AS CHAR                                    NO-UNDO.

    DEF VAR aux_flsenlet AS LOGI                                    NO-UNDO.

    DEF VAR h-b1wgen0011 AS HANDLE                                  NO-UNDO.
    DEF VAR h-b1wgen0025 AS HANDLE                                  NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.

    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.
                             
    IF  NOT AVAILABLE crapcop  THEN
        DO:
            ASSIGN par_dscritic = "651 - Falta registro de controle da " + 
                                  "cooperativa - ERRO DE SISTEMA". 
            RETURN "NOK".
        END.

    FIND crapdat WHERE crapdat.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE crapdat  THEN
        DO:
            ASSIGN par_dscritic = "001 - Sistema sem data de movimento.".
            RETURN "NOK".
        END.

    FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                       crapass.nrdconta = par_nrdconta NO-LOCK NO-ERROR.
                             
    IF  NOT AVAILABLE crapass  THEN
        DO:
            ASSIGN par_dscritic = "009 - Associado nao cadastrado.".
            RETURN "NOK".
        END.

    ASSIGN aux_flgtrans = FALSE.

    /*** Buscar destinatario do email de segurança para tentativa 
                              de acesso indevida ou bloqueada  ***/
    { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }
                
    RUN STORED-PROCEDURE pc_param_sistema aux_handproc = PROC-HANDLE
       (INPUT "CRED",           /* pr_nmsistem */
        INPUT par_cdcooper,     /* pr_cdcooper */
        INPUT "EMAIL_SEGACES",  /* pr_cdacesso */
        OUTPUT ""               /* pr_dsvlrprm */
        ).

    CLOSE STORED-PROCEDURE pc_param_sistema WHERE PROC-HANDLE = aux_handproc.
    { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }
    
    ASSIGN aux_emailseg = ""
           aux_emailseg = pc_param_sistema.pr_dsvlrprm 
                          WHEN pc_param_sistema.pr_dsvlrprm <> ?. 
    
    /** Fim Busca **/

    TRANSACAO:
    
    DO TRANSACTION ON ERROR UNDO TRANSACAO, LEAVE TRANSACAO:
    
        DO aux_contador = 1 TO 10:
    
            ASSIGN par_dscritic = "".
               
            IF  par_nrcpfope = 0  THEN
                DO: 
                    FIND crapsnh WHERE crapsnh.cdcooper = par_cdcooper AND
                                       crapsnh.nrdconta = par_nrdconta AND
                                       crapsnh.idseqttl = par_idseqttl AND
                                       crapsnh.tpdsenha = 1            AND
                                       crapsnh.cdsitsnh = 1
                                       EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                    IF  NOT AVAILABLE crapsnh  THEN
                        DO:
                            IF  LOCKED crapsnh  THEN
                                DO:
                                    par_dscritic = "Registro de senha esta " +
                                                   "sendo alterado. Tente " +
                                                   "novamente.".
                                    PAUSE 1 NO-MESSAGE.
                                    NEXT.
                                END.
                            ELSE
                                par_dscritic = "Registro de senha nao " +
                                               "cadastrado ou bloqueado.".
                        END.
                END.
            ELSE
                DO:
                    FIND crapopi WHERE crapopi.cdcooper = par_cdcooper AND
                                       crapopi.nrdconta = par_nrdconta AND
                                       crapopi.nrcpfope = par_nrcpfope AND
                                       crapopi.flgsitop = TRUE
                                       EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                    IF  NOT AVAILABLE crapopi  THEN
                        DO:
                            IF  LOCKED crapopi  THEN
                                DO:
                                    par_dscritic = "Registro do operador esta" +
                                                   " sendo alterado. Tente " +
                                                   "novamente.".
                                    PAUSE 1 NO-MESSAGE.
                                    NEXT.
                                END.
                            ELSE
                                par_dscritic = "Operador nao cadastrado ou " +
                                               "bloqueado.".
                        END.
                END.        
            
            LEAVE.
            
        END. /** Fim do DO ... TO **/
    
        IF  par_dscritic <> ""  THEN
            UNDO TRANSACAO, LEAVE TRANSACAO.
        
        DO WHILE TRUE:

            IF  par_flgalter  THEN
                DO:
                    IF  par_vldfrase = 1  THEN 
                        DO:
                            par_cdsennew = obtem-nova-senha(INPUT par_cdsennew,
                                                            INPUT par_cdsenrep).
                            
                            IF  LENGTH(par_cdsennew) <> 8  THEN
                                DO:
                                    ASSIGN par_dscritic = "Senha/Frase " +
                                                          "Secreta Incorretas.".
                                    LEAVE.
                                END.
                        END.
                    
                    IF  par_dscritic = ""             AND 
                       (par_dssennew <> par_dssenrep  OR 
                        LENGTH(par_dssennew) < 10     OR  
                        LENGTH(par_dssennew) > 40)    THEN
                        DO:
                            ASSIGN par_dscritic = "Senha/Frase Secreta " +
                                                  "Incorretas.".
                            LEAVE.
                        END.
                END.
            
            IF  NOT valida-senha-numerica(INPUT (IF par_nrcpfope = 0 THEN 
                                                    crapsnh.cddsenha
                                                 ELSE
                                                    crapopi.dsdsenha),
                                          INPUT par_cddsenha)  THEN
                DO:
                    ASSIGN par_dscritic = IF  par_vldshlet      AND 
                                              par_vldfrase = 0  THEN
                                              "Senha/Letras incorretas."
                                          ELSE
                                          IF  par_vldfrase = 0  THEN
                                              "Senha numerica incorreta."
                                          ELSE
                                              "Senha/Frase Secreta Incorretas.".
                    LEAVE.
                END.
            
            IF  par_vldfrase = 1  /** Validar Frase **/         AND
              ((par_nrcpfope = 0                                AND
                crapsnh.dssenweb <> ENCODE(par_dssenweb)        AND
                crapsnh.dssenweb <> ENCODE(CAPS(par_dssenweb))  AND
                crapsnh.dssenweb <> ENCODE(LC(par_dssenweb)))   OR
               (par_nrcpfope > 0                                AND
                crapopi.dsdfrase <> ENCODE(par_dssenweb)        AND
                crapopi.dsdfrase <> ENCODE(CAPS(par_dssenweb))  AND
                crapopi.dsdfrase <> ENCODE(LC(par_dssenweb))))  THEN
                DO: 
                    ASSIGN par_dscritic = "Senha/Frase Secreta Incorretas.".
                    LEAVE.
                END.
            
            IF  par_vldshlet  THEN
                DO:
                    IF  NUM-ENTRIES(par_dssenlet,".") <> 3  THEN
                        DO:
                            ASSIGN par_dscritic = "Senha/Letras incorretas.".
                            LEAVE.
                        END.

                    ASSIGN aux_grpletr1 = ENTRY(1,par_dssenlet,".")
                           aux_grpletr2 = ENTRY(2,par_dssenlet,".")
                           aux_grpletr3 = ENTRY(3,par_dssenlet,".")
                           aux_flsenlet = FALSE.

                    RUN sistema/generico/procedures/b1wgen0025.p PERSISTENT
                        SET h-b1wgen0025.

                    IF  VALID-HANDLE(h-b1wgen0025)  THEN
                        DO: 
                            RUN valida_letras_seguranca IN h-b1wgen0025 
                                                   (INPUT par_cdcooper,
                                                    INPUT par_nrdconta,
                                                    INPUT par_idseqttl,
                                                    INPUT aux_grpletr1,
                                                    INPUT aux_grpletr2,
                                                    INPUT aux_grpletr3,
                                                    INPUT FALSE,
                                                   OUTPUT aux_flsenlet,
                                                   OUTPUT par_dscritic).

                            DELETE PROCEDURE h-b1wgen0025.

                            IF  RETURN-VALUE <> "OK"  THEN
                                DO:
                                    ASSIGN par_dscritic = "Senha/Letras " +
                                                          "incorretas.".
                                    LEAVE.
                                END.
                        END.

                    IF  NOT aux_flsenlet  THEN
                        DO:
                            ASSIGN par_dscritic = "Senha/Letras incorretas.".
                            LEAVE.
                        END.
                END.

            LEAVE.

        END. /** Fim do DO WHILE TRUE **/
        
        IF  par_dscritic <> ""  THEN
            DO:
                ASSIGN aux_qtacerro = 0.

                IF  par_inaceblq = 1  THEN
                    DO: 
                        ASSIGN aux_qttentat = 0.
                        
                        IF  crapass.inpessoa = 1  THEN
                            FIND craptab WHERE 
                                 craptab.cdcooper = par_cdcooper AND
                                 craptab.nmsistem = "CRED"       AND
                                 craptab.tptabela = "GENERI"     AND
                                 craptab.cdempres = 0            AND
                                 craptab.cdacesso = "LIMINTERNT" AND
                                 craptab.tpregist = 1            
                                 NO-LOCK NO-ERROR.
                        ELSE
                            FIND craptab WHERE 
                                 craptab.cdcooper = par_cdcooper AND
                                 craptab.nmsistem = "CRED"       AND
                                 craptab.tptabela = "GENERI"     AND
                                 craptab.cdempres = 0            AND
                                 craptab.cdacesso = "LIMINTERNT" AND
                                 craptab.tpregist = 2            
                                 NO-LOCK NO-ERROR.
                                           
                        IF  NOT AVAILABLE craptab                     OR 
                            INT(ENTRY(2,craptab.dstextab,";")) <= 0  THEN
                            DO:
                                par_dscritic = "Tabela de Limites para " +
                                               "Internet nao cadastrada.".
                           
                                UNDO TRANSACAO, LEAVE TRANSACAO.
                            END.
                        ELSE
                            aux_qttenper = INT(ENTRY(2,craptab.dstextab,";")).
                                                                        
                        IF  par_nrcpfope = 0  THEN
                            DO:
                                ASSIGN crapsnh.qtacerro = crapsnh.qtacerro + 1
                                       aux_qtacerro     = crapsnh.qtacerro.
                                    
                                IF  crapsnh.qtacerro >= aux_qttenper  THEN
                                    ASSIGN crapsnh.cdsitsnh = 2
                                           crapsnh.dtaltsit = aux_datdodia
                                           crapsnh.cdoperad = "996"
                                           par_dscritic     = "Acesso " +
                                                              "Bloqueado.".
                                ELSE
                                    ASSIGN aux_qttentat = aux_qttenper - 
                                                          crapsnh.qtacerro.
                                           
                            END.
                        ELSE
                            DO:
                                ASSIGN crapopi.qtacerro = crapopi.qtacerro + 1
                                       aux_qtacerro     = crapopi.qtacerro.
                                    
                                IF  crapopi.qtacerro >= aux_qttenper  THEN
                                    ASSIGN crapopi.flgsitop = FALSE
                                           crapopi.dtultalt = aux_datdodia
                                           par_dscritic     = "Acesso " +
                                                              "Bloqueado.".
                                ELSE
                                    ASSIGN aux_qttentat = aux_qttenper - 
                                                          crapopi.qtacerro.
                            END.
                            
                        IF  aux_qttentat > 0  THEN    
                            par_dscritic = par_dscritic + "\n" +
                                          (IF  aux_qttentat > 1  THEN    
                                               "Restam " +
                                               STRING(aux_qttentat) + 
                                               " tentativas "
                                           ELSE
                                               "Resta " +
                                               STRING(aux_qttentat) +  
                                               " tentativa ") +
                                           "para acessar a Conta On-Line.\nEm" +
                                           " caso de erro em todas as " +
                                           " tentativas possiveis, sua senha" +
                                           " sera bloqueada.".
                    END.
                
                /************************************************************/
                /** Enviar e-mail se for uma tentativa de acesso direto ao **/
                /** programa ou se for da penultima tentativa em diante.   **/
                /************************************************************/
                IF  par_inaceblq = 0                     OR
                   (par_inaceblq = 1                     AND 
                   (aux_qttenper - aux_qtacerro) < 1)    THEN
                    DO:
                         ASSIGN aux_conteudo = 
                         '<font face="Arial, Helvetica, sans-serif" size="2">' +
                         'Tentativa de acesso a Conta On-Line com senha ' +
                         'incorreta.<br><br>' +
                         'Cooperativa: <strong>' + 
                         CAPS(crapcop.nmrescop) + '</strong><br>' +
                         'Conta: <strong>' + 
                         TRIM(STRING(par_nrdconta,"zzzz,zzz,9")) + '</strong>' +
                         '<br>Data: <strong>' + 
                         STRING(aux_datdodia,"99/99/9999") + '</strong><br>' +
                         'Hor&aacute;rio: <strong>' + 
                         STRING(TIME,"HH:MM:SS") + '</strong><br>' +
                         'IP: <strong>' + par_nripuser + '</strong><br>' + 
                        (IF  par_dscidori <> ""  THEN
                         'Cidade: <strong>' + par_dscidori + '</strong><br>'
                         ELSE '') +
                        (IF  par_dsuforig <> ""  THEN
                         'Estado: <strong>' + par_dsuforig + '</strong><br>'
                         ELSE '') +                  
                        (IF  par_dspaisor <> ""  THEN
                         'Pais: <strong>' + par_dspaisor + '</strong><br>' 
                         ELSE '') +
                         'Tentativa Nr.: <strong>' + 
                        (IF  par_inaceblq = 0  THEN
                             'Tentativa direta de acesso a operacao'
                         ELSE
                             STRING(aux_qtacerro)) +
                        (IF  par_inaceblq = 1             AND
                             aux_qttenper = aux_qtacerro  THEN
                             ' (Acesso Bloqueado)'
                         ELSE
                             '') +
                         '</strong></font><br><br>'.

                        RUN sistema/generico/procedures/b1wgen0011.p PERSISTENT 
                            SET h-b1wgen0011.
                                         
                        IF  VALID-HANDLE(h-b1wgen0011)  THEN
                            DO:

                                RUN enviar_email_completo IN h-b1wgen0011 
                                   (INPUT par_cdcooper,
                                    INPUT "B1WNET0002",
                                    INPUT "AILOS" +
                                          "<cpd@ailos.coop.br>",
                                    INPUT aux_emailseg,
                                    INPUT "Conta On-Line - Senha Incorreta",
                                    INPUT "",
                                    INPUT "",
                                    INPUT aux_conteudo,
                                    INPUT FALSE).
                                                                        
                                DELETE PROCEDURE h-b1wgen0011.    
                            END.
                    END.
            END.
        ELSE
        IF  par_inaceblq = 1  THEN 
            DO:
                IF  par_nrcpfope = 0  THEN
                    ASSIGN crapsnh.qtacerro = 0.
                ELSE
                    ASSIGN crapopi.qtacerro = 0.
            END.
        /* INC0023036 - NAO BLOQUEAR MAIS A CONTA POR TEMPO DE ALTERAÇAO DE SENHA
        IF  NOT par_flgalter THEN
            DO:
                IF  crapass.inpessoa = 1  THEN
                    FIND craptab WHERE craptab.cdcooper = par_cdcooper AND
                                       craptab.nmsistem = "CRED"       AND
                                       craptab.tptabela = "GENERI"     AND
                                       craptab.cdempres = 0            AND
                                       craptab.cdacesso = "LIMINTERNT" AND
                                       craptab.tpregist = 1   
                                       NO-LOCK NO-ERROR.
                ELSE
                    FIND craptab WHERE craptab.cdcooper = par_cdcooper AND
                                       craptab.nmsistem = "CRED"       AND
                                       craptab.tptabela = "GENERI"     AND
                                       craptab.cdempres = 0            AND
                                       craptab.cdacesso = "LIMINTERNT" AND
                                       craptab.tpregist = 2   
                                       NO-LOCK NO-ERROR.

                IF  NOT AVAIL craptab  THEN
                    par_dscritic = "Registro LIMINTERNT nao encontrado.".
                ELSE
                    DO:
                        ASSIGN aux_qtdiauso = INTEGER(ENTRY(17,craptab.dstextab,";"))
                               aux_qtdiaalt = INTEGER(ENTRY(18,craptab.dstextab,";"))
                               aux_qtdiablq = INTEGER(ENTRY(19,craptab.dstextab,";"))
                               aux_dtaltsnh = IF par_nrcpfope = 0 THEN
                                                 crapsnh.dtaltsnh
                                              ELSE
                                                 crapopi.dtaltsnh.
        
                        ASSIGN aux_totdiabq = (aux_qtdiauso + aux_qtdiaalt + 
                                               aux_qtdiablq).
        
                        IF  aux_datdodia >= (aux_dtaltsnh + aux_totdiabq) THEN
                            DO:
                                IF  par_nrcpfope = 0 THEN
                                    ASSIGN crapsnh.cdsitsnh = 2
                                           crapsnh.dtblutsh = aux_datdodia
                                           crapsnh.dtaltsit = aux_datdodia
                                           crapsnh.cdoperad = "996".
                                ELSE
                                    ASSIGN crapopi.flgsitop = FALSE
                                           crapopi.dtblutsh = aux_datdodia
                                           crapopi.dtultalt = aux_datdodia.
        
                                IF  aux_totdiabq = 1  THEN
                                    ASSIGN par_dscritic = "Acesso Bloqueado. " +
                                                   "Senha nao alterada no ultimo dia.". 
                                ELSE
                                   ASSIGN par_dscritic = "Acesso Bloqueado. " +
                                                   "Senha nao alterada nos ultimos " + 
                                                    STRING(aux_totdiabq) + " dias.". 
                            END.
                    END.
            END.
        */
        ASSIGN aux_flgtrans = TRUE.
        
    END. /** Fim do DO TRANSACTION - TRANSACAO **/
    
    IF  NOT aux_flgtrans AND par_dscritic = ""  THEN
        par_dscritic = "Nao foi possivel verificar a senha.".
     

    IF  par_dscritic <> ""  THEN
        RETURN "NOK".

    RETURN "OK".
        
END PROCEDURE.


/******************************************************************************/
/**       Procedure para gerar senha aleatoria para operador da conta        **/
/******************************************************************************/
PROCEDURE gerar-senha:

    DEF OUTPUT PARAM par_dsdsenha AS CHAR                           NO-UNDO.
    
    DEF VAR aux_nrcalcul AS CHAR                                    NO-UNDO.
    DEF VAR aux_nrrandom AS CHAR                                    NO-UNDO.
        
    DEF VAR aux_contador AS INTE                                    NO-UNDO.
    DEF VAR aux_multipli AS INTE                                    NO-UNDO.    
    
    DO WHILE TRUE:
    
        DO WHILE TRUE:
            
            aux_multipli = INTE(SUBSTR(STRING(TIME,"99999"),5,1)).
            
            IF  aux_multipli <> 1 AND aux_multipli <> 5  THEN
                LEAVE.
                                                        
        END. /** Fim do DO WHILE TRUE **/
                                                                
        ASSIGN par_dsdsenha = ""
               aux_nrrandom = STRING(RANDOM(0,99999999),"99999999").
                
        DO aux_contador = 1 TO 8:            
                                    
            ASSIGN aux_nrcalcul = STRING(INTE(SUBSTR(aux_nrrandom,
                                         aux_contador,1)) * aux_multipli)
                   par_dsdsenha = par_dsdsenha +
                                  SUBSTR(aux_nrcalcul,LENGTH(aux_nrcalcul),1).
                                  
        END. /** Fim do DO ... TO **/
                                          
        IF  par_dsdsenha <> "00000000"  THEN
            LEAVE.
            
    END. /** Fim do DO WHILE TRUE **/

    RETURN "OK".
    
END PROCEDURE.


/******************************************************************************/
/**       Procedure para montar conteudo de e-mail para envio da senha       **/
/******************************************************************************/
PROCEDURE conteudo-email:

    DEF  INPUT PARAM par_nmrescop AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dsendweb AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dsdsenha AS CHAR                           NO-UNDO.
 
    DEF OUTPUT PARAM par_conteudo AS CHAR                           NO-UNDO.
    
    par_conteudo = '<font face="Arial, Helvetica, sans-serif" size="2">' +
                   'Prezado(a) <strong>' + par_nmoperad + '</strong>.<br><br>' +
                   '</font>' +
                   '<font face="Arial, Helvetica, sans-serif" size="2">' +
                   'Voc&ecirc; est&aacute; recebendo uma senha ' +
                   'num&eacute;rica de oito d&iacute;gitos para o acesso ' +
                   '&agrave; Conta On-Line.<br>No primeiro acesso o sistema ' +
                   'solicitar&aacute; uma frase secreta de no m&iacute;nimo ' +
                   'dez e no m&aacute;ximo quarenta caracteres que ' +
                   'poder&aacute; contemplar letras e n&uacute;meros.<br><br>' +
                   'Sua senha atual &eacute; <strong>' +
                   par_dsdsenha + '</strong>.<br><br>' +
                   '</font>' +
                   '<hr width="100%" size="1" noshade>' +
                   '<br>' +
                   '<font face="Arial, Helvetica, sans-serif" size="2">' +
                   'Atenciosamente,<br>' + CAPS(par_nmrescop) + '.' +
                   '</font>'.

    RETURN "OK".
 
END PROCEDURE.

/******************************************************************************/
/**           Procedure para obter dados de origem do IP do usuario          **/
/** Essas informacoes sao enviadas pelo script busca_xml.php no servidor web **/
/******************************************************************************/
PROCEDURE formata-dados-origem-ip:

    DEF  INPUT PARAM par_dsorigip AS CHAR                           NO-UNDO.
    
    DEF OUTPUT PARAM par_dscidori AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_dsuforig AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_dspaisor AS CHAR                           NO-UNDO.
    
    IF  NUM-ENTRIES(par_dsorigip,"#") <> 3  THEN
        RETURN "OK".

    ASSIGN par_dspaisor = TRIM(ENTRY(1,par_dsorigip,"#"))
           par_dsuforig = TRIM(ENTRY(2,par_dsorigip,"#"))
           par_dscidori = TRIM(ENTRY(3,par_dsorigip,"#")).

    RETURN "OK".
 
END PROCEDURE.
 

/******************************************************************************/
/**         Procedure para validar a senha no historico                      **/
/******************************************************************************/
PROCEDURE validar-senha-hsh:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrcpfope LIKE crapopi.nrcpfope             NO-UNDO.
    DEF  INPUT PARAM par_cddsenha AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dssenweb AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdvalida AS INTE                           NO-UNDO.

    DEF OUTPUT PARAM par_dscritic AS CHAR                           NO-UNDO.

    /**********************************************************************/
    /**    par_cdvalida = 0 --> VALIDA SENHA NUMERICA                    **/
    /**    par_cdvalida = 1 --> VALIDA SENHA NUMERICA E FRASE SECRETA    **/
    /**    par_cdvalida = 2 --> VALIDA FRASE SECRETA                     **/
    /**********************************************************************/
       

    FOR EACH craphsh WHERE craphsh.cdcooper = par_cdcooper
                       AND craphsh.nrdconta = par_nrdconta
                       AND craphsh.idseqttl = par_idseqttl
                       AND craphsh.tpdsenha = 1
                       AND craphsh.nrcpfope = par_nrcpfope
                       AND craphsh.cddsenha <> ""
                       AND craphsh.dssenweb <> ""
                       NO-LOCK:
        
        IF (par_cdvalida = 0 AND ENCODE(par_cddsenha) = craphsh.cddsenha) OR
           (par_cdvalida = 1 AND ENCODE(par_cddsenha) = craphsh.cddsenha) THEN
            par_dscritic = "A Senha numerica deve ser diferente das " +
                           "ultimas 3 vezes.".
        ELSE 
        IF (par_cdvalida = 1 AND ENCODE(CAPS(par_dssenweb)) = craphsh.dssenweb) 
            OR
           (par_cdvalida = 2 AND ENCODE(CAPS(par_dssenweb)) = craphsh.dssenweb) 
            THEN
            par_dscritic = "A frase secreta deve ser diferente das " +
                           "ultimas 3 vezes.".

        IF par_dscritic <> "" THEN
            RETURN "NOK".

    END.

    RETURN "OK".
    
END.

/******************************************************************************/
/**         Procedure para cadastrar a senha no historico                    **/
/******************************************************************************/
PROCEDURE cadastrar-senha-hsh:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrcpfope LIKE crapopi.nrcpfope             NO-UNDO.
    DEF  INPUT PARAM par_cddsenha AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dssenweb AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_tpdsenha AS INTE                           NO-UNDO.

    DEF OUTPUT PARAM par_dscritic AS CHAR                           NO-UNDO.
    
    DEF VAR aux_flgfirst AS LOGI                                    NO-UNDO.
    DEF VAR aux_flgencod AS LOGI INIT TRUE                          NO-UNDO.
    DEF VAR aux_idseqsnh AS INTE                                    NO-UNDO.

    IF  par_cddsenha <> "" AND par_dssenweb = "" THEN
        DO:
            FIND LAST craphsh WHERE craphsh.cdcooper = par_cdcooper AND
                                    craphsh.nrdconta = par_nrdconta AND
                                    craphsh.idseqttl = par_idseqttl AND
                                    craphsh.tpdsenha = par_tpdsenha AND
                                    craphsh.nrcpfope = par_nrcpfope
                                    EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

            IF  AVAIL craphsh AND craphsh.dssenweb = ""  THEN
                ASSIGN craphsh.dtcadsnh = aux_datdodia
                       craphsh.hrcadsnh = TIME
                       craphsh.cddsenha = ENCODE(par_cddsenha).
            ELSE
                DO:
                    ASSIGN aux_idseqsnh = IF  AVAIL craphsh  THEN 
                                              craphsh.idseqsnh + 1
                                          ELSE
                                              1.
                    
                    CREATE craphsh.
                    ASSIGN craphsh.cdcooper = par_cdcooper
                           craphsh.nrdconta = par_nrdconta
                           craphsh.idseqttl = par_idseqttl
                           craphsh.tpdsenha = par_tpdsenha
                           craphsh.nrcpfope = par_nrcpfope
                           craphsh.idseqsnh = aux_idseqsnh
                           craphsh.dtcadsnh = aux_datdodia
                           craphsh.hrcadsnh = TIME
                           craphsh.cddsenha = ENCODE(par_cddsenha)
                           craphsh.dssenweb = "".
                    VALIDATE craphsh.
                END.
        END.
    ELSE
        DO:
            IF  par_cddsenha = "" AND par_dssenweb <> ""  THEN
                DO:
                    FIND LAST craphsh WHERE craphsh.cdcooper = par_cdcooper AND
                                            craphsh.nrdconta = par_nrdconta AND
                                            craphsh.idseqttl = par_idseqttl AND
                                            craphsh.tpdsenha = par_tpdsenha AND
                                            craphsh.nrcpfope = par_nrcpfope
                                            EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                    IF  AVAIL craphsh  THEN
                        DO:
                            ASSIGN par_cddsenha = craphsh.cddsenha
                                   aux_flgencod = FALSE.
                            DELETE craphsh.
                        END.
                END.

            ASSIGN aux_flgfirst = TRUE.
    
            FOR EACH craphsh WHERE craphsh.cdcooper = par_cdcooper AND
                                   craphsh.nrdconta = par_nrdconta AND
                                   craphsh.idseqttl = par_idseqttl AND
                                   craphsh.tpdsenha = par_tpdsenha AND
                                   craphsh.nrcpfope = par_nrcpfope
                                   EXCLUSIVE-LOCK BY craphsh.idseqsnh DESC:
                
                IF  aux_flgfirst  THEN
                    DO:
                        ASSIGN aux_flgfirst = FALSE.
        
                        IF  craphsh.idseqsnh >= 3 THEN
                            DO:
                                DELETE craphsh.
                                NEXT.
                            END.
                    END.
    
                ASSIGN craphsh.idseqsnh = craphsh.idseqsnh + 1.

            END.
            
            CREATE craphsh.
            ASSIGN craphsh.cdcooper = par_cdcooper
                   craphsh.nrdconta = par_nrdconta
                   craphsh.idseqttl = par_idseqttl
                   craphsh.tpdsenha = par_tpdsenha
                   craphsh.nrcpfope = par_nrcpfope
                   craphsh.idseqsnh = 1
                   craphsh.dtcadsnh = aux_datdodia
                   craphsh.hrcadsnh = TIME
                   craphsh.cddsenha = IF  aux_flgencod  THEN 
                                          ENCODE(par_cddsenha)
                                      ELSE
                                          par_cddsenha
                   craphsh.dssenweb = ENCODE(CAPS(par_dssenweb)).
            VALIDATE craphsh.
        END.

    RETURN "OK".

END.
