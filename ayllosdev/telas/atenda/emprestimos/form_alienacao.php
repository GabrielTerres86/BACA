<?
/*!
 * FONTE        : form_alienacao.php
 * CRIAÇÃO      : Gabriel Capoia (DB1)
 * DATA CRIAÇÃO : 18/04/2011
 * OBJETIVO     : Formulário da rotina Emprestimos da tela ATENDA
 * ALTERAÇÕES   :
 * --------------
 * 000: [20/09/2011] Correções de acentuação - Marcelo L. Pereira (GATI)
 *
 *		[01/11/2012] Incluso função para definição mascara campo CPF/CNPJ (Daniel).
 *		[06/12/2013] Incluso função para definição mascara campo Nr Placa e Renavan(Guilherme/SUPERO).
 *		[29/01/2014] Substituída função criar o campo de UF Licenc (Guilherme/SUPERO).
 *		[21/03/2014] Campo idseqbem como Hidden (Guilherme/SUPERO).
 *      [21/07/2014] Removido o valor default de 999-9999 do campo Número da Placa. (James)
 *      [12/11/2014] Projeto consultas automatizadas (Jonata-RKAM).
 *      [13/01/2015] Adicionado Tipo de Veiculo. (Jorge/Gielow) - SD 241854.
 *		[25/01/2016] Alterar a chamada do botao Salvar. (James) 
 *
 */

if (!in_array($operacao,array('C_ALIENACAO','AI_ALIENACAO','A_ALIENACAO','E_ALIENACAO','I_ALIENACAO','IA_ALIENACAO','A_BENS','AI_BENS'))) {
  	require_once("./lib/metadados.php");
} else {
?>
	<script type="text/javascript" src="../manbem/scripts/historico_gravames.js"></script>
<?
}
	include('../../manbem/form_alie_veiculo.php');
?>
<div id="divBotoes">
	<? if ( $operacao == 'A_ALIENACAO' || $operacao == 'A_BENS' ) {
			if ($operacao == 'A_ALIENACAO') {
				$inicio = "A_INICIO";
			} else {
				$inicio = "AT";
			} ?>
		<a href="#" class="botao" id="btVoltar" onClick="controlaOperacao('<? echo $inicio; ?>'); return false;">Voltar</a>
		<a href="#" hidden="hidden" class="botao" id="btHistoricoGravame" onClick="controlaOperacao('C_HISTORICO_GRAVAMES'); return false;">Hist&oacute;rico Gravames</a>
		<a href="#" class="botao" id="btSalvar" onClick="validaAlienacao('atualizaArray(\'<? echo $operacao; ?>\');','<? echo $operacao; ?>'); return false;">Continuar</a>
	<? } else if ($operacao == 'AI_ALIENACAO' || $operacao == 'AI_BENS') {
			if ($operacao == 'AI_ALIENACAO') {
				$nova_opecacao = "A_ALIENACAO";
				$finalizacao = "A_INTEV_ANU";
				$inicio = "A_INICIO";
			} else {
				$nova_opecacao = "AI_BENS";
				$finalizacao = "A_BENSFIM";
				$inicio = "AT";
			} ?>
		<a href="#" class="botao" id="btVoltar" onClick="controlaOperacao('<? echo $inicio; ?>'); return false;">Voltar</a>
		<a href="#" class="botao" id="btSalvar" onClick="validaAlienacao('insereAlienacao(\'<? echo $nova_opecacao; ?>\',\'<? echo $finalizacao; ?>\');','<? echo $nova_opecacao; ?>'); return false;">Continuar</a>
	<? } else if ($operacao == 'C_ALIENACAO') { ?>
		<a href="#" class="botao" id="btVoltar" onClick="controlaOperacao('CF'); return false;">Voltar</a>
		<a href="#" hidden="hidden" class="botao" id="btHistoricoGravame" onClick="controlaOperacao('C_HISTORICO_GRAVAMES'); return false;">Hist&oacute;rico Gravames</a>
		<a href="#" class="botao" id="btSalvar" onClick="controlaOperacao('C_ALIENACAO'); return false;">Continuar</a>
	<? } else if ($operacao == 'E_ALIENACAO') { ?>
		<a href="#" class="botao" id="btVoltar" onClick="controlaOperacao(''); return false;">Voltar</a>
	<? } else if ($operacao == 'I_ALIENACAO') { ?>
		<a href="#" class="botao" id="btVoltar" onClick="controlaOperacao('I_INICIO'); return false;">Voltar</a>
		<a href="#" class="botao" id="btSalvar" onClick="validaAlienacao('insereAlienacao(\'I_ALIENACAO\',\'I_INTEV_ANU\');','I_ALIENACAO'); return false;">Continuar</a>
	<? } else if ( $operacao == 'IA_ALIENACAO' ) { ?>
		<a href="#" class="botao" id="btVoltar" onClick="controlaOperacao('I_INICIO'); return false;">Voltar</a>
		<a href="#" class="botao" id="btSalvar" onClick="validaAlienacao('atualizaArray(\'I_ALIENACAO\');','I_ALIENACAO'); return false;">Continuar</a>
	<? } ?>
</div>