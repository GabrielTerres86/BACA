<?php
/* * *********************************************************************

  Fonte: form_tarifas.php
  Autor: Jonathan - RKAM
  Data : Marco/2016                       Última Alteração:

  Objetivo  : Mostrar tabela de tarifas.

  Alterações: 
  

 * ********************************************************************* */

 session_start();
 require_once('../../includes/config.php');
 require_once('../../includes/funcoes.php');
 require_once('../../includes/controla_secao.php');		
 require_once('../../class/xmlfile.php');
 isPostMethod();	

?>


<form id="frmTarifas" name="frmTarifas" class="formulario">	

	<fieldset>

		<legend> <? echo utf8ToHtml('Informa&ccedil;&otilde;es das Tarifas')?>  </legend>

			<div id="divRegistros" class="divRegistros">
		
				<table>
					<thead>
						<tr>
							<th>C&oacute;digo</th>
							<th>Descri&ccedil;&atilde;o</th>
							<th>Tipo</th>
							<th>Valor</th>
							<th>Hist&oacute;rico</th>
						</tr>
					</thead>
					<tbody>
						<?php
						if ( count($tarifas) == 0 ) {
							$i = 0;							
							
							?> <tr>			
									<b>Nenhuma tarifa encontrada.</b>																			
								</tr>							
						<?	// Caso a pesquisa retornou itens, exibílos em diversas linhas da tabela
						} else {
							 for($i = 0; $i < count($tarifas); $i++){?>
								
								<script type="text/javascript">

									var regTarifa = new Object();
									regTarifa["cdocorre"] = "<? echo getByTagName($tarifas[$i]->tags,'cdocorre'); ?>";	
									regTarifa["tpocorre"] = "<? echo getByTagName($tarifas[$i]->tags,'tpocorre'); ?>";
									regTarifa["vltarifa"] = "<? echo getByTagName($tarifas[$i]->tags,'vltarifa'); ?>";
									regTarifa["cdtarhis"] = "<? echo getByTagName($tarifas[$i]->tags,'cdtarhis'); ?>";

								</script>

								<tr id="<? echo getByTagName($tarifas[$i]->tags,'cdocorre').getByTagName($tarifas[$i]->tags,'tpocorre'); ?>">	
									<td><span><? echo getByTagName($tarifas[$i]->tags,'cdocorre'); ?></span> <? echo getByTagName($tarifas[$i]->tags,'cdocorre'); ?> </td>
									<td><span><? echo getByTagName($tarifas[$i]->tags,'dsocorre'); ?></span> <? echo getByTagName($tarifas[$i]->tags,'dsocorre'); ?> </td>
									<td><span><? echo getByTagName($tarifas[$i]->tags,'tpocorre'); ?></span> <? if(getByTagName($tarifas[$i]->tags,'tpocorre') == 1 ){echo "REM";}else{echo "RET";} ?> </td>
									<td><span><? echo getByTagName($tarifas[$i]->tags,'vltarifa'); ?></span> <input type="text" id="vltarifa" name="vltarifa" value="<?php echo number_format(str_replace(",",".",getByTagName($tarifas[$i]->tags,'vltarifa')),2,",",".");?>" /> </td>
									<td><span><? echo getByTagName($tarifas[$i]->tags,'cdtarhis'); ?></span> <input type="text" id="cdtarhis" name="cdtarhis" value="<?php echo getByTagName($tarifas[$i]->tags,'cdtarhis');?>" /> </td>
								
									<input type="hidden" id="cddbanco" name="cddbanco" value="<? echo getByTagName($tarifas[$i]->tags,'cddbanco'); ?>" />					
									<input type="hidden" id="nrconven" name="nrconven" value="<? echo getByTagName($tarifas[$i]->tags,'nrconven'); ?>" />					
									<input type="hidden" id="cdocorre" name="cdocorre" value="<? echo getByTagName($tarifas[$i]->tags,'cdocorre'); ?>" />	

								</tr>

								<script type="text/javascript">

									tarifa["<? echo getByTagName($tarifas[$i]->tags,'cdocorre').getByTagName($tarifas[$i]->tags,'tpocorre'); ?>"] = regTarifa;
								
								</script>

							<?}?>

						<?}?>			

					</tbody>	
				</table>
			</div>
			<div id="divRegistrosRodape" class="divRegistrosRodape">
				<table>	
					<tr>
						<td>
							<?if (isset($qtregist) and count($qtregist) == 0) $nriniseq = 0;
							if ($nriniseq > 1) {
								?> <a class='paginacaoAnt'><<< Anterior</a> <?
							} else {
								?> &nbsp; <?
							}?>
						</td>
						<td>
							<? if (isset($nriniseq)) { ?>
								   Exibindo <? echo $nriniseq; ?> at&eacute; <? if (($nriniseq + $nrregist) > $qtregist) { echo $qtregist; } else { echo ($nriniseq + $nrregist - 1); } ?> de <? echo $qtregist; ?>
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

<div id="divBotoesTarifas" style="margin-top:5px; margin-bottom :10px; text-align: center;">	

	<a href="#" class="botao" id="btVoltar" onClick="controlaVoltar('2');" >Voltar</a>
		
	<?php if($cddopcao == 'A' || $cddopcao == 'I'){?>		
		<a href="#" class="botao" id="btAlteraMotivo" >Alterar Motivo</a>	
		<a href="#" class="botao" id="btConcluir" onClick="controlaConcluirTarifa();">Concluir</a>
	<?}else if($cddopcao == 'C'){?>
	    <a href="#" class="botao" id="btConsultaMotivo" >Consultar Motivo</a>	
	<?}?>
		
</div>						

<script text="text/javascript">

	$('a.paginacaoAnt').unbind('click').bind('click', function() {
		
		buscaTarifas('<? echo ($nriniseq - $nrregist)?>','<?php echo $nrregist?>','<?php echo $nrconven?>','<?php echo $cddbanco?>');
		
    });

	$('a.paginacaoProx').unbind('click').bind('click', function() {
		
		atualizaArrayTarifa();
		buscaTarifas('<? echo ($nriniseq + $nrregist)?>','<?php echo $nrregist?>','<?php echo $nrconven?>','<?php echo $cddbanco?>');
		
	});	

	$('#divRegistrosRodape','#divTarifas').formataRodapePesquisa();	
	formataTabelaTarifas();	
	$('#divBotoesCadcco').css('display','none');
	$('#divTarifas').css('display','block');
	
</script>
		