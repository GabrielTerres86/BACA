<?php
/*
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Jaison Fernando
 * DATA CRIAÇÃO : Novembro/2016									ÚLTIMA ALTERAÇÃO: --/--/----
 * OBJETIVO     : Cabeçalho para a tela CONINC
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
		<option value="C"> C - Consulta de Inconsist&ecirc;ncia</option>
        <option value="G"> G - Grupo de Inconsist&ecirc;ncia</option>
		<option value="E"> E - E-mails do Grupo de Inconsist&ecirc;ncia</option>
		<option value="A"> A - Acesso ao Grupo de Inconsist&ecirc;ncia</option>
	</select>

	<a href="#" class="botao" id="btnOK" onClick="btnOK();return false;" style="text-align: right;">OK</a>

    <label for="dtrefini">Per&iacute;odo:</label>
	<input name="dtrefini" id="dtrefini" type="text" />

    <label for="dtreffim">at&eacute;:</label>
	<input name="dtreffim" id="dtreffim" type="text" />

    <label for="dsoperac">Opera&ccedil;&atilde;o:</label>
	<select id="dsoperac" name="dsoperac">
        <option value="C">Consultar</option>
        <option value="I">Incluir</option>
        <option value="E">Excluir</option>
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

    <label for="iddgrupo">Grupo:</label>
	<input name="iddgrupo" id="iddgrupo" type="text" />
    <a id="btngrupo" style="padding: 3px 0 0 3px;" href="#" onClick="mostraPesquisaGrupo();return false;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"/></a>
    <input type="text" name="nmdgrupo" id="nmdgrupo" />

    <label for="dsincons">Inconsist&ecirc;ncia:</label>
	<input name="dsincons" id="dsincons" type="text" />

    <label for="dsregist">Registro de Refer&ecirc;ncia:</label>
	<input name="dsregist" id="dsregist" type="text" />

	<br style="clear:both" />	

</form>