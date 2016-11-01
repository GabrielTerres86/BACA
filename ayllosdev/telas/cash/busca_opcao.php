<? 
/*!
 * FONTE        : busca_rotina.php
 * CRIAÇÃO      : Rogérius Militão (DB1)
 * DATA CRIAÇÃO : 11/11/2011 
 * OBJETIVO     : Rotina para busca
 *ALTERAÇÃO     : 27/05/2014 - Incluido a informação de espécie de deposito e
                  relatório do mesmo. (Andre Santos - SUPERO)
 
 */
?>
 
<?
	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');	
	require_once('../../class/xmlfile.php');
	isPostMethod();		
	
	$procedure = ''; 
	$retornoAposErro= 'fechaOpcao();';
	
	// Guardo os parâmetos do POST em variáveis	
	$operacao = (isset($_POST['operacao'])) ? $_POST['operacao'] : '';
	$cddopcao = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '';
	
	// operacao, sensores, transacao
	$nrterfin = (isset($_POST['nrterfin'])) ? $_POST['nrterfin'] : 0 ;

	// configuracao
	$nrtempor = $_POST['nrtempor'];
	$tpdispen = $_POST['tpdispen'];
	$cdagenci = $_POST['cdagenci'];
	$cdsitfin = $_POST['cdsitfin']; // transacao
	$dsfabtfn = $_POST['dsfabtfn'];
	$dsmodelo = $_POST['dsmodelo'];
	$dsdserie = $_POST['dsdserie'];
	$nmnarede = $_POST['nmnarede'];
	$nrdendip = $_POST['nrdendip'];
	$qtcasset = $_POST['qtcasset'];
	$dsininot = $_POST['dsininot'];
	$dsfimnot = $_POST['dsfimnot'];
	$dssaqnot = $_POST['dssaqnot'];
	$dstempor = $_POST['dstempor'];
	$dsdispen = $_POST['dsdispen'];
	$dssittfn = $_POST['dssittfn'];
	
	// operacao
	$dtlimite = $_POST['dtlimite'];
	
	// transacao
	$dtinicio = $_POST['dtinicio'];
	$dtdfinal = $_POST['dtdfinal'];
	$cdsitenv = $_POST['cdsitenv'];

	// sistema TAA
	$flsistaa = $_POST['flsistaa']; 

	// monitorar
	$mmtramax = $_POST['mmtramax']; 	
	
	if ($operacao == 'diretorio') {
		// relatorio
		$nmdireto = '/micros/'.$glbvars['dsdircop'].'/';
	}else{
		// relatorio
		$nmdireto = $_POST['nmdireto'];
	}
	
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}
	
	switch( $operacao ) {
		case 'sensores'			: 	$procedure = 'Opcao_Sensores'; 						 				break;
		case 'operacao'			: 	$procedure = 'Opcao_Operacao'; 						 				break;
		case 'saldos'			: 	$procedure = 'Opcao_Saldos';   						 				break;
		case 'lista_transacoes'	: 	$procedure = 'Opcao_Transacao'; $cddoptrs = 'L';	 				break;
		case 'depositos'		: 	$procedure = 'Opcao_Transacao'; $cddoptrs = 'D';	 				break;
		case 'sistema_taa'		: 	if ( !empty($flsistaa) ) $procedure = 'Busca_Dados'; 				break;
		case 'monitorar'		: 	
			if ( $mmtramax != '0' ) { 
				$procedure = 'Busca_Dados'; 
			} else {
				$mmtramax  = '10';
			}			
		break;
	}
	
	if (!empty($procedure) ) {
	
		// Monta o xml de requisição
		$xml  = "";
		$xml .= "<Root>";
		$xml .= "  <Cabecalho>";
		$xml .= "	    <Bo>b1wgen0123.p</Bo>";
		$xml .= "        <Proc>".$procedure."</Proc>";
		$xml .= "  </Cabecalho>";
		$xml .= "  <Dados>";
		$xml .= "       <cdcooper>".$glbvars['cdcooper']."</cdcooper>";
		$xml .= "		<cdagenci>".$glbvars['cdagenci']."</cdagenci>";
		$xml .= "		<nrdcaixa>".$glbvars['nrdcaixa']."</nrdcaixa>";
		$xml .= "		<cdoperad>".$glbvars['cdoperad']."</cdoperad>";
		$xml .= "		<cdprogra>".$glbvars['cdprogra']."</cdprogra>";
		$xml .= "		<nmdatela>".$glbvars['nmdatela']."</nmdatela>";
		$xml .= "		<idorigem>".$glbvars['idorigem']."</idorigem>";
		$xml .= "		<dtmvtolt>".$glbvars['dtmvtolt']."</dtmvtolt>";
		$xml .= "		<dtmvtopr>".$glbvars['dtmvtopr']."</dtmvtopr>";
		$xml .= "		<dsdepart>".$glbvars['dsdepart']."</dsdepart>";
		$xml .= "		<cddopcao>".$cddopcao."</cddopcao>";	
		$xml .= "		<cddoptrs>".$cddoptrs."</cddoptrs>";	
		$xml .= "		<dtlimite>".$dtlimite."</dtlimite>";	
		$xml .= "		<nrterfin>".$nrterfin."</nrterfin>";	
		$xml .= "		<cdsitfin>".$cdsitfin."</cdsitfin>";	
		$xml .= "		<dtinicio>".$dtinicio."</dtinicio>";	
		$xml .= "		<dtdfinal>".$dtdfinal."</dtdfinal>";	
		$xml .= "		<cdsitenv>".$cdsitenv."</cdsitenv>";	
		$xml .= "		<flsistaa>".$flsistaa."</flsistaa>";	
		$xml .= "		<mmtramax>".$mmtramax."</mmtramax>";	
		$xml .= "  </Dados>";
		$xml .= "</Root>";	

		// Executa script para envio do XML
		$xmlResult = getDataXML($xml);
		
		// Cria objeto para classe de tratamento de XML
		$xmlObj = getObjectXML($xmlResult);
		
		if ( strtoupper($xmlObj->roottag->tags[0]->name) == 'ERRO' ) {
			exibirErro('error',$xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Ayllos',$retornoAposErro,false);
		}

		$registro 	= $xmlObj->roottag->tags[0]->tags;
		$envelope	= $xmlObj->roottag->tags[1]->tags;
		$monitorar	= $xmlObj->roottag->tags[1]->tags;
		$dtlimite 	= $xmlObj->roottag->tags[0]->attributes['DTLIMITE'];
		$qtsaques	= $xmlObj->roottag->tags[0]->attributes['QTSAQUES'];
		$vlsaques	= formataMoeda($xmlObj->roottag->tags[0]->attributes['VLSAQUES']);
		$qtestorn	= $xmlObj->roottag->tags[0]->attributes['QTESTORN'];
		$vlestorn	= formataMoeda($xmlObj->roottag->tags[0]->attributes['VLESTORN']);
		
	}
	
	if ( $operacao == 'sensores' ) {
		include('tab_sensores.php');

	} else if ( $operacao == 'configuracao' ) {
		include('form_configuracao.php');
	
	} else if ( $operacao == 'operacao' ) {
		include('tab_operacao.php');
	
	} else if ( $operacao == 'saldos' ) {
		include('form_saldos.php');
	
	} else if ( $operacao == 'lista_transacoes' ) {
		include('tab_lista_transacoes.php');
	
	} else if ( $operacao == 'depositos' ) {
		include('tab_depositos.php');
	
	} else if ( $operacao == 'sistema_taa' ) {
		if ( !empty($flsistaa) ) {
			include('tab_sistema_taa.php');
		} else {
			include('form_sistema_taa.php');
		}
		
	} else if ( $operacao == 'opcaol' ) {
		include('form_opcaoL.php');
	
	} else if ( $operacao == 'monitorar' ) {
		include('tab_monitorar.php');
	
	} else if ( $operacao == 'relatorio' ) {
		include('form_relatorio.php');
		
	} else if ( $operacao == 'diretorio' ) {
		include('form_diretorio.php');
	}

?>
