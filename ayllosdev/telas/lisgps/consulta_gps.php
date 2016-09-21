<?
/*!
 * FONTE        : consulta_gps.php
 * CRIAÇÃO      : Andre Santos - SUPERO
 * DATA CRIAÇÃO : Setembro/2015
 * OBJETIVO     : Consulta os totais de folha de pagamentos - GPS
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

	$retornoAposErro = 'unblockBackground()';
	
	$dtpagmto = isset($_POST["dtpagmto"]) ? $_POST["dtpagmto"] : "";
	$cdagenci = isset($_POST["cdagenci"]) ? $_POST["cdagenci"] : 0;
	$nrdcaixa = isset($_POST["nrdcaixa"]) ? $_POST["nrdcaixa"] : 0;

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
	$xml .= '		<dtpagmto>'.$dtpagmto.'</dtpagmto>';
	$xml .= '		<cdagenci>'.$cdagenci.'</cdagenci>';
	$xml .= '		<nrdcaixa>'.$nrdcaixa.'</nrdcaixa>';
	$xml .= '	</Dados>';
	$xml .= '</Root>';

	// Executa script para envio do XML e cria objeto para classe de tratamento de XML
	$xmlResult = mensageria($xml, "LISGPS", "CONSGPS", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjeto = getObjectXML($xmlResult);

	// Se ocorrer um erro, mostra mensagem
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') {
		$msgErro  = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibirErro('error',$msgErro,'Alerta - Ayllos',$retornoAposErro,false);
	}

	$qtdRecebido  = $xmlObjeto->roottag->tags[0]->attributes['QTD_RECEBIDO'];
	$vlrRecebido  = $xmlObjeto->roottag->tags[0]->attributes['VLR_RECEBIDO'];
?>

<fieldset style="width:600px;height:80px;margin: 20px auto;">
	<legend>Pagamentos de GPS</legend>
	<br style="clear:both" />

	<label for="qtdTotal" style="width:200px;"><? echo utf8ToHtml('Quantidade:') ?></label>
	<input name="qtdTotal" class="campo" id="qtdTotal" type="text" value="<?php echo $qtdRecebido ?>" style="width:50px;text-align:right" readonly="true" />
	<label for="vlrTotal" style="width:100px;"><? echo utf8ToHtml('Valor R$:') ?></label>	
	<input name="vlrTotal" class="campo" id="vlrTotal" type="text" value="<?php echo $vlrRecebido ?>" style="width:200px;text-align:right" readonly="true" />
	
</fieldset>