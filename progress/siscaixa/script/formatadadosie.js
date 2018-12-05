/*
Programa: formatadadosie.js

Alteracoes: 15/12/2008 - Alteracoes para unificacao dos bancos de dados (Evandro).

            31/08/2009 - Permitir alterar o tamanho da janela principal do caixa
                         (Evandro).

            17/03/2010 - Adicionada a rotina 61 (Evandro).

            01/06/2011 - Adicionada a rotina IP - Impressora (Adriano).

            27/07/2011 - Adicionado as rotinas 66 e 86 (Guilherme).

            03/11/2011 - Adicionado rotina 22 (Elton).

            17/10/2012 - Adicionado fungco para formatar CEP (Daniel).

            16/04/2013 - Passado parametro v_sangria na chamada das seguintes
                          rotinas: 14,20,22,51,55,56,57,58,61 e 80. (Fabricio)

            20/05/2013 - Adicionado rotina 41 e 42 (Elton).

            24/06/2014 - Adicionada a rotina 87 (Carlos)

            30/06/2014 - Adicionado rotina 88 (Guilherme/SUPERO)

            08/09/2014 - Inclusão Rotina 30 (Lucas Lunelli)
                         Liberação Out/2014.

            28/11/2014 - Funcao para nao permitir informar caracteres e valores
                         negativos para os campos de valor em dinheiro e chaque
                         (Douglas - Chamado 226702)

            06/01/2015 - Ajustado o "FormataValorDeposito" para iniciar o preenchimento
                         do valor do campo pelos decimais (Douglas - Chamado 226702)

            18/03/2015 - Melhoria SD 260475 (Lunelli).

            24/08/2015 - Remocao das rotinas 82 e 83, e inclusao da
                         rotina 89
                         Inclusao formataLinDigGPS
                         (Guilherme/SUPERO)

			25/02/2016  - Adicionadas funções utf8_encode, md5, e dechex para 
						  geração da WorkingKey, dentre outras para comunicação com PinPad Novo
						  (Lucas Lunelli - Projeto 290 - Cartões CECRED no CaixaOnline [PROJ290])

			31/05/2016 - Alteraçoes Oferta DEBAUT Sicredi (Lucas Lunelli - [PROJ320])

		    23/08/2016  - Adicionado funções "setFocus()" e "callBlass()", para chamada do cartão assinatura (Evandro - RKAM).
		    
		    04/09/2017 - Removido rotinas 84, 85 pois nao serao mais usadas (Tiago/Elton #679866).
		    
		    16/11/2017 - Inclusao da rotina 97. (SD 788441 - Kelvin).
		   
			02/05/2018 - Bloqueio da rotina 66. (SCTASK00113081 - Kelvin)
*/

// < ! --
//Bloco de csdigo para esconder e mostra form
var Ver4 = parseInt(navigator.appVersion) >= 4
var IE4 = ((navigator.userAgent.indexOf("MSIE") != -1) && Ver4)
var block = "formulario";

function esconde() {        document.forms.style.visibility = "hidden" }
function mostra() { document.forms.style.visibility = "visible" }
//Bloco de csdigo para esconder e mostra form


// Csdigo para o teclado
function tecladown (digito){
        if (digito == ''){
                document.forms.senha.value = '';
                return;
        }
        var pass = document.forms.senha.value;
        if (pass.length >= 8){
                return;
        }
        document.forms.senha.value = document.forms.senha.value + digito;
}
function teclaclick(tecla){
        return false;
}
function teclaup(tecla){
        tecladown(tecla);
}
// --


// -- Contador para objeto TextArea.
function limita(campo){
        var tamanho = document.forms[campo].value.length;
        var tex=document.forms[campo].value;
        if (tamanho>=1199) {
                document.forms[campo].value=tex.substring(0,1199);
        }
        return true;
}

function contacampo(campo, tamtxt) {
document.forms[tamtxt].value =  1200-document.forms[campo].value.length;
}
// --

function SetHelp(txt) { help.innerText = txt ; }

function FormataCgc(campo,tammax,teclapres) {
        var tecla = teclapres.keyCode;
        vr = document.forms[campo].value;
        vr = vr.replace( "/", "" );
        vr = vr.replace( "/", "" );
        vr = vr.replace( "/", "" );
        vr = vr.replace( ",", "" );
        vr = vr.replace( ".", "" );
        vr = vr.replace( ".", "" );
        vr = vr.replace( ".", "" );
        vr = vr.replace( ".", "" );
        vr = vr.replace( ".", "" );
        vr = vr.replace( ".", "" );
        vr = vr.replace( ".", "" );
        vr = vr.replace( "-", "" );
        vr = vr.replace( "-", "" );
        vr = vr.replace( "-", "" );
        vr = vr.replace( "-", "" );
        vr = vr.replace( "-", "" );
        tam = vr.length;

        if (tam < tammax && tecla != 8){ tam = vr.length + 1 ; }

        if (tecla == 8 ){        tam = tam - 1 ; }

        if ( tecla == 8 || tecla >= 48 && tecla <= 57 || tecla >= 96 && tecla <= 105 ){
                if ( tam <= 2 ){
                         document.forms[campo].value = vr ; }
                 if ( (tam > 2) && (tam <= 6) ){
                         document.forms[campo].value = vr.substr( 0, tam - 2 ) + '-' + vr.substr( tam - 2, tam ) ; }
                 if ( (tam >= 7) && (tam <= 9) ){
                         document.forms[campo].value = vr.substr( 0, tam - 6 ) + '/' + vr.substr( tam - 6, 4 ) + '-' + vr.substr( tam - 2, tam ) ; }
                 if ( (tam >= 10) && (tam <= 12) ){
                         document.forms[campo].value = vr.substr( 0, tam - 9 ) + '.' + vr.substr( tam - 9, 3 ) + '/' + vr.substr( tam - 6, 4 ) + '-' + vr.substr( tam - 2, tam ) ; }
                 if ( (tam >= 13) && (tam <= 14) ){
                         document.forms[campo].value = vr.substr( 0, tam - 12 ) + '.' + vr.substr( tam - 12, 3 ) + '.' + vr.substr( tam - 9, 3 ) + '/' + vr.substr( tam - 6, 4 ) + '-' + vr.substr( tam - 2, tam ) ; }
                 if ( (tam >= 15) && (tam <= 17) ){
                         document.forms[campo].value = vr.substr( 0, tam - 14 ) + '.' + vr.substr( tam - 14, 3 ) + '.' + vr.substr( tam - 11, 3 ) + '.' + vr.substr( tam - 8, 3 ) + '.' + vr.substr( tam - 5, 3 ) + '-' + vr.substr( tam - 2, tam ) ;}
        }
}

function VerificaJava()
         {
        if (navigator.javaEnabled())
                document.forms.javas.value="sim"
        }

function FormataCpf(campo,tammax,teclapres) {
        var tecla = teclapres.keyCode;
        vr = document.forms[campo].value;
        vr = vr.replace( "/", "" );
        vr = vr.replace( "/", "" );
        vr = vr.replace( ",", "" );
        vr = vr.replace( ".", "" );
        vr = vr.replace( ".", "" );
        vr = vr.replace( ".", "" );
        vr = vr.replace( ".", "" );
        vr = vr.replace( "-", "" );
        vr = vr.replace( "-", "" );
        vr = vr.replace( "-", "" );
        vr = vr.replace( "-", "" );
        vr = vr.replace( "-", "" );
        tam = vr.length;

        if (tam < tammax && tecla != 8){ tam = vr.length + 1 ; }

        if (tecla == 8 ){        tam = tam - 1 ; }

        if ( tecla == 8 || tecla >= 48 && tecla <= 57 || tecla >= 96 && tecla <= 105 ){
                if ( tam <= 2 ){
                         document.forms[campo].value = vr ; }
                 if ( (tam > 2) && (tam <= 5) ){
                         document.forms[campo].value = vr.substr( 0, tam - 2 ) + '-' + vr.substr( tam - 2, tam ) ; }
                 if ( (tam >= 6) && (tam <= 8) ){
                         document.forms[campo].value = vr.substr( 0, tam - 5 ) + '.' + vr.substr( tam - 5, 3 ) + '-' + vr.substr( tam - 2, tam ) ; }
                 if ( (tam >= 9) && (tam <= 11) ){
                         document.forms[campo].value = vr.substr( 0, tam - 8 ) + '.' + vr.substr( tam - 8, 3 ) + '.' + vr.substr( tam - 5, 3 ) + '-' + vr.substr( tam - 2, tam ) ; }
                 if ( (tam >= 12) && (tam <= 14) ){
                         document.forms[campo].value = vr.substr( 0, tam - 11 ) + '.' + vr.substr( tam - 11, 3 ) + '.' + vr.substr( tam - 8, 3 ) + '.' + vr.substr( tam - 5, 3 ) + '-' + vr.substr( tam - 2, tam ) ; }
                 if ( (tam >= 15) && (tam <= 17) ){
                         document.forms[campo].value = vr.substr( 0, tam - 14 ) + '.' + vr.substr( tam - 14, 3 ) + '.' + vr.substr( tam - 11, 3 ) + '.' + vr.substr( tam - 8, 3 ) + '.' + vr.substr( tam - 5, 3 ) + '-' + vr.substr( tam - 2, tam ) ;}
        }
}

function Apaga(){
        if (document.forms.elements.length != 0)
                for (i = 0; i < document.forms.elements.length; i++)
                {
                        if( document.forms[i].type != "hidden" )
                                document.forms[i].value="";
                }
}


var da = (document.all) ? 1 : 0;
var pr = (window.print) ? 1 : 0;
var mac = (navigator.userAgent.indexOf("Mac") != -1);

function printPage()
{
  if (pr) // NS4, IE5
    window.print()
  else if (da && !mac) // IE4 (Windows)
    vbPrintPage()
  else // other browsers
    alert("Desculpe seu browser nco suporta esta fungco. Por favor utilize a barra de trabalho para imprimir a pagina.");
  return false;
}

if (da && !pr && !mac) with (document) {
  writeln('<OBJECT ID="WB" WIDTH="0" HEIGHT="0" CLASSID="clsid:8856F961-340A-11D0-A96B-00C04FD705A2"></OBJECT>');
  writeln('<' + 'SCRIPT LANGUAGE="VBScript">');
  writeln('Sub window_onunload');
  writeln('  On Error Resume Next');
  writeln('  Set WB = nothing');
  writeln('End Sub');
  writeln('Sub vbPrintPage');
  writeln('  OLECMDID_PRINT = 6');
  writeln('  OLECMDEXECOPT_DONTPROMPTUSER = 2');
  writeln('  OLECMDEXECOPT_PROMPTUSER = 1');
  writeln('  On Error Resume Next');
  writeln('  WB.ExecWB OLECMDID_PRINT, OLECMDEXECOPT_DONTPROMPTUSER');
  writeln('End Sub');
  writeln('<' + '/SCRIPT>');
}
/*vr = document.forms[campo].value;*/

function FormataDado(campo,tammax,pos,teclapres){
        var tecla = teclapres.keyCode;
   vr = campo.value;
        vr = vr.replace( "-", "" );
        vr = vr.replace( ".", "" );
        vr = vr.replace( "/", "" );
        tam = vr.length ;

   /*aqui valida inteiro*/
   if ( ( tecla < 48 || tecla > 57 && tecla < 96 || tecla > 105) && tecla != 8 && tecla != 9){
      event.returnValue = false;
      return;
   }

   /*formato de conta bancaria*/
        if (tam < tammax && tecla != 8){ tam = vr.length + 1 ; }

        if (tecla == 8 ){ tam = tam - 1 ; }

        if ( tecla == 8 || tecla == 88 || tecla >= 48 && tecla <= 57 || tecla >= 96 && tecla <= 105 ){
                if ( tam <= 2 ){
                         campo.value = vr ;}
                if ( tam > pos && tam <= tammax ){
                        campo.value = vr.substr( 0, tam - pos ) + '-' + vr.substr( tam - pos, tam );}
        }
}

function alteraFoco(){
   alert(campo);
        if(campo == "98") {
                return;
        }
        if (document.forms[0].elements[campo])
                document.forms[0].elements[campo].focus();
}
/******************/

///fungco para iniciar a tela com o campo focado///
function main(campofoco) {
   document.forms[0].elements[campofoco].focus();
}

///fungco para mudar o foco de um campo para outro///
function mudaFoco(){

   var i_campo = 0;

   if (document.forms[0].vh_foco.value == "")
      document.forms[0].vh_foco.value = 0;

   i_campo = document.forms[0].vh_foco.value;

   while ((document.forms[0].elements[i_campo].disabled ||
           document.forms[0].elements[i_campo].type == "hidden")
       && i_campo < document.forms[0].length) {

         i_campo++;
   }

   if (document.forms[0].elements[i_campo].disabled ||
       document.forms[0].elements[i_campo].type == "hidden") {
      i_campo = 0;
      while ((document.forms[0].elements[i_campo].disabled ||
              document.forms[0].elements[i_campo].type == "Hidden")
          && i_campo < document.forms[0].vh_foco.value) {
         i_campo++;
      }
   }

   if (document.forms[0].elements[i_campo].disabled == false &&
       document.forms[0].elements[i_campo].type != "hidden")
      document.forms[0].elements[i_campo].focus();
}

///fungco para validar campos com valores inteiros///
function validaInteiro(teclapres){
   var tecla = teclapres.keyCode;

   if ( ( (tecla < 37 || tecla > 40) && (tecla < 48 || tecla > 57) && (tecla < 96 || tecla > 105)) && tecla != 8 && tecla != 9 && tecla!= 46){
         event.returnValue = false;
         return;
   }
}

///fungco para formatar campos com valores decimais///
function FormataValor(campo,tammax,teclapres) {

   var tecla = teclapres.keyCode;
   vr = campo.value;
        vr = vr.replace( "/", "" );
        vr = vr.replace( "/", "" );
        vr = vr.replace( ",", "" );
        vr = vr.replace( ".", "" );
        vr = vr.replace( ".", "" );
        vr = vr.replace( ".", "" );
        vr = vr.replace( ".", "" );
   tam = vr.length;

        if (tam < tammax && tecla != 8){ tam = vr.length + 1 ; }

        if (tecla == 8 ){        tam = tam - 1 ; }

        if ( tecla == 8 || (tecla >= 48 && tecla <= 57) || (tecla >= 96 && tecla <= 105)){
                if ( tam <= 2 ){
                         campo.value = vr ; }
                 if ( (tam > 2) && (tam <= 5) ){
                         campo.value = vr.substr( 0, tam - 2 ) + ',' + vr.substr( tam - 2, tam ) ; }
                 if ( (tam >= 6) && (tam <= 8) ){
                         campo.value = vr.substr( 0, tam - 5 ) + '.' + vr.substr( tam - 5, 3 ) + ',' + vr.substr( tam - 2, tam ) ; }
                 if ( (tam >= 9) && (tam <= 11) ){
                         campo.value = vr.substr( 0, tam - 8 ) + '.' + vr.substr( tam - 8, 3 ) + '.' + vr.substr( tam - 5, 3 ) + ',' + vr.substr( tam - 2, tam ) ; }
                 if ( (tam >= 12) && (tam <= 14) ){
                         campo.value = vr.substr( 0, tam - 11 ) + '.' + vr.substr( tam - 11, 3 ) + '.' + vr.substr( tam - 8, 3 ) + '.' + vr.substr( tam - 5, 3 ) + ',' + vr.substr( tam - 2, tam ) ; }
                 if ( (tam >= 15) && (tam <= 17) ){
                         campo.value = vr.substr( 0, tam - 14 ) + '.' + vr.substr( tam - 14, 3 ) + '.' + vr.substr( tam - 11, 3 ) + '.' + vr.substr( tam - 8, 3 ) + '.' + vr.substr( tam - 5, 3 ) + ',' + vr.substr( tam - 2, tam ) ;}
        }
   else {if (tecla != 9 && tecla != 46 && (tecla < 37 || tecla > 40)) {event.returnValue = false;}}

}

///funcao para formatar campos Linha Digitavel - GPS
function formataLinDigGPS (campo,tammax,teclapres,proximo) {

    var tecla = teclapres.keyCode;
    vr = campo.value;

    vr = vr.replace( "/", "" );
    vr = vr.replace( "/", "" );
    vr = vr.replace( ",", "" );
    vr = vr.replace( ".", "" );
    vr = vr.replace( ".", "" );
    vr = vr.replace( ".", "" );
    vr = vr.replace( ".", "" );
    vr = vr.replace( "-", "" );

    tam = vr.length;


    //if (tam < tammax && tecla != 8){ // Backspace
    //    tam = vr.length + 1;
    //}
    if (tecla == 8 ){ // Backspace
        tam = tam - 1 ;
    }

    //alert(teclapres.type + " value " + campo.value + " campo: " + campo.value.length + " tam: " + tam);

    if (  tecla == 8 ||
         (tecla >= 48 && tecla <= 57) ||
         (tecla >= 96 && tecla <= 105)){


        if ( tam <= 13 ){
            if (tam == 12) {
                campo.value = vr.substr( 0, 11 ) + '-' + vr.substr(11, 1 ) ;
                proximo.focus();
            }
        }
    }
    else {
        if (tecla != 9 && tecla != 46 && (tecla < 37 || tecla > 40)) {
            event.returnValue = false;
        }
    }
}

///fungco para formatar campos cmc7///
function FormataCmc7(campo,tammax,teclapres) {
   var tecla = teclapres.keyCode;
   vr = campo.value;
        vr = vr.replace( ".", "" );
        vr = vr.replace( ".", "" );
        vr = vr.replace( ".", "" );
        vr = vr.replace( ".", "" );
   tam = vr.length;
        if (tam < tammax && tecla != 8){ tam = vr.length + 1 ; }
   /*alert(campo.value)*/
        if (tecla == 8 ){        tam = tam - 1 ; }

        if ( tecla == 8 || (tecla >= 48 && tecla <= 57) || (tecla >= 96 && tecla <= 105)){
                if ( tam = 1 ){
                         campo.value = vr.substr( 0, tam - 2 ) + vr.substr( 0, tam ) + ':';
      }
      if ( tam >= 2) {
         campo.value = vr.substr( 0, tam - 2 ) + vr.substr( 0, tam ) + ':';
      }
/*                 if ( (tam > 1) && (tam <= 12) ){
                         campo.value = vr.substr( 0, tam - 1 ) + ':' + vr.substr( tam - 5, tam ) ; }
           if ( (tam >= 11) && (tam <= 15) ){
                         campo.value = vr.substr( 0, tam - 11 ) + '.' + vr.substr( tam - 11, 5 ) + '.' + vr.substr( tam - 5, tam ) ; }*/
        }
   else {if (tecla != 9 && tecla != 46 && (tecla < 37 || tecla > 40)) {event.returnValue = false;}}
}

///fungco para formatar campos de tmtulos///
function FormataTitulo(campo,tammax,teclapres) {
   var tecla = teclapres.keyCode;
   vr = campo.value;
        vr = vr.replace( ".", "" );
        vr = vr.replace( ".", "" );
        vr = vr.replace( ".", "" );
        vr = vr.replace( ".", "" );
   tam = vr.length;
        if (tam < tammax && tecla != 8){ tam = vr.length + 1 ; }

        if (tecla == 8 ){        tam = tam - 1 ; }
        if ( tecla == 8 || (tecla >= 48 && tecla <= 57) || (tecla >= 96 && tecla <= 105)){
                if ( tam <= 5 ){
                         campo.value = vr ; }
                 if ( (tam > 5) && (tam <= 10) ){
                         campo.value = vr.substr( 0, tam - 5 ) + '.' + vr.substr( tam - 5, tam ) ; }
           if ( (tam >= 11) && (tam <= 15) ){
                         campo.value = vr.substr( 0, tam - 11 ) + '.' + vr.substr( tam - 11, 5 ) + '.' + vr.substr( tam - 5, tam ) ; }
        }
   else {if (tecla != 9 && tecla != 46 && (tecla < 37 || tecla > 40)) {event.returnValue = false;}}
}

///fungco para formatar campos de tmtulos///
function FormataTitulos(campo,tammax,teclapres) {
   var tecla = teclapres.keyCode;
   vr = campo.value;
        vr = vr.replace( ".", "" );
        vr = vr.replace( ".", "" );
        vr = vr.replace( ".", "" );
        vr = vr.replace( ".", "" );
   tam = vr.length;
        if (tam < tammax && tecla != 8){ tam = vr.length + 1 ; }

        if (tecla == 8 ){        tam = tam - 1 ; }

        if ( tecla == 8 || (tecla >= 48 && tecla <= 57) || (tecla >= 96 && tecla <= 105)){
                if ( tam <= 5 ){
                         campo.value = vr ; }
                 if ( (tam > 5) && (tam <= 10) ){
                         campo.value = vr.substr( 0, tam - 5 ) + '.' + vr.substr( tam - 5, tam ) ; }
        }
   else {if (tecla != 9 && tecla != 46 && (tecla < 37 || tecla > 40)) {event.returnValue = false;}}
}

///fungco para formatar campos de tmtulos///
function FormataTitulof(campo,tammax,teclapres) {
   var tecla = teclapres.keyCode;
   vr = campo.value;
        vr = vr.replace( ".", "" );
        vr = vr.replace( ".", "" );
        vr = vr.replace( ".", "" );
        vr = vr.replace( ".", "" );
   tam = vr.length;
        if (tam < tammax && tecla != 8){ tam = vr.length + 1 ; }

        if (tecla == 8 ){        tam = tam - 1 ; }

        if ( tecla == 8 || (tecla >= 48 && tecla <= 57) || (tecla >= 96 && tecla <= 105)){
                if ( tam <= 6 ){
                         campo.value = vr ; }
                 if ( (tam > 6) && (tam <= 9) ){
                         campo.value = vr.substr( 0, tam - 6 ) + '.' + vr.substr( tam - 6, tam ) ; }
                 if ( (tam >= 10) && (tam <= 12) ){
                         campo.value = vr.substr( 0, tam - 9 ) + '.' + vr.substr( tam - 9, 3 ) + '.' + vr.substr( tam - 6, tam ) ; }
                 if ( (tam >= 13) && (tam <= 15) ){
                         campo.value = vr.substr( 0, tam - 12 ) + '.' + vr.substr( tam - 12, 3 ) + '.' + vr.substr( tam - 9, 3 ) + '.' + vr.substr( tam - 6, tam ) ; }
                 if ( (tam >= 16) && (tam <= 17) ){
                         campo.value = vr.substr( 0, tam - 15 ) + '.' + vr.substr( tam - 15, 2 ) + '.' + vr.substr( tam - 12, 3 ) + '.' + vr.substr( tam - 9, 3 ) + '.' + vr.substr( tam - 6, tam ) ;}
   }
   else {if (tecla != 9 && tecla != 46 && (tecla < 37 || tecla > 40)) {event.returnValue = false;}}
}

///fungco para formatar campos de faturas///
function FormataFatura(campo,tammax,teclapres) {
   var tecla = teclapres.keyCode;
   vr = campo.value;
        vr = vr.replace( ".", "" );
        vr = vr.replace( ".", "" );
        vr = vr.replace( ".", "" );
        vr = vr.replace( ".", "" );
   tam = vr.length;
        if (tam < tammax && tecla != 8){ tam = vr.length + 1 ; }

        if (tecla == 8 ){        tam = tam - 1 ; }

        if ( tecla == 8 || (tecla >= 48 && tecla <= 57) || (tecla >= 96 && tecla <= 105)){
                if ( tam <= 1 ){
                         campo.value = vr ; }
                 if ( (tam > 1) && (tam <= 7) ){
                         campo.value = vr.substr( 0, tam - 1 ) + '.' + vr.substr( tam - 1, tam ) ; }
                 if ( (tam >= 8) && (tam <= 12) ){
                         campo.value = vr.substr( 0, tam - 7 ) + '.' + vr.substr( tam - 7, 6 ) + '.' + vr.substr( tam - 1, tam ) ; }
        }
   else {if (tecla != 9 && tecla != 46 && (tecla < 37 || tecla > 40)) {event.returnValue = false;}}
}

///fungco para formatar campos de conta///
function FormataConta(campo,tammax,teclapres) {

   var tecla = teclapres.keyCode;
   vr = campo.value;
        vr = vr.replace( ".", "" );
        vr = vr.replace( ".", "" );
        vr = vr.replace( ".", "" );
        vr = vr.replace( ".", "" );
   tam = vr.length;

        if (tam < tammax && tecla != 8){ tam = vr.length + 1 ; }

        if (tecla == 8 ){        tam = tam - 1 ; }

        if ( tecla == 8 || (tecla >= 48 && tecla <= 57) || (tecla >= 96 && tecla <= 105))  {
                if ( tam <= 1 ){
                         campo.value = vr ; }
                 if ( (tam > 1) && (tam <= 4) ){
                         campo.value = vr.substr( 0, tam - 1 ) + '.' + vr.substr( tam - 1, tam ) ; }
                 if ( (tam >= 5) && (tam <= 9) ){
                         campo.value = vr.substr( 0, tam - 4 ) + '.' + vr.substr( tam - 4, 3 ) + '.' + vr.substr( tam - 1, tam ) ; }

        }
   else {if (tecla != 9 && tecla != 46 && (tecla < 37 || tecla > 40)) {event.returnValue = false;}}
}

///fungco para formatar a data///
function FormataData(Campo,teclapres) {
        var tecla = teclapres.keyCode;

   if ( ( tecla < 48 || tecla > 57 && tecla < 96 || tecla > 105) && tecla != 8 && tecla != 9 && tecla!= 16){
         event.returnValue = false;
         return;
   }

        vr = Campo.value;
        vr = vr.replace( ".", "" );
        vr = vr.replace( "/", "" );
        vr = vr.replace( "/", "" );
        tam = vr.length + 1;

        if ( tecla != 9 && tecla != 8 ){
                if ( tam > 2 && tam < 5 )
                        Campo.value = vr.substr( 0, tam - 2  ) + '/' + vr.substr( tam - 2, tam );
                if ( tam >= 5 && tam <= 10 )
                        Campo.value = vr.substr( 0, 2 ) + '/' + vr.substr( 2, 2 ) + '/' + vr.substr( 4, 4 ); }
}

///fungco para mudar o foco do campo atual para o campo de rotina do menu///
function change_page(e) {
    if(e.keyCode == 27)
       top.frames[0].document.forms[0].v_rotina.focus();
    return true;
   }

///fungco para chamar o programa quando executado pelo campo de rotina///
function change_location() {
    if(document.forms[0].v_rotina.value == 2) {
        top.frames[1].window.location.href="crap002.html" ;
    }
    else if(document.forms[0].v_rotina.value == 5) {
        top.frames[1].window.location.href="crap005.html" ;
    }
    else if(document.forms[0].v_rotina.value == 6) {
        top.frames[1].window.location.href='crap006.w' ;
    }
    else if(document.forms[0].v_rotina.value == 7) {
        top.frames[1].window.location.href="crap007.html" ;
    }
    else if(document.forms[0].v_rotina.value == 8) {
        top.frames[1].window.location.href="crap008.html" ;
    }
    else if(document.forms[0].v_rotina.value == 9) {
        top.frames[1].window.location.href="crap009.html" ;
    }
    else if(document.forms[0].v_rotina.value == 10) {
        top.frames[1].window.location.href='login.w?v_prog=crap010.w' ;
    }
    else if(document.forms[0].v_rotina.value == 11) {
        top.frames[1].window.location.href="crap011.html" ;
    }
    else if(document.forms[0].v_rotina.value == 12) {
        top.frames[1].window.location.href="crap012.html" ;
    }
    else if(document.forms[0].v_rotina.value == 13) {
        top.frames[1].window.location.href="crap013.html" ;
    }
    else if(document.forms[0].v_rotina.value == 14) {
        top.frames[1].window.location.href="crap014.html?v_sangria=S" ;
    }
    else if(document.forms[0].v_rotina.value == 15) {
         top.frames[1].window.location.href='login.w?v_prog=crap015.w' ;
    }
    else if(document.forms[0].v_rotina.value == 16) {
        top.frames[1].window.location.href="crap016.html" ;
    }
    else if(document.forms[0].v_rotina.value == 17) {
       top.frames[1].window.location.href='login.w?v_prog=crap017.w' ;
    }
    else if(document.forms[0].v_rotina.value == 18) {
        top.frames[1].window.location.href="crap018.html" ;
    }
    else if(document.forms[0].v_rotina.value == 19) {
        top.frames[1].window.location.href="crap019.html" ;
    }
    else if(document.forms[0].v_rotina.value == 20) {
        top.frames[1].window.location.href="crap020.html?v_sangria=S" ;
    }
    else if(document.forms[0].v_rotina.value == 21) {
        top.frames[1].window.location.href='login.w?v_prog=crap021.w' ;
    }
    else if(document.forms[0].v_rotina.value == 22) {
        top.frames[1].window.location.href="crap022.html?v_sangria=S" ;
    }
    else if(document.forms[0].v_rotina.value == 31) {
        top.frames[1].window.location.href="crap031.html" ;
    }
    else if(document.forms[0].v_rotina.value == 32) {
        top.frames[1].window.location.href="crap032.html" ;
    }
    else if(document.forms[0].v_rotina.value == 33) {
        top.frames[1].window.location.href="crap033.html" ;
    }
    else if(document.forms[0].v_rotina.value == 34) {
        top.frames[1].window.location.href="crap034.html" ;
    }
    else if(document.forms[0].v_rotina.value == 35) {
        top.frames[1].window.location.href="crap035.html" ;
    }
     else if(document.forms[0].v_rotina.value == 36) {
        top.frames[1].window.location.href="crap036.html" ;
    }
     else if(document.forms[0].v_rotina.value == 37) {
        top.frames[1].window.location.href="crap037.html" ;
    }
	else if(document.forms[0].v_rotina.value == 38) {
        top.frames[1].window.location.href="crap038.html" ;
    }
    else if(document.forms[0].v_rotina.value == 39) {
        top.frames[1].window.location.href="crap039.htm" ;
    }
    else if(document.forms[0].v_rotina.value == 40) {
        top.frames[1].window.location.href="crap040.html" ;
        }
    else if(document.forms[0].v_rotina.value == 30) {
        top.frames[1].window.location.href="crap030.htm" ;
        }
    else if(document.forms[0].v_rotina.value == 41) {
        top.frames[1].window.location.href="crap041.htm?v_aviso=S" ;
        }
    else if(document.forms[0].v_rotina.value == 42) {
        top.frames[1].window.location.href="crap042.html" ;
    }
    else if(document.forms[0].v_rotina.value == 51) {
        top.frames[1].window.location.href="crap051.html?v_sangria=S" ;
    }
    else if(document.forms[0].v_rotina.value == 52) {
        top.frames[1].window.location.href="crap052.html" ;
    }
    else if(document.forms[0].v_rotina.value == 53) {
        top.frames[1].window.location.href="crap053.html" ;
    }
    else if(document.forms[0].v_rotina.value == 54) {
        top.frames[1].window.location.href="crap054.html" ;
    }
    else if(document.forms[0].v_rotina.value == 55) {
        top.frames[1].window.location.href="crap055.html?v_sangria=S" ;
    }
    else if(document.forms[0].v_rotina.value == 56) {
        top.frames[1].window.location.href="crap056.html?v_sangria=S" ;
    }
    else if(document.forms[0].v_rotina.value == 57) {
        top.frames[1].window.location.href="crap057.html?v_sangria=S" ;
    }
    else if(document.forms[0].v_rotina.value == 58) {
        top.frames[1].window.location.href="crap058.html?v_sangria=S" ;
    }
    else if(document.forms[0].v_rotina.value == 61) {
        top.frames[1].window.location.href="crap061.html?v_sangria=S" ;
    }
	else if(document.forms[0].v_rotina.value == 62) {
        top.frames[1].window.location.href="crap062.html" ;
    }
    else if(document.forms[0].v_rotina.value == 86) {
        top.frames[1].window.location.href='login.w?v_prog=crap086.html';
    }
    else if(document.forms[0].v_rotina.value == 71) {
        top.frames[1].window.location.href='login.w?v_prog=crap071.html';
    }
    else if(document.forms[0].v_rotina.value == 72) {
        top.frames[1].window.location.href='login.w?v_prog=crap072.w';
    }
    else if(document.forms[0].v_rotina.value == 73) {
        top.frames[1].window.location.href='login.w?v_prog=crap073.w';
    }
    else if(document.forms[0].v_rotina.value == 74) {
        top.frames[1].window.location.href='login.w?v_prog=crap074.w';
    }
    else if(document.forms[0].v_rotina.value == 75) {
        top.frames[1].window.location.href='login.w?v_prog=crap075.w';
    }
    else if(document.forms[0].v_rotina.value == 76) {
        top.frames[1].window.location.href='login.w?v_prog=crap076.w';
    }
    else if(document.forms[0].v_rotina.value == 77) {
        top.frames[1].window.location.href='login.w?v_prog=crap077.w';
    }
    else if(document.forms[0].v_rotina.value == 78) {
        top.frames[1].window.location.href='login.w?v_prog=crap078.w';
    }
    else if(document.forms[0].v_rotina.value == 79) {
        top.frames[1].window.location.href='login.w?v_prog=crap079.w';
    }
    else if(document.forms[0].v_rotina.value == 80) {
        top.frames[1].window.location.href="crap080.html?v_sangria=S";
    }
    else if(document.forms[0].v_rotina.value == 81) {
         top.frames[1].window.location.href='login.w?v_prog=crap081.w' ;
    }
    else if(document.forms[0].v_rotina.value == 87) {
         top.frames[1].window.location.href="crap087.htm";
    }
    else if(document.forms[0].v_rotina.value == 88) {
         top.frames[1].window.location.href="login.w?v_prog=crap088.html";
    }
    else if(document.forms[0].v_rotina.value == 89) {
         top.frames[1].window.location.href="crap089.htm";
    }
	else if(document.forms[0].v_rotina.value == 97) {
         top.frames[1].window.location.href="crap097.htm";
    }
    else if(document.forms[0].v_rotina.value == 'at' || document.forms[0].v_rotina.value == 'AT') {
        top.frames[1].window.location.href='login.w?v_prog=autentmenu.w';
    }
    else if(document.forms[0].v_rotina.value == 'ip' || document.forms[0].v_rotina.value == 'IP') {
        top.frames[1].window.location.href='impressora.w';
    }
    else if(document.forms[0].v_rotina.value == 'aa' || document.forms[0].v_rotina.value == 'AA') {
        top.frames[1].window.location.href='logingerente.w?v_prog=autantmenu.w';
    }
    else if (document.forms[0].v_rotina.value == 'bla' || document.forms[0].v_rotina.value == 'BLA') {
        window.open('blass.p', 'werro', 'width=500,height=150,scrollbars=auto,alwaysRaised=true,left=0,top=0');
    }
    else if(document.forms[0].v_rotina.value == 'bli' || document.forms[0].v_rotina.value == 'BLI') {
        window.open('blini.p','werro','width=500,height=320,scrollbars=auto,alwaysRaised=true,left=0,top=0') ;
    }
    else if(document.forms[0].v_rotina.value == 'bls' || document.forms[0].v_rotina.value == 'BLS') {
        window.open('blsal.p','werro','width=500,height=270,scrollbars=auto,alwaysRaised=true,left=0,top=0') ;
    }
    else if(document.forms[0].v_rotina.value == 'cl' || document.forms[0].v_rotina.value == 'CL') {
        window.open('calc.w','werro','height=190,width=270,scrollbars=auto,alwaysRaised=true,left=0,top=0') ;
    }
    else{
        alert("Rotina não Existe!");
        top.frames[1].window.location.href="crap002.html" ;
    }

/*    else{
       alert("Rotina não Existe!");
       top.frames[1].window.location.href="crap002.html" ;
    }*/
}

///função para abrir outro programa passando parâmetros///
function redireciona(campo) {
   if (campo.name == "crap003" || campo.name == "crap004") {
      window.location = campo.name + '.html?v_cta=' + document.forms[0].v_conta.value +
         '&v_nom=' + document.forms[0].v_nome.value + '&v_nomconj=' + document.forms[0].v_nomconj.value;
   }
   else if (campo.name == "crap004a") {
      window.location = campo.name + '.html?v_row=' + document.forms[0].v_rowid.value;
      }
   else if (campo.name == "crap002") {
      window.location = campo.name + '.html?v_row=' + document.forms[0].v_rowid.value;
      }
}

function redir_login(prog){
   window.location = 'login.w?v_prog=' + prog;
}

function redir_zoom(){
   window.location = 'crap002c.html?v_nome=' + document.forms[0].v_nome.value;
}

function preenchimento(evento,foco,campo,tamanho,objeto){

   if (campo.value.length == tamanho) {
      // Menu
      if (objeto == "menu") {
         change_location();
      }
      else {
         // Campo
         if (objeto == "submit") {
             document.forms[0].submit();
             for(var i=0;i<document.forms[0].length;i++){
                document.forms[0].elements[i].disabled=true;
             }
         }
         if (objeto == "foco") {
            for(var i=0;i<document.forms[0].length;i++){
               if (document.forms[0].elements[i].name == campo.name) {
                  document.forms[0].elements[i+1].focus();
               }
            }
         }
         else {
            // Botão
            for(var i=0;i<document.forms[0].length;i++){
               if (document.forms[0].elements[i].name == objeto) {
                  document.forms[0].elements[i].click();
               }
            }
         }
      }
   }
   else {
      if (evento.keyCode == 13) {
         if (foco == 0) {
            document.forms[0].submit();
         }
         else {
            document.forms[0].elements[foco].focus();
         }
      }
   }
}

function onTop() {
   setTimeout("self.focus()",250);
}

function onKey(e) {
    if(e.keyCode == 13){
       document.forms[0].submit();
   }
   else{
      if(e.keyCode == 27) {
         window.close();
      }
   }
}

/*
function callCalc(e, obj) {
        if (e.keyCode == 120) {
                window.open("calc.htm?elem=" + obj.name, "wincalc", "resizable=no, height=190, width=270, left=0, top=0");
        }
}
*/

function Setenter(e) {
    if (e.keyCode == 13) { //alert('teste');
        $(".button").focus(function () {
            $(this).click();
        });
    }
}

function SetFocus(e) {
    document.getElementById("v_conta").focus();
    $(".button").focus(function () {
        $(this).click();
    });

    return false;
}

function callBlass(e) {
    if (e.keyCode == 120) {
        window.open('blass.p', 'wbl', 'width=500,height=150,scrollbars=auto,resizable=no,alwaysRaised=true, left=0, top=0');
        }
}

function callBLini(e) {
        if (e.keyCode == 119) {
      window.open('blini.p','wbl','width=500,height=320,scrollbars=auto,resizable=no,alwaysRaised=true, left=0, top=0');
   }
}

function callBLsal(e) {
        if (e.keyCode == 118) {
      window.open('blsal.p','wbl','width=500,height=270,scrollbars=auto,resizable=no,alwaysRaised=true, left=0, top=0');
   }
}

function log() {
   var Cookies = document.cookie;
   var URL = document.URL;
   var COOP;

   // verifica o parametro da cooperativa existe
   if(URL.match("aux_cdcooper")==null){
      return false;
   }

   COOP = URL.substring(URL.indexOf("aux_cdcooper=") + 13,URL.length);

   // separa o parametro dos demais, caso existam
   if(COOP.match("&")!=null){
      COOP = COOP.substring(0,COOP.indexOf("&"));
   }

   if (Cookies.indexOf("User_cx") != -1 && Cookies.indexOf("User_pac") != -1) {
      window.open("crap001.html","wsis","width=640,height=420,scrollbars=auto,alwaysRaised=true,resizable=yes,left=0,top=0");
   }
   else
      window.open("configura.w?aux_cdcooper=" + COOP,"wconfig","width=640,height=420,scrollbars=auto,alwaysRaised=true,resizable=yes,left=0,top=0");

}
function fecha() {
   alert("fechar");
  opener.close();
}

function click() {
//   if (event.button==2) {
//      alert('Click Esquerdo Desabilitado')
//   }
}
document.onmousedown=click

//-->

// Vander - Funcao que desabilita botões de submits e limpeza de campos

function desabok()
{
   if (window.action.ok.value != "Ok")
   {
      window.action.ok.value = "Ok";
      for (i = 0; i < action.length; i++)
      {
         var tempobj = action.elements[i];
         if (tempobj.type.toLowerCase() == "submit" || tempobj.type.toLowerCase() == "reset")
         tempobj.disabled = true;
      }
      window.action.submit();
   }
}


function desabilita(botao)
{
   document.all[botao].style.display='none';
}


// Vander - Funcao que restringe o escape na autenticação

function onKeyAutent(e, v) {

    document.action.aut.value = v;
    if(e.keyCode == 13){
       document.action.aut.value = "Ok";
       document.forms[0].submit();
   }
   else{
      if(e.keyCode == 27 && document.action.aut.value == "Ok") {
           window.close();
      }
      else
      {
      alert("Você deve realizar ao menos uma autenticação.");
      }
   }
}

function CriaArray(n) {
  this.length = n;
  for (i = 1; i <= n; i++) {
    this[i]="";
  }
}

function Difdocto(v,p) {
   if (v != p)
      alert("Numero do documento invalido");
   else
      return true;
}


// valida os caracteres digitados na descricao
function validaDescricao(campo,valor){

   if((event.keyCode==9)||    // TAB
      (event.keyCode==16)){   // BACK-TAB
       return true;
   }

   // varre o campo em busca de caracteres inválidos e remove-os
   for(var i=0;i< document.all[campo].value.length;i++){
      if((document.all[campo].value.substring(i,i+1)=='@') ||
                   (document.all[campo].value.substring(i,i+1)=='#') ||
                 (document.all[campo].value.substring(i,i+1)=='$') ||
                 (document.all[campo].value.substring(i,i+1)=='%') ||
                 (document.all[campo].value.substring(i,i+1)=='¨') ||
                 (document.all[campo].value.substring(i,i+1)=='=') ||
                 (document.all[campo].value.substring(i,i+1)=='&') ||
                 (document.all[campo].value.substring(i,i+1)=='º') ||
                 (document.all[campo].value.substring(i,i+1)=='ª') ||
                 (document.all[campo].value.substring(i,i+1)=='§') ||
                 (document.all[campo].value.substring(i,i+1)=='°') ||
                 (document.all[campo].value.substring(i,i+1)=='¬') ||
                 (document.all[campo].value.substring(i,i+1)=='¢') ||
                 (document.all[campo].value.substring(i,i+1)=='£') ||
                 (document.all[campo].value.substring(i,i+1)=='³') ||
                 (document.all[campo].value.substring(i,i+1)=='²') ||
                 (document.all[campo].value.substring(i,i+1)=='¹') ||
                 (document.all[campo].value.substring(i,i+1)=='°') ||
                 (document.all[campo].value.substring(i,i+1)=='?') ||
                 (document.all[campo].value.substring(i,i+1)=='"') ||
                 (document.all[campo].value.substring(i,i+1)=="'"))
          document.all[campo].value = document.all[campo].value.substring(0,i);
   }
}

///função para formatar cep///
function FormataCep(Campo,teclapres) {


   var tecla = teclapres.keyCode;
   if ( ( tecla < 48 || tecla > 57 && tecla < 96 || tecla > 105) && tecla != 8 && tecla != 9 && tecla!= 16){
         event.returnValue = false;
         return;
   }

        vr = Campo.value;
        vr = vr.replace( ".", "" );
        vr = vr.replace( "-", "" );
        vr = vr.replace( "-", "" );
        tam = vr.length + 1;

        if ( tecla != 9 && tecla != 8 ){
                if ( tam > 3 && tam < 8)
                        Campo.value = vr.substr( 0, tam - 3  ) + '-' + vr.substr( tam - 3, tam );

                if ( tam = 8 )
                Campo.value = vr.substr( 0, 5 ) + '-' + vr.substr( 5, 3 );
                 }

}



/**
 * Funcao para formatar o valor de deposito, da rotina 51
 * Não permitir valor negativo
 */
function FormataValorDeposito(campo) {

    var vr = campo.value;
        vr = vr.replace( ",", "" );
        vr = vr.replace( ".", "" );
        vr = vr.replace( ".", "" );
        vr = vr.replace( ".", "" );
        vr = vr.replace( ".", "" );
        vr = retiraCaracteres(vr);
        vr = retirarZeros(vr);
    var tam = vr.length;

    if (tam == 0) {
        campo.value = "0,00";
        return;
    }

    if ( tam == 1 ){
        campo.value = "0,0" + vr ;
    } else if ( tam == 2 ){
        campo.value = "0," + vr ;
    } else if ( (tam > 2) && (tam <= 5) ){
        campo.value = vr.substr( 0, tam - 2 ) + ',' + vr.substr( tam - 2, tam ) ;
    } else if ( (tam >= 6) && (tam <= 8) ){
        campo.value = vr.substr( 0, tam - 5 ) + '.' + vr.substr( tam - 5, 3 ) + ',' + vr.substr( tam - 2, tam ) ;
    } else if ( (tam >= 9) && (tam <= 11) ){
        campo.value = vr.substr( 0, tam - 8 ) + '.' + vr.substr( tam - 8, 3 ) + '.' + vr.substr( tam - 5, 3 ) + ',' + vr.substr( tam - 2, tam ) ;
    } else if ( (tam >= 12) && (tam <= 14) ){
        campo.value = vr.substr( 0, tam - 11 ) + '.' + vr.substr( tam - 11, 3 ) + '.' + vr.substr( tam - 8, 3 ) + '.' + vr.substr( tam - 5, 3 ) + ',' + vr.substr( tam - 2, tam ) ;
    } else if ( (tam >= 15) && (tam <= 17) ){
        campo.value = vr.substr( 0, tam - 14 ) + '.' + vr.substr( tam - 14, 3 ) + '.' + vr.substr( tam - 11, 3 ) + '.' + vr.substr( tam - 8, 3 ) + '.' + vr.substr( tam - 5, 3 ) + ',' + vr.substr( tam - 2, tam ) ;
    }
}

/**
 * Retirar todos os caracteres ma formatação do valor que é informado para o campo de valor em dinheiro e cheque
 * Dessa forma não será mais posssível digitar letras ou sinais aritméticos, como o valor negativo.
 */
function retiraCaracteres(str) {
    var result = "";    // Variável que armazena os caracteres v&aacute;lidos
    var temp   = "";    // Variável para armazenar caracter da string
    var valid  = "0123456789"; // Caracteres válidos para o valor de depósito em dinheiro/cheque

    for (var i = 0; i < str.length; i++) {
        temp = str.substr(i,1);
        // Se for um n&uacute;mero concatena na string result
        if (valid.indexOf(temp) != "-1") {
            result += temp;
        }
    }

    return result;
}
/**
 * Funcao para retirar os zeros iniciais do valor
 */
function retirarZeros(numero) {
    var result   = "";    // Armazena conteudo de retorno
    var temp     = "";    // Armazena caracter temporario do numero

    // Efetua leitura de todos os caracteres do numero
    for (var i = 0; i < numero.length; i++) {
        temp = numero.substr(i,1);

        if (temp != '0') {
            result += temp;
        } else {
            if ((temp == '0') && (result.length > 0)) {
                result += temp;
            }
        }
    }

    return result;
}

/* Tratamentos para Blini e Blsal */
function mudaCooperado(incooper){

    if (incooper == 1){
        document.forms[0].v_ident.value='';
        document.forms[0].v_conta.disabled=false;
        document.forms[0].v_ident.disabled=true;
        document.forms[0].ok.disabled=true;
        document.forms[0].v_conta.focus();
    } else {
        document.forms[0].v_conta.value='';
        document.forms[0].v_ident.value='';
        document.forms[0].v_conta.disabled=true;
        document.forms[0].v_ident.disabled=false;
        document.forms[0].ok.disabled=false;
        document.forms[0].v_ident.focus();
    }
}

function carregaRotinaFramePrincipal(element, rotina){

    /* Parâmetro apenas para sinalizar o uso do teclado nas operações de
       abertura/fechamento do BL */
    if (rotina != "menu") {

        /* Restart da Rotina 54 (teclado) direciona fixo para descartar parametros sendo passados na url e, assim, limpar tela */
        if (rotina.indexOf("crap054.html") > -1) {
            top.frames[1].window.location.href = "crap054.html";
        } else {
            top.frames[1].window.location.href = rotina;
        }
    } else {

        /* Rotina 54 */
        if (element.contentWindow.location.href.indexOf("crap054.html") > -1) {
            element.nextSibling.src = (element.contentWindow.location.href.substr(element.contentWindow.location.href.indexOf("crap054.html"), (element.contentWindow.location.href.length - element.contentWindow.location.href.indexOf("crap054.html"))));
            element.src = "menu.r";
        }

        /* Reinicia rotina */
        if (element.contentWindow.location.href.indexOf("crap002.w") > -1) {

            /* Restart da Rotina 54 (mouse) direciona fixo para descartar parametros sendo passados na url e, assim, limpar tela */
            if (top.frames[1].window.location.href.indexOf("crap054.html") > -1) {
                element.nextSibling.src = "crap054.html";
                element.src = "menu.r";
            } else {
                element.nextSibling.src = top.frames[1].window.location.href;
                element.src = "menu.r";
            }


        }
    }

}


/****************************************************************************************/
/********                   FUNÇÕES DE COMUNICAÇÃO COM O PINPAD NOVO             ********/
/****************************************************************************************/

function dechex(number) {
  if (number < 0) {
    number = 0xFFFFFFFF + number + 1;
  }
  return parseInt(number, 10)
    .toString(16);
}

function md5(str) {
  var xl;

  var rotateLeft = function(lValue, iShiftBits) {
    return (lValue << iShiftBits) | (lValue >>> (32 - iShiftBits));
  };

  var addUnsigned = function(lX, lY) {
    var lX4, lY4, lX8, lY8, lResult;
    lX8 = (lX & 0x80000000);
    lY8 = (lY & 0x80000000);
    lX4 = (lX & 0x40000000);
    lY4 = (lY & 0x40000000);
    lResult = (lX & 0x3FFFFFFF) + (lY & 0x3FFFFFFF);
    if (lX4 & lY4) {
      return (lResult ^ 0x80000000 ^ lX8 ^ lY8);
    }
    if (lX4 | lY4) {
      if (lResult & 0x40000000) {
        return (lResult ^ 0xC0000000 ^ lX8 ^ lY8);
      } else {
        return (lResult ^ 0x40000000 ^ lX8 ^ lY8);
      }
    } else {
      return (lResult ^ lX8 ^ lY8);
    }
  };

  var _F = function(x, y, z) {
    return (x & y) | ((~x) & z);
  };
  var _G = function(x, y, z) {
    return (x & z) | (y & (~z));
  };
  var _H = function(x, y, z) {
    return (x ^ y ^ z);
  };
  var _I = function(x, y, z) {
    return (y ^ (x | (~z)));
  };

  var _FF = function(a, b, c, d, x, s, ac) {
    a = addUnsigned(a, addUnsigned(addUnsigned(_F(b, c, d), x), ac));
    return addUnsigned(rotateLeft(a, s), b);
  };

  var _GG = function(a, b, c, d, x, s, ac) {
    a = addUnsigned(a, addUnsigned(addUnsigned(_G(b, c, d), x), ac));
    return addUnsigned(rotateLeft(a, s), b);
  };

  var _HH = function(a, b, c, d, x, s, ac) {
    a = addUnsigned(a, addUnsigned(addUnsigned(_H(b, c, d), x), ac));
    return addUnsigned(rotateLeft(a, s), b);
  };

  var _II = function(a, b, c, d, x, s, ac) {
    a = addUnsigned(a, addUnsigned(addUnsigned(_I(b, c, d), x), ac));
    return addUnsigned(rotateLeft(a, s), b);
  };

  var convertToWordArray = function(str) {
    var lWordCount;
    var lMessageLength = str.length;
    var lNumberOfWords_temp1 = lMessageLength + 8;
    var lNumberOfWords_temp2 = (lNumberOfWords_temp1 - (lNumberOfWords_temp1 % 64)) / 64;
    var lNumberOfWords = (lNumberOfWords_temp2 + 1) * 16;
    var lWordArray = new Array(lNumberOfWords - 1);
    var lBytePosition = 0;
    var lByteCount = 0;
    while (lByteCount < lMessageLength) {
      lWordCount = (lByteCount - (lByteCount % 4)) / 4;
      lBytePosition = (lByteCount % 4) * 8;
      lWordArray[lWordCount] = (lWordArray[lWordCount] | (str.charCodeAt(lByteCount) << lBytePosition));
      lByteCount++;
    }
    lWordCount = (lByteCount - (lByteCount % 4)) / 4;
    lBytePosition = (lByteCount % 4) * 8;
    lWordArray[lWordCount] = lWordArray[lWordCount] | (0x80 << lBytePosition);
    lWordArray[lNumberOfWords - 2] = lMessageLength << 3;
    lWordArray[lNumberOfWords - 1] = lMessageLength >>> 29;
    return lWordArray;
  };

  var wordToHex = function(lValue) {
    var wordToHexValue = '',
      wordToHexValue_temp = '',
      lByte, lCount;
    for (lCount = 0; lCount <= 3; lCount++) {
      lByte = (lValue >>> (lCount * 8)) & 255;
      wordToHexValue_temp = '0' + lByte.toString(16);
      wordToHexValue = wordToHexValue + wordToHexValue_temp.substr(wordToHexValue_temp.length - 2, 2);
    }
    return wordToHexValue;
  };

  var x = [],
    k, AA, BB, CC, DD, a, b, c, d, S11 = 7,
    S12 = 12,
    S13 = 17,
    S14 = 22,
    S21 = 5,
    S22 = 9,
    S23 = 14,
    S24 = 20,
    S31 = 4,
    S32 = 11,
    S33 = 16,
    S34 = 23,
    S41 = 6,
    S42 = 10,
    S43 = 15,
    S44 = 21;

  str = this.utf8_encode(str);
  x = convertToWordArray(str);
  a = 0x67452301;
  b = 0xEFCDAB89;
  c = 0x98BADCFE;
  d = 0x10325476;

  xl = x.length;
  for (k = 0; k < xl; k += 16) {
    AA = a;
    BB = b;
    CC = c;
    DD = d;
    a = _FF(a, b, c, d, x[k + 0], S11, 0xD76AA478);
    d = _FF(d, a, b, c, x[k + 1], S12, 0xE8C7B756);
    c = _FF(c, d, a, b, x[k + 2], S13, 0x242070DB);
    b = _FF(b, c, d, a, x[k + 3], S14, 0xC1BDCEEE);
    a = _FF(a, b, c, d, x[k + 4], S11, 0xF57C0FAF);
    d = _FF(d, a, b, c, x[k + 5], S12, 0x4787C62A);
    c = _FF(c, d, a, b, x[k + 6], S13, 0xA8304613);
    b = _FF(b, c, d, a, x[k + 7], S14, 0xFD469501);
    a = _FF(a, b, c, d, x[k + 8], S11, 0x698098D8);
    d = _FF(d, a, b, c, x[k + 9], S12, 0x8B44F7AF);
    c = _FF(c, d, a, b, x[k + 10], S13, 0xFFFF5BB1);
    b = _FF(b, c, d, a, x[k + 11], S14, 0x895CD7BE);
    a = _FF(a, b, c, d, x[k + 12], S11, 0x6B901122);
    d = _FF(d, a, b, c, x[k + 13], S12, 0xFD987193);
    c = _FF(c, d, a, b, x[k + 14], S13, 0xA679438E);
    b = _FF(b, c, d, a, x[k + 15], S14, 0x49B40821);
    a = _GG(a, b, c, d, x[k + 1], S21, 0xF61E2562);
    d = _GG(d, a, b, c, x[k + 6], S22, 0xC040B340);
    c = _GG(c, d, a, b, x[k + 11], S23, 0x265E5A51);
    b = _GG(b, c, d, a, x[k + 0], S24, 0xE9B6C7AA);
    a = _GG(a, b, c, d, x[k + 5], S21, 0xD62F105D);
    d = _GG(d, a, b, c, x[k + 10], S22, 0x2441453);
    c = _GG(c, d, a, b, x[k + 15], S23, 0xD8A1E681);
    b = _GG(b, c, d, a, x[k + 4], S24, 0xE7D3FBC8);
    a = _GG(a, b, c, d, x[k + 9], S21, 0x21E1CDE6);
    d = _GG(d, a, b, c, x[k + 14], S22, 0xC33707D6);
    c = _GG(c, d, a, b, x[k + 3], S23, 0xF4D50D87);
    b = _GG(b, c, d, a, x[k + 8], S24, 0x455A14ED);
    a = _GG(a, b, c, d, x[k + 13], S21, 0xA9E3E905);
    d = _GG(d, a, b, c, x[k + 2], S22, 0xFCEFA3F8);
    c = _GG(c, d, a, b, x[k + 7], S23, 0x676F02D9);
    b = _GG(b, c, d, a, x[k + 12], S24, 0x8D2A4C8A);
    a = _HH(a, b, c, d, x[k + 5], S31, 0xFFFA3942);
    d = _HH(d, a, b, c, x[k + 8], S32, 0x8771F681);
    c = _HH(c, d, a, b, x[k + 11], S33, 0x6D9D6122);
    b = _HH(b, c, d, a, x[k + 14], S34, 0xFDE5380C);
    a = _HH(a, b, c, d, x[k + 1], S31, 0xA4BEEA44);
    d = _HH(d, a, b, c, x[k + 4], S32, 0x4BDECFA9);
    c = _HH(c, d, a, b, x[k + 7], S33, 0xF6BB4B60);
    b = _HH(b, c, d, a, x[k + 10], S34, 0xBEBFBC70);
    a = _HH(a, b, c, d, x[k + 13], S31, 0x289B7EC6);
    d = _HH(d, a, b, c, x[k + 0], S32, 0xEAA127FA);
    c = _HH(c, d, a, b, x[k + 3], S33, 0xD4EF3085);
    b = _HH(b, c, d, a, x[k + 6], S34, 0x4881D05);
    a = _HH(a, b, c, d, x[k + 9], S31, 0xD9D4D039);
    d = _HH(d, a, b, c, x[k + 12], S32, 0xE6DB99E5);
    c = _HH(c, d, a, b, x[k + 15], S33, 0x1FA27CF8);
    b = _HH(b, c, d, a, x[k + 2], S34, 0xC4AC5665);
    a = _II(a, b, c, d, x[k + 0], S41, 0xF4292244);
    d = _II(d, a, b, c, x[k + 7], S42, 0x432AFF97);
    c = _II(c, d, a, b, x[k + 14], S43, 0xAB9423A7);
    b = _II(b, c, d, a, x[k + 5], S44, 0xFC93A039);
    a = _II(a, b, c, d, x[k + 12], S41, 0x655B59C3);
    d = _II(d, a, b, c, x[k + 3], S42, 0x8F0CCC92);
    c = _II(c, d, a, b, x[k + 10], S43, 0xFFEFF47D);
    b = _II(b, c, d, a, x[k + 1], S44, 0x85845DD1);
    a = _II(a, b, c, d, x[k + 8], S41, 0x6FA87E4F);
    d = _II(d, a, b, c, x[k + 15], S42, 0xFE2CE6E0);
    c = _II(c, d, a, b, x[k + 6], S43, 0xA3014314);
    b = _II(b, c, d, a, x[k + 13], S44, 0x4E0811A1);
    a = _II(a, b, c, d, x[k + 4], S41, 0xF7537E82);
    d = _II(d, a, b, c, x[k + 11], S42, 0xBD3AF235);
    c = _II(c, d, a, b, x[k + 2], S43, 0x2AD7D2BB);
    b = _II(b, c, d, a, x[k + 9], S44, 0xEB86D391);
    a = addUnsigned(a, AA);
    b = addUnsigned(b, BB);
    c = addUnsigned(c, CC);
    d = addUnsigned(d, DD);
  }

  var temp = wordToHex(a) + wordToHex(b) + wordToHex(c) + wordToHex(d);

  return temp.toLowerCase();
}

function utf8_encode(argString) {

  if (argString === null || typeof argString === 'undefined') {
    return '';
  }

  var string = (argString + ''); // .replace(/\r\n/g, "\n").replace(/\r/g, "\n");
  var utftext = '',
    start, end, stringl = 0;

  start = end = 0;
  stringl = string.length;
  for (var n = 0; n < stringl; n++) {
    var c1 = string.charCodeAt(n);
    var enc = null;

    if (c1 < 128) {
      end++;
    } else if (c1 > 127 && c1 < 2048) {
      enc = String.fromCharCode(
        (c1 >> 6) | 192, (c1 & 63) | 128
      );
    } else if ((c1 & 0xF800) != 0xD800) {
      enc = String.fromCharCode(
        (c1 >> 12) | 224, ((c1 >> 6) & 63) | 128, (c1 & 63) | 128
      );
    } else { // surrogate pairs
      if ((c1 & 0xFC00) != 0xD800) {
        throw new RangeError('Unmatched trail surrogate at ' + n);
      }
      var c2 = string.charCodeAt(++n);
      if ((c2 & 0xFC00) != 0xDC00) {
        throw new RangeError('Unmatched lead surrogate at ' + (n - 1));
      }
      c1 = ((c1 & 0x3FF) << 10) + (c2 & 0x3FF) + 0x10000;
      enc = String.fromCharCode(
        (c1 >> 18) | 240, ((c1 >> 12) & 63) | 128, ((c1 >> 6) & 63) | 128, (c1 & 63) | 128
      );
    }
    if (enc !== null) {
      if (end > start) {
        utftext += string.slice(start, end);
      }
      utftext += enc;
      start = end = n + 1;
    }
  }

  if (end > start) {
    utftext += string.slice(start, stringl);
  }

  return utftext;
}


/************** ROTINAS OPERACIONAIS ***************/

function conexaoPinpadNovo(oPinpad) {

	fechaConexaoPinpadNovo(oPinpad);
		
	if (oPinpad == "" || oPinpad == false || typeof oPinpad == 'undefined') {
		try {
			var oPinpad = new ActiveXObject("Gertec.PPC");		
		} catch(e){		
			return false;
		}		
		// Abre a conexao com o PINPAD
		if (!abrePortaPinpadNovo(oPinpad)) {
			return false;
		}	
	}
	return oPinpad;
}

function abrePortaPinpadNovo(oPinpad){
	var oRetornoJson = [];	 
	/* Fecha Porta */
	oPinpad.CloseSerial();	
	// Verifica qual porta esta o PINPAD
	oRetornoJson = oPinpad.FindPort(2);
	eval("oRetornoJson = " + oRetornoJson);
	
	if (oRetornoJson.dwResult != 0){		
		return false;
	}
	
	sPortaPinpad = 'COM' + oRetornoJson.pbPort[0];
	oRetornoJson = oPinpad.OpenSerial(sPortaPinpad);
	eval("oRetornoJson = " + oRetornoJson);	
	/* Verifica se o Pinpad está conectado na Porta */
	if (oRetornoJson.dwResult != 0){
		return false;
	}	
	return true;
}

function fechaConexaoPinpadNovo(oPinpad){
	
	// Se houver conexao ativa, elimina	
	if (oPinpad != false && typeof oPinpad != 'undefined') {
		oPinpad.ReadMagCard_Stop();
		oPinpad.ChangeEMVCardPasswordStop();
		oPinpad.StopPINBlock();
		// Apaga o LED
		oPinpad.SetLED(0);
		// Fecha Porta
		oPinpad.CloseSerial();	
		
		document.getElementById('divAguardeSenha').style.display = "none";
		document.getElementById('divAguardePassagem').style.display = "none";
		
		return false;
	}
}

function solicitaPassagemPinpadNovo(oPinpad, campoNrCartao){
	
	var oRetornoJson  = [];
	var bPassarCartao = true;
	var cont = 0;
	
	// Limpa tela
	oPinpad.LCD_Clear();
	oPinpad.LCD_DisplayString(2,18,1,"Passe o cartao");
	
	try{
		oPinpad.ReadMagCard_Start(60);
		
		/* Espera passagem */
		while (bPassarCartao) {
			
			oRetornoJson = oPinpad.ReadMagCard_Get();
			eval("oRetornoJson = " + oRetornoJson);
			
			/* Houve passagem de cartão não nula */
			if (oRetornoJson.dwResult == 0 ||
				cont				  == 2) {
				bPassarCartao = false;
			}
			cont = cont + 1;
		}
		
		if (oRetornoJson.sTrack2 != ""){
			campoNrCartao.value = retiraCaracteres(oRetornoJson.sTrack2);
		} else if (oRetornoJson.sTrack1 != ""){
			campoNrCartao.value = retiraCaracteres(oRetornoJson.sTrack1);
		}
		
	} catch(e) {
		campoNrCartao.value = "";
		alert("Erro na passagem do cartao, tente novamente.");
		
		return false;
	}	
}

function obtemSenhaCypto(oPinpad, campoNrCartao, campoSenhaCartao, msgAguarde){

	var oRetornoJson  = [];	
	var sNumeroCartao = campoNrCartao.value;
	
	WrkPinpad = (md5(dechex(Math.floor((Math.random() * 10000000000) + 0000000000))).substr(0, 32).toUpperCase());
	
	setTimeout(function(){
	
		try{
			sNumeroCartao = sNumeroCartao.substr(3,12);			
			oRetornoJson = solicitaPI(oPinpad,sNumeroCartao,WrkPinpad,"Informe a senha:");
			sSTexto1   	 = oRetornoJson.sEncDataBlk;
			oPinpad.StopPINBlock();			
			EncPinpad = sSTexto1;
			
			/* insere senha fake, meramente visual */
			campoSenhaCartao.value = "123456";
			
			if (msgAguarde != "" && msgAguarde != false && typeof msgAguarde != 'undefined') {
				msgAguarde.style.display = "none";								
			}
			
			oPinpad.LCD_Clear();
			oPinpad.LCD_DisplayString(2,18,1,"Processando...");
			
			
		}catch(e){
			
			if (msgAguarde != "" && msgAguarde != false && typeof msgAguarde != 'undefined') {
				msgAguarde.style.display = "none";								
			}
			
			alert("Erro na digitação da senha, tente novamente.");
			return false;
		}
	
	},500);
}

function solicitaPI(oPinpad, sNumeroCartao, sWTexto3, sMensagem){

	var oRetornoJson = [];
	var bPedirPI 	 = true;
	
	oPinpad.StartPINBlock(6,6,0,0,300,4,2,1,sMensagem,2," ",3," ",5," ");
	
	while (bPedirPI){
		//oRetornoJson = oPinpad.GetPINBlock(1,0,2,sWTexto3,16,'0'.charCodeAt(0),0,sNumeroCartao,10,4,3," ",6," ");
		oRetornoJson = oPinpad.GetPINBlock(1,0,2,sWTexto3,16,'0'.charCodeAt(0),0,sNumeroCartao,10,4,3," ",6," ");
		eval("oRetornoJson = " + oRetornoJson);
		
		if (oRetornoJson.dwResult == 11054){
			throw { message: 'Tempo para informar a senha ultrapassou o limite, tente novamente.' };
		}else if (oRetornoJson.dwResult == 11053){
			throw { message: 'Cooperado anulou a operação, informe a senha novamente.' };
		}
		
		if ((oRetornoJson.bPINStatus == 4) || (parseFloat(oRetornoJson.sEncDataBlk) == 0)){
			throw { message: 'Erro ao alterar a senha. Codigo: ' + oRetornoJson.dwResult };
		}		
		
		if (oRetornoJson.bPINStatus == 0){
			bPedirPI = false;
		}		
	}
		
	return oRetornoJson;
}

/****************************************************************************************/
/********               FIM FUNÇÕES DE COMUNICAÇÃO COM O PINPAD NOVO             ********/
/****************************************************************************************/