<?php
/*!
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : André Clemer - Supero
 * DATA CRIAÇÃO : 29/10/2018
 * OBJETIVO     : Cabeçalho para a tela CADTAR (Cadastro de tarifas)
 * -------------- 
 * ALTERAÇÕES   : 13/08/2019 - Incluir campos no grid, conforme RITM0011962 (Jose Gracik/Mouts).
 *
 * --------------
 */

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

    exibeErroNew($msgErro);
    exit();
}

$registros = $xmlObj->roottag->tags[0]->tags;

function exibeErroNew($msgErro) {
    echo '<script>hideMsgAguardo();';
    echo 'showError("error","' . $msgErro . '","Alerta - Ayllos","desbloqueia()");</script>';
    exit;
}
?>
<div id="divCab">
	<form id="frmCab" name="frmCab" class="formulario cabecalho">
		<input type="hidden" id="glbcdcooper" name="glbcdcooper" value="<? echo $glbvars["cdcooper"] ?>">
		<input type="hidden" id="glbdtmvtolt" name="glbdtmvtolt" value="<? echo $glbvars["dtmvtolt"] ?>">
		<input type="hidden" id="cdtipcat" name="cdtipcat" value="<? echo $cdtipcat == 0 ? '' : $cdtipcat ?>">
		<table width="100%">
			<tr>
				<td>
					<label for="cddopcao" class="rotulo" style="width: 265px">Op&ccedil;&atilde;o:</label>
					<select id="cddopcao" class="campo" name="cddopcao" style="width: 540px;">
					<? // if  ( $glbvars["cdcooper"] == 3 ) { ?>
					<option value="C"> C - Consultar Tarifas </option> 
					<? // } ?>
					</select>
					<a href="#" class="botao" id="btnOK" name="btnOK" onClick="LiberaCampos(); return false;" style="text-align:right;">OK</a>
				</td>
			</tr>
		</table>
	</form>
</div>