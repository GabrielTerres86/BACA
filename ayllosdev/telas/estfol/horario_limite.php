<?
/*!
 * FONTE        : horario_limite.php
 * CRIAÇÃO      : Andre Santos - SUPERO
 * DATA CRIAÇÃO : Maio/2015
 * OBJETIVO     : Validar horario limite para aprovar e reprovar estouro de folha de pagamento
 * --------------
 * ALTERAÇÕES   : 21/10/2015 - Utilização da cddopcao para esta busca, pois não é especifica
                               de consulta, mas de acesso a tela (Marcos-Supero)
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

	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'@')) <> '') {
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
	$xmlResult = mensageria($xml, "ESTFOL", "HRLIMPFP", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjeto = getObjectXML($xmlResult);

	$codErro = 0;
	
	// Se ocorrer um erro, mostra mensagem
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') {
		$codErro  = $xmlObjeto->roottag->tags[0]->tags[0]->tags[3]->cdata;
		$msgErro  = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		$retornoAposErro = "blockBackground(parseInt($('#divRotina').css('z-index')));";
 	
		switch ($codErro) {
			case 1:
				$msgErro = "N&atilde;o &eacute; mais poss&iacute;vel aprovar os estouros, o hor&aacute;rio limite definido &eacute; $msgErro.";
				break;
		}
		echo "var cdcritic = $codErro;";
		exibirErro('error',$msgErro,'Alerta - Ayllos','',false);
	}
	
	// Se não houver erro, envia 0 para prosseguir o processo normalmente
	echo "var cdcritic = $codErro;";
?>