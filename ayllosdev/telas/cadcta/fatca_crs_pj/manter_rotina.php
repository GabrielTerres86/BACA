<? 
/*!
 * FONTE        : manter_rotina.php
 * CRIAÇÃO      : Mateus Z (Mouts)
 * DATA CRIAÇÃO : 10/04/2018
 * OBJETIVO     : Rotina para validar/alterar os dados do FATCA/CRS da tela de CONTAS
 * ALTERACOES	: 
 */
?>
 
<?	
    session_start();
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");
	require_once("../../../includes/controla_secao.php");
	require_once("../../../class/xmlfile.php");
	isPostMethod();		
	
	// Guardo os parâmetos do POST em variáveis
	$nrcpfcgc 		      = (isset($_POST['nrcpfcgc'])) 			? $_POST['nrcpfcgc'] : '' ;
	$inobrigacao_exterior = (isset($_POST['inobrigacao_exterior'])) ? $_POST['inobrigacao_exterior'] : '' ;
	$insocio_obrigacao    = (isset($_POST['insocio_obrigacao']))    ? $_POST['insocio_obrigacao'] : '' ;
	$cdpais     		  = (isset($_POST['cdpais']))     		    ? $_POST['cdpais'] : '' ;
	$nridentificacao      = (isset($_POST['nridentificacao'])) 		? $_POST['nridentificacao'] : '' ;
	$cdpais_exterior      = (isset($_POST['cdpais_exterior'])) 		? $_POST['cdpais_exterior'] : '' ;
	$dscodigo_postal      = (isset($_POST['dscodigo_postal'])) 		? $_POST['dscodigo_postal'] : '' ;
	$nmlogradouro         = (isset($_POST['nmlogradouro'])) 		? $_POST['nmlogradouro'] : '' ;
	$nrlogradouro         = (isset($_POST['nrlogradouro'])) 		? $_POST['nrlogradouro'] : '' ;
	$dscomplemento        = (isset($_POST['dscomplemento'])) 		? $_POST['dscomplemento'] : '' ;
	$dscidade             = (isset($_POST['dscidade'])) 	        ? $_POST['dscidade'] : '' ;
	$dsestado             = (isset($_POST['dsestado'])) 	        ? $_POST['dsestado'] : '' ;
	$operacao 			  =	(isset($_POST['operacao'])) 			? $_POST['operacao'] : '' ;
	$insocio 			  =	(isset($_POST['insocio'])) 				? $_POST['insocio'] : '' ;
	$nrdconta 			  =	(isset($_POST['nrdconta'])) 			? $_POST['nrdconta'] : '' ;
	$inacordo 			  =	(isset($_POST['inacordo'])) 			? $_POST['inacordo'] : '' ;
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],'A')) <> "") exibirErro('error',$msgError,'Alerta - Ayllos','bloqueiaFundo(divRotina)',false);

	if($operacao == 'AV' || $operacao == 'AVS') validaDados();
	
	if ($operacao == 'VA' || $operacao == 'VAS') {
		
		$xml  = "";
		$xml .= "<Root>";
		$xml .= "  <Dados>";
		$xml .= '		<nrcpfcgc>'			   .$nrcpfcgc.			  '</nrcpfcgc>';
		$xml .= '		<inobrigacao_exterior>'.$inobrigacao_exterior.'</inobrigacao_exterior>';
		$xml .= '		<insocio_obrigacao>'   .$insocio_obrigacao.   '</insocio_obrigacao>';
		$xml .= '		<cdpais>'    		   .$cdpais.    		  '</cdpais>';
		$xml .= '		<nridentificacao>'	   .$nridentificacao.     '</nridentificacao>';
		$xml .= '		<cdpais_exterior>'	   .$cdpais_exterior.     '</cdpais_exterior>';
		$xml .= '		<dscodigo_postal>'	   .$dscodigo_postal.	  '</dscodigo_postal>';
		$xml .= '		<nmlogradouro>'		   .$nmlogradouro.		  '</nmlogradouro>';
		$xml .= '		<nrlogradouro>'		   .$nrlogradouro.		  '</nrlogradouro>';
		$xml .= '		<dscomplemento>'	   .$dscomplemento.		  '</dscomplemento>';
		$xml .= '		<dscidade>'            .$dscidade.	          '</dscidade>';
		$xml .= '		<dsestado>'            .$dsestado.	          '</dsestado>';
		$xml .= '		<insocio>'			   .$insocio.			  '</insocio>';
		$xml .= '		<nrdconta>'			   .$nrdconta.			  '</nrdconta>';
		$xml .= "  </Dados>";
		$xml .= "</Root>";

		// Executa script para envio do XML
		$xmlResult = mensageria($xml, "TELA_FATCA_CRS", 'ATUALIZA_DADOS_FATCA_CRS', $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"],  "</Root>");
		$xmlObjeto = getObjectXML($xmlResult); 

		//-----------------------------------------------------------------------------------------------
		// Controle de Erros
		//-----------------------------------------------------------------------------------------------
		if(strtoupper($xmlObjeto->roottag->tags[0]->name == 'ERRO')){	

			$msgErro = $xmlObjeto->roottag->tags[0]->cdata;
			$nmdcampo = $xmlObjeto->roottag->tags[0]->attributes["NMDCAMPO"];					

			if($msgErro == null || $msgErro == ''){
				$msgErro = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
			}								
			exibirErro('error',$msgErro,'Alerta - Ayllos','bloqueiaFundo(divRotina)',false);								
		}
						
		echo 'exibirMensagens(\''.$stringArrayMsg.'\',\'controlaOperacao(\"\")\');';

	}
	
	if( $operacao == 'AV' ) { // Se é Validação

		exibirConfirmacao('Deseja confirmar alteração?','Confirmação - Ayllos','controlaOperacao(\'VA\')','bloqueiaFundo(divRotina)',false);
	
	} else if ($operacao == 'AVS'){

		exibirConfirmacao('Deseja confirmar alteração?','Confirmação - Ayllos','controlaOperacao(\'VAS\')','bloqueiaFundo(divRotina)',false);

	}

	function validaDados() {
	
		// No início das validações, primeiro remove a classe erro de todos os campos
		echo '$("input","#frmInfAdicional").removeClass("campoErro");';

		if($GLOBALS["inobrigacao_exterior"] == ''){
			exibirErro('error','Favor informar o campo: Cooperado possui domic&iacute;lio ou qualquer obrigac&ccedil;&atilde;o fiscal fora do Brasil?.','Alerta - Ayllos','$(\'input, select\',\'#frmDetalhes\').removeClass(\'campoErro\');focaCampoErro(\'dsnacion\',\'frmDetalhes\');',false);
		}
		
		if($GLOBALS["inobrigacao_exterior"] == 'S' && ($GLOBALS["cdpais"] === '' || $GLOBALS["cdpais"] === 0)){
			exibirErro('error','Favor informar o c&oacute;digo do pa&iacute;s.','Alerta - Ayllos','$(\'input, select\',\'#frmDetalhes\').removeClass(\'campoErro\');focaCampoErro(\'dsnacion\',\'frmDetalhes\');',false);
		}

		if($GLOBALS["operacao"] == 'AV' && $GLOBALS["insocio_obrigacao"] == ''){
			exibirErro('error','Favor informar o campo: Possui algum s&oacute;cio com 10% ou mais de capital e obrigac&ccedil;&atilde;o fiscal fora do Brasil?.','Alerta - Ayllos','$(\'input, select\',\'#frmDetalhes\').removeClass(\'campoErro\');focaCampoErro(\'dsnacion\',\'frmDetalhes\');',false);
		}			

		if(($GLOBALS["inacordo"] == 'FATCA') && $GLOBALS["inobrigacao_exterior"] == 'S' && $GLOBALS["nridentificacao"] == ''){
			exibirErro('error','Favor informar o NIF.','Alerta - Ayllos','$(\'input, select\',\'#frmDetalhes\').removeClass(\'campoErro\');focaCampoErro(\'dsnacion\',\'frmDetalhes\');',false);
		}
	}		
?>