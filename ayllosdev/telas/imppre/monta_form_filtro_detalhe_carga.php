<? 
/* !
 * FONTE        : monta_form_filtro_detalhe_carga.php
 * CRIAÇÃO      : Christian Grauppe - ENVOLTI
 * DATA CRIAÇÃO : Fevereiro/2019
 * OBJETIVO     : monta o filtro para buscar os detalhes da carga
 * --------------
 * ALTERAÇÕES   :
 * --------------
 */
    session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();			
	
	$cddopcao = (isset($_POST["cddopcao"])) ? $_POST["cddopcao"] : 'D';

	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao,false)) <> '') {
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}
	
	// Monta o xml de requisição		
	$xml  		= "";
	$xml 	   .= "<Root>";
	$xml 	   .= "  <Dados>";
	$xml 	   .= "     <flcecred>1</flcecred>";
	$xml 	   .= "     <flgtodas>1</flgtodas>";
	$xml 	   .= "  </Dados>";
	$xml 	   .= "</Root>";
	
	// Executa script para envio do XML	
	$xmlResult = mensageria($xml, "TELA_GRAVAM", "BUSCACOOP", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);

	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
		$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibirErro('error',$msgErro,'Alerta - Ayllos','estadoInicial();',false);		
	}

	$cooperativas = $xmlObj->roottag->tags[0]->tags;
  
	foreach ( $cooperativas as $coop ) {
		
		if ( !in_array( getByTagName($coop->tags,'cdcooper'), array( 4, 15, 17 ) ) ) {
			$nmrescop .= '<option value="'.getByTagName($coop->tags,'cdcooper').'">'.getByTagName($coop->tags,'nmrescop').'</option> ';
		}
	}

	include('form_filtro_detalhe_carga.php'); 
