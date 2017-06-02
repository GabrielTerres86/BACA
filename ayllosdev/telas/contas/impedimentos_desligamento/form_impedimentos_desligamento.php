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
 
?>
<table width="100%" height="92%">
	<tr>
		<td width="35%" height="100%">
			<form name="frmCancAuto" id="frmCancAuto" class="formulario" style="height: inherit; position: relative">
				<fieldset style="height: inherit">				
				<legend>Cancelamento Autom&aacute;tico</legend>
					<table>
						<?foreach( $regServicos as $result ) {?>
							
							<tr id="<?echo getByTagName($result->tags,'cdproduto');?>">
							
								<?if(getByTagName($result->tags,'flativo') == 'S'){?>	
									<td><a style="padding: 0px 0 0 3px;"><img style="width:25px; height:25px;" src="<? echo $UrlImagens; ?>geral/servico_ativo.gif" id="lupaServico" name="lupaServico" /></a></td>
									<td style="text-align:left;width:260px">
										<label><?echo getByTagName($result->tags,'dsproduto');?></label>
									</td>
								<?}?>

							</tr>
						<?}?>
					</table>
					<div class="divBotoes" style="position: absolute; bottom: 0; left: 0; right: 0">
						<a href="#" class="botao" id="btProsseguir"  onClick="btnContinuar(); return false;" style="float: none; padding:3px 6px;">Continuar</a>
					</div>
				</fieldset>
			</form>
		</td>
		<td width="70%" height="100%">
			<form name="frmCancManl" id="frmCancManl" class="formulario" style="height: inherit; position: relative;">
				<fieldset style="height: inherit">
				<legend>Cancelamento Manual</legend>
					<table width="100%">
						<tr>
							<td>								
								<label class="checkbox">Empr&eacute;stimos e financiamento</label>
							</td>
							<td>
								<label>R$ <? echo formataMoeda(getByTagName($regServicos2->tags,'vlemprst')); ?></label>
							</td>
							<td style="vertical-align: middle">
								<input class="checkbox" type="checkbox" style="margin-top: 0px"/>
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
								<input class="checkbox" type="checkbox" style="margin-top: 0px"/>
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
								<input class="checkbox" type="checkbox" style="margin-top: 0px"/>
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
								<input class="checkbox" type="checkbox" style="margin-top: 0px"/>
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
								<input class="checkbox" type="checkbox" style="margin-top: 0px"/>
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
								<input class="checkbox" type="checkbox" style="margin-top: 0px"/>
							</td>
						</tr>
						<tr>
							<td>								
								<label class="checkbox">Cobran&ccedil;a banc&atilde;ria</label>
							</td>
							<td>
								<label><? echo formataFlag(getByTagName($regServicos2->tags,'flcobran')); ?></label>
							</td>
							<td style="vertical-align: middle">
								<input class="checkbox" type="checkbox" style="margin-top: 0px"/>
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
								<input class="checkbox" type="checkbox" style="margin-top: 0px"/>
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
								<input class="checkbox" type="checkbox" style="margin-top: 0px"/>
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
								<input class="checkbox" type="checkbox" style="margin-top: 0px"/>
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
								<input class="checkbox" type="checkbox" style="margin-top: 0px"/>
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
								<input class="checkbox" type="checkbox" style="margin-top: 0px"/>
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
								<input class="checkbox" type="checkbox" style="margin-top: 0px"/>
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
								<input class="checkbox" type="checkbox" style="margin-top: 0px"/>
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
								<input class="checkbox" type="checkbox" style="margin-top: 0px"/>
							</td>
						</tr>
						<tr>
							<td>								
								<label class="checkbox">Cheques cancelados</label>
							</td>
							<td>
								<label><? echo getByTagName($regServicos2->tags,'qtchqcan'); ?></label>
							</td>
							<td style="vertical-align: middle">
								<input class="checkbox" type="checkbox" style="margin-top: 0px"/>
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
								<input class="checkbox" type="checkbox" style="margin-top: 0px"/>
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
								<input class="checkbox" type="checkbox" style="margin-top: 0px"/>
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
								<input class="checkbox" type="checkbox" style="margin-top: 0px"/>
							</td>
						</tr>
					</table>
					<div class="divBotoes" style="position: absolute; bottom: 0; left: 0; right: 0">
						<a href="#" class="botao" id="btProsseguir"  onClick="btnContinuar(); return false;" style="float: none; padding:3px 6px;">Continuar</a>
					</div>
				</fieldset>							
			</form>
		</td>
	</tr>
</table>

<div id="divBotoes" style="margin-top:5px; margin-bottom :10px">
	<a href="#" class="botao" id="btVoltar"  onClick="fechaRotina(divRotina); return false;">Voltar</a>
</div>
