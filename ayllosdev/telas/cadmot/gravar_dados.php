<?
/*!
 * FONTE        : grava_dados.php
 * CRIAÇÃO      : Christian Grauppe - ENVOLTI
 * DATA CRIAÇÃO : Janeiro/2019
 * OBJETIVO     : Rotina para gravar dados
 * --------------
 * ALTERAÇÕES   : 21/10/2015 - Envio da cddopcao conforme a situação (Inserção ou Atualização) (Marcos-Supero)
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

	// Recebe o POST
	$rowid      = (isset($_POST['rowid'])) ? $_POST['rowid'] : ''  ;
	$idmotivo	= (isset($_POST['idmotivo'])) ? $_POST['idmotivo'] : '';
	$dsmotivo 	= (isset($_POST['dsmotivo'])) ? utf8ToHtml($_POST['dsmotivo']) : '';
	$cdproduto 	= (isset($_POST['cdproduto'])) ? $_POST['cdproduto'] : '';
	$flgreserva_sistema = (isset($_POST['flgreserva_sistema'])) ? $_POST['flgreserva_sistema'] : '';
	$flgativo 	= (isset($_POST['flgativo'])) ? $_POST['flgativo'] : '';
	$flgtipo 	= (isset($_POST['flgtipo'])) ? $_POST['flgtipo'] : '';
	$flgexibe 	= (isset($_POST['flgexibe'])) ? $_POST['flgexibe'] : '';
    
	if ($rowid != ""){
		$cddopcao = "A";
	}else{
		$cddopcao = "I";
	}
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}

	// Monta o xml de requisição
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Dados>';
	$xml .= '		<idmotivo>'.$idmotivo.'</idmotivo>';
	$xml .= '		<dsmotivo>'.mb_convert_encoding($dsmotivo,"UTF-8","HTML-ENTITIES").'</dsmotivo>';
	$xml .= '		<cdproduto>'.$cdproduto.'</cdproduto>';
	$xml .= '		<flgreserva_sistema>'.$flgreserva_sistema.'</flgreserva_sistema>';
	$xml .= '		<flgativo>'.$flgativo.'</flgativo>';
	$xml .= '		<flgtipo>'.$flgtipo.'</flgtipo>';
	$xml .= '		<flgexibe>'.$flgexibe.'</flgexibe>';
	$xml .= '	</Dados>';
	$xml .= '</Root>';
	
	//echo $xml;

	// Executa script para envio do XML e cria objeto para classe de tratamento de XML
	$xmlResult = mensageria($xml, "CADMOT", "MANTEM_MOTIVO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjeto = getObjectXML($xmlResult);

	// Se ocorrer um erro, mostra mensagem
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') {
		$msgErro  = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibirErro('error',$msgErro,'Alerta - Ayllos',$retornoAposErro,false);
	} else {
		echo 'showError("inform", "Requisi&ccedil;&atilde;o conclu&iacute;da.", "Alerta - Ayllos", "hideMsgAguardo();");
		encerraRotina(true);paginaMotivos();';
	}        