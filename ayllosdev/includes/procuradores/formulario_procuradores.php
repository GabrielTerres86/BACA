<?
/*!
 * FONTE        : formulario_procuradores.php
 * CRIAÇÃO      : Alexandre Scola - DB1 Informatica
 * DATA CRIAÇÃO : 09/03/2010 
 * OBJETIVO     : Forumlário de dados de Representantes/Procuradores para alteração
  * --------------
 * ALTERAÇÕES   :
 * --------------
 * 001: [13/04/2010] Rodolpho Telmo  (DB1): Inserção da propriedade maxlength nos inputs
 * 000: [25/04/2011] Adicionado pesquisa CEP. ( Rodolpho/Rogérius. (DB1) ).
 * 002: [22/08/2011] Alterações projeto Grupo Econômico (Guilherme).
 * 003: [24/11/2011] Removido frame de Outros Rendimentos. (Fabricio)
 * 004: [01/06/2012] Ajustes referente ao projeto GP - Sócios Menores. ( Adriano).
 * 005: [19/02/2015] Incluir campo hidden fltemcrd, para controle de cartões, conforme SD 251759 ( Renato - Supero )
 * 006: [22/09/2015] Reformulacao cadastral (Gabriel-RKAM).
 * 007: [25/04/2017] Alterado campo dsnacion para cdnacion. (Projeto 339 - Odirlei-AMcom)
 * 008: [12/06/2017] Ajuste devido ao aumento do formato para os campos crapass.nrdocptl, crapttl.nrdocttl, 
			         crapcje.nrdoccje, crapcrl.nridenti e crapavt.nrdocava (Adriano - P339).
 * 009: [31/07/2017] Aumentado campo dsnatura de 25 para 50, PRJ339-CRM (Odirlei-AMcom).
 * 010: [28/08/2017] Alterado tipos de documento para utilizarem CI, CN, CH, RE, PP E CT. (PRJ339 - Reinert)
 * 011: [24/10/2017] Remocao da caixa postal. (PRJ339 - Kelvin).
 */	
 
?>
	
<div id="divProcuradores">
	
	<form name="frmDadosProcuradores" id="frmDadosProcuradores" class="formulario condensado" >		
		<fieldset>
			<legend><? echo utf8ToHtml('Identificação') ?></legend>		

			<input type="hidden" id="nrdconta" name="nrdconta" value="<? echo $frm_nrdconta; ?>" />
			<input type="hidden" id="fltemcrd" name="fltemcrd" value="<? echo $frm_fltemcrd; ?>" />
			
			<label for="nrdctato" class="rotulo rotulo-80">Conta/dv:</label>
			<input name="nrdctato" id="nrdctato" type="text" value="<? echo $frm_nrdctato; ?>" />
			<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
			
			<label for="nrcpfcgc" style="width:256px">C.P.F.:</label>
			<input name="nrcpfcgc" id="nrcpfcgc" type="text" value="<? echo $frm_nrcpfcgc; ?>" />
			<br />
			
			<label for="nmdavali" class="rotulo rotulo-80">Nome:</label>
			<input name="nmdavali" id="nmdavali" type="text" value="<? echo $frm_nmdavali; ?>" />
			
			<label for="dtnascto" style="width:56px;">Dt. Nasc.:</label>
			<input name="dtnascto" id="dtnascto" type="text" value="<? echo $frm_dtnascto; ?>" />
			<br />
			
			<label for="inhabmen" class="rotulo rotulo-80">Resp. Legal:</label>
			<select id="inhabmen" name="inhabmen">
				<option value=""> - </option>
				<option value="0" <? if ($frm_inhabmen == '0'){ echo ' selected'; } ?>> 0 - MENOR / MAIOR</option>
				<option value="1" <? if ($frm_inhabmen == '1'){ echo ' selected'; } ?>> 1 - MENOR HABILITADO</option>
				<option value="2" <? if ($frm_inhabmen == '2'){ echo ' selected'; } ?>> 2 - INCAPACIDADE CIVIL</option>
			</select>
			
			<label for="dthabmen" style="width:104px">Dt. Emancipa&ccedil;&atilde;o:</label>
			<input name="dthabmen" id="dthabmen" type="text" value="<? echo $frm_dthabmen; ?>" />
				
			
			<br />
			
			<label for="tpdocava" class="rotulo rotulo-80">Documento:</label>
			<select name="tpdocava" id="tpdocava">
				<option value="" <? if ($frm_tpdocava == ""){ echo " selected"; } ?>> - </option>
				<option value="CI" <? if ($frm_tpdocava == "CI"){ echo " selected"; } ?>>CI</option>
				<option value="CN" <? if ($frm_tpdocava == "CN"){ echo " selected"; } ?>>CN</option>
				<option value="CH" <? if ($frm_tpdocava == "CH"){ echo " selected"; } ?>>CH</option>
				<option value="RE" <? if ($frm_tpdocava == "RE"){ echo " selected"; } ?>>RE</option>
				<option value="PP" <? if ($frm_tpdocava == "PP"){ echo " selected"; } ?>>PP</option>
				<option value="CT" <? if ($frm_tpdocava == "CT"){ echo " selected"; } ?>>CT</option>
			</select>
			<input name="nrdocava" id="nrdocava" type="text" value="<? echo $frm_nrdocava; ?>" />
			
			<br />

			<label for="cdoeddoc" class="rotulo rotulo-80">Org.Emi.:</label>
			<input name="cdoeddoc" id="cdoeddoc" type="text" value="<? echo $frm_cdoeddoc; ?>" />
			
			<label for="cdufddoc" class="rotulo-linha">U.F.:</label>
			<? echo selectEstado('cdufddoc', $frm_cdufddoc, 1) ?>
			
			<label for="dtemddoc" style="width:54px;">Dt. Emi.:</label>
			<input name="dtemddoc" id="dtemddoc" type="text" value="<? echo $frm_dtemddoc; ?>" />
			
			<label for="cdestcvl" class="rotulo rotulo-80">Estado Civil:</label>
			<input name="cdestciv" type="hidden" value="<? echo $frm_cdestcvl; ?>" />
			<select name="cdestcvl" id="cdestcvl">
				<option value="" selected> - </option>
			</select>
			
			
			<label for="cdsexcto" style="width:38px;">Sexo:</label>
			<input name="cdsexcto" id="sexoMas" type="radio" class="radio" value="1" <? if ($frm_cdsexcto == "1") { echo " checked"; } ?> />
			<label for="sexoMas" class="radio">Mas.</label>
			<input name="cdsexcto" id="sexoFem" type="radio" class="radio" value="2" <? if ($frm_cdsexcto == "2") { echo " checked"; } ?> />
			<label for="sexoFem" class="radio">Fem.</label>
			<br />
				
			<label for="cdnacion" class="rotulo rotulo-80">Nacional.:</label>
            <input name="cdnacion" id="cdnacion" type="text" class="pesquisa" maxlength="15" value="<? echo $frm_cdnacion; ?>" />
			<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
			<input name="dsnacion" id="dsnacion" type="text" class="alphanum pesquisa" maxlength="15" value="<? echo $frm_dsnacion; ?>" />
			<br />
			
			<label for="dsnatura" class="rotulo rotulo-80">Natural de:</label>
			<input name="dsnatura" id="dsnatura" type="text" class="alphanum pesquisa" maxlength="50" value="<? echo $frm_dsnatura; ?>" />
			<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
		</fieldset>
		
		
		<fieldset>
			<legend><? echo utf8ToHtml('Endereço') ?></legend>		
					
			<label for="nrcepend"><? echo utf8ToHtml('CEP:') ?></label>
			<input name="nrcepend" id="nrcepend" type="text" value="<? echo $frm_nrcepend; ?>" />
			<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>

			<label for="dsendres"><? echo utf8ToHtml('End.:') ?></label>
			<input name="dsendres" id="dsendres" type="text" value="<? echo $frm_dsendres; ?>" />		
			<br />

			<label for="nrendere"><? echo utf8ToHtml('Nro.:') ?></label>
			<input name="nrendere" id="nrendere" type="text" value="<? echo $frm_nrendere; ?>" />

			<label for="complend"><? echo utf8ToHtml('Comple.:') ?></label>
			<input name="complend" id="complend" type="text" value="<? echo $frm_complend; ?>" />
			<br />

			<label for="cdufresd"><? echo utf8ToHtml('U.F.:') ?></label>
			<? echo selectEstado('cdufresd', $frm_cdufresd, 1); ?>	

			<label for="nmbairro"><? echo utf8ToHtml('Bairro:') ?></label>
			<input name="nmbairro" id="nmbairro" type="text" value="<? echo $frm_nmbairro; ?>" />								
			<br />	

			<label for="nmcidade"><? echo utf8ToHtml('Cidade:') ?></label>
			<input name="nmcidade" id="nmcidade" type="text"  value="<? echo $frm_nmcidade; ?>" />

		</fieldset>
		
		
		<fieldset>
			<legend><? echo utf8ToHtml('Filiação') ?></legend>				
			
			<label for="nmmaecto" class="rotulo rotulo-80">Nome M&atilde;e:</label>
			<input name="nmmaecto" id="nmmaecto" type="text" value="<? echo $frm_nmmaecto; ?>" /><br />
			
			<label for="nmpaicto" class="rotulo rotulo-80">Nome Pai:</label>
			<input name="nmpaicto" id="nmpaicto" type="text" value="<? echo $frm_nmpaicto; ?>" /><br />
		</fieldset>
		
		
		<fieldset>
			<legend><? echo utf8ToHtml('Operação') ?></legend>
			
			<label for="vledvmto" class="rotulo rotulo-80">Endivid.:</label>
			<input name="vledvmto" id="vledvmto" type="text" class="moeda" maxlength="18" value="<? echo $frm_vledvmto; ?>" />
			
			<label for="dsrelbem" class="rotulo-linha">Descri&ccedil;&atilde;o dos bens:</label>
			<input name="dsrelbem" id="dsrelbem" type="text" value="<? echo $frm_dsrelbem; ?>" />
			<a class="lupaBens"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
			<br />
			
			<label for="dtvalida" class="rotulo rotulo-80">Vig&ecirc;ncia:</label>
			<input name="dtvalida" id="dtvalida" type="text" class="data" value="<? echo $frm_dtvalida; ?>" />
			
			<label for="dsproftl" class="rotulo-linha">Cargo:</label>
			<input name="dsproftl" type="hidden" value="<? echo $frm_dsproftl; ?>" />
			<select name="dsproftl" id="dsproftl">
				<option value="" selected> - </option>
			</select>
			
			<label for="dtadmsoc" class="rotulo-linha">Data Adm.:</label>
			<input name="dtadmsoc" id="dtadmsoc" type="text" class="data" value="<? echo $frm_dtadmsoc; ?>" />
		</fieldset>
		
		<div id="divDadosSocioProp">
		
			<fieldset>
				<legend><? echo utf8ToHtml('Participação') ?></legend>				
				
				<label for="persocio"><? echo utf8ToHtml('% Societário:') ?></label>
				<input name="persocio" id="persocio" type="text" value="<? echo $frm_persocio; ?>" />
				
				<label for="flgdepec" class="rotulo-linha"><? echo utf8ToHtml('Dependência Econômica:') ?></label>
				<select name="flgdepec" id="flgdepec">
					<option value="no" <? if (($frm_flgdepec == "no") || ($frm_flgdepec == "")){ echo " selected"; } ?>>N&atilde;o</option>
					<option value="yes" <? if ($frm_flgdepec == "yes"){ echo " selected"; } ?>>Sim</option>
				</select>			
			</fieldset>
			
			<fieldset>
				<legend><? echo utf8ToHtml('Outras Fontes de Renda do Sócio') ?></legend> 
			
				<label for="vloutren" class="rotulo rotulo-80">Valor:</label>
				<input name="vloutren" id="vloutren" type="text" class="moeda" maxlength="10" value="<? echo $frm_vloutren; ?>" />
							
				<label for="dsoutren" class="rotulo-linha">Referente:</label>
				<textarea name="dsoutren" id="dsoutren" type="text" ><? echo $frm_dsoutren; ?></textarea>
												
			</fieldset>
		
		</div>
		
	</form>	
	
	<div id="divBotoesFormProc">
					
		<input type="image" id="btVoltarCns" src="<? echo $UrlImagens; ?>botoes/voltar.gif"   onClick="" />	
		<input type="image" id="btProsseguirCns" src="<? echo $UrlImagens; ?>botoes/prosseguir.gif" onClick="" />		
		
		<input type="image" id="btVoltarAlt" src="<? echo $UrlImagens; ?>botoes/voltar.gif"   onClick="" />		
		<input type="image" id="btSalvarAlt" src="<? echo $UrlImagens; ?>botoes/concluir.gif" onClick="" />		
	
		<input type="image" id="btVoltarInc" src="<? echo $UrlImagens; ?>botoes/voltar.gif"   onClick="" />		
		<input type="image" id="btLimparInc" src="<? echo $UrlImagens; ?>botoes/limpar.gif"   onClick="" />
		<input type="image" id="btSalvarInc" src="<? echo $UrlImagens; ?>botoes/concluir.gif" onClick="" />		
			
				
	</div>			
</div>

<script type="text/javascript">
	controlaFocoEnter("frmDadosProcuradores");
</script>