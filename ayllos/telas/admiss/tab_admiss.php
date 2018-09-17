<?php
/*!
 * FONTE        : tab_admiss.php
 * CRIAÇÃO      : Lucas Lunelli
 * DATA CRIAÇÃO : 26/07/2013
 * OBJETIVO     : Tabela que apresenda os cooperados admitidos na tela ADMISS
 *
 * ALTERACOES	: 29/07/2016 - Corrigi o uso desnecessario da funcao session_start. SD 491672 (Carlos R.)
 */	
 
require_once('../../includes/config.php');
require_once('../../includes/funcoes.php');
require_once('../../includes/controla_secao.php');	
require_once('../../class/xmlfile.php');
isPostMethod();	
 
?>
<div id="tabAdmissMes">
	<div class="divRegistros">	
		<table class="tituloRegistros">
			<thead>
				<tr>
					<th>PA</th>
					<th>Conta/DV</th>
					<th>Matr&iacute;cula</th>
					<th>Nome</th>
				</tr>
			</thead>
			<tbody>
							
				<? 
				foreach($registros as $i) {
				
					$cdagenci	= getByTagName($i->tags,'cdagenci');
					$nrdconta 	= formataContaDV(getByTagName($i->tags,'nrdconta'));
					$nrmatric	= getByTagName($i->tags,'nrmatric');
					$nmprimtl	= getByTagName($i->tags,'nmprimtl');			
												
				?>			
					<tr>
						<td><span><? echo $cdagenci; ?></span>
								  <? echo $cdagenci; ?>
						</td>
						<td><span><? echo $nrdconta; ?></span>
								  <? echo $nrdconta; ?>
						</td>                      
						<td><span><? echo $nrmatric; ?></span>
								  <? echo $nrmatric; ?>
						</td>                      
						<td><span><? echo $nmprimtl; ?></span>
								  <? echo $nmprimtl; ?>
						</td>
					</tr>
			<? } ?>	
			</tbody>
		</table>
	</div>	
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

<script type="text/javascript">

	$('a.paginacaoAnt').unbind('click').bind('click', function() {
		controlaOperacao(<? echo "'".($nriniseq - $nrregist)."','".$nrregist."'"; ?>);
	});
	$('a.paginacaoProx').unbind('click').bind('click', function() {
		controlaOperacao(<? echo "'".($nriniseq + $nrregist)."','".$nrregist."'"; ?>);
	});	
	
	$('#divPesquisaRodape','#divTela').formataRodapePesquisa();

</script>
