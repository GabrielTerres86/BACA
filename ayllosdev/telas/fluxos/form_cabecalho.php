<?php
/*
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Jaison Fernando
 * DATA CRIAÇÃO : Outubro/2016									ÚLTIMA ALTERAÇÃO: --/--/----
 * OBJETIVO     : Cabeçalho para a tela FLUXOS
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 */

$xml = "<Root>";
$xml .= " <Dados>";
$xml .= "   <cdcooper>".($glbvars["cdcooper"] == 3 ? 0 : $glbvars["cdcooper"])."</cdcooper>";
$xml .= "   <flgativo>1</flgativo>";
$xml .= " </Dados>";
$xml .= "</Root>";

$xmlResult = mensageria($xml, "CADA0001", "LISTA_COOPERATIVAS", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlObject = getObjectXML($xmlResult);
$xmlRegist = $xmlObject->roottag->tags[0]->tags;
?>

<form id="frmCab" name="frmCab" class="formulario cabecalho" style="display:none;">	

	<label for="cddopcao">Op&ccedil;&atilde;o:</label>
	<select id="cddopcao" name="cddopcao">
		<option value=""></option>
		<option value="F"> F - Consulta Fluxo de caixa</option>
        <option value="G"> G - Gera&ccedil;&atilde;o de CSV</option>
		<option value="L"> L - Liquida&ccedil;&otilde;es das previs&otilde;es financeiras</option>
		<?php
            // Somente CECRED pode utilizar
            if ($glbvars["cdcooper"] == 3) {
                ?>
                <option value="M"> M - Movimenta&ccedil;&otilde;es de aplica&ccedil;&atilde;o e resgate</option>
                <?php
            }
        ?>
		<option value="R"> R - Resultado do Fluxo do dia</option>
	</select>

	<a href="#" class="botao" id="btnOK" onClick="btnOK();return false;" style="text-align: right;">OK</a>

    <label for="dtmvtolt">Refer&ecirc;ncia:</label>
	<input name="dtmvtolt" id="dtmvtolt" type="text" />

    <label for="dtlimite">at&eacute;:</label>
	<input name="dtlimite" id="dtlimite" type="text" />

    <label for="tpdmovto">Movimento:</label>
	<select id="tpdmovto" name="tpdmovto">
        <option value="E">Entrada de Recursos</option>
        <option value="S">Saída de Recursos</option>
        <option value="R">Resultado</option>
    </select>

    <label for="cdcooper">Cooperativa:</label>
	<select id="cdcooper" name="cdcooper">
		<?php
            echo ($glbvars["cdcooper"] == 3 ? '<option value="0">Todas</option>' : '');
            foreach ($xmlRegist as $r) {
                if (getByTagName($r->tags, 'cdcooper') <> '' &&
                    getByTagName($r->tags, 'cdcooper') <> 3 ) {
                    ?>
                    <option value="<?php echo getByTagName($r->tags, 'cdcooper'); ?>"><?php echo getByTagName($r->tags, 'nmrescop'); ?></option>
                    <?php
                }
            }
		?>
	</select>

	<br style="clear:both" />	

</form>