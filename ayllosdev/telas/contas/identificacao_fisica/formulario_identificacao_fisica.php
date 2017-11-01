<? 
/*!
 * FONTE        : formulario_identificacao_fisica.php
 * CRIAÇÃO      : Rodolpho Telmo (DB1)
 * DATA CRIAÇÃO : Janeiro/2010 
 * OBJETIVO     : Fomulário de dados de Identificação Física        
 * --------------
 * ALTERAÇÕES   :
 * --------------
 * 001: [09/02/2010] Rodolpho Telmo  (DB1): Alterado campos que são habilitados/desabilitados quando o titular da conta é o primeiro titular ou não.
 * 002: [10/02/2010] Rodolpho Telmo  (DB1): Criado função na saída do CPF buscando informações do titular
 * 003: [12/02/2010] Rodolpho Telmo  (DB1): Criação da função incluiMascaras()
 * 004: [25/03/2010] Rodolpho Telmo  (DB1): Apagada funções antigas e adequado a tela ao novo padrão
 * 005: [13/04/2010] Rodolpho Telmo  (DB1): Inserção da propriedade maxlength nos inputs
 * 006: [24/05/2012] Adriano 			  : Ajustes referente ao projeto GP - Sócios Menores
 * 007: [09/08/2013] Jean Michel		  : Inclusão de botão Dossiê
 * 008: [23/08/2013] David                : Incluir campo UF Naturalidade - cdufnatu
 * 009: [23/10/2013] Jean Michek          : Alteração do link do botão Dossiê
 * 010: [12/08/2015] Gabriel (RKAM)       : Reformulacao cadastral
 * 011: [27/03/2017] Reinert			  : Alterado botão "Dossie DigiDOC" para chamar rotina do Oracle. (Projeto 357)
 * 012: [20/04/0217] Adriano	          : Ajuste para retirar o uso de campos removidos da tabela crapass, crapttl, crapjur e 
    							            ajuste devido ao aumento do formato para os campos crapass.nrdocptl, crapttl.nrdocttl, 
			                                crapcje.nrdoccje, crapcrl.nridenti e crapavt.nrdocava. 
 * 013: [25/04/2017] Odirlei(AMcom)	      : Alterado campo dsnacion para cdnacion. (Projeto 339)
 * 014: [25/09/2017] Kelvin               : Adicionado uma lista de valores para carregar orgao emissor (PRJ339). 
 * 015: [28/08/2017] Lucas Reinert		  : Alterado tipos de documento para utilizarem CI, CN, 
 *										    CH, RE, PP E CT. (PRJ339 - Reinert)
 */	
?>
<form name="frmDadosIdentFisica" id="frmDadosIdentFisica" class="formulario condensado">
	
	<input type="hidden" id="nrctattl" name="nrctattl" value="<? echo getByTagName($IdentFisica,'nrctattl') ?>" />
	<input type="hidden" id="cdnatopc" name="cdnatopc" value="<? echo getByTagName($IdentFisica,'cdnatopc') ?>" />
	<input type="hidden" id="cdocpttl" name="cdocpttl" value="<? echo getByTagName($IdentFisica,'cdocpttl') ?>" />
	<input type="hidden" id="tpcttrab" name="tpcttrab" value="<? echo getByTagName($IdentFisica,'tpcttrab') ?>" />
	<input type="hidden" id="nmextemp" name="nmextemp" value="<? echo getByTagName($IdentFisica,'nmextemp') ?>" />
	<input type="hidden" id="nrcpfemp" name="nrcpfemp" value="<? echo getByTagName($IdentFisica,'nrcpfemp') ?>" />
	<input type="hidden" id="dsproftl" name="dsproftl" value="<? echo getByTagName($IdentFisica,'dsproftl') ?>" />
	<input type="hidden" id="cdnvlcgo" name="cdnvlcgo" value="<? echo getByTagName($IdentFisica,'cdnvlcgo') ?>" />
	<input type="hidden" id="cdturnos" name="cdturnos" value="<? echo getByTagName($IdentFisica,'cdturnos') ?>" />
	<input type="hidden" id="dtadmemp" name="dtadmemp" value="<? echo getByTagName($IdentFisica,'dtadmemp') ?>" />
	<input type="hidden" id="vlsalari" name="vlsalari" value="<? echo getByTagName($IdentFisica,'vlsalari') ?>" />	
	<input type="hidden" id="nmcertif" name="nmcertif" value="<? echo getByTagName($IdentFisica,'nmcertif') ?>" />
	
	
	<fieldset>
		<legend><? echo utf8ToHtml('Identificação') ?></legend>

		<label for="cdgraupr">Relacionamento com o primeiro titular:</label>
		<select name="cdgraupr" id="cdgraupr">
			<option value=""> - </option>
			<option value="0" <? if (getByTagName($IdentFisica,'cdgraupr') == "0"){ echo " selected"; } ?>>0 - PRIMEIRO TITULAR</option>
			<option value="1" <? if (getByTagName($IdentFisica,'cdgraupr') == "1"){ echo " selected"; } ?>><? echo utf8ToHtml('1 - CÔNJUGE') ?></option>
			<option value="2" <? if (getByTagName($IdentFisica,'cdgraupr') == "2"){ echo " selected"; } ?>><? echo utf8ToHtml('2 - PAI / MÃE') ?></option>
			<option value="3" <? if (getByTagName($IdentFisica,'cdgraupr') == "3"){ echo " selected"; } ?>>3 - FILHO(A)</option>
			<option value="4" <? if (getByTagName($IdentFisica,'cdgraupr') == "4"){ echo " selected"; } ?>>4 - COMPANHEIRO(A)</option>
			<option value="6" <? if (getByTagName($IdentFisica,'cdgraupr') == "6"){ echo " selected"; } ?>>6 - COOPERADO(A)</option>													
		</select>	
		
		<label for="nrcpfcgc">C.P.F.:</label>
		<input name="nrcpfcgc" id="nrcpfcgc" type="text" value="<? echo getByTagName($IdentFisica,'nrcpfcgc') ?>" />
		<br />
		
		<label for="nmextttl">Titular:</label>
		<input name="nmextttl" id="nmextttl" type="text" value="<? echo getByTagName($IdentFisica,'nmextttl') ?>" />
		<br />				
		
		<label for="cdsitcpf"><? echo utf8ToHtml('Situação:') ?></label>
		<select id="cdsitcpf" name="cdsitcpf">
			<option value=""> - </option>
			<option value="1" <? if (getByTagName($IdentFisica,'cdsitcpf') == "1"){ echo " selected"; } ?>>1 - REGULAR</option>
			<option value="2" <? if (getByTagName($IdentFisica,'cdsitcpf') == "2"){ echo " selected"; } ?>>2 - PENDENTE</option>
			<option value="3" <? if (getByTagName($IdentFisica,'cdsitcpf') == "3"){ echo " selected"; } ?>>3 - CANCELADO</option>
			<option value="4" <? if (getByTagName($IdentFisica,'cdsitcpf') == "4"){ echo " selected"; } ?>>4 - IRREGULAR</option>
			<option value="5" <? if (getByTagName($IdentFisica,'cdsitcpf') == "5"){ echo " selected"; } ?>>5 - SUSPENSO</option>
		</select>	
		
		<label for="dtcnscpf">Data Consulta:</label>
		<input name="dtcnscpf" id="dtcnscpf" type="text" value="<? echo getByTagName($IdentFisica,'dtcnscpf') ?>" />	
		
		<label for="inpessoa">Natureza:</label>
		<input name="inpessoa" id="inpessoa" type="text" value="<? echo getByTagName($IdentFisica,'inpessoa')." - ".getByTagName($IdentFisica,'dspessoa') ?>" />		
		<br />			

		<label for="tpdocttl">Documento:</label>
		<select name="tpdocttl" id="tpdocttl">
			<option value="" <? if (getByTagName($IdentFisica,'tpdocttl') == ""){ echo " selected"; } ?>> - </option> 
			<option value="CI" <? if (getByTagName($IdentFisica,'tpdocttl') == "CI"){ echo " selected"; } ?>>CI</option>
			<option value="CN" <? if (getByTagName($IdentFisica,'tpdocttl') == "CN"){ echo " selected"; } ?>>CN</option>
			<option value="CH" <? if (getByTagName($IdentFisica,'tpdocttl') == "CH"){ echo " selected"; } ?>>CH</option>
			<option value="RE" <? if (getByTagName($IdentFisica,'tpdocttl') == "RE"){ echo " selected"; } ?>>RE</option>
			<option value="PP" <? if (getByTagName($IdentFisica,'tpdocttl') == "PP"){ echo " selected"; } ?>>PP</option>
			<option value="CT" <? if (getByTagName($IdentFisica,'tpdocttl') == "CT"){ echo " selected"; } ?>>CT</option>
		</select>
		<input name="nrdocttl" id="nrdocttl" type="text" value="<? echo getByTagName($IdentFisica,'nrdocttl') ?>" />

		<br />

		<label for="cdoedttl">Org. Emi.:</label>
		<input name="cdoedttl" id="cdoedttl" type="text" value="<? echo getByTagName($IdentFisica,'cdoedttl') ?>" />	
		<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
        <input name="nmoedttl" id="nmoedttl" type="text" style="display:none;" />
		
		<label for="cdufdttl" class="rotulo-linha">U.F.:</label>
		<? echo selectEstado('cdufdttl', getByTagName($IdentFisica,'cdufdttl'),1) ?>
		
		<label for="dtemdttl">Data Emi.:</label>
		<input name="dtemdttl" id="dtemdttl" type="text" value="<? echo getByTagName($IdentFisica,'dtemdttl') ?>" />	
	
	</fieldset>
	
	
	<fieldset>
		<legend>Perfil</legend>	
	
		<label for="tpnacion">Tipo Nacion.:</label>
		<input name="tpnacion" id="tpnacion" type="text" class="codigo pesquisa" value="<? echo getByTagName($IdentFisica,'tpnacion') ?>" />
		<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
		<input name="destpnac" id="destpnac" type="text" value="<? echo getByTagName($IdentFisica,'destpnac') ?>" />
		<br />
		
        <label for="cdnacion">Nacional.:</label>
        <input name="cdnacion" id="cdnacion" type="text" maxlength="5" class="codigo pesquisa" value="<? echo getByTagName($IdentFisica,'cdnacion') ?>" />        
		<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
		<input name="dsnacion" id="dsnacion" type="text" maxlength="15" value="<? echo getByTagName($IdentFisica,'dsnacion') ?>" />
		
		<br />
		<label for="cdsexotl">Sexo:</label>
		<input name="cdsexotl" type="radio" class="radio" value="1" <? if (getByTagName($IdentFisica,'cdsexotl') == '1') { echo ' checked'; } ?> />
		<label for="sexoMas" class="radio">Masculino</label>
		<input name="cdsexotl" type="radio" class="radio" value="2" <? if (getByTagName($IdentFisica,'cdsexotl') == '2') { echo ' checked'; } ?> />
		<label for="sexoFem" class="radio">Feminino</label>
		<br />
		
		<label for="dsnatura">Naturalidade:</label>
		<input name="dsnatura" id="dsnatura" type="text" maxlength="25" value="<? echo getByTagName($IdentFisica,'dsnatura') ?>" />
		<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>	
		
		<label for="cdufnatu">U.F.:</label>
		<? echo selectEstado('cdufnatu', getByTagName($IdentFisica,'cdufnatu'), 1) ?>
		
		<label for="dtnasttl">Data Nascimento:</label>
		<input name="dtnasttl" id="dtnasttl" type="text" value="<? echo getByTagName($IdentFisica,'dtnasttl') ?>" />	
		<br />		
		
		<label for="inhabmen">Resp. Legal:</label>
		<select id="inhabmen" name="inhabmen">
			<option value=""> - </option>
			<option value="0" <? if (getByTagName($IdentFisica,'inhabmen') == '0'){ echo ' selected'; } ?>> 0 - MENOR / MAIOR</option>
			<option value="1" <? if (getByTagName($IdentFisica,'inhabmen') == '1'){ echo ' selected'; } ?>> 1 - MENOR HABILITADO</option>
			<option value="2" <? if (getByTagName($IdentFisica,'inhabmen') == '2'){ echo ' selected'; } ?>> 2 - INCAPACIDADE CIVIL</option>
		</select>	

		<label for="dthabmen"><? echo utf8ToHtml('Data Emancipação:') ?></label>
		<input name="dthabmen" id="dthabmen" type="text" value="<? echo getByTagName($IdentFisica,'dthabmen') ?>" />
		<br />
		
		<label for="cdestcvl">Estado Civil:</label>
		<input name="cdestcvl" id="cdestcvl" type="text" class="codigo pesquisa" value="<? echo getByTagName($IdentFisica,'cdestcvl') ?>" />
		<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
		<input name="dsestcvl" id="dsestcvl" type="text" value="<? echo getByTagName($IdentFisica,'dsestcvl') ?>" />
		<br />		

		<label for="grescola">Escolaridade:</label>
		<input name="grescola" id="grescola" type="text" class="codigo pesquisa" value="<? echo getByTagName($IdentFisica,'grescola') ?>" />
		<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
		<input name="dsescola" id="dsescola" type="text" value="<? echo getByTagName($IdentFisica,'dsescola') ?>" />
		<br />		

		<label for="cdfrmttl">Curso Sup.:</label>
		<input name="cdfrmttl" id="cdfrmttl" type="text" class="codigo pesquisa" value="<? echo getByTagName($IdentFisica,'cdfrmttl') ?>" />
		<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
		<input name="rsfrmttl" id="rsfrmttl" type="text" value="<? echo getByTagName($IdentFisica,'rsfrmttl') ?>" />

		<br />
		
		<label for="nmtalttl"><? echo utf8ToHtml('Nome Talão:') ?></label>
		<input name="nmtalttl" id="nmtalttl" type="text" value="<? echo getByTagName($IdentFisica,'nmtalttl') ?>" />
		
		<label for="qtfoltal" class="rotulo-linha"><? echo utf8ToHtml('Nr. Folhas Talão:') ?></label>
		<input name="qtfoltal" id="qtfoltal" type="text" value="<? echo getByTagName($IdentFisica,'qtfoltal') ?>" />					
	</fieldset>
</form>
	
<div id="divBotoes">

	<input type="image" id="btVoltar"  class="opConsulta" src="<? echo $UrlImagens; ?>botoes/voltar.gif"  onClick="fechaRotina(divRotina)" />
	<input type="image" id="btAlterar" class="opConsulta" src="<? echo $UrlImagens; ?>botoes/alterar.gif" onClick="aux_operacao = 'CA'; controlaOperacao('CA')" />
	<input type="image" id="btIncluir" class="opConsulta" src="<? echo $UrlImagens; ?>botoes/incluir.gif" onClick="aux_operacao = 'CI'; controlaOperacao('CI')" />		
	<input type="image" id="btDosie" class="opConsulta" src="<? echo $UrlImagens; ?>botoes/dossie.gif" onClick="dossieDigdoc(8);return false;"/>

	<?  if ($flgcadas != 'M')  { ?>
		<input type="image" id="btCancelarAlt"   class="opAlteracao opAlterar" src="<? echo $UrlImagens; ?>botoes/cancelar.gif"	  onClick="controlaOperacao('AC')" />		
		<input type="image" id="btProsseguirAlt" class="opAlterar" 	  		   src="<? echo $UrlImagens; ?>botoes/prosseguir.gif" onClick=""/>	
		<input type="image" id="btConcluirAlt"   class="opAlteracao"		   src="<? echo $UrlImagens; ?>botoes/concluir.gif"	  onClick=""/>	
	<? } else { ?>
		<input type="image" id="btCancelarAlt"  class="opAlteracao opAlterar"  src="<? echo $UrlImagens; ?>botoes/voltar.gif"    onClick="fechaRotina(divRotina);" />
	<? } ?>
	
	<input type="image" id="btContinuar"  class="opContinuar" src="<? echo $UrlImagens; ?>botoes/continuar.gif" onClick="controlaContinuar();"  />
	
	<input type="image" id="btCancelarInc"   class="opInclusao opIncluir"	src="<? echo $UrlImagens; ?>botoes/cancelar.gif"	onClick="aux_operacao = 'IC'; controlaOperacao('IC')" />			
	<input type="image" id="btLimparInc"     class="opInclusao"				src="<? echo $UrlImagens; ?>botoes/limpar.gif"		onClick="aux_operacao = 'CI'; controlaOperacao('CI')" />
	<input type="image" id="btProsseguirInc" class="opIncluir" 			    src="<? echo $UrlImagens; ?>botoes/prosseguir.gif"	onClick="keypressCPF()"/>			
	<input type="image" id="btConcluirInc"   class="opInclusao"			    src="<? echo $UrlImagens; ?>botoes/concluir.gif"	onClick="controlaOperacao('IV')"/>
	
	
</div>		