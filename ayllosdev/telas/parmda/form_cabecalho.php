<?
/*!
 * FONTE        : parmda.php
 * CRIAÇÃO      : Dionathan Henchel
 * DATA CRIAÇÃO : 04/05/2016
 * OBJETIVO     : Cabeçalho para a tela PARMDA
 * --------------
 * ALTERAÇÕES   : 
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
    echo 'hideMsgAguardo();';
    echo 'showError("error","' . $msgErro . '","Alerta - Ayllos","desbloqueia()");';
    exit();
}
 
?>

<form id="frmCab" name="frmCab" class="formulario cabecalho">

	<label for="cddopcao"><? echo utf8ToHtml('Opção:') ?></label>
	<select id="cddopcao" name="cddopcao" alt="Informe a opcao desejada (A)." onchange="habilitaopcaotodas();">
		<option value="C"> <? echo utf8ToHtml('C - Consultar Parâmetros') ?> </option>
		<option value="A"> <? echo utf8ToHtml('A - Alterar Parâmetros') ?> </option>
		<?php //<option value="E"> echo utf8ToHtml('E - Excluir Parâmetros') </option> ?>
	</select>
	<label for="cdcooper"><? echo utf8ToHtml('Cooperativa:') ?></label>
	<select id="cdcooper" name="cdcooper">
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
	<a href="#" class="botao" id="btnOK" name="btnOK" onClick="LiberaCampos(); return false;" style = "text-align:right;">OK</a>
	
	<br style="clear:both" />
	
</form>

<script type='text/javascript'>
	formataCabecalho();
</script>