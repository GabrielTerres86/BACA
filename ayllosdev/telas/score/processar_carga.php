<? 
/*!
 * FONTE        : monta_tab.php
 * CRIAÇÃO      : Thaise Medeiros - Envolti
 * DATA CRIAÇÃO : Outubro/2018
 * OBJETIVO     : Monta o carregamento da tabela correspondente.
 * --------------
 * ALTERAÇÕES   : 
 */

    session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();			
	
	$cdmodelo 	= (isset($_POST["cdmodelo"])) ? $_POST["cdmodelo"] : 0;
	$dtbase 	= (isset($_POST["dtbase"])) ? $_POST["dtbase"] : '';
	$cddopcao 	= (isset($_POST["cddopcao"])) ? $_POST["cddopcao"] : '';
	$dsrejeicao = (isset($_POST["dsrejeicao"])) ? $_POST["dsrejeicao"] : '';


	// Monta o xml de requisição		
	$xml  		= "";
	$xml 	   .= "<Root>";
	$xml 	   .= "  <Dados>";
	$xml 	   .= "  <cdmodelo>".$cdmodelo."</cdmodelo>";
	$xml 	   .= "  <dtbase>".$dtbase."</dtbase>";
	$xml 	   .= "  <cddopcao>".$cddopcao."</cddopcao>";
	$xml 	   .= "  <dsrejeicao>".$dsrejeicao."</dsrejeicao>";
	$xml 	   .= "  </Dados>";
	$xml 	   .= "</Root>";

	// Executa script para envio do XML	
	$xmlResult = mensageria($xml, "SCORE", "EXEC_CARGA_SCORE", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);

	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
	
		$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibirErro('error',$msgErro,'Alerta - Ayllos','estadoInicial();',false);		
					
	}  else {
		echo "showError('inform','Opera&ccedil;&atilde;o realizada com sucesso','Notifica&ccedil;&atilde;o - Ayllos','refreshCarga();');";
	}

		

?>