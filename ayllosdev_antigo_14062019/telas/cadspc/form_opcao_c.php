<? 
/*!
 * FONTE        : form_opcao_c.php
 * CRIAÇÃO      : Rogérius Militao - (DB1)
 * DATA CRIAÇÃO : 06/03/2012 
 * OBJETIVO     : Formulario que apresenta a opcao C da tela CADSPC
 * --------------
 * ALTERAÇÕES   : 13/08/2013 - Alteração da sigla PAC para PA. (Carlos)
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

<form id="frmOpcao" class="formulario" onSubmit="return false;">

	<fieldset>
	<legend> <? echo utf8ToHtml('Informações'); ?> </legend>

	<div class="divRegistros">	
		<table class="tituloRegistros">
			<thead>
				<tr>
					<th><? echo utf8ToHtml('Ide'); ?></th>
					<th><? echo utf8ToHtml('Contrato'); ?></th>
					<th><? echo utf8ToHtml('Ctr.SPC');  ?></th>
					<th><? echo utf8ToHtml('Vencimen.');  ?></th>
					<th><? echo utf8ToHtml('Divida');  ?></th>
					<th><? echo utf8ToHtml('Inclusao');  ?></th>
					<th><? echo utf8ToHtml('Baixa');  ?></th>
					<th><? echo utf8ToHtml('Insti.');  ?></th>
				</tr>
			</thead>
			<tbody>
				<?
				foreach ( $registro as $r ) { 
				?>
					<tr>
						<td><span><? echo getByTagName($r->tags,'dsidenti'); ?></span>
							      <? echo getByTagName($r->tags,'dsidenti'); ?>
								  <input type="hidden" id="nmprimtl" name="nmprimtl" value="<? echo getByTagName($r->tags,'nmprimtl') ?>" />								  
								  <input type="hidden" id="cdagenci" name="cdagenci" value="<? echo getByTagName($r->tags,'cdagenci') ?> - <? echo getByTagName($r->tags,'nmresage') ?>" />								  
								  
						</td>
						<td><span><? echo getByTagName($r->tags,'nrctremp'); ?></span>
							      <? echo mascara(getByTagName($r->tags,'nrctremp'),'##.###.###'); ?>
						</td>
						<td><span><? echo getByTagName($r->tags,'nrctrspc'); ?></span>
							      <? echo getByTagName($r->tags,'nrctrspc'); ?>
						</td>
						<td><span><? echo dataParaTimestamp(getByTagName($r->tags,'dtvencto')); ?></span>
							      <? echo getByTagName($r->tags,'dtvencto'); ?>
						</td>
						<td><span><? echo getByTagName($r->tags,'vldivida'); ?></span>
							      <? echo formataMoeda(getByTagName($r->tags,'vldivida')); ?>
						</td>
						<td><span><? echo dataParaTimestamp(getByTagName($r->tags,'dtinclus')); ?></span>
							      <? echo getByTagName($r->tags,'dtinclus'); ?>
						</td>
						<td><span><? echo dataParaTimestamp(getByTagName($r->tags,'dtdbaixa')); ?></span>
							      <? echo getByTagName($r->tags,'dtdbaixa'); ?>
						</td>
						<td><span><? echo getByTagName($r->tags,'dsinsttu'); ?></span>
							      <? echo getByTagName($r->tags,'dsinsttu'); ?>
						</td>
					</tr>
			<? } ?>	
			</tbody>
		</table>
	</div>
	
	<div id="divPesquisaRodape" class="divPesquisaRodape">
		<table>	
			<tr>
				<td>
					<?
						
						//
						if (isset($qtregist) and $qtregist == 0) $nriniseq = 0;
						
						// Se a paginação não está na primeira, exibe botão voltar
						if ($nriniseq > 1) { 
							?> <a class='paginacaoAnt'><<< Anterior</a> <? 
						} else {
							?> &nbsp; <?
						}
					?>
				</td>
				<td>
					<?
						if (isset($nriniseq)) { 
							?> Exibindo <? echo $nriniseq; ?> at&eacute; <? if (($nriniseq + $nrregist) > $qtregist) { echo $qtregist; } else { echo ($nriniseq + $nrregist - 1); } ?> de <? echo $qtregist; ?><?
						}
					?>
				</td>
				<td>
					<?
						// Se a paginação não está na &uacute;ltima página, exibe botão proximo
						if ($qtregist > ($nriniseq + $nrregist - 1)) {
							?> <a class='paginacaoProx'>Pr&oacute;ximo >>></a> <?
						} else {
							?> &nbsp; <?
						}
					?>			
				</td>
			</tr>
		</table>
	</div>
	
	<div id="linha1">
	<ul class="complemento">
	<li><? echo utf8ToHtml('Nome:'); ?></li>
	<li id="nmprimtl"></li>
	<li><? echo utf8ToHtml('PA:'); ?></li>
	<li id="cdagenci"></li>
	</ul>
	</div>

	
	</fieldset>

</form>




<script type="text/javascript">

	$('a.paginacaoAnt').unbind('click').bind('click', function() {
		controlaOperacao(<? echo "'".($nriniseq - $nrregist)."','".$nrregist."'"; ?>);
	});
	$('a.paginacaoProx').unbind('click').bind('click', function() {
		controlaOperacao(<? echo "'".($nriniseq + $nrregist)."','".$nrregist."'"; ?>);
	});	
	
	$('#divPesquisaRodape','#divTela').formataRodapePesquisa();

</script>