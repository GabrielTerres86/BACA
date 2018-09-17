<? 
/*!
 * FONTE        : tab_notjus.php
 * CRIAÇÃO      : David Kruger
 * DATA CRIAÇÃO : 23/01/2013 
 * OBJETIVO     : Tabela que apresenta a consulta NOTJUS
 * --------------
 * ALTERAÇÕES   : 19/11/2013 - Ajustes para homologação (Adriano)
 * --------------
 */
 
 	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');	
	require_once('../../class/xmlfile.php');
	isPostMethod();		
	
?>
	
<div id="tabNotjus" style="display:none;">

	<form class="formulario">
	
		<fieldset id='tabConteudo'>
		
			<legend><? echo utf8ToHtml('Estouros') ?></legend>
			
			<div class="divRegistros">	
			
				<table class="tituloRegistros">
					<thead>
						<tr>
							<th><? echo utf8ToHtml('Seq'); ?></th>
							<th><? echo utf8ToHtml('Inicio'); ?></th>
							<th><? echo utf8ToHtml('Dias'); ?></th>
							<th><? echo utf8ToHtml('Hist&oacute;rico');  ?></th>
							<th><? echo utf8ToHtml('Valor do Estouro');  ?></th>
							<th><? echo utf8ToHtml('Observa&ccedil;&otilde;es');  ?></th>
						</tr>
					</thead>
					<tbody>
						<?
						foreach ( $registros as $registro ) { 
						?>
							<tr>
							
								<td>
									<span><? echo getByTagName($registro->tags,'nrseqdig'); ?></span>
									 <? echo getByTagName($registro->tags,'nrseqdig'); ?>
									<input type="hidden" id="nrseqdig" name="nrseqdig" value="<? echo getByTagName($registro->tags,'nrseqdig') ?>" />
								</td>
								<td>
									<span><? echo dataParaTimestamp(getByTagName($registro->tags,'dtiniest')); ?></span>
									<? echo getByTagName($registro->tags,'dtiniest'); ?>
								</td>
								<td>
									<span><? echo getByTagName($registro->tags,'qtdiaest'); ?></span>
									<? echo getByTagName($registro->tags,'qtdiaest'); ?>
								</td>
								<td>
									<span><? echo getByTagName($registro->tags,'dshisest'); ?></span>
									<? echo getByTagName($registro->tags,'dshisest'); ?> 
								</td>
								<td>
									<span><? echo getByTagName($registro->tags,'vlestour'); ?></span>
									<? echo getByTagName($registro->tags,'vlestour'); ?>
								</td>
								<td>
									<span><? echo getByTagName($registro->tags,'dsobserv'); ?></span>
									<? echo getByTagName($registro->tags,'dsobserv'); ?>
								</td>
								
							</tr>
							
					<? } ?>	
					
					</tbody>
					
				</table>
				
			</div>	
			
		</fieldset>
		
	</form>
	
</div>

<div id="divBotoes" style="margin-bottom:15px" style="display:none" >

	<a href="#" class="botao" id="btVoltar"      onclick="btnVoltar(); return false;">Voltar</a>
	<a href="#" class="botao" id="btNotificacao" onclick="showConfirmacao('Deseja confirmar opera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Ayllos','selecionaEstouro(\'N\');','','sim.gif','nao.gif'); return false;">Notifica&ccedil;&atilde;o</a>
	<a href="#" class="botao" id="btExcluir"     onclick="showConfirmacao('Deseja confirmar opera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Ayllos','selecionaEstouro(\'E\');','','sim.gif','nao.gif'); return false;">Excluir</a>
	<a href="#" class="botao" id="btJustificar"  onclick="showConfirmacao('Deseja confirmar opera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Ayllos','selecionaEstouro(\'J\');','','sim.gif','nao.gif'); return false;">Justificar</a>
	
</div>