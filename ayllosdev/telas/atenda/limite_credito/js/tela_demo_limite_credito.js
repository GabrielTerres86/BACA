/**
 * Autor: Bruno Luiz Katzjarowski - Mout's
 * Data: 05/12/2018
 * Ultima alteração:
 * 
 * Alterações:
*/


//Formatar campos da tela Demonstração do Limite de Crédito
function formatarCamposDemoLimiteCredito(){
    /*   
    Campos:

    nivrisco -> Nível de Risco
    nrctrlim -> Número do Contrato
    vllimite -> Valor do Limite
    cddlinha -> Linha de Crédito
    dsdtxfix -> Taxa
    dtfimvig -> Data de Término <--- Não utilizada
    qtdiavig -> Vigência
    */
    $('label','#fsDemoLimiteCredito').css({
        'width': '120px'
    });
    
    $('#fsDemoLimiteCredito').css({
        'width':'300px'
    });

    var campos_demo = Array(
        "nivrisco",
        "nrctrlim",
        "vllimite",
        "cddlinha",
        "dsdtxfix"
    );

    for (var i = 0; i < campos_demo.length; i++) {
        var param = campos_demo[i];

        var val = $('#'+param,'#'+nomeForm).val();
        
        $('#demo'+upFirstLetter(param),'#'+nomeForm).val(val);
        $('#demo'+upFirstLetter(param),'#'+nomeForm).desabilitaCampo();
    }

    $('#demoQtdiavig','#'+nomeForm).desabilitaCampo();
    $('#demoQtdiavig','#'+nomeForm).val(var_globais.qtdiavig);
    
}

function upFirstLetter(string) {
    return string.charAt(0).toUpperCase() + string.slice(1);
}