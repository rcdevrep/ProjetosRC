#INCLUDE "AGR093.CH"
#INCLUDE "FIVEWIN.CH"
#INCLUDE "TOPCONN.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AGR093    ºAutor  ³Microsiga           º Data ³  11/10/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Programa para impressao de Cheque Troco - Agricopel        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP5                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function AGR093()
	LOCAL nSavRec := RecNo()
	
	PRIVATE aTELA[0][0],aGETS[0]
	PRIVATE aRotina := { {OemToAnsi(STR0001), "AxPesqui", 0 , 1},;  // "Pesquisar" 
								{OemToAnsi(STR0003), "U_AGR093AVS", 0 , 3},;  // "Avulsos"   
								{OemToAnsi(STR0005), "fa390Can", 0 , 3} }  // "caNcelar"  //substituiso pela padrão para gerar FKs
	                            //{OemToAnsi(STR0005), "U_AGR093Can", 0 , 3} }  // "caNcelar"  
	
	Private cBanco390, cAgencia390, cConta390, cCheque390, dVencIni, dVencFim
	Private nQtde390   // Incluido por Valdecir em 10.11.03
	Private nLimite, cNatur390, cBenef390, cForn390, cHist390, aTitulos:={}
	Private cFil390,cLojaBen
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Chamada da fun‡„o pergunte											  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Set Key VK_F12 To fA390Perg()
	pergunte("FIN390",.F.)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define o cabe‡alho principal do programa.						  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	PRIVATE cCadastro := OemToAnsi(STR0006)  //"Cheques a Pagar"
	Private cMarca 	:= GetMark()
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica o numero do Lote 											  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Private cLote
	LoteCont( "FIN" )
	IF ExistBlock("F390BROW")
		ExecBlock("F390BROW",.f.,.f.)
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Endereca a Fun‡„o de BROWSE											  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	mBrowse( 6, 1,22,75,"SE2",,"E2_IMPCHEQ" )
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Recupera a Integridade dos dados									  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SE2")
	dbSetOrder(1)
	dbGoTo( nSavRec )
	
	Set Key VK_F12 To
Return

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³fa390Avu	³ Autor ³ Wagner Xavier 		  ³ Data ³ 21/03/94 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Cadastra cheque avulso.												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³fa390Avu()																  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³FINA390																	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function AGR093AVS( cAlias, nRec, nOpcE )

LOCAL oDlg
LOCAL nValor390
LOCAL lPadrao,cPadrao:="567"
LOCAL cArquivo, cComprobX
LOCAL nTotal	:=0
LOCAL nHdlPrv	:=0
LOCAL nOpca 	:= 0
Local cLiberado:= GetMv("MV_LIBCHEQ")
Local aFINA100 := {} 
Local cChaveCH := ""
Private lMsErroAuto := .F.


cBanco390		:= CriaVar("EF_BANCO")
cAgencia390 	:= Criavar("EF_AGENCIA")
cConta390		:= Criavar("EF_CONTA")
nValor390		:= 0
nQtde390			:= 0   // Incluido por Valdecir em 10.11.03
cBenef390		:= Space(40)
cHist390 		:= Space(40)
cNatur390		:= Space(10)
cCheque390		:= Space(06)  // Ajustado para (06) pois o padrao (15) estava dando problemas apos 8.11 R3 - Deco 08/11/2006
cForn390			:= Space( 6)
nSavRec			:= RecNO()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se data do movimento n„o ‚ menor que data limite de ³
//³ movimentacao no financeiro    										  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !DtMovFin()
	Return
Endif	

While .T.
	cBanco390	:= CriaVar("EF_BANCO")
	cAgencia390 := Criavar("EF_AGENCIA")
	cConta390	:= Criavar("EF_CONTA")
	nValor390  	:=0
	nQtde390		:= 0	// Incluido por Valdecir em 10.11.03
	cBenef390  	:=Space(40)
	cHist390   	:=Space(40)
	cNatur390  	:=Space(10)
	cCheque390 	:=Space(06) // Ajustado para (06) pois o padrao (15) estava dando problemas apos 8.11 R3 - Deco 08/11/2006
    cForn390   :=Space( 6)
    cLojaBen   :=Space( 2)

	If ExistBlock("A390HIST")
		cHist390:=padr(ExecBlock("A390HIST",.f.,.f.),40)
	Endif

	nOpca := 0
	DEFINE MSDIALOG oDlg FROM 15,6 TO 284,485 TITLE OemToAnsi(STR0035) PIXEL  //"Cheques Avulsos"

	@ 003, 011 TO 038, 193 OF oDlg	PIXEL
	@ 042, 011 TO 129, 193 OF oDlg	PIXEL

	@ 011, 016 SAY 	OemToAnsi(STR0012)                                               SIZE 021, 07 OF oDlg PIXEL  //"Banco"
	@ 020, 016 MSGET	cBanco390 F3 "SA6"   Valid Fa390Banco(1) Picture "@!" SIZE 021, 11 OF oDlg PIXEL
	@ 011, 052 SAY 	OemToAnsi(STR0013)                                    SIZE 028, 07 OF oDlg PIXEL  //"Agˆncia"
	@ 020, 052 MSGET	cAgencia390 			Valid Fa390Banco(2) Picture "@!" SIZE 028, 11 OF oDlg PIXEL
	@ 011, 087 SAY 	OemToAnsi(STR0014)                                               SIZE 025, 07 OF oDlg PIXEL  //"Conta"
	@ 020, 087 MSGET	cConta390				Valid Fa390Banco(3) Picture "@!" SIZE 039, 11 OF oDlg PIXEL
	@ 011, 134 SAY 	OemToAnsi(STR0015)                            			SIZE 046, 07 OF oDlg PIXEL  //"N£mero Cheque"
	@ 020, 133 MSGET	cCheque390				Valid Fa390Cheq(1) Picture "@!"  SIZE 049, 11 OF oDlg PIXEL
//	@ 020, 133 MSGET	cCheque390				Picture "@!"  SIZE 049, 11 OF oDlg PIXEL
//	U_AGR093VALCH()

	@ 049, 018 SAY 	OemToAnsi(STR0019)   	SIZE 053, 07 OF oDlg PIXEL  //"Valor do Cheque"
	@ 059, 018 MSGET	nValor390 Picture "@E 9,999,999.99" Valid nValor390>0;
																									SIZE 053, 11 OF oDlg PIXEL

   @ 049, 075 SAY    OemToAnsi(STR0049) 												SIZE 053, 07 OF oDlg PIXEL  //"Qtde Cheques"  // Incluido por Valdecir em 10.11.03
	@ 059, 075 MSGET	nQtde390 Picture "@E 99999" Valid nQtde390>0				SIZE 053, 11 OF oDlg PIXEL
																									
	@ 049, 134 SAY 	OemToAnsi(STR0021)                                    SIZE 046, 07 OF oDlg PIXEL  //"Natureza"
	@ 059, 133 MSGET	cNatur390 F3 "SED"   Valid fa390Natur() Picture "@!"  SIZE 049, 11 OF oDlg PIXEL
	
	@ 075, 018 SAY 	OemToAnsi(STR0023)                                    SIZE 053, 07 OF oDlg PIXEL  //"Hist¢rico"
	@ 085, 018 MSGET	cHist390 				Picture "@!S35"                  SIZE 168, 11 OF oDlg PIXEL
	If cPaisLoc != "COL"
		@ 101, 018 SAY 	OemToAnsi(STR0022)                             			SIZE 053, 07 OF oDlg PIXEL  //"Benefici rio"
		@ 111, 018 MSGET cBenef390				Picture "@!S29"                   SIZE 168, 11 OF oDlg PIXEL
	Else
		@ 101, 018 SAY 	OemToAnsi(STR0020)                        SIZE 35, 07 OF oDlg PIXEL  //"Fornecedor"
		@ 111, 018 MSGET cForn390 	F3 "SA2" Valid fa390Fornece() SIZE 28, 11 OF oDlg PIXEL
		@ 101, 060 SAY 	OemToAnsi(STR0022)                        SIZE 53, 07 OF oDlg PIXEL  //"Benefici rio"
		@ 111, 060 MSGET cBenef390	Picture "@!S30"	SIZE 126, 11 OF oDlg PIXEL
	EndIf

	DEFINE SBUTTON FROM 07, 204 TYPE 1 ACTION (If(Fa390Ok(oDlg),(nOpca := 1,oDlg:End()),nOpca:=0)) ENABLE OF oDlg
	DEFINE SBUTTON FROM 20, 204 TYPE 2 ACTION oDlg:End() ENABLE OF oDlg

	ACTIVATE MSDIALOG oDlg CENTERED  
	

		
	
	//*************************

	If nOpca == 2 .Or. nOpca == 0
		Exit
	ElseIf nOpca == 1     
	
		//VALIDA CHEQUE            
		cQuery := "SELECT R_E_C_N_O_, D_E_L_E_T_, EF_FILIAL, EF_BANCO, EF_AGENCIA, EF_CONTA, EF_NUM, EF_DATA "
		cQuery += "FROM "+RetSqlName("SEF")+" (NOLOCK) "
   	cQuery += "WHERE EF_FILIAL = '"+xFilial("SEF")+"' "
		cQuery += "AND EF_BANCO    = '"+cBanco390+"' "
		cQuery += "AND EF_AGENCIA  = '"+cAgencia390+"' "
		cQuery += "AND EF_CONTA    = '"+cConta390+"' "
		cQuery += "AND EF_NUM      >='"+cCheque390+"' "		
		cQuery += "AND EF_DATA     = '"+Dtos(dDataBase)+"' "
		cQuery += "AND D_E_L_E_T_ != '*' "
		
		If (Select("MSEF") <> 0)
			dbSelectArea("MSEF")
			dbCloseArea()
		Endif
		
		TCQuery cQuery NEW ALIAS "MSEF"
		
   	DbSelectArea("MSEF")  		
		Count to nCont
/*		If nCont > 0   // se não tem informação !!!
	      alert("Atenção! Cheque já cadastrado para este período!")
         return()
      Endif*/
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Grava cheque no sistema.												  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
		cINICHEQ := cCheque390
		cFIMCHEQ := Space(15) 
		
		For xx := 1 to nQtde390

			BEGIN TRANSACTION
			    
			    cChaveCH := FWUUIDV4()			
				
				Reclock( "SEF", .T. )
					SEF -> EF_FILIAL	:= cFilial
					SEF -> EF_NUM		:= cCheque390
					SEF -> EF_VALOR	:= nValor390
					SEF -> EF_BANCO	:= cBanco390
					SEF -> EF_AGENCIA := cAgencia390
					SEF -> EF_CONTA	:= cConta390
					SEF -> EF_BENEF	:= cBenef390
					SEF -> EF_DATA 	:= dDataBase
					SEF -> EF_HIST 	:= cHist390
					//SEF -> EF_LIBER   := cLiberado
					SEF -> EF_ORIGEM  := "FINA390AVU" //"AGR093AVS"
					SEF -> EF_FORNECE := cForn390
					SEF -> EF_LOJA    := cLojaBen
					SEF -> EF_VENCTO 	:= dDataBase 
				    SEF -> EF_IMPRESS   := 'S' //Alterado para para não deletar  e contabilizar na Rotina padrao Padrao fa390Can -> chamado 75357 
	                SEF -> EF_LIBER     := 'S'//Alterado para para não deletar  e contabilizar na Rotina padrao Padrao fa390Can -> chamado 75357 
	   	            SEF -> EF_IDSEF		:= cChaveCH
	   	            SEF -> EF_SEQUENC   := "01" 
	   	            SEF -> EF_TITULO    := cCheque390
					
					If cPaisLoc == "COL"
						cComprobante := Tabela("YG","CE")			
					 	If SX5->(RecLock("SX5"))
					 	    cComprobX        := StrZero(Val(cComprobante)+1,Len(cComprobante))
					 		SX5->X5_DESCSPA := cComprobX
					 		SX5->X5_DESCRI  := cComprobX
					 		SX5->X5_DESCENG := cComprobX
					 	EndIf
					 	SEF->EF_COMPROB := cComprobante
					 	SX5->(MsUnlock())
					EndIf
				MsUnlock("SEF")
		
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Registra na movimenta‡„o Banc ria. 								  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If ( cLiberado == "S" )
				  
				   aFINA100:= { {"E5_FILIAL", cFilial ,Nil},;
							  {"E5_BANCO" ,cBanco390 ,Nil},;
							  {"E5_AGENCIA" ,cAgencia390 ,Nil},;
							  {"E5_CONTA" ,cConta390 ,Nil},;
  					          {"E5_NUMCHEQ", cCheque390,Nil},;
							  {"E5_DATA"	, dDataBase,Nil},;
							  {"E5_DTDISPO", dDataBase ,Nil},;
							  {"E5_DTDIGIT", dDataBase,Nil},;
							  {"E5_VALOR"	, nValor390,Nil},;
							  {"E5_NATUREZ", cNatur390,Nil},;
						      {"E5_MOEDA"  , "01" ,Nil},;
						      {"E5_RECPAG" , "P",Nil},;
						      {"E5_BENEF",   cBenef390,Nil},;
							  {"E5_CLIFOR", cForn390,Nil},;
							  {"E5_LOJA", cLojaBen,Nil},;   
							  {"E5_TIPODOC", "DH",Nil},;
							  {"E5_HISTOR" , cHist390,Nil}}
  
                              MSExecAuto({|x,y,z| FinA100(x,y,z)},0,aFINA100,3)
                              
                   If lMsErroAuto

                      MostraErro()

                   EndIf 
                   
				    /*/
					Reclock( "SE5", .T. )
						SE5 -> E5_FILIAL  := cFilial
						SE5 -> E5_BANCO	:= cBanco390
						SE5 -> E5_AGENCIA := cAgencia390
						SE5 -> E5_CONTA	:= cConta390
						SE5 -> E5_RECPAG  := "P"
						SE5 -> E5_DATA 	:= dDataBase
						SE5 -> E5_HISTOR  := cHist390
						SE5 -> E5_BENEF	:= cBenef390
						SE5 -> E5_DTDIGIT := dDataBase
						SE5 -> E5_VALOR	:= nValor390
						SE5 -> E5_NUMCHEQ := cCheque390
						SE5 -> E5_NATUREZ := cNatur390
						SE5 -> E5_TIPODOC := "DH"
						SE5 -> E5_DTDISPO := E5_DATA  //DATA DISPONIVEL É A COMP. CHEQUE . POR ISSO FOI COMENTADO.
		            SE5 -> E5_CLIFOR  := cForn390
		            SE5 -> E5_LOJA    := cLojaBen					
					MsUnlock("SE5")
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Atualiza saldo bancario.								  ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                     
					// Retirado abaixo Deco 26/02/2004 para nao atualizar saldo Banco de cheque troco. voltado por vava 28/06/2004
					 AtuSalBco(cBanco390,cAgencia390,cConta390,SE5->E5_DATA,SE5->E5_VALOR,"-") 
				     /*/
				     
				 
				
			    EndIf  
				
		
			END TRANSACTION
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Monta Lan‡amento contabil.								  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cPadrao := '567'
			If (lPadrao := VerPadrao( cPadrao ) .and. mv_par03 == 1)
				nHdlPrv:=HeadProva(cLote,"FINA390",Substr(cUsuario,7,6),@cArquivo)
				nTotal+=DetProva(nHdlPrv,cPadrao,"FINA390",cLote)
				RodaProva(nHdlPrv,nTotal)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Envia para Lan‡amento Contabil 							  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cA100Incl(cArquivo,nHdlPrv,3,cLote,Iif(mv_par02==1,.T.,.F.),.F.)
				 
	 			RecLock("SEF")
					Replace EF_LA With "S"
				MsUnlock()							
			EndIf
			cCheque390 := Soma1(cCheque390)
		Next xx

	   cFIMCHEQ := cCheque390

		cQuery := "SELECT *, R_E_C_N_O_ AS NRECNO  "
		cQuery += "FROM "+RetSqlName("SE5")+" (NOLOCK) "
		cQuery += "WHERE E5_FILIAL = '"+xFilial("SE5")+"' "
		cQuery += "AND D_E_L_E_T_ = '' "
		cQuery += "AND E5_DATA = '"+Dtos(dDataBase)+"' "
		cQuery += "AND E5_BANCO = '"+cBanco390+"' "
		cQuery += "AND E5_AGENCIA = '"+cAgencia390+"' "
		cQuery += "AND E5_CONTA = '"+cConta390+"' "
		cQuery += "AND E5_NUMCHEQ BETWEEN '"+cINICHEQ+"' AND '"+cFIMCHEQ+"' "		
		cQuery += "AND E5_RECONC = 'x' "
		
		If (Select("MSE5") <> 0)
			dbSelectArea("MSE5")
			dbCloseArea()
		Endif
		
		TCQuery cQuery NEW ALIAS "MSE5"
	
		DbSelectArea("MSE5")
		DbGotop()
		While !Eof()		
			
			MsgStop("Registro ja Conciliado, avisar área TI!"+MSE5->E5_NUMCHEQ)
			
			DbSelectArea("SE5")
			DbGoto(MSE5->NRECNO)
			RecLock("SE5",.F.)
				SE5->E5_RECONC := " "
			MsUnLock("SE5")
			
			DbSelectArea("MSE5")
			MSE5->(DbSkip())
		EndDo		
	EndIf
EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Recupera a Integridade dos dados									  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MsUnlockAll()
dbSelectArea("SE2")
dbSetOrder(1)
dbGoTo( nSavRec )

Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³fa390Can	³ Autor ³ Alessandro Freire	  ³ Data ³ 18/04/96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Cancela cheques sobre titulo										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³fa390can()																  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³FINA390																	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function AGR093CAN()

LOCAL oDlg
LOCAL cAlias	 := Alias()
LOCAL nOrder	 := IndexOrd()
LOCAL nRec		 := Recno()
LOCAL lRetorna  := .F.
LOCAL lF390Canc := ExistBlock("F390CANC")
Local lCancelou := .F.

LOCAL nValor390                        // Incluido Deco 14/07/04 para cancelar contabilizacao 
LOCAL lPadrao,  cPadrao := "568"       // Incluido Deco 14/07/04 para cancelar contabilizacao 
LOCAL cArquivo, cComprobX              // Incluido Deco 14/07/04 para cancelar contabilizacao 
LOCAL nTotal	:= 0                    // Incluido Deco 14/07/04 para cancelar contabilizacao 
LOCAL nHdlPrv	:= 0                    // Incluido Deco 14/07/04 para cancelar contabilizacao 


PRIVATE cBanco390
PRIVATE cAgencia390
PRIVATE cConta390
PRIVATE cCheque390
PRIVATE nOpcA

cBanco390		:= CriaVar("EF_BANCO")
cAgencia390 	:= Criavar("EF_AGENCIA")
cConta390		:= Criavar("EF_CONTA")
cCheque390		:= Space( 06 ) // Ajustado para (06) pois o padrao (15) estava dando problemas apos 8.11 R3 - Deco 08/11/2006

While .T.

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se data do movimento n„o ‚ menor que data limite de ³
	//³ movimentacao no financeiro    										  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	If !DtMovFin()
		Exit
	Endif	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Procura no SEF o registro correspondente do SE2 posiciona no momento.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea( "SEF" )
	dbSetOrder( 3 )
	dbSeek( xFilial() 			+;
				SE2->E2_PREFIXO	+;
				SE2->E2_NUM 		+;
				SE2->E2_PARCELA	+;
				SE2->E2_TIPO	)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Procura no SEF o registro que contem o No. do Cheque ³
	//³ Considera Fornecedor na Chave								³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	While !Eof() .And. ;
	SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO == ;
	SEF->EF_PREFIXO+SEF->EF_TITULO+SEF->EF_PARCELA+SEF->EF_TIPO .And. ;
	(Empty( SEF->EF_NUM ) .or. SE2->E2_FORNECE != SEF->EF_FORNECE )
		dbSkip()
	EndDo
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Recebe dados do cheque a ser cancelado.							  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cBanco390	:= SEF->EF_BANCO
	cAgencia390 := SEF->EF_AGENCIA
	cConta390	:= SEF->EF_CONTA
	cCheque390	:= SEF->EF_NUM
	dData390 	:= SEF->EF_DATA
	nOpca := 0
	DEFINE MSDIALOG oDlg FROM 10, 5 TO 22, 46 TITLE OemToAnsi(STR0038)  //"Cancelar Cheque"
	@ 1.0,2	Say OemToAnsi(STR0040)  //"Banco : "
	@ 1.0,7.5 MSGET cBanco390 F3 "SA6" Valid Fa390Banco(1)

	@ 2.0,2	Say OemToAnsi(STR0041)  //"Agˆncia : "
	@ 2.0,7.5 MSGET cAgencia390	Valid Fa390Banco(2)

	@ 3.0,2	Say OemToAnsi(STR0042)  //"Conta : "
	@ 3.0,7.5 MSGET cConta390	Valid Fa390Banco(3)

	@ 4.0,2	Say OemToAnsi(STR0043)  //"N£m Cheque:"
	@ 4.0,7.5 MSGET cCheque390 	Valid Fa390Cheq(2)

	@.3,1 TO 5,20 OF oDlg

	DEFINE SBUTTON FROM 072,097 TYPE 1 ACTION (nOpca := 1,If(!Empty(cBanco390),oDlg:End(),nOpca:=0)) ENABLE OF oDlg
	DEFINE SBUTTON FROM 072,124.1 TYPE 2 ACTION oDlg:End() ENABLE OF oDlg

	ACTIVATE MSDIALOG oDlg CENTERED
        

	If nOpca == 1
      *
      * Caso database difente emissao cheque nao permite cancelamento
      *
      If SEF->EF_DATA <> dDataBase
        MsgStop ("Data emissao cheque diferente Data Base Microsiga")
        Exit
      Endif
      *
      * Verifica cheque ja cancelado
      *
      If SEF->EF_IMPRESS == 'C'
        MsgStop ("Cheque ja Cancelado")
        Exit
      Endif
 
		//Ponto de entrada para permissao ou nao do cancelamento do cheque
		If lF390Canc
			If !(ExecBlock("F390CANC",.F.,.F.))
				Exit
			Endif
		Endif
		
		BEGIN TRANSACTION
		   
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿  // Incluido Deco 14/07/04 para cancelar contabilizacao 
			//³ Monta Lan‡amento contabil.								  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cPadrao := '568'
			If (lPadrao := VerPadrao( cPadrao ) .and. mv_par03 == 1)
				nHdlPrv:=HeadProva(cLote,"FINA390",Substr(cUsuario,7,6),@cArquivo)
				nTotal+=DetProva(nHdlPrv,cPadrao,"FINA390",cLote)
				RodaProva(nHdlPrv,nTotal)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Envia para Lan‡amento Contabil 							  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cA100Incl(cArquivo,nHdlPrv,3,cLote,Iif(mv_par02==1,.T.,.F.),.F.)
			EndIf                                                        // Incluido Deco 14/07/04 para cancelar contabilizacao 

   	   // Grava cheque como nao impresso para ficar somente 1 registro no SE5 e nao aparecer na reconc. manual Feito Deco 22/09/2004
         RecLock("SEF",.F.)
         SEF->EF_IMPRESS := 'N'
         MsUnlock("SEF")

			lCancelou := fa390ver()

    	   // Grava cheque como cancelado para aparecer legenda preta na tela cheques Feito Deco 22/09/2004
			dbSelectArea( "SEF" )
			dbSetOrder(1)
			dbSeek(xFilial()+cBanco390+cAgencia390+cConta390+cCheque390)
			While !Eof() .And. SEF->EF_BANCO+SEF->EF_AGENCIA+SEF->EF_CONTA+SEF->EF_NUM == ;
			                   cBanco390+cAgencia390+cConta390+cCheque390
			   IF SEF->EF_DATA == dData390
	      	   // Grava cheque como cancelado para aparecer legenda preta na tela cheques Feito Deco 22/09/2004
	            RecLock("SEF",.F.)
	            SEF->EF_IMPRESS := 'C'
	            MsUnlock("SEF")
	         EndIf  
				dbSkip()
			EndDo
	
		END TRANSACTION
		
		If lCancelou != Nil .And. ! lCancelou
			// No retorno da Fa390Ver, o SE2 e o SEF estao posicionados nos
			// registros que foram invalidados.
			If Empty( SE2->E2_IMPCHEQ )
				Help( " ", 1, "AGR093AVS" )
			ElseIf SEF->EF_IMPRESS == "C"
				Help( " ", 1, "JA CANCELA")
			Endif	
		Endif

	ElseIf nOpca  == 2 .Or. nOpca == 0
		Exit
	Else
		Loop
	EndIf
EndDo

dbSelectArea( cAlias )
dbSetOrder( nOrder )
dbGoto( nRec )
Return( Nil )

****************************************************************************
*																									*
*							FUNCOES GENERICAS DO PROGRAMA 								*
*																									*
****************************************************************************
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³fA390Perg ³ Autor ³ Wagner Xavier 		  ³ Data ³ 26/05/92 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Ativa Parametros do Programa										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ 																			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Gen‚rico 																  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FA390PERG()
	Pergunte("FIN390",.T.)
Return	

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³fa390Natur³ Autor ³ Wagner Xavier 		  ³ Data ³ 21/03/94 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Valida natureza digitada.											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³fa390Natur() 															  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³FINA390																	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FA390NATUR( )
Local cAlias := Alias( )
Local lRet	 := .t.

If Empty( cNatur390 )
	Return ( .f. )
Endif

dbSelectArea( "SED" )
If !(dbSeek( cFilial + cNatur390 ) )
	 Help( " ",1,"fa390Natur" )
	 lRet := .f.
Endif

//Validacao extra do usuario
If lRet
	IF ExistBlock("F390NATU")
		lRet := ExecBlock("F390NATU",.f.,.f.)
	Endif
Endif	

dbSelectArea( cAlias )
Return lRet

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³fa390Forn ³ Autor ³ Wagner Xavier 		  ³ Data ³ 21/03/94 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Valida fornecedor digitado											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³fa390Forn()																  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³FINA390																	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FA390FORNECE( )
Local cAlias := Alias( )
Local lRet	 := .t.
Local lAltera := IIF(ProcName(3)== "FA390OK",.F.,.T.)
If Empty( cForn390 )
	Return ( .T. )
Endif
dbSelectArea( "SA2" )
If cForn390 != SA2->A2_COD
	If !(MsSeek( cFilial + cForn390 ) )
		Help( " ",1,"fa390Forn" )
		lRet := .f.
	End
Endif

If lAltera .or. Empty(cBenef390)
	cBenef390 := SA2->A2_NOME
Endif

If ExistBlock("F390BEN")
	cBenef390 :=ExecBlock("F390BEN",.F.,.F.,cBenef390)
Endif
If cPaisLoc == "COL"
   cLojaBen := SA2->A2_LOJA
Endif
dbSelectArea( cAlias )
Return lRet

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³FA390Ok	³ Autor ³ Pilar S. Albaladejo   ³ Data ³ 20/12/96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se dados essenciais foram digitados 				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FINA390																	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Fa390Ok(oDlg)
Local nX
Local lRet := .T.

For nX := 1 To Len(oDlg:aControls)
	If ValType(oDlg:aControls[nX]) == "O" .And.;
		!Empty(oDlg:aControls[nX]:bValid)
		
		lRet:=Eval(oDlg:aControls[nX]:bValid)
		If ValType(lRet) != "L"
			lRet := .T.
		Endif	
		If !lRet
//			Help(" ",1,"Fa390Erro1")
//			Exit // Sai no primeiro campo invalido
		Endif	
		
	Endif
Next

If lRet .And. ExistBlock("FA390TOK")
	lRet := Execblock("FA390TOK",.F.,.F.,oDlg)
Endif
Return lRet
