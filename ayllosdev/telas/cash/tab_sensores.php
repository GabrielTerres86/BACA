<? 
/*!
 * FONTE        : tab_sensores.php
 * CRIAÇÃO      : Rogérius Militao - (DB1)
 * DATA CRIAÇÃO : 26/10/2011 
 * OBJETIVO     : Tabela que apresenta a situação dos sensores
 * --------------
 * ALTERAÇÕES   : 17/09/2012 - Implementação do novo layout (David Kruger).
 * --------------
 */
 
?>

<?php
	/*
 	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');	
	require_once('../../class/xmlfile.php');
	isPostMethod();	
	*/
?>

<form id="frmSensores" name="frmSensores" class="formulario" onSubmit="return false;">

	<fieldset>
	<legend><? echo utf8ToHtml('Sensores do Terminal de Saques'); ?></legend>

	<div class="divRegistros">	
		<table class="tituloRegistros">
			<thead>
				<tr>
					<th><? echo utf8ToHtml('Localização'); ?></th>
					<th><? echo utf8ToHtml('Situação');  ?></th>
				</tr>
			</thead>
			<tbody>
				<? 
				foreach( $registro as $r ) { 
								
				?>
					<tr>
						<td><span><? echo getByTagName($r->tags,'dslocali'); ?></span>
							      <? echo getByTagName($r->tags,'dslocali'); ?>
 
						</td>
						<td><span><? echo getByTagName($r->tags,'dssensor'); ?></span>
							      <? echo getByTagName($r->tags,'dssensor'); ?>
 
						</td>
					</tr>
			<? } ?>	
			</tbody>
		</table>
	</div>

	</fieldset>	
</form>

<div id="divBotoes" style="margin-bottom:8px">
    <a href="#" class="botao" id="btVoltar" onclick="fechaOpcao(); return false;">Voltar</a>   
</div>

<script> 
	
	$(document).ready(function(){
		highlightObjFocus($('#frmSensores'));
	});

</script>