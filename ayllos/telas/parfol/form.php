	<?
	/***********************************************************************
	
	  Fonte: form.php                                               
	  Autor: Renato Darosci                                                  
	  Data : Mai/2015                       Última Alteração: 12/05/2017

	  Objetivo  : Mostrar os campos do formulario

	  Alterações: 23/11/2015 - Desconsiderando a posicao 4 do array de acessos
							   (Andre Santos - SUPERO)	  

				  19/01/2017 - Adicionado novo limite de horario para pagamento no dia
							   para contas da cooperativa. (M342 - Kelvin)
							   
				  12/05/2017 - Segunda fase da melhoria 342 (Kelvin). 
	***********************************************************************/	
	?>
	

<form id="frmPARFOL" name="frmPARFOL" class="formulario">

	<!--fieldset-->
		<!--legend><? echo utf8ToHtml('') ?></legend-->
		
		<table style="width:100%;"> 
			<tr >
				<td style="width:95%;" align="center">
					<fieldset style="width:95%;" >
						<legend align="left"><? echo 'Parâmetros Gerais' ?></legend>
						<table style="width:95%;" >
						<tr>
							<td  class="txtNormalBold" style="width:40%;text-align:right;"> <label for="dsvlrprm_1" align = "right" style="width:100%;">Qtde meses cancelamento automático:</label></td>
							<td><input  type="text" class="campo" id="dsvlrprm_1" name="dsvlrprm"  size = "4" maxlength = "2" style="text-align:right;"/></td>
							<td  class="txtNormalBold" style="width:40%;text-align:right;"> <label for="dsvlrprm_2" align = "right" style="width:100%;">Qtde dias para envio comprovantes:</label></td>
							<td><input  type="text" class="campo" id="dsvlrprm_2" name="dsvlrprm"  size = "4" maxlength = "2" style="text-align:right;"/></td>
						</tr>
						<tr>
							<td  class="txtNormalBold" style="text-align:right;"> <label for="dsvlrprm_3" align = "right" style="width:100%;">Nro meses para emissão dos Comprovantes:</label></td>
							<td><input  type="text" class="campo" id="dsvlrprm_3" name="dsvlrprm"  size = "4" maxlength = "2" style="text-align:right;"/>
								<?php // dsvlrprm_4 -- Foi ocultado e esta disponivel para outras informacoes ?>
								<input  type="hidden" class="campo" id="dsvlrprm_4" name="dsvlrprm"  size = "4" maxlength = "4" style="text-align:right;"/>
							</td>							
							<td  class="txtNormalBold" style="text-align:right;"> <label for="dsvlrprm_5" align = "right" style="width:100%;">Histórico Estorno Outras Empresas:</label></td>
							<td><input  type="text" class="campo" id="dsvlrprm_5" name="dsvlrprm"  size = "4" maxlength = "4" style="text-align:right;"/></td>
						</tr>
						<tr>
							<td  class="txtNormalBold" style="text-align:right;"> <label for="dsvlrprm_6" align = "right" style="width:100%;">Histórico Estorno para Cooperativas:</label></td>
							<td><input  type="text" class="campo" id="dsvlrprm_6" name="dsvlrprm"  size = "4" maxlength = "4" style="text-align:right;"/></td>
						</tr>
						<tr>
							<td>&nbsp;</td>
						</tr>
						<tr><td colspan="4" align="center">
							<table> 
							<tr>
								<td  class="txtNormalBold" style="width:175px; text-align:right;vertical-align: top;">
									<label for="dsvlrprm_7" align="right" style="width:100%; text-align:right;">E-mails para alerta na Central:</label>
								</td>
								<td colspan=3>
									<textarea name="dsvlrprm" id="dsvlrprm_7" align="left" rows="3" cols="90" maxlength="1000" placeholder="Separados por vírgula..." class="campo"
										style="font-size:11px;border:1px solid #777;background-color:#fff;color:#111;height:32px;"></textarea>
								</td>
							</tr>
							</table>
						</td>
						</tr>
						<tr>
							<td>&nbsp;</td>
						</tr>
						</table>
					</fieldset>
				</td>
			</tr>
			<tr >
				<td style="width:95%;" align="center">
					<fieldset style="width:95%;" >
						<legend align="left"><? echo 'Horários Limite' ?></legend>
						<table style="width:95%;" >
							<tr>
								<td  class="txtNormalBold" style="width:40%;text-align:right;"> <label for="dsvlrprm_8" align = "right" style="width:100%;">Agendamento:</label></td>
								<td><input  type="text" class="campo" id="dsvlrprm_8" name="dsvlrprm"  size = "4" maxlength = "5" style="text-align:center;"/></td>
								<td  class="txtNormalBold" style="width:40%;text-align:right;"> <label for="dsvlrprm_9" align = "right" style="width:100%;">Portabilidade (Pgto no dia):</label></td>
								<td><input  type="text" class="campo" id="dsvlrprm_9" name="dsvlrprm"  size = "4" maxlength = "5" style="text-align:center;"/></td>
							</tr>
							<tr>
								<td  class="txtNormalBold" style="text-align:right;"> <label for="dsvlrprm_10" align = "right" style="width:100%;">Solicitação Estouro Conta:</label></td>
								<td><input  type="text" class="campo" id="dsvlrprm_10" name="dsvlrprm"  size = "4" maxlength = "5" style="text-align:center;"/></td>
								<td  class="txtNormalBold" style="text-align:right;"> <label for="dsvlrprm_11" align = "right" style="width:100%;">Liberação Estouro Conta:</label></td>
								<td><input  type="text" class="campo" id="dsvlrprm_11" name="dsvlrprm"  size = "4" maxlength = "5" style="text-align:center;"/></td>
							</tr>
							<tr>
								<td  class="txtNormalBold" style="text-align:right;"> <label for="dsvlrprm_22" align = "right" style="width:100%;">Pagto no dia (contas cooperativa):</label></td>
								<td><input  type="text" class="campo" id="dsvlrprm_22" name="dsvlrprm"  size = "4" maxlength = "5" style="text-align:center;"/></td>
							</tr>
							<tr>
								<td>&nbsp;</td>
							</tr>
						</table>
					</fieldset>
				</td>
			</tr>
			<tr >
				<td style="width:95%;" align="center">
					<fieldset style="width:95%;" >
						<legend align="left"><? echo 'Processo CTASAL' ?></legend>
						<table style="width:95%;">
							<tr>
								<td  class="txtNormalBold" style="width:40%;text-align:right;"><label for="dsvlrprm_12" align = "right" style="width:100%;">Lote:</label></td>
								<td><input  type="text" class="campo" id="dsvlrprm_12" name="dsvlrprm"  size = "4" maxlength = "5" style="text-align:right;"/></td>
								<td  class="txtNormalBold" style="width:40%;text-align:right;"> <label for="dsvlrprm_13" align = "right" style="width:100%;">Histórico Crédito TEC:</label></td>
								<td><input  type="text" class="campo" id="dsvlrprm_13" name="dsvlrprm"  size = "4" maxlength = "4" style="text-align:right;"/></td>
							</tr>
                            <tr><td colspan="4" align="center">
                                <fieldset style="width:95%;" >
                                    <legend align="left"><? echo 'Outras IF' ?></legend>
                                    <table style="width:95%;">
                                        <tr>
                                            <td  class="txtNormalBold" style="width:40%;text-align:right;"> <label for="dsvlrprm_14" align = "right" style="width:100%;">Histórico Débito TEC:</label></td>
                                            <td><input  type="text" class="campo" id="dsvlrprm_14" name="dsvlrprm"  size = "4" maxlength = "4" style="text-align:right;"/></td>
                                            <td  class="txtNormalBold" style="text-align:right;"> <label for="dsvlrprm_15" align = "right" style="width:100%;">Histórico Recusa TEC:</label></td>
                                            <td><input  type="text" class="campo" id="dsvlrprm_15" name="dsvlrprm"  size = "4" maxlength = "4" style="text-align:right;"/></td>
                                        </tr>
                                        <tr>
                                            <td  class="txtNormalBold" style="text-align:right;"> <label for="dsvlrprm_16" align = "right" style="width:100%;">Histórico Devolução TEC:</label></td>
                                            <td><input  type="text" class="campo" id="dsvlrprm_16" name="dsvlrprm"  size = "4" maxlength = "4" style="text-align:right;"/></td>
                                            <td  class="txtNormalBold" style="width:40%;text-align:right;"> <label for="dsvlrprm_17" align = "right" style="width:100%;">Histórico Devolução Empresa:</label></td>
                                            <td><input  type="text" class="campo" id="dsvlrprm_17" name="dsvlrprm"  size = "4" maxlength = "4" style="text-align:right;"/></td>
                                        </tr>
                                    </table>
                                </fieldset>
                            </td></tr>
                            <tr><td colspan="4" align="center">
                                <fieldset style="width:95%;" >
                                    <legend align="left"><? echo 'Ailos (Bco 85)' ?></legend>
                                    <table style="width:95%;">
                                        <tr>
                                            <td  class="txtNormalBold" style="width:40%;text-align:right;"> <label for="dsvlrprm_18" align = "right" style="width:100%;">Lote TRF:</label></td>
                                            <td><input  type="text" class="campo" id="dsvlrprm_18" name="dsvlrprm"  size = "4" maxlength = "5" style="text-align:right;"/></td>
                                            <td  class="txtNormalBold" style="text-align:right;"> </td>
                                            <td></td>
                                        </tr>
                                        <tr>
                                            <td  class="txtNormalBold" style="text-align:right;"> <label for="dsvlrprm_19" align = "right" style="width:100%;">Histórico Débito TRF:</label></td>
                                            <td><input  type="text" class="campo" id="dsvlrprm_19" name="dsvlrprm"  size = "4" maxlength = "4" style="text-align:right;"/></td>
                                            <td  class="txtNormalBold" style="width:40%;text-align:right;"> <label for="dsvlrprm_20" align = "right" style="width:100%;">Histórico Crédito TRF:</label></td>
                                            <td><input  type="text" class="campo" id="dsvlrprm_20" name="dsvlrprm"  size = "4" maxlength = "4" style="text-align:right;"/></td>
                                        </tr>
                                    </table>
                                </fieldset>
                            </td></tr>
							<tr>
								<td colspan="4">&nbsp;</td>
							</tr>
							<tr><td colspan="4" align="center">
								<table> 
								<tr>
									<td  class="txtNormalBold" style="text-align:right;vertical-align: top;">
										<label for="dsvlrprm_21" align="right" style="width:100%; text-align:right;">E-mails para alerta ao Financeiro:</label>
									</td>
									<td>
										<textarea name="dsvlrprm" id="dsvlrprm_21" align="left" rows="3" cols="90" maxlength="1000" placeholder="Separados por vírgula..." class="campo"
											style="font-size:11px;border:1px solid #777;background-color:#fff;color:#111;height:32px;"></textarea>
									</td>
								</tr>
								</table>
							</td>
							</tr>
							<tr>
								<td>&nbsp;</td>
							</tr>
						</table>
					</fieldset>
				</td>
			</tr>
			<tr>
				<td style="width:95%;" align="center">
					<fieldset style="width:95%;" >
						<legend align="left"><? echo 'Transferência Tipo Salário' ?></legend>
						<table style="width:95%;" >							
							<tr>
								<td class="txtNormalBold" style="width:40%;text-align:right;">
									<label for="dsvlrprm_23" align="right" style="width:100%;">Habilita Transferência:</label>
								</td>
								<td>
									<select name="dsvlrprm" id="dsvlrprm_23" class="campo" style="width:57px">
										<option value="1">Sim</option>
										<option value="0">Não</option>				
									</select>
								</td>								
							</tr>
							<tr>
								<td class="txtNormalBold" style="text-align:right;"> 
									<label for="dsvlrprm_24" align = "right" style="width:100%;">Horário Limite (transf no dia)</label>
								</td>
								<td>
									<input type="text" class="campo" id="dsvlrprm_24" name="dsvlrprm" size="4" maxlength = "5" style="text-align:center;"/>
								</td>
								<td class="txtNormalBold" style="width:40%;text-align:right;">
									<label for="dsvlrprm_25" align="right" style="width:100%;">Tarifa:</label>
								</td>
								<td>
									<select name="dsvlrprm" id="dsvlrprm_25" class="campo">
										<option value="1">Sim</option>
										<option value="0">Isento</option>				
									</select>
								</td>
							</tr>
						</table>
					</fieldset>					
				</td>				
			</tr>
		</table>
	<!--/fieldset-->
	
</form>

