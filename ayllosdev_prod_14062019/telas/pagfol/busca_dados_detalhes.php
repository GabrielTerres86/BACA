<?
/*!
 * FONTE        : busca_dados_detalhes.php
 * CRIAÇÃO      : Renato Darosci - SUPERO
 * DATA CRIAÇÃO : Julho/2015
 * OBJETIVO     : Rotina para buscar os detalhes do registro pai
 * --------------
 * ALTERAÇÕES   : 21/10/2015 - Envio da opção "E" para retornar os empregados na validaPermissao (Marcos-Supero)
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
	$cdcooper = $_POST['cdcooper'];
	$cdempres = $_POST['cdempres'];
	$nrseqpag = $_POST['nrseqpag'];

	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'E')) <> '') {
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}
?>
<script type="text/javascript" src="../../scripts/funcoes.js"></script>
<?
	if ($nrseqpag.length > 0) {
	
		// Monta o xml de requisição
		$xml  = '';
		$xml .= '<Root>';
		$xml .= '	<Dados>';
		$xml .= '       <cdcooper>'.$cdcooper.'</cdcooper>';
		$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
		$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
		$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
		$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';
		$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';
		$xml .= '		<cdempres>'.$cdempres.'</cdempres>';
		$xml .= '		<nrseqpag>'.$nrseqpag.'</nrseqpag>';
		$xml .= '	</Dados>';
		$xml .= '</Root>';

		// Executa script para envio do XML e cria objeto para classe de tratamento de XML
		$xmlResult = mensageria($xml, "PAGFOL", "CONSDTPG", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
		$xmlObjeto = getObjectXML($xmlResult);

		// Se ocorrer um erro, mostra mensagem
		if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') {
			$msgErro  = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
			exibirErro('error',$msgErro,'Alerta - Ayllos',$retornoAposErro);
		}

		$detalhesPgto = $xmlObjeto->roottag->tags;
	}
	
	include('tab_folhas_detalhe.php');
?>