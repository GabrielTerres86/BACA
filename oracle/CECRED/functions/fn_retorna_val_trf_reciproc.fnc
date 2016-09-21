create or replace function cecred.fn_retorna_val_trf_reciproc (pr_cdcooper IN crapceb.cdcooper%TYPE --Codigo Cooperativa
																															,pr_nrconven IN crapceb.nrconven%TYPE --Numero Convenio
																															,pr_cdocorre IN craptar.cdocorre%TYPE --Codigo Ocorrencia
																															,pr_cdmotivo IN craptar.cdmotivo%TYPE --Codigo Motivo
																															,pr_inpessoa IN craptar.inpessoa%TYPE --Tipo Pessoa
																															) RETURN NUMBER IS


  /**********FUNCTION UTLIZADA NO BI, ANTES DE MEXER FALAR COM JULIANA, GUILHERME OU GEOVANI******************************************/

  -- Programa: fn_retorna_val_trf_reciproc
  -- Sistema : Conta-Corrente - Cooperativa de Credito
  -- Sigla   : CRED
  -- Autor   : Geovani Leitao
  -- Data    : Maio/2016.                     Ultima atualizacao: 04/05/2016

  -- Dados referentes ao programa:

  -- Frequencia : A view para calculo de tarifa da reciprocidade que retorna informacoes para o BI utiliza esta function
  -- Objetivo   : Retornar os valores da tarifa da reciprocidade.
  --
  -- .............................................................................
 
 -- variaveis que armazenam o retorno da procedure
 vr_cdhistor INTEGER;
 vr_cdhisest INTEGER;
 vr_vltarifa NUMBER;
 vr_dtdivulg DATE;
 vr_dtvigenc DATE;
 vr_cdfvlcop INTEGER;
 vr_cdcritic INTEGER;
 vr_dscritic VARCHAR2(4000);
 vr_tab_erro GENE0001.typ_tab_erro;
BEGIN
  --chama procedure para buscar dados da tarifa cobranca
  TARI0001.pc_carrega_dados_tarifa_cobr(pr_cdcooper => pr_cdcooper,
                                        pr_nrdconta => 0,
	                                      pr_nrconven => pr_nrconven,
																				pr_dsincide => 'RETORNO',
																				pr_cdocorre => pr_cdocorre,
																				pr_cdmotivo => pr_cdmotivo,
																				pr_inpessoa => pr_inpessoa,
																				pr_vllanmto => 1,
																				pr_cdprogra => 'ATENDA',
																				pr_cdhistor => vr_cdhistor,
																				pr_cdhisest => vr_cdhisest,
																				pr_vltarifa => vr_vltarifa,
																				pr_dtdivulg => vr_dtdivulg,
																				pr_dtvigenc => vr_dtvigenc,
																				pr_cdfvlcop => vr_cdfvlcop,
																				pr_cdcritic => vr_cdcritic,
																				pr_dscritic => vr_dscritic);
																				
  -- Retorna valor da tarifa
  RETURN vr_vltarifa;

end fn_retorna_val_trf_reciproc;
