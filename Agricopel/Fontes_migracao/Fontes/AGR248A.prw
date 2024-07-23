#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAGR248A   บAutor  ณMicrosiga           บ Data ณ  08/14/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Pesquisa Condicoes de Pagamento para Regra de Desconto.    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบ          ณ Atencao: Quando for liberado para Agricopel, devera ser    บฑฑ
ฑฑบ          ณ aglutinada esta logica com a logica do agr248.prw          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบ          ณ Criar Indice:                                              บฑฑ
ฑฑบ          ณ (3) ACO  ACO_FILIAL+ACO_CODCLI+ACO_LOJA+ACO_CODTAB         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบ          ณ Alterar no dicionario de dados, o F3 para o campo          บฑฑ
ฑฑบ          ณ SUA_CONDPG, para F3 igual MA8                              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบ          ณ Criar SXB, com XB_ALIAS = MA8                              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function AGR248A()

PRIVATE oDlg  := Nil, oPesq := Nil, oBrw := Nil, oCmb := Nil
PRIVATE aSeg  := GetArea(), aIndice := {}, aCampos := {}, aLixo := {}
PRIVATE aRotina := {{"","",0 ,1},{"","",0,2}}, aTela[0][0], aGets[0][0]
PRIVATE cCliente := Space(6), cLoja := Space(2), cProduto := Space(15)
PRIVATE cPesq := Space(100), cIndice := "", cCadastro := "", cNomCli := ""
PRIVATE nOpca := 0, nOpcb := 0, nRecno := 0, lRetu := .F., lOk := .F., M->M_PROD := Space(15)

SetPrvt("lFilCom")

/*                        
 * Thiago Padilha
 * incluida essa clausula para que Agricopel Atacado seja visualizada a consulta padrao de condicao de pagamento
 * essa rotina ้ chamada pela configuracao da consulta padrao AGRMA8 que esta configurado no campo UA_CONDPG
 */
if (cEmpAnt == "01" .and. cFilAnt == "06") 
  lRetu := ConPad1(,,,"SE4") 
  
  Return lRetu
EndIf  

lFilComb := .F.
lRetu    := .T.

If SM0->M0_CODIGO <> "02"
	If cModulo == "TMK"
		if (SM0->M0_CODIGO == '01' .And. (SM0->M0_CODFIL == "03" .OR.SM0->M0_CODFIL == "15")) .OR. SM0->M0_CODIGO == '11' .OR. SM0->M0_CODIGO == '12' .OR. SM0->M0_CODIGO == '15'
			lFilComb := .T.
		elseif SM0->M0_CODIGO == '01' .And. SM0->M0_CODFIL == "02" .and. Alltrim(M->UA_TABELA) == '777' // Feito Deco p/Pien vender combustivel
			lFilComb := .T.                                                                              // Feito Deco p/Pien vender combustivel
		else
			lFilComb := .F.
		endif
	ElseiF cModulo <> "TMK"
		lFilComb := .F.
	EndIf
Else
	If SM0->M0_CODIGO == '02' .And.  FunName() == "TMKA271"
		lFilComb := .T.
	else
		lFilComb := .F.
	endif
EndIf

If (lFilComb)
	lRetu		:= .F.
	//Alimento variaveis com os produtos
	////////////////////////////////////
	cCliente := M->UA_CLIENTE
	cLoja    := M->UA_LOJA
	cCodTab	:= M->UA_TABELA
	
	If Empty(cCliente)
		MsgInfo(">>> Voce precisa informar um cliente!!!")
		Return .F.
	Endif                      
	
	// A parte abaixo busca por regra de desconto os precos cadastros para os produtos que o cliente tem
	// desta forma evita erros em pegar regra com precos antigos
	
	//Monto arquivo de trabalho
	///////////////////////////
	aCamposN := {}
	Aadd(aCamposN,{"M_CODTAB"  ,"C",03,0})
	Aadd(aCamposN,{"M_CONDPG"  ,"C",03,0})
	Aadd(aCamposN,{"M_CODREG"  ,"C",06,0})
	Aadd(aCamposN,{"M_DESCRI"  ,"C",30,0})
	Aadd(aCamposN,{"M_CODPRO"  ,"C",15,0})
	Aadd(aCamposN,{"M_PRECO"   ,"N",10,4})
	If (Select("MAR") <> 0)
		dbSelectArea("MAR")
		dbCloseArea()
	Endif
	cNomArq := CriaTrab(aCamposN,.T.)
	dbUseArea(.T.,,cNomArq,"MAR",.F.,.F.)
	
	//Monta query para pesquisa
	///////////////////////////
	cQuery := "SELECT ACO.ACO_CODTAB,ACO.ACO_CONDPG,ACO.ACO_CODREG,ACO.ACO_DESCRI,ACP.ACP_CODPRO,ACP.ACP_PRECO "
	cQuery += "FROM "+RetSqlName("ACO")+" ACO (NOLOCK), "+RetSqlName("ACP")+" ACP (NOLOCK) " 
	cQuery += "WHERE ACO.ACO_FILIAL = '"+xFilial("ACO")+"' AND ACO.D_E_L_E_T_ = '' "
	cQuery += "AND   ACP.ACP_FILIAL = '"+xFilial("ACP")+"' AND ACP.D_E_L_E_T_ = '' "
	cQuery += "AND ACO.ACO_CODCLI = '"+cCliente+"' AND ACO.ACO_LOJA = '"+cLoja+"' "
	cQuery += "AND ACP.ACP_CODREG = ACO.ACO_CODREG "
	cQuery += "ORDER BY ACP.ACP_CODPRO,ACO.ACO_CODTAB,ACO.ACO_CONDPG,ACO.ACO_CODREG "
	If (Select("MACO") <> 0)
		dbSelectArea("MACO")
		dbCloseArea()
	Endif
	cQuery := ChangeQuery(cQuery)
	TCQuery cQuery NEW ALIAS "MACO"
	TCSetField("MACO","ACP_PRECO"  ,"N",10,4)
	    
	//Alimento arquivo de trabalho
	//////////////////////////////                                                 
	dbSelectArea("MACO")
	dbGotop()
	While !Eof()
	   	//Gravo no arquivo de trabalho
	   	//////////////////////////////
		dbSelectArea("MAR")
		Reclock("MAR",.T.)             
		MAR->M_CODTAB  := MACO->ACO_CODTAB
		MAR->M_CONDPG  := MACO->ACO_CONDPG
		MAR->M_CODREG  := MACO->ACO_CODREG
		MAR->M_DESCRI  := MACO->ACO_DESCRI
		MAR->M_CODPRO  := MACO->ACP_CODPRO
		MAR->M_PRECO   := MACO->ACP_PRECO
		MsUnlock("MAR")
		
		dbSelectArea("MACO")
		dbSkip()
	Enddo
	MAR->(dbGotop())
	                      
	
	//Monto campos q serao exibidos
	///////////////////////////////
	aCamposN := {}      
	Aadd(aCamposN,{"M_CODTAB"  ,"Tabela"   	    ,"@K!" })
	Aadd(aCamposN,{"M_CONDPG"  ,"Cond.Pagto"	,"@K!" })
	Aadd(aCamposN,{"M_CODREG"  ,"Regra"   	    ,"@K!" })
	Aadd(aCamposN,{"M_DESCRI"  ,"Cond.Pagto"	,"@K!" })	
	Aadd(aCamposN,{"M_CODPRO"  ,"Produto"       ,"@K!" })
	Aadd(aCamposN,{"M_PRECO"   ,"Preco"         ,"@E 999,999.9999" })


	//Variavel de retorno
	/////////////////////   
	__R230PROD := Space(15)  
	      
	//Monto tela para exibir registros
	//////////////////////////////////
	cNomCli := Alltrim(Posicione("SA1",1,xFilial("SA1")+cCliente+cLoja,"A1_NOME"))
	DEFINE MSDIALOG oDlgN TITLE OemToAnsi("Regras de Descontos para o Cliente : "+cNomCli) FROM 000,000 TO 320,655 OF oMainWnd PIXEL
	@ 005,005 TO 137,323 BROWSE "MAR" FIELDS aCamposN OBJECT oBrwN
	oBrwN:oBrowse:bLDblClick := { || (nOpcb:=1,Close(oDlgN))}
	@ 142,200 BMPBUTTON TYPE 1 ACTION (nOpcb:=1,Close(oDlgN))
	@ 142,240 BMPBUTTON TYPE 2 ACTION (nOpcb:=0,Close(oDlgN))
	ACTIVATE MSDIALOG oDlgN CENTERED
	
	lRetu := iif(nOpcb==1,.T.,.F.)
	
	//Alimento variavel de retorno
	//////////////////////////////
	If (lRetu)
		dbSelectArea("SE4")
		dbSetOrder(1)
		If (nOpcb == 1)
			DbSeek(xFilial("SE4")+MAR->M_CONDPG,.T.)
		Else
			DbSeek(xFilial("SE4")+M->UA_CONDPG,.T.)
		Endif
	Endif
	
	For _i := 1 to Len(aLixo)
		If File(aLixo[_i])
			FErase(aLixo[_i])
		Endif
	Next _i
	
	nRecno := SE4->(Recno())
	RestArea(aSeg)
	SE4->(dbGoto(nRecno))
	SE4->(dbSetOrder(1))
	
	//Fecho arquivos utilizados
	///////////////////////////
	If (Select("MACO") <> 0)
		dbSelectArea("MACO")
		dbCloseArea()
	Endif
	If (Select("MAR") <> 0)
		dbSelectArea("MAR")
		dbCloseArea()
		If File(cNomArq+OrdBagExt())
			FErase(cNomArq+OrdBagExt())
		Endif
	Endif
		
	
	/*    // Substituido esta parte pela acima para apresentar os precos das regras cadastradas 
	      // para evitar pegar preco errado cfe Rosi. Deco 30/12/2005.
	
	//Busco valor informado
	///////////////////////
	cPesq := M->UA_CONDPG
	//cPesq := &(ReadVar())
	cPesq := Alltrim(cPesq) + Space(100-Len(Alltrim(cPesq)))
	
	//Limpo filtros no arquivo SB1
	//////////////////////////////
	dbSelectArea("ACO")
	dbClearFilter()
	RetIndex("ACO")    
	MsFilter("(ACO_FILIAL='"+xFilial("ACO")+"').and.(ACO_CODCLI='"+cCliente+"').and.(ACO_LOJA='"+cLoja+"') .and.(ACO_CODTAB='"+cCodTab+"')") 
	dbSetOrder(3)
	dbGotop()
	
	//Busco informacao se necessario
	////////////////////////////////
	If !Empty(cPesq)
		dbSelectArea("ACO")
		dbSetOrder(3)
		dbSeek(xFilial("ACO")+cPesq,.T.)
	Else
		cPesq := M->UA_CLIENTE+M->UA_LOJA+M->UA_TABELA	
	Endif             
	
	//Busca indices do ACO
	//////////////////////        
	dbSelectArea("SIX")
	dbSeek("ACO",.T.)
	While !Eof().and.(SIX->INDICE == "ACO") 
		Aadd(aIndice,Alltrim(SIX->descricao))
		dbSkip()
	Enddo            
	                      
	//Monto campos q serao exibidos
	///////////////////////////////
	aCampos := {}      
	Aadd(aCampos,{"ACO_CODTAB"  ,"Tabela"   	,"@K!" })
	Aadd(aCampos,{"ACO_CONDPG"  ,"Cond.Pagto"	,"@K!" })
	Aadd(aCampos,{"ACO_CODREG"  ,"Regra"   	,"@K!" })
	Aadd(aCampos,{"ACO_DESCRI"  ,"Cond.Pagto"	,"@K!" })	
	
	//Monto tela para exibir registros
	//////////////////////////////////
	
	DbSelectArea("ACO")
	DbSetOrder(3)
	DbGotop()
	cNomCli := Alltrim(Posicione("SA1",1,xFilial("SA1")+cCliente+cLoja,"A1_NOME"))
	DEFINE MSDIALOG oDlg TITLE OemToAnsi("Regras de Descontos para o Cliente : "+cNomCli) FROM 000,000 TO 300,400 OF oMainWnd PIXEL
	@ 005,005 TO 118,195 BROWSE "ACO" FIELDS aCampos OBJECT oBrw
	oBrw:oBrowse:bLDblClick := { || (nOpca:=1,Close(oDlg))}
	@ 134,100 BMPBUTTON TYPE 1 ACTION (nOpca:=1,Close(oDlg))
	@ 134,130 BMPBUTTON TYPE 2 ACTION (nOpca:=0,Close(oDlg))
	ACTIVATE MSDIALOG oDlg ON INIT (R241Pesquisa(Alltrim(cPesq))) CENTERED
	
	lRetu := (nOpca==1).or.(lOk)
	
	//Alimento variavel de retorno
	//////////////////////////////
	If (lRetu)
		dbSelectArea("SE4")
		dbSetOrder(1)
		If (nOpca == 1)
			DbSeek(xFilial("SE4")+ACO->ACO_CONDPG,.T.)
		Else
			DbSeek(xFilial("SE4")+M->UA_CONDPG,.T.)
		Endif
	Endif
	
	For _i := 1 to Len(aLixo)
		If File(aLixo[_i])
			FErase(aLixo[_i])
		Endif
	Next _i
	
	nRecno := SE4->(Recno())
	RestArea(aSeg)
	SE4->(dbGoto(nRecno))
	SE4->(dbSetOrder(1))
	
	*/
	
Else

	//Busco valor informado
	///////////////////////
	cPesq := M->UA_CONDPG
	//cPesq := &(ReadVar())
	cPesq := Alltrim(cPesq) + Space(100-Len(Alltrim(cPesq)))
	
	//Limpo filtros no arquivo SB1
	//////////////////////////////
	DbSelectArea("SE4")
	DbClearFilter()
	RetIndex("SE4")    
	MsFilter("(E4_FILIAL='"+xFilial("SE4")+"').and.(E4_USADO='1')") 
	DbSetOrder(1)
	DbGotop()
	
	//Busco informacao se necessario
	////////////////////////////////
	If !Empty(cPesq)
		dbSelectArea("SE4")
		dbSetOrder(1)
		dbSeek(xFilial("SE4")+cPesq,.T.)
	Endif             
	
	//Busca indices do ACO
	//////////////////////        
	DbSelectArea("SIX")
	DbSeek("SE4",.T.)
	While !Eof().and.(SIX->INDICE == "SE4") 
		Aadd(aIndice,Alltrim(SIX->descricao))
		DbSkip()
	Enddo            
	                      
	//Monto campos q serao exibidos
	///////////////////////////////
	aCampos := {}      
	Aadd(aCampos,{"E4_CODIGO"   ,"Codigo"   	   ,"@K!" })
	Aadd(aCampos,{"E4_COND"     ,"Cond.Pagto"	   ,"@K!" })
	Aadd(aCampos,{"E4_X_ACRES"  ,"Acres.Fina"   	,"@K!" })
	Aadd(aCampos,{"E4_DESCRI"   ,"Descricao"   	,"@K!" })
	
	//Monto tela para exibir registros
	//////////////////////////////////
	
	DbSelectArea("SE4")
	DbSetOrder(1)
	DbGotop()
	DEFINE MSDIALOG oDlg TITLE OemToAnsi("Condicoes de Pagamentos Liberadas para CallCenter") FROM 000,000 TO 300,400 OF oMainWnd PIXEL
	@ 005,005 TO 118,195 BROWSE "SE4" FIELDS aCampos OBJECT oBrw
	oBrw:oBrowse:bLDblClick := { || (nOpca:=1,Close(oDlg))}
	@ 134,100 BMPBUTTON TYPE 1 ACTION (nOpca:=1,Close(oDlg))
	@ 134,130 BMPBUTTON TYPE 2 ACTION (nOpca:=0,Close(oDlg))
	ACTIVATE MSDIALOG oDlg ON INIT (RSE4Pesquisa(Alltrim(cPesq))) CENTERED
	
	lRetu := (nOpca==1).or.(lOk)
	
	//Alimento variavel de retorno
	//////////////////////////////
	
	For _i := 1 to Len(aLixo)
		If File(aLixo[_i])
			FErase(aLixo[_i])
		Endif
	Next _i
	
EndIf

Return (lRetu)
      
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณR241PesquisaบAutor  ณ Marcelo da Cunha บ Data ณ  11/04/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao que realiza a pesquisa no Browse                    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function R241Pesquisa(xPesq)
*******************************
LOCAL cIndex := "", cKey := "", cFiltro := ""
LOCAL nInd := 0, nIndex := 0

If Empty(xPesq)
	dbSelectArea("ACO")
	dbClearFilter()
	RetIndex("ACO")     
	MsFilter("(ACO_FILIAL='"+xFilial("ACO")+"').and.(ACO_CODCLI='"+cCliente+"').and.(ACO_LOJA='"+cLoja+"') .and.(ACO_CODTAB='"+cCodTab+"')") 	
	dbSetOrder(3)
	dbGotop()
	If (oBrw <> Nil)
		oBrw:oBrowse:Refresh()
	Endif
	//SysRefresh()
	Return (.T.)
Endif

dbSelectArea("ACO")
dbClearFilter()
RetIndex("ACO")
MsFilter("(ACO_FILIAL='"+xFilial("ACO")+"').and.(ACO_CODCLI='"+cCliente+"').and.(ACO_LOJA='"+cLoja+"') .and.(ACO_CODTAB='"+cCodTab+"')") 
dbSetOrder(3)
dbGotop()

nInd := aScan(aIndice,Alltrim(cIndice))

nInd--
If !Empty(nInd)
	dbSelectArea("ACO")
	dbSetOrder(nInd)
	dbSeek(xFilial("ACO")+xPesq,.T.)
Endif

If (oBrw <> Nil)
	oBrw:oBrowse:Refresh()
Endif
//SysRefresh()

Return (.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณR241PesquisaบAutor  ณ Marcelo da Cunha บ Data ณ  11/04/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao que realiza a pesquisa no Browse                    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function RSE4Pesquisa(xPesq)
*******************************
LOCAL cIndex := "", cKey := "", cFiltro := ""
LOCAL nInd := 0, nIndex := 0

If Empty(xPesq)
	dbSelectArea("SE4")
	dbClearFilter()
	RetIndex("SE4")     
	MsFilter("(E4_FILIAL='"+xFilial("SE4")+"').and.(E4_USADO='1')") 
	dbSetOrder(1)
	dbGotop()
	If (oBrw <> Nil)
		oBrw:oBrowse:Refresh()
	Endif
	//SysRefresh()
	Return (.T.)
Endif

dbSelectArea("SE4")
dbClearFilter()
RetIndex("SE4")
MsFilter("(E4_FILIAL='"+xFilial("SE4")+"').and.(E4_USADO='1')") 
dbSetOrder(1)
dbGotop()

nInd := aScan(aIndice,Alltrim(cIndice))

nInd--
If !Empty(nInd)
	dbSelectArea("SE4")
	dbSetOrder(nInd)
	dbSeek(xFilial("SE4")+xPesq,.T.)
Endif

If (oBrw <> Nil)
	oBrw:oBrowse:Refresh()
Endif
//SysRefresh()

Return (.T.)
