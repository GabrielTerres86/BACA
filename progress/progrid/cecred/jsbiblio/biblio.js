// Biliotecas de JavaScript
// Copyright (C) 1999 
// Library for use exclusive by 

function MostraResultado(vqtdeerro,erro) 
{
alert(erro);
}


/* botão de confirmação */
function ConfirmaMens()
{
 top.frames[3].frames[1].document.form.op.value = '';
 WinMsg.close();
}


/* Fecha confirmacao se estiver aberto */
function FechaMens()
{
  bName = navigator.appName;
  bVer  = parseInt(navigator.appVersion);
  if (bName  == "Netscape") {
    if (window.WinMsg != null)   {	
       if (WinMsg.closed != true) {
          WinMsg.close();
       }
    }
  }  
}

