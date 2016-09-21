<?
/*!
 * FONTE        : form_pesquisa_ass.php
 * CRIAÇÃO      : Guilherme / SUPERO
 * DATA CRIAÇÃO : 26/04/2013
 * OBJETIVO     : Mostrar campos da opcao B - Bloqueio
 * --------------
 * ALTERAÇÕES   : 26/11/2014 - (Chamado 190747) - Melhoria na tela BLQJUD
 *							   Alinhamento no texto que estave sendo quebrado
 *							   e diminuido o tamanho da campo nrdconta
 *							   (Tiago Castro - RKAM).
 * --------------
 */

?>

<div id="divAssociado" style="display:none;">
<form id="frmAssociado" name="frmAssociado" class="formulario" onsubmit="return false;">

    <fieldset>
		<legend><? echo utf8ToHtml('Pesquisar Associado'); ?></legend>

        <label for="nrdconta"><? echo utf8ToHtml('Informe conta/dv ou cpf/cnpj:') ?></label>
		<br style="clear:both;" />
        <input id="nrdconta" name="nrdconta" type="text" maxlength="14" style="width:80px !important;"  />

        <a href="#" class="botao" id="btnOK" name="btnOK" onclick="consultaInicial();">OK</a>
		
		<input name="nmprimtl" id="nmprimtl" type="text"  value="<? echo $dsdconta ?>" />
        <br style="clear:both;" />
    </fieldset>

	<br style="clear:both;" />

    <div id="divResultado" align="center" style="display:none;">
     </div>

</form>
</div>
