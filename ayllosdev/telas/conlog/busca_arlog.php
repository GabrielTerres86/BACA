<? 
/*!
 * FONTE        : busca_coop.php
 * CRIAÇÃO      : Thaise - Envolti
 * DATA CRIAÇÃO : Outubro/2018
 * OBJETIVO     : Busca as cooperativas 
 * --------------
 * ALTERAÇÕES   : 
 */
/*
    session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();			
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}
*/
// Monta o xml de requisição		
		$xml  		= "";
		$xml 	   .= "<Root>";
		$xml 	   .= "  <Dados>";
		$xml 	   .= "     <flcecred>1</flcecred>";
		$xml 	   .= "     <flgtodas>1</flgtodas>";
		$xml 	   .= "  </Dados>";
		$xml 	   .= "</Root>";
		
		$xmlResult = "";
		// Executa script para envio do XML	 
		$xmlResult = mensageria($xml, "CONLOG", "BUSCA_ARQLOG", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
		//$xmlObj = getObjectXML($xmlResult);
		$xmlObj = simplexml_load_string($xmlResult);
		
		// Se ocorrer um erro, mostra crítica
		if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
		
			$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
			//exibirErro('error',$msgErro,'Alerta - Ayllos','estadoInicial();',false);
			echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","","NaN");';
		} 
			
		$arlogs = $xmlObj->Arquivos[0]->nmarqlog;
		foreach ( $arlogs as $arlog ) {
		   $nmarqlog .= '<option value="'.$arlog.'">'.$arlog.'</option> ';		
		}
?>