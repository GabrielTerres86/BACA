CREATE OR REPLACE PROCEDURE CECRED."PC_CRPS314"
                                           (pr_cdcooper  IN craptab.cdcooper%TYPE -- Cooperativa solicitada
                                           ,pr_flgresta  IN PLS_INTEGER           --> Flag 0/1 para utilizar restart na chamada
                                           ,pr_stprogra OUT PLS_INTEGER           --> Saída de termino da execução
                                           ,pr_infimsol OUT PLS_INTEGER           --> Saída de termino da solicitação
                                           ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Critica encontrada
                                           ,pr_dscritic OUT VARCHAR2) as          --> Texto de erro/critica encontrada
/* ..........................................................................
   Programa: pc_crps314 (antigo Fontes/crps314.p)
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Junior.
   Data    : Julho/2001                          Ultima atualizacao: 09/09/2019

   Dados referentes ao programa:

   Frequencia: Diario.
   Objetivo  : Atende a solicitacao 086 / Ordem 033.
               Listar os lotes de contratos de emprestimo.
               Emite relatorio 266.

               24/06/2003 - Dividir em duas listas <= f2000 (Margarete).

               16/07/2003 - Alterada o nro de copias do relatorio 266 de
                            1 para 2 (Julio).

               22/07/2003 - Substituicao do valor fixo de 2000, pela variavel
                            aux_dstextab, no valor max do contrato (Julio).

               23/07/2003 - Separacao do relatorio por PAC (Julio)

               12/03/2004 - Listar Lotes Contratos Limite Desconto de Cheques e
                            Lote Borderos(Mirtes).

               19/03/2004 - Nao paginar por Lote(Lancamentos Borderos)(Mirtes)

               22/04/2004 - Incluir mais uma faixa (Margarete).

               28/05/2004 - Alterado o FORMAT do valor total de emprestimos
                            (Julio)

               10/08/2004 - Imprimir somente borderos de desconto
                            liberados (Margarete).

               28/02/2005 - Controle de quebras a partir da tabela "crapage";
                            Imprimir tambem "Controle de proposta/limite de
                            credito" (Evandro).

               01/03/2005 - Acerto no programa (Ze).

               14/03/2005 - Imprimir tambem "LIMITES DE CARTAO DE CREDITO"
                            (Evandro).

               14/04/2005 - Corrigido o FOR EACH da procedure
                            limite_cartao_cred (Evandro).

               07/06/2005 - Nao gerar mais pedido de impressao para a VIACREDI
                            (Edson).

               28/07/2005 - Alterado para mostrar no relatorio 266  borderos
                            separados entre > e < de  R$ 2.000,00 (Diego).

               19/09/2005 - Alterado para imprimir relatorio separadamente
                            para Viacredi (Diego).

               03/10/2005 - Alterado para imprimir apenas uma copia para
                            CredCrea (Diego).

               11/10/2005 - Acerto no relatorio crrl26699 (Diego).

               01/11/2005 - Relacionar Contrato Cartao no PAC do
                            cooperado(Mirtes)

               23/11/2005 - Alterado numero de vias e formulario para
                            impressao de relatorio na Viacredi (Diego).

               30/01/2006 - Alterando layout relatorio crrl26699 (Diego).

               31/03/2006 - Corrigir nome do relatorio crrl26699 para
                            crrl266_99, e corrigir rotina de impressao de
                            relatorios por agencia (Junior).

               13/06/2008 - Alterações para melhorias de performance (Julio)

               09/07/2008 - Alterado valor da variavel "aux_dstextb2" no caso
                            de nao receber dados da craptab (Elton).

               14/10/2008 - Incluido tratamento para Desconto de Titulos
                            (Diego).

               08/01/2009 - Efetuado acerto na leitura da tabela craplot,
                            procedure -> processa_limite_desconto (Diego).

               13/01/2011 - Alterada a posicao das colunas para acomodar o
                            campo nmprimtl (Kbase - Gilnei)

               14/07/2011 - Sera gerado crrl26699 para demais cooperativas alem
                            da Viacredi (Adriano).

               16/10/2012 - Incluir linha DIGITALIZADOS no frame f_confvist
                            (Lucas R.).

               03/04/2013 - Conversão Progress >> Oracle PL/SQL (Daniel - Supero)

               06/05/2013 - Adicionada relação de Emissão de Aditivos (Lucas).

               26/06/2013 - Correção na exibição de aditivos emitidos no
                            266 por PAC (Lucas).

               12/11/2013 - Correção no nome dos relatórios gerados e também
                            na chamada ao Imprim.p, que deve ocorrer somente para
                            o 999 ou para outras Cooperativas <> 1 (Marcos-Supero)

               11/12/2013 - Incluir alterações realizadas no Progress ( Renato - Supero )
                          - Correção na ordenação de aditivos e borderos emitidos no 266 (Reinert).
                          - Alteracao de PAC/P.A.C para PA. (James)
                          - Ajuste no relatorio 266 para separar por tipo de
                            emprestimo (Price tr/Prefixado) (Adriano).
                          - Alterado totalizador de 99 para 999. (Reinert).

               19/12/2013 - Correção de problema com invalid number pois o campo
                            cdoperad não eh numerico (Marcos-Supero)

               30/07/2014 - Correção na lógica de busca das faixas, pois não trazia
                            a faixa maxima e com isso os empréstimos naõ eram trazidos
                            corretamente (Marcos-Supero)

               31/10/2014 - Ajustes no cancelamento noturno (codigo da agencia com duas
                            posicoes) (Andrino-RKAM)
               
               07/11/2014 - Ajuste no cursor "cr_crapepr" para selecionar 
                            contratos de emprestimo que nao tenham origem 
                            (3) Internet ou (4) TAA. (Jaison)
							
               13/11/2014 - Alterar o cursor cr_crapbdc da rotina pc_grava_borderos para que
                            seja lido o número do contrato de limite(nrctrlim) da tabela crapbdc
                            e não mais da crapcdb. Ajustado devido a problema relatado no 
                            chamado 197280 ( Renato - Supero )
                            
               02/03/2015 - (Chamado 252147) Retirar pendências geradas nos 
                            relatórios: 266, 620, 285  quanto as operações 
                            de crédito liberadas devido aos Termos de Cessão 
                            de Crédito (Cartão Bancoob) (Tiago Castro - RKAM).
                            
               21/05/2015 - Alterado a rotina de limite de credito para apresentar o
                            PA onde o limite foi liberado e não o do cooperado, tambem
                            incluir cdpesqbb "Data da pesquisa".
                          - Na rotina de aditivos incluir agencia e operador da tabela crapadt.
                            (Lucas Ranghetti #288277)

               18/10/2016 - Quando quebrar o loop de emprestimos por troca de filial, se ainda
                            não foram incluídos os aditivos então devem ser incluídos.
                            (AJFink #539415)

               28/07/2017 - Incluso tratativa para nao incluir cheques nao aprovados ao compor valor
			                do bordero de desconto de cheques (Daniel)

               08/08/2017 - Inclusao do produto Pos-Fixado. (Jaison/James - PRJ298)

               26/10/2017 - Passagem do tpctrato. (Jaison/Marcos Martini - PRJ404) 

               19/08/2018 - Incluso trattaiva para efetuar apenas leitura de titulos
                            descontados e liberados (GFT)

               23/10/2018 - PJ439 - nao listar contratos de emprestimo cdc para pendencia (Rafael Faria-Supero)

                31/10/2018 - Incluso a tratativa para não filtrar somente lotes 4.
                			Relatorio 266 - Contratos de cheques.	            

               09/09/2019 - P438 - Inclusão da origem 10 (MOBILE) no filtro dos cursores de emprestimos
                            (Douglas Pagel/AMcom)	            

 ............................................................................ */
  --
  -- Dados da cooperativa
  cursor cr_crapcop(pr_cdcooper in craptab.cdcooper%type) is
    select 1
      from crapcop
     where crapcop.cdcooper = pr_cdcooper;
  rw_crapcop    cr_crapcop%rowtype;
  -- Busca as agências da cooperativa
  cursor cr_crapage (pr_cdcooper in crapage.cdcooper%type) is
    select cdagenci,
           nmresage
      from crapage
     where crapage.cdcooper = pr_cdcooper
     order by crapage.cdagenci;
  -- Busca os associados de uma agência
  cursor cr_crapass (pr_cdcooper in crapass.cdcooper%type,
                     pr_cdagenci in crapass.cdagenci%type) is
    select cdagenci,
           nmprimtl,
           nrdconta
      from crapass
     where crapass.cdcooper = pr_cdcooper
       and crapass.cdagenci = pr_cdagenci;
  --
  cursor cr_craplot (pr_cdcooper in crapepr.cdcooper%type,
                     pr_dtmvtolt in crapepr.dtmvtolt%type,
                     pr_cdagenci in crapepr.cdagenci%type,
                     pr_cdbccxlt in crapepr.cdbccxlt%type,
                     pr_nrdolote in crapepr.nrdolote%type,
                     pr_tplotmov in craplot.tplotmov%type) is
    select cdoperad,
           tplotmov
      from craplot
     where craplot.cdcooper = pr_cdcooper
       and craplot.dtmvtolt = pr_dtmvtolt
       and craplot.cdagenci = pr_cdagenci
       and craplot.cdbccxlt = pr_cdbccxlt
       and craplot.nrdolote = pr_nrdolote
       and craplot.tplotmov = nvl(pr_tplotmov, craplot.tplotmov);
  rw_craplot     cr_craplot%rowtype;
  --
  cursor cr_crapass2 (pr_cdcooper in crapass.cdcooper%type,
                      pr_nrdconta in crapass.nrdconta%type) is
    select nmprimtl
      from crapass
     where crapass.cdcooper = pr_cdcooper
       and crapass.nrdconta = pr_nrdconta;
  rw_crapass2     cr_crapass2%rowtype;

  -- PL/Table para armazenar os borderôs
  type typ_bordero is record (vr_tpctrlim  number(1),
                              vr_nrctrlim  crapcdb.nrctrlim%type,
                              vr_nrborder  crapcdb.nrborder%type,
                              vr_nrdconta  crapcdb.nrdconta%type,
                              vr_vldocmto  crapcdb.vlcheque%type,
                              vr_dtmvtolt  crapcdb.dtmvtolt%type,
                              vr_cdagenci  crapcdb.cdagenci%type,
                              vr_cdbccxlt  crapcdb.cdbccxlt%type,
                              vr_nrdolote  crapcdb.nrdolote%type,
                              vr_dtlibbdc  crapcdb.dtlibbdc%type,
                              vr_cdoperad  crapcdb.cdoperad%type,
                              vr_nmprimtl  crapass.nmprimtl%type,
                              vr_formalizacao VARCHAR2(100) -- Pj470 - SM2 -- MArcelo Telles Coelho -- Mouts
                              );
  -- Definição da tabela para armazenar os registros dos borderôs
  type typ_tab_bordero is table of typ_bordero index by varchar2(23);
  -- Instância da tabela. O índice será o código da agência || número do borderô || número do contrato.
  vr_tab_bordero         typ_tab_bordero;
  -- Variavel para leitura das pl/tables
  vr_indice_bordero      varchar2(23);
  vr_dslinhas            VARCHAR2(2000);        --> Linhas que nao possuirao analise de credito
  -- PL/Table para armazenar os borderôs separados
  type typ_separados is record (vr_tpctrlim  number(1),
                                vr_nrdconta  crapcdb.nrdconta%type,
                                vr_nrctrlim  crapcdb.nrctrlim%type,
                                vr_nrborder  crapcdb.nrborder%type,
                                vr_nmprimtl  crapass.nmprimtl%type,
                                vr_vlemprst  crapcdb.vlcheque%type,
                                vr_nrdolote  crapcdb.nrdolote%type,
                                vr_dtmvtolt  crapcdb.dtmvtolt%type,
                                vr_dtlibbdc  crapcdb.dtlibbdc%type,
                                vr_cdagenci  crapage.cdagenci%type,
                                vr_nmresage  crapage.nmresage%type,
                                vr_cdbccxlt  crapcdb.cdbccxlt%type,
                                vr_formalizacao VARCHAR2(100) -- Pj470 - SM2 -- MArcelo Telles Coelho -- Mouts
                                );
  -- Definição da tabela para armazenar os registros dos borderôs separados
  type typ_tab_separados is table of typ_separados index by varchar2(66);
  -- Instância da tabela. O índice será dtlibbdc || cdagenci || cdbccxlt || nrdolote || nrctrlim || nrborder || nrdconta
  vr_tab_separados       typ_tab_separados;
  -- Variavel para leitura das pl/tables
  vr_indice_separados    varchar2(66);

  -- PL/Table para os aditivos
  type typ_aditivo is record (vr_cdagenci  crapass.cdagenci%type,
                              vr_nrdconta  crapadt.nrdconta%type,
                              vr_nraditiv  crapadt.nraditiv%type,
                              vr_nrctremp  crapadt.nrctremp%type,
                              vr_cdaditiv  crapadt.cdaditiv%type,
                              vr_nmprimtl  crapass.nmprimtl%type,
                              vr_dsaditiv  varchar2(45),
                              vr_cdoperad  crapadt.cdoperad%TYPE,
                              vr_tpctrato  crapadt.tpctrato%TYPE);
  -- Definição da tabela para armazenar os aditivos
  type typ_tab_aditivo is table of typ_aditivo index by varchar2(42);
  -- Instância da tabela. O índice será cdagenci || nrdconta || cdaditiv || nraditiv
  vr_tab_aditivo         typ_tab_aditivo;
  -- Variavel para leitura das pl/tables
  vr_indice_aditivo      varchar2(42);

  -- PL/Table geral com os limites de crédito
  type typ_geral is record (vr_cdagenci  crapass.cdagenci%type,
                            vr_nrdconta  craplim.nrdconta%type,
                            vr_nrctremp  craplim.nrctrlim%type,
                            vr_nrborder  crapcdb.nrborder%type,
                            vr_nmprimtl  crapass.nmprimtl%type,
                            vr_vlemprst  craplim.vllimite%type,
                            vr_flgcontr  number(1),
                            vr_flgvalor  number(1),
                            vr_cdoperad  craplim.cdoperad%type,
                            vr_dsrlgera  varchar2(40),
                            vr_vlrgeral  varchar2(100),
                            vr_dtmvtolt  crapepr.dtmvtolt%type,
                            vr_nrdolote  crapepr.nrdolote%type,
                            vr_cdbccxlt  crapepr.cdbccxlt%type,
                            vr_cdpesqbb  varchar2(26),
                            vr_tpemprst  crapepr.tpemprst%type,
                            vr_dsemprst  varchar2(100),
                            vr_formalizacao VARCHAR2(100) -- Pj470 - SM2 -- MArcelo Telles Coelho -- Mouts
                            );
  -- Definição da tabela para armazenar os registros das agências
  type typ_tab_geral is table of typ_geral index by varchar2(42);
  -- Instância da tabela. O índice será o código da agência || tipo contrato || tipo valor || número conta || número contrato || numero bordero (0s quando nao existir).
  vr_tab_geral           typ_tab_geral;
  -- Variavel para leitura das pl/tables
  vr_indice_geral        varchar2(100);
  -- É necessário criar outra pl/table para fazer a leitura indexada por outra ordem de campos.
  -- Definição da tabela para armazenar os registros das agências
  type typ_tab_geral2 is table of typ_geral index by varchar2(67);
  -- Instância da tabela. O índice será o tipo contrato || tipo valor || tipo emprestimo || código da agência || número conta || valor empréstimo || número contrato || numero bordero (0s quando nao existir).
  vr_tab_geral2          typ_tab_geral2;
  -- Variavel para leitura das pl/tables
  vr_indice_geral2       varchar2(100);

  -- Variável para armazenar as informações em XML
  vr_des_xml             clob;
  vr_des_xml_temp        varchar2(32767);
  -- Variáveis para o caminho e nome do arquivo base
  vr_nom_diretorio       varchar2(200);
  vr_nom_arquivo         varchar2(200);
  vr_nrcopias            number(1);
  vr_flgimpri            varchar2(1);
  -- Código do programa
  vr_cdprogra            crapprg.cdprogra%type;
  -- Controle de critica
  vr_cdcritic            crapcri.cdcritic%type;
  vr_dscritic            varchar2(4000);
  -- Data do movimento
  rw_crapdat             btch0001.cr_crapdat%rowtype;
  -- Variáveis para leitura da tabela de parâmetros
  vr_dstextab            craptab.dstextab%TYPE;
  vr_vlfaixa1            number(10,2);
  vr_vlfaixa2            number(10,2);
  vr_vllimctr            number(10,2);
  vr_vllimcre            number(10,2);
  -- Variáveis globais, utilizadas pelas procedures internas
  vr_dsrelato            varchar2(40);
  vr_desvalor            varchar2(100);
  vr_idexiste            NUMBER; -- Pj470 - SM2 -- MArcelo Telles Coelho -- Mouts
  vr_des_reto            VARCHAR2(1); -- Pj470 - SM2 -- MArcelo Telles Coelho -- Mouts
  vr_err_efet            INTEGER; -- Pj470 - SM2 -- MArcelo Telles Coelho -- Mouts
  -- Variáveis utilizadas para controlas as quebras na leitura das pl/tables
  vr_flgcontr            number(1);
  vr_flgvalor            number(1);
  vr_flesctgvl           boolean;
  --
  vr_vllanbdc            craplim.vllimite%type;
  vr_vlemprst_total      craplim.vllimite%type;
  vr_lancou_aditivos     varchar2(1); --SD#539415
  vr_dstipctr            varchar2(15);
  -- Exceptions
  vr_exc_saida           EXCEPTION;

  -- Inclui informações de borderô na vr_tab_bordero
  PROCEDURE pc_grava_borderos (pr_cdcooper in crapbdc.cdcooper%type
                              ,pr_dtmvtolt in crapbdc.dtmvtolt%type) IS
    -- Borderos de Desconto de Cheques
    cursor cr_crapbdc is
      select crapbdc.nrctrlim,
             crapcdb.nrborder,
             crapcdb.nrdconta,
             crapcdb.vlcheque,
             crapcdb.dtmvtolt,
             crapcdb.cdagenci,
             crapcdb.cdbccxlt,
             crapcdb.nrdolote,
             crapcdb.dtlibbdc,
             crapcdb.cdoperad,
             crapass.nmprimtl
        from crapbdc,
             crapcdb,
             crapage,
             crapass
       where crapage.cdcooper = pr_cdcooper
         and crapass.cdcooper = crapage.cdcooper
         and crapass.cdagenci = crapage.cdagenci
         and crapbdc.cdcooper = crapage.cdcooper
         and crapbdc.dtlibbdc = pr_dtmvtolt
         and crapbdc.nrdconta = crapass.nrdconta
         and crapcdb.cdcooper = crapbdc.cdcooper
         and crapcdb.nrdconta = crapbdc.nrdconta
         and crapcdb.nrborder = crapbdc.nrborder
		 and crapcdb.dtlibbdc IS NOT NULL;
    -- Borderos de Desconto de Titulos
    cursor cr_crapbdt is
      select craptdb.nrctrlim,
             craptdb.nrborder,
             craptdb.nrdconta,
             craptdb.vltitulo,
             crapbdt.dtmvtolt,
             crapbdt.cdagenci,
             crapbdt.cdbccxlt,
             crapbdt.nrdolote,
             craptdb.dtlibbdt,
             craptdb.cdoperad,
             crapass.nmprimtl
        from crapbdt,
             craptdb,
             crapage,
             crapass
       where crapage.cdcooper = pr_cdcooper
         and crapass.cdcooper = crapage.cdcooper
         and crapass.cdagenci = crapage.cdagenci
         and crapbdt.cdcooper = crapage.cdcooper
         and crapbdt.dtlibbdt = pr_dtmvtolt
         and crapbdt.nrdconta = crapass.nrdconta
         and craptdb.cdcooper = crapbdt.cdcooper
         and craptdb.nrdconta = crapbdt.nrdconta
         and craptdb.nrborder = crapbdt.nrborder
         and craptdb.dtlibbdt is not null;
    --
  BEGIN
    -- Incluimos os descontos de cheque
    for rw_crapbdc in cr_crapbdc loop
      vr_indice_bordero := to_char(rw_crapbdc.cdagenci, 'fm000')||to_char(rw_crapbdc.nrborder, 'fm0000000000')||to_char(rw_crapbdc.nrctrlim, 'fm0000000000');
      vr_tab_bordero(vr_indice_bordero).vr_tpctrlim := 1; -- Desconto de cheque
      vr_tab_bordero(vr_indice_bordero).vr_nrctrlim := rw_crapbdc.nrctrlim;
      vr_tab_bordero(vr_indice_bordero).vr_nrborder := rw_crapbdc.nrborder;
      vr_tab_bordero(vr_indice_bordero).vr_nrdconta := rw_crapbdc.nrdconta;
      vr_tab_bordero(vr_indice_bordero).vr_vldocmto := nvl(vr_tab_bordero(vr_indice_bordero).vr_vldocmto, 0) + rw_crapbdc.vlcheque;
      vr_tab_bordero(vr_indice_bordero).vr_dtmvtolt := rw_crapbdc.dtmvtolt;
      vr_tab_bordero(vr_indice_bordero).vr_cdagenci := rw_crapbdc.cdagenci;
      vr_tab_bordero(vr_indice_bordero).vr_cdbccxlt := rw_crapbdc.cdbccxlt;
      vr_tab_bordero(vr_indice_bordero).vr_nrdolote := rw_crapbdc.nrdolote;
      vr_tab_bordero(vr_indice_bordero).vr_dtlibbdc := rw_crapbdc.dtlibbdc;
      vr_tab_bordero(vr_indice_bordero).vr_cdoperad := greatest(rw_crapbdc.cdoperad, nvl(vr_tab_bordero(vr_indice_bordero).vr_cdoperad, ' '));
      vr_tab_bordero(vr_indice_bordero).vr_nmprimtl := rw_crapbdc.nmprimtl;
      -- Pj470 - SM2 -- MArcelo Telles Coelho -- Mouts
      -- Verificar o tipo de autorização feita para a contrato
      cntr0001.pc_ver_protocolo_ctd(pr_cdcooper        => pr_cdcooper
                                   ,pr_nrdconta        => rw_crapbdc.nrdconta
                                   ,pr_tpcontrato      => 27 -- Limite de Desc. Chq. (Contrato)
                                   ,pr_dtmvtolt        => rw_crapbdc.dtmvtolt
                                   ,pr_cdrecid_crapcdc => NULL
                                   ,pr_nrdocmto        => rw_crapbdc.nrctrlim
                                   ,pr_idexiste        => vr_idexiste
                                   ,pr_dscritic        => vr_dscritic);
      IF vr_idexiste = 1 THEN
	      vr_tab_bordero(vr_indice_bordero).vr_formalizacao := 'DIGITAL';
      ELSE
	      vr_tab_bordero(vr_indice_bordero).vr_formalizacao := 'FISICO';
      END IF;
      -- Fim Pj470 - SM2
    end loop;
    -- Descontos de titulos
    for rw_crapbdt in cr_crapbdt loop
      vr_indice_bordero := to_char(rw_crapbdt.cdagenci, 'fm000')||to_char(rw_crapbdt.nrborder, 'fm0000000000')||to_char(rw_crapbdt.nrctrlim, 'fm0000000000');
      vr_tab_bordero(vr_indice_bordero).vr_tpctrlim := 2; -- Desconto de título
      vr_tab_bordero(vr_indice_bordero).vr_nrctrlim := rw_crapbdt.nrctrlim;
      vr_tab_bordero(vr_indice_bordero).vr_nrborder := rw_crapbdt.nrborder;
      vr_tab_bordero(vr_indice_bordero).vr_nrdconta := rw_crapbdt.nrdconta;
      vr_tab_bordero(vr_indice_bordero).vr_vldocmto := nvl(vr_tab_bordero(vr_indice_bordero).vr_vldocmto, 0) + rw_crapbdt.vltitulo;
      vr_tab_bordero(vr_indice_bordero).vr_dtmvtolt := rw_crapbdt.dtmvtolt;
      vr_tab_bordero(vr_indice_bordero).vr_cdagenci := rw_crapbdt.cdagenci;
      vr_tab_bordero(vr_indice_bordero).vr_cdbccxlt := rw_crapbdt.cdbccxlt;
      vr_tab_bordero(vr_indice_bordero).vr_nrdolote := rw_crapbdt.nrdolote;
      vr_tab_bordero(vr_indice_bordero).vr_dtlibbdc := rw_crapbdt.dtlibbdt;
      vr_tab_bordero(vr_indice_bordero).vr_cdoperad := greatest(rw_crapbdt.cdoperad, nvl(vr_tab_bordero(vr_indice_bordero).vr_cdoperad, ' '));
      vr_tab_bordero(vr_indice_bordero).vr_nmprimtl := rw_crapbdt.nmprimtl;
      -- Pj470 - SM2 -- MArcelo Telles Coelho -- Mouts
      -- Verificar o tipo de autorização feita para a contrato
      cntr0001.pc_ver_protocolo_ctd(pr_cdcooper        => pr_cdcooper
                                   ,pr_nrdconta        => rw_crapbdt.nrdconta
                                   ,pr_tpcontrato      => 28 -- Limite de Desc. Tit. (Contrato)
                                   ,pr_dtmvtolt        => rw_crapbdt.dtmvtolt
                                   ,pr_cdrecid_crapcdc => NULL
                                   ,pr_nrdocmto        => rw_crapbdt.nrctrlim
                                   ,pr_idexiste        => vr_idexiste
                                   ,pr_dscritic        => vr_dscritic);
      IF vr_idexiste = 1 THEN
	      vr_tab_bordero(vr_indice_bordero).vr_formalizacao := 'DIGITAL';        
      ELSE
	      vr_tab_bordero(vr_indice_bordero).vr_formalizacao := 'FISICO';
      END IF;
      -- Fim Pj470 - SM2
    end loop;
  END pc_grava_borderos;

  -- Inclui informações de limite de crédito na vr_tab_geral e vr_tab_geral2
  PROCEDURE pc_limite_credito (pr_cdcooper in craplim.cdcooper%type,
                            pr_dtmvtolt in craplim.dtinivig%type,
                            pr_vllimcre in craplim.vllimite%type) IS
    cursor cr_craplim (pr_tipo in varchar2) is
      select craplim.nrdconta,
             craplim.nrctrlim,
             craplim.cdoperad,
             craplim.vllimite,
             craplim.cdopelib,
             craplim.dtinivig,
             craplim.cdcooper,
             crapass.cdagenci,
             crapass.nmprimtl
        from craplim,
             crapage,
             crapass
       where crapage.cdcooper = pr_cdcooper
         and crapass.cdcooper = crapage.cdcooper
         and crapass.cdagenci = crapage.cdagenci
         and craplim.cdcooper = crapage.cdcooper
         and craplim.nrdconta = crapass.nrdconta
         and craplim.dtinivig = pr_dtmvtolt
         and craplim.tpctrlim = 1 /*Chq.Esp.*/
         and craplim.insitlim = 2 /*Ativo*/
         and (   (    pr_tipo = 'MENOR'
                  and craplim.vllimite < pr_vllimcre)
              or (    pr_tipo = 'MAIOR'
                  and craplim.vllimite >= pr_vllimcre));
                  
    CURSOR cr_crapope (pr_cdcooper IN crapope.cdcooper%TYPE
                      ,pr_cdoperad IN crapope.cdoperad%TYPE) IS
    SELECT ope.cdpactra
      FROM crapope ope
     WHERE ope.cdcooper = pr_cdcooper
       AND upper(ope.cdoperad) = upper(pr_cdoperad);
     rw_crapope cr_crapope%ROWTYPE;     
     
     -- Variaveis locais
     vr_cdagenci crapage.cdagenci%TYPE;
      
  BEGIN
    -- valores menores que a tabela
    vr_dsrelato := 'LIMITES DE CREDITO';
    vr_desvalor := 'LIMITES ATE R$ '||to_char(pr_vllimcre - 0.01,'fm999G990D00');
    for rw_craplim in cr_craplim ('MENOR') LOOP
    
      -- Buscar agencia de trabalho do operador
      OPEN cr_crapope(pr_cdcooper => rw_craplim.cdcooper,
                      pr_cdoperad => rw_craplim.cdopelib);
      FETCH cr_crapope INTO rw_crapope;
      
      -- Se encontrou operador, deverá buscar o pac de trabalho do mesmo
      IF cr_crapope%FOUND THEN
        CLOSE cr_crapope;
        vr_cdagenci := rw_crapope.cdpactra;
      ELSE
        CLOSE cr_crapope;
        vr_cdagenci := 0;
      END IF;
      
      -- Inclui na primeira tabela, ordenada por agencia
      vr_indice_geral := to_char(vr_cdagenci, 'fm00000')||'4'||'1'||'00000'||to_char(rw_craplim.nrdconta, 'fm0000000000')||to_char(rw_craplim.nrctrlim, 'fm0000000000')||'0000000000';
      vr_tab_geral(vr_indice_geral).vr_cdagenci := vr_cdagenci;
      vr_tab_geral(vr_indice_geral).vr_dtmvtolt := rw_craplim.dtinivig;
      vr_tab_geral(vr_indice_geral).vr_nrdconta := rw_craplim.nrdconta;
      vr_tab_geral(vr_indice_geral).vr_nrctremp := rw_craplim.nrctrlim;
      vr_tab_geral(vr_indice_geral).vr_nmprimtl := rw_craplim.nmprimtl;
      vr_tab_geral(vr_indice_geral).vr_vlemprst := rw_craplim.vllimite;
      vr_tab_geral(vr_indice_geral).vr_flgcontr := 4;
      vr_tab_geral(vr_indice_geral).vr_flgvalor := 1;
      vr_tab_geral(vr_indice_geral).vr_cdoperad := rw_craplim.cdoperad;
      vr_tab_geral(vr_indice_geral).vr_dsrlgera := vr_dsrelato;
      vr_tab_geral(vr_indice_geral).vr_vlrgeral := vr_desvalor;
      vr_tab_geral(vr_indice_geral).vr_cdpesqbb := to_char(rw_craplim.dtinivig, 'dd/mm/yy')||'-'||
                                                   to_char(vr_cdagenci);
      -- Inclui na segunda tabela, ordenada pelos indicadores e depois por agencia e conta
      vr_indice_geral2 := '4'||'1'||'00000'||to_char(vr_cdagenci, 'fm00000')||to_char(rw_craplim.nrdconta, 'fm0000000000')||to_char(rw_craplim.vllimite, 'fm0000000000000000000000000')||to_char(rw_craplim.nrctrlim, 'fm0000000000')||'0000000000';
      vr_tab_geral2(vr_indice_geral2).vr_cdagenci := vr_cdagenci;
      vr_tab_geral2(vr_indice_geral2).vr_dtmvtolt := rw_craplim.dtinivig;
      vr_tab_geral2(vr_indice_geral2).vr_nrdconta := rw_craplim.nrdconta;
      vr_tab_geral2(vr_indice_geral2).vr_nrctremp := rw_craplim.nrctrlim;
      vr_tab_geral2(vr_indice_geral2).vr_nmprimtl := rw_craplim.nmprimtl;
      vr_tab_geral2(vr_indice_geral2).vr_vlemprst := rw_craplim.vllimite;
      vr_tab_geral2(vr_indice_geral2).vr_flgcontr := 4;
      vr_tab_geral2(vr_indice_geral2).vr_flgvalor := 1;
      vr_tab_geral2(vr_indice_geral2).vr_cdoperad := rw_craplim.cdoperad;
      vr_tab_geral2(vr_indice_geral2).vr_dsrlgera := vr_dsrelato;
      vr_tab_geral2(vr_indice_geral2).vr_vlrgeral := vr_desvalor;
      vr_tab_geral2(vr_indice_geral2).vr_cdpesqbb := to_char(rw_craplim.dtinivig, 'dd/mm/yy')||'-'||
                                                     to_char(vr_cdagenci);
      -- Pj470 - SM2 -- MArcelo Telles Coelho -- Mouts
      -- Verificar o tipo de autorização feita para a contrato
      cntr0001.pc_ver_protocolo_ctd(pr_cdcooper        => pr_cdcooper
                                   ,pr_nrdconta        => rw_craplim.nrdconta
                                   ,pr_tpcontrato      => 29 -- Limite de Crédito (Contrato)
                                   ,pr_dtmvtolt        => rw_craplim.dtinivig
                                   ,pr_cdrecid_crapcdc => NULL
                                   ,pr_nrdocmto        => rw_craplim.nrctrlim
                                   ,pr_idexiste        => vr_idexiste
                                   ,pr_dscritic        => vr_dscritic);
      IF vr_idexiste = 1 THEN
	      vr_tab_geral(vr_indice_geral).vr_formalizacao   := 'DIGITAL';        
	      vr_tab_geral2(vr_indice_geral2).vr_formalizacao := 'DIGITAL';        
      ELSE
	      vr_tab_geral(vr_indice_geral).vr_formalizacao   := 'FISICO';
	      vr_tab_geral2(vr_indice_geral2).vr_formalizacao := 'FISICO';
      END IF;
      -- Fim Pj470 - SM2
    end loop;
    
    -- valores maiores que a tabela
    vr_dsrelato := 'LIMITES DE CREDITO';
    vr_desvalor := 'CONTRATOS ACIMA R$ '||to_char(pr_vllimcre,'fm999G990D00')||' INCLUSIVE';
    for rw_craplim in cr_craplim ('MAIOR') LOOP
      
      -- Buscar agencia de trabalho do operador
      OPEN cr_crapope(pr_cdcooper => rw_craplim.cdcooper,
                      pr_cdoperad => rw_craplim.cdopelib);
      FETCH cr_crapope INTO rw_crapope;
      
      -- Se encontrou operador, deverá buscar o pac de trabalho do mesmo
      IF cr_crapope%FOUND THEN
        CLOSE cr_crapope;
        vr_cdagenci := rw_crapope.cdpactra;
      ELSE
        CLOSE cr_crapope;
        vr_cdagenci := 0;
      END IF;
    
      -- Inclui na primeira tabela, ordenada por agencia
      vr_indice_geral := to_char(vr_cdagenci, 'fm00000')||'4'||'2'||'00000'||to_char(rw_craplim.nrdconta, 'fm0000000000')||to_char(rw_craplim.nrctrlim, 'fm0000000000')||'0000000000';
      vr_tab_geral(vr_indice_geral).vr_cdagenci := vr_cdagenci;
      vr_tab_geral(vr_indice_geral).vr_dtmvtolt := rw_craplim.dtinivig;
      vr_tab_geral(vr_indice_geral).vr_nrdconta := rw_craplim.nrdconta;
      vr_tab_geral(vr_indice_geral).vr_nrctremp := rw_craplim.nrctrlim;
      vr_tab_geral(vr_indice_geral).vr_nmprimtl := rw_craplim.nmprimtl;
      vr_tab_geral(vr_indice_geral).vr_vlemprst := rw_craplim.vllimite;
      vr_tab_geral(vr_indice_geral).vr_flgcontr := 4;
      vr_tab_geral(vr_indice_geral).vr_flgvalor := 2;
      vr_tab_geral(vr_indice_geral).vr_cdoperad := rw_craplim.cdoperad;
      vr_tab_geral(vr_indice_geral).vr_dsrlgera := vr_dsrelato;
      vr_tab_geral(vr_indice_geral).vr_vlrgeral := vr_desvalor;
      vr_tab_geral(vr_indice_geral).vr_cdpesqbb := to_char(rw_craplim.dtinivig, 'dd/mm/yy')||'-'||
                                                   to_char(vr_cdagenci);
      -- Inclui na segunda tabela, ordenada pelos indicadores e depois por agencia e conta
      vr_indice_geral2 := '4'||'2'||'00000'||to_char(vr_cdagenci, 'fm00000')||to_char(rw_craplim.nrdconta, 'fm0000000000')||to_char(rw_craplim.vllimite, 'fm0000000000000000000000000')||to_char(rw_craplim.nrctrlim, 'fm0000000000')||'0000000000';
      vr_tab_geral2(vr_indice_geral2).vr_cdagenci := vr_cdagenci;
      vr_tab_geral2(vr_indice_geral2).vr_dtmvtolt := rw_craplim.dtinivig;
      vr_tab_geral2(vr_indice_geral2).vr_nrdconta := rw_craplim.nrdconta;
      vr_tab_geral2(vr_indice_geral2).vr_nrctremp := rw_craplim.nrctrlim;
      vr_tab_geral2(vr_indice_geral2).vr_nmprimtl := rw_craplim.nmprimtl;
      vr_tab_geral2(vr_indice_geral2).vr_vlemprst := rw_craplim.vllimite;
      vr_tab_geral2(vr_indice_geral2).vr_flgcontr := 4;
      vr_tab_geral2(vr_indice_geral2).vr_flgvalor := 2;
      vr_tab_geral2(vr_indice_geral2).vr_cdoperad := rw_craplim.cdoperad;
      vr_tab_geral2(vr_indice_geral2).vr_dsrlgera := vr_dsrelato;
      vr_tab_geral2(vr_indice_geral2).vr_vlrgeral := vr_desvalor;
      vr_tab_geral2(vr_indice_geral2).vr_cdpesqbb := to_char(rw_craplim.dtinivig, 'dd/mm/yy')||'-'||
                                                     to_char(vr_cdagenci);
      -- Pj470 - SM2 -- MArcelo Telles Coelho -- Mouts
      -- Verificar o tipo de autorização feita para a contrato
      cntr0001.pc_ver_protocolo_ctd(pr_cdcooper        => pr_cdcooper
                                   ,pr_nrdconta        => rw_craplim.nrdconta
                                   ,pr_tpcontrato      => 29 -- Limite de Crédito (Contrato)
                                   ,pr_dtmvtolt        => rw_craplim.dtinivig
                                   ,pr_cdrecid_crapcdc => NULL
                                   ,pr_nrdocmto        => rw_craplim.nrctrlim
                                   ,pr_idexiste        => vr_idexiste
                                   ,pr_dscritic        => vr_dscritic);
      IF vr_idexiste = 1 THEN
	      vr_tab_geral(vr_indice_geral).vr_formalizacao   := 'DIGITAL';        
	      vr_tab_geral2(vr_indice_geral2).vr_formalizacao := 'DIGITAL';        
      ELSE
	      vr_tab_geral(vr_indice_geral).vr_formalizacao   := 'FISICO';
	      vr_tab_geral2(vr_indice_geral2).vr_formalizacao := 'FISICO';
      END IF;
      -- Fim Pj470 - SM2
    end loop;
  END pc_limite_credito;

  -- Inclui informações de limite de cartão de crédito na vr_tab_geral e vr_tab_geral2
  PROCEDURE pc_limite_cartao_cred (pr_cdcooper in crawcrd.cdcooper%type,
                                pr_dtmvtolt in crawcrd.dtentreg%type,
                                pr_vllimcre in craptlc.vllimcrd%type) IS
    cursor cr_crawcrd (pr_tipo in varchar2) is
      select crawcrd.nrdconta,
             crawcrd.nrctrcrd,
             crawcrd.cdoperad,
             crawcrd.cdagenci,
             craptlc.vllimcrd,
             crapass.nmprimtl
        from craptlc,
             crawcrd,
             crapage,
             crapass
       where crapage.cdcooper = pr_cdcooper
         and crapass.cdcooper = crapage.cdcooper
         and crapass.cdagenci = crapage.cdagenci
         and crawcrd.cdcooper = crapage.cdcooper
         and crawcrd.nrdconta = crapass.nrdconta
         and crawcrd.dtentreg = pr_dtmvtolt
         and crawcrd.insitcrd = 4  -- em uso
         and craptlc.cdcooper = crawcrd.cdcooper
         and craptlc.cdadmcrd = crawcrd.cdadmcrd
         and craptlc.tpcartao = crawcrd.tpcartao
         and craptlc.cdlimcrd = crawcrd.cdlimcrd
         and craptlc.dddebito = 0
         and (   (    pr_tipo = 'MENOR'
                  and craptlc.vllimcrd < pr_vllimcre)
              or (    pr_tipo = 'MAIOR'
                  and craptlc.vllimcrd >= pr_vllimcre));
  BEGIN
    -- valores menores que a tabela
    vr_dsrelato := 'LIMITES DE CARTAO DE CREDITO';
    vr_desvalor := 'LIMITES ATE R$ '||to_char(pr_vllimcre - 0.01,'fm999G990D00');
    for rw_crawcrd in cr_crawcrd ('MENOR') loop
      -- Inclui na primeira tabela, ordenada por agencia
      vr_indice_geral := to_char(rw_crawcrd.cdagenci, 'fm00000')||'5'||'1'||'00000'||to_char(rw_crawcrd.nrdconta, 'fm0000000000')||to_char(rw_crawcrd.nrctrcrd, 'fm0000000000')||'0000000000';
      vr_tab_geral(vr_indice_geral).vr_cdagenci := rw_crawcrd.cdagenci;
      vr_tab_geral(vr_indice_geral).vr_dtmvtolt := pr_dtmvtolt;
      vr_tab_geral(vr_indice_geral).vr_nrdconta := rw_crawcrd.nrdconta;
      vr_tab_geral(vr_indice_geral).vr_nrctremp := rw_crawcrd.nrctrcrd;
      vr_tab_geral(vr_indice_geral).vr_nmprimtl := rw_crawcrd.nmprimtl;
      vr_tab_geral(vr_indice_geral).vr_vlemprst := rw_crawcrd.vllimcrd;
      vr_tab_geral(vr_indice_geral).vr_flgcontr := 5;
      vr_tab_geral(vr_indice_geral).vr_flgvalor := 1;
      vr_tab_geral(vr_indice_geral).vr_cdoperad := rw_crawcrd.cdoperad;
      vr_tab_geral(vr_indice_geral).vr_dsrlgera := vr_dsrelato;
      vr_tab_geral(vr_indice_geral).vr_vlrgeral := vr_desvalor;
      -- Inclui na segunda tabela, ordenada pelos indicadores e depois por agencia e conta
      vr_indice_geral2 := '5'||'1'||'00000'||to_char(rw_crawcrd.cdagenci, 'fm00000')||to_char(rw_crawcrd.nrdconta, 'fm0000000000')||to_char(rw_crawcrd.vllimcrd, 'fm0000000000000000000000000')||to_char(rw_crawcrd.nrctrcrd, 'fm0000000000')||'0000000000';
      vr_tab_geral2(vr_indice_geral2).vr_cdagenci := rw_crawcrd.cdagenci;
      vr_tab_geral2(vr_indice_geral2).vr_dtmvtolt := pr_dtmvtolt;
      vr_tab_geral2(vr_indice_geral2).vr_nrdconta := rw_crawcrd.nrdconta;
      vr_tab_geral2(vr_indice_geral2).vr_nrctremp := rw_crawcrd.nrctrcrd;
      vr_tab_geral2(vr_indice_geral2).vr_nmprimtl := rw_crawcrd.nmprimtl;
      vr_tab_geral2(vr_indice_geral2).vr_vlemprst := rw_crawcrd.vllimcrd;
      vr_tab_geral2(vr_indice_geral2).vr_flgcontr := 5;
      vr_tab_geral2(vr_indice_geral2).vr_flgvalor := 1;
      vr_tab_geral2(vr_indice_geral2).vr_cdoperad := rw_crawcrd.cdoperad;
      vr_tab_geral2(vr_indice_geral2).vr_dsrlgera := vr_dsrelato;
      vr_tab_geral2(vr_indice_geral2).vr_vlrgeral := vr_desvalor;
      -- Pj470 - SM2 -- MArcelo Telles Coelho -- Mouts
      -- Verificar o tipo de autorização feita para a contrato
      vr_tab_geral(vr_indice_geral).vr_formalizacao   := 'FISICO';
      vr_tab_geral2(vr_indice_geral2).vr_formalizacao := 'FISICO';
      -- Fim Pj470 - SM2
    end loop;
    -- valores maiores que a tabela
    vr_dsrelato := 'LIMITES DE CARTAO DE CREDITO';
    vr_desvalor := 'CONTRATOS ACIMA R$ '||to_char(pr_vllimcre,'fm999G990D00')||' INCLUSIVE';
    for rw_crawcrd in cr_crawcrd ('MAIOR') loop
      -- Inclui na primeira tabela, ordenada por agencia
      vr_indice_geral := to_char(rw_crawcrd.cdagenci, 'fm00000')||'5'||'2'||'00000'||to_char(rw_crawcrd.nrdconta, 'fm0000000000')||to_char(rw_crawcrd.nrctrcrd, 'fm0000000000')||'0000000000';
      vr_tab_geral(vr_indice_geral).vr_cdagenci := rw_crawcrd.cdagenci;
      vr_tab_geral(vr_indice_geral).vr_dtmvtolt := pr_dtmvtolt;
      vr_tab_geral(vr_indice_geral).vr_nrdconta := rw_crawcrd.nrdconta;
      vr_tab_geral(vr_indice_geral).vr_nrctremp := rw_crawcrd.nrctrcrd;
      vr_tab_geral(vr_indice_geral).vr_nmprimtl := rw_crawcrd.nmprimtl;
      vr_tab_geral(vr_indice_geral).vr_vlemprst := rw_crawcrd.vllimcrd;
      vr_tab_geral(vr_indice_geral).vr_flgcontr := 5;
      vr_tab_geral(vr_indice_geral).vr_flgvalor := 2;
      vr_tab_geral(vr_indice_geral).vr_cdoperad := rw_crawcrd.cdoperad;
      vr_tab_geral(vr_indice_geral).vr_dsrlgera := vr_dsrelato;
      vr_tab_geral(vr_indice_geral).vr_vlrgeral := vr_desvalor;
      -- Inclui na segunda tabela, ordenada pelos indicadores e depois por agencia e conta
      vr_indice_geral2 := '5'||'2'||'00000'||to_char(rw_crawcrd.cdagenci, 'fm00000')||to_char(rw_crawcrd.nrdconta, 'fm0000000000')||to_char(rw_crawcrd.vllimcrd, 'fm0000000000000000000000000')||to_char(rw_crawcrd.nrctrcrd, 'fm0000000000')||'0000000000';
      vr_tab_geral2(vr_indice_geral2).vr_cdagenci := rw_crawcrd.cdagenci;
      vr_tab_geral2(vr_indice_geral2).vr_dtmvtolt := pr_dtmvtolt;
      vr_tab_geral2(vr_indice_geral2).vr_nrdconta := rw_crawcrd.nrdconta;
      vr_tab_geral2(vr_indice_geral2).vr_nrctremp := rw_crawcrd.nrctrcrd;
      vr_tab_geral2(vr_indice_geral2).vr_nmprimtl := rw_crawcrd.nmprimtl;
      vr_tab_geral2(vr_indice_geral2).vr_vlemprst := rw_crawcrd.vllimcrd;
      vr_tab_geral2(vr_indice_geral2).vr_flgcontr := 5;
      vr_tab_geral2(vr_indice_geral2).vr_flgvalor := 2;
      vr_tab_geral2(vr_indice_geral2).vr_cdoperad := rw_crawcrd.cdoperad;
      vr_tab_geral2(vr_indice_geral2).vr_dsrlgera := vr_dsrelato;
      vr_tab_geral2(vr_indice_geral2).vr_vlrgeral := vr_desvalor;
      -- Pj470 - SM2 -- MArcelo Telles Coelho -- Mouts
      -- Verificar o tipo de autorização feita para a contrato
      vr_tab_geral(vr_indice_geral).vr_formalizacao   := 'FISICO';
      vr_tab_geral2(vr_indice_geral2).vr_formalizacao := 'FISICO';
      -- Fim Pj470 - SM2
    end loop;
  END pc_limite_cartao_cred;

  -- Inclui informações de empréstimos na vr_tab_geral e vr_tab_geral2
  PROCEDURE pc_processa_emprestimos (pr_cdcooper in crapepr.cdcooper%type,
                                  pr_dtmvtolt in crapepr.dtmvtolt%type,
                                  pr_vlini in crapepr.vlemprst%type,
                                  pr_vlfim in crapepr.vlemprst%type) IS
    cursor cr_crapepr (pr_cdcooper in crapepr.cdcooper%type,
                       pr_dtmvtolt in crapepr.dtmvtolt%type,
                       pr_tipo in varchar2,
                       pr_vlini in crapepr.vlemprst%type,
                       pr_vlfim in crapepr.vlemprst%type) is
      select /*+ index (crapepr crapepr##crapepr1)*/
             cdcooper,
             dtmvtolt,
             cdagenci,
             cdbccxlt,
             nrdolote,
             nrdconta,
             nrctremp,
             vlemprst,
             tpemprst,
             cdlcremp,
             cdopeori
        from crapepr
       where crapepr.cdcooper = pr_cdcooper
         and crapepr.dtmvtolt = pr_dtmvtolt
		 and crapepr.cdorigem not in (3,4,10) -- (3) Internet / (4) TAA / (10) MOBILE
         and (   (    pr_tipo = 'MENOR'
                  and crapepr.vlemprst < pr_vlini)
              or (    pr_tipo = 'ENTRE'
                  and crapepr.vlemprst >= pr_vlini
                  and crapepr.vlemprst < pr_vlfim)
              or (    pr_tipo = 'MAIOR'
                  and crapepr.vlemprst >= pr_vlfim));
    --
  BEGIN
    vr_dsrelato := 'CONTRATOS EMPRESTIMOS';
    --
    for rw_crapepr in cr_crapepr (pr_cdcooper,
                                  pr_dtmvtolt,
                                  'MENOR',
                                  pr_vlini,
                                  pr_vlfim) loop
      -- Busca as linhas de credito que nao devem possuir analise
      vr_dslinhas := ';'||
                     gene0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                               pr_cdcooper =>  0,
                                               pr_cdacesso => 'CREDITO_BANCOOB')||
                     ';';

      -- Verifica se a linha de credito atual esta parametrizada para nao ser processada
      IF instr(vr_dslinhas,';'||rw_crapepr.cdlcremp||';') > 0 THEN
        -- busca proximo contrato
        continue;
      END IF;

      -- Nao listar emprestimos CDC migrados atraves da integracao CDC
      IF rw_crapepr.cdopeori='AUTOCDC' THEN
        continue;
      END IF;

      open cr_craplot (pr_cdcooper,
                       pr_dtmvtolt,
                       rw_crapepr.cdagenci,
                       rw_crapepr.cdbccxlt,
                       rw_crapepr.nrdolote,
                       null);
        fetch cr_craplot into rw_craplot;
        --
        if cr_craplot%found then
        	if rw_craplot.tplotmov not in (4, 5) then
               close cr_craplot;
               continue;
          end if;
          open cr_crapass2 (pr_cdcooper,
                            rw_crapepr.nrdconta);
            fetch cr_crapass2 into rw_crapass2;
            --
            if cr_crapass2%notfound then
              close cr_crapass2;
              pr_cdcritic := 9;
              pr_dscritic := gene0001.fn_busca_critica(9);
              btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                         pr_ind_tipo_log => 2, -- Erro tratado
                                         pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                            || vr_cdprogra || ' --> '
                                                            || pr_dscritic,
                                         pr_nmarqlog     => vr_cdprogra);
              close cr_craplot;
              continue;
            end if;
            --
            vr_desvalor := 'CONTRATOS ATE R$ '||to_char(pr_vlini - 0.01, 'fm999G999G990D00');
            -- Inclui na primeira tabela, ordenada por agencia
            vr_indice_geral := to_char(rw_crapepr.cdagenci, 'fm00000')||'1'||'1'||TO_CHAR(rw_crapepr.tpemprst,'fm00000')||to_char(rw_crapepr.nrdconta, 'fm0000000000')||to_char(rw_crapepr.nrctremp, 'fm0000000000')||'0000000000';
            vr_tab_geral(vr_indice_geral).vr_cdagenci := rw_crapepr.cdagenci;
            vr_tab_geral(vr_indice_geral).vr_nrdconta := rw_crapepr.nrdconta;
            vr_tab_geral(vr_indice_geral).vr_nrctremp := rw_crapepr.nrctremp;
            vr_tab_geral(vr_indice_geral).vr_nmprimtl := rw_crapass2.nmprimtl;
            vr_tab_geral(vr_indice_geral).vr_vlemprst := rw_crapepr.vlemprst;
            vr_tab_geral(vr_indice_geral).vr_flgcontr := 1;
            vr_tab_geral(vr_indice_geral).vr_flgvalor := 1;
            vr_tab_geral(vr_indice_geral).vr_cdoperad := rw_craplot.cdoperad;
            vr_tab_geral(vr_indice_geral).vr_dsrlgera := vr_dsrelato;
            vr_tab_geral(vr_indice_geral).vr_vlrgeral := vr_desvalor;
            vr_tab_geral(vr_indice_geral).vr_dtmvtolt := rw_crapepr.dtmvtolt;
            vr_tab_geral(vr_indice_geral).vr_nrdolote := rw_crapepr.nrdolote;
            vr_tab_geral(vr_indice_geral).vr_cdbccxlt := rw_crapepr.cdbccxlt;
            vr_tab_geral(vr_indice_geral).vr_cdpesqbb := to_char(rw_crapepr.dtmvtolt, 'dd/mm/yy')||'-'||
                                                         to_char(rw_crapepr.cdagenci)||'-'||
                                                         to_char(rw_crapepr.cdbccxlt)||'-'||
                                                         to_char(rw_crapepr.nrdolote);
            vr_tab_geral(vr_indice_geral).vr_tpemprst := rw_crapepr.tpemprst;
            -- Se o tipo do empréstimo for igual a zero
            IF rw_crapepr.tpemprst = 0 THEN
              vr_tab_geral(vr_indice_geral).vr_dsemprst := 'CONTRATOS PRICE TR';
            ELSIF rw_crapepr.tpemprst = 1 THEN
              vr_tab_geral(vr_indice_geral).vr_dsemprst := 'CONTRATOS PRICE PRE FIXADO';
            ELSIF rw_crapepr.tpemprst = 2 THEN
              vr_tab_geral(vr_indice_geral).vr_dsemprst := 'CONTRATOS PRICE POS FIXADO';
            END IF;
            -- Inclui na segunda tabela, ordenada pelos indicadores e depois por agencia e conta
            vr_indice_geral2 := '1'||'1'||TO_CHAR(rw_crapepr.tpemprst,'fm00000')||to_char(rw_crapepr.cdagenci, 'fm00000')||to_char(rw_crapepr.nrdconta, 'fm0000000000')||to_char(rw_crapepr.vlemprst, 'fm0000000000000000000000000')||to_char(rw_crapepr.nrctremp, 'fm0000000000')||'0000000000';
            vr_tab_geral2(vr_indice_geral2).vr_cdagenci := rw_crapepr.cdagenci;
            vr_tab_geral2(vr_indice_geral2).vr_nrdconta := rw_crapepr.nrdconta;
            vr_tab_geral2(vr_indice_geral2).vr_nrctremp := rw_crapepr.nrctremp;
            vr_tab_geral2(vr_indice_geral2).vr_nmprimtl := rw_crapass2.nmprimtl;
            vr_tab_geral2(vr_indice_geral2).vr_vlemprst := rw_crapepr.vlemprst;
            vr_tab_geral2(vr_indice_geral2).vr_flgcontr := 1;
            vr_tab_geral2(vr_indice_geral2).vr_flgvalor := 1;
            vr_tab_geral2(vr_indice_geral2).vr_cdoperad := rw_craplot.cdoperad;
            vr_tab_geral2(vr_indice_geral2).vr_dsrlgera := vr_dsrelato;
            vr_tab_geral2(vr_indice_geral2).vr_vlrgeral := vr_desvalor;
            vr_tab_geral2(vr_indice_geral2).vr_dtmvtolt := rw_crapepr.dtmvtolt;
            vr_tab_geral2(vr_indice_geral2).vr_nrdolote := rw_crapepr.nrdolote;
            vr_tab_geral2(vr_indice_geral2).vr_cdbccxlt := rw_crapepr.cdbccxlt;
            vr_tab_geral2(vr_indice_geral2).vr_cdpesqbb := to_char(rw_crapepr.dtmvtolt, 'dd/mm/yy')||'-'||
                                                           to_char(rw_crapepr.cdagenci)||'-'||
                                                           to_char(rw_crapepr.cdbccxlt)||'-'||
                                                           to_char(rw_crapepr.nrdolote);
            vr_tab_geral2(vr_indice_geral2).vr_tpemprst := rw_crapepr.tpemprst;
            -- Se o tipo do empréstimo for igual a zero
            IF rw_crapepr.tpemprst = 0 THEN
              vr_tab_geral2(vr_indice_geral2).vr_dsemprst := 'CONTRATOS PRICE TR';
            ELSIF rw_crapepr.tpemprst = 1 THEN
              vr_tab_geral2(vr_indice_geral2).vr_dsemprst := 'CONTRATOS PRICE PRE FIXADO';
            ELSIF rw_crapepr.tpemprst = 2 THEN
              vr_tab_geral2(vr_indice_geral2).vr_dsemprst := 'CONTRATOS PRICE POS FIXADO';
            END IF;
          close cr_crapass2;
          -- Pj470 - SM2 -- MArcelo Telles Coelho -- Mouts
          -- Verificar se o emprestimo é de portabilidade
          EMPR0006.pc_possui_portabilidade(pr_cdcooper => pr_cdcooper
                                          ,pr_nrdconta => rw_crapepr.nrdconta
                                          ,pr_nrctremp => rw_crapepr.nrctremp
                                          ,pr_err_efet => vr_err_efet
                                          ,pr_des_reto => vr_des_reto
                                          ,pr_cdcritic => vr_cdcritic
                                          ,pr_dscritic => vr_dscritic);
          IF vr_des_reto = 'S' THEN
            -- Verificar o tipo de autorização feita para a contrato
            cntr0001.pc_ver_protocolo_ctd(pr_cdcooper        => pr_cdcooper
                                         ,pr_nrdconta        => rw_crapepr.nrdconta
                                         ,pr_tpcontrato      => 26 -- Solicitação de Portab. Créd. (Termo)
                                         ,pr_dtmvtolt        => rw_crapepr.dtmvtolt
                                         ,pr_cdrecid_crapcdc => NULL
                                         ,pr_nrdocmto        => rw_crapepr.nrctremp
                                         ,pr_idexiste        => vr_idexiste
                                         ,pr_dscritic        => vr_dscritic);
          ELSE
            vr_idexiste := 0;
          END IF;
          --
          IF vr_idexiste = 1 THEN
            vr_tab_geral(vr_indice_geral).vr_formalizacao   := 'DIGITAL';        
            vr_tab_geral2(vr_indice_geral2).vr_formalizacao := 'DIGITAL';        
          ELSE
            vr_tab_geral(vr_indice_geral).vr_formalizacao   := 'FISICO';
            vr_tab_geral2(vr_indice_geral2).vr_formalizacao := 'FISICO';
          END IF;
          -- Fim Pj470 - SM2
        end if;
      close cr_craplot;
    end loop;
    --
    for rw_crapepr in cr_crapepr (pr_cdcooper,
                                  pr_dtmvtolt,
                                  'ENTRE',
                                  pr_vlini,
                                  pr_vlfim) loop
      
      -- Busca as linhas de credito que nao devem possuir analise
      vr_dslinhas := ';'||
                     gene0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                               pr_cdcooper =>  0,
                                               pr_cdacesso => 'CREDITO_BANCOOB')||
                     ';';

      -- Verifica se a linha de credito atual esta parametrizada para nao ser processada
      IF instr(vr_dslinhas,';'||rw_crapepr.cdlcremp||';') > 0 THEN
        -- busca proximo contrato
        continue;
      END IF;
      
      -- Nao listar emprestimos CDC migrados atraves da integracao CDC
      IF rw_crapepr.cdopeori='AUTOCDC' THEN
        continue;
      END IF;
      
      open cr_craplot (pr_cdcooper,
                       pr_dtmvtolt,
                       rw_crapepr.cdagenci,
                       rw_crapepr.cdbccxlt,
                       rw_crapepr.nrdolote,
                       null);
        fetch cr_craplot into rw_craplot;
        --
        if cr_craplot%found then
          if rw_craplot.tplotmov not in (4, 5) then
             close cr_craplot;
             continue;
          end if;
          open cr_crapass2 (pr_cdcooper,
                            rw_crapepr.nrdconta);
            fetch cr_crapass2 into rw_crapass2;
            --
            if cr_crapass2%notfound then
              close cr_crapass2;
              pr_cdcritic := 9;
              pr_dscritic := gene0001.fn_busca_critica(9);
              btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                         pr_ind_tipo_log => 2, -- Erro tratado
                                         pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                            || vr_cdprogra || ' --> '
                                                            || pr_dscritic,
                                         pr_nmarqlog     => vr_cdprogra);
              close cr_craplot;
              continue;
            end if;
            -- Define os índices das tabelas, além de alguns campos que dependem do parâmetro cadastrado.
            if vr_vlfaixa2 = 999999.99 then
              vr_desvalor := 'CONTRATOS ACIMA R$ '||to_char(pr_vlini, 'fm999G990D00')||' INCLUSIVE';
              vr_indice_geral := to_char(rw_crapepr.cdagenci, 'fm00000')||'1'||'2'||TO_CHAR(rw_crapepr.tpemprst,'fm00000')||to_char(rw_crapepr.nrdconta, 'fm0000000000')||to_char(rw_crapepr.nrctremp, 'fm0000000000')||'0000000000';
              vr_indice_geral2 := '1'||'2'||TO_CHAR(rw_crapepr.tpemprst,'fm00000')||to_char(rw_crapepr.cdagenci, 'fm00000')||to_char(rw_crapepr.nrdconta, 'fm0000000000')||to_char(rw_crapepr.vlemprst, 'fm0000000000000000000000000')||to_char(rw_crapepr.nrctremp, 'fm0000000000')||'0000000000';
              vr_tab_geral(vr_indice_geral).vr_vlrgeral := vr_desvalor;
              vr_tab_geral(vr_indice_geral).vr_flgvalor := 2;
              vr_tab_geral2(vr_indice_geral2).vr_vlrgeral := vr_desvalor;
              vr_tab_geral2(vr_indice_geral2).vr_flgvalor := 2;
            else
              vr_desvalor := 'CONTRATOS DE R$ '||to_char(pr_vlini, 'fm999G990D00')||' ATE '||to_char(pr_vlfim - 0.01, 'fm999G990D00');
              vr_indice_geral := to_char(rw_crapepr.cdagenci, 'fm00000')||'1'||'3'||TO_CHAR(rw_crapepr.tpemprst,'fm00000')||to_char(rw_crapepr.nrdconta, 'fm0000000000')||to_char(rw_crapepr.nrctremp, 'fm0000000000')||'0000000000';
              vr_indice_geral2 := '1'||'3'||TO_CHAR(rw_crapepr.tpemprst,'fm00000')||to_char(rw_crapepr.cdagenci, 'fm00000')||to_char(rw_crapepr.nrdconta, 'fm0000000000')||to_char(rw_crapepr.vlemprst, 'fm0000000000000000000000000')||to_char(rw_crapepr.nrctremp, 'fm0000000000')||'0000000000';
              vr_tab_geral(vr_indice_geral).vr_vlrgeral := 'CONTRATOS ACIMA DE R$ '||to_char(pr_vlini, 'fm999G990D00')||' INCLUSIVE';
              vr_tab_geral(vr_indice_geral).vr_flgvalor := 3;
              vr_tab_geral2(vr_indice_geral2).vr_vlrgeral := 'CONTRATOS ACIMA DE R$ '||to_char(pr_vlini, 'fm999G990D00')||' INCLUSIVE';
              vr_tab_geral2(vr_indice_geral2).vr_flgvalor := 3;
            end if;
            -- Inclui na primeira tabela, ordenada por agencia
            vr_tab_geral(vr_indice_geral).vr_cdagenci := rw_crapepr.cdagenci;
            vr_tab_geral(vr_indice_geral).vr_nrdconta := rw_crapepr.nrdconta;
            vr_tab_geral(vr_indice_geral).vr_nrctremp := rw_crapepr.nrctremp;
            vr_tab_geral(vr_indice_geral).vr_nmprimtl := rw_crapass2.nmprimtl;
            vr_tab_geral(vr_indice_geral).vr_vlemprst := rw_crapepr.vlemprst;
            vr_tab_geral(vr_indice_geral).vr_flgcontr := 1;
            vr_tab_geral(vr_indice_geral).vr_cdoperad := rw_craplot.cdoperad;
            vr_tab_geral(vr_indice_geral).vr_dsrlgera := vr_dsrelato;
            vr_tab_geral(vr_indice_geral).vr_dtmvtolt := rw_crapepr.dtmvtolt;
            vr_tab_geral(vr_indice_geral).vr_nrdolote := rw_crapepr.nrdolote;
            vr_tab_geral(vr_indice_geral).vr_cdbccxlt := rw_crapepr.cdbccxlt;
            vr_tab_geral(vr_indice_geral).vr_cdpesqbb := to_char(rw_crapepr.dtmvtolt, 'dd/mm/yy')||'-'||
                                                         to_char(rw_crapepr.cdagenci)||'-'||
                                                         to_char(rw_crapepr.cdbccxlt)||'-'||
                                                         to_char(rw_crapepr.nrdolote);
            vr_tab_geral(vr_indice_geral).vr_tpemprst := rw_crapepr.tpemprst;
            -- Se o tipo do empréstimo for igual a zero
            IF rw_crapepr.tpemprst = 0 THEN
              vr_tab_geral(vr_indice_geral).vr_dsemprst := 'CONTRATOS PRICE TR';
            ELSIF rw_crapepr.tpemprst = 1 THEN
              vr_tab_geral(vr_indice_geral).vr_dsemprst := 'CONTRATOS PRICE PRE FIXADO';
            ELSIF rw_crapepr.tpemprst = 2 THEN
              vr_tab_geral(vr_indice_geral).vr_dsemprst := 'CONTRATOS PRICE POS FIXADO';
            END IF;
            -- Inclui na segunda tabela, ordenada pelos indicadores e depois por agencia e conta
            vr_tab_geral2(vr_indice_geral2).vr_cdagenci := rw_crapepr.cdagenci;
            vr_tab_geral2(vr_indice_geral2).vr_nrdconta := rw_crapepr.nrdconta;
            vr_tab_geral2(vr_indice_geral2).vr_nrctremp := rw_crapepr.nrctremp;
            vr_tab_geral2(vr_indice_geral2).vr_nmprimtl := rw_crapass2.nmprimtl;
            vr_tab_geral2(vr_indice_geral2).vr_vlemprst := rw_crapepr.vlemprst;
            vr_tab_geral2(vr_indice_geral2).vr_flgcontr := 1;
            vr_tab_geral2(vr_indice_geral2).vr_cdoperad := rw_craplot.cdoperad;
            vr_tab_geral2(vr_indice_geral2).vr_dsrlgera := vr_dsrelato;
            vr_tab_geral2(vr_indice_geral2).vr_dtmvtolt := rw_crapepr.dtmvtolt;
            vr_tab_geral2(vr_indice_geral2).vr_nrdolote := rw_crapepr.nrdolote;
            vr_tab_geral2(vr_indice_geral2).vr_cdbccxlt := rw_crapepr.cdbccxlt;
            vr_tab_geral2(vr_indice_geral2).vr_cdpesqbb := to_char(rw_crapepr.dtmvtolt, 'dd/mm/yy')||'-'||
                                                           to_char(rw_crapepr.cdagenci)||'-'||
                                                           to_char(rw_crapepr.cdbccxlt)||'-'||
                                                           to_char(rw_crapepr.nrdolote);
            vr_tab_geral2(vr_indice_geral2).vr_tpemprst := rw_crapepr.tpemprst;
            -- Se o tipo do empréstimo for igual a zero
            IF rw_crapepr.tpemprst = 0 THEN
              vr_tab_geral2(vr_indice_geral2).vr_dsemprst := 'CONTRATOS PRICE TR';
            ELSIF rw_crapepr.tpemprst = 1 THEN
              vr_tab_geral2(vr_indice_geral2).vr_dsemprst := 'CONTRATOS PRICE PRE FIXADO';
            ELSIF rw_crapepr.tpemprst = 2 THEN
              vr_tab_geral2(vr_indice_geral2).vr_dsemprst := 'CONTRATOS PRICE POS FIXADO';
            END IF;
          close cr_crapass2;
          -- Pj470 - SM2 -- MArcelo Telles Coelho -- Mouts
          -- Verificar se o emprestimo é de portabilidade
          EMPR0006.pc_possui_portabilidade(pr_cdcooper => pr_cdcooper
                                          ,pr_nrdconta => rw_crapepr.nrdconta
                                          ,pr_nrctremp => rw_crapepr.nrctremp
                                          ,pr_err_efet => vr_err_efet
                                          ,pr_des_reto => vr_des_reto
                                          ,pr_cdcritic => vr_cdcritic
                                          ,pr_dscritic => vr_dscritic);
          IF vr_des_reto = 'S' THEN
            -- Verificar o tipo de autorização feita para a contrato
            cntr0001.pc_ver_protocolo_ctd(pr_cdcooper        => pr_cdcooper
                                         ,pr_nrdconta        => rw_crapepr.nrdconta
                                         ,pr_tpcontrato      => 26 -- Solicitação de Portab. Créd. (Termo)
                                         ,pr_dtmvtolt        => rw_crapepr.dtmvtolt
                                         ,pr_cdrecid_crapcdc => NULL
                                         ,pr_nrdocmto        => rw_crapepr.nrctremp
                                         ,pr_idexiste        => vr_idexiste
                                         ,pr_dscritic        => vr_dscritic);
            IF vr_idexiste = 1 THEN
              vr_tab_geral(vr_indice_geral).vr_formalizacao   := 'DIGITAL';        
              vr_tab_geral2(vr_indice_geral2).vr_formalizacao := 'DIGITAL';        
            ELSE
              vr_tab_geral(vr_indice_geral).vr_formalizacao   := 'FISICO';
              vr_tab_geral2(vr_indice_geral2).vr_formalizacao := 'FISICO';
            END IF;
          END IF;
          -- Fim Pj470 - SM2
        end if;
      close cr_craplot;
    end loop;
    --
    for rw_crapepr in cr_crapepr (pr_cdcooper,
                                  pr_dtmvtolt,
                                  'MAIOR',
                                  pr_vlini,
                                  pr_vlfim) loop
      -- Busca as linhas de credito que nao devem possuir analise
      vr_dslinhas := ';'||
                     gene0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                               pr_cdcooper =>  0,
                                               pr_cdacesso => 'CREDITO_BANCOOB')||
                     ';';

      -- Verifica se a linha de credito atual esta parametrizada para nao ser processada
      IF instr(vr_dslinhas,';'||rw_crapepr.cdlcremp||';') > 0 THEN
        -- busca proximo contrato
        continue;
      END IF;

      -- Nao listar emprestimos CDC migrados atraves da integracao CDC
      IF rw_crapepr.cdopeori='AUTOCDC' THEN
        continue;
      END IF;

      open cr_craplot (pr_cdcooper,
                       pr_dtmvtolt,
                       rw_crapepr.cdagenci,
                       rw_crapepr.cdbccxlt,
                       rw_crapepr.nrdolote,
                       null);
        fetch cr_craplot into rw_craplot;
        --
        if cr_craplot%found then
           if rw_craplot.tplotmov not in (4, 5) then
              close cr_craplot;
              continue;
          end if;
          open cr_crapass2 (pr_cdcooper,
                            rw_crapepr.nrdconta);
            fetch cr_crapass2 into rw_crapass2;
            --
            if cr_crapass2%notfound then
              close cr_crapass2;
              pr_cdcritic := 9;
              pr_dscritic := gene0001.fn_busca_critica(9);
              btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                         pr_ind_tipo_log => 2, -- Erro tratado
                                         pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                            || vr_cdprogra || ' --> '
                                                            || pr_dscritic,
                                         pr_nmarqlog     => vr_cdprogra);
              close cr_craplot;
              continue;
            end if;
            -- Inclui na primeira tabela, ordenada por agencia
            vr_desvalor := 'CONTRATOS ACIMA R$ '||to_char(pr_vlfim, 'fm999G999G990D00')||' INCLUSIVE';
            vr_indice_geral := to_char(rw_crapepr.cdagenci, 'fm00000')||'1'||'4'||TO_CHAR(rw_crapepr.tpemprst,'fm00000')||to_char(rw_crapepr.nrdconta, 'fm0000000000')||to_char(rw_crapepr.nrctremp, 'fm0000000000')||'0000000000';
            vr_tab_geral(vr_indice_geral).vr_cdagenci := rw_crapepr.cdagenci;
            vr_tab_geral(vr_indice_geral).vr_nrdconta := rw_crapepr.nrdconta;
            vr_tab_geral(vr_indice_geral).vr_nrctremp := rw_crapepr.nrctremp;
            vr_tab_geral(vr_indice_geral).vr_nmprimtl := rw_crapass2.nmprimtl;
            vr_tab_geral(vr_indice_geral).vr_vlemprst := rw_crapepr.vlemprst;
            vr_tab_geral(vr_indice_geral).vr_flgcontr := 1;
            vr_tab_geral(vr_indice_geral).vr_flgvalor := 4;
            vr_tab_geral(vr_indice_geral).vr_cdoperad := rw_craplot.cdoperad;
            vr_tab_geral(vr_indice_geral).vr_dsrlgera := vr_dsrelato;
            vr_tab_geral(vr_indice_geral).vr_vlrgeral := vr_desvalor;
            vr_tab_geral(vr_indice_geral).vr_dtmvtolt := rw_crapepr.dtmvtolt;
            vr_tab_geral(vr_indice_geral).vr_nrdolote := rw_crapepr.nrdolote;
            vr_tab_geral(vr_indice_geral).vr_cdbccxlt := rw_crapepr.cdbccxlt;
            vr_tab_geral(vr_indice_geral).vr_cdpesqbb := to_char(rw_crapepr.dtmvtolt, 'dd/mm/yy')||'-'||
                                                         to_char(rw_crapepr.cdagenci)||'-'||
                                                         to_char(rw_crapepr.cdbccxlt)||'-'||
                                                         to_char(rw_crapepr.nrdolote);
            vr_tab_geral(vr_indice_geral).vr_tpemprst := rw_crapepr.tpemprst;
            -- Se o tipo do empréstimo for igual a zero
            IF rw_crapepr.tpemprst = 0 THEN
              vr_tab_geral(vr_indice_geral).vr_dsemprst := 'CONTRATOS PRICE TR';
            ELSIF rw_crapepr.tpemprst = 1 THEN
              vr_tab_geral(vr_indice_geral).vr_dsemprst := 'CONTRATOS PRICE PRE FIXADO';
            ELSIF rw_crapepr.tpemprst = 2 THEN
              vr_tab_geral(vr_indice_geral).vr_dsemprst := 'CONTRATOS PRICE POS FIXADO';
            END IF;
            -- Inclui na segunda tabela, ordenada pelos indicadores e depois por agencia e conta
            vr_desvalor := 'CONTRATOS ACIMA R$ '||to_char(pr_vlfim, 'fm999G999G990D00')||' INCLUSIVE';
            vr_indice_geral2 := '1'||'4'||TO_CHAR(rw_crapepr.tpemprst,'fm00000')||to_char(rw_crapepr.cdagenci, 'fm00000')||to_char(rw_crapepr.nrdconta, 'fm0000000000')||to_char(rw_crapepr.vlemprst, 'fm0000000000000000000000000')||to_char(rw_crapepr.nrctremp, 'fm0000000000')||'0000000000';
            vr_tab_geral2(vr_indice_geral2).vr_cdagenci := rw_crapepr.cdagenci;
            vr_tab_geral2(vr_indice_geral2).vr_nrdconta := rw_crapepr.nrdconta;
            vr_tab_geral2(vr_indice_geral2).vr_nrctremp := rw_crapepr.nrctremp;
            vr_tab_geral2(vr_indice_geral2).vr_nmprimtl := rw_crapass2.nmprimtl;
            vr_tab_geral2(vr_indice_geral2).vr_vlemprst := rw_crapepr.vlemprst;
            vr_tab_geral2(vr_indice_geral2).vr_flgcontr := 1;
            vr_tab_geral2(vr_indice_geral2).vr_flgvalor := 4;
            vr_tab_geral2(vr_indice_geral2).vr_cdoperad := rw_craplot.cdoperad;
            vr_tab_geral2(vr_indice_geral2).vr_dsrlgera := vr_dsrelato;
            vr_tab_geral2(vr_indice_geral2).vr_vlrgeral := vr_desvalor;
            vr_tab_geral2(vr_indice_geral2).vr_dtmvtolt := rw_crapepr.dtmvtolt;
            vr_tab_geral2(vr_indice_geral2).vr_nrdolote := rw_crapepr.nrdolote;
            vr_tab_geral2(vr_indice_geral2).vr_cdbccxlt := rw_crapepr.cdbccxlt;
            vr_tab_geral2(vr_indice_geral2).vr_cdpesqbb := to_char(rw_crapepr.dtmvtolt, 'dd/mm/yy')||'-'||
                                                           to_char(rw_crapepr.cdagenci)||'-'||
                                                           to_char(rw_crapepr.cdbccxlt)||'-'||
                                                           to_char(rw_crapepr.nrdolote);
            vr_tab_geral2(vr_indice_geral2).vr_tpemprst := rw_crapepr.tpemprst;
            -- Se o tipo do empréstimo for igual a zero
            IF rw_crapepr.tpemprst = 0 THEN
              vr_tab_geral2(vr_indice_geral2).vr_dsemprst := 'CONTRATOS PRICE TR';
            ELSIF rw_crapepr.tpemprst = 1 THEN
              vr_tab_geral2(vr_indice_geral2).vr_dsemprst := 'CONTRATOS PRICE PRE FIXADO';
            ELSIF rw_crapepr.tpemprst = 2 THEN
              vr_tab_geral2(vr_indice_geral2).vr_dsemprst := 'CONTRATOS PRICE POS FIXADO';
            END IF;
          close cr_crapass2;
          -- Pj470 - SM2 -- MArcelo Telles Coelho -- Mouts
          -- Verificar se o emprestimo é de portabilidade
          EMPR0006.pc_possui_portabilidade(pr_cdcooper => pr_cdcooper
                                          ,pr_nrdconta => rw_crapepr.nrdconta
                                          ,pr_nrctremp => rw_crapepr.nrctremp
                                          ,pr_err_efet => vr_err_efet
                                          ,pr_des_reto => vr_des_reto
                                          ,pr_cdcritic => vr_cdcritic
                                          ,pr_dscritic => vr_dscritic);
          IF vr_des_reto = 'S' THEN
            -- Verificar o tipo de autorização feita para a contrato
            cntr0001.pc_ver_protocolo_ctd(pr_cdcooper        => pr_cdcooper
                                         ,pr_nrdconta        => rw_crapepr.nrdconta
                                         ,pr_tpcontrato      => 26 -- Solicitação de Portab. Créd. (Termo)
                                         ,pr_dtmvtolt        => rw_crapepr.dtmvtolt
                                         ,pr_cdrecid_crapcdc => NULL
                                         ,pr_nrdocmto        => rw_crapepr.nrctremp
                                         ,pr_idexiste        => vr_idexiste
                                         ,pr_dscritic        => vr_dscritic);
            IF vr_idexiste = 1 THEN
              vr_tab_geral(vr_indice_geral).vr_formalizacao   := 'DIGITAL';        
              vr_tab_geral2(vr_indice_geral2).vr_formalizacao := 'DIGITAL';        
            ELSE
              vr_tab_geral(vr_indice_geral).vr_formalizacao   := 'FISICO';
              vr_tab_geral2(vr_indice_geral2).vr_formalizacao := 'FISICO';
            END IF;
          END IF;
          -- Fim Pj470 - SM2
        end if;
      close cr_craplot;
    end loop;
  END pc_processa_emprestimos;

  -- Inclui informações de aditivos na vr_tab_aditivo
  PROCEDURE pc_processa_aditivos (pr_cdcooper in crapadt.cdcooper%type,
                                  pr_dtmvtolt in crapadt.dtmvtolt%type) IS
    -- Busca os aditivos
    cursor cr_crapadt (pr_cdcooper in crapadt.cdcooper%type,
                       pr_dtmvtolt in crapadt.dtmvtolt%type) is
      select crapadt.nraditiv,
             crapadt.nrctremp,
             crapadt.cdaditiv,
             crapadt.nrdconta,
             crapadt.cdagenci,
             crapadt.cdoperad,
             crapadt.tpctrato
        from crapadt
       where crapadt.cdcooper = pr_cdcooper
         and crapadt.dtmvtolt = pr_dtmvtolt;
    -- Busca informações do associado
    cursor cr_crapass (pr_cdcooper in crapass.cdcooper%type,
                       pr_nrdconta in crapass.nrdconta%type) is
      select crapass.inpessoa,
             crapass.cdagenci
        from crapass
       where crapass.cdcooper = pr_cdcooper
         and crapass.nrdconta = pr_nrdconta;
    rw_crapass    cr_crapass%rowtype;
    -- Busca informações do titular da conta
    cursor cr_crapttl (pr_cdcooper in crapcop.cdcooper%type,
                       pr_nrdconta in crapass.nrdconta%type) is
      select nmextttl
        from crapttl
       where crapttl.cdcooper = pr_cdcooper
         and crapttl.nrdconta = pr_nrdconta
         and crapttl.idseqttl = 1;
    -- Busca informações da conta PJ
    cursor cr_crapjur (pr_cdcooper in crapcop.cdcooper%type,
                       pr_nrdconta in crapass.nrdconta%type) is
      select nmextttl
        from crapjur
       where crapjur.cdcooper = pr_cdcooper
         and crapjur.nrdconta = pr_nrdconta;
    --
  BEGIN
    for rw_crapadt in cr_crapadt (pr_cdcooper,
                                  pr_dtmvtolt) loop
      -- Busca informações do associado
      open cr_crapass (pr_cdcooper,
                       rw_crapadt.nrdconta);
        fetch cr_crapass into rw_crapass;
        if cr_crapass%notfound then
          close cr_crapass;
          pr_cdcritic := 9;
          pr_dscritic := gene0001.fn_busca_critica(9)||' - Conta: '||rw_crapadt.nrdconta;
          -- Gera a mensagem de erro no log e não prossegue a rotina.
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                     pr_ind_tipo_log => 2, -- Erro tratado
                                     pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' --> ' || pr_dscritic,
                                     pr_nmarqlog => vr_cdprogra);
          return;
        end if;
      close cr_crapass;
      --
      vr_indice_aditivo := to_char(rw_crapadt.cdagenci, 'fm00000')||to_char(rw_crapadt.nrdconta, 'fm0000000000')||to_char(rw_crapadt.cdaditiv, 'fm00000')||to_char(rw_crapadt.nraditiv, 'fm0000000000')||to_char(rw_crapadt.nrctremp,'fm0000000000')||to_char(rw_crapadt.tpctrato, 'fm00');
      -- Informações do aditivo
      vr_tab_aditivo(vr_indice_aditivo).vr_cdagenci := rw_crapadt.cdagenci;
      vr_tab_aditivo(vr_indice_aditivo).vr_nrdconta := rw_crapadt.nrdconta;
      vr_tab_aditivo(vr_indice_aditivo).vr_nraditiv := rw_crapadt.nraditiv;
      vr_tab_aditivo(vr_indice_aditivo).vr_nrctremp := rw_crapadt.nrctremp;
      vr_tab_aditivo(vr_indice_aditivo).vr_cdaditiv := rw_crapadt.cdaditiv;
      vr_tab_aditivo(vr_indice_aditivo).vr_cdoperad := rw_crapadt.cdoperad;
      vr_tab_aditivo(vr_indice_aditivo).vr_tpctrato := rw_crapadt.tpctrato;
      -- Descrição do aditivo
      if rw_crapadt.cdaditiv = 1 then
        vr_tab_aditivo(vr_indice_aditivo).vr_dsaditiv := 'Alteracao Data do Debito';
      elsif rw_crapadt.cdaditiv = 2 then
        vr_tab_aditivo(vr_indice_aditivo).vr_dsaditiv := 'Aplicacao Vinculada';
      elsif rw_crapadt.cdaditiv = 3 then
        vr_tab_aditivo(vr_indice_aditivo).vr_dsaditiv := 'Aplicacao Vinculada Terceiro';
      elsif rw_crapadt.cdaditiv = 4 then
        vr_tab_aditivo(vr_indice_aditivo).vr_dsaditiv := 'Inclusao de Fiador/Avalista';
      elsif rw_crapadt.cdaditiv = 5 then
        vr_tab_aditivo(vr_indice_aditivo).vr_dsaditiv := 'Substituicao de Veiculo';
      elsif rw_crapadt.cdaditiv = 6 then
        vr_tab_aditivo(vr_indice_aditivo).vr_dsaditiv := 'Interveniente Garantidor Veiculo';
      elsif rw_crapadt.cdaditiv = 7 then
        vr_tab_aditivo(vr_indice_aditivo).vr_dsaditiv := 'Sub-rogacao - C/ Nota Promissoria';
      elsif rw_crapadt.cdaditiv = 8 then
        vr_tab_aditivo(vr_indice_aditivo).vr_dsaditiv := 'Sub-rogacao - S/ Nota Promissoria';
      elsif rw_crapadt.cdaditiv = 9 then
        vr_tab_aditivo(vr_indice_aditivo).vr_dsaditiv := 'Cobertura de Aplicacao Vinculada a Operacao';
      end if;
      -- Reduzir para 24 caracteres devido a limitação no relatório
      vr_tab_aditivo(vr_indice_aditivo).vr_dsaditiv := substr(vr_tab_aditivo(vr_indice_aditivo).vr_dsaditiv, 1, 24);
      -- Nome do primeiro titular PF ou PJ
      if rw_crapass.inpessoa = 1 then
        open cr_crapttl (pr_cdcooper,
                         rw_crapadt.nrdconta);
          fetch cr_crapttl into vr_tab_aditivo(vr_indice_aditivo).vr_nmprimtl;
        close cr_crapttl;
      else
        open cr_crapjur (pr_cdcooper,
                         rw_crapadt.nrdconta);
          fetch cr_crapjur into vr_tab_aditivo(vr_indice_aditivo).vr_nmprimtl;
        close cr_crapjur;
      end if;
      -- Reduzir para 19 caracteres devido a limitação no relatório
      vr_tab_aditivo(vr_indice_aditivo).vr_nmprimtl := substr(vr_tab_aditivo(vr_indice_aditivo).vr_nmprimtl, 1, 19);
    end loop;
  END pc_processa_aditivos;

  -- Inclui informações de descontos na vr_tab_geral e vr_tab_geral2
  PROCEDURE pc_processa_limite_desconto (pr_cdcooper in crapcdc.cdcooper%type,
                                      pr_dtmvtolt in crapcdc.dtmvtolt%type,
                                      pr_vllimctr in crapcdc.vllimite%type) IS
    cursor cr_crapcdc (pr_cdcooper in crapcdc.cdcooper%type,
                       pr_dtmvtolt in crapcdc.dtmvtolt%type,
                       pr_vllimctr in crapcdc.vllimite%type,
                       pr_tipo in varchar2) is
      select /*+index (crapcdc crapcdc##crapcdc1)*/
             crapcdc.cdcooper,
             crapcdc.dtmvtolt,
             crapcdc.nrdolote,
             crapcdc.cdbccxlt,
             crapcdc.cdagenci,
             crapcdc.nrdconta,
             crapcdc.nrctrlim,
             crapcdc.vllimite
        from crapcdc
       where crapcdc.cdcooper = pr_cdcooper
         and crapcdc.dtmvtolt = pr_dtmvtolt
         and (   (    pr_tipo = 'MENOR'
                  and crapcdc.vllimite < pr_vllimctr)
              or (    pr_tipo = 'MAIOR'
                  and crapcdc.vllimite >= pr_vllimctr));
    --
    vr_flgcontr     number(1);
  BEGIN
    for rw_crapcdc in cr_crapcdc (pr_cdcooper,
                                  pr_dtmvtolt,
                                  pr_vllimctr,
                                  'MENOR') loop
      open cr_craplot (rw_crapcdc.cdcooper,
                       rw_crapcdc.dtmvtolt,
                       rw_crapcdc.cdagenci,
                       rw_crapcdc.cdbccxlt,
                       rw_crapcdc.nrdolote,
                       null);
        fetch cr_craplot into rw_craplot;
        --
        if cr_craplot%found then
          if rw_craplot.tplotmov not in (27, 35) then
            close cr_craplot;
            continue;
          end if;
          --
          open cr_crapass2 (pr_cdcooper,
                            rw_crapcdc.nrdconta);
            fetch cr_crapass2 into rw_crapass2;
            --
            if cr_crapass2%notfound then
              close cr_crapass2;
              pr_cdcritic := 9;
              pr_dscritic := gene0001.fn_busca_critica(9);
              btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                         pr_ind_tipo_log => 2, -- Erro tratado
                                         pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                            || vr_cdprogra || ' --> '
                                                            || pr_dscritic,
                                         pr_nmarqlog     => vr_cdprogra);
              continue;
            end if;
            -- Define os índices das tabelas, além de alguns campos que dependem do parâmetro cadastrado.
            if rw_craplot.tplotmov = 27 then
              vr_dsrelato := 'CONTRATOS LIMITE DESCONTO DE CHEQUE';
              vr_flgcontr := 2;
              vr_indice_geral := to_char(rw_crapcdc.cdagenci, 'fm00000')||'2'||'1'||'00000'||to_char(rw_crapcdc.nrdconta, 'fm0000000000')||to_char(rw_crapcdc.nrctrlim, 'fm0000000000')||'0000000000';
              vr_indice_geral2 := '2'||'1'||'00000'||to_char(rw_crapcdc.cdagenci, 'fm00000')||to_char(rw_crapcdc.nrdconta, 'fm0000000000')||to_char(rw_crapcdc.vllimite, 'fm0000000000000000000000000')||to_char(rw_crapcdc.nrctrlim, 'fm0000000000')||'0000000000';
            else
              vr_dsrelato := 'CONTRATOS LIMITE DESCONTO DE TITULOS';
              vr_flgcontr := 6;
              vr_indice_geral := to_char(rw_crapcdc.cdagenci, 'fm00000')||'6'||'1'||'00000'||to_char(rw_crapcdc.nrdconta, 'fm0000000000')||to_char(rw_crapcdc.nrctrlim, 'fm0000000000')||'0000000000';
              vr_indice_geral2 := '6'||'1'||'00000'||to_char(rw_crapcdc.cdagenci, 'fm00000')||to_char(rw_crapcdc.nrdconta, 'fm0000000000')||to_char(rw_crapcdc.vllimite, 'fm0000000000000000000000000')||to_char(rw_crapcdc.nrctrlim, 'fm0000000000')||'0000000000';
            end if;
            vr_desvalor := 'CONTRATOS ATE R$ '||to_char(pr_vllimctr, 'fm999G990D00');
            -- Inclui na primeira tabela, ordenada por agencia
            vr_tab_geral(vr_indice_geral).vr_cdagenci := rw_crapcdc.cdagenci;
            vr_tab_geral(vr_indice_geral).vr_nrdconta := rw_crapcdc.nrdconta;
            vr_tab_geral(vr_indice_geral).vr_nrctremp := rw_crapcdc.nrctrlim;
            vr_tab_geral(vr_indice_geral).vr_nmprimtl := rw_crapass2.nmprimtl;
            vr_tab_geral(vr_indice_geral).vr_vlemprst := rw_crapcdc.vllimite;
            vr_tab_geral(vr_indice_geral).vr_flgcontr := vr_flgcontr;
            vr_tab_geral(vr_indice_geral).vr_flgvalor := 1;
            vr_tab_geral(vr_indice_geral).vr_cdoperad := rw_craplot.cdoperad;
            vr_tab_geral(vr_indice_geral).vr_dsrlgera := vr_dsrelato;
            vr_tab_geral(vr_indice_geral).vr_vlrgeral := vr_desvalor;
            vr_tab_geral(vr_indice_geral).vr_dtmvtolt := rw_crapcdc.dtmvtolt;
            vr_tab_geral(vr_indice_geral).vr_nrdolote := rw_crapcdc.nrdolote;
            vr_tab_geral(vr_indice_geral).vr_cdbccxlt := rw_crapcdc.cdbccxlt;
            vr_tab_geral(vr_indice_geral).vr_cdpesqbb := to_char(rw_crapcdc.dtmvtolt, 'dd/mm/yy')||'-'||
                                                         to_char(rw_crapcdc.cdagenci)||'-'||
                                                         to_char(rw_crapcdc.cdbccxlt)||'-'||
                                                         to_char(rw_crapcdc.nrdolote);
            -- Inclui na segunda tabela, ordenada pelos indicadores e depois por agencia e conta
            vr_tab_geral2(vr_indice_geral2).vr_cdagenci := rw_crapcdc.cdagenci;
            vr_tab_geral2(vr_indice_geral2).vr_nrdconta := rw_crapcdc.nrdconta;
            vr_tab_geral2(vr_indice_geral2).vr_nrctremp := rw_crapcdc.nrctrlim;
            vr_tab_geral2(vr_indice_geral2).vr_nmprimtl := rw_crapass2.nmprimtl;
            vr_tab_geral2(vr_indice_geral2).vr_vlemprst := rw_crapcdc.vllimite;
            vr_tab_geral2(vr_indice_geral2).vr_flgcontr := vr_flgcontr;
            vr_tab_geral2(vr_indice_geral2).vr_flgvalor := 1;
            vr_tab_geral2(vr_indice_geral2).vr_cdoperad := rw_craplot.cdoperad;
            vr_tab_geral2(vr_indice_geral2).vr_dsrlgera := vr_dsrelato;
            vr_tab_geral2(vr_indice_geral2).vr_vlrgeral := vr_desvalor;
            vr_tab_geral2(vr_indice_geral2).vr_dtmvtolt := rw_crapcdc.dtmvtolt;
            vr_tab_geral2(vr_indice_geral2).vr_nrdolote := rw_crapcdc.nrdolote;
            vr_tab_geral2(vr_indice_geral2).vr_cdbccxlt := rw_crapcdc.cdbccxlt;
            vr_tab_geral2(vr_indice_geral2).vr_cdpesqbb := to_char(rw_crapcdc.dtmvtolt, 'dd/mm/yy')||'-'||
                                                           to_char(rw_crapcdc.cdagenci)||'-'||
                                                           to_char(rw_crapcdc.cdbccxlt)||'-'||
                                                           to_char(rw_crapcdc.nrdolote);
            -- Pj470 - SM2 -- MArcelo Telles Coelho -- Mouts
            -- Verificar o tipo de autorização feita para a contrato
            cntr0001.pc_ver_protocolo_ctd(pr_cdcooper        => pr_cdcooper
                                         ,pr_nrdconta        => rw_crapcdc.nrdconta
                                         ,pr_tpcontrato      => CASE
                                                                WHEN rw_craplot.tplotmov = 27 THEN 27 -- Limite de Desc. Chq. (Contrato)
                                                                ELSE                               28 -- Limite de Desc. Tit. (Contrato)
                                                                END
                                         ,pr_dtmvtolt        => rw_crapcdc.dtmvtolt
                                         ,pr_cdrecid_crapcdc => NULL
                                         ,pr_nrdocmto        => rw_crapcdc.nrctrlim
                                         ,pr_idexiste        => vr_idexiste
                                         ,pr_dscritic        => vr_dscritic);
            IF vr_idexiste = 1 THEN
              vr_tab_geral(vr_indice_geral).vr_formalizacao   := 'DIGITAL';        
              vr_tab_geral2(vr_indice_geral2).vr_formalizacao := 'DIGITAL';        
            ELSE
              vr_tab_geral(vr_indice_geral).vr_formalizacao   := 'FISICO';
              vr_tab_geral2(vr_indice_geral2).vr_formalizacao := 'FISICO';
            END IF;
            -- Fim Pj470 - SM2

          close cr_crapass2;
        end if;
      close cr_craplot;
    end loop;
    --
    for rw_crapcdc in cr_crapcdc (pr_cdcooper,
                                  pr_dtmvtolt,
                                  pr_vllimctr,
                                  'MAIOR') loop
      open cr_craplot (rw_crapcdc.cdcooper,
                       rw_crapcdc.dtmvtolt,
                       rw_crapcdc.cdagenci,
                       rw_crapcdc.cdbccxlt,
                       rw_crapcdc.nrdolote,
                       null);
        fetch cr_craplot into rw_craplot;
        --
        if cr_craplot%found then
          if rw_craplot.tplotmov not in (27, 35) then
            close cr_craplot;
            continue;
          end if;
          --
          open cr_crapass2 (pr_cdcooper,
                            rw_crapcdc.nrdconta);
            fetch cr_crapass2 into rw_crapass2;
            --
            if cr_crapass2%notfound then
              close cr_crapass2;
              pr_cdcritic := 9;
              pr_dscritic := gene0001.fn_busca_critica(9);
              btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                         pr_ind_tipo_log => 2, -- Erro tratado
                                         pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                            || vr_cdprogra || ' --> '
                                                            || pr_dscritic,
                                         pr_nmarqlog     => vr_cdprogra);
              close cr_craplot;
              continue;
            end if;
            -- Define os índices das tabelas, além de alguns campos que dependem do parâmetro cadastrado.
            if rw_craplot.tplotmov = 27 then
              vr_dsrelato := 'CONTRATOS LIMITE DESCONTO DE CHEQUE';
              vr_flgcontr := 2;
              vr_indice_geral := to_char(rw_crapcdc.cdagenci, 'fm00000')||'2'||'2'||'00000'||to_char(rw_crapcdc.nrdconta, 'fm0000000000')||to_char(rw_crapcdc.nrctrlim, 'fm0000000000')||'0000000000';
              vr_indice_geral2 := '2'||'2'||'00000'||to_char(rw_crapcdc.cdagenci, 'fm00000')||to_char(rw_crapcdc.nrdconta, 'fm0000000000')||to_char(rw_crapcdc.vllimite, 'fm0000000000000000000000000')||to_char(rw_crapcdc.nrctrlim, 'fm0000000000')||'0000000000';
            else
              vr_dsrelato := 'CONTRATOS LIMITE DESCONTO DE TITULOS';
              vr_flgcontr := 6;
              vr_indice_geral := to_char(rw_crapcdc.cdagenci, 'fm00000')||'6'||'2'||'00000'||to_char(rw_crapcdc.nrdconta, 'fm0000000000')||to_char(rw_crapcdc.nrctrlim, 'fm0000000000')||'0000000000';
              vr_indice_geral2 := '6'||'2'||'00000'||to_char(rw_crapcdc.cdagenci, 'fm00000')||to_char(rw_crapcdc.nrdconta, 'fm0000000000')||to_char(rw_crapcdc.vllimite, 'fm0000000000000000000000000')||to_char(rw_crapcdc.nrctrlim, 'fm0000000000')||'0000000000';
            end if;
            vr_desvalor := 'CONTRATOS ACIMA R$ '||to_char(pr_vllimctr, 'fm999G990D00')||' INCLUSIVE';
            -- Inclui na primeira tabela, ordenada por agencia
            vr_tab_geral(vr_indice_geral).vr_cdagenci := rw_crapcdc.cdagenci;
            vr_tab_geral(vr_indice_geral).vr_nrdconta := rw_crapcdc.nrdconta;
            vr_tab_geral(vr_indice_geral).vr_nrctremp := rw_crapcdc.nrctrlim;
            vr_tab_geral(vr_indice_geral).vr_nmprimtl := rw_crapass2.nmprimtl;
            vr_tab_geral(vr_indice_geral).vr_vlemprst := rw_crapcdc.vllimite;
            vr_tab_geral(vr_indice_geral).vr_flgcontr := vr_flgcontr;
            vr_tab_geral(vr_indice_geral).vr_flgvalor := 2;
            vr_tab_geral(vr_indice_geral).vr_cdoperad := rw_craplot.cdoperad;
            vr_tab_geral(vr_indice_geral).vr_dsrlgera := vr_dsrelato;
            vr_tab_geral(vr_indice_geral).vr_vlrgeral := vr_desvalor;
            vr_tab_geral(vr_indice_geral).vr_dtmvtolt := rw_crapcdc.dtmvtolt;
            vr_tab_geral(vr_indice_geral).vr_nrdolote := rw_crapcdc.nrdolote;
            vr_tab_geral(vr_indice_geral).vr_cdbccxlt := rw_crapcdc.cdbccxlt;
            vr_tab_geral(vr_indice_geral).vr_cdpesqbb := to_char(rw_crapcdc.dtmvtolt, 'dd/mm/yy')||'-'||
                                                         to_char(rw_crapcdc.cdagenci)||'-'||
                                                         to_char(rw_crapcdc.cdbccxlt)||'-'||
                                                         to_char(rw_crapcdc.nrdolote);
            -- Inclui na segunda tabela, ordenada pelos indicadores e depois por agencia e conta
            vr_tab_geral2(vr_indice_geral2).vr_cdagenci := rw_crapcdc.cdagenci;
            vr_tab_geral2(vr_indice_geral2).vr_nrdconta := rw_crapcdc.nrdconta;
            vr_tab_geral2(vr_indice_geral2).vr_nrctremp := rw_crapcdc.nrctrlim;
            vr_tab_geral2(vr_indice_geral2).vr_nmprimtl := rw_crapass2.nmprimtl;
            vr_tab_geral2(vr_indice_geral2).vr_vlemprst := rw_crapcdc.vllimite;
            vr_tab_geral2(vr_indice_geral2).vr_flgcontr := vr_flgcontr;
            vr_tab_geral2(vr_indice_geral2).vr_flgvalor := 2;
            vr_tab_geral2(vr_indice_geral2).vr_cdoperad := rw_craplot.cdoperad;
            vr_tab_geral2(vr_indice_geral2).vr_dsrlgera := vr_dsrelato;
            vr_tab_geral2(vr_indice_geral2).vr_vlrgeral := vr_desvalor;
            vr_tab_geral2(vr_indice_geral2).vr_dtmvtolt := rw_crapcdc.dtmvtolt;
            vr_tab_geral2(vr_indice_geral2).vr_nrdolote := rw_crapcdc.nrdolote;
            vr_tab_geral2(vr_indice_geral2).vr_cdbccxlt := rw_crapcdc.cdbccxlt;
            vr_tab_geral2(vr_indice_geral2).vr_cdpesqbb := to_char(rw_crapcdc.dtmvtolt, 'dd/mm/yy')||'-'||
                                                           to_char(rw_crapcdc.cdagenci)||'-'||
                                                           to_char(rw_crapcdc.cdbccxlt)||'-'||
                                                           to_char(rw_crapcdc.nrdolote);
            -- Pj470 - SM2 -- MArcelo Telles Coelho -- Mouts
            -- Verificar o tipo de autorização feita para a contrato
            cntr0001.pc_ver_protocolo_ctd(pr_cdcooper        => pr_cdcooper
                                         ,pr_nrdconta        => rw_crapcdc.nrdconta
                                         ,pr_tpcontrato      => CASE
                                                                WHEN rw_craplot.tplotmov = 27 THEN 27 -- Limite de Desc. Chq. (Contrato)
                                                                ELSE                               28 -- Limite de Desc. Tit. (Contrato)
                                                                END
                                         ,pr_dtmvtolt        => rw_crapcdc.dtmvtolt
                                         ,pr_cdrecid_crapcdc => NULL
                                         ,pr_nrdocmto        => rw_crapcdc.nrctrlim
                                         ,pr_idexiste        => vr_idexiste
                                         ,pr_dscritic        => vr_dscritic);
            IF vr_idexiste = 1 THEN
              vr_tab_geral(vr_indice_geral).vr_formalizacao   := 'DIGITAL';        
              vr_tab_geral2(vr_indice_geral2).vr_formalizacao := 'DIGITAL';        
            ELSE
              vr_tab_geral(vr_indice_geral).vr_formalizacao   := 'FISICO';
              vr_tab_geral2(vr_indice_geral2).vr_formalizacao := 'FISICO';
            END IF;
            -- Fim Pj470 - SM2
          close cr_crapass2;
        end if;
      close cr_craplot;
    end loop;
  END pc_processa_limite_desconto;

  --
  procedure pc_inclui_aditivos_xml (pr_cdagenci in number) is
  begin
    -- Posiciona no primeiro registro da pl/table
    vr_indice_aditivo := vr_tab_aditivo.first;
    -- Le a tabela até encontrar a agência correta
    while vr_indice_aditivo is not null and
          vr_tab_aditivo(vr_indice_aditivo).vr_cdagenci <> pr_cdagenci and
          pr_cdagenci <> 99 loop
      vr_indice_aditivo := vr_tab_aditivo.next(vr_indice_aditivo);
    end loop;
    -- Ao final, verifica se encontrou algum registro para a agência
    if vr_indice_aditivo is null then
      return;
    end if;
    -- Abre o novo tipo
    gene0002.pc_escreve_xml(vr_des_xml,vr_des_xml_temp,'<tipo dsrelato="EMISSAO DE ADITIVOS">');
    -- Abre o novo valor no XML
    gene0002.pc_escreve_xml(vr_des_xml,vr_des_xml_temp,'<valor desvalor="TODOS">');
    -- Se for relatório por agência, deve incluir os demais campos
    if pr_cdagenci <> 99 then
      gene0002.pc_escreve_xml(vr_des_xml,vr_des_xml_temp,'<dtmvtolt></dtmvtolt>'||
                                                         '<cdbccxlt></cdbccxlt>'||
                                                         '<dtlibbdc></dtlibbdc>');
    end if;
    -- Leitura dos registros da agência na pl/table
    while vr_indice_aditivo is not null and
          (vr_tab_aditivo(vr_indice_aditivo).vr_cdagenci = pr_cdagenci or
           pr_cdagenci = 99) loop

      CASE vr_tab_aditivo(vr_indice_aditivo).vr_tpctrato
        WHEN 1 THEN vr_dstipctr := 'LIM.CRED';
        WHEN 2 THEN vr_dstipctr := 'DSCT.CHEQ';
        WHEN 3 THEN vr_dstipctr := 'DSCT.TITU';
        WHEN 90 THEN vr_dstipctr := 'EMP.FIN.';
      END CASE;

      if pr_cdagenci <> 99 then
        -- Escreve no XML o detalhe da informação (relatório por agência)
        gene0002.pc_escreve_xml(vr_des_xml,vr_des_xml_temp
                              ,'<conta nrdconta="'||to_char(vr_tab_aditivo(vr_indice_aditivo).vr_nrdconta, 'fm9999G999G9')||
                                  '" tplayout="8" '||
                                  ' dsemprst="" >'||
                               '<nrctremp>'||to_char(vr_tab_aditivo(vr_indice_aditivo).vr_nrctremp, 'fm99G999G999')||'</nrctremp>'||
                               '<nmprimtl>'||vr_tab_aditivo(vr_indice_aditivo).vr_nmprimtl||'</nmprimtl>'||
                               '<vlemprst></vlemprst>'||
                               '<vlemprst_form></vlemprst_form>'||
                               '<nrdolote></nrdolote>'||
                               '<nrctrlim></nrctrlim>'||
                               '<nrborder></nrborder>'||
                               '<dtmvtolt></dtmvtolt>'||
                               '<formalizacao>'||'FISICO'||'</formalizacao>'|| -- Pj470 - SM2 -- MArcelo Telles Coelho -- Mouts
                               '<nraditiv>'||vr_tab_aditivo(vr_indice_aditivo).vr_nraditiv||'</nraditiv>'||
                               '<tpaditiv>'||vr_tab_aditivo(vr_indice_aditivo).vr_cdaditiv||'</tpaditiv>'||
                               '<dsaditiv>'||vr_tab_aditivo(vr_indice_aditivo).vr_dsaditiv||'</dsaditiv>'||
                               '<dstipctr>'||vr_dstipctr||'</dstipctr>'||
                             '</conta>');
      else
        -- Escreve no XML o detalhe da informação (relatório geral)
        gene0002.pc_escreve_xml(vr_des_xml,vr_des_xml_temp,
                       '<conta nrdconta="'||to_char(vr_tab_aditivo(vr_indice_aditivo).vr_nrdconta, 'fm9999G999G9')||
                            '" tplayout="8" '||
                            ' dsemprst="" >'||
                         '<cdagenci>'||vr_tab_aditivo(vr_indice_aditivo).vr_cdagenci||'</cdagenci>'||
                         '<nrctremp>'||to_char(vr_tab_aditivo(vr_indice_aditivo).vr_nrctremp, 'fm99G999G999')||'</nrctremp>'||
                         '<nmprimtl>'||vr_tab_aditivo(vr_indice_aditivo).vr_nmprimtl||'</nmprimtl>'||
                         '<vlemprst></vlemprst>'||
                         '<vlemprst_form></vlemprst_form>'||
                         '<cdpesqbb></cdpesqbb>'||
                         '<cdoperad>'||vr_tab_aditivo(vr_indice_aditivo).vr_cdoperad||'</cdoperad>'||
                         '<nrborder></nrborder>'||
                         '<nraditiv>'||vr_tab_aditivo(vr_indice_aditivo).vr_nraditiv||'</nraditiv>'||
                         '<tpaditiv>'||vr_tab_aditivo(vr_indice_aditivo).vr_cdaditiv||'</tpaditiv>'||
                         '<dsaditiv>'||vr_tab_aditivo(vr_indice_aditivo).vr_dsaditiv||'</dsaditiv>'||
                         '<dstipctr>'||vr_dstipctr||'</dstipctr>'||
                       '</conta>');
      end if;
      -- Passa para o próximo registro
      vr_indice_aditivo := vr_tab_aditivo.next(vr_indice_aditivo);
    end loop;
    gene0002.pc_escreve_xml(vr_des_xml,vr_des_xml_temp,'</valor></tipo>');
    
  end;
  

  --
begin
  vr_cdprogra := 'CRPS314';
  -- Incluir nome do módulo logado
  gene0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra,
                             pr_action => null);
  -- Validações iniciais do programa
  BTCH0001.pc_valida_iniprg (pr_cdcooper => pr_cdcooper
                            ,pr_flgbatch => 1 -- Fixo
                            ,pr_cdprogra => vr_cdprogra
                            ,pr_infimsol => pr_infimsol
                            ,pr_cdcritic => vr_cdcritic);
  -- Se retornou algum erro
  if vr_cdcritic <> 0 then
    -- Sair do programa
    RAISE vr_exc_saida;
  end if;

  -- Buscar a data do movimento
  open btch0001.cr_crapdat(pr_cdcooper);
  fetch btch0001.cr_crapdat
   into rw_crapdat;
  close btch0001.cr_crapdat;

  -- Buscar os dados da cooperativa
  OPEN cr_crapcop(pr_cdcooper);
  FETCH cr_crapcop INTO rw_crapcop;
  IF cr_crapcop%NOTFOUND THEN
    CLOSE cr_crapcop;
    vr_cdcritic:= 651;
    RAISE vr_exc_saida;
  END IF;
  CLOSE cr_crapcop;
  -- Leitura da tabela de parametros para indentificar o valor max do contrato
  vr_dstextab := tabe0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                           ,pr_nmsistem => 'CRED'
                                           ,pr_tptabela => 'GENERI'
                                           ,pr_cdempres => 0
                                           ,pr_cdacesso => 'VLMICFEMPR'
                                           ,pr_tpregist => 0);
  IF NVL(vr_dstextab,' ') = ' ' THEN
    vr_vlfaixa1 := 0;
    vr_vlfaixa2 := 0;
  else
    vr_vlfaixa1 := gene0002.fn_char_para_number(substr(vr_dstextab, 1, 7));
    vr_vlfaixa2 := gene0002.fn_char_para_number(substr(vr_dstextab, 9, 9));
  end if;
  -- Se não há faixa superior
  if nvl(vr_vlfaixa2,0) = 0 then
    vr_vlfaixa2 := 999999.99;
  end if;

  -- Leitura da tabela de parametros para buscar o limite de crédito
  vr_dstextab := tabe0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                           ,pr_nmsistem => 'CRED'
                                           ,pr_tptabela => 'GENERI'
                                           ,pr_cdempres => 0
                                           ,pr_cdacesso => 'VLMICFLIMI'
                                           ,pr_tpregist => 0);
  IF NVL(vr_dstextab,' ') = ' ' THEN
    vr_vllimctr := 0;
    vr_vllimcre := 0.01;
  else
    vr_vllimctr := gene0002.fn_char_para_number(vr_dstextab);
    vr_vllimcre := gene0002.fn_char_para_number(vr_dstextab);
  end if;

  -- Inclui informações de borderô na vr_tab_bordero
  pc_grava_borderos(pr_cdcooper,rw_crapdat.dtmvtolt);

  -- Inclui informações de limite de crédito na vr_tab_geral e vr_tab_geral2
  pc_limite_credito(pr_cdcooper,rw_crapdat.dtmvtolt,vr_vllimcre);

  -- Inclui informações de limite de cartão de crédito na vr_tab_geral e vr_tab_geral2
  pc_limite_cartao_cred(pr_cdcooper,rw_crapdat.dtmvtolt,vr_vllimcre);

  -- Inclui informações de empréstimos na vr_tab_geral e vr_tab_geral2
  pc_processa_emprestimos(pr_cdcooper,rw_crapdat.dtmvtolt,vr_vlfaixa1,vr_vlfaixa2);

  -- Inclui informações de aditivos na vr_tab_aditivo
  pc_processa_aditivos(pr_cdcooper,rw_crapdat.dtmvtolt);

  -- Inclui informações de descontos na vr_tab_geral e vr_tab_geral2
  pc_processa_limite_desconto(pr_cdcooper,rw_crapdat.dtmvtolt,vr_vllimctr);

  -- Busca do diretório base da cooperativa
  vr_nom_diretorio := gene0001.fn_diretorio(pr_tpdireto => 'C', -- /usr/coop
                                            pr_cdcooper => pr_cdcooper,
                                            pr_nmsubdir => '/rl'); --> Utilizaremos o rl
  -- Imprime relatorio por PA
  for rw_crapage in cr_crapage (pr_cdcooper) loop
    -- Nome base do arquivo é crrl266
    vr_nom_arquivo := 'crrl266_'||to_char(rw_crapage.cdagenci, 'fm000');
    -- Inicializar variáveis de controle de quebra
    vr_flgcontr := 0;
    vr_flgvalor := 0;
    vr_lancou_aditivos := 'N'; --SD#539415
    -- Inicializar o CLOB
    dbms_lob.createtemporary(vr_des_xml, TRUE);
    dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
    -- Inicilizar as informações do XML
    gene0002.pc_escreve_xml(vr_des_xml,vr_des_xml_temp,'<?xml version="1.0" encoding="utf-8"?><agencias>');
    -- Informações iniciais no XML
    gene0002.pc_escreve_xml(vr_des_xml,vr_des_xml_temp
                           ,'<agencia cdagenci="'||rw_crapage.cdagenci||'">'||'<nmresage>'||rw_crapage.nmresage||'</nmresage>');
	  -- Inicia a leitura da pl/table de contratos e limites
    vr_indice_geral := vr_tab_geral.first;
    while vr_indice_geral is not null loop
      -- Verifica se é a agência correta
      if vr_tab_geral(vr_indice_geral).vr_cdagenci = rw_crapage.cdagenci then
        -- Verificação de quebra
        if vr_tab_geral(vr_indice_geral).vr_flgcontr <> vr_flgcontr or
           vr_tab_geral(vr_indice_geral).vr_flgvalor <> vr_flgvalor then
          -- Houve uma quebra. Deve verificar quais grupos deve fechar.
          if vr_flgvalor <> 0 then
            -- Se não for a primeira volta do loop, fecha o grupo do valor
            gene0002.pc_escreve_xml(vr_des_xml,vr_des_xml_temp,'</valor>');
            --
            if vr_tab_geral(vr_indice_geral).vr_flgcontr <> vr_flgcontr then
              -- Se mudou o tipo, fecha o grupo do tipo
              gene0002.pc_escreve_xml(vr_des_xml,vr_des_xml_temp,'</tipo>');
            end if;
          end if;
          -- Os aditivos devem entrar após os contratos de empréstimos
          if vr_flgcontr <= 1 and
             vr_tab_geral(vr_indice_geral).vr_flgcontr >= 2 then
            pc_inclui_aditivos_xml(vr_tab_geral(vr_indice_geral).vr_cdagenci);
            vr_lancou_aditivos := 'S'; --SD#539415
          end if;
          -- Define o cabeçalho da nova seção do relatório
          if vr_tab_geral(vr_indice_geral).vr_flgcontr = 1 then
            vr_dsrelato := 'CONTRATOS EMPRESTIMOS';
            if vr_tab_geral(vr_indice_geral).vr_flgvalor = 1   then
              vr_desvalor := 'CONTRATOS ATE R$ '||to_char(vr_vlfaixa1 - 0.01, 'fm999G990D00');
            elsif vr_tab_geral(vr_indice_geral).vr_flgvalor = 2   then
              vr_desvalor := 'CONTRATOS ACIMA R$ '||to_char(vr_vlfaixa1, 'fm999G990D00')||' INCLUSIVE';
            elsif vr_tab_geral(vr_indice_geral).vr_flgvalor = 3   then
              vr_desvalor := 'CONTRATOS DE R$ '||to_char(vr_vlfaixa1, 'fm999G990D00')||' ATE '||to_char(vr_vlfaixa2 - 0.01, 'fm999G990D00');
            elsif vr_tab_geral(vr_indice_geral).vr_flgvalor = 4   then
              vr_desvalor := 'CONTRATOS ACIMA R$ '||to_char(vr_vlfaixa2, 'fm999G990D00')||' INCLUSIVE';
            end if;
          elsif vr_tab_geral(vr_indice_geral).vr_flgcontr = 2 then
            vr_dsrelato := 'CONTRATOS LIMITE DESCONTO DE CHEQUE';
            if vr_tab_geral(vr_indice_geral).vr_flgvalor = 1 then
              vr_desvalor := 'CONTRATOS ATE R$ '||to_char(vr_vllimctr, 'fm999G990D00');
            elsif vr_tab_geral(vr_indice_geral).vr_flgvalor = 2 then
              vr_desvalor := 'CONTRATOS ACIMA R$ '||to_char(vr_vllimctr, 'fm999G990D00')||' INCLUSIVE';
            end if;
          elsif vr_tab_geral(vr_indice_geral).vr_flgcontr = 4 then
            vr_dsrelato := 'LIMITES DE CREDITO';
            if vr_tab_geral(vr_indice_geral).vr_flgvalor = 1 then
              vr_desvalor := 'LIMITES ATE R$ '||to_char(vr_vllimcre - 0.01, 'fm999G990D00');
            elsif vr_tab_geral(vr_indice_geral).vr_flgvalor = 2 then
              vr_desvalor := 'CONTRATOS ACIMA R$ '||to_char(vr_vllimcre, 'fm999G990D00')||' INCLUSIVE';
            end if;
          elsif vr_tab_geral(vr_indice_geral).vr_flgcontr = 5 then
            vr_dsrelato := 'LIMITES DE CARTAO DE CREDITO';
            if vr_tab_geral(vr_indice_geral).vr_flgvalor = 1 then
              vr_desvalor := 'LIMITES ATE R$ '||to_char(vr_vllimcre - 0.01, 'fm999G990D00');
            elsif vr_tab_geral(vr_indice_geral).vr_flgvalor = 2 then
              vr_desvalor := 'CONTRATOS ACIMA R$ '||to_char(vr_vllimcre, 'fm999G990D00')||' INCLUSIVE';
            end if;
          elsif vr_tab_geral(vr_indice_geral).vr_flgcontr = 6 then
            vr_dsrelato := 'CONTRATOS LIMITE DESCONTO DE TITULO';
            if vr_tab_geral(vr_indice_geral).vr_flgvalor = 1 then
              vr_desvalor := 'CONTRATOS ATE R$ '||to_char(vr_vllimctr, 'fm999G990D00');
            elsif vr_tab_geral(vr_indice_geral).vr_flgvalor = 2 then
              vr_desvalor := 'CONTRATOS ACIMA R$ '||to_char(vr_vllimctr, 'fm999G990D00')||' INCLUSIVE';
            end if;
          end if;
          -- Se mudou o tipo, abre o novo tipo no XML
          if vr_tab_geral(vr_indice_geral).vr_flgcontr <> vr_flgcontr then
            gene0002.pc_escreve_xml(vr_des_xml,vr_des_xml_temp,'<tipo dsrelato="'||vr_dsrelato||'">');
          end if;
          -- Abre o novo valor no XML
          gene0002.pc_escreve_xml(vr_des_xml,vr_des_xml_temp,
                         '<valor desvalor="'||vr_desvalor||'">'||
                           '<dtmvtolt>'||to_char(vr_tab_geral(vr_indice_geral).vr_dtmvtolt, 'dd/mm/yyyy')||'</dtmvtolt>'||
                           '<cdbccxlt>'||vr_tab_geral(vr_indice_geral).vr_cdbccxlt||'</cdbccxlt>'||
                           '<dtlibbdc></dtlibbdc>');
          -- Atualiza as variáveis de controle de quebra
          vr_flgvalor := vr_tab_geral(vr_indice_geral).vr_flgvalor;
          vr_flgcontr := vr_tab_geral(vr_indice_geral).vr_flgcontr;
        end if;
        --
        if vr_tab_geral(vr_indice_geral).vr_flgcontr <> 3 then
          -- Limites e cartões; Empréstimos, Desconto de cheques e titulos (todos possuem o mesmo layout)
          -- Escreve no XML o detalhe da informação
          gene0002.pc_escreve_xml(vr_des_xml,vr_des_xml_temp,
                         '<conta nrdconta="'||to_char(vr_tab_geral(vr_indice_geral).vr_nrdconta, 'fm9999G999G9')||
                              '" tplayout="'||vr_tab_geral(vr_indice_geral).vr_flgcontr||'" '||
                              ' dsemprst="'||vr_tab_geral(vr_indice_geral).vr_dsemprst||'" >'||
                           '<nrctremp>'||to_char(vr_tab_geral(vr_indice_geral).vr_nrctremp, 'fm99G999G999')||'</nrctremp>'||
                           '<nmprimtl>'||vr_tab_geral(vr_indice_geral).vr_nmprimtl||'</nmprimtl>'||
                           '<vlemprst>'||vr_tab_geral(vr_indice_geral).vr_vlemprst||'</vlemprst>'||
                           '<vlemprst_form>'||to_char(vr_tab_geral(vr_indice_geral).vr_vlemprst, 'fm999G999G990D00')||'</vlemprst_form>'||
                           '<nrdolote>'||to_char(vr_tab_geral(vr_indice_geral).vr_nrdolote, 'fm999G999')||'</nrdolote>'||
                           '<nrctrlim></nrctrlim>'||
                           '<nrborder></nrborder>'||
                           '<dtmvtolt></dtmvtolt>'||
                           '<formalizacao>'||NVL(vr_tab_geral(vr_indice_geral).vr_formalizacao,'FISICO')||'</formalizacao>'|| -- Pj470 - SM2 -- MArcelo Telles Coelho -- Mouts
                           '<nraditiv></nraditiv>'||
                           '<tpaditiv></tpaditiv>'||
                           '<dsaditiv></dsaditiv>'||
                           '<dstipctr></dstipctr>'||
                         '</conta>');
        end if;
      end if;
      vr_indice_geral := vr_tab_geral.next(vr_indice_geral);
    end loop;
    -- Caso tenha gerado alguma informação no XML, deve fechar as TAGs que ficaram abertas
    if vr_flgvalor <> 0 then
      gene0002.pc_escreve_xml(vr_des_xml,vr_des_xml_temp,'</valor></tipo>');
    end if;
    --Início SD#539415
    --o loop de emprestimos finalizou sem incluir os aditivos devido a troca de filial, mesmo
    --existindo registros na pl/table. Se não lançou então deve incluir.
    if vr_lancou_aditivos = 'N' then
      pc_inclui_aditivos_xml(rw_crapage.cdagenci);
    end if;
    --Fim SD#539415
    -- Processamento dos borderôs (antiga processa_borderos)
    vr_vllanbdc := 0;
    vr_vlemprst_total := 0;
    --
    vr_tab_separados.delete;
    vr_indice_separados := '0';
    -- Inicia a leitura da pl/table de borderôs
    vr_indice_bordero := vr_tab_bordero.first;
    while vr_indice_bordero is not null loop
      -- Verifica se é a agência correta
      if vr_tab_bordero(vr_indice_bordero).vr_cdagenci = rw_crapage.cdagenci then
        -- Verifica se mudou o agrupamento
        if vr_indice_separados <> to_char(vr_tab_bordero(vr_indice_bordero).vr_dtlibbdc, 'yyyymmdd')||
                                  to_char(vr_tab_bordero(vr_indice_bordero).vr_cdagenci, 'fm000')||
                                  to_char(vr_tab_bordero(vr_indice_bordero).vr_cdbccxlt, 'fm00000')||
                                  to_char(vr_tab_bordero(vr_indice_bordero).vr_nrdolote, 'fm0000000000')||
                                  to_char(vr_tab_bordero(vr_indice_bordero).vr_nrctrlim, 'fm0000000000')||
                                  to_char(vr_tab_bordero(vr_indice_bordero).vr_nrborder, 'fm0000000000')||
                                  to_char(vr_tab_bordero(vr_indice_bordero).vr_nrdconta, 'fm0000000000')||
                                  RPAD(vr_tab_bordero(vr_indice_bordero).vr_cdoperad,10,' ') then
          -- Monta o novo índice
          vr_indice_separados := to_char(vr_tab_bordero(vr_indice_bordero).vr_dtlibbdc, 'yyyymmdd')||
                                 to_char(vr_tab_bordero(vr_indice_bordero).vr_cdagenci, 'fm000')||
                                 to_char(vr_tab_bordero(vr_indice_bordero).vr_cdbccxlt, 'fm00000')||
                                 to_char(vr_tab_bordero(vr_indice_bordero).vr_nrdolote, 'fm0000000000')||
                                 to_char(vr_tab_bordero(vr_indice_bordero).vr_nrctrlim, 'fm0000000000')||
                                 to_char(vr_tab_bordero(vr_indice_bordero).vr_nrborder, 'fm0000000000')||
                                 to_char(vr_tab_bordero(vr_indice_bordero).vr_nrdconta, 'fm0000000000')||
                                 RPAD(vr_tab_bordero(vr_indice_bordero).vr_cdoperad,10,' ');
          -- Zera o totalizador
          vr_vllanbdc := 0;
        end if;
        -- Acumula valores
        vr_vllanbdc       := vr_vllanbdc       + vr_tab_bordero(vr_indice_bordero).vr_vldocmto;
        vr_vlemprst_total := vr_vlemprst_total + vr_tab_bordero(vr_indice_bordero).vr_vldocmto;
        -- Verifica se já existe informação na pl/table. Se existe, altera o valor. Se não existe, cria.
        if not vr_tab_separados.exists(vr_indice_separados) then
          vr_tab_separados(vr_indice_separados).vr_tpctrlim := vr_tab_bordero(vr_indice_bordero).vr_tpctrlim;
          vr_tab_separados(vr_indice_separados).vr_nrdconta := vr_tab_bordero(vr_indice_bordero).vr_nrdconta;
          vr_tab_separados(vr_indice_separados).vr_nrctrlim := vr_tab_bordero(vr_indice_bordero).vr_nrctrlim;
          vr_tab_separados(vr_indice_separados).vr_nrborder := vr_tab_bordero(vr_indice_bordero).vr_nrborder;
          vr_tab_separados(vr_indice_separados).vr_nmprimtl := vr_tab_bordero(vr_indice_bordero).vr_nmprimtl;
          vr_tab_separados(vr_indice_separados).vr_nrdolote := vr_tab_bordero(vr_indice_bordero).vr_nrdolote;
          vr_tab_separados(vr_indice_separados).vr_dtmvtolt := vr_tab_bordero(vr_indice_bordero).vr_dtmvtolt;
          vr_tab_separados(vr_indice_separados).vr_dtlibbdc := vr_tab_bordero(vr_indice_bordero).vr_dtlibbdc;
          vr_tab_separados(vr_indice_separados).vr_cdagenci := rw_crapage.cdagenci;
          vr_tab_separados(vr_indice_separados).vr_nmresage := rw_crapage.nmresage;
          vr_tab_separados(vr_indice_separados).vr_cdbccxlt := vr_tab_bordero(vr_indice_bordero).vr_cdbccxlt;
          vr_tab_separados(vr_indice_separados).vr_formalizacao := vr_tab_bordero(vr_indice_bordero).vr_formalizacao; -- Pj470 - SM2 -- MArcelo Telles Coelho -- Mouts
        end if;
        vr_tab_separados(vr_indice_separados).vr_vlemprst := vr_vllanbdc;
        -- Define o título da seção do relatório
        if vr_tab_bordero(vr_indice_bordero).vr_tpctrlim = 1 then
          vr_dsrelato := 'LANCAMENTOS BORDEROS DESCONTO DE CHEQUE';
        else
          vr_dsrelato := 'LANCAMENTOS BORDEROS DESCONTO DE TITULO';
        end if;
        -- Define os flags e títulos a utilizar
        if vr_tab_bordero(vr_indice_bordero).vr_tpctrlim = 1 then
          vr_flgcontr := 3;
        else
          vr_flgcontr := 7;
        end if;
        --
        -- Projeto 470 - Marcelo Telles Coelho - Mouts
        -- Deixar de fazer a quebra até R$ 2.000,00
        -- if vr_tab_separados(vr_indice_separados).vr_vlemprst < 2000 then
        --   vr_desvalor := 'BORDEROS ATE R$ 1.999,99';
        --   vr_flgvalor := 1;
        -- elsif vr_tab_separados(vr_indice_separados).vr_vlemprst >= 2000  then
        --   vr_desvalor := 'BORDEROS ACIMA R$ 2.000,00  INCLUSIVE';
        --   vr_flgvalor := 2;
        -- end if;
        -- Passar a fazer quebra única
        vr_desvalor := 'BORDEROS ACIMA R$ 0,00 INCLUSIVE';
          vr_flgvalor := 1;
        -- Fim Projeto 470
        --
        -- Define o índice das tabelas gerais
        vr_indice_geral := to_char(rw_crapage.cdagenci, 'fm00000')||
                           to_char(vr_flgcontr)||
                           to_char(vr_flgvalor)||
                           to_char(vr_tab_bordero(vr_indice_bordero).vr_nrdconta, 'fm0000000000')||
                           to_char(vr_tab_bordero(vr_indice_bordero).vr_nrctrlim, 'fm0000000000')||
                           to_char(vr_tab_separados(vr_indice_separados).vr_nrborder, 'fm0000000000');
        --
        vr_indice_geral2 := to_char(vr_flgcontr)||
                            to_char(vr_flgvalor)||
                            to_char(rw_crapage.cdagenci, 'fm00000')||
                            to_char(vr_tab_bordero(vr_indice_bordero).vr_nrdconta, 'fm0000000000')||
                            to_char(vr_tab_separados(vr_indice_separados).vr_vlemprst, 'fm0000000000000000000000000')||
                            to_char(vr_tab_bordero(vr_indice_bordero).vr_nrctrlim, 'fm0000000000')||
                            to_char(vr_tab_separados(vr_indice_separados).vr_nrborder, 'fm0000000000');
        -- Inclui na primeira tabela, ordenada por agencia
        vr_tab_geral(vr_indice_geral).vr_cdagenci := vr_tab_separados(vr_indice_separados).vr_cdagenci;
        vr_tab_geral(vr_indice_geral).vr_nrdconta := vr_tab_separados(vr_indice_separados).vr_nrdconta;
        vr_tab_geral(vr_indice_geral).vr_nrctremp := vr_tab_separados(vr_indice_separados).vr_nrctrlim;
        vr_tab_geral(vr_indice_geral).vr_nrborder := vr_tab_separados(vr_indice_separados).vr_nrborder;
        vr_tab_geral(vr_indice_geral).vr_nmprimtl := vr_tab_separados(vr_indice_separados).vr_nmprimtl;
        vr_tab_geral(vr_indice_geral).vr_vlemprst := vr_tab_separados(vr_indice_separados).vr_vlemprst;
        vr_tab_geral(vr_indice_geral).vr_cdpesqbb := to_char(vr_tab_separados(vr_indice_separados).vr_dtmvtolt, 'dd/mm/yy')||'-'||
                                                     to_char(vr_tab_separados(vr_indice_separados).vr_cdagenci)||'-'||
                                                     to_char(vr_tab_separados(vr_indice_separados).vr_cdbccxlt)||'-'||
                                                     to_char(vr_tab_separados(vr_indice_separados).vr_nrdolote);
        vr_tab_geral(vr_indice_geral).vr_cdoperad := vr_tab_bordero(vr_indice_bordero).vr_cdoperad;
        vr_tab_geral(vr_indice_geral).vr_flgcontr := vr_flgcontr;
        vr_tab_geral(vr_indice_geral).vr_dsrlgera := vr_dsrelato;
        vr_tab_geral(vr_indice_geral).vr_vlrgeral := vr_desvalor;
        vr_tab_geral(vr_indice_geral).vr_flgvalor := vr_flgvalor;
        vr_tab_geral(vr_indice_geral).vr_formalizacao :=vr_tab_separados(vr_indice_separados).vr_formalizacao; -- Pj470 - SM2 -- MArcelo Telles Coelho -- Mouts
        -- Inclui na segunda tabela, ordenada pelos indicadores e depois por agencia e conta
        vr_tab_geral2(vr_indice_geral2).vr_cdagenci := vr_tab_separados(vr_indice_separados).vr_cdagenci;
        vr_tab_geral2(vr_indice_geral2).vr_nrdconta := vr_tab_separados(vr_indice_separados).vr_nrdconta;
        vr_tab_geral2(vr_indice_geral2).vr_nrctremp := vr_tab_separados(vr_indice_separados).vr_nrctrlim;
        vr_tab_geral2(vr_indice_geral2).vr_nrborder := vr_tab_separados(vr_indice_separados).vr_nrborder;
        vr_tab_geral2(vr_indice_geral2).vr_nmprimtl := vr_tab_separados(vr_indice_separados).vr_nmprimtl;
        vr_tab_geral2(vr_indice_geral2).vr_vlemprst := vr_tab_separados(vr_indice_separados).vr_vlemprst;
        vr_tab_geral2(vr_indice_geral2).vr_cdpesqbb := to_char(vr_tab_separados(vr_indice_separados).vr_dtmvtolt, 'dd/mm/yy')||'-'||
                                                       to_char(vr_tab_separados(vr_indice_separados).vr_cdagenci)||'-'||
                                                       to_char(vr_tab_separados(vr_indice_separados).vr_cdbccxlt)||'-'||
                                                       to_char(vr_tab_separados(vr_indice_separados).vr_nrdolote);
        vr_tab_geral2(vr_indice_geral2).vr_cdoperad := vr_tab_bordero(vr_indice_bordero).vr_cdoperad;
        vr_tab_geral2(vr_indice_geral2).vr_flgcontr := vr_flgcontr;
        vr_tab_geral2(vr_indice_geral2).vr_dsrlgera := vr_dsrelato;
        vr_tab_geral2(vr_indice_geral2).vr_vlrgeral := vr_desvalor;
        vr_tab_geral2(vr_indice_geral2).vr_flgvalor := vr_flgvalor;
        vr_tab_geral2(vr_indice_geral2).vr_formalizacao := vr_tab_separados(vr_indice_separados).vr_formalizacao; -- Pj470 - SM2 -- MArcelo Telles Coelho -- Mouts
      end if;
      vr_indice_bordero := vr_tab_bordero.next(vr_indice_bordero);
    end loop;
    --
    -- imprime_bordero_cheques - valor baixo
    --
    vr_dsrelato := 'LANCAMENTOS BORDEROS DESCONTO DE CHEQUE';
    vr_desvalor := 'BORDEROS ATE R$ 1.999,99';
    vr_flesctgvl := false;
    -- Abre o grupo TIPO
    gene0002.pc_escreve_xml(vr_des_xml,vr_des_xml_temp,'<tipo dsrelato="'||vr_dsrelato||'">');
    -- Primeira leitura dos borderôs
    vr_indice_separados := vr_tab_separados.first;
    while vr_indice_separados is not null loop
      -- Projeto 470 - Marcelo Telles Coelho - Mouts
      -- Deixar de fazer a quebra até R$ 2.000,00
      if vr_tab_separados(vr_indice_separados).vr_tpctrlim = 1 and
         -- vr_tab_separados(vr_indice_separados).vr_vlemprst < 2000 then
         vr_tab_separados(vr_indice_separados).vr_vlemprst < 0 then
      -- Fim Projeto 470
        if not vr_flesctgvl then
          -- Na primeira volta do loop, deve abrir o grupo VALOR
          gene0002.pc_escreve_xml(vr_des_xml,vr_des_xml_temp
                          ,'<valor desvalor="'||vr_desvalor||'">'||
                           '<dtmvtolt></dtmvtolt>'||
                           '<cdbccxlt>'||vr_tab_separados(vr_indice_separados).vr_cdbccxlt||'</cdbccxlt>'||
                           '<dtlibbdc>'||to_char(vr_tab_separados(vr_indice_separados).vr_dtlibbdc, 'dd/mm/yyyy')||'</dtlibbdc>');
          vr_flesctgvl := true;
        end if;
        gene0002.pc_escreve_xml(vr_des_xml,vr_des_xml_temp,
                       '<conta nrdconta="'||to_char(vr_tab_separados(vr_indice_separados).vr_nrdconta, 'fm9999G999G9')||
                            '" tplayout="3">'||
                            ' dsemprst="" >'||
                         '<nrctremp></nrctremp>'||
                         '<nmprimtl>'||vr_tab_separados(vr_indice_separados).vr_nmprimtl||'</nmprimtl>'||
                         '<vlemprst>'||vr_tab_separados(vr_indice_separados).vr_vlemprst||'</vlemprst>'||
                         '<vlemprst_form>'||to_char(vr_tab_separados(vr_indice_separados).vr_vlemprst, 'fm999G999G990D00')||'</vlemprst_form>'||
                         '<nrdolote>'||to_char(vr_tab_separados(vr_indice_separados).vr_nrdolote, 'fm999G999')||'</nrdolote>'||
                         '<nrctrlim>'||to_char(vr_tab_separados(vr_indice_separados).vr_nrctrlim, 'fm99G999G999')||'</nrctrlim>'||
                         '<nrborder>'||to_char(vr_tab_separados(vr_indice_separados).vr_nrborder, 'fm99G999G999')||'</nrborder>'||
                         '<dtmvtolt>'||to_char(vr_tab_separados(vr_indice_separados).vr_dtmvtolt, 'dd/mm/yyyy')||'</dtmvtolt>'||
                         '<formalizacao>'||NVL(vr_tab_separados(vr_indice_separados).vr_formalizacao,'FISICO')||'</formalizacao>'|| -- Pj470 - SM2 -- MArcelo Telles Coelho -- Mouts
                         '<nraditiv></nraditiv>'||
                         '<tpaditiv></tpaditiv>'||
                         '<dsaditiv></dsaditiv>'||
                         '<dstipctr></dstipctr>'||
                       '</conta>');
      end if;
      vr_indice_separados := vr_tab_separados.next(vr_indice_separados);
    end loop;
    if vr_flesctgvl then
      -- Fecha a TAG do valor
      gene0002.pc_escreve_xml(vr_des_xml,vr_des_xml_temp,'</valor>');
    end if;
    -- imprime_bordero_cheques - valor alto
    -- vr_desvalor := 'BORDEROS ACIMA R$ 2.000,00  INCLUSIVE'; -- Projeto 470 - Marcelo Telles Coelho - Mouts
    vr_desvalor := 'BORDEROS ACIMA R$ 0,00  INCLUSIVE'; -- Projeto 470 - Marcelo Telles Coelho - Mouts
    vr_flesctgvl := false;
    -- primeira leitura dos borderôs
    vr_indice_separados := vr_tab_separados.first;
    while vr_indice_separados is not null loop
      -- Projeto 470 - Marcelo Telles Coelho - Mouts
      -- Deixar de fazer a quebra até R$ 2.000,00
      if vr_tab_separados(vr_indice_separados).vr_tpctrlim = 1 and
         -- vr_tab_separados(vr_indice_separados).vr_vlemprst >= 2000 then
         vr_tab_separados(vr_indice_separados).vr_vlemprst >= 0 then
      -- Fim Projeto 470
        if not vr_flesctgvl then
          -- Na primeira volta do loop, deve abrir o grupo VALOR
          gene0002.pc_escreve_xml(vr_des_xml,vr_des_xml_temp
                             ,'<valor desvalor="'||vr_desvalor||'">'||
                             '<dtmvtolt></dtmvtolt>'||
                             '<cdbccxlt>'||vr_tab_separados(vr_indice_separados).vr_cdbccxlt||'</cdbccxlt>'||
                             '<dtlibbdc>'||to_char(vr_tab_separados(vr_indice_separados).vr_dtlibbdc, 'dd/mm/yyyy')||'</dtlibbdc>');
          vr_flesctgvl := true;
        end if;
        gene0002.pc_escreve_xml(vr_des_xml,vr_des_xml_temp
                       ,'<conta nrdconta="'||to_char(vr_tab_separados(vr_indice_separados).vr_nrdconta, 'fm9999G999G9')||
                            '" tplayout="3" '||
                            ' dsemprst="" >'||
                         '<nrctremp></nrctremp>'||
                         '<nmprimtl>'||vr_tab_separados(vr_indice_separados).vr_nmprimtl||'</nmprimtl>'||
                         '<vlemprst>'||vr_tab_separados(vr_indice_separados).vr_vlemprst||'</vlemprst>'||
                         '<vlemprst_form>'||to_char(vr_tab_separados(vr_indice_separados).vr_vlemprst, 'fm999G999G990D00')||'</vlemprst_form>'||
                         '<nrdolote>'||to_char(vr_tab_separados(vr_indice_separados).vr_nrdolote, 'fm999G999')||'</nrdolote>'||
                         '<nrctrlim>'||to_char(vr_tab_separados(vr_indice_separados).vr_nrctrlim, 'fm99G999G999')||'</nrctrlim>'||
                         '<nrborder>'||to_char(vr_tab_separados(vr_indice_separados).vr_nrborder, 'fm99G999G999')||'</nrborder>'||
                         '<dtmvtolt>'||to_char(vr_tab_separados(vr_indice_separados).vr_dtmvtolt, 'dd/mm/yyyy')||'</dtmvtolt>'||
                         '<formalizacao>'||NVL(vr_tab_separados(vr_indice_separados).vr_formalizacao,'FISICO')||'</formalizacao>'|| -- Pj470 - SM2 -- MArcelo Telles Coelho -- Mouts
                         '<nraditiv></nraditiv>'||
                         '<tpaditiv></tpaditiv>'||
                         '<dsaditiv></dsaditiv>'||
                         '<dstipctr></dstipctr>'||
                       '</conta>');
      end if;
      vr_indice_separados := vr_tab_separados.next(vr_indice_separados);
    end loop;
    if vr_flesctgvl then
      -- Fecha a TAG do valor
      gene0002.pc_escreve_xml(vr_des_xml,vr_des_xml_temp,'</valor>');
    end if;
    -- Fecha a TAG do TIPO, pois vai mudar
    gene0002.pc_escreve_xml(vr_des_xml,vr_des_xml_temp,'</tipo>');
    --
    -- imprime_bordero_titulos - valor baixo
    --
    vr_dsrelato := 'LANCAMENTOS BORDEROS DESCONTO DE TITULO';
    vr_desvalor := 'BORDEROS ATE R$ 1.999,99';
    vr_flesctgvl := false;
    -- Abre o grupo TIPO
    gene0002.pc_escreve_xml(vr_des_xml,vr_des_xml_temp,'<tipo dsrelato="'||vr_dsrelato||'">');
    -- primeira leitura dos borderôs
    vr_indice_separados := vr_tab_separados.first;
    while vr_indice_separados is not null loop
      -- Projeto 470 - Marcelo Telles Coelho - Mouts
      -- Deixar de fazer a quebra até R$ 2.000,00
      if vr_tab_separados(vr_indice_separados).vr_tpctrlim = 2 and
--         vr_tab_separados(vr_indice_separados).vr_vlemprst < 2000 then
         vr_tab_separados(vr_indice_separados).vr_vlemprst < 0 then
      -- Fim Projeto 470
        if not vr_flesctgvl then
          -- Na primeira volta do loop, deve abrir o grupo VALOR
          gene0002.pc_escreve_xml(vr_des_xml,vr_des_xml_temp
                            ,'<valor desvalor="'||vr_desvalor||'">'||
                             '<dtmvtolt></dtmvtolt>'||
                             '<cdbccxlt>'||vr_tab_separados(vr_indice_separados).vr_cdbccxlt||'</cdbccxlt>'||
                             '<dtlibbdc>'||to_char(vr_tab_separados(vr_indice_separados).vr_dtlibbdc, 'dd/mm/yyyy')||'</dtlibbdc>');
          vr_flesctgvl := true;
        end if;
        gene0002.pc_escreve_xml(vr_des_xml,vr_des_xml_temp
                       ,'<conta nrdconta="'||to_char(vr_tab_separados(vr_indice_separados).vr_nrdconta, 'fm9999G999G9')||
                            '" tplayout="7" '||
                            ' dsemprst="" >'||
                         '<nrctremp></nrctremp>'||
                         '<nmprimtl>'||vr_tab_separados(vr_indice_separados).vr_nmprimtl||'</nmprimtl>'||
                         '<vlemprst>'||vr_tab_separados(vr_indice_separados).vr_vlemprst||'</vlemprst>'||
                         '<vlemprst_form>'||to_char(vr_tab_separados(vr_indice_separados).vr_vlemprst, 'fm999G999G990D00')||'</vlemprst_form>'||
                         '<nrdolote>'||to_char(vr_tab_separados(vr_indice_separados).vr_nrdolote, 'fm999G999')||'</nrdolote>'||
                         '<nrctrlim>'||to_char(vr_tab_separados(vr_indice_separados).vr_nrctrlim, 'fm99G999G999')||'</nrctrlim>'||
                         '<nrborder>'||to_char(vr_tab_separados(vr_indice_separados).vr_nrborder, 'fm99G999G999')||'</nrborder>'||
                         '<dtmvtolt>'||to_char(vr_tab_separados(vr_indice_separados).vr_dtmvtolt, 'dd/mm/yyyy')||'</dtmvtolt>'||
                         '<formalizacao>'||NVL(vr_tab_separados(vr_indice_separados).vr_formalizacao,'FISICO')||'</formalizacao>'|| -- Pj470 - SM2 -- MArcelo Telles Coelho -- Mouts
                         '<nraditiv></nraditiv>'||
                         '<tpaditiv></tpaditiv>'||
                         '<dsaditiv></dsaditiv>'||
                         '<dstipctr></dstipctr>'||
                       '</conta>');
      end if;
      vr_indice_separados := vr_tab_separados.next(vr_indice_separados);
    end loop;
    if vr_flesctgvl then
      -- Fecha a TAG do valor
      gene0002.pc_escreve_xml(vr_des_xml,vr_des_xml_temp,'</valor>');
    end if;
    -- imprime_bordero_titulos - valor alto
    -- vr_desvalor := 'BORDEROS ACIMA R$ 2.000,00  INCLUSIVE'; -- Projeto 470 - Marcelo Telles Coelho - Mouts
    vr_desvalor := 'BORDEROS ACIMA R$ 0,00  INCLUSIVE'; -- Projeto 470 - Marcelo Telles Coelho - Mouts
    vr_flesctgvl := false;
    -- primeira leitura dos borderôs
    vr_indice_separados := vr_tab_separados.first;
    while vr_indice_separados is not null loop
      -- Projeto 470 - Marcelo Telles Coelho - Mouts
      -- Deixar de fazer a quebra até R$ 2.000,00
      if vr_tab_separados(vr_indice_separados).vr_tpctrlim = 2 and
         -- vr_tab_separados(vr_indice_separados).vr_vlemprst >= 2000 then
         vr_tab_separados(vr_indice_separados).vr_vlemprst >= 0 then
      -- Fim Projeto 470
        if not vr_flesctgvl then
          -- Na primeira volta do loop, deve abrir o grupo VALOR
          gene0002.pc_escreve_xml(vr_des_xml,vr_des_xml_temp,
                             '<valor desvalor="'||vr_desvalor||'">'||
                             '<dtmvtolt></dtmvtolt>'||
                             '<cdbccxlt>'||vr_tab_separados(vr_indice_separados).vr_cdbccxlt||'</cdbccxlt>'||
                             '<dtlibbdc>'||to_char(vr_tab_separados(vr_indice_separados).vr_dtlibbdc, 'dd/mm/yyyy')||'</dtlibbdc>');
          vr_flesctgvl := true;
        end if;
        gene0002.pc_escreve_xml(vr_des_xml,vr_des_xml_temp,
                         '<conta nrdconta="'||to_char(vr_tab_separados(vr_indice_separados).vr_nrdconta, 'fm9999G999G9')||
                            '" tplayout="7" '||
                            ' dsemprst="" >'||
                         '<nrctremp></nrctremp>'||
                         '<nmprimtl>'||vr_tab_separados(vr_indice_separados).vr_nmprimtl||'</nmprimtl>'||
                         '<vlemprst>'||vr_tab_separados(vr_indice_separados).vr_vlemprst||'</vlemprst>'||
                         '<vlemprst_form>'||to_char(vr_tab_separados(vr_indice_separados).vr_vlemprst, 'fm999G999G990D00')||'</vlemprst_form>'||
                         '<nrdolote>'||to_char(vr_tab_separados(vr_indice_separados).vr_nrdolote, 'fm999G999')||'</nrdolote>'||
                         '<nrctrlim>'||to_char(vr_tab_separados(vr_indice_separados).vr_nrctrlim, 'fm99G999G999')||'</nrctrlim>'||
                         '<nrborder>'||to_char(vr_tab_separados(vr_indice_separados).vr_nrborder, 'fm99G999G999')||'</nrborder>'||
                         '<dtmvtolt>'||to_char(vr_tab_separados(vr_indice_separados).vr_dtmvtolt, 'dd/mm/yyyy')||'</dtmvtolt>'||
                         '<formalizacao>'||NVL(vr_tab_separados(vr_indice_separados).vr_formalizacao,'FISICO')||'</formalizacao>'|| -- Pj470 - SM2 -- MArcelo Telles Coelho -- Mouts
                         '<nraditiv></nraditiv>'||
                         '<tpaditiv></tpaditiv>'||
                         '<dsaditiv></dsaditiv>'||
                         '<dstipctr></dstipctr>'||
                       '</conta>');
      end if;
      vr_indice_separados := vr_tab_separados.next(vr_indice_separados);
    end loop;
    if vr_flesctgvl then
      -- Fecha a TAG do valor
      gene0002.pc_escreve_xml(vr_des_xml,vr_des_xml_temp,'</valor>');
    end if;
    -- Fecha a TAG do TIPO
    gene0002.pc_escreve_xml(vr_des_xml,vr_des_xml_temp,'</tipo>');
    -- Fecha as TAGs abertas
    gene0002.pc_escreve_xml(vr_des_xml,vr_des_xml_temp,'</agencia></agencias>',true);
    -- Verifica se existe informação útil no arquivo
    if instr(vr_des_xml, '<valor') = 0 then
      dbms_lob.close(vr_des_xml);
      dbms_lob.freetemporary(vr_des_xml);
      continue;
    end if;

    -- PAra Viacredi não há chamada ao Imprim.p
    IF pr_cdcooper = 1 THEN -- Cfe. chamado 8482 - Edson
      -- Limpar as variaveis de chamada ao Imprim.p
      vr_flgimpri := 'N';
      vr_nrcopias := null;
    ELSE
      -- Haverá imprim.p
      vr_flgimpri := 'S';
      -- Para Credifiesc e Credcrea
      if pr_cdcooper in (6, 7) then
        -- Apenas 1 cópia
        vr_nrcopias := 1;
      else
        -- Para outras, duas cópias
        vr_nrcopias := 2;
      end if;
    END IF;

    -- Solicita a geração do relatório
    gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper,         --> Cooperativa conectada
                                pr_cdprogra  => vr_cdprogra,         --> Programa chamador
                                pr_dtmvtolt  => rw_crapdat.dtmvtolt, --> Data do movimento atual
                                pr_dsxml     => vr_des_xml,          --> Arquivo XML de dados (CLOB)
                                pr_dsxmlnode => '/agencias/agencia/tipo/valor', --> Nó base do XML para leitura dos dados
                                pr_dsjasper  => 'crrl266.jasper',    --> Arquivo de layout do iReport
                                pr_dsparams  => null,   --> Enviar como parâmetro apenas a agência
                                pr_dsarqsaid => vr_nom_diretorio||'/'||vr_nom_arquivo||'.lst', --> Arquivo final com código da agência
                                pr_flg_gerar => 'N',
                                pr_flg_impri => vr_flgimpri,         --> Chamar a impressão (Imprim.p)
                                pr_nmformul  => null,                --> Nome do formulário para impressão
                                pr_nrcopias  => vr_nrcopias,
                                pr_qtcoluna  => 132,
                                pr_nrvergrl  => 1,                   --> TIBCO -- Pj470 - SM2 -- MArcelo Telles Coelho -- Mouts
                                pr_des_erro  => vr_dscritic);        --> Saída com erro
    -- Liberando a memória alocada pro CLOB
    dbms_lob.close(vr_des_xml);
    dbms_lob.freetemporary(vr_des_xml);
    -- Verifica se ocorreu erro na geração do arquivo ou na solicitação do relatório
    if vr_dscritic is not null then
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                 pr_ind_tipo_log => 2, -- Erro tratado
                                 pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' --> '|| vr_dscritic);
    end if;
  end loop;
  -- Nome base do arquivo é crrl266
  vr_nom_arquivo := 'crrl266_'||gene0001.fn_param_sistema('CRED',pr_cdcooper,'SUFIXO_RELATO_TOTAL');
  -- Inicializar o CLOB
  dbms_lob.createtemporary(vr_des_xml, TRUE);
  dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
  -- Inicilizar as informações do XML
  gene0002.pc_escreve_xml(vr_des_xml,vr_des_xml_temp,'<?xml version="1.0" encoding="utf-8"?><agencias>');
  -- Inicializar as variáveis de controle de quebra
  vr_flgcontr := 0;
  vr_flgvalor := 0;
  vr_lancou_aditivos := 'N'; --SD#539415
  -- Relatorio Geral (234 colunas)
  vr_indice_geral2 := vr_tab_geral2.first;
  while vr_indice_geral2 is not null loop
    -- Verificação de quebra
    if vr_tab_geral2(vr_indice_geral2).vr_flgcontr <> vr_flgcontr or
       vr_tab_geral2(vr_indice_geral2).vr_flgvalor <> vr_flgvalor then
      -- Houve uma quebra. Deve verificar quais grupos deve fechar.
      if vr_flgvalor <> 0 then
        -- Se não for a primeira volta do loop, fecha o grupo do valor
        gene0002.pc_escreve_xml(vr_des_xml,vr_des_xml_temp,'</valor>');
        --
        if vr_tab_geral2(vr_indice_geral2).vr_flgcontr <> vr_flgcontr then
          -- Se mudou o tipo, fecha o grupo do tipo
          gene0002.pc_escreve_xml(vr_des_xml,vr_des_xml_temp,'</tipo>');
        end if;
      end if;
      -- Os aditivos devem entrar após os contratos de empréstimos
      if vr_flgcontr <= 1 and
         vr_tab_geral2(vr_indice_geral2).vr_flgcontr >= 2 then
        pc_inclui_aditivos_xml(99);
        vr_lancou_aditivos := 'S'; --SD#539415
      end if;
      -- Se mudou o tipo, abre o novo tipo no XML
      if vr_tab_geral2(vr_indice_geral2).vr_flgcontr <> vr_flgcontr then
        gene0002.pc_escreve_xml(vr_des_xml,vr_des_xml_temp,'<tipo dsrelato="'||vr_tab_geral2(vr_indice_geral2).vr_dsrlgera||'">');
      end if;
      -- Abre o novo valor no XML
      gene0002.pc_escreve_xml(vr_des_xml,vr_des_xml_temp,'<valor desvalor="'||vr_tab_geral2(vr_indice_geral2).vr_vlrgeral||'">');
      vr_flesctgvl := true;
      -- Atualiza as variáveis de controle de quebra
      vr_flgvalor := vr_tab_geral2(vr_indice_geral2).vr_flgvalor;
      vr_flgcontr := vr_tab_geral2(vr_indice_geral2).vr_flgcontr;
    end if;
    --
    gene0002.pc_escreve_xml(vr_des_xml,vr_des_xml_temp,
                   '<conta nrdconta="'||to_char(vr_tab_geral2(vr_indice_geral2).vr_nrdconta, 'fm9999G999G9')||
                        '" tplayout="'||vr_tab_geral2(vr_indice_geral2).vr_flgcontr||'" '||
                        ' dsemprst="'||vr_tab_geral2(vr_indice_geral2).vr_dsemprst||'" >'||
                     '<cdagenci>'||vr_tab_geral2(vr_indice_geral2).vr_cdagenci||'</cdagenci>'||
                     '<nrctremp>'||to_char(vr_tab_geral2(vr_indice_geral2).vr_nrctremp, 'fm99G999G999')||'</nrctremp>'||
                     '<nmprimtl>'||vr_tab_geral2(vr_indice_geral2).vr_nmprimtl||'</nmprimtl>'||
                     '<vlemprst>'||vr_tab_geral2(vr_indice_geral2).vr_vlemprst||'</vlemprst>'||
                     '<vlemprst_form>'||to_char(vr_tab_geral2(vr_indice_geral2).vr_vlemprst, 'fm999G999G990D00')||'</vlemprst_form>'||
                     '<cdpesqbb>'||vr_tab_geral2(vr_indice_geral2).vr_cdpesqbb||'</cdpesqbb>'||
                     '<cdoperad>'||vr_tab_geral2(vr_indice_geral2).vr_cdoperad||'</cdoperad>'||
                     '<nrborder>'||to_char(vr_tab_geral2(vr_indice_geral2).vr_nrborder, 'fm99G999G999')||'</nrborder>'||
                     '<formalizacao>'||NVL(vr_tab_geral2(vr_indice_geral2).vr_formalizacao,'FISICO')||'</formalizacao>'|| -- Pj470 - SM2 -- MArcelo Telles Coelho -- Mouts
                     '<nraditiv></nraditiv>'||
                     '<tpaditiv></tpaditiv>'||
                     '<dsaditiv></dsaditiv>'||
                     '<dstipctr></dstipctr>'||
                   '</conta>');
    -- Passa para o próximo registro da PL/Table
    vr_indice_geral2 := vr_tab_geral2.next(vr_indice_geral2);
  end loop;
  -- Se escreveu a tag de valor
  if vr_flesctgvl then
    -- Fecha a TAG do valor
    gene0002.pc_escreve_xml(vr_des_xml,vr_des_xml_temp,'</valor>');
    -- Fecha a TAG do TIPO
    gene0002.pc_escreve_xml(vr_des_xml,vr_des_xml_temp,'</tipo>');
  end if;
  --Início SD#539415
  --o loop de emprestimos finalizou sem incluir os aditivos devido a troca de filial, mesmo
  --existindo registros na pl/table. Se não lançou então deve incluir.
  if vr_lancou_aditivos = 'N' then
    pc_inclui_aditivos_xml(99);
  end if;
  --Fim SD#539415
  -- Fecha as TAGs abertas
  gene0002.pc_escreve_xml(vr_des_xml,vr_des_xml_temp,'</agencias>',true);
                           
  -- Chamada do iReport para gerar o arquivo de saída
  gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper,         --> Cooperativa conectada
                              pr_cdprogra  => vr_cdprogra,         --> Programa chamador
                              pr_dtmvtolt  => rw_crapdat.dtmvtolt, --> Data do movimento atual
                              pr_dsxml     => vr_des_xml,          --> Arquivo XML de dados (CLOB)
                              pr_dsxmlnode => '/agencias/tipo/valor', --> Nó base do XML para leitura dos dados
                              pr_dsjasper  => 'crrl26699.jasper',    --> Arquivo de layout do iReport
                              pr_dsparams  => null,   --> Enviar como parâmetro apenas a agência
                              pr_dsarqsaid => vr_nom_diretorio||'/'||vr_nom_arquivo||'.lst', --> Arquivo final com código da agência
                              pr_flg_gerar => 'N',
                              pr_flg_impri => 'S',           --> Chamar a impressão (Imprim.p)
                              pr_nmformul  => '234dh',       --> Nome do formulário para impressão
                              pr_nrcopias  => 1,             --> Número de cópias para impressão
                              pr_qtcoluna  => 234,
                              pr_nrvergrl  => 1,                   --> TIBCO -- Pj470 - SM2 -- MArcelo Telles Coelho -- Mouts
                              pr_des_erro  => vr_dscritic);       --> Saída com erro
  -- Verifica se ocorreu erro na geração do arquivo ou na solicitação do relatório
  if pr_dscritic is not null then
    btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                               pr_ind_tipo_log => 2, -- Erro tratado
                               pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' --> '|| vr_dscritic);
  end if;
  -- Liberando a memória alocada pro CLOB
  dbms_lob.close(vr_des_xml);
  dbms_lob.freetemporary(vr_des_xml);
  --

  -- Processo OK, devemos chamar a fimprg
  btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                           ,pr_cdprogra => vr_cdprogra
                           ,pr_infimsol => pr_infimsol
                           ,pr_stprogra => pr_stprogra);

  commit;

EXCEPTION
  WHEN vr_exc_saida THEN
    -- Se foi retornado apenas código
    IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
      -- Buscar a descrição
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
    END IF;
    -- Devolvemos código e critica encontradas
    pr_cdcritic := NVL(vr_cdcritic,0);
    pr_dscritic := vr_dscritic;
    -- Efetuar rollback
    ROLLBACK;
  when others then
    -- Efetuar retorno do erro não tratado
    pr_cdcritic := 0;
    pr_dscritic := SQLERRM;
    -- Efetuar rollback
    ROLLBACK;
end pc_crps314;
/
