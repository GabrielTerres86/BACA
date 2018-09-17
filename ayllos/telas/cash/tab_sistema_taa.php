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

<form id="frmSistemaTAA" name="frmSistemaTAA" class="formulario" onSubmit="return false;">

	<fieldset>
	<legend><? echo utf8ToHtml('Sistema TAA'); ?></legend>

	<div class="divRegistros">	
		<table class="tituloRegistros">
			<thead>
				<tr>
					<th><? echo utf8ToHtml('Terminal'); ?></th>
					<th><? echo utf8ToHtml('Sistema TAA');  ?></th>
				</tr>
			</thead>
			<tbody>
				<? 
				foreach( $registro as $r ) { 
					$flsistaa = getByTagName($r->tags,'flsistaa') == 'yes' ? 'Liberado' : 'Bloqueado';		
				?>
					<tr>
						<td><span><? echo getByTagName($r->tags,'dsterfin'); ?></span>
							      <? echo getByTagName($r->tags,'dsterfin'); ?>
 
						</td>
						<td><span><? echo $flsistaa ?></span>
							      <? echo $flsistaa ?>
 
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
		highlightObjFocus($('#frmSistemaTAA'));
	});

</script>