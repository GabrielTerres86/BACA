<? 
/*!
 * FONTE        : tab_depositos.php
 * CRIAÇÃO      : Rogérius Militao - (DB1)
 * DATA CRIAÇÃO : 26/10/2011 
 * OBJETIVO     : Tabela que apresenta os depositos
 * --------------
 * ALTERAÇÕES   :  17/09/2012 - Implementação do novo layout (David Kruger).
 *                27/05/2014 - Incluido a informação de espécie de deposito e
							   relatório do mesmo. (Andre Santos - SUPERO)
							   
			      14/09/2016 - #462247 Inclusão da opção de exportar para arquivo csv as transações de depósitos (Carlos)
 * --------------
 */
	/*
 	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');	
	require_once('../../class/xmlfile.php');
	isPostMethod();	
	*/
	?>

<form id="frmDepositos" name="frmDepositos" class="formulario" onSubmit="return false;">

	<fieldset>
	<legend><? echo utf8ToHtml('Depositos'); ?></legend>

	<div class="divRegistros" >	
		<table class="tituloRegistros">
			<thead>
				<tr>
					<th><? echo utf8ToHtml('Data'); ?></th>
					<th><? echo utf8ToHtml('Hora');  ?></th>
					<th><? echo utf8ToHtml('Conta Fav');  ?></th>
					<th><? echo utf8ToHtml('Envelope');  ?></th>
					<th><? echo utf8ToHtml('ESP');  ?></th>
					<th><? echo utf8ToHtml('Valor Inf');  ?></th>
					<th><? echo utf8ToHtml('Valor Comp');  ?></th>
					<th><? echo utf8ToHtml('Situação');  ?></th>
				</tr>
			</thead>
			<tbody>
				<?php
				$csv = utf8_decode('Data;Hora;Conta Fav;Envelope;Esp;Valor Inf; Valor Comp;Situação')."\r\n";

				foreach( $envelope as $r ) {

					$csv .= getByTagName($r->tags,'dtmvtolt') . ';' .
					        getByTagName($r->tags,'hrtransa') . ';' .
							getByTagName($r->tags,'nrdconta') . ';' .							
							getByTagName($r->tags,'nrseqenv') . ';' .
							getByTagName($r->tags,'dsespeci') . ';' .
							getByTagName($r->tags,'vlenvinf') . ';' .
							getByTagName($r->tags,'vlenvcmp') . ';' .
							getByTagName($r->tags,'dssitenv') . "\r\n"; ?>
					<tr>
						<td><span><? echo dataParaTimestamp(getByTagName($r->tags,'dtmvtolt')); ?></span>
							      <? echo getByTagName($r->tags,'dtmvtolt'); ?>
 
						</td>
						<td><span><? echo getByTagName($r->tags,'hrtransa'); ?></span>
							      <? echo getByTagName($r->tags,'hrtransa'); ?>
						</td>
						<td><span><? echo getByTagName($r->tags,'nrdconta'); ?></span>
							      <? echo getByTagName($r->tags,'nrdconta'); ?>
						</td>
						<td><span><? echo getByTagName($r->tags,'nrseqenv'); ?></span>
							      <? echo getByTagName($r->tags,'nrseqenv'); ?>
						</td>
						<td><span><? echo getByTagName($r->tags,'dsespeci'); ?></span>
							      <? echo getByTagName($r->tags,'dsespeci'); ?>
						</td>
						<td><span><? echo getByTagName($r->tags,'vlenvinf'); ?></span>
								  <? echo getByTagName($r->tags,'vlenvinf'); ?>
						</td>
						<td><span><? echo getByTagName($r->tags,'vlenvcmp'); ?></span>
								  <? echo getByTagName($r->tags,'vlenvcmp'); ?>
						</td>
						<td><span><? echo getByTagName($r->tags,'dssitenv'); ?></span>
								  <? echo getByTagName($r->tags,'dssitenv'); ?>
						</td>
					</tr>
			<? }
			   // Salva arquivo csv com nome em microsegundos
			   $nmarquivo   = 'cash_depositos_' . round(microtime(true) * 1000) . '.xls';
			   $nmdir       = '../../documentos/'.$glbvars['dsdircop'].'/temp/';
			   file_put_contents($nmdir.$nmarquivo, $csv);
			?>
			</tbody>
		</table>
	</div>	
	
	</fieldset>
</form>

<div id="divBotoes" style="margin-bottom:8px">
    <a href="#" class="botao" id="btVoltar" onclick="fechaOpcao(); return false;">Voltar</a>
	<a href="baixar.php?arquivo=<?php echo $nmarquivo; ?>&coop=<?php echo $glbvars['dsdircop']?>" class="botao" id="btExportar" target="_blank">Exportar</a>
</div>

<script> 
	
	$(document).ready(function(){
		highlightObjFocus($('#frmDepositos'));
	});

</script>
