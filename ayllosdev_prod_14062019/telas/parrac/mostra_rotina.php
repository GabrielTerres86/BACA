<? 
/*!
 * FONTE        : busca_rotina.php
 * CRIAÇÃO      : Jonata Cardoso (RKAM)
 * DATA CRIAÇÃO : 03/02/2015 
 * OBJETIVO     : Rotina para buscar os dados e exibir as rotinas
 * ALTERAÇÃO    :
 */
?>
 
<?
	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');	
	require_once('../../class/xmlfile.php');
	isPostMethod();		
	
	
	// Guardo os parâmetos do POST em variáveis	
	$operacao = (isset($_POST['operacao'])) ? $_POST['operacao'] : '' ;
	$cddopcao = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : 'C';
	$nrseqvac = (isset($_POST['nrseqvac'])) ? $_POST['nrseqvac'] : 0  ;
	$nrseqqac = (isset($_POST['nrseqqac'])) ? $_POST['nrseqqac'] : 0  ;
	$dscasprp = (isset($_POST['dscasprp'])) ? $_POST['dscasprp'] : '' ;
	$dssitcta = (isset($_POST['dssitcta'])) ? $_POST['dssitcta'] : '' ;
	$nrseqiac = (isset($_POST['nrseqiac'])) ? $_POST['nrseqiac'] : '' ;
	$dsmensag = (isset($_POST['dsmensag'])) ? $_POST['dsmensag'] : '' ;
	$inmensag = (isset($_POST['inmensag'])) ? $_POST['inmensag'] : '' ;
	
	if (! in_array($cddopcao,array("C","A","E","I"))) { 
		$cddopcao = 'C';
	}
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}
	
	$procedure  = '';
	$strnomacao = '';
	
	switch( $operacao ) {
		case 'D_crapvac_4'      : $procedure = 'Busca_Cooperativa';  break;
		case 'mensagem_atencao' :
		case 'mensagem_positiv' : $strnomacao = 'VARIAVEIS_CRAPIAC'; break;
	}
	
	if ($procedure != '' || $strnomacao != '') {
			
		// Montar o xml para requisicao
		$xml  = '';
		$xml .= '<Root>';
		if ($procedure != '') {
			$xml .= '	<Cabecalho>';
			$xml .= '		<Bo>b1wgen0131.p</Bo>';
			$xml .= '		<Proc>Busca_Cooperativas</Proc>';
			$xml .= '	</Cabecalho>';
		}
		$xml .= '	<Dados>';
		$xml .= '       <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
		$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
		$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
		$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
		$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';	
		$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';	
		$xml .= '		<nmrescop>'.$glbvars['nmrescop'].'</nmrescop>';
		$xml .= '		<cddopcao>'.$cddopcao.'</cddopcao>';
		$xml .= '		<nrseqiac>'.$nrseqiac.'</nrseqiac>';
		$xml .= '	</Dados>';
		$xml .= '</Root>';

		
		if ($strnomacao != '') {
			$xmlResult = mensageria($xml, "PARRAC", $strnomacao, $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["nmoperad"] , "</Root>");		
			$xml_dados = simplexml_load_string($xmlResult);
		} else {
			$xmlResult = getDataXML($xml);
			$xmlObjeto = getObjectXML($xmlResult);
		}

		if ($operacao == 'D_crapvac_4') {
		
			// Recebe as cooperativas
			$nmcooper		= $xmlObjeto->roottag->tags[0]->attributes['NMCOOPER'];
		
			// Faz o tratamento para criar o select
			$nmcooperArray	= explode(',', $nmcooper);
			$qtcooper		= count($nmcooperArray);
			$slcooper		= '';
			
			for ( $j = 0; $j < $qtcooper; $j +=2 ) {
				$slcooper = $slcooper . '<option value="'.$nmcooperArray[$j+1].'">'.$nmcooperArray[$j].'</option>';	
			}
		}
		else {
		
		}
		
	}	
		
	if ($operacao == 'I_crapvac_1' || $operacao == 'A_crapvac_1' || $operacao == 'D_crapvac_1') {
		include('form_crapvac.php');
	} 
	else 
	if ($operacao == 'D_crapvac_4' ) {
		include('form_duplica_versao_coop.php');
	} 
	else 
	if ($operacao == 'tipo_residencia') {
		include ('form_residencia.php');
	}
	else 
	if ($operacao == 'situacao_conta') {
		include ('form_situacao_conta.php');
	}
	else 
	if ($operacao == 'mensagem_atencao' || $operacao == 'mensagem_positiv') {
		include ('form_mensagem.php');	
	}


?>
