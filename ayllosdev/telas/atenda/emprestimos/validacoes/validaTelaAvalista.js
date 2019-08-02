/**
 * Autor: Bruno Luiz Katzjarowski - Mout's
 * Data: 17/01/2019
 * 
 * Arquivo exclusivo para validaçao da tela de avalistas
 * 
 * Ultima alteração:
 * 
 * Alterações:
 */


 /**
  * Descrição: Validar tela avalista
  */
 function validaTelaAvalistas(){
    return validarCamposTelaAvalista();
 }

 /**
  * Descrição: Validar somente campos da tela de avalista
  */
 function validarCamposTelaAvalista(inpessoa){

    //hideMsgAguardo(); //bruno - prj 438 - bug 14400
    var aux_nomeForm = "#frmDadosAval";

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
                return validaAnalistaPF();
                break;
            default:
                return validaAnalistaPJ();
                break;
        }
    }else{
        return true;
    }
 }

 function validaAnalistaPF(){

    var aux_nomeForm = "#frmDadosAval";
    //Nacionalidade: cdnacion
    if($('#cdnacion',aux_nomeForm).val() == ""){
        exibirErroAvalista('Favor inserir uma Nacionalidade.');
        return false;
    }

    //Data de Abertura: dtnascto
    if($('#dtnascto',aux_nomeForm).val() == ""){
        exibirErroAvalista('Favor inserir uma Data de Nascimento.');
        return false;
    }else if($('#dtnascto',aux_nomeForm).val() != '' && typeof $('#dtnascto',aux_nomeForm).val() != "undefined"){ //bruno - prj 438 - bug 6666
        if(!validaDataAvalista($('#dtnascto',aux_nomeForm).val())){
        exibirErroAvalista('Data de Nascimento invalida.');
        return false;
    }
    }

    //Telefone: nrfonres
    if($('#nrfonres',aux_nomeForm).val() == ""){
        exibirErroAvalista('Favor inserir um Telefone.');
        return false;
    }

    //E-mail: dsdemail 
    // if($('#dsdemail',aux_nomeForm).val() == ""){
    //     exibirErroAvalista('Favor inserir um endereco de E-mail.');
    //     return false;
    // }else
    if($('#dsdemail',aux_nomeForm).val() !== ""){
        if(!vaidaEmailAvalista($('#dsdemail',aux_nomeForm).val())){
        exibirErroAvalista('Favor inserir um endereco de E-mail valido.');
        return false;
        }
    }

    //Rendimento Mensal: vlrenmes
    if($('#vlrenmes',aux_nomeForm).val() == ""){
        exibirErroAvalista('Favor preencher Rendimento Mensal.');
        return false;
    }

    return true;
 }

 function validaAnalistaPJ(){
    var aux_nomeForm = "#frmDadosAval";
    //Nacionalidade: cdnacion
    // Rafael Ferreira (Mouts) - Story 13447
    //if($('#cdnacion',aux_nomeForm).val() == ""){
    //    exibirErroAvalista('Favor inserir uma Nacionalidade.');
    //    return false;
    //}

    //Data de Abertura: dtnascto
    if($('#dtnascto',aux_nomeForm).val() == ""){
        exibirErroAvalista('Favor inserir uma Data de Abertura.');
        return false;
    }else if($('#dtnascto',aux_nomeForm).val() != '' && typeof $('#dtnascto',aux_nomeForm).val() != "undefined"){ //bruno - prj 438 - bug 6666
        if(!validaDataAvalista($('#dtnascto',aux_nomeForm).val())){
        exibirErroAvalista('Data de Abertura invalida.');
        return false;
    }
    }

    //Telefone: nrfonres
    if($('#nrfonres',aux_nomeForm).val() == ""){
        exibirErroAvalista('Favor inserir um Telefone.');
        return false;
    }

    //E-mail: dsdemail 
    // if($('#dsdemail',aux_nomeForm).val() == ""){
    //     exibirErroAvalista('Favor inserir um endereco de E-mail.');
    //     return false;
    // }else
    if($('#dsdemail',aux_nomeForm).val() !== ""){
        if(!vaidaEmailAvalista($('#dsdemail',aux_nomeForm).val())){
        exibirErroAvalista('Favor inserir um endereco de E-mail valido.');
        return false;
        }    
    }

    //Faturamente médio Mensal: vlrenmes
    if($('#vlrenmes',aux_nomeForm).val() == ""){
        exibirErroAvalista('Favor preencher Faturamente Medio Mensal.');
        return false;
    }

    return true;
 }

/** 
 * --------------------------------------------------------
 *                  FUNCOES DE APOIO
 * --------------------------------------------------------
*/
 function exibirErroAvalista(msg){
    showError('error', msg, 'Alerta - Aimaro', 'hideMsgAguardo();bloqueiaFundo($(\'#divRotina\'));'); //bruno - prj 438 - bug 18013
 }

 function validaDataAvalista(data){
        var regex = "\\d{2}/\\d{2}/\\d{4}";
        var dtArray = data.split("/");

        if (dtArray == null)
            return false;

        // Checks for dd/mm/yyyy format.
        var dtDay= dtArray[0];
        var dtMonth = dtArray[1];
        var dtYear = dtArray[2];

        if (dtMonth < 1 || dtMonth > 12){
            return false;
        }else if (dtDay < 1 || dtDay> 31){
            return false;
        }else if ((dtMonth==4 || dtMonth==6 || dtMonth==9 || dtMonth==11) && dtDay ==31){
            return false;
        }else if (dtMonth == 2){
            var isleap = (dtYear % 4 == 0 && (dtYear % 100 != 0 || dtYear % 400 == 0));
            if (dtDay> 29 || (dtDay ==29 && !isleap)){
                return false;
            }
        }
        return true;
    }

 function vaidaEmailAvalista(email) {
    var re = /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
    return re.test(email);
  }