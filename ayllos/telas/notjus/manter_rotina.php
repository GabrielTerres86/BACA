<? 
/*!
 * FONTE        : manter_rotina.php
 * CRIAÇÃO      : David Kruger
 * DATA CRIAÇÃO : 23/01/2013
 * OBJETIVO     : Rotina para manter as operações da tela NOTJUS
 * --------------
 * ALTERAÇÕES   : 19/11/2013 - Ajustes para homologação (Adriano)
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
	$cddopcao = (isset($_POST['cddopcao']))   ? $_POST['cddopcao']   : ''  ; 
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}
	
	$nrseqdig = (isset($_POST['nrseqdig']))   ? $_POST['nrseqdig']   : '' ; 
	$nrdconta = (isset($_POST['nrdconta']))   ? $_POST['nrdconta']   : 0  ; 
	
	switch($cddopcao) {
	
		case 'N': $procedure = 'cria_notificacao';	break;
		case 'E': $procedure = 'exclui_registro'; 	break;
		case 'J': $procedure = 'justifica_estouro'; break;
		
	}
	
	validaDados();
	
	// Monta o xml dinâmico de acordo com a operação 
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0146.p</Bo>';
	$xml .= '		<Proc>'.$procedure.'</Proc>';
	$xml .= '	</Cabecalho>';
	$xml .= '	<Dados>';
	$xml .= '       <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
	$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';	
	$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';
	$xml .= '		<dtmvtolt>'.$glbvars['dtmvtolt'].'</dtmvtolt>';
	$xml .= '		<cddopcao>'.$glbvars['cddopcao'].'</cddopcao>';
    $xml .= '		<nrdconta>'.$nrdconta.'</nrdconta>';
    
	if($cddopcao != 'N'){
	   $xml .= '		<nrseqdig>'.$nrseqdig.'</nrseqdig>';
	}
	
	$xml .= '	</Dados>';
	$xml .= '</Root>';
	
	$xmlResult = getDataXML($xml);
	$xmlObjeto = getObjectXML($xmlResult);

	//----------------------------------------------------------------------------------------------------------------------------------	
	// Controle de Erros
	//----------------------------------------------------------------------------------------------------------------------------------
	if ( strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO" ) {
			
		$msgErro  = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;													
		exibirErro('error',$msgErro,'Alerta - Ayllos','',false);
		
	}

	echo "controlaOperacao();";
	
	function validaDados(){
		
		// Se conta informada não for um número inteiro válido
		if ($GLOBALS["nrdconta"] == 0) {
			exibirErro('error','Conta/dv inv&aacute;lida.','Alerta - Ayllos','',false);
		}
		
		// Se conta informada não for um número inteiro válido
		if ($GLOBALS["nrseqdig"] == 0 && $GLOBALS["cddopcao"] != "N") {
			exibirErro('error','N&uacute;mero sequ&ecirc;ncial inv&aacute;lido.','Alerta - Ayllos','',false);
		}
		
	}
	
?>