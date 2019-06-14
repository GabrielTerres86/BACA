<? 
/*!
 * FONTE        : tab_contas_antigas_demitidas.php						Última alteração: 05/12/2017  
 * CRIAÇÃO      : Jonata - RKAM
 * DATA CRIAÇÃO : Novembro/2017
 * OBJETIVO     : Tabela que apresenta as contas antigas demitidas da opção "H" da tela MATRIC
 * --------------
 * ALTERAÇÕES   : 05/12/2017 - Retirado tratamento para format de valor (Jonata - RKAM P364).
                    
 * --------------
 */ 

 	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');	
	require_once('../../class/xmlfile.php');
	isPostMethod();	
?>

<form id="frmContasAntigasDemitidas" name="frmContasAntigasDemitidas" class="formulario">

	<fieldset id="fsetContasAntigasDemitidas" name="fsetContasAntigasDemitidas" style="padding:0px; margin:0px; padding-bottom:10px;">
		
		<legend><? echo "Contas"; ?></legend>
		
		<div class="divRegistros">		
			<table>
				<thead>
					<tr>
						
					    <th>Conta</th>
						<th>Nome</th>
						<th>Valor</th>	
						<th>Tipo</th>						
						<th><input type="checkbox" name="marcaTodos" id="marcaTodos" onClick="marcaDesmarcaTodos(<?php echo $qtdContas; ?>,'2');">Pago</th>
				</thead>
				<tbody>
					<? for ($i = 0; $i < $qtdContas; $i++) {    ?>
					
						<script type="text/javascript">
							objContasAntigasDemitidas = new Object();						
							objContasAntigasDemitidas.auxidres = "<?php echo $i; ?>";
							objContasAntigasDemitidas.cooperativa = "<?php echo getByTagName($registros[$i]->tags,'cdcooper'); ?>";
							objContasAntigasDemitidas.nrdconta = "<?php echo getByTagName($registros[$i]->tags,'nrdconta'); ?>";
							objContasAntigasDemitidas.tpdevolucao = "<?php echo getByTagName($registros[$i]->tags,'tpdevolucao'); ?>";
							lstContasAntigasDemitidas[<?php echo $i; ?>] = objContasAntigasDemitidas;
						</script>
						
						<tr>								
							
							<td><span><? echo formataContaDV(getByTagName($registros[$i]->tags,'nrdconta')); ?></span><? echo formataContaDV(getByTagName($registros[$i]->tags,'nrdconta')); ?>
							<td><span><? echo getByTagName($registros[$i]->tags,'nmprimtl'); ?></span> <? echo getByTagName($registros[$i]->tags,'nmprimtl'); ?> </td>
							<td><span><? echo getByTagName($registros[$i]->tags,'vlcapital'); ?></span><? echo getByTagName($registros[$i]->tags,'vlcapital'); ?>
							<td><span><? echo getByTagName($registros[$i]->tags,'dscdevolucao'); ?></span> <? echo getByTagName($registros[$i]->tags,'dscdevolucao'); ?> </td>
							<td><input type="checkbox" name="conta<?php echo $i;?>" id="conta<?php echo $i;?>" onchange="selecionaContas('<?php echo $i;?>','2');" ></td>
							
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
							   Exibindo <? echo $nriniseq; ?> at&eacute; <? if (($nriniseq + $nrregist) > $qtregist) { echo $qtregist; } else { echo ($nriniseq + $nrregist - 1); } ?> de <? echo $qtregist; ?> / Total: <? echo $vlrtotal; ?>
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

<div id="divBotoesContasAntigasDemitidas" style='text-align:center; margin-bottom: 10px; margin-top: 10px; display:block;'>
																			
	<a href="#" class="botao" id="btVoltar" onClick="controlaVoltar('1'); return false;">Voltar</a>		
	<a href="#" class="botao" id="btConcluir">Concluir</a>	
		   																			
</div>


<script type="text/javascript">
	
	$('a.paginacaoAnt','#frmContasAntigasDemitidas').unbind('click').bind('click', function() {
		
		buscarContasAntigasDemitidas('<? echo ($nriniseq - $nrregist)?>','<?php echo $nrregist?>');
		
    });

	$('a.paginacaoProx','#frmContasAntigasDemitidas').unbind('click').bind('click', function() {
		
		buscarContasAntigasDemitidas('<? echo ($nriniseq + $nrregist)?>','<?php echo $nrregist?>');
		
	});	

	//Define ação para CLICK no botão de Concluir
    $("#btConcluir", "#divBotoesContasAntigasDemitidas").unbind('click').bind('click', function () {
		
		if (lstContasAntigasDemitidas.length > 0) {
			
			showConfirmacao('Deseja confirmar opera&ccedil;&atilde;o?', 'Confirma&ccedil;&atilde;o - Aimaro', 'mostrarRotina(\'LCH\');', '$(\'#btVoltar\',\'#divBotoesContasAntigasDemitidas\').focus();', 'sim.gif', 'nao.gif');
		    		
		}
		
        return false;

    });

	$('#divRegistrosRodape','#frmContasAntigasDemitidas').formataRodapePesquisa();
	
	$('#marcaTodos','#frmContasAntigasDemitidas').click();	
	
	$('#divBotoesFiltroContaAntigasDemitidas').css('display', 'none');
	
	formataTabelaContasAntigasDemitidas();	
	
				
</script>