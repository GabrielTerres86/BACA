<? 
/*!
 * FONTE        : tab_modalidade_detalhe.php
 * CRIAÇÃO      : Rogérius Militao - (DB1)
 * DATA CRIAÇÃO : 05/12/2011 
 * OBJETIVO     : Tabela que apresenta o DETALHE da MODALIDADE da tela CONSCR
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

<form id="frmModalidadeDetalhe" class="formulario">

	<fieldset>
	<legend> <? echo utf8ToHtml('Submodalidade ');  ?> </legend>

	<label for="cdmodali">Modalidade Principal:</label>
	<input type="text" id="cdmodali" name="cdmodali" value="<?php echo $cdmodali ?>" />
	<input type="text" id="dsmodali" name="dsmodali" value="<?php echo $dsmodali ?>" />								  
	
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
  								  <input type="hidden" id="cdsubmod" name="cdsubmod" value="<? echo getByTagName($r->tags,'cdmodali') ?>" />								  
								  
 						</td>
						<td><span><? echo getByTagName($r->tags,'dssubmod'); ?></span>
							      <? echo stringTabela(getByTagName($r->tags,'dssubmod'),37,'maiuscula'); ?>
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
	<span>Clique para visualizar os vencimentos.</span> -->

	<div id="divBotoes" style="margin-bottom:10px">
		<a href="#" class="botao" id="btVoltar" onclick="operacao='modalidade'; buscaOpcao(); return false;" >Voltar</a>
	</div>

<!-- </div>	-->																

