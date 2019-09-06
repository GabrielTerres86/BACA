<div id="divFiltroGrid">
	<form id="frmFiltroGrid" name="frmFiltroGrid" class="formulario" style="display:block;">

		<table width="100%">
			<tr>
				<td>
					<label for="cddgrupo" class="txtNormalBold" style="width:265px">Grupo:</label>
					<input type="text" id="cddgrupo" class="campo" name="cddgrupo" value="<? echo $cddgrupo == 0 ? '' : $cddgrupo ?>"
					 style="width:90px">
					<a style="padding: 3px 0 0 3px;" href="#" onClick="filtro.controlaPesquisa('G');return false;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"/></a>
					<input type="text" class="campoTelaSemBorda" disabled readonly name="dsdgrupo" id="dsdgrupo" value="<? echo $dsdgrupo; ?>" style="width:460px">
				</td>
			</tr>
			<tr>
				<td>
					<label for="cdtarifa" class="txtNormalBold" style="width:265px">Tarifa:</label>
					<input type="text" id="cdtarifa" class="campo" name="cdtarifa" value="<? echo $cdtarifa == 0 ? '' : $cdtarifa ?>" style="width:90px">	
					<a style="padding: 3px 0 0 3px;" href="#" onClick="filtro.controlaPesquisa('T');return false;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"/></a>
					<input type="text" class="campoTelaSemBorda" disabled readonly name="dstarifa" id="dstarifa"  value="<? echo $dstarifa; ?>" style="width:460px">
				</td>
			</tr>
			<tr id="linha-convenio" style="display:none">
				<td>
					<label for="nrconven" class="txtNormalBold" style="width:265px">Conv&ecirc;nio:</label>
					<input type="text" id="nrconven" class="campo" name="nrconven" value="<? echo $nrconven == 0 ? '' : $nrconven ?>" style="width:550px">	
					<a style="padding: 3px 0 0 3px;" href="#" onClick="filtro.controlaPesquisa('C');return false;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"/></a>
				</td>
			</tr>
			<tr id="linha-credito" style="display:none">
				<td>
					<label for="cdlcremp" class="txtNormalBold" style="width:265px">Linha de Cr&eacute;dito:</label>
					<input type="text" id="cdlcremp" class="campo" name="cdlcremp" value="<? echo $cdlcremp == 0 ? '' : $cdlcremp ?>" style="width:550px">	
					<a style="padding: 3px 0 0 3px;" href="#" onClick="filtro.controlaPesquisa('L');return false;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"/></a>
				</td>
			</tr>
		</table>

		<br style="clear:both" />

		<hr style="background-color:#666; height:1px;" />

		<div id="divBotoes" style="margin-bottom: 10px;">
			<a href="#" class="botao" id="btVoltar" onClick="estadoInicial();">Voltar</a>
			<a href="#" class="botao" id="btProsseguir" onClick="filtro.onClick_Prosseguir();">Prosseguir</a>
		</div>

	</form>
</div>