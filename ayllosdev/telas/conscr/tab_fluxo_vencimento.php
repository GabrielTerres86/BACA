<? 
/*!
 * FONTE        : tab_fluxo.php
 * CRIAÇÃO      : Rogérius Militao - (DB1)
 * DATA CRIAÇÃO : 05/12/2011 
 * OBJETIVO     : Tabela que apresenta o VENCIMENTO do fluxo da tela CONSCR
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

<form id="frmFluxoVencimento" class="formulario">

	<fieldset>
	<legend> <? echo utf8ToHtml('Vencimentos');  ?> </legend>

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


<!--<div id="divMsgAjuda">
	<span><? /* echo utf8ToHtml('Clique no botão VOLTAR para sair!.'); */?></span> -->

	<div id="divBotoes" style="margin-bottom:10px">
		<a href="#" class="botao" id="btVoltar" onclick="buscaOpcao(); return false;" >Voltar</a>
	</div>

<!--</div>			-->														
