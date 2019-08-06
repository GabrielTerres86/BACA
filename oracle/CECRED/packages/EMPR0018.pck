CREATE OR REPLACE PACKAGE CECRED.EMPR0018 AS

  /* -------------------------------------------------------------------------------------------------------------

    Programa: EMPR0018           Antigo: sistema/generico/procedures/b1wgen0097.p
    Autor   : Douglas Pagel / AMcom 
    Data    : 18/12/2018               ultima Atualizacao: --
     
    Dados referentes ao programa:
   
    Objetivo  : BO para a simulacao de Emprestimos
   
    Alteracoes: 01/03/2019 - Conversão das alterações do PRJ298. (Douglas Pagel / AMcom)

				11/03/2019 - Inclusão de LOG ao gravar a simulação. (Douglas Pagel / AMcom)

				23/07/2019 - Removido filtro de data passado via sessão, criado parametro de data
                             na busca_simulacoes. (P438 Douglas Pagel / AMcom)

..............................................................................*/

    ---------------------------- ESTRUTURAS DE REGISTRO ---------------------
    -- Tipo de Registro para Data das parcelas (b1wgen0084tt.i/tt-datas-parcelas)
    TYPE typ_reg_datas_parcelas IS RECORD 
      (nrparepr INTEGER
      ,dtparepr DATE);
    TYPE typ_tab_datas_parcelas IS TABLE OF typ_reg_datas_parcelas INDEX BY PLS_INTEGER;
    
    --Tipo de Registro para dados da simulação
    TYPE typ_reg_sim IS RECORD
      (cdcooper NUMBER(10) 
      ,nrdconta NUMBER(10) 
      ,nrsimula NUMBER(10) 
      ,vlemprst NUMBER(25,2)
      ,qtparepr NUMBER(5)
      ,vlparepr NUMBER(25,2)
      ,txmensal NUMBER(25,6)
      ,txdiaria NUMBER(25,7)
      ,cdlcremp NUMBER(5) 
      ,dtdpagto DATE
      ,vliofepr NUMBER(25,2)
      ,vlrtarif NUMBER(25,2)
      ,vllibera NUMBER(25,2)
      ,dtmvtolt DATE
      ,hrtransa NUMBER(10) 
      ,cdoperad VARCHAR2(10)
      ,dtlibera DATE
      ,vlajuepr NUMBER(25,2)
      ,percetop NUMBER(25,2)
      ,cdfinemp NUMBER(5) 
      ,idfiniof NUMBER(1) 
      ,vliofcpl NUMBER(25,2)
      ,vliofadc NUMBER(25,2)
      ,cdagenci crapass.cdagenci%TYPE
      ,nrdialib INTEGER
      ,dslcremp VARCHAR2(40)
      ,dsfinemp VARCHAR2(40)
      ,cdmodali VARCHAR2(40)
      ,dsmodali VARCHAR2(40)
      ,tpfinali INTEGER
      ,vlrtotal NUMBER(14, 2)
      ,tpemprst NUMBER(5)
      ,idcarenc NUMBER(5) 
      ,vlprecar NUMBER(25,2)
      ,dtcarenc DATE
      ,dtvalidade DATE
      ,idsegmento NUMBER(10) 
      ,cdorigem NUMBER(3) 
      ,idpessoa NUMBER(15) 
      ,nrseq_telefone NUMBER(5) 
      ,nrseq_email NUMBER(5));
    TYPE typ_tab_sim IS TABLE OF typ_reg_sim INDEX BY PLS_INTEGER;
    
    --Tipo de Registro para parcelas da simulação
    TYPE typ_reg_parc_epr IS RECORD
      (cdcooper INTEGER
      ,nrdconta crapass.nrdconta%TYPE
      ,nrctremp crappep.nrctremp%TYPE
      ,nrparepr INTEGER
      ,vlparepr NUMBER(12, 2)
      ,dtparepr DATE    
      ,indpagto INTEGER DEFAULT 0
      ,dtvencto DATE);  
    TYPE typ_tab_parc_epr IS TABLE OF typ_reg_parc_epr INDEX BY PLS_INTEGER;
    
    
    TYPE typ_reg_crapsim IS RECORD
      ( cdcooper	number(10)
       ,nrdconta	number(10)
       ,nrsimula	number(10)
       ,vlemprst	number(25,2)
       ,qtparepr	number(5)
       ,vlparepr	number(25,2)
       ,txmensal	number(25,6)
       ,txdiaria	number(25,7)
       ,cdlcremp	number(5)
       ,dtdpagto	date
       ,vliofepr	number(25,2)
       ,vlrtarif	number(25,2)
       ,vllibera	number(25,2)
       ,dtmvtolt	date
       ,hrtransa	number(10)
       ,cdoperad	varchar2(10)
       ,dtlibera	date
       ,vlajuepr	number(25,2)
       ,percetop	number(25,2)
       ,progress_recid	number
       ,cdfinemp	number(5)
       ,idfiniof	number(1)
       ,vliofcpl	number(25,2)
       ,vliofadc	number(25,2)
       ,tpemprst	number(5)
       ,idcarenc	number(5)
       ,vlprecar	number(25,2)
       ,dtcarenc	date 
       ,dtvalidade	DATE
       ,idsegmento	number(10)
       ,idpessoa crapsim.idpessoa%TYPE
       ,nrseq_email tbcadast_pessoa_email.nrseq_email%TYPE
       ,nrseq_telefone tbcadast_pessoa_telefone.nrseq_telefone%TYPE                                
       );
    
    TYPE typ_tab_crapsim IS TABLE OF typ_reg_crapsim INDEX BY PLS_INTEGER; 
    
    -- Tipo de Registro para Data das parcelas (b1wgen0084tt.i/tt-datas-parcelas)
    TYPE typ_parametros IS RECORD 
          (dtmvtolt_ini DATE,
           dtmvtolt_fim DATE);
    
    TYPE typ_reg_crawepr IS RECORD
         (nrdconta	number(10),
          nrctremp	number(10),
          vlemprst	number(25,2),
          qtpreemp	number(5),
          vlpreemp	number(25,2),
          cdlcremp	number(5),
          cdfinemp	number(5),
          qtdialib	number(5),
          dsobserv	long,
          nrctrliq##1	number(10),
          nrctrliq##2	number(10),
          nrctrliq##3	number(10),
          nrctrliq##4	number(10),
          nrctrliq##5	number(10),
          nrctrliq##6	number(10),
          nrctrliq##7	number(10),
          nrctrliq##8	number(10),
          nrctrliq##9	number(10),
          nrctrliq##10	number(10),
          dtmvtolt	date,
          flgimppr	number,
          txminima	number(25,2),
          txbaspre	number(25,2),
          txdiaria	number(25,7),
          flgimpnp	number,
          cdcomite	number(5),
          nmchefia	varchar2(40),
          nrctaav1	number(10),
          nrctaav2	number(10),
          dsendav1##1	varchar2(154),
          dsendav1##2	varchar2(154),
          dsendav2##1	varchar2(154),
          dsendav2##2	varchar2(154),
          nmdaval1	varchar2(60),
          nmdaval2	varchar2(60),
          dscpfav1	varchar2(63),
          dscpfav2	varchar2(62),
          dtvencto	date,
          cdoperad	varchar2(10),
          flgpagto	number,
          dtdpagto	date,
          qtpromis	number(5),
          dscfcav1	varchar2(62),
          dscfcav2	varchar2(61),
          nmcjgav1	varchar2(60),
          nmcjgav2	varchar2(60),
          dsnivris	varchar2(2),
          dsnivcal	varchar2(2),
          tpdescto	number(5),
          cdcooper	number(10),
          dtaprova	date,
          insitapr	number(5),
          cdopeapr	varchar2(10),
          hraprova	number(10),
          percetop	number(25,2),
          dsoperac	varchar2(29),
          dtaltniv	date,
          idquapro	number(5),
          dsobscmt	varchar2(678),
          dtaltpro	date,
          tpemprst	number(5),
          txmensal	number(25,6),
          dtlibera	date,
          flgokgrv	number,
          progress_recid	number,
          qttolatr	number(5),
          cdorigem	number(3),
          nrconbir	number(10),
          inconcje	number(1),
          nrseqrrq	number(10),
          nrseqpac	number(10),
          insitest	number(2),
          dtenvest	date,
          hrenvest	number(8),
          cdagenci	number(5),
          hrinclus	number(8),
          dtdscore	date,
          dsdscore	varchar2(100),
          cdopeste	varchar2(10),
          flgaprvc	integer,
          dtenefes	date,
          dtrefatu	date,
          dsprotoc	varchar2(275),
          dtenvmot	date,
          hrenvmot	number(8),
          idcarenc	number(5),
          dtcarenc	date,
          tpatuidx	number(1),
          cddindex	number(3),
          txjurvar	number(25,2),
          nrliquid	number(10),
          dsnivori	varchar2(2),
          idfiniof	number(1),
          idcobope	number(20),
          idcobefe	number(20),
          inliquid_operac_atraso	number(1),
          vlempori	number(25,2),
          vlpreori	number(25,2),
          dsratori	varchar2(2),
          cdopealt	varchar2(10),
          dtexpira	date,
          flgpreap	number(1),
          flgdocdg	number(1),
          dtanulac	date,
          dtulteml	DATE );
/*          vlprecar	number(25,2),
          vlperidx	number(25,2)*/ 
              
    TYPE typ_tab_crawepr IS TABLE OF typ_reg_crawepr INDEX BY PLS_INTEGER; 

    TYPE typ_query_parcelas IS RECORD
        ( vr_parcela  NUMBER,
          vr_metade   NUMBER,
          vr_total    NUMBER, 
          vr_lado     VARCHAR2(20),
          vr_posicao  NUMBER,
          vr_vlparepr NUMBER(12,2),
          vr_dtparepr DATE );
    
    TYPE typ_cr_query_parcelas is ref cursor RETURN typ_query_parcelas;
    
    
    ---------------------------- ESTRUTURAS DE ROTINAS ---------------------  
    --Subrotina para formatar valores
    FUNCTION fn_formata_valor (pr_dsprefix    IN VARCHAR2   --> Prefixo para concatenação
                               ,pr_vlrvalor    IN NUMBER    --> Valor a ser formatado
                               ,pr_dsformat    IN VARCHAR2  --> Formato válido para formatação
                               ,pr_dsdsufix    IN VARCHAR2) --> Sufixo para concatenação 
        RETURN VARCHAR2; 
    
    -- Calcula datas de vencimento das parcelas    
    PROCEDURE pc_calcula_data_parcela_sim(pr_cdcooper IN crapcop.cdcooper%TYPE      --> Codigo Cooperativa
                                         ,pr_dtvencto IN DATE                       --> Data de vencimento da primeira parcela
                                         ,pr_nrparcel IN INTEGER                    --> Número de parcelas
                                         ,pr_ttvencto OUT typ_tab_datas_parcelas);  --> Tabela de retorno com as datas de vencimento
                                         
    --Carregar os dados de uma determinada simulacao de emprestimo
    PROCEDURE pc_busca_dados_simulacao(pr_cdcooper IN crapcop.cdcooper%TYPE
                                      ,pr_cdagenci IN crapage.cdagenci%TYPE
                                      ,pr_nrdcaixa IN INTEGER
                                      ,pr_cdoperad IN VARCHAR2
                                      ,pr_nmdatela IN VARCHAR2
                                      ,pr_cdorigem IN INTEGER
                                      ,pr_nrdconta IN crapass.nrdconta%TYPE
                                      ,pr_idseqttl IN INTEGER
                                      ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE
                                      ,pr_flgerlog IN BOOLEAN
                                      ,pr_nrsimula INTEGER
                                      ,pr_tcrapsim OUT typ_tab_sim
                                      ,pr_tparcepr OUT typ_tab_parc_epr                                   
                                      ,pr_cdcritic OUT crapcri.cdcritic%TYPE      --> Código da crítica tratada
                                      ,pr_des_erro OUT VARCHAR2                   --> Descrição de critica tratada
                                      ,pr_des_reto OUT VARCHAR2                   --> Retorno OK / NOK
                                      ,pr_tab_erro OUT gene0001.typ_tab_erro);    --> Tabela com possíves erros
                                      
    -- Excluir simulação de empréstimo
    PROCEDURE pc_exclui_simulacao(pr_cdcooper IN crapcop.cdcooper%TYPE
                                 ,pr_cdagenci IN crapage.cdagenci%TYPE
                                 ,pr_nrdcaixa IN INTEGER
                                 ,pr_cdoperad IN VARCHAR2
                                 ,pr_nmdatela IN VARCHAR2
                                 ,pr_cdorigem IN INTEGER
                                 ,pr_nrdconta IN crapass.nrdconta%TYPE
                                 ,pr_idseqttl IN INTEGER
                                 ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE
                                 ,pr_flgerlog IN BOOLEAN
                                 ,pr_nrsimula INTEGER
                                 ,pr_cdcritic OUT crapcri.cdcritic%TYPE      --> Código da crítica tratada
                                 ,pr_des_erro OUT VARCHAR2                   --> Descrição de critica tratada
                                 ,pr_des_reto OUT VARCHAR                    --> Retorno OK / NOK
                                 ,pr_tab_erro OUT gene0001.typ_tab_erro);    --> Tabela com possíves erros
 
                                         
    --Carregar simulacões de emprestimo de uma conta
    PROCEDURE pc_busca_simulacoes(pr_cdcooper IN crapcop.cdcooper%TYPE
                                 ,pr_cdagenci IN crapage.cdagenci%TYPE
                                 ,pr_nrdcaixa IN INTEGER
                                 ,pr_cdoperad IN VARCHAR2
                                 ,pr_nmdatela IN VARCHAR2
                                 ,pr_cdorigem IN INTEGER
                                 ,pr_nrdconta IN crapass.nrdconta%TYPE
                                 ,pr_idseqttl IN INTEGER
                                 ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE
                                 ,pr_flgerlog IN BOOLEAN
								 ,pr_datainic IN DATE DEFAULT NULL           --> Data inicial da pesquisa
                                 ,pr_datafina IN DATE DEFAULT NULL           --> Data final da pesquisa
                                 ,pr_tcrapsim OUT typ_tab_sim
                                 ,pr_cdcritic OUT crapcri.cdcritic%TYPE      --> Código da crítica tratada
                                 ,pr_des_erro OUT VARCHAR2                   --> Descrição de critica tratada
                                 ,pr_des_reto OUT VARCHAR                    --> Retorno OK / NOK
                                 ,pr_tab_erro OUT gene0001.typ_tab_erro);    --> Tabela com possíves erros
                                 
    PROCEDURE pc_consulta_tarifa_emprst(pr_cdcooper IN INTEGER                    
                                       ,pr_cdlcremp IN INTEGER 
                                       ,pr_vlemprst IN NUMBER                      --> Valor do empréstimo
                                       ,pr_nrdconta IN INTEGER                     --> Número da conta do associado
                                       ,pr_nrctremp IN INTEGER                     --> Número do contrato de empréstimo
                                       ,pr_dscatbem IN VARCHAR2                    --> Bens informados para o empréstimo
                                       ,pr_vlrtarif OUT NUMBER                     --> Retorno com o valor da tarifa 
                                       ,pr_cdcritic OUT crapcri.cdcritic%TYPE      --> Código da crítica tratada
                                       ,pr_des_erro OUT VARCHAR2                   --> Descrição de critica tratada
                                       ,pr_des_reto OUT VARCHAR                    --> Retorno OK / NOK
                                       ,pr_tab_erro OUT gene0001.typ_tab_erro);    --> Tabela com possíves erros
    
    PROCEDURE pc_consu_tari_emprst_prog(pr_cdcooper IN INTEGER                    
                                       ,pr_cdlcremp IN INTEGER 
                                       ,pr_vlemprst IN NUMBER                      --> Valor do empréstimo
                                       ,pr_nrdconta IN INTEGER                     --> Número da conta do associado
                                       ,pr_nrctremp IN INTEGER                     --> Número do contrato de empréstimo
                                       ,pr_dscatbem IN VARCHAR2                    --> Bens informados para o empréstimo
                                       ,pr_vlrtarif OUT NUMBER                     --> Retorno com o valor da tarifa 
                                       ,pr_cdcritic OUT crapcri.cdcritic%TYPE      --> Código da crítica tratada
                                       ,pr_dscritic OUT VARCHAR2                   --> Descrição de critica tratada
                                       ,pr_des_reto OUT VARCHAR);                  --> Retorno da execução
    
    --b1wgen0084.valida_novo_calculo
    PROCEDURE pc_valida_novo_calculo(pr_cdcooper IN crapcop.cdcooper%TYPE
                                    ,pr_cdagenci IN crapage.cdagenci%TYPE
                                    ,pr_nrdcaixa IN INTEGER
                                    ,pr_qtparepr IN INTEGER
                                    ,pr_cdlcremp IN INTEGER
                                    ,pr_flgpagto IN BOOLEAN
                                    ,pr_cdcritic OUT crapcri.cdcritic%TYPE      --> Código da crítica tratada
                                    ,pr_des_erro OUT VARCHAR2                   --> Descrição de critica tratada
                                    ,pr_des_reto OUT VARCHAR                    --> Retorno OK / NOK
                                    ,pr_tab_erro OUT gene0001.typ_tab_erro);    --> Tabela com possíves erros
                                    
    
    PROCEDURE pc_valida_calculo_prog(pr_cdcooper IN crapcop.cdcooper%TYPE
                                    ,pr_cdagenci IN crapage.cdagenci%TYPE
                                    ,pr_nrdcaixa IN INTEGER
                                    ,pr_qtparepr IN INTEGER
                                    ,pr_cdlcremp IN INTEGER
                                    ,pr_flgpagto IN INTEGER
                                    ,pr_cdcritic OUT crapcri.cdcritic%TYPE      --> Código da crítica tratada
                                    ,pr_des_erro OUT VARCHAR2                   --> Descrição de critica tratada
                                    ,pr_des_reto OUT VARCHAR);                  --> Retorno da execução
                                    
    --Procedure para validar a gravacao de uma simulacao de emprestimo                                
    PROCEDURE pc_valida_gravacao_simulacao(pr_cdcooper IN crapcop.cdcooper%TYPE
                                    	    ,pr_cdagenci IN crapage.cdagenci%TYPE
                                          ,pr_nrdcaixa IN INTEGER
	                                        ,pr_cdoperad IN VARCHAR2
                                          ,pr_nrdconta IN INTEGER
                                          ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE
                                          ,pr_vlemprst IN NUMBER
                                          ,pr_qtparepr IN INTEGER
                                          ,pr_cdlcremp IN INTEGER
                                          ,pr_dtlibera IN DATE
                                          ,pr_dtdpagto IN DATE
                                          ,pr_cddopcao IN VARCHAR
                                          ,pr_nrsimula IN INTEGER
                                          ,pr_cdfinemp IN INTEGER
                                          ,pr_tpemprst IN INTEGER
                                          ,pr_idcarenc IN INTEGER
                                          ,pr_dtcarenc IN DATE
                                          ,pr_cdcritic OUT crapcri.cdcritic%TYPE      --> Código da crítica tratada
                                          ,pr_des_erro OUT VARCHAR2                   --> Descrição de critica tratada
                                          ,pr_des_reto OUT VARCHAR                    --> Retorno OK / NOK
                                          ,pr_tab_erro OUT gene0001.typ_tab_erro);    --> Tabela com possíves erros
                                          
   PROCEDURE pc_grava_simulacao( pr_cdcooper IN crapcop.cdcooper%TYPE
                                ,pr_cdagenci IN crapage.cdagenci%TYPE
                                ,pr_nrdcaixa IN INTEGER
	                              ,pr_cdoperad IN VARCHAR2 
                                ,pr_nmdatela IN VARCHAR2
                                ,pr_cdorigem IN INTEGER
                                ,pr_nrdconta IN crapass.nrdconta%TYPE
                                ,pr_idseqttl IN INTEGER
                                ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE
                                ,pr_flgerlog IN BOOLEAN    
                                ,pr_cddopcao IN VARCHAR
                                ,pr_nrsimula IN INTEGER 
                                ,pr_cdlcremp IN INTEGER  
                                ,pr_vlemprst IN NUMBER
                                ,pr_qtparepr IN INTEGER 
                                ,pr_dtlibera IN DATE
                                ,pr_dtdpagto IN DATE
                                ,pr_percetop IN NUMBER
                                ,pr_cdfinemp IN INTEGER
                                ,pr_idfiniof IN INTEGER
                                ,pr_nrgravad OUT INTEGER
                                ,pr_txcetano OUT NUMBER
                                ,pr_cdcritic OUT crapcri.cdcritic%TYPE      --> Código da crítica tratada
                                ,pr_des_erro OUT VARCHAR2                   --> Descrição de critica tratada
                                ,pr_des_reto OUT VARCHAR                    --> Retorno OK / NOK
                                ,pr_tab_erro OUT gene0001.typ_tab_erro      --> Tabela com possíves erros  
                                ,pr_retorno  OUT typ_reg_crapsim
                                ,pr_flggrava IN NUMBER DEFAULT 1 
                                ,pr_idpessoa IN INTEGER
                                ,pr_nrseq_email IN tbcadast_pessoa_email.nrseq_email%TYPE
                                ,pr_nrseq_telefone IN tbcadast_pessoa_telefone.nrseq_telefone%TYPE                                
                                ,pr_idsegmento tbepr_segmento.idsegmento%TYPE
                                ,pr_tpemprst IN INTEGER
                                ,pr_idcarenc IN INTEGER
                                ,pr_dtcarenc IN DATE );                                
                                
    PROCEDURE pc_calcula_emprestimo(pr_cdcooper IN crapcop.cdcooper%TYPE
                                   ,pr_cdagenci IN crapage.cdagenci%TYPE
                                   ,pr_nrdcaixa IN INTEGER
                                   ,pr_cdoperad IN VARCHAR2 
                                   ,pr_nmdatela IN VARCHAR2
                                   ,pr_cdorigem IN INTEGER
                                   ,pr_nrdconta IN crapass.nrdconta%TYPE
                                   ,pr_idseqttl IN INTEGER   
                                   ,pr_flgerlog IN BOOLEAN 
                                   ,pr_nrctremp IN INTEGER  
                                   ,pr_cdlcremp IN INTEGER 
                                   ,pr_cdfinemp IN INTEGER 
                                   ,pr_vlemprst IN NUMBER
                                   ,pr_qtparepr IN INTEGER 
                                   ,pr_dtmvtolt IN DATE
                                   ,pr_dtdpagto IN DATE
                                   ,pr_flggrava In BOOLEAN
                                   ,pr_dtlibera IN DATE
                                   ,pr_idfiniof IN INTEGER
                                   ,pr_qtdiacar OUT INTEGER
                                   ,pr_vlajuepr OUT NUMBER
                                   ,pr_txdiaria OUT NUMBER
                                   ,pr_txmensal OUT NUMBER
                                   ,pr_tparcepr OUT typ_tab_parc_epr
                                   ,pr_cdcritic OUT crapcri.cdcritic%TYPE      --> Código da crítica tratada
                                   ,pr_des_erro OUT VARCHAR2                   --> Descrição de critica tratada
                                   ,pr_des_reto OUT VARCHAR                    --> Retorno OK / NOK
                                   ,pr_tab_erro OUT gene0001.typ_tab_erro);    --> Tabela com possíves erros 
                                
   PROCEDURE pc_calcula_emprestimo_prog(pr_cdcooper IN crapcop.cdcooper%TYPE
                                       ,pr_cdagenci IN crapage.cdagenci%TYPE
                                       ,pr_nrdcaixa IN INTEGER
                                       ,pr_cdoperad IN VARCHAR2 
                                       ,pr_nmdatela IN VARCHAR2
                                       ,pr_cdorigem IN INTEGER
                                       ,pr_nrdconta IN crapass.nrdconta%TYPE
                                       ,pr_idseqttl IN INTEGER   
                                       ,pr_flgerlog IN INTEGER 
                                       ,pr_nrctremp IN INTEGER  
                                       ,pr_cdlcremp IN INTEGER 
                                       ,pr_cdfinemp IN INTEGER 
                                       ,pr_vlemprst IN NUMBER
                                       ,pr_qtparepr IN INTEGER 
                                       ,pr_dtmvtolt IN DATE
                                       ,pr_dtdpagto IN DATE
                                       ,pr_flggrava In INTEGER
                                       ,pr_dtlibera IN DATE
                                       ,pr_idfiniof IN INTEGER
                                       ,pr_qtdiacar OUT INTEGER
                                       ,pr_vlajuepr OUT NUMBER
                                       ,pr_txdiaria OUT NUMBER
                                       ,pr_txmensal OUT NUMBER
                                       ,pr_tparcepr OUT CLOB
                                       ,pr_cdcritic OUT crapcri.cdcritic%TYPE      --> Código da crítica tratada
                                       ,pr_dscritic OUT VARCHAR2                   --> Descrição de critica tratada
                                       ,pr_des_reto OUT VARCHAR);                  --> Retorno da execução                                    
                                
                                                                
    PROCEDURE pc_gera_parcelas_emprestimo(pr_cdcooper IN crapcop.cdcooper%TYPE
                                         ,pr_cdagenci IN crapage.cdagenci%TYPE
                                         ,pr_nrdcaixa IN INTEGER
                                         ,pr_cdoperad IN VARCHAR2 
                                         ,pr_nmdatela IN VARCHAR2
                                         ,pr_cdorigem IN INTEGER
                                         ,pr_nrdconta IN crapass.nrdconta%TYPE
                                         ,pr_idseqttl IN INTEGER 
                                         ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE
                                         ,pr_flgerlog IN BOOLEAN  
                                         ,pr_nrctremp IN INTEGER  
                                         ,pr_tparcepr IN typ_tab_parc_epr  
                                         ,pr_cdcritic OUT crapcri.cdcritic%TYPE      --> Código da crítica tratada
                                         ,pr_des_erro OUT VARCHAR2                   --> Descrição de critica tratada
                                         ,pr_des_reto OUT VARCHAR                    --> Retorno OK / NOK
                                         ,pr_tab_erro OUT gene0001.typ_tab_erro);    --> Tabela com possíves erros                      

    -- Impressao de Simulação de empréstimo
   PROCEDURE pc_imprime_simulacao(pr_cdcooper IN NUMBER, 
                                  pr_cdagenci IN NUMBER,
                                  pr_nrdcaixa IN NUMBER,
                                  pr_cdoperad IN VARCHAR2,
                                  pr_nmdatela IN VARCHAR2,
                                  pr_cdorigem IN NUMBER,
                                  pr_nrdconta IN NUMBER,
                                  pr_idseqttl IN NUMBER,
                                  pr_dtmvtolt IN DATE,
                                  pr_flgerlog BOOLEAN,
                                  pr_nrsimula IN NUMBER,
                                  pr_dsiduser IN VARCHAR2,
                                  pr_tpemprst IN INTEGER,
                                  pr_nmarqimp OUT VARCHAR2,
                                  pr_nmarqpdf OUT VARCHAR2,
                                  pr_tab_erro OUT gene0001.typ_tab_erro,
                                  pr_des_reto  OUT VARCHAR2,
                                  pr_retorno  OUT xmltype);
                                                                    
    PROCEDURE insere_tag(pr_xml      IN OUT NOCOPY XMLType  --> XML que receberá a nova TAG
                        ,pr_tag_pai  IN VARCHAR2            --> TAG que receberá a nova TAG
                        ,pr_posicao  IN PLS_INTEGER         --> Posição da tag na lista
                        ,pr_tag_nova IN VARCHAR2            --> String com a nova TAG
                        ,pr_tag_cont IN VARCHAR2            --> Conteúdo da nova TAG
                        ,pr_des_erro OUT VARCHAR2);
    
   
END EMPR0018;                                        
/
CREATE OR REPLACE PACKAGE BODY CECRED.EMPR0018 AS

  /* -------------------------------------------------------------------------------------------------------------

    Programa: EMPR0018           Antigo: sistema/generico/procedures/b1wgen0097.p
    Autor   : Douglas Pagel/AMcom 
    Data    : 18/12/2018               ultima Atualizacao: -- 01/07/2019
     
    Dados referentes ao programa:
   
    Objetivo  : BO para a simulacao de Emprestimos
   
    Alteracoes: 01/07/2019 - P438 - Incluíndo rotinas para serem chamadas pelo PROGRESS
                             pc_valida_calculo_prog, pc_consu_tari_emprst_prog e pc_calcula_emprestimo_prog.
                             (Douglas Pagel / AMcom)

..............................................................................*/

    vr_parametros    typ_parametros;
    vr_exc_erro EXCEPTION;

   --Subrotina para formatar valores
   FUNCTION fn_formata_valor (pr_dsprefix    IN VARCHAR2
                              ,pr_vlrvalor    IN NUMBER
                              ,pr_dsformat    IN VARCHAR2
                              ,pr_dsdsufix    IN VARCHAR2) 
        RETURN VARCHAR2 IS
        
  /* -------------------------------------------------------------------------------------------------------------

    Programa: fn_formata_valor    
    Autor   : Rafael Rocha / AMcom 
    Data    : 02/2019               ultima Atualizacao: -- 
     
    Dados referentes ao programa:
   
    Objetivo  : Rotina formatar valores para XML
   
    Alteracoes: 

  ..............................................................................*/          
         
    vr_vlformatado VARCHAR2(100);
        
    BEGIN
      vr_vlformatado := pr_dsprefix || TRIM(TO_CHAR(pr_vlrvalor, pr_dsformat,'NLS_NUMERIC_CHARACTERS='',.''') ) || pr_dsdsufix;
    
      return vr_vlformatado;
  
    END fn_formata_valor; 
    
    FUNCTION fn_retorna_telefone(pr_cdcooper crapass.cdcooper%TYPE
                                 ,pr_idpessoa tbcadast_pessoa_telefone.idpessoa%TYPE
                                 ,pr_nrseq_telefone tbcadast_pessoa_telefone.nrseq_telefone%TYPE)
      RETURN VARCHAR2 IS
      
  /* -------------------------------------------------------------------------------------------------------------

    Programa: fn_retorna_telefone     
    Autor   : Rafael Rocha / AMcom 
    Data    : 02/2019               ultima Atualizacao: -- 
     
    Dados referentes ao programa:
   
    Objetivo  : Rotina retornar o telefone de uma pessoa
   
    Alteracoes: 

  ..............................................................................*/            
      
      -- Buscar dados do telefone
      CURSOR cr_telefone( pr_idpessoa    tbcadast_pessoa.idpessoa%TYPE) IS                    
        SELECT pt.nrtelefone
          FROM tbcadast_pessoa_telefone PT
         WHERE PT.idpessoa = pr_idpessoa
           AND PT.nrseq_telefone  = pr_nrseq_telefone; 
      rw_telefone cr_telefone%ROWTYPE;
          
    BEGIN
     
     OPEN cr_telefone(pr_idpessoa => pr_idpessoa);
       FETCH cr_telefone INTO rw_telefone;
      CLOSE cr_telefone;
       
      RETURN to_char(rw_telefone.nrtelefone);
      
   END fn_retorna_telefone; 
             
   FUNCTION fn_retorna_email(pr_cdcooper crapass.cdcooper%TYPE
                            ,pr_idpessoa tbcadast_pessoa_telefone.idpessoa%TYPE
                            ,pr_nrseq_telefone tbcadast_pessoa_telefone.nrseq_telefone%TYPE)
      RETURN VARCHAR2 IS
      
  /* -------------------------------------------------------------------------------------------------------------

    Programa: fn_retorna_email     
    Autor   : Rafael Rocha / AMcom 
    Data    : 02/2019               ultima Atualizacao: -- 
     
    Dados referentes ao programa:
   
    Objetivo  : Rotina retornar o e-mail de uma pessoa
   
    Alteracoes: 

  ..............................................................................*/                  
      
      -- Buscar dados do telefone
      CURSOR cr_email( pr_idpessoa    tbcadast_pessoa.idpessoa%TYPE) IS                    
        SELECT tpe.dsemail
          FROM tbcadast_pessoa_email tpe
         WHERE tpe.idpessoa = pr_idpessoa
           AND tpe.nrseq_email = pr_nrseq_telefone; 
      rw_email cr_email%ROWTYPE;
          
    BEGIN
      
      OPEN cr_email(pr_idpessoa => pr_idpessoa);
       FETCH cr_email INTO rw_email;
      CLOSE cr_email;
       
      RETURN rw_email.dsemail;
      
    END fn_retorna_email;  
   

   -- Calcula datas de vencimento das parcelas  
   PROCEDURE pc_calcula_data_parcela_sim(pr_cdcooper IN crapcop.cdcooper%TYPE          --> Codigo Cooperativa
                                         ,pr_dtvencto IN DATE                           --> Data de vencimento da primeira parcela
                                         ,pr_nrparcel IN INTEGER                        --> Número de parcelas
                                         ,pr_ttvencto OUT typ_tab_datas_parcelas) IS    --> Tabela de retorno com as datas de vencimento                
  /* -------------------------------------------------------------------------------------------------------------

    Programa: pc_calcula_data_parcela_sim      Antigo: b1wgen0097.p(calcula_data_parcela_sim)
    Autor   : Douglas Pagel / AMcom 
    Data    : 18/12/2018               ultima Atualizacao: -- 
     
    Dados referentes ao programa:
   
    Objetivo  : Rotina para calculo das datas de parcelas da simulação
   
    Alteracoes: 

  ..............................................................................*/                                         
    vr_aux_dtcalcu DATE;
    vr_aux_nrparce INTEGER;
    vr_index PLS_INTEGER;
    
    BEGIN
      vr_aux_dtcalcu := pr_dtvencto;
      
      FOR vr_aux_nrparce IN 1..pr_nrparcel LOOP
        -- Busca o dia original de vencimento
        vr_aux_dtcalcu := pr_dtvencto;
        
        --Incrementa os meses na data auxiliar.
        -- A função ADD_MONTHS já posiciona para o ultimo dia do mês caso o dia não exista.
        -- e faz a troca de ano automaticamente.
        vr_aux_dtcalcu := ADD_MONTHS(vr_aux_dtcalcu, vr_aux_nrparce-1);
        
        --Incrementa indice da Tabela de retorno  
        vr_index:= pr_ttvencto.count + 1;
        
        --Adiciona a parcela na tabela de retorno
        pr_ttvencto(vr_index).nrparepr := vr_aux_nrparce;
        pr_ttvencto(vr_index).dtparepr := vr_aux_dtcalcu;

      END LOOP;
                                                                                 
    END pc_calcula_data_parcela_sim;
    
   PROCEDURE pc_busca_dados_simulacao(pr_cdcooper IN crapcop.cdcooper%TYPE
                                      ,pr_cdagenci IN crapage.cdagenci%TYPE
                                      ,pr_nrdcaixa IN INTEGER
                                      ,pr_cdoperad IN VARCHAR2
                                      ,pr_nmdatela IN VARCHAR2
                                      ,pr_cdorigem IN INTEGER
                                      ,pr_nrdconta IN crapass.nrdconta%TYPE
                                      ,pr_idseqttl IN INTEGER
                                      ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE
                                      ,pr_flgerlog IN BOOLEAN
                                      ,pr_nrsimula INTEGER
                                      ,pr_tcrapsim OUT typ_tab_sim
                                      ,pr_tparcepr OUT typ_tab_parc_epr                                      
                                      ,pr_cdcritic OUT crapcri.cdcritic%TYPE     --> Código da crítica tratada
                                      ,pr_des_erro OUT VARCHAR2                  --> Descrição de critica tratada
                                      ,pr_des_reto OUT VARCHAR2                  --> Retorno OK / NOK
                                      ,pr_tab_erro OUT gene0001.typ_tab_erro) IS --> Tabela com possíves erros
  /* -------------------------------------------------------------------------------------------------------------

    Programa: pc_busca_dados_simulacao      Antigo: b1wgen0097.p(calcula_data_parcela_sim)
    Autor   : Douglas Pagel / AMcom 
    Data    : 18/12/2018               ultima Atualizacao: -- 
     
    Dados referentes ao programa:
   
    Objetivo  : Rotina para buscar dados de uma simulação específica
   
    Alteracoes: 

  ..............................................................................*/  
                                            
    --Cursores
    
    --Cursor para dados da simulação
    CURSOR cr_crapsim(pr_cdcooper IN crapsim.cdcooper%TYPE
                     ,pr_nrdconta IN crapsim.nrdconta%TYPE
                     ,pr_nrsimula IN crapsim.nrsimula%TYPE) IS
      SELECT *
        FROM crapsim sim
       WHERE sim.cdcooper = pr_cdcooper
         AND sim.nrdconta = pr_nrdconta
         AND sim.nrsimula = pr_nrsimula;
    rw_crapsim cr_crapsim%ROWTYPE;
    
    --Cursor para associado
    CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE
                     ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
      SELECT ass.cdagenci 
        FROM crapass ass
       WHERE ass.cdcooper = pr_cdcooper
         AND ass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;
    
    --Cursor para Linhas de Crédito
    CURSOR cr_craplcr(pr_cdcooper IN craplcr.cdcooper%TYPE
                     ,pr_cdlcremp IN craplcr.cdlcremp%TYPE) IS
      SELECT lcr.dslcremp, lcr.cdmodali, lcr.cdsubmod
        FROM craplcr lcr
       WHERE lcr.cdcooper = pr_cdcooper
         AND lcr.cdlcremp = pr_cdlcremp;
    rw_craplcr cr_craplcr%ROWTYPE;
    
    --Cursor para Finalidades
    CURSOR cr_crapfin(pr_cdcooper IN crapfin.cdcooper%TYPE
                     ,pr_cdfinemp IN crapfin.cdfinemp%TYPE) IS
      SELECT fin.dsfinemp, fin.tpfinali
        FROM crapfin fin
       WHERE fin.cdcooper = pr_cdcooper
         AND fin.cdfinemp = pr_cdfinemp;
    rw_crapfin cr_crapfin%ROWTYPE;
    
    --Cursor para Cadastro de submodalidades das operacoes de credito.
    CURSOR cr_gnsbmod(pr_cdmodali IN gnsbmod.cdmodali%TYPE
                     ,pr_cdsubmod IN gnsbmod.cdsubmod%TYPE) IS
      SELECT modali.dssubmod, modali.cdsubmod
        FROM gnsbmod modali 
       WHERE modali.cdmodali = pr_cdmodali
         AND modali.cdsubmod = pr_cdsubmod;
    rw_gnsbmod cr_gnsbmod%ROWTYPE;     
                     
    --Variaveis
    vr_tt_datas_parcelas typ_tab_datas_parcelas;
    vr_aux_nrparce INTEGER;
    vr_aux_log_rowid ROWID;
    vr_aux_dstransa VARCHAR2(50);
    vr_aux_dsorigem VARCHAR2(40);
    vr_tab_parc tela_atenda_simulacao.typ_tab_parcelas;
    idx integer;
    
    BEGIN
      IF pr_flgerlog THEN
        vr_aux_dsorigem := gene0001.vr_vet_des_origens(pr_cdorigem);
        vr_aux_dstransa := 'Carregar as simulacoes de emprestimos.';
      END IF;
      
      --Carrega cursor com a simulação 
      OPEN cr_crapsim(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta
                     ,pr_nrsimula => pr_nrsimula);
      FETCH cr_crapsim
       INTO rw_crapsim;
      -- Se encontrar informações
      IF cr_crapsim%FOUND THEN
        pr_tcrapsim(pr_nrdconta).cdcooper := rw_crapsim.cdcooper;                                                       
        pr_tcrapsim(pr_nrdconta).nrdconta := rw_crapsim.nrdconta;                                                       
        pr_tcrapsim(pr_nrdconta).nrsimula := rw_crapsim.nrsimula;                                                       
        pr_tcrapsim(pr_nrdconta).vlemprst := rw_crapsim.vlemprst;                                                       
        pr_tcrapsim(pr_nrdconta).qtparepr := rw_crapsim.qtparepr;                                                       
        pr_tcrapsim(pr_nrdconta).vlparepr := rw_crapsim.vlparepr;                                                       
        pr_tcrapsim(pr_nrdconta).txmensal := rw_crapsim.txmensal;                                                       
        pr_tcrapsim(pr_nrdconta).txdiaria := rw_crapsim.txdiaria;                                                       
        pr_tcrapsim(pr_nrdconta).cdlcremp := rw_crapsim.cdlcremp;                                                       
        pr_tcrapsim(pr_nrdconta).dtdpagto := rw_crapsim.dtdpagto;                                                       
        pr_tcrapsim(pr_nrdconta).vliofepr := rw_crapsim.vliofepr;                                                       
        pr_tcrapsim(pr_nrdconta).vlrtarif := rw_crapsim.vlrtarif;                                                       
        pr_tcrapsim(pr_nrdconta).vllibera := rw_crapsim.vllibera;                                                       
        pr_tcrapsim(pr_nrdconta).dtmvtolt := rw_crapsim.dtmvtolt;                                                       
        pr_tcrapsim(pr_nrdconta).hrtransa := rw_crapsim.hrtransa;                                                       
        pr_tcrapsim(pr_nrdconta).cdoperad := rw_crapsim.cdoperad;                                                       
        pr_tcrapsim(pr_nrdconta).dtlibera := rw_crapsim.dtlibera;                                                       
        pr_tcrapsim(pr_nrdconta).vlajuepr := rw_crapsim.vlajuepr;                                                       
        pr_tcrapsim(pr_nrdconta).percetop := rw_crapsim.percetop;                                                       
        pr_tcrapsim(pr_nrdconta).cdfinemp := rw_crapsim.cdfinemp;                                                       
        pr_tcrapsim(pr_nrdconta).idfiniof := rw_crapsim.idfiniof;                                                       
        pr_tcrapsim(pr_nrdconta).vliofcpl := rw_crapsim.vliofcpl;                                                       
        pr_tcrapsim(pr_nrdconta).vliofadc := rw_crapsim.vliofadc;
        pr_tcrapsim(pr_nrdconta).tpemprst := rw_crapsim.tpemprst;
        
        IF rw_crapsim.tpemprst = 2 THEN
          pr_tcrapsim(pr_nrdconta).idcarenc := rw_crapsim.idcarenc;
          pr_tcrapsim(pr_nrdconta).vlprecar := rw_crapsim.vlprecar;
          pr_tcrapsim(pr_nrdconta).dtcarenc := rw_crapsim.dtcarenc;
        END IF;
        
        pr_tcrapsim(pr_nrdconta).dtvalidade := rw_crapsim.dtvalidade;
        pr_tcrapsim(pr_nrdconta).idsegmento := rw_crapsim.idsegmento;
        pr_tcrapsim(pr_nrdconta).cdorigem := rw_crapsim.cdorigem;
        pr_tcrapsim(pr_nrdconta).idpessoa := rw_crapsim.idpessoa;
        pr_tcrapsim(pr_nrdconta).nrseq_telefone := rw_crapsim.nrseq_telefone;
        pr_tcrapsim(pr_nrdconta).nrseq_email := rw_crapsim.nrseq_email;
        
          
        pr_tcrapsim(pr_nrdconta).nrdialib := gene0005.fn_calc_qtd_dias_uteis(pr_cdcooper => rw_crapsim.cdcooper 
                                                               ,pr_dtinical => rw_crapsim.dtmvtolt
                                                               ,pr_dtfimcal => rw_crapsim.dtlibera);
                                                               
          
        --Busca a agencia do associado
        OPEN cr_crapass(pr_cdcooper => rw_crapsim.cdcooper
                       ,pr_nrdconta => rw_crapsim.nrdconta);
        FETCH cr_crapass 
         INTO rw_crapass;
        
        IF cr_crapass%FOUND THEN
          pr_tcrapsim(pr_nrdconta).cdagenci := rw_crapass.cdagenci;   
        END IF; 
        CLOSE cr_crapass;
        
        --Busca a linha de crédito
        OPEN cr_craplcr(pr_cdcooper => rw_crapsim.cdcooper
                       ,pr_cdlcremp => rw_crapsim.cdlcremp);
        FETCH cr_craplcr 
         INTO rw_craplcr;
        
        IF cr_craplcr%FOUND THEN
          pr_tcrapsim(pr_nrdconta).dslcremp := rw_craplcr.dslcremp;   
        END IF; 
        
        --Busca a finalidade
        OPEN cr_crapfin(pr_cdcooper => rw_crapsim.cdcooper
                       ,pr_cdfinemp => rw_crapsim.cdfinemp);
        FETCH cr_crapfin 
         INTO rw_crapfin;
        
        IF cr_crapfin%FOUND THEN
          pr_tcrapsim(pr_nrdconta).dsfinemp := rw_crapfin.dsfinemp;   
        END IF; 

        pr_tcrapsim(pr_nrdconta).vlrtotal := nvl(rw_crapsim.vlemprst,0);
        
        IF rw_crapsim.idfiniof = 1 THEN
          pr_tcrapsim(pr_nrdconta).vlrtotal := nvl(rw_crapsim.vlemprst,0) + nvl(rw_crapsim.vliofepr,0) + nvl(rw_crapsim.vlrtarif,0); 
        END IF;
        
        IF (cr_crapfin%FOUND) AND (cr_craplcr%FOUND) THEN
          pr_tcrapsim(pr_nrdconta).tpfinali := rw_crapfin.tpfinali;   
        
          -- Se for portabilidade
          IF rw_crapfin.tpfinali = 2 THEN
            --Busca modalidade
            OPEN cr_gnsbmod(pr_cdmodali => rw_craplcr.cdmodali
                           ,pr_cdsubmod => rw_craplcr.cdsubmod);
            FETCH cr_gnsbmod 
             INTO rw_gnsbmod;
             
            -- armazena o nome da submodalidade e cdmodali 
            IF cr_gnsbmod%FOUND THEN
              pr_tcrapsim(pr_nrdconta).dsmodali := rw_gnsbmod.dssubmod;
              pr_tcrapsim(pr_nrdconta).cdmodali := rw_craplcr.cdmodali || rw_gnsbmod.cdsubmod ;  
            END IF;
           CLOSE cr_gnsbmod; 
          END IF;    
        END IF;
        CLOSE cr_craplcr;
        CLOSE cr_crapfin;
        -- Datas das prestações
        tela_atenda_simulacao.pc_retorna_simulacao_parcela(pr_cdcooper => pr_cdcooper
                                                         , pr_nrdconta => pr_nrdconta
                                                         , pr_nrsimula => pr_nrsimula
                                                         , pr_tab_parcelas => vr_tab_parc
                                                         , pr_cdcritic => pr_cdcritic
                                                         , pr_dscritic => pr_des_erro);
                                                         
        --Alimenta parametro tabela de prestações  
          FOR idx IN 1..vr_tab_parc.count
          LOOP
            pr_tparcepr(idx).cdcooper := pr_cdcooper;   
            pr_tparcepr(idx).nrdconta := pr_nrdconta;
            pr_tparcepr(idx).nrparepr := vr_tab_parc(idx).nrparepr; 
            pr_tparcepr(idx).vlparepr := vr_tab_parc(idx).vlparepr;
            pr_tparcepr(idx).dtvencto := vr_tab_parc(idx).dtvencto; 
            pr_tparcepr(idx).dtparepr := vr_tab_parc(idx).dtvencto; 
          END LOOP;
                                                                 
        CLOSE cr_crapsim;                                                         
      ELSE
        CLOSE cr_crapsim;
        pr_des_reto :=  'NOK';
        pr_cdcritic := 0;
        pr_des_erro := 'Registro de simulacao nao encontrado.';
        
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => pr_cdcritic
                             ,pr_dscritic => pr_des_erro
                             ,pr_tab_erro => pr_tab_erro);  
      END IF;
      
      IF pr_flgerlog THEN
        GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper 
                           , pr_cdoperad => pr_cdoperad
                           , pr_dscritic => NULL
                           , pr_dsorigem => vr_aux_dsorigem
                           , pr_dstransa => vr_aux_dstransa
                           , pr_dttransa => TRUNC(SYSDATE)
                           , pr_flgtrans => 1 
                           , pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE, 'SSSSS'))
                           , pr_idseqttl => pr_idseqttl
                           , pr_nmdatela => pr_nmdatela
                           , pr_nrdconta => pr_nrdconta
                           , pr_nrdrowid => vr_aux_log_rowid);
      END IF;
      
      pr_des_reto := 'OK'; 
    EXCEPTION WHEN OTHERS
      THEN

        pr_des_reto := 'NOK';
        pr_des_erro := 'Erro nao esperado na pc_busca_dados_simulacao - '|| SQLERRM;

        IF cr_crapsim%ISOPEN 
          THEN
            CLOSE cr_crapsim;
        END IF;
        
        IF cr_craplcr%ISOPEN
          THEN
            CLOSE cr_craplcr;           
        END IF;
      
    END pc_busca_dados_simulacao; 
    
   -- Excluir simulação de empréstimo
   PROCEDURE pc_exclui_simulacao(pr_cdcooper IN crapcop.cdcooper%TYPE
                                 ,pr_cdagenci IN crapage.cdagenci%TYPE
                                 ,pr_nrdcaixa IN INTEGER
                                 ,pr_cdoperad IN VARCHAR2
                                 ,pr_nmdatela IN VARCHAR2
                                 ,pr_cdorigem IN INTEGER
                                 ,pr_nrdconta IN crapass.nrdconta%TYPE
                                 ,pr_idseqttl IN INTEGER
                                 ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE
                                 ,pr_flgerlog IN BOOLEAN
                                 ,pr_nrsimula INTEGER
                                 ,pr_cdcritic OUT crapcri.cdcritic%TYPE      --> Código da crítica tratada
                                 ,pr_des_erro OUT VARCHAR2                   --> Descrição de critica tratada
                                 ,pr_des_reto OUT VARCHAR                    --> Retorno OK / NOK
                                 ,pr_tab_erro OUT gene0001.typ_tab_erro) IS  --> Tabela com possíves erros

  /* -------------------------------------------------------------------------------------------------------------

    Programa: pc_exclui_simulacao      Antigo: b1wgen0097.p(exclui_simulacao)
    Autor   : Douglas Pagel / AMcom 
    Data    : 18/12/2018               ultima Atualizacao: -- 
     
    Dados referentes ao programa:
   
    Objetivo  : Rotina para excluír uma simulação específica
   
    Alteracoes: 

  ..............................................................................*/
                                   
    --Cursores
    --Cursor para dados da simulação
    CURSOR cr_crapsim(pr_cdcooper IN crapsim.cdcooper%TYPE
                     ,pr_nrdconta IN crapsim.nrdconta%TYPE
                     ,pr_nrsimula IN crapsim.nrsimula%TYPE) IS
      SELECT nrsimula
        FROM crapsim sim
       WHERE sim.cdcooper = pr_cdcooper
         AND sim.nrdconta = pr_nrdconta
         AND sim.nrsimula = pr_nrsimula;
    rw_crapsim cr_crapsim%ROWTYPE;
    
    --Variaveis
    vr_aux_log_rowid ROWID;
    vr_aux_dstransa VARCHAR2(50);
    vr_aux_dsorigem VARCHAR2(40);
    vr_des_erro VARCHAR2(4000);
    vr_cdcritic INTEGER;
    
    --Variaveis de Excecao
    vr_exc_erro  EXCEPTION;
    
                                      
    BEGIN
      IF pr_flgerlog THEN
        vr_aux_dsorigem := gene0001.vr_vet_des_origens(pr_cdorigem);
        vr_aux_dstransa := 'Excluir simulacao de emprestimo ' || pr_nrsimula;
      END IF; 
      
      OPEN cr_crapsim(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta
                     ,pr_nrsimula => pr_nrsimula);
      FETCH cr_crapsim
       INTO rw_crapsim;
       
      IF cr_crapsim%FOUND THEN
        -- Se encontrou o registro, faz o delete
      BEGIN
        DELETE FROM crapsim sim 
         WHERE sim.cdcooper = pr_cdcooper
           AND sim.nrdconta = pr_nrdconta
           AND sim.nrsimula = pr_nrsimula;
           
      EXCEPTION
        WHEN OTHERS THEN
          pr_des_erro := 'Erro ao excluir a simulação de emprestimo. ' ||
                          sqlerrm;
         RAISE vr_exc_erro;    
      END;
           
        tela_atenda_simulacao.pc_remove_simulacao_parcela(pr_cdcooper => pr_cdcooper
                                                        , pr_nrdconta => pr_nrdconta
                                                        , pr_nrsimula => pr_nrsimula
                                                        , pr_cdcritic => vr_cdcritic
                                                        , pr_dscritic => vr_des_erro);
                                                        
        IF vr_cdcritic <> 0 or trim(vr_des_erro) is not null THEN
          RAISE vr_exc_erro;  
        END IF;                                                                                                                        
      
      ELSE
        vr_des_erro := 'Registro de simulação não encontrado.';
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_des_erro
                             ,pr_tab_erro => pr_tab_erro);  
        CLOSE cr_crapsim;
        RAISE vr_exc_erro;
      END IF;
      
      CLOSE cr_crapsim;
      
      IF pr_flgerlog THEN
        GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper 
                           , pr_cdoperad => pr_cdoperad
                           , pr_dscritic => NULL
                           , pr_dsorigem => vr_aux_dsorigem
                           , pr_dstransa => vr_aux_dstransa
                           , pr_dttransa => TRUNC(SYSDATE)
                           , pr_flgtrans => 1 
                           , pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE, 'SSSSS'))
                           , pr_idseqttl => pr_idseqttl
                           , pr_nmdatela => pr_nmdatela
                           , pr_nrdconta => pr_nrdconta
                           , pr_nrdrowid => vr_aux_log_rowid);
      END IF;
      pr_des_reto := 'OK'; 

    EXCEPTION
      WHEN vr_exc_erro THEN
        IF cr_crapsim%ISOPEN
          THEN
            CLOSE cr_crapsim;
        END IF;    
        
        pr_des_reto := 'NOK';
        pr_cdcritic := nvl(vr_cdcritic, 0);
        pr_des_erro := vr_des_erro;
      WHEN OTHERS THEN
        pr_des_reto := 'NOK';
        pr_cdcritic := nvl(pr_cdcritic, 0);
        pr_des_erro := 'Erro na rotina de exclusão de simulação de emprestimo. ' ||
                       sqlerrm; 
    END pc_exclui_simulacao; 
    
   --Carregar simulacões de emprestimo de uma conta
   PROCEDURE pc_busca_simulacoes(pr_cdcooper IN crapcop.cdcooper%TYPE
                                 ,pr_cdagenci IN crapage.cdagenci%TYPE
                                 ,pr_nrdcaixa IN INTEGER
                                 ,pr_cdoperad IN VARCHAR2
                                 ,pr_nmdatela IN VARCHAR2
                                 ,pr_cdorigem IN INTEGER
                                 ,pr_nrdconta IN crapass.nrdconta%TYPE
                                 ,pr_idseqttl IN INTEGER
                                 ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE
                                 ,pr_flgerlog IN BOOLEAN
								 ,pr_datainic IN DATE DEFAULT NULL           --> Data inicial da pesquisa
                                 ,pr_datafina IN DATE DEFAULT NULL           --> Data final da pesquisa
                                 ,pr_tcrapsim OUT typ_tab_sim
                                 ,pr_cdcritic OUT crapcri.cdcritic%TYPE      --> Código da crítica tratada
                                 ,pr_des_erro OUT VARCHAR2                   --> Descrição de critica tratada
                                 ,pr_des_reto OUT VARCHAR                    --> Retorno OK / NOK
                                 ,pr_tab_erro OUT gene0001.typ_tab_erro) IS  --> Tabela com possíves erros

  /* -------------------------------------------------------------------------------------------------------------

    Programa: pc_busca_simulacoes      Antigo: b1wgen0097.p(busca_simulacoes)
    Autor   : Douglas Pagel / AMcom 
    Data    : 18/12/2018               ultima Atualizacao: -- 
     
    Dados referentes ao programa:
   
    Objetivo  : Rotina para buscar simulações de emprestimos de um cooperado
   
    Alteracoes: 

  ..............................................................................*/
                                   
    vr_dt_ini DATE;
    vr_dt_fim DATE;
    -- Cursores
    -- Cursor para dados da simulação
    CURSOR cr_crapsim(pr_cdcooper IN crapsim.cdcooper%TYPE
                     ,pr_nrdconta IN crapsim.nrdconta%TYPE
                     ,pr_cdorigem IN INTEGER) IS
      SELECT *
        FROM crapsim sim
       WHERE sim.cdcooper = pr_cdcooper
         AND sim.nrdconta = pr_nrdconta
         AND sim.dtmvtolt BETWEEN vr_dt_ini AND vr_dt_fim
         AND NOT ( vr_dt_ini IS NULL ) 
         AND NOT ( vr_dt_fim IS NULL )
         AND ( ( pr_cdorigem = 3 AND sim.cdorigem = pr_cdorigem )
          OR ( NVL(pr_cdorigem,0) != 3 ) )
         AND NOT EXISTS ( SELECT 1
                            FROM crawepr wpr
                           WHERE wpr.cdcooper = sim.cdcooper
                             AND wpr.nrdconta = sim.nrdconta
                             AND wpr.nrsimula = sim.nrsimula )
      UNION  
      SELECT *
        FROM crapsim sim
       WHERE sim.cdcooper = pr_cdcooper
         AND sim.nrdconta = pr_nrdconta         
         AND sim.dtmvtolt BETWEEN nvl(vr_dt_ini,to_date('01/01/1500','dd/mm/rrrr')) AND nvl(vr_dt_fim,to_date('01/01/3999','dd/mm/rrrr'))
         AND ( ( pr_cdorigem = 3 AND sim.cdorigem = pr_cdorigem )
          OR ( NVL(pr_cdorigem,0) != 3 ) )
         AND NOT EXISTS ( SELECT 1
                            FROM crawepr wpr
                           WHERE wpr.cdcooper = sim.cdcooper
                             AND wpr.nrdconta = sim.nrdconta
                             AND wpr.nrsimula = sim.nrsimula );
    rw_crapsim cr_crapsim%ROWTYPE;
    
    --Cursor para associado
    CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE
                     ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
      SELECT ass.cdagenci 
        FROM crapass ass
       WHERE ass.cdcooper = pr_cdcooper
         AND ass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;
    
    --Cursor para Linhas de Crédito
    CURSOR cr_craplcr(pr_cdcooper IN craplcr.cdcooper%TYPE
                     ,pr_cdlcremp IN craplcr.cdlcremp%TYPE) IS
      SELECT lcr.dslcremp, lcr.cdmodali, lcr.cdsubmod
        FROM craplcr lcr
       WHERE lcr.cdcooper = pr_cdcooper
         AND lcr.cdlcremp = pr_cdlcremp;
    rw_craplcr cr_craplcr%ROWTYPE;
    
    --Cursor para Finalidades
    CURSOR cr_crapfin(pr_cdcooper IN crapfin.cdcooper%TYPE
                     ,pr_cdfinemp IN crapfin.cdfinemp%TYPE) IS
      SELECT fin.dsfinemp, fin.tpfinali
        FROM crapfin fin
       WHERE fin.cdcooper = pr_cdcooper
         AND fin.cdfinemp = pr_cdfinemp;
    rw_crapfin cr_crapfin%ROWTYPE;
    
    --Variaveis
    vr_aux_log_rowid ROWID;
    vr_aux_dstransa VARCHAR2(50);
    vr_aux_dsorigem VARCHAR2(40);
    vr_des_erro VARCHAR2(4000);
    vr_index PLS_INTEGER;
    
    BEGIN
      IF pr_flgerlog THEN
        vr_aux_dsorigem := gene0001.vr_vet_des_origens(pr_cdorigem);
        vr_aux_dstransa := 'Buscar simulacoes de emprestimo. ';
      END IF; 

      vr_dt_ini := pr_datainic;
      vr_dt_fim := pr_datafina;
      
      --Carrega a tabela de retorno com os dados da simulações
      FOR rw_crapsim in cr_crapsim(pr_cdcooper => pr_cdcooper, pr_nrdconta => pr_nrdconta, pr_cdorigem => pr_cdorigem) LOOP
        --Incrementa indice da Tabela de retorno  
        vr_index:= pr_tcrapsim.count + 1;
        
        pr_tcrapsim(vr_index).cdcooper := rw_crapsim.cdcooper;                                                       
        pr_tcrapsim(vr_index).nrdconta := rw_crapsim.nrdconta;                                                       
        pr_tcrapsim(vr_index).nrsimula := rw_crapsim.nrsimula;                                                       
        pr_tcrapsim(vr_index).vlemprst := rw_crapsim.vlemprst;                                                       
        pr_tcrapsim(vr_index).qtparepr := rw_crapsim.qtparepr;                                                       
        pr_tcrapsim(vr_index).vlparepr := rw_crapsim.vlparepr;                                                       
        pr_tcrapsim(vr_index).txmensal := rw_crapsim.txmensal;                                                       
        pr_tcrapsim(vr_index).txdiaria := rw_crapsim.txdiaria;                                                       
        pr_tcrapsim(vr_index).cdlcremp := rw_crapsim.cdlcremp;                                                       
        pr_tcrapsim(vr_index).dtdpagto := rw_crapsim.dtdpagto;                                                       
        pr_tcrapsim(vr_index).vliofepr := rw_crapsim.vliofepr;                                                       
        pr_tcrapsim(vr_index).vlrtarif := rw_crapsim.vlrtarif;                                                       
        pr_tcrapsim(vr_index).vllibera := rw_crapsim.vllibera;                                                       
        pr_tcrapsim(vr_index).dtmvtolt := rw_crapsim.dtmvtolt;                                                       
        pr_tcrapsim(vr_index).hrtransa := rw_crapsim.hrtransa;                                                       
        pr_tcrapsim(vr_index).cdoperad := rw_crapsim.cdoperad;                                                       
        pr_tcrapsim(vr_index).dtlibera := rw_crapsim.dtlibera;                                                       
        pr_tcrapsim(vr_index).vlajuepr := rw_crapsim.vlajuepr;                                                       
        pr_tcrapsim(vr_index).percetop := rw_crapsim.percetop;                                                       
        pr_tcrapsim(vr_index).cdfinemp := rw_crapsim.cdfinemp;                                                       
        pr_tcrapsim(vr_index).idfiniof := rw_crapsim.idfiniof;                                                       
        pr_tcrapsim(vr_index).vliofcpl := rw_crapsim.vliofcpl;                                                       
        pr_tcrapsim(vr_index).vliofadc := rw_crapsim.vliofadc;
        pr_tcrapsim(vr_index).tpemprst := rw_crapsim.tpemprst;
        pr_tcrapsim(vr_index).idcarenc := rw_crapsim.idcarenc;
        pr_tcrapsim(vr_index).vlprecar := rw_crapsim.vlprecar;
        pr_tcrapsim(vr_index).dtcarenc := rw_crapsim.dtcarenc;
        pr_tcrapsim(vr_index).dtvalidade := rw_crapsim.dtvalidade;
        pr_tcrapsim(vr_index).idsegmento := rw_crapsim.idsegmento;
        pr_tcrapsim(vr_index).cdorigem := rw_crapsim.cdorigem;
        pr_tcrapsim(vr_index).idpessoa := rw_crapsim.idpessoa;
        pr_tcrapsim(vr_index).nrseq_telefone := rw_crapsim.nrseq_telefone;
        pr_tcrapsim(vr_index).nrseq_email := rw_crapsim.nrseq_email;
          
        --Busca a agencia do associado
        OPEN cr_crapass(pr_cdcooper => rw_crapsim.cdcooper
                       ,pr_nrdconta => rw_crapsim.nrdconta);
        FETCH cr_crapass 
         INTO rw_crapass;
        
        IF cr_crapass%FOUND THEN
          pr_tcrapsim(vr_index).cdagenci := rw_crapass.cdagenci;   
        END IF; 
        CLOSE cr_crapass;
        
        --Busca a linha de crédito
        OPEN cr_craplcr(pr_cdcooper => rw_crapsim.cdcooper
                       ,pr_cdlcremp => rw_crapsim.cdlcremp);
        FETCH cr_craplcr 
         INTO rw_craplcr;
        
        IF cr_craplcr%FOUND THEN
          pr_tcrapsim(vr_index).dslcremp := rw_craplcr.dslcremp; 
          pr_tcrapsim(vr_index).cdmodali := rw_craplcr.cdmodali || rw_craplcr.cdsubmod;   
        END IF; 
        CLOSE cr_craplcr;
        
        --Busca a finalidade
        OPEN cr_crapfin(pr_cdcooper => rw_crapsim.cdcooper
                       ,pr_cdfinemp => rw_crapsim.cdfinemp);
        FETCH cr_crapfin 
         INTO rw_crapfin;
        
        IF cr_crapfin%FOUND THEN
          pr_tcrapsim(vr_index).dsfinemp := rw_crapfin.dsfinemp;  
          pr_tcrapsim(vr_index).tpfinali := rw_crapfin.tpfinali; 
        END IF; 
        CLOSE cr_crapfin;
      END LOOP;
      
      IF pr_flgerlog THEN
        GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper 
                           , pr_cdoperad => pr_cdoperad
                           , pr_dscritic => NULL
                           , pr_dsorigem => vr_aux_dsorigem
                           , pr_dstransa => vr_aux_dstransa
                           , pr_dttransa => TRUNC(SYSDATE)
                           , pr_flgtrans => 1 
                           , pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE, 'SSSSS'))
                           , pr_idseqttl => pr_idseqttl
                           , pr_nmdatela => pr_nmdatela
                           , pr_nrdconta => pr_nrdconta
                           , pr_nrdrowid => vr_aux_log_rowid);
      END IF;
      pr_des_reto := 'OK'; 
         
    EXCEPTION
      WHEN OTHERS THEN
        pr_des_reto := 'NOK';
        pr_cdcritic := nvl(pr_cdcritic, 0);
        pr_des_erro := 'Erro na rotina que carrega as simulações de empréstimo. ' ||
                       sqlerrm;    
    END pc_busca_simulacoes;
    
   PROCEDURE pc_consulta_tarifa_emprst(pr_cdcooper IN INTEGER                    
                                       ,pr_cdlcremp IN INTEGER 
                                       ,pr_vlemprst IN NUMBER                      --> Valor do empréstimo
                                       ,pr_nrdconta IN INTEGER                     --> Número da conta do associado
                                       ,pr_nrctremp IN INTEGER                     --> Número do contrato de empréstimo
                                       ,pr_dscatbem IN VARCHAR2                    --> Bens informados para o empréstimo
                                       ,pr_vlrtarif OUT NUMBER                     --> Retorno com o valor da tarifa
                                       ,pr_cdcritic OUT crapcri.cdcritic%TYPE      --> Código da crítica tratada
                                       ,pr_des_erro OUT VARCHAR2                   --> Descrição de critica tratada
                                       ,pr_des_reto OUT VARCHAR                    --> Retorno OK / NOK 
                                       ,pr_tab_erro OUT gene0001.typ_tab_erro) IS  --> Tabela com possíves erros
                                       
  /* -------------------------------------------------------------------------------------------------------------

    Programa: pc_consulta_tarifa_emprst      Antigo: b1wgen0097.p(consulta_tarifa_emprst)
    Autor   : Douglas Pagel / AMcom 
    Data    : 18/12/2018               ultima Atualizacao: -- 
     
    Dados referentes ao programa:
   
    Objetivo  : Rotina para retornar o valor da tarifa de um emprestimo
   
    Alteracoes: 

  ..............................................................................*/
                                         
    --Cursor
    --Busca a linha de crédito
    CURSOR cr_craplcr(pr_cdcooper IN craplcr.cdcooper%TYPE
                     ,pr_cdlcremp IN craplcr.cdlcremp%TYPE) IS
      SELECT lcr.dslcremp, lcr.cdmodali, lcr.cdsubmod, lcr.cdusolcr, lcr.tpctrato
        FROM craplcr lcr
       WHERE lcr.cdcooper = pr_cdcooper
         AND lcr.cdlcremp = pr_cdlcremp;
    rw_craplcr cr_craplcr%ROWTYPE;
     
    --Busca dados do associado
    CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE
                     ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
      SELECT ass.inpessoa
        FROM crapass ass 
       WHERE ass.cdcooper = pr_cdcooper
         AND ass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;
    
    --Busca categoria do bem
    CURSOR cr_crapbpr(pr_cdcooper IN crapbpr.cdcooper%TYPE
                     ,pr_nrdconta IN crapbpr.nrdconta%TYPE
                     ,pr_nrctrpro IN crapbpr.nrctrpro%TYPE
                     ,pr_tpctrpro IN crapbpr.tpctrpro%TYPE) IS
      SELECT bpr.dscatbem
        FROM crapbpr bpr
       WHERE bpr.cdcooper = pr_cdcooper
         AND bpr.nrdconta = pr_nrdconta
         AND bpr.nrctrpro = pr_nrctrpro
         AND bpr.tpctrpro = pr_tpctrpro;
    rw_crapbpr cr_crapbpr%ROWTYPE;
    
    --Variaveis
    vr_aux_inpessoa INTEGER;
    vr_aux_dscatbem VARCHAR2(1000); 
    vr_vlrtarif crapfco.vltarifa%TYPE; 
    vr_vltrfesp craplcr.vltrfesp%TYPE; 
    vr_vltrfgar crapfco.vltarifa%TYPE; 
    vr_cdhistor craphis.cdhistor%TYPE; 
    vr_cdfvlcop crapfco.cdfvlcop%TYPE; 
    vr_cdhisgar craphis.cdhistor%TYPE; 
    vr_cdfvlgar crapfco.cdfvlcop%TYPE; 
    vr_cdcritic crapcri.cdcritic%TYPE; 
    vr_dscritic VARCHAR2(4000);
    vr_exc_erro EXCEPTION; 
    vr_aux_cdbattar VARCHAR2(25);
     
    vr_cdhisest NUMBER;  
    vr_vltarifa NUMBER;  
    vr_dtdivulg DATE;    
    vr_dtvigenc DATE;    
    
    BEGIN
      OPEN cr_craplcr(pr_cdcooper => pr_cdcooper
                     ,pr_cdlcremp => pr_cdlcremp);
      FETCH cr_craplcr
       INTO rw_craplcr;
      
      IF cr_craplcr%NOTFOUND THEN
        CLOSE cr_craplcr;
        pr_cdcritic := 363;
        pr_des_reto := 'NOK';
        RAISE vr_exc_erro;    
      ELSE
        CLOSE cr_craplcr;
      END IF;
      
      
      OPEN cr_crapass(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta);
      FETCH cr_crapass
       INTO rw_crapass;
       
      IF cr_crapass%FOUND THEN
        vr_aux_inpessoa := rw_crapass.inpessoa;
      END IF;
      CLOSE cr_crapass;
      
      --Caso enviado Numero Contrato, buscamos os bens, senão usamos a lista passada
      IF pr_nrctremp > 0 THEN
        vr_aux_dscatbem := null;
        FOR rw_crapbpr IN cr_crapbpr(pr_cdcooper => pr_cdcooper
                                    ,pr_nrdconta => pr_nrdconta
                                    ,pr_nrctrpro => pr_nrctremp
                                    ,pr_tpctrpro => 90) LOOP
           vr_aux_dscatbem := vr_aux_dscatbem || '|' || rw_crapbpr.dscatbem;
         END LOOP;
      ELSE
        vr_aux_dscatbem := pr_dscatbem;    
      END IF;
      
      --Busca a tarifa                     
      TARI0001.pc_calcula_tarifa(pr_cdcooper => pr_cdcooper    
                                ,pr_nrdconta => pr_nrdconta    
                                ,pr_cdlcremp => pr_cdlcremp 
                                ,pr_vlemprst => pr_vlemprst 
                                ,pr_cdusolcr => rw_craplcr.cdusolcr
                                ,pr_tpctrato => rw_craplcr.tpctrato
                                ,pr_dsbemgar => vr_aux_dscatbem    
                                ,pr_cdprogra => 'ATENDA'        
                                ,pr_flgemail => 'N'             
                                ,pr_tpemprst => NULL               
                                ,pr_idfiniof => 0
                                --
                                ,pr_vlrtarif => vr_vlrtarif
                                ,pr_vltrfesp => vr_vltrfesp
                                ,pr_vltrfgar => vr_vltrfgar
                                ,pr_cdhistor => vr_cdhistor
                                ,pr_cdfvlcop => vr_cdfvlcop
                                ,pr_cdhisgar => vr_cdhisgar
                                ,pr_cdfvlgar => vr_cdfvlgar
                                ,pr_cdcritic => vr_cdcritic
                                ,pr_dscritic => vr_dscritic);
      
      IF trim(vr_dscritic) is not null THEN
      
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => 1
                             ,pr_nrdcaixa => 1
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro); 
        RAISE vr_exc_erro;      
      END IF;
      
      --Retorna a tarifa
      pr_vlrtarif := 0;
      
      IF NVL(vr_vlrtarif,0) > 0 THEN
        pr_vlrtarif := pr_vlrtarif + ROUND(vr_vlrtarif,2);
      END IF;
      
      IF NVL(vr_vltrfesp,0) > 0 THEN
        pr_vlrtarif := pr_vlrtarif + ROUND(vr_vltrfesp,2);
      END IF;
      
      IF NVL(vr_vltrfgar,0) > 0 THEN
        pr_vlrtarif := pr_vlrtarif + ROUND(vr_vltrfgar,2);
      END IF;
      vr_vltarifa := 0;
      --Faremos o cálculo abaixo somente se não recebemos bens nem contrato
      IF (pr_nrctremp = 0) AND (pr_dscatbem IS NULL) THEN
        IF rw_craplcr.tpctrato = 2 OR 
           rw_craplcr.tpctrato = 3 THEN
           
           IF rw_craplcr.tpctrato = 2 THEN
             --Verifica qual tarifa deve ser cobrada com base tipo pessoa 
             IF vr_aux_inpessoa = 1 THEN /* Fisica */
               vr_aux_cdbattar := 'AVALBMOVPF';
             ELSE
               vr_aux_cdbattar := 'AVALBMOVPJ';
             END IF;
           ELSE
             IF vr_aux_inpessoa = 1 THEN /* Fisica */
               vr_aux_cdbattar := 'AVALBIMVPF';
             ELSE
               vr_aux_cdbattar := 'AVALBIMVPJ'; 
             END IF; 
           END IF;
           
           -- Busca valor da tarifa de Emprestimo pessoa fisica
           TARI0001.pc_carrega_dados_tar_vigente(pr_cdcooper => pr_cdcooper
                                                ,pr_cdbattar => vr_aux_cdbattar
                                                ,pr_cdtarifa => null
                                                ,pr_vllanmto => pr_vlemprst
                                                ,pr_cdprogra => ''
                                                ,pr_cdhistor => vr_cdhistor
                                                ,pr_cdhisest => vr_cdhisest
                                                ,pr_vltarifa => vr_vltarifa
                                                ,pr_dtdivulg => vr_dtdivulg
                                                ,pr_dtvigenc => vr_dtvigenc
                                                ,pr_cdfvlcop => vr_cdfvlcop
                                                ,pr_cdcritic => vr_cdcritic
                                                ,pr_dscritic => vr_dscritic
                                                ,pr_tab_erro => pr_tab_erro); 
                                                
           IF trim(vr_dscritic) is not null THEN
      
              gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                                   ,pr_cdagenci => 1
                                   ,pr_nrdcaixa => 1
                                   ,pr_nrsequen => 1 --> Fixo
                                   ,pr_cdcritic => vr_cdcritic
                                   ,pr_dscritic => vr_dscritic
                                   ,pr_tab_erro => pr_tab_erro); 
              RAISE vr_exc_erro;      
      END IF;              
         END IF;    
      END IF;
      
    pr_vlrtarif := nvl(pr_vlrtarif,0) + nvl(vr_vltarifa,0);
      
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_cdcritic:= vr_cdcritic;
        pr_des_erro:= vr_dscritic;
        
      WHEN OTHERS THEN
        pr_des_reto := 'NOK';
        pr_cdcritic := nvl(vr_cdcritic, 0);
        pr_des_erro := 'Erro na rotina que busca a tarifa de empréstimo. ' ||
                       sqlerrm;  
        
    END pc_consulta_tarifa_emprst;
    
  PROCEDURE pc_consu_tari_emprst_prog(pr_cdcooper IN INTEGER                    
                                       ,pr_cdlcremp IN INTEGER 
                                       ,pr_vlemprst IN NUMBER                      --> Valor do empréstimo
                                       ,pr_nrdconta IN INTEGER                     --> Número da conta do associado
                                       ,pr_nrctremp IN INTEGER                     --> Número do contrato de empréstimo
                                       ,pr_dscatbem IN VARCHAR2                    --> Bens informados para o empréstimo
                                       ,pr_vlrtarif OUT NUMBER                     --> Retorno com o valor da tarifa 
                                       ,pr_cdcritic OUT crapcri.cdcritic%TYPE      --> Código da crítica tratada
                                       ,pr_dscritic OUT VARCHAR2                   --> Descrição de critica tratada
                                       ,pr_des_reto OUT VARCHAR) IS                --> Retorno da execução
  /* -------------------------------------------------------------------------------------------------------------

    Programa: pc_consu_tari_emprst_PROG      
    Autor   : Douglas Pagel / AMcom 
    Data    : 01/07/2019               ultima Atualizacao: -- 
     
    Dados referentes ao programa:
   
    Objetivo  : Rotina para retornar o valor da tarifa de um emprestimo pelo PROGRESS
   
    Alteracoes: 

  ..............................................................................*/
  /*Variaveis*/
  vr_tab_erro gene0001.typ_tab_erro;
                                       
  BEGIN
    EMPR0018.pc_consulta_tarifa_emprst( pr_cdcooper => pr_cdcooper   
                                       ,pr_cdlcremp => pr_cdlcremp
                                       ,pr_vlemprst => pr_vlemprst
                                       ,pr_nrdconta => pr_nrdconta
                                       ,pr_nrctremp => pr_nrctremp
                                       ,pr_dscatbem => pr_dscatbem
                                       ,pr_vlrtarif => pr_vlrtarif
                                       ,pr_cdcritic => pr_cdcritic
                                       ,pr_des_erro => pr_dscritic
                                       ,pr_des_reto => pr_des_reto
                                       ,pr_tab_erro => vr_tab_erro);
                                       
  EXCEPTION
    WHEN OTHERS THEN
        pr_des_reto := 'NOK';
        pr_cdcritic := nvl(vr_cdcritic, 0);
        pr_dscritic := 'Erro na rotina pc_consu_tari_emprst_prog. ' ||
                       sqlerrm;
                       
  END pc_consu_tari_emprst_prog;                                       
    
   PROCEDURE pc_valida_novo_calculo(pr_cdcooper IN crapcop.cdcooper%TYPE
                                    ,pr_cdagenci IN crapage.cdagenci%TYPE
                                    ,pr_nrdcaixa IN INTEGER
                                    ,pr_qtparepr IN INTEGER
                                    ,pr_cdlcremp IN INTEGER
                                    ,pr_flgpagto IN BOOLEAN
                                    ,pr_cdcritic OUT crapcri.cdcritic%TYPE      --> Código da crítica tratada
                                    ,pr_des_erro OUT VARCHAR2                   --> Descrição de critica tratada
                                    ,pr_des_reto OUT VARCHAR                    --> Retorno OK / NOK
                                    ,pr_tab_erro OUT gene0001.typ_tab_erro) IS  --> Tabela com possíves erros
                                    
  /* -------------------------------------------------------------------------------------------------------------

    Programa: pc_valida_novo_calculo      Antigo: b1wgen0084.p(valida_novo_calculo)
    Autor   : Douglas Pagel / AMcom 
    Data    : 18/12/2018               ultima Atualizacao: -- 
     
    Dados referentes ao programa:
   
    Objetivo  : Rotina para validar linha e parcelas da simulação
   
    Alteracoes: 

  ..............................................................................*/                                    
     
    /*CURSORES*/
    --Cursor para Linhas de Crédito
    CURSOR cr_craplcr(pr_cdcooper IN craplcr.cdcooper%TYPE
                     ,pr_cdlcremp IN craplcr.cdlcremp%TYPE) IS
      SELECT lcr.dslcremp, lcr.tpdescto
        FROM craplcr lcr
       WHERE lcr.cdcooper = pr_cdcooper
         AND lcr.cdlcremp = pr_cdlcremp;
    rw_craplcr cr_craplcr%ROWTYPE;
    
  --Cursor de parametrização
  CURSOR cr_craptab(pr_cdcooper IN craptab.cdcooper%TYPE
                   ,pr_nmsistem IN craptab.nmsistem%TYPE
                   ,pr_tptabela IN craptab.tptabela%TYPE
                   ,pr_cdempres IN craptab.cdempres%TYPE
                   ,pr_cdacesso IN craptab.cdacesso%TYPE
                   ,pr_tpregist IN craptab.tpregist%TYPE) IS
    SELECT tab.dstextab
          ,tab.tpregist
          ,tab.ROWID
      FROM craptab tab
     WHERE tab.cdcooper = pr_cdcooper
           AND UPPER(tab.nmsistem) = pr_nmsistem
           AND UPPER(tab.tptabela) = pr_tptabela
           AND tab.cdempres = pr_cdempres
           AND UPPER(tab.cdacesso) = pr_cdacesso
           AND tab.tpregist = pr_tpregist;
  rw_craptab cr_craptab%ROWTYPE;
    
                                   
    /*Variaveis*/
    vr_dscritic VARCHAR2(4000);
    vr_cdcritic INTEGER;
    vr_exc_erro EXCEPTION;
    
    BEGIN
      vr_dscritic := '';
      vr_cdcritic := 0;
      
      OPEN cr_craptab(pr_cdcooper => 3
                     ,pr_nmsistem => 'CRED'
                     ,pr_tptabela => 'USUARI'
                     ,pr_cdempres => 11
                     ,pr_cdacesso => 'PAREMPCTL'
                     ,pr_tpregist => 1);
      FETCH cr_craptab
       INTO rw_craptab;
      
      
      IF cr_craptab%NOTFOUND THEN
        CLOSE cr_craptab;
        vr_cdcritic := 55;
        vr_dscritic := '';
        RAISE vr_exc_erro;
      END IF;
      CLOSE cr_craptab;
      
      IF pr_qtparepr > SUBSTR(rw_craptab.dstextab, 8,3) THEN
        vr_dscritic := 'Produto nao permitido para emprestimos de longo prazo';
        vr_cdcritic := 0;
        RAISE vr_exc_erro;
      END IF;
      
      OPEN cr_craplcr(pr_cdcooper => pr_cdcooper
                     ,pr_cdlcremp => pr_cdlcremp);
      FETCH cr_craplcr
       INTO rw_craplcr;
      
      
      IF cr_craplcr%NOTFOUND THEN
        CLOSE cr_craplcr;
        vr_cdcritic := 817;
        vr_dscritic := '';
        RAISE vr_exc_erro;
      END IF;
      CLOSE cr_craplcr;
      
      IF rw_craplcr.tpdescto = 2 THEN
        vr_dscritic := 'Linha nao permitida para esse produto.';
        vr_cdcritic := 0;
        RAISE vr_exc_erro;
      END IF;
      
      IF (rw_craplcr.dslcremp LIKE('%CDC%')) OR
         (rw_craplcr.dslcremp LIKE('%CREDITO DIRETO AO COOPERADO%'))  THEN
        vr_dscritic := 'Linha nao permitida para esse produto.';
        vr_cdcritic := 0;
        RAISE vr_exc_erro;
      END IF;
      
      IF pr_flgpagto THEN
        vr_dscritic := 'Tipo de debito folha bloqueado para todas as operacoes';
        vr_cdcritic := 0;
        RAISE vr_exc_erro;
      END IF;  

      pr_des_reto := 'OK';
      
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_cdcritic:= vr_cdcritic;
        pr_des_erro:= vr_dscritic;
        pr_des_reto := 'NOK';
        
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => pr_cdcritic
                             ,pr_dscritic => pr_des_erro
                             ,pr_tab_erro => pr_tab_erro);
        
      WHEN OTHERS THEN
        pr_des_reto := 'NOK';
        pr_cdcritic := nvl(vr_cdcritic, 0);
        pr_des_erro := 'Erro na rotina valida novo cálculo. ' ||
                       sqlerrm;     
    END pc_valida_novo_calculo;
    
  PROCEDURE pc_valida_calculo_prog(pr_cdcooper IN crapcop.cdcooper%TYPE
                                  ,pr_cdagenci IN crapage.cdagenci%TYPE
                                  ,pr_nrdcaixa IN INTEGER
                                  ,pr_qtparepr IN INTEGER
                                  ,pr_cdlcremp IN INTEGER
                                  ,pr_flgpagto IN INTEGER
                                  ,pr_cdcritic OUT crapcri.cdcritic%TYPE      --> Código da crítica tratada
                                  ,pr_des_erro OUT VARCHAR2                   --> Descrição de critica tratada
                                  ,pr_des_reto OUT VARCHAR) IS                --> Retorno da execução
  /* -------------------------------------------------------------------------------------------------------------

    Programa: pc_valida_calculo_prog      
    Autor   : Douglas Pagel / AMcom 
    Data    : 01/07/2019               ultima Atualizacao: -- 
     
    Dados referentes ao programa:
   
    Objetivo  : Rotina para validar linha e parcelas da simulação pelo PROGRESS
   
    Alteracoes: 

  ..............................................................................*/
  /*Variaveis*/
  vr_tab_erro gene0001.typ_tab_erro;
  
  BEGIN
    EMPR0018.pc_valida_novo_calculo( pr_cdcooper => pr_cdcooper 
                                    ,pr_cdagenci => pr_cdagenci
                                    ,pr_nrdcaixa => pr_nrdcaixa
                                    ,pr_qtparepr => pr_qtparepr
                                    ,pr_cdlcremp => pr_cdlcremp
                                    ,pr_flgpagto => CASE pr_flgpagto WHEN 1 THEN TRUE ELSE FALSE END
                                    ,pr_cdcritic => pr_cdcritic
                                    ,pr_des_erro => pr_des_erro
                                    ,pr_des_reto => pr_des_reto
                                    ,pr_tab_erro => vr_tab_erro);
  EXCEPTION
    WHEN OTHERS THEN
        pr_des_reto := 'NOK';
        pr_cdcritic := nvl(vr_cdcritic, 0);
        pr_des_erro := 'Erro na rotina pc_valida_calculo_prog. ' ||
                       sqlerrm;         
  END pc_valida_calculo_prog; 
   
   PROCEDURE pc_valida_gravacao_simulacao(pr_cdcooper IN crapcop.cdcooper%TYPE
                                    	    ,pr_cdagenci IN crapage.cdagenci%TYPE
                                          ,pr_nrdcaixa IN INTEGER
	                                        ,pr_cdoperad IN VARCHAR2
                                          ,pr_nrdconta IN INTEGER
                                          ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE
                                          ,pr_vlemprst IN NUMBER
                                          ,pr_qtparepr IN INTEGER
                                          ,pr_cdlcremp IN INTEGER
                                          ,pr_dtlibera IN DATE
                                          ,pr_dtdpagto IN DATE
                                          ,pr_cddopcao IN VARCHAR
                                          ,pr_nrsimula IN INTEGER
                                          ,pr_cdfinemp IN INTEGER
                                          ,pr_tpemprst IN INTEGER
                                          ,pr_idcarenc IN INTEGER
                                          ,pr_dtcarenc IN DATE
                                          ,pr_cdcritic OUT crapcri.cdcritic%TYPE      --> Código da crítica tratada
                                          ,pr_des_erro OUT VARCHAR2                   --> Descrição de critica tratada
                                          ,pr_des_reto OUT VARCHAR                    --> Retorno OK / NOK
                                          ,pr_tab_erro OUT gene0001.typ_tab_erro) IS  --> Tabela com possíves erros);
                                          
  /* -------------------------------------------------------------------------------------------------------------

    Programa: pc_valida_gravacao_simulacao      Antigo: b1wgen0097.p(valida_gravacao_simulacao)
    Autor   : Douglas Pagel / AMcom 
    Data    : 18/12/2018               ultima Atualizacao: -- 
     
    Dados referentes ao programa:
   
    Objetivo  : Rotina para validar os dados informados na simulação
   
    Alteracoes: 

  ..............................................................................*/                                               

    --Cursor para dados da simulação
    CURSOR cr_crapsim(pr_cdcooper IN crapsim.cdcooper%TYPE
                     ,pr_nrdconta IN crapsim.nrdconta%TYPE
                     ,pr_nrsimula IN crapsim.nrsimula%TYPE) IS
      SELECT qtparepr
        FROM crapsim sim
       WHERE sim.cdcooper = pr_cdcooper
         AND sim.nrdconta = pr_nrdconta
         AND sim.nrsimula = pr_nrsimula;
    rw_crapsim cr_crapsim%ROWTYPE;

    --Cursor para associado
    CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE
                     ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
      SELECT ass.inpessoa 
        FROM crapass ass
       WHERE ass.cdcooper = pr_cdcooper
         AND ass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;
    
    --Cursor para Linhas de Crédito
    CURSOR cr_craplcr(pr_cdcooper IN craplcr.cdcooper%TYPE
                     ,pr_cdlcremp IN craplcr.cdlcremp%TYPE) IS
      SELECT lcr.nrfimpre, lcr.nrinipre, lcr.tpprodut, lcr.flgstlcr, lcr.qtcarenc
        FROM craplcr lcr
       WHERE lcr.cdcooper = pr_cdcooper
         AND lcr.cdlcremp = pr_cdlcremp;
    rw_craplcr cr_craplcr%ROWTYPE;
    
    --Cursor para Finalidades
    CURSOR cr_crapfin(pr_cdcooper IN crapfin.cdcooper%TYPE
                     ,pr_cdfinemp IN crapfin.cdfinemp%TYPE) IS
      SELECT fin.flgstfin
        FROM crapfin fin
       WHERE fin.cdcooper = pr_cdcooper
         AND fin.cdfinemp = pr_cdfinemp;
    rw_crapfin cr_crapfin%ROWTYPE;
    
    --Cursor para Linhas de credito habilitadas por finalidade
    CURSOR cr_craplch(pr_cdcooper IN craplch.cdcooper%TYPE
                     ,pr_cdfinemp IN craplch.cdfinemp%TYPE
                     ,pr_cdlcremp IN craplch.cdlcrhab%TYPE) IS
      SELECT lch.cdcooper
        FROM craplch lch
       WHERE lch.cdcooper = pr_cdcooper
         AND lch.cdfinemp = pr_cdfinemp
         AND lch.cdlcrhab = pr_cdlcremp;
    rw_craplch cr_craplch%ROWTYPE;
    
    --Cursor para associado PF titular
    CURSOR cr_crapttl(pr_cdcooper IN crapttl.cdcooper%TYPE
                     ,pr_nrdconta IN crapttl.nrdconta%TYPE) IS
      SELECT ttl.cdempres 
        FROM crapttl ttl
       WHERE ttl.cdcooper = pr_cdcooper
         AND ttl.nrdconta = pr_nrdconta
         AND ttl.idseqttl = 1;
    rw_crapttl cr_crapttl%ROWTYPE;
    
    --Cursor para associado PJ
    CURSOR cr_crapjur(pr_cdcooper IN crapjur.cdcooper%TYPE
                     ,pr_nrdconta IN crapjur.nrdconta%TYPE) IS
      SELECT jur.cdempres 
        FROM crapjur jur
       WHERE jur.cdcooper = pr_cdcooper
         AND jur.nrdconta = pr_nrdconta;
    rw_crapjur cr_crapjur%ROWTYPE;
    
  --Cursor de parametrização
  CURSOR cr_craptab(pr_cdcooper IN craptab.cdcooper%TYPE
                   ,pr_nmsistem IN craptab.nmsistem%TYPE
                   ,pr_tptabela IN craptab.tptabela%TYPE
                   ,pr_cdempres IN craptab.cdempres%TYPE
                   ,pr_cdacesso IN craptab.cdacesso%TYPE
                   ,pr_tpregist IN craptab.tpregist%TYPE) IS
    SELECT tab.dstextab
          ,tab.tpregist
          ,tab.ROWID
      FROM craptab tab
     WHERE tab.cdcooper = pr_cdcooper
           AND UPPER(tab.nmsistem) = pr_nmsistem
           AND UPPER(tab.tptabela) = pr_tptabela
           AND tab.cdempres = pr_cdempres
           AND UPPER(tab.cdacesso) = pr_cdacesso
           AND tab.tpregist = pr_tpregist;
  rw_craptab cr_craptab%ROWTYPE;
    
    /*Variaveis*/
    vr_dscritic VARCHAR2(4000);
    vr_des_reto VARCHAR2(10);
    vr_cdcritic INTEGER;
    vr_exc_erro EXCEPTION;
    vr_aux_cdempres INTEGER;
    vr_aux_qtdiacar INTEGER;
    
    BEGIN
      OPEN cr_crapsim(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta
                     ,pr_nrsimula => pr_nrsimula);
      FETCH cr_crapsim
       INTO rw_crapsim;
      
      IF (pr_cddopcao = 'A') AND 
         (cr_crapsim%NOTFOUND) THEN
        CLOSE cr_crapsim;
        vr_dscritic := 'Simulacao nao encontrada com a chave informada';
        vr_cdcritic := 0;
        RAISE vr_exc_erro;  
      END IF;
      CLOSE cr_crapsim;
      
      OPEN cr_crapass(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta);
      FETCH cr_crapass
       INTO rw_crapass;
       
      IF cr_crapass%NOTFOUND THEN
        CLOSE cr_crapass;
        vr_dscritic := '';
        vr_cdcritic := 251;
        RAISE vr_exc_erro;  
      END IF;
      CLOSE cr_crapass;
      
      IF pr_vlemprst <= 0 THEN
        vr_dscritic := 'Valor simulado para o emprestimo nao informado.';
        vr_cdcritic := 0;
        RAISE vr_exc_erro;       
      END IF;

      IF pr_qtparepr <= 0 THEN
        vr_dscritic := 'Quantidade de parcelas nao informada.';
        vr_cdcritic := 0;
        RAISE vr_exc_erro;       
      END IF;    
      
      IF pr_tpemprst = 1 THEN
        pc_valida_novo_calculo(pr_cdcooper => pr_cdcooper 
                              ,pr_cdagenci => pr_cdagenci
                              ,pr_nrdcaixa => pr_nrdcaixa
                              ,pr_qtparepr => pr_qtparepr
                              ,pr_cdlcremp => pr_cdlcremp
                              ,pr_flgpagto => FALSE
                              ,pr_cdcritic => vr_cdcritic 
                              ,pr_des_erro => vr_dscritic
                              ,pr_des_reto => vr_des_reto
                              ,pr_tab_erro => pr_tab_erro);
                              
        IF vr_des_reto <> 'OK' THEN
          pr_des_reto := 'NOK';
        END IF;  
      ELSIF pr_tpemprst = 2 THEN
        EMPR0011.pc_valida_dados_pos_fixado(pr_cdcooper => pr_cdcooper
                                          , pr_dtmvtolt => pr_dtmvtolt 
                                          , pr_cdlcremp => pr_cdlcremp
                                          , pr_vlemprst => pr_vlemprst
                                          , pr_qtparepr => pr_qtparepr
                                          , pr_dtlibera => pr_dtlibera
                                          , pr_dtdpagto => pr_dtdpagto
                                          , pr_dtcarenc => pr_dtcarenc
                                          , pr_flgpagto => 0 
                                          , pr_cdcritic => vr_cdcritic
                                          , pr_dscritic => vr_dscritic);
      
        IF vr_cdcritic <> 0 or trim(vr_dscritic) is not null THEN
          RAISE vr_exc_erro;
        END IF;
      END IF;   
      
      OPEN cr_craplcr(pr_cdcooper => pr_cdcooper
                     ,pr_cdlcremp => pr_cdlcremp);
      FETCH cr_craplcr
       INTO rw_craplcr;
       
      IF cr_craplcr%NOTFOUND THEN
        CLOSE cr_craplcr;
        vr_dscritic := 'Linha nao permitida para esse produto.';
        vr_cdcritic := 0;
        RAISE vr_exc_erro; 
      END IF;
      CLOSE cr_craplcr;
      
      IF rw_craplcr.flgstlcr = 0 THEN
        vr_dscritic := 'Linha de credito nao liberada.';
        vr_cdcritic := 0;
        RAISE vr_exc_erro;   
      END IF;  
      
      --Não permitido para produto TR
      IF rw_craplcr.tpprodut = 0 THEN
        vr_dscritic := 'Linha nao permitida para esse produto';
        vr_cdcritic := 0;
        RAISE vr_exc_erro;  
      END IF;
      
      OPEN cr_crapfin(pr_cdcooper => pr_cdcooper
                     ,pr_cdfinemp => pr_cdfinemp);
      FETCH cr_crapfin
       INTO rw_crapfin;
       
      IF cr_crapfin%NOTFOUND THEN
        CLOSE cr_crapfin;
        vr_dscritic := '';
        vr_cdcritic := 362;
        RAISE vr_exc_erro;   
      END IF;
      CLOSE cr_crapfin;
      
      IF rw_crapfin.flgstfin = 0 THEN
        vr_dscritic := '';
        vr_cdcritic := 469;
        RAISE vr_exc_erro;
      END IF;
      
      OPEN cr_craplch(pr_cdcooper => pr_cdcooper
                     ,pr_cdfinemp => pr_cdfinemp
                     ,pr_cdlcremp => pr_cdlcremp);
      FETCH cr_craplch
       INTO rw_craplch;
       
      IF cr_craplch%NOTFOUND THEN
        CLOSE cr_craplch;
        vr_dscritic := '';
        vr_cdcritic := 364;
        RAISE vr_exc_erro;   
      END IF;
      CLOSE cr_craplch;
      
      IF (pr_qtparepr < rw_craplcr.nrinipre) OR 
         (pr_qtparepr > rw_craplcr.nrfimpre) THEN
        vr_dscritic := 'Quantidade de parcelas acima do permitido para linha de credito.';
        vr_cdcritic := 0;
        RAISE vr_exc_erro;       
      END IF; 
      
      --Validacao da data de liberacao que agora fica obrigatoria - Portabilidade 
      IF pr_dtlibera IS NULL then
        vr_dscritic := 'Informe a data de liberacao';
        vr_cdcritic := 0;
        RAISE vr_exc_erro;  
      END IF;
      
      IF pr_dtlibera < trunc(pr_dtmvtolt) THEN
        vr_dscritic := 'Data de movimento nao pode ser maior que a data de liberacao.';
        vr_cdcritic := 0;
        RAISE vr_exc_erro;  
      END IF;    
      
      IF pr_dtlibera >= pr_dtdpagto THEN
        vr_dscritic := 'Data de liberacao de emprestimo igual ou maior que data de pagamento da primeira parcela.';
        vr_cdcritic := 0;
        RAISE vr_exc_erro;  
      END IF;   
      
      IF pr_dtlibera <> GENE0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper
                                                   ,pr_dtmvtolt => pr_dtlibera) THEN
        vr_dscritic := 'Data de liberação deve ser um dia útil.';
        vr_cdcritic := 0;
        RAISE vr_exc_erro;
      END IF; 
                                                   
      IF pr_dtdpagto < pr_dtmvtolt THEN
        vr_dscritic := 'Data de pagamento da primeira parcela deve ser maior ou igual a data atual.';
        vr_cdcritic := 0;
        RAISE vr_exc_erro;  
      END IF;
      
      IF (pr_tpemprst = 1 or pr_tpemprst = 2) AND
         (TO_CHAR(pr_dtdpagto, 'DD') > 27) THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Data de pagamento nao pode ser maior ou igual ao dia 28';
        RAISE vr_exc_erro;
      END IF;
      
      OPEN cr_craptab(pr_cdcooper => pr_cdcooper
                     ,pr_nmsistem => 'CRED'
                     ,pr_tptabela => 'USUARI'
                     ,pr_cdempres => 11
                     ,pr_cdacesso => 'PAREMPREST'
                     ,pr_tpregist => 01);
      FETCH cr_craptab
       INTO rw_craptab;
       
      IF cr_craptab%NOTFOUND THEN
        CLOSE cr_craptab;
        vr_dscritic := '';
        vr_cdcritic := 55;
        RAISE vr_exc_erro;   
      END IF;
      CLOSE cr_craptab;
      
      IF pr_dtlibera > pr_dtmvtolt + SUBSTR(rw_craptab.dstextab, 35,4) THEN
        vr_dscritic := 'Data de liberacao nao deve ser superior ao prazo maximo de dias parametrizados.';
        vr_cdcritic := 0;
        RAISE vr_exc_erro;   
      END IF;
      
      IF rw_crapass.inpessoa = 1 THEN
        OPEN cr_crapttl(pr_cdcooper => pr_cdcooper
                       ,pr_nrdconta => pr_nrdconta);  
        FETCH cr_crapttl
         INTO rw_crapttl;
         
        IF cr_crapttl%NOTFOUND THEN
          CLOSE cr_crapttl;
          vr_dscritic := '';
          vr_cdcritic := 821;
          RAISE vr_exc_erro;  
        END IF;  
        CLOSE cr_crapttl;
         
         vr_aux_cdempres := rw_crapttl.cdempres;      
      ELSE
        OPEN cr_crapjur(pr_cdcooper => pr_cdcooper
                       ,pr_nrdconta => pr_nrdconta);
        FETCH cr_crapjur
         INTO rw_crapjur;
        
        IF cr_crapjur%NOTFOUND THEN
          CLOSE cr_crapjur;
          vr_dscritic := '';
          vr_cdcritic := 821;
          RAISE vr_exc_erro;  
        END IF;  
          CLOSE cr_crapjur; 
          vr_aux_cdempres := rw_crapjur.cdempres;             
      END IF;
      
      vr_aux_qtdiacar := rw_craplcr.qtcarenc;
      
      IF vr_aux_qtdiacar <> 0 THEN
        IF (pr_dtdpagto - pr_dtlibera) > vr_aux_qtdiacar THEN
          vr_dscritic := 'Carencia da linha deve ser ate ' || TRIM(vr_aux_qtdiacar) || ' dias.';
          vr_cdcritic := 0;
          RAISE vr_exc_erro;    
        END IF;
      ELSE
        /* Temporariamente solicitado para ficar 60 dias
           Foi mantido o IF e ELSE pois será reavaliado
           pelo negócio essa carência e será alterado
           posteriormente */ 
        IF TO_CHAR(pr_dtlibera,'DD') <= 19 THEN
          IF (pr_dtdpagto - pr_dtlibera) > 60 THEN
            vr_dscritic := 'Carencia da linha deve ser ate 60 dias.';
            vr_cdcritic := 0;
            RAISE vr_exc_erro; 
          END IF;
        ELSE
          IF (pr_dtdpagto - pr_dtlibera) > 60 THEN
            vr_dscritic := 'Carencia da linha deve ser ate 60 dias.';
            vr_cdcritic := 0;
            RAISE vr_exc_erro; 
          END IF;  
        END IF; 
      END IF;

      pr_des_reto := 'OK';
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_cdcritic:= vr_cdcritic;
        pr_des_erro:= vr_dscritic;
        pr_des_reto := 'NOK';
        
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => pr_cdcritic
                             ,pr_dscritic => pr_des_erro
                             ,pr_tab_erro => pr_tab_erro);
        
      WHEN OTHERS THEN
        pr_des_reto := 'NOK';
        pr_cdcritic := nvl(vr_cdcritic, 0);
        pr_des_erro := 'Erro na rotina valida a simulação. ' ||
                       sqlerrm;    
    END pc_valida_gravacao_simulacao;
    
   PROCEDURE pc_grava_simulacao( pr_cdcooper IN crapcop.cdcooper%TYPE
                                ,pr_cdagenci IN crapage.cdagenci%TYPE
                                ,pr_nrdcaixa IN INTEGER
	                              ,pr_cdoperad IN VARCHAR2 
                                ,pr_nmdatela IN VARCHAR2
                                ,pr_cdorigem IN INTEGER
                                ,pr_nrdconta IN crapass.nrdconta%TYPE
                                ,pr_idseqttl IN INTEGER
                                ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE
                                ,pr_flgerlog IN BOOLEAN    
                                ,pr_cddopcao IN VARCHAR
                                ,pr_nrsimula IN INTEGER 
                                ,pr_cdlcremp IN INTEGER  
                                ,pr_vlemprst IN NUMBER
                                ,pr_qtparepr IN INTEGER 
                                ,pr_dtlibera IN DATE
                                ,pr_dtdpagto IN DATE
                                ,pr_percetop IN NUMBER
                                ,pr_cdfinemp IN INTEGER
                                ,pr_idfiniof IN INTEGER
                                ,pr_nrgravad OUT INTEGER
                                ,pr_txcetano OUT NUMBER
                                ,pr_cdcritic OUT crapcri.cdcritic%TYPE      --> Código da crítica tratada
                                ,pr_des_erro OUT VARCHAR2                   --> Descrição de critica tratada
                                ,pr_des_reto OUT VARCHAR                    --> Retorno OK / NOK
                                ,pr_tab_erro OUT gene0001.typ_tab_erro      --> Tabela com possíves erros  
                                ,pr_retorno  OUT typ_reg_crapsim
                                ,pr_flggrava IN NUMBER DEFAULT 1 
                                ,pr_idpessoa IN INTEGER
                                ,pr_nrseq_email IN tbcadast_pessoa_email.nrseq_email%TYPE
                                ,pr_nrseq_telefone IN tbcadast_pessoa_telefone.nrseq_telefone%TYPE                                
                                ,pr_idsegmento tbepr_segmento.idsegmento%TYPE
                                ,pr_tpemprst IN INTEGER
                                ,pr_idcarenc IN INTEGER
                                ,pr_dtcarenc IN DATE ) IS
 /* -------------------------------------------------------------------------------------------------------------

    Programa: pc_grava_simulacao      Antigo: b1wgen0097.p(grava_simulacao)
    Autor   : Douglas Pagel / AMcom 
    Data    : 18/12/2018               ultima Atualizacao: -- 
     
    Dados referentes ao programa:
   
    Objetivo  : Rotina para gravar e alterar uma simulação
   
    Alteracoes: 

  ..............................................................................*/  
                                  
    --CURSORES
    --Cursor para associado
    CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE
                     ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
      SELECT ass.inpessoa 
        FROM crapass ass
       WHERE ass.cdcooper = pr_cdcooper
         AND ass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;
    
    --Cursor para Finalidades
    CURSOR cr_crapfin(pr_cdcooper IN crapfin.cdcooper%TYPE
                     ,pr_cdfinemp IN crapfin.cdfinemp%TYPE) IS
      SELECT fin.tpfinali
        FROM crapfin fin
       WHERE fin.cdcooper = pr_cdcooper
         AND fin.cdfinemp = pr_cdfinemp;
    rw_crapfin cr_crapfin%ROWTYPE;
    
    --Cursor buscar numero da próxima simulação
    CURSOR cr_crapsimMax(pr_cdcooper IN crapsim.cdcooper%TYPE
                     ,pr_nrdconta IN crapsim.nrdconta%TYPE) IS
      SELECT MAX(nrsimula) nrsimula
        FROM crapsim sim
       WHERE sim.cdcooper = pr_cdcooper
         AND sim.nrdconta = pr_nrdconta;
    rw_crapsimMax cr_crapsimMax%ROWTYPE;
    
    --Cursor para Linhas de Crédito
    CURSOR cr_craplcr(pr_cdcooper IN craplcr.cdcooper%TYPE
                     ,pr_cdlcremp IN craplcr.cdlcremp%TYPE) IS
      SELECT lcr.tpctrato, lcr.txmensal
        FROM craplcr lcr
       WHERE lcr.cdcooper = pr_cdcooper
         AND lcr.cdlcremp = pr_cdlcremp;
    rw_craplcr cr_craplcr%ROWTYPE;
    
    --Cursor para dados da simulação
    CURSOR cr_crapsim(pr_cdcooper IN crapsim.cdcooper%TYPE
                     ,pr_nrdconta IN crapsim.nrdconta%TYPE
                     ,pr_nrsimula IN crapsim.nrsimula%TYPE) IS
      SELECT cdlcremp, vlemprst, qtparepr, dtlibera, dtdpagto, idsegmento
        FROM crapsim sim
       WHERE sim.cdcooper = pr_cdcooper
         AND sim.nrdconta = pr_nrdconta
         AND sim.nrsimula = pr_nrsimula;
    rw_crapsim cr_crapsim%ROWTYPE;
    
    --Variaveis
    vr_contador INTEGER;
    vr_nrsimula INTEGER;
    vr_cdlcremp INTEGER;
    vr_vlemprst NUMBER;
    vr_qtparepr INTEGER;
    vr_dtlibera DATE;
    vr_dtdpagto DATE;
    vr_txcetano NUMBER;
    vr_valorcet NUMBER;
    vr_txcetmes NUMBER;
    vr_dscatbem VARCHAR2(4000);
    vr_nrparepr INTEGER;
    vr_vlpreclc NUMBER;
    vr_valoriof NUMBER;
    vr_vliofpri NUMBER;
    vr_vliofadi NUMBER;
    vr_flgimune INTEGER;
    vr_idsegmento INTEGER;
    
    
    vr_qtdiacar INTEGER;
    vr_vlajuepr NUMBER;
    vr_txdiaria NUMBER;
    vr_txmensal NUMBER;
    
    vr_qtdias_carenc INTEGER;
    vr_vlprecar NUMBER;
    vr_vlpreemp NUMBER;
    vr_dtvencto DATE;
        
    
    vr_tparcepr typ_tab_parc_epr;
    vr_tab_parc_pos empr0011.typ_tab_parcelas;
    
    vr_rowparcepr INTEGER;
    vr_vllibera NUMBER;
    
    
    vr_vlrtarif NUMBER;
    
    vr_dscritic VARCHAR2(4000);
    vr_cdcritic INTEGER;
    vr_aux_log_rowid ROWID;
    
    vr_exc_erro EXCEPTION;
    vr_exc_saida EXCEPTION;
    
    vr_dstransa VARCHAR2(50);
    vr_dsorigem VARCHAR2(40);
    vr_des_reto VARCHAR2(10);
    vr_dt_validade DATE;
    
    idx INTEGER;
    
    vr_data_base DATE;
    
    FUNCTION fn_data_validade RETURN DATE IS
    --
    CURSOR cr_data_validade IS
      SELECT vr_data_base + nvl(seg.qtdias_validade,0) AS dt_validade
        FROM tbepr_segmento seg
       WHERE seg.idsegmento = pr_idsegmento
         AND seg.cdcooper = pr_cdcooper;
    --
    rw_data_validade cr_data_validade%ROWTYPE;                          
    --
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;
    
    BEGIN
    
      OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
       FETCH btch0001.cr_crapdat INTO rw_crapdat;
      CLOSE btch0001.cr_crapdat;
    
      vr_data_base := rw_crapdat.dtmvtolt;
      --
      OPEN cr_data_validade;
      FETCH cr_data_validade INTO  rw_data_validade;
      CLOSE cr_data_validade;
      --
      RETURN rw_data_validade.dt_validade;
      --
    END fn_data_validade;


    BEGIN
    
    pr_retorno := NULL;
    
      --Busca o associado
      OPEN cr_crapass(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta);
      FETCH cr_crapass
       INTO rw_crapass;
      CLOSE cr_crapass;
      
      --valida o cadastro/alteracao de simulacao de portabilidade para PJ
      IF (pr_cddopcao = 'A') OR (pr_cddopcao = 'I') THEN
        OPEN cr_crapfin(pr_cdcooper => pr_cdcooper
                     ,pr_cdfinemp => pr_cdfinemp);
        FETCH cr_crapfin
         INTO rw_crapfin;    
        
        IF cr_crapfin%FOUND THEN
          IF (rw_crapass.inpessoa = 2) and (rw_crapfin.tpfinali = 2) THEN
            CLOSE cr_crapfin;
            vr_cdcritic := 0;
            vr_dscritic := 'Operação não permitida para conta PJ';
            RAISE vr_exc_erro;  
          END IF;
        END IF; 
      END IF;
      CLOSE cr_crapfin;
      
      IF pr_cddopcao = 'I' THEN
        OPEN cr_crapsimMax(pr_cdcooper => pr_cdcooper
                          ,pr_nrdconta => pr_nrdconta);
        FETCH cr_crapsimMax
         INTO rw_crapsimMax;
         
        IF NVL(rw_crapsimMax.Nrsimula,0) < 1 THEN --cr_crapsimMax%NOTFOUND THEN
          vr_nrsimula := 1;
        ELSE
          vr_nrsimula := rw_crapsimMax.nrsimula + 1;
        END IF; 
        CLOSE cr_crapsimMax;
        
      ELSE
        vr_nrsimula := pr_nrsimula;                    
      END IF;
      
      IF pr_flgerlog THEN
        vr_dsorigem := gene0001.vr_vet_des_origens(pr_cdorigem);
        IF pr_cddopcao = 'I' THEN
          vr_dstransa := 'Incluir simulacao de emprestimo ' || vr_nrsimula;
        ELSE
          vr_dstransa := 'Alterar simulacao de emprestimo ' || vr_nrsimula;
        END IF;
      END IF;

      pc_valida_gravacao_simulacao(pr_cdcooper => pr_cdcooper
                                  ,pr_cdagenci => pr_cdagenci
                                  ,pr_nrdcaixa => pr_nrdcaixa
                                  ,pr_cdoperad => pr_cdoperad
                                  ,pr_nrdconta => pr_nrdconta
                                  ,pr_dtmvtolt => pr_dtmvtolt
                                  ,pr_vlemprst => pr_vlemprst
                                  ,pr_qtparepr => pr_qtparepr
                                  ,pr_cdlcremp => pr_cdlcremp
                                  ,pr_dtlibera => pr_dtlibera
                                  ,pr_dtdpagto => pr_dtdpagto
                                  ,pr_cddopcao => pr_cddopcao
                                  ,pr_nrsimula => pr_nrsimula
                                  ,pr_cdfinemp => pr_cdfinemp
                                  ,pr_tpemprst => pr_tpemprst
                                  ,pr_idcarenc => pr_idcarenc
                                  ,pr_dtcarenc => pr_dtcarenc
                                  ,pr_cdcritic => vr_cdcritic
                                  ,pr_des_erro => vr_dscritic
                                  ,pr_des_reto => vr_des_reto 
                                  ,pr_tab_erro => pr_tab_erro);
                                  
      IF vr_des_reto = 'NOK' THEN
        RAISE vr_exc_saida;
      END IF;
      
      -- Busca dados da Linha
      OPEN cr_craplcr(pr_cdcooper => pr_cdcooper
                     ,pr_cdlcremp => pr_cdlcremp);
      FETCH cr_craplcr
       INTO rw_craplcr;
      
      IF cr_craplcr%NOTFOUND THEN
        CLOSE cr_craplcr;
        pr_cdcritic := 363;
        pr_des_reto := 'NOK';  
        RAISE vr_exc_erro; 
      ELSE
        CLOSE cr_craplcr;
      END IF;
    
      -- Criar um bem fixo para simular o cálculo do IOF de acordo com a alienação
      IF rw_craplcr.tpctrato = 2 THEN
        vr_dscatbem := 'AUTOMOVEL';
      ELSIF rw_craplcr.tpctrato = 3 THEN
        vr_dscatbem := 'CASA';
      ELSE
        vr_dscatbem := '';
      END IF;

      pc_consulta_tarifa_emprst(pr_cdcooper => pr_cdcooper
                               ,pr_cdlcremp => pr_cdlcremp
                               ,pr_vlemprst => pr_vlemprst
                               ,pr_nrdconta => pr_nrdconta
                               ,pr_nrctremp => 0 
                               ,pr_dscatbem => vr_dscatbem 
                               ,pr_vlrtarif => vr_vlrtarif
                               ,pr_cdcritic => vr_cdcritic
                               ,pr_des_erro => vr_dscritic
                               ,pr_des_reto => vr_des_reto
                               ,pr_tab_erro => pr_tab_erro);
                               
      IF vr_des_reto = 'NOK' THEN
        RAISE vr_exc_saida;
      END IF; 
      
      IF pr_tpemprst = 1 THEN
        pc_calcula_emprestimo(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_cdoperad => pr_cdoperad
                             ,pr_nmdatela => pr_nmdatela
                             ,pr_cdorigem => pr_cdorigem
                             ,pr_nrdconta => pr_nrdconta
                             ,pr_idseqttl => pr_idseqttl
                             ,pr_flgerlog => pr_flgerlog
                             ,pr_nrctremp => 0
                             ,pr_cdlcremp => pr_cdlcremp
                             ,pr_cdfinemp => pr_cdfinemp
                             ,pr_vlemprst => pr_vlemprst
                             ,pr_qtparepr => pr_qtparepr
                             ,pr_dtmvtolt => pr_dtmvtolt
                             ,pr_dtdpagto => pr_dtdpagto
                             ,pr_flggrava => FALSE
                             ,pr_dtlibera => pr_dtlibera
                             ,pr_idfiniof => pr_idfiniof
                             ,pr_qtdiacar => vr_qtdiacar 
                             ,pr_vlajuepr => vr_vlajuepr 
                             ,pr_txdiaria => vr_txdiaria 
                             ,pr_txmensal => vr_txmensal 
                             ,pr_tparcepr => vr_tparcepr 
                             ,pr_cdcritic => vr_cdcritic 
                             ,pr_des_erro => vr_dscritic
                             ,pr_des_reto => vr_des_reto
                             ,pr_tab_erro => pr_tab_erro);      

        IF vr_des_reto = 'NOK' THEN
          RAISE vr_exc_erro;
        END IF;
      
      ELSE --POS
        IF pr_tpemprst = 2 THEN
          vr_txmensal := rw_craplcr.txmensal;
           
          IF pr_idcarenc > 0 THEN

            EMPR0011.pc_busca_qtd_dias_carencia(pr_idcarencia => pr_idcarenc
                                               , pr_qtddias => vr_qtdias_carenc
                                               , pr_cdcritic => vr_cdcritic
                                               , pr_dscritic => vr_dscritic);
                                               
            IF vr_cdcritic <> 0 or NOT ( TRIM(vr_dscritic) IS NULL) THEN
              RAISE vr_exc_erro;
            END IF;             
                                  
          END IF;
           
          vr_vlemprst := pr_vlemprst;
          vr_vllibera := pr_vlemprst;
          
          IF pr_idfiniof = 0 THEN
             vr_vllibera := nvl(vr_vllibera,0) - nvl(vr_vlrtarif,0);
					ELSE
						 vr_vlemprst := nvl(vr_vlemprst,0) + nvl(vr_vlrtarif,0);
           END IF;
           
          -- Calcular o IOF da operação

          TIOF0001.pc_calcula_iof_epr(pr_cdcooper => pr_cdcooper                      
                                    , pr_nrdconta => pr_nrdconta                      
                                    , pr_nrctremp => 0                                
                                    , pr_dtmvtolt => pr_dtmvtolt                      
                                    , pr_inpessoa => rw_crapass.inpessoa              
                                    , pr_cdlcremp => pr_cdlcremp                      
                                    , pr_cdfinemp => pr_cdfinemp                      
                                    , pr_qtpreemp => pr_qtparepr                      
                                    , pr_vlpreemp => 0                                
                                    , pr_vlemprst => pr_vlemprst                      
                                    , pr_dtdpagto => pr_dtdpagto                      
                                    , pr_dtlibera => pr_dtlibera                      
                                    , pr_tpemprst => pr_tpemprst                      
                                    , pr_dtcarenc => pr_dtcarenc                      
                                    , pr_qtdias_carencia => vr_qtdias_carenc          
                                    , pr_dscatbem => vr_dscatbem                      
                                    , pr_idfiniof => pr_idfiniof                      
                                    , pr_dsctrliq => NULL                             
                                    , pr_idgravar => 'N'                              
                                    , pr_vlpreclc => vr_vlpreclc                      
                                    , pr_valoriof => vr_valoriof                      
                                    , pr_vliofpri => vr_vliofpri                      
                                    , pr_vliofadi => vr_vliofadi                      
                                    , pr_flgimune => vr_flgimune                      
                                    , pr_dscritic => vr_dscritic); 
                                    
          IF NOT ( TRIM(vr_dscritic) IS NULL) THEN
            RAISE vr_exc_saida;  
          END IF;                                                       
        
          IF pr_idfiniof = 0 THEN
             vr_vllibera := nvl(vr_vllibera,0) - nvl(vr_valoriof,0);
					ELSE
						 vr_vlemprst := nvl(vr_vlemprst,0) + nvl(vr_valoriof,0);
           END IF; 
           
           --Parcelas

           EMPR0011.pc_calcula_parcelas_pos_fixado(pr_cdcooper => pr_cdcooper
                                                 , pr_flgbatch => false
                                                 , pr_dtcalcul => pr_dtlibera
                                                 , pr_cdlcremp => pr_cdlcremp
                                                 , pr_dtcarenc => pr_dtcarenc
                                                 , pr_qtdias_carencia => vr_qtdias_carenc
                                                 , pr_dtdpagto => pr_dtdpagto
                                                 , pr_qtpreemp => pr_qtparepr
                                                 , pr_vlemprst => vr_vlemprst
                                                 , pr_tab_parcelas => vr_tab_parc_pos
                                                 , pr_cdcritic => vr_cdcritic
                                                 , pr_dscritic => vr_dscritic);  
                                                 
          IF (vr_cdcritic <> 0) or (NOT ( TRIM(vr_dscritic) IS NULL)) THEN
            RAISE vr_exc_erro;
          END IF; 
          
          vr_vlprecar := 0;
          vr_vlpreemp := 0;
           

          --Alimenta parametro tabela de prestações  
          FOR idx IN 1..vr_tab_parc_pos.count
          LOOP
            vr_tparcepr(idx).cdcooper := pr_cdcooper;   
            vr_tparcepr(idx).nrdconta := pr_nrdconta;
            vr_tparcepr(idx).nrparepr := vr_tab_parc_pos(idx).nrparepr; 
            vr_tparcepr(idx).vlparepr := vr_tab_parc_pos(idx).vlparepr;
            vr_tparcepr(idx).dtvencto := vr_tab_parc_pos(idx).dtvencto; 
            vr_tparcepr(idx).dtparepr := vr_tab_parc_pos(idx).dtvencto; 
            
            IF vr_tparcepr(idx).dtvencto >= pr_dtcarenc AND vr_vlprecar = 0 THEN
              vr_vlprecar := vr_tparcepr(idx).vlparepr;
            END IF;
            
            IF vr_tparcepr(idx).dtvencto >= pr_dtdpagto AND vr_vlpreemp = 0 THEN
              vr_vlpreemp := vr_tparcepr(idx).vlparepr;
            END IF;
          END LOOP;  
        END IF;
      END IF;
      
      IF pr_tpemprst = 1 THEN
        -- Calcular o IOF da operação
        TIOF0001.pc_calcula_iof_epr(pr_cdcooper => pr_cdcooper
                                  , pr_nrdconta => pr_nrdconta
                                  , pr_nrctremp => 0
                                  , pr_dtmvtolt => pr_dtmvtolt
                                  , pr_inpessoa => rw_crapass.inpessoa
                                  , pr_cdlcremp => pr_cdlcremp
                                  , pr_cdfinemp => pr_cdfinemp
                                  , pr_qtpreemp => pr_qtparepr
                                  , pr_vlpreemp => CASE WHEN vr_tparcepr.COUNT > 0 THEN vr_tparcepr(1).vlparepr ELSE 0 END   
                                  , pr_vlemprst => pr_vlemprst 
                                  , pr_dtdpagto => pr_dtdpagto
                                  , pr_dtlibera => pr_dtlibera
                                  , pr_tpemprst => 1
                                  , pr_dtcarenc => NULL
                                  , pr_qtdias_carencia => 0 
                                  , pr_dscatbem => vr_dscatbem
                                  , pr_idfiniof => pr_idfiniof 
                                  , pr_dsctrliq => NULL 
                                  , pr_idgravar => 'N'
                                  , pr_vlpreclc => vr_vlpreclc 
                                  , pr_valoriof => vr_valoriof
                                  , pr_vliofpri => vr_vliofpri
                                  , pr_vliofadi => vr_vliofadi
                                  , pr_flgimune => vr_flgimune
                                  , pr_dscritic => vr_dscritic);
        
        -- Financia IOF e Tarifa
        IF pr_idfiniof = 1 THEN
          -- Atualizar valor da Parcela conforme calculo do IOF
          FOR vr_rowparcepr IN 1 .. pr_qtparepr LOOP
            vr_tparcepr(vr_rowparcepr).vlparepr := vr_vlpreclc;
            vr_vlpreemp := vr_vlpreclc;   
          END LOOP;
          
          IF NOT ( TRIM(vr_dscritic) IS NULL) THEN
            RAISE vr_exc_saida;  
          END IF;

          vr_vllibera := pr_vlemprst;
        ELSE
          vr_vllibera := pr_vlemprst - vr_vlrtarif - vr_valoriof;
          vr_vlpreemp := vr_tparcepr(1).vlparepr; 
        END IF;
        
      END IF;

      --> Apenas calcular CET se irá gravar
      IF  pr_flggrava > 0 THEN
        ccet0001.pc_calculo_cet_emprestimos(pr_cdcooper => pr_cdcooper
                                          , pr_dtmvtolt => pr_dtmvtolt
                                          , pr_nrdconta => pr_nrdconta
                                          , pr_cdprogra => pr_cdorigem
                                          , pr_inpessoa => rw_crapass.inpessoa
                                          , pr_cdusolcr => 2
                                          , pr_cdlcremp => pr_cdlcremp
                                          , pr_tpemprst => pr_tpemprst
                                          , pr_nrctremp => 0
                                          , pr_dtlibera => pr_dtlibera
                                          , pr_vlemprst => pr_vlemprst
                                          , pr_txmensal => vr_txmensal
                                          , pr_vlpreemp => vr_vlpreemp
                                          , pr_qtpreemp => pr_qtparepr
                                          , pr_dtdpagto => pr_dtdpagto
                                          , pr_cdfinemp => pr_cdfinemp
                                          , pr_dscatbem => vr_dscatbem
                                          , pr_idfiniof => pr_idfiniof
                                          , pr_dsctrliq => ''
                                          , pr_idgravar => 'N' 
																				, pr_dtcarenc => CASE WHEN pr_idcarenc > 0 THEN pr_dtcarenc ELSE null END
                                          , pr_txcetano => vr_txcetano
                                          , pr_txcetmes => vr_txcetmes
                                          , pr_cdcritic => vr_cdcritic
                                          , pr_dscritic => vr_dscritic);
                                        
        IF NOT ( TRIM(vr_dscritic) IS NULL) THEN
          RAISE vr_exc_saida;  
        END IF;                                        
     
        pr_txcetano := ROUND(vr_txcetano, 2);
        
        vr_dt_validade := fn_data_validade();
      END IF;
     
    IF  pr_flggrava > 0 THEN
      IF pr_cddopcao = 'I' THEN
        BEGIN
         
          INSERT 
            INTO crapsim
              (crapsim.cdcooper  
              ,crapsim.nrdconta
              ,crapsim.nrsimula) 
          VALUES 
              (pr_cdcooper
              ,pr_nrdconta
              ,vr_nrsimula);
              
        EXCEPTION
          WHEN OTHERS THEN
            pr_des_reto := 'NOK';
            pr_cdcritic := nvl(vr_cdcritic, 0);
            pr_des_erro := 'Erro na rotina que grava a simulação. ' ||
                           sqlerrm;   
        END;  
      ELSE
        OPEN cr_crapsim(pr_cdcooper => pr_cdcooper
                       ,pr_nrdconta => pr_nrdconta
                       ,pr_nrsimula => vr_nrsimula);
        FETCH cr_crapsim
         INTO rw_crapsim;
        
        IF cr_crapsim%NOTFOUND THEN
          CLOSE cr_crapsim;
          vr_cdcritic := 0;
          vr_dscritic := 'Registro de simulacao nao encontrado.';
          RAISE vr_exc_erro;
        
        ELSE
          -- Controle para log de alterações
          vr_cdlcremp := rw_crapsim.cdlcremp;  
          vr_vlemprst := rw_crapsim.vlemprst;
          vr_qtparepr := rw_crapsim.qtparepr;
          vr_dtlibera := rw_crapsim.dtlibera;
          vr_dtdpagto := rw_crapsim.dtdpagto;
          vr_idsegmento := rw_crapsim.idsegmento;
        
        END IF; 
        CLOSE cr_crapsim;
      END IF;
     
      pr_nrgravad := vr_nrsimula;
  
      BEGIN

        UPDATE crapsim
           SET crapsim.cdlcremp = pr_cdlcremp
              ,crapsim.vlemprst = pr_vlemprst
              ,crapsim.qtparepr = pr_qtparepr
              ,crapsim.vlparepr = vr_vlpreemp
              ,crapsim.dtmvtolt = pr_dtmvtolt
              ,crapsim.dtdpagto = pr_dtdpagto
              ,crapsim.dtlibera = pr_dtlibera
              ,crapsim.txmensal = vr_txmensal
              ,crapsim.txdiaria = vr_txdiaria
              ,crapsim.vliofepr = vr_valoriof
              ,crapsim.vlrtarif = vr_vlrtarif
              ,crapsim.vllibera = vr_vllibera
              ,crapsim.hrtransa = TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
              ,crapsim.percetop = vr_txcetano
              ,crapsim.cdoperad = pr_cdoperad
              ,crapsim.vlajuepr = vr_vlajuepr
              ,crapsim.cdfinemp = pr_cdfinemp
              ,crapsim.idfiniof = pr_idfiniof
              ,crapsim.dtvalidade = vr_dt_validade
              ,crapsim.nrseq_email = pr_nrseq_email
              ,crapsim.nrseq_telefone = pr_nrseq_telefone
              ,crapsim.idpessoa = pr_idpessoa
              ,crapsim.idsegmento = pr_idsegmento
              ,crapsim.cdorigem = pr_cdorigem
              ,crapsim.tpemprst = pr_tpemprst
              ,crapsim.idcarenc = pr_idcarenc
              ,crapsim.vlprecar = vr_vlprecar
              ,crapsim.dtcarenc = pr_dtcarenc
         WHERE crapsim.cdcooper = pr_cdcooper
           AND crapsim.nrdconta = pr_nrdconta
           AND crapsim.nrsimula = vr_nrsimula;

      EXCEPTION
        WHEN OTHERS THEN
          pr_cdcritic := 0;
          pr_des_erro := 'Erro ao inserir dados na simulação';
          pr_des_reto := 'NOK';
          
          gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                               ,pr_cdagenci => pr_cdagenci
                               ,pr_nrdcaixa => pr_nrdcaixa
                               ,pr_nrsequen => 1 --> Fixo
                               ,pr_cdcritic => pr_cdcritic
                               ,pr_dscritic => pr_des_erro
                               ,pr_tab_erro => pr_tab_erro);
      END;
      
     END IF; 

      pr_retorno.cdlcremp := pr_cdlcremp;
      pr_retorno.vlemprst := pr_vlemprst;
      pr_retorno.qtparepr := pr_qtparepr;
      pr_retorno.vlparepr := vr_vlpreclc;
      pr_retorno.dtmvtolt := pr_dtmvtolt;
      pr_retorno.dtdpagto := pr_dtdpagto;
      pr_retorno.dtlibera := pr_dtlibera;
      pr_retorno.txmensal := vr_txmensal;
      pr_retorno.txdiaria := vr_txdiaria;
      pr_retorno.vliofepr := vr_valoriof;
      pr_retorno.vlrtarif := vr_vlrtarif;
      pr_retorno.vllibera := vr_vllibera;
      pr_retorno.hrtransa := TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'));
      pr_retorno.percetop := vr_txcetano;
      pr_retorno.cdoperad := pr_cdoperad;
      pr_retorno.vlajuepr := vr_vlajuepr;
      pr_retorno.cdfinemp := pr_cdfinemp;
      pr_retorno.idfiniof := pr_idfiniof;
      pr_retorno.cdcooper := pr_cdcooper;
      pr_retorno.nrdconta := pr_nrdconta;
      pr_retorno.nrsimula := vr_nrsimula;
      pr_retorno.dtvalidade := vr_dt_validade;
      pr_retorno.nrseq_email := pr_nrseq_email;
      pr_retorno.nrseq_telefone := pr_nrseq_telefone;
      pr_retorno.idsegmento := pr_idsegmento;
      pr_retorno.tpemprst := pr_tpemprst;
      pr_retorno.idcarenc := pr_idcarenc;
      pr_retorno.dtcarenc := pr_dtcarenc;
      
      IF  pr_flggrava > 0 THEN
      --Se for alteração limpa a tabela de parcelas simulacao
      IF pr_cddopcao = 'A' THEN

        TELA_ATENDA_SIMULACAO.pc_remove_simulacao_parcela(pr_cdcooper => pr_cdcooper
                                                        , pr_nrdconta => pr_nrdconta
                                                        , pr_nrsimula => pr_nrgravad
                                                        , pr_cdcritic => vr_cdcritic
                                                        , pr_dscritic => vr_dscritic);
                                                        
        IF vr_cdcritic <> 0 or NOT ( TRIM(vr_dscritic) IS NULL) THEN
          RAISE vr_exc_erro;
        END IF;
      END IF;

      --Grava as parcelas da simulação

      FOR idx IN 1..vr_tparcepr.count
        LOOP
          vr_dtvencto := vr_tparcepr(idx).dtvencto;            
          
          tela_atenda_simulacao.pc_grava_simulacao_parcela(pr_cdcooper => vr_tparcepr(idx).cdcooper
                                                         , pr_nrdconta => vr_tparcepr(idx).nrdconta
                                                         , pr_nrsimula => pr_nrgravad
                                                         , pr_nrparepr => vr_tparcepr(idx).nrparepr
                                                         , pr_vlparepr => vr_tparcepr(idx).vlparepr
                                                         , pr_dtvencto => vr_dtvencto
                                                         , pr_cdcritic => vr_cdcritic
                                                         , pr_dscritic => vr_dscritic);

          IF ( (vr_cdcritic <> 0) or (NOT ( TRIM(vr_dscritic) IS NULL)) ) THEN
             RAISE vr_exc_erro;
          END IF; 
           
        END LOOP;    
      
      IF pr_flgerlog THEN
        GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper 
                           , pr_cdoperad => pr_cdoperad
                           , pr_dscritic => NULL
                           , pr_dsorigem => vr_dsorigem
                           , pr_dstransa => vr_dstransa
                           , pr_dttransa => TRUNC(SYSDATE)
                           , pr_flgtrans => 1 
                           , pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE, 'SSSSS'))
                           , pr_idseqttl => pr_idseqttl
                           , pr_nmdatela => pr_nmdatela
                           , pr_nrdconta => pr_nrdconta
                           , pr_nrdrowid => vr_aux_log_rowid); 
                           
        IF pr_cddopcao = 'A' THEN
          IF vr_cdlcremp <> pr_cdlcremp THEN
            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_aux_log_rowid
                                 ,pr_nmdcampo => 'cdlcremp'
                                 ,pr_dsdadant => vr_cdlcremp
                                 ,pr_dsdadatu => pr_cdlcremp);
          END IF;
          
          IF vr_vlemprst <> pr_vlemprst THEN
            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_aux_log_rowid
                                 ,pr_nmdcampo => 'vlemprst'
                                 ,pr_dsdadant => vr_vlemprst
                                 ,pr_dsdadatu => pr_vlemprst);
          END IF;
          
          IF vr_qtparepr <> pr_qtparepr THEN
            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_aux_log_rowid
                                 ,pr_nmdcampo => 'qtparepr'
                                 ,pr_dsdadant => vr_qtparepr
                                 ,pr_dsdadatu => pr_qtparepr);
          END IF;
          
          IF vr_dtlibera <> pr_dtlibera THEN
            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_aux_log_rowid
                                 ,pr_nmdcampo => 'dtmvtolt'
                                 ,pr_dsdadant => vr_dtlibera
                                 ,pr_dsdadatu => pr_dtlibera);
          END IF;
          
          IF vr_dtdpagto <> pr_dtdpagto THEN
            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_aux_log_rowid
                                 ,pr_nmdcampo => 'dtdpagto'
                                 ,pr_dsdadant => vr_dtdpagto
                                 ,pr_dsdadatu => pr_dtdpagto);
                                 
          END IF;
          
          IF vr_idsegmento <> pr_idsegmento THEN
            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_aux_log_rowid
                                 ,pr_nmdcampo => 'idsegmento'
                                 ,pr_dsdadant => vr_idsegmento
                                 ,pr_dsdadatu => pr_idsegmento);
          END IF;                                 
          
          
        ELSIF pr_cddopcao = 'I' THEN
          --Gera log dos daods da simulação
          GENE0001.pc_gera_log_item(pr_nrdrowid => vr_aux_log_rowid
                                 ,pr_nmdcampo => 'Simulacao'
                                 ,pr_dsdadant => ''
                                 ,pr_dsdadatu => pr_nrgravad); 
          
          GENE0001.pc_gera_log_item(pr_nrdrowid => vr_aux_log_rowid
                                 ,pr_nmdcampo => 'Linha'
                                 ,pr_dsdadant => ''
                                 ,pr_dsdadatu => pr_cdlcremp); 
                                 
          GENE0001.pc_gera_log_item(pr_nrdrowid => vr_aux_log_rowid
                                 ,pr_nmdcampo => 'Finalidade'
                                 ,pr_dsdadant => ''
                                 ,pr_dsdadatu => pr_cdfinemp);                                  
                                 
          GENE0001.pc_gera_log_item(pr_nrdrowid => vr_aux_log_rowid
                                 ,pr_nmdcampo => 'Valor Solicitado'
                                 ,pr_dsdadant => ''
                                 ,pr_dsdadatu => pr_vlemprst);     
                                 
          GENE0001.pc_gera_log_item(pr_nrdrowid => vr_aux_log_rowid
                                 ,pr_nmdcampo => 'Valor Emprestado'
                                 ,pr_dsdadant => ''
                                 ,pr_dsdadatu => CASE WHEN pr_idfiniof = 0 THEN pr_vlemprst ELSE pr_vlemprst + vr_valoriof + vr_vlrtarif END);                                   
                                 
          GENE0001.pc_gera_log_item(pr_nrdrowid => vr_aux_log_rowid
                                 ,pr_nmdcampo => 'Parcelas'
                                 ,pr_dsdadant => ''
                                 ,pr_dsdadatu => pr_qtparepr);                                                  

          GENE0001.pc_gera_log_item(pr_nrdrowid => vr_aux_log_rowid
                                 ,pr_nmdcampo => 'Valor Parcelas'
                                 ,pr_dsdadant => ''
                                 ,pr_dsdadatu => vr_vlpreemp);                                                  

          GENE0001.pc_gera_log_item(pr_nrdrowid => vr_aux_log_rowid
                                 ,pr_nmdcampo => 'Liberacao'
                                 ,pr_dsdadant => ''
                                 ,pr_dsdadatu => pr_dtlibera);    
                                 
          GENE0001.pc_gera_log_item(pr_nrdrowid => vr_aux_log_rowid
                                 ,pr_nmdcampo => 'Pagamento'
                                 ,pr_dsdadant => ''
                                 ,pr_dsdadatu => pr_dtdpagto);   
                                 
          GENE0001.pc_gera_log_item(pr_nrdrowid => vr_aux_log_rowid
                                 ,pr_nmdcampo => 'Financia IOF'
                                 ,pr_dsdadant => ''
                                 ,pr_dsdadatu => CASE WHEN pr_idfiniof = 0 THEN 'NAO' ELSE 'SIM' END);                                   
                                 
          GENE0001.pc_gera_log_item(pr_nrdrowid => vr_aux_log_rowid
                                 ,pr_nmdcampo => 'Tipo Emprestimo'
                                 ,pr_dsdadant => ''
                                 ,pr_dsdadatu => pr_tpemprst);  
                                 
          GENE0001.pc_gera_log_item(pr_nrdrowid => vr_aux_log_rowid
                                 ,pr_nmdcampo => 'Segmento'
                                 ,pr_dsdadant => ''
                                 ,pr_dsdadatu => pr_idsegmento);   
                                 
          GENE0001.pc_gera_log_item(pr_nrdrowid => vr_aux_log_rowid
                                 ,pr_nmdcampo => 'Carencia'
                                 ,pr_dsdadant => ''
                                 ,pr_dsdadatu => pr_idcarenc); 
                                 
          GENE0001.pc_gera_log_item(pr_nrdrowid => vr_aux_log_rowid
                                 ,pr_nmdcampo => 'Data Carencia'
                                 ,pr_dsdadant => ''
                                 ,pr_dsdadatu => pr_dtcarenc);                                                                                                                                 
                                                                                                                                                     
          GENE0001.pc_gera_log_item(pr_nrdrowid => vr_aux_log_rowid
                                 ,pr_nmdcampo => 'IDPessoa'
                                 ,pr_dsdadant => ''
                                 ,pr_dsdadatu => pr_idpessoa); 
                                 
          GENE0001.pc_gera_log_item(pr_nrdrowid => vr_aux_log_rowid
                                 ,pr_nmdcampo => 'Email'
                                 ,pr_dsdadant => ''
                                 ,pr_dsdadatu => fn_retorna_email(pr_cdcooper, pr_idpessoa, pr_nrseq_email));                                   
                                 
          GENE0001.pc_gera_log_item(pr_nrdrowid => vr_aux_log_rowid
                                 ,pr_nmdcampo => 'Telefone'
                                 ,pr_dsdadant => ''
                                 ,pr_dsdadatu => fn_retorna_telefone(pr_cdcooper, pr_idpessoa, pr_nrseq_telefone));                                 
                                 
        END IF; 
      END IF;
      end if;
      pr_des_reto := 'OK'; 

    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_cdcritic:= vr_cdcritic;
        pr_des_erro:= vr_dscritic;
        pr_des_reto := 'NOK';
        
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => pr_cdcritic
                             ,pr_dscritic => pr_des_erro
                             ,pr_tab_erro => pr_tab_erro);
                             
      WHEN vr_exc_saida THEN
        pr_cdcritic:= vr_cdcritic;
        pr_des_erro:= vr_dscritic;
        pr_des_reto := 'NOK';  
        
      WHEN OTHERS THEN
        pr_des_reto := 'NOK';
        pr_cdcritic := nvl(vr_cdcritic, 0);
        pr_des_erro := 'Erro na rotina grava a simulação: ' ||
                       sqlerrm;   
    END pc_grava_simulacao;
    
   PROCEDURE pc_calcula_emprestimo(pr_cdcooper IN crapcop.cdcooper%TYPE
                                ,pr_cdagenci IN crapage.cdagenci%TYPE
                                ,pr_nrdcaixa IN INTEGER
	                              ,pr_cdoperad IN VARCHAR2 
                                ,pr_nmdatela IN VARCHAR2
                                ,pr_cdorigem IN INTEGER
                                ,pr_nrdconta IN crapass.nrdconta%TYPE
                                ,pr_idseqttl IN INTEGER   
                                ,pr_flgerlog IN BOOLEAN 
                                ,pr_nrctremp IN INTEGER  
                                ,pr_cdlcremp IN INTEGER 
                                ,pr_cdfinemp IN INTEGER 
                                ,pr_vlemprst IN NUMBER
                                ,pr_qtparepr IN INTEGER 
                                ,pr_dtmvtolt IN DATE
                                ,pr_dtdpagto IN DATE
                                ,pr_flggrava In BOOLEAN
                                ,pr_dtlibera IN DATE
                                ,pr_idfiniof IN INTEGER
                                ,pr_qtdiacar OUT INTEGER
                                ,pr_vlajuepr OUT NUMBER
                                ,pr_txdiaria OUT NUMBER
                                ,pr_txmensal OUT NUMBER
                                ,pr_tparcepr OUT typ_tab_parc_epr
                                ,pr_cdcritic OUT crapcri.cdcritic%TYPE      --> Código da crítica tratada
                                ,pr_des_erro OUT VARCHAR2                   --> Descrição de critica tratada
                                ,pr_des_reto OUT VARCHAR                    --> Retorno OK / NOK
                                ,pr_tab_erro OUT gene0001.typ_tab_erro) IS  --> Tabela com possíves erros 
                                
 /* -------------------------------------------------------------------------------------------------------------

    Programa: pc_calcula_emprestimo      Antigo: b1wgen0084.p(calcula_emprestimo)
    Autor   : Douglas Pagel / AMcom 
    Data    : 18/12/2018               ultima Atualizacao: -- 
     
    Dados referentes ao programa:
   
    Objetivo  : Rotina para calcular valores da simulação
   
    Alteracoes: 

  ..............................................................................*/                                
    
    --Cursores
    --Busca categoria do bem
    CURSOR cr_crapbpr(pr_cdcooper IN crapbpr.cdcooper%TYPE
                     ,pr_nrdconta IN crapbpr.nrdconta%TYPE
                     ,pr_nrctrpro IN crapbpr.nrctrpro%TYPE
                     ,pr_tpctrpro IN crapbpr.tpctrpro%TYPE) IS
      SELECT bpr.dscatbem
        FROM crapbpr bpr
       WHERE bpr.cdcooper = pr_cdcooper
         AND bpr.nrdconta = pr_nrdconta
         AND bpr.nrctrpro = pr_nrctrpro
         AND bpr.tpctrpro = pr_tpctrpro;
    rw_crapbpr cr_crapbpr%ROWTYPE;
    
    --Busca dados do contrato de emprestimo
    CURSOR cr_crawepr(pr_cdcooper IN crawepr.cdcooper%TYPE
                     ,pr_nrdconta IN crawepr.nrdconta%TYPE
                     ,pr_nrctremp IN crawepr.nrctremp%TYPE) IS
      SELECT wpr.nrctrliq##1 || ',' ||
             wpr.nrctrliq##2 || ',' ||
             wpr.nrctrliq##3 || ',' ||
             wpr.nrctrliq##4 || ',' ||
             wpr.nrctrliq##5 || ',' ||
             wpr.nrctrliq##6 || ',' ||
             wpr.nrctrliq##7 || ',' ||
             wpr.nrctrliq##8 || ',' ||
             wpr.nrctrliq##9 || ',' ||
             wpr.nrctrliq##10 dsctrliq,
             wpr.tpemprst
        FROM crawepr wpr
       WHERE wpr.cdcooper = pr_cdcooper
         AND wpr.nrdconta = pr_nrdconta
         AND wpr.nrctremp = pr_nrctremp;
    rw_crawepr cr_crawepr%ROWTYPE;
    
    --Cursor para Linhas de Crédito
    CURSOR cr_craplcr(pr_cdcooper IN craplcr.cdcooper%TYPE
                     ,pr_cdlcremp IN craplcr.cdlcremp%TYPE) IS
      SELECT lcr.txmensal, lcr.cdmodali, lcr.cdsubmod
        FROM craplcr lcr
       WHERE lcr.cdcooper = pr_cdcooper
         AND lcr.cdlcremp = pr_cdlcremp;
    rw_craplcr cr_craplcr%ROWTYPE;
    
    --Cursor para associado
    CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE
                     ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
      SELECT ass.inpessoa 
        FROM crapass ass
       WHERE ass.cdcooper = pr_cdcooper
         AND ass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;
    
    --Variaveis
    vr_dstransa VARCHAR2(60);
    vr_dsorigem VARCHAR2(40);
    vr_des_reto VARCHAR2(10);
    vr_dscritic VARCHAR2(4000);
    vr_cdcritic INTEGER;
    
    vr_exc_erro EXCEPTION;
    vr_exc_saida EXCEPTION;
    vr_aux_log_rowid ROWID;
    
    vr_aux_dscatbem VARCHAR2(25);
    vr_aux_dsctrliq VARCHAR2(150);
    vr_diapagto INTEGER;
    vr_mespagto INTEGER;
    vr_anopagto INTEGER;
    
    vr_vlexpone NUMBER(18,10);
    vr_vlparepr NUMBER;
    
    vr_vlpreclc NUMBER;
    vr_valoriof NUMBER;
    vr_vliofpri NUMBER;
    vr_vliofadi NUMBER;
    vr_flgimune INTEGER;
    
    vr_tt_datas_parcelas typ_tab_datas_parcelas;
    
    vr_aux_nrparce INTEGER;

    
    BEGIN
      IF pr_flgerlog THEN
        vr_dsorigem := gene0001.vr_vet_des_origens(pr_cdorigem);
        vr_dstransa := 'Realizar o calculo do valor das parcelas do EMPRESTIMO';                           
      END IF;
      
      FOR rw_crapbpr IN cr_crapbpr(pr_cdcooper => pr_cdcooper
                                  ,pr_nrdconta => pr_nrdconta
                                  ,pr_nrctrpro => pr_nrctremp
                                  ,pr_tpctrpro => 90) LOOP
        vr_aux_dscatbem := vr_aux_dscatbem || '|' || rw_crapbpr.dscatbem;
      END LOOP;
        
      OPEN cr_crawepr(pr_cdcooper => pr_cdcooper 
                     ,pr_nrdconta => pr_nrdconta 
                     ,pr_nrctremp => pr_nrctremp);
      FETCH cr_crawepr
       INTO rw_crawepr;
      
      IF cr_crawepr%FOUND THEN
        IF rw_crawepr.tpemprst <> 1 THEN
          CLOSE cr_crawepr;
          vr_cdcritic := 946;
          vr_dscritic := '';
          RAISE vr_exc_saida;
        END IF;
          vr_aux_dsctrliq := rw_crawepr.dsctrliq;     
        -- CLOSE cr_crawepr;
      END IF;
      CLOSE cr_crawepr;
       
      OPEN cr_craplcr(pr_cdcooper => pr_cdcooper
                     ,pr_cdlcremp => pr_cdlcremp);
      FETCH cr_craplcr 
       INTO rw_craplcr;
        
      IF cr_craplcr%NOTFOUND THEN
        CLOSE cr_craplcr;
        vr_cdcritic := 363;
        vr_dscritic := '';
        RAISE vr_exc_saida;   
      END IF;
      
      vr_diapagto := TO_CHAR(pr_dtdpagto,'DD');
      vr_mespagto := TO_CHAR(pr_dtdpagto,'MM');
      vr_anopagto := TO_CHAR(pr_dtdpagto,'YYYY');
      
      empr0001.pc_calc_dias360(pr_ehmensal => FALSE 
                              ,pr_dtdpagto => TO_CHAR(pr_dtdpagto,'DD')
                              ,pr_diarefju => TO_CHAR(pr_dtlibera,'DD')
                              ,pr_mesrefju => TO_CHAR(pr_dtlibera,'MM')
                              ,pr_anorefju => TO_CHAR(pr_dtlibera,'YYYY')
                              ,pr_diafinal => vr_diapagto
                              ,pr_mesfinal => vr_mespagto
                              ,pr_anofinal => vr_anopagto
                              ,pr_qtdedias => pr_qtdiacar);
      
      -- considera calendario comercial                         
      pr_txmensal := rw_craplcr.txmensal;
      -- Calculo da Taxa Diaria definida pela Karina*/
      vr_vlexpone := POWER((pr_txmensal / 100) + 1 , (1 / 30));
      pr_txdiaria := ROUND( (100 * (POWER ((pr_txmensal / 100) + 1 , (1 / 30)) - 1)), 8);

      -- Valor presente com ajuste da carencia 
      pr_vlajuepr := pr_vlemprst * POWER( (1 + (pr_txdiaria / 100 )), pr_qtdiacar - 30);

      -- Valor da Prestacao
      vr_vlparepr := (pr_vlajuepr * rw_craplcr.txmensal / 100) / (1 - POWER ( (1 + rw_craplcr.txmensal / 100) , ( -1 * pr_qtparepr ) ) );

      IF pr_idfiniof > 0 THEN
        OPEN cr_crapass(pr_cdcooper => pr_cdcooper
                       ,pr_nrdconta => pr_nrdconta);
        FETCH cr_crapass
         INTO rw_crapass;
        CLOSE cr_crapass;
       
        TIOF0001.pc_calcula_iof_epr(pr_cdcooper => pr_cdcooper
                                   ,pr_nrdconta => pr_nrdconta
                                   ,pr_nrctremp => pr_nrctremp
                                   ,pr_dtmvtolt => pr_dtmvtolt
                                   ,pr_inpessoa => rw_crapass.inpessoa
                                   ,pr_cdlcremp => pr_cdlcremp
                                   ,pr_cdfinemp => pr_cdfinemp
                                   ,pr_qtpreemp => pr_qtparepr
                                   ,pr_vlpreemp => vr_vlparepr 
                                   ,pr_vlemprst => pr_vlemprst
                                   ,pr_dtdpagto => pr_dtdpagto
                                   ,pr_dtlibera => pr_dtlibera
                                   ,pr_tpemprst => 1 
                                   ,pr_dtcarenc => pr_dtmvtolt
                                   ,pr_qtdias_carencia => 0
                                   ,pr_dscatbem => vr_aux_dscatbem
                                   ,pr_idfiniof => pr_idfiniof
                                   ,pr_dsctrliq => vr_aux_dsctrliq 
                                   ,pr_idgravar => 'N'
                                   ,pr_vlpreclc => vr_vlpreclc 
                                   ,pr_valoriof => vr_valoriof
                                   ,pr_vliofpri => vr_vliofpri
                                   ,pr_vliofadi => vr_vliofadi
                                   ,pr_flgimune => vr_flgimune
                                   ,pr_dscritic => vr_dscritic);
                                   
        IF vr_vlpreclc > 0 THEN
          vr_vlparepr := vr_vlpreclc;   
        END IF;  
      ELSE
        -- considera calendario comercial                         
        pr_txmensal := rw_craplcr.txmensal; 
        
        -- Calculo da Taxa Diaria definida pela Karina*/
        vr_vlexpone := POWER((pr_txmensal / 100) + 1 , (1 / 30));
        pr_txdiaria := ROUND( (100 * (POWER ((pr_txmensal / 100) + 1 , (1 / 30)) - 1)), 8);

        -- Valor presente com ajuste da carencia 
        pr_vlajuepr := pr_vlemprst * POWER( (1 + (pr_txdiaria / 100 )), pr_qtdiacar - 30);

        -- Valor da Prestacao
        vr_vlparepr := (pr_vlajuepr * rw_craplcr.txmensal / 100) / (1 - POWER ( (1 + rw_craplcr.txmensal / 100) , ( -1 * pr_qtparepr ) ) );
      END IF;
      
      pc_calcula_data_parcela_sim(pr_cdcooper => pr_cdcooper 
                                 ,pr_dtvencto => pr_dtdpagto
                                 ,pr_nrparcel => pr_qtparepr
                                 ,pr_ttvencto => vr_tt_datas_parcelas);
        
      FOR vr_aux_nrparce IN 1..pr_qtparepr LOOP
        pr_tparcepr(vr_aux_nrparce).cdcooper := pr_cdcooper;   
        pr_tparcepr(vr_aux_nrparce).nrdconta := pr_nrdconta;
        pr_tparcepr(vr_aux_nrparce).nrparepr := vr_aux_nrparce; 
        pr_tparcepr(vr_aux_nrparce).vlparepr := vr_vlparepr; 
        pr_tparcepr(vr_aux_nrparce).dtparepr := vr_tt_datas_parcelas(vr_aux_nrparce).dtparepr; 
      END LOOP; 
    
      IF pr_flggrava THEN
        pc_gera_parcelas_emprestimo(pr_cdcooper => pr_cdcooper
                                   ,pr_cdagenci => pr_cdagenci
                                   ,pr_nrdcaixa => pr_nrdcaixa
                                   ,pr_cdoperad => pr_cdoperad
                                   ,pr_nmdatela => pr_nmdatela
                                   ,pr_cdorigem => pr_cdorigem
                                   ,pr_nrdconta => pr_nrdconta
                                   ,pr_idseqttl => pr_idseqttl
                                   ,pr_dtmvtolt => pr_dtmvtolt
                                   ,pr_flgerlog => pr_flgerlog
                                   ,pr_nrctremp => pr_nrctremp
                                   ,pr_tparcepr => pr_tparcepr
                                   ,pr_cdcritic => vr_cdcritic
                                   ,pr_des_erro => vr_dscritic
                                   ,pr_des_reto => vr_des_reto
                                   ,pr_tab_erro => pr_tab_erro);
                                   
        BEGIN
          IF pr_tparcepr.COUNT > 0 THEN
            
            UPDATE crawepr
               SET crawepr.vlpreemp = pr_tparcepr(1).vlparepr
                  ,crawepr.txdiaria = pr_txdiaria
                  ,crawepr.txmensal = pr_txmensal
             WHERE crawepr.cdcooper = pr_cdcooper
               AND crawepr.nrdconta = pr_nrdconta
               AND crawepr.nrctremp = pr_nrctremp; 

          END IF;   
        EXCEPTION 
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao atualizar a simulação na crawepr.'||sqlerrm;
            RAISE vr_exc_erro;    
        END;
                                             
      END IF;
      IF pr_flgerlog THEN
        GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper 
                           , pr_cdoperad => pr_cdoperad
                           , pr_dscritic => NULL
                           , pr_dsorigem => vr_dsorigem
                           , pr_dstransa => vr_dstransa
                           , pr_dttransa => TRUNC(SYSDATE)
                           , pr_flgtrans => 1 
                           , pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE, 'SSSSS'))
                           , pr_idseqttl => pr_idseqttl
                           , pr_nmdatela => pr_nmdatela
                           , pr_nrdconta => pr_nrdconta
                           , pr_nrdrowid => vr_aux_log_rowid);
      END IF;
      pr_des_reto := 'OK';
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_cdcritic:= vr_cdcritic;
        pr_des_erro:= vr_dscritic;
        pr_des_reto := 'NOK';
        
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => pr_cdcritic
                             ,pr_dscritic => pr_des_erro
                             ,pr_tab_erro => pr_tab_erro);
                             
        IF pr_flgerlog THEN
        GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper 
                           , pr_cdoperad => pr_cdoperad
                           , pr_dscritic => NULL
                           , pr_dsorigem => vr_dsorigem
                           , pr_dstransa => vr_dstransa
                           , pr_dttransa => TRUNC(SYSDATE)
                           , pr_flgtrans => 1 
                           , pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE, 'SSSSS'))
                           , pr_idseqttl => pr_idseqttl
                           , pr_nmdatela => pr_nmdatela
                           , pr_nrdconta => pr_nrdconta
                           , pr_nrdrowid => vr_aux_log_rowid);
        END IF;
          
                             
      WHEN vr_exc_saida THEN
        pr_cdcritic:= vr_cdcritic;
        pr_des_erro:= vr_dscritic;
        pr_des_reto := 'NOK';  
        
      WHEN OTHERS THEN
        pr_des_reto := 'NOK';
        pr_cdcritic := nvl(vr_cdcritic, 0);
        pr_des_erro := 'Erro na rotina grava a simulação. ' ||sqlerrm;
      
    END pc_calcula_emprestimo; 
    
   PROCEDURE pc_calcula_emprestimo_prog(pr_cdcooper IN crapcop.cdcooper%TYPE
                                       ,pr_cdagenci IN crapage.cdagenci%TYPE
                                       ,pr_nrdcaixa IN INTEGER
                                       ,pr_cdoperad IN VARCHAR2 
                                       ,pr_nmdatela IN VARCHAR2
                                       ,pr_cdorigem IN INTEGER
                                       ,pr_nrdconta IN crapass.nrdconta%TYPE
                                       ,pr_idseqttl IN INTEGER   
                                       ,pr_flgerlog IN INTEGER 
                                       ,pr_nrctremp IN INTEGER  
                                       ,pr_cdlcremp IN INTEGER 
                                       ,pr_cdfinemp IN INTEGER 
                                       ,pr_vlemprst IN NUMBER
                                       ,pr_qtparepr IN INTEGER 
                                       ,pr_dtmvtolt IN DATE
                                       ,pr_dtdpagto IN DATE
                                       ,pr_flggrava In INTEGER
                                       ,pr_dtlibera IN DATE
                                       ,pr_idfiniof IN INTEGER
                                       ,pr_qtdiacar OUT INTEGER
                                       ,pr_vlajuepr OUT NUMBER
                                       ,pr_txdiaria OUT NUMBER
                                       ,pr_txmensal OUT NUMBER
                                       ,pr_tparcepr OUT CLOB
                                       ,pr_cdcritic OUT crapcri.cdcritic%TYPE      --> Código da crítica tratada
                                       ,pr_dscritic OUT VARCHAR2                   --> Descrição de critica tratada
                                       ,pr_des_reto OUT VARCHAR) IS                --> Retorno da execução 
  /* -------------------------------------------------------------------------------------------------------------

    Programa: pc_calcula_emprestimo_prog      
    Autor   : Douglas Pagel / AMcom 
    Data    : 01/07/2019               ultima Atualizacao: -- 
     
    Dados referentes ao programa:
   
    Objetivo  : Rotina para calcular valores da simulação pelo PROGRESS
   
    Alteracoes: 

  ..............................................................................*/
  /*Variaveis*/
  vr_tab_erro gene0001.typ_tab_erro; 
  vr_tparcepr typ_tab_parc_epr;
  
  vr_dados_xml CLOB;
  vr_index PLS_INTEGER;
  vr_dstexto  VARCHAR2(32767);
  vr_string   VARCHAR2(32767);
                                       
  BEGIN
    pr_des_reto := 'OK';
    EMPR0018.pc_calcula_emprestimo(pr_cdcooper =>  pr_cdcooper
                                  ,pr_cdagenci =>  pr_cdagenci
                                  ,pr_nrdcaixa =>  pr_nrdcaixa
                                  ,pr_cdoperad =>  pr_cdoperad
                                  ,pr_nmdatela =>  pr_nmdatela
                                  ,pr_cdorigem =>  pr_cdorigem
                                  ,pr_nrdconta =>  pr_nrdconta
                                  ,pr_idseqttl =>  pr_idseqttl
                                  ,pr_flgerlog =>  CASE pr_flgerlog WHEN 1 THEN TRUE ELSE FALSE END
                                  ,pr_nrctremp =>  pr_nrctremp
                                  ,pr_cdlcremp =>  pr_cdlcremp
                                  ,pr_cdfinemp =>  pr_cdfinemp
                                  ,pr_vlemprst =>  pr_vlemprst
                                  ,pr_qtparepr =>  pr_qtparepr
                                  ,pr_dtmvtolt =>  pr_dtmvtolt
                                  ,pr_dtdpagto =>  pr_dtdpagto
                                  ,pr_flggrava =>  CASE pr_flggrava WHEN 1 THEN TRUE ELSE FALSE END
                                  ,pr_dtlibera =>  pr_dtlibera
                                  ,pr_idfiniof =>  pr_idfiniof
                                  ,pr_qtdiacar =>  pr_qtdiacar
                                  ,pr_vlajuepr =>  pr_vlajuepr
                                  ,pr_txdiaria =>  pr_txdiaria
                                  ,pr_txmensal =>  pr_txmensal
                                  ,pr_tparcepr =>  vr_tparcepr
                                  ,pr_cdcritic =>  pr_cdcritic
                                  ,pr_des_erro =>  pr_dscritic
                                  ,pr_des_reto =>  pr_des_reto
                                  ,pr_tab_erro =>  vr_tab_erro); 
                                  
    dbms_lob.createtemporary(pr_tparcepr, TRUE);
    dbms_lob.open(pr_tparcepr, dbms_lob.lob_readwrite);
    
    -- Insere o cabeçalho do XML
    gene0002.pc_escreve_xml(pr_xml            => pr_tparcepr
                           ,pr_texto_completo => vr_dstexto
                           ,pr_texto_novo     => '<root>');
                           
    vr_index := vr_tparcepr.FIRST;
     
    WHILE vr_index IS NOT NULL LOOP      
      vr_string := '<Registro>'||
                        '<cdcooper>'|| vr_tparcepr(vr_index).cdcooper ||'</cdcooper>'||
                        '<nrdconta>'|| vr_tparcepr(vr_index).nrdconta ||'</nrdconta>'||
                        '<nrctremp>'|| NVL(vr_tparcepr(vr_index).nrctremp,0) ||'</nrctremp>'||
                        '<nrparepr>'|| NVL(vr_tparcepr(vr_index).nrparepr,0) ||'</nrparepr>'||
                        '<vlparepr>'|| to_char(NVL(vr_tparcepr(vr_index).vlparepr,0),'fm999g999g990d00','NLS_NUMERIC_CHARACTERS='',.''') ||'</vlparepr>'||
                        '<dtparepr>'|| to_char(vr_tparcepr(vr_index).dtparepr,'DD/MM/RRRR') ||'</dtparepr>'||
                        '<indpagto>'|| vr_tparcepr(vr_index).indpagto ||'</indpagto>'||
                        '<dtvencto>'|| to_char(vr_tparcepr(vr_index).dtvencto,'DD/MM/RRRR') ||'</dtvencto>'||
                    '</Registro>';
                    
      -- Escrever no XML
      gene0002.pc_escreve_xml(pr_xml            => pr_tparcepr
                             ,pr_texto_completo => vr_dstexto
                             ,pr_texto_novo     => vr_string);

      vr_index := vr_tparcepr.next(vr_index);
            
    END LOOP;
    
    -- Encerrar a tag raiz
    gene0002.pc_escreve_xml(pr_xml            => pr_tparcepr
                           ,pr_texto_completo => vr_dstexto
                           ,pr_texto_novo     => '</root>'
                           ,pr_fecha_xml      => TRUE);                                   
  EXCEPTION
    WHEN OTHERS THEN
        pr_des_reto := 'NOK';
        pr_cdcritic := nvl(vr_cdcritic, 0);
        pr_dscritic := 'Erro na rotina pc_calcula_emprestimo_prog. ' ||
                       sqlerrm;  
                                                     
  END pc_calcula_emprestimo_prog;
    
   PROCEDURE pc_gera_parcelas_emprestimo(pr_cdcooper IN crapcop.cdcooper%TYPE
                                         ,pr_cdagenci IN crapage.cdagenci%TYPE
                                         ,pr_nrdcaixa IN INTEGER
                                         ,pr_cdoperad IN VARCHAR2 
                                         ,pr_nmdatela IN VARCHAR2
                                         ,pr_cdorigem IN INTEGER
                                         ,pr_nrdconta IN crapass.nrdconta%TYPE
                                         ,pr_idseqttl IN INTEGER 
                                         ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE
                                         ,pr_flgerlog IN BOOLEAN  
                                         ,pr_nrctremp IN INTEGER  
                                         ,pr_tparcepr IN typ_tab_parc_epr  
                                         ,pr_cdcritic OUT crapcri.cdcritic%TYPE      --> Código da crítica tratada
                                         ,pr_des_erro OUT VARCHAR2                   --> Descrição de critica tratada
                                         ,pr_des_reto OUT VARCHAR                    --> Retorno OK / NOK
                                         ,pr_tab_erro OUT gene0001.typ_tab_erro) IS  --> Tabela com possíves erros                      
                                         
  /* -------------------------------------------------------------------------------------------------------------

    Programa: pc_gera_parcelas_emprestimo      Antigo: b1wgen0084.p(gera_parcelas_emprestimo)
    Autor   : Douglas Pagel / AMcom 
    Data    : 18/12/2018               ultima Atualizacao: -- 
     
    Dados referentes ao programa:
   
    Objetivo  : Rotina para gerar e gravar as parcelas do emprestimo
   
    Alteracoes: 

  ..............................................................................*/  
                                           
      --Variaveis
      vr_dscritic VARCHAR2(4000);
      vr_cdcritic INTEGER;
      vr_exc_erro EXCEPTION;
      vr_aux_log_rowid ROWID;
      vr_aux_dstransa VARCHAR2(50);
      vr_aux_dsorigem VARCHAR2(40);
      
      i INTEGER;                                      
    BEGIN
      IF pr_flgerlog THEN
        vr_aux_dsorigem := gene0001.vr_vet_des_origens(pr_cdorigem);
        vr_aux_dstransa := 'Gerar parcelas de emprestimo.';
      END IF;
      
      BEGIN
        DELETE CRAPPEP pep 
         WHERE pep.cdcooper = pr_cdcooper
           AND pep.nrdconta = pr_nrdconta
           AND pep.nrctremp = pr_nrctremp;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao excluir crappep.'||sqlerrm;
          RAISE vr_exc_erro;
      END;                            
      
      FOR I IN 1 .. pr_tparcepr.COUNT LOOP
        BEGIN
          INSERT INTO crappep(cdcooper
                             ,nrdconta
                             ,nrctremp
                             ,nrparepr
                             ,vlparepr
                             ,vlsdvpar
                             ,vlsdvsji
                             ,dtvencto
                             ,inliquid)
                       VALUES(pr_cdcooper
                             ,pr_nrdconta
                             ,pr_nrctremp
                             ,pr_tparcepr(i).nrparepr
                             ,pr_tparcepr(i).vlparepr
                             ,pr_tparcepr(i).vlparepr
                             ,pr_tparcepr(i).vlparepr
                             ,pr_tparcepr(i).dtvencto
                             ,0);
                             
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao incluir parcela na crappep.'||sqlerrm;
            RAISE vr_exc_erro; 
        END; 
      END LOOP;
      
      IF pr_flgerlog THEN
        GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper 
                           , pr_cdoperad => pr_cdoperad
                           , pr_dscritic => NULL
                           , pr_dsorigem => vr_aux_dsorigem
                           , pr_dstransa => vr_aux_dstransa
                           , pr_dttransa => TRUNC(SYSDATE)
                           , pr_flgtrans => 1 
                           , pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE, 'SSSSS'))
                           , pr_idseqttl => pr_idseqttl
                           , pr_nmdatela => pr_nmdatela
                           , pr_nrdconta => pr_nrdconta
                           , pr_nrdrowid => vr_aux_log_rowid);
                           
        GENE0001.pc_gera_log_item(pr_nrdrowid => vr_aux_log_rowid
                                 ,pr_nmdcampo => 'nrctremp'
                                 ,pr_dsdadant => pr_nrctremp
                                 ,pr_dsdadatu => pr_nrctremp);                           
      END IF;
      

      pr_des_reto := 'OK';  
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_cdcritic:= vr_cdcritic;
        pr_des_erro:= vr_dscritic;
        pr_des_reto := 'NOK';
        
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => pr_cdcritic
                             ,pr_dscritic => pr_des_erro
                             ,pr_tab_erro => pr_tab_erro);

      WHEN OTHERS THEN
        pr_des_reto := 'NOK';
        pr_cdcritic := nvl(vr_cdcritic, 0);
        pr_des_erro := 'Erro na rotina que gera parcelas da simulação. ' ||
                       sqlerrm; 
    END pc_gera_parcelas_emprestimo;                                         

   PROCEDURE pc_imprime_simulacao(pr_cdcooper IN NUMBER, 
                                   pr_cdagenci IN NUMBER,
                                   pr_nrdcaixa IN NUMBER,
                                   pr_cdoperad IN VARCHAR2,
                                   pr_nmdatela IN VARCHAR2,
                                   pr_cdorigem IN NUMBER,
                                   pr_nrdconta IN NUMBER,
                                   pr_idseqttl IN NUMBER,
                                   pr_dtmvtolt IN DATE,
                                   pr_flgerlog BOOLEAN,
                                   pr_nrsimula IN NUMBER,
                                   pr_dsiduser IN VARCHAR2,
                                   pr_tpemprst IN INTEGER,
                                   pr_nmarqimp OUT VARCHAR2,
                                   pr_nmarqpdf OUT VARCHAR2,
                                   pr_tab_erro OUT gene0001.typ_tab_erro,
                                   pr_des_reto  OUT VARCHAR2,
                                   pr_retorno  OUT xmltype ) IS
                                   
/* -------------------------------------------------------------------------------------------------------------

    Programa: pc_imprime_simulacao      Antigo: b1wgen0097.p(imprime_simulacao)
    Autor   : Douglas Pagel / AMcom 
    Data    : 18/12/2018               ultima Atualizacao: 13/06/2019
     
    Dados referentes ao programa:
   
    Objetivo  : Rotina para gerar a impressão da simulação
   
    Alteracoes: 13/06/2019 - Adicionada a informação do CDI junto a taxa mensal quando for Pós Fixado
  -                          SM P298.3 (Darlei / Supero)
  -
  ..............................................................................*/  
                                     
    --
    --
    -- changeset do Jasper
    --
    -- Changeset 30030
    --
    aux_cdcritic   NUMBER;
    aux_dscritic   VARCHAR2(1000);
    vr_nom_direto  VARCHAR2(500);
    vr_retorno_ok  VARCHAR2(3); 
    vr_exc_saida   EXCEPTION;
    vr_retorno     XMLTYPE;
    vr_retorno_xml XMLTYPE;
    --
    vr_dscritic VARCHAR2(4000);
    aux_valor VARCHAR2(200);
    aux_dsorigem VARCHAR2(200);
    aux_dstransa VARCHAR2(200);
    aux_dttransa DATE;
    aux_hrtransa NUMBER(2);
    aux_flgtrans NUMBER(1);
    aux_contador_parc NUMBER;  
    aux_nrdrowid ROWID;
    vr_nmarqimp VARCHAR2(200);
    vr_nmarqpdf VARCHAR2(200);
    aux_string_parc CLOB;
    vr_posicao_aux  NUMBER;
    vr_endline BOOLEAN;
    vr_clob CLOB;
    --
    CURSOR cr_crapcop IS
     SELECT *
       FROM crapcop 
      WHERE cdcooper = pr_cdcooper;
    --      
    rw_crapcop  cr_crapcop%ROWTYPE;
    --
    -- procedure generica para auxiliar na montagem do xml
    PROCEDURE monta_xml(pr_retorno OUT XMLTYPE, pr_dsretorno OUT VARCHAR2) IS
    --
    aux_dtdlibera NUMBER;
    aux_dtmlibera NUMBER;
    aux_dtalibera NUMBER;
      
    aux_carencia  VARCHAR2(50);
    aux_codig     VARCHAR2(10);
    aux_data_parc VARCHAR2(20);
      
    aux_vlrsolic  VARCHAR2(18);
    aux_txmensal  VARCHAR2(30);
    aux_vlparepr  VARCHAR2(18);
    aux_tributos  VARCHAR2(18);
    -- aux_vlajuepr VARCHAR2; varivel sem uso -- AS CHAR        NO-UNDO.
    aux_vlrtarif VARCHAR2(13); 
    aux_vllibera VARCHAR2(18); 
    aux_dsfiniof VARCHAR2(3); 
    aux_percetop VARCHAR2(30); /* P298.6 */ 
    aux_diapagto NUMBER; 
    aux_mespagto NUMBER; 
    aux_anopagto NUMBER; 
    -- Variáveis para Pós Fixado
    aux_dscarenc VARCHAR2(100);
    aux_vlprecar VARCHAR2(18);     
    aux_dtcarenc VARCHAR2(20);
    aux_vlperidx VARCHAR2(20);
    --
    --/ variaveis para montagem do layout das parcelas no jasper
    --
    TYPE c_refcur IS REF CURSOR;
    vr_query CLOB;
    vr_query_1 CLOB;
    vr_query_2 LONG;
    c_dummy c_refcur;
    vr_nrparepr_1 INTEGER;
    vr_vlparepr_1 VARCHAR2(20);
    vr_dtparepr_1 DATE;
    vr_count INTEGER;
    --
    vr_parcela  NUMBER;
    vr_metade   NUMBER;
    vr_total    NUMBER; 
    vr_lado     VARCHAR2(20);
    vr_posicao  NUMBER;
    vr_vlparepr NUMBER(12,2);
    vr_dtparepr DATE;
    --
    --/ fim variaveis para montagem do layout das parcelas no jasper    
    --          
    aux_ehmensal BOOLEAN := FALSE;  
    vr_nok EXCEPTION;  
    --
    vr_tcrapsim  typ_tab_sim; -- typ_tab_sim;
    vr_tparcepr  typ_tab_parc_epr; -- typ_tab_parc_epr;
    vr_contador NUMBER := 0;
    vr_contador_parc NUMBER := 0;
    --    
    CURSOR cr_crapcop IS
       SELECT *
         FROM crapcop 
        WHERE cdcooper = pr_cdcooper; 
    --
    CURSOR cr_craplcr(pr_cdooper craplcr.cdcooper%TYPE, pr_cdlcremp craplcr.cdlcremp%TYPE ) IS
      SELECT * 
        FROM craplcr 
       WHERE cdcooper = pr_cdooper 
         AND cdlcremp = pr_cdlcremp;
    -- 
    CURSOR cr_crapfin(pr_cdcooper crapfin.cdcooper%TYPE, pr_cdfinemp crapfin.cdfinemp%TYPE ) IS
      SELECT * 
        FROM crapfin 
       WHERE cdcooper = pr_cdcooper 
         AND cdfinemp = pr_cdfinemp;
    --    
    rw_crapcop  cr_crapcop%ROWTYPE;
    rw_craplcr  cr_craplcr%ROWTYPE;
    rw_crapfin  cr_crapfin%ROWTYPE;
    vr_tab_erro gene0001.typ_tab_erro;
     
    PROCEDURE insere_tag(pr_xml      IN OUT NOCOPY XMLType  --> XML que receberá a nova TAG
                        ,pr_tag_pai  IN VARCHAR2            --> TAG que receberá a nova TAG
                        ,pr_posicao  IN PLS_INTEGER         --> Posição da tag na lista
                        ,pr_tag_nova IN VARCHAR2            --> String com a nova TAG
                        ,pr_tag_cont IN VARCHAR2            --> Conteúdo da nova TAG
                        ,pr_des_erro OUT VARCHAR2) IS
                           
     vr_domDoc    DBMS_XMLDOM.DOMDocument;      --> Definição do documento DOM (XML)
     vr_elemento  DBMS_XMLDOM.DOMElement;       --> Novo elemento que será adicionado
     vr_novoNodo  DBMS_XMLDOM.DOMNode;          --> Novo nodo baseado no elemento
     vr_paiNodo   DBMS_XMLDOM.DOMNode;          --> Nodo pai
     vr_texto     DBMS_XMLDOM.DOMText;          --> Texto que será incluido

     BEGIN

      -- Cria o documento DOM com base no XML enviado
      vr_domDoc := DBMS_XMLDOM.newDOMDocument(pr_xml);
      -- Criar novo elemento
      vr_elemento := DBMS_XMLDOM.createElement(vr_domDoc, pr_tag_nova);
      -- Criar novo nodo
      vr_novoNodo := DBMS_XMLDOM.makeNode(vr_elemento);
      -- Definir nodo pai
      vr_paiNodo := DBMS_XMLDOM.makeNode(DBMS_XMLDOM.makeElement(DBMS_XMLDOM.item(DBMS_XMLDOM.getElementsByTagName(vr_domDoc, pr_tag_pai), pr_posicao)));
      -- Adiciona novo nodo no nodo pai
      vr_novoNodo := DBMS_XMLDOM.appendChild(vr_paiNodo, vr_novoNodo);
      -- Adiciona o conteúdo ao novo nodo
      vr_texto := DBMS_XMLDOM.createTextNode(vr_domDoc, pr_tag_cont);
      vr_novoNodo := DBMS_XMLDOM.appendChild(vr_novoNodo, DBMS_XMLDOM.makeNode(vr_texto));

      -- Gerar o novo stream XML
      pr_xml := DBMS_XMLDOM.getxmltype(vr_domDoc);
          
      -- Liberar uso de memória
      dbms_xmldom.freeDocument(vr_domDoc);

     EXCEPTION
          WHEN OTHERS THEN
            pr_des_erro := 'Erro pc_insere_tag: ' || SQLERRM;
     END insere_tag;
      
    PROCEDURE monta_subquery_parcelas IS
    --/
    BEGIN
      FOR idx IN vr_tparcepr.FIRST .. vr_tparcepr.COUNT LOOP
        --
        dbms_OUTPUT.put_line('teste loop');
        vr_nrparepr_1 := vr_tparcepr(idx).nrparepr;
        vr_vlparepr_1 := to_char(vr_tparcepr(idx).vlparepr);
        vr_dtparepr_1 := vr_tparcepr(idx).dtparepr;
        vr_query_2    := vr_query_2 || ' SELECT ' || vr_nrparepr_1 ||' AS nrparepr,' 
                                    || 'TO_NUMBER(''' || vr_vlparepr_1 ||''') AS vlparepr,' || '''' 
                                    || vr_dtparepr_1 ||''' AS dtparepr 
                                           FROM DUAL ';
        IF vr_count < vr_tparcepr.count THEN
          vr_query_2 := vr_query_2 || '
               UNION ALL 
               ';
        END IF;
        vr_count := vr_count + 1;
      END LOOP;      
    END monta_subquery_parcelas;
    
    FUNCTION fn_query_parcelas RETURN CLOB IS
    --/
    BEGIN
    vr_query_1 := 'SELECT parcela,
                          metade,
                          total, 
                          LADO,
                          dense_rank() OVER (PARTITION BY lado ORDER BY lado, parcela  ASC) posicao,
                          vlparepr,
                          dtparepr                    
                    FROM( SELECT  parcela,
                                  metade,
                                  total,
                                  CASE WHEN parcela <= metade
                                     THEN
                                       ''DIREITA''
                                  ELSE
                                       ''ESQUERDA''   
                                  END LADO,
                                  vlparepr,
                                  dtparepr                             
                          FROM (  SELECT parcela,
                                         ROUND((COUNT(*) OVER()) /2 ) metade , 
                                         COUNT(*) OVER() total,
                                         vlparepr,
                                         dtparepr
                                    FROM ( SELECT  nrparepr AS parcela
                                                  ,vlparepr 
                                                  ,dtparepr 
                                             FROM ( ' || vr_query_2 || ' )
                                           ORDER BY 1       
                                         )
                                  ORDER BY 1)
                       ORDER BY 1) 
                       ORDER BY 5,1 ASC ';
      RETURN vr_query_1;
    END fn_query_parcelas;
     
    BEGIN  
      --
      pr_dsretorno  := '-';
      --     
      IF pr_dsiduser IS NULL THEN
         aux_cdcritic := 0;
         aux_dscritic := 'Sessao de usuario nao informada. '||
                           'Problema ao gerar arquivos de impressao.';
           --
           gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper,
                                 pr_cdagenci => pr_cdagenci,
                                 pr_nrdcaixa => pr_nrdcaixa,
                                 pr_nrsequen => 1,
                                 pr_cdcritic => aux_cdcritic,
                                 pr_dscritic => aux_dscritic,
                                 pr_tab_erro => vr_tab_erro );
           RAISE VR_NOK;
       END IF;
       --/
      pc_busca_dados_simulacao(pr_cdcooper => pr_cdcooper, 
                               pr_cdagenci => pr_cdagenci, 
                               pr_nrdcaixa => pr_nrdcaixa, 
                               pr_cdoperad => pr_cdoperad, 
                               pr_nmdatela => pr_nmdatela, 
                               pr_cdorigem => pr_cdorigem, 
                               pr_nrdconta => pr_nrdconta, 
                               pr_idseqttl => pr_idseqttl, 
                               pr_dtmvtolt => pr_dtmvtolt, 
                               pr_flgerlog => pr_flgerlog, 
                               pr_nrsimula => pr_nrsimula, 
                               pr_tcrapsim => vr_tcrapsim, 
                               pr_tparcepr => vr_tparcepr, 
                               pr_cdcritic => aux_cdcritic, 
                               pr_des_erro => aux_dscritic, 
                               pr_des_reto => vr_retorno_ok, 
                               pr_tab_erro => vr_tab_erro);
      --/
      IF vr_retorno_ok = 'NOK' THEN
         RAISE vr_NOK;
      END IF;      
      --/      
      pr_retorno := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados_simulacao/>');

       FOR rw_crapcop IN cr_crapcop LOOP
        --
        FOR idx IN vr_tcrapsim.first..vr_tcrapsim.last LOOP
         --
         OPEN cr_craplcr(vr_tcrapsim(idx).cdcooper,vr_tcrapsim(idx).cdlcremp);
          FETCH cr_craplcr INTO rw_craplcr;
         CLOSE cr_craplcr;
         --
         --    
         OPEN cr_crapfin(vr_tcrapsim(idx).cdcooper,vr_tcrapsim(idx).cdfinemp);
          FETCH cr_crapfin INTO rw_crapfin;
         CLOSE cr_crapfin;

         -- adicionada a informação do CDI junto a taxa mensal quando for Pós
         aux_vlperidx := '';
         IF pr_tpemprst = 2 THEN
           aux_vlperidx := empr0018.fn_formata_valor(' + ',
                                                rw_craplcr.vlperidx,
                                                'fm990',
                                                '% CDI');
         END IF;

         /* Ajuste de formatos s serem exibidos */
         aux_vlrsolic := empr0018.fn_formata_valor('R$ ',
                                                  vr_tcrapsim(idx).vlemprst,
                                                 'fm999g999g990d00',
                                                 '');
              
         aux_txmensal := empr0018.fn_formata_valor('',
                                                vr_tcrapsim(idx).txmensal,
                                                'fm999g999g990d00',
                                                ' %');

         -- concateno a taxa mensal com o cdi para a mesma linha
         aux_txmensal := aux_txmensal || ' ' || aux_vlperidx;
              
         aux_vlparepr := empr0018.fn_formata_valor('R$ ',
                                                vr_tcrapsim(idx).vlparepr,
                                               'fm999g999g990d00',
                                               '');
              
         aux_tributos := empr0018.fn_formata_valor('R$ ',
                                                vr_tcrapsim(idx).vliofepr,
                                               'fm999g999g990d00',
                                               '');

         aux_vlrtarif := empr0018.fn_formata_valor('R$ ',
                                                   vr_tcrapsim(idx).vlrtarif,
                                                  'fm999g999g990d00',
                                                  '');

         aux_vllibera := empr0018.fn_formata_valor('R$ ',
                                                   vr_tcrapsim(idx).vllibera,
                                                  'fm999g999g990d00',
                                                  '');
                                                  
         aux_vlprecar := empr0018.fn_formata_valor('R$ ',
                                                   vr_tcrapsim(idx).vlprecar,
                                                  'fm999g999g990d00',
                                                  '');
                                                  
         CASE vr_tcrapsim(idx).idcarenc
              WHEN 1 THEN aux_dscarenc := 'Sem pagamento';
              WHEN 2 THEN aux_dscarenc := 'Mensal';
              WHEN 3 THEN aux_dscarenc := 'Bimestral';
              WHEN 4 THEN aux_dscarenc := 'Trimestral';
              WHEN 5 THEN aux_dscarenc := 'Semestral';
              WHEN 6 THEN aux_dscarenc := 'Anual';
              ELSE aux_dscarenc := 'Sem carencia';
            END CASE;
                        
                        
         aux_percetop := empr0018.fn_formata_valor('',
                                                vr_tcrapsim(idx).percetop,
                                                'fm999g999g990d00',
                                                '%');/* P298.6 */
         --
         aux_diapagto := to_char(vr_tcrapsim(idx).dtdpagto,'DD'); 
         --
         aux_mespagto := TO_CHAR(vr_tcrapsim(idx).dtdpagto,'MM'); 
         --    
         aux_anopagto := TO_CHAR(vr_tcrapsim(idx).dtdpagto,'YYYY');
         --
         aux_dtdlibera := TO_CHAR(vr_tcrapsim(idx).dtlibera,'DD');
             
         aux_dtmlibera := TO_CHAR(vr_tcrapsim(idx).dtlibera,'MM');
             
         aux_dtalibera := TO_CHAR(vr_tcrapsim(idx).dtlibera,'YYYY');
         
         aux_dtcarenc := to_char(vr_tcrapsim(idx).dtcarenc,'dd/mm/yyyy');

         IF vr_tcrapsim(idx).idfiniof = 1 THEN 
             aux_dsfiniof := 'SIM';
         ELSE
             aux_dsfiniof := 'NAO';
         END IF;
         --
         empr0001.pc_calc_dias360(pr_ehmensal => aux_ehmensal, 
                                  pr_dtdpagto => aux_diapagto,
                                  pr_diarefju => aux_dtdlibera, 
                                  pr_mesrefju => aux_dtmlibera, 
                                  pr_anorefju => aux_dtalibera, 
                                  pr_diafinal => aux_diapagto, 
                                  pr_mesfinal => aux_mespagto, 
                                  pr_anofinal => aux_anopagto, 
                                  pr_qtdedias => aux_carencia);
         --
         aux_carencia := empr0018.fn_formata_valor('',ROUND(aux_carencia), 'FM990', ' dias');        
         --
          insere_tag(pr_xml      => pr_retorno
                    ,pr_tag_pai  => 'Dados_simulacao'
                    ,pr_posicao  => 0
                    ,pr_tag_nova => 'Dados_titulo'
                    ,pr_tag_cont => NULL
                    ,pr_des_erro => vr_dscritic);

          insere_tag(pr_xml      => pr_retorno
                    ,pr_tag_pai  => 'Dados_titulo'
                    ,pr_posicao  => vr_contador
                    ,pr_tag_nova => 'nome_cooperativa'
                    ,pr_tag_cont => rw_crapcop.nmextcop||' -  '||rw_crapcop.nmrescop
                    ,pr_des_erro => vr_dscritic);

         /* insere_tag(pr_xml      => pr_retorno
                    ,pr_tag_pai  => 'Dados_titulo'
                    ,pr_posicao  => vr_contador
                    ,pr_tag_nova => 'nome_resum_cooperativa'
                    ,pr_tag_cont => ' -  '||rw_crapcop.nmrescop
                    ,pr_des_erro => vr_dscritic);*/

          insere_tag(pr_xml      => pr_retorno
                    ,pr_tag_pai  => 'Dados_titulo'
                    ,pr_posicao  => vr_contador
                    ,pr_tag_nova => 'Data_Emissao'
                    ,pr_tag_cont => to_char(pr_dtmvtolt,'dd/mm/yy')
                    ,pr_des_erro => vr_dscritic);

          insere_tag(pr_xml      => pr_retorno
                    ,pr_tag_pai  => 'Dados_titulo'
                    ,pr_posicao  => vr_contador
                    ,pr_tag_nova => 'Conta'
                    ,pr_tag_cont => vr_tcrapsim(idx).nrdconta
                    ,pr_des_erro => vr_dscritic);

          insere_tag(pr_xml      => pr_retorno
                    ,pr_tag_pai  => 'Dados_titulo'
                    ,pr_posicao  => vr_contador
                    ,pr_tag_nova => 'Simulacao'
                    ,pr_tag_cont => vr_tcrapsim(idx).nrsimula
                    ,pr_des_erro => vr_dscritic);

          insere_tag(pr_xml      => pr_retorno
                    ,pr_tag_pai  => 'Dados_titulo'
                    ,pr_posicao  => vr_contador
                    ,pr_tag_nova => 'Pac'
                    ,pr_tag_cont => vr_tcrapsim(idx).cdagenci
                    ,pr_des_erro => vr_dscritic);

          insere_tag(pr_xml      => pr_retorno
                    ,pr_tag_pai  => 'Dados_simulacao'
                    ,pr_posicao  => vr_contador
                    ,pr_tag_nova => 'Simulacao_Emprestimo'
                    ,pr_tag_cont => NULL
                    ,pr_des_erro => vr_dscritic);
                      
          insere_tag(pr_xml      => pr_retorno
                    ,pr_tag_pai  => 'Simulacao_Emprestimo'
                    ,pr_posicao  => vr_contador
                    ,pr_tag_nova => 'Dados_emprestimo'
                    ,pr_tag_cont => NULL
                    ,pr_des_erro => vr_dscritic);                      
                      
          insere_tag(pr_xml      => pr_retorno
                    ,pr_tag_pai  => 'Dados_emprestimo'
                    ,pr_posicao  => vr_contador
                    ,pr_tag_nova => 'codigo_finalidade'
                    ,pr_tag_cont => vr_tcrapsim(idx).cdfinemp
                    ,pr_des_erro => vr_dscritic);

          insere_tag(pr_xml      => pr_retorno
                    ,pr_tag_pai  => 'Dados_emprestimo'
                    ,pr_posicao  => vr_contador
                    ,pr_tag_nova => 'descricao_finalidade'
                    ,pr_tag_cont => vr_tcrapsim(idx).cdfinemp||' -  '||vr_tcrapsim(idx).dsfinemp
                    ,pr_des_erro => vr_dscritic);

          /* imprime modalidade caso for uma PORTABILIDADE */
          IF vr_tcrapsim(idx).tpfinali = 2 THEN   
            --/            
            insere_tag(pr_xml      => pr_retorno
                      ,pr_tag_pai  => 'Dados_emprestimo'
                      ,pr_posicao  => vr_contador
                      ,pr_tag_nova => 'codigo_modalidade'
                      ,pr_tag_cont => vr_tcrapsim(idx).cdmodali
                      ,pr_des_erro => vr_dscritic);
            --/
            insere_tag(pr_xml      => pr_retorno
                      ,pr_tag_pai  => 'Dados_emprestimo'
                      ,pr_posicao  => vr_contador
                      ,pr_tag_nova => 'desc_modalidade'
                      ,pr_tag_cont => vr_tcrapsim(idx).dsmodali
                      ,pr_des_erro => vr_dscritic);
          END IF; 
          --/
          insere_tag(pr_xml      => pr_retorno
                    ,pr_tag_pai  => 'Dados_emprestimo'
                    ,pr_posicao  => vr_contador
                    ,pr_tag_nova => 'codigo_lin_cred_emprestimo'
                    ,pr_tag_cont => vr_tcrapsim(idx).cdlcremp
                    ,pr_des_erro => vr_dscritic);
          --/
          insere_tag(pr_xml      => pr_retorno
                    ,pr_tag_pai  => 'Dados_emprestimo'
                    ,pr_posicao  => vr_contador
                    ,pr_tag_nova => 'desc_lin_cred_emprestimo'
                    ,pr_tag_cont => 'Linha de Credito: '||vr_tcrapsim(idx).cdlcremp||' -  '||vr_tcrapsim(idx).dslcremp
                    ,pr_des_erro => vr_dscritic);
          --/
          insere_tag(pr_xml      => pr_retorno
                    ,pr_tag_pai  => 'Dados_emprestimo'
                    ,pr_posicao  => vr_contador
                    ,pr_tag_nova => 'Valor_Solicitado'
                    ,pr_tag_cont => aux_vlrsolic
                    ,pr_des_erro => vr_dscritic);
          --/
          insere_tag(pr_xml      => pr_retorno
                    ,pr_tag_pai  => 'Dados_emprestimo'
                    ,pr_posicao  => vr_contador
                    ,pr_tag_nova => 'data_liberacao'
                    ,pr_tag_cont => to_char(vr_tcrapsim(idx).dtlibera,'dd/mm/yyyy')
                    ,pr_des_erro => vr_dscritic);
                    
          IF vr_tcrapsim(idx).tpemprst = 2 THEN                    
          --/
          insere_tag(pr_xml      => pr_retorno
                    ,pr_tag_pai  => 'Dados_emprestimo'  -- Data Pgto 1 parcela carenc
                    ,pr_posicao  => vr_contador
                    ,pr_tag_nova => 'label_dtcarenc'
                    ,pr_tag_cont => 'Data Pgto 1 parc. carenc.: '
                    ,pr_des_erro => vr_dscritic);

          insere_tag(pr_xml      => pr_retorno
                    ,pr_tag_pai  => 'Dados_emprestimo'  -- Data Pgto 1 parcela carenc
                    ,pr_posicao  => vr_contador
                    ,pr_tag_nova => 'dtcarenc'
                    ,pr_tag_cont => aux_dtcarenc
                    ,pr_des_erro => vr_dscritic);
          END IF;
          --
          --/
          insere_tag(pr_xml      => pr_retorno
                    ,pr_tag_pai  => 'Dados_emprestimo'
                    ,pr_posicao  => vr_contador
                    ,pr_tag_nova => 'valor_parcela'
                    ,pr_tag_cont => aux_vlparepr
                    ,pr_des_erro => vr_dscritic);
          --
          --/
          IF vr_tcrapsim(idx).tpemprst = 2 THEN
          insere_tag(pr_xml      => pr_retorno
                    ,pr_tag_pai  => 'Dados_emprestimo'
                    ,pr_posicao  => vr_contador
                    ,pr_tag_nova => 'label_vlparcar'            -- Vl. Parc. 1 Carenc.
                    ,pr_tag_cont => 'Vl. Parc. 1 Carenc.: '
                    ,pr_des_erro => vr_dscritic);
          --/
          insere_tag(pr_xml      => pr_retorno
                    ,pr_tag_pai  => 'Dados_emprestimo'
                    ,pr_posicao  => vr_contador
                    ,pr_tag_nova => 'vlparcar'            -- Vl. Parc. 1 Carenc.
                    ,pr_tag_cont => aux_vlprecar                                    
                    ,pr_des_erro => vr_dscritic);
          --/
          insere_tag(pr_xml      => pr_retorno
                    ,pr_tag_pai  => 'Dados_emprestimo'
                    ,pr_posicao  => vr_contador
                    ,pr_tag_nova => 'label_dscarenc'             -- Periodo Carencia
                    ,pr_tag_cont => 'Periodo Carencia: '
                    ,pr_des_erro => vr_dscritic);

          insere_tag(pr_xml      => pr_retorno
                    ,pr_tag_pai  => 'Dados_emprestimo'
                    ,pr_posicao  => vr_contador
                    ,pr_tag_nova => 'dscarenc'             -- Periodo Carencia
                    ,pr_tag_cont => aux_dscarenc
                    ,pr_des_erro => vr_dscritic);
          END IF;
          --/
          insere_tag(pr_xml      => pr_retorno
                    ,pr_tag_pai  => 'Dados_emprestimo'
                    ,pr_posicao  => vr_contador
                    ,pr_tag_nova => 'Carencia'
                    ,pr_tag_cont => aux_carencia
                    ,pr_des_erro => vr_dscritic);
          --/
          insere_tag(pr_xml      => pr_retorno
                    ,pr_tag_pai  => 'Dados_emprestimo'
                    ,pr_posicao  => vr_contador
                    ,pr_tag_nova => 'taxa_mensal'
                    ,pr_tag_cont => aux_txmensal
                    ,pr_des_erro => vr_dscritic);
          --/
          insere_tag(pr_xml      => pr_retorno
                    ,pr_tag_pai  => 'Dados_emprestimo'
                    ,pr_posicao  => vr_contador
                    ,pr_tag_nova => 'qtd_parcela'
                    ,pr_tag_cont => vr_tcrapsim(idx).qtparepr
                    ,pr_des_erro => vr_dscritic);
          --/
          insere_tag(pr_xml      => pr_retorno
                    ,pr_tag_pai  => 'Dados_emprestimo'
                    ,pr_posicao  => vr_contador
                    ,pr_tag_nova => 'Tributos'
                    ,pr_tag_cont => aux_tributos
                    ,pr_des_erro => vr_dscritic);
          --/
          insere_tag(pr_xml      => pr_retorno
                    ,pr_tag_pai  => 'Dados_emprestimo'
                    ,pr_posicao  => vr_contador
                    ,pr_tag_nova => 'Tarifa'
                    ,pr_tag_cont => aux_vlrtarif
                    ,pr_des_erro => vr_dscritic);
          --/
          insere_tag(pr_xml      => pr_retorno
                    ,pr_tag_pai  => 'Dados_emprestimo'
                    ,pr_posicao  => vr_contador
                    ,pr_tag_nova => 'financia_iof_tarifa'
                    ,pr_tag_cont => aux_dsfiniof
                    ,pr_des_erro => vr_dscritic);
          --/
          insere_tag(pr_xml      => pr_retorno
                    ,pr_tag_pai  => 'Dados_emprestimo'
                    ,pr_posicao  => vr_contador
                    ,pr_tag_nova => 'vl_Liquido_liberado'
                    ,pr_tag_cont => aux_vllibera
                    ,pr_des_erro => vr_dscritic);
          --/
          insere_tag(pr_xml      => pr_retorno
                    ,pr_tag_pai  => 'Dados_emprestimo'
                    ,pr_posicao  => vr_contador
                    ,pr_tag_nova => 'cet_a_a'
                    ,pr_tag_cont => aux_percetop
                    ,pr_des_erro => vr_dscritic);
          --/
          insere_tag(pr_xml      => pr_retorno
                    ,pr_tag_pai  => 'Dados_emprestimo'
                    ,pr_posicao  => vr_contador
                    ,pr_tag_nova => 'tpemprst'
                    ,pr_tag_cont =>  vr_tcrapsim(idx).tpemprst
                    ,pr_des_erro => vr_dscritic);
          --/
          vr_contador_parc := 0;
          --/
          insere_tag(pr_xml => pr_retorno
                    ,pr_tag_pai  => 'Dados_emprestimo'
                    ,pr_posicao  => vr_contador
                    ,pr_tag_nova => 'Parcelas'
                    ,pr_tag_cont => NULL
                    ,pr_des_erro => vr_dscritic);

          -- parcelas do emprestimo        
          aux_contador_parc := 0;
          vr_count := vr_tparcepr.first;
          vr_query_2 := NULL;
          vr_query_1 := NULL;
          --
          monta_subquery_parcelas(); -- ajustado para layout das parcelas no jasper
          --;
          vr_query := fn_query_parcelas(); -- ajustado para layout das parcelas no jasper
          --/  
          OPEN c_dummy FOR vr_query;
          LOOP
           FETCH c_dummy
           INTO vr_parcela,vr_metade,vr_total,vr_lado,vr_posicao,vr_vlparepr,vr_dtparepr;
           EXIT WHEN c_dummy%NOTFOUND;
           --
           aux_contador_parc := aux_contador_parc + 1;
           --
           aux_codig := empr0018.fn_formata_valor('',
                                                  vr_parcela,
                                                  'FM990',
                                                  ') ');
           --
           aux_data_parc := to_char(vr_dtparepr,'dd/mm/yyyy');
           --
           aux_valor := empr0018.fn_formata_valor('R$ ',
                                                  vr_vlparepr,
                                                  'fm999g999g990d00',
                                                  '');
           --/
           vr_endline := FALSE;
           --/
        /* IF aux_string_parc IS NULL
             THEN
                 aux_string_parc := aux_codig||' '||aux_data_parc||' '||aux_valor;
                
           ELSIF vr_posicao_aux = vr_posicao
             THEN
                aux_string_parc := aux_string_parc||'              '||aux_codig||' '||aux_data_parc||' '||aux_valor;
                vr_endline := TRUE;
                
           ELSE
                aux_string_parc := aux_string_parc||CHR(13)||aux_codig||' '||aux_data_parc||' '||aux_valor;
           END IF;*/
           --/
           IF aux_string_parc IS NULL
             THEN
                 aux_string_parc := RPAD(TRIM(aux_codig),5,chr(32))||aux_data_parc||chr(32)||chr(32)||aux_valor;
                
           ELSIF vr_posicao_aux = vr_posicao
             THEN
                aux_string_parc := RPAD(aux_string_parc,38,chr(32))||RPAD(TRIM(aux_codig),5,chr(32))||aux_data_parc||chr(32)||chr(32)||aux_valor;
                vr_endline := TRUE;
                
           ELSE
                aux_string_parc := aux_string_parc||CHR(13)||RPAD(TRIM(aux_codig),5,chr(32))||aux_data_parc||chr(32)||chr(32)||aux_valor;
           END IF;
           --
           --/  
           vr_posicao_aux  := vr_posicao;
           --/
           IF aux_contador_parc = vr_total THEN
                vr_endline := TRUE;
           END IF;
           --/
           IF vr_endline THEN             
             insere_tag(pr_xml => pr_retorno
                       ,pr_tag_pai  => 'Parcelas'
                       ,pr_posicao  => vr_contador
                       ,pr_tag_nova => 'Parcela'
                       ,pr_tag_cont => aux_string_parc
                       ,pr_des_erro => vr_dscritic);
               vr_contador_parc := vr_contador_parc +1;       
              aux_string_parc := NULL;
           END IF;
           --/
          END LOOP;
         --/
         vr_contador := vr_contador+1;
        --/
        END LOOP idxcrapsim;   
       --/
       END LOOP rw_crapcop;
       --
      pr_dsretorno := 'OK'; 
    --
    EXCEPTION WHEN vr_nok THEN
      pr_dsretorno := 'NOK - '||aux_dscritic;   
    END monta_xml;
    --
    BEGIN
     
      OPEN cr_crapcop;
       FETCH cr_crapcop INTO rw_crapcop;
     
       IF cr_crapcop%NOTFOUND THEN
          CLOSE cr_crapcop;
          vr_dscritic := 'Cooperativa não cadastrada!';
         RAISE vr_exc_saida;
       END IF;  
       
       CLOSE cr_crapcop;
       --
       monta_xml(vr_retorno,vr_retorno_ok);
       --
       IF vr_retorno_ok != 'OK' THEN
          vr_dscritic := 'Problema na montagem do XML';
          RAISE vr_exc_saida;
       END IF;
       --   
       vr_clob := NULL;
       dbms_lob.createtemporary(vr_clob, TRUE);
       dbms_lob.open(vr_clob, dbms_lob.lob_readwrite);
       --
       vr_clob := vr_retorno.getClobVal;
       -- 
       --
       vr_nom_direto:= gene0001.fn_diretorio(pr_tpdireto => 'C', 
                                             pr_cdcooper => pr_cdcooper, 
                                             pr_nmsubdir => '/rl');
       --
       -- Definir nome do relatorio
       vr_nmarqimp := pr_dsiduser||to_char(SYSDATE,'hh24miss')||'.ex';
       vr_nmarqpdf := pr_dsiduser||to_char(SYSDATE,'hh24miss')||'.pdf';
       --
       -- Solicitar geração do relatorio
       --
        gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper --> Cooperativa conectada
                                   ,pr_cdprogra  => 'ATENDA' --> Programa chamador
                                   ,pr_dtmvtolt  => SYSDATE --> Data do movimento atual
                                   ,pr_dsxml     => vr_clob --> Arquivo XML de dados
                                   ,pr_dsxmlnode => '/Dados_simulacao/Simulacao_Emprestimo' --> Nó base do XML para leitura dos dados
                                   ,pr_dsjasper  => 'crrl771_simulacao.jasper' --> Arquivo de layout do iReport
                                   ,pr_dsparams  => NULL --> Sem parâmetros
                                   ,pr_dsarqsaid => vr_nom_direto || '/' || vr_nmarqpdf --> Arquivo final com o path
                                   ,pr_cdrelato  => 771 -- verificar script de insert na craprel (Rafael em 19/12/2018)
                                   ,pr_qtcoluna  => 80 --> 80 colunas
                                   ,pr_flg_gerar => 'S' --> Geraçao na hora
                                   ,pr_flg_impri => 'N' --> Chamar a impressão (Imprim.p)
                                   ,pr_nmformul  => ' ' --> Nome do formulário para impressão
                                   ,pr_nrcopias  => 1 --> Número de cópias
                                   ,pr_sqcabrel  => 1 --> Qual a seq do cabrel
                                   ,pr_nrvergrl  => 1 -- CHAMANDO TIBICO
                                   ,pr_des_erro  => vr_dscritic); --> Saída com erro

         -- Tratar erro
         IF TRIM(vr_dscritic) IS NOT NULL THEN
           raise vr_exc_saida;
         END IF;
         --   
         IF pr_cdorigem = 5 THEN /** Ayllos Web **/              
            gene0002.pc_efetua_copia_pdf(pr_cdcooper => pr_cdcooper ,
                                         pr_cdagenci => pr_cdagenci,
                                         pr_nrdcaixa => pr_nrdcaixa,
                                         pr_nmarqpdf => vr_nom_direto || '/' || vr_nmarqpdf,
                                         pr_des_reto => vr_dscritic,
                                         pr_tab_erro => pr_tab_erro);
         END IF;
         --
         IF pr_flgerlog   THEN
          --
          aux_dsorigem := gene0001.vr_vet_des_origens(pr_cdorigem);        
          aux_dstransa := 'Imprime simulacao '||pr_nrsimula||'.';                    
          aux_dttransa := TRUNC(sysdate);
          aux_hrtransa := to_number(to_char(SYSDATE,'hh24'));
          aux_flgtrans := 1;
          --
          gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper, 
                               pr_cdoperad => pr_cdoperad, 
                               pr_dscritic => ' ', 
                               pr_dsorigem => aux_dsorigem, 
                               pr_dstransa => aux_dstransa, 
                               pr_dttransa => aux_dttransa, 
                               pr_flgtrans => aux_flgtrans, 
                               pr_hrtransa => aux_hrtransa, 
                               pr_idseqttl => pr_idseqttl, 
                               pr_nmdatela => pr_nmdatela, 
                               pr_nrdconta => pr_nrdconta, 
                               pr_nrdrowid => aux_nrdrowid);
          END IF;

          -- Liberando a memória alocada pro CLOB
          IF dbms_lob.isopen(vr_clob) = 1 THEN
            dbms_lob.close(vr_clob);
            dbms_lob.freetemporary(vr_clob);
          END IF; 


        pr_nmarqimp := vr_nmarqimp;
        pr_nmarqpdf := vr_nmarqpdf;
       

        vr_retorno_xml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><retorno/>');

        insere_tag(pr_xml      => vr_retorno_xml
                  ,pr_tag_pai  => 'retorno'
                  ,pr_posicao  => 0
                  ,pr_tag_nova => 'arquivo_imp'
                  ,pr_tag_cont => pr_nmarqimp
                  ,pr_des_erro => vr_dscritic);

        insere_tag(pr_xml      => vr_retorno_xml
                  ,pr_tag_pai  => 'retorno'
                  ,pr_posicao  => 0
                  ,pr_tag_nova => 'url_arquivo_pdf'
                  ,pr_tag_cont => pr_nmarqpdf
                  ,pr_des_erro => vr_dscritic);

        pr_retorno := vr_retorno_xml;
        pr_des_reto := 'OK';
       
   EXCEPTION
    WHEN vr_exc_saida THEN
       pr_des_reto := 'NOK';
       pr_retorno := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                          '<Root><Erro>' ||vr_dscritic ||
                                          '</Erro></Root>');
       aux_cdcritic := 0; 
       aux_dscritic  := 'Erro não tratado na geração da impressão da simulação';       
       gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper,
                             pr_cdagenci => pr_cdagenci,
                             pr_nrdcaixa => pr_nrdcaixa,
                             pr_nrsequen => 1,
                             pr_cdcritic => aux_cdcritic,
                             pr_dscritic => aux_dscritic,
                             pr_tab_erro => pr_tab_erro );
    WHEN OTHERS THEN

       IF cr_crapcop%ISOPEN THEN 
        CLOSE cr_crapcop;  
       END IF;
   
       pr_des_reto := 'NOK';
       pr_retorno  := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                        '<Root><Erro>' || vr_dscritic ||SQLERRM||
                                        '</Erro></Root>');
       aux_cdcritic := 0; 
       aux_dscritic := 'Erro não tratado na geração da impressão da simulação';
       gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper,
                             pr_cdagenci => pr_cdagenci,
                             pr_nrdcaixa => pr_nrdcaixa,
                             pr_nrsequen => 1,
                             pr_cdcritic => aux_cdcritic,
                             pr_dscritic => aux_dscritic,
                             pr_tab_erro => pr_tab_erro );
          
    END pc_imprime_simulacao;



   --/ procedure generica para inserir as tags no xml montado
   PROCEDURE insere_tag(pr_xml      IN OUT NOCOPY XMLType  --> XML que receberá a nova TAG
                      ,pr_tag_pai  IN VARCHAR2            --> TAG que receberá a nova TAG
                      ,pr_posicao  IN PLS_INTEGER         --> Posição da tag na lista
                      ,pr_tag_nova IN VARCHAR2            --> String com a nova TAG
                      ,pr_tag_cont IN VARCHAR2            --> Conteúdo da nova TAG
                      ,pr_des_erro OUT VARCHAR2) IS
                      
  /* -------------------------------------------------------------------------------------------------------------

    Programa: insere_tag    
    Autor   : Rafael Rocha / AMcom 
    Data    : 02/2019               ultima Atualizacao: -- 
     
    Dados referentes ao programa:
   
    Objetivo  :procedure generica para inserir as tags no xml montado
   
    Alteracoes: 

  ..............................................................................*/                            
                       
      vr_domDoc    DBMS_XMLDOM.DOMDocument;      --> Definição do documento DOM (XML)
      vr_elemento  DBMS_XMLDOM.DOMElement;       --> Novo elemento que será adicionado
      vr_novoNodo  DBMS_XMLDOM.DOMNode;          --> Novo nodo baseado no elemento
      vr_paiNodo   DBMS_XMLDOM.DOMNode;          --> Nodo pai
      vr_texto     DBMS_XMLDOM.DOMText;          --> Texto que será incluido

    BEGIN
      -- Cria o documento DOM com base no XML enviado
      vr_domDoc := DBMS_XMLDOM.newDOMDocument(pr_xml);
      -- Criar novo elemento
      vr_elemento := DBMS_XMLDOM.createElement(vr_domDoc, pr_tag_nova);
      -- Criar novo nodo
      vr_novoNodo := DBMS_XMLDOM.makeNode(vr_elemento);
      -- Definir nodo pai
      vr_paiNodo := DBMS_XMLDOM.makeNode(DBMS_XMLDOM.makeElement(DBMS_XMLDOM.item(DBMS_XMLDOM.getElementsByTagName(vr_domDoc, pr_tag_pai), pr_posicao)));
      -- Adiciona novo nodo no nodo pai
      vr_novoNodo := DBMS_XMLDOM.appendChild(vr_paiNodo, vr_novoNodo);
      -- Adiciona o conteúdo ao novo nodo
      vr_texto := DBMS_XMLDOM.createTextNode(vr_domDoc, pr_tag_cont);
      vr_novoNodo := DBMS_XMLDOM.appendChild(vr_novoNodo, DBMS_XMLDOM.makeNode(vr_texto));

      -- Gerar o novo stream XML
      pr_xml := DBMS_XMLDOM.getxmltype(vr_domDoc);
      
      -- Liberar uso de memória
      dbms_xmldom.freeDocument(vr_domDoc);
    EXCEPTION
      WHEN OTHERS THEN
        pr_des_erro := 'Erro pc_insere_tag: ' || SQLERRM;
    END insere_tag;

                    
END EMPR0018;
/
