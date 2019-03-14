/**
 * Autor: Bruno Luiz katzjarowski - Mouts's
 * Data: 11/02/2019
 * 
 * bug 14750
 */

/**
 * Validar se a linha selecionada está com situação 'ANULADA' e jogar critica correspondente.
 * @param linha tr linha da tabela
 * @param operacao_atual string operacao em andamento
 */
function validaAnulada(linha, operacao_atual){

    if(typeof operacao_atual == 'undefined'){
        operacao_atual = '';
    }

    var dssitest = $(linha).find("input[id='dssitest']").val();
    ///Anulada
    if(dssitest.toUpperCase() == 'ANULADA'){
        switch(operacao_atual){
            case 'T_EFETIVA':
                showError('error', 'A proposta n&atilde;o pode ser efetivada, verifique a situa&ccedil;&atilde;o da proposta.', 'Alerta - Aimaro', 'bloqueiaFundo(divRotina)');
                break;
            default:
        showError('error', 'A situa&ccedil;&atilde;o está "Anulada".', 'Alerta - Aimaro', 'bloqueiaFundo(divRotina)');
                break;
        }
        return false;
    }
    return true;
}