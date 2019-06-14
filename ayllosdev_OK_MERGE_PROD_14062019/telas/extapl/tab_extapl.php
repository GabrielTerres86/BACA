<? 
/*!
 * FONTE        : tab_extapl.php
 * CRIAÇÃO      : Rogérius Militao - (DB1)
 * DATA CRIAÇÃO : 23/08/2011 
 * OBJETIVO     : Tabela que apresenta a consulta EXTAPL
 * --------------
 * ALTERAÇÕES   : 30/11/2012 - Alterado botões do tipo tag <input> para
 *					           tag <a> novo layout, alterado para não mostrar
 * 							   form ao carregar a tela (Daniel).
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
	
<div id="tabExtapl" style="display:none;">
<form class="formulario">
<fieldset id='tabConteudo'>
	<legend><? echo utf8ToHtml('Aplicações') ?></legend>
	<div class="divRegistros">	
		<table class="tituloRegistros">
			<thead>
				<tr>
					<th><? echo utf8ToHtml('Seq'); ?></th>
					<th><? echo utf8ToHtml('Aplicação'); ?></th>
					<th><? echo utf8ToHtml('Número'); ?></th>
					<th><? echo utf8ToHtml('Data Apl');  ?></th>
					<th><? echo utf8ToHtml('Tipo Impressão do Extrato');  ?></th>
				</tr>
			</thead>
			<tbody>
				<?
				foreach ( $registro as $r ) { 
				?>
					<tr>
						<td><span><? echo getByTagName($r->tags,'nrsequen'); ?></span>
							      <? echo getByTagName($r->tags,'nrsequen'); ?>
  								  <input type="hidden" id="nrsequen" name="nrsequen" value="<? echo getByTagName($r->tags,'nrsequen') ?>" />								  
  								  <input type="hidden" id="descapli" name="descapli" value="<? echo getByTagName($r->tags,'descapli') ?>" />								  
  								  <input type="hidden" id="nraplica" name="nraplica" value="<? echo getByTagName($r->tags,'nraplica') ?>" />								  
  								  <input type="hidden" id="dtmvtolt" name="dtmvtolt" value="<? echo getByTagName($r->tags,'dtmvtolt') ?>" />								  
  								  <input type="hidden" id="tpemiext" name="tpemiext" value="<? echo getByTagName($r->tags,'tpemiext') ?>" />								  
  								  <input type="hidden" id="tpaplica" name="tpaplica" value="<? echo getByTagName($r->tags,'tpaplica') ?>" />								  

						</td>
						<td><span><? echo getByTagName($r->tags,'descapli'); ?></span>
							      <? echo getByTagName($r->tags,'descapli'); ?>
						</td>
						<td><span><? echo getByTagName($r->tags,'nraplica'); ?></span>
							      <? echo mascara(getByTagName($r->tags,'nraplica'),'#.###.###'); ?>
						</td>
						<td><span><? echo dataParaTimestamp(getByTagName($r->tags,'dtmvtolt')); ?></span>
							      <? echo getByTagName($r->tags,'dtmvtolt'); ?>
						</td>
						<td><span><? echo getByTagName($r->tags,'tpemiext'); ?>  <? echo getByTagName($r->tags,'dsemiext'); ?></span>
							      <? echo getByTagName($r->tags,'tpemiext'); ?>  <? echo getByTagName($r->tags,'dsemiext'); ?>
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
	<a href="#" class="botao" id="btVoltar" onclick="btnVoltar(); return false;">Voltar</a>
	<a href="#" class="botao" id="btAlterar" onclick="selecionaAplicacao('A'); return false;">Alterar</a>
	<a href="#" class="botao" id="btTodas" onclick="selecionaAplicacao('T');  return false;"> Todas</a>
</div>

