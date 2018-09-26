<? 
/*!
 * FONTE        : qualifica_operacao.php
 * CRIAÇÃO      : Gabriel Capoia (DB1)
 * DATA CRIAÇÃO : 06/04/2011 
 * OBJETIVO     : Busca registros para tela de liquidações de emprestimo
 */
?>
 
<?
	session_start();
	require_once('../../../../includes/config.php');
	require_once('../../../../includes/funcoes.php');
	require_once('../../../../includes/controla_secao.php');	
	require_once('../../../../class/xmlfile.php');
	isPostMethod();		
	
	// Guardo os parâmetos do POST em variáveis	
	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : '';
	$dsctrliq = (isset($_POST['dsctrliq'])) ? $_POST['dsctrliq'] : ''; 
			
	// exibirErro('error','dsctrliq= '.$dtmvtoep.'\n'.
	                   // 'nrdconta= '.$vlsdeved,'Alerta - Aimaro','bloqueiaFundo(divRotina);',false);
					  
		
	// Monta o xml de requisição
	$xml  = "<Root>";
	$xml .= "	<Cabecalho>";
	$xml .= "		<Bo>b1wgen0002.p</Bo>";
	$xml .= "		<Proc>proc_qualif_operacao</Proc>";
	$xml .= "	</Cabecalho>";
	$xml .= "	<Dados>";
	$xml .= "       <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xml .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xml .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xml .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xml .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";	
	$xml .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";	
	$xml .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";	
	$xml .= "		<dtmvtopr>".$glbvars["dtmvtopr"]."</dtmvtopr>";	
	$xml .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "		<dsctrliq>".$dsctrliq."</dsctrliq>";
	$xml .= "	</Dados>";
	$xml .= "</Root>";
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xml);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObj = getObjectXML($xmlResult);
	
	if ( strtoupper($xmlObj->roottag->tags[0]->name) == 'ERRO' ) {
		exibirErro('error',$xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Aimaro','bloqueiaFundo(divRotina)',false);
	}
	
	$dsquapro = trim($xmlObj->roottag->tags[0]->attributes['DSQUAPRO']);
	$idquapro = trim($xmlObj->roottag->tags[0]->attributes['IDQUAPRO']);
	
	// exibirErro('error',$msgretor.' | '.$tpdretor,'Alerta - Aimaro','bloqueiaFundo(divRotina)',false);
	
	if( $dsquapro != '' and $idquapro != '' ){
		
		echo '$("#dsquapro","#frmNovaProp").val("'.$dsquapro.'");';
		echo '$("#idquapro","#frmNovaProp").val("'.$idquapro.'");';
		echo 'arrayProposta["idquapro"] = "'.$idquapro.'";';
		echo 'arrayProposta["dsquapro"] = "'.$dsquapro.'";';
				
	}	
					

			

		
?>