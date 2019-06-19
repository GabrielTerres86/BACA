<?php
/* !
 * FONTE        : form_cargas_sas_just.php
 * CRIAÇÃO      : Christian Grauppe - ENVOLTI
 * DATA CRIAÇÃO : Janeiro/2019
 * OBJETIVO     : Mostrar tela IMPPRE - justivicativa de carga
 * --------------
 * ALTERAÇÕES   : 09/09/2015 - Retirada a opção N da coluna 'Permite varias no mês' (Vanessa)
 * --------------
 */

require_once("../../class/xmlfile.php");

$skcarga = (isset($_POST['skcarga'])) ? $_POST['skcarga'] : '';
$cdcooper = (isset($_POST['cdcooper'])) ? $_POST['cdcooper'] : '';
$dscarga = (isset($_POST['dscarga'])) ? $_POST['dscarga'] : '';

?>
<form id="frmDados" name="frmDados" class="formulario" onSubmit="return false;" style="display:block;">

    <br style="clear:both" />
	<fieldset style="width:95%;" >
        <legend align="left"><?php echo 'Justifcativa da Carga SAS' ?></legend>

		<input type="hidden" id="skcarga" name="skcarga" value="<? echo $skcarga; ?>" />
		<input type="hidden" id="cdcooper" name="cdcooper" value="<? echo $cdcooper; ?>" />

		<label for="dsrejeicao"><? echo utf8ToHtml('Justificativa para '.$dscarga.":"); ?></label><br/>
		<textarea name='dsrejeicao' id='dsrejeicao' class="campo" style="width:100%;height:120px;" > </textarea>
    </fieldset>

    <br style="clear:both" />

    <div id="divBotoes">
    	<a href="#" class="botao" id="btVoltar" name="btVoltar" onClick="encerraRotina(true);return false;" style="float:none;">Voltar</a>
        <a href="#" class="botao" id="btGravar" name="btGravar" onClick="cargaSAS('R');return false;" style="float:none;">Gravar</a>
	</div>

</form>

<script type="text/javascript">
    // Bloqueia o conteudo em volta da divRotina
    blockBackground(parseInt($("#divRotina").css("z-index")));
</script>