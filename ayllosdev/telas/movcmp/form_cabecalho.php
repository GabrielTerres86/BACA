<?
/*!
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Jackson Barcellos AMcom
 * DATA CRIAÇÃO : 06/2019
 * OBJETIVO     : P565
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 */
 
 
$xml = "<Root>";
$xml .= " <Dados>";
$xml .= "   <cdcooper>0</cdcooper>";
$xml .= "   <flgativo>1</flgativo>";
$xml .= " </Dados>";
$xml .= "</Root>";

$xmlResult = mensageria($xml, "PAREST", "PAREST_LISTA_COOPER", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlObj = getObjectXML($xmlResult);

if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
    $msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
    if ($msgErro == "") {
        $msgErro = $xmlObj->roottag->tags[0]->cdata;
    }

    exibeErroNew($msgErro);
    exit();
}

$registros = $xmlObj->roottag->tags[0]->tags;

function exibeErroNew($msgErro) {
    echo 'hideMsgAguardo();';
    echo 'showError("error","' . $msgErro . '","Alerta - Ayllos","desbloqueia()");';
    exit();
}
 
?>

<form id="frmCab" name="frmCab" class="formulario cabecalho" onSubmit="return false;" style="display:none">
	
	<label for="tpremessa"><? echo utf8ToHtml('Tipo Remessa:') ?></label>	
	<select id="tpremessa" name="tpremessa">
		<option value="nr">Nossa Remessa</option> 
		<option value="sr">Sua Remessa</option> 
	</select>
	<? if ($glbvars["cdcooper"] == 3){ ?>
	<label for="vcooper"><? echo utf8ToHtml('Cooperativa:') ?></label>
    <select id="vcooper" name="vcooper">
		<option value="0"><? echo utf8ToHtml(' Todas') ?></option> 
		<?php
		foreach ($registros as $r) {
			
			if ( getByTagName($r->tags, 'cdcooper') <> '' ) {
		?>
			<option value="<?= getByTagName($r->tags, 'cdcooper'); ?>"><?= getByTagName($r->tags, 'nmrescop'); ?></option> 
			
			<?php
			}
		}
		?>
    </select>
	<? } ?>	
	<label for="cdagenci"><? echo utf8ToHtml('PA:') ?></label>
	<input type="text" id="cdagenci" name="cdagenci" value="<? echo $cdagenci ?>" />

	<br style="clear:both" />
	
	<label for="tparquivo"><? echo utf8ToHtml('Tipo Arquivo:') ?></label>
	<select id="tparquivo" name="tparquivo">
		<option value="0">Todos</option> 		
	</select>

	<label for="dtinicial"><? echo utf8ToHtml('Data Inicial:') ?></label>
	<input type="text" id="dtinicial" name="dtinicial" value="<? echo $dtinicial ?>" />

	<label for="dtfinal"><? echo utf8ToHtml('Data Final:') ?></label>
	<input type="text" id="dtfinal" name="dtfinal" value="<? echo $dtfinal ?>" />

	<a href="#" onclick="btnOk(); " class="botao" id="btnOK" >OK</a>

	<br style="clear:both" />	
	
	<input type="hidden" id="glbdtmvtolt" name="glbdtmvtolt" value="<? echo $glbvars["dtmvtolt"] ?>" />
</form>