<? 
/*!
 * FONTE        : manter_rotina.php
 * CRIAÇÃO      : Luis Fernando (Supero)
 * DATA CRIAÇÃO : 28/01/2019
 * OBJETIVO     : Rotina para alteração dos parametros da tela PARECC
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
	
	$cddopcao = isset($_POST["cddopcao"]) ? $_POST["cddopcao"] : "";
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'A',false)) <> '') {
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}
	
	$cdcooperativa = isset($_POST["cdcooperativa"]) ? $_POST["cdcooperativa"] : ""; // Cooperativa selecionada
	$flghabilitar = isset($_POST["flghabilitar"]) ? $_POST["flghabilitar"] : ""; // Habilitar cooperativa para envio ao endereço do cooperado
	$idfuncionalidade = isset($_POST["idfuncionalidade"]) ? $_POST["idfuncionalidade"] : ""; // Funcionalidade
	$idtipoenvio = isset($_POST["idtipoenvio"]) ? $_POST["idtipoenvio"] : ""; // Tipo de envio
	$cdcooppodenviar = isset($_POST["cdcooppodenviar"]) ? $_POST["cdcooppodenviar"] : ""; // Lista de cooperativas que podem enviar
	
	// MESAGERIA
	
	// Montar o xml de Requisicao
	$xml .= "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <cddopcao>".$cddopcao."</cddopcao>";
	$xml .= "   <cdcooperativa>".$cdcooperativa."</cdcooperativa>";
	$xml .= "   <idfuncionalidade>".$idfuncionalidade."</idfuncionalidade>";
	$xml .= "   <flghabilitar>".$flghabilitar."</flghabilitar>";
	$xml .= "   <idtipoenvio>".$idtipoenvio."</idtipoenvio>";
	$xml .= "   <cdcooppodenviar>".$cdcooppodenviar."</cdcooppodenviar>";
	$xml .= " </Dados>";
	$xml .= "</Root>";
	
	$xmlResult = mensageria($xml, "TELA_PARECC", "ALTERA_PARAMS_PARECC", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);
	
	//-----------------------------------------------------------------------------------------------
	// Controle de Erros
	//-----------------------------------------------------------------------------------------------
	if(strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')){	
	
		$msgErro = $xmlObj->roottag->tags[0]->cdata;
		
		if($msgErro == null || $msgErro == ''){
			$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibirErro('error',utf8_encode($msgErro),'Alerta - Ayllos','',false);
		}
	} 
	
	exibirErro('inform','Altera&ccedil;&atilde;o efetuada com sucesso.','Alerta - Ayllos',"estadoInicial();",false);
?>