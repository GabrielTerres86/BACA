<? 
/*!
 * FONTE        : form_impedimentos_desligamento.php
 * CRIAÇÃO      : Lucas Reinert
 * DATA CRIAÇÃO : 25/05/2017
 * OBJETIVO     : Rotina para apresentar todos os produtos ativos que precisam ser cancelados no caso 
 *				  de desligamento do cooperado
 * --------------
 * ALTERAÇÕES   : 14/11/2017 - Ajsute para inclusão de novo item para impedimento (Jonata - RKAM P364).
 * --------------
                  21/11/2017 - Ajuste para controle das mensagens de alerta referente a seguro (Jonata - RKAM P364).
 */
 function formataFlag($valor){
	 if ($valor == 1) return 'Sim'; else return 'N&atilde;o';
 }
 
 
 $produtos = array('3', '8', '10', '15', '16', '38');
?>
<div id="divImpedimentos">
			<form name="frmCancAuto" id="frmCancAuto" class="formulario"  >
				<fieldset>				
					<legend>Cancelamento Autom&aacute;tico</legend>
					<table style="padding-left:0px;width:100%">
							<?foreach( $regServicosObrigatorios as $result ) {
								if (in_array(getByTagName($result->tags,'cdproduto'), $produtos)){
									if(getByTagName($result->tags,'flativo') == 'S'){?>	
										<tr id="<?echo getByTagName($result->tags,'cdproduto');?>">
																
											<td><a style="padding: 0px 0 0 3px;"><img style="width:25px; height:25px;" src="<? echo $UrlImagens; ?>geral/servico_ativo.gif" id="lupaServico" name="lupaServico" /></a></td>
											<td style="text-align:left;width:260px">
												<label><?echo getByTagName($result->tags,'dsproduto');?></label>
											</td>
											<td style="vertical-align: middle">
												<input class="checkbox" type="checkbox" style="margin-top: 0px" id="<?echo getByTagName($result->tags,'cdproduto');?>"/>
											</td>

										</tr>
									<?}?>
								<?}?>
							<?}?>
						</table>
						<table>
							<?foreach( $regServicosOpcionais as $result ) {
								if (in_array(getByTagName($result->tags,'cdproduto'), $produtos)){
									if(getByTagName($result->tags,'flativo') == 'S'){?>	
										<tr id="<?echo getByTagName($result->tags,'cdproduto');?>">
																
											<td><a style="padding: 0px 0 0 3px;"><img style="width:25px; height:25px;" src="<? echo $UrlImagens; ?>geral/servico_ativo.gif" id="lupaServico" name="lupaServico" /></a></td>
											<td style="text-align:left;width:260px">
												<label><?echo getByTagName($result->tags,'dsproduto');?></label>
											</td>
											<td style="vertical-align: middle">
												<input class="checkbox" type="checkbox" style="margin-top: 0px" id="<?echo getByTagName($result->tags,'cdproduto');?>"/>
											</td>

										</tr>
									<?}?>
								<?}?>
							<?}?>
						</table>
						
					</fieldset>
				</form>
				
					
		
			<form name="frmCancManl" id="frmCancManl" class="formulario"  >
				<fieldset>
					<legend>Cancelamento Manual</legend>
					<table style="padding-left:0px;width:100%">
							<tr>
								<td>								
									<label class="checkbox">Empr&eacute;stimos e financiamento</label>
								</td>
								<td>
									<label>R$ <? echo formataMoeda($valor_emprestimos); ?></label>
									<!--<label>R$ <? echo formataMoeda(getByTagName($regServicos2->tags,'vlemprst')); ?></label>-->
								</td>
								<td style="vertical-align: middle">
								<?if (getByTagName($regServicos2->tags,'vlemprst') > 0){?>
									<input class="checkbox" type="checkbox" style="margin-top: 0px" id="1"/>
								<?}?>
								</td>
							</tr>
							<tr>
								<td>								
									<label class="checkbox">Cheque especial</label>
								</td>
								<td>
									<label>R$ <? echo formataMoeda(getByTagName($regServicos2->tags,'vllimpro')); ?></label>
								</td>
								<td style="vertical-align: middle">
								<?if (getByTagName($regServicos2->tags,'vllimpro') > 0){?>
									<input class="checkbox" type="checkbox" style="margin-top: 0px" id="2"/>
								<?}?>
								</td>
							</tr>
							<tr>
								<td>								
									<label class="checkbox">Limite de Descontos</label>
								</td>
								<td>
									<label>R$ <? echo formataMoeda(getByTagName($regServicos2->tags,'vllimdsc')); ?></label>
								</td>
								<td style="vertical-align: middle">
								<?if (getByTagName($regServicos2->tags,'vllimdsc') > 0){?>
									<input class="checkbox" type="checkbox" style="margin-top: 0px" id="3"/>
								<?}?>
								</td>
							</tr>
							<tr>
								<td>								
									<label class="checkbox">Border&ocirc;s</label>
								</td>
								<td>
									<label>R$ <? echo formataMoeda(getByTagName($regServicos2->tags,'vlcompcr')); ?></label>
								</td>
								<td style="vertical-align: middle">
								<?if (getByTagName($regServicos2->tags,'vlcompcr') > 0){?>
									<input class="checkbox" type="checkbox" style="margin-top: 0px" id="4"/>
								<?}?>
								</td>
							</tr>
							<tr>
								<td>								
									<label class="checkbox">Cart&atilde;o Ailos/BB/Bradesco</label>
								</td>
								<td>
									<?if (getByTagName($regServicos2->tags,'vllimcar') > 0){?>
										<label>R$ <? echo formataMoeda(getByTagName($regServicos2->tags,'vllimcar')); ?></label>
									<?}else{?>
										<label><? echo formataFlag(getByTagName($regServicos2->tags,'flgcarta')); ?></label>
									<?}?>
								</td>
								<td style="vertical-align: middle">
							
									<?if (getByTagName($regServicos2->tags,'vllimcar') > 0 || 
								   		  getByTagName($regServicos2->tags,'flgcarta') > 0){?>
										<input class="checkbox" type="checkbox" style="margin-top: 0px" id="5"/>
									<?}?>
								
								</td>
							</tr>
							<tr>
								<td>								
									<label class="checkbox">Resgate da aplica&ccedil;&atilde;o</label>
								</td>
								<td>
									<label>R$ <? echo formataMoeda(getByTagName($regServicos2->tags,'vlresapl')); ?></label>
								</td>
								<td style="vertical-align: middle">
								<?if (getByTagName($regServicos2->tags,'vlresapl') > 0){?>
									<input class="checkbox" type="checkbox" style="margin-top: 0px" id="6"/>
								<?}?>
								</td>
							</tr>
							<tr>
								<td>								
									<label class="checkbox">Resgate da poupan&ccedil;a programada</label>
								</td>
								<td>
									<label>R$ <? echo formataMoeda(getByTagName($regServicos2->tags,'vlsrdrpp')); ?></label>
								</td>
								<td style="vertical-align: middle">
								<?if (getByTagName($regServicos2->tags,'vlsrdrpp') > 0){?>
									<input class="checkbox" type="checkbox" style="margin-top: 0px" id="7"/>
								<?}?>
								</td>
							</tr>
							<tr>
								<td>								
									<label class="checkbox">Pagamento por arquivo</label>
								</td>
								<td>							
									<label><? echo formataFlag(getByTagName($regServicos2->tags,'inarqcbr')); ?></label>							
								</td>
								<td style="vertical-align: middle">
								<?if (getByTagName($regServicos2->tags,'inarqcbr') == 1){?>
									<input class="checkbox" type="checkbox" style="margin-top: 0px" id="8"/>
								<?}?>
								</td>
							</tr>
							<tr>
								<td>								
									<label class="checkbox">Cobran&ccedil;a banc&aacute;ria</label>
								</td>
								<td>
									<label><? echo formataFlag(getByTagName($regServicos2->tags,'flcobran')); ?></label>
								</td>
								<td style="vertical-align: middle">
								<?if (getByTagName($regServicos2->tags,'flcobran') == 1){?>							
									<input class="checkbox" type="checkbox" style="margin-top: 0px" id="9"/>
								<?}?>
								</td>
							</tr>
							<tr>
								<td>								
									<label class="checkbox">Seguros</label>
								</td>
								<td>
									<label><? echo formataFlag(getByTagName($regServicos2->tags,'flseguro')); ?></label>
									<input id="flsegauto" name="flsegauto" type="hidden" value="<?echo getByTagName($regServicos2->tags,'flsegauto');?>"></input>
									<input id="flsegvida" name="flsegvida" type="hidden" value="<?echo getByTagName($regServicos2->tags,'flsegvida');?>"></input>
								</td>
								<td style="vertical-align: middle">
								<?if (getByTagName($regServicos2->tags,'flseguro') == 1){?>														
									<input class="checkbox" type="checkbox" style="margin-top: 0px" id="10"/>
								<?}?>
								</td>
							</tr>
							<tr>
								<td>								
									<label class="checkbox">Cons&oacute;rcio</label>
								</td>
								<td>
									<label><? echo formataFlag(getByTagName($regServicos2->tags,'flconsor')); ?></label>
								</td>
								<td style="vertical-align: middle">
								<?if (getByTagName($regServicos2->tags,'flconsor') == 1){?>																					
									<input class="checkbox" type="checkbox" style="margin-top: 0px" id="11"/>
								<?}?>
								</td>
							</tr>
							<tr>
								<td>								
									<label class="checkbox">Conta ITG</label>
								</td>
								<td>
									<label><? echo formataFlag(getByTagName($regServicos2->tags,'flgctitg')); ?></label>
								</td>
								<td style="vertical-align: middle">
								<?if (getByTagName($regServicos2->tags,'flgctitg') == 1){?>							
									<input class="checkbox" type="checkbox" style="margin-top: 0px" id="12"/>
								<?}?>
								</td>
							</tr>
							<tr>
								<td>								
									<label class="checkbox">Vendas com cart&otilde;es - Parceiro Bancoob</label>
								</td>
								<td>
									<label><? echo formataFlag(getByTagName($regServicos2->tags,'flgccbcb')); ?></label>
								</td>
								<td style="vertical-align: middle">
								<?if (getByTagName($regServicos2->tags,'flgccbcb') == 1){ ?>
									<input class="checkbox" type="checkbox" style="margin-top: 0px" id="13"/>
								<?}?>
								</td>
							</tr>
							<tr>
								<td>								
									<label class="checkbox">Vendas com cart&otilde;es - Parceiro BB</label>
								</td>
								<td>
									<label><? echo formataFlag(getByTagName($regServicos2->tags,'flgccbdb')); ?></label>
								</td>
								<td style="vertical-align: middle">
								<?if (getByTagName($regServicos2->tags,'flgccbdb') == 1){?>
									<input class="checkbox" type="checkbox" style="margin-top: 0px" id="14"/>
								<?}?>
								</td>
							</tr>
							<tr>
								<td>								
									<label class="checkbox">Folhas de cheque em uso</label>
								</td>
								<td>
								<label><?  echo formataNumericos('zzzz9',getByTagName($regServicos2->tags,'qtfdcuso'),'.'); ?></label>
								</td>
								<td style="vertical-align: middle">
								<?if (getByTagName($regServicos2->tags,'qtfdcuso') > 0){?>
									<input class="checkbox" type="checkbox" style="margin-top: 0px" id="15"/>
								<?}?>
								</td>
							</tr>
						<tr>
								<td>								
									<label class="checkbox">Cheques cancelados</label>
								</td>
								<td>
								<label><? echo formataNumericos('zzzz9',getByTagName($regServicos2->tags,'qtchqcan'),'.');  ?></label>
								</td>
								<td style="vertical-align: middle">
								<?if (getByTagName($regServicos2->tags,'qtchqcan') > 0){?>
									<input class="checkbox" type="checkbox" style="margin-top: 0px" id="16"/>
								<?}?>
								</td>
							</tr>						
							<tr>
								<td>								
									<label class="checkbox">Talon&aacute;rios em estoque</label>
								</td>
								<td>							
								<label><? echo formataNumericos('zzzz9',getByTagName($regServicos2->tags,'qtreqtal'),'.');   ?></label>
							
								</td>
								<td style="vertical-align: middle">
								<?if (getByTagName($regServicos2->tags,'qtreqtal') > 0){?>
									<input class="checkbox" type="checkbox" style="margin-top: 0px" id="17"/>
								<?}?>
								</td>
							</tr>
							<tr>
								<td>								
									<label class="checkbox">Cheques devolvidos</label>
								</td>
								<td>
								<label><? echo formataNumericos('zzzz9',getByTagName($regServicos2->tags,'qtchqdev'),'.'); ?></label>
								</td>
								<td style="vertical-align: middle">
								<?if (getByTagName($regServicos2->tags,'qtchqdev') > 0){?>
									<input class="checkbox" type="checkbox" style="margin-top: 0px" id="18"/>
								<?}?>
								</td>
							</tr>						
							<tr>
								<td>								
									<label class="checkbox">Benef&iacute;cio INSS</label>
								</td>
								<td>
									<label><? echo formataFlag(getByTagName($regServicos2->tags,'flgbinss')); ?></label>
								</td>
								<td style="vertical-align: middle">
								<?if (getByTagName($regServicos2->tags,'flgbinss') == 1){?>							
									<input class="checkbox" type="checkbox" style="margin-top: 0px" id="19"/>
								<?}?>
								</td>
							</tr>
							<tr>
								<td>								
									<label class="checkbox">Produtos BRDE</label>
								</td>
								<td>
									<label><? echo formataFlag(getByTagName($regServicos2->tags,'flpdbrde')); ?></label>														
								</td>
								<td style="vertical-align: middle">
								<?if (getByTagName($regServicos2->tags,'flpdbrde') == 1){?>														
									<input class="checkbox" type="checkbox" style="margin-top: 0px" id="20"/>
								<?}?>
								</td>
							</tr>
							<tr>
								<td>								
									<label class="checkbox">Lan&ccedil;amentos Futuros</label>
								</td>
								<td>
									<label><? echo formataFlag(getByTagName($regServicos2->tags,'flgagend')); ?></label>
								</td>
								<td style="vertical-align: middle">
								<?if (getByTagName($regServicos2->tags,'flgagend') == 1){?>														
									<input class="checkbox" type="checkbox" style="margin-top: 0px" id="21"/>
								<?}?>
								</td>
							</tr>
							<tr>
								<td>								
									<label class="checkbox">Cart&otilde;es Magn&eacute;tico</label>
								</td>
								<td>
									<label><? echo formataFlag(getByTagName($regServicos2->tags,'flgcrmag')); ?></label>
								</td>
								<td style="vertical-align: middle">
								<?if (getByTagName($regServicos2->tags,'flgcrmag') == 1){?>														
									<input class="checkbox" type="checkbox" style="margin-top: 0px" id="22"/>
								<?}?>
								</td>
							</tr>
							<tr>
								<td>								
									<label class="checkbox">Folhas de cheque em estoque</label>
								</td>
								<td>
								<label><?  echo formataNumericos('zzzz9',getByTagName($regServicos2->tags,'qtfdcest'),'.'); ?></label>
								</td>
								<td style="vertical-align: middle">
								<?if (getByTagName($regServicos2->tags,'qtfdcest') > 0){?>
									<input class="checkbox" type="checkbox" style="margin-top: 0px" id="23"/>
								<?}?>
								</td>
							</tr>
						</table>
						
				<br style="clear:both" />	
					
				</fieldset>							
			</form>
			
			
	<br style="clear:both" />					
		

	<div id="divBotoes" >
			 
		<div id="divBotoesAuto" style="margin-top:5px; margin-bottom :10px; text-align: center;">
			<a href="#" class="botao" id="btProsseguir"  onClick="efetuaCancelamentoAuto(); return false;" style="float: none; padding:3px 6px;">Continuar</a>
		</div>
		
		<div id="divBotoesManual" style="margin-top:5px; margin-bottom :10px; text-align: center;">
							<a href="#" class="botao" id="btProsseguir"  onClick="efetuaCancelamentoManual()" style="float: none; padding:3px 6px;">Continuar</a>
						</div>

	<div id="divBotoes" style="margin-top:5px; margin-bottom :10px">
		<a href="#" class="botao" id="btVoltar"  onClick="finalizarRotina(); return false;">Voltar</a>
	</div>
	</div>

</div>

<script type="text/javascript">

	$(document).ready(function(){
		$('#frmCancManl table tbody tr').each(function(key, val){
			if ($(val).find('td').eq(1).text().replace(/(\r\n|\n|\r)/gm,"").trim() == 'R$ 0,00' ||
			    $(val).find('td').eq(1).text().replace(/(\r\n|\n|\r)/gm,"").trim() == '<?=utf8_decode('Não')?>' ||
				$(val).find('td').eq(1).text().replace(/(\r\n|\n|\r)/gm,"").trim() == '0'){

				$(val).remove();
				
			}
		});
	});
	
	var tamfrmCancAuto = parseFloat($('#frmCancAuto').css('height').replace('px','')) ;
	var tamFrmCancManl = parseFloat($('#frmCancManl').css('height').replace('px','')) ;
				
	if(tamfrmCancAuto > tamFrmCancManl){
		$('#frmCancManl').css('height',tamfrmCancAuto + 'px');
		$('#frmCancAuto').css('height',tamfrmCancAuto + 'px');
	}else{ 
		$('#frmCancManl').css('height',tamFrmCancManl + 'px');
		$('#frmCancAuto').css('height',tamFrmCancManl + 'px');
		
	}
		
	
</script>