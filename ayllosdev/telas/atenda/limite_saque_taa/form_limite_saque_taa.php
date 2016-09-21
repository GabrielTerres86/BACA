<? 
/*!
 * FONTE        : form_limite_saque_taa.php
 * CRIAÇÃO      : James Prust Junior
 * DATA CRIAÇÃO : Julho/2015
 * OBJETIVO     : Formulário da rotina Limite Saque TAA da tela de ATENDA
 * --------------
 * ALTERAÇÕES   :
 * --------------
 */	
?>
<form name="frmLimiteSaqueTAA" id="frmLimiteSaqueTAA" class="formulario" >

	<fieldset>
		
		<legend>Limite de Saque</legend>

			<label for="vllimite_saque">Limite de Saque: </label>
			<input type="text" name="vllimite_saque" id="vllimite_saque" />
			
			<br />
			
			<label for="flgemissao_recibo_saque">Recibo de Saque: </label>
			<select id="flgemissao_recibo_saque" name="flgemissao_recibo_saque">
				<option value="1">Emite</option>
				<option value="0">Não Emite</option>
			</select>
			
			<br />
			
			<label for="dtalteracao_limite">Data Última Alteração: </label>
			<input type="text" name="dtalteracao_limite" id="dtalteracao_limite" />
			
			<br />
			
			<label for="nmoperador_alteracao">Operador: </label>
			<input type="text" name="nmoperador_alteracao" id="nmoperador_alteracao" />

	</fieldset>
	
</form>

<div id="divBotoes">		
	<? if ($nomeRotinaPai == 'magnetico'){ ?>	
  		  <input type="image" id="btVoltar"  src="<? echo $UrlImagens; ?>botoes/cancelar.gif" onClick="acessaOpcaoAba('0','0','@'); return false;" />		
	 	  <input type="image" id="btSalvar"  src="<? echo $UrlImagens; ?>botoes/concluir.gif" onClick="controlaOperacaoLimiteSaqueTAA('CONCLUIR','<?= $nomeRotinaPai ?>')" />

	<? }else if ($nomeRotinaPai == 'cartao_credito'){ ?>
  		  
		  <a class="botao" onclick="acessaOpcaoAba('0','0','@'); return false;" href="#">Cancelar</a>
		  <a class="botao" onClick="controlaOperacaoLimiteSaqueTAA('CONCLUIR','<?= $nomeRotinaPai ?>');return false;" href="#">Concluir</a>

	<? }else{ ?>
	
		<? if ( in_array($operacao,array('AC',''))){ ?>
			<a class="botao" onclick="encerraRotina(true); return false;" href="#">Voltar</a>
			<a class="botao" onClick="controlaOperacaoLimiteSaqueTAA('CA');return false;" href="#">Alterar</a>
		  
		<? } else if ( $operacao == 'CA' ){ ?>
			<a class="botao" onclick="controlaOperacaoLimiteSaqueTAA('AC'); return false;" href="#">Cancelar</a>
			<a class="botao" onClick="controlaOperacaoLimiteSaqueTAA('CONCLUIR');return false;" href="#">Concluir</a>
			
		<? }?>	
	
	<? } ?>	
</div>
