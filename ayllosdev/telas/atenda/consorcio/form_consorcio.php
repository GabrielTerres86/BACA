<? 
/*!
 * FONTE        : form_consorcio.php
 * CRIA��O      : Lucas R
 * DATA CRIA��O : Julho/2013 
 * OBJETIVO     : Forumlario de dados dos consorcios
 * --------------
 * ALTERA��ES   : 
 * --------------
 */	
 
session_start();
require_once('../../../includes/config.php');
require_once('../../../includes/funcoes.php');		
require_once('../../../includes/controla_secao.php');
require_once('../../../class/xmlfile.php');
isPostMethod();
?>	

<form name="frmDadosConsorcio" id="frmDadosConsorcio" class="formulario" >
	
	<fieldset>
		<legend>Cons�rcios</legend>
			
		<label for="dsconsor">Tipo do Consorcio:</label>
		<input name="dsconsor" style="text-align: right;" id="dsconsor" type="text" value="" />
		
		<label for="nrctacns">Conta Cons�rcio:</label>
		<input name="nrctacns" style="text-align: right;" id="nrctacns" type="text" value="" />
		<br />
		<br />
		<br />
		
		<label for="nrdgrupo">Grupo:</label>
		<input name="nrdgrupo" style="text-align: right;" id="nrdgrupo" type="text" value="" />	
		
		<label for="dtinicns">Data Inicio Cons�rcio:</label>
		<input name="dtinicns" style="text-align: right;" id="dtinicns" type="text" value="" />
		<br />
		
		<label for="nrcotcns">N�mero da Cota:</label>
		<input name="nrcotcns" style="text-align: right;" id="nrcotcns" type="text" value="" />
		
						
		<label for="dtfimcns">Data t�rmino Cons�rcio:</label>
		<input name="dtfimcns" style="text-align: right;" id="dtfimcns" type="text" value="" />
		<br />
		
		<label for="nrctrato">Contrato:</label>
		<input name="nrctrato" style="text-align: right;" id="nrctrato" type="text" value="" />
		
		
		<label for="nrdiadeb">Dia do D�bito:</label>
		<input name="nrdiadeb" style="text-align: right;" id="nrdiadeb" type="text" value="" />	
		<br />
		
		<label for="vlrcarta">Valor Carta:</label>
		<input name="vlrcarta" style="text-align: right;" id="vlrcarta" type="text" value="" />
		
		<label for="parcpaga">Parcelas Pagas:</label>
		<input name="parcpaga" style="text-align: right;" id="parcpaga" type="text" value="" />
		<br />	
		
		
		<label for="qtparcns">Parcelas Cons�rcio:</label>
		<input name="qtparcns" style="text-align: right;" id="qtparcns" type="text" value="" />
		
		<label for="instatus">Situa��o:</label>
		<input name="instatus" style="text-align: right;" id="instatus" type="text" value="" />
		<br />			
		
		<label for="vlparcns">Valor Parcela:</label>
		<input name="vlparcns" style="text-align: right;" id="vlparcns" type="text" value="" />		
		
		
	</fieldset>
</form>	

<div id="divBotoes">
	<input id="btVoltar" type="image" onclick="acessaOpcaoAba(1,0,0);" src="<? echo $UrlImagens; ?>botoes/voltar.gif">
</div>
			
