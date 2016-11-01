<?php
/*****************************************************************
	Fonte        : form_opcoes.php						Última Alteração: 03/08/2016
  Criação      : Adriano
  Data criação : Maio/2013
  Objetivo     : Mostrar as rotinas da opção "R" e solicitar cpf/nit para as demais opções.
  --------------
	Alterações   : 10/03/2015 - Ajuste referente ao Histórico cadastral (Adriano - Softdesk 261226).
				 
				   20/10/2015 - Adicionada opção de geração de log Projeto 255 (Lombardi).
                              
				   03/08/2016 - Corrigi o uso desnecessario da funcao session_start. SD 491672 (Carlos R.)
  --------------
 ****************************************************************/ 
 
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');	
	require_once('../../class/xmlfile.php');
	isPostMethod();	
	
?>

<form id="frmOpcoes" name="frmOpcoes" class="formulario" style="display:none;">	
	
	<div id="divRelatorio" style="display: none;">
		
		<label for="tprelato">Relat&oacute;rio:</label>
		<select id="tprelato" name="tprelato" >
			<option value="A" selected> Benef&iacute;cios Pagos </option>
			<option value="B"> Benef&iacute;cios a Pagar e Bloqueados </option>					
			<option value="C"> Benef&iacute;cios Rejeitados </option>	
			<option value="D"> Hist&oacute;rico Cadastral </option>
		</select>
				
		<br style="clear:both" />	
			
	</div>
	
	<div id="divBeneficio" style="display: none;">	
	
		<label for="nrcpfcgc">C.P.F.:</label>
		<input id="nrcpfcgc" name="nrcpfcgc" type="text"></input>
		<a style="padding: 3px 0 0 3px;" href="#" onClick="controlaPesquisa(1); return false;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"/></a>			
		
		<label for="nrrecben">NB:</label>
		<input id="nrrecben" name="nrrecben" type="text"></input>
				
		<br />					
		<br style="clear:both" />			
				
	</div>
	
	<div id="divConsultaLog" style="display: none;">	
	
		<label for="dtmvtolt">Data:</label>
		<input id="dtmvtolt" name="dtmvtolt" type="text"></input>
		
		<label for="nrrecben">NB:</label>
		<input id="nrrecben" name="nrrecben" type="text"></input>
				
		<label for="nrdconta_log">Conta/dv:</label>
		<input id="nrdconta_log" name="nrdconta_log" type="text"></input>
				
		<br />					
		<br style="clear:both" />			
				
	</div>
				
</form>

<div id="divBotoesRelatorio" style="margin-top:5px; margin-bottom :10px; display:none; text-align: center;">
		
	<a href="#" class="botao" id="btVoltar" onClick="controlaVoltar('V1');">Voltar</a>
	
	<?for ($i = 0; $i < count($rotinas); $i++) {
		
		if($rotinas[$i] == "RELATORIO"){?>
				
			<a href="#" class="botao" id="btProsseguir" onClick="controlaRotina('<?echo $rotinas[$i];?>',$('#tprelato','#divRelatorio').val());return false;">Prosseguir</a>	
		
		<?}	
		
	}?>
	
	
</div>

<div id="divBotoesConta" style="margin-top:5px; margin-bottom :10px; display:none; text-align: center;">
	
	<a href="#" class="botao" id="btVoltar" onClick="controlaVoltar('V2');return false;">Voltar</a>
	<a href="#" class="botao" id="btProsseguir" onClick="solicitaConsultaBeneficiario($('#cddopcao','#frmCabInss').val());return false;" >Prosseguir</a>	
	
</div>

<div id="divBotoesLog" style="margin-top:5px; margin-bottom :10px; display:none; text-align: center;">
	
	<a href="#" class="botao" id="btVoltar" onClick="controlaVoltar('V9');return false;">Voltar</a>
	<a href="#" class="botao" id="btProsseguir" onClick="solicitaConsultaLog($('#cddopcao','#frmCabInss').val()
                                                                          ,$('#dtmvtolt','#divConsultaLog').val()
                                                                          ,$('#nrrecben','#divConsultaLog').val()
                                                                          ,$('#nrdconta_log','#divConsultaLog').val()
                                                                          ,1,20);
                                                       return false;" >Prosseguir</a>	
	
</div>

