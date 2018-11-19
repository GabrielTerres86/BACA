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
	
	$cddopcao = (isset($_POST["cddopcao"])) ? $_POST["cddopcao"] : '';
	$cdmodelo = (isset($_POST["cdmodelo"])) ? $_POST["cdmodelo"] : '';
	$dtbase = (isset($_POST["dtbase"])) ? $_POST["dtbase"] : '';
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],'',$cddopcao)) <> '') {
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}
	
	if($cddopcao == "C"){
		
		// Monta o xml de requisição		
		$xml  		= "";
		$xml 	   .= "<Root>";
		$xml 	   .= "  <Dados>";
		$xml 	   .= "  </Dados>";
		$xml 	   .= "</Root>";
		
		// Executa script para envio do XML	
		$xmlResult = mensageria($xml, "SCORE", "LISTA_CARGAS", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
		$xmlObj = getObjectXML($xmlResult);

		// Se ocorrer um erro, mostra crítica
		if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
		
			$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
			exibirErro('error',$msgErro,'Alerta - Ayllos','estadoInicial();',false);		
						
		} 

		$cargas = $xmlObj->roottag->tags[0]->tags;

		include('tab_carga.php');
		?>

		<script type="text/javascript">
			formatarTabelaCarga();
		</script>

		<?
	} else if($cddopcao == "H"){
		
		// Monta o xml de requisição		
		$xml  		= "";
		$xml 	   .= "<Root>";
		$xml 	   .= "	  <Dados>";
		$xml 	   .= "  	<cdmodelo>".$cdmodelo."</cdmodelo>";
		$xml 	   .= "  	<dtbase>".$dtbase."</dtbase>";
		$xml 	   .= "   </Dados>";
		$xml 	   .= "</Root>";
		
		// Executa script para envio do XML	
		$xmlResult = mensageria($xml, "SCORE", "LISTA_HIST_CARGAS", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
		$xmlObj = getObjectXML($xmlResult);

		//var_dump($xml); die;

		if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
		
			$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
			exibirErro('error',$msgErro,'Alerta - Ayllos','estadoInicial();',false);
		} 

		$cargas = $xmlObj->roottag->tags[0]->tags;

		include('tab_historico.php');
		?>

		<script type="text/javascript">
			formatarTabelaHistorico();
		</script>

		<?
	}
		
?>
