<? 
/*!
 * FONTE        : tab_contas_demitidas.php						Última alteração:  
 * CRIAÇÃO      : Jonata - RKAM
 * DATA CRIAÇÃO : Junho/2017
 * OBJETIVO     : Tabela que apresenta as contas demitidas da opção "G" da tela MATRIC
 * --------------
 * ALTERAÇÕES   :  14/11/2017 - Ajuste para remoção do botão de concluir (Jonata - RKAM P364).
                    
 * --------------
 */ 

 	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');	
	require_once('../../class/xmlfile.php');
	isPostMethod();	
?>

<form id="frmContasDemitidas" name="frmContasDemitidas" class="formulario">

	<fieldset id="fsetContasDemitidas" name="fsetContasDemitidas" style="padding:0px; margin:0px; padding-bottom:10px;">
		
		<legend><? echo "Contas"; ?></legend>
		
		<div class="divRegistros">		
			<table>
				<thead>
					<tr>
					    <th style="display:none;"><?php echo utf8ToHtml('Sequencia'); ?></th> <!-- campo hidden, utilizado para ordenacao -->
						<th><input type="checkbox" name="marcaTodos" id="marcaTodos" checked onClick="marcaDesmarcaTodos(<?php echo $qtdContas; ?>,'1');"></th>
						<th>Conta</th>
						<th>Nome</th>
						<th>Valor</th>
					</tr>
				</thead>
				<tbody>
					<? for ($i = 0; $i < $qtdContas; $i++) {    ?>
					
						<script type="text/javascript">
							objContasDemitidas = new Object();						
							objContasDemitidas.auxidres = "<?php echo $i; ?>";
							objContasDemitidas.cooperativa = "<?php echo getByTagName($registros[$i]->tags,'cdcooper'); ?>";
							objContasDemitidas.nrdconta = "<?php echo getByTagName($registros[$i]->tags,'nrdconta'); ?>";
							objContasDemitidas.formadev = "<?php echo getByTagName($registros[$i]->tags,'formadev'); ?>";
							objContasDemitidas.qtdparce = "<?php echo getByTagName($registros[$i]->tags,'qtdparce'); ?>";
							objContasDemitidas.datadevo = "<?php echo getByTagName($registros[$i]->tags,'datadevo'); ?>";
							objContasDemitidas.mtdemiss = "<?php echo getByTagName($registros[$i]->tags,'mtdemiss'); ?>";
							objContasDemitidas.dtdemiss = "<?php echo getByTagName($registros[$i]->tags,'dtdemiss'); ?>";
							objContasDemitidas.vldcotas = "<?php echo getByTagName($registros[$i]->tags,'vldcotas'); ?>";
							lstContasDemitidas[<?php echo $i; ?>] = objContasDemitidas;
						</script>
						
						<tr>	
							<td style="display:none;"><span><?php echo $i; ?></span><?php echo $i; ?></td>
							<td><input type="checkbox" name="conta<?php echo $i;?>" id="conta<?php echo $i;?>" onchange="selecionaContas('<?php echo $i;?>','1');" ></td>
							<td><span><? echo formataContaDV(getByTagName($registros[$i]->tags,'nrdconta')); ?></span><? echo formataContaDV(getByTagName($registros[$i]->tags,'nrdconta')); ?>
							<td><span><? echo getByTagName($registros[$i]->tags,'nmprimtl'); ?></span> <? echo getByTagName($registros[$i]->tags,'nmprimtl'); ?> </td>
							<td><span><?php echo str_replace(",",".",getByTagName($registros[$i]->tags,'vldcotas')); ?></span><?php echo number_format(str_replace(",",".",getByTagName($registros[$i]->tags,'vldcotas')),2,",","."); ?>
														
						</tr>	
					<? } ?>
				</tbody>	
			</table>
		</div>
		<div id="divRegistrosRodape" class="divRegistrosRodape">
			<table>	
				<tr>
					<td>
						<? if (isset($qtregist) and $qtregist == 0){ $nriniseq = 0;} ?>
						<? if ($nriniseq > 1){ ?>
							   <a class="paginacaoAnt"><<< Anterior</a>
						<? }else{ ?>
								&nbsp;
						<? } ?>
					</td>
					<td>
						<? if (isset($nriniseq)) { ?>
							   Exibindo <? echo $nriniseq; ?> at&eacute; <? if (($nriniseq + $nrregist) > $qtregist) { echo $qtregist; } else { echo ($nriniseq + $nrregist - 1); } ?> de <? echo $qtregist; ?> / Total: <? echo number_format(str_replace(",",".",$vlrtotal),2,",","."); ?>
							<? } ?>
					</td>
					<td>
						<? if($qtregist > ($nriniseq + $nrregist - 1)) { ?>
							  <a class="paginacaoProx">Pr&oacute;ximo >>></a>
						<? }else{ ?>
								&nbsp;
						<? } ?>
					</td>
				</tr>
			</table>
		</div>	
	</fieldset>
	
</form>

<div id="divBotoesContasDemitidas" style='text-align:center; margin-bottom: 10px; margin-top: 10px; display:block;'>
																			
	<a href="#" class="botao" id="btVoltar" onClick="controlaVoltar('1'); return false;">Voltar</a>																																							
	 
		   																			
</div>


<script type="text/javascript">
	
	$('a.paginacaoAnt','#frmContasDemitidas').unbind('click').bind('click', function() {
		
		buscarContasDemitidas('<? echo ($nriniseq - $nrregist)?>','<?php echo $nrregist?>');
		
    });

	$('a.paginacaoProx','#frmContasDemitidas').unbind('click').bind('click', function() {
		
		buscarContasDemitidas('<? echo ($nriniseq + $nrregist)?>','<?php echo $nrregist?>');
		
	});	

	$('#divRegistrosRodape','#frmContasDemitidas').formataRodapePesquisa();
	
	$('#marcaTodos','#frmContasDemitidas').click();	
	
	
	$('#divBotoesFiltroContasDemitidas').css('display', 'none');
	formataTabelaContasDemitidas();	
	
				
</script>