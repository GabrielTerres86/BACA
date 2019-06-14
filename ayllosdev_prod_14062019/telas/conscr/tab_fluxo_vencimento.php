<?php
/*!
 * FONTE        : tab_fluxo.php
	* CRIACAO      : Rogérius Militao - (DB1)
	* DATA CRIACAO : 05/12/2011 
 * OBJETIVO     : Tabela que apresenta o VENCIMENTO do fluxo da tela CONSCR
 * --------------
	* ALTERACOES   :
 * 001: 21/01/2013 - Daniel (CECRED) : Implantacao novo layout.
	* 002: 01/08/2016 - Carlos R. (CECRED) : Corrigi o uso desnecessario da funcao session_start. SD 491672.
 * --------------
 */
 
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');	
	require_once('../../class/xmlfile.php');
	isPostMethod();		
?>

<form id="frmFluxoVencimento" class="formulario">

	<fieldset>
	<legend>Vencimentos</legend>

	<div class="divRegistros">	
		<table class="tituloRegistros">
			<thead>
				<tr>
					<th>Cod.</th>
					<th>Descri&ccedil;&atilde;o</th>
					<th>Valor</th>
				</tr>
			</thead>
			<tbody>
				<?php
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
			<?php } ?>	
			</tbody>
		</table>
	</div>
	</fieldset>
	
</form>

	<div id="divBotoes" style="margin-bottom:10px">
		<a href="#" class="botao" id="btVoltar" onclick="buscaOpcao(); return false;" >Voltar</a>
	</div>

