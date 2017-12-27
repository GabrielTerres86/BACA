<? 
/*!
 * FONTE        : formulario_conjuge.php
 * CRIAÇÃO      : Gabriel C. Santos (DB1)
 * DATA CRIAÇÃO : 04/03/2010 
 * OBJETIVO     : Formulário de dados de CÔNJUGE da tela de CONTAS
 * --------------
 * ALTERAÇÕES   :
 * --------------
 * 001: [13/04/2010] Rodolpho Telmo (DB1): Inserção da propriedade maxlength nos inputs
 * 002: [24/08/2015] Gabriel (RKAM)      : Reformulacao Cadastral (Gabriel)
 * 003: [13/06/2017] Adrian: Ajuste devido ao aumento do formato para os campos crapass.nrdocptl, crapttl.nrdocttl, 
			                 crapcje.nrdoccje, crapcrl.nridenti e crapavt.nrdocava.
 * 004: [25/09/2017] Kelvin              : Adicionado uma lista de valores para carregar orgao emissor (PRJ339).
 * 005: [28/08/2017] Lucas Reinert		 : Alterado tipos de documento para utilizarem CI, CN, 
 *              						   CH, RE, PP E CT. (PRJ339 - Reinert)
 */	
?>

<form name="frmDadosConjuge" id="frmDadosConjuge" class="formulario">
	
	<fieldset>
		<legend><? echo utf8ToHtml('Identificação') ?></legend>
	
		<label for="nrctacje">Conta/dv:</label>
		<input name="nrctacje" id="nrctacje" type="text" value="<? echo getByTagName($conjuge,'nrctacje') ?>" />
		<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
		
		<label for="nrcpfcjg">CPF:</label>
		<input name="nrcpfcjg" id="nrcpfcjg" type="text" value="<? echo getByTagName($conjuge,'nrcpfcjg') ?>" />
		<br />
		
		<label for="nmconjug">Nome:</label>
		<input name="nmconjug" id="nmconjug" type="text" value="<? echo getByTagName($conjuge,'nmconjug') ?>" />
		
		<label for="dtnasccj">Dt. Nasc.:</label>
		<input name="dtnasccj" id="dtnasccj" type="text" value="<? echo getByTagName($conjuge,'dtnasccj') ?>" />
		<br />
		
		<label for="tpdoccje">Documento:</label>
		<select name="tpdoccje" id="tpdoccje">
			<option value=""   <? if (getByTagName($conjuge,'tpdoccje') == ""  ){ echo " selected"; } ?>> - </option> 
			<option value="CI" <? if (getByTagName($conjuge,'tpdoccje') == "CI"){ echo " selected"; } ?>>CI</option>
			<option value="CN" <? if (getByTagName($conjuge,'tpdoccje') == "CN"){ echo " selected"; } ?>>CN</option>
			<option value="CH" <? if (getByTagName($conjuge,'tpdoccje') == "CH"){ echo " selected"; } ?>>CH</option>
			<option value="RE" <? if (getByTagName($conjuge,'tpdoccje') == "RE"){ echo " selected"; } ?>>RE</option>
			<option value="PP" <? if (getByTagName($conjuge,'tpdoccje') == "PP"){ echo " selected"; } ?>>PP</option>
			<option value="CT" <? if (getByTagName($conjuge,'tpdoccje') == "CT"){ echo " selected"; } ?>>CT</option>
		</select>
		<input name="nrdoccje" id="nrdoccje" type="text" value="<? echo getByTagName($conjuge,'nrdoccje') ?>" />
		
		<br />
		
		<label for="cdoedcje">Org.Emi.:</label>
		<input name="cdoedcje" id="cdoedcje" type="text" value="<? echo getByTagName($conjuge,'cdoedcje') ?>" />
		<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
        <input name="nmoedcje" id="nmoedcje" type="text" style="display:none;" />
					
		<label for="cdufdcje">U.F.:</label>
		<? echo selectEstado('cdufdcje', getByTagName($conjuge,'cdufdcje'), 1) ?>
		
		<label for="dtemdcje">Dt. Emi.:</label>
		<input name="dtemdcje" id="dtemdcje" type="text" value="<? echo getByTagName($conjuge,'dtemdcje') ?>" />
	</fieldset>
	
	<fieldset>
		<legend>Perfil</legend>
	
		<label for="grescola">Escolaridade:</label>
		<input name="grescola" id="grescola" type="text" value="<? echo getByTagName($conjuge,'grescola') ?>" />
		<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
		<input name="dsescola" id="dsescola" type="text" value="<? echo getByTagName($conjuge,'dsescola') ?>" />
		
		<label for="cdfrmttl">Curso Sup.:</label>
		<input name="cdfrmttl" id="cdfrmttl" type="text" value="<? echo getByTagName($conjuge,'cdfrmttl') ?>" />
		<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
		<input name="rsfrmttl" id="rsfrmttl" type="text" value="<? echo getByTagName($conjuge,'rsfrmttl') ?>" />
		<br />
		
		<label for="cdnatopc"><? echo utf8ToHtml('Nat. Ocupação:') ?></label>
		<input name="cdnatopc" id="cdnatopc" type="text" value="<? echo getByTagName($conjuge,'cdnatopc') ?>" />
		<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
		<input name="rsnatocp" id="rsnatocp" type="text" value="<? echo getByTagName($conjuge,'rsnatocp') ?>" />
		
		<label for="cdocpcje"><? echo utf8ToHtml('Ocupação:') ?></label>
		<input name="cdocpcje" id="cdocpcje" type="text" value="<? echo getByTagName($conjuge,'cdocpcje') ?>" />
		<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
		<input name="rsdocupa" id="rsdocupa" type="text" value="<? echo getByTagName($conjuge,'rsdocupa') ?>" />
	</fieldset>
	
	<fieldset>
		<legend>Inf. Profissionais</legend>
	
		<label for="tpcttrab">Tp. Ctr. Trab.:</label>
		<select name="tpcttrab" id='tpcttrab'>
			<option value=""> - </option> 
			<option value="1" <? if (getByTagName($conjuge,'tpcttrab') == "1"){ echo " selected"; } ?>>1 - PERMANENTE</option>
			<option value="2" <? if (getByTagName($conjuge,'tpcttrab') == "2"){ echo " selected"; } ?>>2 - TEMP/TERCEIRO</option>
			<option value="3" <? if (getByTagName($conjuge,'tpcttrab') == "3"){ echo " selected"; } ?>>3 - SEM V&Iacute;NCULO</option>
		</select>
		
		<br>
		
		<label for="nrdocnpj">C.N.P.J.:</label>
		<input name="nrdocnpj" id="nrdocnpj" type="text" onfocusout="buscaNomePessoa(); $('#nmextemp', '#frmDadosConjuge').focus();" value="<? echo getByTagName($conjuge,'nrdocnpj') ?>" />
				
		<label for="nmextemp">Empresa:</label>
		<input name="nmextemp" id="nmextemp" type="text" value="<? echo getByTagName($conjuge,'nmextemp') ?>" />
		<br />
		
		
		<label for="dsproftl"><? echo utf8ToHtml('Cargo:') ?></label>
		<input name="dsproftl" id="dsproftl" type="text" value="<? echo getByTagName($conjuge,'dsproftl') ?>" />
		<br />
		
		<label for="cdnvlcgo"><? echo utf8ToHtml('Nível Cargo:') ?></label>
		<select name="cdnvlcgo" id="cdnvlcgo">
			<option value="" selected> - </option>
		</select>
		
		<label for="nrfonemp">Tel. Com.:</label>
		<input name="nrfonemp" id="nrfonemp" type="text" onKeyUp="telefone(this)" value="<? echo (strlen(getByTagName($conjuge,'nrfonemp')) > 9 && strlen(getByTagName($conjuge,'nrfonemp')) < 12 ) ? telefone(getByTagName($conjuge,'nrfonemp')) : '' ?>" />
		
		<label for="nrramemp">Ramal:</label>
		<input name="nrramemp" id="nrramemp" type="text" value="<? echo getByTagName($conjuge,'nrramemp') ?>" />
		<br />
		
		<label for="cdturnos">Turno:</label>
		<select name="cdturnos" id="cdturnos">
			<option value="" selected> - </option>
		</select>
		
		<label for="dtadmemp">Dt. Adm.:</label>
		<input name="dtadmemp" id="dtadmemp" type="text" value="<? echo getByTagName($conjuge,'dtadmemp') ?>" />
		
		<label for="vlsalari">Rendim.:</label>
		<input name="vlsalari" id="vlsalari" type="text" value="<? echo getByTagName($conjuge,'vlsalari') ?>" />
	</fieldset>
</form>

<div id="divBotoes">		
	<? if ( ($operacao == 'CF') || ($operacao == '')) { ?>
		<input type="image" id="btVoltar"  src="<? echo $UrlImagens; ?>botoes/voltar.gif"   onClick="fechaRotina(divRotina);" />
		<input type="image" id="btAlterar" src="<? echo $UrlImagens; ?>botoes/alterar.gif"  onClick="controlaOperacao('CA');" />
	<? } else if ( (($operacao == 'CA')  || ($operacao == 'CB')) && $flgcadas != 'M' ) { ?>
		<input type="image" id="btVoltar"  src="<? echo $UrlImagens; ?>botoes/voltar.gif"   onClick="controlaOperacao('AC');" />		
		<input type="image" id="btLimpar"  src="<? echo $UrlImagens; ?>botoes/limpar.gif"	onClick="estadoInicial();" />		
		<input type="image" id="btSalvar"  src="<? echo $UrlImagens; ?>botoes/concluir.gif" onClick="controlaOperacao('AV');" />
	<? } else if ($flgcadas == 'M') { ?>
		<input type="image" id="btVoltar"  src="<? echo $UrlImagens; ?>botoes/voltar.gif"   onClick="voltarRotina();" />		
		<input type="image" id="btLimpar"  src="<? echo $UrlImagens; ?>botoes/limpar.gif"	onClick="estadoInicial();" />		
	<? } else if ( $operacao == 'SC' ){?>
		<input type="image" id="btVoltar"  src="<? echo $UrlImagens; ?>botoes/voltar.gif"   onClick="fechaRotina(divRotina);" />
	<?}?>
	<input type="image" id="btContinuar"  src="<? echo $UrlImagens; ?>botoes/continuar.gif" onClick="controlaContinuar();" />

</div>
<?php	
	function telefone($numero) {
		if (strlen($numero) == 10)
			$fone = preg_replace('/^(\\d\\d)(\\d{4})(\\d{4})$/','(\1) \2-\3',$numero, 1);
		else
			$fone = preg_replace('/^(\\d\\d)(\\d{5})(\\d{4})$/','(\1) \2-\3',$numero, 1);		
		return substr($fone,0, 15);
	}
?>