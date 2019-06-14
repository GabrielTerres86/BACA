/**
 * Autor: Bruno Luiz Katzjarowski;
 * Data: 04/02/2018;
 * 
 * Obs.: Arquivo exclusivo para validação da tela de interveniente
 * 
 * Ultima alteração:
 * 
 * Alterações:
 */

function validaTelaInterveniente(){
    return validarCamposTelaInterveniente();
}

function validarCamposTelaInterveniente(inpessoa){
    hideMsgAguardo();
    var aux_nomeForm = "#frmIntevAnuente";

    if(typeof inpessoa == 'undefined'){
        inpessoa = $('#inpessoa',aux_nomeForm).val();
    }

    //Se não inseriu nenhum valor tanto no campo de conta e cpf/cnpj o usuario não está inserindo avalista. Não há necessidade
    //de validação
    if($('#nrctaava',aux_nomeForm).val() == "" && $('#nrcpfcgc',aux_nomeForm).val() == ""){
        return true;
    }

    //Se já possui conta de cooperado inserida não há necessidade de validação
    if($('#nrctaava',aux_nomeForm).val() != "" && $('#nrctaava',aux_nomeForm).val() != "0"){
        return true;
    }


    if(inpessoa != ""){
        switch(inpessoa){
            case '1':
                return validaintervenientePF();
            default:
                return validaintervenientePJ();
        }
    }else{
        return true;
    }

}

function  validaintervenientePF(){
    var aux_nomeForm = "#frmIntevAnuente";

    if(!validaDataAberturaNasciInterveniente()){
        return false;
    }

    //Validar campos de endereço
    if(!validaEnderecoInterveniente()){
        return false;
    }

    //Telefone: nrfonres
    if($('#nrfonres',aux_nomeForm).val() == ""){
        exibirErroAvalista('Favor inserir um Telefone.');
        return false;
    }else if(normalizaNumero($('#nrfonres',aux_nomeForm).val()).length > 11 || normalizaNumero($('#nrfonres',aux_nomeForm).val()).length < 10){
        exibirErroAvalista('Favor inserir um n&uacute;mero de Telefone v&aacute;lido');
        return false;
    }

    //E-mail: dsdemail 
    if($('#dsdemail',aux_nomeForm).val() == ""){
        exibirErroAvalista('Favor inserir um endere&ccedil;o de E-mail.');
        return false;
    }else if(!vaidaEmailAvalista($('#dsdemail',aux_nomeForm).val())){
        exibirErroAvalista('Favor inserir um endere&ccedil;o de E-mail v&aacute;lido.');
        return false;
    }

    return true;
}


function  validaintervenientePJ(){

    if(!validaDataAberturaNasciInterveniente()){
        return false;
    }

    //Validar campos de endereço
    if(!validaEnderecoInterveniente()){
        return false;
    }

    var aux_nomeForm = "#frmIntevAnuente";
    //Telefone: nrfonres
    if($('#nrfonres',aux_nomeForm).val() == ""){
        exibirErroAvalista('Favor inserir um Telefone.');
        return false;
    }else if(normalizaNumero($('#nrfonres',aux_nomeForm).val()).length > 11 || normalizaNumero($('#nrfonres',aux_nomeForm).val()).length < 10){
        exibirErroAvalista('Favor inserir um n&uacute;mero de Telefone v&aacute;lido');
        return false;
    }

    //E-mail: dsdemail 
    if($('#dsdemail',aux_nomeForm).val() == ""){
        exibirErroAvalista('Favor inserir um endere&ccedil;o de E-mail.');
        return false;
    }else if(!vaidaEmailAvalista($('#dsdemail',aux_nomeForm).val())){
        exibirErroAvalista('Favor inserir um endere&ccedil;o de E-mail v&aacute;lido.');
        return false;
    }
    
    return true;
}

/**
 * Autor: Bruno Luiz Katzjarowski
 * Data: 05/02/2019
 * bug - 14587
 */
function validaDataAberturaNasciInterveniente(inpessoa){
    var aux_nomeForm = "#frmIntevAnuente";

    if(typeof inpessoa == 'undefined'){
        inpessoa = $('#inpessoa',aux_nomeForm).val();
    }

    if($('#dtnascto',aux_nomeForm).val() == ""){
        if(inpessoa == "1"){
            exibirErroAvalista('Favor inserir uma Data de nascimento.');
        }else{
            exibirErroAvalista('Favor inserir uma Data de Abertura.');        
        }
        return false;
    }

    if(!validaDataAvalista($('#dtnascto',aux_nomeForm).val())){
        if(inpessoa == "1"){
            exibirErroAvalista('Favor inserir uma Data de nascimento valida.');
        }else{
            exibirErroAvalista('Favor inserir uma Data de Abertura valida.');        
        }
        return false;
    }
    return true;
}

/*
Autor: Bruno Luiz Katzjarowski
Data: 05/02/2019
bug - 14587
*/
function validaEnderecoInterveniente(){
    var aux_nomeForm = "#frmIntevAnuente";
    /**
     * nrcepend --> CEP
     * dsendre2 --> BAIRRO
     * cdufresd --> ESTADO/UF
     * nmcidade --> CIDADE
     */

    if($('#nrcepend',aux_nomeForm).val() == ""){
        exibirErroAvalista("Favor inserir um n&uacute;mero de CEP.");
        return false;
    }
    if($('#dsendre2',aux_nomeForm).val() == ""){
         exibirErroAvalista("Favor inserir um Endere&ccedil;o.");
        return false;
    }
    if($('#cdufresd',aux_nomeForm).val() == ""){
         exibirErroAvalista("Favor selecionar um estado (UF).");
        return false;
    }
    if($('#nmcidade',aux_nomeForm).val() == ""){
         exibirErroAvalista("Favor inserir uma Cidada.");
        return false;
    }
    
    return true;
}


/** 
 * --------------------------------------------------------
 *                  FUNCOES DE APOIO
 * --------------------------------------------------------
*/
 function exibirErroInterveniente(msg){
    showError('error', msg, 'Alerta - Aimaro', 'bloqueiaFundo(divRotina)');
 }

function vaidaEmailInterveniente(email) {
    var re = /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
    return re.test(email);
  }