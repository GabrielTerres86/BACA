<?
/*!
 * FONTE        : excluir_dados.php
 * CRIAÇÃO      : Andre Santos - SUPERO
 * DATA CRIAÇÃO : Maio/2015
 * OBJETIVO     : Rotina para gravar dados
 * --------------
 * ALTERAÇÕES   : 23/11/2015 - Ajustado para excluir o convenio quando nao for mais utilizado
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

	// Recebe o POST
	$rowid       = (isset($_POST['rowid'])) ? $_POST['rowid'] : ' '  ;
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'E')) <> '') {
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}

	// Monta o xml de requisição
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Dados>';
	$xml .= '       <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
	$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';
	$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';
	$xml .= '		<dtmvtolt>'.$glbvars['dtmvtolt'].'</dtmvtolt>';
	$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xml .= '		<rowid>'.$rowid.'</rowid>';
	$xml .= '	</Dados>';
	$xml .= '</Root>';

	// Executa script para envio do XML e cria objeto para classe de tratamento de XML
	$xmlResult = mensageria($xml, "CONFOL", "DELCONV", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjeto = getObjectXML($xmlResult);

	// Se ocorrer um erro, mostra mensagem
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') {
		$msgErro  = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		$codErro  = $xmlObjeto->roottag->tags[0]->tags[0]->tags[3]->cdata;
		$retornoAposErro = "";
		
		switch ($codErro) {
			case 1:
				$msgErro = "Registro de conv&ecirc;nio n&atilde;o localizado!";
				break;
			case 2:
				$msgErro = "Existe pelo menos uma empresa vinculada ao conv&ecirc;nio, imposs&iacute;vel exclu&iacute;-lo!";
				break;
			case 3:
				$msgErro = "Conv&ecirc;nio Tarif&aacute;rio n&atilde;o pode ser exclu&iacute;do! Motivo: Existem tarifas vig&ecirc;ntes vinculadas ao mesmo!";
				break;
			case 9999:
			    $retornoAposErro = "blockBackground(parseInt($('#divRotina').css('z-index')));";
				break;
		}		
		
		exibirErro('error',$msgErro,'Alerta - Ayllos',$retornoAposErro,false);
	}

?>