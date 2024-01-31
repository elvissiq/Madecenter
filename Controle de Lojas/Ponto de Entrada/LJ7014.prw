#Include "Protheus.ch"
#Include "Totvs.ch"
#Include "TopConn.ch"

/*--------------------------------------------------------------------------------------------------------------*
 | P.E.:  LJ7014                                                                                                |
 | Desc:  LJ7014 - Utilizado para verificar se realiza ou não a análise de crédito padrão.                      |
 |                                                                                                              |
 | Link:  https://tdn.totvs.com/pages/releaseview.action?pageId=6790889                                         |
 *--------------------------------------------------------------------------------------------------------------*/

User Function LJ7014()
Local aArea   := GetArea()
Local aPgtos  := ParamIXB[4]
Local _cAlias := GetNextAlias()
Local cTipo   := ""
Local lRet    := .F.
Local nId 

  For nId:=1 To Len(aPgtos)
    cTipo := aPgtos[nId][3]

        BeginSql Alias _cAlias
          SELECT    
              AE_FINPRO
          FROM
              %table:SAE% 
          WHERE
              AE_FILIAL   = %xFilial:SAE%
              AND AE_TIPO = %Exp:cTipo%
              AND %notDel%
        EndSql

            While !(_cAlias)->(EoF())
              If (_cAlias)->AE_FINPRO == "S"
                
                lRet := .T.
              
              EndIf 
              (_cAlias)->(dbSkip())
            ENDDO

          IF Select(_cAlias) > 0
            (_cAlias)->(DbCloseArea())
          EndIf
  Next nId 

RestArea(aArea)

Return (lRet)
