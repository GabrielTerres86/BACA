<? 
/*!
 * FONTE        : manter_rotina.php
 * CRIAÇÃO      : Guilherme
 * DATA CRIAÇÃO : 07/07/2011 
 * OBJETIVO     : Rotina para manter as operações da tela CONALT
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
		
	
	// Recebe a operação que está sendo realizada
	$operacao = (isset($_POST['operacao'])) ? $_POST['operacao'] : ''; 

	// opcao c
	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0; 

	// opcao t
	$nrpacori = (isset($_POST['nrpacori'])) ? $_POST['nrpacori'] : 0 ;
	$nrpacdes = (isset($_POST['nrpacdes'])) ? $_POST['nrpacdes'] : 0;
	$dtperini = (isset($_POST['dtperini'])) ? $_POST['dtperini'] : '';
	$dtperfim = (isset($_POST['dtperfim'])) ? $_POST['dtperfim'] : '';
	
	// Dependendo da operação, chamo uma procedure diferente
	$procedure 	= '';
	$mtdErro	= 'estadoInicial();';
	$mtdRetorno	= '';
	
	switch($operacao) {
		// opcao c
		case 'C1': $cddopcao = 'C';	echo 'controlaOperacao();hideMsgAguardo();';  exit(); break;
		case 'C2': $cddopcao = 'C';	$procedure = 'consulta_alteracoes_tp_conta'; $mtdRetorno = ''; $mtdErro = '$(\'#nrpacori\',\'#frmConalt\').focus();'; 	break;

		// opcao t
		case 'T1': $cddopcao = 'T';	echo 'controlaOperacao();hideMsgAguardo();'; exit(); break;
		case 'T2': $cddopcao = 'T';	$procedure = 'consulta_transf_pacs'; $mtdRetorno = ''; $mtdErro = '$(\'#nrpacori\',\'#frmConalt\').focus();';  	break;
		default: $mtdErro = 'estadoInicial();'; return false; break;
	}
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}

	// Monta o xml dinâmico de acordo com a operação 
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "	<Cabecalho>";
	$xml .= "		<Bo>b1wgen0018.p</Bo>";
	$xml .= "		<Proc>".$procedure."</Proc>";
	$xml .= "	</Cabecalho>";
	$xml .= "	<Dados>";
	$xml .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xml .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xml .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xml .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xml .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xml .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";
	$xml .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xml .= "		<nmrescop>".$glbvars["nmcooper"]."</nmrescop>";
	$xml .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "		<nrpacori>".$nrpacori."</nrpacori>";
	$xml .= "		<nrpacdes>".$nrpacdes."</nrpacdes>";
	$xml .= "		<dtperini>".$dtperini."</dtperini>";
	$xml .= "		<dtperfim>".$dtperfim."</dtperfim>";
	$xml .= "	</Dados>";
	$xml .= "</Root>";

	$xmlResult = getDataXML($xml);
	$xmlObjeto = getObjectXML($xmlResult);
	
	//----------------------------------------------------------------------------------------------------------------------------------	
	// Controle de Erros
	//----------------------------------------------------------------------------------------------------------------------------------
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {	
		$msgErro	= str_ireplace('"','',$xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata);
		exibirErro('error',$msgErro,'Alerta - Ayllos',$mtdErro,false);
	}	
	
	// Coloca as informações no formulario
	if (in_array($operacao,array('C2'))) {
		
		echo "fechaRotina($('#divRotina'));";
		
		$conta = $xmlObjeto->roottag->tags[0]->tags[0]->tags;
		$registros = $xmlObjeto->roottag->tags[1]->tags;
		
		echo "$('#dsagenci','#frmConalt').val('".getByTagName($conta,'dsagenci')."');";
		echo "$('#nrmatric','#frmConalt').val('".getByTagName($conta,'nrmatric')."');";
		echo "$('#dstipcta','#frmConalt').val('".getByTagName($conta,'dstipcta')."');";
		echo "$('#dtabtcct','#frmConalt').val('".getByTagName($conta,'dtabtcct')."');";
		echo "$('#dssititg','#frmConalt').val('".getByTagName($conta,'dssititg')."');";
		echo "$('#dtatipct','#frmConalt').val('".getByTagName($conta,'dtatipct')."');";
		echo "$('#nmprimtl','#frmConalt').val('".getByTagName($conta,'nmprimtl')."');";
		echo "$('#nmsegntl','#frmConalt').val('".getByTagName($conta,'nmsegntl')."');";
		
		include('tab_alt_conta.php'); 
	}elseif (in_array($operacao,array('T2'))) { // Coloca as informações no formulario
		$registros = $xmlObjeto->roottag->tags[0]->tags;
		
		echo "fechaRotina($('#divRotina'));";

		//monta tabela dos registros de transf
		include('tab_transf_pac.php');
	}
	
	echo "hideMsgAguardo();";
	echo $mtdRetorno;
?>