#Include "Protheus.ch"
 
/*-------------------------------------------------------------------------------------*
 | P.E.:  M440FIL - Filtro no browse                                                   |
 | Desc:  M440FIL - No momento da exibicao da mBrowse de pedidos de venda.             |
 |                                                                                     |
 | Link:  https://tdn.totvs.com/display/public/PROT/M440FIL+-+Filtro+no+browse         |
 *-------------------------------------------------------------------------------------*/

User Function M440FIL()
        Local cRet := ""

        Default cNumPed := ""

        If !Empty(cNumPed)
            cRet := " C5_NUM == " + cNumPed
        EndIf 

Return cRet
