/**
 * Autor: Bruno Luiz Katzjarowski - Mout's
 * Data: 05/12/2018
 * Ultima alteração:
 * 
 * Alterações:
 */

/**
 * Atualizar campos tela rating
 * @param {Array{nrgarope,nrinfcad,nrliquid,nrpatlvr,nrperger}} dados aux_rating -> cadastrar_novo_limite.php
 */
function atualizarCamposRating(dados){
    aplicarEventosLupasTelaRating();
    
    var aux_nomeForm = '#frmNovoLimite';

    $('#nrgarope',aux_nomeForm).val(dados.nrgarope);
    $('#nrgarope',aux_nomeForm).trigger('change');

    $('#nrinfcad',aux_nomeForm).val(dados.nrinfcad);
    $('#nrinfcad',aux_nomeForm).trigger('change');

    $('#nrliquid',aux_nomeForm).val(dados.nrliquid);
    $('#nrliquid',aux_nomeForm).trigger('change');

    $('#nrpatlvr',aux_nomeForm).val(dados.nrpatlvr);
    $('#nrpatlvr',aux_nomeForm).trigger('change');

    $('#nrperger',aux_nomeForm).val(dados.nrperger);
    $('#nrperger',aux_nomeForm).trigger('change');
}