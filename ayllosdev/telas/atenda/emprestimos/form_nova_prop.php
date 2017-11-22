<!DOCTYPE html>
<? 
/*!
 * FONTE        : form_nova_prop.php
 * CRIAÇÃO      : Gabriel Capoia (DB1)
 * DATA CRIAÇÃO : 01/04/2011 
 * OBJETIVO     : Formulário da rotina Emprestimos da tela ATENDA
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 * 000: [08/08/2011] Adicionado campo para tipo de empréstimo - Marcelo L. Pereira (GATI)
 * 001: [20/09/2011] Correções de acentuação - Marcelo L. Pereira (GATI)
 * 002: [17/02/2012] Implementado calendario no campo "Liberar em" (Tiago).
 * 003: [05/04;2012] Incluido campo dtlibera (Gabriel). 
 * 004: [10/04/2012] Incluido funcao para desabilitar feriados no calendario (Tiago).
 * 005: [10/07/2012] Validar sempre os contratos a serem liquidados (Gabriel).
 * 006: [05/09/2012] Mudar para layout padrao (Gabriel). 
 * 007: [04/06/2013] Segunda fase Projeto Credito (Gabriel).
 * 008: [24/12/2013] Alterado fluxo de botao continuar quando operacao for "TC", de "C_COMITE_APROV" para "C_DADOS_AVAL".  (Jorge)
 * 009: [07/04/2014] Trocado posicao dos campos "Linha Credito" por "Finalidade". (Reinert)
 * 010: [30/07/2014] Ajustado ordem dos labels para ficar de acordo com Projeto CET (Lucas R./Gielow).
 * 011: [26/06/2015] Criei a funcionalidade de atualizacao da "Data últ. pagto" a partir do numero de parcelas com base na "Data pagto" (Carlos R.)
 */
 ?> 

<style>
.ui-datepicker-trigger{
	float:left;
	margin-left:2px;
	margin-top:3px;
}
</style> 
 
<script>
	
	$(document).ready(function() {
	
		 highlightObjFocus($('#frmNovaProp'));
			 
		retornaListaFeriados();	
		
		function isAvailable (date) { 
			var mes = "";
			var dia = "";
			var ano = "";
			
			if (date.getMonth() < 9){
				mes = "0" + (date.getMonth()+1).toString();
			}else{
				mes = (date.getMonth()+1).toString();;
			}
			
			if (date.getDate() < 10){
				dia = "0"+date.getDate().toString();
			}else{
				dia = date.getDate().toString();
			}
			
			ano = date.getFullYear().toString();
			
			var dateAsString =  ano + "/" + mes + "/" + dia; 						
			var resultado = $.inArray (dateAsString, arrayFeriados) == -1 ?  [true]: [false]; 
			
			if (date.getDay() == 0 || date.getDay() == 6){
				resultado = false;
			}
			
			return resultado;
		}				
						
		$("#qtdialib").val(" ");		

		$.datepicker.setDefaults( $.datepicker.regional[ "pt-BR" ] );						
		
		$( "#qtdialib" ).datepicker({						
			defaultDate: "<?php echo $glbvars["dtmvtolt"]; ?>",																		
			onSelect: function(dateText, inst){
			
				$("#qtdialib").val("0"); 
				
				if  ( $("#tpemprst").val()  == "0") {
					calculaDiasUteis(dateText); 
					$("#dtlibera","#frmNovaProp").val(dateText); 
					arrayProposta['dtlibera'] = dateText; 		
				}
				else {
					$("#dtlibera","#frmNovaProp").val("<?php echo $glbvars["dtmvtolt"]; ?>"); 
				}
			},
			onClose: function(dateText, inst) {  },
			minDate: "<?php echo $glbvars["dtmvtolt"]; ?>",
			maxDate: "+1Y",
			beforeShowDay: isAvailable,
			showOn: "button",
			buttonImage: UrlSite + "imagens/geral/btn_calendario.gif",
			buttonImageOnly: true,
			buttonText: "Calendario"
		});

		$( "#qtdialib" ).datepicker( "option", "dateFormat", "dd/mm/yy" );			
		$( "#qtdialib" ).datepicker( "option", "gotoCurrent", true );
	 
	 	$("#dtlibera","#frmNovaProp").val( "<?php echo $glbvars["dtmvtolt"]; ?>" );		
					
                /* PORTABILIDADE */
                $('#dtultpag','#frmNovaProp').desabilitaCampo();

                //calcula a data de ultimo pagamento
		$('#qtpreemp, #dtdpagto','#frmNovaProp').unbind('blur').bind('blur', function() {
                    atualizaCampoData();
	});	

                //tratamento para o botao VOLTAR
                if (typeof arrayDadosPortabilidade['nrcnpjbase_if_origem'] != 'undefined' &&
                    typeof arrayDadosPortabilidade['nrcontrato_if_origem'] != 'undefined' &&
                    typeof arrayDadosPortabilidade['nmif_origem']          != 'undefined' &&
                    typeof arrayDadosPortabilidade['cdmodali']             != 'undefined' )
                {
                    var ope = '';
                    if ( operacao == 'I_DADOS_AVAL' ) { 
                        ope = 'PORTAB_CRED_I';
                    } else if ( operacao == 'A_DADOS_AVAL' ) { 
                        ope = 'PORTAB_CRED_A';
                    } else {
                        ope = 'PORTAB_CRED_C';
                    }
                    $("#divBotoes #btVoltar").attr('onclick', "controlaOperacao('"+ope+"'); return false;");                    
                }
	});	
</script>
 
<form name="frmNovaProp" id="frmNovaProp" class="formulario condensado">	

	<input id="nrctremp" name="nrctremp" type="hidden" value="" />
	<input id="portabilidade" name="portabilidade" type="hidden" value="" />
	<input id="tpfinali" name="tpfinali" type="hidden" value="" />
	
	<fieldset>
		<legend><? echo utf8ToHtml('Nova Proposta de Empréstimo') ?></legend>
	
		<label for="nivrisco"><? echo utf8ToHtml('Nível Risco:') ?></label>
		<select name="nivrisco" id="nivrisco">
			<option value="" > - </option>
			<option value="A">A</option>
			<option value="B">B</option>
			<option value="C">C</option>
			<option value="D">D</option>
			<option value="E">E</option>
			<option value="F">F</option>
			<option value="G">G</option>
			<option value="H">H</option>
		</select>
				
		<label for="nivcalcu">Risco Calc.:</label>
		<input name="nivcalcu" id="nivcalcu" type="text" value="" />
		<br />
		
		<label for="tpemprst">Produto:</label>
		<select name="tpemprst" id="tpemprst">
		</select>
		
		<label for="cdfinemp">Finalidade:</label>
		<input name="cdfinemp" id="cdfinemp" type="text" value="" />
		<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
		<input name="dsfinemp" id="dsfinemp" type="text" value="" />
		<br />		
				
		<label for="vlemprst"><? echo utf8ToHtml('Vl. do Empr.:') ?></label>
		<input name="vlemprst" id="vlemprst" type="text" value="" />
		
		<label for="cdlcremp"><? echo utf8ToHtml('Linha Crédito:') ?></label>
		<input name="cdlcremp" id="cdlcremp" type="text" value="" />
		<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
		<input name="dslcremp" id="dslcremp" type="text" value="" />
		<br />
		
		<label for="vlpreemp"><? echo utf8ToHtml('Vl. da Prest.:') ?></label>
		<input name="vlpreemp" id="vlpreemp" type="text" value="" />
		
		<label for="idquapro"><? echo utf8ToHtml('Qualif. Oper.:') ?></label>
		<input name="idquapro" id="idquapro" type="text" value="" />
		<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
		<input name="dsquapro" id="dsquapro" type="text" value="" />
		<br />
		
		<label for="qtpreemp">Qtd. de Parc.:</label>
		<input name="qtpreemp" id="qtpreemp" type="text" value="" />
		
		<label for="qtdialib">Liberar em:</label>		
		<input name="qtdialib" id="qtdialib" type="text" value=" " />
	    <label id="duteis"><? echo utf8ToHtml('dias úteis') ?></label>	
		<br />
		
		<label for="flgpagto">Debitar em:</label>
		<select name="flgpagto" id="flgpagto">
			<option value="no" >Conta</option>
			<option value="yes">Folha</option>
		</select>
		
		<label for="dtlibera"> <? echo utf8ToHtml("Data Liberação:") ?> </label>
		<input name="dtlibera" id="dtlibera" type="text" value="">
		<br />
		
		<label for="dtdpagto">Data pagto:</label>
		<input name="dtdpagto" id="dtdpagto" type="text" value="" />
		<br />
		
                <label for="dtultpag">Data &uacute;lt. pagto:</label>
                <input name="dtultpag" id="dtultpag" type="text" disabled="disabled" value="" />
		<br />
		
		<label for="percetop">CET(%a.a.):</label>
		<input name="percetop" id="percetop" type="text" value="" />
		<br />
		
		<label for="flgimppr">Proposta:</label>
		<select name="flgimppr" id="flgimppr">
			<option value=""   > - </option>
			<option value="yes" >Imprime</option>
			<option value="no"><? echo utf8ToHtml('Não Imprime') ?></option>
		</select>
		<br />
						
		<label for="flgimpnp"><? echo utf8ToHtml('Nota Promissória:') ?></label>
		<select name="flgimpnp" id="flgimpnp">
			<option value=""   > - </option>
			<option value="yes" >Imprime</option>
			<option value="no"><? echo utf8ToHtml('Não Imprime') ?></option>
		</select>
		<br />
		
		<label for="dsctrliq"><? echo utf8ToHtml('Liquidações:') ?></label>
		<input name="dsctrliq" id="dsctrliq" type="text" value="" />
		<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
		<br />
		
		
	</fieldset>
</form>


<div id="divBotoes">
	<? if ( $operacao == 'A_NOVA_PROP' || $operacao == 'A_INICIO' ) { ?>
		<a href="#" class="botao" id="btVoltar" onClick="controlaOperacao('AT'); return false;">Voltar</a>
		<a href="#" class="botao" id="btSalvar" onClick="buscaLiquidacoes('A_DADOS_AVAL'); return false;">Continuar</a>	
	<? }else if ( $operacao == 'A_VALOR' ) { ?>
		<a href="#" class="botao" id="btVoltar" onClick="controlaOperacao('AT'); return false;">Voltar</a>
		<a href="#" class="botao" id="btSalvar" onClick="validaDadosAlterarSomenteValorProposta(); return false;">Concluir</a>	
	<? } else if ( $operacao == 'A_FINALIZA' || $operacao == 'I_CONTRATO' || $operacao == 'I_FINALIZA'  ) { ?>
		<a href="#" class="botao" id="btVoltar" onClick="controlaOperacao(''); return false;">Voltar</a>
	<? } else if ( $operacao == 'A_NUMERO' ) { ?>
		<a href="#" class="botao" id="btVoltar" onClick="controlaOperacao(''); return false;">Voltar</a>
	<? } else if ($operacao == 'TC' || $operacao == 'CF') { ?>
		<a href="#" class="botao" id="btVoltar" onClick="controlaOperacao(''); return false;">Voltar</a>
		<a href="#" class="botao" id="btSalvar" onClick="controlaOperacao('C_DADOS_AVAL'); return false;">Continuar</a>
	<? } else if ($operacao == 'TE') { ?>
		<a href="#" class="botao" id="btVoltar" onClick="controlaOperacao(''); return false;">Voltar</a>
		<a href="#" class="botao" id="btSalvar" onClick="controlaOperacao('E_COMITE_APROV'); return false;">Continuar</a>
	<? } else if ($operacao == 'TI' || $operacao == 'I_INICIO' ) { ?>
		<a href="#" class="botao" id="btVoltar" onClick="controlaOperacao('IT'); return false;">Voltar</a>
		<a href="#" class="botao" id="btSalvar" onClick="buscaLiquidacoes('I_DADOS_AVAL'); return false;">Continuar</a>
	<? } ?>
</div>
