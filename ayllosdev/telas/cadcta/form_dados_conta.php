<? 
/*!
 * FONTE        : form_dados_conta.php
 * CRIAÇÃO      : Mateus Zimmermann (Mouts)
 * DATA CRIAÇÃO : 09/10/2017 
 * OBJETIVO     : Fomulário de dados de Identificação Física        
 * --------------
 * ALTERAÇÕES   :
 * --------------
 *
 */	

//recupera tag com a conta consorcio
$vr_nrctacns = getByTagName($registro,'nrctacns');

?>
<form name="frmCadcta" id="frmCadcta" class="formulario condensado">

	<label for="cdbcochq">Banco Emissor de Cheque:</label>
	<input name="cdbcochq" id="cdbcochq" type="text" value="<? echo getByTagName($registro,'cdbcochq') ?>" />

	<label for="cdconsultor">Consultor:</label>
	<input name="cdconsultor" id="cdconsultor" type="text" value="<? echo $cdconsul ?>"/>
	<a><img src="<?php echo $UrlImagens; ?>geral/ico_lupa.gif" width="14" height="14" border="0"></a>
	<input name="nmconsultor" id="nmconsultor" type="text" value="<? echo $nmconsul ?>"/>

	<br />

	<label for="cdbcoitg">Bco. ITG:</label>
	<input name="cdbcoitg" id="cdbcoitg" type="text" value="<? echo getByTagName($registro,'cdbcoitg') ?>" />	

	<label for="cdagedbb">Age. ITG:</label>
	<input name="cdagedbb" id="cdagedbb" type="text" value="<? echo getByTagName($registro,'cdagedbb') ?>" />

	<label for="nrdctitg">Conta/ITG:</label>
	<input name="nrdctitg" id="nrdctitg" type="text" value="<? echo getByTagName($registro,'nrdctitg') ?>" />

	<label for="nrctacns"> Conta Consorcio: </label>
	<input name="nrctacns" id="nrctacns" type="text" value="<?php echo ( $vr_nrctacns > 0 ) ? formataContaDVsimples($vr_nrctacns) : ''; ?>" />		

	</br>
	<hr />        

	<label for="incadpos"> Cadastro Positivo: </label>
	<select name="incadpos" id="incadpos">
		<option value="1" <?php if (getByTagName($registro,'dscadpos') == 'Nao Autorizado'){ echo " selected"; } ?>> <? echo utf8ToHtml('Não Autorizado') ?> </option>
		<option value="2" <?php if (getByTagName($registro,'dscadpos') == 'Autorizado'){ echo " selected"; } ?>> Autorizado</option>
		<option value="3" <?php if (getByTagName($registro,'dscadpos') == 'Cancelado'){ echo " selected"; } ?>> Cancelado</option>
	</select>

	<label for="flgiddep"><? echo utf8ToHtml('Identifica Depósito:') ?></label>
	<select name="flgiddep" id="flgiddep">
		<option value="1" <?php if (getByTagName($registro,'flgiddep') == "yes"){ echo " selected"; } ?>> Sim </option>
		<option value="0" <?php if (getByTagName($registro,'flgiddep') == "no"){ echo " selected"; } ?>> <? echo utf8ToHtml('Não') ?> </option>
	</select>

	<label for="flblqtal"><? echo utf8ToHtml('Blq.Entrega Talão:') ?></label>
	<select name="flblqtal" id="flblqtal">
		<option value="1" <?php if (getByTagName($registro,'flblqtal') == 1){ echo " selected"; } ?>> Sim </option>
		<option value="2" <?php if (getByTagName($registro,'flblqtal') == 0){ echo " selected"; } ?>> <? echo utf8ToHtml('Não') ?> </option>
	</select>        

	</br>

	<input name="cdsecext" id="cdsecext" type="hidden" value="<? echo getByTagName($registro,'cdsecext') ?>" />

	<label for="flgrestr">Grau de Acesso:</label>
	<select name="flgrestr" id="flgrestr">
		<option value="1" <?php if (getByTagName($registro,'flgrestr') == "yes"){ echo " selected"; } ?>> Restrito </option>
		<option value="0" <?php if (getByTagName($registro,'flgrestr') == "no"){ echo " selected"; } ?>> Liberado </option>
	</select>        

	<label for="indserma"><? echo utf8ToHtml('Serviço de Malote:'); ?> </label>
	<select name="indserma" id="indserma">
		<option value="1" <?php if (getByTagName($registro,'indserma') == "yes"){ echo " selected"; } ?>> Sim </option>
		<option value="0" <?php if (getByTagName($registro,'indserma') == "no"){ echo " selected"; } ?>> <? echo utf8ToHtml('Não') ?> </option>
	</select>    

	<label for="fldevchq"><? echo utf8ToHtml('Devolução Aut.Cheques:'); ?> </label>
	<select name="fldevchq" id="fldevchq">
		<option value="1" <?php if ($flgdevolu_autom == 1){ echo " selected"; } ?>> Sim </option>
		<option value="0" <?php if ($flgdevolu_autom == 0){ echo " selected"; } ?>> <? echo utf8ToHtml('Não') ?> </option>
	</select>    

	</br>
	<label for="inlbacen">Consulta CCF:</label>
	<select name="inlbacen" id="inlbacen">
		<option value="1" <?php if (getByTagName($registro,'inlbacen') == "1"){ echo " selected"; } ?>> Sim </option>
		<option value="0" <?php if (getByTagName($registro,'inlbacen') == "0"){ echo " selected"; } ?>> <? echo utf8ToHtml('Não') ?> </option>
	</select>    

	<label for="dtcnsscr">Consulta SCR:</label>
	<input name="dtcnsscr" id="dtcnsscr" type="text" value="<? echo getByTagName($registro,'dtcnsscr') ?>" />

	<input name="inadimpl" id="inadimpl" type="hidden" value="<? echo getByTagName($registro,'inadimpl') ?>" />
	<input name="dtcnsspc" id="dtcnsspc" type="hidden" value="<? echo getByTagName($registro,'dtcnsspc') ?>" />
	<input name="dtdsdspc" id="dtdsdspc" type="hidden" value="<? echo getByTagName($registro,'dtdsdspc') ?>" />	

	<label for="dtabtcta">Abertura Conta:</label>
	<input name="dtabtcta" id="dtabtcta" type="text" value="<? echo getByTagName($registro,'dtabtcct') ?>" />
	</br>

	<label for="dtadmiss">Admiss&atilde;o:</label>
	<input name="dtadmiss" id="dtadmiss" type="text" value="<? echo getByTagName($registro,'dtadmiss') ?>" />

	<label for="dtelimin"><? echo utf8ToHtml('Demissão:') ?></label>
	<input name="dtelimin" id="dtelimin" type="text" value="<? echo getByTagName($registro,'dtelimin') ?>" />		

	<label for="dtdemiss">Encerramento:</label>
	<input name="dtdemiss" id="dtdemiss" type="text" value="<? echo getByTagName($registro,'dtdemiss') ?>" />								
	<br />		
	<hr /> 	

	<label for="nmtalttl"><? echo utf8ToHtml('Nome Talão:') ?></label>
	<input name="nmtalttl" id="nmtalttl" type="text" value="<? echo getByTagName($identificacao,'nmtalttl') ?>" />

	<label for="qtfoltal" class="rotulo-linha"><? echo utf8ToHtml('Nr. Folhas Talão:') ?></label>
	<input name="qtfoltal" id="qtfoltal" type="text" value="<? echo getByTagName($identificacao,'qtfoltal') ?>" />	

	<br />
	<hr />

	<div class="pessoaFisica">
    
        <fieldset>
			<legend><? echo utf8ToHtml('Informações Profissionais') ?></legend>

			<label for="cdempres">Empresa:</label>
			<input name="cdempres" id="cdempres" type="text" value="<?php echo getByTagName($comercial,'cdempres') ?>" />
			<a><img src="<?php echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
			<input name="nmresemp" id="nmresemp" type="text" value="<?php echo getByTagName($comercial,'nmresemp') ?>" />
            
            <label for="cdnatopc"><?php echo utf8ToHtml('Nat. Ocupação:') ?></label>
            <input name="cdnatopc" id="cdnatopc" type="text" value="<?php echo getByTagName($comercial,'cdnatopc') ?>" />            
            <input name="rsnatocp" id="rsnatocp" type="text" value="<?php echo getByTagName($comercial,'rsnatocp') ?>" />
            <br />
            
            <label for="cdocpttl"><?php echo utf8ToHtml('Ocupação:') ?></label>
            <input name="cdocpttl" id="cdocpttl" type="text" value="<?php echo getByTagName($comercial,'cdocpttl') ?>" />            
            <input name="rsocupa" id="rsocupa" type="text" value="<?php echo getByTagName($comercial,'rsocupa') ?>" />
            
            
            <label for="tpcttrab">Tp. Ctr. Trab.:</label>
            <select name="tpcttrab" id="tpcttrab">
                <option value=""> - </option> 
                <option value="1" <?php if (getByTagName($comercial,'tpcttrab') == "1"){ echo " selected"; } ?>>1 - PERMANENTE</option>
                <option value="2" <?php if (getByTagName($comercial,'tpcttrab') == "2"){ echo " selected"; } ?>>2 - TEMP/TERCEIRO</option>
                <option value="3" <?php if (getByTagName($comercial,'tpcttrab') == "3"){ echo " selected"; } ?>>3 - SEM V&Iacute;NCULO</option>
                <option value="4" <?php if (getByTagName($comercial,'tpcttrab') == "4"){ echo " selected"; } ?>>4 - AUT&Ocirc;NOMO</option>
            </select>

			<br style="clear:both" />
		</fieldset>
    
		<fieldset>
			<legend><? echo utf8ToHtml('Rendas automáticas') ?></legend>

			<label for="dtrefere"><? echo utf8ToHtml('Referência:') ?> </label>
			<input name="dtrefere" id="dtrefere" type="text" value="<? echo $edDtrefere; ?>" />

			<label for="vltotmes">Valor total m&ecirc;s:</label>
			<input name="vltotmes" id="vltotmes" type="text" value="<? echo $edVlrefere; ?>" />

            <a href="#" onClick="abreTelaDetalheRendas();"><img src="<? echo $UrlImagens; ?>botoes/detalhar.gif"></img></a>

			<br style="clear:both" />
		</fieldset>

		<hr />
	</div>

	<fieldset>		

		<legend><? echo utf8ToHtml('Informações Adicionais') ?></legend>

		<label for="nrinfcad"><? echo utf8ToHtml('Informações cadastrais:') ?></label>
		<input name="nrinfcad" id="nrinfcad" type="text" value="<? echo getByTagName($infAdicionais,'nrinfcad'); ?>" />
		<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
		<input name="dsinfcad" id="dsinfcad" type="text" value="<? echo getByTagName($infAdicionais,'dsinfcad'); ?>" />
		<br />

		<label for="nrpatlvr"><? echo utf8ToHtml('Patrimônio pessoal livre em relação ao endividamento:') ?></label>
		<input name="nrpatlvr" id="nrpatlvr" type="text" value="<? echo getByTagName($infAdicionais,'nrpatlvr'); ?>" />
		<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
		<input name="dspatlvr" id="dspatlvr" type="text" value="<? echo getByTagName($infAdicionais,'dspatlvr'); ?>" />
		<br />
        
        <div id="divJuridico" class="pessoaJuridica">
			<label for="nrperger"><? echo utf8ToHtml('Percepção geral com relação a empresa:'); ?></label><br />
			<input name="nrperger" id="nrperger" type="text" value="<? echo getByTagName($infAdicionais,'nrperger'); ?>" />
			<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
			<input name="dsperger" id="dsperger" type="text" value="<? echo getByTagName($infAdicionais,'dsperger'); ?>" />
			<br />
			
		</div>	

		<label for="dsinfadi"><? echo utf8ToHtml('Informações complementares:') ?></label><br />
		<textarea name="dsinfadi" id="dsinfadi" cols="74" rows="5"><? echo juntaTexto($textareaTags) ?></textarea>

	</fieldset>  

	<hr />

	<div id="divBotoes"> 		
		<a href="#" class="botao" id="btCancelar" onclick="controlaOpeCadcta('CA'); return false;">Cancelar</a>
		<a href="#" class="botao" id="btSalvar" onclick="controlaOpeCadcta('AV'); return false;">Concluir</a>
		<a href="#" class="botao" id="btAlterar" onclick="controlaOpeCadcta('A'); return false;">Alterar</a>
		<a href="#" class="botao" id="btContinuar" onclick="proximaRotina(); return false;">Continuar</a>
		<a href="#" class="botao" id="btImpressoes" onclick="abreTelaImpressoes(); return false;"><? echo utf8ToHtml('Impressões') ?></a>
		<a href="#" class="botao" id="btGrEconomico" onclick="abreTelaGrEconomico(); return false;"><? echo utf8ToHtml('Gr. Econômico') ?></a>
        <a href="#" class="botao" id="btDosie" onclick="dossieDigidoc();return false;"><? echo utf8ToHtml('Dossiê DigiDOC') ?></a>        
		<a href="#" class="botao pessoaJuridica" id="btImunidadeTributaria" onclick="abreTelaImunidadeTributaria(); return false;"><? echo utf8ToHtml('Imunidade Tribut.') ?></a>
		<div style="margin-top:5px;"></div>
		<a href="#" class="botao" id="btClienteFinanceiro" onclick="abreTelaClienteFinanceiro(); return false;">Cliente Financeiro</a>
		<a href="#" class="botao" id="btOrgaosProtecaoCredito" onclick="abreTelaOrgaosProtecaoCredito(); return false;"><? echo utf8ToHtml('Órgãos de Proteção ao Crédito') ?></a>
		<a href="#" class="botao" id="btImpedimentosDesligamento" onclick="abreTelaImpedimentoDesligamento(); return false;">Impedimento Desligamento</a>
	</div>	
</form>