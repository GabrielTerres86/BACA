<? 
/*!
 * FONTE        : tab_monitorar.php
 * CRIAÇÃO      : Rogérius Militao - (DB1)
 * DATA CRIAÇÃO : 16/11/2011 
 * OBJETIVO     : Tabela que apresenta a consulta da opção M da tela Cash
 * --------------
 * ALTERAÇÕES   : 17/09/2012 - Implementação do novo layout (David Kruger).
 *                13/08/2013 - Alteração da sigla PAC para PA (Carlos).
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


<form id="frmMonitorar" name="frmMonitorar" class="formulario" onSubmit="return false;">

	<fieldset>
	<legend><? echo utf8ToHtml('Monitorar'); ?></legend>
	
	
	<label for="mmtramax">Tolerancia de:</label>
	<input id="mmtramax" name="mmtramax" type="text" value="<?php echo $mmtramax ?>" >
	<label for="mminutos">minutos</label>
    <a href="#" class="botao" id="btnOK">OK</a> 
		
	<div class="divRegistros">	
		<table class="tituloRegistros">
			<thead>
				<tr>
					<th><? echo utf8ToHtml('COOP'); ?></th>
					<th><? echo utf8ToHtml('PA');  ?></th>
					<th><? echo utf8ToHtml('TAA');  ?></th>
					<th><? echo utf8ToHtml('Horario');  ?></th>
					<th><? echo utf8ToHtml('Nome');  ?></th>
					<th><? echo utf8ToHtml('PING');  ?></th>
				</tr>
			</thead>
			<tbody>
				<? 
				foreach( $monitorar as $r ) { 
								
				?>
					<tr>
						<td><span><? echo getByTagName($r->tags,'cdcoptfn'); ?></span>
							      <? echo getByTagName($r->tags,'cdcoptfn'); ?>
  
						</td>
						<td><span><? echo getByTagName($r->tags,'nmagetfn'); ?></span>
							      <? echo getByTagName($r->tags,'nmagetfn'); ?>
						</td>
						<td><span><? echo getByTagName($r->tags,'nrterfin'); ?></span>
							      <? echo getByTagName($r->tags,'nrterfin'); ?>
						</td>
						<td><span><? echo getByTagName($r->tags,'dstransa'); ?></span>
							      <? echo getByTagName($r->tags,'dstransa'); ?>
						</td>
						<td><span><? echo getByTagName($r->tags,'nmnarede'); ?></span>
								  <? echo getByTagName($r->tags,'nmnarede'); ?>
						</td>
						<td><span><? echo getByTagName($r->tags,'dsdoping'); ?></span>
								  <? echo getByTagName($r->tags,'dsdoping'); ?>
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
		highlightObjFocus($('#frmMonitorar'));
	});

</script>