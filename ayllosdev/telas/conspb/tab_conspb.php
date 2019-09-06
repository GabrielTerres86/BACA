<? 
/*!
 * FONTE        : tab_conspb.php
 * CRIAÇÃO      : Douglas Quisinski
 * DATA CRIAÇÃO : 30/07/2015
 * OBJETIVO     : Tabela que para listar as informações da conciliação de TED/TEC
 * --------------
 * ALTERAÇÕES   : 
 */	
?>
<div class="divTabConteudo" id="divConteudo">
	<div id="tabConspb" style="overflow-x: scroll; height: 300px; width: 600px;">
		<div style="width: 2500px">
			<table class="tituloRegistros" id="tbConspb" border="0" cellpadding="0" cellspacing="0">
				<thead>
					<tr style="background-color: #F4D0C9;" height="20">
						<th width="130px" align="center" class="txtNormalBold"><? echo utf8ToHtml('Tipo');?></th>
						<th width="250px" align="center" class="txtNormalBold"><? echo utf8ToHtml('N&uacute;mero de Controle');?></th>
						<th width="250px" align="center" class="txtNormalBold"><? echo utf8ToHtml('N&uacute;mero de Controle IF');?></th>
						<th width="100px" align="center" class="txtNormalBold"><? echo utf8ToHtml('Valor');?></th>
						<th width="100px" align="center" class="txtNormalBold"><? echo utf8ToHtml('Data');?></th>
						<th width=" 60px" align="center" class="txtNormalBold"><? echo utf8ToHtml('Hor&aacute;rio');?></th>
						<th width="130px" align="center" class="txtNormalBold"><? echo utf8ToHtml('Erro');?></th>
						<th width="220px" align="center" class="txtNormalBold"><? echo utf8ToHtml('Origem');?></th>
						<th width=" 60px" align="center" class="txtNormalBold"><? echo utf8ToHtml('Esp&eacutecie');?></th>
						<th width="170px" align="center" class="txtNormalBold"><? echo utf8ToHtml('Banco Debitado');?></th>
						<th width="180px" align="center" class="txtNormalBold"><? echo utf8ToHtml('Ag&ecirc;ncia Debitada');?></th>
						<th width="170px" align="center" class="txtNormalBold"><? echo utf8ToHtml('Conta Debitada');?></th>
						<th width="180px" align="center" class="txtNormalBold"><? echo utf8ToHtml('CPF/CNPJ Debitado');?></th>
						<th width="230px" align="center" class="txtNormalBold"><? echo utf8ToHtml('Nome Debitado');?></th>
						<th width="170px" align="center" class="txtNormalBold"><? echo utf8ToHtml('Banco Creditado');?></th>
						<th width="180px" align="center" class="txtNormalBold"><? echo utf8ToHtml('Ag&ecirc;ncia Creditada');?></th>
						<th width="170px" align="center" class="txtNormalBold"><? echo utf8ToHtml('Conta Creditada');?></th>
						<th width="180px" align="center" class="txtNormalBold"><? echo utf8ToHtml('CPF/CNPJ Creditado');?></th>
						<th width="230px" align="center" class="txtNormalBold"><? echo utf8ToHtml('Nome Creditado');?></th>
					</tr>
				</thead>
				<tbody>
				</tbody>
			</table>
		</div> 
	</div>
	
	<div id="divPesquisaRodape" class="divPesquisaRodape">
		<table>	
			<tr>
				<td id="lable_anterior" >
					<a class="paginacaoAnt"><<< Anterior</a>
				</td>
				<td id="lable_quantidade">
					
				</td>
				<td id="lable_proximo">
					<a class="paginacaoProx">Pr&oacute;ximo >>></a>
				</td>
			</tr>
		</table>
	</div>
</div>

<div id="divBotoes">
	<a href="#" class="botao" id="btProcessar" onclick="controlaBotao('P'); return false;">Processar</a>
	<a href="#" class="botao" id="btVoltar"    onClick="controlaBotao('C'); return false;">Cancelar</a>
</div>

<div id="divDetalhes">
	<table id="tbDetalhes">
		<tr>
			<td colspan="2" width="100%">
				<table>
					<tr>
						<td align="right">
							<label for="cddotipo">Tipo:</label>
						</td>
						<td>
							<input type="text" id="cddotipo" name="cddotipo"/>
						</td>
					</tr>
					<tr>
						<td align="right">
							<label for="nrcontro">N&uacute;mero de Controle:</label>
						</td>
						<td>
							<input type="text" id="nrcontro" name="nrcontro"/>
						</td>
					</tr>
					<tr>
						<td align="right">
							<label for="nrctrlif">N&uacute;mero de Controle IF:</label>
						</td>
						<td>
							<input type="text" id="nrctrlif" name="nrctrlif"/>
						</td>
					</tr>
					<tr>
						<td align="right">
							<label for="vlconcil">Valor:</label>
						</td>
						<td>
							<input type="text" id="vlconcil" name="vlconcil"/>
						</td>
					</tr>
					<tr>
						<td align="right">
							<label for="dtmensag">Data:</label>
						</td>
						<td>
							<input type="text" id="dtmensag" name="dtmensag"/>
						</td>
					</tr>
					<tr>
						<td align="right">
							<label for="dsdahora">Hora:</label>
						</td>
						<td>
							<input type="text" id="dsdahora" name="dsdahora"/>
						</td>
					</tr>
					<tr>
						<td align="right">
							<label for="dsorigemerro">Erro:</label>
						</td>
						<td>
							<input type="text" id="dsorigemerro" name="dsorigemerro"/>
						</td>
					</tr>
					<tr>
						<td align="right">
							<label for="dsorigem">Origem:</label>
						</td>
						<td>
							<input type="text" id="dsorigem" name="dsorigem"/>
						</td>
					</tr>
					<tr>
						<td align="right">
							<label for="dsespeci">Esp&eacute;cie:</label>
						</td>
						<td>
							<input type="text" id="dsespeci" name="dsespeci"/>
						</td>
					</tr>
				</table>
			</td>
		</tr>
		<tr>
			<td width="350px">
				<form id="frmDebitado" name="frmDebitado" class="formulario" enctype="multipart/form-data" style="display:none">
					<fieldset>
						<legend>Debitado</legend>
						<table width="100%" >
							<tr>		
								<td align="right">
									<label for="cddbanco_deb">Banco:</label>
								</td>
								<td>
									<input type="text" id="cddbanco_deb" name="cddbanco_deb"/>
								</td>
							</tr>
							<tr>		
								<td align="right">
									<label for="cdagenci_deb">Ag&ecirc;ncia:</label>
								</td>
								<td>
									<input type="text" id="cdagenci_deb" name="cdagenci_deb"/>
								</td>
							</tr>
							<tr>		
								<td align="right">
									<label for="nrdconta_deb">Conta:</label>
								</td>
								<td>
									<input type="text" id="nrdconta_deb" name="nrdconta_deb"/>
								</td>
							</tr>
							<tr>		
								<td align="right">
									<label for="nrcpfcgc_deb">CPF/CNPJ:</label>
								</td>
								<td>
									<input type="text" id="nrcpfcgc_deb" name="nrcpfcgc_deb"/>
								</td>
							</tr>
							<tr>		
								<td align="right">
									<label for="nmcooper_deb">Nome:</label>
								</td>
								<td>
									<input type="text" id="nmcooper_deb" name="nmcooper_deb"/>
								</td>
							</tr>
						</table>
					</fieldset>
				</form>
			</td>
			<td width="350px">
				<form id="frmCreditado" name="frmCreditado" class="formulario" enctype="multipart/form-data" style="display:none">
					<fieldset>
						<legend>Creditado</legend>
						<table width="100%" class="formulario">
							<tr>		
								<td align="right">
									<label for="cddbanco_cre">Banco:</label>
								</td>
								<td>
									<input type="text" id="cddbanco_cre" name="cddbanco_cre"/>
								</td>
							</tr>
							<tr>		
								<td align="right">
									<label for="cdagenci_cre">Ag&ecirc;ncia:</label>
								</td>
								<td>
									<input type="text" id="cdagenci_cre" name="cdagenci_cre"/>
								</td>
							</tr>
							<tr>		
								<td align="right">
									<label for="nrdconta_cre">Conta:</label>
								</td>
								<td>
									<input type="text" id="nrdconta_cre" name="nrdconta_cre"/>
								</td>
							</tr>
							<tr>		
								<td align="right">
									<label for="nrcpfcgc_cre">CPF/CNPJ:</label>
								</td>
								<td>
									<input type="text" id="nrcpfcgc_cre" name="nrcpfcgc_cre"/>
								</td>
							</tr>
							<tr>		
								<td align="right">
									<label for="nmcooper_cre">Nome:</label>
								</td>
								<td>
									<input type="text" id="nmcooper_cre" name="nmcooper_cre"/>
								</td>
							</tr>
						</table>
					</fieldset>
				</form>
			</td>
		</tr>
		<tr>
			<td colspan="2" align="center">
				<a href="#" class="botao" id="btVoltar2" onClick="voltarSelecao(); return false;">Voltar</a>
			</td>
		</tr>
	</table>
</div>

<script type="text/javascript">
	$('#divPesquisaRodape').formataRodapePesquisa();
	$('a.paginacaoAnt').unbind('click').bind('click', function() {
		controlaPaginacaoAnterior();
	});
	$('a.paginacaoProx').unbind('click').bind('click', function() {
		controlaPaginacaoProximo();
	});
	
	formataCamposDetalhe();
</script>
