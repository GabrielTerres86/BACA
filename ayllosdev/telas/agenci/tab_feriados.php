<? 
/*!
 * FONTE        : tab_feriados.php
 * CRIA��O      : David Kruger
 * DATA CRIA��O : 06/02/2013
 * OBJETIVO     : Tabela que apresenta os feriados municipais das Agencias.
 * --------------
 * ALTERA��ES   : 08/01/2014 - Ajustes para homologa��o (Adriano)
 * --------------
 */
 
?>

<?php
 	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');	
	require_once('../../class/xmlfile.php');
	isPostMethod();		
?>
	
<div id="tabFeriados" style="display:block; ">

	<form class="formulario" id="frmFeriados" name="frmFeriados">
	
		<fieldset id="tabConteudo">
		
			<legend><? echo utf8ToHtml('Feriados Municipais') ?></legend>
			
			<div class="divRegistros">	
			
				<table class="tituloRegistros">
					<thead>
						<tr>
							<th><? echo utf8ToHtml('Feriados Municipais'); ?></th>
						</tr>
					</thead>
					<tbody>
						<?
						foreach ( $feriados as $f ) { 
						?>
							<tr>
								<td><span><? echo dataParaTimestamp(getByTagName($f->tags,'dtferiad')); ?></span>
										  <? echo getByTagName($f->tags,'dtferiad'); ?>
								</td>
							</tr>
					<? } ?>	
					</tbody>
				</table>
				
			</div>	
			
		</fieldset>
		
	</form>
	
</div>