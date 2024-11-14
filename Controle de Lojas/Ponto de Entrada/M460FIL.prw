#Include "Protheus.ch"
 
//-----------------------------------------------------------
/*
{Protheus.doc} M460FIL()
Ponto de entrada executado antes da exibição da tela de seleção
de itens para a geração de Doc. de Saída (Markbrowse). 
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
