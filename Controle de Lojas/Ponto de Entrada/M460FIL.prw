#Include "Protheus.ch"
 
//-----------------------------------------------------------
/*
{Protheus.doc} M460FIL()
Ponto de entrada executado antes da exibi��o da tela de sele��o
de itens para a gera��o de Doc. de Sa�da (Markbrowse). 
@since 14/11/2024
*/
//-----------------------------------------------------------
 
User Function M460FIL()
    Local cFilSC9 := ""//PARAMIXB[1]
    
    Default cNumPed := ""

    If !Empty(cNumPed) 
        cFilSC9 += "C9_PEDIDO == " + cNumPed
    EndIF

Return cFilSC9
