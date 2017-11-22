<? 
/*!
 * FONTE        : form_impedimentos_desligamento.php
 * CRIAÇÃO      : Lucas Reinert
 * DATA CRIAÇÃO : 25/05/2017
 * OBJETIVO     : Rotina para apresentar todos os produtos ativos que precisam ser cancelados no caso 
 *				  de desligamento do cooperado
 * --------------
 * ALTERAÇÕES   :
 * --------------
 */
 function formataFlag($valor){
	 if ($valor == 1) return 'Sim'; else return 'N&atilde;o';
 }
 
 
 $produtos = array('3', '8', '10', '15', '16', '38');
?>
<table width="100%" height="94%">
	<tr>
		<td width="40%" height="100%">
			<form name="frmCancAuto" id="frmCancAuto" class="formulario" style="height: inherit; position: relative">
				<fieldset style="height: inherit">				
				<legend>Cancelamento Autom&aacute;tico</legend>
					<table>
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
					<div class="divBotoes" style="position: absolute; bottom: 0; left: 0; right: 0">
						<a href="#" class="botao" id="btProsseguir"  onClick="efetuaCancelamentoAuto(); return false;" style="float: none; padding:3px 6px;">Continuar</a>
					</div>
				</fieldset>
			</form>
		</td>
		<td width="60%" height="100%">
			<form name="frmCancManl" id="frmCancManl" class="formulario" style="height: inherit; position: relative;">
				<fieldset style="height: inherit">
				<legend>Cancelamento Manual</legend>
					<table width="100%">
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
								<label class="checkbox">Cart&atilde;o Cecred/BB/Bradesco</label>
							</td>
							<td>
								<label>R$ <? echo formataMoeda(getByTagName($regServicos2->tags,'vllimcar')); ?></label>
							</td>
							<td style="vertical-align: middle">
							<?if (getByTagName($regServicos2->tags,'vllimcar') > 0){?>
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
								<label><? echo getByTagName($regServicos2->tags,'qtfdcuso'); ?></label>
							</td>
							<td style="vertical-align: middle">
							<?if (getByTagName($regServicos2->tags,'qtfdcuso') > 0){?>
								<input class="checkbox" type="checkbox" style="margin-top: 0px" id="15"/>
							<?}?>
							</td>
						</tr>
						<tr style="display: none;">
							<td>								
								<label class="checkbox">Cheques cancelados</label>
							</td>
							<td>
								<label><? echo getByTagName($regServicos2->tags,'qtchqcan'); ?></label>
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
								<label><? echo getByTagName($regServicos2->tags,'qtreqtal'); ?></label>
							
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
								<label><? echo getByTagName($regServicos2->tags,'qtchqdev'); ?></label>
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
								<label class="checkbox">Agendamentos</label>
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
					</table>
					<div class="divBotoes" style="position: absolute; bottom: 0; left: 0; right: 0">
						<a href="#" class="botao" id="btProsseguir"  onClick="efetuaCancelamentoManual()" style="float: none; padding:3px 6px;">Continuar</a>
					</div>
				</fieldset>							
			</form>
		</td>
	</tr>
</table>

<div id="divBotoes" style="margin-top:5px; margin-bottom :10px">
	<a href="#" class="botao" id="btVoltar"  onClick="fechaRotina(divRotina); return false;">Voltar</a>
</div>

<script type="text/javascript">
	$(document).ready(function(){
		$('#frmCancManl table tbody tr').each(function(key, val){
			if ($(val).find('td').eq(1).text().replace(/(\r\n|\n|\r)/gm,"").trim() == 'R$ 0,00' ||
			    $(val).find('td').eq(1).text().replace(/(\r\n|\n|\r)/gm,"").trim() == '<?=utf8_decode('Não')?>' ||
				$(val).find('td').eq(1).text().replace(/(\r\n|\n|\r)/gm,"").trim() == '0'){

				$(val).hide();
				
			}
		});
	});
</script>