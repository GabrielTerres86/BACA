<?
/*!
 * FONTE        : consulta_pre_inclusao.php
 * CRIAÇÃO      : Lucas Reinert
 * DATA CRIAÇÃO : 29/09/2017
 * OBJETIVO     : Busca dados de cadastro de pessoa no CRM
 * --------------
 * ALTERAÇÕES   : 
 * -------------- 
 */ 
?>

<?	
	session_start();	
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');		
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();	
	
	$nrcpfcgc = (isset($_POST['nrcpfcgc'])) ? $_POST['nrcpfcgc'] : '';

	if (!validaInteiro($nrcpfcgc) || $nrcpfcgc == 0) exibirErro('error','CPF/CNPJ n&atilde;o informado.','Alerta - Ayllos','$(\'#nrdconta\', \'#frmCab\').focus()',false);

	$xml  = "";
	$xml .= "<Root>";
	$xml .= "	<Dados>";
    $xml .= "		<nrcpfcgc>".$nrcpfcgc."</nrcpfcgc>";
	$xml .= "	</Dados>";
	$xml .= "</Root>";
		
	//$xmlResult 	= getDataXML($xml);
	$xmlResult = mensageria($xml, "TELA_CADMAT", "CONSULTA_PRE_INCLUSAO", $glbvars["cdcooper"], $glbvars["cdpactra"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjeto 	= simplexml_load_string($xmlResult);		
	
	// Se ocorrer um erro, mostra mensagem
	if (isset($xmlObjeto->Root->Erro) && $xmlObjeto->Root->Erro != '') {	
		$msgErro = utf8_encode($xmlObjeto->Root->Erro);
		exibirErro('error',$msgErro,'Alerta - Ayllos','estadoInicial();',false);
		exit();
	} 
	// Flag de verificação de conta duplicada
	$flgdpcnt = $xmlObjeto->flgopcao[0]->flgdpcnt;
	
	$nrcpfcgc = $xmlObjeto->infcadastro[0]->nrcpfcgc;
	$tpdocptl = $xmlObjeto->infcadastro[0]->tpdocptl;
	$nrdocptl = $xmlObjeto->infcadastro[0]->nrdocptl;
	$nmttlrfb = $xmlObjeto->infcadastro[0]->nmttlrfb;
	$cdsitcpf = $xmlObjeto->infcadastro[0]->cdsitcpf;
	$nmprimtl = $xmlObjeto->infcadastro[0]->nmprimtl;
	$dtcnscpf = $xmlObjeto->infcadastro[0]->dtcnscpf;
	$dsdemail = $xmlObjeto->infcadastro[0]->dsdemail;
	$nrcepcor = $xmlObjeto->infcadastro[0]->nrcepcor;
	$dsendcor = $xmlObjeto->infcadastro[0]->dsendcor;
	$nrendcor = $xmlObjeto->infcadastro[0]->nrendcor;
	$complcor = $xmlObjeto->infcadastro[0]->complcor;
	$nmbaicor = $xmlObjeto->infcadastro[0]->nmbaicor;
	$cdufcorr = $xmlObjeto->infcadastro[0]->cdufcorr;
	$nmcidcor = $xmlObjeto->infcadastro[0]->nmcidcor;
	$idoricor = $xmlObjeto->infcadastro[0]->idoricor;
	$inpessoa = $xmlObjeto->infcadastro[0]->inpessoa;
	$cdagenci = $xmlObjeto->infcadastro[0]->cdagenci;
	$nmresage = $xmlObjeto->infcadastro[0]->nmresage;
	
	// Colocar informações nos campos da tela
	echo "$('#nrcpfcgc','#frmCadmat').val('$nrcpfcgc');";
	echo "$('#tpdocptl','#frmCadmat').val('$tpdocptl');";
	echo "$('#nrdocptl','#frmCadmat').val('$nrdocptl');";
	echo "$('#nmttlrfb','#frmCadmat').val('$nmttlrfb');";
	echo "$('#cdsitcpf','#frmCadmat').val('$cdsitcpf');";
	echo "$('#nmprimtl','#frmCadmat').val('$nmprimtl');";
	echo "$('#dtcnscpf','#frmCadmat').val('$dtcnscpf');";
	echo "$('#dsdemail','#frmCadmat').val('$dsdemail');";
	echo "$('#nrcepcor','#frmCadmat').val('$nrcepcor');";
	echo "$('#dsendcor','#frmCadmat').val('$dsendcor');";
	echo "$('#nrendcor','#frmCadmat').val('$nrendcor');";
	echo "$('#complcor','#frmCadmat').val('$complcor');";
	echo "$('#nmbaicor','#frmCadmat').val('$nmbaicor');";
	echo "$('#cdufcorr','#frmCadmat').val('$cdufcorr');";
	echo "$('#nmcidcor','#frmCadmat').val('$nmcidcor');";
	echo "$('#idoricor','#frmCadmat').val('$idoricor');";
	echo "$('#cdagenci','#frmCadmat').val('$cdagenci');";
	echo "$('#nmresage','#frmCadmat').val('$nmresage');";
	
	if ($inpessoa == 1){
	// PF
		$dsnacion = $xmlObjeto->infcadastro[0]->dsnacion;
		$inhabmen = $xmlObjeto->infcadastro[0]->inhabmen;
		$dthabmen = $xmlObjeto->infcadastro[0]->dthabmen;
		$cdestcvl = $xmlObjeto->infcadastro[0]->cdestcvl;
		$tpnacion = $xmlObjeto->infcadastro[0]->tpnacion;
		$cdnacion = $xmlObjeto->infcadastro[0]->cdnacion;
		$cdoedptl = $xmlObjeto->infcadastro[0]->cdoedptl;
		$cdufdptl = $xmlObjeto->infcadastro[0]->cdufdptl;
		$dtemdptl = $xmlObjeto->infcadastro[0]->dtemdptl;
		$dtnasctl = $xmlObjeto->infcadastro[0]->dtnasctl;
		$nmconjug = $xmlObjeto->infcadastro[0]->nmconjug;
		$nmmaettl = $xmlObjeto->infcadastro[0]->nmmaettl;
		$nmpaittl = $xmlObjeto->infcadastro[0]->nmpaittl;
		$dsnatura = $xmlObjeto->infcadastro[0]->dsnatura;
		$cdufnatu = $xmlObjeto->infcadastro[0]->cdufnatu;
		$nrdddres = $xmlObjeto->infcadastro[0]->nrdddres;
		$nrtelres = $xmlObjeto->infcadastro[0]->nrtelres;
		$cdopetfn = $xmlObjeto->infcadastro[0]->cdopetfn;
		$nrdddcel = $xmlObjeto->infcadastro[0]->nrdddcel;
		$nrtelcel = $xmlObjeto->infcadastro[0]->nrtelcel;
		$nrcepend = $xmlObjeto->infcadastro[0]->nrcepend;
		$dsendere = $xmlObjeto->infcadastro[0]->dsendere;
		$nrendere = $xmlObjeto->infcadastro[0]->nrendere;
		$complend = $xmlObjeto->infcadastro[0]->complend;
		$nmbairro = $xmlObjeto->infcadastro[0]->nmbairro;
		$cdufende = $xmlObjeto->infcadastro[0]->cdufende;
		$nmcidade = $xmlObjeto->infcadastro[0]->nmcidade;
		$idorigee = $xmlObjeto->infcadastro[0]->idorigee;
		$cdocpttl = $xmlObjeto->infcadastro[0]->cdocpttl;
		$nrcadast = $xmlObjeto->infcadastro[0]->nrcadast;
		$cdsexotl = $xmlObjeto->infcadastro[0]->cdsexotl;
		$idorgexp = $xmlObjeto->infcadastro[0]->idorgexp;
		
		// Colocar informações nos campos da tela
		echo "$('#pessoaFi', '#frmCab').prop('checked', true);";
		echo "$('#pessoaJu', '#frmCab').prop('checked', false);";
		echo "$('#dsnacion','#frmCadmat').val('$dsnacion');";
		echo "$('#inhabmen','#frmCadmat').val('$inhabmen');";
		echo "$('#dthabmen','#frmCadmat').val('$dthabmen');";
		echo "$('#cdestcvl','#frmCadmat').val('$cdestcvl');";
		echo "$('#tpnacion','#frmCadmat').val('$tpnacion');";
		echo "$('#cdnacion','#frmCadmat').val('$cdnacion');";
		echo "$('#cdoedptl','#frmCadmat').val('$cdoedptl');";
		echo "$('#cdufdptl','#frmCadmat').val('$cdufdptl');";
		echo "$('#dtemdptl','#frmCadmat').val('$dtemdptl');";
		echo "$('#dtnasctl','#frmCadmat').val('$dtnasctl');";
		echo "$('#nmconjug','#frmCadmat').val('$nmconjug');";
		echo "$('#nmmaettl','#frmCadmat').val('$nmmaettl');";
		echo "$('#nmpaittl','#frmCadmat').val('$nmpaittl');";
		echo "$('#dsnatura','#frmCadmat').val('$dsnatura');";
		echo "$('#cdufnatu','#frmCadmat').val('$cdufnatu');";
		echo "$('#nrdddres','#frmCadmat').val('$nrdddres');";
		echo "$('#nrtelres','#frmCadmat').val('$nrtelres');";
		echo "$('#cdopetfn','#frmCadmat').val('$cdopetfn');";
		echo "$('#nrdddcel','#frmCadmat').val('$nrdddcel');";
		echo "$('#nrtelcel','#frmCadmat').val('$nrtelcel');";
		echo "$('#nrcepend','#frmCadmat').val('$nrcepend');";
		echo "$('#dsendere','#frmCadmat').val('$dsendere');";
		echo "$('#nrendere','#frmCadmat').val('$nrendere');";
		echo "$('#complend','#frmCadmat').val('$complend');";
		echo "$('#nmbairro','#frmCadmat').val('$nmbairro');";
		echo "$('#cdufende','#frmCadmat').val('$cdufende');";
		echo "$('#nmcidade','#frmCadmat').val('$nmcidade');";
		echo "$('#idorigee','#frmCadmat').val('$idorigee');";
		echo "$('#cdocpttl','#frmCadmat').val('$cdocpttl');";
		echo "$('#nrcadast','#frmCadmat').val('$nrcadast');";
		echo "$('#cdsexotl','#frmCadmat').val('$cdsexotl');";
		echo "$('#idorgexp','#frmCadmat').val('$idorgexp');";
		
	}else{
	// PJ
		$nmfansia = $xmlObjeto->infcadastro[0]->nmfansia;
		$nrcepend = $xmlObjeto->infcadastro[0]->nrcepend;
		$dsendere = $xmlObjeto->infcadastro[0]->dsendere;
		$nrendere = $xmlObjeto->infcadastro[0]->nrendere;
		$complend = $xmlObjeto->infcadastro[0]->complend;
		$nmbairro = $xmlObjeto->infcadastro[0]->nmbairro;
		$cdufende = $xmlObjeto->infcadastro[0]->cdufende;
		$nmcidade = $xmlObjeto->infcadastro[0]->nmcidade;
		$idorigee = $xmlObjeto->infcadastro[0]->idorigee;
		$nrdddtfc = $xmlObjeto->infcadastro[0]->nrdddtfc;
		$nrtelefo = $xmlObjeto->infcadastro[0]->nrtelefo;
		$nrinsest = $xmlObjeto->infcadastro[0]->nrinsest;
		$nrlicamb = $xmlObjeto->infcadastro[0]->nrlicamb;
		$natjurid = $xmlObjeto->infcadastro[0]->natjurid;
		$cdseteco = $xmlObjeto->infcadastro[0]->cdseteco;
		$cdrmativ = $xmlObjeto->infcadastro[0]->cdrmativ;
		$cdcnae   = $xmlObjeto->infcadastro[0]->cdcnae;
		$dtiniatv = $xmlObjeto->infcadastro[0]->dtiniatv;
		
		// Colocar informações nos campos da tela
		echo "$('#pessoaFi', '#frmCab').prop('checked', false);";
		echo "$('#pessoaJu', '#frmCab').prop('checked', true);";
		echo "$('#nmfansia','#frmCadmat').val('$nmfansia');";
		echo "$('#nrcepend','#frmCadmat').val('$nrcepend');";
		echo "$('#dsendere','#frmCadmat').val('$dsendere');";
		echo "$('#nrendere','#frmCadmat').val('$nrendere');";
		echo "$('#complend','#frmCadmat').val('$complend');";
		echo "$('#nmbairro','#frmCadmat').val('$nmbairro');";
		echo "$('#cdufende','#frmCadmat').val('$cdufende');";
		echo "$('#nmcidade','#frmCadmat').val('$nmcidade');";
		echo "$('#idorigee','#frmCadmat').val('$idorigee');";
		echo "$('#nrdddtfc','#frmCadmat').val('$nrdddtfc');";
		echo "$('#nrtelefo','#frmCadmat').val('$nrtelefo');";
		echo "$('#nrinsest','#frmCadmat').val('$nrinsest');";
		echo "$('#nrlicamb','#frmCadmat').val('$nrlicamb');";
		echo "$('#natjurid','#frmCadmat').val('$natjurid');";
		echo "$('#cdseteco','#frmCadmat').val('$cdseteco');";
		echo "$('#cdrmativ','#frmCadmat').val('$cdrmativ');";
		echo "$('#cdcnae','#frmCadmat').val('$cdcnae');";
		echo "$('#dtiniatv','#frmCadmat').val('$dtiniatv');";
		
	}
	
	if($flgdpcnt == 1) {
		// Se ja poussui uma conta, perguntar se deseja duplicar 
		if ( count ($xmlObjeto->inf) == 1) {
			$nrdconta_org = $xmlObjeto->inf[0]->nrdconta;
			exibirConfirmacao('CPF/CNPJ já possui a conta '. $nrdconta_org .' na cooperativa. Deseja efetuar a duplicação?',
						      'Confirmação - CADMAT',"nrdconta_org = '$nrdconta_org'; mostraFormSenha('DCC');","$('#cdagenci','#frmCadmat').focus();",false);
		}
		else 
		if ( count ($xmlObjeto->inf) > 1) { // Se possui mais de uma conta, perguntar se deseja duplicar
			
			$lscontas = '';
			
			// Juntar todas as contas que o cooperado ja possui
			for ($i=0; $i < count ($xmlObjeto->inf); $i++) {
				
				$lscontas  = ($lscontas != '') ? $lscontas . '|' : '';			
				$lscontas .=  $xmlObjeto->inf[$i]->nrdconta . ';' . $xmlObjeto->inf[$i]->dtadmiss ;
				
			}
			
			echo "lscontas = '$lscontas';";
			exibirConfirmacao('CPF/CNPJ já possui a conta na cooperativa. Deseja efetuar a duplicação?',
							  'Confirmação - CADMAT',"mostraFormSenha('LCC')","$('#cdagenci','#frmCadmat').focus();",false);
		}
	}
	
?>