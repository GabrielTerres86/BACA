CREATE OR REPLACE PROCEDURE CECRED."PC_CRPS010_1" (pr_cdcooper         IN crapcop.cdcooper%TYPE  --Código da Cooperativa
                                                  ,pr_cdprogra         IN crapprg.cdprogra%TYPE default null  --Codigo do programa chamador 
                                                  ,pr_dtmvtolt         IN crapdat.dtmvtolt%TYPE  --Data da utilizacao atual
                                                  ,pr_rel_nomemes1     OUT VARCHAR2  --Nome do mes 1
                                                  ,pr_rel_nomemes2     OUT VARCHAR2  --Nome do mes 2
                                                  ,pr_rel_nomemes3     OUT VARCHAR2  --Nome do mes 3
                                                  ,pr_res_qtassati     OUT NUMBER --Qtdade Associados mes anterior ativos
                                                  ,pr_res_qtassdem     OUT NUMBER --Qtdade Associados mes anterior demitidos
                                                  ,pr_res_qtassmes     OUT NUMBER --Qtdade Associados adimitidos
                                                  ,pr_res_qtdemmes_ati OUT NUMBER --Qtdade Associados mes ativo
                                                  ,pr_res_qtdemmes_dem OUT NUMBER --Qtdade Associados mes demitido
                                                  ,pr_res_qtassbai     OUT NUMBER --Qtdade Associados baixados
                                                  ,pr_res_qtdesmes_ati OUT NUMBER --Qtdade de Desdemissoes ativo
                                                  ,pr_res_qtdesmes_dem OUT NUMBER --Qtdade de Desdemissoes demitido
                                                  ,pr_res_vlcapcrz_exc OUT NUMBER --Valor Capital
                                                  ,pr_res_vlcapexc_fis OUT NUMBER --Valor Capital por PF
                                                  ,pr_res_vlcapexc_jur OUT NUMBER --Valor Capital por PJ                                                  
                                                  ,pr_res_vlcmicot_exc OUT NUMBER --Valor Cota CMI
                                                  ,pr_res_vlcmmcot_exc OUT NUMBER --Valor cota CMM
                                                  ,pr_res_vlcapmfx_exc OUT NUMBER --Valor Capital moeda fixa
                                                  ,pr_res_qtcotist_exc OUT NUMBER --Quantidade Cotistas Excluidos
                                                  ,pr_res_qtcotexc_fis OUT NUMBER --Quantidade Cotistas Excluidos por PF
                                                  ,pr_res_qtcotexc_jur OUT NUMBER --Quantidade Cotistas Excluidos por PJ                                                  
                                                  ,pr_res_vlcapcrz_tot OUT NUMBER --Valor Capital Total
                                                  ,pr_res_vlcaptot_fis OUT NUMBER --Valor Capital Total por PF
                                                  ,pr_res_vlcaptot_jur OUT NUMBER --Valor Capital Total por PJ
                                                  ,pr_res_vlcmicot_tot OUT NUMBER --Valor Cota CMI Total
                                                  ,pr_res_vlcmmcot_tot OUT NUMBER --Valor Cota CMM Total
                                                  ,pr_res_vlcapmfx_tot OUT NUMBER --Valor Capital moeda fixa Total
                                                  ,pr_res_qtcotist_tot OUT NUMBER --Quantidade Total Cotistas
                                                  ,pr_res_qtcottot_fis OUT NUMBER --Quantidade Total Cotistas por PF
                                                  ,pr_res_qtcottot_jur OUT NUMBER --Quantidade Total Cotistas por PJ
                                                  ,pr_tot_qtassati     OUT NUMBER --Total associados ativos
                                                  ,pr_tot_qtassdem     OUT NUMBER --Total associados demitidos
                                                  ,pr_tot_qtassexc     OUT NUMBER --Total associados excluidos
                                                  ,pr_tot_qtasexpf     OUT NUMBER --Total associados excluidos
                                                  ,pr_tot_qtasexpj     OUT NUMBER --Total associados excluidos
                                                  ,pr_cdcritic         OUT NUMBER -- Código de critica
                                                  ,pr_des_erro         OUT VARCHAR2) IS --Mensagem de Erro

  BEGIN
  /* ..........................................................................

     Programa: pc_crps010_1                        Antigo: fontes/crps010_1.p
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Deborah/Edson
     Data    : Abril/95.                           Ultima atualizacao: 21/06/2016

     Dados referentes ao programa:

     Frequencia: Mensal (Batch - Background).
     Objetivo  : Monta nome dos meses e inicializa resumo do capital.

     Alteracoes: 09/04/2001 - Tratar a tabela de VALORBAIXA somente nos meses
                              6 e 12 (Deborah).

                 14/02/2006 - Unificacao dos bancos - SQLWorks - Eder

                 12/03/2013 - Conversão Progress -> Oracle - Alisson (AMcom)

                 21/06/2016 - Correcao para o uso correto do indice da CRAPTAB nesta rotina.
                              SD 470740.(Carlos Rafael Tanholi).     
							  
		         05/01/2017 - Ajustado para não parar o processo em caso de parâmetro
							  nulo. (Rodrigo - 586601)   
  ............................................................................. */
    DECLARE

      /* Cursores Locais */

      --Selecionar informacoes das Matriculas
      CURSOR cr_crapmat (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
        SELECT crapmat.cdcooper
              ,crapmat.qtassati
              ,crapmat.qtassdem
              ,crapmat.qtassmes
              ,crapmat.qtdemmes
              ,crapmat.qtdesmes
              ,crapmat.qtassbai
              ,crapmat.qtasbxpf
              ,crapmat.qtasbxpj
        FROM crapmat crapmat
        WHERE crapmat.cdcooper = pr_cdcooper
        ORDER BY crapmat.progress_recid ASC;
      rw_crapmat cr_crapmat%ROWTYPE;

      --Variaveis Locais
      vr_des_erro     VARCHAR2(4000);
      vr_exc_erro     EXCEPTION;
      -- Guardar registro dstextab
      vr_dstextab craptab.dstextab%TYPE;
	  vr_flgfound BOOLEAN := TRUE;

    BEGIN
      
      -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => pr_cdprogra
                                ,pr_action => 'PC_CRPS010_1');
      
      --Inicializar variavel de erro
      pr_des_erro:= NULL;

      --Encontrar o mes do movimento e determinar os meses
      CASE To_Number(To_Char(pr_dtmvtolt,'MM'))
        WHEN 1 THEN
         pr_rel_nomemes1:= GENE0001.vr_vet_nmmesano(01);
         pr_rel_nomemes2:= GENE0001.vr_vet_nmmesano(12);
         pr_rel_nomemes3:= GENE0001.vr_vet_nmmesano(11);
        WHEN 2 THEN
         pr_rel_nomemes1:= GENE0001.vr_vet_nmmesano(02);
         pr_rel_nomemes2:= GENE0001.vr_vet_nmmesano(01);
         pr_rel_nomemes3:= GENE0001.vr_vet_nmmesano(12);
        WHEN 3 THEN
         pr_rel_nomemes1:= GENE0001.vr_vet_nmmesano(03);
         pr_rel_nomemes2:= GENE0001.vr_vet_nmmesano(02);
         pr_rel_nomemes3:= GENE0001.vr_vet_nmmesano(01);
        WHEN 4 THEN
         pr_rel_nomemes1:= GENE0001.vr_vet_nmmesano(04);
         pr_rel_nomemes2:= GENE0001.vr_vet_nmmesano(03);
         pr_rel_nomemes3:= GENE0001.vr_vet_nmmesano(02);
        WHEN 5 THEN
         pr_rel_nomemes1:= GENE0001.vr_vet_nmmesano(05);
         pr_rel_nomemes2:= GENE0001.vr_vet_nmmesano(04);
         pr_rel_nomemes3:= GENE0001.vr_vet_nmmesano(03);
        WHEN 6 THEN
         pr_rel_nomemes1:= GENE0001.vr_vet_nmmesano(06);
         pr_rel_nomemes2:= GENE0001.vr_vet_nmmesano(05);
         pr_rel_nomemes3:= GENE0001.vr_vet_nmmesano(04);
        WHEN 7 THEN
         pr_rel_nomemes1:= GENE0001.vr_vet_nmmesano(07);
         pr_rel_nomemes2:= GENE0001.vr_vet_nmmesano(06);
         pr_rel_nomemes3:= GENE0001.vr_vet_nmmesano(05);
        WHEN 8 THEN
         pr_rel_nomemes1:= GENE0001.vr_vet_nmmesano(08);
         pr_rel_nomemes2:= GENE0001.vr_vet_nmmesano(07);
         pr_rel_nomemes3:= GENE0001.vr_vet_nmmesano(06);
        WHEN 9 THEN
         pr_rel_nomemes1:= GENE0001.vr_vet_nmmesano(09);
         pr_rel_nomemes2:= GENE0001.vr_vet_nmmesano(08);
         pr_rel_nomemes3:= GENE0001.vr_vet_nmmesano(07);
        WHEN 10 THEN
         pr_rel_nomemes1:= GENE0001.vr_vet_nmmesano(10);
         pr_rel_nomemes2:= GENE0001.vr_vet_nmmesano(09);
         pr_rel_nomemes3:= GENE0001.vr_vet_nmmesano(08);
        WHEN 11 THEN
         pr_rel_nomemes1:= GENE0001.vr_vet_nmmesano(11);
         pr_rel_nomemes2:= GENE0001.vr_vet_nmmesano(10);
         pr_rel_nomemes3:= GENE0001.vr_vet_nmmesano(09);
        WHEN 12 THEN
         pr_rel_nomemes1:= GENE0001.vr_vet_nmmesano(12);
         pr_rel_nomemes2:= GENE0001.vr_vet_nmmesano(11);
         pr_rel_nomemes3:= GENE0001.vr_vet_nmmesano(10);
      END CASE;

      --Selecionar a primeira matricula
      OPEN cr_crapmat (pr_cdcooper => pr_cdcooper);
      --Posicionar no primeiro registro
      FETCH cr_crapmat INTO rw_crapmat;
      --Se nao encontrou
      IF cr_crapmat%NOTFOUND THEN
        --Fechar Cursor
        CLOSE cr_crapmat;
        -- Montar mensagem de critica
        pr_cdcritic := 71;
        vr_des_erro := gene0001.fn_busca_critica(pr_cdcritic => 71);
        RAISE vr_exc_erro;
      ELSE
        --Fechar Cursor
        CLOSE cr_crapmat;
        --Qtdade Associados mes anterior ativos recebe valor encontrado
        pr_res_qtassati:= rw_crapmat.qtassati;
        --Qtdade Associados mes anterior demitidos recebe valor encontrado
        pr_res_qtassdem:= rw_crapmat.qtassdem;
        --Qtdade Associados adimitidos rece valor encontrado
        pr_res_qtassmes:= rw_crapmat.qtassmes;
        --Qtdade Associados mes ativo recebe valor encontrado
        pr_res_qtdemmes_ati:= rw_crapmat.qtdemmes;
        --Qtdade Associados mes demitido recebe valor encontrado
        pr_res_qtdemmes_dem:= rw_crapmat.qtdemmes;
        --Qtdade Associados baixados recebe valor encontrado
        pr_res_qtassbai:= rw_crapmat.qtassbai;
        --Qtdade de Desdemissoes ativo recebe valor encontrado
        pr_res_qtdesmes_ati:= rw_crapmat.qtdesmes;
        --Qtdade de Desdemissoes demitido recebe valor encontrado
        pr_res_qtdesmes_dem:= rw_crapmat.qtdesmes;
        --Total associados ativos recebe associados ativos + associados mes - desassociados - demitidos
        pr_tot_qtassati:= Nvl(rw_crapmat.qtassati,0) + Nvl(rw_crapmat.qtassmes,0) +
                          Nvl(rw_crapmat.qtdesmes,0) - Nvl(rw_crapmat.qtdemmes,0);
        --Total associados demitidos recebe demitidos + demitidos mes - desdemitidos mes - baixados
        pr_tot_qtassdem:= Nvl(rw_crapmat.qtassdem,0) + Nvl(rw_crapmat.qtdemmes,0) -
                          Nvl(rw_crapmat.qtdesmes,0) - Nvl(rw_crapmat.qtassbai,0);
        --Total associados excluidos recebe baixados
        pr_tot_qtassexc:= rw_crapmat.qtassbai;
        --Total de associados PF excluidos recebe baixados
        pr_tot_qtasexpf:= rw_crapmat.qtasbxpf;
        --Total de associados PJ excluidos recebe baixados
        pr_tot_qtasexpj:= rw_crapmat.qtasbxpj;
      END IF;

      --Se o mes de atualização for Junho ou Dezembro
      IF To_Number(To_Char(pr_dtmvtolt,'MM')) IN (6,12) THEN

         -- Buscar configuração na tabela
         TABE0001.pc_busca_craptab(pr_cdcooper => pr_cdcooper
                         ,pr_nmsistem => 'CRED'
                         ,pr_tptabela => 'GENERI'
                         ,pr_cdempres => 0
                         ,pr_cdacesso => 'VALORBAIXA'
                                  ,pr_tpregist => 0
                                  ,pr_flgfound => vr_flgfound
                                  ,pr_dstextab => vr_dstextab);
         
         --Se nao encontrou entao
         IF NOT vr_flgfound THEN
           -- Montar mensagem de critica
           pr_cdcritic := 409;
           vr_des_erro := gene0001.fn_busca_critica(pr_cdcritic => 409);
           RAISE vr_exc_erro;
         ELSE
           --Valor Capital recebe valor tabela
           pr_res_vlcapcrz_exc:= GENE0002.fn_char_para_number(SUBSTR(vr_dstextab,001,016));
           --Valor Cota CMI recebe valor tabela
           pr_res_vlcmicot_exc:= GENE0002.fn_char_para_number(SUBSTR(vr_dstextab,018,016));
           --Valor cota CMM recebe valor tabela
           pr_res_vlcmmcot_exc:= GENE0002.fn_char_para_number(SUBSTR(vr_dstextab,035,016));
           --Valor Capital moeda fixa recebe valor tabela
           pr_res_vlcapmfx_exc:= GENE0002.fn_char_para_number(SUBSTR(vr_dstextab,052,016));
           --Valor Capital recebe valor tabela por PF
           pr_res_vlcapexc_fis:= GENE0002.fn_char_para_number(SUBSTR(vr_dstextab,069,016));
           --Valor Capital recebe valor tabela por PJ
           pr_res_vlcapexc_jur:= GENE0002.fn_char_para_number(SUBSTR(vr_dstextab,086,016));           
           --Quantidade Cotistas excluidos recebe total associados excluidos
           pr_res_qtcotist_exc:= pr_tot_qtassexc;
           --Quantidade Cotistas excluidos recebe total associados excluidos por PF
           pr_res_qtcotexc_fis:= pr_tot_qtasexpf;
           --Quantidade Cotistas excluidos recebe total associados excluidos por PJ
           pr_res_qtcotexc_jur:= pr_tot_qtasexpj;
           --Valor Capital Total recebe valor capital excluido
           pr_res_vlcapcrz_tot:= pr_res_vlcapcrz_exc;
           --Valor Capital Total recebe valor capital excluido por PF
           pr_res_vlcaptot_fis:= pr_res_vlcapexc_fis;
           --Valor Capital Total recebe valor capital excluido por PJ
           pr_res_vlcaptot_jur:= pr_res_vlcapexc_jur;
           --Valor Cota CMI Total recebe valor cmicot excluido
           pr_res_vlcmicot_tot:= pr_res_vlcmicot_exc;
           --Valor Cota CMM Total recebe valor cmmcot excluido
           pr_res_vlcmmcot_tot:= pr_res_vlcmmcot_exc;
           --Valor Capital moeda fixa Total recebe valor capital moeda fixa excluido
           pr_res_vlcapmfx_tot:= pr_res_vlcapmfx_exc;
           --Quantidade Total Cotistas recebe total associados excluidos
           pr_res_qtcotist_tot:= pr_tot_qtassexc;
           --Quantidade Total Cotistas recebe total associados excluidos por PF
           pr_res_qtcottot_fis:= pr_tot_qtasexpf;
           --Quantidade Total Cotistas recebe total associados excluidos por PJ
           pr_res_qtcottot_jur:= pr_tot_qtasexpj;
         END IF;
      ELSE
        --Valor Capital recebe zero
        pr_res_vlcapcrz_exc:= 0;
        --Valor Capital recebe zero por PF
        pr_res_vlcapexc_fis:= 0;
        --Valor Capital recebe zero por PJ
        pr_res_vlcapexc_jur:= 0;        
        --Valor Cota CMI recebe zero
        pr_res_vlcmicot_exc:= 0;
        --Valor cota CMM recebe zero
        pr_res_vlcmmcot_exc:= 0;
        --Valor Capital moeda fixa recebe zero
        pr_res_vlcapmfx_exc:= 0;
        --Quantidade Cotistas excluidos recebe zero
        pr_res_qtcotist_exc:= 0;
        --Quantidade Cotistas excluidos recebe zero por PF        
        pr_res_qtcotexc_fis:= 0;
        --Quantidade Cotistas excluidos recebe zero por PJ
        pr_res_qtcotexc_jur:= 0;
        --Valor Capital Total recebe zero
        pr_res_vlcapcrz_tot:= 0;
        --Valor Capital Total recebe zero por PF
        pr_res_vlcaptot_fis:= 0;
        --Valor Capital Total recebe zero por PJ
        pr_res_vlcaptot_jur:= 0;
        --Valor Cota CMI Total recebe zero
        pr_res_vlcmicot_tot:= 0;
        --Valor Cota CMM Total recebe zero
        pr_res_vlcmmcot_tot:= 0;
        --Valor Capital moeda fixa Total recebe zero
        pr_res_vlcapmfx_tot:= 0;
        --Quantidade Total Cotistas recebe zero
        pr_res_qtcotist_tot:= 0;
        --Quantidade Total Cotistas recebe zero por PF
        pr_res_qtcottot_fis:= 0;
        --Quantidade Total Cotistas recebe zero por PJ
        pr_res_qtcottot_jur:= 0;
      END IF;
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_cdcritic := nvl(pr_cdcritic,0);
        pr_des_erro := vr_des_erro;
      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_des_erro := 'Erro na rotina pc_crps010_1. '||SQLERRM;
    END;
  END PC_CRPS010_1;
/
