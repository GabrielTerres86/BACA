<?
/*!
 * FONTE        : busca_convenios.php
 * CRIAÇÃO      : Andre Santos - SUPERO
 * DATA CRIAÇÃO : Maio/2015
 * OBJETIVO     : Rotina para buscar os dados de convenios tarifarios
 * --------------
 * ALTERAÇÕES   : 23/11/2015 - Ajustado para buscar os valores de tarifa pelo TARI0001
					           (Andre Santos - SUPERO)
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

	$retornoAposErro = '';
	
	$exibiErro = ($_POST['exibiErro']!="") ? $_POST["exibiErro"] : "true";

	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'C')) <> '') {
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}

	// Monta o xml de requisição
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Dados>';
	$xml .= '       <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
	$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';
	$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';
	$xml .= '	</Dados>';
	$xml .= '</Root>';

	// Executa script para envio do XML e cria objeto para classe de tratamento de XML
	$xmlResult = mensageria($xml, "CONFOL", "BUSCONV", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjeto = getObjectXML($xmlResult);

	// Se ocorrer um erro, mostra mensagem
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') {
		$msgErro  = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibirErro('error',$msgErro,'Alerta - Ayllos',$retornoAposErro);
	}
	
	$convenios 	= $xmlObjeto->roottag->tags;	
	
	// Se ocorrer a critica 9998, ao menos um registro convenio nao esta vinculado as tarifas cadastradas na CADTAR
	if ($xmlObjeto->roottag->tags[0]->cdata == 9998 && $exibiErro=="true"){
		$msgErro  = 'Houve erro no retorno de pelo menos um dos valores, favor rever o cadastros dos conv&ecirc;nios na CADTAR.';
		$retornoAposErro = "exibiErro = 'false';"; // Controla exibicao de erro
		exibirErro('inform',$msgErro,'Alerta - Ayllos',$retornoAposErro);
	} else {
		echo "<script>exibiErro = 'false';</script>"; // Controla exibicao de erro
	}

	include('tab_convenios.php');
?>