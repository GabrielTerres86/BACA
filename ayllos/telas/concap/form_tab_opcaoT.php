<? 
/*!
 * FONTE        : form_tab_opcaoT.php
 * CRIAÇÃO      : Lucas R.
 * DATA CRIAÇÃO : Novembro/2013 
 * OBJETIVO     : Tabela com os dados da Consulta do CONCAP
 * --------------
 * ALTERAÇÕES   : 
 * 001: 29/01/2014 - Incluir campo Data Resgate quando for opção Resgates Futuros (David)
 * --------------
 */	
 ?>
 
<form id="frmTabOpcaoT" class="frmTabOpcaoT" name="frmTabOpcaoT">
<div class="divRegistros" >	
	<table>
		<thead>
		<tr><th>PA</th>
			<th>Conta/dv</th>
			<th align="left">Nome</th>
			<th>Aplicação</th>
			<th>Valor Aplicação</th>
			<th>Operador</th>
			<?php if ($opcaoimp == "F") { ?>
			<th>Data Resgate</th>
			<?php } ?>
		</tr>			
		</thead>
		<tbody> 
			<? foreach( $dados as $banco) { $conta++; ?>
				<tr> 
					<td id="cdagetel" ><span><?php echo getByTagName($banco->tags,'cdagenci'); ?></span>
							<?php echo getByTagName($banco->tags,'cdagenci'); ?>
					</td>
					<td id="nrdconta" ><span><?php echo formataContaDV(getByTagName($banco->tags,'NRDCONTA')); ?></span>
							<?php echo formataContaDV(getByTagName($banco->tags,'NRDCONTA')); ?>
					</td>
					<td id="nmprimtl" ><span><?php echo getByTagName($banco->tags,'nmprimtl'); ?></span>
							<?php echo getByTagName($banco->tags,'nmprimtl'); ?>
					</td>						
					<td id="nraplica" ><span><?php echo getByTagName($banco->tags,'nraplica'); ?></span>
						    <?php echo mascara(getByTagName($banco->tags,'nraplica'),'####.###'); ?>							 
					</td>
					<td id="vlaplica" ><span><?php echo number_format(str_replace(",",".",getByTagName($banco->tags,'vlaplica')),2,",","."); ?></span>
							<?php echo number_format(str_replace(",",".",getByTagName($banco->tags,'vlaplica')),2,",","."); ?>
					</td>	
					<td id="cdoperad" ><span><?php echo getByTagName($banco->tags,'cdoperad'); ?></span>
							<?php echo getByTagName($banco->tags,'cdoperad') != '' ? substr(getByTagName($banco->tags,'cdoperad').' - '.getByTagName($banco->tags,'nmoperad'),0,24) : ''; ?>
					</td>											
					<?php if ($opcaoimp == "F") { ?>
					<td id="dtresgat" ><span><?php echo getByTagName($banco->tags,'dtresgat'); ?></span>
							<?php echo getByTagName($banco->tags,'dtresgat'); ?>					
					</td>
					<?php } ?>
				</tr>												
			<? } ?>			
		</tbody>		
	</table>
	<input type="hidden" id="qtdreg" name="qtdreg" value="<? echo $conta; ?>" />
</div>
</form>

<div id="divPesquisaRodape" class="divPesquisaRodape">
		<table>	
			<tr>
				<td>
					<?
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
		consultar(<? echo "'".($nriniseq - $nrregist)."','".$nrregist."'"; ?>);
	});
	
	$('a.paginacaoProx').unbind('click').bind('click', function() {
		consultar(<? echo "'".($nriniseq + $nrregist)."','".$nrregist."'"; ?>);
	});	
</script>