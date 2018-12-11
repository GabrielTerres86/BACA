<? 
/*!
 * FONTE        : form_filtro.php
 * CRIAÇÃO      : Augusto - Supero
 * DATA CRIAÇÃO : 17/10/2018
 * OBJETIVO     : Formulario para filtrar as solicitações.
 */
session_start();
	
// Includes para controle da session, vari&aacute;veis globais de controle, e biblioteca de fun&ccedil;&otilde;es
require_once("../../includes/config.php");
require_once("../../includes/funcoes.php");		
require_once("../../includes/controla_secao.php");

// Verifica se tela foi chamada pelo m&eacute;todo POST
isPostMethod();
// Classe para leitura do xml de retorno
require_once("../../class/xmlfile.php");

$cddopcao = (!empty($_POST['cddopcao'])) ? $_POST['cddopcao'] : '';

function exibeErro($msgErro) {
	echo '<script type="text/javascript">';
	echo 'hideMsgAguardo();';
	echo 'showError("error","'.addslashes($msgErro).'","Alerta - Aimaro","");';
	echo '</script>';
	exit();
}
 
$xml = "<Root>";
$xml .= " <Dados>";
$xml .= "   <cdcooper>0</cdcooper>";
$xml .= "   <flgativo>1</flgativo>";
$xml .= " </Dados>";
$xml .= "</Root>";

$xmlResult = mensageria($xml, "CADA0001", "LISTA_COOPERATIVAS", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlObj = getObjectXML($xmlResult);

if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
    $msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
    if ($msgErro == "") {
        $msgErro = $xmlObj->roottag->tags[0]->cdata;
    }
    exibeErro($msgErro);
}

$cooperativas = $xmlObj->roottag->tags[0]->tags;

if ($cddopcao == 'M' || $cddopcao == 'R') {
	$dominio = 'SIT_PORTAB_SALARIO_RECEBE';
} else {
	$dominio = 'SIT_PORTAB_SALARIO_ENVIA';
}

$xml = "<Root>";
$xml .= " <Dados>";
$xml .= "   <nmdominio>$dominio</nmdominio>";
$xml .= " </Dados>";
$xml .= "</Root>";

$xmlResult = mensageria($xml, "SOLPOR", "BUSCA_DOMINIO_TBCC", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlObj = getObjectXML($xmlResult);

if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
    $msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
    if ($msgErro == "") {
        $msgErro = $xmlObj->roottag->tags[0]->cdata;
    }
    exibeErro($msgErro);
}

$dominios = $xmlObj->roottag->tags[0]->tags;

?>

<style>
	.ui-datepicker-trigger{
		float:left;
		margin-left:6px;
		margin-top:6px;
		cursor:pointer;
	}
</style>

<form id="frmFiltro" class="formulario" onSubmit="return false;">
	<div style="border: 1px solid #777;padding: 10px;min-height: 50px;">
		<div>
			<label for="nmrescop" style="width: 135px;">Cooperativa:</label>
			<select style="width:180px" id="nmrescop" name="nmrescop">
				<?php
				foreach ($cooperativas as $cooperativa) {					
					if ( getByTagName($cooperativa->tags, 'cdcooper') <> '' ) {
				?>
					<option <?=(getByTagName($cooperativa->tags, 'cdcooper') == $glbvars["cdcooper"] ? 'selected' : '')?> value="<?= getByTagName($cooperativa->tags, 'cdcooper'); ?>"><?= getByTagName($cooperativa->tags, 'nmrescop'); ?></option> 
					
				<?php
					}
				}
				?>
			</select>
			
			<label for="cdagenci" style="width: 77px;">PA:</label>
			<input style="width:50px" type="text" id="cdagenci" class="inteiro campo" name="cdagenci" maxlength="5" />
			<a id="lupaPA" style="cursor: pointer;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>

			<label for="nrdconta" style="width: 85px;">Conta/dv:</label>
			<input type="text" id="nrdconta" class="inteiro" maxlength="10" style="width:135px" name="nrdconta" />
			<a id="lupaAss" style="cursor: pointer;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>

			<br style="clear:both" />

			<label for="situacaoPortabilidade" style="width: 135px;">Situa&ccedil;&atilde;o:</label>
    		<select style="width:180px" id="situacaoPortabilidade" name="situacaoPortabilidade">
				<option value=""></option>
				<?php foreach ($dominios as $dominio) { ?>
					<option value="<?= getByTagName($dominio->tags, 'cddominio'); ?>"><?= getByTagName($dominio->tags, 'dscodigo'); ?></option> 					
				<?php } ?>
			</select>

			<label for="dataSolicitacaoInicio" style="width: 160px;">Data Solicita&ccedil;&atilde;o:</label>
			<input name="dataSolicitacaoInicio" id="dataSolicitacaoInicio" type="text" autocomplete="off" class="data campo" style="width: 80px;">
			<label for="dataSolicitacaoFim" style="margin-left:5px;">at&eacute;</label>
			<input name="dataSolicitacaoFim" id="dataSolicitacaoFim" type="text" autocomplete="off" class="data campo" style="width: 80px;">

			<br style="clear:both" />

			<label for="nuPortabilidade" style="width: 135px;">NU Portabilidade:</label>
    		<input name="nuPortabilidade" id="nuPortabilidade" type="text" class="inteiro campo" maxlength="21" style="margin-right: 5px;width:180px">

			<label for="dataRetornoInicio" style="width: 155px;">Data Retorno:</label>
			<input name="dataRetornoInicio" id="dataRetornoInicio" type="text" autocomplete="off" class="data campo" style="width: 80px;">
			<label for="dataRetornoFim" style="margin-left:5px;">at&eacute;</label>
			<input name="dataRetornoFim" id="dataRetornoFim" type="text" autocomplete="off" class="data campo" style="width: 80px;">


			<br style="clear:both" />
		</div>
	</div>
	<input type="hidden" id="cdcooper" value="<?=$glbvars["cdcooper"]?>"/>
</form>