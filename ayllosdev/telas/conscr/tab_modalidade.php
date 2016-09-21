<? 
/*!
 * FONTE        : tab_modalidade.php
 * CRIAÇÃO      : Rogérius Militao - (DB1)
 * DATA CRIAÇÃO : 05/12/2011 
 * OBJETIVO     : Tabela que apresenta a MODALIDADE da tela CONSCR
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

<form id="frmModalidade" class="formulario">

	<fieldset>
	<legend> <? echo utf8ToHtml('Modalidades');  ?> </legend>

	<div class="divRegistros">	
		<table class="tituloRegistros">
			<thead>
				<tr>
					<th><? echo utf8ToHtml('Cod.'); ?></th>
					<th><? echo utf8ToHtml('Descrição');  ?></th>
					<th><? echo utf8ToHtml('Valor');  ?></th>
				</tr>
			</thead>
			<tbody>
				<?
				foreach ( $registro as $r ) { 
				?>
					<tr>
						<td><span><? echo getByTagName($r->tags,'cdmodali'); ?></span>
							      <? echo getByTagName($r->tags,'cdmodali'); ?>
  								  <input type="hidden" id="cdmodali" name="cdmodali" value="<? echo getByTagName($r->tags,'cdmodali') ?>" />								  
								  
 						</td>
						<td><span><? echo getByTagName($r->tags,'dsmodali'); ?></span>
							      <? echo stringTabela(getByTagName($r->tags,'dsmodali'),37,'maiuscula'); ?>
						</td>
						<td><span><? echo converteFloat(getByTagName($r->tags,'vlvencto')); ?></span>
							      <? echo formataMoeda(getByTagName($r->tags,'vlvencto')) ?>
						</td>
					</tr>
			<? } ?>	
			</tbody>
		</table>
	</div>
	</fieldset>
	
</form>

<!-- <div id="divMsgAjuda">
	<span>&nbsp;</span> -->

	<div id="divBotoes" style="margin-bottom:10px">
		<a href="#" class="botao" id="btVoltar" onclick="fechaOpcao(); return false;" >Voltar</a>
		<a href="#" class="botao" id="btBotao1" onclick="selecionaModalidade('detalhe'); return false;" >Detalhar Modalidade</a>
		<a href="#" class="botao" id="btBotao2" onclick="selecionaModalidade('vencimento'); return false;" >Detalhar Vencimento</a>
	</div>

<!-- </div>							-->										

