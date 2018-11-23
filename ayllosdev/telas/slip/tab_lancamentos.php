<?php
	/*!
    * FONTE        : tab_lancamentos.php
	* CRIAÇÃO      : Alcemir Junior - Mout's
	* DATA CRIAÇÃO : 10/10/2018
	* OBJETIVO     : form para a inclusao de lançamento da tela SLIP
	* --------------
	* ALTERAÇÕES   :
	* --------------
	*/
	
 	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();
?>

    		
<div id="tabIncLancamento" style="display:block">
	<fieldset id="fsTabIncLancamento">	
	<legend><? echo utf8ToHtml("Lista De lançamentos nesta data") ?></legend>			    	

		<div class="divRegistros" style="display:block" >	
			

			<table class="tituloRegistros" id="tbLancamento">
				<thead>								
					<tr>														
						<th><? echo utf8ToHtml("Seq. Slip");?></th>								
						<th><? echo utf8ToHtml("Hist. Ailos:");?></th>								
						<th><? echo utf8ToHtml("Conta Débito");?></th>								
						<th><? echo utf8ToHtml("Conta Crédito");?></th>																
						<th><? echo utf8ToHtml("Vlr. Lanc.");?></th>	
						<th><? echo utf8ToHtml("Hist. Padrão");?></th>																							
					</tr>								
				</thead>
				<tbody>

					<? $cont_id = 0;
					for ($i = 0; $i < count($lancamentos); $i++) {
					?>
						<tr>							
							<td><span><? echo getByTagName($lancamentos[$i]->tags,'nrseq_slip'); ?></span>
									  <? echo getByTagName($lancamentos[$i]->tags,'nrseq_slip'); ?>
							</td>
							<td><span><? echo getByTagName($lancamentos[$i]->tags,'cdhistor'); ?></span>
									  <? echo getByTagName($lancamentos[$i]->tags,'cdhistor'); ?>
							</td>
							<td><span><? echo getByTagName($lancamentos[$i]->tags,'nrctadeb'); ?></span>
									  <? echo getByTagName($lancamentos[$i]->tags,'nrctadeb'); ?>
							</td>
							<td><span><? echo getByTagName($lancamentos[$i]->tags,'nrctacrd'); ?></span>
									  <? echo getByTagName($lancamentos[$i]->tags,'nrctacrd'); ?>
							</td>

							<td><span><? echo getByTagName($lancamentos[$i]->tags,'vllanmto'); ?></span>
									  <? echo formataMoeda(getByTagName($lancamentos[$i]->tags,'vllanmto')); ?>
							</td>
							
							<td><span><? echo getByTagName($lancamentos[$i]->tags,'cdhistor_padrao'); ?></span>
									  <? echo getByTagName($lancamentos[$i]->tags,'cdhistor_padrao'); ?>
							</td>

				<input type="hidden" id="nrseq_sliph" name="nrseq_sliph" value="<? echo getByTagName($lancamentos[$i]->tags,'nrseq_slip'); ?>" /> 
				<input type="hidden" id="cdhistorh" name="cdhistorh" value="<? echo getByTagName($lancamentos[$i]->tags,'cdhistor'); ?>" /> 
		        <input type="hidden" id="nrctadebh" name="nrctadebh" value="<? echo getByTagName($lancamentos[$i]->tags,'nrctadeb'); ?>" /> 
				
				<input type="hidden" id="nrctacrdh" name="nrctacrdh" value="<? echo getByTagName($lancamentos[$i]->tags,'nrctacrd'); ?>" /> 
				<input type="hidden" id="cdhistorh" name="cdhistorh" value="<? echo getByTagName($lancamentos[$i]->tags,'cdhistor'); ?>" /> 
		        <input type="hidden" id="vllanmtoh" name="vllanmtoh" value="<? echo formataMoeda(getByTagName($lancamentos[$i]->tags,'vllanmto')); ?>" /> 
				<input type="hidden" id="cdhistor_padraoh" name="cdhistor_padraoh" value="<? echo getByTagName($lancamentos[$i]->tags,'cdhistor_padrao'); ?>" /> 	




			    <input type="hidden" id="dslancamentoh" name="dslancamentoh" value="<? echo getByTagName($lancamentos[$i]->tags,'dslancamento'); ?>" /> 
				<input type="hidden" id="cdoperadh" name="cdoperadh" value="<? echo getByTagName($lancamentos[$i]->tags,'cdoperad'); ?>" /> 
		        <input type="hidden" id="dsoperadorh" name="dsoperadorh" value="<? echo getByTagName($lancamentos[$i]->tags,'dsoperador'); ?>" /> 



					
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

		
		<fieldset id="fsTabIncLancamentot" style="vertical-align: bottom;">			    				
			
			<label for="dslancamentot"><? echo utf8ToHtml("Descrição:") ?></label>
			<input name="dslancamentot" type="text"  id="dslancamentot"  style="width: 380px;">
			<br style="clear:both" />
			<label for="dsoperador"><? echo utf8ToHtml("Operador:") ?></label>
			<input name="dsoperador" type="text"  id="dsoperador"  style="width: 380px;">
			
		</fieldset>

	</fieldset>	
</div>	        


<script type="text/javascript">

	$('label[for="dslancamentot"]',"#frmIncLancamento").css({"width":"68px"});
	$("#dslancamentot","#frmIncLancamento").addClass("campoTelaSemBorda").attr("maxlength","240").css({"width":"420px"}).desabilitaCampo();
	
	$('label[for="dslancamentot"]',"#frmConLancamento").css({"width":"68px"});
	$("#dslancamentot","#frmConLancamento").addClass("campoTelaSemBorda").attr("maxlength","240").css({"width":"420px"}).desabilitaCampo();
	
	$('label[for="dsoperador"]',"#frmIncLancamento").css({"width":"68px"});
	$("#dsoperador","#frmIncLancamento").addClass("campoTelaSemBorda").attr("maxlength","230").css({"width": "300px"}).desabilitaCampo();
	
	
	$('label[for="dsoperador"]',"#frmConLancamento").css({"width":"68px"});
	$("#dsoperador","#frmConLancamento").addClass("campoTelaSemBorda").attr("maxlength","230").css({"width":"300px"}).desabilitaCampo();
	

	$('a.paginacaoAnt').unbind('click').bind('click', function() {

		<?	
		if ($tipbusca == "C"){?>
			reqConsultaLanc(<? echo ($nriniseq - $nrregist)?>,<? echo $nrregist?>);
		<?}else{?>
			buscaLancamentosDia(<? echo ($nriniseq - $nrregist)?>,<? echo $nrregist?>);
		<?}?>
	
	
		
	});

	$('a.paginacaoProx').unbind('click').bind('click', function() {
		
		<?	
		if ($tipbusca == "C"){?>
			reqConsultaLanc(<? echo ($nriniseq + $nrregist)?>,<?php echo $nrregist?>);
		<?}else{?>
			buscaLancamentosDia(<? echo ($nriniseq + $nrregist)?>,<?php echo $nrregist?>);
		<?}?>
						
	});	
	
	$('#divRegistrosRodape','#tabIncLancamento').formataRodapePesquisa();
	
	//formatarTabelaLanc();
	
//	formataFormularios();
//	controlaLayout("1");		
			
</script>
	    	

