<?
/*!
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Rogerius Militão (DB1)
 * DATA CRIAÇÃO : 25/10/2011
 * OBJETIVO     : Cabeçalho para a tela BCAIXA
 * --------------
 * ALTERAÇÕES   : 16/04/2013 - Ajustes de layout no combo-box de consulta.
							 - Incluir novo label tpcaicof (Lucas R.)
				  12/08/2013 - Alteração da sigla PAC para PA. (Carlos)
				  18/02/2015 - Incluir <option value="TOTAL"> TOTAL </option> no span panelTpcaicof (Lucas R. #245838 ) 
 * --------------
 */
 
 	 
?>
<script language="javascript"> 

function mudaFoco(opcao){
	switch(opcao)
	{
		case "T":
		  $("#cdagenci").focus();
		  $("#panelTpcaicof").css('visibility','visible');
		  $("#tpcaicof").val('CAIXA');
		  break;
		default:
		  $("#dtmvtolt").focus();
		  $("#panelTpcaicof").css({'visibility':'hidden'});
	}
}

</script>

<form id="frmCab" name="frmCab" class="formulario cabecalho" onSubmit="return false;" >
	<table width = "100%">
		<tr>
			<td>
				<label for="cddopcao"><? echo utf8ToHtml('Opção:') ?></label>	
				<select id="cddopcao" name="cddopcao"  onChange="valorInicial(); formataCabecalho(this.value); mudaFoco($(this).val());">
					<option value="C">C - Consultar o boletim de caixa </option>
					<option value="F">F - Fechar o boletim de caixa </option>
					<option value="I">I - Abrir o boletim de caixa </option>
					<option value="K">K - Reabrir o boletim de caixa </option>
					<option value="L">L - Efetuar lancamentos extra-caixa </option>
					<option value="S">S - Visualizar por PA, saldos iniciais e finais dos caixas </option>
					<option value="T">T - Visualizar por PA, saldos dos caixas e total do PA </option>
				</select>
				
			</td>
		</tr>
	</table>
	
	<label for="dtmvtolt">Data:</label>
	<input name="dtmvtolt" id="dtmvtolt" type="text"  />	
	
	<label for="cdagenci">PA:</label>
	<input type="text" id="cdagenci" name="cdagenci" />

	<label for="nrdcaixa">Caixa:</label>
	<input type="text" id="nrdcaixa" name="nrdcaixa" />

	<label for="cdopecxa">Operador:</label>
	<input type="text" id="cdopecxa" name="cdopecxa" />
	
	<span id="panelTpcaicof">
		<label for="tpcaicof">Tipo:</label>
		<select id="tpcaicof" name="tpcaicof"onChange="changeTpcaicof($(this).val())">
			<option value="CAIXA"> CAIXA </option>
			<option value="COFRE"> COFRE </option>
			<option value="TOTAL"> TOTAL </option>
		</select>
	</span>
	
	
	
	<br style="clear:both" />	
	
</form>
