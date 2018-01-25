<? 
 /*!
 * FONTE        : form_faturas.php
 * CRIAÇÃO      : Adriano	
 * DATA CRIAÇÃO : Agosto/2011							 Última Alteração: 19/09/2016
 * OBJETIVO     : Formulário de exibição
 * --------------
 * ALTERAÇÕES   : 06/08/2012 - Listar Históricos, campo Vl.FOZ e 
							   implementação da Opção A (Lucas).   
							   
				  16/12/2014 - #203812 Para as faturas (Cecred e Sicredi)
                               no lugar da descrição do Banco Destino e o
                               nome do banco, apresentar: Convênio e Nome
                               do convênio (Carlos)
				
				  17/06/2015 - Ajuste decorrente a melhoria no layout da tela
 							  (Adriano).

                  12/05/2016 - Adicionar campo da linha digitavel (Douglas - Chamado 426870)
				  
				  19/09/2016 - Alteraçoes pagamento/agendamento de DARF/DAS 
							   pelo InternetBanking (Projeto 338 - Lucas Lunelli)
                 
          18/01/2018 - Alterações referentes ao PJ406
				  
 */	
?>


<form name="frmFaturas" id="frmFaturas" class="formulario" style="display:none">	
	<fieldset>
		<legend><? echo utf8ToHtml('Detalhes da Fatura') ?></legend>
		
		<label for="dspactaa"><? echo utf8ToHtml('COOPERATIVA/PA/TAA:') ?></label>
		<input name="dspactaa" id="dspactaa" type="text" />
		
		<label for="vlconfoz"><? echo utf8ToHtml('Valor Foz:') ?></label>
		<input name="vlconfoz" id="vlconfoz" type="text" />
			
		<br />
		<label for="nrautdoc"><? echo utf8ToHtml('Autenticação:') ?></label>
		<input name="nrautdoc" id="nrautdoc" type="text" />

		<label for="nrdocmto"><? echo utf8ToHtml('Sequência:') ?></label>
		<input name="nrdocmto" id="nrdocmto" type="text" />
		
		<br/>
<!--	<label for="cdbandst"><? #echo utf8ToHtml('Banco Destin.:') ?></label>
		<input name="cdbandst" id="cdbandst" type="text" /> -->
		
		<label for="nmempres"><? echo utf8ToHtml('Convênio:') ?></label>
		<input name="nmempres" id="nmempres" type="text" />
		
		<label for="nrdconta"><? echo utf8ToHtml('Conta/dv:') ?></label>
		<input name="nrdconta" id="nrdconta" type="text" />
	
		<br/>
		<label for="nmresage"><? echo utf8ToHtml('Ag. Arrecada.:') ?></label>
		<input name="nmresage" id="nmresage" type="text" />
    
    <br/>
		<label for="dscodbar"><? echo utf8ToHtml('Cod. de Barras:') ?></label>
		<input name="dscodbar" id="dscodbar" type="text" />
		
		<label for="insitfat"><? echo utf8ToHtml('Enviado:') ?></label>
		<select name="insitfat" id="insitfat" class="campo">
			<option value="1">NAO</option>
			<option value="2">SIM</option> 
		</select>
		
		<br/>
		<label for="dslindig"><? echo utf8ToHtml('Linha Digitavel:') ?></label>
		<input name="dslindig" id="dslindig" type="text" />	
		
		<br/>
		
		<label for="dscptdoc"><? echo utf8ToHtml('Origem pagto:') ?></label>
		<input name="dscptdoc" id="dscptdoc" type="text" />	
		
		<label for="dsnomfon"><? echo utf8ToHtml('Nome/Telefone:') ?></label>
		<input name="dsnomfon" id="dsnomfon" type="text" />	

		<input name="cdagenci" id="cdagenci" type="hidden" />	
		<input name="nrdolote" id="nrdolote" type="hidden" />	
		<input name="cdbccxlt" id="cdbccxlt" type="hidden" />	
		<input name="dtdpagto" id="dtdpagto" type="hidden" />	
		
		<br/>
		<br/>
		
	</fieldset>				
</form>
