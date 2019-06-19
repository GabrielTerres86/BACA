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
	$nrdconta = (isset($_POST["nrdconta"])) ? $_POST["nrdconta"] : '';
	$cdcooper = $glbvars['cdcooper'];

	// echo '<br> cddopcao: ' . $cddopcao;
	// echo '<br> cdcooper: ' . $glbvars['cdcooper'];
	// echo '<br> nrdconta: ' . $nrdconta;
	// echo '<br> nudconta: ' . $nudconta;

	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
		echo ' teste exibir erro ';
	}
	
	// Monta o xml
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "  <Dados>";	
	$xml .= "		<cdcooper>".$cdcooper."</cdcooper>";
	$xml .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "  </Dados>";
	$xml .= "</Root>";

	// Executa script para envio do XML
	$xmlResult = mensageria($xml, "PGTA0001", 'CONSULTARARQREM', $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");

	// Cria objeto para classe de tratamento de XML
	$xmlObjeto = getObjectXML($xmlResult);

	//print_r($xmlResult);

	error_reporting(E_ALL);
	ini_set('display_errors', 1);

	$xml = simplexml_load_string($xmlResult);

	$criticas = '';
	$showNumber = 1;

	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {
		
		echo "msgError('error','".utf8ToHtml( removeCaracteresInvalidos($xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata))."','hideMsgAguardo();');";
		// echo '<script> parent.framePrincipal.eval("'.$funcao.'"); </script>';
//		return false;
		exit;
	
	} else if (isset($xmlObjeto->roottag->tags[0]->tags[0]->name)) {
	//se tem criticas, exibe tabela de criticas
		if(strtoupper($xmlObjeto->roottag->tags[0]->tags[0]->name) === 'DADOSREM') {

			//print_r($xmlResult);

			// percorre vetor de criticas
			foreach ($xml->Remessa->DadosRem as $key => $value) {

				$criticas .= ' <tr class="teste" ondblclick=downloadArquivoRemessaTed('.$value->nrseqarq.',"'.$value->nomereme.'")>';
				$criticas .= '   <td>';
				$criticas .= 	   $value->sequenci;
				$criticas .= '   </td>';
				$criticas .= '   <td>';
				$criticas .= 	    $value->nomereme;
				$criticas .= '   </td>';
				$criticas .= '   <td>';
				$criticas .= 	    $value->datareme;
				$criticas .= '   </td>';
				$criticas .= ' </tr>';

					$showNumber++;
			}
			// monta tabela
			$table_erros  = '<table>';
			$table_erros .= '  <thead>';
			$table_erros .= '    <tr>';
			$table_erros .= '      <th>Seq.</th>';
			$table_erros .= '      <th>Nome do Arquivo</th>';
			$table_erros .= '      <th>Data da Remessa</th>';
			$table_erros .= '    </tr>';
			$table_erros .= '  </thead>';
			$table_erros .= '  <tbody>';
			$table_erros .= $criticas;
			$table_erros .= '</tbody></table>';


			echo "$('#fRemessasTed').show();";

			echo "criticaOpcaoE2('$table_erros');";

		}
	} else {
		$funcao = "alert(' teste else ');";
		echo '<script> parent.framePrincipal.eval("'.$funcao.'"); </script>';
//		return false;
		exit;

	}

	exit();


?>
