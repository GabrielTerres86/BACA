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
 */

if (!in_array($operacao,array('C_ALIENACAO','AI_ALIENACAO','A_ALIENACAO','E_ALIENACAO','I_ALIENACAO','IA_ALIENACAO'))) {
  	require_once("./lib/metadados.php");
}
	include('../../manbem/form_alie_veiculo.php');
 ?>
<div id="divBotoes">
	<? if ( $operacao == 'A_ALIENACAO' ) { ?>
		<a href="#" class="botao" id="btVoltar" onClick="controlaOperacao('A_INICIO'); return false;">Voltar</a>
		<a href="#" hidden="hidden" class="botao" id="btHistoricoGravame" onClick="controlaOperacao('C_HISTORICO_GRAVAMES'); return false;">Hist&oacute;rico de Gravames</a>
		<a href="#" class="botao" id="btSalvar" onClick="validaAlienacao('atualizaArray(\'A_ALIENACAO\');','A_ALIENACAO'); return false;">Continuar</a>
	<? } else if ($operacao == 'AI_ALIENACAO') { ?>
		<a href="#" class="botao" id="btVoltar" onClick="controlaOperacao('A_INICIO'); return false;">Voltar</a>
		<a href="#" hidden="hidden" class="botao" id="btHistoricoGravame" onClick="controlaOperacao('C_HISTORICO_GRAVAMES'); return false;">Hist&oacute;rico de Gravames</a>
		<a href="#" class="botao" id="btSalvar" onClick="validaAlienacao('insereAlienacao(\'A_ALIENACAO\',\'A_INTEV_ANU\');','A_ALIENACAO'); return false;">Continuar</a>		
	<? } else if ($operacao == 'C_ALIENACAO') { ?>
		<a href="#" class="botao" id="btVoltar" onClick="controlaOperacao('CF'); return false;">Voltar</a>
		<a href="#" hidden="hidden" class="botao" id="btHistoricoGravame" onClick="controlaOperacao('C_HISTORICO_GRAVAMES'); return false;">Hist&oacute;rico de Gravames</a>
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

<script>
	/*$(document).ready(function() {
        highlightObjFocus($('#frmTipo'));
	});

	function VerificaPessoa( campo ){
		if ( verificaTipoPessoa( campo ) == 1 ) {
		$('#nrcpfbem', '#frmAlienacao').setMask('INTEGER','999.999.999-99','.-','');
		} else if( verificaTipoPessoa( campo ) == 2 ) {
			$('#nrcpfbem', '#frmAlienacao').setMask('INTEGER','z.zzz.zzz/zzzz-zz','/.-','');
		} else {
			$('#nrcpfbem', '#frmAlienacao').setMask('INTEGER', 'zzzzzzzzzzzzzz','','');
		}
	};

    function formataCategoriaBem(dscatbem) {

        $('#nrdplaca', '#frmAlienacao').removeClass('placa');
		$('#nrdplaca', '#frmAlienacao').setMask('STRING' ,'zzzzzzz','','');
    };*/
</script>
