<?php
/* !
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Daniel Zimmermann 
 * DATA CRIAÇÃO : 24/03/2016
 * OBJETIVO     : Cabeçalho para a tela PAREST
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

<form id="frmCab" name="frmCab" class="formulario">

    <label for="cddopcao"><? echo utf8ToHtml('Opção:') ?></label>
    <select id="cddopcao" name="cddopcao">
        <option value="C"><? echo utf8ToHtml(' C - Consultar Parâmetros da Esteira') ?></option> 
		<option value="A"><? echo utf8ToHtml(' A - Alterar Parâmetros da Esteira') ?></option>
    </select>
		
	  <label for="tlcooper"><? echo utf8ToHtml('Cooperativa:') ?></label>
    <select id="tlcooper" name="tlcooper">
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

    <label style="width:80px" for="tpproduto">
            <?php echo utf8ToHtml('Tipo Produto:') ?>
    </label>
    <select id="tpproduto" name="tpproduto">
        <option value="4"> <?php echo utf8ToHtml('Cartão')?> </option>
        <option value="0"> <?php echo utf8ToHtml('Empréstimo') ?> </option>
    </select>
	
	<a href="#" class="botao" id="btnOK" name="btnOK" onClick="controlaOperacao();
            return false;" style = "text-align:right;">OK</a>

</form>