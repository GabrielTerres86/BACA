/*************************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +----------------------------------------+-----------------------------------------+
  | Rotina Progress                        | Rotina Oracle PLSQL                     |
  +----------------------------------------+-----------------------------------------+
  |   gera-arquivo-intranet                | GENE0002.pc_gera_arquivo_intranet       |
  |   gera-pdf-impressao                   | GENE0002.pc_gera_pdf_impressao          |
  |   efetua-copia-pdf                     | GENE0002.pc_efetua_copia_pdf            |
  |   envia-arquivo-web                    | EXTR0002.pc_envia_arquivo_web           |  
  |   obtem-valores-central-risco          | CADA0001.pc_obtem_valores_central_risco |
  +----------------------------------------+-----------------------------------------+

  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.

  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - Daniel Zimmermann    (CECRED)
   - Marcos Martini       (SUPERO)

**************************************************************************************/





/* ...........................................................................

   Programa: b1wgen0024.p
   Autor   : Gabriel
   Data    : Junho/2010                        Ultima Atualizacao: 14/10/2015

   Dados referentes ao programa:
   
   Objetivo: Juntar as funcoes em comum entre as operacoes de Emprestimo,
             descontos, e limite de credito. Gerar impressoes. Disponibilizar
             as mesmas na intranet da cooperativa.
             
   Alteracoes: 28/07/2010 - Projeto de melhorias de operacoes (Gabriel). 

               31/08/2010 - Incluido caminho completo na gravacao dos arquivos
                            nos diretorios "arq" e "rl" (Elton).
                            
               21/09/2010 - Criar nova procedure executa-envio-email para
                            tratar envio de email das propostas dentro das BO's 
                            (David)
                                                              
               22/09/2010 - Arrumar alteraçao do dia 31/08/2010 (Gabriel). 
               
               22/11/2010 - Arrumar validacao do segundo aval (Gabriel).
               
               24/11/2010 - Chamar a procedure que gera o PDF na Impressao
                            da Improp para o Ayllos Web (Gabriel) .
                            
               30/11/2010 - Incluir novos parametros da BO b1wgen0056 (David).
               
               11/01/2011 - Passar com parametro a conta na validacao dos
                            avalistas (Gabriel).
                            
               21/01/2011 - Antes de chamar a procedure lista_avalistas,
                            validar se o craplim esta AVAIL (Guilherme).
                            
               09/02/2011 - Melhorada leitura da craptdb para performance
                            (Guilherme).
                                     
               28/02/2011 - Alterado valores das variaveis aux_nrtopico e
                            aux_nritetop na procedure dados-analise-proposta.                             
                            (Fabricio)
                                         
               29/03/2011 - Incluir rotina de envio de arquivo pro Ayllos
                            Web (Gabriel).
               
               16/04/2011 - Incluida validação de CEP existente. (André - DB1)
                                                                                                                   
               28/04/2011 - Tratar a monta contratos para nao aceitar
                            arquivos em branco ou inexistentes (Gabriel) 
                            
               13/07/2011 - Arrumar critica na validacao dos avalistas (Gabriel).
               
               08/08/2011 - Gerar impressao na procedure monta-contratos com id
                            de terminal sendo passado por parametro. ID do 
                            Ayllos WEB e obtido com logica diferente (David).
                            
               24/11/2011 - Alimentado o campo tt-rendimento.dsjusren na 
                            procedure rendimentos-cadastro-proposta e incluido o
                            parametro dsjusren na procedure grava-dados-cadastro
                            (Adriano).
                            
               30/01/2012 - Criado procedure gera-arquivo-intranet, para
                            disponibilizar os relatorios gerado pelo Ayllos
                            Web. (Fabricio)
                            
               14/02/2012 - Utilizar arquivo de configuracao na chamada do 
                            gnupdf.pl quando for proposta de seguro residencial
                            (Diego).             
                            
               28/02/2012 - Utilizar script "gnupdf_ft12.pl" para gerar PDF da 
                            proposta de seguro residencial(tamanho de fonte 12
                            e negrito) (Diego).
                            
               27/03/2012 - Incluido parametro crapcop.dsdircop na chamada
                            do script CriaPDF.sh, na procedure 
                            gera-arquivo-intranet. (Fabricio)
                            
               10/04/2012 - Incluido index crapopf2 na consulta da data-base.
                            (Irlan).       

               10/07/2012 - Criar procedure efetua-copia-pdf (David).

               03/09/2012 - Verificar se o 2.ttl ou conjuge eh cooperado da 
                            cooperativa em questao antes de consultar os seus
                            dados (Gabriel).     

               01/10/2012 - Tratamento para evitar erros nos bens do cooperado
                            (Gabriel).                

               08/05/2013 - Comentada validação de Notas promissorias na
                            procedure 'valida-avalistas' (Lucas)

               13/06/2013 - Verificar se arquivos .lst e pdf existem antes
                            de enviar para a sede (Gabriel).             

               20/06/2013 - Campos BNDES  no grava-dados-proposta (BO 0024)
                            (Guilherme/Supero)
                            
               22/07/2013 - Alimentar campo crapprp.dtmvtolt (Diego).
               
               18/07/2013 - Paginação da tela IMPROP (Gabriel).
               
               26/07/2013 - Tratamento antes de exclusao de arquivos (Jean).
               
               30/09/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).
                            
               19/12/2013 - Adicionado validate para as tabelas crapprp,
                           crapjfn (Tiago).
                           
               03/01/2014 - Aumentado o format da lista de arquivos de 
                            aux_nomedarq FORMAT "x(70)" para aux_nomedarq 
                            FORMAT "x(78)" na procedure lista-contratos-sede 
                            (Carlos)
                            
               03/01/2014 - Criticas de busca de crapage alteradas de 15 p 962
                            (Carlos)
                            
               24/02/2014 - Adicionado param. de paginacao em procedure
                             obtem-dados-emprestimos em BO 0002.(Jorge)
                             
               21/03/2014 - Ajuste na inclusao, alteracao e exclusao dos bens
                            para melhoria de log da tela Altera (Carlos)
                            
                            Limpar bens da proposta apenas para nao Alienados
                            CRAPBPR flgalien = FALSE (Guilherme/Supero)
                            
               02/04/2014 - Ajuste leitura crapopf para ganho performace no 
                            data server (Daniel).
                            
               15/04/2014 - Correcao leitura crapopf. (Daniel).
               
               06/05/2014 - Correcao para verificar idseqbem vindo da proposta.
                            (Jorge/Rosangela) SD - 150872 
                            
               27/06/2014 - Alteracao de parametro, de: par_nmdatela
                             por: par_dsoperac (procedure grava-dados-cadastro).
               Motivo: Com esta alteracao, eu passo a receber nesta procedure
                       a operacao que esta sendo executada, e nao mais a tela
                       que esta sendo usada para a operacao, tendo em vista
                       que todas as operacoes (desconto de titulo, 
                       desconto de cheque, proposta de limite de credito, 
                       proposta de cartao de credito, alem da proposta de 
                       emprestimo) que usam esta procedure, sao executadas na
                       tela ATENDA. Tudo isso pois, agora, eu passo a tratar os
                       bens do avalista da proposta, se existir, apenas quando
                       a operacao for igual 'a 'PROPOSTA EMPRESTIMO', pois eh
                       a unica operacao dentre as citadas acima, onde o operador
                       pode fazer a manutencao desse cadastro dos bens do 
                       avalista. A nao existencia desta condicao, fazia com que
                       os bens de um avalista fossem eliminados nesta procedure,
                       caso a operacao fosse diferente de 'PROPOSTA EMPRESTIMO',
                       em virtude da nao manutencao de bens para as demais
                       operacoes; fazendo com que o parametro com os bens do
                       avalista entrassem nesta procedure com valor vazio e 
                       dessa forma a procedure entendia que o operador havia
                       excluido todos os bens do aval pela tela da manutencao,
                       mas o que nao eh verdade.
                       (Chamado 166383) - (Fabricio)
               
               22/08/2014 - Novo campo de consulta ao conjuge (Jonata-RKAM).
               
               04/09/2014 - #189652 Criadas as procedures 
                         gera-pdf-impressao-sem-pcl e envia-arquivo-web-sem-pcl 
                         p/ a tela imprel (Carlos)
               
               06/11/2014 - Alterado verificacao do parametro par_dsoperac
                            recebido na procedure grava-dados-cadastro,
                            de: 'PROPOSTA EMPRESTIMO' para: 'PROP.EMPREST'.
                            Motivo: Erro ao tentar gravar registro de log
                            quando entrar nessa condicao com mudanca nos bens
                            do aval (craplgm). (Fabricio)
                            
               26/11/2014 - Trazer a conta e cpf do conjuge independente de
                            ser co-responsavel do contrato (Jonata-RKAM).
                            
               28/11/2014 - Retirar consulta do 2.do titular (Jonata-RKAM).       
               
               20/01/2015 - Substituicao da procedure consulta-aplicacoes pela 
                            obtem-dados-aplicacoes e foi adicionada uma chamada 
                            para a procedure pc_busca_saldos_aplicacoes.
                            (Carlos Rafael Tanholi - Projeto Novos Produtos de Captacao)
                            
               26/01/2015 - Alterado o formato do campo nrctremp para 8 
                            caracters (Kelvin - 233714)
               
               12/02/2015 - Foi visto que o parâmetro par_inpessoa estava sendo 
                            passado fixo "0" e não havia nenhuma forma de 
                            validação onde mudaria esse valor, fazendo com que 
                            sempre houvesse valores diferentes na validação,
                            caindo então sempre na critica "Tipo de Natureza errado".
                            O que foi feito foi comentar essa validação. 
                            SD 252962  (Kelvin/Gielow) 
                            
               08/04/2015 - Consultas automatizadas para o limite de credito
                            (Gabriel-RKAM).
                            
               17/08/2015 - Ajuste no retorno da procedure grava-dados-proposta.
                            Adicionado variavel de controle aux_dsreturn.
                            (Jorge/Gielow) - SD 320666 
                            
               14/10/2015 - Ajuste em determinar idseqbem da crapbpr na proc.
                            grava-dados-proposta. (Jorge/Gielow) SD - 325844

               21/12/2017 - Ajuste para nao alterar nome da empresa do conjuge no emprestimo.
                            PRJ-339(Odirlei-AMcom)
               
.............................................................................*/

{ sistema/generico/includes/b1wgen0001tt.i }
{ sistema/generico/includes/b1wgen0002tt.i }
{ sistema/generico/includes/b1wgen0004tt.i }
{ sistema/generico/includes/b1wgen0021tt.i }
{ sistema/generico/includes/b1wgen0024tt.i }
{ sistema/generico/includes/b1wgen0038tt.i }
{ sistema/generico/includes/b1wgen0043tt.i }
{ sistema/generico/includes/b1wgen0056tt.i }   
{ sistema/generico/includes/b1wgen0059tt.i }
{ sistema/generico/includes/b1wgen0069tt.i }
{ sistema/generico/includes/b1wgen9999tt.i }
 
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_erro.i    }
{ sistema/generico/includes/var_oracle.i   }
                                                                   
DEF VAR aux_cdcritic AS INTE                                        NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                        NO-UNDO.
DEF VAR aux_msgconta AS CHAR                                        NO-UNDO.                                                                    

DEF VAR h-b1wgen0001 AS HANDLE                                      NO-UNDO.
DEF VAR h-b1wgen0002 AS HANDLE                                      NO-UNDO.
DEF VAR h-b1wgen0004 AS HANDLE                                      NO-UNDO.
DEF VAR h-b1wgen0081 AS HANDLE                                      NO-UNDO.
DEF VAR h-b1wgen0021 AS HANDLE                                      NO-UNDO.
DEF VAR h-b1wgen0043 AS HANDLE                                      NO-UNDO.
DEF VAR h-b1wgen0056 AS HANDLE                                      NO-UNDO.
DEF VAR h-b1wgen0059 AS HANDLE                                      NO-UNDO.     
DEF VAR h-b1wgen0060 AS HANDLE                                      NO-UNDO.  
DEF VAR h-b1wgen0069 AS HANDLE                                      NO-UNDO.
DEF VAR h-b1wgen9999 AS HANDLE                                      NO-UNDO.

DEF VAR aux_vlsldrgt AS DEC                                         NO-UNDO.
DEF VAR aux_vlsldtot AS DEC                                         NO-UNDO.
DEF VAR aux_vlsldapl AS DEC                                         NO-UNDO.

DEF STREAM str_1.
DEF STREAM str_2.


/****************************************************************************/
/**       Procedure para solicitar envio da proposta para o PA Sede       **/
/****************************************************************************/
PROCEDURE enviar-contratos-pdf-email:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cdrelato AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmarquiv AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_tpctrato AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctrato AS INTE                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_flconfir AS LOGI                                    NO-UNDO.

    DEF VAR aux_nmarqimp AS CHAR                                    NO-UNDO.
    DEF VAR aux_nmarqpdf AS CHAR                                    NO-UNDO.
    
    EMPTY TEMP-TABLE tt-erro.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".

    FORM SKIP(1)
         "Efetuar envio de e-mail para Sede?" AT 3
         aux_flconfir NO-LABEL FORMAT "S/N"
         SKIP(1)
         WITH OVERLAY ROW 14 CENTERED WIDTH 42 TITLE COLOR NORMAL "Destino"
         FRAME f_email.
        
    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE crapcop  THEN
        DO:
            ASSIGN aux_cdcritic = 651
                   aux_dscritic = "".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,     /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            RETURN "NOK".
        END.

    ASSIGN aux_flconfir = FALSE.
    
    /* Este update foi implementado aqui pois no Ayllos Web nao pode ser 
       reaproveitada esta procedure. Só é utilizada no caracter  */
    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
    
        UPDATE aux_flconfir WITH FRAME f_email.
        LEAVE.

    END. /** Fim do DO WHILE TRUE **/

    HIDE FRAME f_email NO-PAUSE.
    
    IF  KEY-FUNCTION(LASTKEY) = "END-ERROR"  OR
        NOT aux_flconfir                     THEN
        RETURN "OK".

    /** Procedure recebe nome do arquivo assim: rl/NOMEARQUIVO.ex **/
    ASSIGN aux_nmarqimp = "/usr/coop/" + crapcop.dsdircop + "/" + par_nmarquiv
           aux_nmarqpdf = "/usr/coop/" + crapcop.dsdircop + "/" + par_nmarquiv +
                          ".pdf".

    RUN gera-pdf-impressao (INPUT aux_nmarqimp,
                            INPUT aux_nmarqpdf).
    
    RUN executa-envio-email (INPUT par_cdcooper, 
                             INPUT par_cdagenci, 
                             INPUT par_nrdcaixa, 
                             INPUT par_cdoperad, 
                             INPUT par_nmdatela, 
                             INPUT par_idorigem, 
                             INPUT par_dtmvtolt, 
                             INPUT par_cdrelato, 
                             INPUT aux_nmarqimp, 
                             INPUT aux_nmarqpdf,
                             INPUT par_nrdconta, 
                             INPUT par_tpctrato, 
                             INPUT par_nrctrato, 
                            OUTPUT TABLE tt-erro).
    
    IF SEARCH(aux_nmarqpdf) <> ? THEN
        UNIX SILENT VALUE("rm " + aux_nmarqpdf + " 2>/dev/null").
                            
    IF  RETURN-VALUE = "NOK"  THEN
        RETURN "NOK".
    
    RETURN "OK".
    
END PROCEDURE.


/****************************************************************************/
/** Procedure para executar o envio da proposta para o PA Sede via e-mail **/
/****************************************************************************/
PROCEDURE executa-envio-email:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cdrelato AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmarqimp AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmarqpdf AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_tpctrato AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctrato AS INTE                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_nmarqpdf AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsagenci AS CHAR                                    NO-UNDO.    
    DEF VAR aux_contador AS INTE                                    NO-UNDO.
    DEF VAR aux_flgtrans AS LOGI                                    NO-UNDO.
    
    DEF VAR h-b1wgen0011 AS HANDLE                                  NO-UNDO.
    
    EMPTY TEMP-TABLE tt-erro.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".

    DO WHILE TRUE:
                                      
        FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

        IF  NOT AVAILABLE crapcop  THEN
            DO:
                ASSIGN aux_cdcritic = 651
                       aux_dscritic = "".
                LEAVE.
            END.
                                        
        FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                           crapass.nrdconta = par_nrdconta NO-LOCK NO-ERROR.

        IF  NOT AVAILABLE crapass  THEN
            DO:
                ASSIGN aux_cdcritic = 9
                       aux_dscritic = "".
                LEAVE.
            END.
        
        FIND crapage WHERE crapage.cdcooper = par_cdcooper     AND
                           crapage.cdagenci = crapass.cdagenci NO-LOCK NO-ERROR.
   
        IF  NOT AVAILABLE crapage  THEN
            DO:
                ASSIGN aux_cdcritic = 962
                       aux_dscritic = "".
                LEAVE.
            END.
                 
        FIND craprel WHERE craprel.cdcooper = par_cdcooper AND
                           craprel.cdrelato = par_cdrelato NO-LOCK NO-ERROR.
                        
        IF  NOT AVAILABLE craprel  THEN
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Relatorio nao cadastrado - " +
                                      STRING(par_cdrelato,"999") + ".". 
                LEAVE.
            END.
      
        IF  TRIM(craprel.dsdemail) = ""  THEN
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Necessario cadastro de e-mail. Tela " +
                                      "PAMREL.".
                LEAVE.
            END.

        /** Deixar esta validacao por ultimo, instancia da BO **/
        RUN sistema/generico/procedures/b1wgen0011.p PERSISTENT 
            SET h-b1wgen0011.
        
        IF  NOT VALID-HANDLE(h-b1wgen0011)  THEN
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Handle invalido para BO b1wgen0011.".
                LEAVE.
            END.
         
        LEAVE.

    END. /** Fim do DO WHILE TRUE **/

    IF  aux_cdcritic <> 0   OR
        aux_dscritic <> ""  THEN
        DO:
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,     /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                                               
            RETURN "NOK".      
        END.                   

    ASSIGN aux_flgtrans = FALSE.

    DO TRANSACTION ON ERROR UNDO,  LEAVE
                   ON ENDKEY UNDO, LEAVE:

        /** Atualizar Envio a Sede na tabela das propostas **/
        DO aux_contador = 1 TO 10:
            
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "".

            FIND crapprp WHERE crapprp.cdcooper = par_cdcooper AND
                               crapprp.nrdconta = par_nrdconta AND
                               crapprp.nrctrato = par_nrctrato AND
                               crapprp.tpctrato = par_tpctrato
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
      
            IF  NOT AVAIL crapprp  THEN
                DO:
                    IF  LOCKED crapprp  THEN
                        DO: 
                            ASSIGN aux_cdcritic = 77.
                            NEXT.
                        END.
                    ELSE
                        ASSIGN aux_cdcritic = 510.
                END.
            
            LEAVE.
          
        END. /** Fim Lock crapprp **/

        IF  aux_cdcritic <> 0   OR
            aux_dscritic <> ""  THEN
            UNDO, LEAVE.

        ASSIGN aux_nmarqpdf = "crrl" + STRING(craprel.cdrelato,"999") +
                              "_" + par_cdoperad + "_" + STRING(TIME) + "_" + 
                              STRING(par_nrdconta) + ".pdf"
               aux_dsagenci = "PA " + STRING(crapage.cdagenci,"999") + " " +
                              crapage.nmresage.
    
        /* Se nao existe arquivo TXT ou PDF, volta */
        IF   SEARCH(par_nmarqimp) = ?   OR 
             SEARCH(par_nmarqpdf) = ?  THEN
             DO:
                 ASSIGN aux_dscritic = "Arquivo inexistente. Tente novamente.".
                 UNDO, LEAVE.
             END.

        /** Copiar o arquivo para /log (TELA IMPROP) **/  
        UNIX SILENT VALUE ("cp " + par_nmarqimp + " /usr/coop/" + 
                           TRIM(crapcop.dsdircop) + "/log/crrl" + 
                           STRING(par_cdrelato,"999") + "_" + 
                           STRING(crapage.cdagenci,"999") + "_" + 
                           TRIM(STRING(crapass.nrdconta,"zzzzzzz9")) + "_" +
                           TRIM(STRING(par_nrctrato,"zzzzzz9")) + "_" +
                           STRING(TIME,"999999") + "_" +  
                           STRING(par_dtmvtolt,"99999999") + 
                           ".lst 2>/dev/null").

        /** Copia PDF para diretorio salvar **/
        UNIX SILENT VALUE ("cp " + par_nmarqpdf + " /usr/coop/" + 
                            crapcop.dsdircop + "/salvar/" + aux_nmarqpdf + 
                            " 2>/dev/null").

        /** Copia PDF para diretorio de anexos para email **/
        UNIX SILENT VALUE ("cp " + par_nmarqpdf + " /usr/coop/" + 
                           crapcop.dsdircop + "/converte/" + aux_nmarqpdf +
                           " 2>/dev/null").

        /** Envia PDF por e-mail **/
        RUN enviar_email IN h-b1wgen0011 (INPUT par_cdcooper,
                                          INPUT par_nmdatela,
                                          INPUT craprel.dsdemail, 
                                          INPUT "crrl" + 
                                                STRING(par_cdrelato,"999") + 
                                                " - Conta/dv: " +
                                                TRIM(STRING(par_nrdconta,
                                                            "zzzz,zzz,9")) + 
                                                " - " + aux_dsagenci,
                                          INPUT aux_nmarqpdf,
                                          INPUT TRUE).
        
        ASSIGN crapprp.flgenvio = TRUE
               aux_flgtrans     = TRUE.

    END. /** Fim do DO TRANSACTION **/

    DELETE PROCEDURE h-b1wgen0011.

    IF  NOT aux_flgtrans  THEN
        DO:
            IF  aux_cdcritic = 0   AND 
                aux_dscritic = ""  THEN
                ASSIGN aux_dscritic = "Nao foi possivel enviar o e-mail.".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,     /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                                               
            RETURN "NOK".      
        END.                   

    RETURN "OK".

END PROCEDURE.


/****************************************************************************/
/**          Procedure para converter proposta para o formato PDF          **/
/****************************************************************************/
PROCEDURE gera-pdf-impressao:

    DEF  INPUT PARAM par_nmarqimp AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmarqpdf AS CHAR                           NO-UNDO.
    
    /** Retirar caracteres especiais para impressoras matriciais **/
    UNIX SILENT VALUE ("cat " + par_nmarqimp + 
                       " | /usr/local/cecred/bin/convertePCL.pl > " +
                       par_nmarqimp + "_PCL 2>/dev/null ").

    /*
    Para tratar nova formatacao de arquivo PDF(tamanho de fonte 12 + negrito),
    sera utilizado o script "gnupdf_ft12". Demais PDF's (relatorios batch, 
    Ayllos WEB) gerados pelo sistema continuam utilizando "gnupdf"
    */
    IF   par_nmarqimp MATCHES "*proposta_seguro*" THEN 
         /** Converte documento para o formato PDF  **/
         UNIX SILENT VALUE ("gnupdf_ft12.pl --in " + par_nmarqimp + "_PCL " +
                            "--conf fonte12.conf" + " " + 
                            "--out " + par_nmarqpdf + " 2>/dev/null"). 
    ELSE
         /** Converte documento para o formato PDF **/        
         UNIX SILENT VALUE ("gnupdf.pl --in " + par_nmarqimp + "_PCL " +
                            "--out " + par_nmarqpdf + " 2>/dev/null").
        
    IF SEARCH(par_nmarqimp) <> ? THEN
        UNIX SILENT VALUE ("rm " + par_nmarqimp + "_PCL 2>/dev/null").
     
    RETURN "OK".

END PROCEDURE.

/****************************************************************************
         Procedure para converter proposta para o formato PDF (IMPREL)
         sem Retirar caracteres especiais para impressoras matriciais      
****************************************************************************/
PROCEDURE gera-pdf-impressao-sem-pcl:

    DEF  INPUT PARAM par_nmarqimp AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmarqpdf AS CHAR                           NO-UNDO.
    
    UNIX SILENT VALUE ("gnupdf.pl --in " + par_nmarqimp +
                              " --out " + par_nmarqpdf + " 2>/dev/null").

    IF SEARCH(par_nmarqimp) <> ? THEN
        UNIX SILENT VALUE ("rm " + par_nmarqimp + " 2>/dev/null").
     
    RETURN "OK".

END PROCEDURE.


/******************************************************************************
 Validar dados antes de listar os contratos que foram enviados para a sede. 
 (Tela IMPROP)
******************************************************************************/

PROCEDURE valida-dados-contratos:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtiniper AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtfimper AS DATE                           NO-UNDO.

    DEF  OUTPUT PARAM TABLE FOR tt-erro.


    EMPTY TEMP-TABLE tt-erro.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".


    DO WHILE TRUE:

        IF   par_nrdconta > 0  THEN
             DO:
                 FIND crapass WHERE crapass.cdcooper = par_cdcooper   AND
                                    crapass.nrdconta = par_nrdconta   
                                    NO-LOCK NO-ERROR.

                 IF   NOT AVAIL crapass  THEN
                      DO:
                          aux_cdcritic = 9.
                          LEAVE.
                      END.                     
             END.

        IF   par_cdagenci > 0   THEN
             DO:
                 FIND crapage WHERE crapage.cdcooper = par_cdcooper   AND
                                    crapage.cdagenci = par_cdagenci
                                    NO-LOCK NO-ERROR.


                 IF   NOT AVAIL crapage THEN
                      DO:
                          aux_cdcritic = 962.
                          LEAVE.
                      END.
             END.

        IF   par_dtiniper <> ?   THEN
             DO:
                 IF   par_dtiniper > par_dtmvtolt   THEN
                      DO:
                          aux_cdcritic = 13.
                          LEAVE.
                      END.
                            
                 IF   par_dtfimper = ? THEN
                      DO:
                          aux_cdcritic = 13.
                          LEAVE.
                       END.
             END.
                 
                
        IF   par_dtfimper <> ?   THEN
             DO:
                 IF   par_dtfimper > par_dtmvtolt   THEN
                      DO:
                          aux_cdcritic = 13.
                          LEAVE.
                      END.

                 IF   par_dtiniper = ?   THEN
                      DO:
                          aux_cdcritic = 13.
                          LEAVE.
                       END.    

                 IF   par_dtiniper > par_dtfimper   THEN
                      DO:
                          aux_cdcritic = 13.  
                          LEAVE.
                      END.
             END.

        LEAVE.

    END.

    IF   aux_cdcritic <> 0   OR
         aux_dscritic <> ""  THEN
         DO:
             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,     /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).

             RETURN "NOK".   
         END.

    RETURN "OK".

END PROCEDURE.


/******************************************************************************
 Obter os contratos que foram enviados para a sede. (Tela IMPROP)
******************************************************************************/

PROCEDURE lista-contratos-sede:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nmrelato AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtiniper AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtfimper AS DATE                           NO-UNDO.
    
    DEF  INPUT PARAM par_nrregist AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nriniseq AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_qtregist AS INTE                           NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-contratos.

    DEF  VAR         aux_contador AS INTE                           NO-UNDO.
    DEF  VAR         aux_nmrelato AS CHAR                           NO-UNDO.
    DEF  VAR         aux_nomedarq AS CHAR                           NO-UNDO.
    DEF  VAR         aux_nrdconta AS INTE                           NO-UNDO.
    DEF  VAR         aux_cdagenci AS INTE                           NO-UNDO.
    DEF  VAR         aux_dtmvtolt AS DATE                           NO-UNDO.
    DEF  VAR         aux_tpctrato AS INTE                           NO-UNDO.
    DEF  VAR         aux_vloperac AS DECI                           NO-UNDO.
    DEF  VAR         aux_dsoperac AS CHAR                           NO-UNDO.
    DEF  VAR         aux_nrregist AS INTE                           NO-UNDO.


    EMPTY TEMP-TABLE tt-contratos.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_nrregist = par_nrregist.
    
    /* Todos os contratos  */
    IF    par_nmrelato = "5"   THEN
          DO:
              ASSIGN par_nmrelato = "crrl488,crrl517,crrl518,crrl519".              
          END.
    ELSE
          DO: /* Atribuir os contratos correspondentes */
              DO aux_contador = 1 TO NUM-ENTRIES(par_nmrelato):
          
                 IF   aux_nmrelato <> ""  THEN
                      aux_nmrelato = aux_nmrelato + ",".

                 CASE ENTRY(aux_contador,par_nmrelato):
            
                    WHEN "1" THEN aux_nmrelato = aux_nmrelato + "crrl488".
                    WHEN "2" THEN aux_nmrelato = aux_nmrelato + "crrl517".
                    WHEN "3" THEN aux_nmrelato = aux_nmrelato + "crrl518".
                    WHEN "4" THEN aux_nmrelato = aux_nmrelato + "crrl519".
                  
                 END CASE.                    
          
              END.

              ASSIGN par_nmrelato = aux_nmrelato
                     aux_nmrelato = "".

          END.
             
    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

    /* Para todos os relatorios passados por paramentro */
    DO aux_contador = 1 TO NUM-ENTRIES(par_nmrelato):

        ASSIGN aux_nmrelato = ENTRY(aux_contador,par_nmrelato).

        /* Lista todos os relatorios com*/     
        INPUT STREAM str_1 THROUGH VALUE("ls /usr/coop/" + 
                                         TRIM(crapcop.dsdircop) +
                                         "/log/" + aux_nmrelato + "*" +
                                         " 2>/dev/null") NO-ECHO.

        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:  /* Para todos os arquivos ... */
 
           SET STREAM str_1 aux_nomedarq FORMAT "x(78)".

           /* Retirar o '.lst'  */
           ASSIGN aux_nomedarq = REPLACE(aux_nomedarq,".lst","") 
               
                  aux_cdagenci = INTE(ENTRY(2,aux_nomedarq,"_)"))
                  aux_nrdconta = INTE(ENTRY(3,aux_nomedarq,"_"))
                  aux_dtmvtolt = DATE (ENTRY(6,aux_nomedarq,"_"))
                  aux_vloperac = 0
                  aux_dsoperac = "".  
                  
           /* Se informou o PA */
           IF   par_cdagenci > 0  THEN
                DO:
                    /* Se pa Informado diferente de PA do arquivo */
                    IF  par_cdagenci <> aux_cdagenci   THEN
                        NEXT.
                END.
              
           /* Se informou a conta */
           IF   par_nrdconta > 0  THEN
                DO:
                    /* Se conta informada diferente de conta do arquivo */
                    IF   aux_nrdconta <> par_nrdconta THEN
                         NEXT.
                END.

           /* Se data do periodo informado */
           IF   par_dtiniper <> ?   AND
                par_dtfimper <> ?   THEN
                DO:
                    /* Se data fora do periodo informado */
                    IF   par_dtiniper > aux_dtmvtolt   OR
                         par_dtfimper < aux_dtmvtolt   THEN
                         NEXT.
                END.

           FIND crapass WHERE crapass.cdcooper = par_cdcooper   AND
                              crapass.nrdconta = aux_nrdconta
                              NO-LOCK NO-ERROR.
              
           /* Pegar tipo de contrato */
           IF   ENTRY(1,aux_nomedarq,"_") MATCHES "*crrl488*" THEN
                ASSIGN aux_dsoperac = "Emprestimo"
                       aux_tpctrato = 90.
           ELSE
           IF   ENTRY(1,aux_nomedarq,"_") MATCHES "*crrl517*" THEN 
                ASSIGN aux_dsoperac = "Lim. Credito"
                       aux_tpctrato = 1.
           ELSE
           IF   ENTRY(1,aux_nomedarq,"_") MATCHES "*crrl518*"  THEN 
                ASSIGN aux_dsoperac = "Des. cheque"
                       aux_tpctrato = 2.
           ELSE
           IF   ENTRY(1,aux_nomedarq,"_") MATCHES "*crrl519*" THEN 
                ASSIGN aux_dsoperac = "Des. titulo"
                       aux_tpctrato = 3.

           IF   aux_tpctrato = 90   THEN
                DO:
                    FIND crawepr WHERE 
                         crawepr.cdcooper = par_cdcooper   AND
                         crawepr.nrdconta = aux_nrdconta   AND
                         crawepr.nrctremp = INTE(ENTRY(4,aux_nomedarq,"_"))
                         NO-LOCK NO-ERROR.

                    /* Se contrato nao existe mais */
                    IF   NOT AVAIL crawepr THEN 
                         NEXT.

                    aux_vloperac = crawepr.vlemprst.
                END.
          ELSE
                DO:
                    FIND craplim WHERE 
                         craplim.cdcooper = par_cdcooper   AND
                         craplim.nrdconta = aux_nrdconta   AND
                         craplim.tpctrlim = aux_tpctrato   AND
                         craplim.nrctrlim = INTE(ENTRY(4,aux_nomedarq,"_"))
                         NO-LOCK NO-ERROR.
    
                    /* Se contrato nao existe mais */
                    IF   NOT AVAIL craplim   THEN
                         NEXT.

                    aux_vloperac = craplim.vllimite.
                END.

          ASSIGN par_qtregist = par_qtregist + 1.

          /* controles da paginação */
          IF   par_qtregist < par_nriniseq  OR
               par_qtregist >= (par_nriniseq + par_nrregist) THEN
               NEXT.         

          IF   aux_nrregist > 0   THEN
               DO: 
                   CREATE tt-contratos.
                   ASSIGN tt-contratos.cdagenci = aux_cdagenci
                          tt-contratos.nrdconta = aux_nrdconta
                          tt-contratos.nmprimtl = crapass.nmprimtl WHEN AVAIL crapass
                          tt-contratos.nrctrato = INTE(ENTRY(4,aux_nomedarq,"_"))
                          tt-contratos.dtmvtolt = DATETIME (aux_dtmvtolt,
                                                            INTE(ENTRY(5,aux_nomedarq,"_")) * 1000 )
                          tt-contratos.dsdimpri = "N"
                          tt-contratos.nomedarq = aux_nomedarq + ".lst"
                          tt-contratos.vloperac = aux_vloperac
                          tt-contratos.dsoperac = aux_dsoperac.
               END.

          ASSIGN aux_nrregist = aux_nrregist - 1.

        END. /* Fim ls do contrato */
        
    END.

    RETURN "OK".

END PROCEDURE.

PROCEDURE efetua-copia-pdf:

    DEF INPUT PARAM par_cdcooper AS INTE NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE NO-UNDO.
    DEF INPUT PARAM par_nmarqpdf AS CHAR NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    EMPTY TEMP-TABLE tt-erro.

    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

    IF  NOT AVAIL crapcop  THEN
        DO:
            ASSIGN aux_cdcritic = 651
                   aux_dscritic = "".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,     /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            RETURN "NOK".
        END.

    UNIX SILENT VALUE ('sudo /usr/bin/su - scpuser -c ' +
                       '"scp ' + par_nmarqpdf + ' scpuser@' + aux_srvintra +
                       ':/var/www/ayllos/documentos/' + crapcop.dsdircop +
                       '/temp/" 2>/dev/null').

    RETURN "OK".

END PROCEDURE.

/****************************************************************************
 Montar todos os contratos em um arquivo só (Para impressao na tela IMPROP)
****************************************************************************/

PROCEDURE monta-contratos:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nomedarq AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dsiduser AS CHAR                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM par_nmarquiv AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_nmarqpdf AS CHAR                           NO-UNDO.

    DEF VAR          aux_contador AS INTE                           NO-UNDO.
    DEF VAR          aux_nmarqpdf AS CHAR                           NO-UNDO.


    EMPTY TEMP-TABLE tt-erro.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".
    
    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.
    
    ASSIGN par_nmarquiv = "/usr/coop/" + TRIM(crapcop.dsdircop) +    
                          "/rl/" + par_dsiduser + STRING(TIME) + ".ex"
           aux_nmarqpdf = REPLACE(par_nmarquiv,".ex",".pdf").
             
    /* Para cada contrato colocar no mesmo arquivo  */
    DO aux_contador = 1 TO NUM-ENTRIES(par_nomedarq):

       /* Arquivo nao existe mais */
       IF   SEARCH(ENTRY(aux_contador,par_nomedarq)) = ?  THEN 
            NEXT.                                              

       UNIX SILENT VALUE ("cat " + ENTRY(aux_contador,par_nomedarq) + " >> " +
                           par_nmarquiv + " 2>/dev/null").

    END.

    /* Se nao criou nenhum arquivo , critica */
    IF   SEARCH(par_nmarquiv) = ?   THEN
         DO:
             ASSIGN aux_dscritic = "Nao existe nenhum arquivo a imprimir.".

             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,     /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).
             RETURN "NOK".    
         END.

    /* Se for do Ayllos Web , criar o PDF e copiar para o servidor */
    IF   par_idorigem = 5   THEN 
         DO:                         
             /* Gerar o PDF */
             RUN gera-pdf-impressao (INPUT par_nmarquiv,
                                     INPUT aux_nmarqpdf).

             UNIX SILENT VALUE ('sudo /usr/bin/su - scpuser -c ' +
                  '"scp ' + aux_nmarqpdf + ' scpuser@' + aux_srvintra +
                  ':/var/www/ayllos/documentos/' + crapcop.dsdircop +
                  '/temp/" 2>/dev/null').    


             /* Remover arquivos nao mais necessarios */
             IF SEARCH(par_nmarquiv) <> ? THEN
                UNIX SILENT VALUE ("rm " + par_nmarquiv + "* 2>/dev/null").

             /* Remover arquivos nao mais necessarios */
             IF SEARCH(aux_nmarqpdf) <> ? THEN
                UNIX SILENT VALUE ("rm " + aux_nmarqpdf + "* 2>/dev/null").
                                                     

             /* Nome do PDF para devolver como parametro */
             par_nmarqpdf = ENTRY(NUM-ENTRIES(aux_nmarqpdf,"/"),aux_nmarqpdf,"/"). 

         END.
  
    RETURN "OK".

END PROCEDURE.



/*****************************************************************************
  Excluir os contratos da tela IMPROP (Opcao E)
*****************************************************************************/

PROCEDURE deleta-contratos:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nomedarq AS CHAR                           NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    

    DEF VAR          aux_contador AS INTE                           NO-UNDO.
    DEF VAR          aux_nomedarq AS CHAR                           NO-UNDO.
    DEF VAR          aux_nrdconta AS INTE                           NO-UNDO.
    DEF VAR          aux_nrctremp AS INTE                           NO-UNDO.
    DEF VAR          aux_dsoperac AS CHAR                           NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".

    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

    DO aux_contador = 1 TO NUM-ENTRIES(par_nomedarq):

        ASSIGN aux_nomedarq = REPLACE(ENTRY(aux_contador,par_nomedarq),".lst","")
               aux_nrdconta = INTE(ENTRY(3,aux_nomedarq,"_"))
               aux_nrctremp = INTE(ENTRY(4,aux_nomedarq,"_")).
          
        /* Pegar tipo de contrato */
        CASE SUBSTR(ENTRY(1,aux_nomedarq,"_"),5):
                
               WHEN "crrl488" THEN aux_dsoperac = " de Emprestimo.".                                          
               WHEN "crrl517" THEN aux_dsoperac = " de Lim. Credito.".                                        
               WHEN "crrl518" THEN aux_dsoperac = " de Des. cheque.".                              
               WHEN "crrl519" THEN aux_dsoperac = " de Des. titulo.".
                                       
        END.
        
        IF SEARCH(ENTRY(aux_contador,par_nomedarq)) <> ? THEN
           UNIX SILENT VALUE ("rm " + ENTRY(aux_contador,par_nomedarq) + " 2>/dev/null").

        /* Logar as informacoes pra tela LOGTEL */
        UNIX SILENT VALUE("echo " + STRING(par_dtmvtolt, "99/99/9999") + " " +
                        STRING(TIME,"HH:MM:SS") + "' --> ' Operador "        +
                        par_cdoperad + " - excluiu da conta/dv "             +
                        STRING(aux_nrdconta,"zzzz,zzz,9") + ", o contrato "  +
                        STRING(aux_nrctremp,"zz,zzz,zz9")  + aux_dsoperac     +  
                        " >> /usr/coop/" + TRIM(crapcop.dsdircop) +
                        "/log/improp.log").
                        
    END.
    
    RETURN "OK". 

END PROCEDURE.


/*****************************************************************************
 Trazer os bens do cooperado nas propostas de credito (crapprp) ou no 
 Proprio cadastro do cooperado (crapbem), dependendo a situacao .
*****************************************************************************/

PROCEDURE bens-cadastro-proposta:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_tpctrato AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctrato AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-crapbem.


    DEF VAR par_flgcadas  AS LOGI                                   NO-UNDO.
   

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-crapbem.


    /* Se for diferente de consulta , verifica de onde tem q pegar os dados */
    IF    CAN-DO("A,I",STRING(par_cddopcao))  THEN
          DO:
              RUN verifica-contrato-proposta (INPUT par_cdcooper,
                                              INPUT par_cdagenci,
                                              INPUT par_nrdcaixa,
                                              INPUT par_nrdconta,
                                              INPUT par_tpctrato,
                                              INPUT par_nrctrato,
                                              INPUT par_cddopcao,
                                              OUTPUT TABLE tt-erro,
                                              OUTPUT par_flgcadas).

              IF   RETURN-VALUE <> "OK"   THEN
                   RETURN "NOK".          
          END.              
    ELSE
          par_flgcadas = FALSE. /* Pegar da proposta (Consulta, Exclusao) */
          


    IF   par_flgcadas   THEN /* Pegar dados do cadastro */ 
         DO:
             RUN sistema/generico/procedures/b1wgen0056.p 
                                  PERSISTENT SET h-b1wgen0056.

             /* Buscar os bens do cooperado da crapbem (Tela Contas ) */
             RUN Busca-Dados IN h-b1wgen0056 (INPUT par_cdcooper,
                                              INPUT par_cdagenci,
                                              INPUT par_nrdcaixa,
                                              INPUT par_cdoperad,
                                              INPUT par_nrdconta,
                                              INPUT par_idorigem,
                                              INPUT par_nmdatela,
                                              INPUT 1,
                                              INPUT par_flgerlog,
                                              INPUT 0,
                                              INPUT "",
                                              INPUT ?,
                                              OUTPUT aux_msgconta,
                                              OUTPUT TABLE tt-crapbem,
                                              OUTPUT TABLE tt-erro).

             DELETE PROCEDURE h-b1wgen0056.
        
             IF   RETURN-VALUE <> "OK"   THEN
                  RETURN "NOK".

         END.
    ELSE 
         DO:
             /* Senao traz os dados dos bens da proposta */
             RUN bens-proposta (INPUT par_cdcooper,
                                INPUT par_cdagenci,
                                INPUT par_nrdcaixa,
                                INPUT par_cdoperad,
                                INPUT par_nmdatela,
                                INPUT par_idorigem,
                                INPUT par_dtmvtolt,
                                INPUT par_nrdconta,
                                INPUT par_tpctrato,
                                INPUT par_nrctrato,
                                INPUT FALSE,
                                OUTPUT TABLE tt-erro,
                                OUTPUT TABLE tt-crapbem). 

             IF   RETURN-VALUE <> "OK" THEN
                  RETURN "NOK". 
         END.
   
    RETURN "OK".

END PROCEDURE.


/*****************************************************************************
 Trazer os bens na proposta de credito.
*****************************************************************************/

PROCEDURE bens-proposta:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_tpctrato AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctrato AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-crapbem.


    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-crapbem.


    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".


    /* Tabela dos bens da proposta */
    FOR EACH crapbpr WHERE crapbpr.cdcooper = par_cdcooper   AND
                           crapbpr.nrdconta = par_nrdconta   AND
                           crapbpr.tpctrpro = par_tpctrato   AND
                           crapbpr.nrctrpro = par_nrctrato   AND
                           crapbpr.flgalien = FALSE          NO-LOCK:

        CREATE tt-crapbem.
        BUFFER-COPY crapbpr TO tt-crapbem.

    END.

    RETURN "OK".

END PROCEDURE.


/******************************************************************************
Trazer os rendimentos do cooperado da proposta de credito ou do proprio 
cadastro , dependendo a situacao 
******************************************************************************/

PROCEDURE rendimentos-cadastro-proposta:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_tpctrato AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctrato AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-tipo-rendi.
    DEF OUTPUT PARAM TABLE FOR tt-rendimento.
    DEF OUTPUT PARAM TABLE FOR tt-faturam.


    DEF VAR par_qtregist AS INTE                                    NO-UNDO.
    DEF VAR par_flgcadas AS LOGI                                    NO-UNDO.
    DEF VAR aux_contador AS INTE                                    NO-UNDO.
    DEF VAR aux_dsdrendi AS CHAR                                    NO-UNDO.
    DEF VAR aux_msgconta AS CHAR                                    NO-UNDO.

    DEF VAR h-b1wgen0038 AS HANDLE                                  NO-UNDO.

    DEF VAR par_inpessoa AS INTE                                    NO-UNDO.

    
    RUN sistema/generico/procedures/b1wgen0059.p 
                                    PERSISTENT SET h-b1wgen0059.

    /* Busca todos os tipos / descricao dos rendimentos */
    RUN busca-tipo-rendi IN h-b1wgen0059 (INPUT par_cdcooper,
                                          INPUT 0,
                                          INPUT "",
                                          INPUT 99999,
                                          INPUT 0,
                                          OUTPUT par_qtregist,                                     
                                          OUTPUT TABLE tt-tipo-rendi).
    DELETE PROCEDURE h-b1wgen0059.

    IF   CAN-DO("A,I,C",par_cddopcao) THEN
         DO:               
             RUN verifica-contrato-proposta (INPUT par_cdcooper,
                                             INPUT par_cdagenci,
                                             INPUT par_nrdcaixa,
                                             INPUT par_nrdconta,
                                             INPUT par_tpctrato,
                                             INPUT par_nrctrato,
                                             INPUT par_cddopcao,
                                             OUTPUT TABLE tt-erro,
                                             OUTPUT par_flgcadas).

             IF   RETURN-VALUE <> "OK"   THEN
                  RETURN "NOK".
                                     
         END.
    ELSE    
         par_flgcadas = FALSE. 
          
 
    FIND crapass WHERE crapass.cdcooper = par_cdcooper   AND
                       crapass.nrdconta = par_nrdconta 
                       NO-LOCK NO-ERROR.

    /* Cadastro de propostas */
    FIND crapprp WHERE crapprp.cdcooper = par_cdcooper   AND
                       crapprp.nrdconta = par_nrdconta   AND
                       crapprp.tpctrato = par_tpctrato   AND
                       crapprp.nrctrato = par_nrctrato  
                       NO-LOCK NO-ERROR.

    /* Se tiver conjuge ainda */
    FIND crapcje WHERE crapcje.cdcooper = par_cdcooper  AND
                       crapcje.nrdconta = par_nrdconta  AND
                       crapcje.idseqttl = 1 
                       NO-LOCK NO-ERROR.

    CREATE tt-rendimento.
    ASSIGN tt-rendimento.inpessoa = crapass.inpessoa
           tt-rendimento.vloutras = crapprp.vloutras WHEN AVAIL crapprp
           tt-rendimento.flgconju = AVAIL (crapcje).

    IF   AVAIL crawepr   THEN
         ASSIGN tt-rendimento.inconcje = (crawepr.inconcje = 1).
                                          
    IF   par_flgcadas   THEN /* Pegar dados do cadastro */
         DO:
             RUN sistema/generico/procedures/b1wgen0038.p 
                        PERSISTENT SET h-b1wgen0038.

             RUN obtem-endereco IN h-b1wgen0038
                                     (INPUT  par_cdcooper,
                                      INPUT  par_cdagenci,
                                      INPUT  par_nrdcaixa,
                                      INPUT  par_cdoperad,
                                      INPUT  par_nmdatela,
                                      INPUT  par_idorigem,
                                      INPUT  par_nrdconta,
                                      INPUT  1, /* Tit */
                                      INPUT  par_flgerlog,
                                      OUTPUT aux_msgconta,
                                      OUTPUT par_inpessoa,
                                      OUTPUT TABLE tt-erro,
                                      OUTPUT TABLE tt-endereco-cooperado).

             DELETE PROCEDURE h-b1wgen0038.

             IF   RETURN-VALUE <> "OK"  THEN
                  RETURN "NOK".

             FIND FIRST tt-endereco-cooperado NO-LOCK NO-ERROR.

             /* Valor do Aluguel */
             IF   AVAIL tt-endereco-cooperado  THEN
                  IF   tt-endereco-cooperado.incasprp = 3 THEN /* Aluguel */
                       tt-rendimento.vlalugue = tt-endereco-cooperado.vlalugue.

             IF   crapass.inpessoa = 1   THEN
                  DO:
                      FIND crapttl WHERE crapttl.cdcooper = par_cdcooper   AND
                                         crapttl.nrdconta = par_nrdconta   AND
                                         crapttl.idseqttl = 1
                                         NO-LOCK NO-ERROR.

                      RUN sistema/generico/procedures/b1wgen0060.p
                           PERSISTENT SET h-b1wgen0060.

                      ASSIGN tt-rendimento.vlsalari = crapttl.vlsalari
                             tt-rendimento.dsjusren = crapttl.dsjusren.
                             

                      /* Rendimentos */
                      DO aux_contador = 1 TO 6:
                    
                          ASSIGN tt-rendimento.tpdrendi[aux_contador] = 
                                            crapttl.tpdrendi[aux_contador]

                                 tt-rendimento.vldrendi[aux_contador] =
                                            crapttl.vldrendi[aux_contador].

                          DYNAMIC-FUNCTION 
                              ("BuscaTipoRendimento" IN h-b1wgen0060,
                              
                              INPUT  par_cdcooper,
                              INPUT  tt-rendimento.tpdrendi[aux_contador],
                              OUTPUT aux_dsdrendi,
                              OUTPUT aux_dscritic).

                          ASSIGN tt-rendimento.dsdrendi[aux_contador] = aux_dsdrendi.

                      END.

                      DELETE PROCEDURE h-b1wgen0060.

                      IF   AVAIL crapcje   THEN
                           DO:
                               ASSIGN tt-rendimento.flgdocje = crapprp.flgdocje
                                                               WHEN AVAIL crapprp
                                      tt-rendimento.nrctacje = crapcje.nrctacje
                                      tt-rendimento.nrcpfcjg = crapcje.nrcpfcjg.

                               IF   crapcje.nrctacje <> 0   THEN
                                     DO:
                                         FIND crapttl WHERE 
                                              crapttl.cdcooper = par_cdcooper       AND
                                              crapttl.nrdconta = crapcje.nrctacje   AND
                                              crapttl.idseqttl = 1
                                              NO-LOCK NO-ERROR.

                                         IF   AVAIL crapttl   THEN
                                              ASSIGN tt-rendimento.vlsalcon = crapttl.vlsalari
                                                     tt-rendimento.nrcpfcjg = crapttl.nrcpfcgc 
                                                                   WHEN tt-rendimento.flgdocje

                                                     tt-rendimento.nmextemp = crapttl.nmextemp.
                                     END.
                               ELSE
                                     DO:
                                         /* Se o conjuge eh segundo titular da conta */
                                         FIND crapttl WHERE
                                              crapttl.cdcooper = par_cdcooper   AND
                                              crapttl.nrdconta = par_nrdconta   AND
                                              crapttl.idseqttl > 1              AND
                                              CAN-DO("1,4",STRING(crapttl.cdgraupr))  
                                              NO-LOCK NO-ERROR.

                                         IF  AVAIL crapttl   THEN
                                             ASSIGN tt-rendimento.nrctacje = crapttl.nrdconta   
                                                    tt-rendimento.nrcpfcjg = crapttl.nrcpfcgc.

                                         ASSIGN tt-rendimento.vlsalcon = crapcje.vlsalari
                                                tt-rendimento.nmextemp = crapcje.nmextemp. 

                                     END.
                                    
                           END.
                  
                  END. /* Fim Pessoa fisica */
             ELSE
                  DO:
                       RUN sistema/generico/procedures/b1wgen9999.p
                                            PERSISTENT SET h-b1wgen9999.

                       RUN calcula-faturamento IN h-b1wgen9999 
                                              (INPUT par_cdcooper,
                                               INPUT par_cdagenci,
                                               INPUT par_nrdcaixa,
                                               INPUT par_idorigem,
                                               INPUT par_nrdconta,
                                               INPUT par_dtmvtolt,
                                             OUTPUT tt-rendimento.vlmedfat).

                       DELETE PROCEDURE h-b1wgen9999.
                                                                                                  
                  END.  /* Fim pessoa juridica */
                 
         END.
    ELSE       /* Pegar os dados da proposta */
         DO:    
             ASSIGN aux_contador = 0.

             RUN sistema/generico/procedures/b1wgen0060.p
                           PERSISTENT SET h-b1wgen0060.


             /* Rendimentos da proposta */
             FOR EACH craprpr WHERE craprpr.cdcooper = par_cdcooper   AND
                                    craprpr.nrdconta = par_nrdconta   AND
                                    craprpr.tpctrato = par_tpctrato   AND
                                    craprpr.nrctrato = par_nrctrato   NO-LOCK:
                                   
                 DYNAMIC-FUNCTION ("BuscaTipoRendimento" IN h-b1wgen0060,
                               
                              INPUT  par_cdcooper,
                              INPUT  craprpr.tpdrendi,
                              OUTPUT aux_dsdrendi,
                              OUTPUT aux_dscritic).

                 ASSIGN aux_contador = aux_contador + 1
                        tt-rendimento.tpdrendi[aux_contador] = 
                            craprpr.tpdrendi
                        tt-rendimento.vldrendi[aux_contador] = 
                            craprpr.vldrendi
                        tt-rendimento.dsdrendi[aux_contador] =
                            aux_dsdrendi
                        tt-rendimento.dsjusren = craprpr.dsjusren.
                 
             END. /* Rendimentos */

             DELETE PROCEDURE h-b1wgen0060.

             /* Se tiver registro de proposta */
             IF   AVAIL crapprp   THEN
                  DO:
                      ASSIGN tt-rendimento.vlsalari = crapprp.vlsalari
                             tt-rendimento.vlalugue = crapprp.vlalugue 
                             tt-rendimento.vlsalcon = crapprp.vlsalcon
                             tt-rendimento.nmextemp = crapprp.nmempcje
                             tt-rendimento.vlmedfat = crapprp.vlmedfat.
                                    
                      IF    crapass.inpessoa = 1   THEN
                            DO:
                                IF   AVAIL crapcje    THEN
                                     ASSIGN tt-rendimento.flgdocje = 
                                                    crapprp.flgdocje
                                            tt-rendimento.nrctacje = 
                                                    crapprp.nrctacje
                                            tt-rendimento.nrcpfcjg =
                                                    crapprp.nrcpfcje.                            
                            END.
                  END.
            
         END.
         
    /* Se pessoa juridica pegar concentracao maior cliente e faturamento */
    IF   crapass.inpessoa > 1  THEN
         DO:
             /* Buscar dados de faturamento */
             RUN sistema/generico/procedures/b1wgen0069.p 
                                  PERSISTENT SET h-b1wgen0069.

             RUN Busca_Dados IN h-b1wgen0069 (INPUT par_cdcooper,
                                              INPUT par_cdagenci,
                                              INPUT par_nrdcaixa,
                                              INPUT par_cdoperad,
                                              INPUT par_nmdatela,
                                              INPUT par_idorigem,
                                              INPUT par_nrdconta,
                                              INPUT 1, /* Titular */
                                              INPUT par_flgerlog,
                                              INPUT 0, /* Todos os faturam. */
                                              OUTPUT TABLE tt-faturam,
                                              OUTPUT TABLE tt-erro).
             DELETE PROCEDURE h-b1wgen0069.

             IF   RETURN-VALUE <> "OK" THEN
                  RETURN "NOK".

             FIND crapjfn WHERE crapjfn.cdcooper = par_cdcooper AND
                                crapjfn.nrdconta = par_nrdconta
                                NO-LOCK NO-ERROR.
              
             IF   AVAIL crapjfn   THEN
                  ASSIGN tt-rendimento.perfatcl = crapjfn.perfatcl. 
          
         END.
   
    RETURN "OK".

END PROCEDURE.


/******************************************************************************
 Buscar os dados correspondente a analise da proposta.
******************************************************************************/

PROCEDURE dados-analise-proposta:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_inpessoa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_tpctrato AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctrato AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-dados-analise.
    DEF OUTPUT PARAM TABLE FOR tt-itens-topico-rating.


    DEF VAR          aux_nrcpfcgc AS DECI                           NO-UNDO.
    DEF VAR          aux_nrtopico AS INTE                           NO-UNDO.
    DEF VAR          aux_nritetop AS INTE                           NO-UNDO.
    DEF VAR          aux_nrdindex AS INTE                           NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-valores-rating.
    
    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".

    DO WHILE TRUE:

       /* Deixar as criticas das instancias das BO por ultimo */
       CREATE tt-dados-analise.

       FIND crapprp WHERE crapprp.cdcooper = par_cdcooper   AND
                          crapprp.nrdconta = par_nrdconta   AND
                          crapprp.tpctrato = par_tpctrato   AND
                          crapprp.nrctrato = par_nrctrato
                          NO-LOCK NO-ERROR.

       IF   AVAIL crapprp THEN
            ASSIGN tt-dados-analise.dtoutris = crapprp.dtoutris
                   tt-dados-analise.vlsfnout = crapprp.vlsfnout.

       RUN sistema/generico/procedures/b1wgen0043.p
                                     PERSISTENT SET h-b1wgen0043.

       IF   NOT VALID-HANDLE(h-b1wgen0043)  THEN
            DO:
                aux_dscritic = "Handle invalido para a BO b1wgen0043.".
                LEAVE.
            END.
                
       RUN busca_dados_rating IN h-b1wgen0043 
                           (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT par_cdoperad,
                            INPUT par_dtmvtolt,
                            INPUT par_nrdconta,
                            INPUT par_idorigem, 
                            INPUT 1, /* Titular */
                            INPUT par_nmdatela,
                            INPUT FALSE,
                           OUTPUT TABLE tt-erro,
                           OUTPUT TABLE tt-valores-rating,
                           OUTPUT TABLE tt-itens-topico-rating).

       DELETE PROCEDURE h-b1wgen0043.

       IF   RETURN-VALUE <> "OK"   THEN
            RETURN "NOK".

       FIND FIRST tt-valores-rating NO-LOCK NO-ERROR.

       /* Se for inclusao/alteracao pegar estes dados do cadastro */
       IF   CAN-DO("I",par_cddopcao)   THEN
            DO:
                IF   AVAIL tt-valores-rating   THEN
                     ASSIGN tt-dados-analise.nrinfcad = tt-valores-rating.nrinfcad 
                            tt-dados-analise.nrpatlvr = tt-valores-rating.nrpatlvr
                            tt-dados-analise.nrperger = tt-valores-rating.nrperger.  

                RUN obtem-valores-central-risco
                                         (INPUT par_cdcooper,
                                          INPUT par_cdagenci,
                                          INPUT par_nrdcaixa,
                                          INPUT par_cdoperad,
                                          INPUT par_nmdatela,
                                          INPUT par_idorigem,
                                          INPUT par_dtmvtolt,
                                          INPUT 4, /* crapvop/crapopf */
                                          INPUT par_nrdconta,
                                          INPUT par_tpctrato,
                                          INPUT par_nrctrato,
                                          INPUT par_nrdconta,
                                          INPUT 0, /* CPF */
                                          INPUT FALSE,
                                         OUTPUT TABLE tt-erro,
                                         OUTPUT TABLE tt-central-risco).
                
                IF   RETURN-VALUE <> "OK"   THEN
                     RETURN "NOK".
                
                FIND FIRST tt-central-risco NO-LOCK NO-ERROR.

                IF   AVAIL tt-central-risco   THEN
                     ASSIGN tt-dados-analise.dtdrisco = tt-central-risco.dtdrisco
                            tt-dados-analise.qtopescr = tt-central-risco.qtopescr
                            tt-dados-analise.qtifoper = tt-central-risco.qtifoper
                            tt-dados-analise.vltotsfn = tt-central-risco.vltotsfn
                            tt-dados-analise.vlopescr = tt-central-risco.vlopescr
                            tt-dados-analise.vlrpreju = tt-central-risco.vlrpreju
                            tt-dados-analise.flgcentr = TRUE.
                ELSE
                     DO: 
                          RUN consulta_bacen (INPUT par_cdcooper,
                                              INPUT par_nrdconta,
                                              INPUT par_nrctrato,
                                              INPUT par_nrdconta,
                                              INPUT 0,
                                             OUTPUT tt-dados-analise.dtdrisco,
                                             OUTPUT tt-dados-analise.qtopescr,
                                             OUTPUT tt-dados-analise.qtifoper,
                                             OUTPUT tt-dados-analise.vltotsfn,
                                             OUTPUT tt-dados-analise.vlopescr,
                                             OUTPUT tt-dados-analise.vlrpreju,
                                             OUTPUT aux_dscritic).

                          IF   aux_dscritic <> ""   THEN
                               LEAVE.

                          ASSIGN tt-dados-analise.flgcentr = TRUE.

                     END.

                /* CPF do Conjuge */
                FIND crapcje WHERE crapcje.cdcooper = par_cdcooper   AND
                                   crapcje.nrdconta = par_nrdconta   AND
                                   crapcje.idseqttl = 1
                                   NO-LOCK NO-ERROR.
                         
                IF    AVAIL crapcje   THEN
                      DO:
                          IF   crapcje.nrctacje = 0   THEN
                               ASSIGN aux_nrcpfcgc = crapcje.nrcpfcjg.
                          ELSE
                               DO:
                                   FIND crapass WHERE 
                                        crapass.cdcooper = par_cdcooper AND
                                        crapass.nrdconta = crapcje.nrctacje 
                                        NO-LOCK NO-ERROR.
                    
                                   IF  AVAIL crapass   THEN
                                       ASSIGN aux_nrcpfcgc = crapass.nrcpfcgc.
                               END.
                      END.

                /* Informacoes da cental do Conjuge */
                IF   aux_nrcpfcgc <> 0   THEN
                     DO:
                         /* Verificar se eh cooperado */
                         FIND FIRST crapttl WHERE
                                    crapttl.cdcooper = par_cdcooper   AND
                                    crapttl.nrcpfcgc = aux_nrcpfcgc
                                    NO-LOCK NO-ERROR.

                         IF   AVAIL crapttl   THEN
                              DO:
                                  RUN obtem-valores-central-risco
                                         (INPUT par_cdcooper,
                                          INPUT par_cdagenci,
                                          INPUT par_nrdcaixa,
                                          INPUT par_cdoperad,
                                          INPUT par_nmdatela,
                                          INPUT par_idorigem,
                                          INPUT par_dtmvtolt,
                                          INPUT 4, /* crapvop/crapopf */
                                          INPUT 0, /* Conta */
                                          INPUT par_tpctrato,
                                          INPUT par_nrctrato,
                                          INPUT 0, /* Buscar da conta */
                                          INPUT aux_nrcpfcgc, /* CPF */
                                          INPUT FALSE,
                                         OUTPUT TABLE tt-erro,
                                         OUTPUT TABLE tt-central-risco).

                                 IF   RETURN-VALUE <> "OK"   THEN
                                      RETURN "NOK".
                                 
                                 FIND FIRST tt-central-risco NO-LOCK NO-ERROR.
                                 
                                 /* Endividamento do Conjuge */
                                 IF   AVAIL  tt-central-risco  THEN
                                      ASSIGN tt-dados-analise.dtoutris =
                                                    tt-central-risco.dtdrisco 
                                             tt-dados-analise.vlsfnout = 
                                                    tt-central-risco.vltotsfn
                                             tt-dados-analise.flgcoout = TRUE.
                              END.
                     END.             
            END.
       ELSE     /* So consulta, alteracao  ... */
            DO:
                IF   AVAIL crapprp   THEN
                     ASSIGN tt-dados-analise.nrinfcad = crapprp.nrinfcad
                            tt-dados-analise.nrpatlvr = crapprp.nrpatlvr
                            tt-dados-analise.nrperger = crapprp.nrperger
                            tt-dados-analise.dtdrisco = crapprp.dtdrisco
                            tt-dados-analise.vltotsfn = crapprp.vltotsfn
                            tt-dados-analise.qtopescr = crapprp.qtopescr
                            tt-dados-analise.qtifoper = crapprp.qtifoper
                            tt-dados-analise.vlopescr = crapprp.vlopescr
                            tt-dados-analise.vlrpreju = crapprp.vlrpreju.  

                IF   par_cddopcao = "A"   THEN
                     ASSIGN tt-dados-analise.flgcentr = TRUE.

            END.          
                         
       IF   AVAIL crapprp   THEN
            ASSIGN tt-dados-analise.nrgarope = crapprp.nrgarope
                   tt-dados-analise.dtcnsspc = crapprp.dtcnsspc
                   tt-dados-analise.nrliquid = crapprp.nrliquid
                   tt-dados-analise.dtoutspc = crapprp.dtoutspc.  

       /* Descricao da Inf. Cadastral */
       IF   tt-dados-analise.nrinfcad <> 0  THEN
            DO:
                IF   par_inpessoa = 1  THEN
                     ASSIGN aux_nrtopico = 1
                            aux_nritetop = 4.
                ELSE
                     ASSIGN aux_nrtopico = 3
                            aux_nritetop = 3.

                FIND tt-itens-topico-rating WHERE 
                     tt-itens-topico-rating.nrtopico = aux_nrtopico   AND
                     tt-itens-topico-rating.nritetop = aux_nritetop   AND
                     tt-itens-topico-rating.nrseqite = tt-dados-analise.nrinfcad  
                     NO-LOCK NO-ERROR.

                IF   AVAIL tt-itens-topico-rating  THEN
                     DO:
                         /* Verifica se tem um '.' na descricao */
                         aux_nrdindex = INDEX(tt-itens-topico-rating.dsseqite,".").

                         tt-dados-analise.dsinfcad = IF   aux_nrdindex  >= 1  THEN 
                                 SUBSTRING(tt-itens-topico-rating.dsseqite,1,aux_nrdindex)             
                                                     ELSE 
                                 tt-itens-topico-rating.dsseqite.             
                     END.
                   
            END.

       /* Descricao da garantia */
       IF   tt-dados-analise.nrgarope <> 0  THEN
            DO:
                IF   par_inpessoa = 1   THEN
                     ASSIGN aux_nrtopico = 2
                            aux_nritetop = 2.
                ELSE
                     ASSIGN aux_nrtopico = 4
                            aux_nritetop = 2.

                FIND tt-itens-topico-rating WHERE 
                     tt-itens-topico-rating.nrtopico = aux_nrtopico   AND
                     tt-itens-topico-rating.nritetop = aux_nritetop   AND
                     tt-itens-topico-rating.nrseqite = tt-dados-analise.nrgarope
                     NO-LOCK NO-ERROR.

                IF   AVAIL tt-itens-topico-rating  THEN
                     DO:
                         /* Verifica se tem um '.' na descricao */
                         aux_nrdindex = INDEX(tt-itens-topico-rating.dsseqite,".").

                         tt-dados-analise.dsgarope= IF   aux_nrdindex  >= 1  THEN 
                                 SUBSTRING(tt-itens-topico-rating.dsseqite,1,aux_nrdindex)             
                                                    ELSE 
                                 tt-itens-topico-rating.dsseqite. 
                     END.                   
            END.

       /* Descricao da Liquidez da garantia */
       IF   tt-dados-analise.nrliquid <> 0  THEN
            DO:
                IF   par_inpessoa = 1   THEN
                     ASSIGN aux_nrtopico = 2
                            aux_nritetop = 3.
                ELSE
                     ASSIGN aux_nrtopico = 4
                            aux_nritetop = 3.

                FIND tt-itens-topico-rating WHERE 
                     tt-itens-topico-rating.nrtopico = aux_nrtopico   AND
                     tt-itens-topico-rating.nritetop = aux_nritetop   AND
                     tt-itens-topico-rating.nrseqite = tt-dados-analise.nrliquid
                     NO-LOCK NO-ERROR.

                IF   AVAIL tt-itens-topico-rating   THEN
                     DO:
                         /* Verifica se tem um '.' na descricao */
                         aux_nrdindex = INDEX(tt-itens-topico-rating.dsseqite,".").

                         tt-dados-analise.dsliquid = IF   aux_nrdindex  >= 1  THEN 
                                 SUBSTRING(tt-itens-topico-rating.dsseqite,1,aux_nrdindex)             
                                                     ELSE  
                                 tt-itens-topico-rating.dsseqite.      

                     END.
            END.

       /* Descricao do Patrimonio */
       IF   tt-dados-analise.nrpatlvr <> 0    THEN
            DO:
                IF   par_inpessoa = 1   THEN
                     ASSIGN aux_nrtopico = 1
                            aux_nritetop = 8.
                ELSE
                     ASSIGN aux_nrtopico = 3
                            aux_nritetop = 9.

                FIND tt-itens-topico-rating WHERE 
                     tt-itens-topico-rating.nrtopico = aux_nrtopico   AND
                     tt-itens-topico-rating.nritetop = aux_nritetop   AND
                     tt-itens-topico-rating.nrseqite = tt-dados-analise.nrpatlvr
                     NO-LOCK NO-ERROR.

                IF   AVAIL tt-itens-topico-rating   THEN
                     DO:
                         tt-dados-analise.dspatlvr = 
                             REPLACE(tt-itens-topico-rating.dsseqite,"..","").
                     END.     
            END.    

       /* Percepcao Geral da empresa - Pessoa Juridica */
       IF   tt-dados-analise.nrperger <> 0  THEN
            DO:
                FIND tt-itens-topico-rating WHERE 
                     tt-itens-topico-rating.nrtopico = 3   AND
                     tt-itens-topico-rating.nritetop = 11  AND
                     tt-itens-topico-rating.nrseqite = tt-dados-analise.nrperger 
                     NO-LOCK NO-ERROR.

                IF   AVAIL tt-itens-topico-rating   THEN
                     DO:    
                          /* Verifica se tem um '.' na descricao */
                         aux_nrdindex = INDEX(tt-itens-topico-rating.dsseqite,".").

                         tt-dados-analise.dsperger = IF   aux_nrdindex  >= 1  THEN 
                                 SUBSTRING(tt-itens-topico-rating.dsseqite,1,aux_nrdindex)             
                                                     ELSE  
                                 tt-itens-topico-rating.dsseqite.
                     END.           
            END.

       LEAVE.

    END. /* Fim tratamento criticas */

    IF   aux_cdcritic <> 0    OR
         aux_dscritic <> ""   THEN
         DO:
             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,     /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).
             RETURN "NOK".
         END.

    RETURN "OK".

END PROCEDURE.


/******************************************************************************
 Obter os dados do banco cetral para analise da proposta, consulta de SCR. 
 (Tela CONSCR)
******************************************************************************/

PROCEDURE obtem-valores-central-risco:
                 
    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cdtipcon AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_tpctrato AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctrato AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctacon AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrcpfcon AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-central-risco.

    DEF  VAR aux_tpctrava AS INTE                                   NO-UNDO.
    DEF  VAR aux_tpctrpro AS INTE                                   NO-UNDO.

   
    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-central-risco.
 
    Consulta_Scr:
    DO ON ERROR UNDO, LEAVE:

       /* Os tipos sao iguais na crapavl , crpavt e inprodut (aux_tpctrava)*/
       /* Mas sao diferentes na crapprp e craplim (aux_tpctrpro)           */
       ASSIGN aux_tpctrava = par_tpctrato
              aux_tpctrpro = IF   par_tpctrato = 1   THEN /* Emprestimo */
                                  90 
                             ELSE
                             IF   par_tpctrato = 3   THEN /* Lim. Credito*/
                                  1
                             ELSE
                                  par_tpctrato.

       IF   par_cdtipcon = 1   OR    /* Consultar dados da central na     */
            par_cdtipcon = 2   OR
            par_cdtipcon = 5   THEN  /* proposta para o titular e conjuge */
            DO:
                RUN obtem-valores-central-prp (INPUT par_cdcooper,
                                               INPUT par_nrdconta,
                                               INPUT aux_tpctrpro,
                                               INPUT par_nrctrato,
                                               INPUT par_cdtipcon,
                                              OUTPUT aux_cdcritic,
                                              OUTPUT TABLE tt-central-risco).
            END.   
       ELSE
       IF   par_cdtipcon = 3   THEN /* Consultar dados da central na */
            DO:                     /* proposta para os avalistas    */
                RUN obtem-valores-central-ava (INPUT par_cdcooper,
                                               INPUT par_nrdconta,
                                               INPUT aux_tpctrava,
                                               INPUT par_nrctrato,
                                               INPUT par_nrctacon,
                                               INPUT par_nrcpfcon,
                                              OUTPUT aux_cdcritic,
                                              OUTPUT TABLE tt-central-risco).               
            END.
       ELSE
       IF   par_cdtipcon = 4   THEN /* Consultar dados da central na */
            DO:                     /* crapvop e crapopf             */
                RUN obtem-valores-central-vop (INPUT par_cdcooper,
                                               INPUT par_nrdconta,
                                               INPUT par_nrcpfcon,
                                              OUTPUT aux_cdcritic,
                                              OUTPUT TABLE tt-central-risco).
            END.

       IF  RETURN-VALUE <> "OK"   THEN
           LEAVE Consulta_Scr.

    END. /* Fim DO WHILE TRUE , tramento de criticas */
  
    IF   aux_cdcritic <> 0   OR
         aux_dscritic <> ""   THEN
         DO:
             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,     /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).
              
             RETURN "NOK".
         END.
        
    RETURN "OK".

END PROCEDURE.


PROCEDURE obtem-valores-central-prp:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.   
    DEF  INPUT PARAM par_tpctrato AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctrato AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdtipcon AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_cdcritic AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-central-risco.


    EMPTY TEMP-TABLE tt-central-risco.


    /* Achar registro da proposta */
    FIND crapprp WHERE crapprp.cdcooper = par_cdcooper   AND
                       crapprp.nrdconta = par_nrdconta   AND
                       crapprp.tpctrato = par_tpctrato   AND
                       crapprp.nrctrato = par_nrctrato
                       NO-LOCK NO-ERROR.

    IF   NOT AVAIL crapprp   THEN
         DO:
             par_cdcritic = 510.
             RETURN "NOK".
         END.

    CREATE tt-central-risco.

    IF   par_cdtipcon <= 2   THEN /* Titular */
         ASSIGN tt-central-risco.dtdrisco = crapprp.dtdrisco
                tt-central-risco.qtopescr = crapprp.qtopescr
                tt-central-risco.qtifoper = crapprp.qtifoper
                tt-central-risco.vltotsfn = crapprp.vltotsfn
                tt-central-risco.vlopescr = crapprp.vlopescr
                tt-central-risco.vlrpreju = crapprp.vlrpreju.
    ELSE                        /* Conjuge */
         ASSIGN tt-central-risco.dtdrisco = crapprp.dtoutris 
                tt-central-risco.qtopescr = crapprp.qtopecje
                tt-central-risco.qtifoper = crapprp.qtifocje
                tt-central-risco.vltotsfn = crapprp.vlsfnout  
                tt-central-risco.vlopescr = crapprp.vlopecje
                tt-central-risco.vlrpreju = crapprp.vlprjcje.
               
    RETURN "OK".

END PROCEDURE.

PROCEDURE obtem-valores-central-ava:
     
    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.   
    DEF  INPUT PARAM par_tpctrato AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctrato AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctacon AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrcpfcon AS DECI                           NO-UNDO.
    DEF OUTPUT PARAM par_cdcritic AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-central-risco.


    EMPTY TEMP-TABLE tt-central-risco.

    CREATE tt-central-risco.

    IF   par_nrctacon <> 0   THEN /* Aval cooperado */
         DO:
             FIND crapavl WHERE crapavl.cdcooper = par_cdcooper   AND
                                crapavl.nrdconta = par_nrctacon   AND
                                crapavl.nrctravd = par_nrctrato   AND
                                crapavl.tpctrato = par_tpctrato
                                NO-LOCK NO-ERROR.
             
             IF  AVAIL crapavl   THEN
                 ASSIGN tt-central-risco.dtdrisco = crapavl.dtdrisco
                        tt-central-risco.qtopescr = crapavl.qtopescr
                        tt-central-risco.qtifoper = crapavl.qtifoper
                        tt-central-risco.vltotsfn = crapavl.vltotsfn
                        tt-central-risco.vlopescr = crapavl.vlopescr
                        tt-central-risco.vlrpreju = crapavl.vlprejuz. 
         END.
    ELSE 
         DO:
             FIND crapavt WHERE crapavt.cdcooper = par_cdcooper AND
                                crapavt.tpctrato = par_tpctrato AND
                                crapavt.nrdconta = par_nrdconta AND
                                crapavt.nrctremp = par_nrctrato AND
                                crapavt.nrcpfcgc = par_nrcpfcon
                                NO-LOCK NO-ERROR.

             IF   AVAIL crapavt   THEN
                  ASSIGN tt-central-risco.dtdrisco = crapavt.dtdrisco
                         tt-central-risco.qtopescr = crapavt.qtopescr
                         tt-central-risco.qtifoper = crapavt.qtifoper
                         tt-central-risco.vltotsfn = crapavt.vltotsfn
                         tt-central-risco.vlopescr = crapavt.vlopescr
                         tt-central-risco.vlrpreju = crapavt.vlprejuz.               
         END.

    RETURN "OK".

END PROCEDURE.


PROCEDURE obtem-valores-central-vop:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO. 
    DEF  INPUT PARAM par_nrcpfcon AS DECI                           NO-UNDO.
    DEF OUTPUT PARAM par_cdcritic AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-central-risco.


    DEF  VAR         aux_dtrefere AS DATE                           NO-UNDO.
    DEF  VAR         aux_vltotsfn AS DECI                           NO-UNDO.
    DEF  VAR         aux_vlopescr AS DECI                           NO-UNDO.
    DEF  VAR         aux_vlrpreju AS DECI                           NO-UNDO.
    DEF  VAR         aux_data     AS DATE                           NO-UNDO.


    EMPTY TEMP-TABLE tt-central-risco.

    ASSIGN aux_data =  ADD-INTERVAL (TODAY, -1, "MONTH").

    DO WHILE TRUE:

        /** Tabela crapopf nao possui cdcooper **/
       FIND LAST crapopf WHERE crapopf.dtrefere >= aux_data 
                 USE-INDEX crapopf2 NO-LOCK NO-ERROR.
       
       IF   AVAIL crapopf   THEN 
            DO:
                ASSIGN aux_dtrefere = crapopf.dtrefere.
                LEAVE.
            END.
       ELSE
            ASSIGN aux_data =  ADD-INTERVAL (aux_data, -1, "MONTH").
    
    END.

    IF   par_nrcpfcon = 0    THEN /* Se nao mando CPF , pega da conta */
         DO:
             FIND crapass WHERE crapass.cdcooper = par_cdcooper   AND
                                crapass.nrdconta = par_nrdconta 
                                NO-LOCK NO-ERROR.
       
             IF   NOT AVAIL crapass   THEN
                  DO:
                      par_cdcritic = 9.
                      RETURN "NOK".
                  END.
       
             par_nrcpfcon = crapass.nrcpfcgc.
       
         END.
       
    /* Pegar ultimo valor recibido das ope. financeiras, s/ CDCOOPER */  
    FIND LAST crapopf WHERE crapopf.nrcpfcgc  = par_nrcpfcon   AND
                            crapopf.dtrefere >= aux_dtrefere      
                            NO-LOCK NO-ERROR.
   
    /* Se nao tiver operacoes, sair ... */
    IF   NOT AVAIL crapopf   THEN
         LEAVE.

    FOR EACH crapvop WHERE crapvop.nrcpfcgc = crapopf.nrcpfcgc   AND
                           crapvop.dtrefere = crapopf.dtrefere   NO-LOCK:
   
        ASSIGN aux_vltotsfn = aux_vltotsfn + crapvop.vlvencto.
   
        /** Operacoes vencidas **/
        IF  crapvop.cdvencto >= 205   AND
            crapvop.cdvencto <= 290   THEN
            ASSIGN aux_vlopescr = aux_vlopescr + crapvop.vlvencto.
   
        /** Operacoes em Prejuizo **/
        IF  crapvop.cdvencto >= 310   AND
            crapvop.cdvencto <= 330   THEN
            ASSIGN aux_vlrpreju = aux_vlrpreju + crapvop.vlvencto.
   
    END.
   
    CREATE tt-central-risco.
    ASSIGN tt-central-risco.dtdrisco = crapopf.dtrefere
           tt-central-risco.qtopescr = crapopf.qtopesfn
           tt-central-risco.qtifoper = crapopf.qtifssfn
           tt-central-risco.vltotsfn = aux_vltotsfn
           tt-central-risco.vlopescr = aux_vlopescr
           tt-central-risco.vlrpreju = aux_vlrpreju.
   
    RETURN "OK".

END PROCEDURE.


/******************************************************************************
 Procedure para validar os avalistas por separado. (Um aval por tela)
 ******************************************************************************/
PROCEDURE valida-avalistas:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.

    /* Nota promissoria / Pestacoes */
    DEF  INPUT PARAM par_qtpromis AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_qtpreemp AS INTE                           NO-UNDO.

    /* Para verificar que os dois avalistas nao sejam o mesmo */
    DEF  INPUT PARAM par_nrctaav1 AS INTE                           NO-UNDO.      
    DEF  INPUT PARAM par_nrcpfav1 AS DECI                           NO-UNDO.

    /* Dados do avalista */
    DEF  INPUT PARAM par_idavalis AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctaava AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmdavali AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrcpfava AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_cpfcjavl AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_ende1avl AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdufresd AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrcepend AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_inpessoa AS INTE                           NO-UNDO.

    DEF OUTPUT PARAM par_nmdcampo AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.


    DEF  VAR         aux_nrdocnp1 AS CHAR                           NO-UNDO.
    DEF  VAR         aux_nrdocnp2 AS CHAR                           NO-UNDO.
    DEF  VAR         aux_stsnrcal AS LOGI                           NO-UNDO.
    DEF  VAR         avt_inpessoa AS INTE                           NO-UNDO.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".

    EMPTY TEMP-TABLE tt-erro.

    DO WHILE TRUE:

       /* Contas devem ser diferentes */
       IF   par_nrctaav1 > 0              AND
            par_nrctaava > 0              AND
            par_nrctaav1 = par_nrctaava   THEN
            DO:
                ASSIGN aux_dscritic = "A conta/dv dos avalistas devem ser " +
                                      "diferentes."
                       par_nmdcampo = "nrctaava". 
                LEAVE.
            END.

       /* Trazer CPF do primeiro aval */
       IF   par_nrctaav1 <> 0   THEN
            DO:
                FIND crapass WHERE crapass.cdcooper = par_cdcooper   AND
                                   crapass.nrdconta = par_nrctaav1   
                                   NO-LOCK NO-ERROR.

                IF   NOT AVAIL crapass   THEN
                     DO:
                         ASSIGN aux_cdcritic = 9
                                par_nmdcampo = "nrctaava".
                         LEAVE.
                     END.
                
                ASSIGN par_nrcpfav1 = crapass.nrcpfcgc.
                
                IF   crapass.inpessoa > 1 THEN
                     ASSIGN aux_nrdocnp1 = STRING(crapass.nrcpfcgc,"99999999999999")
                            aux_nrdocnp1 = SUBSTR(aux_nrdocnp1,1,8).
            END.
        ELSE
        IF  par_nrcpfav1 <> 0 THEN /* Primeiro avalista terceiro */
            DO: /* Pegar CNPJ, para verificar os 8 digitos */ 

                RUN sistema/generico/procedures/b1wgen9999.p 
                                    PERSISTENT SET h-b1wgen9999.

                RUN valida-cpf-cnpj IN h-b1wgen9999
                                    (INPUT par_nrcpfav1,
                                    OUTPUT aux_stsnrcal,
                                    OUTPUT avt_inpessoa).

                DELETE PROCEDURE h-b1wgen9999.

                IF  NOT aux_stsnrcal  THEN
                    DO:
                        ASSIGN aux_dscritic = "CPF do 1o avalista com erro."
                               par_nmdcampo = "nrcpfcgc".
                        LEAVE.
                    END.

                IF   avt_inpessoa > 1 THEN
                     ASSIGN aux_nrdocnp1 = STRING(par_nrcpfav1,"99999999999999")
                            aux_nrdocnp1 = SUBSTR(aux_nrdocnp1,1,8).
            END.

       IF   par_nrctaava <> 0   THEN /* Se cooperado , pegar CPF */
            DO:
                FIND crapass WHERE crapass.cdcooper = par_cdcooper   AND
                                   crapass.nrdconta = par_nrctaava   
                                   NO-LOCK NO-ERROR.

                IF   NOT AVAIL crapass   THEN
                     DO:
                         ASSIGN aux_cdcritic = 9
                                par_nmdcampo = "nrctaava".
                         LEAVE.
                     END.

                 ASSIGN par_nrcpfava = crapass.nrcpfcgc.

                 IF   crapass.inpessoa > 1   THEN
                      ASSIGN aux_nrdocnp2 = STRING(crapass.nrcpfcgc,"99999999999999")
                             aux_nrdocnp2 = SUBSTR(aux_nrdocnp2,1,8).
            END.
       ELSE
       IF   par_nrcpfava <> 0   THEN   /* Se nao cooperado */
            DO: /* Pegar CNPJ, para verificar os 8 digitos */ 
                
                RUN sistema/generico/procedures/b1wgen9999.p 
                                    PERSISTENT SET h-b1wgen9999.
                
                RUN valida-cpf-cnpj IN h-b1wgen9999
                                   (INPUT par_nrcpfava,
                                    OUTPUT aux_stsnrcal,
                                    OUTPUT avt_inpessoa).

                DELETE PROCEDURE h-b1wgen9999.

                IF  NOT aux_stsnrcal  THEN
                    DO:
                        ASSIGN aux_dscritic = "CPF do avalista com erro."
                               par_nmdcampo = "nrcpfcgc".
                        LEAVE.
                    END.
                
                /*12/02/2015
                 Foi visto que o parâmetro par_inpessoa estava sendo passado fixo
                 "0" e não havia nenhuma forma de validação onde mudaria esse valor,
                 fazendo com que sempre houvesse valores diferentes na validação abaixo 
                 SD 252962  (Kelvin/Gielow)*/

                /*IF   par_inpessoa <> avt_inpessoa   THEN
                     DO: 
                         ASSIGN aux_dscritic = "Tipo de Natureza errado.".
                               par_nmdcampo = "inpessoa".
                         LEAVE.
                     END.*/

                IF   avt_inpessoa > 1  THEN
                     ASSIGN aux_nrdocnp2 = STRING(par_nrcpfava,"99999999999999")
                            aux_nrdocnp2 = SUBSTR(aux_nrdocnp2,1,8).       
            END.
            
       /* CPF devem ser diferentes */
       IF   par_nrcpfav1 > 0              AND
            par_nrcpfava > 0              AND
            par_nrcpfav1 = par_nrcpfava   THEN
            DO:
                ASSIGN aux_dscritic = "CPF dos avalistas devem ser diferentes."
                       par_nmdcampo = "nrcpfcgc".
                LEAVE.
            END.

       /* Oito primeiros digito do CNPJ nao podem ser iguais */
       IF   aux_nrdocnp1 <> ""   AND
            aux_nrdocnp2 <> ""   AND
            aux_nrdocnp1 = aux_nrdocnp2   THEN
            DO:
                ASSIGN aux_dscritic = "CNPJ dos avalistas devem ser diferentes."
                       par_nmdcampo = "nrcpfcgc".
                LEAVE.
            END.

       RUN sistema/generico/procedures/b1wgen9999.p PERSISTENT SET h-b1wgen9999.

       IF   par_idavalis = 1   THEN
            RUN valida-avalistas IN h-b1wgen9999 
                                           (INPUT par_cdcooper,
                                            INPUT par_cdagenci,
                                            INPUT par_nrdcaixa,
                                            INPUT par_nrdconta,
                                            INPUT par_nrctaava,
                                            INPUT par_nmdavali,
                                            INPUT par_nrcpfava,
                                            INPUT par_cpfcjavl,
                                            INPUT par_ende1avl,
                                            INPUT par_nrcepend,
                                            INPUT 0,
                                            INPUT "",
                                            INPUT 0,
                                            INPUT 0,
                                            INPUT "",
                                            INPUT 0,
                                            OUTPUT par_nmdcampo,
                                            OUTPUT TABLE tt-erro).
       ELSE 
            RUN valida-avalistas IN h-b1wgen9999 
                                           (INPUT par_cdcooper,
                                            INPUT par_cdagenci,
                                            INPUT par_nrdcaixa,
                                            INPUT par_nrdconta,
                                            INPUT 0,
                                            INPUT "",
                                            INPUT 0,
                                            INPUT 0,
                                            INPUT "",
                                            INPUT 0,
                                            INPUT par_nrctaava,
                                            INPUT par_nmdavali,
                                            INPUT par_nrcpfava,
                                            INPUT par_cpfcjavl,
                                            INPUT par_ende1avl,
                                            INPUT par_nrcepend,
                                           OUTPUT par_nmdcampo,
                                           OUTPUT TABLE tt-erro).
       DELETE PROCEDURE h-b1wgen9999.

       IF   RETURN-VALUE <> "OK"   THEN
            RETURN "NOK".

       IF   par_nmdavali <> ""   THEN /* Se aval prenchido */
            DO:
                /* Validar UF */
                RUN sistema/generico/procedures/b1wgen0002.p
                                     PERSISTENT SET h-b1wgen0002.
            
                RUN valida_uf IN h-b1wgen0002 ( INPUT par_cdufresd,
                                               OUTPUT aux_cdcritic).
            
                DELETE PROCEDURE h-b1wgen0002.

                IF   aux_cdcritic <> 0   THEN
                     DO:
                         par_nmdcampo = "cdufresd".
                         LEAVE.
                     END.
            END.

       LEAVE.

    END. /* Tratamento de criticas */

    IF   aux_cdcritic <> 0    OR 
         aux_dscritic <> ""   THEN
         DO:
             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,     /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).

             RETURN "NOK".
         END.

    RETURN "OK".

END PROCEDURE.


/******************************************************************************
 Verifica se existe outras propostas em andamento para determinada operacao.
******************************************************************************/
PROCEDURE verifica-outras-propostas:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_tpctrato AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctrato AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.

    DEF OUTPUT PARAM par_dsalerta AS CHAR.


    DEF   VAR        aux_flgopera AS LOGI                           NO-UNDO.


    ASSIGN aux_flgopera = FALSE.


    /* Para todas as operacoes do mesmo tipo mas contratos diferentes */
    FOR EACH crapprp WHERE crapprp.cdcooper = par_cdcooper   AND
                           crapprp.nrdconta = par_nrdconta   AND
                           crapprp.tpctrato = par_tpctrato   AND
                           crapprp.nrctrato <> par_nrctrato  NO-LOCK:

        IF   crapprp.tpctrato = 90   THEN /* Emprestimo */
             DO:
                 FIND crapepr WHERE crapepr.cdcooper = par_cdcooper   AND
                                    crapepr.nrdconta = par_nrdconta   AND
                                    crapepr.nrctremp = crapprp.nrctrato
                                    NO-LOCK NO-ERROR.

                 /* Se nao disponivel entao eh proposta */
                 IF    NOT AVAIL crapepr   THEN
                       ASSIGN aux_flgopera = TRUE.
             END.
        ELSE
             DO:
                 /* Limite em estudo */
                 FIND craplim WHERE craplim.cdcooper = par_cdcooper       AND
                                    craplim.nrdconta = par_nrdconta       AND
                                    craplim.tpctrlim = crapprp.tpctrato   AND
                                    craplim.nrctrlim = crapprp.nrctrato   AND
                                    craplim.insitlim = 1
                                    NO-LOCK NO-ERROR.

                 /* Se disponivel, eh proposta */
                 IF   AVAIL craplim   THEN
                      ASSIGN aux_flgopera = TRUE.

             END.
             
        IF   aux_flgopera   THEN
             LEAVE.

    END. /* Fim FOR EACH contratos */

    /* Se existe outras operacoes do mesmo tipo */
    IF   aux_flgopera   THEN
         par_dsalerta = "Existem propostas em aberto, atenção para o " +
                        "comprometimento da renda".

    RETURN "OK".

END PROCEDURE.


/*****************************************************************************
 Buscar os rotativos para a impressao das propostas de credito.
*****************************************************************************/
PROCEDURE busca-rotativos:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtopr AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-valores-gerais.
    DEF OUTPUT PARAM TABLE FOR tt-rotativos.
    DEF OUTPUT PARAM TABLE FOR tt-dados-epr.
    DEF OUTPUT PARAM par_vlsdeved AS DECI                           NO-UNDO.
    DEF OUTPUT PARAM par_vlpreemp AS DECI                           NO-UNDO.
    DEF OUTPUT PARAM par_qtmesatr AS DECI                           NO-UNDO.

    DEF VAR          aux_contador AS INTE                           NO-UNDO.
    DEF VAR          aux_vlsdeved AS DECI                           NO-UNDO.
    DEF VAR          aux_vlsldapl AS DECI                           NO-UNDO.
    DEF VAR          aux_tpctrato AS INTE                           NO-UNDO.
    DEF VAR          aux_nrctrato AS INTE                           NO-UNDO.
    DEF VAR          aux_nrctaav1 AS INTE                           NO-UNDO.
    DEF VAR          aux_nrctaav2 AS INTE                           NO-UNDO.
    DEF VAR          aux_dsgarant AS CHAR                           NO-UNDO.
    DEF VAR          aux_existcrd AS LOGI                           NO-UNDO.
    DEF VAR          aux_qtregist AS INTE                           NO-UNDO.


    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-valores-gerais.
    EMPTY TEMP-TABLE tt-rotativos.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".


    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

        FIND crapass WHERE crapass.cdcooper = par_cdcooper   AND
                           crapass.nrdconta = par_nrdconta  
                           NO-LOCK NO-ERROR.

        IF   NOT AVAIL crapass   THEN
             DO:
                 aux_cdcritic = 9.
                 LEAVE.
             END.

        RUN sistema/generico/procedures/b1wgen0001.p 
            PERSISTEN SET h-b1wgen0001.

        /* Medias dos saldos */
        RUN carrega_medias IN h-b1wgen0001 (INPUT par_cdcooper,
                                            INPUT par_cdagenci,
                                            INPUT par_nrdcaixa,
                                            INPUT par_cdoperad,
                                            INPUT par_nrdconta,
                                            INPUT par_dtmvtolt,
                                            INPUT par_idorigem,
                                            INPUT 1, /* Tit. */
                                            INPUT par_nmdatela,
                                            INPUT par_flgerlog,
                                            OUTPUT TABLE tt-erro,
                                            OUTPUT TABLE tt-medias,
                                            OUTPUT TABLE tt-comp_medias). 
        DELETE PROCEDURE h-b1wgen0001.

        IF   RETURN-VALUE <> "OK"   THEN
             RETURN "NOK".

        RUN sistema/generico/procedures/b1wgen0021.p 
            PERSISTENT SET h-b1wgen0021.

        /* Valor da prestacao e do capital */
        RUN obtem_dados_capital IN h-b1wgen0021
                                   (INPUT par_cdcooper,
                                    INPUT par_cdagenci,
                                    INPUT par_nrdcaixa,
                                    INPUT par_cdoperad,
                                    INPUT par_nmdatela,
                                    INPUT par_idorigem,
                                    INPUT par_nrdconta,
                                    INPUT 1, /* Tit. */
                                    INPUT par_dtmvtolt,
                                    INPUT par_flgerlog,
                                    OUTPUT TABLE tt-dados-capital,
                                    OUTPUT TABLE tt-erro). 

        DELETE PROCEDURE h-b1wgen0021.

        IF   RETURN-VALUE <> "OK"   THEN
             RETURN "NOK".
        

    	/** Saldo das aplicacoes **/
    	RUN sistema/generico/procedures/b1wgen0081.p PERSISTENT
    		SET h-b1wgen0081.        
       
    	IF  VALID-HANDLE(h-b1wgen0081)  THEN
    		DO:
    			ASSIGN aux_vlsldtot = 0.
    
    			
    			RUN obtem-dados-aplicacoes IN h-b1wgen0081
    									  (INPUT par_cdcooper,
    									   INPUT par_cdagenci,
    									   INPUT 1,
    									   INPUT 1,
    									   INPUT par_nmdatela,
    									   INPUT 1,
    									   INPUT par_nrdconta,
    									   INPUT 1,
    									   INPUT 0,
    									   INPUT par_nmdatela,
    									   INPUT FALSE,
    									   INPUT ?,
    									   INPUT ?,
    									   OUTPUT aux_vlsldapl,
    									   OUTPUT TABLE tt-saldo-rdca,
    									   OUTPUT TABLE tt-erro).
    		
    			IF  RETURN-VALUE = "NOK"  THEN
    				DO:
    					DELETE PROCEDURE h-b1wgen0081.
    					
    					FIND FIRST tt-erro NO-LOCK NO-ERROR.
    				 
    					IF  AVAILABLE tt-erro  THEN
    						MESSAGE tt-erro.dscritic.
    					ELSE
    						MESSAGE "Erro nos dados das aplicacoes.".
    		
    					NEXT.
    				END.
    
    			DELETE PROCEDURE h-b1wgen0081.
    		END.
    	 
           DO TRANSACTION ON ERROR UNDO, RETRY:
             /*Busca Saldo Novas Aplicacoes*/
             
             { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }    
              RUN STORED-PROCEDURE pc_busca_saldo_aplicacoes
                aux_handproc = PROC-HANDLE NO-ERROR
                                        (INPUT par_cdcooper, /* Código da Cooperativa */
                                         INPUT '1',            /* Código do Operador */
                                         INPUT par_nmdatela, /* Nome da Tela */
                                         INPUT 1,            /* Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA */
                                         INPUT par_nrdconta, /* Número da Conta */
                                         INPUT 1,            /* Titular da Conta */
                                         INPUT 0,            /* Número da Aplicação / Parâmetro Opcional */
                                         INPUT par_dtmvtolt, /* Data de Movimento */
                                         INPUT 0,            /* Código do Produto */
                                         INPUT 1,            /* Identificador de Bloqueio de Resgate (1 – Todas / 2 – Bloqueadas / 3 – Desbloqueadas) */
                                         INPUT 0,            /* Identificador de Log (0 – Não / 1 – Sim) */
                                        OUTPUT 0,            /* Saldo Total da Aplicação */
                                        OUTPUT 0,            /* Saldo Total para Resgate */
                                        OUTPUT 0,            /* Código da crítica */
                                        OUTPUT "").          /* Descrição da crítica */
              
              CLOSE STORED-PROC pc_busca_saldo_aplicacoes
                    aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
              
              { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
    
              ASSIGN aux_cdcritic = 0
                     aux_dscritic = ""
                     aux_vlsldtot = 0
                     aux_vlsldrgt = 0
                     aux_cdcritic = pc_busca_saldo_aplicacoes.pr_cdcritic 
                                     WHEN pc_busca_saldo_aplicacoes.pr_cdcritic <> ?
                     aux_dscritic = pc_busca_saldo_aplicacoes.pr_dscritic
                                     WHEN pc_busca_saldo_aplicacoes.pr_dscritic <> ?
                     aux_vlsldtot = pc_busca_saldo_aplicacoes.pr_vlsldtot
                                     WHEN pc_busca_saldo_aplicacoes.pr_vlsldtot <> ?
                     aux_vlsldrgt = pc_busca_saldo_aplicacoes.pr_vlsldrgt
                                     WHEN pc_busca_saldo_aplicacoes.pr_vlsldrgt <> ?.
    
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
            
                     CREATE tt-erro.
            
                     ASSIGN tt-erro.cdcritic = aux_cdcritic
                            tt-erro.dscritic = aux_dscritic.
              
                     RETURN "NOK".
                                    
                 END.
                                                  
             ASSIGN aux_vlsldapl = aux_vlsldrgt + aux_vlsldapl.
         END.
         /*Fim Busca Saldo Novas Aplicacoes*/

        
        /* Medias dos saldos */
        FIND FIRST tt-comp_medias NO-LOCK NO-ERROR.

        /* Valores do capital */
        FIND FIRST tt-dados-capital NO-LOCK NO-ERROR.

        CREATE tt-valores-gerais.
        ASSIGN tt-valores-gerais.nmprimtl = crapass.nmprimtl
               tt-valores-gerais.nrdconta = par_nrdconta
               tt-valores-gerais.vlsmdtri = tt-comp_medias.vlsmdtri 
                                            WHEN AVAIL tt-comp_medias

               tt-valores-gerais.vldcotas = tt-dados-capital.vldcotas
                                            WHEN AVAIL tt-dados-capital

               tt-valores-gerais.vlprepla = tt-dados-capital.vlprepla
                                            WHEN AVAIL tt-dados-capital
                
               tt-valores-gerais.vlsldapl = aux_vlsldapl.


        /* Cheque especial , Desconto de cheque / Titulo */
        DO aux_contador = 1 TO 3:

           FIND craplim WHERE craplim.cdcooper = par_cdcooper  AND
                              craplim.nrdconta = par_nrdconta  AND
                              craplim.tpctrlim = aux_contador  AND
                              craplim.insitlim = 2 /* Ativo */
                              NO-LOCK NO-ERROR.

           IF  NOT AVAIL craplim  THEN
               NEXT.
           
           CREATE tt-rotativos.
           ASSIGN tt-rotativos.vllimite = IF   AVAIL craplim   THEN
                                               craplim.vllimite 
                                          ELSE 0

                  tt-rotativos.dtmvtolt = IF   AVAIL craplim   THEN
                                               craplim.dtinivig 
                                          ELSE
                                               ?

                           aux_nrctrato = craplim.nrctrlim 
                                          WHEN AVAIL craplim

                           aux_dsgarant = ""
                           aux_nrctaav1 = IF   AVAIL craplim   then
                                               craplim.nrctaav1 
                                          ELSE 0

                           aux_nrctaav2 = IF   AVAIL craplim   THEN 
                                               craplim.nrctaav2
                                          ELSE 0.

           CASE aux_contador:
               
               WHEN 1 THEN ASSIGN tt-rotativos.dsoperac = "Cheque Especial"
                                  aux_tpctrato = 3.
               
               WHEN 2 THEN ASSIGN tt-rotativos.dsoperac = "Descto. Cheques"
                                  aux_tpctrato = 2.
               
               WHEN 3 THEN ASSIGN tt-rotativos.dsoperac = "Descto. Titulos"
                                  aux_tpctrato = 8.
           
           END CASE.

           /* Garantidor */
           RUN sistema/generico/procedures/b1wgen9999.p 
                                           PERSISTENT SET h-b1wgen9999.

           RUN lista_avalistas IN h-b1wgen9999 (INPUT par_cdcooper,
                                                INPUT par_cdagenci,
                                                INPUT par_nrdcaixa,
                                                INPUT par_cdoperad,
                                                INPUT par_nmdatela,
                                                INPUT par_idorigem,
                                                INPUT par_nrdconta,
                                                INPUT 1, /* Tit. */
                                                INPUT aux_tpctrato,
                                                INPUT aux_nrctrato,
                                                INPUT aux_nrctaav1,
                                                INPUT aux_nrctaav2,
                                                OUTPUT TABLE tt-dados-avais,
                                                OUTPUT TABLE tt-erro).
           DELETE PROCEDURE h-b1wgen9999.

           IF   RETURN-VALUE <> "OK"   THEN
                RETURN "NOK".

           FOR EACH tt-dados-avais NO-LOCK:

               IF   aux_dsgarant <> ""   THEN
                    ASSIGN aux_dsgarant = aux_dsgarant + " /".

               ASSIGN aux_dsgarant = aux_dsgarant + " Aval " +
                                     IF   tt-dados-avais.nrctaava = 0 THEN 
                                          STRING(tt-dados-avais.nrcpfcgc)  
                                     ELSE 
                                          STRING(tt-dados-avais.nrctaava).
           END.

           ASSIGN tt-rotativos.dsgarant = aux_dsgarant.

           /* Para valores utilizados */
           IF   aux_contador = 1   THEN  /* Cheque especial */
                DO:
                    RUN sistema/generico/procedures/b1wgen0001.p 
                                         PERSISTENT SET h-b1wgen0001.

                    RUN carrega_dep_vista IN h-b1wgen0001 
                                             (INPUT par_cdcooper,
                                              INPUT par_cdagenci,
                                              INPUT par_nrdcaixa,
                                              INPUT par_cdoperad,
                                              INPUT par_nrdconta,
                                              INPUT par_dtmvtolt,
                                              INPUT par_idorigem,
                                              INPUT 1, /* Tit. */
                                              INPUT par_nmdatela,
                                              INPUT par_flgerlog,
                                              OUTPUT TABLE tt-erro,
                                              OUTPUT TABLE tt-saldos,
                                              OUTPUT TABLE tt-libera-epr).

                    DELETE PROCEDURE h-b1wgen0001.

                    IF   RETURN-VALUE <> "OK"   THEN
                         RETURN "NOK".

                    FIND FIRST tt-saldos NO-LOCK NO-ERROR.

                    IF   AVAIL tt-saldos THEN
                         ASSIGN tt-rotativos.vlutiliz = tt-saldos.vlstotal.

                    IF   tt-rotativos.vlutiliz < 0   THEN
                         tt-rotativos.vlutiliz = tt-rotativos.vlutiliz * -1.
                    ELSE
                         tt-rotativos.vlutiliz = 0.

                END. /* Fim cheque especial */
           ELSE
           IF   aux_contador = 2   THEN /* Desconto de cheque */
                DO:
                    FOR EACH crapcdb WHERE 
                             crapcdb.cdcooper = par_cdcooper   AND
                             crapcdb.nrdconta = par_nrdconta   AND
                             crapcdb.insitchq = 2              AND
                             crapcdb.dtlibera > par_dtmvtolt   NO-LOCK:
                       
                        ASSIGN tt-rotativos.vlutiliz = tt-rotativos.vlutiliz + 
                                                       crapcdb.vlcheque.                   
                       
                    END.

                END. /* Fim Desconto de cheque */
           ELSE
           IF   aux_contador = 3   THEN /* Desconto de titulos */
                DO:
                    FOR EACH craptdb WHERE 
                                    (craptdb.cdcooper = par_cdcooper AND
                                     craptdb.nrdconta = par_nrdconta AND
                                     craptdb.insittit =  4)
                                    OR
                                    (craptdb.cdcooper = par_cdcooper  AND
                                     craptdb.nrdconta = par_nrdconta  AND
                                     craptdb.insittit = 2             AND
                                     craptdb.dtdpagto = par_dtmvtolt) NO-LOCK:
             
                         ASSIGN tt-rotativos.vlutiliz =  tt-rotativos.vlutiliz +
                                                         craptdb.vltitulo.
                        
                    END.  /*  Fim do FOR EACH craptdb  */                    
       
                END. /* Fim Desconto de titulos */

        END. /* Fim Cheque especial , descontos */

        /* Cartao de Credito */
        
        FOR EACH crawcrd WHERE  crawcrd.cdcooper = par_cdcooper   AND
                                crawcrd.nrdconta = par_nrdconta   AND
                                crawcrd.insitcrd = 4              NO-LOCK,
            
            FIRST craptlc WHERE craptlc.cdcooper = par_cdcooper       AND
                                craptlc.cdadmcrd = crawcrd.cdadmcrd   AND
                                craptlc.tpcartao = crawcrd.tpcartao   AND
                                craptlc.cdlimcrd = crawcrd.cdlimcrd   AND
                                craptlc.dddebito = 0 
                                USE-INDEX craptlc1 NO-LOCK:

            ASSIGN aux_dsgarant = "".

            /* Garantidor */
            RUN sistema/generico/procedures/b1wgen9999.p 
                                           PERSISTENT SET h-b1wgen9999.
            
            RUN lista_avalistas IN h-b1wgen9999 (INPUT par_cdcooper,
                                                 INPUT par_cdagenci,
                                                 INPUT par_nrdcaixa,
                                                 INPUT par_cdoperad,
                                                 INPUT par_nmdatela,
                                                 INPUT par_idorigem,
                                                 INPUT par_nrdconta,
                                                 INPUT 1, /* Tit. */
                                                 INPUT 4, /* Cartao */ 
                                                 INPUT crawcrd.nrctrcrd,
                                                 INPUT crawcrd.nrctaav1,
                                                 INPUT crawcrd.nrctaav2, 
                                                 OUTPUT TABLE tt-dados-avais,
                                                 OUTPUT TABLE tt-erro).
            DELETE PROCEDURE h-b1wgen9999.
            
            IF   RETURN-VALUE <> "OK"   THEN
                 RETURN "NOK".
            
            FOR EACH tt-dados-avais NO-LOCK:

               IF   aux_dsgarant <> ""   THEN
                    ASSIGN aux_dsgarant = aux_dsgarant + "/".

               ASSIGN aux_dsgarant = aux_dsgarant + " Aval " +
                                     IF   tt-dados-avais.nrctaava = 0 THEN 
                                          STRING(tt-dados-avais.nrcpfcgc)  
                                     ELSE 
                                          STRING(tt-dados-avais.nrctaava).
            END.

            CREATE tt-rotativos.
            ASSIGN tt-rotativos.dsoperac = IF   NOT aux_existcrd   THEN        
                                                "Cartao Credito"
                                           ELSE
                                                ""
                   tt-rotativos.vllimite = craptlc.vllimcrd
                   tt-rotativos.vlutiliz = 0
                   tt-rotativos.dsgarant = aux_dsgarant
                   tt-rotativos.dtmvtolt = crawcrd.dtentreg. 


            ASSIGN aux_existcrd = TRUE.

        END. /* Fim Cartao de credito */

        /* So para mostrar o Label Cartao Credito*/
        IF   NOT aux_existcrd   THEN
             DO:
                 CREATE tt-rotativos.
                 ASSIGN tt-rotativos.dsoperac = "Cartao Credito".   
             END.


        /* Empresimo / Financiamento */

        RUN sistema/generico/procedures/b1wgen0002.p 
                                        PERSISTENT SET h-b1wgen0002.

        RUN obtem-dados-emprestimos IN h-b1wgen0002 
                                       (INPUT par_cdcooper,
                                        INPUT par_cdagenci,
                                        INPUT par_nrdcaixa,
                                        INPUT par_cdoperad,
                                        INPUT par_nmdatela,
                                        INPUT par_idorigem,
                                        INPUT par_nrdconta,
                                        INPUT 1, /* Tit. */
                                        INPUT par_dtmvtolt,
                                        INPUT par_dtmvtopr,
                                        INPUT par_dtmvtolt, 
                                        INPUT 0,
                                        INPUT "",
                                        INPUT 0,
                                        INPUT FALSE,
                                        INPUT FALSE,
                                        INPUT 0, /** nriniseq **/
                                        INPUT 0, /** nrregist **/
                                        OUTPUT aux_qtregist,
                                        OUTPUT TABLE tt-erro,
                                        OUTPUT TABLE tt-dados-epr). 

        DELETE PROCEDURE h-b1wgen0002.

        /* Totalizar emprestimos */
        FOR EACH tt-dados-epr NO-LOCK:

            ASSIGN par_vlsdeved = par_vlsdeved + tt-dados-epr.vlsdeved
                   par_vlpreemp = par_vlpreemp + tt-dados-epr.vlpreemp
                   par_qtmesatr = par_qtmesatr + tt-dados-epr.qtmesatr.

        END.
        
        LEAVE.

    END. /* Fim tratamento de criticas */

    IF   aux_cdcritic <> 0    OR
         aux_dscritic <> ""   THEN
         DO:
             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,     /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).

             RETURN "NOK".
         END.

    RETURN "OK".

END PROCEDURE.


/******************************************************************************
 Gravar os dados que sao comuns as 4 operacoes de credito na crapprp.
******************************************************************************/
PROCEDURE grava-dados-proposta:
                                                                 
  DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
  DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
  DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
  DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
  DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
  DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
  DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
  DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
  DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
  DEF  INPUT PARAM par_tpctrato AS INTE                           NO-UNDO.
  DEF  INPUT PARAM par_nrctrato AS INTE                           NO-UNDO.
  DEF  INPUT PARAM par_vlempbnd AS DECI     /*BNDES*/             NO-UNDO.
  DEF  INPUT PARAM par_qtparbnd AS INT      /*BNDES*/             NO-UNDO.
  /* Analise da proposta e dados do Banco central */
  DEF  INPUT PARAM par_nrgarope AS INTE                           NO-UNDO.
  DEF  INPUT PARAM par_nrperger AS INTE                           NO-UNDO.
  DEF  INPUT PARAM par_dtcnsspc AS DATE                           NO-UNDO.
  DEF  INPUT PARAM par_nrinfcad AS INTE                           NO-UNDO.
  DEF  INPUT PARAM par_dtdrisco AS DATE                           NO-UNDO.
  DEF  INPUT PARAM par_vltotsfn AS DECI                           NO-UNDO.
  DEF  INPUT PARAM par_qtopescr AS INTE                           NO-UNDO.
  DEF  INPUT PARAM par_qtifoper AS INTE                           NO-UNDO.
  DEF  INPUT PARAM par_nrliquid AS INTE                           NO-UNDO.
  DEF  INPUT PARAM par_vlopescr AS DECI                           NO-UNDO.
  DEF  INPUT PARAM par_vlrpreju AS DECI                           NO-UNDO.
  DEF  INPUT PARAM par_nrpatlvr AS INTE                           NO-UNDO.
  DEF  INPUT PARAM par_dtoutspc AS DATE                           NO-UNDO.
  DEF  INPUT PARAM par_dtoutris AS DATE                           NO-UNDO.
  DEF  INPUT PARAM par_vlsfnout AS DECI                           NO-UNDO.
  /* Salarios e Rendimentos */
  DEF  INPUT PARAM par_vlsalari AS DECI                           NO-UNDO.
  DEF  INPUT PARAM par_vloutras AS DECI                           NO-UNDO.
  DEF  INPUT PARAM par_vlalugue AS DECI                           NO-UNDO.
  DEF  INPUT PARAM par_vlsalcon AS DECI                           NO-UNDO.
  DEF  INPUT PARAM par_nmempcje AS CHAR                           NO-UNDO.
  DEF  INPUT PARAM par_flgdocje AS LOGI                           NO-UNDO.
  DEF  INPUT PARAM par_nrctacje AS INTE                           NO-UNDO.
  DEF  INPUT PARAM par_nrcpfcje AS DECI                           NO-UNDO.
  DEF  INPUT PARAM par_vlmedfat AS DECI                           NO-UNDO.
  DEF  INPUT PARAM par_dsobserv AS CHAR                           NO-UNDO.
  DEF  INPUT PARAM par_dsdrendi AS CHAR                           NO-UNDO.
  /* Bens da proposta */
  DEF  INPUT PARAM par_dsdebens AS CHAR                           NO-UNDO.
  DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.   
  DEF  INPUT PARAM par_dsjusren AS CHAR                           NO-UNDO.
  
  DEF OUTPUT PARAM TABLE FOR tt-erro.
  DEF OUTPUT PARAM par_idseqbem AS INTE INIT 1                    NO-UNDO.


  DEF VAR    aux_contador       AS INTE                           NO-UNDO.
  DEF VAR    aux_contado2       AS INTE                           NO-UNDO.
  DEF VAR    aux_tpdrendi       AS INTE                           NO-UNDO.
  DEF VAR    aux_vldrendi       AS DECI                           NO-UNDO.
  DEF VAR    aux_dsrelbem       AS CHAR                           NO-UNDO.
  DEF VAR    aux_persemon       AS DECI                           NO-UNDO.
  DEF VAR    aux_qtprebem       AS INTE                           NO-UNDO.
  DEF VAR    aux_vlprebem       AS DECI                           NO-UNDO.
  DEF VAR    aux_vlrdobem       AS DECI                           NO-UNDO.
  DEF VAR    reg_dsdregis       AS CHAR                           NO-UNDO.

  DEF  VAR   con_idseqbem       AS INTE                           NO-UNDO.
  DEF  VAR   aux_dsdregis       AS CHAR                           NO-UNDO.
  DEF  VAR   aux_ulseqbem       AS INTE                           NO-UNDO.
  DEF  VAR   aux_dsreturn       AS CHAR INIT "NOK"                NO-UNDO.

  DEF  VAR   h-b1wgen0024       AS HANDLE                         NO-UNDO.

  DEF BUFFER crabrpr FOR craprpr.
  DEF BUFFER crabbpr FOR crapbpr.
  DEF BUFFER crabbpr2 FOR crapbpr.

  EMPTY TEMP-TABLE tt-erro.

  
  ASSIGN aux_cdcritic = 0
         aux_dscritic = "".
  
  Grava: DO TRANSACTION ON ERROR  UNDO Grava, LEAVE Grava
                        ON ENDKEY UNDO Grava, LEAVE Grava:

    DO aux_contador = 1 TO 10:

       FIND crapprp WHERE crapprp.cdcooper = par_cdcooper   AND
                          crapprp.nrdconta = par_nrdconta   AND
                          crapprp.tpctrato = par_tpctrato   AND
                          crapprp.nrctrato = par_nrctrato
                          EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

       IF   NOT AVAIL crapprp   THEN
       DO:
            IF   LOCKED crapprp  THEN 
                 DO:
                     aux_cdcritic = 77.
                     PAUSE 1 NO-MESSAGE.
                     NEXT.
                 END.
            ELSE
                 DO:
                     CREATE crapprp. /* Inclusao da proposta */
                     ASSIGN crapprp.cdcooper = par_cdcooper
                            crapprp.nrdconta = par_nrdconta
                            crapprp.tpctrato = par_tpctrato
                            crapprp.nrctrato = par_nrctrato
                            crapprp.cdoperad = par_cdoperad
                            crapprp.dtmvtolt = par_dtmvtolt.
                 END.
       END.
       aux_cdcritic = 0.
       LEAVE.

    END. /* Fim Lock crapprp */
                
    IF   aux_cdcritic <> 0   THEN
         UNDO Grava, LEAVE.
           
    /* Se Co-responsavel , entao pegar a conta e cpf do conjuge */
    IF  par_flgdocje   AND
        par_nrctacje = 0  AND
        par_nrcpfcje = 0 THEN
        DO:
            FIND crapcje WHERE crapcje.cdcooper = par_cdcooper   AND
                               crapcje.nrdconta = par_nrdconta   AND
                               crapcje.idseqttl = 1
                               NO-LOCK NO-ERROR.
    
            IF   AVAIL crapcje   THEN
                 DO:
                     ASSIGN par_nrctacje = crapcje.nrctacje
                            par_nrcpfcje = crapcje.nrcpfcjg.

                     IF   par_nrctacje <> 0   AND 
                          par_nrcpfcje = 0    THEN
                          DO:
                              FIND crapttl WHERE crapttl.cdcooper = par_cdcooper AND
                                                 crapttl.nrdconta = par_nrctacje AND
                                                 crapttl.idseqttl = 1
                                                 NO-LOCK NO-ERROR.

                              /* Alimentar CPF */
                              IF   AVAIL crapttl   THEN
                                   ASSIGN par_nrcpfcje = crapttl.nrcpfcgc.
                          END.
                 END.       
        END.

    /* Analise da proposta */
    ASSIGN crapprp.nrgarope = par_nrgarope
           crapprp.nrperger = par_nrperger
           crapprp.dtcnsspc = par_dtcnsspc
           crapprp.nrinfcad = par_nrinfcad
           crapprp.dtdrisco = par_dtdrisco 
           crapprp.vltotsfn = par_vltotsfn
           crapprp.qtopescr = par_qtopescr
           crapprp.qtifoper = par_qtifoper
           crapprp.nrliquid = par_nrliquid
           crapprp.vlopescr = par_vlopescr
           crapprp.vlrpreju = par_vlrpreju
           crapprp.nrpatlvr = par_nrpatlvr
           crapprp.dtoutspc = par_dtoutspc
           crapprp.dtoutris = par_dtoutris
           crapprp.vlsfnout = par_vlsfnout
           crapprp.vlctrbnd = par_vlempbnd
           crapprp.qtparbnd = par_qtparbnd
           /* Rendimetos */
           crapprp.vlsalari = par_vlsalari
           crapprp.vloutras = par_vloutras
           crapprp.vlalugue = par_vlalugue
           crapprp.vlsalcon = par_vlsalcon
           crapprp.nmempcje = par_nmempcje
           crapprp.flgdocje = par_flgdocje
           crapprp.nrctacje = par_nrctacje
           crapprp.nrcpfcje = par_nrcpfcje
           crapprp.vlmedfat = par_vlmedfat 
           crapprp.dsobserv[1] = par_dsobserv.

    VALIDATE crapprp.
    
    /* Limpar os rendimentos da proposta */
    FOR EACH craprpr WHERE craprpr.cdcooper = par_cdcooper   AND
                           craprpr.nrdconta = par_nrdconta   AND
                           craprpr.tpctrato = par_tpctrato   AND
                           craprpr.nrctrato = par_nrctrato   NO-LOCK:

        DO aux_contador = 1 TO 10:

            FIND crabrpr WHERE crabrpr.cdcooper = par_cdcooper   AND
                               crabrpr.nrdconta = par_nrdconta   AND
                               crabrpr.tpctrato = par_tpctrato   AND
                               crabrpr.nrctrato = par_nrctrato   AND
                               crabrpr.tpdrendi = craprpr.tpdrendi
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

            IF   NOT AVAIL crabrpr   THEN
                 IF   LOCKED crabrpr   THEN
                       DO:
                           aux_cdcritic = 77.
                           PAUSE 1 NO-MESSAGE.
                           NEXT.
                       END.
                 ELSE
                       DO:
                           aux_cdcritic = 55.
                           LEAVE.
                       END.

            aux_cdcritic = 0.
            LEAVE.

        END.

        IF   aux_cdcritic <> 0    OR
             aux_dscritic <> ""   THEN
             LEAVE.

        DELETE crabrpr.

    END. /* Fim , Limpar rendimentos da proposta */
    
    IF    aux_cdcritic <> 0    OR
          aux_dscritic <> ""   THEN
          UNDO, LEAVE Grava.

    /* Rendimentos - Registros separados por pipe e campos por ponto/virgula */
    DO aux_contador = 1 TO NUM-ENTRIES(par_dsdrendi,"|"):
    
       /* Registro */
       ASSIGN reg_dsdregis = ENTRY(aux_contador,par_dsdrendi,"|").
        
       /* Pegar os campos  - Tipo de rendimento e o seu valor */       
       ASSIGN aux_tpdrendi = INTE(ENTRY(1,reg_dsdregis,";"))
              aux_vldrendi = DECI(ENTRY(2,reg_dsdregis,";")).

       DO aux_contado2 = 1 TO 10:

          FIND craprpr WHERE craprpr.cdcooper = par_cdcooper   AND
                             craprpr.nrdconta = par_nrdconta   AND
                             craprpr.tpctrato = par_tpctrato   AND
                             craprpr.nrctrato = par_nrctrato   AND
                             craprpr.tpdrendi = aux_tpdrendi
                             EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                        
          IF   NOT AVAIL craprpr   THEN
               IF   LOCKED craprpr   THEN
                    DO:
                        aux_cdcritic = 77.
                        PAUSE 1 NO-MESSAGE.
                        NEXT.

                    END.
               ELSE
                    DO: /* Criar o rendimento */
                        CREATE craprpr.
                        ASSIGN craprpr.cdcooper = par_cdcooper  
                               craprpr.nrdconta = par_nrdconta
                               craprpr.tpctrato = par_tpctrato
                               craprpr.nrctrato = par_nrctrato
                               craprpr.tpdrendi = aux_tpdrendi
                               craprpr.dsjusren = par_dsjusren.
                    END.

          aux_cdcritic = 0.
          LEAVE.

       END.

       IF   aux_cdcritic <> 0   OR
            aux_dscritic <> ""  THEN
            LEAVE.

       /* Atualizar o valor do rendimento */
       /* Se tiver um deste tipo, somar a ele */
       ASSIGN craprpr.vldrendi = craprpr.vldrendi + aux_vldrendi.

       RELEASE craprpr.

    END. /* Fim do tratamento dos rendimentos das operacoes */

    IF   aux_cdcritic <> 0    OR
         aux_dscritic <> ""   THEN
         UNDO, LEAVE Grava.
    
    /* Limpar os bens da proposta - Apenas alienado FALSE */
    FOR EACH crapbpr WHERE crapbpr.cdcooper = par_cdcooper
                       AND crapbpr.nrdconta = par_nrdconta
                       AND crapbpr.tpctrpro = par_tpctrato
                       AND crapbpr.nrctrpro = par_nrctrato
                       AND crapbpr.flgalien = FALSE
        NO-LOCK:

        DO aux_contador = 1 TO 10:

            FIND crabbpr WHERE crabbpr.cdcooper = par_cdcooper   AND
                               crabbpr.nrdconta = par_nrdconta   AND
                               crabbpr.tpctrpro = par_tpctrato   AND
                               crabbpr.nrctrpro = par_nrctrato   AND
                               crabbpr.idseqbem = crapbpr.idseqbem
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

            IF   NOT AVAIL crabbpr   THEN
                 IF   LOCKED crabbpr   THEN
                      DO:
                          aux_cdcritic = 77.
                          PAUSE 1 NO-MESSAGE.
                          NEXT.
                      END.
                 ELSE
                      DO:
                          aux_cdcritic = 55.
                          LEAVE.
                      END.
                     
            aux_cdcritic = 0.
            LEAVE.

        END.

        IF   aux_cdcritic <> 0    OR
             aux_dscritic <> ""   THEN
             LEAVE.                     

        DELETE crabbpr.

    END. /* Fim, Limpa bens da proposta */
    
    IF   aux_cdcritic <> 0    OR
         aux_dscritic <> ""   THEN
         UNDO, LEAVE Grava.
    
    /* Bens - Dividir registro por pipe e campos por ponto e virgula */
    DO aux_contador = 1 TO NUM-ENTRIES(par_dsdebens,"|"):

       /* Registro */
       ASSIGN reg_dsdregis = ENTRY(aux_contador,par_dsdebens,"|").
       
       IF NUM-ENTRIES(reg_dsdregis,";") <> 8 THEN
       DO:
           ASSIGN aux_cdcritic = 0
                  aux_dscritic = "Caracter invalido na descricao do bem, verifique.".
           UNDO, LEAVE Grava.
       END.

       /* Campos dos bens */
       ASSIGN aux_dsrelbem = CAPS(ENTRY(3,reg_dsdregis,";"))
              aux_persemon = DECI(ENTRY(4,reg_dsdregis,";"))
              aux_qtprebem = INTE(ENTRY(5,reg_dsdregis,";")) 
              aux_vlprebem = DECI(ENTRY(6,reg_dsdregis,";"))
              aux_vlrdobem = DECI(ENTRY(7,reg_dsdregis,";")).
       
       /* Cria bem da proposta */
       CREATE crapbpr.
       ASSIGN crapbpr.cdcooper = par_cdcooper
              crapbpr.nrdconta = par_nrdconta
              crapbpr.tpctrpro = par_tpctrato
              crapbpr.nrctrpro = par_nrctrato
              crapbpr.cdoperad = par_cdoperad
              crapbpr.dtmvtolt = par_dtmvtolt
              crapbpr.flgalien = FALSE
              crapbpr.dsrelbem = aux_dsrelbem
              crapbpr.persemon = aux_persemon
              crapbpr.qtprebem = aux_qtprebem
              crapbpr.vlprebem = aux_vlprebem
              crapbpr.vlrdobem = aux_vlrdobem.
       
       /* Gravar com o mesmo indice da crapbem (idseqbem) */
       IF ENTRY(8,reg_dsdregis,";") <> "" AND 
          ENTRY(8,reg_dsdregis,";") <> "0" THEN 
          ASSIGN con_idseqbem = INTE(ENTRY(8,reg_dsdregis,";")).
       ELSE
          DO: /* quando vire "" significa bem adicionado na proposta */
             FIND LAST crapbem WHERE crapbem.cdcooper = par_cdcooper AND
                                     crapbem.nrdconta = par_nrdconta AND
                                     crapbem.idseqttl = par_idseqttl NO-LOCK NO-ERROR.
             IF AVAIL crapbem THEN DO:
                 IF con_idseqbem = 0 THEN
                    ASSIGN con_idseqbem = crapbem.idseqbem + 1.
                 ELSE 
                    ASSIGN con_idseqbem = con_idseqbem + 1.
             END.
             ELSE
                 ASSIGN con_idseqbem = con_idseqbem + 1.
          END.
       
       DO WHILE TRUE:
          /* Verificar se o idseqbem ja existe na crapbpr */
          FIND FIRST crabbpr2 WHERE crabbpr2.cdcooper = par_cdcooper
                                AND crabbpr2.nrdconta = par_nrdconta
                                AND crabbpr2.tpctrpro = par_tpctrato   
                                AND crabbpr2.nrctrpro = par_nrctrato 
                                AND crabbpr2.idseqbem = con_idseqbem
                                NO-LOCK NO-ERROR.
          IF AVAIL crabbpr2 THEN
          DO:
              ASSIGN con_idseqbem = con_idseqbem + 1.
              NEXT.
          END.
          ELSE
              LEAVE.
       END.
       
       /* Atribui o idseqbem ao registro crapbpr. */
       ASSIGN crapbpr.idseqbem = con_idseqbem.

       /* Salvar o indice do bem para futuro uso Hipoteca/Alienacao. */
       /* Os bens alienados do emprestimo sao gravados nesta tabela*/
       IF   crapbpr.idseqbem + 1 > par_idseqbem  THEN            
            par_idseqbem     = crapbpr.idseqbem + 1.

       RELEASE crapbpr.



    END.
    
    /* Gravar as informacoes ds SCR para o titular, conjuge e avais */
    RUN grava-proposta-scr (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT par_cdoperad,
                            INPUT par_nmdatela,
                            INPUT par_idorigem,
                            INPUT par_dtmvtolt,
                            INPUT par_nrdconta,
                            INPUT 90, /* tpctrato */
                            INPUT par_nrctrato,
                           OUTPUT TABLE tt-erro).
                           
    IF   RETURN-VALUE <> "OK"   THEN
         LEAVE.
    
    /* atribui OK  no return */
    ASSIGN aux_dsreturn = "OK".

    /* Fim inclui novos */
    LEAVE Grava.
   
  END.  /* Fim TRANSACTION Grava */

  RELEASE crapprp.
 
  IF   aux_dscritic <> ""  OR 
       aux_cdcritic <> 0   THEN
       DO:
           RUN gera_erro (INPUT par_cdcooper,
                          INPUT par_cdagenci,
                          INPUT par_nrdcaixa,
                          INPUT 1,            /** Sequencia **/
                          INPUT aux_cdcritic,
                          INPUT-OUTPUT aux_dscritic).
           RETURN "NOK".
       END.     

  RETURN aux_dsreturn.

END PROCEDURE.


/******************************************************************************
 Atualizar os dados cadastrais que foram alterados na proposta em questao.
******************************************************************************/                      
PROCEDURE grava-dados-cadastro:
  /* Fabricio - em 27/06/2014: Alteracao de parametro, de: par_nmdatela
                             por: par_dsoperac.
              Motivo: Com esta alteracao, eu passo a receber nesta procedure
                      a operacao que esta sendo executada, e nao mais a tela
                      que esta sendo usada para a operacao, tendo em vista
                      que todas as operacoes (desconto de titulo, 
                      desconto de cheque, proposta de limite de credito, 
                      proposta de cartao de credito, alem da proposta de 
                      emprestimo) que usam esta procedure, sao executadas na
                      tela ATENDA. Tudo isso pois, agora, eu passo a tratar os
                      bens do avalista da proposta, se existir, apenas quando
                      a operacao for igual 'a 'PROP.EMPREST', pois eh
                      a unica operacao dentre as citadas acima, onde o operador
                      pode fazer a manutencao desse cadastro dos bens do 
                      avalista. A nao existencia desta condicao, fazia com que
                      os bens de um avalista fossem eliminados nesta procedure,
                      caso a operacao fosse diferente de 'PROP.EMPREST',
                      em virtude da nao manutencao de bens para as demais
                      operacoes; fazendo com que o parametro com os bens do
                      avalista entrassem nesta procedure com valor vazio e 
                      dessa forma a procedure entendia que o operador havia
                      excluido todos os bens do aval pela tela da manutencao,
                      mas o que nao eh verdade. */

  DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
  DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
  DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
  DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
  DEF  INPUT PARAM par_dsoperac AS CHAR                           NO-UNDO.
  DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
  DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
  DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
  DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
  DEF  INPUT PARAM par_inpessoa AS INTE                           NO-UNDO.
  
  DEF  INPUT PARAM par_dsdebens AS CHAR                           NO-UNDO.
  DEF  INPUT PARAM par_dsdrendi AS CHAR                           NO-UNDO.
  DEF  INPUT PARAM par_vlsalari AS DECI                           NO-UNDO.
  DEF  INPUT PARAM par_vlalugue AS DECI                           NO-UNDO.
  DEF  INPUT PARAM par_vlsalcon AS DECI                           NO-UNDO.
  DEF  INPUT PARAM par_nmextemp AS CHAR                           NO-UNDO.
  DEF  INPUT PARAM par_perfatcl AS DECI                           NO-UNDO.
  DEF  INPUT PARAM par_dsdfinan AS CHAR                           NO-UNDO.
  DEF  INPUT PARAM par_dsjusren AS CHAR                           NO-UNDO.
  DEF OUTPUT PARAM TABLE FOR tt-erro.


  DEF  VAR         aux_contador AS INTE                           NO-UNDO.
  DEF  VAR         aux_dsdregis AS CHAR                           NO-UNDO.
  DEF  VAR         aux_idseqbem AS INTE                           NO-UNDO.
  DEF  VAR         aux_tpdrendi AS INTE EXTENT 6                  NO-UNDO.
  DEF  VAR         aux_vldrendi AS DECI EXTENT 6                  NO-UNDO.
  DEF  VAR         aux_anoftbru AS INTE EXTENT 12                 NO-UNDO.
  DEF  VAR         aux_mesftbru AS INTE EXTENT 12                 NO-UNDO.
  DEF  VAR         aux_vlrftbru AS DECI EXTENT 12                 NO-UNDO.
  DEF  VAR         par_msgalert AS CHAR                           NO-UNDO.
  DEF  VAR         par_msgrvcad AS CHAR                           NO-UNDO.
  DEF  VAR         log_tpatlcad AS INTE                           NO-UNDO.
  DEF  VAR         log_msgatcad AS CHAR                           NO-UNDO.
  DEF  VAR         log_chavealt AS CHAR                           NO-UNDO. 
  
  /* contador de idseqbem para criar os novos crapbem */
  DEF  VAR         con_idseqbem AS INTE                           NO-UNDO.
  /* ultimo idseqbem */
  DEF  VAR         aux_ulseqbem AS INTE                           NO-UNDO.

  DEF BUFFER crabbem FOR crapbem.

  EMPTY TEMP-TABLE tt-erro.
  EMPTY TEMP-TABLE tt-crapbem.

  ASSIGN aux_cdcritic = 0
         aux_dscritic = "".


  /* Desmontar par_dsdebens para a TT-CRAPBEM e comparar com a crapbem */
  DO aux_contador = 1 TO NUM-ENTRIES(par_dsdebens,"|"):

     ASSIGN aux_dsdregis = ENTRY(aux_contador,par_dsdebens,"|").


     CREATE tt-crapbem.
     ASSIGN tt-crapbem.cdcooper = par_cdcooper
            tt-crapbem.nrdconta = INTE(ENTRY(1,aux_dsdregis,";"))
            tt-crapbem.idseqttl = par_idseqttl
            tt-crapbem.dtmvtolt = par_dtmvtolt
            tt-crapbem.cdoperad = par_cdoperad
            tt-crapbem.dsrelbem = ENTRY(3,aux_dsdregis,";")
            tt-crapbem.persemon = DECI(ENTRY(4,aux_dsdregis,";"))
            tt-crapbem.qtprebem = INTE(ENTRY(5,aux_dsdregis,";"))
            tt-crapbem.vlprebem = DECI(ENTRY(6,aux_dsdregis,";"))
            tt-crapbem.vlrdobem = DECI(ENTRY(7,aux_dsdregis,";")).

     IF  ENTRY(8,aux_dsdregis,";") <> "" THEN 
         tt-crapbem.idseqbem = INTE(ENTRY(8,aux_dsdregis,";")).
     ELSE
         DO:
             FIND LAST crapbem WHERE crapbem.cdcooper = par_cdcooper AND
                                     crapbem.nrdconta = par_nrdconta AND
                                     crapbem.idseqttl = par_idseqttl NO-LOCK NO-ERROR.
             IF AVAIL crapbem THEN DO:
                 
                 IF con_idseqbem = 0 THEN 
                     con_idseqbem = crapbem.idseqbem + 1.
                 ELSE 
                     con_idseqbem = con_idseqbem + 1.

                 tt-crapbem.idseqbem = con_idseqbem.
             END.
             ELSE
                 DO:
                    ASSIGN con_idseqbem        = con_idseqbem + 1
                           tt-crapbem.idseqbem = con_idseqbem.
                 END.
         END.
  END.

  /* Desmontar os rendimentos */
  DO aux_contador = 1 TO NUM-ENTRIES(par_dsdrendi,"|"):

     ASSIGN aux_dsdregis = ENTRY(aux_contador,par_dsdrendi,"|")

            aux_tpdrendi[aux_contador] = INTE(ENTRY(1,aux_dsdregis,";"))
            aux_vldrendi[aux_contador] = DECI(ENTRY(2,aux_dsdregis,";")) .

  END.

  /* Valores de faturamento para P. juridica */
  DO aux_contador = 1 TO NUM-ENTRIES(par_dsdfinan,"|"):

     ASSIGN aux_dsdregis = ENTRY(aux_contador,par_dsdfinan,"|")

            aux_anoftbru[aux_contador] = INTE(ENTRY(1,aux_dsdregis,";"))
            aux_mesftbru[aux_contador] = INTE(ENTRY(2,aux_dsdregis,";"))
            aux_vlrftbru[aux_contador] = DECI(ENTRY(3,aux_dsdregis,";")).

  END.

  Grava_Cadastro:
  DO TRANSACTION WHILE TRUE:
      
      IF par_dsoperac = "PROP.EMPREST" THEN
      DO:
          /* Verifica se tem o bem na tt. Se nao tiver, exclui  */
          FOR EACH crapbem WHERE crapbem.cdcooper = par_cdcooper  AND
                                 crapbem.nrdconta = par_nrdconta  AND
                                 crapbem.idseqttl = par_idseqttl  NO-LOCK:
    
              FIND tt-crapbem WHERE tt-crapbem.cdcooper = crapbem.cdcooper AND
                                    tt-crapbem.nrdconta = crapbem.nrdconta AND
                                    tt-crapbem.idseqttl = crapbem.idseqttl AND
                                    tt-crapbem.idseqbem = crapbem.idseqbem NO-ERROR.
    
              IF  NOT AVAIL tt-crapbem THEN
                  DO:
                      RUN sistema/generico/procedures/b1wgen0056.p 
                                  PERSISTENT SET h-b1wgen0056.
    
                      RUN exclui-registro IN h-b1wgen0056 (INPUT  par_cdcooper,
                                                           INPUT  par_cdagenci,
                                                           INPUT  par_nrdcaixa,
                                                           INPUT  par_cdoperad,
                                                           INPUT  par_nrdconta,
                                                           INPUT  par_idseqttl,
                                                           INPUT  ROWID(crapbem),
                                                           INPUT  0,
                                                           INPUT  par_dsoperac,
                                                           INPUT  par_idorigem,
                                                           INPUT  TRUE,
                                                           INPUT  par_dtmvtolt,
                                                           INPUT  "E",
                                                           OUTPUT par_msgalert,
                                                           OUTPUT log_tpatlcad,
                                                           OUTPUT log_msgatcad,
                                                           OUTPUT log_chavealt,
                                                           OUTPUT par_msgrvcad,
                                                           OUTPUT TABLE tt-erro).
                      DELETE PROCEDURE h-b1wgen0056.
                      
                      IF  RETURN-VALUE <> "OK"   THEN
                          UNDO Grava_Cadastro , RETURN "NOK".
                          
                  END.
              ELSE
                  DO:
                      /* Atualiza o maior idseqbem que ainda existe no cadastro */
                      IF  aux_ulseqbem < crapbem.idseqbem THEN
                      aux_ulseqbem = crapbem.idseqbem.
    
                      /* Se tiver diferenca, altera registro */
                      IF  tt-crapbem.dsrelbem <> crapbem.dsrelbem OR 
                          tt-crapbem.persemon <> crapbem.persemon OR
                          tt-crapbem.qtprebem <> crapbem.qtprebem OR
                          tt-crapbem.vlprebem <> crapbem.vlprebem OR 
                          tt-crapbem.vlrdobem <> crapbem.vlrdobem THEN
                          DO:
                              RUN sistema/generico/procedures/b1wgen0056.p 
                              PERSISTENT SET h-b1wgen0056.
    
                              RUN altera-registro IN h-b1wgen0056 
                                    ( INPUT par_cdcooper,
                                      INPUT par_cdagenci,
                                      INPUT par_nrdcaixa,
                                      INPUT par_nrdconta,
                                      INPUT par_idseqttl,
                                      INPUT par_cdoperad,
                                      INPUT par_dsoperac,
                                      INPUT par_idorigem,
                                      INPUT YES, /* gravar log */
                                      INPUT ROWID(crapbem),
                                      INPUT tt-crapbem.dsrelbem,
                                      INPUT par_dtmvtolt,
                                      INPUT par_dtmvtolt,
                                      INPUT "A",
                                      INPUT tt-crapbem.persemon,
                                      INPUT tt-crapbem.qtprebem,
                                      INPUT tt-crapbem.vlprebem,
                                      INPUT tt-crapbem.vlrdobem,
                                      INPUT tt-crapbem.idseqbem,
                                     OUTPUT par_msgalert,
                                     OUTPUT log_tpatlcad,
                                     OUTPUT log_msgatcad,
                                     OUTPUT log_chavealt,
                                     OUTPUT par_msgrvcad,
                                     OUTPUT TABLE tt-erro).
                              DELETE PROCEDURE h-b1wgen0056.
                              
                              IF  RETURN-VALUE <> "OK"   THEN
                                  UNDO Grava_Cadastro , RETURN "NOK". 
                          END.
                  END. /* else */
          END.
      END.

      /* Inclui os novos bens */
      FOR EACH tt-crapbem WHERE tt-crapbem.idseqbem > aux_ulseqbem :
      
          RUN sistema/generico/procedures/b1wgen0056.p 
                          PERSISTENT SET h-b1wgen0056.

          RUN inclui-registro IN h-b1wgen0056 (INPUT par_cdcooper,
                                               INPUT par_cdagenci,
                                               INPUT par_nrdcaixa,
                                               INPUT par_nrdconta,
                                               INPUT par_idseqttl,
                                               INPUT par_cdoperad,
                                               INPUT par_dsoperac,
                                               INPUT par_idorigem,
                                               INPUT TRUE,
                                               INPUT tt-crapbem.dsrelbem,
                                               INPUT par_dtmvtolt,
                                               INPUT par_dtmvtolt,
                                               INPUT "I",
                                               INPUT tt-crapbem.persemon,
                                               INPUT tt-crapbem.qtprebem,
                                               INPUT tt-crapbem.vlprebem,
                                               INPUT tt-crapbem.vlrdobem,
                                              OUTPUT par_msgalert,
                                              OUTPUT log_tpatlcad,
                                              OUTPUT log_msgatcad,
                                              OUTPUT log_chavealt,
                                              OUTPUT par_msgrvcad,
                                              OUTPUT TABLE tt-erro).
          DELETE PROCEDURE h-b1wgen0056.

          IF   RETURN-VALUE <> "OK"   THEN
               UNDO Grava_Cadastro , RETURN "NOK".
            
      END.
      /* Fim inclui novos */
      


      /* Atualizacao do valor do aluguel */
      DO aux_contador = 1 TO 10:

          /** Endereco Pessoa Fisica - Residencial Aluguel **/
          IF   par_inpessoa = 1   THEN
               FIND LAST crapenc WHERE crapenc.cdcooper = par_cdcooper AND
                                       crapenc.nrdconta = par_nrdconta AND
                                       crapenc.idseqttl = par_idseqttl AND
                                       crapenc.tpendass = 10           AND
                                       crapenc.incasprp = 3
                                       EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

          ELSE  /** Endereco Pessoa Juridica - Comercial **/
               FIND LAST crapenc WHERE crapenc.cdcooper = par_cdcooper AND
                                       crapenc.nrdconta = par_nrdconta AND
                                       crapenc.idseqttl = 1            AND
                                       crapenc.cdseqinc = 1            AND
                                       crapenc.tpendass = 9            AND
                                       crapenc.incasprp = 3
                                       EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

          IF   NOT AVAIL crapenc   THEN
               IF   LOCKED crapenc   THEN
                    DO:
                        aux_cdcritic = 77.
                        PAUSE 1 NO-MESSAGE.
                        NEXT.

                    END.
               
          ASSIGN aux_cdcritic = 0.

          /* Atualiza valor do aluguel e data */
          IF   AVAIL crapenc  THEN
               ASSIGN crapenc.vlalugue = par_vlalugue
                      crapenc.dtaltenc = par_dtmvtolt.
               
          LEAVE.

      END.  /* Fim Atualizacao do Aluguel */        
      
      IF   aux_cdcritic <> 0   THEN
           UNDO Grava_Cadastro , LEAVE.
        
      IF  par_inpessoa = 1   THEN /* Atualizacoes para pessoas fisicas */
          DO:
              /* Atualizar os valores do titular */
              DO aux_contador = 1 TO 10:
             
                  FIND crapttl WHERE crapttl.cdcooper = par_cdcooper   AND
                                     crapttl.nrdconta = par_nrdconta   AND
                                     crapttl.idseqttl = 1   
                                     EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
             
                  IF   NOT AVAIL crapttl  THEN
                       IF   LOCKED crapttl   THEN
                            DO:
                                aux_cdcritic = 72.
                                PAUSE 1 NO-MESSAGE.
                                NEXT.
                            END.
                       ELSE
                            DO:
                                aux_cdcritic = 821.
                                LEAVE.
                            END.
                            
                  aux_cdcritic = 0.
                  LEAVE.
             
              END.
                                
              IF   aux_cdcritic <> 0    OR
                   aux_dscritic <> ""  THEN
                   UNDO Grava_Cadastro , LEAVE Grava_Cadastro.
                                  
              /* Atualizar salario e rendimentos */
              ASSIGN crapttl.vlsalari = par_vlsalari
                     crapttl.tpdrendi = 0
                     crapttl.vldrendi = 0
                     crapttl.dsjusren = "".
              
              DO aux_contador = 1 TO 6:
              
                 ASSIGN crapttl.tpdrendi[aux_contador] = 
                                        aux_tpdrendi[aux_contador]
                        crapttl.vldrendi[aux_contador] = 
                                        aux_vldrendi[aux_contador].

                 IF crapttl.tpdrendi[aux_contador] = 6 THEN
                    crapttl.dsjusren = par_dsjusren.
              
              END.

              DO aux_contador = 1 TO 10:

                  FIND crapcje WHERE crapcje.cdcooper = par_cdcooper   AND
                                     crapcje.nrdconta = par_nrdconta   AND
                                     crapcje.idseqttl = 1              
                                     EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                       
                  IF   NOT AVAILABLE crapcje   THEN
                       IF   LOCKED crapcje   THEN
                            DO:
                                aux_cdcritic = 77.
                                PAUSE 1 NO-MESSAGE.
                                NEXT.

                            END.

                  aux_cdcritic = 0.
                  LEAVE.

              END.
                                  
              IF   aux_cdcritic <> 0   OR
                   aux_dscritic <> ""  THEN
                   UNDO Grava_Cadastro , LEAVE Grava_Cadastro.
                                    
              /* Se possui conjuge */
              IF   AVAIL crapcje  THEN
                   ASSIGN crapcje.vlsalari = par_vlsalcon.
                          /* Nao deve mais alterar nome da empresa do conjuge no emprestimo
                             crapcje.nmextemp = par_nmextemp.*/
                   
          END.
      ELSE    /* Atualizacoes para pessoa juridica */
      IF  par_inpessoa = 2  THEN
          DO:
              DO aux_contador = 1 TO 10:

                 FIND crapjfn WHERE crapjfn.cdcooper = par_cdcooper   AND
                                    crapjfn.nrdconta = par_nrdconta
                                    EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                 IF   NOT AVAILABLE crapjfn   THEN
                      IF   LOCKED crapjfn   THEN
                           DO:
                              aux_cdcritic = 77.
                              PAUSE 1 NO-MESSAGE.
                              NEXT.
                           END.
                      ELSE
                           DO:
                               CREATE crapjfn.
                               ASSIGN crapjfn.cdcooper = par_cdcooper
                                      crapjfn.nrdconta = par_nrdconta.
                           END.

                 aux_cdcritic = 0.
                 LEAVE.

              END.
                                  
              IF   aux_cdcritic <> 0   OR
                   aux_dscritic <> ""  THEN
                   UNDO Grava_Cadastro , LEAVE Grava_Cadastro.
                                    
              ASSIGN crapjfn.perfatcl = par_perfatcl
                     crapjfn.anoftbru = 0
                     crapjfn.mesftbru = 0
                     crapjfn.vlrftbru = 0.

              /* Atualizar faturamentos */
              DO aux_contador = 1 TO 12:

                  ASSIGN crapjfn.anoftbru[aux_contador] = 
                                    aux_anoftbru[aux_contador]
                         crapjfn.mesftbru[aux_contador] =
                                    aux_mesftbru[aux_contador]
                         crapjfn.vlrftbru[aux_contador] =
                                    aux_vlrftbru[aux_contador].                       
              END.

              VALIDATE crapjfn.

          END.  /* Fim atualizacao pessoa juridica*/
          
      LEAVE.
       
  END. /* Fim do DO WHILE TRUE (transaction) */

  IF   aux_cdcritic <> 0    OR
       aux_dscritic <> ""   THEN
       DO:           
           RUN gera_erro (INPUT par_cdcooper,
                          INPUT par_cdagenci,
                          INPUT par_nrdcaixa,
                          INPUT 1,            /** Sequencia **/
                          INPUT aux_cdcritic,
                          INPUT-OUTPUT aux_dscritic).

           RETURN "NOK".
       END.

  RETURN "OK".

END PROCEDURE.


/*****************************************************************************
 Gerar PDF do arquivo e mandar o para o servidor do Ayllos Web 
*****************************************************************************/
PROCEDURE envia-arquivo-web:

    DEF  INPUT PARAM par_cdcooper AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nmarqimp AS CHAR                              NO-UNDO.
    DEF OUTPUT PARAM par_nmarqpdf AS CHAR                              NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    
    EMPTY TEMP-TABLE tt-erro.

    DO WHILE TRUE:

       FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

       IF   NOT AVAIL crapcop   THEN
            DO:
                ASSIGN aux_cdcritic = 651.
                LEAVE.
            END.

       ASSIGN par_nmarqpdf = REPLACE(par_nmarqimp,".ex",".pdf").
               
       /* Gerar o PDF */
       RUN gera-pdf-impressao (INPUT par_nmarqimp,
                               INPUT par_nmarqpdf).         
      
       /* Copiar para o servidor */
       UNIX SILENT VALUE ('sudo /usr/bin/su - scpuser -c ' +
                          '"scp ' + par_nmarqpdf + ' scpuser@' + aux_srvintra +
                          ':/var/www/ayllos/documentos/' + crapcop.dsdircop +
                          '/temp/" 2>/dev/null'). 

       IF SEARCH(par_nmarqimp) <> ? THEN
          UNIX SILENT VALUE ("rm " + par_nmarqimp + "* 2>/dev/null").
       
       IF SEARCH(par_nmarqpdf) <> ? THEN
          UNIX SILENT VALUE ("rm " + par_nmarqpdf + "* 2>/dev/null").

       
       /* Nome do PDF para devolver como parametro */
       par_nmarqpdf = ENTRY(NUM-ENTRIES(par_nmarqpdf,"/"),par_nmarqpdf,"/"). 
                       
       LEAVE.

    END. /* Fim tratamento critica */

    IF   aux_cdcritic <> 0   OR
         aux_dscritic <> ""   THEN
         DO:
             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,         
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).
             RETURN "NOK".
         END.

    RETURN "OK".

END PROCEDURE.


/*****************************************************************************
 Gerar PDF do arquivo da tela imprel quando opcao de relatorios for D
*****************************************************************************/
PROCEDURE envia-arquivo-web-sem-pcl:

    DEF  INPUT PARAM par_cdcooper AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nmarqimp AS CHAR                              NO-UNDO.
    DEF OUTPUT PARAM par_nmarqpdf AS CHAR                              NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    
    EMPTY TEMP-TABLE tt-erro.

    DO WHILE TRUE:

       FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

       IF   NOT AVAIL crapcop   THEN
            DO:
                ASSIGN aux_cdcritic = 651.
                LEAVE.
            END.

       ASSIGN par_nmarqpdf = REPLACE(par_nmarqimp,".ex",".pdf").
               
       /* Gerar o PDF */
       RUN gera-pdf-impressao-sem-pcl (INPUT par_nmarqimp,
                               INPUT par_nmarqpdf).         
       
       /* Copiar para o servidor */
       UNIX SILENT VALUE ('sudo /usr/bin/su - scpuser -c ' +
                          '"scp ' + par_nmarqpdf + ' scpuser@' + aux_srvintra +
                          ':/var/www/ayllos/documentos/' + crapcop.dsdircop +
                          '/temp/" 2>/dev/null').
            
       IF SEARCH(par_nmarqimp) <> ? THEN
          UNIX SILENT VALUE ("rm " + par_nmarqimp + "* 2>/dev/null").
       
       IF SEARCH(par_nmarqpdf) <> ? THEN
          UNIX SILENT VALUE ("rm " + par_nmarqpdf + "* 2>/dev/null").
       
       /* Nome do PDF para devolver como parametro */
       par_nmarqpdf = ENTRY(NUM-ENTRIES(par_nmarqpdf,"/"),par_nmarqpdf,"/"). 
                       
       LEAVE.

    END. /* Fim tratamento critica */

    IF   aux_cdcritic <> 0   OR
         aux_dscritic <> ""   THEN
         DO:
             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,         
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).
             RETURN "NOK".
         END.

    RETURN "OK".

END PROCEDURE.


PROCEDURE gera-arquivo-intranet:

    DEF INPUT PARAM par_cdcooper AS INTE NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE NO-UNDO.
    DEF INPUT PARAM par_nmarqimp AS CHAR NO-UNDO.
    DEF INPUT PARAM par_nmformul AS CHAR NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_nrtamarq AS INTE NO-UNDO.
    DEF VAR aux_dsgerenc AS CHAR NO-UNDO.
    DEF VAR aux_tprelato AS INTE NO-UNDO.
    DEF VAR aux_ingerpdf AS INTE NO-UNDO.
    DEF VAR aux_nmrelato AS CHAR NO-UNDO.
    DEF VAR aux_cdrelato AS INTE NO-UNDO.
    DEF VAR aux_setlinha AS CHAR FORMAT "x(80)" NO-UNDO.
    DEF VAR aux_nmarqtmp AS CHAR FORMAT "x(150)" NO-UNDO.
    DEF VAR aux_nmarqpdf AS CHAR FORMAT "x(40)" NO-UNDO.

    INPUT STREAM str_1 THROUGH VALUE("wc -c " + par_nmarqimp + 
                                 " 2> /dev/null") NO-ECHO.
 
    DO WHILE TRUE ON ENDKEY UNDO, LEAVE.

        SET STREAM str_1 aux_nrtamarq ^.
        LEAVE.

    END.  /*  Fim do DO WHILE TRUE  */

    IF aux_nrtamarq = 0 THEN
        RETURN "NOK".

    /*  Busca dados da cooperativa  */
    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

    IF NOT AVAILABLE crapcop THEN
    DO:
        ASSIGN aux_dscritic = "".

        RUN gera_erro (INPUT par_cdcooper,
                       INPUT par_cdagenci,
                       INPUT 0,
                       INPUT 0,            /** Sequencia **/
                       INPUT 651,
                       INPUT-OUTPUT aux_dscritic).      
        
        RETURN "NOK".
    END.

    IF INDEX(par_nmarqimp,"*") > 0 THEN
    DO:
        ASSIGN aux_dscritic = "Caracter invalido no nome do relatorio " +
                                par_nmarqimp + ". VERIFIQUE!".

        RUN gera_erro (INPUT par_cdcooper,
                       INPUT par_cdagenci,
                       INPUT 0,
                       INPUT 0,            /** Sequencia **/
                       INPUT 0,
                       INPUT-OUTPUT aux_dscritic).      
        
        RETURN "NOK".
    END.

    INPUT STREAM str_1 CLOSE.

    /* Obter Dados para impressao e INTRANET */
    ASSIGN aux_dsgerenc = "NAO"
           aux_tprelato = 0 
           aux_ingerpdf = 0
           aux_nmrelato = " ".

    ASSIGN aux_cdrelato = INT(SUBSTRING(par_nmarqimp, 
                          INDEX(par_nmarqimp, "crrl") + 4, 3)) NO-ERROR.

    IF NOT ERROR-STATUS:ERROR THEN
        DO:
            FIND craprel WHERE craprel.cdcooper = par_cdcooper AND
                               craprel.cdrelato = aux_cdrelato 
                                                    NO-LOCK NO-ERROR.
     
            IF AVAIL craprel THEN
                DO:
                    ASSIGN aux_ingerpdf = craprel.ingerpdf
                           aux_nmrelato = craprel.nmrelato.
                    IF craprel.tprelato = 2 THEN
                        ASSIGN aux_dsgerenc = "SIM"
                               aux_tprelato = 1.
                END.
        END.

        
    /*-----------------  GERAR ARQUIVO PARA INTRANET  ------------*/

    INPUT STREAM str_1 THROUGH VALUE("ls " + par_nmarqimp + 
                                 " 2> /dev/null") NO-ECHO.
     
    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

        SET STREAM str_1 aux_setlinha WITH WIDTH 90.
        
        ASSIGN aux_setlinha = TRIM(aux_setlinha).
        
        IF aux_ingerpdf = 1 THEN
        DO:
            INPUT THROUGH VALUE("basename " + par_nmarqimp) NO-ECHO.
            
            SET aux_nmarqtmp FORMAT "x(150)" WITH WIDTH 160.
          
            INPUT CLOSE.
                
            INPUT THROUGH VALUE("echo " + aux_nmarqtmp + " | cut -d '.'" +
                                " -f 1") NO-ECHO.
            
            SET aux_nmarqpdf FORMAT "x(40)".
                
            INPUT CLOSE.
               
            ASSIGN aux_nmarqtmp = "/usr/coop/" + crapcop.dsdircop + 
                                   "/tmppdf/" + SUBSTR(aux_nmarqtmp, 1, 
                                            LENGTH(aux_nmarqtmp) - 4) + ".txt"
                   aux_nmarqpdf = aux_nmarqpdf + ".pdf".
        
            OUTPUT STREAM str_2 TO VALUE (aux_nmarqtmp).
              
            PUT STREAM str_2 crapcop.nmrescop ";"
                            STRING(YEAR(par_dtmvtolt),"9999") FORMAT "x(4)" ";"
                            STRING(MONTH(par_dtmvtolt),"99")  FORMAT "x(2)" ";"
                            STRING(DAY(par_dtmvtolt),"99")    FORMAT "x(2)" ";"
                            STRING(aux_tprelato,"z9")         FORMAT "x(2)" ";"
                            aux_nmarqpdf ";"
                            CAPS(aux_nmrelato)            FORMAT "x(50)" ";"
                            SKIP.
                         
            OUTPUT STREAM str_2 CLOSE.
            
            /* Cria o arquivo PDF */
            UNIX SILENT VALUE("echo script/CriaPDF.sh " +
                              aux_setlinha + " " + aux_dsgerenc + " " + 
                              par_nmformul + " " +
                              STRING(YEAR(par_dtmvtolt),"9999") +
                              "_" + STRING(MONTH(par_dtmvtolt),"99") +
                              "/" + STRING(DAY(par_dtmvtolt),"99") +
                              " >> /usr/coop/" + crapcop.dsdircop +
                              "/log/CriaPDF.log 2> /dev/null").
             
            UNIX SILENT VALUE("/usr/coop/" + crapcop.dsdircop +
                              "/script/CriaPDF.sh " +
                              aux_setlinha + " " + aux_dsgerenc + " " + 
                              par_nmformul + " " +
                              STRING(YEAR(par_dtmvtolt),"9999") +
                              "_" + STRING(MONTH(par_dtmvtolt),"99") +
                              "/" + STRING(DAY(par_dtmvtolt),"99") + " " +
                              crapcop.dsdircop).
                
        END.
    END.

END PROCEDURE.


/******************************************************************************
 Procedure para buscar os dados da central de risco para o titular, conjuge, 
 e avais das propostas de limite e emprestimo e gravar na crapprp, crapavt e
 crapavl
******************************************************************************/

PROCEDURE grava-proposta-scr:

   DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
   DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
   DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
   DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
   DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
   DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
   DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
   DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
   DEF  INPUT PARAM par_tpctrato AS INTE                           NO-UNDO.
   DEF  INPUT PARAM par_nrctrato AS INTE                           NO-UNDO.
   
   DEF OUTPUT PARAM TABLE FOR tt-erro.

   DEF VAR aux_contador AS INTE                                    NO-UNDO.
   DEF VAR aux_flgtrans AS LOGI INIT FALSE                         NO-UNDO.
   DEF VAR aux_nrcpfcjg AS DECI                                    NO-UNDO.
   DEF VAR aux_nrctacje AS INTE                                    NO-UNDO.
   DEF VAR aux_nrctaav1 AS INTE                                    NO-UNDO.
   DEF VAR aux_nrcpfav1 AS DECI                                    NO-UNDO.
   DEF VAR aux_nrctaav2 AS INTE                                    NO-UNDO.
   DEF VAR aux_nrcpfav2 AS DECI                                    NO-UNDO.
   DEF VAR aux_tpctrato AS INTE                                    NO-UNDO.
    
   ASSIGN aux_cdcritic = 0
          aux_dscritic = "".

   EMPTY TEMP-TABLE tt-erro.

   Grava_Dados:
   DO ON ERROR UNDO, LEAVE Grava_Dados:

      FIND crapass WHERE crapass.cdcooper = par_cdcooper   AND
                         crapass.nrdconta = par_nrdconta
                         NO-LOCK NO-ERROR.

      IF   NOT AVAIL crapass   THEN
           DO:
               ASSIGN aux_cdcritic = 9.
               LEAVE Grava_Dados. 
           END.

      IF   crapass.inpessoa = 1   THEN /* Achar o conjute  */
           DO:
               FIND crapcje WHERE crapcje.cdcooper = par_cdcooper   AND
                                  crapcje.nrdconta = par_nrdconta   AND
                                  crapcje.idseqttl = 1
                                  NO-LOCK NO-ERROR.

               IF   AVAIL crapcje   THEN
                    ASSIGN aux_nrcpfcjg = crapcje.nrcpfcjg
                           aux_nrctacje = crapcje.nrctacje.
           END.

      IF   par_tpctrato = 90   THEN /* Emprestimo */
           DO:
               FIND crawepr WHERE crawepr.cdcooper = par_cdcooper   AND
                                  crawepr.nrdconta = par_nrdconta   AND
                                  crawepr.nrctremp = par_nrctrato
                                  NO-LOCK NO-ERROR.
        
               IF   NOT AVAIL crawepr  THEN
                    DO: 
                        aux_cdcritic = 484.
                        LEAVE Grava_Dados.
                    END.

               /* Buscar conta dos avais */
               ASSIGN aux_nrctaav1 = crawepr.nrctaav1
                      aux_nrctaav2 = crawepr.nrctaav2.

               /* Emprestimo - crapavt */
               ASSIGN aux_tpctrato = 1.

           END.
      ELSE 
           DO:
               FIND craplim WHERE craplim.cdcooper = par_cdcooper   AND
                                  craplim.nrdconta = par_nrdconta   AND
                                  craplim.tpctrlim = par_tpctrato   AND
                                  craplim.nrctrlim = par_nrctrato
                                  NO-LOCK NO-ERROR.
        
               IF   NOT AVAIL craplim   THEN
                    DO:
                        aux_cdcritic = 484.
                        LEAVE Grava_Dados.
                    END.

               /* Buscar conta dos avais */
               ASSIGN aux_nrctaav1 = craplim.nrctaav1
                      aux_nrctaav2 = craplim.nrctaav2.

               /* Lim. credito - crapavt */
               ASSIGN aux_tpctrato = 3.

           END.

      /** Avalistas - Terceiros - Buscar CPF **/
      FOR EACH crapavt WHERE
               crapavt.cdcooper = par_cdcooper   AND
               crapavt.nrdconta = par_nrdconta   AND
               crapavt.nrctremp = par_nrctrato   AND
               crapavt.tpctrato = aux_tpctrato   NO-LOCK:

          IF   aux_nrctaav1 = 0   AND   
               aux_nrcpfav1 = 0   THEN
               ASSIGN aux_nrcpfav1 = crapavt.nrcpfcgc.
          ELSE
          IF   aux_nrctaav2 = 0   THEN
               ASSIGN aux_nrcpfav2 =crapavt.nrcpfcgc.

      END.

      /* Obter o registro da proposta para salvar os dados */
      /* do titular e conjuge */
      DO aux_contador = 1 TO 10:
          
         FIND crapprp WHERE crapprp.cdcooper = par_cdcooper AND
                            crapprp.nrdconta = par_nrdconta AND
                            crapprp.nrctrato = par_nrctrato AND
                            crapprp.tpctrato = par_tpctrato
                            EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
      
         IF  NOT AVAIL crapprp  THEN
             DO:
                 IF  LOCKED crapprp  THEN
                     DO: 
                         ASSIGN aux_cdcritic = 77.
                         NEXT.
                     END.
                 ELSE
                     ASSIGN aux_cdcritic = 510.
             END.
         
         LEAVE.
          
      END. /** Fim Lock crapprp **/

      IF   aux_cdcritic <> 0   THEN
           LEAVE Grava_Dados.

      /* Buscar os dados da central para o titular */
      RUN obtem-valores-central-risco (INPUT par_cdcooper,
                                       INPUT par_cdagenci,
                                       INPUT par_nrdcaixa,
                                       INPUT par_cdoperad,
                                       INPUT par_nmdatela,
                                       INPUT par_idorigem,
                                       INPUT par_dtmvtolt,
                                       INPUT 4, /* crapvop/crapopf */
                                       INPUT par_nrdconta,
                                       INPUT par_tpctrato,
                                       INPUT par_nrctrato,
                                       INPUT par_nrdconta,
                                       INPUT crapass.nrcpfcgc,                                    
                                       INPUT FALSE,
                                      OUTPUT TABLE tt-erro,
                                      OUTPUT TABLE tt-central-risco).

      IF   RETURN-VALUE <> "OK"   THEN
           LEAVE Grava_Dados.

      FIND FIRST tt-central-risco NO-LOCK NO-ERROR.

      /* Se tem dados, gravar na proposta */
      IF   AVAIL tt-central-risco   THEN
           ASSIGN crapprp.dtdrisco = tt-central-risco.dtdrisco
                  crapprp.qtopescr = tt-central-risco.qtopescr
                  crapprp.qtifoper = tt-central-risco.qtifoper
                  crapprp.vltotsfn = tt-central-risco.vltotsfn
                  crapprp.vlopescr = tt-central-risco.vlopescr
                  crapprp.vlrpreju = tt-central-risco.vlrpreju.

      /* Se tem conjuge */
      IF   aux_nrctacje <> 0    OR
           aux_nrcpfcjg <> 0   THEN
           DO:
               /* Buscar os dados da central para o conjuge */
               RUN obtem-valores-central-risco (INPUT par_cdcooper,
                                                INPUT par_cdagenci,
                                                INPUT par_nrdcaixa,
                                                INPUT par_cdoperad,
                                                INPUT par_nmdatela,
                                                INPUT par_idorigem,
                                                INPUT par_dtmvtolt,
                                                INPUT 4, /* crapvop/crapopf */
                                                INPUT aux_nrctacje,
                                                INPUT par_tpctrato,
                                                INPUT par_nrctrato,
                                                INPUT aux_nrctacje,
                                                INPUT aux_nrcpfcjg,
                                                INPUT FALSE,
                                               OUTPUT TABLE tt-erro,
                                               OUTPUT TABLE tt-central-risco).

               IF   RETURN-VALUE <> "OK"   THEN
                    LEAVE Grava_Dados.

               FIND FIRST tt-central-risco NO-LOCK NO-ERROR.

               /* Se tem dados, gravar na proposta  */ 
               IF   AVAIL tt-central-risco   THEN
                   ASSIGN crapprp.dtoutris = tt-central-risco.dtdrisco
                          crapprp.qtopecje = tt-central-risco.qtopescr
                          crapprp.qtifocje = tt-central-risco.qtifoper
                          crapprp.vlsfnout = tt-central-risco.vltotsfn 
                          crapprp.vlopecje = tt-central-risco.vlopescr
                          crapprp.vlprjcje = tt-central-risco.vlrpreju.
                         
                         
           END.

      /* Se tiver aval 1, gravar os dados da scr */
      IF   aux_nrctaav1 <> 0   OR
           aux_nrcpfav1 <> 0   THEN
           DO:
               RUN grava-scr-aval (INPUT par_cdcooper,
                                   INPUT par_nrdconta,
                                   INPUT par_cdoperad,
                                   INPUT par_nmdatela,
                                   INPUT par_idorigem,
                                   INPUT par_dtmvtolt,
                                   INPUT aux_tpctrato,
                                   INPUT par_nrctrato,
                                   INPUT aux_nrctaav1,
                                   INPUT aux_nrcpfav1,
                                  OUTPUT aux_cdcritic,
                                  OUTPUT aux_dscritic).

               IF   RETURN-VALUE <> "OK"   THEN
                    LEAVE Grava_Dados.
           END.

      /* Se tiver aval 2, gravar os dados da scr */
      IF   aux_nrctaav2 <> 0   OR 
           aux_nrcpfav2 <> 0   THEN
           DO:
               RUN grava-scr-aval (INPUT par_cdcooper,
                                   INPUT par_nrdconta,
                                   INPUT par_cdoperad,
                                   INPUT par_nmdatela,
                                   INPUT par_idorigem,
                                   INPUT par_dtmvtolt,
                                   INPUT aux_tpctrato,
                                   INPUT par_nrctrato,
                                   INPUT aux_nrctaav2,
                                   INPUT aux_nrcpfav2,
                                  OUTPUT aux_cdcritic,
                                  OUTPUT aux_dscritic).

               IF   RETURN-VALUE <> "OK"   THEN
                    LEAVE Grava_Dados.
           END.
                   
      /* Procedure executada com sucesso */
      ASSIGN aux_flgtrans = TRUE. 

   END.

   /* Se houve algu erro */
   IF   NOT aux_flgtrans   THEN 
        DO:
            IF   NOT TEMP-TABLE tt-erro:HAS-RECORDS THEN
                 RUN gera_erro (INPUT par_cdcooper,
                                INPUT par_cdagenci,
                                INPUT par_nrdcaixa,
                                INPUT 1,     /** Sequencia **/
                                INPUT aux_cdcritic,
                                INPUT-OUTPUT aux_dscritic).
                          
            RETURN "NOK".            
        END.

   RETURN "OK".

END PROCEDURE.



/******************************************************************************
                                  PROCEDURES INTERNAS 
******************************************************************************/

PROCEDURE grava-scr-aval:
    
   DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.   
   DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
   DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
   DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
   DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
   DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
   DEF  INPUT PARAM par_tpctrato AS INTE                           NO-UNDO.
   DEF  INPUT PARAM par_nrctrato AS INTE                           NO-UNDO.
   DEF  INPUT PARAM par_nrctaava AS INTE                           NO-UNDO.
   DEF  INPUT PARAM par_nrcpfava AS DECI                           NO-UNDO.
   DEF OUTPUT PARAM par_cdcritic AS INTE                           NO-UNDO.
   DEF OUTPUT PARAM par_dscritic AS CHAR                           NO-UNDO.

   DEF VAR aux_contador AS INTE                                    NO-UNDO.


   Grava_Dados:
   DO ON ERROR UNDO, LEAVE Grava_Dados:

      /* Buscar os dados da central para o aval */
      RUN obtem-valores-central-risco (INPUT par_cdcooper,
                                       INPUT 0,
                                       INPUT 0,
                                       INPUT par_cdoperad,
                                       INPUT par_nmdatela,
                                       INPUT par_idorigem,
                                       INPUT par_dtmvtolt,
                                       INPUT 4, /* crapvop/crapopf */
                                       INPUT par_nrctaava,
                                       INPUT par_tpctrato,
                                       INPUT par_nrctrato,
                                       INPUT par_nrctaava,
                                       INPUT par_nrcpfava,
                                       INPUT FALSE,
                                      OUTPUT TABLE tt-erro,
                                      OUTPUT TABLE tt-central-risco).

      IF   RETURN-VALUE <> "OK"   THEN
           RETURN "NOK".

      FIND FIRST tt-central-risco NO-LOCK NO-ERROR.

      IF   NOT AVAIL tt-central-risco   THEN
           RETURN "OK".

      IF   par_nrctaava = 0   THEN /* Avalista Terceiro */
           DO:
               DO aux_contador = 1 TO 10:
          
                  FIND crapavt WHERE crapavt.cdcooper = par_cdcooper AND
                                     crapavt.tpctrato = par_tpctrato AND
                                     crapavt.nrdconta = par_nrdconta AND
                                     crapavt.nrctremp = par_nrctrato AND
                                     crapavt.nrcpfcgc = par_nrcpfava
                                     EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                  
                  IF  NOT AVAIL crapavt  THEN
                      DO:
                          IF  LOCKED crapavt  THEN
                              DO: 
                                  ASSIGN par_cdcritic = 77.
                                  NEXT.
                              END.
                          ELSE
                              ASSIGN par_cdcritic = 839.
                      END.
                  
                  LEAVE.
          
               END. /** Fim Lock crapavt **/

               IF   par_cdcritic <> 0   THEN
                    RETURN "NOK".

               /* Atualizar a SCR para o aval */
               ASSIGN crapavt.dtdrisco = tt-central-risco.dtdrisco  
                      crapavt.qtopescr = tt-central-risco.qtopescr  
                      crapavt.qtifoper = tt-central-risco.qtifoper  
                      crapavt.vltotsfn = tt-central-risco.vltotsfn  
                      crapavt.vlopescr = tt-central-risco.vlopescr  
                      crapavt.vlprejuz = tt-central-risco.vlrpreju. 

           END.
      ELSE                         /* Avalista cooperado */
           DO:
               DO aux_contador = 1 TO 10:
          
                  FIND crapavl WHERE crapavl.cdcooper = par_cdcooper   AND
                                     crapavl.nrdconta = par_nrctaava   AND
                                     crapavl.nrctravd = par_nrctrato   AND
                                     crapavl.tpctrato = par_tpctrato   
                                     EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                  
                  IF  NOT AVAIL crapavl  THEN
                      DO:
                          IF  LOCKED crapavl  THEN
                              DO: 
                                  ASSIGN par_cdcritic = 77.
                                  NEXT.
                              END.
                          ELSE
                              ASSIGN par_cdcritic = 55.
                      END.
                  
                  LEAVE.
          
               END. /** Fim Lock crapavl **/

               IF   par_cdcritic <> 0   THEN
                    RETURN "NOK".

               /* Atualizar o SCR para o aval */
               ASSIGN crapavl.dtdrisco = tt-central-risco.dtdrisco  
                      crapavl.qtopescr = tt-central-risco.qtopescr  
                      crapavl.qtifoper = tt-central-risco.qtifoper  
                      crapavl.vltotsfn = tt-central-risco.vltotsfn  
                      crapavl.vlopescr = tt-central-risco.vlopescr  
                      crapavl.vlprejuz = tt-central-risco.vlrpreju.

           END.

   END.

   RETURN "OK".

END PROCEDURE.

/******************************************************************************
 Procedure que verifica se os dados a serem pegos, deverao ser do cadastro
 do cooperado ou dos dados na proposta de credito
******************************************************************************/

PROCEDURE verifica-contrato-proposta:

   DEF INPUT PARAM par_cdcooper AS INTE                         NO-UNDO.
   DEF INPUT PARAM par_cdagenci AS INTE                         NO-UNDO.
   DEF INPUT PARAM par_nrdcaixa AS INTE                         NO-UNDO.   
   DEF INPUT PARAM par_nrdconta AS INTE                         NO-UNDO.
   DEF INPUT PARAM par_tpctrato AS INTE                         NO-UNDO.
   DEF INPUT PARAM par_nrctrato AS INTE                         NO-UNDO.
   DEF INPUT PARAM par_cddopcao AS CHAR                         NO-UNDO.
    
   DEF OUTPUT PARAM TABLE FOR tt-erro.
   DEF OUTPUT PARAM par_flgcadas AS LOGI                        NO-UNDO.


   DEF VAR          aux_dtmvtolt AS DATE                        NO-UNDO.


   EMPTY TEMP-TABLE tt-erro.

   ASSIGN aux_cdcritic = 0
          aux_dscritic = "".


   /* Se igual a zero , trata de uma nova inclusao de proposta    */
   /* Se realizou alteracao cadastral apos a inclucao da proposta */
   /* Entao pega os dados do cadastro, tela CONTAS                */

   DO WHILE TRUE:

      IF   par_nrctrato = 0    THEN
           DO:
               par_flgcadas = TRUE.
               LEAVE.
           END.
           
      IF   par_tpctrato = 90   THEN  /* Emprestimo */
           DO:
               FIND crawepr WHERE crawepr.cdcooper = par_cdcooper   AND
                                  crawepr.nrdconta = par_nrdconta   AND
                                  crawepr.nrctremp = par_nrctrato
                                  NO-LOCK NO-ERROR.

               IF   NOT AVAIL crawepr  THEN
                    DO:
                        aux_cdcritic = 484.
                        LEAVE.
                    END.

               /* Data da ultima alteraçao proposta */
               ASSIGN aux_dtmvtolt = crawepr.dtaltpro.

               FIND LAST crapalt WHERE crapalt.cdcooper = par_cdcooper   AND
                                       crapalt.nrdconta = par_nrdconta 
                                       NO-LOCK NO-ERROR.                    
           END.
      ELSE
      IF   par_tpctrato > 0   THEN  /* Limite */
           DO:
               FIND craplim WHERE craplim.cdcooper = par_cdcooper   AND
                                  craplim.nrdconta = par_nrdconta   AND
                                  craplim.tpctrlim = par_tpctrato   AND
                                  craplim.nrctrlim = par_nrctrato
                                  NO-LOCK NO-ERROR.

               IF   NOT AVAIL craplim   THEN
                    DO:
                        aux_cdcritic = 484.
                        LEAVE.
                    END.

               aux_dtmvtolt = craplim.dtpropos.

               FIND LAST crapalt WHERE crapalt.cdcooper = par_cdcooper   AND
                                       crapalt.nrdconta = par_nrdconta 
                                       NO-LOCK NO-ERROR.
           END.

      /* Se TRUE Pegar os dados do cadastro do cooperado, senao proposta */
      par_flgcadas =   (AVAIL crapalt                    AND 
                        crapalt.dtaltera >= aux_dtmvtolt AND 
                        par_cddopcao <> "C").
                       
      LEAVE.

   END. /* Fim tratamento criticas */

   IF   aux_cdcritic <>  0    OR
        aux_dscritic <> ""   THEN
        DO:
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,     /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            RETURN "NOK".            
        END.

   RETURN "OK".

END PROCEDURE.

PROCEDURE consulta_bacen:
    
    DEF INPUT PARAM par_cdcooper  AS INTE                           NO-UNDO.
    DEF INPUT PARAM par_nrdconta  AS INTE                           NO-UNDO.
    DEF INPUT PARAM par_nrctremp  AS INTE                           NO-UNDO.
    DEF INPUT PARAM par_nrctacon  AS INTE                           NO-UNDO.
    DEF INPUT PARAM par_nrcpfcon  AS DECI                           NO-UNDO.
                                                                   
    DEF OUTPUT PARAM par_dtconbir AS DATE                           NO-UNDO.
    DEF OUTPUT PARAM par_qtopescr AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_qtifoper AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_vltotsfn AS DECI                           NO-UNDO.
    DEF OUTPUT PARAM par_vlopescr AS DECI                           NO-UNDO.
    DEF OUTPUT PARAM par_vlprejui AS DECI                           NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                           NO-UNDO.

    DEF VAR aux_contador AS INTE                                    NO-UNDO.
    DEF VAR aux_contado2 AS INTE                                    NO-UNDO.
    DEF VAR aux_contado3 AS INTE                                    NO-UNDO.
    DEF VAR aux_dstagxml AS CHAR                                    NO-UNDO.
    DEF VAR aux_dstagvlr AS CHAR                                    NO-UNDO.
    DEF VAR ponteiro_xml AS MEMPTR                                  NO-UNDO.
    DEF VAR xml_req      AS LONGCHAR                                NO-UNDO.
    DEF VAR xDoc         AS HANDLE                                  NO-UNDO.  
    DEF VAR xRoot        AS HANDLE                                  NO-UNDO. 
    DEF VAR xRoot2       AS HANDLE                                  NO-UNDO. 
    DEF VAR xRoot3       AS HANDLE                                  NO-UNDO.
    DEF VAR xRoot4       AS HANDLE                                  NO-UNDO.
    DEF VAR xText        AS HANDLE                                  NO-UNDO.


    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

    RUN STORED-PROCEDURE pc_consulta_bacen 
        aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper,
                                             INPUT par_nrdconta,
                                             INPUT par_nrctremp,
                                             INPUT 1, /* inprodut */
                                             INPUT par_nrctacon,
                                             INPUT par_nrcpfcon,
                                            OUTPUT "",
                                            OUTPUT 0,
                                            OUTPUT ""). 
    
    CLOSE STORED-PROC pc_consulta_bacen
       aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
    
    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
    
    ASSIGN par_dscritic =  pc_consulta_bacen.pr_dscritic
                            WHEN pc_consulta_bacen.pr_dscritic <> ?.
    
    IF  par_dscritic <> ""   THEN
        RETURN "NOK".

    ASSIGN xml_req = pc_consulta_bacen.pr_retxml.

    CREATE X-DOCUMENT xDoc.    /* Vai conter o XML completo */
    CREATE X-NODEREF  xRoot.   
    CREATE X-NODEREF  xRoot2. 
    CREATE X-NODEREF  xRoot3. 
    CREATE X-NODEREF  xRoot4.
    CREATE X-NODEREF  xText.  
    
    SET-SIZE(ponteiro_xml) = LENGTH(xml_req) + 1.
    PUT-STRING(ponteiro_xml,1) = xml_req.
    
    xDoc:LOAD("MEMPTR",ponteiro_xml,FALSE).
      
    xDoc:GET-DOCUMENT-ELEMENT(xRoot).
     
    DO aux_contador = 1 TO xRoot:NUM-CHILDREN:
    
       xRoot:GET-CHILD(xRoot2,aux_contador).

       DO  aux_contado2 = 1 TO xRoot2:NUM-CHILDREN:
                   
            xRoot2:GET-CHILD(xRoot3,aux_contado2).
        
            DO aux_contado3 = 1 TO xRoot3:NUM-CHILDREN:
    
               xRoot3:GET-CHILD(xRoot4,aux_contado3).       
               
               IF   xRoot4:NUM-CHILDREN = 0   THEN
                    NEXT.
    
               xRoot4:GET-CHILD(xText,1).
    
               ASSIGN aux_dstagxml = xRoot4:NAME
                      aux_dstagvlr = xText:NODE-VALUE NO-ERROR.
      
               CASE aux_dstagxml:
                   WHEN "dtconbir" THEN
                       ASSIGN par_dtconbir = DATE(aux_dstagvlr).
                   WHEN "qtopescr" THEN
                       ASSIGN par_qtopescr = INTE(aux_dstagvlr).
                   WHEN "qtifoper" THEN
                       ASSIGN par_qtifoper = INTE(aux_dstagvlr).
                   WHEN "vltotsfn" THEN
                       ASSIGN par_vltotsfn = DECI(aux_dstagvlr).
                   WHEN "vlopescr" THEN
                       ASSIGN par_vlopescr = DECI(aux_dstagvlr).
                   WHEN "vlprejui" THEN
                       ASSIGN par_vlprejui = DECI(aux_dstagvlr).
               END CASE.
           
            END.

       END.

    END.

    RETURN "OK".

END PROCEDURE.
 

 
/* ..........................................................................*/




