<?
/*!
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Jackson Barcellos AMcom
 * DATA CRIAÇÃO : 04/2019
 * OBJETIVO     : P530
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
	<label for="nrdconta">Conta:</label>
	<input type="text" id="nrdconta" name="nrdconta" value="<? echo $nrdconta ?>" />
	<a href="#" onclick="montaPesquisaAssociados(); " ><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif" /></a>
		
	<label for="nrdconta">CPF/CNPJ:</label>
	<input type="text" id="nrcpfcnpj" name="nrcpfcnpj" value="<? echo $nrcpfcnpj ?>" />
		
	<a href="#" onclick="btnOk(); " class="botao" id="btnOK" >OK</a>

	<br style="clear:both" />	
	
	<input type="hidden" id="glbdtmvtolt" name="glbdtmvtolt" value="<? echo $glbvars["dtmvtolt"] ?>" />
</form>