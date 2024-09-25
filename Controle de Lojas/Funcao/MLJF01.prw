//Bibliotecas
#Include 'Protheus.ch'
#Include "TOPCONN.ch"
#Include 'FWMVCDef.ch'

Static cCamposSL2 := "L2_NUM;L2_EMISSAO;L2_ITEM;L2_PRODUTO;L2_DESCRI;L2_QUANT;L2_VRUNIT;L2_VLRITEM;L2_DOC;L2_SERIE;L2_PDV;"

//----------------------------------------------------------------------
/*/{PROTHEUS.DOC} MLJF01
FUNÇÃO MLJF01 - Tela para consulta de Historico de Vendas do Cliente
@VERSION PROTHEUS 12
@SINCE 25/09/2024
/*/
//----------------------------------------------------------------------

User Function MLJF01()
    Local aButtons := {{.F.,Nil},;
                       {.F.,Nil},;
                       {.F.,Nil},;
                       {.F.,Nil},;
                       {.F.,Nil},;
                       {.F.,Nil},;
                       {.F.,Nil},;
                       {.T.,"Fechar"},;
                       {.F.,Nil},;
                       {.F.,Nil},;
                       {.F.,Nil},;
                       {.F.,Nil},;
                       {.F.,Nil},;
                       {.F.,NIl}}

    Private oTableTMP  := Nil
    Private aFieldsTMP := {}

    oTableTMP  := FWTemporaryTable():New("TMP")

    aAdd(aFieldsTMP,{"TMP_CLIENT","C", FWTamSX3("A1_CGC")[1]    , FWTamSX3("A1_CGC")[2]    , "Código ou CNPJ/CPF" ,"","SA1AZ0"})
    aAdd(aFieldsTMP,{"TMP_NOMCLI","C", FWTamSX3("A1_NOME")[1]   , FWTamSX3("A1_NOME")[2]   , "Nome Cliente"       ,"",""      })
    aAdd(aFieldsTMP,{"TMP_DTINI" ,"D", FWTamSX3("L1_EMISSAO")[1], FWTamSX3("L1_EMISSAO")[2], "Data Inicio"        ,"",""      })
    aAdd(aFieldsTMP,{"TMP_DTFIM" ,"D", FWTamSX3("L1_EMISSAO")[1], FWTamSX3("L1_EMISSAO")[2], "Data Fim"           ,"",""      })

    oTableTMP:SetFields(aFieldsTMP)
    oTableTMP:AddIndex("01", {"TMP_CLIENT"})
    oTableTMP:Create()

    FWExecView("",'MLJF01',3,,{||.T.},,,aButtons)
    
    oTableTMP:Delete()

Return

/*---------------------------------------------------------------------*
 | Func:  ModelDef                                                     |
 | Desc:  Criação do modelo de dados MVC                               |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
 
Static Function ModelDef()
Local oModel
Local oStrTMP := fnM01TMP()
Local oStrSL2 := FWFormStruct(1,'SL2', {|cCampo| Alltrim(cCampo) $ cCamposSL2})

    oStrTMP:AddTrigger("TMP_CLIENT", "TMP_NOMCLI" ,{||.T.},{|oStrTMP| fBusNCli(oStrTMP) })

    oModel := MPFormModel():New('MLJF01M',/*bPre*/,/*bPost*/,/*bCommit*/,/*bCancel*/)
    oModel:AddFields('TMPMASTER',/*cOwner*/,oStrTMP,/*bPre*/,/*bPos*/,/*bLoad*/)
    oModel:AddGrid('SL2DETAIL', 'TMPMASTER', oStrSL2,/*bLinePre*/, /*bLinePost*/,/*bPre - Grid Inteiro*/,/*bPos - Grid Inteiro*/,/*bLoad - Carga do modelo manualmente*/)

    oModel:SetPrimaryKey({})
    oModel:SetDescription("Historico Cliente")
    oModel:GetModel('TMPMASTER'):SetDescription('Dados da Carga')
    oModel:GetModel('SL2DETAIL'):SetDescription('Notas Fiscais da Carga')

    oStrTMP:SetProperty("TMP_NOMCLI", MODEL_FIELD_WHEN, {||.F.})

Return oModel

//-----------------------------------------
/*/ fnM01TMP
  Estrutura dos Parâmetros.								  
/*/
//-----------------------------------------
Static Function fnM01TMP()
Local oStruct := FWFormModelStruct():New()
Local nId  

oStruct:AddTable("TMP",{},"Tabela TMP")

For nId := 1 To Len(aFieldsTMP)
    oStruct:AddField(aFieldsTMP[nId][5]; 
                    ,aFieldsTMP[nId][5]; 
                    ,aFieldsTMP[nId][1]; 
                    ,aFieldsTMP[nId][2];
                    ,aFieldsTMP[nId][3];
                    ,aFieldsTMP[nId][4];
                    ,Nil,Nil,{},.F.,,.F.,.F.,.F.)
Next nId

Return oStruct

//-----------------------------------------
/*/ fBusNCli
  Retorna o Nome do Cliente.								  
/*/
//-----------------------------------------
Static Function fBusNCli(oStrTMP)
    Local cRet := ""
    Local _cAlias := GetNextAlias()

    cQry := " SELECT SA1.A1_NOME "
    cQry += " FROM "+RetSQLName("SA1")+" SA1 "
    cQry += " WHERE SA1.D_E_L_E_T_ <> '*' "
    cQry += " 	AND ( SA1.A1_COD = '"+AllTrim(oStrTMP:GetValue("TMP_CLIENT"))+"' OR SA1.A1_CGC = '"+AllTrim(oStrTMP:GetValue("TMP_CLIENT"))+"' ) "
    cQry := ChangeQuery(cQry)
    TCQuery cQry ALIAS (_cAlias) NEW

    IF !(_cAlias)->(EOF())
        cRet := Alltrim((_cAlias)->A1_NOME)
    Endif 

    (_cAlias)->(DBCloseArea())

Return cRet

/*---------------------------------------------------------------------*
 | Func:  ViewDef                                                      |
 | Desc:  Criação da visão MVC                                         |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
 
Static Function ViewDef()
Local oView 
Local oModel   := FWLoadModel('MLJF01')
Local oStrTMP  := fnV01TMP()
Local oStrSL2  := FWFormStruct(2, 'SL2', {|cCampo| Alltrim(cCampo) $ cCamposSL2})

    oView := FWFormView():New()
    oView:SetModel(oModel)
    oView:SetProgressBar(.T.)
    oView:AddField('VIEW_TMP',oStrTMP,'TMPMASTER')
    oView:AddGrid('VIEW_SL2',oStrSL2,'SL2DETAIL')
    
    oView:CreateHorizontalBox('CABEC',020)
    oView:CreateHorizontalBox('GRID',080)
    
    oView:SetOwnerView('VIEW_TMP','CABEC')
    oView:SetOwnerView('VIEW_SL2','GRID')
    
    oView:EnableTitleView('VIEW_TMP','Cliente')
    oView:EnableTitleView('VIEW_SL2','Historico de Vendas')
    
    oView:SetViewProperty("VIEW_SL2", "SETCSS", {"QTableView { selection-background-color: #CD853F; selection-color: #000000; }"} )
    oView:SetViewProperty("VIEW_SL2", "GRIDSEEK",   {.T.})
    oView:SetViewProperty("VIEW_SL2", "GRIDFILTER", {.T.})

    oView:AddUserButton( 'Consultar', 'NOTE',;
                        {|oView| FWMsgRun(, {|| fConsulta(oView) }, "Aguarde...", "Consultando Historico")},;
                         /*cToolTip  | Comentário do botão*/,;
                         /*nShortCut | Codigo da Tecla para criação de Tecla de Atalho*/,;
                         /*aOptions  | */,;
                         /*lShowBar */ .T.)
    
    oView:SetViewAction("ASKONCANCELSHOW",{|| .F.}) // Tirar a mensagem do final "Há Alterações não..."

Return oView

//-------------------------------------------------------------------
/*/ Função fnV01TMP()
  Estrutura do cabeçalho (View)	
/*/
//-------------------------------------------------------------------
Static Function fnV01TMP()
Local oViewTMP := FWFormViewStruct():New() 
Local nId

  For nId := 1 To Len(aFieldsTMP)   
    oViewTMP:AddField(aFieldsTMP[nId][1],;   // 01 = Nome do Campo
                      StrZero(nId,2),;       // 02 = Ordem
                      aFieldsTMP[nId][5],;   // 03 = Título do campo
                      aFieldsTMP[nId][5],;   // 04 = Descrição do campo
                      Nil,;                  // 05 = Array com Help
                      aFieldsTMP[nId][2],;   // 06 = Tipo do campo
                      aFieldsTMP[nId][6],;   // 07 = Picture
                      Nil,;                  // 08 = Bloco de PictTre Var
                      aFieldsTMP[nId][7],;   // 09 = Consulta F3
                      .T.,;                  // 10 = Indica se o campo é alterável
                      Nil,;                  // 11 = Pasta do Campo
                      Nil,;                  // 12 = Agrupamnento do campo
                      Nil,;                  // 13 = Lista de valores permitido do campo (Combo)
                      Nil,;                  // 14 = Tamanho máximo da opção do combo
                      Nil,;                  // 15 = Inicializador de Browse
                      .F.,;                  // 16 = Indica se o campo é virtual (.T. ou .F.)
                      Nil,;                  // 17 = Picture Variavel
                      Nil)                   // 18 = Indica pulo de linha após o campo (.T. ou .F.)
  NExt nId

Return oViewTMP

/*---------------------------------------------------------------------*
 | Func:  fConsulta                                                    |
 | Desc:  Realiza consulta na SL2 para trazer o historico de vendas    |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
Static Function fConsulta(oView)
    Local oModel := FWModelActive() 
    Local oModelTMP := oModel:GetModel("TMPMASTER")
    Local oModelSL2 := oModel:GetModel("SL2DETAIL")
    Local _cAlias   := GetNextAlias()
    Local cDtIni    := IIF(!Empty(oModelTMP:GetValue("TMP_DTINI")),DToS(oModelTMP:GetValue("TMP_DTINI")),DToS(DaySub(dDataBase, 1825)))
    Local cDtFim    := IIF(!Empty(oModelTMP:GetValue("TMP_DTFIM")),DToS(oModelTMP:GetValue("TMP_DTFIM")),DToS(dDataBase))
    Local cQry      := ""
    Local nLinQry   := 0
    
    cQry := " SELECT SL2.L2_NUM, SL2.L2_EMISSAO,  SL2.L2_ITEM, SL2.L2_PRODUTO, SL2.L2_DESCRI, SL2.L2_QUANT, SL2.L2_VRUNIT, "
    cQry += " SL2.L2_VLRITEM, SL2.L2_DOC, SL2.L2_SERIE,SL2.L2_PDV "
    cQry += " FROM "+RetSQLName("SL1")+" SL1 "
    cQry += " INNER JOIN "+RetSQLName("SL2")+" SL2 ON SL2.L2_NUM = SL1.L1_NUM"
    cQry += " INNER JOIN "+RetSQLName("SA1")+" SA1 ON SA1.A1_COD = SL1.L1_CLIENTE"
    cQry += " WHERE SL1.D_E_L_E_T_ <> '*' "
    cQry += " 	AND SL2.D_E_L_E_T_ <> '*' "
    cQry += " 	AND SA1.D_E_L_E_T_ <> '*' "
    cQry += " 	AND ( SA1.A1_COD = '"+AllTrim(oModelTMP:GetValue("TMP_CLIENT"))+"' OR SA1.A1_CGC = '"+AllTrim(oModelTMP:GetValue("TMP_CLIENT"))+"' ) "
    cQry += " 	AND SL1.L1_EMISSAO BETWEEN '"+cDtIni+"' AND '"+cDtFim+"' "
    cQry += " 	ORDER BY SL1.L1_NUM DESC "
    cQry := ChangeQuery(cQry)
    TCQuery cQry ALIAS (_cAlias) NEW

    oModelSL2:ClearData(.T.)

    While !(_cAlias)->(EOF())
        
        nLinQry++
        IF nLinQry > 1
            oModelSL2:AddLine()
        EndIF 

        oModelSL2:LoadValue("L2_NUM"    ,(_cAlias)->L2_NUM          )
        oModelSL2:LoadValue("L2_EMISSAO",SToD((_cAlias)->L2_EMISSAO))
        oModelSL2:LoadValue("L2_ITEM"   ,(_cAlias)->L2_ITEM         )
        oModelSL2:LoadValue("L2_PRODUTO",(_cAlias)->L2_PRODUTO      )
        oModelSL2:LoadValue("L2_DESCRI" ,(_cAlias)->L2_DESCRI       )
        oModelSL2:LoadValue("L2_QUANT"  ,(_cAlias)->L2_QUANT        )
        oModelSL2:LoadValue("L2_VRUNIT" ,(_cAlias)->L2_VRUNIT       )
        oModelSL2:LoadValue("L2_VLRITEM",(_cAlias)->L2_VLRITEM      )
        oModelSL2:LoadValue("L2_DOC"    ,(_cAlias)->L2_DOC          )
        oModelSL2:LoadValue("L2_SERIE"  ,(_cAlias)->L2_SERIE        )
        oModelSL2:LoadValue("L2_PDV"    ,(_cAlias)->L2_PDV          )
        
        oView:Refresh('VIEW_SL2')
    
    (_cAlias)->(DBSkip()) 
    EndDo
    
    (_cAlias)->(DBCloseArea())

    oModelSL2:GoLine(1)
    oView:Refresh('VIEW_SL2')
    oView:SetNoDeleteLine('VIEW_SL2')
    oView:SetNoInsertLine('VIEW_SL2')
    
Return
