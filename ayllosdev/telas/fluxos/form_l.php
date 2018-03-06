<?php
/*!
 * FONTE        	: form_l.php
 * CRIAÇÃO      	: Jaison Fernando
 * DATA CRIAÇÃO 	: Outubro/2016
 * OBJETIVO     	: Form da opcao L
 * ÚLTIMA ALTERAÇÃO : --/--/----
 * --------------
 * ALTERAÇÕES   	: 19/06/2017 - Remover informação referente a COMPE. PRJ367 - Compe Sessao Unica (Lombardi)
 * --------------
 */
?>

<form id="frmOpcaoL" name="frmOpcaoL" class="formulario">
    
    <br />

	<fieldset id="fsetInvestimentos" name="fsetInvestimentos" style="padding:10px;">
	<legend> SILOC </legend>
        <table width="500" cellpadding="10" cellspacing="2">
        <tr>
            <td align="right" width="300">COBRAN&Ccedil;A/DOC NR</td>
            <td width="200"><input type="text" value="<?php echo getByTagName($xmlRegist->tags,'VLCBDONR'); ?>" /></td>
        </tr>
        <tr>
            <td align="right">COBRAN&Ccedil;A/DOC SR</td>
            <td><input type="text" value="<?php echo getByTagName($xmlRegist->tags,'VLCBDOSR'); ?>" /></td>
        </tr>
        <tr>
            <td align="right">PREVIS&Atilde;O PARA LIQUIDA&Ccedil;&Atilde;O NO SILOC</td>
            <td><input type="text" value="<?php echo getByTagName($xmlRegist->tags,'VLPRELIQ'); ?>" /></td>
        </tr>
        </table>
	</fieldset>
    
    <br style="clear:both" />
	
</form>

<script type="text/javascript">
    var cTodosFormulario = $('input[type="text"],input[type="checkbox"],select', '#frmOpcaoL');
    cTodosFormulario.css('text-align', 'right').desabilitaCampo();
    trocaBotao('','','btnVoltar()');
</script>