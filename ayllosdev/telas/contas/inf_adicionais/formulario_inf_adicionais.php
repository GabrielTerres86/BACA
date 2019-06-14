<?
/*!
 * FONTE        : funcoes.php
 * CRIAÇÃO      : Rodolpho Telmo (DB1)
 * DATA CRIAÇÃO : 14/04/2010
 * OBJETIVO     : Formulário para tela de INF. ADICIONAIS da rotina de CONTAS
 
   ALTERACOES   : 16/09/2010 - Incluir campo de observacao na pessoa fisica
							   tambem (Gabriel).	
							   
				  06/08/2015 - Reformulacao Cadastral (Gabriel-RKAM)

				  18/09/2017 - Alterei a forma de limitacao de caracteres no campo
							   Inf. Complem. (SD 754979 - Carlos Rafael Tanholi)
 */
?>
 
 <form name="frmInfAdicional" id="frmInfAdicional" class="formulario">

 		<label for="nrinfcad"><? echo utf8ToHtml('Informações cadastrais:') ?></label><br />
		<input name="nrinfcad" id="nrinfcad" type="text" value="<? echo $nrinfcad; ?>" />
		<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
		<input name="dsinfcad" id="dsinfcad" type="text" value="<? echo getByTagName($infAdicionais,'dsinfcad'); ?>" />
		<br />
		
		<label for="nrpatlvr"><? echo utf8ToHtml('Patrimônio pessoal livre em relação ao endividamento:') ?></label><br />
		<input name="nrpatlvr" id="nrpatlvr" type="text" value="<? echo $nrpatlvr; ?>" />
		<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
		<input name="dspatlvr" id="dspatlvr" type="text" value="<? echo getByTagName($infAdicionais,'dspatlvr'); ?>" />
		<br />
		
		<div id="divJuridico">
			<label for="nrperger"><? echo utf8ToHtml('Percepção geral com relação a empresa:'); ?></label><br />
			<input name="nrperger" id="nrperger" type="text" value="<? echo getByTagName($infAdicionais,'nrperger'); ?>" />
			<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
			<input name="dsperger" id="dsperger" type="text" value="<? echo getByTagName($infAdicionais,'dsperger'); ?>" />
			<br />
			
		</div>	
		
		<label for="dsinfadi"><? echo utf8ToHtml('Informações complementares:') ?></label><br />
		<textarea name="dsinfadi" id="dsinfadi" maxlength="365"><? echo juntaTexto($textareaTags) ?></textarea>
				
								
		<br clear="both" />
</form>

<div id="divBotoes">		
	<? if ( in_array($operacao,array('AC','FA','')) ) { ?>
		
		<input type="image" id="btVoltar"  src="<? echo $UrlImagens; ?>botoes/voltar.gif"  onClick="fechaRotina(divRotina);"   />
		<input type="image" id="btAlterar" src="<? echo $UrlImagens; ?>botoes/alterar.gif"  onClick="controlaOperacao('CA')" />
		
	<? } else if ( $operacao == 'CA' ) { ?>
	
		<? if ($flgcadas == 'M' ) { ?>
			<input type="image" id="btVoltar"  src="<? echo $UrlImagens; ?>botoes/voltar.gif"  onClick="voltarRotina();" />
		<? } else { ?>
			<input type="image" id="btVoltar"  src="<? echo $UrlImagens; ?>botoes/cancelar.gif" onClick="controlaOperacao('AC')" />		
		<? } ?>
	
		<input type="image" id="btSalvar"  src="<? echo $UrlImagens; ?>botoes/concluir.gif" onClick="controlaOperacao('AV');" />
	<? } ?>
	
		<input type="image" id="btContinuar"  src="<? echo $UrlImagens; ?>botoes/continuar.gif" onClick="controlaContinuar();" />

</div>