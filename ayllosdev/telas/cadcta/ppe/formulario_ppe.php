<?php 
/*!
 * FONTE        : contas/ppe/formulario_ppe.php					Última alteração: 08/03/2017
 * CRIAÇÃO      : Carlos Henrique (CECRED)
 * DATA CRIAÇÃO : 24/05/2010 
 * OBJETIVO     : Formulário de dados de Comercial/PPE da tela de CONTAS
 * --------------
 * ALTERAÇÕES   : 21/02/2017 - Ajuste para inclusão de novos campos (Adriano - SD 614408). 

	              08/03/2017 - Ajuste para alterar o nome do campo nmempresa para nmemporg (Adriano - SD 614408).
 */	
?>
<form name="frmDadosPpe" id="frmDadosPpe" class="formulario">
	<fieldset>
		<legend>Pessoa Exposta Politicamente</legend>
	
		<input name="inpolexp" id="inpolexp" type="hidden" value="<? echo getByTagName($ppe,'inpolexp') ?>" />
		<input name="nmextttl" id="nmextttl" type="hidden" value="<? echo getByTagName($ppe,'nmextttl') ?>" />
		<input name="rsocupa"  id="rsocupa"  type="hidden" value="<? echo getByTagName($ppe,'rsocupa') ?>" />
		<input name="nrcpfcgc" id="nrcpfcgc" type="hidden" value="<? echo formataNumericos('999.999.999-10',getByTagName($ppe,'nrcpfcgc'),'.-'); ?>" />
	    <input name="nrdconta" id="nrdconta" type="hidden" value="<? echo getByTagName($ppe,'nrdconta') ?>" />
		<input name="cidade"   id="cidade"   type="hidden" value="<? echo getByTagName($ppe,'cidade') ?>" />
	
		<div style="height:36px">

			<label for="tpexposto">Tp. Exposto:</label>
			<select name="tpexposto" id="tpexposto" onchange="atualizaTipoExposto(this)">
				<option value=""> - </option>
				<option value="1" <? if (getByTagName($ppe,'tpexposto') == '1') { echo " selected"; } ?>>1 - Exerce/Exerceu</option>
				<option value="2" <? if (getByTagName($ppe,'tpexposto') == '2') { echo " selected"; } ?>>2 - Relacionamento</option>
			</select>
			
			<br />

			<label for="cdocpttl">Ocupação:</label>
			<input name="cdocpttl" id="cdocpttl" type="text" value="<? echo getByTagName($ppe,'cdocupacao') ?>" />
			<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
			
			<input name="rsocupa" id="rsocupa" type="text" value="<? echo getByTagName($ppe,'rsocupa') ?>" />
			
		</div>

		<div style="height:60px">

			<div id="divExposto1">
				<label for="nmempresa">Nome Empresa:</label>
				<input name="nmempresa" id="nmempresa" type="text" value="<? echo getByTagName($ppe,'nmempresa') ?>"  />
				
				<label for="nrcnpj_empresa">CNPJ:</label>
				<input name="nrcnpj_empresa" id="nrcnpj_empresa" class="cnpj" type="text" value='<? echo formataNumericos("99.999.999/9999-99",getByTagName($ppe,'nrcnpj_empresa'),"./-"); ?>'  />
				
				<br />

				<label for="dtinicio">Dt. Início:</label>
				<input name="dtinicio" id="dtinicio" type="text" value="<? echo getByTagName($ppe,'dtinicio') ?>" />			
				
				<label for="dttermino" style="width:85px">Dt. Término:</label>
				<input name="dttermino" id="dttermino" type="text" value="<? echo getByTagName($ppe,'dttermino') ?>" />
				
			</div>

			<div id="divExposto2">
				
				<label for="nmpolitico">Nome do Relacionado:</label>
				<input name="nmpolitico" id="nmpolitico" type="text" value="<? echo getByTagName($ppe,'nmpolitico'); ?>" />
			
				<label for="nrcpf_politico">CPF:</label>
				<input name="nrcpf_politico" id="nrcpf_politico" type="text" class="cpf" value="<? echo formataNumericos('999.999.999-10',getByTagName($ppe,'nrcpf_politico'),'.-'); ?>"  />
				
				<br />

				<label for="nmemporg">Nome Empresa:</label>
				<input name="nmemporg" id="nmemporg" type="text" value="<? echo getByTagName($ppe,'nmempresa') ?>"  />

				<br />

				<label for="cdrelacionamento">Tp. relacionamento:</label>
				<input name="cdrelacionamento" id="cdrelacionamento" type="text" value="<? echo getByTagName($ppe,'cdrelacionamento') ?>" />
				<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
					
				<br />

				<input name="dsrelacionamento" id="dsrelacionamento" type="text" value="<? echo getByTagName($ppe,'dsrelacionamento') ?>"  />
								
			</div>		
		</div>
	
	</fieldset>

</form>

<div id="divBotoes" style="margin-top:5px; margin-bottom :10px; display:none; text-align: center;">
	<a href="#" class="botao" id="btVoltar" onClick="controlaOperacao('AC');return false;;">Voltar</a>
		
	<?  if (getByTagName($ppe,'inpolexp') == 1) { ?>		
		<a href="#" class="botao" id="btPpeAlterar" onClick="controlaOperacao('VA');return false;">Alterar</a>
	<?  } ?>
	<?  if (getByTagName($ppe,'inpolexp') <> 2) { ?>		
		<a href="#" class="botao" id="btContinuar" onClick="proximaRotina();return false;">Continuar</a>
	<?  } ?>
</div>

<script>
	
	$('#divBotoes').css('display','block');
	$('#divExposto1','#'+nomeForm).css('display', '<? echo ($tpexposto == 1)? 'block':'none' ?>');
	$('#divExposto2','#'+nomeForm).css('display', '<? echo ($tpexposto == 2)? 'block':'none' ?>');
	
</script>
