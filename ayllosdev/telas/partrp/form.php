	<?
	/***********************************************************************

	  Fonte: form.php
	  Autor: Jean Calao - Mout´s
	  Data : Mai/2017                       Ultima Alteracao: 27/05/2017

	  Objetivo  : Mostrar os campos do formulario


	***********************************************************************/
	?>


<form id="frmPARTRP" name="frmPARTRP" class="formulario">

		<table style="width:100%;">
			<tr >
				<td style="width:95%;" align="center">
					<fieldset style="width:95%;" >
						<legend align="left"><? echo 'Par&acirc;metros Gerais' ?></legend>
						<table style="width:95%;" >
						<tr>
							<td  class="txtNormalBold" style="width:40%;text-align:right;">
								<label for="dsvlrprm_1" align = "right" style="width:100%;">Data de in&iacute;cio da vig&ecirc;ncia:</label></td>
							<td><input  type="text" class="campo" id="dsvlrprm_1" name="dsvlrprm"  size = "10" maxlength = "10" style="text-align:right;" /></td>
					   </tr>
					   <tr>
							<td  class="txtNormalBold" style="width:40%;text-align:right;">
								<label for="dsvlrprm_2" align = "right" style="width:100%;">Produto da transfer&ecirc;ncia:</label></td>
							    <td><select class="campo" id="dsvlrprm_2" name="dsvlrprm">
									<option value="PP"><? echo utf8ToHtml("Price PP - Empr&eacute;stimo") ?></option>
									<option value="PF"><? echo utf8ToHtml("Price PP - Financiamento ") ?></option>
									<option value="TR"><? echo utf8ToHtml("Price TR - Empr&eacute;stimo") ?></option>
									<option value="TF"><? echo utf8ToHtml("Price TR - Financiamento") ?></option>
									<option value="CC"><? echo utf8ToHtml("CC - Conta Corrente ") ?></option>
									<option value="FE"><? echo utf8ToHtml("P&oacute;s Fixado - Empr&eacute;stimo") ?></option>
									<option value="FF"><? echo utf8ToHtml("P&oacute;s Fixado - Financiamento") ?></option>
									<option value="DC"><? echo utf8ToHtml("DC - Desconto ") ?></option>
								</select>
								<a href="#" id="pesquisa" name="pesquisa" onClick="fn_pesquisa();return false;">
								       <img src="<?php echo $UrlImagens; ?>geral/ico_lupa.gif" ></a>
	
								</td>
						</tr>
						
							   <td>&nbsp;</td>
						</tr>
						</table>
					</fieldset>
				</td>
			</tr>
			<tr >
				<td style="width:95%;" align="center">
					<fieldset style="width:95%;" >
						<legend align="left"><? echo 'Hist&oacute;ricos' ?></legend>
						<table style="width:95%;" >
							<tr>
							   <td>&nbsp;</td>
							   <td><b>Transfer&ecirc;ncia</b></td>
							    <td>&nbsp;</td>
							   <td><b>Estornos</b></td>
							</tr>
							<tr>
								<td  class="txtNormalBold" style="width:40%;text-align:right;">
									 <label for="dsvlrprm_3" align = "right" style="width:100%;">Valor Principal:</label>
								</td>
								<td><input  type="text" class="campo" id="dsvlrprm_3" name="dsvlrprm"  size = "4" maxlength = "5" style="text-align:center;"/></td>
								<td  class="txtNormalBold" style="width:40%;text-align:right;"> 
								     <label for="dsvlrprm_4" align = "right" style="width:100%;">&nbsp;</label></td>
								<td><input  type="text" class="campo" id="dsvlrprm_4" name="dsvlrprm"  size = "4" maxlength = "5" style="text-align:center;"/></td>
							</tr>
							<tr>
								<td  class="txtNormalBold" style="text-align:right;">
									<label for="dsvlrprm_5" align = "right" style="width:100%;">Juros + 60: </label></td>
								<td><input  type="text" class="campo" id="dsvlrprm_5" name="dsvlrprm"  size = "4" maxlength = "5" style="text-align:center;"/></td>
								<td  class="txtNormalBold" style="text-align:right;">
									<label for="dsvlrprm_6" align = "right" style="width:100%;">&nbsp;</label></td>
								<td><input  type="text" class="campo" id="dsvlrprm_6" name="dsvlrprm"  size = "4" maxlength = "5" style="text-align:center;"/></td>
							</tr>
 
							<tr>
								<td>&nbsp;</td>
							</tr>
							<tr>
							   <td>&nbsp;</td>
							   <td><b>Compensa&ccedil;&atilde;o</b></td>
							    <td>&nbsp;</td>
							   <td><b>Estornos</b></td>
							   
							</tr>
							<tr>
								<td  class="txtNormalBold" style="width:40%;text-align:right;">
									 <label for="dsvlrprm_7" align = "right" style="width:100%;">Valor Principal:</label>
								</td>
								<td><input  type="text" class="campo" id="dsvlrprm_7" name="dsvlrprm"  size = "4" maxlength = "5" style="text-align:center;"/></td>
								<td  class="txtNormalBold" style="width:40%;text-align:right;"> 
								     <label for="dsvlrprm_8" align = "right" style="width:100%;">&nbsp;</label></td>
								<td><input  type="text" class="campo" id="dsvlrprm_8" name="dsvlrprm"  size = "4" maxlength = "5" style="text-align:center;"/></td>
							</tr>
							<tr>
								<td  class="txtNormalBold" style="text-align:right;">
									<label for="dsvlrprm_9" align = "right" style="width:100%;">(-) Juros atualiza&ccedil;&atilde;o: </label></td>
								<td><input  type="text" class="campo" id="dsvlrprm_9" name="dsvlrprm"  size = "4" maxlength = "5" style="text-align:center;"/></td>
								<td  class="txtNormalBold" style="text-align:right;">
									<label for="dsvlrprm_10" align = "right" style="width:100%;">&nbsp;</label></td>
								<td><input  type="text" class="campo" id="dsvlrprm_10" name="dsvlrprm"  size = "4" maxlength = "5" style="text-align:center;"/></td>
							</tr>
							<tr>
								<td  class="txtNormalBold" style="text-align:right;">
									<label for="dsvlrprm_11" align = "right" style="width:100%;">(-) Multas e Juros atraso: </label></td>
								<td><input  type="text" class="campo" id="dsvlrprm_11" name="dsvlrprm"  size = "4" maxlength = "5" style="text-align:center;"/></td>
								<td  class="txtNormalBold" style="text-align:right;">
									<label for="dsvlrprm_12" align = "right" style="width:100%;">&nbsp;</label></td>
								<td><input  type="text" class="campo" id="dsvlrprm_12" name="dsvlrprm"  size = "4" maxlength = "5" style="text-align:center;"/></td>
							</tr>
							<tr>
								<td  class="txtNormalBold" style="text-align:right;">
									<label for="dsvlrprm_13" align = "right" style="width:100%;">(-) Despesas com Recup. Prej.: </label></td>
								<td><input  type="text" class="campo" id="dsvlrprm_13" name="dsvlrprm"  size = "4" maxlength = "5" style="text-align:center;"/></td>
								<td  class="txtNormalBold" style="text-align:right;">
									<label for="dsvlrprm_14" align = "right" style="width:100%;">&nbsp;</label></td>
								<td><input  type="text" class="campo" id="dsvlrprm_14" name="dsvlrprm"  size = "4" maxlength = "5" style="text-align:center;"/></td>
							</tr>
							
						</table>
					</fieldset>
				</td>
			</tr>

			<tr >
				<td style="width:95%;" align="center">
					<fieldset style="width:95%;" >
						<table style="width:95%;" >
							<tr>
							   <td>&nbsp;</td>
							   <td><b>Recupera&ccedil;&atilde;o</b></td>
							    <td>&nbsp;</td>
							   <td><b>Estornos</b></td>
							</tr>
							<tr>
								<td  class="txtNormalBold" style="width:40%;text-align:right;">
									 <label for="dsvlrprm_15" align = "right" style="width:100%;">Valor Principal:</label>
								</td>
								<td><input  type="text" class="campo" id="dsvlrprm_15" name="dsvlrprm"  size = "4" maxlength = "5" style="text-align:center;"/></td>
								<td  class="txtNormalBold" style="width:40%;text-align:right;"> 
								     <label for="dsvlrprm_16" align = "right" style="width:100%;">&nbsp;</label></td>
								<td><input  type="text" class="campo" id="dsvlrprm_16" name="dsvlrprm"  size = "4" maxlength = "5" style="text-align:center;"/></td>
							</tr>
							<tr>
								<td>&nbsp;</td>
							</tr>
							<tr>
							   <td>&nbsp;</td>
							   <td><b>Compensa&ccedil;&atilde;o</b></td>
							    <td>&nbsp;</td>
							   <td><b>Estornos</b></td>
							   
							</tr>
							<tr>
								<td  class="txtNormalBold" style="width:40%;text-align:right;">
									 <label for="dsvlrprm_17" align = "right" style="width:100%;">Valor Principal:</label>
								</td>
								<td><input  type="text" class="campo" id="dsvlrprm_17" name="dsvlrprm"  size = "4" maxlength = "5" style="text-align:center;"/></td>
								<td  class="txtNormalBold" style="width:40%;text-align:right;"> 
								     <label for="dsvlrprm_18" align = "right" style="width:100%;">&nbsp;</label></td>
								<td><input  type="text" class="campo" id="dsvlrprm_18" name="dsvlrprm"  size = "4" maxlength = "5" style="text-align:center;"/></td>
							</tr>
							<tr>
								<td  class="txtNormalBold" style="text-align:right;">
									<label for="dsvlrprm_19" align = "right" style="width:100%;">(-) Juros atualiza&ccedil;&atilde;o: </label></td>
								<td><input  type="text" class="campo" id="dsvlrprm_19" name="dsvlrprm"  size = "4" maxlength = "5" style="text-align:center;"/></td>
								<td  class="txtNormalBold" style="text-align:right;">
									<label for="dsvlrprm_20" align = "right" style="width:100%;">&nbsp;</label></td>
								<td><input  type="text" class="campo" id="dsvlrprm_20" name="dsvlrprm"  size = "4" maxlength = "5" style="text-align:center;"/></td>
							</tr>
							<tr>
								<td  class="txtNormalBold" style="text-align:right;">
									<label for="dsvlrprm_21" align = "right" style="width:100%;">(-) Multas e Juros: </label></td>
								<td><input  type="text" class="campo" id="dsvlrprm_21" name="dsvlrprm"  size = "4" maxlength = "5" style="text-align:center;"/></td>
								<td  class="txtNormalBold" style="text-align:right;">
									<label for="dsvlrprm_22" align = "right" style="width:100%;">&nbsp;</label></td>
								<td><input  type="text" class="campo" id="dsvlrprm_22" name="dsvlrprm"  size = "4" maxlength = "5" style="text-align:center;"/></td>
							</tr>
							<tr>
								<td  class="txtNormalBold" style="text-align:right;">
									<label for="dsvlrprm_23" align = "right" style="width:100%;">Abono: </label></td>
								<td><input  type="text" class="campo" id="dsvlrprm_23" name="dsvlrprm"  size = "4" maxlength = "5" style="text-align:center;"/></td>
								<td  class="txtNormalBold" style="text-align:right;">
									<label for="dsvlrprm_24" align = "right" style="width:100%;">&nbsp;</label></td>
								<td><input  type="text" class="campo" id="dsvlrprm_24" name="dsvlrprm"  size = "4" maxlength = "5" style="text-align:center;"/></td>
							</tr>
						</table>
					</fieldset>
				</td>
			</tr>
			
			<tr >
				<td style="width:95%;" align="center">
					<fieldset style="width:95%;" >
						<table style="width:95%;" >
							<tr>
								<td  class="txtNormalBold" style="width:40%;text-align:right;">
									 <label for="dsvlrprm_25 align = "right" style="width:100%;">Baixa opera&ccedil;&atilde;o fraude:</label>
								</td>
								<td><input  type="text" class="campo" id="dsvlrprm_25" name="dsvlrprm"  size = "4" maxlength = "5" style="text-align:center;"/></td>
								
							</tr>
							<tr>
								<td>&nbsp;</td>
							</tr>
							
						</table>
					</fieldset>
				</td>
			</tr>
		</table>
	<!--/fieldset-->

</form>
