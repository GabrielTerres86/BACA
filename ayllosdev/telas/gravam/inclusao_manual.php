<?php
/*!
 * FONTE        : inclusao_manual.php
 * CRIAÇÃO      : Andrei (RKAM)
 * DATA CRIAÇÃO : Maio/2016 
 * OBJETIVO     : Rotina para realizar inclusão manual do gravame
 * --------------
 * ALTERAÇÕES   : 24/08/2016 - Alteração da descricao de confirmação da inclusao manual. Projeto 369 (Lombardi).
 */
?>

<?php
	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();

	// Carrega permissões do operador
	require_once('../../includes/carrega_permissoes.php');

	$cddopcao = (isset($_POST["cddopcao"])) ? $_POST["cddopcao"] : '';

	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}

	$nrdconta = (isset($_POST["nrdconta"])) ? $_POST["nrdconta"] : 0;
	$nrctrpro = (isset($_POST["nrctrpro"])) ? $_POST["nrctrpro"] : 0;
	$dtmvttel = (isset($_POST["dtmvttel"])) ? $_POST["dtmvttel"] : '';
	$nrgravam = (isset($_POST["nrgravam"])) ? $_POST["nrgravam"] : 0;
	$tpctrpro = (isset($_POST["tpctrpro"])) ? $_POST["tpctrpro"] : 0;
	$idseqbem = (isset($_POST["idseqbem"])) ? $_POST["idseqbem"] : 0;
	$dsjustif = (isset($_POST["dsjustif"])) ? $_POST["dsjustif"] : '';
	$tpinclus = (isset($_POST["tpinclus"])) ? $_POST["tpinclus"] : '';

	validaDados();

	// Monta o xml de requisição
	$xml  		= "";
	$xml 	   .= "<Root>";
	$xml 	   .= "  <Dados>";
	$xml 	   .= "     <nrdconta>".$nrdconta."</nrdconta>";
	$xml 	   .= "     <cddopcao>".$cddopcao."</cddopcao>";
  	$xml 	   .= "     <nrctrpro>".$nrctrpro."</nrctrpro>";
  	$xml 	   .= "     <tpctrpro>".$tpctrpro."</tpctrpro>";
  	$xml 	   .= "     <idseqbem>".$idseqbem."</idseqbem>";
  	$xml 	   .= "     <nrgravam>".$nrgravam."</nrgravam>";
  	$xml 	   .= "     <dtmvttel>".$dtmvttel."</dtmvttel>";
if ($tpinclus == "M") {
	$xml 	   .= "     <dsjustif>".$dsjustif."</dsjustif>";
	$xml       .= "     <tpinclus>".$tpinclus."</tpinclus>";
	$xml       .= "     <cdopeapr>".$_SESSION['cdopelib']."</cdopeapr>";
} else {
	$xml 	   .= "     <dsjustif></dsjustif>";
	$xml       .= "     <tpinclus>".$tpinclus."</tpinclus>";
	$xml       .= "     <cdopeapr></cdopeapr>";
}
	$xml 	   .= "  </Dados>";
	$xml 	   .= "</Root>";

	// Executa script para envio do XML
	$xmlResult = mensageria($xml, "GRVM0001", "INCMANUALGRAVAM", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);

	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {

		$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
		$nmdcampo = $xmlObj->roottag->tags[0]->attributes["NMDCAMPO"];

		if(empty ($nmdcampo)){
			$nmdcampo = "dtmvttel";
		}

		exibirErro('error',$msgErro,'Alerta - Ayllos','formataFormularioBens();focaCampoErro(\''.$nmdcampo.'\',\'frmBens\');',false);

	} else {
		echo "showError('inform','".utf8ToHtml('Alienação confirmada junto ao SNG')."','Notifica&ccedil;&atilde;o - Ayllos','');";
	}

	function validaDados() {

		IF($GLOBALS["dtmvttel"] == '' ) {
			exibirErro('error','Data do registro deve ser informada!.','Alerta - Ayllos','focaCampoErro(\'dtmvttel\',\'frmBens\');',false);
		}

		IF($GLOBALS["dsjustif"] == '' ) {
			exibirErro('error','Justificativa deve ser informada!','Alerta - Ayllos','focaCampoErro(\'dsjustif\',\'frmBens\');',false);
		}

		IF($GLOBALS["nrgravam"] == 0 ) {
			exibirErro('error','O n&uacute;mero do registro deve ser informado!','Alerta - Ayllos','focaCampoErro(\'nrgravam\',\'frmBens\');',false);
		}
	}

 ?>
