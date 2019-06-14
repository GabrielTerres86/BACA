<?
/*!
 * FONTE        : processa_perda_aprovacao.php
 * CRIAÇÃO      : Mateus Zimmermann (Mouts)
 * DATA CRIAÇÃO : 13/07/2018
 * OBJETIVO     : Verifica se haverá perda de aprovacao
 *
 * --------------
 * ALTERAÇÕES   :
 * --------------
 */
?>

<?
	session_start();
	require_once('../../../includes/config.php');
	require_once('../../../includes/funcoes.php');
	require_once('../../../includes/controla_secao.php');
	require_once('../../../class/xmlfile.php');
	isPostMethod();

	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : '';
	$nrctremp = (isset($_POST['nrctremp'])) ? $_POST['nrctremp'] : '';
	$idseqttl = (isset($_POST['idseqttl'])) ? $_POST['idseqttl'] : '';
	$vlemprst = (isset($_POST['vlemprst'])) ? $_POST['vlemprst'] : '';
	$vlpreemp = (isset($_POST['vlpreemp'])) ? $_POST['vlpreemp'] : '';
	$tipoacao = 'C';
	$tpctrato = 90;
	$flgcalcu = 1;
	$flgerlog = 'N';
	$flghisto = 1;
	
	$xml  = "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "   <nrctremp>".$nrctremp."</nrctremp>";
	$xml .= "   <tipoacao>".$tipoacao."</tipoacao>";
	$xml .= "   <vlemprst>".$vlemprst."</vlemprst>";
	$xml .= "   <vlpreemp>".$vlpreemp."</vlpreemp>";
	$xml .= "   <tpctrato>".$tpctrato."</tpctrato>";
	$xml .= "   <flgcalcu>".$flgcalcu."</flgcalcu>";
	$xml .= "   <idseqttl>".$idseqttl."</idseqttl>";
	$xml .= "   <flgerlog>".$flgerlog."</flgerlog>";
	$xml .= "   <flghisto>".$flghisto."</flghisto>";
	$xml .= " </Dados>";
	$xml .= "</Root>";
	
	$xmlResult = mensageria($xml, "EMPR0015", "PROCESSA_PERDA_APROVACAO", $glbvars["cdcooper"], $glbvars["cdpactra"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");

	$xmlObj = getObjectXML($xmlResult);

	if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO"){
		$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
		if ($msgErro == "") {
			$msgErro = $xmlObj->roottag->tags[0]->cdata;
		}
		exibirErro('error',$msgErro,'Alerta - Aimaro','',false);
	}

	$dados = $xmlObj->roottag->tags[0]->tags;

	$idpeapro = getByTagName($dados,'idpeapro');

	// idpeapro irá retornar 0 quando nao haverá perda de aprovacao e 1 para quando terá perda de aprovacao
	if ($idpeapro == 0) {
		echo "showConfirmacao('Deseja confirmar opera&ccedil;&atilde;o?', 'Confirma&ccedil;&atilde;o - Aimaro', 'manterRotina(\'F_VALOR\');', 'undoValor();bloqueiaFundo(divRotina);', 'sim.gif', 'nao.gif');";
	} else {
		echo "showConfirmacao('Com a altera&ccedil;&atilde;o a situa&ccedil;&atilde;o da proposta ser&aacute; modificada! Confirma altera&ccedil;&atilde;o?', 'Confirma&ccedil;&atilde;o - Aimaro', 'manterRotina(\'F_VALOR\');', '', 'sim.gif', 'nao.gif');";
	}

?>