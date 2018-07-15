<?
/*!
 * FONTE        : form_configuracao.php
 * CRIAÇÃO      : Rogerius Militão (DB1)
 * DATA CRIAÇÃO : 26/10/2011
 * OBJETIVO     : Formulario com os dados de configuração
 * --------------
 * ALTERAÇÕES   : 17/09/2012 - Implementação do novo layout (David Kruger).
 *                13/08/2013 - Alteração da sigla PAC para PA (Carlos).
 *                25/07/2017 - #712156 Melhoria 274, inclusão do campo flgntcem (Carlos)
 *                03/07/2018 - sctask0014656 permitir alterar a descricao do TAA (Carlos)
 * --------------
 */
?>
<form id="frmConfiguracao" name="frmConfiguracao" class="formulario" onSubmit="return false;">
		
	<fieldset>	
		
		<legend><? echo utf8ToHtml('Configuração:') ?></legend>

        <label for="dsterfin">Nome:</label>
        <input name="dsterfin" id="dsterfin" type="text" value="<? echo $dsterfin ?>" />
        <br />
		
		<label for="cdagenci"><? echo utf8ToHtml('PA:') ?></label>	
		<input name="cdagenci" id="cdagenci" type="text" value="<? echo $cdagenci ?>" />
		<br />
		
		<label for="dsfabtfn"><? echo utf8ToHtml('Fabricante:') ?></label>
		<input name="dsfabtfn" id="dsfabtfn" type="text" value="<? echo $dsfabtfn?>" />
		<br />

		<label for="dsmodelo"><? echo utf8ToHtml('Modelo:') ?></label>
		<input name="dsmodelo" id="dsmodelo" type="text" value="<? echo $dsmodelo ?>" />
		<br />

		<label for="dsdserie"><? echo utf8ToHtml('Número de Serie:') ?></label>
		<input name="dsdserie" id="dsdserie" type="text" value="<? echo $dsdserie ?>" />
		<br />

		<label for="nmnarede"><? echo utf8ToHtml('Ident. na Rede:') ?></label>
		<input name="nmnarede" id="nmnarede" type="text" value="<? echo $nmnarede ?>" />
		<input name="nrdendip" id="nrdendip" type="text" value="<? echo $nrdendip ?>" />
		<br />

		<label for="cdsitfin"><? echo utf8ToHtml('Situação:') ?></label>
		<input name="cdsitfin" id="cdsitfin" type="text" value="<? echo $cdsitfin ?>" />
		<input name="dssittfn" id="dssittfn" type="text" value="<? echo $dssittfn ?>" />
		<br />
		
		<label for="qtcasset"><? echo utf8ToHtml('N° de Cassetes:') ?></label>
		<input name="qtcasset" id="qtcasset" type="text" value="<? echo $qtcasset ?>" />
		<br />

		<label for="flgntcem"><? echo utf8ToHtml('Usa Notas 100:') ?></label>		
		<input name="flgntcem" id="flgntcem" type="checkbox" value="yes"
		<?php echo ($flgntcem == 'yes')? 'checked="checked"':'' ?> />
		<br />
		
		<label for="dstempor"><? echo utf8ToHtml('Temporizador:') ?></label>
		<input name="dstempor" id="dstempor" type="text" value="<? echo $dstempor ?>" />
		<br />

		<label for="dsdispen"><? echo utf8ToHtml('Dispensador:') ?></label>
		<input name="dsdispen" id="dsdispen" type="text" value="<? echo $dsdispen ?>" />
		<br />

		<label for="noturno1"><? echo utf8ToHtml('Noturno:') ?></label>
		<label for="dsininot"><? echo utf8ToHtml('Início:') ?></label>
		<input name="dsininot" id="dsininot" type="text" value="<? echo $dsininot ?>" /> 
		<label for="dsinino2"><? echo utf8ToHtml('Horas') ?></label>

		
		<br  />

		<label for="dsfimnot"><? echo utf8ToHtml('Final:') ?></label>
		<input name="dsfimnot" id="dsfimnot" type="text" value="<? echo $dsfimnot ?>" /> 
		<label for="dsfimno2"><? echo utf8ToHtml('Horas') ?></label>
		<br />

		<label for="dssaqnot"><? echo utf8ToHtml('Saque Máximo:') ?></label>
		<input name="dssaqnot" id="dssaqnot" type="text" value="<? echo $dssaqnot ?>" />

		<br style="clear:both" />
		
	</fieldset>

</form>

<div id="divBotoes" style="margin-bottom:8px">
	<a href="#" class="botao" id="btVoltar" onclick="fechaOpcao(); return false;">Voltar</a>
	<?php
	if ( $cddopcao == 'A' or $cddopcao == 'I' ) {
	?>
    <a href="#" class="botao" id="btSalvar" onclick="btnContinuar(); return false;">Continuar</a> 
	<?php
	}
	?>
</div>

<script> 
	
	$(document).ready(function(){
		highlightObjFocus($('#frmConfiguracao'));
	});

</script>
