<? 
/*!
 * FONTE        : busca_remessas_ted.php
 * CRIAÇÃO      : Anderson Schloegel
 * DATA CRIAÇÃO : maio/2019
 * OBJETIVO     : Busca os registros de remessas de ted
 * --------------
 * ALTERAÇÕES   : 
 */


if( !ini_get('safe_mode') ){
		set_time_limit(300);
	}
	session_cache_limiter("private");
	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	
	isPostMethod();
	
	$cddopcao = (isset($_POST["cddopcao"])) ? $_POST["cddopcao"] : '';
	$nrseqarq = (isset($_POST["nrseqarq"])) ? $_POST["nrseqarq"] : '';

	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
		echo ' teste exibir erro ';
	}
	
	// Monta o xml
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "  <Dados>";	
	$xml .= "		<nrseq_arq_ted>".$nrseqarq."</nrseq_arq_ted>";
	$xml .= "  </Dados>";
	$xml .= "</Root>";

	// Executa script para envio do XML
	$xmlResult = mensageria($xml, "PGTA0001", 'EXPORTARARQRET', $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");

	$dados = simplexml_load_string($xmlResult);

	echo $dados->Download->DadosDown->arqclob1;
	echo $dados->Download->DadosDown->arqclob2;
	echo $dados->Download->DadosDown->arqclob3;
	echo $dados->Download->DadosDown->arqclob4;
	echo $dados->Download->DadosDown->arqclob5;
	echo $dados->Download->DadosDown->arqclob6;
	echo $dados->Download->DadosDown->arqclob7;
	echo $dados->Download->DadosDown->arqclob8;
	echo $dados->Download->DadosDown->arqclob9;
	echo $dados->Download->DadosDown->arqclob10;

	exit();


?>
