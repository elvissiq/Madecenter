#Include 'Protheus.ch'
/*/
  @param
  @return Não retorna nada
  @author Totvs Nordeste (Elvis Siqueira)
  @owner Totvs S/A
  @version Protheus 10, Protheus 11,Protheus 12
  @since 07/02/2024
  @sample
  			Ponto de Entrada chamado depois da gravação de todos os dados 
        e da impressão do cupom fiscal na Venda Assistida e após o processamento do Job LjGrvBatch
  @obs
  @project
  @menu 
  @history
  31/01/2024 - Desenvolvimento da Rotina.
/*/

User Function LJ7002()
  Local aArea  := FWGetArea()
  Local cOpcao := cValToChar(ParamIxB[1])
  Local lGrvBatch := IIF(ParamIxB[3] == 2,.T.,.F.)
  Local _cAlias := GetNextAlias()
  Local cWhere := "%SL4.L4_NUM = '"+SL1->L1_NUM+"' AND SL4.L4_FORMA = 'BOL'%"

  If cOpcao $("1/2") .AND. !(lGrvBatch)
     
     If cOpcao == '1' //Orçamento
        
        IF FWAlertNoYes("Imprimir orçamento ?","Impressão")
          u_zROrcVen()
        EndIF
     
     ElseIF cOpcao == '2' //Venda
        
        BeginSql Alias _cAlias
            SELECT SL4.L4_FORMA FROM %table:SL4% SL4
            WHERE
                SL4.L4_FILIAL  = %xFilial:SL4%
                AND %Exp:cWhere%
                AND SL4.%notDel%
        EndSql

        IF !(_cAlias)->(EOF())
          U_XLOJ001(SL1->L1_NUM)
        EndIF
        
        (_cAlias)->(DbCloseArea())
     
     EndIF 
  EndIf

  FWRestArea(aArea)
  
Return
