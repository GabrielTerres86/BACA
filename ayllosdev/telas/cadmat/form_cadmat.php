<?
/*!
 * FONTE        : form_titular.php
 * CRIAÇÃO      : Odirlei Busana - AMcom
 * DATA CRIAÇÃO : 22/09/2017
 * OBJETIVO     : Formulário para dados do titular da tela CADMAT
 * --------------
 * ALTERAÇÕES   : 
 *
 * -------------- 
 */  
?>

<form id="frmCadmat" name="frmCadmat" class="formulario condensado">
	
	<fieldset>
		<legend> Titular</legend>
			
		<label for="nrcpfcgc">CPF/CNPJ:</label>
		<input type="text" name="nrcpfcgc" id="nrcpfcgc" alt="Entre com o CPF/CNPJ do cooperado." />
        
		<label for="nmprimtl">Nome Tit.:</label>
		<input type="text" name="nmprimtl" id="nmprimtl" alt="Entre com o nome do associado." />
		<br />
        
        <label for="cdagenci">PA:</label>
		<input type="text" name="cdagenci" id="cdagenci" alt="Entre com a agencia do cooperado." />      
		<a><img src="<?php echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
		<input type="text" name="nmresage" id="nmresage" />

        <label for="cdempres">Empresa:</label>
		<input type="text" name="cdempres" id="cdempres" alt="Entre com a empresa de trabalho do cooperado." />      
		<a><img src="<?php echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
		<input type="text" name="nmresemp" id="nmresemp" />
        
        <label for="nrmatric"> Matr&iacute;cula:</label>
		<input name="nrmatric" id="nrmatric" type="text" />
        
		<label for="nrdconta"> Conta:</label>
		<input name="nrdconta" id="nrdconta" type="text" />      
        </br>
       
		<label for="dtadmiss">Admiss&atilde;o:</label>
		<input name="dtadmiss" id="dtadmiss" type="text"  />
        
        <label for="dtdemiss">Desligamento:</label>
		<input name="dtdemiss" id="dtdemiss" type="text"  />
        
        <label for="dstipsai">Tipo:</label>
		<input name="dstipsai" id="dstipsai" type="text" />
        </br>
		
		<label for="dsinctva">Iniciativa:</label>
		<input type="text" name="dsinctva" id="dsinctva" />
		
        <label for="cdmotdem">Motivo:</label>
		<input type="text" name="cdmotdem" id="cdmotdem" alt="Entre com a o motivo da demissao." />      
		<input type="text" name="dsmotdem" id="dsmotdem"  />
        
		<br />		

		<input type="hidden" id="rowidass" name="rowidass" />
		<input type="hidden" id="inmatric" name="inmatric" />
		<input type="hidden" id="tpdocptl" name="tpdocptl" />
		<input type="hidden" id="nrdocptl" name="nrdocptl" />
		<input type="hidden" id="nmttlrfb" name="nmttlrfb" />
		<input type="hidden" id="cdsitcpf" name="cdsitcpf" />
		<input type="hidden" id="dtcnscpf" name="dtcnscpf" />
		<input type="hidden" id="dsdemail" name="dsdemail" />
		<input type="hidden" id="nrcepcor" name="nrcepcor" />
		<input type="hidden" id="dsendcor" name="dsendcor" />
		<input type="hidden" id="nrendcor" name="nrendcor" />
		<input type="hidden" id="complcor" name="complcor" />
		<input type="hidden" id="nmbaicor" name="nmbaicor" />
		<input type="hidden" id="cdufcorr" name="cdufcorr" />
		<input type="hidden" id="nmcidcor" name="nmcidcor" />
		<input type="hidden" id="idoricor" name="idoricor" />
		<input type="hidden" id="inpessoa" name="inpessoa" />
		<input type="hidden" id="dsnacion" name="dsnacion" />
		<input type="hidden" id="inhabmen" name="inhabmen" />
		<input type="hidden" id="dthabmen" name="dthabmen" />
		<input type="hidden" id="cdestcvl" name="cdestcvl" />
		<input type="hidden" id="tpnacion" name="tpnacion" />
		<input type="hidden" id="cdnacion" name="cdnacion" />
		<input type="hidden" id="cdoedptl" name="cdoedptl" />
		<input type="hidden" id="cdufdptl" name="cdufdptl" />
		<input type="hidden" id="dtemdptl" name="dtemdptl" />
		<input type="hidden" id="dtnasctl" name="dtnasctl" />
		<input type="hidden" id="nmconjug" name="nmconjug" />
		<input type="hidden" id="nmmaettl" name="nmmaettl" />
		<input type="hidden" id="nmpaittl" name="nmpaittl" />
		<input type="hidden" id="dsnatura" name="dsnatura" />
		<input type="hidden" id="cdufnatu" name="cdufnatu" />
		<input type="hidden" id="nrdddres" name="nrdddres" />
		<input type="hidden" id="nrtelres" name="nrtelres" />
		<input type="hidden" id="cdopetfn" name="cdopetfn" />
		<input type="hidden" id="nrdddcel" name="nrdddcel" />
		<input type="hidden" id="nrtelcel" name="nrtelcel" />
		<input type="hidden" id="nrcepend" name="nrcepend" />
		<input type="hidden" id="dsendere" name="dsendere" />
		<input type="hidden" id="nrendere" name="nrendere" />
		<input type="hidden" id="complend" name="complend" />
		<input type="hidden" id="nmbairro" name="nmbairro" />
		<input type="hidden" id="cdufende" name="cdufende" />
		<input type="hidden" id="nmcidade" name="nmcidade" />
		<input type="hidden" id="idorigee" name="idorigee" />
		<input type="hidden" id="cdocpttl" name="cdocpttl" />
		<input type="hidden" id="nrcadast" name="nrcadast" />
		<input type="hidden" id="cdsexotl" name="cdsexotl" />
		<input type="hidden" id="idorgexp" name="idorgexp" />
		<input type="hidden" id="nmfansia" name="nmfansia" />
		<input type="hidden" id="nrdddtfc" name="nrdddtfc" />
		<input type="hidden" id="nrtelefo" name="nrtelefo" />
		<input type="hidden" id="nrinsest" name="nrinsest" />
		<input type="hidden" id="nrlicamb" name="nrlicamb" />
		<input type="hidden" id="natjurid" name="natjurid" />
		<input type="hidden" id="cdseteco" name="cdseteco" />
		<input type="hidden" id="cdrmativ" name="cdrmativ" />
		<input type="hidden" id="cdcnae"   name="cdcnae"   />
		<input type="hidden" id="dtiniatv" name="dtiniatv" />
		<input type="hidden" id="flgtermo" name="flgtermo" />
		<input type="hidden" id="flgdigit" name="flgdigit" />
		
	</fieldset>		
	
</form>