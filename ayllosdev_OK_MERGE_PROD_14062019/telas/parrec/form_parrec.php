<?php
/*!
 * FONTE        : form_parrec.php
 * CRIAÇÃO      : Lucas Reinert
 * DATA CRIAÇÃO : 30/01/2017
 * OBJETIVO     : Formulario de consulta da Tela PARREC
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 */ 

	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');	
	require_once('../../class/xmlfile.php');
	isPostMethod();	

?>

<form id="frmParrec" name="frmParrec" class="formulario" style="display: none">
	
	<div id="divSingulares" style="display: none">		
		<fieldset style="margin-top: 10px">
			<legend> Canais de Recarga </legend>
			<div>				
				<label for="flsitsac">SAC:</label>		
				<input type="radio" id="flsitsacs" name="flsitsac" value="1" style="height: 20px; margin: 3px 0px 3px 3px !important;"/>
				<label for="flsitsacs">Sim</label>                                  
				<input type="radio" id="flsitsacn" name="flsitsac" value="0" style="height: 20px; margin: 3px 0px 3px 3px !important;"/>
				<label for="flsitsacn">N&atilde;o</label>     
				
				<br/>                                    
				
				<label for="flsittaa">TA:</label>		                            
				<input type="radio" id="flsittaas" name="flsittaa" value="1" style="height: 20px; margin: 3px 0px 3px 3px !important;"/>
				<label for="flsittaas">Sim</label>		                            
				<input type="radio" id="flsittaan" name="flsittaa" value="0" style="height: 20px; margin: 3px 0px 3px 3px !important;"/>
				<label for="flsittaan">N&atilde;o</label>   
				
				<br/>                                          
				
				<label for="flsitibn">INTERNET BANKING / MOBILE:</label>                     
				<input type="radio" id="flsitibns" name="flsitibn" value="1" style="height: 20px; margin: 3px 0px 3px 3px !important;"/>
				<label for="flsitibns">Sim</label>		                            
				<input type="radio" id="flsitibnn" name="flsitibn" value="0" style="height: 20px; margin: 3px 0px 3px 3px !important;"/>
				<label for="flsitibnn">N&atilde;o</label>		

			</div>
		</fieldset>		
		<fieldset style="margin-top: 10px">
			<legend> Limite M&aacute;ximo Di&aacute;rio </legend>
			
			<label for="vlrmaxpf">Pessoa F&iacute;sica:</label>		
			<input type="text" id="vlrmaxpf" name="vlrmaxpf" />
			
			<label for="vlrmaxpj">Pessoa Jur&iacute;dica:</label>		
			<input type="text" id="vlrmaxpj" name="vlrmaxpj" />
			
			<br style="clear:both" />
			<br style="clear:both" />
		</fieldset>
	</div>
	<div id="divCecred" style="display: none">		
		<fieldset style="margin-top: 10px">
			<legend> Dados banc&aacute;rios do repasse </legend>
			
			<label for="nrispbif">ISPB:</label>		
			<input type="text" id="nrispbif" name="nrispbif" />
			<a style="padding: 3px 0 0 3px;" id="btLupaISPB" >
				<img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"/>
			</a>				
			
			<br/>
			
			<label for="cdbccxlt">Banco:</label>		
			<input type="text" id="cdbccxlt" name="cdbccxlt" />
			<input type="text" id="nmresbcc" name="nmresbcc" />
			
			<br/>
			
			<label for="cdageban">Ag&ecirc;ncia:</label>
			<input name="cdageban" id="cdageban" type="text" />
			<a style="padding: 3px 0 0 3px;" id="btLupaAge" >
				<img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"/>
			</a>				
			<input type="text" id="nmageban" name="nmageban" />
			
			<br/>
			
			<label for="nrdconta">Conta Creditada (com DV):</label>
			<input name="nrdconta" id="nrdconta" type="text" />
			
			<br/>
			
			<label for="nrdocnpj">CNPJ:</label>
			<input name="nrdocnpj" id="nrdocnpj" type="text" />
			
			<br/>
			
			<label for="dsdonome">Nome:</label>
			<input name="dsdonome" id="dsdonome" type="text" />
			
		</fieldset>
	</div>
	
	<div id="divMensagens" style="display: none">
		<fieldset>
			<legend> Texto Minhas Mensagens </legend> 
			<fieldset>
				<legend> Insufici&ecirc;ncia de Saldo </legend>

				<textarea name="dsmsgsaldo" id="dsmsgsaldo" rows="4" cols="56" style="margin-left: 15px; margin-top: 10px; margin-bottom: 10px;" ></textarea>
			
				<p style=" margin-left: 10px; font-family:Arial, Helvetica, sans-serif; font-size:11px;">Obs.: #Operadora#, #DDD#, #Celular#, #Data# e #Valor# s&atilde;o preenchidos automaticamente pelo sistema.</p>
			</fieldset>
			<fieldset>
				<legend> Opera&ccedil;&atilde;o n&atilde;o autorizada </legend>

				<textarea name="dsmsgoperac" id="dsmsgoperac" rows="4" cols="56" style="margin-left: 15px; margin-top: 10px; margin-bottom: 10px;" ></textarea>
			
				<p style=" margin-left: 10px; font-family:Arial, Helvetica, sans-serif; font-size:11px;">Obs.: #Operadora#, #DDD#, #Celular#, #Data#, #Valor# e #Motivo# s&atilde;o preenchidos automaticamente pelo sistema.</p>
			</fieldset>
			<br/>
		</fieldset>
	</div>
	
</form>
