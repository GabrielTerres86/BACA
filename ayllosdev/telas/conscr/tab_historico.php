<? 
/*!
 * FONTE        : tab_historico.php
 * CRIAÇÃO      : Rogérius Militao - (DB1)
 * DATA CRIAÇÃO : 01/12/2011 
 * OBJETIVO     : Tabela que apresenta a consulta HISTORICO da tela CONSCR
 * --------------
 * ALTERAÇÕES   :
 * 001: 21/01/2013 - Daniel (CECRED) : Implantacao novo layout.
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

<form id="frmHistorico" class="formulario">

	<fieldset>
	<legend> <? echo utf8ToHtml('Histórico');  ?> </legend>

	<div class="divRegistros">	
		<table class="tituloRegistros">
			<thead>
				<tr>
					<th><? echo utf8ToHtml('Data Base'); ?></th>
					<th><? echo utf8ToHtml('Op. SFN');  ?></th>
					<th><? echo utf8ToHtml('Observação');  ?></th>
				</tr>
			</thead>
			<tbody>
				<?
				foreach ( $registro as $r ) { 
				?>
					<tr>
						<td><span><? echo getByTagName($r->tags,'dtrefere'); ?></span>
							      <? echo getByTagName($r->tags,'dtrefere'); ?>
 						</td>
						
						<td><span><? echo converteFloat(getByTagName($r->tags,'vlvencto')); ?></span>
							      <? echo formataMoeda(getByTagName($r->tags,'vlvencto')) ?>
						</td>
						<td><span><? echo getByTagName($r->tags,'dsdbacen'); ?></span>
							      <? echo stringTabela(getByTagName($r->tags,'dsdbacen'),45,'maiuscula'); ?>
						</td>
					</tr>
			<? } ?>	
			</tbody>
		</table>
	</div>
	</fieldset>
	
</form>

<!-- <div id="divMsgAjuda">
	<span><? /* echo utf8ToHtml('Clique no botão VOLTAR para sair!.'); */?></span> -->

	<div id="divBotoes" style="margin-bottom:10px">
		<a href="#" class="botao" id="btVoltar" onclick="fechaOpcao(); return false;" >Voltar</a>
	</div>

<!-- </div>		-->															

