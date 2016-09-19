/* .............................................................................

   Programa: Fontes/internet.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Evandro
   Data    : Fevereiro/2006                   Ultima Atualizacao: 06/04/2016

   Dados referentes ao programa:
   

   Frequencia: Diario (on-line)
   Objetivo  : Efetuar Manutencao dos dados referentes a Internet do Associado.

   Alteracoes: 26/02/2007 - Desabilitado campos "Valor Limite/Dia" e 
                            "Valor Usado" (Elton).
                            
               13/03/2007 - Emitir a mensagem do frame f_mensagem quando for
                            liberado o acesso a conta (Evandro).
                            
               12/04/2007 - Alimentar a data de alteracao da senha quando a
                            mesma for liberada, por causa do controle de
                            alteracoes de senha da internet;
                          - Habilitados os campos de limites da web; 
                          - Rotina para cadastrar contas para transferencia;
                          - Rotinas para gerar log na nova estrutura: craplgm
                            e craplgi
                            (Evandro/David).

               23/07/2007 - Critica se o limite do 1o. titular for menor que os
                            demais titulares
                          - Solicita senha quando inclui/exclui contas para
                            transferencia (Guilherme).

               15/08/2007 - Criacao campos vllimtrf Transf , vllimpgo Pagtos
                          - Alteracao no frame f_habilita 
                          - Mostrar novos campos, excluido campo "valor usado"
                            (Guilherme).
                            
               04/09/2007 - Substituicao dos campos vllimtrf e vllimpgo pelo
                            campo vllimweb (Elton).
                            
               19/09/2007 - Funcao ENCODE no campo cddsenha (Junior).
                          - Retirar procedure que atualiza crapass (David).
                          
               16/11/2007 - Zerar campo snh.qtacerro na 'Liberacao'(Guilherme).
               
               26/12/2007 - Ajustado Limites de internet pessoa juridica
                            (Guilherme).
                            
               22/01/2007 - Internet para pessoa juridica (Guilherme)
                          - Mensagem para aviso de bloqueio referente ao
                            primeiro acesso baseado na craptab de limites da
                            internet (David).           

               29/01/2009 - Alterado para incluir campos 'Recebe Arq.Cobranca'
                            e e-mail (Gabriel)

               22/04/2009 - Acerto na atualizacao do crapass (Ze).

               14/07/2009 - Acerto no tamanho do campo de e-mail (David).

               29/07/2009 - Alteracoes do Projeto de Transferencia para 
                            Credito de Salario (David).
                            
               25/01/2010 - Alterar ordem da crawcti BY nome (Guilherme)
               
               22/04/2010 - Verificar se existem agendamentos pendentes no
                            cancelamento do acesso ao InternetBank (David).
               
               14/12/2010 - Alterado format do campo nmprimtl para x(40).
                            Kbase.
                            
               10/01/2011 - Passar a parte de Cobranca dentro da habilitacao
                            para a rotina COBRANCA da ATENDA (Gabriel).  
                            
               13/03/2012 - Convertida para trabalhar com a BO15 (Lucas).
               
               17/05/2012 - Projeto TED Internet (Lucas/David).
               
               03/07/2012 - Ajuste de parametro na procedure
                            valida-inclusao-conta-transferencia (David Kistner)
                            
               07/11/2012 - Alteraçao para permitir atualizaçao das Letras de
                            Segurança juntamente com a Senha da Internet (Lucas).
                            
               11/12/2012 - Alteracao layout da tela, inclusao novos campos
                            dtlimtrf dtlimpgo dtlimted dtlimweb (Daniel).  
                            
               11/01/2013 - Requisitar cadastro das Letras ao liberar acesso (Lucas).
               
               12/03/2013 - Correçao para aceitar senhas inicidas em zero. (Lucas).
               
               22/03/2013 - Transferencia intercooperativa (Gabriel). 
               
               17/04/2013 - Cadastro de limites VR Boleto (David Kruger).
               
               23/07/2013 - Adicionado campo referente a data bloqueio de senha
                            assim como sua leitura na crapsnh. (Jorge)
                            
               12/02/2014 - Inclusao da verificacao de acessos das opcoes da 
                            rotina INTERNET (Carlos).
                            
               29/05/2014 - Concatena o numero do servidor no endereco do
                            terminal (Tiago-RKAM).
                            
               15/12/2014 - Melhorias Cadastro de Favorecidos TED
                           (André Santos - SUPERO)   
                           
               22/01/2015 - (Chamado 217240) Alterar formato do numero de caracteres 
                            de todos os valores de parametros para pessoa juridica
                            (Tiago Castro - RKAM).
                            
               27/04/2015 - Inclusão do campo ISPB SD271603 FDR041 (Vanessa)
               
               03/09/2015 - Projeto Reformulacao cadastral 
                            (Tiago Castro - RKAM). 
                           
			         10/11/2015 - Restrição de acesso para PJ quando conta exigir Assinatura
							              Conjunta, PRJ 131 - Ass. Conjunta (Jean Michel).
							
               24/11/2015 - Adicionado parametro de entrada flgimpte em chamada 
                            de proc. liberar-senha-internet.
                            (Jorge/David) Projeto Multipla Assinatura PJ.             
               
               06/04/2016 - Ajustes feito para que nao seja possivel cadastrar o nome
                            do favorecido com caracteres especiais conforme solicitado
                            no chamado 421691. (Kelvin)
                           
............................................................................. */

{ includes/var_online.i }
{ includes/var_atenda.i }

{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/b1wgen0015tt.i }
{ sistema/generico/includes/b1wgen0059tt.i }
{ sistema/generico/includes/gera_erro.i }

DEF VAR aux_cdsenha1 AS CHAR FORMAT "X(08)"                           NO-UNDO.
DEF VAR aux_cdsenha2 AS CHAR FORMAT "X(08)"                           NO-UNDO.
DEF VAR tel_cddsenha AS CHAR FORMAT "X(08)"                           NO-UNDO.
DEF VAR aux_qtdiaace AS INTE                                          NO-UNDO.
DEF VAR aux_inpessoa AS INTE                                          NO-UNDO.
DEF VAR aux_inconfir AS INTE                                          NO-UNDO.
DEF VAR aux_idseqttl AS INTE                                          NO-UNDO.
DEF VAR aux_nrdctato AS INTE                                          NO-UNDO.
DEF VAR aux_cntrgcad AS INTE                                          NO-UNDO.
DEF VAR aux_cntrgpen AS INTE                                          NO-UNDO.
DEF VAR aux_intipdif AS INTE                                          NO-UNDO.
DEF VAR aux_insitcta AS INTE                                          NO-UNDO.
DEF VAR aux_tpctatrf AS INTE                                          NO-UNDO.
DEF VAR tel_inpessoa AS INTE                                          NO-UNDO.
DEF VAR aux_cddbanco AS INTE                                          NO-UNDO.
DEF VAR aux_cdispbif AS INTE                                          NO-UNDO.
DEF VAR aux_cdageban AS INTE                                          NO-UNDO.
DEF VAR aux_qtregist AS INTE                                          NO-UNDO.
DEF VAR aux_flgregis AS LOGICAL INIT FALSE                            NO-UNDO.
DEF VAR aux_flgimpte AS LOGICAL INIT FALSE                            NO-UNDO.
DEF VAR aux_idastcjt AS INTE                                          NO-UNDO.

/* Vars de retorno */
DEF VAR aux_nmtpcont AS CHAR                                          NO-UNDO.
DEF VAR aux_intpcont AS CHAR                                          NO-UNDO.

DEF VAR aux_postpcon AS INTE  INIT 1                                  NO-UNDO.
DEF VAR aux_nmtpctin AS CHAR                                          NO-UNDO.
DEF VAR aux_nmtipcta AS CHAR                                          NO-UNDO.
DEF VAR aux_nmarqimp AS CHAR                                          NO-UNDO.
DEF VAR aux_dssitcta AS CHAR                                          NO-UNDO.
DEF VAR aux_confirma AS CHAR FORMAT "!"                               NO-UNDO.
DEF VAR aux_tldatela AS CHAR                                          NO-UNDO.
DEF VAR aux_dsavsace AS CHAR                                          NO-UNDO.
DEF VAR aux_dsmensag AS CHAR                                          NO-UNDO.
DEF VAR tel_nmdavali AS CHAR                                          NO-UNDO.
DEF VAR tel_nmdavanv AS CHAR                                          NO-UNDO.
DEF VAR aux_dscpfcgc AS CHAR                                          NO-UNDO.
DEF VAR tel_dspessoa AS CHAR                                          NO-UNDO.
DEF VAR aux_nmtitula AS CHAR                                          NO-UNDO.
DEF VAR aux_ifsnmtit AS CHAR                                          NO-UNDO.
DEF VAR aux_nmdcampo AS CHAR                                          NO-UNDO.
DEF VAR aux_msgaviso AS CHAR                                          NO-UNDO.

DEF VAR tel_sennumer AS CHAR INIT "Numerica"                          NO-UNDO.
DEF VAR tel_solletra AS CHAR INIT "Letras de Seguranca"               NO-UNDO.
DEF VAR tel_dssennov AS CHAR                                          NO-UNDO.
DEF VAR tel_dssencon AS CHAR                                          NO-UNDO.
DEF VAR tel_flgcadas AS CHAR                                          NO-UNDO.
DEF VAR aux_flgletca AS LOGI                                          NO-UNDO.
DEF VAR aux_qtdregis AS INTE                                          NO-UNDO.

DEF VAR aux_nrcpfcgc AS DEC                                           NO-UNDO.

DEF VAR flg_vldinclu AS LOGI                                          NO-UNDO.

DEF VAR tel_vllimpgo LIKE crapsnh.vllimweb                            NO-UNDO.
DEF VAR tel_vllimtrf LIKE crapsnh.vllimtrf                            NO-UNDO.
DEF VAR tel_vllimweb LIKE crapsnh.vllimpgo                            NO-UNDO.
DEF VAR tel_vllimted LIKE crapsnh.vllimted                            NO-UNDO.
DEF VAR tel_vllimvrb LIKE crapsnh.vllimvrb                            NO-UNDO.
DEF VAR tel_nmrescop AS   CHAR                                        NO-UNDO.
DEF VAR tel_nrctatrf LIKE crapcti.nrctatrf                            NO-UNDO.

/* Impressoes */
DEF VAR aux_nmendter AS CHAR    FORMAT "x(20)"                        NO-UNDO.
DEF VAR par_flgrodar AS LOGICAL               INIT TRUE               NO-UNDO.
DEF VAR aux_flgescra AS LOGICAL                                       NO-UNDO.
DEF VAR aux_dscomand AS CHAR                                          NO-UNDO.
DEF VAR par_flgfirst AS LOGICAL               INIT TRUE               NO-UNDO.
DEF VAR tel_dsimprim AS CHAR    FORMAT "x(8)" INIT "Imprimir"         NO-UNDO.
DEF VAR tel_dscancel AS CHAR    FORMAT "x(8)" INIT "Cancelar"         NO-UNDO.
DEF VAR par_flgcance AS LOGICAL                                       NO-UNDO.

/* Opcoes dos menus */                      
DEF VAR tel_opbloque AS CHAR INIT "Bloqueio"                          NO-UNDO.
DEF VAR tel_opcancel AS CHAR INIT "Cancelamento"                      NO-UNDO.
DEF VAR tel_opimpres AS CHAR INIT "Impressao"                         NO-UNDO.
DEF VAR tel_opcadsen AS CHAR INIT "Senha"                             NO-UNDO.
DEF VAR tel_oplibera AS CHAR INIT "Liberacao"                         NO-UNDO.
DEF VAR tel_ophabint AS CHAR INIT "Habilitacao"                       NO-UNDO.
DEF VAR tel_opcadlim AS CHAR INIT "CADASTRAMENTO DE LIMITE"           NO-UNDO.
DEF VAR tel_opcadcon AS CHAR INIT "CADASTRAMENTO DE CONTAS"           NO-UNDO.
DEF VAR tel_oppencon AS CHAR INIT "PENDENTES CONFIRMACAO"             NO-UNDO.
DEF VAR tel_opconcad AS CHAR INIT "CONTAS CADASTRADAS"                NO-UNDO.
DEF VAR tel_opinccon AS CHAR INIT "INCLUIR CONTA"                     NO-UNDO.
DEF VAR tel_opctcoop AS CHAR INIT "CONTAS SISTEMA CECRED"             NO-UNDO.
DEF VAR tel_opctnsif AS CHAR INIT "CONTAS DE OUTRAS IFs"              NO-UNDO.
DEF VAR tel_opaltsit AS CHAR INIT "ALTERAR"                           NO-UNDO.
DEF VAR aux_nrispbif AS CHAR FORMAT "99999999"                        NO-UNDO.
DEF VAR h-b1wgen0015 AS HANDLE                                        NO-UNDO.
DEF VAR h-b1wgen0059 AS HANDLE                                        NO-UNDO.
DEF VAR h_b1wgen0032 AS HANDLE                                        NO-UNDO.

/* Querys */
DEF QUERY q_tt-dados-tit      FOR tt-dados-titular.
DEF QUERY q_procuradores      FOR tt-dados-preposto.
DEF QUERY q_tt-cnts-pend      FOR tt-contas-pendentes.
DEF QUERY q_tt-cnts-cadastr   FOR tt-contas-cadastradas.
DEF QUERY q_zoom-bancos       FOR tt-crapban.
DEF QUERY q_zoom-agencias     FOR tt-crapagb.
DEF QUERY q_crapcop           FOR tt-crapcop.

/* Browsers */
DEF BROWSE b_tt-dados-tit QUERY q_tt-dados-tit
      DISP tt-dados-titular.idseqttl                    COLUMN-LABEL "Seq"
           tt-dados-titular.nmextttl  FORMAT "x(40)"    COLUMN-LABEL "Titular"
           WITH 9 DOWN OVERLAY TITLE "TITULARES".

DEF BROWSE b_zoom-bancos QUERY q_zoom-bancos
      DISP SPACE(5)
           tt-crapban.nmextbcc         COLUMN-LABEL "Nome do Banco"
           SPACE(3)
           tt-crapban.cdbccxlt         COLUMN-LABEL "Codigo"
           SPACE(5)
           tt-crapban.nrispbif         COLUMN-LABEL "ISPB"
           SPACE(5) 
           WITH 9 DOWN OVERLAY. 

DEF BROWSE b_zoom-agencias QUERY q_zoom-agencias
      DISP SPACE(5)
           tt-crapagb.nmageban         COLUMN-LABEL "Nome da Agencia"
           SPACE(3)
           tt-crapagb.cdageban         COLUMN-LABEL "Codigo"
           SPACE(5)
           WITH 9 DOWN OVERLAY. 

DEF BROWSE b_procuradores QUERY q_procuradores
    DISPLAY tt-dados-preposto.nrdctato COLUMN-LABEL "Conta/dv"  FORMAT "zzzz,zzz,9"
            tt-dados-preposto.nmdavali COLUMN-LABEL "Nome"      FORMAT "x(25)"    
            tt-dados-preposto.dscpfcgc COLUMN-LABEL "C.P.F"     FORMAT "x(14)"       
            tt-dados-preposto.dsproftl COLUMN-LABEL "Cargo"     FORMAT "x(15)"    
            WITH 5 DOWN NO-BOX.

DEF BROWSE b_tt-cnts-pend QUERY q_tt-cnts-pend
    DISP tt-contas-pendentes.flgselec NO-LABEL FORMAT "*/"
         tt-contas-pendentes.nrctatrf COLUMN-LABEL "Conta/dv"  FORMAT "zzzzzzzzzzzz,9"
         tt-contas-pendentes.nrcpfcgc COLUMN-LABEL "CPF/CNPJ"  FORMAT "x(18)"
         tt-contas-pendentes.dsprotoc COLUMN-LABEL "Protocolo" FORMAT "x(30)"
         tt-contas-pendentes.dstipfav  COLUMN-LABEL "Situacao" FORMAT "x(10)"
         WITH 5 DOWN WIDTH 78 OVERLAY CENTERED NO-BOX.

DEF BROWSE b_tt-cnts-cadastr QUERY q_tt-cnts-cadastr                             
    DISP tt-contas-cadastradas.dsageban FORMAT "x(20)"
         tt-contas-cadastradas.dsctatrf COLUMN-LABEL "Conta/dv"         FORMAT "x(14)"
         tt-contas-cadastradas.nmtitula COLUMN-LABEL "Nome do Titular"  FORMAT "x(29)"
         tt-contas-cadastradas.dssitcta COLUMN-LABEL "Situacao"         FORMAT "x(10)"
         WITH 5 DOWN NO-BOX WIDTH 78 OVERLAY CENTERED.

DEF BROWSE b_crapcop QUERY q_crapcop
    DISP tt-crapcop.cdagectl COLUMN-LABEL "Agencia"
         tt-crapcop.nmrescop COLUMN-LABEL "Cooperativa" FORMAT "X(15)"
         WITH 5 DOWN NO-BOX WIDTH 28 OVERLAY CENTERED.

/* Forms */
FORM b_tt-dados-tit HELP "Use as SETAS para navegar." SKIP
     WITH NO-BOX CENTERED OVERLAY ROW 8 FRAME f_titulares. 

FORM SKIP(1)
     aux_dsavsace NO-LABEL FORMAT "x(58)"
     SKIP
     " e cadastrar uma frase para o acesso da conta."
     SKIP(1)
     WITH OVERLAY CENTERED ROW 13 WIDTH 60 COLOR MESSAGE FRAME f_mensagem.

FORM SKIP(1)
     aux_msgaviso NO-LABEL FORMAT "x(58)" AT 02
     SKIP(1)
     WITH OVERLAY CENTERED ROW 13 WIDTH 62 COLOR MESSAGE FRAME f_aviso.

FORM SKIP(1)
     tt-dados-titular.dssitsnh     AT 17 LABEL "Situacao"                FORMAT "x(10)"
     tt-dados-titular.nmprepos     AT 17 LABEL "Preposto"                FORMAT "x(50)"
     tt-dados-titular.vllimtrf     AT 02 LABEL "Valor Limite/Dia Transf" FORMAT "z,zzz,zz9.99"
     tt-dados-titular.dtlimtrf     AT 40 LABEL "Dt.Alter.Limite/Dia Transf" FORMAT "99/99/9999"
     tt-dados-titular.vllimpgo     AT 03 LABEL "Valor Limite/Dia Pagto"  FORMAT "z,zzz,zz9.99"
     tt-dados-titular.dtlimpgo     AT 41 LABEL "Dt.Alter.Limite/Dia Pagto"  FORMAT "99/99/9999"
     tt-dados-titular.vllimted     AT 05 LABEL "Valor Limite/Dia TED"    FORMAT "z,zzz,zz9.99"
     tt-dados-titular.dtlimted     AT 43 LABEL "Dt.Alter.Limite/Dia TED" FORMAT "99/99/9999"
     tt-dados-titular.vllimvrb     AT 09 LABEL "Limite VR Boleto"        FORMAT "z,zzz,zz9.99"
     tt-dados-titular.dtlimvrb     AT 41 LABEL "Dt.Alter.Limite VR Boleto"  FORMAT "99/99/9999"
     tt-dados-titular.dtlibera     AT 11 LABEL "Data Liberacao"          FORMAT "99/99/9999"
     tt-dados-titular.hrlibera     AT 52 LABEL "Hora Liberacao"
     tt-dados-titular.dtultace     AT 07 LABEL "Data Ultimo Acesso"      FORMAT "99/99/9999"
     tt-dados-titular.hrultace     AT 48 LABEL "Hora Ultimo Acesso"
     tt-dados-titular.dtaltsit     AT 02 LABEL "Data Alteracao Situacao" FORMAT "99/99/9999"
     tt-dados-titular.dtaltsnh     AT 46 LABEL "Data Alteracao Senha"    FORMAT "99/99/9999"
     tt-dados-titular.dtblutsh     AT 47 LABEL "Data Bloqueio Senha"     FORMAT "99/99/9999"
     SKIP(1)
     tel_opbloque                  AT  6 NO-LABEL                        FORMAT "x(08)"
                                   HELP "Bloqueia o uso da internet."
     SPACE(3)
     tel_opcancel                        NO-LABEL                        FORMAT "x(12)"
                                   HELP "Cancela o uso da internet."
     SPACE(3)
     tel_opimpres                        NO-LABEL                        FORMAT "x(09)"
                                   HELP "Imprime o contrato."
     SPACE(3)
     tel_opcadsen                        NO-LABEL                        FORMAT "x(05)"
                                   HELP "Altera a senha numerica para acesso a internet."
     SPACE(3)
     tel_oplibera                        NO-LABEL                        FORMAT "x(09)"
                                   HELP "Liberacao para uso da internet."    
     SPACE(3)
     tel_ophabint                        NO-LABEL                        FORMAT "x(11)"
                                   HELP "Altera contas para transf. e os valores de limites da internet."
     WITH ROW 7 WIDTH 80 CENTERED SIDE-LABELS NO-LABELS OVERLAY TITLE COLOR NORMAL
     aux_tldatela FRAME f_internet_juridica.
          
FORM SKIP(1)
     tt-dados-titular.dssitsnh  AT 16 LABEL "Situacao"                FORMAT "x(10)"
     SKIP(1)
     tt-dados-titular.vllimweb  AT 09 LABEL "Valor Limite/Dia"        FORMAT "z,zzz,zz9.99"
     tt-dados-titular.dtlimweb  AT 47 LABEL "Dt.Alter.Limite/Dia"     FORMAT "99/99/9999" 
     tt-dados-titular.vllimted  AT 05 LABEL "Valor Limite/Dia TED"    FORMAT "z,zzz,zz9.99"
     tt-dados-titular.dtlimted  AT 43 LABEL "Dt.Alter.Limite/Dia TED" FORMAT "99/99/9999" 
     tt-dados-titular.vllimvrb  AT 09 LABEL "Limite VR Boleto"        FORMAT "z,zzz,zz9.99"
     tt-dados-titular.dtlimvrb  AT 41 LABEL "Dt.Alter.Limite VR Boleto" FORMAT "99/99/9999"
     tt-dados-titular.dtlibera  AT 11 LABEL "Data Liberacao"          FORMAT "99/99/9999"
     tt-dados-titular.hrlibera  AT 52 LABEL "Hora Liberacao"
     tt-dados-titular.dtultace  AT 07 LABEL "Data Ultimo Acesso"      FORMAT "99/99/9999" 
     tt-dados-titular.hrultace  AT 48 LABEL "Hora Ultimo Acesso"
     tt-dados-titular.dtaltsit  AT 02 LABEL "Data Alteracao Situacao" FORMAT "99/99/9999"
     tt-dados-titular.dtaltsnh  AT 46 LABEL "Data Alteracao Senha"    FORMAT "99/99/9999"
     tt-dados-titular.dtblutsh  AT 47 LABEL "Data Bloqueio Senha"     FORMAT "99/99/9999"
      
     SKIP(1)
     tel_opbloque               AT  6 NO-LABEL                        FORMAT "x(08)"
                                HELP "Bloqueia o uso da internet."
     SPACE(3)
     tel_opcancel                     NO-LABEL                        FORMAT "x(12)"
                                HELP "Cancela o uso da internet."
     SPACE(3)
     tel_opimpres                     NO-LABEL                        FORMAT "x(09)"
                                HELP "Imprime o contrato."
     SPACE(3)
     tel_opcadsen                     NO-LABEL                        FORMAT "x(05)"
                                HELP "Altera a senha numerica para acesso a internet."
     SPACE(3)
     tel_oplibera                     NO-LABEL                        FORMAT "x(09)"
                                HELP "Liberacao para uso da internet."    
     SPACE(3)
     tel_ophabint                     NO-LABEL                        FORMAT "x(11)"
                                HELP "Altera contas para transf. e os valores de limites da internet."
     WITH ROW 8 WIDTH 80 CENTERED SIDE-LABELS NO-LABELS OVERLAY TITLE COLOR NORMAL
     aux_tldatela FRAME f_internet_fisica.          
          
FORM SKIP(1)                            
     tel_cddsenha   AT 10 LABEL "Senha Atual"    BLANK AUTO-RETURN
                    HELP "Senha atual com 8 posicoes numericas"
                    VALIDATE(ENCODE(STRING(tel_cddsenha)) <> "",
                               "003 - Senha errada.") 
     SKIP(1)
     aux_cdsenha1   AT 11 LABEL "Nova Senha"     BLANK AUTO-RETURN
                    HELP "Senha com 8 posicoes numericas"
     SKIP(1)     
     aux_cdsenha2   AT 07 LABEL "Confirme Senha" BLANK AUTO-RETURN
                    HELP "Repita a nova senha"
     SKIP(1)
     WITH CENTERED ROW 12 WIDTH 40 SIDE-LABELS OVERLAY FRAME f_alt_senha.
     
FORM SKIP(1)                            
     tel_cddsenha   AT 16 LABEL "Senha"          BLANK AUTO-RETURN
                    HELP "Senha com 8 posicoes numericas"
     SKIP(1)
     aux_cdsenha2   AT 07 LABEL "Confirme Senha" BLANK AUTO-RETURN
                    HELP "Repita a nova senha"
     SKIP(1)                            
     WITH CENTERED ROW 12 WIDTH 40 SIDE-LABELS OVERLAY FRAME f_libera.
     
FORMAT SKIP(1)
     aux_cdsenha1   AT 16 LABEL "Senha"          BLANK AUTO-RETURN
                    HELP "Senha com 8 posicoes numericas"
                    VALIDATE(ENCODE(aux_cdsenha1) = STRING(crapsnh.cddsenha),
                               "003 - Senha errada.") 
     SKIP(1)
     aux_cdsenha2   AT 07 LABEL "Confirme Senha" BLANK AUTO-RETURN
                    VALIDATE(aux_cdsenha2 <> "","088 - Senha deve ser informada.")
                    HELP "Repita a senha"
     SKIP(1)                            
     WITH CENTERED ROW 12 WIDTH 40 SIDE-LABELS OVERLAY TITLE 
     "Validacao de Senha" FRAME f_valida.

FORM SKIP(2) 
     tel_vllimtrf   AT 12 LABEL "Valor Limite/Dia Transferencia"              FORMAT "z,zzz,zz9.99"
                    HELP "Informe o valor do limite diario para transferencias"
     SKIP
     tel_vllimpgo   AT 16 LABEL "Valor Limite/Dia Pagamento"                  FORMAT "z,zzz,zz9.99"
                    HELP "Informe o valor do limite diario para pagamentos"
     tel_vllimted   AT 22 LABEL "Valor Limite/Dia TED"                        FORMAT "z,zzz,zz9.99" 
                    HELP "Informe o valor do limite diario para transferencias TED"
     tel_vllimvrb   AT 18 LABEL "Limite VR Boleto (Pagto)"                    FORMAT "z,zzz,zz9.99"
                    HELP "Informe o limite de pagamento do VR Boleto"
     SKIP(1)
     WITH CENTERED ROW 14 WIDTH 78 TITLE "Transacoes" SIDE-LABELS OVERLAY 
     FRAME f_transacoes_juridica.
                    
FORM SKIP(2)
     tel_vllimweb   AT 09 LABEL "Limite/Dia(Transf/Paga)"                     FORMAT "z,zzz,zz9.99"
                    HELP "Informe o limite diario para transferencias e pagamentos"
     tel_vllimted   AT 12 LABEL "Valor Limite/Dia TED"                        FORMAT "z,zzz,zz9.99"
                    HELP "Informe o valor do limite diario para transferencias TED"
     tel_vllimvrb   AT 08 LABEL "Limite VR Boleto (Pagto)"                    FORMAT "z,zzz,zz9.99"
                    HELP "Informe o limite de pagamento do VR Boleto"
     SKIP(2)
     WITH CENTERED ROW 14 WIDTH 78 TITLE "Transacoes" SIDE-LABELS OVERLAY 
     FRAME f_transacoes_fisica.


FORM SKIP(2)
     tel_opcadlim   AT 9  NO-LABEL   FORMAT "x(25)"
                    HELP "Alterar os valores de limites da internet."
     tel_opcadcon   AT 43 NO-LABEL   FORMAT "x(25)"                
                  HELP "Incluir/Excluir contas para transferencias"
     SKIP(2)
     WITH CENTERED ROW 14 WIDTH 78 TITLE "Habilitacao" NO-LABELS OVERLAY 
     FRAME f_habilita.

FORM SKIP(1)
     tel_oppencon                   AT 24    NO-LABEL   FORMAT "x(21)"
                                    HELP "Verificar contas com confirmacao pendente." "("
     aux_cntrgpen                   NO-LABEL FORMAT "999" ")"
     SKIP(1)
     tel_opconcad                   AT 26     NO-LABEL   FORMAT "x(18)"
                                    HELP "Verificar situacao de contas cadastradas." "("
     aux_cntrgcad                   NO-LABEL FORMAT "999" ")"
     SKIP(1)
     tel_opinccon                   AT 30     NO-LABEL   FORMAT "x(13)"                
                                    HELP "Incluir contas para transferencia."
     WITH CENTERED ROW 14 WIDTH 78 TITLE "Habilitacao - CADASTRAMENTO DE CONTAS"  NO-LABELS OVERLAY 
     FRAME f_cadcon.

FORM SKIP(1)
     b_tt-cnts-pend HELP "Use <ESPACO> para selecionar e  <F4> para encerrar." SKIP 
     WITH CENTERED OVERLAY WIDTH 80 ROW 12 FRAME f_tt-cnts-pend TITLE "Habilitacao - Cadastramento de Contas - Pendentes" SIDE-LABELS.


FORM SKIP(1)                         
     "Dados Favorecido:"            AT 10
     SKIP(1)
     tt-contas-pendentes.cddbanco   AT 10  LABEL "Banco"                  FORMAT "zz9"
     tt-contas-pendentes.nrispbif   AT 24  LABEL "ISPB"                   FORMAT "99999999"
     tt-contas-pendentes.cdageban   AT 45  LABEL "Agencia"                FORMAT "zzz9"
     SKIP(1) 
     tt-contas-pendentes.nrctatrf   AT 10  LABEL "Conta Corrente"         FORMAT "zzzzzzzzzzzz,9"
     tt-contas-pendentes.nmtitula   AT 10  LABEL "Nome do titular"        FORMAT "x(50)"                
     aux_dscpfcgc                   AT 10  NO-LABEL                       FORMAT "x(16)"
     tt-contas-pendentes.nrcpfcgc   AT 27  NO-LABEL                       FORMAT "x(18)"
     SKIP(1)                        
     tt-contas-pendentes.dstransa   AT 10  LABEL "Data Pre-Cadastro"      FORMAT "x(30)"
     tt-contas-pendentes.dsprotoc   AT 18  LABEL "Protocolo"              FORMAT "x(40)"
     SKIP(1)
     WITH CENTERED ROW 8 WIDTH 80 TITLE "Habilitacao - Cadastramento de Contas - Pendentes" OVERLAY
     SIDE-LABELS FRAME f_det-cont-pend.

FORM SKIP(1)
     "Dados Favorecido:"            AT 10
     SKIP(1)
     tt-contas-cadastradas.cddbanco AT 2  LABEL "Banco"                  FORMAT "zz9"
     aux_nrispbif                   AT 14  LABEL "ISPB"                   FORMAT "99999999"
     tt-contas-cadastradas.cdageban AT 33  LABEL "Agencia"                FORMAT "zzz9"
     tt-contas-cadastradas.nrctatrf AT 48  LABEL "Conta Corrente"         FORMAT "zzzzzzzzzzzz,9"
     aux_ifsnmtit                   AT 10  LABEL "Nome do Titular"        FORMAT "x(50)"
                                           VALIDATE(aux_ifsnmtit <> "", "Nome do Titular nao pode estar vazio.")
                                           HELP "Insira o nome do Titular."

     aux_dscpfcgc                   AT 10  NO-LABEL                       FORMAT "x(16)"
                                           
     aux_nrcpfcgc                   AT 27  NO-LABEL                       FORMAT "99999999999999"
                                           VALIDATE(aux_nrcpfcgc <> 0, "CPF/CNPJ do Titular nao pode ser nulo.")
                                           HELP "Insira o CPF/CNPJ do Titular."

     tel_inpessoa                   AT 10  LABEL "Tipo de Pessoa"         FORMAT "9"
                                           VALIDATE(CAN-DO("1,2",STRING(tel_inpessoa)),
                                                           "014 - Opcao errada.") 
                                           HELP "Insira o Tipo de Pessoa (1 - Fisica / 2 - Juridica.)" " - "
                                    
     tel_dspessoa                   AT 31  NO-LABEL                       FORMAT "x(10)"
                                    
     aux_nmtipcta                   AT 10  LABEL "Tipo de Conta"          FORMAT "x(18)"
                                           HELP "Use as SETAS para selecionar o Tipo de Conta."

     tt-contas-cadastradas.dstransa AT 10  LABEL "Data Pre-Cadastro"      FORMAT "x(30)"
     tt-contas-cadastradas.dsoperad AT 10  LABEL "Operador Cadastro"      FORMAT "x(40)"
     aux_insitcta                   AT 19  LABEL "Situacao"               FORMAT "9"
                                    HELP "Informe a situacao da conta (2-Ativa/3-Bloqueada)"
                                    VALIDATE(CAN-DO("3,2",aux_insitcta),
                                             "014 - Opcao errada.")
     "-"                            
     aux_dssitcta                   AT 33  NO-LABEL                       FORMAT "x(10)"
     SKIP(1)
     tel_opaltsit                   AT 40  NO-LABEL                       FORMAT "x(7)"
     WITH CENTERED ROW 7 WIDTH 80 TITLE "Habilitacao - Cadastramento de Contas - Contas Cadastradas" OVERLAY
     SIDE-LABELS FRAME f_det-cont-cad-otrif.

FORM SKIP(1)
     "Dados Favorecido:"            AT 10
     SKIP(1)
     tt-contas-cadastradas.dsageban AT 10  LABEL "Cooperativa"            FORMAT "x(20)"
     tt-contas-cadastradas.nrctatrf AT 10  LABEL "Conta/Dv   "            FORMAT "zzzz,zzz,9"
     tt-contas-cadastradas.nmtitula AT 10  LABEL "Nome do titular"        FORMAT "x(50)"                
     aux_dscpfcgc                   AT 10  NO-LABEL                       FORMAT "x(16)"
     tt-contas-cadastradas.dscpfcgc AT 27  NO-LABEL                       FORMAT "x(18)"
     tt-contas-cadastradas.dstransa AT 10  LABEL "Data Pre-Cadastro"      FORMAT "x(30)"
     tt-contas-cadastradas.dsoperad AT 10  LABEL "Operador Cadastro"      FORMAT "x(40)"
     aux_insitcta                   AT 19  LABEL "Situacao"               FORMAT "9"
                                    HELP "Informe a situacao da conta (2-Ativa/3-Bloqueada)"
                                    VALIDATE(CAN-DO("3,2",aux_insitcta),
                                            "014 - Opcao errada.")
     "-"
     aux_dssitcta AT 33  NO-LABEL                      FORMAT "x(10)"
     SKIP(1)
     tel_opaltsit                   AT 40  NO-LABEL                      FORMAT "x(7)"
     WITH CENTERED ROW 8 WIDTH 80 TITLE "Habilitacao - Cadastramento de Contas - Contas Cadastradas" OVERLAY
     SIDE-LABELS FRAME f_det-cont-cad-coop.


FORM SKIP(1)
     b_tt-cnts-cadastr HELP "Use as SETAS para navegar e ENTER para detalhes" SKIP 
     WITH CENTERED OVERLAY NO-BOX WIDTH 78 ROW 12 FRAME f_tt-cnts-cadastr SIDE-LABELS.

FORM SKIP(1)
     tel_opctcoop                 AT 13     NO-LABEL   FORMAT "x(21)"
                                    HELP "Pesquisar contas do sistema CECRED."
     tel_opctnsif                 AT 43     NO-LABEL   FORMAT "x(20)"                
                                    HELP "Pesquisar contas de outras IFs."
     WITH 6 DOWN CENTERED ROW 8 WIDTH 80 TITLE "Habilitacao - Cadastramento de Contas - Contas Cadastradas" NO-LABELS OVERLAY
     FRAME f_op-cnts-cadastr.

FORM SKIP(1)
     tel_opctcoop                 AT 13     NO-LABEL   FORMAT "x(21)"
                                    HELP "Incluir conta da Cooperativa."
     tel_opctnsif                 AT 46     NO-LABEL   FORMAT "x(20)"                
                                    HELP "Incluir conta de outras IFs."
     WITH 6 DOWN CENTERED ROW 8 WIDTH 80 TITLE "Habilitacao - Cadastramento de Contas - Incluir Conta" NO-LABELS OVERLAY
     FRAME f_op-cnts-incluir.

FORM SKIP(1)
     tel_nmrescop                 AT 07     LABEL "Cooperativa" FORMAT "X(20)"
                                  HELP "Digite <F7> para listar as cooperativas."  
     tel_nrctatrf                 AT 10     LABEL "Conta/DV"  FORMAT "zzzz,zzz,9"
                                  HELP "Insira o numero da conta para transferencia."
     aux_nmtitula                 AT 11     LABEL "Titular"   FORMAT "x(40)"                
     aux_dscpfcgc                 AT 10     LABEL "CPF/CNPJ"  FORMAT "x(18)"
     WITH CENTERED ROW 13 WIDTH 65 SIDE-LABELS NO-BOX OVERLAY
     FRAME f_incluir-conta-coop.

FORM aux_cddbanco AT 2   LABEL "Banco"                  FORMAT "zz9"
                         HELP "Insira o codigo do Banco ou F7 para listar."
     
     aux_cdispbif AT 14   LABEL "ISPB"                  FORMAT "99999999"
                         HELP "Insira o ISPB do Banco ou F7 para listar."

     aux_cdageban AT 32  LABEL "Agencia"                FORMAT "zzz9"
                         HELP "Insira o numero da Agencia ou F7 para listar."
    
     tel_nrctatrf AT 48  LABEL "Conta Corrente"         
                         VALIDATE(tel_nrctatrf <> 0, "Conta para Transferencia nao pode ser nula.")
                         HELP "Insira o numero da Conta para Transferencia."
     SKIP(1)
     aux_ifsnmtit AT 8  LABEL "Nome do Titular"        FORMAT "x(50)"
                         VALIDATE(aux_ifsnmtit <> "", "Nome do Titular nao pode estar vazio.")
                         HELP "Insira o nome do Titular."
                                
                                                        
     aux_nrcpfcgc AT 15  LABEL "CPF/CNPJ"               FORMAT "99999999999999"
                         VALIDATE(aux_nrcpfcgc <> 0, "CPF/CNPJ do Titular nao pode ser nulo.")
                         HELP "Insira o CPF/CNPJ do Titular."

     tel_inpessoa AT 9  LABEL "Tipo de Pessoa"         FORMAT "9"
                         VALIDATE(CAN-DO("1,2",STRING(tel_inpessoa)),
                                         "014 - Opcao errada.") 
                         HELP "Insira o Tipo de Pessoa (1 - Fisica / 2 - Juridica.)" " - "

     tel_dspessoa AT 31  NO-LABEL                       FORMAT "x(10)"

     aux_nmtpctin AT 10  LABEL "Tipo de Conta"          FORMAT "x(18)"
                         VALIDATE(aux_nmtpctin <> "", "Tipo da Conta nao pode estar vazio.")
                         HELP "Use as SETAS para selecionar o Tipo de Conta."
     SKIP(1)
     WITH CENTERED ROW 13 WIDTH 78 OVERLAY NO-BOX SIDE-LABELS 
     FRAME f_incluir-conta-otrif.

FORM b_procuradores
     SKIP(1)
     tel_vllimtrf   AT 03 LABEL "Limite/Dia Transferencia" FORMAT "z,zzz,zz9.99"
     SKIP
     tel_vllimpgo   AT 03 LABEL "Limite/Dia Pagamento    " FORMAT "z,zzz,zz9.99"
     SKIP
     tel_nmdavali   AT 03 LABEL "Preposto atual"           FORMAT "x(25)"
     SKIP
     tel_nmdavanv   AT 03 LABEL "Preposto novo "           FORMAT "x(25)"
     WITH CENTERED ROW 8 TITLE "Selecao de Preposto" SIDE-LABELS OVERLAY 
     FRAME f_procurad.

DEF FRAME f_zoom-bancos
          b_zoom-bancos HELP "Use as SETAS para navegar e <F4> para sair" SKIP 
          WITH NO-BOX CENTERED OVERLAY ROW 7.

DEF FRAME f_zoom-agencias
          b_zoom-agencias HELP "Use as SETAS para navegar e <F4> para sair" SKIP 
          WITH NO-BOX CENTERED OVERLAY ROW 7.

FORM SKIP(1)
     tel_dssennov AT 3 FORMAT "x(3)" LABEL " Letras de Seguranca" BLANK
                  HELP "Informe letras de 'A' a 'U'."
     SKIP(1)
     tel_dssencon AT 3 FORMAT "x(3)" LABEL "Confirme suas letras" BLANK
                  HELP "Informe letras de 'A' a 'U'."
     " "
     SKIP(1)
     WITH ROW 12 CENTERED TITLE COLOR NORMAL " Letras de Seguranca "
          OVERLAY SIDE-LABELS FRAME f_senha_let.

FORM SKIP(1)
     tel_sennumer AT 5
     HELP "Tecle <Entra> para confirmar ou <Fim> para retornar."
     tel_solletra  FORMAT "x(19)" AT 18
     HELP "Tecle <Entra> para confirmar ou <Fim> para retornar."
     SKIP(1)
     WITH ROW 14 COLUMN 14 OVERLAY CENTERED  WIDTH 42
     NO-LABELS FRAME f_opcao_senha.

FORM b_crapcop
        HELP ""
     WITH ROW 12 CENTERED OVERLAY WIDTH 30 NO-LABELS FRAME f_cooperativas.

/*................................. TRIGGER ................................*/

ON  ANY-KEY OF b_tt-cnts-pend DO:
    
    IF  LASTKEY = 32 THEN /* ESPACO */
        DO: /* Verifica se o registro existe e a situacao for diferente de excluido */
            IF  AVAIL tt-contas-pendentes AND tt-contas-pendentes.insitfav <> 3 THEN
                DO:
                    IF  tt-contas-pendentes.flgselec THEN
                        ASSIGN tt-contas-pendentes.flgselec:SCREEN-VALUE
                                 IN BROWSE b_tt-cnts-pend = STRING(FALSE)
                               tt-contas-pendentes.flgselec = FALSE.
                    ELSE
                        ASSIGN tt-contas-pendentes.flgselec:SCREEN-VALUE 
                                 IN BROWSE b_tt-cnts-pend = STRING(TRUE)
                               tt-contas-pendentes.flgselec = TRUE.
                END.
    END.
END.

/* Trigger do Tp. de Pessoa [Cnts. Cadastr IF's] */            
ON VALUE-CHANGED OF tel_inpessoa IN FRAME f_det-cont-cad-otrif
    DO:
        IF  FRAME-VALUE = "1" THEN
            ASSIGN tel_inpessoa = INT(FRAME-VALUE)
                   tel_dspessoa = "Fisica"
                   aux_dscpfcgc = "CPF do Titular:".
        ELSE
        IF FRAME-VALUE = "2" THEN
            ASSIGN tel_inpessoa = INT(FRAME-VALUE)
                   tel_dspessoa = "Juridica"
                   aux_dscpfcgc = "CNPJ do Titular:".
        ELSE
            ASSIGN tel_dspessoa = ""
                   aux_dscpfcgc = "CPF do Titular:".
                
        DISPLAY tel_dspessoa aux_dscpfcgc WITH FRAME f_det-cont-cad-otrif.
    END.

/* Trigger do Tp. de Pessoa [Inclusao de Cnts. IF's] */
ON VALUE-CHANGED OF tel_inpessoa IN FRAME f_incluir-conta-otrif
    DO:
        IF  FRAME-VALUE = "1" THEN
            ASSIGN tel_inpessoa = INT(FRAME-VALUE)
                   tel_dspessoa = "Fisica".
        ELSE
        IF FRAME-VALUE = "2" THEN
            ASSIGN tel_inpessoa = INT(FRAME-VALUE)
                   tel_dspessoa = "Juridica".
        ELSE
            ASSIGN tel_dspessoa = "".

        DISPLAY tel_dspessoa WITH FRAME f_incluir-conta-otrif.
    END.

 /* Trigger do do ISPB [Inclusao de Cnts. IF's] vanessa */
ON RETURN OF aux_cddbanco IN FRAME f_incluir-conta-otrif
    DO:

        ASSIGN aux_cddbanco = INTE(aux_cddbanco:SCREEN-VALUE).

        IF aux_cddbanco > 0 THEN DO:
             
            EMPTY TEMP-TABLE tt-crapban-ispb.
            
            RUN sistema/generico/procedures/b1wgen0015.p 
              PERSISTENT SET h-b1wgen0015.
        
            RUN busca_crapban IN h-b1wgen0015(INPUT aux_cddbanco,
                                              INPUT "",
                                              INPUT 0,
                                              OUTPUT TABLE tt-crapban-ispb).
       
            DELETE PROCEDURE h-b1wgen0015.
            
            FIND tt-crapban-ispb NO-LOCK.
        
            IF AVAIL tt-crapban-ispb THEN
            DO:                    
                ASSIGN aux_cddbanco = tt-crapban-ispb.cdbccxlt.
                ASSIGN aux_cdispbif = tt-crapban-ispb.nrispbif.
               
            END.
        
            IF (aux_cddbanco <> 0 AND aux_cdispbif <> 0) OR (aux_cddbanco = 1 AND aux_cdispbif = 0)  THEN
               DISPLAY aux_cddbanco aux_cdispbif WITH FRAME f_incluir-conta-otrif.
                   
        END.
       
    END.
 /* Trigger do do BANCO [Inclusao de Cnts. IF's] vanessa */
ON RETURN OF aux_cdispbif IN FRAME f_incluir-conta-otrif DO:
    
    EMPTY TEMP-TABLE tt-crapban-ispb.
      
    ASSIGN aux_cdispbif = INTE(aux_cdispbif:SCREEN-VALUE).
    
    RUN sistema/generico/procedures/b1wgen0015.p 
      PERSISTENT SET h-b1wgen0015.
    
    RUN busca_crapban IN h-b1wgen0015(INPUT 0,
                                      INPUT "",
                                      INPUT aux_cdispbif,
                                      OUTPUT TABLE tt-crapban-ispb).
    
    FIND tt-crapban-ispb NO-LOCK.
    
    IF AVAIL tt-crapban-ispb THEN
        DO: 
            ASSIGN aux_cddbanco = tt-crapban-ispb.cdbccxlt.
            ASSIGN aux_cdispbif = tt-crapban-ispb.nrispbif. 
        END.  
        
       IF (aux_cddbanco <> 0 AND aux_cdispbif <> 0) OR (aux_cddbanco = 1 AND aux_cdispbif = 0)  THEN
           DISPLAY aux_cddbanco aux_cdispbif WITH FRAME f_incluir-conta-otrif.
          
   
    DELETE PROCEDURE h-b1wgen0015.

    
    
END.

/* Trigger Browse [Cnts.Pendentes] */
ON  RETURN OF b_tt-cnts-pend
    DO:
        IF  TEMP-TABLE tt-contas-pendentes:HAS-RECORDS THEN
            DO:
                HIDE FRAME f_tt-cnts-pend.
                VIEW FRAME f_det-cont-pend.
                IF tt-contas-pendentes.inpessoa = 1 THEN
                    ASSIGN aux_dscpfcgc = "CPF do Titular:".
                ELSE
                    ASSIGN aux_dscpfcgc = "CNPJ do Titular:".      
    
                DISPLAY tt-contas-pendentes.cddbanco
                        tt-contas-pendentes.nrispbif
                        tt-contas-pendentes.cdageban
                        tt-contas-pendentes.nmtitula
                        tt-contas-pendentes.nrctatrf
                        tt-contas-pendentes.nrcpfcgc
                        tt-contas-pendentes.dstransa
                        tt-contas-pendentes.dsprotoc
                        aux_dscpfcgc
                        WITH FRAME f_det-cont-pend.

                MESSAGE tt-contas-pendentes.dssitfav.
    
                WAIT-FOR RETURN, END-ERROR OF CURRENT-WINDOW.
            END.
    
        APPLY "GO".
    
    END.

/* Trigger da Sit. da Conta de Transf. [Cnts. Cadastr IF's] */
ON  VALUE-CHANGED OF aux_insitcta IN FRAME f_det-cont-cad-otrif 
    DO: 
        ASSIGN aux_insitcta = INT(FRAME-VALUE).
        
        ASSIGN aux_dssitcta = "".
        DISP aux_dssitcta WITH FRAME f_det-cont-cad-otrif.

        IF  aux_insitcta = 2 THEN
            DO: 
                ASSIGN aux_dssitcta = "Ativa".
                DISP aux_dssitcta WITH FRAME f_det-cont-cad-otrif.
            END.

        IF  aux_insitcta = 3 THEN
            DO:
                ASSIGN aux_dssitcta = "Bloqueada".
                DISP aux_dssitcta WITH FRAME f_det-cont-cad-otrif.
            END.
END.

/* Trigger da Sit. da Conta de Transf. [Cnts. Cadastr Coop.] */
ON  VALUE-CHANGED OF aux_insitcta IN FRAME f_det-cont-cad-coop 
    DO:
        ASSIGN aux_insitcta = INT(FRAME-VALUE).
        
        ASSIGN aux_dssitcta = "".
        DISP aux_dssitcta WITH FRAME f_det-cont-cad-coop.
        
        IF  aux_insitcta = 2 THEN
            DO: 
                ASSIGN aux_dssitcta = "Ativa".
                DISP aux_dssitcta WITH FRAME f_det-cont-cad-coop.
            END.
        IF  aux_insitcta = 3 THEN
            DO:
                ASSIGN aux_dssitcta = "Bloqueada".
                DISP aux_dssitcta WITH FRAME f_det-cont-cad-coop.
            END.
END.


/* F7 do incluir nova conta do sistema cecred */
ON "RECALL" OF tel_nmrescop IN FRAME f_incluir-conta-coop DO:
    
    RUN zoom_cooperativas.

END.

ON "RETURN" OF b_crapcop IN FRAME f_cooperativas DO:
   
    IF   NOT AVAIL tt-crapcop   THEN
         RETURN.

    ASSIGN  aux_cdageban = tt-crapcop.cdagectl
            aux_cddbanco = tt-crapcop.cdbcoctl
            tel_nmrescop = tt-crapcop.cdagenmr.

    DISPLAY tel_nmrescop WITH FRAME f_incluir-conta-coop.

    APPLY "GO".

END.

/*................................. PRINCIPAL ................................*/

DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

    RUN sistema/generico/procedures/b1wgen0015.p 
        PERSISTENT SET h-b1wgen0015.
        
    RUN obtem-dados-titulares IN h-b1wgen0015  (INPUT glb_cdcooper,
                                                INPUT glb_cdagenci,
                                                INPUT 0, /* Caixa */
                                                INPUT glb_cdoperad,
                                                INPUT glb_nmdatela,
                                                INPUT 1, /* Ayllos */
                                                INPUT tel_nrdconta,
                                                INPUT 1, /* idseqttl */
                                                INPUT FALSE,
                                                OUTPUT aux_inpessoa,
												OUTPUT aux_idastcjt,
                                                OUTPUT TABLE tt-dados-titular,
                                                OUTPUT TABLE tt-erro).
                                                
    DELETE PROCEDURE h-b1wgen0015.
    
    /* Verifica se a Procedure retornou erro */
    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
    
            IF  AVAILABLE tt-erro  THEN
                MESSAGE tt-erro.dscritic.
                NEXT.
        END.

	/* Verificacao de tipo de conta e se exige assinatura conjunta JMD */
	IF aux_idastcjt = 1 THEN
		DO:
			MESSAGE "Conta exige assinatura conjunta. Utilize o Ayllos Web.".
			PAUSE 3 NO-MESSAGE.
			HIDE MESSAGE.
			LEAVE.
		END.	
	/* Fim verificacao assinatura conjunta JMD */

    /* Lista Titulares */
    FIND tt-dados-titular NO-LOCK NO-ERROR.

    IF  NOT AVAIL tt-dados-titular THEN 
        DO:    
            OPEN QUERY q_tt-dados-tit FOR EACH tt-dados-titular NO-LOCK
                                           BY tt-dados-titular.idseqttl.
                                   
            ON  RETURN OF b_tt-dados-tit
                DO:                    
                    ASSIGN aux_idseqttl = tt-dados-titular.idseqttl.
                    APPLY "GO". 
                END.

            UPDATE b_tt-dados-tit WITH FRAME f_titulares.
        END.
    ELSE 
        DO:
            IF  KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
                LEAVE.

            ASSIGN aux_idseqttl = tt-dados-titular.idseqttl.
        END.

    ASSIGN aux_tldatela = " ACESSO A CONTA CORRENTE VIA INTERNET (" + STRING(aux_idseqttl) + " TITULAR)".

    lab:
    DO WHILE TRUE ON ENDKEY UNDO, LEAVE lab:

        HIDE FRAME f_titulares.
        HIDE FRAME f_opcao_senha NO-PAUSE.
       

        RUN sistema/generico/procedures/b1wgen0015.p 
        PERSISTENT SET h-b1wgen0015.
        
        RUN obtem-dados-titulares IN h-b1wgen0015  (INPUT glb_cdcooper,
                                                    INPUT glb_cdagenci,
                                                    INPUT 0, /* Caixa */
                                                    INPUT glb_cdoperad,
                                                    INPUT glb_nmdatela,
                                                    INPUT 1, /* Ayllos */
                                                    INPUT tel_nrdconta,
                                                    INPUT 1, /* idseqttl */
                                                    INPUT TRUE,
                                                    OUTPUT aux_inpessoa,
													OUTPUT aux_idastcjt,
                                                    OUTPUT TABLE tt-dados-titular,
                                                    OUTPUT TABLE tt-erro).
                                                    
        DELETE PROCEDURE h-b1wgen0015.
        
        /* Verifica se a Procedure retornou erro */
        IF  RETURN-VALUE = "NOK"  THEN
            DO:
                FIND FIRST tt-erro NO-LOCK NO-ERROR.
        
                IF  AVAILABLE tt-erro  THEN
                    MESSAGE tt-erro.dscritic.
                    NEXT.
            END.

        /* Exibe dados referentes ao titular escolhido */
        FIND tt-dados-titular WHERE tt-dados-titular.idseqttl = aux_idseqttl NO-LOCK NO-ERROR.
    
        IF  aux_inpessoa = 1  THEN
            DO:
                DISPLAY tt-dados-titular.dssitsnh   tt-dados-titular.dtblutsh
                        tt-dados-titular.dtlibera   tt-dados-titular.hrlibera
                        tt-dados-titular.dtaltsit   tt-dados-titular.dtaltsnh   
                        tt-dados-titular.vllimweb   tt-dados-titular.dtultace
                        tt-dados-titular.dtlimweb   tt-dados-titular.dtlimted
                        tt-dados-titular.hrultace   tt-dados-titular.vllimted
                        tt-dados-titular.dtlimvrb   tt-dados-titular.vllimvrb
                        tel_opbloque            tel_opcancel
                        tel_opimpres            tel_opcadsen
                        tel_oplibera            tel_ophabint
                        WITH FRAME f_internet_fisica.
              
                IF  tt-dados-titular.dssitsnh = "INATIVA"  THEN
                        CHOOSE FIELD tel_oplibera
                                    WITH FRAME f_internet_fisica.
                ELSE
                        CHOOSE FIELD tel_opbloque  tel_opcancel  tel_opimpres 
                                     tel_opcadsen  tel_oplibera  tel_ophabint
                                     WITH FRAME f_internet_fisica.
            END.
        ELSE 
            DO:
                DISPLAY tt-dados-titular.dssitsnh   tt-dados-titular.dtblutsh
                        tt-dados-titular.dtlibera   tt-dados-titular.hrlibera
                        tt-dados-titular.dtaltsit   tt-dados-titular.dtaltsnh   
                        tt-dados-titular.vllimtrf   tt-dados-titular.vllimpgo
                        tt-dados-titular.dtultace   tt-dados-titular.hrultace      
                        tt-dados-titular.nmprepos   tt-dados-titular.vllimted
                        tt-dados-titular.dtlimtrf   tt-dados-titular.dtlimpgo
                        tt-dados-titular.dtlimted
                        tt-dados-titular.dtlimvrb   tt-dados-titular.vllimvrb 
                        tel_opbloque            tel_opcancel
                        tel_opimpres            tel_opcadsen
                        tel_oplibera            tel_ophabint
                        WITH FRAME f_internet_juridica.
                      
                IF  tt-dados-titular.dssitsnh = "INATIVA"  THEN
                        CHOOSE FIELD tel_oplibera
                                    WITH FRAME f_internet_juridica.
                ELSE
                        CHOOSE FIELD tel_opbloque  tel_opcancel  tel_opimpres 
                                     tel_opcadsen  tel_oplibera  tel_ophabint
                                     WITH FRAME f_internet_juridica.                   
            END.
     
        HIDE MESSAGE NO-PAUSE.
     
        IF  FRAME-VALUE = tel_opbloque  THEN /** BLOQUEIO **/
            DO:
                /* Verifica acesso a opcao B da INTERNET */
                ASSIGN glb_cddopcao = "B"
                       glb_nmrotina = "INTERNET".
                
                RUN p_acesso.

                IF   glb_cdcritic < 0 THEN
                     NEXT.
                /* Fim verificacao de acesso */


                ASSIGN aux_confirma = "N".
                RUN fontes/confirma.p (INPUT  "",
                                       OUTPUT aux_confirma).
                    
                IF  aux_confirma = "S" THEN 
                    DO:
                        RUN sistema/generico/procedures/b1wgen0015.p 
                        PERSISTENT SET h-b1wgen0015.
               
                        RUN bloquear-senha-internet IN h-b1wgen0015 (INPUT glb_cdcooper,
                                                                     INPUT glb_cdagenci,
                                                                     INPUT 0, /* Caixa */
                                                                     INPUT glb_cdoperad,
                                                                     INPUT glb_nmdatela,
                                                                     INPUT 1, /* Ayllos */
                                                                     INPUT tel_nrdconta,
                                                                     INPUT aux_idseqttl,
                                                                     INPUT glb_dtmvtolt,
                                                                     INPUT TRUE,
                                                                     OUTPUT TABLE tt-erro).
                      
                        DELETE PROCEDURE h-b1wgen0015.
                       
                        /* Verifica se a Procedure retornou erro */
                        IF  RETURN-VALUE = "NOK"  THEN
                            DO:
                                FIND FIRST tt-erro NO-LOCK NO-ERROR.
                       
                                IF  AVAILABLE tt-erro  THEN
                                    MESSAGE tt-erro.dscritic.
                                    NEXT.
                            END.
                    END.
            END. /* FIM BLOQUEIO */
     
        IF  FRAME-VALUE = tel_oplibera THEN /** LIBERAÇAO  **/
            DO:   
        
                /* Verifica acesso a opcao L da INTERNET */
                ASSIGN glb_cddopcao = "L"
                       glb_nmrotina = "INTERNET".
                
                RUN p_acesso.

                IF   glb_cdcritic < 0 THEN
                     NEXT.
                /* Fim verificacao de acesso */
        
                /* Verifica se a conta já está ativa */
                IF  tt-dados-titular.dssitsnh = "ATIVA"  THEN
                    DO: 
                        ASSIGN glb_cdcritic = 14.
     
                        IF  glb_cdcritic > 0   THEN
                            DO:
                                RUN fontes/critic.p.
                                MESSAGE glb_dscritic.
                                glb_cdcritic = 0.
                            END.
                        NEXT.
                    END.                                      
    
                senhas:
                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                    ASSIGN tel_cddsenha = "" 
                           aux_cdsenha2 = ""
                           tel_dssennov = ""
                           tel_dssencon = "".
                   
                    UPDATE  tel_cddsenha 
                            aux_cdsenha2 
                            WITH FRAME f_libera.

                    INTE(tel_cddsenha) NO-ERROR.
                    IF  ERROR-STATUS:ERROR THEN
                        DO:
                            MESSAGE "A senha nao pode conter Letras.".
                            NEXT.
                        END.

                    INTE(aux_cdsenha2) NO-ERROR.
                    IF  ERROR-STATUS:ERROR THEN
                        DO:
                            MESSAGE "A senha nao pode conter Letras.".
                            NEXT.
                        END.

                    ASSIGN aux_confirma = "N".
                    RUN fontes/confirma.p (INPUT  "",
                                           OUTPUT aux_confirma).
                    
                    IF  aux_confirma = "S" THEN 
                        DO: 
                            RUN sistema/generico/procedures/b1wgen0015.p 
                            PERSISTENT SET h-b1wgen0015.
                    
                            RUN liberar-senha-internet IN h-b1wgen0015  (INPUT glb_cdcooper,
                                                                         INPUT glb_cdagenci,
                                                                         INPUT 0, /* Caixa */
                                                                         INPUT glb_cdoperad,
                                                                         INPUT glb_nmdatela,
                                                                         INPUT 1, /* Ayllos */
                                                                         INPUT tel_nrdconta,
                                                                         INPUT aux_idseqttl,
                                                                         INPUT glb_dtmvtolt,
                                                                         INPUT STRING(tel_cddsenha),
                                                                         INPUT STRING(aux_cdsenha2),
                                                                         INPUT TRUE,
                                                                         OUTPUT aux_qtdiaace,
                                                                         OUTPUT aux_flgletca,
                                                                         OUTPUT aux_flgimpte,
                                                                         OUTPUT TABLE tt-erro).
                          
                            DELETE PROCEDURE h-b1wgen0015.
                           
                            /* Verifica se a Procedure retornou erro */
                            IF  RETURN-VALUE = "NOK"  THEN
                                DO:
                                    FIND FIRST tt-erro NO-LOCK NO-ERROR.
                           
                                    IF  AVAILABLE tt-erro  THEN
                                        MESSAGE tt-erro.dscritic.
                                        NEXT.
                                END.

                            ASSIGN aux_dsavsace = " ATENCAO! O cooperado tem " +
                                                    STRING(aux_qtdiaace) + 
                                                    (IF  aux_qtdiaace > 1  THEN 
                                                      " dias " 
                                                     ELSE 
                                                      " dia ") +
                                                    "para acessar a internet".

                            DISPLAY aux_dsavsace WITH FRAME f_mensagem.

                            /* Se a Liberaçao nao retornar erros e flag de imressao TRUE, imprime o contrato */
                            IF aux_flgimpte THEN
                            DO:
                            PAUSE 5 NO-MESSAGE.
                            HIDE FRAME f_mensagem NO-PAUSE.
                            MESSAGE COLOR NORMAL "Imprimindo contrato....".

                            /* Coleta id do terminal */
                            INPUT THROUGH basename `tty` NO-ECHO.
                            SET aux_nmendter WITH FRAME f_terminal.
                            INPUT CLOSE.  
                            
                            aux_nmendter = substr(glb_hostname,length(glb_hostname) - 1) +
                                                  aux_nmendter.
                          
                            RUN sistema/generico/procedures/b1wgen0015.p 
                                   PERSISTENT SET h-b1wgen0015.
                          
                                RUN gera-termo-responsabilidade IN h-b1wgen0015 
                                                               (INPUT glb_cdcooper,
                                                                      INPUT glb_cdagenci,
                                                                      INPUT 0, /* Caixa */
                                                                      INPUT glb_cdoperad,
                                                                      INPUT glb_nmdatela,
                                                                      INPUT tel_nrdconta,
                                                                INPUT 1, /* Ayllos */
                                                                      INPUT aux_idseqttl,
                                                                      INPUT aux_nmendter,
                                                                      OUTPUT aux_nmarqimp,
                                                                      OUTPUT TABLE tt-erro).
                            DELETE PROCEDURE h-b1wgen0015.
                           
                            /* Verifica se a Procedure retornou erro */
                            IF  RETURN-VALUE = "NOK"  THEN
                                DO:
                                    FIND FIRST tt-erro NO-LOCK NO-ERROR.
                                   
                                    IF  AVAILABLE tt-erro  THEN
                                        MESSAGE tt-erro.dscritic.
                                        NEXT.
                                END.
                          
                            RUN chama_impressao.
                            END.
    
                            HIDE MESSAGE NO-PAUSE.                   
    
                            IF  NOT aux_flgletca THEN
                                DO:
                                    MESSAGE "Necessario cadastramento das Letras" +
                                                 " de Seguranca.".

                                    DO WHILE TRUE ON ENDKEY UNDO, LEAVE senhas.
                                    
                                        UPDATE  tel_dssennov
                                                tel_dssencon
                                                WITH FRAME f_senha_let.

                                        ASSIGN aux_confirma = "N".
                                        RUN fontes/confirma.p (INPUT  "",
                                                               OUTPUT aux_confirma).
                                        
                                        IF  aux_confirma = "S" THEN 
                                            DO: 
                                                RUN sistema/generico/procedures/b1wgen0032.p
                                                               PERSISTENT SET h_b1wgen0032. 
                                                
                                                RUN grava-senha-letras IN h_b1wgen0032
                                                                        (INPUT glb_cdcooper,
                                                                         INPUT 0,
                                                                         INPUT 0,
                                                                         INPUT glb_cdoperad,
                                                                         INPUT glb_nmdatela,
                                                                         INPUT 1,
                                                                         INPUT tel_nrdconta,
                                                                         INPUT aux_idseqttl,
                                                                         INPUT glb_dtmvtolt,
                                                                         INPUT tel_dssennov,
                                                                         INPUT tel_dssencon,
                                                                         INPUT TRUE,
                                                                        OUTPUT tel_flgcadas,
                                                                        OUTPUT TABLE tt-erro).
                                                
                                                DELETE PROCEDURE h_b1wgen0032.
                                                
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
                                                
                                                MESSAGE "Operacao efetuada com sucesso!".
                                            END.

                                        LEAVE.

                                    END.
                                END.
                        END.
                    LEAVE.
                END. /* DO WHILE TRUE */
            END. /* LIBERAÇAO */
     
        IF  FRAME-VALUE = tel_opcancel  THEN /** CANCELAMENTO **/
            DO:

                /* Verifica acesso a opcao X da INTERNET */
                ASSIGN glb_cddopcao = "X"
                       glb_nmrotina = "INTERNET".
                
                RUN p_acesso.

                IF   glb_cdcritic < 0 THEN
                     NEXT.
                /* Fim verificacao de acesso */


                ASSIGN aux_inconfir = 1.
     
                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                      
                    RUN sistema/generico/procedures/b1wgen0015.p 
                    PERSISTENT SET h-b1wgen0015.
                   
                    RUN cancelar-senha-internet IN h-b1wgen0015 (INPUT glb_cdcooper,
                                                                 INPUT glb_cdagenci,
                                                                 INPUT 0, /* Caixa */
                                                                 INPUT glb_cdoperad,
                                                                 INPUT glb_nmdatela,
                                                                 INPUT 1, /* Ayllos */
                                                                 INPUT tel_nrdconta,
                                                                 INPUT aux_idseqttl,
                                                                 INPUT glb_dtmvtolt,
                                                                 INPUT aux_inconfir,
                                                                 INPUT TRUE,
                                                                 OUTPUT TABLE tt-msg-confirma,
                                                                 OUTPUT TABLE tt-erro).
                   
                    DELETE PROCEDURE h-b1wgen0015.
                 
                    IF  RETURN-VALUE = "NOK" THEN
                        DO:
                            FIND FIRST tt-erro NO-LOCK NO-ERROR.
                            IF  AVAIL tt-erro THEN
                                DO:
                                    MESSAGE tt-erro.dscritic.
                                END.
                        END.
                    ELSE
                        IF  CAN-FIND(FIRST tt-msg-confirma WHERE
                                     tt-msg-confirma.inconfir < 3)   THEN 
                            DO:
                                FIND tt-msg-confirma.
             
                                ASSIGN aux_dsmensag = tt-msg-confirma.dsmensag.
             
                                IF  NUM-ENTRIES(tt-msg-confirma.dsmensag,".") = 2 THEN
                                    DO:
                                        MESSAGE ENTRY(1,tt-msg-confirma.dsmensag,".") + ".".
                                        ASSIGN aux_dsmensag = TRIM(ENTRY(2,tt-msg-confirma.dsmensag,".")).
                                    END.
         
                                ASSIGN aux_confirma = "N".
                                RUN fontes/confirma.p (INPUT  aux_dsmensag,
                                                       OUTPUT aux_confirma).
         
                                IF  aux_confirma = "S"    THEN
                                    DO:
                                        ASSIGN aux_inconfir = tt-msg-confirma.inconfir + 1.
                                        NEXT.
                                    END.
                            END. 
                    LEAVE.
    
                END. /* DO WHILE TRUE ON ENDKEY UNDO */
            
            END. /* CANCELAMENTO */
      
        IF  FRAME-VALUE = tel_opimpres  THEN /** IMPRESSAO **/
            DO:

                /* Verifica acesso a opcao M da INTERNET */
                ASSIGN glb_cddopcao = "M"
                       glb_nmrotina = "INTERNET".
                
                RUN p_acesso.

                IF   glb_cdcritic < 0 THEN
                     NEXT.
                /* Fim verificacao de acesso */


                MESSAGE COLOR NORMAL "Imprimindo contrato....".

                /* Coleta id do terminal */
                INPUT THROUGH basename `tty` NO-ECHO.
                SET aux_nmendter WITH FRAME f_terminal.
                INPUT CLOSE. 
                
                aux_nmendter = substr(glb_hostname,length(glb_hostname) - 1) +
                                      aux_nmendter.
             
                RUN sistema/generico/procedures/b1wgen0015.p 
                       PERSISTENT SET h-b1wgen0015.
             
                RUN gera-termo-responsabilidade IN h-b1wgen0015 (INPUT glb_cdcooper,
                                                          INPUT glb_cdagenci,
                                                          INPUT 0, /* Caixa */
                                                          INPUT glb_cdoperad,
                                                          INPUT glb_nmdatela,
                                                          INPUT tel_nrdconta,
                                                                 INPUT 1, /* Ayllos */
                                                          INPUT aux_idseqttl,
                                                          INPUT aux_nmendter,
                                                          OUTPUT aux_nmarqimp,
                                                          OUTPUT TABLE tt-erro).
              
                DELETE PROCEDURE h-b1wgen0015.
               
                /* Verifica se a Procedure retornou erro */
                IF  RETURN-VALUE = "NOK"  THEN
                    DO:
                        FIND FIRST tt-erro NO-LOCK NO-ERROR.
                       
                        IF  AVAILABLE tt-erro  THEN
                            MESSAGE tt-erro.dscritic.
                            NEXT.
                    END.
              
                RUN chama_impressao.
              
                HIDE MESSAGE NO-PAUSE.                   
    
            END. /* IMPRESSAO */
         
        IF  FRAME-VALUE = tel_opcadsen  THEN /** ALTERA SENHA **/
            DO: 

                /* Verifica acesso a opcao S da INTERNET */
                ASSIGN glb_cddopcao = "S"
                       glb_nmrotina = "INTERNET".
                
                RUN p_acesso.

                IF   glb_cdcritic < 0 THEN
                     NEXT.
                /* Fim verificacao de acesso */

                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                    HIDE FRAME f_alt_senha NO-PAUSE.
                    HIDE FRAME f_senha_let NO-PAUSE.

                    DISPLAY tel_sennumer tel_solletra 
                            WITH FRAME f_opcao_senha.
                    
                    CHOOSE FIELD tel_sennumer tel_solletra 
                            WITH FRAME f_opcao_senha.
                    
                    IF  FRAME-VALUE = tel_sennumer  THEN
                        DO:
                            IF  tt-dados-titular.dssitsnh <> "ATIVA"  THEN
                                DO: 
                                    ASSIGN glb_dscritic = " Senha deve estar ATIVA.".
                                
                                    IF  glb_cdcritic > 0   OR
                                        glb_dscritic <> "" THEN
                                        DO:
                                            MESSAGE glb_dscritic.
                                            glb_cdcritic = 0.
                                        END.
                                    NEXT.
                                END.
                            
                            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                            
                                ASSIGN tel_cddsenha = ""
                                       aux_cdsenha1 = ""
                                       aux_cdsenha2 = "".
                                
                                UPDATE tel_cddsenha
                                       aux_cdsenha1
                                       aux_cdsenha2
                                       WITH FRAME f_alt_senha.

                                INTE(tel_cddsenha) NO-ERROR.
                                IF  ERROR-STATUS:ERROR THEN
                                    DO:
                                        MESSAGE "A nova senha nao pode conter Letras.".
                                        NEXT.
                                    END.

                                INTE(aux_cdsenha1) NO-ERROR.
                                IF  ERROR-STATUS:ERROR THEN
                                    DO:
                                        MESSAGE "A nova senha nao pode conter Letras.".
                                        NEXT.
                                    END.

                                INTE(aux_cdsenha2) NO-ERROR.
                                IF  ERROR-STATUS:ERROR THEN
                                    DO:
                                        MESSAGE "A senha nao pode conter Letras.".
                                        NEXT.
                                    END.
                               
                                ASSIGN aux_confirma = "N".
                                RUN fontes/confirma.p (INPUT  "",
                                                       OUTPUT aux_confirma).
                               
                                IF  aux_confirma = "S" THEN 
                                    DO:
                                        RUN sistema/generico/procedures/b1wgen0015.p 
                                        PERSISTENT SET h-b1wgen0015.
                                      
                                        RUN alterar-senha-internet IN h-b1wgen0015  (INPUT glb_cdcooper,
                                                                                     INPUT glb_cdagenci,
                                                                                     INPUT 0, /* Caixa */
                                                                                     INPUT glb_cdoperad,
                                                                                     INPUT glb_nmdatela,
                                                                                     INPUT 1, /* Ayllos */
                                                                                     INPUT tel_nrdconta,
                                                                                     INPUT aux_idseqttl,
                                                                                     INPUT glb_dtmvtolt,
                                                                                     INPUT STRING(tel_cddsenha),
                                                                                     INPUT STRING(aux_cdsenha1),
                                                                                     INPUT STRING(aux_cdsenha2),
                                                                                     INPUT TRUE,
                                                                                     OUTPUT TABLE tt-erro).
                                      
                                        DELETE PROCEDURE h-b1wgen0015.
                                      
                                       /* Verifica se a Procedure retornou erro */
                                        IF  RETURN-VALUE = "NOK"  THEN
                                            DO:
                                                FIND FIRST tt-erro NO-LOCK NO-ERROR.
                                      
                                                IF  AVAILABLE tt-erro  THEN
                                                    MESSAGE tt-erro.dscritic.
                                                    NEXT.
                                            END.
                                    END.
                                LEAVE.
                            
                            END. /*  DO WHILE TRUE ON ENDKEY UNDO  */
                        END.
                    ELSE
                    IF  FRAME-VALUE = tel_solletra  THEN
                        DO:
                            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                    
                                UPDATE tel_dssennov tel_dssencon
                                       WITH FRAME f_senha_let.
                               
                                ASSIGN aux_confirma = "N"
                                      glb_cdcritic = 78.
                               
                                RUN fontes/critic.p.
                                    glb_cdcritic = 0.
                               
                                BELL.
                                MESSAGE COLOR NORMAL glb_dscritic 
                                        UPDATE aux_confirma.
                               
                                IF  aux_confirma <> "S"  THEN 
                                    LEAVE.

                                RUN sistema/generico/procedures/b1wgen0032.p
                                    PERSISTENT SET h_b1wgen0032. 
                               
                                RUN grava-senha-letras 
                                    IN h_b1wgen0032
                                    (INPUT glb_cdcooper,
                                     INPUT 0,
                                     INPUT 0,
                                     INPUT glb_cdoperad,
                                     INPUT glb_nmdatela,
                                     INPUT 1,
                                     INPUT tel_nrdconta,
                                     INPUT aux_idseqttl,
                                     INPUT glb_dtmvtolt,
                                     INPUT tel_dssennov,
                                     INPUT tel_dssencon,
                                     INPUT TRUE,
                                    OUTPUT tel_flgcadas,
                                    OUTPUT TABLE tt-erro).
                               
                                DELETE PROCEDURE h_b1wgen0032.
                               
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
                               
                                MESSAGE "Operacao efetuada com sucesso!".
                               
                                PAUSE 5 NO-MESSAGE.
                               
                                LEAVE.
                               
                            END.
                        END.

                END. /* DO WHILE TRUE */

            END.  /** ALTERA SENHA **/
     
        IF  FRAME-VALUE = tel_ophabint  THEN /** ALTERA/HAB. VALORES DE LIMITES **/
            DO:

                /* Verifica acesso a opcao H da INTERNET */
                ASSIGN glb_cddopcao = "H"
                       glb_nmrotina = "INTERNET".
                
                RUN p_acesso.

                IF   glb_cdcritic < 0 THEN
                     NEXT.
                /* Fim verificacao de acesso */
           
                IF  tt-dados-titular.dssitsnh <> "ATIVA"  THEN
                    DO: 
                        ASSIGN glb_cdcritic = 14.
     
                        IF  glb_cdcritic > 0 THEN
                            DO:
                                RUN fontes/critic.p.
                                MESSAGE glb_dscritic.
                                glb_cdcritic = 0.
                            END.
                        NEXT.
                    END.
    
                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                    
                    HIDE FRAME f_transacoes_fisica. 
                    HIDE FRAME f_transacoes_juridica.
                    HIDE FRAME f_cadcon.
    
                    VIEW FRAME f_habilita.
                   
                    DISPLAY tel_opcadlim tel_opcadcon WITH FRAME f_habilita.
                    CHOOSE FIELD tel_opcadlim tel_opcadcon WITH FRAME f_habilita.
                    
                    HIDE MESSAGE NO-PAUSE.
                    IF  FRAME-VALUE = tel_opcadlim  THEN /*** ALTERAR LIM. ***/
                        DO:
                            ASSIGN tel_vllimtrf = 0 
                                   tel_vllimpgo = 0
                                   tel_vllimweb = 0
                                   tel_vllimted = 0
                                   tel_vllimvrb = 0. 

                            lim:
                            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                
                                RUN sistema/generico/procedures/b1wgen0015.p 
                                      PERSISTENT SET h-b1wgen0015.
                              
                                RUN obtem-dados-limites
                                     IN h-b1wgen0015 (INPUT glb_cdcooper,
                                                      INPUT glb_cdagenci,
                                                      INPUT 0, /* Caixa */
                                                      INPUT glb_cdoperad,
                                                      INPUT glb_nmdatela,
                                                      INPUT 1, /* Ayllos */
                                                      INPUT tel_nrdconta,
                                                      INPUT aux_idseqttl,
                                                      INPUT TRUE,
                                                      OUTPUT TABLE tt-dados-habilitacao,
                                                      OUTPUT TABLE tt-erro).
                              
                                DELETE PROCEDURE h-b1wgen0015.
                                
                                /* Verifica se a Procedure retornou erro */
                                IF  RETURN-VALUE = "NOK"  THEN
                                    DO:
                                        FIND FIRST tt-erro NO-LOCK NO-ERROR.
                                     
                                        IF  AVAILABLE tt-erro  THEN
                                            MESSAGE tt-erro.dscritic.
                                        LEAVE.
                                    END.
                   
                                FIND tt-dados-habilitacao.
                   
                                /* Alimenta vars dependendo do tipo de pessoa */
                                IF  aux_inpessoa = 1  THEN
                                    DO:
                                        ASSIGN  tel_vllimweb = tt-dados-habilitacao.vllimweb
                                                tel_vllimted = tt-dados-habilitacao.vllimted
                                                tel_vllimvrb = tt-dados-habilitacao.vllimvrb. 
                                        
                                        DISPLAY tel_vllimweb 
                                                tel_vllimted 
                                                tel_vllimvrb 
                                                WITH FRAME f_transacoes_fisica.
                                    END.
                                ELSE 
                                    DO:
                                        ASSIGN tel_vllimtrf = tt-dados-habilitacao.vllimtrf
                                               tel_vllimpgo = tt-dados-habilitacao.vllimpgo
                                               tel_vllimted = tt-dados-habilitacao.vllimted
                                               tel_vllimvrb = tt-dados-habilitacao.vllimvrb.
                              
                                        DISPLAY tel_vllimtrf 
                                                tel_vllimpgo 
                                                tel_vllimted
                                                tel_vllimvrb 
                                                WITH FRAME f_transacoes_juridica.
                                    END.

                                DO WHILE TRUE ON ENDKEY UNDO, LEAVE lim:
                                
                                    /* Edita as vars dependendo do tipo de pessoa */
                                    IF aux_inpessoa = 1 THEN  /* P. Fisica */
                                        UPDATE tel_vllimweb 
                                               tel_vllimted
                                               tel_vllimvrb 
                                               WITH FRAME f_transacoes_fisica.
                                    
                                    ELSE  /* P. Juridica */
                                        UPDATE tel_vllimtrf
                                               tel_vllimpgo
                                               tel_vllimted
                                               tel_vllimvrb 
                                               WITH FRAME f_transacoes_juridica.
                                    
                                    RUN sistema/generico/procedures/b1wgen0015.p 
                                    PERSISTENT SET h-b1wgen0015.
                                    
                                    RUN valida-dados-limites 
                                        IN h-b1wgen0015 (INPUT glb_cdcooper,
                                                         INPUT glb_cdagenci,
                                                         INPUT 0, /* Caixa */
                                                         INPUT glb_cdoperad,
                                                         INPUT glb_nmdatela,
                                                         INPUT 1, /* Ayllos */
                                                         INPUT tel_nrdconta,
                                                         INPUT aux_idseqttl,
                                                         INPUT tel_vllimweb,
                                                         INPUT tel_vllimtrf,
                                                         INPUT tel_vllimpgo,
                                                         INPUT tel_vllimted,
                                                         INPUT tel_vllimvrb,
                                                         INPUT TRUE,
                                                         OUTPUT TABLE tt-dados-preposto,
                                                         OUTPUT TABLE tt-erro).
                                    
                                    DELETE PROCEDURE h-b1wgen0015.
                                    
                                    /* Verifica se a Procedure retornou erro */
                                    IF  RETURN-VALUE = "NOK"  THEN
                                        DO:
                                            FIND FIRST tt-erro NO-LOCK NO-ERROR.
                                    
                                            IF  AVAILABLE tt-erro  THEN
                                                MESSAGE tt-erro.dscritic.
                                                NEXT.
                                        END.

                                   LEAVE.

                                END.
                                        
                                CLEAR FRAME f_procurad.
    
                                /* Se nao for pess. física, entao lista prepostos */
                                IF  TEMP-TABLE tt-dados-preposto:HAS-RECORDS AND
                                    aux_inpessoa <> 1                        THEN
                                    DO:
                                        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
    
                                            FOR EACH tt-dados-preposto WHERE tt-dados-preposto.flgatual = TRUE:
    
                                                ASSIGN tel_nmdavali = tt-dados-preposto.nmdavali.
                                                DISP   tel_nmdavali
                                                       tel_vllimtrf
                                                       tel_vllimpgo WITH FRAME f_procurad.
                                            END.
                                            
                                            OPEN QUERY q_procuradores FOR EACH tt-dados-preposto NO-LOCK.
                                           
                                            ON  RETURN OF b_procuradores
                                                DO:                    
                                                    ASSIGN aux_nrcpfcgc = tt-dados-preposto.nrcpfcgc
                                                           tel_nmdavanv = tt-dados-preposto.nmdavali.
                                           
                                                    DISP tel_nmdavanv WITH FRAME f_procurad.
                                                    APPLY "GO". 
                                                END.     
                                           
                                            UPDATE b_procuradores WITH FRAME f_procurad.
                                           
                                            ASSIGN aux_confirma = "N".
                                            RUN fontes/confirma.p (INPUT  "Confirma atualizacao de preposto?",
                                                                   OUTPUT aux_confirma). 

                                            IF  aux_confirma = "S" THEN 
                                                DO:
                                                    RUN sistema/generico/procedures/b1wgen0015.p 
                                                    PERSISTENT SET h-b1wgen0015.
                                                   
                                                    RUN atualizar-preposto IN h-b1wgen0015  (INPUT glb_cdcooper,
                                                                                             INPUT glb_cdagenci,
                                                                                             INPUT 0, /* Caixa */
                                                                                             INPUT glb_cdoperad,
                                                                                             INPUT glb_nmdatela,
                                                                                             INPUT 1, /* Ayllos */
                                                                                             INPUT tel_nrdconta,
                                                                                             INPUT aux_idseqttl,
                                                                                             INPUT aux_nrcpfcgc,
                                                                                             INPUT TRUE,
                                                                                             OUTPUT TABLE tt-erro).
                                                    DELETE PROCEDURE h-b1wgen0015.
                                                   
                                                    /* Verifica se a Procedure retornou erro */
                                                    IF  RETURN-VALUE = "NOK"  THEN
                                                        DO:
                                                            FIND FIRST tt-erro NO-LOCK NO-ERROR.
                                                            IF  AVAILABLE tt-erro  THEN
                                                                MESSAGE tt-erro.dscritic.
                                                                NEXT.
                                                        END.
    
                                                    /* Caso nao haja proposto atual, cria um registro */
                                                    FIND tt-dados-preposto WHERE tt-dados-preposto.flgatual = TRUE 
                                                                          NO-LOCK NO-ERROR NO-WAIT.
    
                                                    IF NOT AVAIL tt-dados-preposto THEN DO:
                                                        CREATE tt-dados-preposto.
                                                        ASSIGN tt-dados-preposto.flgatual = TRUE.
                                                    END.
    
    
                                                END.
                                            ELSE 
                                                ASSIGN aux_nrcpfcgc = 0. /* CPF do Prep. escolhido */
                                            
                                            /* Verifica se há preposto selecionado */
                                            FIND tt-dados-preposto WHERE tt-dados-preposto.flgatual = TRUE 
                                                                           NO-LOCK NO-ERROR NO-WAIT.
                                           
                                            IF  NOT AVAIL tt-dados-preposto AND
                                                aux_confirma = "N"          THEN
                                                DO:
                                                    HIDE FRAME f_procurad.
                                                    MESSAGE "Preposto nao selecionado.".
                                                    NEXT.
                                                END.

                                            LEAVE.
    
                                        END. /* FIM DO DO WHILE */
                                    END. /* Fim Prepostos */
        
                                HIDE FRAME f_procurad.
    
                                ASSIGN aux_confirma = "N".
                                RUN fontes/confirma.p (INPUT  "Confirma alteracoes de habilitacao?",
                                                       OUTPUT aux_confirma).
    
                                IF  aux_confirma = "S" THEN 
                                    DO:
                                        /* Verifica se o Preposto foi selecionado */
                                        FIND tt-dados-preposto WHERE tt-dados-preposto.flgatual = TRUE 
                                                                 NO-LOCK NO-ERROR NO-WAIT.
    
                                        IF NOT AVAIL tt-dados-preposto THEN 
                                            DO:
                                                IF TEMP-TABLE tt-dados-preposto:HAS-RECORDS THEN
                                                    DO:
                                                        HIDE FRAME f_procurad.
                                                        MESSAGE "Preposto nao selecionado.".
                                                        NEXT.
                                                    END.
                                            END.
    
                                        /* Uma vez Validado, entao Atualiza os Limites */
                                        RUN sistema/generico/procedures/b1wgen0015.p 
                                        PERSISTENT SET h-b1wgen0015.
                                     
                                        RUN alterar-limites-internet 
                                            IN h-b1wgen0015 (INPUT glb_cdcooper,
                                                             INPUT glb_cdagenci,
                                                             INPUT 0, /* Caixa */
                                                             INPUT glb_cdoperad,
                                                             INPUT glb_nmdatela,
                                                             INPUT 1, /* Ayllos */
                                                             INPUT tel_nrdconta,
                                                             INPUT aux_idseqttl,
                                                             INPUT tel_vllimweb,
                                                             INPUT tel_vllimtrf,
                                                             INPUT tel_vllimpgo,
                                                             INPUT tel_vllimted,
                                                             INPUT tel_vllimvrb, 
                                                             INPUT TRUE,
                                                             OUTPUT TABLE tt-erro).
                                     
                                        DELETE PROCEDURE h-b1wgen0015.
                                     
                                        /* Verifica se a Procedure retornou erro */
                                        IF  RETURN-VALUE = "NOK"  THEN
                                            DO:
                                                FIND FIRST tt-erro NO-LOCK NO-ERROR.
                                       
                                                IF  AVAILABLE tt-erro  THEN
                                                    MESSAGE tt-erro.dscritic.
                                                    NEXT.
                                            END.
                                    END.
                                    
                                LEAVE. 
                                
                            END. /*** DO WHILE TRUE. ***/
                        END. /*** ALTERAR LIM. ***/

                        IF  FRAME-VALUE = tel_opcadcon THEN /*** CADASTRAMENTO DE CONTAS ***/
                            DO:

                                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
    
                                    HIDE FRAME f_habilita.
                                    HIDE FRAME f_op-cnts-cadastr.
                                    HIDE FRAME f_op-cnts-incluir.
                                    HIDE FRAME f_tt-cnts-cadastr.
                                    HIDE FRAME f_incluir-conta-otrif.
                                    HIDE FRAME f_tt-cnts-pend.

                                    RUN sistema/generico/procedures/b1wgen0015.p 
                                        PERSISTENT SET h-b1wgen0015.
                                                                                        
                                    RUN resumo-cnts-internet IN h-b1wgen0015  (INPUT glb_cdcooper,
                                                                               INPUT glb_cdagenci,
                                                                               INPUT 0, /* Caixa */
                                                                               INPUT glb_cdoperad,
                                                                               INPUT glb_nmdatela,
                                                                               INPUT 1, /* Ayllos */
                                                                               INPUT tel_nrdconta,
                                                                               INPUT aux_idseqttl,
                                                                               INPUT glb_dtmvtolt,
                                                                               INPUT FALSE,
                                                                               OUTPUT aux_cntrgcad,
                                                                               OUTPUT aux_cntrgpen,
                                                                               OUTPUT TABLE tt-erro).
    
                                    DELETE PROCEDURE h-b1wgen0015.
    
                                    IF  RETURN-VALUE = "NOK"  THEN
                                        DO:
                                            FIND FIRST tt-erro NO-LOCK NO-ERROR.
                                   
                                            IF  AVAILABLE tt-erro  THEN
                                                MESSAGE tt-erro.dscritic.
                                                NEXT.
                                        END.
    
                                    DISPLAY tel_oppencon tel_opconcad tel_opinccon aux_cntrgcad aux_cntrgpen WITH FRAME f_cadcon.
                                    CHOOSE FIELD tel_oppencon tel_opconcad tel_opinccon WITH FRAME f_cadcon.
                                    
                                    IF  FRAME-VALUE = tel_oppencon THEN /*** CONTS. PEND. DE CONFIRM. ***/
                                        DO: 
                                            lab:
                                            DO WHILE TRUE:
    
                                                HIDE FRAME f_det-cont-pend NO-PAUSE.
                                    
                                                RUN sistema/generico/procedures/b1wgen0015.p 
                                                        PERSISTENT SET h-b1wgen0015.

                                                RUN consulta-contas-pendentes IN h-b1wgen0015  (INPUT glb_cdcooper,
                                                                                                INPUT glb_cdagenci,
                                                                                                INPUT 0, /* Caixa */
                                                                                                INPUT glb_cdoperad,
                                                                                                INPUT glb_nmdatela,
                                                                                                INPUT 1, /* Ayllos */
                                                                                                INPUT tel_nrdconta,
                                                                                                INPUT aux_idseqttl,
                                                                                                INPUT glb_dtmvtolt,
                                                                                                INPUT TRUE,
                                                                                                INPUT 0,
                                                                                                INPUT 0,
                                                                                                OUTPUT aux_qtdregis,
                                                                                                OUTPUT TABLE tt-contas-pendentes,
                                                                                                OUTPUT TABLE tt-erro).
                                                DELETE PROCEDURE h-b1wgen0015.
    
                                                OPEN QUERY q_tt-cnts-pend FOR EACH tt-contas-pendentes NO-LOCK.
    
                                                /* Esconde o frame de detalhes ao pressionar F4 */
                                                ON  END-ERROR OF b_tt-cnts-pend DO:
                                                    HIDE FRAME f_det-cont-pend.
                                                END.
    
                                                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
    
                                                    HIDE FRAME f_det-cont-pend.
                                                    UPDATE b_tt-cnts-pend WITH FRAME f_tt-cnts-pend.

                                                END.
                                                        
                                                IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  OR
                                                    aux_confirma <> "S"                 THEN
                                                    DO:
                                                        FIND FIRST tt-contas-pendentes WHERE tt-contas-pendentes.flgselec NO-WAIT NO-ERROR.
    
                                                        IF  AVAIL tt-contas-pendentes THEN
                                                            DO:
                                                                /* Deleta as contas nao assinaladas da tt */
                                                                FOR EACH tt-contas-pendentes WHERE NOT tt-contas-pendentes.flgselec.
                                                                    DELETE tt-contas-pendentes.
                                                                END.
                                                              
                                                                ASSIGN aux_confirma = "N".
                                                                RUN fontes/confirma.p (INPUT  "",
                                                                                       OUTPUT aux_confirma). 
                                                              
                                                                IF  aux_confirma = "S" THEN 
                                                                    DO:
                                                                        RUN sistema/generico/procedures/b1wgen0015.p 
                                                                            PERSISTENT SET h-b1wgen0015.
                                                                 
                                                                        RUN confirma-contas-pendentes IN h-b1wgen0015  (INPUT glb_cdcooper,
                                                                                                                        INPUT glb_cdagenci,
                                                                                                                        INPUT 0, /* Caixa */
                                                                                                                        INPUT glb_cdoperad,
                                                                                                                        INPUT glb_nmdatela,
                                                                                                                        INPUT 1, /* Ayllos */
                                                                                                                        INPUT tel_nrdconta,
                                                                                                                        INPUT aux_idseqttl,
                                                                                                                        INPUT glb_dtmvtolt,
                                                                                                                        INPUT TRUE,
                                                                                                                        INPUT TABLE tt-contas-pendentes,
                                                                                                                       OUTPUT aux_msgaviso,
                                                                                                                       OUTPUT TABLE tt-erro).

                                                                        DELETE PROCEDURE h-b1wgen0015.
                                                              
                                                                        IF  RETURN-VALUE = "NOK"  THEN
                                                                            DO:
                                                                                FIND FIRST tt-erro NO-LOCK NO-ERROR.
                                                                          
                                                                                IF  AVAILABLE tt-erro  THEN
                                                                                    MESSAGE tt-erro.dscritic.
                                                                                    NEXT.
                                                                            END.

                                                                        IF  aux_msgaviso <> ""  THEN
                                                                            DO:
                                                                                DISPLAY aux_msgaviso WITH FRAME f_aviso.

                                                                                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                                                                                    PAUSE 5 NO-MESSAGE.
                                                                                    LEAVE.

                                                                                END.

                                                                                 HIDE FRAME f_aviso NO-PAUSE.
                                                                            END.
                                                                    END.
                                                            END.
                                                        ELSE
                                                            LEAVE lab.
                                                   
                                                    END.
                                                NEXT.
                                            END.
                                        END. /* FIM CONTAS PENDENTES */
                                         
                                    IF  FRAME-VALUE = tel_opconcad THEN /*** CONTS. CADASTRADAS ***/
                                        DO: 
                                            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                                           
                                                DISPLAY tel_opctcoop tel_opctnsif WITH FRAME f_op-cnts-cadastr.
                                                CHOOSE FIELD tel_opctcoop tel_opctnsif WITH FRAME f_op-cnts-cadastr.
    
                                                cadastr:
                                                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                                            
                                                    IF  KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
                                                        DO:
                                                            HIDE FRAME f_tt-cnts-cadastr.
                                                            LEAVE.
                                                        END.
    
                                                    IF FRAME-VALUE = tel_opctcoop THEN
                                                        ASSIGN aux_intipdif = 1. /* Coop */
                                                    ELSE
                                                        ASSIGN aux_intipdif = 2. /* Outras IF's */
    
                                                    /* Exibir e editar dados das Cnts. cadastradas */
                                                    ON  RETURN OF b_tt-cnts-cadastr
                                                        DO: 
                                                            IF  TEMP-TABLE tt-contas-cadastradas:HAS-RECORDS THEN
                                                                DO: 
                                                                    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
    
                                                                        HIDE FRAME f_tt-cnts-cadastr.
    
                                                                        IF  tt-contas-cadastradas.inpessoa = 1 THEN
                                                                            ASSIGN aux_dscpfcgc = "CPF do Titular:".
                                                                        ELSE
                                                                            ASSIGN aux_dscpfcgc = "CNPJ do Titular:". 
                                                                   
                                                                        ASSIGN aux_insitcta = tt-contas-cadastradas.insitcta
                                                                               aux_dssitcta = tt-contas-cadastradas.dssitcta.
                                                                        
                                                                        /* Define o tipo de form para exibir detalhes */
                                                                        IF  tt-contas-cadastradas.intipdif = 1 THEN /* Coop */
                                                                            DO:
                                                                                DISPLAY tt-contas-cadastradas.dsageban 
                                                                                        tt-contas-cadastradas.nmtitula
                                                                                        tt-contas-cadastradas.nrctatrf
                                                                                        tt-contas-cadastradas.dscpfcgc
                                                                                        tt-contas-cadastradas.dsoperad
                                                                                        tt-contas-cadastradas.dstransa
                                                                                        aux_insitcta
                                                                                        aux_dssitcta
                                                                                        aux_dscpfcgc
                                                                                        tel_opaltsit
                                                                                        aux_dssitcta
                                                                                        WITH FRAME f_det-cont-cad-coop.
    
                                                                                /* inpessoa nao é atualizado para Coop */
                                                                                ASSIGN tel_inpessoa = tt-contas-cadastradas.inpessoa.
                                                                                
                                                                                CHOOSE FIELD tel_opaltsit NO-ERROR WITH FRAME f_det-cont-cad-coop.
                                                                   
                                                                                /* Edita infs da conta de transf. */
                                                                                IF FRAME-VALUE = tel_opaltsit AND
                                                                                   KEYFUNCTION(LASTKEY) = "RETURN" THEN
                                                                                    UPDATE aux_insitcta
                                                                                           WITH FRAME f_det-cont-cad-coop.
                                                                            END.
                                                                        ELSE /* Outras IF's */
                                                                            DO:
                                                                                ASSIGN aux_ifsnmtit = tt-contas-cadastradas.nmtitula
                                                                                       aux_nrcpfcgc = tt-contas-cadastradas.nrcpfcgc
                                                                                       tel_inpessoa = tt-contas-cadastradas.inpessoa
                                                                                       aux_nmtipcta = tt-contas-cadastradas.dstipcta
                                                                                       aux_tpctatrf = tt-contas-cadastradas.intipcta.
    
                                                                                IF  tel_inpessoa = 1 THEN
                                                                                    ASSIGN tel_dspessoa = "Fisica".
                                                                                ELSE
                                                                                    ASSIGN tel_dspessoa = "Juridica".

                                                                                IF tt-contas-cadastradas.nrispbif = 0 THEN
                                                                                DO:
                                                                                   IF  tt-contas-cadastradas.cddbanco = 1 THEN
                                                                                       aux_nrispbif = STRING(tt-contas-cadastradas.nrispbif,"99999999").
                                                                                   ELSE
                                                                                       aux_nrispbif = "       ".
                                                                                END.
                                                                                ELSE 
                                                                                    aux_nrispbif =   STRING(tt-contas-cadastradas.nrispbif,"99999999").

                                                                                DISPLAY tt-contas-cadastradas.cddbanco
                                                                                        aux_nrispbif
                                                                                        tt-contas-cadastradas.cdageban
                                                                                        tt-contas-cadastradas.nrctatrf
                                                                                        tt-contas-cadastradas.dstransa
                                                                                        tt-contas-cadastradas.dsoperad
                                                                                        aux_ifsnmtit
                                                                                        aux_insitcta
                                                                                        aux_dssitcta
                                                                                        aux_nrcpfcgc
                                                                                        aux_dscpfcgc
                                                                                        tel_opaltsit
                                                                                        aux_nmtipcta
                                                                                        tel_inpessoa
                                                                                        tel_dspessoa
                                                                                        WITH FRAME f_det-cont-cad-otrif.

                                                                                CHOOSE FIELD tel_opaltsit NO-ERROR WITH FRAME f_det-cont-cad-otrif.

                                                                                /* Edita infs da conta de transf. */
                                                                                IF  FRAME-VALUE = tel_opaltsit      AND
                                                                                    KEYFUNCTION(LASTKEY) = "RETURN" THEN
                                                                                    DO:
                                                                                        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                                                                            
                                                                                            ASSIGN aux_nmtpcont = ""
                                                                                                   aux_intpcont = "".
                                                                                           
                                                                                            /* Carrega Tipos de Conta */
                                                                                            RUN pi-carrega-tpcontas (INPUT tt-contas-cadastradas.dstipcta,
                                                                                                                     INPUT tt-contas-cadastradas.intipcta,
                                                                                                                     OUTPUT aux_nmtpcont,
                                                                                                                     OUTPUT aux_intpcont).
                                                                                           
                                                                                            ASSIGN aux_postpcon = 1. /* Contador */
                                                                                           
                                                                                            UPDATE aux_ifsnmtit
                                                                                                   aux_nrcpfcgc
                                                                                                   tel_inpessoa
                                                                                                   aux_nmtipcta
                                                                                                   aux_insitcta WITH FRAME f_det-cont-cad-otrif
                                                                                                EDITING:
                                                                                           
                                                                                                        READKEY.
                                                                                           
                                                                                                        /* Controle de Tipos de Conta */
                                                                                                        IF (KEYFUNCTION(LASTKEY) = "CURSOR-UP" OR
                                                                                                            KEYFUNCTION(LASTKEY) = "CURSOR-RIGHT") AND
                                                                                                            FRAME-FIELD = "aux_nmtipcta" THEN
                                                                                                            DO:
                                                                                                                IF  aux_postpcon > 
                                                                                                                          NUM-ENTRIES(aux_nmtpcont)  THEN
                                                                                                                    aux_postpcon = NUM-ENTRIES(aux_nmtpcont).
                                                                                                        
                                                                                                                aux_postpcon = aux_postpcon - 1.
                                                                                                        
                                                                                                                IF  aux_postpcon = 0  THEN
                                                                                                                    aux_postpcon = NUM-ENTRIES(aux_nmtpcont).
                                                                                                        
                                                                                                                ASSIGN aux_tpctatrf = INT(ENTRY(aux_postpcon,aux_intpcont))
                                                                                                                       aux_nmtipcta = ENTRY(aux_postpcon,aux_nmtpcont).
                                                                                                    
                                                                                                                DISPLAY aux_nmtipcta 
                                                                                                                        WITH FRAME f_det-cont-cad-otrif.
                                                                                                            END.
                                                                                                        ELSE
                                                                                                        IF (KEYFUNCTION(LASTKEY) = "CURSOR-DOWN" OR
                                                                                                            KEYFUNCTION(LASTKEY) = "CURSOR-LEFT") AND
                                                                                                            FRAME-FIELD = "aux_nmtipcta"         THEN
                                                                                                            DO:
                                                                                                                aux_postpcon = aux_postpcon + 1.
                                                                                                        
                                                                                                                IF  aux_postpcon > 
                                                                                                                           NUM-ENTRIES(aux_nmtpcont)  THEN
                                                                                                                    aux_postpcon = 1.
                                                                                                        
                                                                                                                ASSIGN aux_tpctatrf = INT(ENTRY(aux_postpcon,aux_intpcont))
                                                                                                                       aux_nmtipcta = ENTRY(aux_postpcon,aux_nmtpcont).
                                                                                                        
                                                                                                                DISPLAY aux_nmtipcta 
                                                                                                                        WITH FRAME f_det-cont-cad-otrif.
                                                                                                            END.

                                                                                                       IF  FRAME-FIELD = "aux_nmtipcta"   THEN
                                                                                                           DO:
                                                                                                               IF (KEYFUNCTION(LASTKEY) = "TAB"        OR
                                                                                                                   KEYFUNCTION(LASTKEY) = "RETURN"     OR
                                                                                                                   KEYFUNCTION(LASTKEY) = "END-ERROR"  OR
                                                                                                                   KEYFUNCTION(LASTKEY) = "BACK-TAB" ) THEN
                                                                                                                       APPLY LASTKEY.
                                                                                                           END.
                                                                                                       ELSE
                                                                                                           APPLY LASTKEY.
.

                                                                                                END. /*** Editing ***/
                                                                                           
                                                                                            /* Nao é inclusao de nova Conta */
                                                                                            ASSIGN flg_vldinclu = FALSE
                                                                                                   aux_nmtitula = aux_ifsnmtit.
                                                                                            
                                                                                            /* Valida dados alterados */
                                                                                            RUN sistema/generico/procedures/b1wgen0015.p 
                                                                                                    PERSISTENT SET h-b1wgen0015.
                                                                                            
                                                                                            RUN valida-inclusao-conta-transferencia IN h-b1wgen0015  
                                                                                                (INPUT glb_cdcooper,
                                                                                                 INPUT glb_cdagenci,
                                                                                                 INPUT 0, /* Caixa */
                                                                                                 INPUT glb_cdoperad,
                                                                                                 INPUT glb_nmdatela,
                                                                                                 INPUT 1, /* Ayllos */
                                                                                                 INPUT tel_nrdconta,
                                                                                                 INPUT aux_idseqttl,
                                                                                                 INPUT glb_dtmvtolt,
                                                                                                 INPUT TRUE,
                                                                                                 INPUT tt-contas-cadastradas.cddbanco,
                                                                                                 INPUT INT(tt-contas-cadastradas.nrispbif),
                                                                                                 INPUT tt-contas-cadastradas.cdageban,
                                                                                                 INPUT tt-contas-cadastradas.nrctatrf,
                                                                                                 INPUT aux_intipdif,
                                                                                                 INPUT aux_tpctatrf,
                                                                                                 INPUT aux_insitcta,
                                                                                                 INPUT tel_inpessoa,
                                                                                                 INPUT aux_nrcpfcgc,
                                                                                                 INPUT flg_vldinclu,
                                                                                                 INPUT "", /* Validacao de Registro */
                                                                                                 INPUT-OUTPUT aux_nmtitula,
                                                                                                OUTPUT aux_dscpfcgc,
                                                                                                OUTPUT aux_nmdcampo,
                                                                                                OUTPUT TABLE tt-erro).
                                                                                            
                                                                                            DELETE PROCEDURE h-b1wgen0015.
                                                                                            
                                                                                            IF  RETURN-VALUE = "NOK"  THEN
                                                                                                DO:
                                                                                                    FIND FIRST tt-erro NO-LOCK NO-ERROR.
                                                                                              
                                                                                                    IF  AVAILABLE tt-erro  THEN 
                                                                                                        DO:
                                                                                                            MESSAGE tt-erro.dscritic.
                                                                                                            NEXT.
                                                                                                        END.
                                                                                                END.
                                                                                            ELSE
                                                                                                LEAVE.

                                                                                        END. /*** DO WHILE TRUE ***/
                                                                                    END.
                                                                            END.

                                                                        IF  KEYFUNCTION(LASTKEY) = "RETURN" THEN
                                                                            DO: 
                                                                                ASSIGN aux_confirma = "N".
                                                                                RUN fontes/confirma.p (INPUT  "",
                                                                                                       OUTPUT aux_confirma).
 
                                                                                IF  aux_confirma = "S" THEN 
                                                                                    DO:   
                                                                                        /* Altera os Dados da Conta de Tranfs */
                                                                                        RUN sistema/generico/procedures/b1wgen0015.p 
                                                                                                PERSISTENT SET h-b1wgen0015.
                                                                                        
                                                                                        RUN fontes/substitui_caracter.p (INPUT-OUTPUT aux_nmtitula).
                                                                
                                                                                        RUN fontes/substitui_caracter.p (INPUT-OUTPUT aux_ifsnmtit).
                                                                                        
                                                                                        RUN altera-dados-cont-cadastrada IN h-b1wgen0015  (INPUT glb_cdcooper,
                                                                                                                                           INPUT glb_cdagenci,
                                                                                                                                           INPUT 0, /* Caixa */
                                                                                                                                           INPUT glb_cdoperad,
                                                                                                                                           INPUT glb_nmdatela,
                                                                                                                                           INPUT 1, /* Ayllos */
                                                                                                                                           INPUT tel_nrdconta,
                                                                                                                                           INPUT aux_idseqttl,
                                                                                                                                           INPUT glb_dtmvtolt,
                                                                                                                                           INPUT TRUE,
                                                                                                                                           INPUT aux_ifsnmtit,
                                                                                                                                           INPUT aux_nrcpfcgc,
                                                                                                                                           INPUT tel_inpessoa,
                                                                                                                                           INPUT aux_tpctatrf,
                                                                                                                                           INPUT aux_insitcta,
                                                                                                                                           INPUT aux_intipdif,
                                                                                                                                           INPUT tt-contas-cadastradas.cddbanco,
                                                                                                                                           INPUT tt-contas-cadastradas.cdageban,
                                                                                                                                           INPUT tt-contas-cadastradas.nrctatrf,
                                                                                                                                           OUTPUT TABLE tt-erro).
                                                                                        DELETE PROCEDURE h-b1wgen0015.
                                                                       
                                                                                        IF  RETURN-VALUE = "NOK"  THEN
                                                                                            DO:
                                                                                                FIND FIRST tt-erro NO-LOCK NO-ERROR.
                                                                                          
                                                                                                IF  AVAILABLE tt-erro  THEN
                                                                                                    MESSAGE tt-erro.dscritic.
                                                                                                    NEXT.
                                                                                            END.
                                                                                        ELSE
                                                                                            LEAVE.
                                                                                    END.
                                                                            END.

                                                                    END. /*** DO WHILE TRUE */
                                                                END.

                                                            APPLY "GO". 
                                                        END. /*** Fim RETURN ***/
    
                                                    DO WHILE TRUE ON ENDKEY UNDO, NEXT cadastr:
    
                                                        HIDE FRAME f_det-cont-cad-otrif.
                                                        HIDE FRAME f_det-cont-cad-coop.

                                                        
                                                        RUN sistema/generico/procedures/b1wgen0015.p 
                                                            PERSISTENT SET h-b1wgen0015.                                                                  
                                                                  
                                                        RUN consulta-contas-cadastradas IN h-b1wgen0015  (INPUT glb_cdcooper,
                                                                                                          INPUT glb_cdagenci,
                                                                                                          INPUT 0, /* Caixa */
                                                                                                          INPUT glb_cdoperad,
                                                                                                          INPUT glb_nmdatela,
                                                                                                          INPUT 1, /* Ayllos */
                                                                                                          INPUT tel_nrdconta,
                                                                                                          INPUT aux_idseqttl,
                                                                                                          INPUT glb_dtmvtolt,
                                                                                                          INPUT 0, /* Fisica e Jur. */
                                                                                                          INPUT aux_intipdif,
                                                                                                          INPUT "",
                                                                                                          OUTPUT TABLE tt-contas-cadastradas).
                                                                                                          
                                                        DELETE PROCEDURE h-b1wgen0015.
    
                                                        IF   aux_intipdif = 1 THEN
                                                             tt-contas-cadastradas.dsageban:LABEL 
                                                                  IN BROWSE b_tt-cnts-cadastr = "Cooperativa".
                                                        ELSE
                                                             tt-contas-cadastradas.dsageban:LABEL 
                                                                  IN BROWSE b_tt-cnts-cadastr = "Instit. Financeira".

                                                        OPEN QUERY q_tt-cnts-cadastr FOR EACH tt-contas-cadastradas NO-LOCK.
    
                                                        UPDATE b_tt-cnts-cadastr WITH FRAME f_tt-cnts-cadastr.

                                                    END.
    
                                                END. /*** DO WHILE TRUE cadastr ***/
                                            END. /*** DO WHILE TRUE ***/
    
                                        END. /* FIM CONTAS CADASTRADAS */
                                    
                                    IF  FRAME-VALUE = tel_opinccon THEN /*** INCLUIR CONTA ***/
                                        DO: 
                                            
                                            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                
                                             
                                                DISPLAY tel_opctcoop tel_opctnsif WITH FRAME f_op-cnts-incluir.
                                                CHOOSE FIELD tel_opctcoop tel_opctnsif WITH FRAME f_op-cnts-incluir.
                                                
                                               
                                                IF FRAME-VALUE = tel_opctcoop THEN
                                                    DO:
                                                        ASSIGN aux_intipdif = 1 /* Coop */
                                                               tel_nmrescop = ""
                                                               tel_nrctatrf = 0
                                                               aux_insitcta = 2
                                                               aux_cdageban = 0     
                                                               aux_cddbanco = 0
                                                               aux_cdispbif = 0
                                                               aux_nmtitula = " "
                                                               aux_dscpfcgc = " ".
                                                        
                                                        DISPLAY aux_dscpfcgc
                                                                aux_nmtitula WITH FRAME f_incluir-conta-coop.
                                                    END.
                                                ELSE
                                                    DO:  
                                                        ASSIGN aux_intipdif = 2 /* Outras IF's */
                                                               /* Zera valores */
                                                               aux_dscpfcgc = " "
                                                               aux_nmtitula = " "
                                                               tel_dspessoa = " "
                                                               aux_nrcpfcgc = 0
                                                               tel_nrctatrf = 0
                                                               aux_cddbanco = 0
                                                               aux_cdispbif = 0
                                                               aux_cdageban = 0
                                                               tel_inpessoa = 0
                                                               aux_insitcta = 2
                                                               aux_nmtpctin = " "
                                                               aux_ifsnmtit = " ".  /* Nome do Titular de Outra IF */
                                                    END.
    
                                                lab:
                                                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                                    
                                                    ASSIGN aux_flgregis = FALSE.
                                                    CLEAR FRAME f_incluir-conta-otrif.
                                                    HIDE FRAME f_libera.
                                                    
                                                    /* Coop */
                                                    IF  aux_intipdif = 1 THEN
                                                        DO:
                                                            tel_nmrescop:READ-ONLY = TRUE.

                                                            UPDATE  tel_nmrescop
                                                                    tel_nrctatrf WITH FRAME f_incluir-conta-coop.                                                               
                                                        END.
                                                    ELSE /* Outras IFs */
                                                        DO:
                                                            /* Carrega TODOS os tipos de contas */
                                                            RUN pi-carrega-tpcontas (INPUT "",
                                                                                     INPUT "",
                                                                                     OUTPUT aux_nmtpcont,
                                                                                     OUTPUT aux_intpcont).
                                                            incl:
                                                            DO WHILE TRUE:
                                                                DISPLAY tel_dspessoa WITH FRAME f_incluir-conta-otrif.
                                                                
                                                                /**********************************************************/
                                                                IF aux_cddbanco = 0 OR aux_cddbanco = ? OR flg_vldinclu = TRUE THEN
                                                                    DO:   
                                                                        atuBank:
                                                                        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                                                            
                                                                            UPDATE aux_cddbanco WITH FRAME f_incluir-conta-otrif
                                                                        		EDITING:
                                                                        
                                                                        			READKEY.
                                                                        
                                                                        			 /* Se precionado o F7 abre o zoom correspondente */
                                                                        			 IF  LASTKEY = KEYCODE("F7") THEN
                                                                        				 DO:
                                                                                            RUN zoom_bancos.
                                                                                            IF aux_cddbanco <> 1 AND aux_cdispbif > 0 THEN
                                                                                                ASSIGN aux_flgregis = TRUE.
                                                                                            HIDE FRAME f_zoom-bancos.
                                                                        				 END.
                                                                                     ELSE
                                                                                        APPLY LASTKEY.
                                                                        
                                                                        		END. /* Fim do EDITING */
                                                                           
                                                                           LEAVE atuBank.
                                                                        
                                                                        END. /*** DO WHILE TRUE ***/

                                                                        IF KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
                                                                           LEAVE lab.
                                                                  END. 
                                                                /**********************************************************/
                                                                   IF NOT aux_flgregis AND aux_cddbanco = 0 OR flg_vldinclu = TRUE THEN DO:   
                                                                      
                                                                       ASSIGN aux_flgregis = FALSE.
                                                                       
                                                                        atuISPB:
                                                                        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                                                            
                                                                            UPDATE aux_cdispbif WITH FRAME f_incluir-conta-otrif
                                                                                EDITING:

                                                                                    READKEY.

                                                                                     /* Se precionado o F7 abre o zoom correspondente */
                                                                                     IF  LASTKEY = KEYCODE("F7") THEN
                                                                                         DO:
                                                                                            RUN zoom_bancos.
                                                                                            HIDE FRAME f_zoom-bancos.
                                                                                         END.
                                                                                     ELSE
                                                                                        APPLY LASTKEY.

                                                                                END. /* Fim do EDITING */
                                                                               

                                                                            LEAVE atuISPB. 

                                                                        END. /*** DO WHILE TRUE ***/

                                                                        IF KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
                                                                            LEAVE lab.
                                                                 END.  
                                                               
                                                              atuDados:
                                                              DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                                             
                                                             /**************************************/
                                                                   UPDATE aux_cdageban
                                                                          tel_nrctatrf 
                                                                          aux_ifsnmtit
                                                                          aux_nrcpfcgc
                                                                          tel_inpessoa
                                                                          aux_nmtpctin
                                                                          WITH FRAME f_incluir-conta-otrif
                                                                       EDITING:
                                                                   
                                                                           READKEY.
                                                                   
                                                                           /* Controle de Tipos de Conta */
                                                                           IF (KEYFUNCTION(LASTKEY) = "CURSOR-UP" OR
                                                                               KEYFUNCTION(LASTKEY) = "CURSOR-RIGHT") AND
                                                                               FRAME-FIELD = "aux_nmtpctin" THEN
                                                                               DO:
                                                                                   IF  aux_postpcon > 
                                                                                             NUM-ENTRIES(aux_nmtpcont)  THEN
                                                                                       aux_postpcon = NUM-ENTRIES(aux_nmtpcont).
                                                                           
                                                                                   aux_postpcon = aux_postpcon - 1.
                                                                           
                                                                                   IF  aux_postpcon = 0  THEN
                                                                                       aux_postpcon = NUM-ENTRIES(aux_nmtpcont).
                                                                           
                                                                                   ASSIGN aux_tpctatrf = INT(ENTRY(aux_postpcon,aux_intpcont))
                                                                                          aux_nmtpctin = ENTRY(aux_postpcon,aux_nmtpcont).
                                                                       
                                                                                   DISPLAY aux_nmtpctin 
                                                                                           WITH FRAME f_incluir-conta-otrif.
                                                                               END.
                                                                           ELSE
                                                                           IF (KEYFUNCTION(LASTKEY) = "CURSOR-DOWN" OR
                                                                               KEYFUNCTION(LASTKEY) = "CURSOR-LEFT") AND
                                                                               FRAME-FIELD = "aux_nmtpctin"         THEN
                                                                               DO:
                                                                                   aux_postpcon = aux_postpcon + 1.
                                                                           
                                                                                   IF  aux_postpcon > 
                                                                                              NUM-ENTRIES(aux_nmtpcont)  THEN
                                                                                       aux_postpcon = 1.
                                                                           
                                                                                   ASSIGN aux_tpctatrf = INT(ENTRY(aux_postpcon,aux_intpcont))
                                                                                          aux_nmtpctin = ENTRY(aux_postpcon,aux_nmtpcont).
                                                                           
                                                                                   DISPLAY aux_nmtpctin 
                                                                                           WITH FRAME f_incluir-conta-otrif.
                                                                               END.
                                                                   
                                                                           IF  FRAME-FIELD = "aux_nmtpctin"   THEN
                                                                               DO:
                                                                           
                                                                                   IF (KEYFUNCTION(LASTKEY) = "TAB"     OR
                                                                                       KEYFUNCTION(LASTKEY) = "RETURN"  OR
                                                                                       KEYFUNCTION(LASTKEY) = "BACK-TAB") THEN
                                                                                           APPLY LASTKEY.
                                                                               END.
                                                                           ELSE
                                                                               APPLY LASTKEY.
                                                                           
                                                                           /* Se precionado o F7 abre o zoom correspondente */
                                                                            IF  LASTKEY = KEYCODE("F7") THEN
                                                                                DO:
                                                                                   IF  FRAME-FIELD = "aux_cdageban" THEN
                                                                                       DO:
                                                                                          RUN zoom_agencias(INPUT INPUT aux_cddbanco).
                                                                                          HIDE FRAME f_zoom-agencias.
                                                                                       END.
                                                                                END.
                                                                   
                                                                          
                                                                 
                                                                       END. /* Fim do EDITING */

                                                                   LEAVE atuDados.            

                                                                END.
                                                                              
                                                                IF KEYFUNCTION (LASTKEY) = "END-ERROR" THEN
                                                                    LEAVE lab.
                                                                
                                                                  
                                                                
                                                                ASSIGN aux_nmtitula = aux_ifsnmtit.

                                                                LEAVE incl.

                                                            END. /*** DO WHILE TRUE ***/ 

                                                        END.
                                                  
                                                    /* É inclusao de Nova Conta */
                                                    ASSIGN flg_vldinclu = TRUE.
                            
                                                    DO WHILE TRUE ON ENDKEY UNDO, NEXT:
                                                        
                                                        /* Faz validaçao */
                                                       
                                                        RUN sistema/generico/procedures/b1wgen0015.p 
                                                            PERSISTENT SET h-b1wgen0015.                                                            

                                                        RUN valida-inclusao-conta-transferencia IN h-b1wgen0015  
                                                           (INPUT glb_cdcooper,
                                                            INPUT glb_cdagenci,
                                                            INPUT 0, /* Caixa */
                                                            INPUT glb_cdoperad,
                                                            INPUT glb_nmdatela,
                                                            INPUT 1, /* Ayllos */
                                                            INPUT tel_nrdconta,
                                                            INPUT aux_idseqttl,
                                                            INPUT glb_dtmvtolt,
                                                            INPUT TRUE,
                                                            INPUT aux_cddbanco,
                                                            INPUT aux_cdispbif,
                                                            INPUT aux_cdageban,
                                                            INPUT tel_nrctatrf,
                                                            INPUT aux_intipdif,
                                                            INPUT aux_tpctatrf,
                                                            INPUT aux_insitcta,
                                                            INPUT tel_inpessoa,
                                                            INPUT aux_nrcpfcgc,
                                                            INPUT flg_vldinclu,
                                                            INPUT "", /* Validacao de Registro */
                                                            INPUT-OUTPUT aux_nmtitula,
                                                           OUTPUT aux_dscpfcgc,
                                                           OUTPUT aux_nmdcampo,
                                                           OUTPUT TABLE tt-erro).

                                                        DELETE PROCEDURE h-b1wgen0015.
                                                      
                                                        IF  RETURN-VALUE = "NOK"  THEN
                                                            DO:
                                                                FIND FIRST tt-erro NO-LOCK NO-ERROR.
                                                          
                                                                IF  AVAILABLE tt-erro  THEN 
                                                                    MESSAGE tt-erro.dscritic.
                                                                    NEXT lab. 
                                                            END.
                                                
                                                        /* Se Coop, exibe dados trazidos do assoc */
                                                        IF aux_intipdif = 1 THEN
                                                            DISPLAY aux_dscpfcgc
                                                                    aux_nmtitula WITH FRAME f_incluir-conta-coop.
                                                        
                                                        PAUSE(0).

                                                        IF   aux_intipdif = 2 THEN
                                                             DO WHILE TRUE ON ENDKEY UNDO, NEXT lab:

                                                                ASSIGN tel_cddsenha = ""
                                                                       aux_cdsenha2 = "".
                                                                
                                                                IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
                                                                    NEXT lab.
                                                                 
                                                               
                                                                /* Pede a senha */
                                                                UPDATE  tel_cddsenha
                                                                        aux_cdsenha2
                                                                        WITH FRAME f_libera.
                                                               
                                                                INTE(tel_cddsenha) NO-ERROR.
                                                                IF  ERROR-STATUS:ERROR THEN
                                                                    DO:
                                                                        MESSAGE "A senha nao pode conter Letras.".
                                                                        NEXT.
                                                                    END.
                                                               
                                                                INTE(aux_cdsenha2) NO-ERROR.
                                                                IF  ERROR-STATUS:ERROR THEN
                                                                    DO:
                                                                        MESSAGE "A senha nao pode conter Letras.".
                                                                        NEXT.
                                                                    END.
                                                                
                                                                RUN sistema/generico/procedures/b1wgen0015.p 
                                                                            PERSISTENT SET h-b1wgen0015.
                                                            
                                                                RUN verifica-senha-internet IN h-b1wgen0015  (INPUT glb_cdcooper,
                                                                                                              INPUT glb_cdagenci,
                                                                                                              INPUT 0, /* Caixa */
                                                                                                              INPUT glb_cdoperad,
                                                                                                              INPUT glb_nmdatela,
                                                                                                              INPUT 1, /* Ayllos */
                                                                                                              INPUT tel_nrdconta,
                                                                                                              INPUT aux_idseqttl,
                                                                                                              INPUT glb_dtmvtolt,
                                                                                                              INPUT TRUE,
                                                                                                              INPUT STRING(tel_cddsenha),
                                                                                                              INPUT STRING(aux_cdsenha2),
                                                                                                              OUTPUT TABLE tt-erro).
                                                                DELETE PROCEDURE h-b1wgen0015.
                                                                
                                                                IF  RETURN-VALUE = "NOK"  THEN
                                                                    DO:
                                                                        ASSIGN tel_cddsenha = ""
                                                                               aux_cdsenha2 = "".
                                                                        FIND FIRST tt-erro NO-LOCK NO-ERROR.
                                                                  
                                                                        IF  AVAILABLE tt-erro  THEN
                                                                            MESSAGE tt-erro.dscritic.
                                                                            NEXT.
                                                                    END.
                                                               
                                                                LEAVE.

                                                             END.
    
                                                        /* Esconde frame de entrada da Senha */
                                                        HIDE FRAME f_libera.
    
                                                        ASSIGN aux_confirma = "N".
                                                        RUN fontes/confirma.p (INPUT  "",
                                                                               OUTPUT aux_confirma).
    
                                                        IF  aux_confirma = "S" THEN 
                                                            DO:
                                                                RUN sistema/generico/procedures/b1wgen0015.p 
                                                                        PERSISTENT SET h-b1wgen0015.
                                                                
                                                                RUN fontes/substitui_caracter.p (INPUT-OUTPUT aux_nmtitula).
                                                                
                                                                RUN fontes/substitui_caracter.p (INPUT-OUTPUT aux_ifsnmtit).
                                                                
                                                                RUN inclui-conta-transferencia IN h-b1wgen0015  (INPUT glb_cdcooper,
                                                                                                                 INPUT glb_cdagenci,
                                                                                                                 INPUT 0, /* Caixa */
                                                                                                                 INPUT glb_cdoperad,
                                                                                                                 INPUT glb_nmdatela,
                                                                                                                 INPUT 1, /* Ayllos */
                                                                                                                 INPUT tel_nrdconta,
                                                                                                                 INPUT aux_idseqttl,
                                                                                                                 INPUT glb_dtmvtolt,
                                                                                                                 INPUT 0,
                                                                                                                 INPUT TRUE,
                                                                                                                 INPUT aux_cddbanco,
                                                                                                                 INPUT aux_cdageban,
                                                                                                                 INPUT tel_nrctatrf,
                                                                                                                 INPUT IF aux_intipdif = 1 THEN aux_nmtitula ELSE aux_ifsnmtit,
                                                                                                                 INPUT aux_nrcpfcgc,
                                                                                                                 INPUT tel_inpessoa,
                                                                                                                 INPUT aux_tpctatrf,
                                                                                                                 INPUT aux_intipdif,
                                                                                                                 INPUT aux_insitcta,
                                                                                                                 INPUT "", /* Alteracao de Registro */
                                                                                                                 INPUT aux_cdispbif,
                                                                                                                OUTPUT aux_msgaviso,
                                                                                                                OUTPUT TABLE tt-autorizacao-favorecido,
                                                                                                                OUTPUT TABLE tt-erro).
                                                                DELETE PROCEDURE h-b1wgen0015.
                                                      
                                                                IF  RETURN-VALUE = "NOK"  THEN
                                                                    DO:
                                                                        FIND FIRST tt-erro NO-LOCK NO-ERROR.
                                                      
                                                                        IF  AVAILABLE tt-erro  THEN
                                                                            MESSAGE tt-erro.dscritic.
                                                                            NEXT.
                                                                    END.

                                                                IF  aux_msgaviso <> ""  THEN
                                                                    DO:
                                                                        DISPLAY aux_msgaviso WITH FRAME f_aviso.

                                                                        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                                                                            PAUSE 5 NO-MESSAGE.
                                                                            LEAVE.

                                                                        END.

                                                                        HIDE FRAME f_aviso NO-PAUSE.
                                                                    END.
                                                            END.
                                                        
                                                        LEAVE.
                                                    END.
    
                                                    LEAVE.
                                                END. /*** DO WHILE TRUE lab ***/    
                                              
                                            END.
                                            
                                        END. /*** FIM INCLUIR CONTA ***/
                                          
                                END. /*** DO WHILE TRUE ***/
                                
                            END. /*** CADASTRAMENTO DE CONTAS ***/
    
                END. /** DO WHILE TRUE ON ENDLEY UNDO **/
            END. /** ALTERA/HAB. VALORES DE LIMITES **/
    
        NEXT.
    END. /* Fim DO WHILE TRUE */
    
    HIDE MESSAGE NO-PAUSE.
    HIDE FRAME f_internet_juridica.
    HIDE FRAME f_internet_fisica.
    HIDE FRAME f_habilita.
    
END. /***** DO WHILE TRUE *****/
/*............................................................................*/

PROCEDURE chama_impressao:

    FIND FIRST crapass WHERE crapass.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.
            
    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
        { includes/impressao.i }
        LEAVE.
    END.
    
    RETURN "OK".
    
END PROCEDURE.

/*............................................................................*/

PROCEDURE pi-carrega-tpcontas:

    DEF  INPUT  PARAM par_tpcotini AS CHAR                           NO-UNDO.
    DEF  INPUT  PARAM par_intipcta AS CHAR                           NO-UNDO.
    DEF  OUTPUT PARAM par_nmtpcont AS CHAR                           NO-UNDO.
    DEF  OUTPUT PARAM par_intpcont AS CHAR                           NO-UNDO.

    DEFINE VARIABLE aux_contador AS INTEGER                          NO-UNDO.

    EMPTY TEMP-TABLE tt-tp-contas.
    EMPTY TEMP-TABLE tt-erro.

    RUN sistema/generico/procedures/b1wgen0015.p 
                PERSISTENT SET h-b1wgen0015.
    
    RUN consulta-tipos-contas IN h-b1wgen0015  (INPUT glb_cdcooper,
                                                INPUT glb_cdagenci,
                                                INPUT 0, /* Caixa */
                                                OUTPUT TABLE tt-tp-contas,
                                                OUTPUT TABLE tt-erro).
    DELETE PROCEDURE h-b1wgen0015.
    
    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  AVAILABLE tt-erro  THEN
                MESSAGE tt-erro.dscritic.
                NEXT.
        END.

    /* Carrega contas com base em uma já informada */
    IF  par_tpcotini <> "" THEN
        DO:
            FOR EACH tt-tp-contas WHERE tt-tp-contas.nmtipcta <> par_tpcotini :
           
                IF   aux_contador = 0 THEN
                ASSIGN par_nmtpcont =  par_nmtpcont + tt-tp-contas.nmtipcta 
                       par_intpcont =  par_intpcont + tt-tp-contas.intipcta
                       aux_contador = 1.
                ELSE
                ASSIGN par_nmtpcont =  par_nmtpcont + "," + tt-tp-contas.nmtipcta 
                       par_intpcont =  par_intpcont + "," + tt-tp-contas.intipcta.


            END.
            ASSIGN par_nmtpcont = par_tpcotini + "," + par_nmtpcont 
                   par_intpcont = par_intipcta + "," + par_intpcont.
        END.

   /* Carrega TODAS as contas */
   ELSE
       DO:
            FOR EACH tt-tp-contas:

                IF   aux_contador = 0 THEN
                     ASSIGN par_nmtpcont = par_nmtpcont + tt-tp-contas.nmtipcta
                            par_intpcont = par_intpcont + tt-tp-contas.intipcta
                            aux_contador = 1.
                ELSE                        
                      ASSIGN par_nmtpcont = par_nmtpcont + "," + tt-tp-contas.nmtipcta
                             par_intpcont = par_intpcont + "," + tt-tp-contas.intipcta.
                                            
            END.
        END.
        
    RETURN "OK".

END PROCEDURE.

/*............................................................................*/

PROCEDURE zoom_bancos:

    EMPTY TEMP-TABLE tt-crapban.
    
    RUN sistema/generico/procedures/b1wgen0059.p 
    PERSISTENT SET h-b1wgen0059.
    
    RUN busca-crapban IN h-b1wgen0059(INPUT 0,
                                      INPUT "",
                                      INPUT 99999,
                                      INPUT 0,
                                     OUTPUT aux_qtregist,
                                     OUTPUT TABLE tt-crapban).

    DELETE PROCEDURE h-b1wgen0059.
    
    OPEN QUERY q_zoom-bancos FOR EACH tt-crapban NO-LOCK BY tt-crapban.cdbccxlt.
                                       
    ON  RETURN OF b_zoom-bancos IN FRAME f_zoom-bancos
        DO:                    
            ASSIGN aux_cddbanco = tt-crapban.cdbccxlt.
            ASSIGN aux_cdispbif = tt-crapban.nrispbif.
            
            DISPLAY aux_cddbanco aux_cdispbif WITH FRAME f_incluir-conta-otrif.
            HIDE FRAME f_zoom-bancos.
            
            APPLY "GO".
        END.  

    UPDATE b_zoom-bancos WITH FRAME f_zoom-bancos.

    RETURN "OK".

END PROCEDURE.

/*............................................................................*/

PROCEDURE zoom_agencias:

    DEF  INPUT PARAM par_cdbccxlt AS INTE                           NO-UNDO.

    EMPTY TEMP-TABLE tt-crapagb.

    RUN sistema/generico/procedures/b1wgen0059.p 
    PERSISTENT SET h-b1wgen0059.
    
    RUN busca-crapagb IN h-b1wgen0059(INPUT par_cdbccxlt,
                                      INPUT 0,
                                      INPUT "",
                                      INPUT 99999,
                                      INPUT 0,
                                     OUTPUT aux_qtregist,
                                     OUTPUT TABLE tt-crapagb).

    DELETE PROCEDURE h-b1wgen0059.
    
    OPEN QUERY q_zoom-agencias FOR EACH tt-crapagb NO-LOCK
                                           BY tt-crapagb.cdageban.
                                       
    ON  RETURN OF b_zoom-agencias IN FRAME f_zoom-agencias
        DO:                    
            ASSIGN aux_cdageban = tt-crapagb.cdageban.
            DISPLAY aux_cdageban WITH FRAME f_incluir-conta-otrif.
            
            APPLY "GO". 
        END.     

    UPDATE b_zoom-agencias WITH FRAME f_zoom-agencias.

    RETURN "OK".

END PROCEDURE.

PROCEDURE zoom_cooperativas:

    DEF VAR par_qtregist AS INTE                                    NO-UNDO.

    RUN sistema/generico/procedures/b1wgen0059.p PERSISTENT SET h-b1wgen0059.

    RUN busca-crapcop IN h-b1wgen0059 (INPUT 0,
                                       INPUT "",
                                       INPUT 99999,
                                       INPUT 0,
                                       OUTPUT par_qtregist,
                                       OUTPUT TABLE tt-crapcop).

    DELETE PROCEDURE h-b1wgen0059.

    OPEN QUERY q_crapcop FOR EACH tt-crapcop NO-LOCK.

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
        UPDATE b_crapcop WITH FRAME f_cooperativas.
        LEAVE.
    END.

    HIDE FRAME f_cooperativas.

END PROCEDURE.

PROCEDURE p_acesso:

    DEF VAR pro_flgfirst AS LOGICAL INIT TRUE NO-UNDO.
    
    DO WHILE TRUE:
    
       IF   NOT pro_flgfirst   THEN
       DO:
           glb_cdcritic = -1.
           RETURN.
       END.
     
       pro_flgfirst = FALSE.
       
       { includes/acesso.i }
       
       glb_cdcritic = 0.

       LEAVE.
    
    END.  /*  Fim do DO WHILE TRUE  */

END PROCEDURE.


/*............................................................................*/
